package com.noahstudio.model;

public class VerifiedReview extends Review {
    private String bookingId;

    public VerifiedReview(String id, String clientId, String clientName, String staffId, String bookingId, int rating, String comment, String date, String status) {
        super(id, clientId, clientName, staffId, rating, comment, date, status);
        this.bookingId = bookingId;
    }

    public String getBookingId() { return bookingId; }

    @Override
    public String getType() { return "Verified"; }

    @Override
    protected String getExtraField() { return bookingId; }

    @Override
    public String renderBadgeHTML() {
        return "<span class='badge badge-success' style='font-size:0.6rem; background:rgba(76,175,80,0.1); color:#4caf50; border:1px solid rgba(76,175,80,0.2);'><i class='fa fa-check-circle'></i> Verified Session</span>";
    }
}
