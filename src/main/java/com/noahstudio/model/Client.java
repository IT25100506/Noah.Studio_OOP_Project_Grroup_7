package com.noahstudio.model;

/**
 * Client — inherits from User.
 * Can create bookings, make payments, and post reviews.
 */
public class Client extends User {

    public Client() { super(); setRole("client"); }

    public Client(String id, String username, String password,
                  String email, String phone, String fullName) {
        super(id, username, password, email, phone, "client", fullName);
    }

    public Client(String id, String username, String password,
                  String email, String phone, String fullName,
                  String specialization, String availability) {
        super(id, username, password, email, phone, "client", fullName, specialization, availability);
    }

    @Override
    public String getDashboardUrl() { return "booking.jsp"; }

    @Override
    public String getRoleDescription() {
        return "Create bookings, view packages, make payments, and submit reviews.";
    }
}
