<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.noahstudio.model.*, com.noahstudio.util.FileHandler, java.util.*" %>
<%
    HttpSession sess = request.getSession(false);
    if (sess == null || !"admin".equals(sess.getAttribute("role"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    String role = (String) sess.getAttribute("role");
    List<ServicePackage> pkgs = (List<ServicePackage>) request.getAttribute("packages");
    if (pkgs == null) {
        response.sendRedirect("package?action=list");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Package Management — Noah Studio</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        .pkg-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 1.5rem; }
        .pkg-card { background: #0a0a0a; border: 1px solid #1a1a1a; border-radius: 16px; padding: 2rem; transition: 0.3s; position: relative; }
        .pkg-card:hover { border-color: var(--accent); transform: translateY(-5px); }
        .pkg-type { font-size: 0.6rem; text-transform: uppercase; letter-spacing: 2px; color: var(--accent); font-weight: 800; margin-bottom: 0.5rem; display: block; }
        .pkg-price { font-size: 2rem; font-weight: 800; margin: 1rem 0; }
        .feature-list { list-style: none; padding: 0; margin: 1.5rem 0; }
        .feature-list li { margin-bottom: 0.5rem; color: var(--text-muted); font-size: 0.8rem; display: flex; align-items: center; gap: 0.5rem; }
        .feature-list li i { color: var(--accent); font-size: 0.7rem; }

        /* Premium Modal Styles */
        .modal-overlay { 
            backdrop-filter: blur(12px); 
            background: rgba(0,0,0,0.85); 
            z-index: 9999;
        }
        .modal-container { 
            background: #080808; 
            border: 1px solid rgba(255,255,255,0.08);
            box-shadow: 0 25px 50px -12px rgba(0,0,0,0.5);
            max-width: 650px;
            padding: 3.5rem;
            border-radius: 24px;
            position: relative;
        }
        .modal-container::before {
            content: "";
            position: absolute;
            top: 0; left: 0; right: 0; height: 2px;
            background: linear-gradient(90deg, transparent, var(--accent), transparent);
            border-radius: 24px 24px 0 0;
        }
        .form-group label {
            font-size: 0.65rem;
            text-transform: uppercase;
            letter-spacing: 1.5px;
            color: var(--accent);
            font-weight: 800;
            margin-bottom: 0.75rem;
            display: block;
        }
        .modal-container .form-control {
            background: #0f0f0f !important;
            border: 1px solid #1a1a1a !important;
            color: #fff !important;
            padding: 1rem !important;
            border-radius: 12px !important;
            transition: 0.3s !important;
        }
        .modal-container .form-control:focus {
            border-color: var(--accent) !important;
            background: #141414 !important;
            box-shadow: 0 0 20px rgba(184, 115, 51, 0.1) !important;
        }
        .modal-close-btn {
            background: #1a1a1a;
            color: #fff;
            width: 32px;
            height: 32px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.2rem;
            transition: 0.3s;
            border: none;
            cursor: pointer;
            position: absolute;
            top: 2rem;
            right: 2rem;
        }
        .modal-close-btn:hover { background: var(--danger); transform: rotate(90deg); }
    </style>
</head>
<body style="background: var(--bg-primary);">

<div class="dashboard-layout">
    <jsp:include page="admin-sidebar.jsp" />

    <main class="main-content">
        <header class="content-header" style="display:flex; justify-content: space-between; align-items: center; margin-bottom: 3rem;">
            <div>
                <span class="section-tag">Catalog Management</span>
                <h1 style="font-size: 2.5rem; margin: 0;">Service <span class="serif" style="color:var(--accent); text-transform:none;">Packages</span></h1>
            </div>
            <button class="btn-primary-sm" onclick="openModal('addPkgModal')">+ New Package</button>
        </header>

        <!-- Filter Controls -->
        <div class="card" style="padding: 1.5rem; margin-bottom: 2rem; border: 1px solid #1a1a1a;">
            <form action="package" method="get" style="display:flex; gap: 1.5rem; align-items: center;">
                <input type="hidden" name="action" value="list">
                <select name="type" class="filter-select" style="min-width: 200px;" onchange="this.form.submit()">
                    <option value="">All Service Types</option>
                    <option value="photography" <%= "photography".equals(request.getParameter("type")) ? "selected" : "" %>>Photography</option>
                    <option value="videography" <%= "videography".equals(request.getParameter("type")) ? "selected" : "" %>>Videography</option>
                </select>
                <input type="number" name="priceMax" placeholder="Max Price" class="form-control" style="margin:0; width: 150px;" value="<%= request.getParameter("priceMax") != null ? request.getParameter("priceMax") : "" %>">
                <button type="submit" class="btn-primary-sm">Apply</button>
                <a href="package?action=list" class="btn-icon" title="Reset Filters"><i class="fa fa-rotate-left"></i></a>
            </form>
        </div>

        <div class="pkg-grid">
            <% for (ServicePackage p : pkgs) { %>
                <div class="pkg-card">
                    <span class="pkg-type"><%= p.getType() %> • <%= p.getDuration() %></span>
                    <h3 style="font-size: 1.2rem;"><%= p.getName() %></h3>
                    <div class="pkg-price">LKR <%= String.format("%.0f", p.getPrice()) %></div>
                    
                    <ul class="feature-list">
                        <% for (String feat : p.getFeatures().split(",")) { %>
                            <li><i class="fa fa-check-circle"></i> <%= feat.trim() %></li>
                        <% } %>
                    </ul>

                    <div style="display:flex; gap: 0.75rem; border-top: 1px solid #1a1a1a; padding-top: 1.5rem;">
                        <button class="btn-icon" 
                                data-id="<%= p.getId() %>"
                                data-name="<%= p.getName().replace("\"", "&quot;") %>"
                                data-price="<%= p.getPrice() %>"
                                data-duration="<%= p.getDuration().replace("\"", "&quot;") %>"
                                data-features="<%= p.getFeatures().replace("\"", "&quot;") %>"
                                data-desc="<%= p.getDescription().replace("\"", "&quot;").replace("\n", " ").replace("\r", " ") %>"
                                data-type="<%= p.getType() %>"
                                data-featured="<%= p.isFeatured() %>"
                                onclick="initEdit(this)">
                            <i class="fa fa-edit" style="color: red;"></i>
                        </button>
                        <a href="package?action=delete&id=<%= p.getId() %>" class="btn-icon btn-delete" onclick="return confirm('Delete this package?')"><i class="fa fa-trash" style="color: white;"></i></a>
                    </div>
                </div>
            <% } %>
        </div>
    </main>
</div>

<!-- Modals -->
<div id="addPkgModal" class="modal-overlay" style="display:none;">
    <div class="modal-container">
        <button class="modal-close-btn" onclick="closeModal('addPkgModal')">&times;</button>
        <h2 style="margin-bottom: 2rem;">Create <span style="color:var(--accent)">Package</span></h2>
        <form action="package" method="post">
            <input type="hidden" name="action" value="create">
            <div style="display:grid; grid-template-columns: 1fr 1fr; gap: 1rem;">
                <div class="form-group"><label>Name</label><input type="text" name="name" class="form-control" required></div>
                <div class="form-group"><label>Type</label>
                    <select name="type" class="form-control" required>
                        <option value="photography">Photography</option>
                        <option value="videography">Videography</option>
                    </select>
                </div>
                <div class="form-group"><label>Featured</label>
                    <select name="featured" class="form-control" required>
                        <option value="false">No</option>
                        <option value="true">Yes</option>
                    </select>
                </div>
                <div class="form-group"><label>Price (LKR)</label><input type="number" name="price" class="form-control" required></div>
                <div class="form-group"><label>Duration</label><input type="text" name="duration" class="form-control" required></div>
            </div>
            <div class="form-group"><label>Inclusions (Comma separated)</label><input type="text" name="features" class="form-control" required></div>
            <div class="form-group"><label>Description</label><textarea name="description" class="form-control" rows="3"></textarea></div>
            <button type="submit" class="btn-primary" style="width: 100%; margin-top: 2rem; padding: 1.25rem;">Create Package</button>
        </form>
    </div>
</div>

<div id="editPkgModal" class="modal-overlay" style="display:none;">
    <div class="modal-container">
        <button class="modal-close-btn" onclick="closeModal('editPkgModal')">&times;</button>
        <h2 style="margin-bottom: 2rem;">Edit <span style="color:var(--accent)">Package</span></h2>
        <form action="package" method="post">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="id" id="edit-id">
            <div style="display:grid; grid-template-columns: 1fr 1fr; gap: 1rem;">
                <div class="form-group"><label>Name</label><input type="text" name="name" id="edit-name" class="form-control" required></div>
                <div class="form-group"><label>Type</label>
                    <select name="type" id="edit-type" class="form-control" required>
                        <option value="photography">Photography</option>
                        <option value="videography">Videography</option>
                    </select>
                </div>
                <div class="form-group"><label>Featured</label>
                    <select name="featured" id="edit-featured" class="form-control" required>
                        <option value="false">No</option>
                        <option value="true">Yes</option>
                    </select>
                </div>
                <div class="form-group"><label>Price (LKR)</label><input type="number" name="price" id="edit-price" class="form-control" required></div>
                <div class="form-group"><label>Duration</label><input type="text" name="duration" id="edit-duration" class="form-control" required></div>
            </div>
            <div class="form-group"><label>Inclusions</label><input type="text" name="features" id="edit-features" class="form-control" required></div>
            <div class="form-group"><label>Description</label><textarea name="description" id="edit-desc" class="form-control" rows="3"></textarea></div>
            <button type="submit" class="btn-primary" style="width: 100%; margin-top: 2rem; padding: 1.25rem;">Save Changes</button>
        </form>
    </div>
</div>

<script>
    function openModal(id) { document.getElementById(id).style.display = 'flex'; }
    function closeModal(id) { document.getElementById(id).style.display = 'none'; }
    
    function initEdit(btn) {
        document.getElementById('edit-id').value = btn.getAttribute('data-id');
        document.getElementById('edit-name').value = btn.getAttribute('data-name');
        document.getElementById('edit-price').value = btn.getAttribute('data-price');
        document.getElementById('edit-duration').value = btn.getAttribute('data-duration');
        document.getElementById('edit-features').value = btn.getAttribute('data-features');
        document.getElementById('edit-desc').value = btn.getAttribute('data-desc');
        document.getElementById('edit-type').value = btn.getAttribute('data-type');
        document.getElementById('edit-featured').value = btn.getAttribute('data-featured');
        openModal('editPkgModal');
    }
</script>
</body>
</html>
