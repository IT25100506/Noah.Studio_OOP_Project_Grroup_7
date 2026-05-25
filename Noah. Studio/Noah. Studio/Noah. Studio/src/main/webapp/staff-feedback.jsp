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
    
    List<Review> myFeedback = new ArrayList<>();
    double avgRating = 0;
    for (String l : FileHandler.readLines("reviews.txt")) {
        Review r = Review.fromFileString(l);
        if (r != null && uid.equals(r.getStaffId())) {
            myFeedback.add(r);
            avgRating += r.getRating();
        }
    }
    if (!myFeedback.isEmpty()) avgRating /= myFeedback.size();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My Feedback — Noah Studio</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body style="background: var(--bg-primary);">

<div class="dashboard-layout">
    <jsp:include page="admin-sidebar.jsp" />

    <main class="main-content">
        <header class="content-header" style="margin-bottom: 3rem; display:flex; justify-content: space-between; align-items: flex-end;">
            <div>
                <span class="section-tag">Performance</span>
                <h1 style="font-size: 2.5rem; margin: 0;">Client <span class="serif" style="color:var(--accent); text-transform:none;">Feedback</span></h1>
            </div>
            <div style="text-align: right;">
                <div style="font-size: 0.8rem; color:var(--text-muted); text-transform:uppercase; letter-spacing:1px; margin-bottom: 0.5rem;">Average Rating</div>
                <div style="font-size: 2.5rem; font-weight: 800; color: var(--accent); line-height: 1;"><%= String.format("%.1f", avgRating) %> <i class="fa fa-star" style="font-size: 1.5rem;"></i></div>
            </div>
        </header>

        <div class="card">
            <h3 style="margin-bottom: 2rem;">Recent Reviews</h3>
            <% if (myFeedback.isEmpty()) { %>
                <p style="color:var(--text-muted); padding: 2rem; text-align: center;">No client feedback available yet.</p>
            <% } else { %>
                <% for (Review r : myFeedback) { %>
                    <div style="padding: 2rem; border-bottom: 1px solid #1a1a1a;">
                        <div style="color:var(--accent); margin-bottom: 0.5rem;">
                            <% for(int i=0; i<r.getRating(); i++) { %>★<% } %>
                        </div>
                        <p style="font-style: italic; margin-bottom: 1rem; color: #fff;">"<%= r.getComment() %>"</p>
                        <% 
                            String bookingInfo = "";
                            if (r instanceof com.noahstudio.model.VerifiedReview) {
                                bookingInfo = " (Booking: " + ((com.noahstudio.model.VerifiedReview)r).getBookingId() + ")";
                            }
                        %>
                        <div style="font-size: 0.7rem; color:var(--text-muted); text-transform: uppercase; letter-spacing: 1px;">— <%= r.getClientName() %><%= bookingInfo %></div>
                    </div>
                <% } %>
            <% } %>
        </div>
    </main>
</div>

</body>
</html>
