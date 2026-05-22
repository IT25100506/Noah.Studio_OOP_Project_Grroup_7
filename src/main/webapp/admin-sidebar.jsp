<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String currentURI = request.getRequestURI();
    String queryString = request.getQueryString();
    String activePage = "dashboard";

    HttpSession navSession = request.getSession(false);
    String navRole = (navSession != null) ? (String) navSession.getAttribute("role") : "";
    if (navRole == null) navRole = "";

    if (currentURI.contains("users-management")) {
        activePage = "users";
    } else if (currentURI.contains("booking-management") || currentURI.contains("staff-bookings")) {
        activePage = "bookings";
    } else if (currentURI.contains("portfolio-management")) {
        activePage = "gallery";
    } else if (currentURI.contains("packages-management")) {
        activePage = "packages";
    } else if (currentURI.contains("payment") || currentURI.contains("staff-payments") || (currentURI.contains("admin-dashboard") && queryString != null && queryString.contains("tab=payments"))) {
        activePage = "payments";
    } else if (currentURI.contains("staff-feedback") || currentURI.contains("review")) {
        activePage = "feedback";
    } else if (currentURI.contains("contact-management")) {
        activePage = "inquiries";
    } else if (currentURI.contains("dashboard")) {
        activePage = "dashboard";
    }

    String dashLink = "admin-dashboard.jsp";
    if ("photographer".equals(navRole)) dashLink = "photographer-dashboard.jsp";
    else if ("videographer".equals(navRole)) dashLink = "videographer-dashboard.jsp";

    boolean isAdmin = "admin".equals(navRole);
%>
<aside class="sidebar">
    <a href="index.jsp" class="sidebar-brand">NOAHSTUDIO</a>
    <ul class="sidebar-nav">
        <li><a href="<%= dashLink %>" class="<%= activePage.equals("dashboard") ? "active" : "" %>"><i class="fa fa-tachometer-alt"></i> Overview</a></li>

        <% if (isAdmin) { %>
        <li><a href="users-management.jsp" class="<%= activePage.equals("users") ? "active" : "" %>"><i class="fa fa-users"></i> Manage Users</a></li>
        <% } %>

        <li><a href="<%= isAdmin ? "booking-management.jsp" : "staff-bookings.jsp" %>" class="<%= activePage.equals("bookings") ? "active" : "" %>"><i class="fa fa-calendar-check"></i> Bookings</a></li>

        <% if (isAdmin) { %>
        <li><a href="packages-management.jsp" class="<%= activePage.equals("packages") ? "active" : "" %>"><i class="fa fa-box"></i> Packages</a></li>
        <% } %>

        <li><a href="portfolio-management.jsp" class="<%= activePage.equals("gallery") ? "active" : "" %>"><i class="fa fa-images"></i> Gallery</a></li>
        <li><a href="<%= isAdmin ? "payment?action=list" : "staff-payments.jsp" %>" class="<%= activePage.equals("payments") ? "active" : "" %>"><i class="fa fa-credit-card"></i> Payments</a></li>
        <li><a href="<%= isAdmin ? "review?action=list" : "staff-feedback.jsp" %>" class="<%= activePage.equals("feedback") ? "active" : "" %>"><i class="fa fa-star"></i> Feedback</a></li>
        <% if (isAdmin) { %>
        <li><a href="contact-management.jsp" class="<%= activePage.equals("inquiries") ? "active" : "" %>"><i class="fa fa-envelope-open-text"></i> Inquiries</a></li>
        <% } %>
    </ul>
    <a href="user?action=logout" class="logout-link"><i class="fa fa-sign-out-alt"></i> Logout</a>
</aside>