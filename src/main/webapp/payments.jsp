<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.noahstudio.model.*, java.util.*" %>
<%
    HttpSession sess = request.getSession(false);
    String uid = (sess != null) ? (String) sess.getAttribute("userId") : null;
    if (sess == null || uid == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<Payment> payments = (List<Payment>) request.getAttribute("payments");
    if (payments == null) {
        response.sendRedirect("payment?action=list");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My Payments — Noah Studio</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body>

<nav class="navbar scrolled">
    <a class="navbar-brand" href="index.jsp">Noah<span>Studio</span></a>
    <ul class="nav-links">
        <li><a href="index.jsp">Home</a></li>
        <li><a href="portfolio?action=list">Portfolio</a></li>
        <li><a href="booking?action=list">My Bookings</a></li>
        <li><a href="payment?action=list" class="active">Payments</a></li>
        <li><a href="user?action=logout" class="btn-nav">Logout</a></li>
    </ul>
</nav>

<div class="page-hero" style="padding-top: 10rem; padding-bottom: 3rem; text-align: center;">
    <span class="section-tag">Finance</span>
    <h1>Payment <span style="color:var(--accent)">History</span></h1>
</div>

<section style="padding-top:0;">
    <div class="container" style="max-width: 1000px;">
        <div class="card card-table">
            <table class="ns-table">
                <thead>
                    <tr>
                        <th>Date</th>
                        <th>Booking ID</th>
                        <th>Category</th>
                        <th>Amount</th>
                        <th>Status</th>
                        <th class="text-right">Receipt</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Payment p : payments) { %>
                    <tr>
                        <td style="font-size: 0.8rem;"><%= p.getPaidAt().equals("-") ? "Pending Submission" : p.getPaidAt() %></td>
                        <td class="text-accent font-bold"><%= p.getBookingId() %></td>
                        <td><%= p.getPaymentCategory() %></td>
                        <td style="font-weight: 800;">LKR <%= String.format("%.0f", p.getAmount()) %></td>
                        <td>
                            <span class="status-badge <%= p.getStatus().equals("Paid") ? "status-online" : "status-pending" %>">
                                <i class="fa fa-circle"></i> <%= p.getStatus() %>
                            </span>
                        </td>
                        <td class="text-right">
                            <a href="payment?action=invoice&id=<%= p.getId() %>" class="btn-secondary" style="font-size: 0.65rem; padding: 0.5rem 1rem;">View Details</a>
                        </td>
                    </tr>
                    <% } %>
                    <% if (payments.isEmpty()) { %>
                        <tr><td colspan="6" class="text-center py-5 text-muted">You have no recorded payments yet.</td></tr>
                    <% } %>
                </tbody>
            </table>
        </div>
        
        <div style="margin-top: 4rem; padding: 3rem; background: var(--bg-secondary); border-radius: 20px; border: 1px solid rgba(255,255,255,0.05); text-align: center;">
            <h3 style="margin-bottom: 1rem;">Need Help with a Payment?</h3>
            <p style="color:var(--text-muted); font-size: 0.9rem; margin-bottom: 2rem;">Our accounts team is available to assist you with installments or refund requests.</p>
            <a href="contact.jsp" class="btn-primary-sm">Contact Support</a>
        </div>
    </div>
</section>

</body>
</html>
