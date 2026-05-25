package com.noahstudio.model;

/**
 * PhotoPortfolioItem — Subclass for photography portfolio entries.
 * Demonstrates OOP Inheritance and Polymorphism.
 */
public class PhotoPortfolioItem extends PortfolioItem {

    public PhotoPortfolioItem() {
        super();
        this.setType("Photo");
    }

    public PhotoPortfolioItem(String id, String staffId, String staffName, 
                              String title, String description, String category, 
                              String date, String mediaUrl) {
        super(id, "Photo", staffId, staffName, title, description, category, date, mediaUrl);
    }

    /**
     * Polymorphic implementation: Renders an image tag for the gallery.
     */
    @Override
    public String renderPreviewHTML() {
        return "<div class=\"portfolio-media photo-media\">" +
               "<img src=\"" + this.getMediaUrl() + "\" alt=\"" + this.getTitle() + "\" loading=\"lazy\">" +
               "</div>";
    }
}
