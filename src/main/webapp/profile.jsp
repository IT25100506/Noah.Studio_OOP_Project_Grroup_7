<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.noahstudio.model.User, com.noahstudio.util.FileHandler" %>
<%
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("user") == null) { response.sendRedirect("login.jsp"); return; }
    User user = (User) sess.getAttribute("user");
    
    String error = (String) request.getAttribute("error");
    String success = (String) request.getAttribute("success");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My Profile — Noah Studio</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body>

<nav class="navbar scrolled">
    <a class="navbar-brand" href="index.jsp">Noah<span>Studio</span></a>
    <ul class="nav-links">
        <li><a href="index.jsp">Home</a></li>
        <li><a href="<%= user.getDashboardUrl() %>">Dashboard</a></li>
        <li><a href="user?action=logout" class="btn-nav">Logout</a></li>
    </ul>
</nav>

<div class="page-hero" style="padding-top: 10rem; padding-bottom: 4rem; text-align: center;">
    <span class="section-tag">Account Settings</span>
    <h1>Edit <span style="color:var(--accent)">Profile</span></h1>
</div>

<section style="padding-top:0;">
    <div style="display:grid; grid-template-columns: 0.8fr 1.2fr; gap: 4rem; max-width: 1000px; margin: 0 auto;">
        <div class="card" style="text-align: center;">
            <div style="width: 120px; height: 120px; border: 2px solid var(--accent); margin: 0 auto 2rem; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 3rem;">
                <i class="fa fa-user"></i>
            </div>
            <h3 style="margin-bottom: 0.5rem;"><%= user.getFullName() %></h3>
            <span class="section-tag" style="margin-bottom: 2rem;"><%= user.getRole() %></span>
            <p style="color:var(--text-muted); font-size: 0.8rem; line-height: 1.8;"><%= user.getRoleDescription() %></p>
        </div>

        <div class="card">
            <% if (error != null) { %><div class="alert"><%= error %></div><% } %>
            <% if (success != null) { %><div class="alert" style="border-color:var(--success);"><%= success %></div><% } %>

            <form action="user" method="post">
                <input type="hidden" name="action" value="updateProfile">
                <div class="form-group">
                    <label>Full Name</label>
                    <input type="text" name="fullName" class="form-control" value="<%= user.getFullName() %>" required>
                </div>
                <div class="form-group">
                    <label>Email Address</label>
                    <input type="email" name="email" class="form-control" value="<%= user.getEmail() %>" required>
                </div>
                <div class="form-group">
                    <label>Phone Number</label>
                    <input type="text" name="phone" class="form-control" value="<%= user.getPhone() %>" required>
                </div>
                <div class="form-group">
                    <label>New Password (leave blank to keep current)</label>
                    <input type="password" name="password" class="form-control">
                </div>
                <button type="submit" class="btn-primary" style="width: 100%; margin-top: 2rem;">Save Changes</button>
            </form>
        </div>
    </div>
</section>

</body>
</html>
