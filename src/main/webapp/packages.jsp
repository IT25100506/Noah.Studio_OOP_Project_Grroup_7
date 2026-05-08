<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.noahstudio.model.*, com.noahstudio.util.FileHandler, java.util.*" %>
<%
    List<ServicePackage> pkgs = (List<ServicePackage>) request.getAttribute("packages");
    if (pkgs == null) {
        response.sendRedirect("package?action=list");
        return;
    }
    
    HttpSession sess = request.getSession(false);
    String role = (sess != null) ? (String) sess.getAttribute("role") : null;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Our Packages — Noah Studio</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        .packages-hero {
            padding: 10rem 0 6rem;
            text-align: center;
            background: linear-gradient(to bottom, rgba(0,0,0,0.8), var(--bg-primary)), url('https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?w=1600') center/cover;
        }
    </style>
</head>
<body style="background: var(--bg-primary);">

<!-- Navbar -->
<nav class="navbar scrolled">
    <a class="navbar-brand" href="index.jsp">Noah<span>Studio</span></a>
    <ul class="nav-links">
        <li><a href="index.jsp#home">Home</a></li>
        <li><a href="index.jsp#about">About</a></li>
        <li><a href="portfolio?action=list">Portfolio</a></li>
        <li><a href="index.jsp#packages" class="active">Packages</a></li>
        <li><a href="index.jsp#testimonials">Review</a></li>
        <li><a href="index.jsp#contact">Contact</a></li>
        <% if (role != null) { %>
            <li><a href="booking?action=list">My Bookings</a></li>
            <% if ("admin".equals(role)) { %><li><a href="admin-dashboard.jsp">Dashboard</a></li><% } %>
            <% if ("photographer".equals(role)) { %><li><a href="photographer-dashboard.jsp">Dashboard</a></li><% } %>
            <% if ("videographer".equals(role)) { %><li><a href="videographer-dashboard.jsp">Dashboard</a></li><% } %>
            <li><a href="user?action=logout" class="btn-nav">Logout</a></li>
        <% } else { %>
            <li><a href="login.jsp" class="btn-nav">Login</a></li>
        <% } %>
    </ul>
</nav>

<header class="packages-hero">
    <div class="container">
        <span class="section-tag">Investment</span>
        <h1 style="font-size: 4rem; margin-top: 1rem;">Choose Your <span style="color:var(--accent)">Vision</span></h1>
        <p style="max-width: 600px; margin: 1.5rem auto; color: var(--text-muted);">Tailored experiences designed to capture your most significant moments with cinematic precision.</p>
    </div>
</header>

<section class="container" style="padding-bottom: 10rem;">
    <!-- Filter Bar -->
    <div class="card" style="margin-bottom: 4rem; padding: 1.5rem; border: 1px solid rgba(255,255,255,0.05);">
        <form action="package" method="get" style="display:flex; gap: 2rem; align-items: center; justify-content: center;">
            <input type="hidden" name="action" value="list">
            <select name="type" class="filter-select" style="min-width: 200px;" onchange="this.form.submit()">
                <option value="">All Services</option>
                <option value="photography" <%= "photography".equals(request.getParameter("type")) ? "selected" : "" %>>Photography</option>
                <option value="videography" <%= "videography".equals(request.getParameter("type")) ? "selected" : "" %>>Videography</option>
            </select>
            <input type="number" name="priceMax" placeholder="Max Price (LKR)" class="form-control" style="margin:0; width: 200px;" value="<%= request.getParameter("priceMax") != null ? request.getParameter("priceMax") : "" %>">
            <button type="submit" class="btn-primary-sm">Apply Filters</button>
            <% if ("admin".equals(role)) { %>
                <a href="packages-management.jsp" class="btn-outline-sm" style="margin-left: auto;">Manage Packages</a>
            <% } %>
        </form>
    </div>

    <div class="packages-grid">
        <% for (ServicePackage p : pkgs) { %>
            <div class="package-card <%= p.getName().equalsIgnoreCase("Premium") ? "featured" : "" %>">
                <span class="section-tag" style="font-size: 0.6rem;"><%= p.getType() %> • <%= p.getDuration() %></span>
                <h3 style="margin: 1rem 0;"><%= p.getName() %></h3>
                <div class="package-price">LKR <%= String.format("%.0f", p.getPrice()) %></div>
                
                <div style="margin: 2rem 0; text-align: left;">
                    <% for (String feat : p.getFeatures().split(",")) { %>
                        <div style="margin-bottom: 0.75rem; color: var(--text-muted); font-size: 0.9rem; display: flex; align-items: center; gap: 0.75rem;">
                            <i class="fa fa-check-circle" style="color:var(--accent); font-size: 0.8rem;"></i>
                            <%= feat.trim() %>
                        </div>
                    <% } %>
                </div>

                <p style="color:var(--text-muted); font-size: 0.8rem; margin-bottom: 2.5rem; line-height: 1.6;"><%= p.getDescription() %></p>
                
                <button onclick="initBooking('<%= p.getId() %>', '<%= p.getName() %>', '<%= p.getType() %>')" class="btn-primary" style="width:100%;">Book This Package</button>
            </div>
        <% } %>
    </div>
</section>

<!-- Booking Modal -->
<div id="bookingModal" class="modal-overlay" style="display:none;">
    <div class="modal-container" style="max-width: 500px;">
        <button class="modal-close-btn" onclick="closeBooking()">&times;</button>
        <span class="section-tag">Reservation</span>
        <h2 style="margin-bottom: 2rem;">Book <span id="modal-pkg-name" style="color:var(--accent)">Package</span></h2>
        
        <form action="booking" method="post">
            <input type="hidden" name="action" value="create">
            <input type="hidden" name="packageId" id="book-pkg-id">
            <input type="hidden" name="packageName" id="book-pkg-name">
            <input type="hidden" name="eventType" id="book-pkg-type">

            <div style="display:grid; grid-template-columns: 1fr 1fr; gap: 1rem;">
                <div class="form-group">
                    <label>Event Date</label>
                    <input type="date" name="eventDate" class="form-control" required style="background:#0f0f0f; border:1px solid #1a1a1a; color:#fff; width:100%; padding:1rem; border-radius:12px;">
                </div>
                <div class="form-group">
                    <label>Event Time</label>
                    <input type="time" name="eventTime" class="form-control" required style="background:#0f0f0f; border:1px solid #1a1a1a; color:#fff; width:100%; padding:1rem; border-radius:12px;">
                </div>
                <div class="form-group">
                    <label>Event Location</label>
                    <input type="text" name="eventLocation" class="form-control" placeholder="Venue name, City..." required style="background:#0f0f0f; border:1px solid #1a1a1a; color:#fff; width:100%; padding:1rem; border-radius:12px;">
                </div>
                <div class="form-group">
                    <label>Contact Number</label>
                    <input type="tel" name="clientContact" class="form-control" placeholder="+94..." required style="background:#0f0f0f; border:1px solid #1a1a1a; color:#fff; width:100%; padding:1rem; border-radius:12px;">
                </div>
            </div>

            <p style="font-size: 0.7rem; color: var(--text-muted); margin: 1.5rem 0;">* Our team will contact you within 24 hours to finalize details and confirm availability.</p>

            <button type="submit" class="btn-primary" style="width: 100%; padding: 1.25rem;">Book Now</button>
        </form>
    </div>
</div>

<!-- Footer -->
<footer class="footer">
    <div class="footer-grid">
        <div>
            <div class="footer-brand">Noah<span>Studio</span></div>
            <p style="color:var(--text-muted); font-size: 0.8rem; margin-top: 1rem;">© 2026 Noah Studio</p>
        </div>
        <div style="text-align:right;">
            <div style="display:flex; gap:1.5rem; justify-content: flex-end;">
                <a href="#"><i class="fab fa-facebook"></i></a>
                <a href="#"><i class="fab fa-instagram"></i></a>
                <a href="#"><i class="fab fa-vimeo"></i></a>
            </div>
        </div>
    </div>
</footer>

<style>
    .modal-overlay { 
        position: fixed; top: 0; left: 0; width: 100%; height: 100%;
        backdrop-filter: blur(12px); background: rgba(0,0,0,0.85);
        display: flex; align-items: center; justify-content: center; z-index: 10000;
    }
    .modal-container { 
        background: #080808; border: 1px solid rgba(255,255,255,0.08);
        padding: 3.5rem; border-radius: 24px; position: relative; width: 90%;
    }
    .modal-close-btn {
        background: #1a1a1a; color: #fff; width: 32px; height: 32px;
        border-radius: 50%; border: none; cursor: pointer;
        position: absolute; top: 2rem; right: 2rem;
    }
    .form-group label {
        font-size: 0.65rem; text-transform: uppercase; letter-spacing: 1.5px;
        color: var(--accent); font-weight: 800; margin-bottom: 0.75rem; display: block;
    }
</style>

<script>
    const isLoggedIn = "<%= (role != null) %>" === "true";

    function initBooking(id, name, type) {
        if (!isLoggedIn) {
            window.location.href = 'login.jsp';
            return;
        }
        document.getElementById('book-pkg-id').value = id;
        document.getElementById('book-pkg-name').value = name;
        document.getElementById('book-pkg-type').value = type;
        document.getElementById('modal-pkg-name').innerText = name;
        document.getElementById('bookingModal').style.display = 'flex';
    }

    function closeBooking() {
        document.getElementById('bookingModal').style.display = 'none';
    }
</script>

</body>
</html>
