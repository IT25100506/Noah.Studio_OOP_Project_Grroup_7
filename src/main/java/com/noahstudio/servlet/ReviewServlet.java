// Feedback and Review Management Module - Owned by IT25100494
package com.noahstudio.servlet;

import com.noahstudio.model.*;
import com.noahstudio.util.FileHandler;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.util.*;

public class ReviewServlet extends HttpServlet {
    private static final String REV_FILE = "reviews.txt";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null) action = "list";

        FileHandler.init(getServletContext().getRealPath("/") + "data");

        switch (action) {
            case "list": handleList(req, res); break;
            case "delete": handleDelete(req, res); break;
            case "moderate": handleModerate(req, res); break;
            default: res.sendRedirect("index.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String action = req.getParameter("action");
        FileHandler.init(getServletContext().getRealPath("/") + "data");

        if ("create".equals(action)) handleCreate(req, res);
        else if ("update".equals(action)) handleUpdate(req, res);
        else res.sendRedirect("index.jsp");
    }

    private void handleList(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        List<Review> reviews = new ArrayList<>();
        for (String l : FileHandler.readLines(REV_FILE)) {
            Review r = Review.fromFileString(l);
            if (r != null) reviews.add(r);
        }

        HttpSession sess = req.getSession(false);
        String role = (sess != null) ? (String) sess.getAttribute("role") : null;
        String uid = (sess != null) ? (String) sess.getAttribute("uid") : null;

        if ("admin".equals(role)) {
            req.setAttribute("reviews", reviews);
            req.getRequestDispatcher("review-management.jsp").forward(req, res);
        } else {
            List<Review> visible = new ArrayList<>();
            for (Review r : reviews) {
                if (Review.STATUS_APPROVED.equals(r.getStatus()) || (uid != null && uid.equals(r.getClientId()))) {
                    visible.add(r);
                }
            }
            req.setAttribute("reviews", visible);
            req.getRequestDispatcher("reviews.jsp").forward(req, res);
        }
    }

    private void handleCreate(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession sess = req.getSession(false);
        if (sess == null || sess.getAttribute("userId") == null) {
            res.sendRedirect("login.jsp"); return;
        }

        String id = "REV" + System.currentTimeMillis();
        String clientId = (String) sess.getAttribute("userId");
        String clientName = (String) sess.getAttribute("fullName");
        String staffId = req.getParameter("staffId");
        String bookingId = req.getParameter("bookingId");
        int rating = Integer.parseInt(req.getParameter("rating"));
        String comment = req.getParameter("comment");

        Review rev;
        if (bookingId != null && !bookingId.isEmpty() && !"-".equals(bookingId)) {
            rev = new VerifiedReview(id, clientId, clientName, staffId, bookingId, rating, comment, LocalDate.now().toString(), Review.STATUS_PENDING);
        } else {
            rev = new GuestReview(id, clientId, clientName, staffId, rating, comment, LocalDate.now().toString(), Review.STATUS_PENDING);
        }

        FileHandler.appendLine(REV_FILE, rev.toFileString());
        
        String source = req.getParameter("source");
        if ("dashboard".equals(source)) {
            res.sendRedirect("booking?action=list&tab=reviews&success=Review submitted! It will appear after moderation.");
        } else {
            res.sendRedirect("review?action=list&success=Review submitted! It will appear after moderation.");
        }
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse res) throws IOException {
        String id = req.getParameter("id");
        String line = FileHandler.findById(REV_FILE, id);
        if (line != null) {
            Review r = Review.fromFileString(line);
            if (r != null) {
                r.setRating(Integer.parseInt(req.getParameter("rating")));
                r.setComment(req.getParameter("comment"));
                r.setStatus(Review.STATUS_PENDING); 
                FileHandler.updateById(REV_FILE, id, r.toFileString());
            }
        }
        
        String source = req.getParameter("source");
        if ("dashboard".equals(source)) {
            res.sendRedirect("booking?action=list&tab=reviews&success=Changes saved successfully!");
        } else {
            res.sendRedirect("review?action=list&success=Changes saved successfully!");
        }
    }

    private void handleModerate(HttpServletRequest req, HttpServletResponse res) throws IOException {
        String id = req.getParameter("id");
        String status = req.getParameter("status");
        String line = FileHandler.findById(REV_FILE, id);
        if (line != null) {
            Review r = Review.fromFileString(line);
            if (r != null) {
                r.setStatus(status);
                FileHandler.updateById(REV_FILE, id, r.toFileString());
            }
        }
        res.sendRedirect("review?action=list");
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse res) throws IOException {
        String id = req.getParameter("id");
        FileHandler.deleteById(REV_FILE, id);
        
        String source = req.getParameter("source");
        if ("dashboard".equals(source)) {
            res.sendRedirect("booking?action=list&tab=reviews&success=Review has been deleted.");
        } else {
            res.sendRedirect("review?action=list&success=Review has been deleted.");
        }
    }
}
