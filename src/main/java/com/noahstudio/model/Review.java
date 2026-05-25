package com.noahstudio.model;

import java.time.LocalDate;

public abstract class Review {
    protected String id;
    protected String clientId;
    protected String clientName;
    protected String staffId;
    protected int rating;
    protected String comment;
    protected String date;
    protected String status; // Pending, Approved, Hidden
    protected int helpfulCount = 0;

    public static final String STATUS_PENDING = "Pending";
    public static final String STATUS_APPROVED = "Approved";
    public static final String STATUS_HIDDEN = "Hidden";

    public Review(String id, String clientId, String clientName, String staffId, int rating, String comment, String date, String status) {
        this.id = id;
        this.clientId = clientId;
        this.clientName = clientName;
        this.staffId = staffId;
        this.rating = rating;
        this.comment = comment;
        this.date = (date == null || date.equals("-")) ? LocalDate.now().toString() : date;
        this.status = (status == null) ? STATUS_PENDING : status;
    }

    // Getters and Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getClientId() { return clientId; }
    public String getClientName() { return clientName; }
    public String getStaffId() { return staffId; }
    public int getRating() { return rating; }
    public void setRating(int rating) { this.rating = rating; }
    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }
    public String getDate() { return date; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public int getHelpfulCount() { return helpfulCount; }
    public void setHelpfulCount(int helpfulCount) { this.helpfulCount = helpfulCount; }
    public void incrementHelpfulCount() { this.helpfulCount++; }

    public abstract String getType();
    public abstract String renderBadgeHTML();

    public String toFileString() {
        return String.join("|", 
            id, getType(), clientId, clientName, staffId, 
            getExtraField(), String.valueOf(rating), comment, date, status, String.valueOf(helpfulCount)
        );
    }

    protected abstract String getExtraField();

    public static Review fromFileString(String line) {
        if (line == null || line.trim().isEmpty()) return null;
        String[] parts = line.split("\\|");
        if (parts.length < 10) return null;

        String id = parts[0];
        String type = parts[1];
        String cId = parts[2];
        String cName = parts[3];
        String sId = parts[4];
        String extra = parts[5];
        int rating = Integer.parseInt(parts[6]);
        String comment = parts[7];
        String date = parts[8];
        String status = parts[9];
        
        int helpful = 0;
        if (parts.length > 10) {
            try { helpful = Integer.parseInt(parts[10]); } catch (Exception e) {}
        }

        Review rev;
        if ("Verified".equals(type)) {
            rev = new VerifiedReview(id, cId, cName, sId, extra, rating, comment, date, status);
        } else {
            rev = new GuestReview(id, cId, cName, sId, rating, comment, date, status);
        }
        rev.setHelpfulCount(helpful);
        return rev;
    }
}
