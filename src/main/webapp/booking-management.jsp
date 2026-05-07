<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.noahstudio.model.*, com.noahstudio.util.FileHandler, java.util.*" %>
<%
    // 1. Session & Auth Check
    HttpSession sess = request.getSession(false);
    if (sess == null || !"admin".equals(sess.getAttribute("role"))) { 
        response.sendRedirect("login.jsp"); 
        return; 
    }
    
    // 2. Initialize Data
    FileHandler.init(application.getRealPath("/") + "data");
    
    List<Booking> bookings = new ArrayList<>();
    for (String l : FileHandler.readLines("bookings.txt")) { 
        Booking b = Booking.fromFileString(l); 
        if (b != null) bookings.add(b); 
    }
    
    List<User> staffList = new ArrayList<>();
    for (String l : FileHandler.readLines("users.txt")) {
        User u = User.fromFileString(l);
        if (u != null && ("photographer".equals(u.getRole()) || "videographer".equals(u.getRole()))) {
            staffList.add(u);
        }
    }
    
    List<User> clients = new ArrayList<>();
    for (String l : FileHandler.readLines("users.txt")) {
        User u = User.fromFileString(l);
        if (u != null && "client".equals(u.getRole())) {
            clients.add(u);
        }
    }
    
    List<ServicePackage> pkgList = new ArrayList<>();
    for (String l : FileHandler.readLines("packages.txt")) {
        ServicePackage p = ServicePackage.fromFileString(l);
        if (p != null) pkgList.add(p);
    }

    String query = request.getParameter("q");
    String statusFilter = request.getParameter("statusFilter");
    String searchQ = (query != null) ? query.toLowerCase().trim() : "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Booking Management — Noah Studio</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;800&family=Outfit:wght@400;800&display=swap" rel="stylesheet">
</head>
<body style="background: var(--bg-primary);">

<div class="dashboard-layout">
    <!-- Sidebar Navigation -->
    <jsp:include page="admin-sidebar.jsp" />

    <!-- Main Content Area -->
    <main class="main-content">
        <header class="content-header">
            <div class="header-title">
                <span class="section-tag">Reservations</span>
                <h1>Booking <span class="text-accent">Management</span></h1>
            </div>
            <div class="header-meta">
                Administrator Access • <%= new java.text.SimpleDateFormat("MMM dd, yyyy").format(new java.util.Date()) %>
            </div>
        </header>

        <div class="registry-controls mb-2">
            <div class="control-header">
                <h2>All Reservations</h2>
                <button class="btn-primary-sm" onclick="openNewBookingModal()">+ New Booking</button>
            </div>
            <form action="booking-management.jsp" method="get" class="search-bar">
                <div class="input-group">
                    <i class="fa fa-search"></i>
                    <input type="text" name="q" placeholder="Search by client or location..." value="<%= (query != null) ? query : "" %>">
                </div>
                <select name="statusFilter" class="filter-select">
                    <option value="">All Statuses</option>
                    <option value="Pending" <%= "Pending".equals(statusFilter) ? "selected" : "" %>>Pending</option>
                    <option value="Confirmed" <%= "Confirmed".equals(statusFilter) ? "selected" : "" %>>Confirmed</option>
                    <option value="Completed" <%= "Completed".equals(statusFilter) ? "selected" : "" %>>Completed</option>
                </select>
                <button type="submit" class="btn-secondary">Filter</button>
            </form>
        </div>

        <div class="card card-table">
            <table class="ns-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Client</th>
                        <th>Package</th>
                        <th>Date & Time</th>
                        <th>Location</th>
                        <th>Status</th>
                        <th>Assign Staff</th>
                        <th class="text-right">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% 
                        int count = 0;
                        for(Booking b : bookings) { 
                            boolean matchesQ = searchQ.isEmpty() || 
                                               (b.getClientName().toLowerCase().contains(searchQ)) || 
                                               (b.getEventLocation().toLowerCase().contains(searchQ)) ||
                                               (b.getId().toLowerCase().contains(searchQ));
                            boolean matchesS = statusFilter == null || statusFilter.isEmpty() || b.getStatus().equals(statusFilter);
                            
                            if (matchesQ && matchesS) {
                                count++;
                    %>
                    <tr>
                        <td class="text-accent font-bold"><%= b.getId() %></td>
                        <td>
                            <div style="font-weight: 600;"><%= b.getClientName() %></div>
                            <div style="font-size: 0.65rem; color: var(--text-muted);"><%= b.getClientContact() %></div>
                        </td>
                        <td><%= b.getServicePackageName() %></td>
                        <td>
                            <div><%= b.getEventDate() %></div>
                            <div style="font-size: 0.65rem; color: var(--accent);"><%= b.getEventTime() %></div>
                        </td>
                        <td><%= b.getEventLocation() %></td>
                        <td>
                            <form action="booking" method="post">
                                <input type="hidden" name="action" value="update">
                                <input type="hidden" name="id" value="<%= b.getId() %>">
                                <input type="hidden" name="redirect" value="booking-management.jsp">
                                <select name="status" class="filter-select" style="padding: 0.3rem; font-size: 0.7rem;" onchange="this.form.submit()">
                                    <option value="Pending" <%= "Pending".equals(b.getStatus()) ? "selected" : "" %>>Pending</option>
                                    <option value="Confirmed" <%= "Confirmed".equals(b.getStatus()) ? "selected" : "" %>>Confirm</option>
                                    <option value="Completed" <%= "Completed".equals(b.getStatus()) ? "selected" : "" %>>Complete</option>
                                    <option value="Cancelled" <%= "Cancelled".equals(b.getStatus()) ? "selected" : "" %>>Cancel</option>
                                </select>
                            </form>
                        </td>
                        <td>
                            <form action="booking" method="post">
                                <input type="hidden" name="action" value="update">
                                <input type="hidden" name="id" value="<%= b.getId() %>">
                                <input type="hidden" name="redirect" value="booking-management.jsp">
                                <select name="staffId" class="filter-select" style="padding: 0.3rem; font-size: 0.7rem; min-width: 140px;" onchange="this.form.submit()">
                                    <option value="-">-- No Staff --</option>
                                    <% for (User s : staffList) { %>
                                    <option value="<%= s.getId() %>" <%= s.getId().equals(b.getStaffId()) ? "selected" : "" %>><%= s.getFullName() %> (<%= s.getRole() %>)</option>
                                    <% } %>
                                </select>
                            </form>
                        </td>
                        <td class="text-right">
                            <div class="action-group">
                                <button class="btn-icon" title="Edit Full Details" 
                                        data-id="<%= b.getId() %>"
                                        data-pkgid="<%= b.getServicePackageId() %>"
                                        data-pkgname="<%= b.getServicePackageName().replace("\"", "&quot;") %>"
                                        data-date="<%= b.getEventDate() %>"
                                        data-time="<%= b.getEventTime() %>"
                                        data-loc="<%= b.getEventLocation().replace("\"", "&quot;") %>"
                                        data-type="<%= b.getEventType() %>"
                                        data-contact="<%= b.getClientContact().replace("\"", "&quot;") %>"
                                        onclick="initEditBooking(this)">
                                    <i class="fa fa-edit"></i>
                                </button>
                                <a href="booking?action=delete&id=<%= b.getId() %>&redirect=booking-management.jsp" class="btn-icon btn-delete" onclick="return confirm('Delete this booking permanently?')"><i class="fa fa-trash"></i></a>
                            </div>
                        </td>
                    </tr>
                    <%      }
                        } 
                        if(count == 0) {
                    %>
                    <tr><td colspan="8" class="text-center py-5 text-muted">No reservations found.</td></tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </main>
</div>

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
            <input type="hidden" name="redirect" value="booking-management.jsp">
            
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
        padding: 3.5rem; border-radius: 24px; position: relative; width: 90%;
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
    .text-accent { color: var(--accent); }
    .btn-icon.btn-delete:hover { color: var(--danger); }
</style>

<!-- New Booking Modal (Admin) -->
<div id="newBookingModal" class="modal-overlay" style="display:none;">
    <div class="modal-container" style="max-width: 700px;">
        <button class="modal-close-btn" onclick="closeNewBookingModal()">&times;</button>
        <span class="section-tag">Manual Entry</span>
        <h2 style="margin-bottom: 2rem;">Create <span style="color:var(--accent)">New Reservation</span></h2>
        
        <form action="booking" method="post">
            <input type="hidden" name="action" value="create">
            <input type="hidden" name="redirect" value="booking-management.jsp">
            <input type="hidden" name="packageName" id="new-packageName">
            
            <div style="display:grid; grid-template-columns: 1fr 1fr; gap: 1.5rem;">
                <div class="form-group" style="grid-column: span 2;">
                    <label>Select Client</label>
                    <select name="clientId" class="form-control" required>
                        <option value="">-- Choose Existing Client --</option>
                        <% for (User c : clients) { %>
                        <option value="<%= c.getId() %>"><%= c.getFullName() %> (<%= c.getUsername() %>)</option>
                        <% } %>
                    </select>
                </div>
                <div class="form-group">
                    <label>Select Package</label>
                    <select name="packageId" class="form-control" required onchange="document.getElementById('new-packageName').value = this.options[this.selectedIndex].text.split('—')[0].trim()">
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
                    <input type="text" name="eventLocation" class="form-control" placeholder="Venue name..." required>
                </div>
                <div class="form-group">
                    <label>Contact Number</label>
                    <input type="tel" name="clientContact" class="form-control" placeholder="+94..." required>
                </div>
            </div>
            
            <button type="submit" class="btn-primary" style="width: 100%; margin-top: 2rem; padding: 1.25rem;">Create Manual Booking</button>
        </form>
    </div>
</div>

<script>
    function openNewBookingModal() { document.getElementById('newBookingModal').style.display = 'flex'; }
    function closeNewBookingModal() { document.getElementById('newBookingModal').style.display = 'none'; }
    
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
</script>

</body>
</html>
