package com.noahstudio.model;

/**
 * Payment model — Abstract base class for payment records.
 * Demonstrates OOP Encapsulation (private fields) and Polymorphism (abstract methods).
 */
public abstract class Payment {

    public static final String STATUS_PAID      = "Paid";
    public static final String STATUS_PARTIAL   = "Partially Paid";
    public static final String STATUS_PENDING   = "Pending";
    public static final String STATUS_REFUNDED  = "Refunded";

    private String id;
    private String bookingId;
    private String clientId;
    private String clientName;
    private double amount;
    private String method;       // Cash | Bank Transfer | Online
    private String status;       // Paid | Pending | Partial | Refunded
    private String paidAt;       // yyyy-MM-dd or "-"
    private String notes;
    private String staffId = "-";

    public Payment() {}

    public Payment(String id, String bookingId, String clientId,
                   String clientName, double amount, String method,
                   String status, String paidAt, String notes, String staffId) {
        this.id          = id;
        this.bookingId   = bookingId;
        this.clientId    = clientId;
        this.clientName  = clientName;
        this.amount      = amount;
        this.method      = method;
        this.status      = status;
        this.paidAt      = paidAt;
        this.notes       = notes;
        this.staffId     = staffId;
    }

    // ── Polymorphic Methods ──────────────────────────────────────────────────
    public abstract String getPaymentCategory();
    public abstract String renderInvoiceHeaderHTML();

    // ── Getters / Setters (Encapsulation) ────────────────────────────────────
    public String getId()                   { return id; }
    public void   setId(String v)           { this.id = v; }

    public String getBookingId()            { return bookingId; }
    public void   setBookingId(String v)    { this.bookingId = v; }

    public String getClientId()             { return clientId; }
    public void   setClientId(String v)     { this.clientId = v; }

    public String getClientName()           { return clientName; }
    public void   setClientName(String v)   { this.clientName = v; }

    public double getAmount()               { return amount; }
    public void   setAmount(double v)       { this.amount = v; }

    public String getMethod()               { return method; }
    public void   setMethod(String v)       { this.method = v; }

    public String getStatus()               { return status; }
    public void   setStatus(String v)       { this.status = v; }

    public String getPaidAt()               { return paidAt; }
    public void   setPaidAt(String v)       { this.paidAt = v; }

    public String getNotes()                { return notes; }
    public void   setNotes(String v)        { this.notes = v; }

    public String getStaffId()              { return staffId; }
    public void   setStaffId(String v)      { this.staffId = v; }

    // ── File serialisation ────────────────────────────────────────────────────
    public abstract String toFileString();

    public static Payment fromFileString(String line) {
        String[] p = line.split("\\|", -1);
        if (p.length < 10) return null;
        
        String type = p[1]; // Payment type (Full/Partial)
        Payment pay;
        
        if ("Full".equalsIgnoreCase(type)) {
            pay = new FullPayment();
        } else if ("Partial".equalsIgnoreCase(type)) {
            pay = new PartialPayment();
            if (p.length > 10) {
                try { ((PartialPayment)pay).setBalanceDue(Double.parseDouble(p[10])); } catch(Exception e) {}
            }
        } else {
            return null;
        }

        pay.setId(p[0]);
        pay.setBookingId(p[2]);
        pay.setClientId(p[3]);
        pay.setClientName(p[4]);
        try { pay.setAmount(Double.parseDouble(p[5])); } catch (Exception e) {}
        pay.setMethod(p[6]);
        pay.setStatus(p[7]);
        pay.setPaidAt(p[8]);
        pay.setNotes(p[9].replace("~","|"));
        if (p.length > 11) pay.setStaffId(p[11]);
        
        return pay;
    }
}
