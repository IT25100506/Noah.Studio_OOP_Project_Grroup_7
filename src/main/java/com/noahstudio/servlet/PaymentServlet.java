package com.noahstudio.servlet;

import com.noahstudio.model.*;
import com.noahstudio.util.FileHandler;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.time.LocalDate;
import java.util.*;

/**
 * PaymentServlet — manages studio finances using OOP Inheritance and Polymorphism.
 * Actions: list | create | update | delete | invoice
 */
public class PaymentServlet extends HttpServlet {

    private static final String PAY_FILE = "payments.txt";

    @Override
    public void init() throws ServletException {
        String dataPath = getServletContext().getRealPath("/") + "data";
        FileHandler.init(dataPath);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null) action = "list";
        
        switch (action) {
            case "delete":  handleDelete(req, res); break;
            case "invoice": handleInvoice(req, res); break;
            default:        handleList(req, res);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        
        if ("create".equals(action)) handleCreate(req, res);
        else if ("update".equals(action)) handleUpdate(req, res);
        else res.sendRedirect(req.getContextPath() + "/payment?action=list");
    }

    // ── List Payments (Role Based) ──────────────────────────────────────────
    private void handleList(HttpServletRequest req, HttpServletResponse res)
            throws IOException, ServletException {
        HttpSession session = req.getSession(false);
        if (session == null) { res.sendRedirect(req.getContextPath() + "/login.jsp"); return; }
        
        String role = (String) session.getAttribute("role");
        String uid  = (String) session.getAttribute("userId");
        
        List<Payment> payments = new ArrayList<>();
        for (String line : FileHandler.readLines(PAY_FILE)) {
            Payment p = Payment.fromFileString(line);
            if (p != null) {
                if ("admin".equals(role) || p.getClientId().equals(uid)) {
                    payments.add(p);
                }
            }
        }
        
        req.setAttribute("payments", payments);
        if ("admin".equals(role)) {
            req.getRequestDispatcher("/payment-management.jsp").forward(req, res);
        } else {
            req.getRequestDispatcher("/payments.jsp").forward(req, res);
        }
    }

    // ── Create Payment (Inheritance Applied) ────────────────────────────────
    private void handleCreate(HttpServletRequest req, HttpServletResponse res)
            throws IOException, ServletException {
        HttpSession session = req.getSession(false);
        if (session == null) { res.sendRedirect(req.getContextPath() + "/login.jsp"); return; }

        String bookingId  = FileHandler.sanitize(req.getParameter("bookingId"));
        String amountStr  = req.getParameter("amount");
        String method     = FileHandler.sanitize(req.getParameter("method"));
        String notes      = FileHandler.sanitize(req.getParameter("notes"));
        String type       = req.getParameter("paymentType"); // Full or Partial
        
        String clientId   = (String) session.getAttribute("userId");
        String clientName = (String) session.getAttribute("fullName");

        if (FileHandler.isNullOrEmpty(bookingId) || FileHandler.isNullOrEmpty(amountStr)) {
            req.setAttribute("error", "Booking ID and amount are required.");
            handleList(req, res); return;
        }

        double amount = 0;
        try { amount = Double.parseDouble(amountStr); } catch (Exception e) {}

        String id = FileHandler.generateId("PAY", PAY_FILE);
        Payment pay;
        
        if ("Full".equalsIgnoreCase(type)) {
            pay = new FullPayment(id, bookingId, clientId, clientName, amount, method, 
                                  Payment.STATUS_PENDING, LocalDate.now().toString(), notes, "-");
        } else {
            double balance = 0;
            String balanceStr = req.getParameter("balanceDue");
            if (balanceStr != null) try { balance = Double.parseDouble(balanceStr); } catch(Exception e) {}
            
            pay = new PartialPayment(id, bookingId, clientId, clientName, amount, method, 
                                     Payment.STATUS_PENDING, LocalDate.now().toString(), notes, "-", balance);
        }

        FileHandler.appendLine(PAY_FILE, pay.toFileString());
        
        String redirect = req.getParameter("redirect");
        String finalRedirect = (redirect != null ? redirect : "payment?action=list");
        if (finalRedirect.contains("?")) finalRedirect += "&success=Payment+recorded+successfully!";
        else finalRedirect += "?success=Payment+recorded+successfully!";
        
        res.sendRedirect(req.getContextPath() + "/" + finalRedirect);
    }

    // ── Update Status ────────────────────────────────────────────────────────
    private void handleUpdate(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("role"))) {
            res.sendRedirect(req.getContextPath() + "/login.jsp"); return;
        }

        String id = req.getParameter("id");
        String status = req.getParameter("status");
        String line = FileHandler.findById(PAY_FILE, id);
        
        if (line != null) {
            Payment pay = Payment.fromFileString(line);
            if (pay != null) {
                if (status != null) {
                    pay.setStatus(status);
                    if (Payment.STATUS_PAID.equals(status)) pay.setPaidAt(LocalDate.now().toString());
                } else {
                    // Full Edit
                    try { pay.setAmount(Double.parseDouble(req.getParameter("amount"))); } catch(Exception e) {}
                    pay.setMethod(req.getParameter("method"));
                    pay.setNotes(req.getParameter("notes"));
                    pay.setStatus(req.getParameter("status_full"));
                    if (pay instanceof PartialPayment) {
                        try { ((PartialPayment)pay).setBalanceDue(Double.parseDouble(req.getParameter("balanceDue"))); } catch(Exception e) {}
                    }
                }
                FileHandler.updateById(PAY_FILE, id, pay.toFileString());
            }
        }
        res.sendRedirect(req.getContextPath() + "/payment?action=list");
    }

    // ── Delete ───────────────────────────────────────────────────────────────
    private void handleDelete(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("role"))) {
            res.sendRedirect(req.getContextPath() + "/login.jsp"); return;
        }
        FileHandler.deleteById(PAY_FILE, req.getParameter("id"));
        res.sendRedirect(req.getContextPath() + "/payment?action=list");
    }

    // ── Invoice View (Polymorphism in Action) ───────────────────────────────
    private void handleInvoice(HttpServletRequest req, HttpServletResponse res)
            throws IOException, ServletException {
        String id = req.getParameter("id");
        String line = FileHandler.findById(PAY_FILE, id);
        if (line != null) {
            Payment pay = Payment.fromFileString(line);
            req.setAttribute("payment", pay);
            req.getRequestDispatcher("/invoice-view.jsp").forward(req, res);
        } else {
            res.sendRedirect(req.getContextPath() + "/payment?action=list");
        }
    }
}
