<%-- Feedback and Review Management Module - Owned by IT25100494 --%>
<%@ page import="com.noahstudio.model.*, com.noahstudio.util.FileHandler, java.util.*" %>
<%
    List<Review> reviews = (List<Review>) request.getAttribute("reviews");
    if (reviews == null) reviews = new ArrayList<>();
    
    HttpSession sess = request.getSession(false);
    if (sess == null || !"admin".equals(sess.getAttribute("role"))) {
        response.sendRedirect("login.jsp");
        return;
    }

    FileHandler.init(application.getRealPath("/") + "data");
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
    <title>Review Moderation — Noah Studio</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body style="background: var(--bg-primary);">

<div class="dashboard-layout">
    <jsp:include page="admin-sidebar.jsp" />

    <main class="main-content">
        <header class="content-header" style="margin-bottom: 3rem;">
            <span class="section-tag">Moderation Panel</span>
            <h1 style="font-size: 2.5rem; margin: 0;">Feedback <span class="serif" style="color:var(--accent); text-transform:none;">Registry</span></h1>
        </header>

        <div class="card card-table">
            <table class="ns-table">
                <thead>
                    <tr>
                        <th>Client</th>
                        <th>Type</th>
                        <th>Rating</th>
                        <th>Comment</th>
                        <th>Status</th>
                        <th class="text-right">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Review r : reviews) { %>
                        <tr>
                            <td>
                                <div style="font-weight: 800;"><%= r.getClientName() %></div>
                                <div style="font-size: 0.65rem; color: var(--text-muted);"><%= r.getDate() %></div>
                            </td>
                            <td><%= r.renderBadgeHTML() %></td>
                            <td>
                                <span style="color: var(--accent); font-weight: 800;"><%= r.getRating() %> <i class="fa fa-star"></i></span>
                            </td>
                            <td style="max-width: 300px; font-size: 0.8rem; color: #aaa; line-height: 1.5;">
                                "<%= r.getComment() %>"
                            </td>
                            <td>
                                <span class="role-badge <%= Review.STATUS_APPROVED.equals(r.getStatus()) ? "badge-success" : (Review.STATUS_HIDDEN.equals(r.getStatus()) ? "badge-danger" : "badge-muted") %>" style="font-size: 0.6rem;">
                                    <%= r.getStatus().toUpperCase() %>
                                </span>
                            </td>
                            <td class="text-right">
                                <div class="action-group">
                                    <button class="btn-icon" title="Edit Review" style="color: var(--accent);"
                                            data-id="<%= r.getId() %>"
                                            data-rating="<%= r.getRating() %>"
                                            data-staff="<%= r.getStaffId() %>"
                                            data-status="<%= r.getStatus() %>"
                                            data-comment="<%= r.getComment().replace("\"", "&quot;") %>"
                                            onclick="initEditReview(this)">
                                        <i class="fa fa-edit"></i>
                                    </button>
                                    <% if (!Review.STATUS_APPROVED.equals(r.getStatus())) { %>
                                        <a href="review?action=moderate&status=Approved&id=<%= r.getId() %>" class="btn-icon" style="color: #4caf50;" title="Approve Review"><i class="fa fa-check"></i></a>
                                    <% } %>
                                    <% if (!Review.STATUS_HIDDEN.equals(r.getStatus())) { %>
                                        <a href="review?action=moderate&status=Hidden&id=<%= r.getId() %>" class="btn-icon" style="color: #ff9800;" title="Hide Review"><i class="fa fa-eye-slash"></i></a>
                                    <% } %>
                                    <a href="review?action=delete&id=<%= r.getId() %>" class="btn-icon btn-delete" onclick="return confirm('Delete this review forever?')" title="Delete Record"><i class="fa fa-trash"></i></a>
                                </div>
                            </td>
                        </tr>
                    <% } %>
                    <% if (reviews.isEmpty()) { %>
                        <tr><td colspan="6" style="text-align:center; padding:4rem; color:var(--text-muted);">No feedback records found.</td></tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </main>
</div>

<!-- Admin Edit Review Modal -->
<div id="editReviewModal" class="modal-overlay" style="display:none;">
    <div class="modal-container" style="max-width: 500px;">
        <button class="modal-close-btn" onclick="closeEditReview()">&times;</button>
        <span class="section-tag">Admin Management</span>
        <h2>Edit <span style="color:var(--accent)">Feedback</span></h2>
        
        <form action="review" method="post">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="id" id="edit-rev-id">
            
            <div class="form-group" style="margin-bottom: 1.5rem;">
                <label>Professional Assigned</label>
                <select name="staffId" id="edit-rev-staffId" class="form-control">
                    <option value="-">-- General Studio Feedback --</option>
                    <% for (User s : staffMembers) { %>
                        <option value="<%= s.getId() %>"><%= s.getFullName() %> (<%= s.getRole() %>)</option>
                    <% } %>
                </select>
            </div>

            <div style="display:grid; grid-template-columns: 1fr 1fr; gap: 1.5rem; margin-bottom: 1.5rem;">
                <div class="form-group">
                    <label>Star Rating</label>
                    <div class="star-edit-container" style="display: flex; gap: 0.5rem; margin-top: 0.5rem;">
                        <% for(int i=1; i<=5; i++) { %>
                            <i class="far fa-star star-edit-btn" data-value="<%= i %>" style="cursor: pointer; color: var(--accent); font-size: 1.2rem;"></i>
                        <% } %>
                    </div>
                    <input type="hidden" name="rating" id="edit-rev-rating" required>
                </div>
                <div class="form-group">
                    <label>Status</label>
                    <select name="status" id="edit-rev-status" class="form-control">
                        <option value="Pending">Pending</option>
                        <option value="Approved">Approved</option>
                        <option value="Hidden">Hidden</option>
                    </select>
                </div>
            </div>
            
            <div class="form-group" style="margin-bottom: 2rem;">
                <label>Review Content</label>
                <textarea name="comment" id="edit-rev-comment" class="form-control" rows="4" required></textarea>
            </div>
            
            <button type="submit" class="btn-primary" style="width: 100%; padding: 1.25rem;">Update Feedback Record</button>
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
    .star-edit-btn.active { font-weight: 900 !important; }
</style>

<script>
    function initEditReview(btn) {
        const id = btn.getAttribute('data-id');
        const rating = btn.getAttribute('data-rating');
        const staff = btn.getAttribute('data-staff');
        const status = btn.getAttribute('data-status');
        const comment = btn.getAttribute('data-comment');
        
        document.getElementById('edit-rev-id').value = id;
        document.getElementById('edit-rev-staffId').value = staff;
        document.getElementById('edit-rev-status').value = status;
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
