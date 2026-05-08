<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.noahstudio.model.*, com.noahstudio.util.FileHandler, java.util.*" %>
<%
    HttpSession sess = request.getSession(false);
    if (sess == null || (!"photographer".equals(sess.getAttribute("role")) && !"videographer".equals(sess.getAttribute("role")))) {
        response.sendRedirect("login.jsp");
        return;
    }

    String uid = (String) sess.getAttribute("userId");
    FileHandler.init(application.getRealPath("/") + "data");
    
    // 1. Identify bookings assigned to this staff member
    Set<String> myBookingIds = new HashSet<>();
    for (String bl : FileHandler.readLines("bookings.txt")) {
        Booking b = Booking.fromFileString(bl);
        if (b != null && uid.equals(b.getStaffId())) {
            myBookingIds.add(b.getId());
        }
    }

    // 2. Filter payments for those bookings
    List<Payment> myPayments = new ArrayList<>();
    double totalEarned = 0;
    for (String l : FileHandler.readLines("payments.txt")) {
        Payment p = Payment.fromFileString(l);
        if (p != null && myBookingIds.contains(p.getBookingId())) {
            myPayments.add(p);
            if ("Paid".equals(p.getStatus())) totalEarned += p.getAmount();
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My Payments — Noah Studio</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body style="background: var(--bg-primary);">

<div class="dashboard-layout">
    <jsp:include page="admin-sidebar.jsp" />

    <main class="main-content">
        <header class="content-header" style="margin-bottom: 3rem;">
            <span class="section-tag">Finance</span>
            <h1 style="font-size: 2.5rem; margin: 0;">My <span class="serif" style="color:var(--accent); text-transform:none;">Earnings</span></h1>
        </header>

        <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 2rem; margin-bottom: 3rem;">
            <div style="background: #0a0a0a; padding: 2rem; border-radius: 20px; border: 1px solid #1a1a1a;">
                <h4 style="font-size: 0.7rem; color: var(--text-muted); text-transform: uppercase; letter-spacing: 1px; margin-bottom: 0.5rem;">Total Earnings</h4>
                <div style="font-size: 2rem; font-weight: 800; color: var(--accent);">LKR <%= String.format("%.0f", totalEarned) %></div>
            </div>
            <div style="background: #0a0a0a; padding: 2rem; border-radius: 20px; border: 1px solid #1a1a1a;">
                <h4 style="font-size: 0.7rem; color: var(--text-muted); text-transform: uppercase; letter-spacing: 1px; margin-bottom: 0.5rem;">Total Transactions</h4>
                <div style="font-size: 2rem; font-weight: 800; color: var(--accent);"><%= myPayments.size() %></div>
            </div>
        </div>

        <div class="card card-table">
            <table class="ns-table">
                <thead>
                    <tr><th>ID</th><th>Booking</th><th>Amount</th><th>Method</th><th>Status</th><th>Date</th></tr>
                </thead>
                <tbody>
                    <% if (myPayments.isEmpty()) { %>
                        <tr><td colspan="6" style="text-align:center; padding:3rem; color:var(--text-muted);">No payment records found.</td></tr>
                    <% } else { %>
                        <% for (Payment p : myPayments) { %>
                            <tr>
                                <td style="color:var(--accent); font-weight: 800;"><%= p.getId() %></td>
                                <td><%= p.getBookingId() %></td>
                                <td>LKR <%= String.format("%.0f", p.getAmount()) %></td>
                                <td><%= p.getMethod() %></td>
                                <td>
                                    <span class="role-badge <%= "Paid".equals(p.getStatus()) ? "badge-success" : "badge-muted" %>" style="font-size:0.6rem;">
                                        <%= p.getStatus().toUpperCase() %>
                                    </span>
                                </td>
                                <td><%= p.getPaidAt() %></td>
                            </tr>
                        <% } %>
                    <% } %>
                </tbody>
            </table>
        </div>
    </main>
</div>

</body>
</html>
