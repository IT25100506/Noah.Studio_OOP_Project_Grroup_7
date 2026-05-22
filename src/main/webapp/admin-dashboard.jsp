<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.noahstudio.model.*, com.noahstudio.util.FileHandler, java.util.*, java.util.stream.Collectors" %>
<%
    // 1. INITIALIZATION & SECURITY
    HttpSession sess = request.getSession(false);
    if (sess == null || !"admin".equals(sess.getAttribute("role"))) { 
        response.sendRedirect("login.jsp"); 
        return; 
    }
    
    FileHandler.init(application.getRealPath("/") + "data");
    
    // 2. DATA LOADING
    List<User> users = new ArrayList<>();
    for (String l : FileHandler.readLines("users.txt")) { 
        User u = User.fromFileString(l); 
        if (u != null) users.add(u); 
    }
    
    List<Booking> bookings = new ArrayList<>();
    for (String l : FileHandler.readLines("bookings.txt")) { 
        Booking b = Booking.fromFileString(l); 
        if (b != null) bookings.add(b); 
    }
    
    List<Payment> payments = new ArrayList<>();
    for (String l : FileHandler.readLines("payments.txt")) { 
        Payment p = Payment.fromFileString(l); 
        if (p != null) payments.add(p); 
    }
    
    // 3. ANALYTICS CALCULATIONS (JAVA ONLY)
    double totalRevenue = payments.stream().filter(p -> "Paid".equals(p.getStatus())).mapToDouble(Payment::getAmount).sum();
    double pendingRevenue = payments.stream().filter(p -> "Pending".equals(p.getStatus())).mapToDouble(Payment::getAmount).sum();
    double refundedRevenue = payments.stream().filter(p -> "Refunded".equals(p.getStatus())).mapToDouble(Payment::getAmount).sum();
    
    Map<String, Long> bookingByStatus = bookings.stream().collect(Collectors.groupingBy(Booking::getStatus, Collectors.counting()));
    long totalBookings = bookings.size();
    long pendingCount = bookings.stream().filter(b -> "Pending".equalsIgnoreCase(b.getStatus())).count();
    long confirmedCount = bookings.stream().filter(b -> "Confirmed".equalsIgnoreCase(b.getStatus())).count();
    
    // Package Analytics
    List<ServicePackage> allPkgs = new ArrayList<>();
    for (String l : FileHandler.readLines("packages.txt")) { 
        ServicePackage p = ServicePackage.fromFileString(l); 
        if (p != null) allPkgs.add(p); 
    }
    long totalPkgs = allPkgs.size();
    long photoPkgs = allPkgs.stream().filter(p -> "photography".equalsIgnoreCase(p.getType())).count();
    long videoPkgs = allPkgs.stream().filter(p -> "videography".equalsIgnoreCase(p.getType())).count();
    long activePkgs = allPkgs.stream().filter(ServicePackage::isActive).count();
    long inactivePkgs = totalPkgs - activePkgs;
    
    // Pre-format strings to avoid complex JSP expressions in HTML
    String displayRevenue = String.format("%,.0f", totalRevenue);
    String displayPendingRevenue = String.format("%,.0f", pendingRevenue);
    String displayRefundedRevenue = String.format("%,.0f", refundedRevenue);
    String displayAvgValue = totalBookings > 0 ? String.format("%,.0f", totalRevenue / totalBookings) : "0";
    
    double revenueRatio = (totalRevenue + pendingRevenue) > 0 ? (totalRevenue / (totalRevenue + pendingRevenue) * 100) : 0;
    int revenueBarWidth = (int)revenueRatio;
    int pendingBarWidth = 100 - revenueBarWidth;
    
    double convRate = totalBookings > 0 ? ((bookingByStatus.getOrDefault("Confirmed", 0L) + bookingByStatus.getOrDefault("Completed", 0L)) * 100.0 / totalBookings) : 0;
    String displayConvRate = String.format("%.1f", convRate);

    List<Booking> recentBookings = bookings.stream()
        .sorted(Comparator.comparing(Booking::getId).reversed())
        .limit(4)
        .collect(Collectors.toList());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Executive Dashboard — Noah Studio</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        /* Modern CSS variables for dynamic elements to satisfy linters */
        :root { --accent-rgb: 209, 120, 95; }
        
        .stat-card { position: relative; overflow: hidden; border: 1px solid rgba(255,255,255,0.05); background: var(--bg-secondary); padding: 2rem; transition: var(--transition); }
        .stat-card:hover { border-color: var(--accent); transform: translateY(-5px); }
        .stat-card i { position: absolute; right: -10px; bottom: -10px; font-size: 5rem; opacity: 0.05; color: var(--accent); }
        

        
        .analytics-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 2rem; margin-bottom: 3rem; }
        .chart-container { padding: 2.5rem; background: var(--bg-secondary); border: 1px solid rgba(255,255,255,0.05); }
        
        .bar-row { margin-bottom: 1.5rem; }
        .bar-label { display: flex; justify-content: space-between; margin-bottom: 0.5rem; font-size: 0.75rem; text-transform: uppercase; letter-spacing: 1px; color: var(--text-muted); }
        .bar-bg { height: 6px; background: rgba(255,255,255,0.05); border-radius: 3px; overflow: hidden; }
        .bar-fill { height: 100%; transition: width 1.5s cubic-bezier(0.4, 0, 0.2, 1); }
        
        .activity-item { display: flex; align-items: center; gap: 1.5rem; padding: 1.5rem 0; border-bottom: 1px solid rgba(255,255,255,0.05); }
        .activity-icon { width: 40px; height: 40px; border-radius: 50%; background: var(--bg-primary); border: 1px solid var(--accent); display: flex; align-items: center; justify-content: center; color: var(--accent); font-size: 0.8rem; }
        
        .stat-highlight { font-size: 2rem; font-weight: 800; color: var(--accent); margin: 0.5rem 0 1.5rem; }
    </style>
</head>
<body>
<div class="dashboard-layout">
    <jsp:include page="admin-sidebar.jsp" />

    <main class="main-content">
        <header style="display:flex; justify-content: space-between; align-items: flex-end; margin-bottom: 3rem;">
            <div>
                <span class="section-tag">Executive Command</span>
                <h1 style="font-size: 2.5rem; margin: 0;">Noah <span class="serif" style="color:var(--accent); text-transform:none;">Dashboard</span></h1>
            </div>
            <div style="text-align: right;">
                <div style="font-size: 0.7rem; color: var(--text-muted); letter-spacing: 2px;"><%= new java.text.SimpleDateFormat("EEEE, MMM dd yyyy").format(new Date()) %></div>
                <div class="status-badge status-online" style="justify-content: flex-end; margin-top: 0.5rem;"><i class="fa fa-circle"></i> System Active</div>
            </div>
        </header>



        <div style="margin-bottom: 2rem;">
            <span class="section-tag">Financial Summary</span>
            <h2 style="font-size: 1.5rem; margin-top: 0.5rem;">Revenue <span style="color:var(--accent)">Overview</span></h2>
        </div>
        <div style="display:grid; grid-template-columns: repeat(3, 1fr); gap: 1.5rem; margin-bottom: 4rem;">
            <div class="card stat-card">
                <span class="section-tag" style="font-size: 0.6rem;">Total Revenue Collected</span>
                <div style="font-size: 1.8rem; font-weight: 800; margin-top: 0.5rem; color: #4caf50;">LKR <%= displayRevenue %></div>
                <i class="fa fa-wallet"></i>
            </div>
            <div class="card stat-card">
                <span class="section-tag" style="font-size: 0.6rem;">Total Pending Payments</span>
                <div style="font-size: 1.8rem; font-weight: 800; margin-top: 0.5rem; color: #ff9800;">LKR <%= displayPendingRevenue %></div>
                <i class="fa fa-hourglass-half"></i>
            </div>
            <div class="card stat-card">
                <span class="section-tag" style="font-size: 0.6rem;">Total Refunds</span>
                <div style="font-size: 1.8rem; font-weight: 800; margin-top: 0.5rem; color: var(--danger);">LKR <%= displayRefundedRevenue %></div>
                <i class="fa fa-hand-holding-dollar"></i>
            </div>
        </div>

        <div class="analytics-grid">
            <div class="chart-container">
                <span class="section-tag" style="margin-bottom: 2rem;">Financial Intelligence</span>
                <h3 style="font-size: 1rem; margin-bottom: 1rem;">Revenue Realization</h3>
                <div class="stat-highlight">LKR <%= displayRevenue %></div>
                
                <div class="bar-row">
                    <div class="bar-label"><span>Paid Revenue</span><span><%= revenueBarWidth %>%</span></div>
                    <div class="bar-bg">
                        <div class="bar-fill" <%= "style=\"width: " + revenueBarWidth + "%; background: var(--accent);\"" %>></div>
                    </div>
                </div>
                <div class="bar-row">
                    <div class="bar-label"><span>Pending (Projected)</span><span><%= pendingBarWidth %>%</span></div>
                    <div class="bar-bg">
                        <div class="bar-fill" <%= "style=\"width: " + pendingBarWidth + "%; background: #333;\"" %>></div>
                    </div>
                </div>
                <div class="bar-row" style="margin-top: 1.5rem; padding-top: 1.5rem; border-top: 1px solid rgba(255,255,255,0.05);">
                    <div class="bar-label" style="color: var(--danger);"><span>Refunded Amount</span><span>LKR <%= displayRefundedRevenue %></span></div>
                </div>
            </div>

            <div class="chart-container">
                <span class="section-tag" style="margin-bottom: 2rem;">Operational Health</span>
                <h3 style="font-size: 1rem; margin-bottom: 1rem;">Booking Distribution</h3>
                <div style="margin-top: 1rem;">
                    <% 
                        String[] statuses = {"Confirmed", "Pending", "Cancelled", "Completed"};
                        for(String status : statuses) {
                            long count = bookingByStatus.getOrDefault(status, 0L);
                            int pct = totalBookings > 0 ? (int)(count * 100 / totalBookings) : 0;
                            String color = status.equals("Confirmed") ? "var(--success)" : 
                                           status.equals("Pending") ? "var(--accent)" : 
                                           status.equals("Cancelled") ? "var(--danger)" : "#555";
                    %>
                    <div class="bar-row">
                        <div class="bar-label"><span><%= status %></span><span><%= count %></span></div>
                        <div class="bar-bg">
                            <div class="bar-fill" <%= "style=\"width: " + pct + "%; background: " + color + ";\"" %>></div>
                        </div>
                    </div>
                    <% } %>
                </div>
            </div>
        </div>

        <div style="display:grid; grid-template-columns: 2fr 1.2fr; gap: 2rem;">
            <div class="card">
                <div style="display:flex; justify-content: space-between; align-items: center; margin-bottom: 2rem;">
                    <h3 style="font-size: 1rem;">Recent Activity</h3>
                    <a href="booking-management.jsp" style="font-size: 0.7rem; color: var(--accent); letter-spacing: 1px;">MANAGE ALL</a>
                </div>
                <div class="activity-feed">
                    <% for(Booking b : recentBookings) { %>
                    <div class="activity-item">
                        <div class="activity-icon"><i class="fa fa-calendar-plus"></i></div>
                        <div style="flex:1">
                            <div style="font-size: 0.9rem; font-weight: 600;">New Booking Request</div>
                            <div style="font-size: 0.75rem; color: var(--text-muted);"><%= b.getEventType() %> • Client #<%= b.getClientId() %></div>
                        </div>
                        <div style="font-size: 0.7rem; color: var(--accent); font-weight: 700;"><%= b.getStatus() %></div>
                    </div>
                    <% } %>
                </div>
            </div>

            <div class="card" style="text-align: center; display: flex; flex-direction: column; justify-content: center;">
                <div style="font-size: 0.7rem; color: var(--accent); letter-spacing: 3px; margin-bottom: 2rem;">QUICK METRICS</div>
                <div style="margin-bottom: 2.5rem;">
                    <div style="font-size: 2.5rem; font-weight: 800;"><%= displayConvRate %>%</div>
                    <div style="font-size: 0.6rem; color: var(--text-muted); letter-spacing: 1px;">CONVERSION RATE</div>
                </div>
                <div>
                    <div style="font-size: 1.5rem; font-weight: 800; color: var(--danger);">LKR <%= displayPendingRevenue %></div>
                    <div style="font-size: 0.6rem; color: var(--text-muted); letter-spacing: 1px;">UNPAID INVOICES</div>
                </div>
            </div>
        </div>
    </main>
</div>
</body>
</html>