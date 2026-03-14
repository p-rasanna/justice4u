package com.j4u.servlet;

import com.j4u.dao.UserDAO;
import util.EmailUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/ViewCustomers")
public class ViewCustomersServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(ViewCustomersServlet.class.getName());
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("aname") == null) {
            response.sendRedirect("Login.html");
            return;
        }

        try {
            List<Map<String, Object>> customers = userDAO.getAllClients();
            request.setAttribute("customers", customers);
            request.getRequestDispatcher("/viewcustomers.jsp").forward(request, response);

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error retrieving clients", e);
            throw new ServletException("Unable to secure customer data list.", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("aname") == null) {
            response.sendRedirect("Login.html");
            return;
        }

        String action = request.getParameter("action");
        String idParam = request.getParameter("id");

        if (action == null || idParam == null) {
            request.setAttribute("actionMessage", "❌ Missing required parameters.");
            doGet(request, response);
            return;
        }

        try {
            int customerId = Integer.parseInt(idParam);
            Map<String, Object> client = userDAO.getClientById(customerId);

            if (client == null) {
                request.setAttribute("actionMessage", "❌ Customer not found with ID: " + customerId);
            } else {
                String customerName = (String) client.get("name");
                String customerEmail = (String) client.get("email");

                if ("approve".equals(action)) {
                    if (userDAO.updateVerificationStatus(customerId, "VERIFIED")) {
                        try {
                            EmailUtil.sendEmail(customerEmail, "Account Approved - Justice4U",
                                    "Dear " + customerName + ",\n\n" +
                                            "Congratulations! Your account has been approved and is now active.\n\n" +
                                            "You can now login to your account and access our services.\n\n" +
                                            "Login URL: http://localhost:8080/J4U/cust_login.html\n\n" +
                                            "Best regards,\n" +
                                            "Justice4U Team");
                            request.setAttribute("actionMessage",
                                    "✅ Customer " + customerName + " approved and email sent successfully!");
                        } catch (Exception e) {
                            request.setAttribute("actionMessage",
                                    "✅ Customer " + customerName + " approved, but email failed: " + e.getMessage());
                        }
                    }
                } else if ("reject".equals(action)) {
                    if (userDAO.updateVerificationStatus(customerId, "REJECTED")) {
                        try {
                            EmailUtil.sendEmail(customerEmail, "Account Registration Status - Justice4U",
                                    "Dear " + customerName + ",\n\n" +
                                            "We regret to inform you that your registration has been rejected after review.\n\n"
                                            +
                                            "If you believe this is an error or need clarification, please contact our support team.\n\n"
                                            +
                                            "Email: support@justice4u.com\n\n" +
                                            "Best regards,\n" +
                                            "Justice4U Team");
                            request.setAttribute("actionMessage",
                                    "❌ Customer " + customerName + " rejected and email sent successfully!");
                        } catch (Exception e) {
                            request.setAttribute("actionMessage",
                                    "❌ Customer " + customerName + " rejected, but email failed: " + e.getMessage());
                        }
                    }
                } else {
                    request.setAttribute("actionMessage", "❌ Invalid action type.");
                }
            }
        } catch (NumberFormatException e) {
            request.setAttribute("actionMessage", "❌ Invalid customer ID format.");
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error updating customer", e);
            request.setAttribute("actionMessage", "❌ Error processing request due to database failure.");
        }

        doGet(request, response);
    }
}
