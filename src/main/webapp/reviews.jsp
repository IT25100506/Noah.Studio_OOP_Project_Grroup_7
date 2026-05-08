<%-- Feedback and Review Management Module - Owned by IT25100494 --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.noahstudio.model.*, java.util.*" %>
<%
    List<Review> reviews = (List<Review>) request.getAttribute("reviews");
    if (reviews == null) {
        response.sendRedirect("review?action=list");
        return;
    }
    
    HttpSession sess = request.getSession(false);
    String loggedRole = (sess != null) ? (String) sess.getAttribute("role") : null;
    String uid = (sess != null) ? (String) sess.getAttribute("userId") : null;
    String success = request.getParameter("success");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Client Love — Noah Studio</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        .reviews-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(400px, 1fr)); gap: 2.5rem; padding: 0 5%; margin-bottom: 5rem; }
        .review-card { 
            position: relative; background: #0c0c0c; border: 1px solid rgba(255,255,255,0.05); 
            padding: 3rem; border-radius: 12px; transition: 0.4s ease; height: fit-content;
        }
        .review-card:hover { border-color: rgba(168,130,255,0.3); transform: translateY(-5px); box-shadow: 0 20px 40px rgba(0,0,0,0.4); }
        .quote-icon { position: absolute; top: 2rem; right: 2rem; color: var(--accent); opacity: 0.1; font-size: 2rem; }
        .star-rating { color: var(--accent); margin-bottom: 1.5rem; font-size: 0.8rem; }
        .client-info h4 { font-size: 1rem; text-transform: uppercase; letter-spacing: 2px; margin: 0; }
        .client-info span { font-size: 0.7rem; color: var(--text-muted); margin-top: 0.5rem; display: block; }
        .verified-pill { 
            background: rgba(76, 175, 80, 0.1); color: #4caf50; font-size: 0.6rem; 
            padding: 0.4rem 0.8rem; border-radius: 100px; font-weight: 800; text-transform: uppercase; letter-spacing: 1px;
        }
    </style>
</head>
<body>

<nav class="navbar scrolled">
    <a class="navbar-brand" href="index.jsp">Noah<span>Studio</span></a>
    <ul class="nav-links">
        <li><a href="index.jsp#home">Home</a></li>
        <li><a href="index.jsp#about">About</a></li>
        <li><a href="portfolio?action=list">Portfolio</a></li>
        <li><a href="package?action=list">Packages</a></li>
        <li><a href="review?action=list" class="active">Review</a></li>
        <li><a href="index.jsp#contact">Contact</a></li>
        <% if (loggedRole != null) { %>
            <li><a href="booking?action=list">My Dashboard</a></li>
            <li><a href="user?action=logout" class="btn-nav">Logout</a></li>
        <% } else { %>
            <li><a href="login.jsp" class="btn-nav">Login</a></li>
        <% } %>
    </ul>
</nav>

<div class="page-hero" style="padding-top: 10rem; padding-bottom: 5rem; text-align: center;">
    <span class="section-tag">Social Proof</span>
    <h1>Client <span style="color:var(--accent)">Love</span></h1>
    <p style="color: var(--text-muted); max-width: 600px; margin: 1.5rem auto 0;">The stories of our journeys together, captured in their own words.</p>
</div>

<section style="padding-top:0;">
    <div class="container" style="padding: 0 5%; margin-bottom: 4rem;">
        <% if (success != null) { %>
            <div class="alert alert-success" style="margin-bottom: 3rem; background: rgba(76,175,80,0.1); border: 1px solid #4caf50; color: #4caf50; padding: 1.25rem; border-radius: 12px; font-size: 0.85rem;">
                <i class="fa fa-check-circle"></i> <%= success %>
            </div>
        <% } %>
        
        <div style="display:flex; justify-content: space-between; align-items: flex-end; margin-bottom: 1rem;">
            <div>
                <span class="section-tag" style="margin-bottom: 0.5rem;">Archive</span>
                <h2 style="font-size: 2rem;">All <span style="color:var(--accent)">Testimonials</span></h2>
            </div>
            <% if (uid != null) { %>
                <a href="booking?action=list&tab=reviews" class="btn-primary-sm">+ Share Your Story</a>
            <% } %>
        </div>
    </div>

    <div class="reviews-grid">
        <% for (Review r : reviews) { %>
            <div class="review-card">
                <i class="fa fa-quote-right quote-icon"></i>
                <div class="star-rating">
                    <% for(int i=1; i<=5; i++) { %>
                        <i class="fa<%= i <= r.getRating() ? "s" : "r" %> fa-star"></i>
                    <% } %>
                </div>
                
                <p style="font-size: 1.1rem; line-height: 1.8; color: #fff; margin-bottom: 2.5rem; font-style: italic; font-family: 'Playfair Display', serif;">
                    "<%= r.getComment() %>"
                </p>

                <div style="display: flex; justify-content: space-between; align-items: center;">
                    <div class="client-info">
                        <h4><%= r.getClientName() %></h4>
                        <span><%= r.getDate() %></span>
                    </div>
                    <%= r.renderBadgeHTML() %>
                </div>
            </div>
        <% } %>
        
        <% if (reviews.isEmpty()) { %>
            <div style="grid-column: 1 / -1; text-align: center; padding: 8rem; border: 1px dashed rgba(255,255,255,0.05); border-radius: 24px;">
                <p style="color: var(--text-muted); letter-spacing: 1px; text-transform: uppercase; font-size: 0.75rem;">Waiting for our next story to be written.</p>
            </div>
        <% } %>
    </div>
</section>

</body>
</html>
