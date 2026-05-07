package com.noahstudio.model;

/**
 * Abstract User base class — demonstrates Abstraction and Encapsulation.
 * Subclasses: Admin, Client, Photographer, Videographer
 */
public abstract class User {

    // ── Private fields (Encapsulation) ──────────────────────────────────────
    private String id;
    private String username;
    private String password;
    private String email;
    private String phone;
    private String role;       // admin | client | photographer | videographer
    private String fullName;
    private String specialization = "-"; // Default for non-staff
    private String availability   = "-"; // Default for non-staff

    // ── Constructors ─────────────────────────────────────────────────────────
    public User() {}

    public User(String id, String username, String password,
                String email, String phone, String role, String fullName) {
        this(id, username, password, email, phone, role, fullName, "-", "-");
    }

    public User(String id, String username, String password,
                String email, String phone, String role, String fullName,
                String specialization, String availability) {
        this.id       = id;
        this.username = username;
        this.password = password;
        this.email    = email;
        this.phone    = phone;
        this.role     = role;
        this.fullName = fullName;
        this.specialization = specialization;
        this.availability   = availability;
    }

    // ── Abstract method — Polymorphism ────────────────────────────────────────
    public abstract String getDashboardUrl();
    public abstract String getRoleDescription();

    // ── Getters / Setters ─────────────────────────────────────────────────────
    public String getId()                 { return id; }
    public void   setId(String id)        { this.id = id; }

    public String getUsername()               { return username; }
    public void   setUsername(String u)       { this.username = u; }

    public String getPassword()               { return password; }
    public void   setPassword(String p)       { this.password = p; }

    public String getEmail()                  { return email; }
    public void   setEmail(String e)          { this.email = e; }

    public String getPhone()                  { return phone; }
    public void   setPhone(String p)          { this.phone = p; }

    public String getRole()                   { return role; }
    public void   setRole(String r)           { this.role = r; }

    public String getFullName()               { return fullName; }
    public void   setFullName(String n)       { this.fullName = n; }

    public String getSpecialization()         { return specialization; }
    public void   setSpecialization(String s) { this.specialization = s; }

    public String getAvailability()           { return availability; }
    public void   setAvailability(String a)   { this.availability = a; }

    // ── File serialisation ────────────────────────────────────────────────────
    /**
     * Format: id|username|password|email|phone|role|fullName|specialization|availability
     */
    public String toFileString() {
        return id + "|" + username + "|" + password + "|"
             + email + "|" + phone + "|" + role + "|" + fullName + "|"
             + specialization + "|" + availability;
    }

    public static User fromFileString(String line) {
        String[] p = line.split("\\|", -1);
        if (p.length < 7) return null;
        String id = p[0], username = p[1], password = p[2],
               email = p[3], phone = p[4], role = p[5], fullName = p[6];
        
        String spec = (p.length > 7) ? p[7] : "-";
        String avail = (p.length > 8) ? p[8] : "-";

        switch (role.toLowerCase()) {
            case "admin":        return new Admin(id, username, password, email, phone, fullName, spec, avail);
            case "photographer": return new Photographer(id, username, password, email, phone, fullName, spec, avail);
            case "videographer": return new Videographer(id, username, password, email, phone, fullName, spec, avail);
            default:             return new Client(id, username, password, email, phone, fullName, spec, avail);
        }
    }

    @Override
    public String toString() {
        return "User{id='" + id + "', username='" + username + "', role='" + role + "'}";
    }
}
