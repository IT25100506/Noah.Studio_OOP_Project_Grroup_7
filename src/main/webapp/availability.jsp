<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.noahstudio.model.User, com.noahstudio.util.FileHandler" %>
<%
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("user") == null) { response.sendRedirect("login.jsp"); return; }
    User user = (User) sess.getAttribute("user");
    
    if (!"photographer".equals(user.getRole()) && !"videographer".equals(user.getRole())) {
        response.sendRedirect("index.jsp"); return;
    }
    
    String error = (String) request.getAttribute("error");
    String success = (String) request.getAttribute("success");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Duty Status — Noah Studio</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body>

<nav class="navbar scrolled">
    <a class="navbar-brand" href="index.jsp">Noah<span>Studio</span></a>
    <ul class="nav-links">
        <li><a href="index.jsp">Home</a></li>
        <li><a href="portfolio?action=list">Gallery</a></li>
        <li><a href="profile.jsp">Profile</a></li>
        <li><a href="user?action=logout" class="btn-nav">Logout</a></li>
    </ul>
</nav>

<div class="page-hero" style="padding-top: 10rem; padding-bottom: 4rem; text-align: center;">
    <span class="section-tag">Staff Command</span>
    <h1>Duty <span style="color:var(--accent)">Status</span></h1>
</div>

<section style="padding-top:0;">
    <div style="max-width: 800px; margin: 0 auto;">
        <div class="card" style="text-align: center; padding: 5rem 3rem;">
            <div style="margin-bottom: 3rem;">
                <h3 style="margin-bottom: 1rem;">Current Availability</h3>
                <p style="color:var(--text-muted); font-size: 0.8rem;">Setting your status to 'Unavailable' will hide you from new client bookings.</p>
            </div>

            <% if (success != null) { %><div class="alert" style="border-color:var(--success); margin-bottom:3rem;"><%= success %></div><% } %>

            <div style="display: flex; justify-content: center; gap: 2rem;">
                <form action="user" method="post">
                    <input type="hidden" name="action" value="updateAvailability">
                    <input type="hidden" name="status" value="Available">
                    <button type="submit" class="btn-primary" <%= "Available".equals(user.getAvailability()) ? "style='background:var(--success); border-color:var(--success); pointer-events:none;'" : "" %>>
                        <i class="fa fa-check-circle"></i> On Duty
                    </button>
                </form>

                <form action="user" method="post">
                    <input type="hidden" name="action" value="updateAvailability">
                    <input type="hidden" name="status" value="Unavailable">
                    <button type="submit" class="btn-primary" <%= "Unavailable".equals(user.getAvailability()) ? "style='background:var(--danger); border-color:var(--danger); pointer-events:none;'" : "" %>>
                        <i class="fa fa-times-circle"></i> Off Duty
                    </button>
                </form>
            </div>

            <div style="margin-top: 5rem; border-top: 1px solid rgba(255,255,255,0.05); padding-top: 3rem;">
                <h4 style="color:var(--accent); margin-bottom: 1.5rem;">Specialization</h4>
                <form action="user" method="post" style="max-width: 400px; margin: 0 auto;">
                    <input type="hidden" name="action" value="updateSpecialization">
                    <input type="text" name="specialization" class="form-control" value="<%= user.getSpecialization() %>" placeholder="e.g. Cinematic Wedding, Drone Pilot..." required>
                    <button type="submit" class="btn-outline" style="width:100%; margin-top: 2rem;">Update Expertise</button>
                </form>
            </div>
        </div>
    </div>
</section>

</body>
</html>
