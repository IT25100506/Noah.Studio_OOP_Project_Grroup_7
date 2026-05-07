<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.noahstudio.model.*, com.noahstudio.util.FileHandler, java.util.*" %>
<%
    HttpSession sess = request.getSession(false);
    String role = (sess != null) ? (String) sess.getAttribute("role") : null;
    String uid  = (sess != null) ? (String) sess.getAttribute("userId") : null;
    if (sess == null || uid == null) { response.sendRedirect("login.jsp?redirect=booking%3Faction%3Dlist"); return; }
    if ("admin".equals(role)) { response.sendRedirect("booking-management.jsp"); return; }

    FileHandler.init(application.getRealPath("/") + "data");
    List<ServicePackage> pkgList = new ArrayList<>();
    for (String l : FileHandler.readLines("packages.txt")) {
        ServicePackage p = ServicePackage.fromFileString(l);
        if (p != null && p.isActive()) pkgList.add(p);
    }

    // Identify fully paid bookings
    Set<String> paidBookings = new HashSet<>();
    for (String l : FileHandler.readLines("payments.txt")) {
        Payment pay = Payment.fromFileString(l);
        if (pay != null && "Paid".equals(pay.getStatus()) && pay instanceof FullPayment) {
            paidBookings.add(pay.getBookingId());
        }
    }

    List<Booking> bookings = (List<Booking>) request.getAttribute("bookings");
    if (bookings == null) {
        bookings = new ArrayList<>();
        for (String l : FileHandler.readLines("bookings.txt")) {
            Booking b = Booking.fromFileString(l);
            if (b != null && ("admin".equals(role) || b.getClientId().equals(uid))) bookings.add(b);
        }
    }
    String error = (String) request.getAttribute("error");
    String success = (String) request.getAttribute("success");
    if (success == null) success = request.getParameter("success");

    // Fetch All Payments for this user
    List<Payment> userPayments = new ArrayList<>();
    for (String pl : FileHandler.readLines("payments.txt")) {
        Payment p = Payment.fromFileString(pl);
        if (p != null && uid.equals(p.getClientId())) userPayments.add(p);
    }

    // Fetch All Reviews for this user
    List<Review> userReviews = new ArrayList<>();
    for (String rl : FileHandler.readLines("reviews.txt")) {
        Review r = Review.fromFileString(rl);
        if (r != null && uid.equals(r.getClientId())) userReviews.add(r);
    }

    // Fetch All Staff (Photographers/Videographers)
    List<User> staffMembers = new ArrayList<>();
    for (String ul : FileHandler.readLines("users.txt")) {
        User u = User.fromFileString(ul);
        if (u != null && ("photographer".equals(u.getRole()) || "videographer".equals(u.getRole()))) {
            staffMembers.add(u);
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My Dashboard — Noah Studio</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body>
<nav class="navbar scrolled">
    <a class="navbar-brand" href="index.jsp">Noah<span>Studio</span></a>
    <ul class="nav-links">
        <li><a href="index.jsp#home">Home</a></li>
        <li><a href="index.jsp#about">About</a></li>
        <li><a href="index.jsp#portfolio">Portfolio</a></li>
        <li><a href="index.jsp#packages">Packages</a></li>
        <li><a href="index.jsp#testimonials">Review</a></li>
        <li><a href="index.jsp#contact">Contact</a></li>
        <% if (uid != null) { %>
            <li><a href="booking?action=list" class="active">My Dashboard</a></li>
            <li><a href="user?action=logout" class="btn-nav">Logout</a></li>
        <% } else { %>
            <li><a href="login.jsp" class="btn-nav">Login</a></li>
        <% } %>
    </ul>
</nav>

<div class="page-hero" style="padding-top: 10rem; padding-bottom: 2rem; text-align: center;">
    <span class="section-tag">Management</span>
    <h1>Your <span style="color:var(--accent)">Dashboard</span></h1>
</div>

<div class="container" style="margin-bottom: 3rem;">
    <div class="dashboard-tabs" style="display:flex; justify-content:center; gap:3rem; border-bottom: 1px solid #222; padding-bottom: 1rem;">
        <div class="dash-tab active" onclick="switchTab('bookings', this)" style="cursor:pointer; font-weight: 800; font-size: 0.8rem; letter-spacing: 1px; text-transform: uppercase;">Bookings</div>
        <div class="dash-tab" onclick="switchTab('payments', this)" style="cursor:pointer; font-weight: 800; font-size: 0.8rem; letter-spacing: 1px; text-transform: uppercase; color: var(--text-muted);">Payments</div>
        <div class="dash-tab" onclick="switchTab('reviews', this)" style="cursor:pointer; font-weight: 800; font-size: 0.8rem; letter-spacing: 1px; text-transform: uppercase; color: var(--text-muted);">Reviews</div>
    </div>
</div>

<section id="bookings-section" class="container dash-section active" style="padding-top:0;">
    <% if (error != null) { %>
        <div class="alert alert-danger" style="margin-bottom: 2rem; padding: 1.5rem; background: rgba(211,47,47,0.1); border: 1px solid var(--danger); border-radius: 12px; color: var(--danger); font-size: 0.85rem;">
            <i class="fa fa-exclamation-circle"></i> <%= error %>
        </div>
    <% } %>

    <div style="display:flex; justify-content: space-between; align-items: center; margin-bottom: 3rem;">
        <div>
            <span class="section-tag">Booking History</span>
            <h2 style="font-size: 2rem; margin-top: 0.5rem;">Recent <span style="color:var(--accent)">Reservations</span></h2>
        </div>
        <% if ("client".equals(role)) { %>
        <button class="btn-primary-sm" onclick="openBookingModal()">+ New Reservation</button>
        <% } %>
    </div>

    <div class="card" style="padding: 0; border: 1px solid rgba(255,255,255,0.05); overflow: hidden;">
        <table class="ns-table">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Package</th>
                    <th>Date</th>
                    <th>Location</th>
                    <th>Status</th>
                    <th style="text-align:right;">Actions</th>
                </tr>
            </thead>
            <tbody>
                <% for (Booking b : bookings) { %>
                <tr>
                    <td style="color:var(--accent); font-weight: 800;"><%= b.getId() %></td>
                    <td><%= b.getServicePackageName() %></td>
                    <td><%= b.getEventDate() %></td>
                    <td><%= b.getEventLocation() %></td>
                    <td>
                        <span class="role-badge <%= "Confirmed".equals(b.getStatus()) ? "badge-success" : "badge-muted" %>" style="margin:0; font-size: 0.6rem;">
                            <%= b.getStatus().toUpperCase() %>
                        </span>
                    </td>
                    <td style="text-align:right;">
                        <div style="display:flex; gap: 0.5rem; justify-content: flex-end; align-items: center;">
                            <% if ("admin".equals(role)) { %>
                                <form action="booking" method="post" style="display:flex; gap: 0.5rem;">
                                    <input type="hidden" name="action" value="update">
                                    <input type="hidden" name="id" value="<%= b.getId() %>">
                                    <select name="status" class="filter-select" style="padding: 0.3rem 0.5rem; font-size: 0.7rem; min-width: 100px;" onchange="this.form.submit()">
                                        <option value="Pending" <%= "Pending".equals(b.getStatus()) ? "selected" : "" %>>Pending</option>
                                        <option value="Confirmed" <%= "Confirmed".equals(b.getStatus()) ? "selected" : "" %>>Confirm</option>
                                        <option value="Completed" <%= "Completed".equals(b.getStatus()) ? "selected" : "" %>>Complete</option>
                                    </select>
                                    <select name="staffId" class="filter-select" style="padding: 0.3rem 0.5rem; font-size: 0.7rem; min-width: 130px;" onchange="this.form.submit()">
                                        <option value="-">-- Assign Staff --</option>
                                        <% 
                                           for (String sl : FileHandler.readLines("users.txt")) {
                                               User u = User.fromFileString(sl);
                                               if (u != null && ("photographer".equals(u.getRole()) || "videographer".equals(u.getRole()))) {
                                        %>
                                        <option value="<%= u.getId() %>" <%= u.getId().equals(b.getStaffId()) ? "selected" : "" %>><%= u.getFullName() %> (<%= u.getRole() %>)</option>
                                        <% }} %>
                                    </select>
                                </form>
                            <% } %>
                            
                            <% if ("admin".equals(role) || ("client".equals(role) && "Pending".equals(b.getStatus()))) { %>
                                <button class="btn-icon" title="Edit Booking" 
                                        data-id="<%= b.getId() %>"
                                        data-pkgid="<%= b.getServicePackageId() != null ? b.getServicePackageId() : "" %>"
                                        data-pkgname="<%= b.getServicePackageName() != null ? b.getServicePackageName().replace("\"", "&quot;") : "" %>"
                                        data-date="<%= b.getEventDate() != null ? b.getEventDate() : "" %>"
                                        data-time="<%= b.getEventTime() != null ? b.getEventTime() : "" %>"
                                        data-loc="<%= b.getEventLocation() != null ? b.getEventLocation().replace("\"", "&quot;") : "" %>"
                                        data-type="<%= b.getEventType() != null ? b.getEventType() : "" %>"
                                        data-contact="<%= b.getClientContact() != null ? b.getClientContact().replace("\"", "&quot;") : "" %>"
                                        onclick="initEditBooking(this)">
                                    <i class="fa fa-edit"></i>
                                </button>
                                <a href="booking?action=delete&id=<%= b.getId() %>" class="btn-icon btn-delete" title="Cancel Booking" onclick="return confirm('Cancel this booking?')">
                                    <i class="fa fa-trash"></i>
                                </a>
                            <% } %>
                        </div>
                    </td>
                </tr>
                <% } %>
                <% if (bookings.isEmpty()) { %>
                <tr><td colspan="6" style="text-align:center; padding: 4rem; color:var(--text-muted);">No bookings found. Start by creating a new reservation.</td></tr>
                <% } %>
            </tbody>
        </table>
    </div>
</section>

<!-- Consolidated Payments Section -->
<section id="payments-section" class="container dash-section" style="display:none; padding-top:0;">
    <div style="margin-bottom: 3rem;">
        <span class="section-tag">Financial Summary</span>
        <h2 style="font-size: 2rem; margin-top: 0.5rem;">Payment <span style="color:var(--accent)">History</span></h2>
    </div>
    
    <div class="card" style="padding: 0; border: 1px solid rgba(255,255,255,0.05); overflow: hidden;">
        <table class="ns-table">
            <thead>
                <tr>
                    <th>Booking ID</th>
                    <th>Package</th>
                    <th>Cost (LKR)</th>
                    <th>Status</th>
                    <th style="text-align:right;">Actions</th>
                </tr>
            </thead>
            <tbody>
                <% for (Booking b : bookings) { 
                    double pkgPrice = 0;
                    for(ServicePackage sp : pkgList) if(sp.getId().equals(b.getServicePackageId())) pkgPrice = sp.getPrice();
                    
                    List<Payment> bkgPayments = new ArrayList<>();
                    double totalPaid = 0;
                    for(Payment p : userPayments) {
                        if(p.getBookingId().equals(b.getId())) {
                            bkgPayments.add(p);
                            if("Paid".equals(p.getStatus())) totalPaid += p.getAmount();
                        }
                    }
                    boolean isFullyPaid = (totalPaid >= pkgPrice && pkgPrice > 0);
                %>
                <tr>
                    <td style="color:var(--accent); font-weight: 800;"><%= b.getId() %></td>
                    <td><%= b.getServicePackageName() %></td>
                    <td><%= String.format("%.0f", pkgPrice) %></td>
                    <td>
                        <span class="role-badge <%= isFullyPaid ? "badge-success" : "badge-muted" %>" style="font-size: 0.6rem;">
                            <%= isFullyPaid ? "SETTLED" : "UNPAID" %>
                        </span>
                    </td>
                    <td style="text-align:right;">
                        <div class="action-group" style="justify-content: flex-end;">
                            <% if (!isFullyPaid) { %>
                                <button class="btn-primary-sm" onclick="initPayment('<%= b.getId() %>', '<%= b.getServicePackageName() %>', '<%= pkgPrice %>')">
                                    <i class="fa fa-credit-card"></i> Pay
                                </button>
                            <% } %>
                            
                            <% if(!bkgPayments.isEmpty()) { %>
                                <button class="btn-icon" title="Payment History" 
                                        onclick="showBkgPaymentHistory('<%= b.getId() %>', '<%= bkgPayments.size() %>', '<%= totalPaid %>')">
                                    <i class="fa fa-history"></i>
                                </button>
                                <div id="data-pay-<%= b.getId() %>" style="display:none;">
                                    <% for(Payment bp : bkgPayments) { %>
                                        <div class="pay-row">
                                            <span><%= bp.getPaidAt() %></span>
                                            <span><%= bp.getPaymentCategory() %></span>
                                            <span class="text-accent">LKR <%= String.format("%.0f", bp.getAmount()) %></span>
                                            <span class="status-<%= bp.getStatus().toLowerCase() %>"><%= bp.getStatus() %></span>
                                        </div>
                                    <% } %>
                                </div>
                            <% } %>
                        </div>
                    </td>
                </tr>
                <% } %>
            </tbody>
        </table>
    </div>
</section>

<!-- My Reviews Section -->
<section id="reviews-section" class="container dash-section" style="display:none; padding-top:0;">
    <div style="display:flex; justify-content: space-between; align-items: center; margin-bottom: 3rem;">
        <div>
            <span class="section-tag">Feedback History</span>
            <h2 style="font-size: 2rem; margin-top: 0.5rem;">Your <span style="color:var(--accent)">Reviews</span></h2>
        </div>
        <button class="btn-primary-sm" onclick="initReview('-', '-')">
            <i class="fa fa-plus-circle"></i> Submit Feedback
        </button>
    </div>
    
    <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 1.5rem; margin-bottom: 3rem;">
        <% for (Review r : userReviews) { %>
            <div class="card" style="padding: 2rem; border: 1px solid rgba(255,255,255,0.05);">
                <div style="margin-bottom: 0.8rem;">
                    <% for(int i=1; i<=5; i++) { %>
                        <i class="fa<%= i <= r.getRating() ? "s" : "r" %> fa-star" style="color: var(--accent); font-size: 0.7rem;"></i>
                    <% } %>
                </div>
                <p style="font-size: 0.85rem; color: #ccc; font-style: italic; margin-bottom: 1.5rem;">"<%= r.getComment() %>"</p>
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
                    <span style="font-size: 0.65rem; color: var(--text-muted);"><%= r.getDate() %></span>
                    <%= r.renderBadgeHTML() %>
                </div>
                <div style="display: flex; gap: 0.5rem; padding-top: 1rem; border-top: 1px solid rgba(255,255,255,0.05);">
                    <button class="btn-icon" title="Edit Review" 
                            data-id="<%= r.getId() %>"
                            data-rating="<%= r.getRating() %>"
                            data-staff="<%= r.getStaffId() %>"
                            data-comment="<%= r.getComment().replace("\"", "&quot;") %>"
                            onclick="initEditReview(this)">
                        <i class="fa fa-edit"></i>
                    </button>
                    <a href="review?action=delete&id=<%= r.getId() %>&source=dashboard" class="btn-icon btn-delete" title="Delete Review" onclick="return confirm('Delete this review?')">
                        <i class="fa fa-trash"></i>
                    </a>
                </div>
            </div>
        <% } %>
    </div>

</section>

<!-- Create Booking Modal -->
<% if ("client".equals(role)) { %>
<div id="newBookingModal" class="modal-overlay" style="display:none;">
    <div class="modal-container" style="max-width: 600px;">
        <button class="modal-close-btn" onclick="closeBookingModal()">&times;</button>
        <span class="section-tag">New Reservation</span>
        <h2 style="margin-bottom: 2rem;">Confirm your <span style="color:var(--accent)">Booking</span></h2>
        
        <form action="booking" method="post">
            <input type="hidden" name="action" value="create">
            <input type="hidden" name="packageName" id="packageName">
            
            <div style="display:grid; grid-template-columns: 1fr 1fr; gap: 1.5rem;">
                <div class="form-group">
                    <label>Select Package</label>
                    <select name="packageId" class="form-control" required onchange="document.getElementById('packageName').value = this.options[this.selectedIndex].text.split('—')[0].trim()">
                        <option value="">-- Choose Plan --</option>
                        <% for (ServicePackage p : pkgList) { %>
                        <option value="<%= p.getId() %>"><%= p.getName() %> — LKR <%= String.format("%.0f", p.getPrice()) %></option>
                        <% } %>
                    </select>
                </div>
                <div class="form-group">
                    <label>Event Type</label>
                    <select name="eventType" class="form-control">
                        <option>Wedding</option>
                        <option>Corporate</option>
                        <option>Portrait</option>
                        <option>Event Coverage</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Event Date</label>
                    <input type="date" name="eventDate" class="form-control" required>
                </div>
                <div class="form-group">
                    <label>Event Time</label>
                    <input type="time" name="eventTime" class="form-control" required>
                </div>
                <div class="form-group">
                    <label>Event Location</label>
                    <input type="text" name="eventLocation" class="form-control" placeholder="Venue name, City..." required>
                </div>
                <div class="form-group">
                    <label>Contact Number</label>
                    <input type="tel" name="clientContact" class="form-control" placeholder="e.g. +94 77..." required>
                </div>
            </div>
            
            <div style="margin-top: 1.5rem; padding: 1.5rem; background: rgba(255,255,255,0.02); border-radius: 12px; border: 1px solid rgba(255,255,255,0.05);">
                <p style="font-size: 0.75rem; color: var(--text-muted); line-height: 1.6;">
                    <i class="fa fa-info-circle" style="color:var(--accent); margin-right: 0.5rem;"></i>
                    Once submitted, our team will review your request and assign a professional photographer/videographer. You will be notified of the status change.
                </p>
            </div>

            <button type="submit" class="btn-primary" style="width: 100%; margin-top: 2rem; padding: 1.25rem;">Confirm Booking Request</button>
        </form>
    </div>
</div>
<% } %>

<!-- Edit Booking Modal -->
<div id="editBookingModal" class="modal-overlay" style="display:none;">
    <div class="modal-container" style="max-width: 600px;">
        <button class="modal-close-btn" onclick="closeEditModal()">&times;</button>
        <span class="section-tag">Modify Request</span>
        <h2 style="margin-bottom: 2rem;">Update <span style="color:var(--accent)">Booking</span></h2>
        
        <form action="booking" method="post">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="id" id="edit-bkg-id">
            <input type="hidden" name="packageName" id="edit-packageName">
            
            <div style="display:grid; grid-template-columns: 1fr 1fr; gap: 1.5rem;">
                <div class="form-group">
                    <label>Select Package</label>
                    <select name="packageId" id="edit-packageId" class="form-control" required onchange="document.getElementById('edit-packageName').value = this.options[this.selectedIndex].text.split('—')[0].trim()">
                        <% for (ServicePackage p : pkgList) { %>
                        <option value="<%= p.getId() %>"><%= p.getName() %> — LKR <%= String.format("%.0f", p.getPrice()) %></option>
                        <% } %>
                    </select>
                </div>
                <div class="form-group">
                    <label>Event Type</label>
                    <select name="eventType" id="edit-eventType" class="form-control">
                        <option>Wedding</option>
                        <option>Corporate</option>
                        <option>Portrait</option>
                        <option>Event Coverage</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Event Date</label>
                    <input type="date" name="eventDate" id="edit-eventDate" class="form-control" required>
                </div>
                <div class="form-group">
                    <label>Event Time</label>
                    <input type="time" name="eventTime" id="edit-eventTime" class="form-control" required>
                </div>
                <div class="form-group">
                    <label>Event Location</label>
                    <input type="text" name="eventLocation" id="edit-eventLocation" class="form-control" required>
                </div>
                <div class="form-group">
                    <label>Contact Number</label>
                    <input type="tel" name="clientContact" id="edit-clientContact" class="form-control" required>
                </div>
            </div>
            
            <button type="submit" class="btn-primary" style="width: 100%; margin-top: 2rem; padding: 1.25rem;">Save Changes</button>
        </form>
    </div>
</div>

<style>
    .modal-overlay { 
        position: fixed; top: 0; left: 0; width: 100%; height: 100%;
        backdrop-filter: blur(12px); background: rgba(0,0,0,0.85);
        display: flex; align-items: center; justify-content: center; z-index: 10000;
    }
    .modal-container { 
        background: #080808; border: 1px solid rgba(255,255,255,0.08);
        padding: 2.5rem; border-radius: 24px; position: relative; width: 90%;
    }
    .modal-close-btn {
        background: #1a1a1a; color: #fff; width: 32px; height: 32px;
        border-radius: 50%; border: none; cursor: pointer;
        position: absolute; top: 2rem; right: 2rem; transition: 0.3s;
    }
    .modal-close-btn:hover { background: var(--danger); transform: rotate(90deg); }
    .form-group label {
        font-size: 0.65rem; text-transform: uppercase; letter-spacing: 1.5px;
        color: var(--accent); font-weight: 800; margin-bottom: 0.75rem; display: block;
    }
    .form-control {
        background: #0f0f0f !important; border: 1px solid #1a1a1a !important;
        color: #fff !important; padding: 1rem !important; border-radius: 12px !important;
    }
</style>

<!-- Payment Modal -->
<div id="paymentModal" class="modal-overlay" style="display:none;">
    <div class="modal-container" style="max-width: 550px;">
        <button class="modal-close-btn" onclick="closePaymentModal()" style="top:1.5rem; right:1.5rem;">&times;</button>
        <span class="section-tag" style="margin-bottom: 0.5rem;">Secure Checkout</span>
        <h2 style="margin-bottom: 1.5rem; font-size: 1.5rem;">Process <span style="color:var(--accent)">Payment</span></h2>
        
        <form action="payment" method="post">
            <input type="hidden" name="action" value="create">
            <input type="hidden" name="bookingId" id="pay-bookingId">
            <input type="hidden" name="redirect" value="booking?action=list">
            
            <div class="form-group" style="margin-bottom: 1rem;">
                <label style="margin-bottom: 0.3rem;">Reference Booking</label>
                <div id="pay-ref" style="font-weight: 800; color: var(--accent); font-size: 0.9rem;"></div>
            </div>
            
            <div style="display:grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin-bottom: 1rem;">
                <div class="form-group">
                    <label style="margin-bottom: 0.3rem;">Payment Plan</label>
                    <select name="paymentType" id="pay-type" class="form-control" onchange="toggleBalance(this)" required style="padding: 0.8rem !important;">
                        <option value="Full">Full Settlement</option>
                        <option value="Partial">Partial / Installment</option>
                    </select>
                </div>
                <div class="form-group">
                    <label style="margin-bottom: 0.3rem;">Amount (LKR)</label>
                    <input type="number" name="amount" id="pay-amount" class="form-control" placeholder="0.00" required style="padding: 0.8rem !important;" oninput="calculateBalance()">
                </div>
            </div>
            
            <input type="hidden" id="pay-total-pkg-price">
            
            <div id="balance-group" class="form-group" style="display:none; margin-bottom: 1rem;">
                <label style="margin-bottom: 0.3rem;">Remaining Balance (LKR)</label>
                <input type="number" name="balanceDue" class="form-control" placeholder="Outstanding amount" style="padding: 0.8rem !important;">
            </div>
            
            <div class="form-group" style="margin-bottom: 1rem;">
                <label style="margin-bottom: 0.3rem;">Payment Method</label>
                <select name="method" class="form-control" style="padding: 0.8rem !important;">
                    <option>Online Payment</option>
                    <option>Bank Transfer</option>
                    <option>Cash Deposit</option>
                </select>
            </div>
            
            <div class="form-group" style="margin-bottom: 1rem;">
                <label style="margin-bottom: 0.3rem;">Additional Notes</label>
                <textarea name="notes" class="form-control" placeholder="Transaction ID or bank reference..." rows="2" style="padding: 0.8rem !important;"></textarea>
            </div>
            
            <button type="submit" class="btn-primary" style="width: 100%; margin-top: 1rem; padding: 1rem;">Submit Payment</button>
        </form>
    </div>
</div>

<!-- Booking Payment History Modal -->
<div id="bkgPaymentModal" class="modal-overlay" style="display:none;">
    <div class="modal-container" style="max-width: 600px; background: #080808; padding: 2.5rem; border-radius: 20px; border: 1px solid rgba(255,255,255,0.1);">
        <button class="modal-close-btn" onclick="closeBkgPayModal()" style="position:absolute; top:1.5rem; right:1.5rem; background:none; border:none; color:#fff; font-size:1.5rem; cursor:pointer;">&times;</button>
        <span class="section-tag">Financial Ledger</span>
        <h2 style="margin-bottom: 1rem; font-size: 1.5rem;">Payment <span style="color:var(--accent)">History</span></h2>
        <div id="bkg-pay-meta" style="font-size: 0.75rem; color: var(--text-muted); margin-bottom: 2rem; font-weight: 600;"></div>
        
        <div class="ledger-header" style="display:grid; grid-template-columns: 1fr 1.5fr 1.5fr 1fr; padding: 1rem; border-bottom: 1px solid #222; font-size: 0.65rem; text-transform: uppercase; letter-spacing: 1px; color: var(--accent); font-weight: 800;">
            <div>Date</div>
            <div>Category</div>
            <div>Amount</div>
            <div>Status</div>
        </div>
        <div id="bkg-pay-list" style="max-height: 300px; overflow-y: auto;">
            <!-- Rows injected by JS -->
        </div>
    </div>
</div>

<style>
    .pay-row { 
        display: grid; grid-template-columns: 1fr 1.5fr 1.5fr 1fr; 
        padding: 1.25rem 1rem; border-bottom: 1px solid #111; font-size: 0.8rem; 
    }
    .status-paid { color: #4caf50; font-weight: 600; }
    .status-pending { color: #ff9800; font-weight: 600; }
    .status-refunded { color: var(--danger); font-weight: 600; }
</style>
<!-- Review Submission Modal -->
<div id="reviewModal" class="modal-overlay" style="display:none;">
    <div class="modal-container" style="max-width: 500px;">
        <button class="modal-close-btn" onclick="closeReviewModal()">&times;</button>
        <span class="section-tag">Share your experience</span>
        <h2>Leave a <span style="color:var(--accent)">Review</span></h2>
        
        <form action="review" method="post">
            <input type="hidden" name="action" value="create">
            <input type="hidden" name="source" value="dashboard">
            <input type="hidden" name="bookingId" id="rev-bookingId">
            
            <div class="form-group" style="margin-bottom: 1.5rem;">
                <label>Select Professional (Optional)</label>
                <select name="staffId" id="rev-staffId" class="form-control">
                    <option value="-">-- General Studio Feedback --</option>
                    <% for (User s : staffMembers) { %>
                        <option value="<%= s.getId() %>"><%= s.getFullName() %> (<%= s.getRole() %>)</option>
                    <% } %>
                </select>
            </div>
            
            <div class="form-group" style="margin-bottom: 1.5rem;">
                <label>Rating</label>
                <div class="star-rating-container" style="display: flex; gap: 0.5rem; margin-top: 0.5rem;">
                    <% for(int i=1; i<=5; i++) { %>
                        <i class="far fa-star star-input" data-value="<%= i %>" style="cursor: pointer; color: var(--accent); font-size: 1.5rem;"></i>
                    <% } %>
                </div>
                <input type="hidden" name="rating" id="rev-rating" value="5" required>
            </div>
            
            <div class="form-group" style="margin-bottom: 2rem;">
                <label>Comments</label>
                <textarea name="comment" class="form-control" rows="4" placeholder="How was your session with our professional?" required></textarea>
            </div>
            
            <button type="submit" class="btn-primary" style="width: 100%; padding: 1.25rem;">Submit Review</button>
        </form>
    </div>
</div>

<style>
    .star-input.active { font-weight: 900 !important; }
</style>

<!-- Success Toast Notification -->
<div id="successToast" class="toast-popup">
    <div class="toast-content">
        <i class="fa fa-check-circle" style="color: #4caf50; font-size: 1.5rem;"></i>
        <div>
            <div style="font-weight: 800; font-size: 0.9rem;">Success</div>
            <div id="toastMessage" style="font-size: 0.75rem; color: #aaa;"></div>
        </div>
    </div>
</div>

<style>
    .toast-popup {
        position: fixed; top: 2rem; right: 2rem; z-index: 20000;
        background: #111; border: 1px solid rgba(76, 175, 80, 0.3);
        padding: 1.5rem 2rem; border-radius: 16px;
        box-shadow: 0 20px 50px rgba(0,0,0,0.5);
        transform: translateX(120%); transition: 0.5s cubic-bezier(0.68, -0.55, 0.27, 1.55);
        min-width: 300px;
    }
    .toast-popup.active { transform: translateX(0); }
    .toast-content { display: flex; align-items: center; gap: 1.25rem; }
</style>
<!-- Edit Review Modal -->
<div id="editReviewModal" class="modal-overlay" style="display:none;">
    <div class="modal-container" style="max-width: 500px;">
        <button class="modal-close-btn" onclick="closeEditReview()">&times;</button>
        <span class="section-tag">Update Feedback</span>
        <h2>Edit your <span style="color:var(--accent)">Review</span></h2>
        
        <form action="review" method="post">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="source" value="dashboard">
            <input type="hidden" name="id" id="edit-rev-id">
            
            <div class="form-group" style="margin-bottom: 1.5rem;">
                <label>Professional</label>
                <select name="staffId" id="edit-rev-staffId" class="form-control">
                    <option value="-">-- General Studio Feedback --</option>
                    <% for (User s : staffMembers) { %>
                        <option value="<%= s.getId() %>"><%= s.getFullName() %> (<%= s.getRole() %>)</option>
                    <% } %>
                </select>
            </div>

            <div class="form-group" style="margin-bottom: 1.5rem;">
                <label>Star Rating</label>
                <div class="star-edit-container" style="display: flex; gap: 0.5rem; margin-top: 0.5rem;">
                    <% for(int i=1; i<=5; i++) { %>
                        <i class="far fa-star star-edit-btn" data-value="<%= i %>" style="cursor: pointer; color: var(--accent); font-size: 1.5rem;"></i>
                    <% } %>
                </div>
                <input type="hidden" name="rating" id="edit-rev-rating" required>
            </div>
            
            <div class="form-group" style="margin-bottom: 2rem;">
                <label>Your Comments</label>
                <textarea name="comment" id="edit-rev-comment" class="form-control" rows="4" required></textarea>
            </div>
            
            <button type="submit" class="btn-primary" style="width: 100%; padding: 1.25rem;">Save Changes</button>
        </form>
    </div>
</div>

<style>
    .star-input.active, .star-edit-btn.active { font-weight: 900 !important; }
</style>

<script>
    function openBookingModal() { document.getElementById('newBookingModal').style.display = 'flex'; }
    function closeBookingModal() { document.getElementById('newBookingModal').style.display = 'none'; }
    
    function initEditBooking(btn) {
        document.getElementById('edit-bkg-id').value = btn.getAttribute('data-id');
        document.getElementById('edit-packageId').value = btn.getAttribute('data-pkgid');
        document.getElementById('edit-packageName').value = btn.getAttribute('data-pkgname');
        document.getElementById('edit-eventDate').value = btn.getAttribute('data-date');
        document.getElementById('edit-eventTime').value = btn.getAttribute('data-time');
        document.getElementById('edit-eventLocation').value = btn.getAttribute('data-loc');
        document.getElementById('edit-eventType').value = btn.getAttribute('data-type');
        document.getElementById('edit-clientContact').value = btn.getAttribute('data-contact');
        document.getElementById('editBookingModal').style.display = 'flex';
    }
    
    function closeEditModal() { document.getElementById('editBookingModal').style.display = 'none'; }

    function initPayment(bId, pName, pPrice) {
        document.getElementById('pay-bookingId').value = bId;
        document.getElementById('pay-ref').innerText = bId + " — " + pName;
        document.getElementById('pay-amount').value = pPrice;
        document.getElementById('pay-total-pkg-price').value = pPrice;
        document.getElementById('pay-type').value = 'Full';
        document.getElementById('balance-group').style.display = 'none';
        document.getElementById('paymentModal').style.display = 'flex';
    }
    function closePaymentModal() { document.getElementById('paymentModal').style.display = 'none'; }
    
    function toggleBalance(select) {
        const balanceGroup = document.getElementById('balance-group');
        if (select.value === 'Partial') {
            balanceGroup.style.display = 'block';
            calculateBalance();
        } else {
            balanceGroup.style.display = 'none';
        }
    }

    function calculateBalance() {
        const total = parseFloat(document.getElementById('pay-total-pkg-price').value) || 0;
        const paid = parseFloat(document.getElementById('pay-amount').value) || 0;
        const balance = total - paid;
        const balanceInput = document.getElementsByName('balanceDue')[0];
        if (balanceInput) {
            balanceInput.value = (balance > 0) ? balance : 0;
        }
    }

    function showBkgPaymentHistory(bId, count, total) {
        const list = document.getElementById('bkg-pay-list');
        const data = document.getElementById('data-pay-' + bId);
        list.innerHTML = data.innerHTML;
        document.getElementById('bkg-pay-meta').innerText = "Booking ID: " + bId + " | Total Transactions: " + count + " | Confirmed Paid: LKR " + total;
        document.getElementById('bkgPaymentModal').style.display = 'flex';
    }
    function closeBkgPayModal() { document.getElementById('bkgPaymentModal').style.display = 'none'; }

    function initReview(bId, sId) {
        document.getElementById('rev-bookingId').value = bId;
        const staffSelect = document.getElementById('rev-staffId');
        if (sId && sId !== '-') {
            staffSelect.value = sId;
            staffSelect.disabled = true; 
        } else {
            staffSelect.value = '-';
            staffSelect.disabled = false;
        }
        setSubmitRating(5);
        document.getElementById('reviewModal').style.display = 'flex';
        
        const stars = document.querySelectorAll('.star-input');
        stars.forEach(star => {
            star.onclick = function() {
                setSubmitRating(this.getAttribute('data-value'));
            };
        });
    }
    function closeReviewModal() { document.getElementById('reviewModal').style.display = 'none'; }
    function setSubmitRating(val) {
        document.getElementById('rev-rating').value = val;
        const stars = document.querySelectorAll('.star-input');
        stars.forEach((star, idx) => {
            if (idx < val) {
                star.classList.replace('far', 'fas');
                star.classList.add('active');
            } else {
                star.classList.replace('fas', 'far');
                star.classList.remove('active');
            }
        });
    }

    // Trigger Success Toast
    document.addEventListener('DOMContentLoaded', function() {
        // Handle URL-based tab switching
        const urlParams = new URLSearchParams(window.location.search);
        const activeTab = urlParams.get('tab');
        if (activeTab === 'reviews') {
            const reviewsTabBtn = document.querySelector('.dash-tab[onclick*="reviews"]');
            if (reviewsTabBtn) switchTab('reviews', reviewsTabBtn);
        } else if (activeTab === 'payments') {
            const paymentsTabBtn = document.querySelector('.dash-tab[onclick*="payments"]');
            if (paymentsTabBtn) switchTab('payments', paymentsTabBtn);
        }

        const msg = '<%= (success != null) ? success : "" %>';
        if (msg && msg.trim().length > 0) {
            const toast = document.getElementById('successToast');
            const toastMsg = document.getElementById('toastMessage');
            if (toast && toastMsg) {
                toastMsg.innerText = msg;
                toast.classList.add('active');
                setTimeout(() => { toast.classList.remove('active'); }, 5000);
            }
        }
    });

    function switchTab(sectionId, element) {
        // Hide all sections
        document.querySelectorAll('.dash-section').forEach(sec => sec.style.display = 'none');
        // Show target section
        document.getElementById(sectionId + '-section').style.display = 'block';
        
        // Reset tab styles
        document.querySelectorAll('.dash-tab').forEach(tab => {
            tab.style.color = 'var(--text-muted)';
            tab.classList.remove('active');
        });
        // Activate current tab
        element.style.color = 'var(--accent)';
        element.classList.add('active');
    }

    // Edit Review Functions
    function initEditReview(btn) {
        const id = btn.getAttribute('data-id');
        const rating = btn.getAttribute('data-rating');
        const staff = btn.getAttribute('data-staff');
        const comment = btn.getAttribute('data-comment');
        openEditReview(id, rating, staff, comment);
    }

    function openEditReview(id, rating, staff, comment) {
        document.getElementById('edit-rev-id').value = id;
        document.getElementById('edit-rev-staffId').value = staff;
        document.getElementById('edit-rev-comment').value = comment;
        setEditRating(rating);
        document.getElementById('editReviewModal').style.display = 'flex';
        
        const stars = document.querySelectorAll('.star-edit-btn');
        stars.forEach(star => {
            star.onclick = function() {
                setEditRating(this.getAttribute('data-value'));
            };
        });
    }
    function closeEditReview() { document.getElementById('editReviewModal').style.display = 'none'; }
    function setEditRating(val) {
        document.getElementById('edit-rev-rating').value = val;
        const stars = document.querySelectorAll('.star-edit-btn');
        stars.forEach((star, idx) => {
            if (idx < val) {
                star.classList.replace('far', 'fas');
                star.classList.add('active');
            } else {
                star.classList.replace('fas', 'far');
                star.classList.remove('active');
            }
        });
    }
</script>
</body>
</html>
