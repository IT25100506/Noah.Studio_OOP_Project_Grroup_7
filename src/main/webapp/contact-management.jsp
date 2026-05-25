<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.noahstudio.model.*, com.noahstudio.util.FileHandler, java.util.*" %>
<%
    HttpSession sess = request.getSession(false);
    if (sess == null || !"admin".equals(sess.getAttribute("role"))) {
        response.sendRedirect("login.jsp");
        return;
    }

    FileHandler.init(application.getRealPath("/") + "data");
    List<String> rawContacts = FileHandler.readLines("contacts.txt");
    Collections.reverse(rawContacts); // Newest first
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Inquiry Management — Noah Studio</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body style="background: var(--bg-primary);">

<div class="dashboard-layout">
    <jsp:include page="admin-sidebar.jsp" />

    <main class="main-content">
        <header class="content-header" style="margin-bottom: 3rem;">
            <span class="section-tag">Leads</span>
            <h1 style="font-size: 2.5rem; margin: 0;">Client <span class="serif" style="color:var(--accent); text-transform:none;">Inquiries</span></h1>
            <p style="color:var(--text-muted); margin-top: 0.5rem;">Showing newest inquiries first</p>
        </header>

        <div class="card card-table">
            <table class="ns-table">
                <thead>
                    <tr>
                        <th style="width: 150px;">Date</th>
                        <th style="width: 200px;">Client</th>
                        <th>Message</th>
                        <th class="text-right">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% 
                        int count = 0;
                        for(String line : rawContacts) {
                            String[] parts = line.split("\\|");
                            if(parts.length < 4) continue;
                            count++;
                            String date = parts[0];
                            String name = parts[1];
                            String email = parts[2];
                            String msg = parts[3];
                    %>
                    <tr>
                        <td><%= date %></td>
                        <td>
                            <div style="font-weight: 600;"><%= name %></div>
                            <div style="font-size: 0.7rem; color: var(--accent);"><%= email %></div>
                        </td>
                        <td style="color: var(--text-muted); font-size: 0.85rem; line-height: 1.5; padding-right: 2rem;">
                            <%= msg %>
                        </td>
                        <td class="text-right">
                            <a href="mailto:<%= email %>?subject=Regarding your inquiry at Noah Studio" class="btn-icon" title="Reply via Email">
                                <i class="fa fa-reply"></i>
                            </a>
                        </td>
                    </tr>
                    <% } %>
                    <% if(count == 0) { %>
                    <tr><td colspan="4" class="text-center py-5 text-muted">No inquiries found in logs.</td></tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </main>
</div>

</body>
</html>
