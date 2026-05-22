package com.noahstudio.model;

/**
 * VideoPortfolioItem — Subclass for videography portfolio entries.
 * Demonstrates OOP Inheritance and Polymorphism.
 */
public class VideoPortfolioItem extends PortfolioItem {

    public VideoPortfolioItem() {
        super();
        this.setType("Video");
    }

    public VideoPortfolioItem(String id, String staffId, String staffName, 
                              String title, String description, String category, 
                              String date, String mediaUrl) {
        super(id, "Video", staffId, staffName, title, description, category, date, mediaUrl);
    }

    @Override
    public String getMediaUrl() {
        String url = super.getMediaUrl();
        if (url == null) return "";
        
        // Convert standard youtube links to embed links
        if (url.contains("youtube.com/watch?v=")) {
            url = url.replace("watch?v=", "embed/");
            int ampersandIndex = url.indexOf("&");
            if (ampersandIndex != -1) {
                url = url.substring(0, ampersandIndex);
            }
        } else if (url.contains("youtu.be/")) {
            url = url.replace("youtu.be/", "youtube.com/embed/");
            int queryIndex = url.indexOf("?");
            if (queryIndex != -1) {
                url = url.substring(0, queryIndex);
            }
        }
        return url;
    }

    /**
     * Polymorphic implementation: Renders an iframe (e.g. YouTube/Vimeo embed) 
     * or a video tag for the gallery. We'll use a standardized iframe embed layout.
     */
    @Override
    public String renderPreviewHTML() {
        String url = this.getMediaUrl();
        // If it's a standard MP4 file instead of YouTube, we would use <video>.
        // For this system, we'll assume standard video links or YouTube embeds.
        boolean isMp4 = url.toLowerCase().endsWith(".mp4");
        
        if (isMp4) {
            return "<div class=\"portfolio-media video-media\">" +
                   "<video controls loop muted preload=\"metadata\">" +
                   "<source src=\"" + url + "\" type=\"video/mp4\">" +
                   "Your browser does not support the video tag." +
                   "</video>" +
                   "<div class=\"play-overlay\"><i class=\"fa fa-play-circle\"></i></div>" +
                   "</div>";
        } else {
            // Assume iframe embed (e.g., YouTube)
            return "<div class=\"portfolio-media video-media iframe-container\">" +
                   "<iframe src=\"" + url + "\" frameborder=\"0\" allow=\"accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen></iframe>" +
                   "</div>";
        }
    }
}
