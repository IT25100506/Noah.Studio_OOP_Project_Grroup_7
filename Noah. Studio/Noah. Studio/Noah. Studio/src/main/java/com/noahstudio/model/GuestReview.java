package com.noahstudio.model;

public class GuestReview extends Review {
    public GuestReview(String id, String clientId, String clientName, String staffId, int rating, String comment, String date, String status) {
        super(id, clientId, clientName, staffId, rating, comment, date, status);
    }

    @Override
    public String getType() { return "Guest"; }

    @Override
    protected String getExtraField() { return "-"; }

    @Override
    public String renderBadgeHTML() {
        return "<span class='badge' style='font-size:0.6rem; background:rgba(255,255,255,0.05); color:rgba(255,255,255,0.5); border:1px solid rgba(255,255,255,0.1);'><i class='fa fa-user'></i> Guest Feedback</span>";
    }
}
