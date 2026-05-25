package com.noahstudio.servlet;

import com.noahstudio.model.*;
import com.noahstudio.util.FileHandler;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.util.*;
import java.util.stream.Collectors;

public class PackageServlet extends HttpServlet {
    private static final String PKG_FILE = "packages.txt";

    @Override
    public void init() throws ServletException {
        FileHandler.init(getServletContext().getRealPath("/") + "data");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("delete".equals(action)) handleDelete(req, res);
        else handleList(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        if ("create".equals(action)) handleCreate(req, res);
        else if ("update".equals(action)) handleUpdate(req, res);
        else res.sendRedirect(req.getContextPath() + "/package?action=list");
    }

    private void handleList(HttpServletRequest req, HttpServletResponse res) throws IOException, ServletException {
        String typeFilter = req.getParameter("type");
        String priceMaxStr = req.getParameter("priceMax");
        
        List<ServicePackage> pkgs = new ArrayList<>();
        for (String line : FileHandler.readLines(PKG_FILE)) {
            ServicePackage p = ServicePackage.fromFileString(line);
            if (p != null) {
                // Apply filters
                boolean matchType = (typeFilter == null || typeFilter.isEmpty() || typeFilter.equalsIgnoreCase(p.getType()));
                boolean matchPrice = true;
                if (priceMaxStr != null && !priceMaxStr.isEmpty()) {
                    try { matchPrice = p.getPrice() <= Double.parseDouble(priceMaxStr); } catch(Exception e) {}
                }
                
                if (matchType && matchPrice) pkgs.add(p);
            }
        }
        req.setAttribute("packages", pkgs);
        
        HttpSession sess = req.getSession(false);
        String role = (sess != null) ? (String) sess.getAttribute("role") : null;
        
        if ("admin".equals(role)) {
            req.getRequestDispatcher("/packages-management.jsp").forward(req, res);
        } else {
            req.getRequestDispatcher("/packages.jsp").forward(req, res);
        }
    }

    private void handleCreate(HttpServletRequest req, HttpServletResponse res) throws IOException, ServletException {
        String id = FileHandler.generateId("PKG", PKG_FILE);
        String name = req.getParameter("name");
        double price = Double.parseDouble(req.getParameter("price"));
        String duration = req.getParameter("duration");
        String features = req.getParameter("features");
        String description = req.getParameter("description");
        String type = req.getParameter("type");

        ServicePackage pkg;
        if ("videography".equalsIgnoreCase(type)) {
            pkg = new VideographyPackage(id, name, price, duration, features, description, true);
        } else {
            pkg = new PhotographyPackage(id, name, price, duration, features, description, true);
        }
        boolean featured = Boolean.parseBoolean(req.getParameter("featured"));
        pkg.setFeatured(featured);
        
        FileHandler.appendLine(PKG_FILE, pkg.toFileString());
        res.sendRedirect(req.getContextPath() + "/package?action=list");
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse res) throws IOException {
        String id = req.getParameter("id");
        String line = FileHandler.findById(PKG_FILE, id);
        if (line != null) {
            ServicePackage pkg = ServicePackage.fromFileString(line);
            if (pkg != null) {
                pkg.setName(req.getParameter("name"));
                pkg.setPrice(Double.parseDouble(req.getParameter("price")));
                pkg.setDuration(req.getParameter("duration"));
                pkg.setFeatures(req.getParameter("features"));
                pkg.setDescription(req.getParameter("description"));
                pkg.setType(req.getParameter("type"));
                pkg.setFeatured(Boolean.parseBoolean(req.getParameter("featured")));
                
                FileHandler.updateById(PKG_FILE, id, pkg.toFileString());
            }
        }
        res.sendRedirect(req.getContextPath() + "/package?action=list");
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse res) throws IOException {
        FileHandler.deleteById(PKG_FILE, req.getParameter("id"));
        res.sendRedirect(req.getContextPath() + "/package?action=list");
    }
}
