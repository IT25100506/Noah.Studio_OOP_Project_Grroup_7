package com.noahstudio.model;

/**
 * Booking model — encapsulates a client's service booking.
 * Status lifecycle: Pending → Confirmed → Completed / Cancelled
 */
public class Booking {

    // ── Constants ─────────────────────────────────────────────────────────────
    public static final String STATUS_PENDING   = "Pending";
    public static final String STATUS_CONFIRMED = "Confirmed";
    public static final String STATUS_COMPLETED = "Completed";
    public static final String STATUS_CANCELLED = "Cancelled";

    // ── Private fields (Encapsulation) ────────────────────────────────────────
    private String id;
    private String clientId;
    private String clientName;
    private String packageId;
    private String packageName;
    private String eventDate;       // yyyy-MM-dd
    private String eventLocation;
    private String eventType;       // Wedding | Birthday | Corporate | Other
    private String eventTime;
    private String clientContact;
    private String status;
    private String notes;
    private String createdAt;       // yyyy-MM-dd
    private String staffId = "-";   // Assigned photographer/videographer

    // ── Constructors ──────────────────────────────────────────────────────────
    public Booking() {}

    public Booking(String id, String clientId, String clientName,
                   String packageId, String packageName,
                   String eventDate, String eventTime, String eventLocation,
                   String eventType, String clientContact, String status,
                   String notes, String createdAt, String staffId) {
        this.id            = id;
        this.clientId      = clientId;
        this.clientName    = clientName;
        this.packageId     = packageId;
        this.packageName   = packageName;
        this.eventDate     = eventDate;
        this.eventTime     = eventTime;
        this.eventLocation = eventLocation;
        this.eventType     = eventType;
        this.clientContact = clientContact;
        this.status        = status;
        this.notes         = notes;
        this.createdAt     = createdAt;
        this.staffId       = staffId;
    }

    // ── Getters / Setters ─────────────────────────────────────────────────────
    public String getId()                      { return id; }
    public void   setId(String id)             { this.id = id; }

    public String getClientId()                { return clientId; }
    public void   setClientId(String v)        { this.clientId = v; }

    public String getClientName()              { return clientName; }
    public void   setClientName(String v)      { this.clientName = v; }

    public String getServicePackageId()               { return packageId; }
    public void   setServicePackageId(String v)       { this.packageId = v; }

    public String getServicePackageName()             { return packageName; }
    public void   setServicePackageName(String v)     { this.packageName = v; }

    public String getEventDate()               { return eventDate; }
    public void   setEventDate(String v)       { this.eventDate = v; }

    public String getEventTime()               { return eventTime; }
    public void   setEventTime(String v)       { this.eventTime = v; }

    public String getEventLocation()           { return eventLocation; }
    public void   setEventLocation(String v)   { this.eventLocation = v; }

    public String getEventType()               { return eventType; }
    public void   setEventType(String v)       { this.eventType = v; }

    public String getClientContact()           { return clientContact; }
    public void   setClientContact(String v)   { this.clientContact = v; }

    public String getStatus()                  { return status; }
    public void   setStatus(String v)          { this.status = v; }

    public String getNotes()                   { return notes; }
    public void   setNotes(String v)           { this.notes = v; }

    public String getCreatedAt()               { return createdAt; }
    public void   setCreatedAt(String v)       { this.createdAt = v; }

    public String getStaffId()                 { return staffId; }
    public void   setStaffId(String v)         { this.staffId = v; }

    // ── File serialisation ────────────────────────────────────────────────────
    /** Format: id|clientId|clientName|packageId|packageName|eventDate|eventTime|eventLocation|eventType|clientContact|status|notes|createdAt|staffId */
    public String toFileString() {
        return id + "|" + clientId + "|" + clientName + "|"
             + packageId + "|" + packageName + "|" + eventDate + "|"
             + eventTime + "|" + eventLocation + "|" + eventType + "|"
             + clientContact + "|" + status + "|"
             + notes.replace("|", "~") + "|" + createdAt + "|" + staffId;
    }

    public static Booking fromFileString(String line) {
        String[] p = line.split("\\|", -1);
        if (p.length < 13) return null;
        Booking b = new Booking();
        b.setId(p[0]);
        b.setClientId(p[1]);
        b.setClientName(p[2]);
        b.setServicePackageId(p[3]);
        b.setServicePackageName(p[4]);
        b.setEventDate(p[5]);
        b.setEventTime(p[6]);
        b.setEventLocation(p[7]);
        b.setEventType(p[8]);
        b.setClientContact(p[9]);
        b.setStatus(p[10]);
        b.setNotes(p[11].replace("~", "|"));
        b.setCreatedAt(p[12]);
        if (p.length > 13) b.setStaffId(p[13]);
        return b;
    }
}
