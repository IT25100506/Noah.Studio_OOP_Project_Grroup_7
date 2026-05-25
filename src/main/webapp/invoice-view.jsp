<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.noahstudio.model.*, java.util.*" %>
<%
    Payment p = (Payment) request.getAttribute("payment");
    if (p == null) {
        response.sendRedirect("payment?action=list");
        return;
    }
%>
<% 
    String bkgPkg = "";
    for(String l : com.noahstudio.util.FileHandler.readLines("bookings.txt")) {
        com.noahstudio.model.Booking b = com.noahstudio.model.Booking.fromFileString(l);
        if(b != null && b.getId().equals(p.getBookingId())) {
            bkgPkg = b.getServicePackageName();
            break;
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Invoice #<%= p.getId() %> — Noah Studio</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        body { 
            background: #e3e3e3; 
            color: #1a1a1a; 
            font-family: 'Inter', -apple-system, sans-serif;
            min-height: 100vh; 
            display: flex;
            justify-content: center;
            align-items: center;
            margin: 0;
            padding: 40px 20px;
        }
        .invoice-paper {
            background: #f1f0ee;
            width: 100%;
            max-width: 794px; /* A4 width roughly */
            min-height: 1123px; /* A4 height */
            padding: 80px;
            box-sizing: border-box;
            box-shadow: 0 20px 50px rgba(0,0,0,0.1);
            position: relative;
        }
        .header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 60px; }
        .logo-text { font-size: 24px; font-weight: 500; line-height: 1.1; letter-spacing: -0.5px; }
        .invoice-title { font-size: 42px; font-weight: 400; letter-spacing: -1px; margin-bottom: 10px; text-transform: uppercase; }
        .invoice-number { font-size: 20px; font-weight: 400; text-align: right; }
        
        .contact-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 40px; margin-bottom: 60px; font-size: 13px; line-height: 1.8; }
        .contact-col { display: flex; flex-direction: column; }
        .contact-row { display: grid; grid-template-columns: 80px 1fr; margin-bottom: 5px; }
        .contact-label { color: #555; }
        .contact-value { color: #111; }
        
        .section-title { font-size: 28px; font-weight: 400; margin-bottom: 20px; letter-spacing: -0.5px; }
        
        .invoice-table { width: 100%; border-collapse: collapse; margin-bottom: 30px; border-top: 1px solid #ccc; border-bottom: 1px solid #ccc; }
        .invoice-table th, .invoice-table td { padding: 15px 0; text-align: left; font-size: 14px; }
        .invoice-table th { font-weight: 500; }
        .text-right { text-align: right; }
        
        .totals-container { display: flex; justify-content: flex-end; margin-bottom: 60px; }
        .totals-table { width: 350px; border-collapse: collapse; }
        .totals-table td { padding: 8px 0; font-size: 14px; }
        .totals-table td.total-label { width: 100px; color: #111; }
        .totals-table tr.total-row td { border-top: 1px solid #ccc; padding-top: 15px; margin-top: 5px; font-weight: 500; }
        
        .due-date-row td { border-top: 1px solid #ccc; padding-top: 15px; border-bottom: 1px solid #ccc; padding-bottom: 15px; }

        .footer-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 60px; border-top: 1px solid #ccc; padding-top: 30px; font-size: 13px; line-height: 1.6; }
        .footer-title { font-size: 18px; font-weight: 400; margin-bottom: 15px; }
        .bank-row { display: grid; grid-template-columns: 80px 1fr; margin-bottom: 5px; }

        .no-print { position: fixed; top: 20px; right: 20px; display: flex; gap: 10px; z-index: 100; }
        .btn { padding: 10px 20px; background: #1a1a1a; color: white; border: none; border-radius: 4px; cursor: pointer; text-decoration: none; font-size: 14px; display: inline-flex; align-items: center; gap: 8px; }
        
        /* Needed for the polymorphic HTML which might use some classes */
        .invoice-badge { 
            display: inline-block; padding: 0.3rem 0.6rem; font-size: 0.6rem; font-weight: 600; 
            letter-spacing: 1px; text-transform: uppercase; border-radius: 4px; margin-top: 10px; border: 1px solid #ccc;
        }

        @media print {
            body { background: white; padding: 0; display: block; height: 100%; }
            .invoice-paper { box-shadow: none; max-width: none; width: 100%; padding: 40px; margin: 0; min-height: 0; height: auto; }
            .no-print { display: none; }
        }
    </style>
</head>
<body>

<div class="no-print">
    <a href="payment?action=list" class="btn"><i class="fa fa-arrow-left"></i> Back</a>
    <button onclick="window.print()" class="btn"><i class="fa fa-print"></i> Print</button>
</div>

<div class="invoice-paper">
    <div class="header">
        <div class="logo-text">Noah<br>Studio</div>
        <div style="text-align: right;">
            <div class="invoice-title">INVOICE</div>
            <div class="invoice-number">#<%= p.getId() %></div>
            <%= p.renderInvoiceHeaderHTML() %>
        </div>
    </div>
    
    <div class="contact-grid">
        <div class="contact-col">
            <div class="contact-row">
                <span class="contact-label">Client</span>
                <span class="contact-value"><%= p.getClientName() %></span>
            </div>
            <div class="contact-row">
                <span class="contact-label">Client ID</span>
                <span class="contact-value"><%= p.getClientId() %></span>
            </div>
            <% if(p.getPaidAt() != null && !p.getPaidAt().isEmpty() && !"-".equals(p.getPaidAt())) { %>
            <div class="contact-row">
                <span class="contact-label">Paid At</span>
                <span class="contact-value"><%= p.getPaidAt() %></span>
            </div>
            <% } %>
        </div>
        <div class="contact-col">
            <div class="contact-row">
                <span class="contact-label">Status</span>
                <span class="contact-value"><%= p.getStatus() %></span>
            </div>
            <div class="contact-row">
                <span class="contact-label">Method</span>
                <span class="contact-value"><%= p.getMethod() %></span>
            </div>
            <div class="contact-row">
                <span class="contact-label">Booking</span>
                <span class="contact-value"><%= p.getBookingId() %></span>
            </div>
        </div>
    </div>
    
    <div class="section-title">Description</div>
    
    <table class="invoice-table">
        <tbody>
            <tr>
                <td><%= bkgPkg.isEmpty() ? "Studio Service (Custom)" : bkgPkg %></td>
                <td class="text-right">LKR <%= String.format("%.2f", p.getAmount()) %></td>
            </tr>
            <% if(p instanceof PartialPayment) { %>
            <tr>
                <td>Advance Payment</td>
                <td class="text-right">- LKR <%= String.format("%.2f", p.getAmount() - ((PartialPayment)p).getBalanceDue()) %></td>
            </tr>
            <tr>
                <td>Balance Due</td>
                <td class="text-right">LKR <%= String.format("%.2f", ((PartialPayment)p).getBalanceDue()) %></td>
            </tr>
            <% } %>
            <% if (!p.getNotes().isEmpty() && !p.getNotes().equals("-")) { %>
            <tr>
                <td colspan="2" style="color: #666; font-size: 13px; font-style: italic; border-top: none; padding-top: 0;">Notes: <%= p.getNotes() %></td>
            </tr>
            <% } %>
        </tbody>
    </table>
    
    <div class="totals-container">
        <table class="totals-table">
            <tr>
                <td class="total-label">Subtotal</td>
                <td class="text-right">LKR <%= String.format("%.2f", p.getAmount()) %></td>
            </tr>
            <tr>
                <td class="total-label">Tax (0%)</td>
                <td class="text-right">LKR 0.00</td>
            </tr>
            <tr class="total-row">
                <td class="total-label">Total</td>
                <td class="text-right">LKR <%= String.format("%.2f", p.getAmount()) %></td>
            </tr>
            <tr class="due-date-row">
                <td class="total-label">Due Date</td>
                <td class="text-right"><%= p.getPaidAt() != null && !"-".equals(p.getPaidAt()) ? p.getPaidAt() : "Upon Receipt" %></td>
            </tr>
        </table>
    </div>
    
    <div class="footer-grid">
        <div>
            <div class="footer-title">Bank Details</div>
            <div class="bank-row">
                <span class="contact-label">BANK / FIC:</span>
                <span class="contact-value">000734456</span>
            </div>
            <div class="bank-row">
                <span class="contact-label">IBAN</span>
                <span class="contact-value">DE12 245K 7880 1254 5578.50</span>
            </div>
            <div class="bank-row">
                <span class="contact-label">Address</span>
                <span class="contact-value">Main. @ 12<br>50002 Denin<br>Germany</span>
            </div>
        </div>
        <div>
            <div class="footer-title">Terms</div>
            <div style="color: #555;">
                Payment is due within 20 days from the date of the invoice. 
                Please make payment to the specified bank account. 
                If you have any questions concerning this invoice, please contact us at your earliest.
            </div>
        </div>
    </div>
</div>

</body>
</html>
