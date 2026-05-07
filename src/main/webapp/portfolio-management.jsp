<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.noahstudio.model.*, com.noahstudio.util.FileHandler, java.util.*" %>
<%
    // Auth Check
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("role") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String role = (String) sess.getAttribute("role");
    String uid = (String) sess.getAttribute("userId");
    
    // Admins and Staff can view this page
    if (!Arrays.asList("admin", "photographer", "videographer").contains(role)) {
        response.sendRedirect("index.jsp");
        return;
    }

    FileHandler.init(application.getRealPath("/") + "data");
    
    // Load portfolio items
    List<PortfolioItem> items = new ArrayList<>();
    for (String l : FileHandler.readLines("portfolio.txt")) {
        PortfolioItem p = PortfolioItem.fromFileString(l);
        if (p != null) {
            // Staff can only see their own items, admins can see all
            if ("admin".equals(role) || uid.equals(p.getStaffId())) {
                items.add(p);
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Portfolio Management — Noah Studio</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body style="background: var(--bg-primary);">

<div class="dashboard-layout">
    <jsp:include page="admin-sidebar.jsp" />

    <main class="main-content">
        <header class="content-header" style="display:flex; justify-content: space-between; align-items: flex-end; margin-bottom: 3rem;">
            <div>
                <span class="section-tag">Content Management</span>
                <h1 style="font-size: 2.5rem; margin: 0;">Portfolio <span class="serif" style="color:var(--accent); text-transform:none;">Gallery</span></h1>
            </div>
            <button class="btn-primary-sm" onclick="openModal('addPortfolioModal')">+ Add Entry</button>
        </header>

        <div class="card card-table">
            <table class="ns-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Preview</th>
                        <th>Details</th>
                        <th>Type</th>
                        <th>Category</th>
                        <th class="text-right">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (items.isEmpty()) { %>
                        <tr><td colspan="6" style="text-align:center; padding:3rem; color:var(--text-muted);">No portfolio entries found.</td></tr>
                    <% } else { %>
                        <% for (PortfolioItem item : items) { %>
                        <tr>
                            <td class="text-accent font-bold"><%= item.getId() %></td>
                            <td>
                                <% if (item instanceof PhotoPortfolioItem) { %>
                                    <div style="width: 60px; height: 40px; background: url('<%= item.getMediaUrl() %>') center/cover; border-radius: 4px;"></div>
                                <% } else { %>
                                    <div style="width: 60px; height: 40px; background: #222; display:flex; align-items:center; justify-content:center; border-radius: 4px;"><i class="fa fa-play" style="font-size:0.8rem; color:var(--accent);"></i></div>
                                <% } %>
                            </td>
                            <td>
                                <div style="font-weight: 600;"><%= item.getTitle() %></div>
                                <div style="font-size: 0.65rem; color: var(--text-muted);"><%= item.getStaffName() %> • <%= item.getDate() %></div>
                            </td>
                            <td><span class="status-badge" style="color:#fff;"><i class="fa <%= item instanceof PhotoPortfolioItem ? "fa-camera" : "fa-video" %>"></i> <%= item.getType() %></span></td>
                            <td><%= item.getCategory() %></td>
                            <td class="text-right">
                                <div class="action-group">
                                    <button class="btn-icon" title="Edit Entry" 
                                            data-id="<%= item.getId() %>"
                                            data-type="<%= item.getType() %>"
                                            data-title="<%= item.getTitle().replace("\"", "&quot;") %>"
                                            data-category="<%= item.getCategory() %>"
                                            data-media="<%= item.getMediaUrl().replace("\"", "&quot;") %>"
                                            data-desc="<%= item.getDescription().replace("\"", "&quot;") %>"
                                            onclick="initEdit(this)">
                                        <i class="fa fa-edit"></i>
                                    </button>
                                    <form action="portfolio" method="post" style="display:inline;" onsubmit="return confirm('Delete this entry permanently?');">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="id" value="<%= item.getId() %>">
                                        <input type="hidden" name="redirect" value="portfolio-management.jsp">
                                        <button type="submit" class="btn-icon btn-delete" title="Delete Entry"><i class="fa fa-trash"></i></button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                    <% } %>
                </tbody>
            </table>
        </div>
    </main>
</div>

<!-- Modals -->
<div id="addPortfolioModal" class="modal-overlay" style="display:none;">
    <div class="modal-container" style="max-width: 500px; background: #080808; border: 1px solid rgba(255,255,255,0.08); padding: 2rem; border-radius: 20px; position: relative;">
        <button class="modal-close-btn" onclick="closeModal('addPortfolioModal')" style="position:absolute; top:1.5rem; right:1.5rem; background:#1a1a1a; color:#fff; width:28px; height:28px; border-radius:50%; border:none; cursor:pointer; font-size:1.2rem;">&times;</button>
        <span class="section-tag">New Entry</span>
        <h2 style="margin-bottom: 1.5rem;">Add to <span style="color:var(--accent)">Portfolio</span></h2>
        
        <form action="portfolio" method="post" enctype="multipart/form-data">
            <input type="hidden" name="action" value="create">
            <input type="hidden" name="redirect" value="portfolio-management.jsp">
            
            <div style="display:grid; grid-template-columns: 1fr 1fr; gap: 1.5rem;">
                <div class="form-group" style="grid-column: span 2;">
                    <label style="font-size:0.65rem; text-transform:uppercase; letter-spacing:1.5px; color:var(--accent); font-weight:800; margin-bottom:0.75rem; display:block;">Project Title</label>
                    <input type="text" name="title" class="form-control" style="background:#0f0f0f; border:1px solid #1a1a1a; color:#fff; padding:1rem; border-radius:12px; width:100%;" required>
                </div>
                <div class="form-group">
                    <label style="font-size:0.6rem; text-transform:uppercase; letter-spacing:1px; color:var(--accent); font-weight:800; margin-bottom:0.5rem; display:block;">Media Type</label>
                    <select name="type" class="form-control" onchange="toggleMediaInput(this, 'add')" style="background:#0f0f0f; border:1px solid #1a1a1a; color:#fff; padding:0.8rem; border-radius:10px; width:100%;" required>
                        <option value="Photo">Photography (Image)</option>
                        <option value="Video">Videography (Video/Embed)</option>
                    </select>
                </div>
                <div class="form-group">
                    <label style="font-size:0.6rem; text-transform:uppercase; letter-spacing:1px; color:var(--accent); font-weight:800; margin-bottom:0.5rem; display:block;">Category</label>
                    <select name="category" class="form-control" style="background:#0f0f0f; border:1px solid #1a1a1a; color:#fff; padding:0.8rem; border-radius:10px; width:100%;" required>
                        <option value="Wedding">Wedding</option>
                        <option value="Events">Events</option>
                        <option value="Portrait">Portrait</option>
                        <option value="Corporate">Corporate</option>
                    </select>
                </div>
                <div class="form-group" id="add-file-group" style="grid-column: span 2;">
                    <label style="font-size:0.6rem; text-transform:uppercase; letter-spacing:1px; color:var(--accent); font-weight:800; margin-bottom:0.5rem; display:block;">Browse Image</label>
                    <input type="file" name="mediaFile" accept="image/*" class="form-control" style="background:#0f0f0f; border:1px solid #1a1a1a; color:#fff; padding:0.8rem; border-radius:10px; width:100%;">
                </div>
                <div class="form-group" id="add-url-group" style="grid-column: span 2; display:none;">
                    <label style="font-size:0.6rem; text-transform:uppercase; letter-spacing:1px; color:var(--accent); font-weight:800; margin-bottom:0.5rem; display:block;">Media URL (Image Link or YouTube Embed URL)</label>
                    <input type="text" name="mediaUrl" class="form-control" style="background:#0f0f0f; border:1px solid #1a1a1a; color:#fff; padding:0.8rem; border-radius:10px; width:100%;">
                </div>
                <div class="form-group" style="grid-column: span 2;">
                    <label style="font-size:0.65rem; text-transform:uppercase; letter-spacing:1.5px; color:var(--accent); font-weight:800; margin-bottom:0.75rem; display:block;">Description</label>
                    <textarea name="description" class="form-control" rows="3" style="background:#0f0f0f; border:1px solid #1a1a1a; color:#fff; padding:1rem; border-radius:12px; width:100%;"></textarea>
                </div>
            </div>
            
            <button type="submit" class="btn-primary" style="width: 100%; margin-top: 2rem; padding: 1.25rem;">Save Entry</button>
        </form>
    </div>
</div>

<div id="editPortfolioModal" class="modal-overlay" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; backdrop-filter:blur(12px); background:rgba(0,0,0,0.85); align-items:center; justify-content:center; z-index:10000;">
    <div class="modal-container" style="max-width: 500px; background: #080808; border: 1px solid rgba(255,255,255,0.08); padding: 2rem; border-radius: 20px; position: relative;">
        <button class="modal-close-btn" onclick="closeModal('editPortfolioModal')" style="position:absolute; top:1.5rem; right:1.5rem; background:#1a1a1a; color:#fff; width:28px; height:28px; border-radius:50%; border:none; cursor:pointer; font-size:1.2rem;">&times;</button>
        <span class="section-tag">Modify</span>
        <h2 style="margin-bottom: 1.5rem;">Edit <span style="color:var(--accent)">Entry</span></h2>
        
        <form action="portfolio" method="post" enctype="multipart/form-data">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="id" id="edit-id">
            <input type="hidden" name="redirect" value="portfolio-management.jsp">
            
            <div style="display:grid; grid-template-columns: 1fr 1fr; gap: 1.5rem;">
                <div class="form-group" style="grid-column: span 2;">
                    <label style="font-size:0.65rem; text-transform:uppercase; letter-spacing:1.5px; color:var(--accent); font-weight:800; margin-bottom:0.75rem; display:block;">Project Title</label>
                    <input type="text" name="title" id="edit-title" class="form-control" style="background:#0f0f0f; border:1px solid #1a1a1a; color:#fff; padding:1rem; border-radius:12px; width:100%;" required>
                </div>
                <div class="form-group">
                    <label style="font-size:0.6rem; text-transform:uppercase; letter-spacing:1px; color:var(--accent); font-weight:800; margin-bottom:0.5rem; display:block;">Media Type</label>
                    <select name="type" id="edit-type" class="form-control" onchange="toggleMediaInput(this, 'edit')" style="background:#0f0f0f; border:1px solid #1a1a1a; color:#fff; padding:0.8rem; border-radius:10px; width:100%;" required>
                        <option value="Photo">Photography (Image)</option>
                        <option value="Video">Videography (Video/Embed)</option>
                    </select>
                </div>
                <div class="form-group">
                    <label style="font-size:0.6rem; text-transform:uppercase; letter-spacing:1px; color:var(--accent); font-weight:800; margin-bottom:0.5rem; display:block;">Category</label>
                    <select name="category" id="edit-category" class="form-control" style="background:#0f0f0f; border:1px solid #1a1a1a; color:#fff; padding:0.8rem; border-radius:10px; width:100%;" required>
                        <option value="Wedding">Wedding</option>
                        <option value="Events">Events</option>
                        <option value="Portrait">Portrait</option>
                        <option value="Corporate">Corporate</option>
                    </select>
                </div>
                <div class="form-group" id="edit-file-group" style="grid-column: span 2;">
                    <label style="font-size:0.6rem; text-transform:uppercase; letter-spacing:1px; color:var(--accent); font-weight:800; margin-bottom:0.5rem; display:block;">Change Image (Optional)</label>
                    <input type="file" name="mediaFile" accept="image/*" class="form-control" style="background:#0f0f0f; border:1px solid #1a1a1a; color:#fff; padding:0.8rem; border-radius:10px; width:100%;">
                </div>
                <div class="form-group" id="edit-url-group" style="grid-column: span 2; display:none;">
                    <label style="font-size:0.6rem; text-transform:uppercase; letter-spacing:1px; color:var(--accent); font-weight:800; margin-bottom:0.5rem; display:block;">Media URL</label>
                    <input type="text" name="mediaUrl" id="edit-mediaUrl" class="form-control" style="background:#0f0f0f; border:1px solid #1a1a1a; color:#fff; padding:0.8rem; border-radius:10px; width:100%;">
                </div>
                <div class="form-group" style="grid-column: span 2;">
                    <label style="font-size:0.65rem; text-transform:uppercase; letter-spacing:1.5px; color:var(--accent); font-weight:800; margin-bottom:0.75rem; display:block;">Description</label>
                    <textarea name="description" id="edit-desc" class="form-control" rows="3" style="background:#0f0f0f; border:1px solid #1a1a1a; color:#fff; padding:1rem; border-radius:12px; width:100%;"></textarea>
                </div>
            </div>
            
            <button type="submit" class="btn-primary" style="width: 100%; margin-top: 2rem; padding: 1.25rem;">Update Entry</button>
        </form>
    </div>
</div>

<script>
    function openModal(id) { 
        document.getElementById(id).style.display = 'flex'; 
    }
    function closeModal(id) { 
        document.getElementById(id).style.display = 'none'; 
    }
    function initEdit(btn) {
        document.getElementById('edit-id').value = btn.getAttribute('data-id');
        document.getElementById('edit-title').value = btn.getAttribute('data-title');
        document.getElementById('edit-type').value = btn.getAttribute('data-type');
        document.getElementById('edit-category').value = btn.getAttribute('data-category');
        document.getElementById('edit-mediaUrl').value = btn.getAttribute('data-media');
        document.getElementById('edit-desc').value = btn.getAttribute('data-desc');
        
        toggleMediaInput(document.getElementById('edit-type'), 'edit');
        openModal('editPortfolioModal');
    }
    function toggleMediaInput(select, prefix) {
        const type = select.value;
        const fileGroup = document.getElementById(prefix + '-file-group');
        const urlGroup = document.getElementById(prefix + '-url-group');
        if (type === 'Photo') {
            fileGroup.style.display = 'block';
            urlGroup.style.display = 'none';
        } else {
            fileGroup.style.display = 'none';
            urlGroup.style.display = 'block';
        }
    }
</script>

</body>
</html>
