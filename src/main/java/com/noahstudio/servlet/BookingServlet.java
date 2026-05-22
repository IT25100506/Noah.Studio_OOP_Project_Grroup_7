package com.noahstudio.servlet;

import com.noahstudio.model.Booking;
import com.noahstudio.util.FileHandler;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.time.LocalDate;
import java.util.*;

public class BookingServlet extends HttpServlet {
    private static final String BOOKINGS_FILE = "bookings.txt";

    @Override
    public void init() throws ServletException {
        FileHandler.init(getServletContext().getRealPath("/") + "data");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null) action = "list";
        switch (action) {
            case "list":   handleList(req, res);   break;
            case "view":   handleView(req, res);   break;
            case "delete": handleDelete(req, res); break;
            default:       req.getRequestDispatcher("/booking.jsp").forward(req, res);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        if ("create".equals(action)) handleCreate(req, res);
        else if ("update".equals(action)) handleUpdate(req, res);
        else if ("cancel".equals(action)) handleCancel(req, res);
        else res.sendRedirect(req.getContextPath() + "/booking.jsp");
    }

    private void handleCreate(HttpServletRequest req, HttpServletResponse res) throws IOException, ServletException {
        HttpSession session = req.getSession(false);
        if (session == null) { res.sendRedirect(req.getContextPath() + "/login.jsp?redirect=booking%3Faction%3Dlist"); return; }
        String clientId = req.getParameter("clientId");
        String clientName = null;
        
        if (clientId != null && !clientId.isEmpty()) {
            // Admin manual entry
            String uLine = FileHandler.findById("users.txt", clientId);
            if (uLine != null) {
                com.noahstudio.model.User u = com.noahstudio.model.User.fromFileString(uLine);
                if (u != null) clientName = u.getFullName();
            }
        } else {
            // Standard client entry
            clientId = (String) session.getAttribute("userId");
            clientName = (String) session.getAttribute("fullName");
        }
        
        String packageId = req.getParameter("packageId");
        String packageName = req.getParameter("packageName");
        String eventDate = req.getParameter("eventDate");
        String eventTime = req.getParameter("eventTime");
        String eventLocation = req.getParameter("eventLocation");
        String eventType = req.getParameter("eventType");
        String clientContact = req.getParameter("clientContact");
        
        if (FileHandler.isNullOrEmpty(eventDate) || FileHandler.isNullOrEmpty(eventLocation)) {
            req.setAttribute("error", "Fill all required fields.");
            handleList(req, res); return;
        }
        String id = FileHandler.generateId("BKG", BOOKINGS_FILE);
        Booking b = new Booking(id, clientId, clientName, packageId, packageName, eventDate, eventTime, eventLocation, eventType, clientContact, "Pending", "", LocalDate.now().toString(), "-");
        
        // Generate human-readable reference number
        String refNum = "BK-" + LocalDate.now().getYear() + "-" + String.format("%04d", new Random().nextInt(10000));
        if (id.startsWith("BKG")) {
            try {
                int num = Integer.parseInt(id.substring(3));
                refNum = "BK-" + LocalDate.now().getYear() + "-" + String.format("%04d", num);
            } catch (Exception ignored) {}
        }
        b.setReferenceNumber(refNum);
        
        FileHandler.appendLine(BOOKINGS_FILE, b.toFileString());
        
        String redirect = req.getParameter("redirect");
        if (redirect != null && !redirect.isEmpty()) {
            res.sendRedirect(req.getContextPath() + "/" + redirect);
        } else {
            HttpSession sess = req.getSession(false);
            if (sess != null && "admin".equals(sess.getAttribute("role"))) {
                res.sendRedirect(req.getContextPath() + "/booking-management.jsp");
            } else {
                res.sendRedirect(req.getContextPath() + "/booking?action=list");
            }
        }
    }

    private void handleList(HttpServletRequest req, HttpServletResponse res) throws IOException, ServletException {
        HttpSession session = req.getSession(false);
        if (session == null) { res.sendRedirect(req.getContextPath() + "/login.jsp?redirect=booking%3Faction%3Dlist"); return; }
        String role = (String) session.getAttribute("role");
        String uid = (String) session.getAttribute("userId");
        List<Booking> bookings = new ArrayList<>();
        for (String line : FileHandler.readLines(BOOKINGS_FILE)) {
            Booking b = Booking.fromFileString(line);
            if (b != null && ("admin".equals(role) || b.getClientId().equals(uid))) bookings.add(b);
        }
        req.setAttribute("bookings", bookings);
        if ("admin".equals(role)) {
            res.sendRedirect(req.getContextPath() + "/booking-management.jsp");
        } else {
            req.getRequestDispatcher("/mydashboard.jsp").forward(req, res);
        }
    }

    private void handleView(HttpServletRequest req, HttpServletResponse res) throws IOException, ServletException {
        String line = FileHandler.findById(BOOKINGS_FILE, req.getParameter("id"));
        if (line != null) req.setAttribute("booking", Booking.fromFileString(line));
        req.getRequestDispatcher("/booking.jsp").forward(req, res);
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse res) throws IOException {
        String id = req.getParameter("id");
        String line = FileHandler.findById(BOOKINGS_FILE, id);
        if (line != null) {
            Booking b = Booking.fromFileString(line);
            if (b != null) {
                // Common fields
                if (req.getParameter("status") != null) b.setStatus(req.getParameter("status"));
                if (req.getParameter("staffId") != null) b.setStaffId(req.getParameter("staffId"));
                
                // Detailed fields (from edit modal)
                if (req.getParameter("packageId") != null) b.setServicePackageId(req.getParameter("packageId"));
                if (req.getParameter("packageName") != null) b.setServicePackageName(req.getParameter("packageName"));
                if (req.getParameter("eventDate") != null) b.setEventDate(req.getParameter("eventDate"));
                if (req.getParameter("eventTime") != null) b.setEventTime(req.getParameter("eventTime"));
                if (req.getParameter("eventLocation") != null) b.setEventLocation(req.getParameter("eventLocation"));
                if (req.getParameter("eventType") != null) b.setEventType(req.getParameter("eventType"));
                if (req.getParameter("clientContact") != null) b.setClientContact(req.getParameter("clientContact"));
                
                FileHandler.updateById(BOOKINGS_FILE, id, b.toFileString());
            }
        }
        
        String redirect = req.getParameter("redirect");
        if (redirect != null && !redirect.isEmpty()) {
            res.sendRedirect(req.getContextPath() + "/" + redirect);
        } else {
            HttpSession sess = req.getSession(false);
            if (sess != null && "admin".equals(sess.getAttribute("role"))) {
                res.sendRedirect(req.getContextPath() + "/booking-management.jsp");
            } else {
                res.sendRedirect(req.getContextPath() + "/booking?action=list");
            }
        }
    }

    private void handleCancel(HttpServletRequest req, HttpServletResponse res) throws IOException {
        String id = req.getParameter("id");
        String reason = req.getParameter("cancellationReason");
        String line = FileHandler.findById(BOOKINGS_FILE, id);
        
        if (line != null) {
            Booking b = Booking.fromFileString(line);
            if (b != null) {
                b.setStatus(Booking.STATUS_CANCELLED);
                if (reason != null && !reason.trim().isEmpty()) {
                    b.setCancellationReason(reason.trim());
                }
                
                try {
                    java.time.LocalDate eventDate = java.time.LocalDate.parse(b.getEventDate());
                    java.time.LocalDate today = java.time.LocalDate.now();
                    long daysBetween = java.time.temporal.ChronoUnit.DAYS.between(today, eventDate);
                    
                    if (daysBetween >= 0 && daysBetween <= 3) {
                        double pkgPrice = 0;
                        String pkgLine = FileHandler.findById("packages.txt", b.getServicePackageId());
                        if (pkgLine != null) {
                            com.noahstudio.model.ServicePackage sp = com.noahstudio.model.ServicePackage.fromFileString(pkgLine);
                            if (sp != null) pkgPrice = sp.getPrice();
                        }
                        
                        if (pkgPrice > 0) {
                            double fineAmount = pkgPrice * 0.20;
                            String payId = FileHandler.generateId("PAY", "payments.txt");
                            com.noahstudio.model.Payment finePay = new com.noahstudio.model.FullPayment(
                                payId, b.getId(), b.getClientId(), b.getClientName(), fineAmount, 
                                "Pending", com.noahstudio.model.Payment.STATUS_PENDING, 
                                "-", "Late cancellation fine (20% of LKR " + String.format("%.0f", pkgPrice) + ")", "-"
                            );
                            FileHandler.appendLine("payments.txt", finePay.toFileString());
                        }
                    }
                } catch (Exception e) {}
                
                FileHandler.updateById(BOOKINGS_FILE, id, b.toFileString());
            }
        }
        
        String redirect = req.getParameter("redirect");
        if (redirect != null && !redirect.isEmpty()) {
            res.sendRedirect(req.getContextPath() + "/" + redirect);
        } else {
            res.sendRedirect(req.getContextPath() + "/booking?action=list");
        }
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse res) throws IOException {
        FileHandler.deleteById(BOOKINGS_FILE, req.getParameter("id"));
        String redirect = req.getParameter("redirect");
        if (redirect != null && !redirect.isEmpty()) {
            res.sendRedirect(req.getContextPath() + "/" + redirect);
        } else {
            HttpSession sess = req.getSession(false);
            if (sess != null && "admin".equals(sess.getAttribute("role"))) {
                res.sendRedirect(req.getContextPath() + "/booking-management.jsp");
            } else {
                res.sendRedirect(req.getContextPath() + "/booking?action=list");
            }
        }
    }
}
