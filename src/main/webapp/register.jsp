<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String redirect = request.getParameter("redirect");
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Register — Noah Studio</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        .split-layout { display: flex; height: 100vh; overflow: hidden; background: var(--bg-primary); }
        .form-side { flex: 0.8; display: flex; align-items: center; justify-content: center; padding: 4rem; position: relative; }
        .side-image { flex: 1.2; background: url('https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?w=1000') center/cover no-repeat; border-left: 1px solid rgba(255,255,255,0.05); filter: grayscale(0.5); }
        .back-home { position: absolute; top: 3rem; left: 4rem; font-size: 0.65rem; letter-spacing: 2px; color: var(--accent); text-transform: uppercase; font-weight: 800; }
        .auth-container { width: 100%; max-width: 450px; }
    </style>
</head>
<body>
<div class="split-layout">
    <div class="form-side">
        <a href="index.jsp" class="back-home"><i class="fa fa-arrow-left"></i> Back to Home</a>
        <div class="auth-container">
            <div class="navbar-brand" style="margin-bottom: 3rem; display: block;">Noah<span>Studio</span></div>
            <h2 style="font-size: 1.8rem; margin-bottom: 0.5rem;">Create Account</h2>
            <p style="color:var(--text-muted); font-size: 0.8rem; margin-bottom: 3rem; letter-spacing: 1px;">Join our community of professional creators</p>

            <form action="user" method="post">
                <input type="hidden" name="action" value="register">
                <% if (redirect != null && !redirect.isEmpty()) { %>
                <input type="hidden" name="redirect" value="<%= redirect %>">
                <% } %>
                <div style="display:grid; grid-template-columns: 1fr 1fr; gap: 1.5rem;">
                    <div class="form-group">
                        <label>Full Name</label>
                        <input type="text" name="fullName" class="form-control" required>
                    </div>
                    <div class="form-group">
                        <label>Username</label>
                        <input type="text" name="username" class="form-control" required>
                    </div>
                </div>
                <div class="form-group">
                    <label>Email Address</label>
                    <input type="email" name="email" class="form-control" required>
                </div>
                <div style="display:grid; grid-template-columns: 1fr 1fr; gap: 1.5rem;">
                    <div class="form-group">
                        <label>Phone</label>
                        <input type="text" name="phone" class="form-control">
                    </div>
                    <div class="form-group">
                        <label>I am a...</label>
                        <select name="role" class="form-control">
                            <option value="client">Client</option>
                            <option value="photographer">Photographer</option>
                            <option value="videographer">Videographer</option>
                        </select>
                    </div>
                </div>
                <div class="form-group">
                    <label>Password</label>
                    <input type="password" name="password" class="form-control" required>
                </div>
                <button type="submit" class="btn-primary" style="width: 100%; margin-top: 1.5rem;">Register Now</button>
            </form>
            <p style="margin-top: 3rem; font-size: 0.75rem; color: var(--text-muted);">
                Already registered? <a href="login.jsp<%= (redirect != null && !redirect.isEmpty()) ? "?redirect=" + java.net.URLEncoder.encode(redirect, "UTF-8") : "" %>" style="color:var(--accent); font-weight: 800;">Sign In</a>
            </p>
        </div>
    </div>
    <div class="side-image"></div>
</div>
</body>
</html>
