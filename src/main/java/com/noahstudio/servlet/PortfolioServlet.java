package com.noahstudio.servlet;

import com.noahstudio.model.PortfolioItem;
import com.noahstudio.model.PhotoPortfolioItem;
import com.noahstudio.model.VideoPortfolioItem;
import com.noahstudio.util.FileHandler;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.time.LocalDate;
import java.util.*;

import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;

/**
 * PortfolioServlet — manages portfolio items using OOP Polymorphism.
 * URL: /portfolio
 * Actions: list | create | update | delete
 */
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,    // 1MB
    maxFileSize = 1024 * 1024 * 10,     // 10MB
    maxRequestSize = 1024 * 1024 * 50   // 50MB
)
public class PortfolioServlet extends HttpServlet {

    private static final String PORT_FILE = "portfolio.txt";

    @Override
    public void init() throws ServletException {
        String dataPath = getServletContext().getRealPath("/") + "data";
        FileHandler.init(dataPath);
        try {
            if (FileHandler.readLines(PORT_FILE).isEmpty()) seedPortfolio();
        } catch (IOException e) { e.printStackTrace(); }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null) action = "list";
        switch (action) {
            case "delete": handleDelete(req, res); break;
            case "view":   handleView(req, res); break;
            default:       handleList(req, res);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        if ("create".equals(action)) handleCreate(req, res);
        else if ("update".equals(action)) handleUpdate(req, res);
        else if ("delete".equals(action)) handleDelete(req, res);
        else if ("toggleFeatured".equals(action)) handleToggleFeatured(req, res);
        else res.sendRedirect(req.getContextPath() + "/portfolio.jsp");
    }

    // ── List all ─────────────────────────────────────────────────────────────
    private void handleList(HttpServletRequest req, HttpServletResponse res)
            throws IOException, ServletException {
        List<PortfolioItem> items = loadAll();
        
        String cat = req.getParameter("category");
        String type = req.getParameter("type");
        
        List<PortfolioItem> filtered = new ArrayList<>();
        for (PortfolioItem p : items) {
            boolean matchCat = FileHandler.isNullOrEmpty(cat) || cat.equalsIgnoreCase(p.getCategory());
            boolean matchType = FileHandler.isNullOrEmpty(type) || type.equalsIgnoreCase(p.getType());
            
            if (matchCat && matchType) {
                filtered.add(p);
            }
        }
        
        items = filtered;
        req.setAttribute("activeCategory", cat);
        req.setAttribute("activeType", type);
        
        req.setAttribute("portfolioItems", items);
        req.getRequestDispatcher("/portfolio.jsp").forward(req, res);
    }

    // ── Create ───────────────────────────────────────────────────────────────
    private void handleCreate(HttpServletRequest req, HttpServletResponse res)
            throws IOException, ServletException {
        HttpSession session = req.getSession(false);
        if (session == null) { res.sendRedirect(req.getContextPath() + "/login.jsp"); return; }
        
        String role = (String) session.getAttribute("role");
        if (!Arrays.asList("admin","photographer","videographer").contains(role)) {
            req.setAttribute("error", "Only photographers/videographers can add portfolio items.");
            handleList(req, res); return;
        }

        String type        = FileHandler.sanitize(req.getParameter("type"));
        String title       = FileHandler.sanitize(req.getParameter("title"));
        String category    = FileHandler.sanitize(req.getParameter("category"));
        String description = FileHandler.sanitize(req.getParameter("description"));
        String mediaUrl    = "";
        
        if ("Photo".equalsIgnoreCase(type)) {
            mediaUrl = uploadFile(req);
            if (mediaUrl == null || mediaUrl.isEmpty()) {
                mediaUrl = FileHandler.sanitize(req.getParameter("mediaUrl")); // fallback to URL if no file
            }
        } else {
            mediaUrl = FileHandler.sanitize(req.getParameter("mediaUrl"));
        }

        String staffId     = (String) session.getAttribute("userId");
        String staffName   = (String) session.getAttribute("fullName"); // Use fullName
        String date        = LocalDate.now().toString();

        if (FileHandler.isNullOrEmpty(title) || FileHandler.isNullOrEmpty(mediaUrl)) {
            req.setAttribute("error", "Title and Media (File or URL) are required.");
            handleList(req, res); return;
        }

        String id = FileHandler.generateId("PRT", PORT_FILE);
        PortfolioItem item;
        
        if ("Video".equalsIgnoreCase(type)) {
            item = new VideoPortfolioItem(id, staffId, staffName, title, description, category, date, mediaUrl);
        } else {
            item = new PhotoPortfolioItem(id, staffId, staffName, title, description, category, date, mediaUrl);
        }

        FileHandler.appendLine(PORT_FILE, item.toFileString());
        
        String redirect = req.getParameter("redirect");
        res.sendRedirect(req.getContextPath() + "/" + (redirect != null ? redirect : "portfolio.jsp"));
    }

    // ── Update ───────────────────────────────────────────────────────────────
    private void handleUpdate(HttpServletRequest req, HttpServletResponse res)
            throws IOException, ServletException {
        HttpSession session = req.getSession(false);
        if (session == null) { res.sendRedirect(req.getContextPath() + "/login.jsp"); return; }
        
        String id          = FileHandler.sanitize(req.getParameter("id"));
        String type        = FileHandler.sanitize(req.getParameter("type"));
        String title       = FileHandler.sanitize(req.getParameter("title"));
        String category    = FileHandler.sanitize(req.getParameter("category"));
        String description = FileHandler.sanitize(req.getParameter("description"));
        String mediaUrl    = "";

        if ("Photo".equalsIgnoreCase(type)) {
            mediaUrl = uploadFile(req);
        }
        
        // If no new file uploaded, keep the old one
        if (FileHandler.isNullOrEmpty(mediaUrl)) {
            mediaUrl = FileHandler.sanitize(req.getParameter("mediaUrl"));
        }

        String line = FileHandler.findById(PORT_FILE, id);
        if (line != null) {
            PortfolioItem existing = PortfolioItem.fromFileString(line);
            if (existing != null) {
                PortfolioItem updated;
                if ("Video".equalsIgnoreCase(type)) {
                    updated = new VideoPortfolioItem(id, existing.getStaffId(), existing.getStaffName(), 
                                                     title, description, category, existing.getDate(), mediaUrl);
                } else {
                    updated = new PhotoPortfolioItem(id, existing.getStaffId(), existing.getStaffName(), 
                                                     title, description, category, existing.getDate(), mediaUrl);
                }
                FileHandler.updateById(PORT_FILE, id, updated.toFileString());
            }
        }
        
        String redirect = req.getParameter("redirect");
        res.sendRedirect(req.getContextPath() + "/" + (redirect != null ? redirect : "portfolio.jsp"));
    }

    // ── Delete ───────────────────────────────────────────────────────────────
    private void handleDelete(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null) { res.sendRedirect(req.getContextPath() + "/login.jsp"); return; }
        
        String id   = req.getParameter("id");
        String role = (String) session.getAttribute("role");
        String uid  = (String) session.getAttribute("userId");
        
        String line = FileHandler.findById(PORT_FILE, id);
        if (line != null) {
            PortfolioItem pf = PortfolioItem.fromFileString(line);
            if (pf != null && ("admin".equals(role) || pf.getStaffId().equals(uid))) {
                FileHandler.deleteById(PORT_FILE, id);
            }
        }
        
        String redirect = req.getParameter("redirect");
        if (redirect != null && !redirect.isEmpty()) {
            res.sendRedirect(req.getContextPath() + "/" + redirect);
        } else {
            if ("admin".equals(role) || "photographer".equals(role) || "videographer".equals(role)) {
                res.sendRedirect(req.getContextPath() + "/portfolio-management.jsp");
            } else {
                res.sendRedirect(req.getContextPath() + "/portfolio.jsp");
            }
        }
    }

    // ── View (Increment Views) ───────────────────────────────────────────────
    private void handleView(HttpServletRequest req, HttpServletResponse res)
            throws IOException, ServletException {
        String id = req.getParameter("id");
        String line = FileHandler.findById(PORT_FILE, id);
        
        if (line != null) {
            PortfolioItem item = PortfolioItem.fromFileString(line);
            if (item != null) {
                // Increment views
                item.incrementViews();
                FileHandler.updateById(PORT_FILE, id, item.toFileString());
                
                req.setAttribute("portfolioItem", item);
                req.getRequestDispatcher("/portfolio-detail.jsp").forward(req, res);
                return;
            }
        }
        res.sendRedirect(req.getContextPath() + "/portfolio?action=list");
    }

    // ── Toggle Featured ──────────────────────────────────────────────────────
    private void handleToggleFeatured(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("role"))) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String id = req.getParameter("id");
        String line = FileHandler.findById(PORT_FILE, id);
        if (line != null) {
            PortfolioItem item = PortfolioItem.fromFileString(line);
            if (item != null) {
                item.setFeatured(!item.isFeatured());
                FileHandler.updateById(PORT_FILE, id, item.toFileString());
            }
        }
        res.sendRedirect(req.getContextPath() + "/portfolio-management.jsp");
    }

    // ── File Upload Helper ───────────────────────────────────────────────────
    private String uploadFile(HttpServletRequest req) {
        try {
            Part part = req.getPart("mediaFile");
            if (part == null || part.getSize() == 0) return null;

            String fileName = UUID.randomUUID().toString() + "_" + getFileName(part);
            String uploadPath = getServletContext().getRealPath("/") + "uploads" + File.separator + "portfolio";
            
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdirs();

            part.write(uploadPath + File.separator + fileName);
            return "uploads/portfolio/" + fileName;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        for (String content : contentDisp.split(";")) {
            if (content.trim().startsWith("filename")) {
                return content.substring(content.indexOf("=") + 2, content.length() - 1);
            }
        }
        return "file";
    }

    // ── Helper ────────────────────────────────────────────────────────────────
    private List<PortfolioItem> loadAll() throws IOException {
        List<PortfolioItem> items = new ArrayList<>();
        for (String line : FileHandler.readLines(PORT_FILE)) {
            PortfolioItem p = PortfolioItem.fromFileString(line);
            if (p != null) items.add(p);
        }
        return items;
    }

    // ── Seed sample portfolio ─────────────────────────────────────────────────
    private void seedPortfolio() throws IOException {
        FileHandler.appendLine(PORT_FILE, "PRT001|Photo|USR002|Alex|Garden Wedding|Romantic garden wedding shoot in golden hour.|Wedding|2026-01-15|https://images.unsplash.com/photo-1519741497674-611481863552?w=800");
        FileHandler.appendLine(PORT_FILE, "PRT002|Photo|USR002|Alex|Corporate Gala|Annual corporate awards night coverage.|Events|2026-02-10|https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800");
        FileHandler.appendLine(PORT_FILE, "PRT003|Photo|USR002|Alex|Studio Portrait|Professional studio portrait session.|Portrait|2026-03-05|https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=800");
        FileHandler.appendLine(PORT_FILE, "PRT004|Photo|USR002|Alex|Beach Wedding|Sunset beach wedding ceremony.|Wedding|2026-03-20|https://images.unsplash.com/photo-1465495976277-4387d4b0b4c6?w=800");
        FileHandler.appendLine(PORT_FILE, "PRT005|Video|USR003|Sam|Birthday Bash|Colourful 30th birthday celebration.|Events|2026-04-01|https://www.youtube.com/embed/dQw4w9WgXcQ");
    }
}
