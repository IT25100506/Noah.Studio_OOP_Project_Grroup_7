<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String error = (String) request.getAttribute("error");
    String success = (String) request.getAttribute("success");
    String redirect = request.getParameter("redirect");
    String registered = request.getParameter("registered");
    if ("true".equals(registered) && success == null) success = "Registration successful! Please log in.";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Login — Noah Studio</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        .split-layout { display: flex; height: 100vh; overflow: hidden; background: var(--bg-primary); }
        .side-image { flex: 1.2; background: url('https://images.unsplash.com/photo-1542038784456-1ea8e935640e?w=1000') center/cover no-repeat; border-right: 1px solid rgba(255,255,255,0.05); filter: grayscale(0.5); }
        .form-side { flex: 0.8; display: flex; align-items: center; justify-content: center; padding: 4rem; position: relative; }
        .back-home { position: absolute; top: 3rem; left: 4rem; font-size: 0.65rem; letter-spacing: 2px; color: var(--accent); text-transform: uppercase; font-weight: 800; }
        .auth-container { width: 100%; max-width: 400px; }
    </style>
</head>
<body>
<div class="split-layout">
    <div class="side-image"></div>
    <div class="form-side">
        <a href="index.jsp" class="back-home"><i class="fa fa-arrow-left"></i> Back to Home</a>
        <div class="auth-container">
            <div class="navbar-brand" style="margin-bottom: 3rem; display: block;">Noah<span>Studio</span></div>
            <h2 style="font-size: 1.8rem; margin-bottom: 0.5rem;">Welcome Back</h2>
            <p style="color:var(--text-muted); font-size: 0.8rem; margin-bottom: 3rem; letter-spacing: 1px;">Sign in to your professional account</p>

            <% if (redirect != null && !redirect.isEmpty()) { %>
            <div class="alert" style="border-color:var(--accent); background: rgba(168,130,255,0.08); margin-bottom: 2rem; padding: 1rem 1.25rem; border-radius: 12px; display: flex; align-items: center; gap: 0.75rem;">
                <i class="fa fa-lock" style="color:var(--accent); font-size: 1rem;"></i>
                <span style="font-size: 0.78rem; color: var(--text-main); letter-spacing: 0.5px;">Please log in to access the booking page.</span>
            </div>
            <% } %>
            <% if (error != null) { %><div class="alert"><%= error %></div><% } %>
            <% if (success != null) { %><div class="alert" style="border-color:var(--success);"><%= success %></div><% } %>

            <form action="user" method="post">
                <input type="hidden" name="action" value="login">
                <% if (redirect != null && !redirect.isEmpty()) { %>
                <input type="hidden" name="redirect" value="<%= redirect %>">
                <% } %>
                <div class="form-group">
                    <label>Username</label>
                    <input type="text" name="username" class="form-control" required>
                </div>
                <div class="form-group">
                    <label>Password</label>
                    <input type="password" name="password" class="form-control" required>
                </div>
                <button type="submit" class="btn-primary" style="width: 100%; margin-top: 2rem;">Access Studio</button>
            </form>
            <p style="margin-top: 3rem; font-size: 0.75rem; color: var(--text-muted);">
                New here? <a href="register.jsp<%= (redirect != null && !redirect.isEmpty()) ? "?redirect=" + java.net.URLEncoder.encode(redirect, "UTF-8") : "" %>" style="color:var(--accent); font-weight: 800;">Register</a>
            </p>
        </div>
    </div>
</div>
</body>
</html>
