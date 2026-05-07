<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.noahstudio.model.*, java.util.*" %>
<%
    Payment p = (Payment) request.getAttribute("payment");
    if (p == null) {
        response.sendRedirect("payment?action=list");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Invoice #<%= p.getId() %> — Noah Studio</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        body { background: #fdfdfd; color: #1a1a1a; min-height: 100vh; padding: 5rem 0; }
        .invoice-container { 
            background: #fff; max-width: 800px; margin: 0 auto; 
            padding: 5rem; border: 1px solid #eee; box-shadow: 0 40px 100px rgba(0,0,0,0.03); 
            border-radius: 4px; position: relative;
        }
        .invoice-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 5rem; }
        .brand-logo { font-family: 'Outfit', sans-serif; font-weight: 800; font-size: 1.5rem; letter-spacing: -1px; }
        .brand-logo span { color: #888; font-weight: 400; }
        
        .invoice-badge { 
            display: inline-block; padding: 0.5rem 1rem; font-size: 0.65rem; font-weight: 800; 
            letter-spacing: 2px; text-transform: uppercase; border-radius: 4px; margin-bottom: 1rem;
        }
        .invoice-badge.full { background: #e8f5e9; color: #2e7d32; }
        .invoice-badge.partial { background: #fff3e0; color: #ef6c00; }
        
        .balance-notice { font-size: 0.75rem; color: #d32f2f; font-weight: 600; margin-top: 0.5rem; }
        
        .details-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 4rem; margin-bottom: 5rem; }
        .detail-item label { display: block; font-size: 0.7rem; color: #888; text-transform: uppercase; letter-spacing: 1.5px; margin-bottom: 0.5rem; font-weight: 600; }
        .detail-item p { font-size: 1.1rem; font-weight: 500; margin: 0; }
        
        .amount-section { border-top: 2px solid #1a1a1a; padding-top: 2.5rem; display: flex; justify-content: space-between; align-items: center; }
        .amount-total { font-size: 3rem; font-weight: 800; letter-spacing: -2px; }
        
        @media print {
            .no-print { display: none; }
            body { padding: 0; }
            .invoice-container { box-shadow: none; border: none; }
        }
    </style>
</head>
<body>

<div class="no-print" style="max-width: 800px; margin: 0 auto 2rem; display: flex; justify-content: space-between;">
    <a href="payment?action=list" style="color:#1a1a1a; font-weight: 600; font-size: 0.8rem;"><i class="fa fa-arrow-left"></i> Back to History</a>
    <button onclick="window.print()" class="btn-primary-sm" style="background:#1a1a1a; color:#fff; border:none; padding: 0.8rem 1.5rem; border-radius: 4px; cursor:pointer;"><i class="fa fa-print"></i> Print Document</button>
</div>

<div class="invoice-container">
    <div class="invoice-header">
        <div>
            <div class="brand-logo">Noah<span>Studio</span></div>
            <div style="font-size: 0.75rem; color: #888; margin-top: 0.5rem;">Cinnamon Gardens, Colombo 07</div>
        </div>
        <div style="text-align: right;">
            <!-- POLYMORPHISM IN ACTION: Specialized header based on Payment subtype -->
            <%= p.renderInvoiceHeaderHTML() %>
            <div style="font-size: 0.8rem; font-weight: 800; margin-top: 1.5rem;">ID: <%= p.getId() %></div>
            <div style="font-size: 0.75rem; color: #888;"><%= p.getPaidAt() %></div>
        </div>
    </div>

    <div class="details-grid">
        <div class="detail-item">
            <label>Billed To</label>
            <p><%= p.getClientName() %></p>
            <div style="font-size: 0.75rem; color: #666; margin-top: 0.25rem;">Client ID: <%= p.getClientId() %></div>
        </div>
        <div class="detail-item" style="text-align: right;">
            <label>Booking Reference</label>
            <p><%= p.getBookingId() %></p>
        </div>
        <div class="detail-item">
            <label>Payment Method</label>
            <p><%= p.getMethod() %></p>
        </div>
        <div class="detail-item" style="text-align: right;">
            <label>Current Status</label>
            <p style="color: <%= p.getStatus().equals("Paid") ? "#2e7d32" : "#ef6c00" %>;"><%= p.getStatus() %></p>
        </div>
    </div>

    <% if (!p.getNotes().isEmpty()) { %>
    <div style="margin-bottom: 5rem; padding: 2rem; background: #f9f9f9; border-radius: 4px;">
        <label style="display: block; font-size: 0.65rem; color: #888; text-transform: uppercase; letter-spacing: 1.5px; margin-bottom: 1rem; font-weight: 600;">Transaction Notes</label>
        <div style="font-size: 0.85rem; line-height: 1.6; color: #444;"><%= p.getNotes() %></div>
    </div>
    <% } %>

    <div class="amount-section">
        <div>
            <div style="font-size: 0.75rem; color: #888; font-weight: 600; text-transform: uppercase; letter-spacing: 1px;">Amount Received</div>
            <div style="font-size: 0.75rem; color: #aaa; margin-top: 0.25rem;">Currency: LKR</div>
        </div>
        <div class="amount-total">LKR <%= String.format("%.0f", p.getAmount()) %></div>
    </div>

    <div style="margin-top: 8rem; border-top: 1px solid #eee; padding-top: 2rem; display: flex; justify-content: space-between; font-size: 0.7rem; color: #aaa;">
        <div>Noah Studio — Premium Production & Photography</div>
        <div>Computer Generated Document — No Signature Required</div>
    </div>
</div>

</body>
</html>
