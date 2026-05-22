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
        .portfolio-hero {
            padding: 10rem 0 6rem;
            text-align: center;
            background: linear-gradient(to bottom, rgba(0,0,0,0.8), #080808), url('https://images.unsplash.com/photo-1542038784456-1ea8e935640e?w=1600') center/cover;
        }
        .filter-nav { display: flex; justify-content: center; gap: 2rem; margin-bottom: 4rem; }
        .filter-nav a { font-size: 0.8rem; font-weight: 800; text-transform: uppercase; letter-spacing: 2px; color: var(--text-muted); transition: 0.3s; }
        .filter-nav a:hover, .filter-nav a.active { color: var(--accent); }
        .filter-nav a:hover, .filter-nav a.active { color: var(--accent); }
        
        .filter-btn { padding: 0.5rem 1rem; border: 1px solid rgba(255,255,255,0.1); border-radius: 20px; font-size: 0.75rem; text-transform: uppercase; letter-spacing: 1px; color: #fff; cursor: pointer; background: transparent; transition: 0.3s; }
        .filter-btn.active, .filter-btn:hover { background: var(--accent); border-color: var(--accent); }
        .filter-controls { display: flex; justify-content: center; gap: 1rem; margin-bottom: 2rem; }
        
        .portfolio-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(350px, 1fr)); gap: 2rem; padding: 0 5%; margin-bottom: 5rem; }
        .portfolio-card { position: relative; overflow: hidden; border-radius: 12px; background: #0c0c0c; border: 1px solid rgba(255,255,255,0.05); display: block; }
        .portfolio-card.featured { grid-column: span 2; grid-row: span 2; }
        .portfolio-card.featured .portfolio-media { height: 100%; min-height: 500px; }
        
        .media-badge { position: absolute; top: 1rem; left: 1rem; background: rgba(0,0,0,0.7); backdrop-filter: blur(5px); padding: 0.3rem 0.8rem; border-radius: 20px; font-size: 0.7rem; color: #fff; text-transform: uppercase; letter-spacing: 1px; z-index: 10; display: flex; align-items: center; gap: 0.5rem; }
        .views-badge { position: absolute; top: 1rem; right: 1rem; background: rgba(0,0,0,0.7); backdrop-filter: blur(5px); padding: 0.3rem 0.8rem; border-radius: 20px; font-size: 0.7rem; color: #fff; z-index: 10; display: flex; align-items: center; gap: 0.5rem; }
        .featured-badge { position: absolute; top: 1rem; left: 50%; transform: translateX(-50%); background: var(--accent); color: #fff; padding: 0.3rem 1rem; border-radius: 20px; font-size: 0.7rem; font-weight: bold; text-transform: uppercase; letter-spacing: 2px; z-index: 10; box-shadow: 0 0 15px rgba(231,76,60,0.5); }
        
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
            <li><a href="booking?action=list">My Dashboard</a></li>
            <% if ("admin".equals(loggedRole)) { %><li><a href="admin-dashboard.jsp">Dashboard</a></li><% } %>
            <% if ("photographer".equals(loggedRole)) { %><li><a href="photographer-dashboard.jsp">Dashboard</a></li><% } %>
            <% if ("videographer".equals(loggedRole)) { %><li><a href="videographer-dashboard.jsp">Dashboard</a></li><% } %>
            <li><a href="user?action=logout" class="btn-nav">Logout</a></li>
        <% } else { %>
            <li><a href="login.jsp" class="btn-nav">Login</a></li>
        <% } %>
    </ul>
</nav>

<header class="portfolio-hero">
    <div class="container">
        <span class="section-tag">Visuals</span>
        <h1 style="font-size: 4rem; margin-top: 1rem;">The <span style="color:var(--accent)">Portfolio</span></h1>
        <p style="max-width: 600px; margin: 1.5rem auto; color: var(--text-muted);">A curated collection of our most stunning and cinematic visual storytelling.</p>
    </div>
</header>

<section style="padding-top:0;">
    <div class="filter-controls" id="type-filters">
        <button class="filter-btn active" onclick="filterType('all')">All Media</button>
        <button class="filter-btn" onclick="filterType('photo')">Photos Only</button>
        <button class="filter-btn" onclick="filterType('video')">Videos Only</button>
    </div>

    <div class="filter-nav" style="margin-bottom: 5rem;" id="cat-filters">
        <a href="javascript:void(0)" onclick="filterCategory('All', this)" class="active">All</a>
        <a href="javascript:void(0)" onclick="filterCategory('Wedding', this)">Wedding</a>
        <a href="javascript:void(0)" onclick="filterCategory('Corporate', this)">Corporate</a>
        <a href="javascript:void(0)" onclick="filterCategory('Birthday', this)">Birthday</a>
        <a href="javascript:void(0)" onclick="filterCategory('Fashion', this)">Fashion</a>
        <a href="javascript:void(0)" onclick="filterCategory('Drone', this)">Drone</a>
    </div>

    <!-- Featured Section -->
    <% 
        boolean hasFeatured = false;
        for (PortfolioItem item : items) {
            if (item.isFeatured()) {
                if (!hasFeatured) {
    %>
    <div class="container" id="featured-header" style="padding: 0 5%; margin-bottom: 2rem;">
        <span class="section-tag" style="margin-bottom: 0.5rem; color: var(--accent);">Highlights</span>
        <h2 style="font-size: 2rem;">Featured <span style="color:var(--accent)">Work</span></h2>
    </div>
    <div class="portfolio-grid" id="featured-grid" style="margin-bottom: 5rem;">
    <%          hasFeatured = true; } %>
        <a href="portfolio?action=view&id=<%= item.getId() %>" class="portfolio-card featured filter-item" data-type="<%= item.getType().toLowerCase() %>" data-category="<%= item.getCategory() %>">
            <div class="media-badge"><i class="fa <%= "Photo".equals(item.getType()) ? "fa-camera" : "fa-video" %>"></i> <%= item.getType() %></div>
            <div class="views-badge"><i class="fa fa-eye"></i> <%= item.getViews() %> views</div>
            <div class="featured-badge"><i class="fa fa-star"></i> Featured</div>
            <%= item.renderPreviewHTML() %>
            <div class="portfolio-overlay">
                <span class="section-tag" style="font-size:0.6rem;"><%= item.getCategory() %></span>
                <h3><%= item.getTitle() %></h3>
                <div class="staff-credit">By <%= item.getStaffName() %></div>
            </div>
        </a>
    <%      } 
        } 
        if (hasFeatured) { out.print("</div>"); }
    %>

    <!-- Regular Gallery Section -->
    <div class="container" style="padding: 0 5%; margin-bottom: 3rem;">
        <span class="section-tag" style="margin-bottom: 0.5rem;">Visual Art</span>
        <h2 style="font-size: 2rem; margin-bottom: 3rem;">Complete <span style="color:var(--accent)">Gallery</span></h2>
    </div>
    <div class="portfolio-grid" id="main-grid">
        <% 
            for (PortfolioItem item : items) { 
                if (!item.isFeatured()) {
        %>
        <a href="portfolio?action=view&id=<%= item.getId() %>" class="portfolio-card filter-item" data-type="<%= item.getType().toLowerCase() %>" data-category="<%= item.getCategory() %>">
            <div class="media-badge"><i class="fa <%= "Photo".equals(item.getType()) ? "fa-camera" : "fa-video" %>"></i> <%= item.getType() %></div>
            <div class="views-badge"><i class="fa fa-eye"></i> <%= item.getViews() %> views</div>
            <%= item.renderPreviewHTML() %>
            <div class="portfolio-overlay">
                <span class="section-tag" style="font-size:0.6rem;"><%= item.getCategory() %></span>
                <h3><%= item.getTitle() %></h3>
                <div class="staff-credit">By <%= item.getStaffName() %></div>
            </div>
        </a>
        <%      }
            } 
        %>
    </div>
</section>

<script>
    let currentType = 'all';
    let currentCat = 'All';

    function applyFilters() {
        const items = document.querySelectorAll('.filter-item');
        let visibleCount = 0;
        items.forEach(item => {
            const itemType = item.getAttribute('data-type');
            const itemCat = item.getAttribute('data-category');
            
            const matchType = (currentType === 'all' || itemType === currentType);
            const matchCat = (currentCat === 'All' || itemCat === currentCat);
            
            if (matchType && matchCat) {
                item.style.display = 'block';
                visibleCount++;
            } else {
                item.style.display = 'none';
            }
        });
    }

    function filterType(type) {
        currentType = type;
        document.querySelectorAll('#type-filters .filter-btn').forEach(btn => btn.classList.remove('active'));
        event.target.classList.add('active');
        applyFilters();
    }

    function filterCategory(cat, element) {
        currentCat = cat;
        document.querySelectorAll('#cat-filters a').forEach(a => a.classList.remove('active'));
        element.classList.add('active');
        applyFilters();
    }
</script>
</body>
</html>
