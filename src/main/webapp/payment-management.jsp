<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.noahstudio.model.*, com.noahstudio.util.FileHandler, java.util.*" %>
<%
    HttpSession sess = request.getSession(false);
    if (sess == null || !"admin".equals(sess.getAttribute("role"))) {
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
    <title>Financial Management — Noah Studio</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body style="background: var(--bg-primary);">

<div class="dashboard-layout">
    <jsp:include page="admin-sidebar.jsp" />

    <main class="main-content">
        <header class="content-header" style="display:flex; justify-content: space-between; align-items: flex-end; margin-bottom: 3rem;">
            <div>
                <span class="section-tag">Finance</span>
                <h1 style="font-size: 2.5rem; margin: 0;">Payment <span class="serif" style="color:var(--accent); text-transform:none;">Registry</span></h1>
            </div>
            <div class="header-meta">Administrator Access • Secure Environment</div>
        </header>

        <div class="card card-table">
            <table class="ns-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Client / Booking</th>
                        <th>Type</th>
                        <th>Amount</th>
                        <th>Method</th>
                        <th>Status</th>
                        <th class="text-right">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Payment p : payments) { %>
                    <tr>
                        <td class="text-accent font-bold"><%= p.getId() %></td>
                        <td>
                            <div style="font-weight: 600;"><%= p.getClientName() %></div>
                            <div style="font-size: 0.65rem; color: var(--text-muted);"><%= p.getBookingId() %></div>
                        </td>
                        <td><span class="status-badge" style="background: rgba(209,120,95,0.1); color: var(--accent);"><%= p.getPaymentCategory() %></span></td>
                        <td>
                            <div style="font-weight: 800;">LKR <%= String.format("%.0f", p.getAmount()) %></div>
                            <% if (p instanceof PartialPayment) { %>
                                <div style="font-size: 0.6rem; color: var(--danger);">Bal: LKR <%= String.format("%.0f", ((PartialPayment)p).getBalanceDue()) %></div>
                            <% } %>
                        </td>
                        <td><%= p.getMethod() %></td>
                        <td>
                            <form action="payment" method="post" style="display:inline;">
                                <input type="hidden" name="action" value="update">
                                <input type="hidden" name="id" value="<%= p.getId() %>">
                                <select name="status" class="filter-select" style="padding: 0.2rem; font-size: 0.65rem;" onchange="this.form.submit()">
                                    <option value="Pending" <%= "Pending".equals(p.getStatus()) ? "selected" : "" %>>Pending</option>
                                    <option value="Paid" <%= "Paid".equals(p.getStatus()) ? "selected" : "" %>>Paid</option>
                                    <option value="Refunded" <%= "Refunded".equals(p.getStatus()) ? "selected" : "" %>>Refunded</option>
                                </select>
                            </form>
                        </td>
                        <td class="text-right">
                            <div class="action-group">
                                <a href="payment?action=invoice&id=<%= p.getId() %>" class="btn-icon" title="View Digital Receipt"><i class="fa fa-file-invoice"></i></a>
                                <button class="btn-icon" title="Edit Record" 
                                        data-id="<%= p.getId() %>"
                                        data-amount="<%= p.getAmount() %>"
                                        data-method="<%= p.getMethod() %>"
                                        data-status="<%= p.getStatus() %>"
                                        data-notes="<%= p.getNotes().replace("\"", "&quot;") %>"
                                        data-type="<%= (p instanceof PartialPayment) ? "Partial" : "Full" %>"
                                        data-balance="<%= (p instanceof PartialPayment) ? ((PartialPayment)p).getBalanceDue() : "0" %>"
                                        onclick="initEditPayment(this)">
                                    <i class="fa fa-edit"></i>
                                </button>
                                <a href="payment?action=delete&id=<%= p.getId() %>" class="btn-icon btn-delete" onclick="return confirm('Delete this payment record?')" title="Delete Record"><i class="fa fa-trash"></i></a>
                            </div>
                        </td>
                    </tr>
                    <% } %>
                    <% if (payments.isEmpty()) { %>
                        <tr><td colspan="7" class="text-center py-5 text-muted">No payment records found.</td></tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </main>
</div>

<!-- Edit Payment Modal -->
<div id="editPaymentModal" class="modal-overlay" style="display:none;">
    <div class="modal-container" style="max-width: 500px; background: #080808; padding: 2.5rem; border-radius: 20px; border: 1px solid rgba(255,255,255,0.1);">
        <button class="modal-close-btn" onclick="closeEditModal()" style="position:absolute; top:1.5rem; right:1.5rem; background:none; border:none; color:#fff; font-size:1.5rem; cursor:pointer;">&times;</button>
        <span class="section-tag">Modify Transaction</span>
        <h2 style="margin-bottom: 2rem;">Edit <span style="color:var(--accent)">Payment</span></h2>
        
        <form action="payment" method="post">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="id" id="edit-pay-id">
            
            <div class="form-group" style="margin-bottom: 1rem;">
                <label style="font-size: 0.65rem; color: var(--accent); font-weight: 800; text-transform: uppercase; margin-bottom: 0.5rem; display: block;">Amount (LKR)</label>
                <input type="number" name="amount" id="edit-pay-amount" class="filter-select" style="width:100%; background:#111; color:#fff; padding:0.8rem; border:1px solid #222; border-radius:8px;" required>
            </div>
            
            <div id="edit-balance-group" class="form-group" style="display:none; margin-bottom: 1rem;">
                <label style="font-size: 0.65rem; color: var(--accent); font-weight: 800; text-transform: uppercase; margin-bottom: 0.5rem; display: block;">Remaining Balance (LKR)</label>
                <input type="number" name="balanceDue" id="edit-pay-balance" class="filter-select" style="width:100%; background:#111; color:#fff; padding:0.8rem; border:1px solid #222; border-radius:8px;">
            </div>
            
            <div class="form-group" style="margin-bottom: 1rem;">
                <label style="font-size: 0.65rem; color: var(--accent); font-weight: 800; text-transform: uppercase; margin-bottom: 0.5rem; display: block;">Payment Method</label>
                <select name="method" id="edit-pay-method" class="filter-select" style="width:100%; background:#111; color:#fff; padding:0.8rem; border:1px solid #222; border-radius:8px;">
                    <option>Online Payment</option>
                    <option>Bank Transfer</option>
                    <option>Cash Deposit</option>
                </select>
            </div>
            
            <div class="form-group" style="margin-bottom: 1rem;">
                <label style="font-size: 0.65rem; color: var(--accent); font-weight: 800; text-transform: uppercase; margin-bottom: 0.5rem; display: block;">Payment Status</label>
                <select name="status_full" id="edit-pay-status" class="filter-select" style="width:100%; background:#111; color:#fff; padding:0.8rem; border:1px solid #222; border-radius:8px;">
                    <option value="Pending">Pending</option>
                    <option value="Paid">Paid</option>
                    <option value="Refunded">Refunded</option>
                </select>
            </div>
            
            <div class="form-group" style="margin-bottom: 1.5rem;">
                <label style="font-size: 0.65rem; color: var(--accent); font-weight: 800; text-transform: uppercase; margin-bottom: 0.5rem; display: block;">Notes</label>
                <textarea name="notes" id="edit-pay-notes" class="filter-select" style="width:100%; background:#111; color:#fff; padding:0.8rem; border:1px solid #222; border-radius:8px;" rows="3"></textarea>
            </div>
            
            <button type="submit" class="btn-primary-sm" style="width: 100%; padding: 1rem; border-radius: 8px; font-weight: 800;">Update Record</button>
        </form>
    </div>
</div>

<style>
    .modal-overlay { 
        position: fixed; top: 0; left: 0; width: 100%; height: 100%;
        backdrop-filter: blur(12px); background: rgba(0,0,0,0.85);
        display: flex; align-items: center; justify-content: center; z-index: 10000;
    }
</style>

<script>
    function initEditPayment(btn) {
        document.getElementById('edit-pay-id').value = btn.getAttribute('data-id');
        document.getElementById('edit-pay-amount').value = btn.getAttribute('data-amount');
        document.getElementById('edit-pay-method').value = btn.getAttribute('data-method');
        document.getElementById('edit-pay-status').value = btn.getAttribute('data-status');
        document.getElementById('edit-pay-notes').value = btn.getAttribute('data-notes');
        
        const type = btn.getAttribute('data-type');
        const balanceGroup = document.getElementById('edit-balance-group');
        if (type === 'Partial') {
            balanceGroup.style.display = 'block';
            document.getElementById('edit-pay-balance').value = btn.getAttribute('data-balance');
        } else {
            balanceGroup.style.display = 'none';
        }
        
        document.getElementById('editPaymentModal').style.display = 'flex';
    }
    function closeEditModal() { document.getElementById('editPaymentModal').style.display = 'none'; }
</script>

</body>
</html>
