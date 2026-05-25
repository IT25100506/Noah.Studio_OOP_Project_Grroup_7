package com.noahstudio.servlet;

import com.noahstudio.model.*;
import com.noahstudio.util.FileHandler;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.util.*;

/**
 * UserServlet — handles registration, login, logout, and user CRUD.
 * URL: /user
 * Actions (via 'action' parameter):
 *   register  — POST
 *   login     — POST
 *   logout    — GET
 *   list      — GET  (admin only)
 *   delete    — POST (admin only)
 *   update    — POST
 */
public class UserServlet extends HttpServlet {

    private static final String USERS_FILE = "users.txt";

    @Override
    public void init() throws ServletException {
        // Initialise FileHandler with the real data directory
        String dataPath = getServletContext().getRealPath("/") + "data";
        FileHandler.init(dataPath);
        // Seed default admin if file is empty
        try {
            if (FileHandler.readLines(USERS_FILE).isEmpty()) {
                seedDefaultAdmin();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    // ── GET handler ───────────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        if (action == null) action = "";

        switch (action) {
            case "logout":
                req.getSession().invalidate();
                res.sendRedirect(req.getContextPath() + "/index.jsp");
                break;
            case "list":
                handleList(req, res);
                break;
            case "checkDuplicate":
                handleCheckDuplicate(req, res);
                break;
            default:
                res.sendRedirect(req.getContextPath() + "/login.jsp");
        }
    }

    // ── POST handler ──────────────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        if (action == null) action = "";

        switch (action) {
            case "register":           handleRegister(req, res);           break;
            case "login":              handleLogin(req, res);              break;
            case "delete":             handleDelete(req, res);             break;
            case "updateProfile":      handleUpdateProfile(req, res);      break;
            case "adminUpdateUser":    handleAdminUpdateUser(req, res);    break;
            case "updateAvailability": handleUpdateAvailability(req, res); break;
            case "updateSpecialization": handleUpdateSpecialization(req, res); break;
            default:                   res.sendRedirect(req.getContextPath() + "/login.jsp");
        }
    }

    // ── Register ─────────────────────────────────────────────────────────────
    private void handleRegister(HttpServletRequest req, HttpServletResponse res)
            throws IOException, ServletException {

        String username = FileHandler.sanitize(req.getParameter("username"));
        String password = req.getParameter("password");
        String email    = FileHandler.sanitize(req.getParameter("email"));
        String phone    = FileHandler.sanitize(req.getParameter("phone"));
        String role     = FileHandler.sanitize(req.getParameter("role"));
        String fullName = FileHandler.sanitize(req.getParameter("fullName"));

        // Validation
        if (FileHandler.isNullOrEmpty(username) || FileHandler.isNullOrEmpty(password)
                || !FileHandler.isValidEmail(email)) {
            req.setAttribute("error", "Please fill all required fields with valid data.");
            req.getRequestDispatcher("/register.jsp").forward(req, res);
            return;
        }

        // Check username uniqueness
        for (String line : FileHandler.readLines(USERS_FILE)) {
            User existing = User.fromFileString(line);
            if (existing != null && existing.getUsername().equalsIgnoreCase(username)) {
                req.setAttribute("error", "Username already taken. Please choose another.");
                req.getRequestDispatcher("/register.jsp").forward(req, res);
                return;
            }
        }

        // Allowed roles for self-registration
        if (!Arrays.asList("client","photographer","videographer").contains(role)) {
            role = "client";
        }

        String id = FileHandler.generateId("USR", USERS_FILE);
        String spec = FileHandler.sanitize(req.getParameter("specialization"));
        String avail = FileHandler.sanitize(req.getParameter("availability"));
        if (spec == null) spec = "-";
        if (avail == null) avail = "Available";

        User user;
        switch (role) {
            case "photographer": user = new Photographer(id, username, password, email, phone, fullName, spec, avail); break;
            case "videographer": user = new Videographer(id, username, password, email, phone, fullName, spec, avail); break;
            default:             user = new Client(id, username, password, email, phone, fullName);
        }

        FileHandler.appendLine(USERS_FILE, user.toFileString());
        
        String isAdminSource = req.getParameter("isAdminSource");
        String redirect = req.getParameter("redirect");
        
        if ("true".equals(isAdminSource)) {
            String target = (redirect != null) ? redirect : "admin-dashboard.jsp?tab=users";
            res.sendRedirect(req.getContextPath() + "/" + target);
        } else {
            req.setAttribute("success", "Registration successful! Please log in.");
            String regRedirect = req.getParameter("redirect");
            if (regRedirect != null && !regRedirect.isEmpty()) {
                res.sendRedirect(req.getContextPath() + "/login.jsp?redirect=" + java.net.URLEncoder.encode(regRedirect, "UTF-8") + "&registered=true");
            } else {
                req.getRequestDispatcher("/login.jsp").forward(req, res);
            }
        }
    }

    // ── Login ─────────────────────────────────────────────────────────────────
    private void handleLogin(HttpServletRequest req, HttpServletResponse res)
            throws IOException, ServletException {

        String username = req.getParameter("username");
        String password = req.getParameter("password");

        for (String line : FileHandler.readLines(USERS_FILE)) {
            User user = User.fromFileString(line);
            if (user != null
                    && user.getUsername().equalsIgnoreCase(username)
                    && user.getPassword().equals(password)) {
                
                if ("Suspended".equalsIgnoreCase(user.getAccountStatus())) {
                    req.setAttribute("error", "Your account has been suspended. Please contact the admin.");
                    req.getRequestDispatcher("/login.jsp").forward(req, res);
                    return;
                }

                // Update last login
                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("MMM dd, yyyy 'at' hh:mm a");
                user.setLastLogin(sdf.format(new java.util.Date()));
                FileHandler.updateById(USERS_FILE, user.getId(), user.toFileString());

                // Valid — create session
                HttpSession session = req.getSession(true);
                session.setAttribute("user",     user);
                session.setAttribute("userId",   user.getId());
                session.setAttribute("username", user.getUsername());
                session.setAttribute("role",     user.getRole());
                session.setAttribute("fullName", user.getFullName());
                
                // Check for redirect parameter (e.g., from "Book Now" button)
                String redirectParam = req.getParameter("redirect");
                
                // Explicit role-based redirection
                String dashboard;
                if ("admin".equalsIgnoreCase(user.getRole())) dashboard = "admin-dashboard.jsp";
                else if ("photographer".equalsIgnoreCase(user.getRole())) dashboard = "photographer-dashboard.jsp";
                else if ("videographer".equalsIgnoreCase(user.getRole())) dashboard = "videographer-dashboard.jsp";
                else if (redirectParam != null && !redirectParam.isEmpty()) dashboard = redirectParam; // Honor redirect for clients
                else dashboard = "booking?action=list"; // Default: show their bookings
                
                res.sendRedirect(req.getContextPath() + "/" + dashboard);
                return;
            }
        }

        req.setAttribute("error", "Invalid username or password.");
        req.getRequestDispatcher("/login.jsp").forward(req, res);
    }

    // ── List users (admin) ────────────────────────────────────────────────────
    private void handleList(HttpServletRequest req, HttpServletResponse res)
            throws IOException, ServletException {

        HttpSession session = req.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("role"))) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        List<User> users = new ArrayList<>();
        for (String line : FileHandler.readLines(USERS_FILE)) {
            User u = User.fromFileString(line);
            if (u != null) users.add(u);
        }
        req.setAttribute("users", users);
        req.getRequestDispatcher("/admin-dashboard.jsp").forward(req, res);
    }

    // ── Delete user (admin) ───────────────────────────────────────────────────
    private void handleDelete(HttpServletRequest req, HttpServletResponse res)
            throws IOException {

        HttpSession session = req.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("role"))) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        String id = req.getParameter("id");
        String redirect = req.getParameter("redirect");
        FileHandler.deleteById(USERS_FILE, id);
        
        String target = (redirect != null) ? redirect : "admin-dashboard.jsp?tab=users";
        res.sendRedirect(req.getContextPath() + "/" + target);
    }

    // ── Update Profile ───────────────────────────────────────────────────────
    private void handleUpdateProfile(HttpServletRequest req, HttpServletResponse res)
            throws IOException, ServletException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        String id = user.getId();
        
        String email    = FileHandler.sanitize(req.getParameter("email"));
        String phone    = FileHandler.sanitize(req.getParameter("phone"));
        String fullName = FileHandler.sanitize(req.getParameter("fullName"));
        String password = req.getParameter("password");

        if (!FileHandler.isNullOrEmpty(email))    user.setEmail(email);
        if (!FileHandler.isNullOrEmpty(phone))    user.setPhone(phone);
        if (!FileHandler.isNullOrEmpty(fullName)) user.setFullName(fullName);
        if (!FileHandler.isNullOrEmpty(password)) user.setPassword(password);

        FileHandler.updateById(USERS_FILE, id, user.toFileString());
        session.setAttribute("user", user); // Update session object
        session.setAttribute("fullName", user.getFullName());
        
        req.setAttribute("success", "Profile updated successfully.");
        req.getRequestDispatcher("/profile.jsp").forward(req, res);
    }

    // ── Update Availability (Staff) ──────────────────────────────────────────
    private void handleUpdateAvailability(HttpServletRequest req, HttpServletResponse res)
            throws IOException, ServletException {

        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("user");
        String status = req.getParameter("status");

        if (user != null && !FileHandler.isNullOrEmpty(status)) {
            user.setAvailability(status);
            FileHandler.updateById(USERS_FILE, user.getId(), user.toFileString());
            session.setAttribute("user", user);
            req.setAttribute("success", "Status updated to " + status);
        }
        req.getRequestDispatcher("/availability.jsp").forward(req, res);
    }

    // ── Update Specialization (Staff) ────────────────────────────────────────
    private void handleUpdateSpecialization(HttpServletRequest req, HttpServletResponse res)
            throws IOException, ServletException {

        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("user");
        String spec = FileHandler.sanitize(req.getParameter("specialization"));

        if (user != null && !FileHandler.isNullOrEmpty(spec)) {
            user.setSpecialization(spec);
            FileHandler.updateById(USERS_FILE, user.getId(), user.toFileString());
            session.setAttribute("user", user);
            req.setAttribute("success", "Expertise updated successfully.");
        }
        req.getRequestDispatcher("/availability.jsp").forward(req, res);
    }

    // ── Admin Update User ────────────────────────────────────────────────────
    private void handleAdminUpdateUser(HttpServletRequest req, HttpServletResponse res)
            throws IOException, ServletException {

        HttpSession session = req.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("role"))) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String id       = req.getParameter("id");
        String email    = FileHandler.sanitize(req.getParameter("email"));
        String phone    = FileHandler.sanitize(req.getParameter("phone"));
        String fullName = FileHandler.sanitize(req.getParameter("fullName"));
        String role           = FileHandler.sanitize(req.getParameter("role"));
        String password       = req.getParameter("password");
        String specialization = FileHandler.sanitize(req.getParameter("specialization"));
        String availability   = FileHandler.sanitize(req.getParameter("availability"));

        String existing = FileHandler.findById(USERS_FILE, id);
        if (existing != null) {
            User user = User.fromFileString(existing);
            if (user != null) {
                if (!FileHandler.isNullOrEmpty(email))    user.setEmail(email);
                if (!FileHandler.isNullOrEmpty(phone))    user.setPhone(phone);
                if (!FileHandler.isNullOrEmpty(fullName)) user.setFullName(fullName);
                if (!FileHandler.isNullOrEmpty(role))     user.setRole(role);
                if (!FileHandler.isNullOrEmpty(password)) user.setPassword(password);
                if (specialization != null) user.setSpecialization(specialization);
                if (availability != null)   user.setAvailability(availability);
                String accountStatus = req.getParameter("accountStatus");
                if (accountStatus != null) user.setAccountStatus(accountStatus);
                
                FileHandler.updateById(USERS_FILE, id, user.toFileString());
            }
        }
        String redirect = req.getParameter("redirect");
        String target = (redirect != null) ? redirect : "admin-dashboard.jsp?tab=users";
        res.sendRedirect(req.getContextPath() + "/" + target);
    }

    // ── Seed default admin ────────────────────────────────────────────────────
    private void seedDefaultAdmin() throws IOException {
        Admin admin = new Admin("USR001", "admin", "admin123",
                                "admin@noahstudio.com", "0123456789", "System Admin");
        FileHandler.appendLine(USERS_FILE, admin.toFileString());
    }

    // ── Check Duplicate ───────────────────────────────────────────────────────
    private void handleCheckDuplicate(HttpServletRequest req, HttpServletResponse res) throws IOException {
        res.setContentType("application/json");
        res.setCharacterEncoding("UTF-8");
        PrintWriter out = res.getWriter();
        
        String username = req.getParameter("username");
        String email = req.getParameter("email");
        boolean exists = false;
        String message = "";
        
        for (String line : FileHandler.readLines(USERS_FILE)) {
            User u = User.fromFileString(line);
            if (u != null) {
                if (username != null && u.getUsername().equalsIgnoreCase(username)) {
                    exists = true;
                    message = "This username is already taken.";
                    break;
                }
                if (email != null && u.getEmail().equalsIgnoreCase(email)) {
                    exists = true;
                    message = "This email is already taken.";
                    break;
                }
            }
        }
        
        out.print("{\"exists\": " + exists + ", \"message\": \"" + message + "\"}");
        out.flush();
    }
}

// UserServlet handles Login, Logout, and Register actions
