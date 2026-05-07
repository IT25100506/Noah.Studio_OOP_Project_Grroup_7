package com.noahstudio.model;

/**
 * Photographer — inherits from User.
 * Adds specialization and availability tracking.
 */
public class Photographer extends User {

    public Photographer() { super(); setRole("photographer"); }

    public Photographer(String id, String username, String password,
                        String email, String phone, String fullName) {
        super(id, username, password, email, phone, "photographer", fullName);
    }

    public Photographer(String id, String username, String password,
                        String email, String phone, String fullName,
                        String specialization, String availability) {
        super(id, username, password, email, phone, "photographer", fullName, specialization, availability);
    }

    @Override
    public String getDashboardUrl() { return "photographer-dashboard.jsp"; }

    @Override
    public String getRoleDescription() {
        return "Expert in capturing visual still moments. Can manage their own portfolio and availability.";
    }
}
