package com.noahstudio.model;

/**
 * PortfolioItem — Abstract base class for all portfolio entries.
 * Demonstrates OOP Encapsulation (private fields, public getters/setters) 
 * and Polymorphism (abstract renderPreviewHTML method).
 */
public abstract class PortfolioItem {

    // ── Private fields (Encapsulation) ────────────────────────────────────────
    private String id;
    private String type;         // "Photo" or "Video"
    private String staffId;
    private String staffName;
    private String title;
    private String description;
    private String category;     // e.g. Wedding, Corporate, Portrait
    private String date;         // yyyy-MM-dd
    private String mediaUrl;     // URL or file path to the image/video
    private int views = 0;
    private boolean featured = false;

    // ── Constructors ──────────────────────────────────────────────────────────
    public PortfolioItem() {}

    public PortfolioItem(String id, String type, String staffId, String staffName, 
                         String title, String description, String category, 
                         String date, String mediaUrl) {
        this.id = id;
        this.type = type;
        this.staffId = staffId;
        this.staffName = staffName;
        this.title = title;
        this.description = description;
        this.category = category;
        this.date = date;
        this.mediaUrl = mediaUrl;
    }

    // ── Abstract Method (Polymorphism) ────────────────────────────────────────
    /**
     * Subclasses MUST define how they should be rendered in the HTML gallery.
     */
    public abstract String renderPreviewHTML();

    // ── Getters / Setters ─────────────────────────────────────────────────────
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getStaffId() { return staffId; }
    public void setStaffId(String staffId) { this.staffId = staffId; }

    public String getStaffName() { return staffName; }
    public void setStaffName(String staffName) { this.staffName = staffName; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getDate() { return date; }
    public void setDate(String date) { this.date = date; }

    public String getMediaUrl() { return mediaUrl; }
    public void setMediaUrl(String mediaUrl) { this.mediaUrl = mediaUrl; }

    public int getViews() { return views; }
    public void setViews(int views) { this.views = views; }
    public void incrementViews() { this.views++; }

    public boolean isFeatured() { return featured; }
    public void setFeatured(boolean featured) { this.featured = featured; }

    // ── File serialization ────────────────────────────────────────────────────
    /** Format: id|type|staffId|staffName|title|description|category|date|mediaUrl|views|featured */
    public String toFileString() {
        return id + "|" + type + "|" + staffId + "|" + staffName + "|" 
             + title.replace("|", "~") + "|" 
             + description.replace("|", "~") + "|" 
             + category + "|" + date + "|" + mediaUrl + "|" + views + "|" + featured;
    }

    /** 
     * Factory method: Instantiates the correct subclass based on the "type" field. 
     */
    public static PortfolioItem fromFileString(String line) {
        String[] p = line.split("\\|", -1);
        if (p.length < 9) return null;
        
        String type = p[1];
        PortfolioItem item;
        
        if ("Photo".equalsIgnoreCase(type)) {
            item = new PhotoPortfolioItem();
        } else if ("Video".equalsIgnoreCase(type)) {
            item = new VideoPortfolioItem();
        } else {
            return null; // Unknown type
        }

        item.setId(p[0]);
        item.setType(p[1]);
        item.setStaffId(p[2]);
        item.setStaffName(p[3]);
        item.setTitle(p[4].replace("~", "|"));
        item.setDescription(p[5].replace("~", "|"));
        item.setCategory(p[6]);
        item.setDate(p[7]);
        item.setMediaUrl(p[8]);
        
        if (p.length > 9) {
            try { item.setViews(Integer.parseInt(p[9])); } catch (Exception e) { item.setViews(0); }
        }
        if (p.length > 10) {
            item.setFeatured(Boolean.parseBoolean(p[10]));
        }
        
        return item;
    }
}
