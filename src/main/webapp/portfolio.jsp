<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.noahstudio.model.*, java.util.*" %>
<%
    List<PortfolioItem> items = (List<PortfolioItem>) request.getAttribute("portfolioItems");
    if (items == null) {
        response.sendRedirect("portfolio?action=list");
        return;
    }
    String activeCategory = (String) request.getAttribute("activeCategory");
    HttpSession userSession = request.getSession(false);
    String loggedRole = (userSession != null) ? (String) userSession.getAttribute("role") : null;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Portfolio — Noah Studio</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        .filter-nav { display: flex; justify-content: center; gap: 2rem; margin-bottom: 4rem; }
        .filter-nav a { font-size: 0.8rem; font-weight: 800; text-transform: uppercase; letter-spacing: 2px; color: var(--text-muted); transition: 0.3s; }
        .filter-nav a:hover, .filter-nav a.active { color: var(--accent); }
        
        .portfolio-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(350px, 1fr)); gap: 2rem; padding: 0 5%; margin-bottom: 5rem; }
        .portfolio-card { position: relative; overflow: hidden; border-radius: 12px; background: #0c0c0c; border: 1px solid rgba(255,255,255,0.05); }
        
        /* Polymorphic rendering handles the internal media (img or video) */
        .portfolio-media { width: 100%; height: 350px; position: relative; overflow: hidden; }
        .portfolio-media img { width: 100%; height: 100%; object-fit: cover; transition: transform 0.8s ease; }
        .portfolio-card:hover .portfolio-media img { transform: scale(1.05); }
        
        .video-media { background: #000; display: flex; align-items: center; justify-content: center; }
        .video-media video { width: 100%; height: 100%; object-fit: cover; }
        .video-media .play-overlay { position: absolute; color: rgba(255,255,255,0.8); font-size: 3rem; pointer-events: none; }
        .iframe-container iframe { width: 100%; height: 100%; border: none; }
        
        .portfolio-overlay { position: absolute; bottom: 0; left: 0; width: 100%; padding: 2rem; background: linear-gradient(to top, rgba(0,0,0,0.9), transparent); display: flex; flex-direction: column; justify-content: flex-end; }
        .portfolio-overlay h3 { font-size: 1.2rem; margin: 0.5rem 0; color: #fff; text-transform: uppercase; letter-spacing: 1px; }
        .staff-credit { font-size: 0.75rem; color: #ccc; font-style: italic; font-family: 'Playfair Display', serif; }
    </style>
</head>
<body>
<nav class="navbar scrolled">
    <a class="navbar-brand" href="index.jsp">Noah<span>Studio</span></a>
    <ul class="nav-links">
        <li><a href="index.jsp#home">Home</a></li>
        <li><a href="index.jsp#about">About</a></li>
        <li><a href="portfolio?action=list" class="active">Portfolio</a></li>
        <li><a href="index.jsp#packages">Packages</a></li>
        <li><a href="index.jsp#testimonials">Review</a></li>
        <li><a href="index.jsp#contact">Contact</a></li>
        <% if (loggedRole != null) { %>
            <li><a href="booking?action=list">My Bookings</a></li>
            <% if ("admin".equals(loggedRole)) { %><li><a href="admin-dashboard.jsp">Dashboard</a></li><% } %>
            <% if ("photographer".equals(loggedRole)) { %><li><a href="photographer-dashboard.jsp">Dashboard</a></li><% } %>
            <% if ("videographer".equals(loggedRole)) { %><li><a href="videographer-dashboard.jsp">Dashboard</a></li><% } %>
            <li><a href="user?action=logout" class="btn-nav">Logout</a></li>
        <% } else { %>
            <li><a href="login.jsp" class="btn-nav">Login</a></li>
        <% } %>
    </ul>
</nav>

<div class="page-hero" style="padding-top: 10rem; padding-bottom: 3rem; text-align: center;">
    <span class="section-tag">Visuals</span>
    <h1>The <span style="color:var(--accent)">Portfolio</span></h1>
</div>

<section style="padding-top:0;">
    <div class="filter-nav" style="margin-bottom: 5rem;">
        <a href="portfolio?action=list" class="<%= activeCategory == null ? "active" : "" %>">All Categories</a>
        <a href="portfolio?action=list&category=Wedding" class="<%= "Wedding".equals(activeCategory) ? "active" : "" %>">Wedding</a>
        <a href="portfolio?action=list&category=Events" class="<%= "Events".equals(activeCategory) ? "active" : "" %>">Events</a>
        <a href="portfolio?action=list&category=Portrait" class="<%= "Portrait".equals(activeCategory) ? "active" : "" %>">Portrait</a>
    </div>

    <!-- 📸 Photography Section -->
    <div class="container" style="padding: 0 5%; margin-bottom: 3rem;">
        <span class="section-tag" style="margin-bottom: 0.5rem;">Visual Art</span>
        <h2 style="font-size: 2rem; margin-bottom: 3rem;">Photography <span style="color:var(--accent)">Portfolio</span></h2>
    </div>
    <div class="portfolio-grid">
        <% 
            boolean hasPhotos = false;
            for (PortfolioItem item : items) { 
                if ("Photo".equalsIgnoreCase(item.getType())) {
                    hasPhotos = true;
        %>
        <div class="portfolio-card">
            <%= item.renderPreviewHTML() %>
            <div class="portfolio-overlay">
                <span class="section-tag" style="font-size:0.6rem;"><%= item.getCategory() %></span>
                <h3><%= item.getTitle() %></h3>
                <div class="staff-credit">Shot by <%= item.getStaffName() %></div>
            </div>
        </div>
        <%      }
            } 
            if (!hasPhotos) { 
        %>
            <div style="grid-column: 1/-1; text-align: center; padding: 4rem; color: var(--text-muted); opacity: 0.5;">No photography items in this category.</div>
        <% } %>
    </div>

    <!-- 🎥 Cinematography Section -->
    <div class="container" style="padding: 0 5%; margin-top: 8rem; margin-bottom: 3rem;">
        <span class="section-tag" style="margin-bottom: 0.5rem;">Motion Picture</span>
        <h2 style="font-size: 2rem; margin-bottom: 3rem;">Cinematography <span style="color:var(--accent)">Portfolio</span></h2>
    </div>
    <div class="portfolio-grid" style="margin-bottom: 10rem;">
        <% 
            boolean hasVideos = false;
            for (PortfolioItem item : items) { 
                if ("Video".equalsIgnoreCase(item.getType())) {
                    hasVideos = true;
        %>
        <div class="portfolio-card">
            <%= item.renderPreviewHTML() %>
            <div class="portfolio-overlay">
                <span class="section-tag" style="font-size:0.6rem;"><%= item.getCategory() %></span>
                <h3><%= item.getTitle() %></h3>
                <div class="staff-credit">Directed by <%= item.getStaffName() %></div>
            </div>
        </div>
        <%      }
            } 
            if (!hasVideos) { 
        %>
            <div style="grid-column: 1/-1; text-align: center; padding: 4rem; color: var(--text-muted); opacity: 0.5;">No cinematography items in this category.</div>
        <% } %>
    </div>
</section>
</body>
</html>
