package com.noahstudio.model;

/**
 * FullPayment — represents a 100% settlement for a booking.
 */
public class FullPayment extends Payment {

    public FullPayment() {
        super();
    }

    public FullPayment(String id, String bookingId, String clientId,
                       String clientName, double amount, String method,
                       String status, String paidAt, String notes, String staffId) {
        super(id, bookingId, clientId, clientName, amount, method, status, paidAt, notes, staffId);
    }

    @Override
    public String getPaymentCategory() {
        return "Full Settlement";
    }

    @Override
    public String renderInvoiceHeaderHTML() {
        return "<div class='invoice-badge full'>OFFICIAL RECEIPT — FULL SETTLEMENT</div>";
    }

    @Override
    public String toFileString() {
        return getId() + "|Full|" + getBookingId() + "|" + getClientId() + "|"
             + getClientName() + "|" + getAmount() + "|" + getMethod() + "|"
             + getStatus() + "|" + getPaidAt() + "|" + getNotes().replace("|","~") + "|" 
             + "0.0" + "|" + getStaffId(); // 0.0 for balanceDue column
    }
}
