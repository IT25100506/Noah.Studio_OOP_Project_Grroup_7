package com.noahstudio.servlet;

import com.noahstudio.util.FileHandler;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.time.LocalDate;

/**
 * ContactServlet — saves contact form messages to contacts.txt.
 * URL: /contact
 */
public class ContactServlet extends HttpServlet {

    private static final String CONTACT_FILE = "contacts.txt";

    @Override
    public void init() throws ServletException {
        String dataPath = getServletContext().getRealPath("/") + "data";
        FileHandler.init(dataPath);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        String name    = FileHandler.sanitize(req.getParameter("name"));
        String email   = FileHandler.sanitize(req.getParameter("email"));
        String message = FileHandler.sanitize(req.getParameter("message"));

        if (FileHandler.isNullOrEmpty(name) || !FileHandler.isValidEmail(email)
                || FileHandler.isNullOrEmpty(message)) {
            res.sendRedirect("index.jsp?error=Please fill all fields with valid data#contact");
            return;
        }

        // Store: date|name|email|message
        String record = LocalDate.now() + "|" + name + "|" + email + "|" + message;
        FileHandler.appendLine(CONTACT_FILE, record);

        res.sendRedirect("index.jsp?success=Message sent! We will contact you soon#contact");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        res.sendRedirect("index.jsp#contact");
    }
}
