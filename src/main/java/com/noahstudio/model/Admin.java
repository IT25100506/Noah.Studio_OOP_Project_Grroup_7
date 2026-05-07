package com.noahstudio.model;

/**
 * Admin — inherits from User (Inheritance + Polymorphism).
 * Has full system access.
 */
public class Admin extends User {

    public Admin() { super(); setRole("admin"); }

    public Admin(String id, String username, String password,
                 String email, String phone, String fullName) {
        super(id, username, password, email, phone, "admin", fullName);
    }

    public Admin(String id, String username, String password,
                 String email, String phone, String fullName,
                 String specialization, String availability) {
        super(id, username, password, email, phone, "admin", fullName, specialization, availability);
    }

    @Override
    public String getDashboardUrl() { return "admin-dashboard.jsp"; }

    @Override
    public String getRoleDescription() {
        return "Full system administration: manage users, bookings, packages, payments, reviews.";
    }
}
