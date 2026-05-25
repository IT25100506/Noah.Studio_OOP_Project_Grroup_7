<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.noahstudio.model.*" %>
<%
    PortfolioItem item = (PortfolioItem) request.getAttribute("portfolioItem");
    if (item == null) {
        response.sendRedirect("portfolio?action=list");
        return;
    }
    HttpSession userSession = request.getSession(false);
    String loggedRole = (userSession != null) ? (String) userSession.getAttribute("role") : null;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title><%= item.getTitle() %> — Noah Studio</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        .detail-container { max-width: 900px; margin: 10rem auto 5rem; padding: 2rem; background: #0c0c0c; border-radius: 12px; border: 1px solid rgba(255,255,255,0.05); }
        .detail-media { width: 100%; max-height: 600px; border-radius: 8px; overflow: hidden; margin-bottom: 2rem; background: #000; }
        .detail-media img, .detail-media video, .detail-media iframe { width: 100%; height: 100%; object-fit: contain; }
        .detail-header { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 1rem; border-bottom: 1px solid rgba(255,255,255,0.1); padding-bottom: 1rem; }
        .detail-meta { display: flex; gap: 1rem; color: var(--text-muted); font-size: 0.85rem; margin-bottom: 1rem; }
        .detail-description { color: #ccc; line-height: 1.6; }
    </style>
</head>
<body>
<nav class="navbar scrolled">
    <a class="navbar-brand" href="index.jsp">Noah<span>Studio</span></a>
    <ul class="nav-links">
        <li><a href="portfolio?action=list" class="btn-outline"><i class="fa fa-arrow-left"></i> Back to Gallery</a></li>
    </ul>
</nav>

<div class="detail-container">
    <div class="detail-media">
        <% if ("Photo".equalsIgnoreCase(item.getType())) { %>
            <img src="<%= item.getMediaUrl() %>" alt="<%= item.getTitle() %>">
        <% } else { 
            String url = item.getMediaUrl();
            if (url.contains("youtube.com/embed/")) {
        %>
            <iframe src="<%= url %>" allowfullscreen></iframe>
        <%  } else { %>
            <video src="<%= url %>" controls autoplay></video>
        <%  }
        } %>
    </div>
    
    <div class="detail-header">
        <div>
            <span class="section-tag" style="font-size:0.7rem;"><%= item.getCategory() %></span>
            <h1 style="font-size: 2.5rem; margin-top:0.5rem;"><%= item.getTitle() %></h1>
        </div>
        <div style="text-align: right;">
            <div style="font-size: 1.2rem; color: var(--accent);"><i class="fa fa-eye"></i> <%= item.getViews() %> Views</div>
        </div>
    </div>
    
    <div class="detail-meta">
        <span><i class="fa fa-user"></i> <%= item.getStaffName() %>
            <% 
                int totalRating = 0;
                int ratingCount = 0;
                for(String l : com.noahstudio.util.FileHandler.readLines("reviews.txt")) {
                    com.noahstudio.model.Review r = com.noahstudio.model.Review.fromFileString(l);
                    if (r != null && r.getStaffId().equals(item.getStaffId())) {
                        totalRating += r.getRating();
                        ratingCount++;
                    }
                }
                if (ratingCount > 0) {
                    double avg = (double)totalRating / ratingCount;
            %>
                <span style="color:var(--accent); margin-left: 0.5rem; font-size: 0.8rem; font-weight: bold;"><i class="fa fa-star"></i> <%= String.format("%.1f", avg) %></span>
            <% } %>
        </span>
        <span><i class="fa fa-calendar"></i> <%= item.getDate() %></span>
        <span><i class="fa <%= "Photo".equalsIgnoreCase(item.getType()) ? "fa-camera" : "fa-video" %>"></i> <%= item.getType() %></span>
    </div>
    
    <div class="detail-description">
        <p><%= item.getDescription() %></p>
    </div>
</div>
</body>
</html>
