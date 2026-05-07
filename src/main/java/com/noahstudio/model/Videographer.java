package com.noahstudio.model;

/**
 * Videographer — inherits from User.
 * Adds specialization and availability tracking.
 */
public class Videographer extends User {

    public Videographer() { super(); setRole("videographer"); }

    public Videographer(String id, String username, String password,
                        String email, String phone, String fullName) {
        super(id, username, password, email, phone, "videographer", fullName);
    }

    public Videographer(String id, String username, String password,
                        String email, String phone, String fullName,
                        String specialization, String availability) {
        super(id, username, password, email, phone, "videographer", fullName, specialization, availability);
    }

    @Override
    public String getDashboardUrl() { return "videographer-dashboard.jsp"; }

    @Override
    public String getRoleDescription() {
        return "Cinematic story teller through moving visuals. Can manage their own portfolio and availability.";
    }
}
