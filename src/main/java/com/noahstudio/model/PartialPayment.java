package com.noahstudio.model;

/**
 * PartialPayment — represents an installment or deposit for a booking.
 */
public class PartialPayment extends Payment {

    private double balanceDue;

    public PartialPayment() {
        super();
    }

    public PartialPayment(String id, String bookingId, String clientId,
                          String clientName, double amount, String method,
                          String status, String paidAt, String notes, String staffId, 
                          double balanceDue) {
        super(id, bookingId, clientId, clientName, amount, method, status, paidAt, notes, staffId);
        this.balanceDue = balanceDue;
    }

    public double getBalanceDue() { return balanceDue; }
    public void setBalanceDue(double v) { this.balanceDue = v; }

    @Override
    public String getPaymentCategory() {
        return "Installment / Deposit";
    }

    @Override
    public String renderInvoiceHeaderHTML() {
        return "<div class='invoice-badge partial'>INTERIM INVOICE — PARTIAL PAYMENT</div>" +
               "<div class='balance-notice'>Outstanding Balance: LKR " + String.format("%.0f", balanceDue) + "</div>";
    }

    @Override
    public String toFileString() {
        return getId() + "|Partial|" + getBookingId() + "|" + getClientId() + "|"
             + getClientName() + "|" + getAmount() + "|" + getMethod() + "|"
             + getStatus() + "|" + getPaidAt() + "|" + getNotes().replace("|","~") + "|" 
             + balanceDue + "|" + getStaffId();
    }
}
