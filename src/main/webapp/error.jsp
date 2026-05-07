<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>404 — Noah Studio</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .error-page {
            height: 100vh; display: flex; align-items: center; justify-content: center;
            background: #050505; text-align: center;
        }
        .error-content { max-width: 600px; }
        .error-code { 
            font-size: 10rem; font-weight: 800; color: var(--accent); 
            line-height: 1; margin-bottom: 2rem; opacity: 0.8;
        }
    </style>
</head>
<body>
<div class="error-page">
    <div class="error-content">
        <div class="error-code">404</div>
        <h2 style="font-size: 1.5rem; margin-bottom: 1rem;">Frame Not Found</h2>
        <p style="color:var(--text-muted); margin-bottom: 3rem; letter-spacing: 1px;">The story you're looking for doesn't exist in our gallery.</p>
        <a href="index.jsp" class="btn-primary">Return to Studio</a>
    </div>
</div>
</body>
</html>
