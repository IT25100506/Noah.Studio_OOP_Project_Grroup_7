<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.noahstudio.model.*, com.noahstudio.util.FileHandler, java.util.*" %>
<%
    HttpSession sess = request.getSession(false);
    if (sess == null || (!"photographer".equals(sess.getAttribute("role")) && !"videographer".equals(sess.getAttribute("role")))) {
        response.sendRedirect("login.jsp");
        return;
    }

    String uid = (String) sess.getAttribute("userId");
    FileHandler.init(application.getRealPath("/") + "data");
    
    List<Booking> myJobs = new ArrayList<>();
    for (String l : FileHandler.readLines("bookings.txt")) {
        Booking b = Booking.fromFileString(l);
        if (b != null && uid.equals(b.getStaffId())) {
            myJobs.add(b);
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My Assignments — Noah Studio</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body style="background: var(--bg-primary);">

<div class="dashboard-layout">
    <jsp:include page="admin-sidebar.jsp" />

    <main class="main-content">
        <header class="content-header" style="margin-bottom: 3rem;">
            <span class="section-tag">Schedule</span>
            <h1 style="font-size: 2.5rem; margin: 0;">My <span class="serif" style="color:var(--accent); text-transform:none;">Assignments</span></h1>
        </header>

        <div class="card card-table">
            <table class="ns-table">
                <thead>
                    <tr><th>ID</th><th>Client</th><th>Date</th><th>Type</th><th>Location</th><th>Status</th></tr>
                </thead>
                <tbody>
                    <% if (myJobs.isEmpty()) { %>
                        <tr><td colspan="6" style="text-align:center; padding:3rem; color:var(--text-muted);">No assignments found.</td></tr>
                    <% } else { %>
                        <% for (Booking b : myJobs) { %>
                            <tr>
                                <td style="color:var(--accent); font-weight: 800;"><%= b.getId() %></td>
                                <td><%= b.getClientName() %></td>
                                <td><%= b.getEventDate() %></td>
                                <td><%= b.getEventType() %></td>
                                <td><%= b.getEventLocation() %></td>
                                <td>
                                    <span class="role-badge <%= "Confirmed".equals(b.getStatus()) ? "badge-success" : "badge-muted" %>" style="margin:0; font-size:0.6rem;">
                                        <%= b.getStatus().toUpperCase() %>
                                    </span>
                                </td>
                            </tr>
                        <% } %>
                    <% } %>
                </tbody>
            </table>
        </div>
    </main>
</div>

</body>
</html>
