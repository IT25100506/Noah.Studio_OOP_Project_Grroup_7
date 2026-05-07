<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.noahstudio.model.*, com.noahstudio.util.FileHandler, java.util.*" %>
<%
    String dataPath = application.getRealPath("/") + "data";
    FileHandler.init(dataPath);
    
    // Load Packages
    List<ServicePackage> pkgList = new ArrayList<>();
    for (String l : FileHandler.readLines("packages.txt")) {
        ServicePackage p = ServicePackage.fromFileString(l);
        if (p != null && p.isActive()) pkgList.add(p);
    }

    // Load Portfolio Preview (first 6)
    List<PortfolioItem> portList = new ArrayList<>();
    for (String l : FileHandler.readLines("portfolio.txt")) {
        PortfolioItem pf = PortfolioItem.fromFileString(l);
        if (pf != null && portList.size() < 6) portList.add(pf);
    }

    // Load Reviews Preview (first 3)
    List<Review> revList = new ArrayList<>();
    for (String l : FileHandler.readLines("reviews.txt")) {
        Review r = Review.fromFileString(l);
        if (r != null && revList.size() < 3) revList.add(r);
    }

    HttpSession userSession = request.getSession(false);
    String loggedRole = (userSession != null) ? (String)userSession.getAttribute("role") : null;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Noah Studio — Capture Your Perfect Moments</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        .portfolio-media { width: 100%; height: 350px; position: relative; overflow: hidden; }
        .portfolio-media img { width: 100%; height: 100%; object-fit: cover; transition: transform 0.8s ease; }
        .portfolio-card:hover .portfolio-media img { transform: scale(1.05); }
        .video-media { background: #000; display: flex; align-items: center; justify-content: center; }
        .video-media video { width: 100%; height: 100%; object-fit: cover; }
        .video-media .play-overlay { position: absolute; color: rgba(255,255,255,0.8); font-size: 3rem; pointer-events: none; }
        .iframe-container iframe { width: 100%; height: 100%; border: none; }
        .portfolio-overlay { position: absolute; bottom: 0; left: 0; width: 100%; padding: 2rem; background: linear-gradient(to top, rgba(0,0,0,0.9), transparent); display: flex; flex-direction: column; justify-content: flex-end; z-index: 2;}
        .portfolio-overlay h3 { font-size: 1.2rem; margin: 0.5rem 0; color: #fff; text-transform: uppercase; letter-spacing: 1px; }
    </style>
</head>
<body>

<!-- 🧭 2. NAVBAR -->
<nav class="navbar scrolled">
    <a class="navbar-brand" href="index.jsp">Noah<span>Studio</span></a>
    <ul class="nav-links">
        <li><a href="#home">Home</a></li>
        <li><a href="#about">About</a></li>
        <li><a href="#portfolio">Portfolio</a></li>
        <li><a href="#packages">Packages</a></li>
        <li><a href="#testimonials">Review</a></li>
        <li><a href="#contact">Contact</a></li>
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

<!-- 🏠 1. HERO SECTION -->
<header class="hero" id="home">
    <div class="hero-content">
        <span class="section-tag">Since 2020</span>
        <h1>Capture Your <br><span style="color:var(--accent)">Perfect Moments</span></h1>
        <p style="margin-left:auto; margin-right:auto;">Professional Event Photography &amp; Videography Services — We transform your most treasured celebrations into timeless visual stories.</p>
        <div class="hero-btns" style="justify-content: center; display: flex; gap: 1.5rem;">
            <% if (loggedRole != null) { %>
                <a href="booking?action=list" class="btn-primary">Book Now</a>
            <% } else { %>
                <a href="login.jsp?redirect=booking%3Faction%3Dlist" class="btn-primary">Book Now</a>
            <% } %>
            <a href="#portfolio" class="btn-outline" style="color:var(--text-main)">View Portfolio</a>
        </div>
    </div>
</header>

<!-- 📖 3. ABOUT SECTION -->
<section class="about" id="about">
    <div style="display:grid; grid-template-columns: 1fr 1fr; gap: 6rem; align-items:center;">
        <div>
            <div class="section-header" style="text-align:left; margin-bottom: 2.5rem;">
                <span class="section-tag">Our Story</span>
                <h2 style="font-size: 3.5rem;">About <span style="color:var(--accent)">Us</span></h2>
                <div class="divider" style="margin-left:0;"></div>
                <p style="text-align:left;">We are a professional photography and videography team dedicated to capturing unforgettable moments. From weddings and corporate events to personal shoots, we combine creativity and technology to deliver high-quality visual stories.</p>
            </div>
            
            <div style="display:grid; grid-template-columns: 1fr 1fr; gap: 1.5rem;">
                <div class="card" style="text-align: center; padding: 1.5rem;">
                    <i class="fa fa-users" style="color:var(--accent); font-size: 1.5rem; margin-bottom: 0.8rem;"></i>
                    <h4 style="font-size: 0.7rem;">Experienced Team</h4>
                </div>
                <div class="card" style="text-align: center; padding: 1.5rem;">
                    <i class="fa fa-camera" style="color:var(--accent); font-size: 1.5rem; margin-bottom: 0.8rem;"></i>
                    <h4 style="font-size: 0.7rem;">High-Quality Equipment</h4>
                </div>
                <div class="card" style="text-align: center; padding: 1.5rem;">
                    <i class="fa fa-magic" style="color:var(--accent); font-size: 1.5rem; margin-bottom: 0.8rem;"></i>
                    <h4 style="font-size: 0.7rem;">Creative Editing</h4>
                </div>
                <div class="card" style="text-align: center; padding: 1.5rem;">
                    <i class="fa fa-award" style="color:var(--accent); font-size: 1.5rem; margin-bottom: 0.8rem;"></i>
                    <h4 style="font-size: 0.7rem;">Professional Service</h4>
                </div>
            </div>
        </div>
        <div style="position:relative;">
            <img src="https://images.unsplash.com/photo-1542038784456-1ea8e935640e?w=1000" 
                 style="width:100%; height:600px; object-fit:cover; border: 1px solid rgba(255,255,255,0.05); filter: contrast(1.1) brightness(0.9);" alt="Professional Studio">
        </div>
    </div>
</section>

<!-- 📸 4. PORTFOLIO PREVIEW -->
<section class="portfolio" id="portfolio">
    <div class="section-header">
        <span class="section-tag">Showcase</span>
        <h2>Our <span style="color:var(--accent)">Work</span></h2>
        <p>Weddings • Events • Portraits</p>
    </div>
    <div class="portfolio-grid">
        <% for (PortfolioItem pf : portList) { %>
        <div class="portfolio-card">
            <%= pf.renderPreviewHTML() %>
            <div class="portfolio-overlay">
                <span class="section-tag" style="font-size:0.6rem;"><%= pf.getCategory() %></span>
                <h3><%= pf.getTitle() %></h3>
            </div>
        </div>
        <% } %>
    </div>
    <div style="text-align:center; margin-top: 4rem;">
        <a href="portfolio?action=list" class="btn-primary" style="padding: 1rem 3rem;">View All Portfolio</a>
    </div>
</section>

<!-- 💰 5. PACKAGES PREVIEW -->
<section class="packages" id="packages">
    <div class="section-header">
        <span class="section-tag">Pricing</span>
        <h2>Select Your <span style="color:var(--accent)">Package</span></h2>
    </div>
    <div class="packages-grid">
        <% 
            int count = 0;
            for (ServicePackage pkg : pkgList) { 
                if (count++ >= 3) break;
        %>
        <div class="package-card <%= pkg.getName().equalsIgnoreCase("Premium") ? "featured" : "" %>">
            <h3><%= pkg.getName() %></h3>
            <div class="package-price">LKR <%= String.format("%.0f", pkg.getPrice()) %></div>
            <p style="color:var(--text-muted); font-size: 0.8rem; margin-bottom: 2rem;"><%= pkg.getDuration() %></p>
            <a href="package?action=list" class="btn-primary" style="width:100%; display:block; text-align:center;">View Details</a>
        </div>
        <% } %>
    </div>
    <div style="text-align:center; margin-top: 4rem;">
        <a href="package?action=list" class="btn-primary">View All Packages</a>
    </div>
</section>

<!-- ⭐ 6. TESTIMONIALS -->
<section class="testimonials" id="testimonials">
    <div class="section-header">
        <span class="section-tag">Client Love</span>
        <h2>User <span style="color:var(--accent)">Reviews</span></h2>
    </div>
    <div class="reviews-grid">
        <% for (Review r : revList) { %>
        <div class="review-card">
            <div class="stars" style="color:var(--accent); margin-bottom: 1rem;">
                <% for(int i=0; i<r.getRating(); i++) { %>★<% } %>
            </div>
            <p style="margin-bottom: 2rem;">"<%= r.getComment() %>"</p>
            <h5 style="text-transform: uppercase; letter-spacing: 2px;"><%= r.getClientName() %></h5>
        </div>
        <% } %>
    </div>
    <div style="text-align:center; margin-top: 4rem;">
        <a href="review?action=list" class="btn-primary" style="padding: 1.25rem 3rem;">View All Client Feedback</a>
    </div>
</section>

<!-- 📞 7. CONTACT US SECTION -->
<section class="contact" id="contact">
    <div class="section-header">
        <span class="section-tag">Inquiry</span>
        <h2>Contact <span style="color:var(--accent)">Us</span></h2>
    </div>
    <div style="display:grid; grid-template-columns: 1fr 1.5fr; gap: 4rem;">
        <div class="card">
            <div style="margin-bottom: 2rem;">
                <h5 style="color:var(--accent); margin-bottom: 0.5rem;">ADDRESS</h5>
                <p style="color:var(--text-muted); font-size: 0.9rem;">123 Studio Lane, Creative District<br>Kuala Lumpur, Malaysia</p>
            </div>
            <div style="margin-bottom: 2rem;">
                <h5 style="color:var(--accent); margin-bottom: 0.5rem;">PHONE</h5>
                <p style="color:var(--text-muted); font-size: 0.9rem;">+60 12-345 6789</p>
            </div>
            <div>
                <h5 style="color:var(--accent); margin-bottom: 0.5rem;">EMAIL</h5>
                <p style="color:var(--text-muted); font-size: 0.9rem;">hello@noahstudio.com</p>
            </div>
        </div>
        <div class="card">
            <form action="contact" method="post">
                <div class="form-group">
                    <label>Your Name</label>
                    <input type="text" name="name" class="form-control" required>
                </div>
                <div class="form-group">
                    <label>Your Email</label>
                    <input type="email" name="email" class="form-control" required>
                </div>
                <div class="form-group">
                    <label>Message</label>
                    <textarea name="message" class="form-control" rows="4" required></textarea>
                </div>
                <button type="submit" class="btn-primary" style="width:100%;">Send Message</button>
            </form>
        </div>
    </div>
</section>

<!-- 📍 8. FOOTER -->
<footer class="footer">
    <div class="footer-grid">
        <div>
            <div class="footer-brand">Noah<span>Studio</span></div>
            <p style="color:var(--text-muted); font-size: 0.8rem; margin-top: 1rem;">© 2026 Noah Studio</p>
        </div>
        <div>
            <h5>Quick Links</h5>
            <div style="display:grid; grid-template-columns: 1fr 1fr; gap: 1rem;">
                <a href="#home">Home</a>
                <a href="#about">About</a>
                <% if (loggedRole != null) { %>
                    <a href="booking?action=list">Booking</a>
                <% } else { %>
                    <a href="login.jsp?redirect=booking%3Faction%3Dlist">Booking</a>
                <% } %>
                <a href="#contact">Contact</a>
            </div>
        </div>
        <div style="text-align:right;">
            <h5>Social Media</h5>
            <div style="display:flex; gap:1.5rem; justify-content: flex-end;">
                <a href="#"><i class="fab fa-facebook"></i></a>
                <a href="#"><i class="fab fa-instagram"></i></a>
                <a href="#"><i class="fab fa-vimeo"></i></a>
            </div>
        </div>
    </div>
</footer>

</body>
</html>
