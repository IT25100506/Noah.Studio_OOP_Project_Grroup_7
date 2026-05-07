<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.noahstudio.model.*, com.noahstudio.util.FileHandler, java.util.*, java.time.LocalDate" %>
<%
    HttpSession sess = request.getSession(false);
    if (sess == null || !"videographer".equals(sess.getAttribute("role"))) {
        response.sendRedirect("login.jsp");
        return;
    }

    String uid = (String) sess.getAttribute("userId");
    String uName = (String) sess.getAttribute("fullName");
    String role = (String) sess.getAttribute("role");
    
    FileHandler.init(application.getRealPath("/") + "data");
    
    // Fetch stats for Overview
    List<Booking> myJobs = new ArrayList<>();
    int pendingJobs = 0;
    for (String l : FileHandler.readLines("bookings.txt")) {
        Booking b = Booking.fromFileString(l);
        if (b != null && uid.equals(b.getStaffId())) {
            myJobs.add(b);
            if ("Confirmed".equals(b.getStatus())) pendingJobs++;
        }
    }
    
    List<PortfolioItem> myGallery = new ArrayList<>();
    for (String l : FileHandler.readLines("portfolio.txt")) {
        PortfolioItem pf = PortfolioItem.fromFileString(l);
        if (pf != null && uid.equals(pf.getStaffId())) myGallery.add(pf);
    }
    
    double avgRating = 0;
    int reviewCount = 0;
    for (String l : FileHandler.readLines("reviews.txt")) {
        Review r = Review.fromFileString(l);
        if (r != null && uid.equals(r.getStaffId())) {
            reviewCount++;
            avgRating += r.getRating();
        }
    }
    if (reviewCount > 0) avgRating /= reviewCount;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>VIDEOGRAPHER PANEL — Noah Studio</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        .stat-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 2rem; margin-bottom: 3rem; }
        .stat-card { background: #0a0a0a; padding: 2rem; border-radius: 20px; border: 1px solid #1a1a1a; }
        .stat-card h4 { font-size: 0.7rem; color: var(--text-muted); text-transform: uppercase; letter-spacing: 1px; margin-bottom: 0.5rem; }
        .stat-card .val { font-size: 2rem; font-weight: 800; color: var(--accent); }
        .job-card { background: #0a0a0a; border: 1px solid #1a1a1a; border-radius: 16px; padding: 1.5rem; margin-bottom: 1rem; display: flex; justify-content: space-between; align-items: center; transition: 0.3s; }
        .job-card:hover { border-color: var(--accent); transform: translateX(5px); }
    </style>
</head>
<body style="background: var(--bg-primary);">
    <div class="dashboard-layout">
        <jsp:include page="admin-sidebar.jsp" />
        
        <main class="main-content">
            <header class="content-header" style="margin-bottom: 4rem;">
                <span class="section-tag" style="color:var(--accent)">Cinematic Videographer</span>
                <h1 style="font-size: 3rem;">Director <span style="color:var(--accent)"><%= uName.split(" ")[0] %></span></h1>
                <p style="color:var(--text-muted)">Your cinematic production hub. Manage shoots and view performance metrics.</p>
            </header>
            
            <div class="stat-grid">
                <div class="stat-card"><h4>Production Jobs</h4><div class="val"><%= myJobs.size() %></div></div>
                <div class="stat-card"><h4>Confirmed</h4><div class="val"><%= pendingJobs %></div></div>
                <div class="stat-card"><h4>Reel Clips</h4><div class="val"><%= myGallery.size() %></div></div>
                <div class="stat-card"><h4>Auteur Score</h4><div class="val"><%= String.format("%.1f", avgRating) %> <i class="fa fa-star" style="font-size: 1rem;"></i></div></div>
            </div>
            
            <div class="card">
                <h3 style="margin-bottom: 2rem;">Production Schedule</h3>
                <% if (myJobs.isEmpty()) { %>
                    <p style="color:var(--text-muted)">No filming assignments found.</p>
                <% } else { %>
                    <% for (Booking b : myJobs) { %>
                        <div class="job-card">
                            <div>
                                <div style="font-weight: 800; font-size: 1.1rem;"><%= b.getServicePackageName() %></div>
                                <div style="color:var(--text-muted); font-size: 0.8rem;"><%= b.getEventDate() %> • <%= b.getEventLocation() %></div>
                            </div>
                            <span class="role-badge" style="background: rgba(191,126,103,0.1); color: var(--accent); border: 1px solid var(--accent);">
                                <%= b.getStatus().toUpperCase() %>
                            </span>
                        </div>
                    <% } %>
                <% } %>
            </div>
        </main>
    </div>
</body>
</html>
