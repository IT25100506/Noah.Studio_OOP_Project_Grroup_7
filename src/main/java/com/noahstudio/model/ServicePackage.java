package com.noahstudio.model;

/**
 * ServicePackage — Abstract base class (Abstraction).
 * Subclasses: PhotographyPackage, VideographyPackage
 */
public abstract class ServicePackage {

    private String id;
    private String name;
    private double price;
    private String duration;
    private String features;
    private String description;
    private boolean active;
    private String type; // photography | videography

    // ── Constructors ──────────────────────────────────────────────────────────
    public ServicePackage() {}

    public ServicePackage(String id, String name, double price,
                          String duration, String features,
                          String description, boolean active, String type) {
        this.id          = id;
        this.name        = name;
        this.price       = price;
        this.duration    = duration;
        this.features    = features;
        this.description = description;
        this.active      = active;
        this.type        = type;
    }

    // ── Abstract method — Polymorphism ────────────────────────────────────────
    /** Different pricing logic for membership levels */
    public abstract double getDiscountedPrice(String membershipLevel);

    // ── Getters / Setters ─────────────────────────────────────────────────────
    public String getId()                  { return id; }
    public void   setId(String v)          { this.id = v; }

    public String getName()                { return name; }
    public void   setName(String v)        { this.name = v; }

    public double getPrice()               { return price; }
    public void   setPrice(double v)       { this.price = v; }

    public String getDuration()            { return duration; }
    public void   setDuration(String v)    { this.duration = v; }

    public String getFeatures()            { return features; }
    public void   setFeatures(String v)    { this.features = v; }

    public String getDescription()         { return description; }
    public void   setDescription(String v) { this.description = v; }

    public boolean isActive()              { return active; }
    public void    setActive(boolean v)    { this.active = v; }

    public String getType()                { return type; }
    public void   setType(String v)        { this.type = v; }

    // ── File serialisation ────────────────────────────────────────────────────
    /** Format: id|name|price|duration|features|description|active|type */
    public String toFileString() {
        return id + "|" + name + "|" + price + "|"
             + duration + "|" + features.replace("|","~") + "|"
             + description.replace("|","~") + "|" + active + "|" + type;
    }

    public static ServicePackage fromFileString(String line) {
        String[] p = line.split("\\|", -1);
        if (p.length < 7) return null;
        
        String id = p[0], name = p[1];
        double prc; try { prc = Double.parseDouble(p[2]); } catch(Exception e) { prc = 0; }
        String dur = p[3], feat = p[4].replace("~","|"), desc = p[5].replace("~","|"), 
               activeStr = p[6], type = (p.length > 7) ? p[7] : "photography";
        
        boolean active = Boolean.parseBoolean(activeStr);

        if ("videography".equalsIgnoreCase(type)) {
            return new VideographyPackage(id, name, prc, dur, feat, desc, active);
        } else {
            return new PhotographyPackage(id, name, prc, dur, feat, desc, active);
        }
    }
}
