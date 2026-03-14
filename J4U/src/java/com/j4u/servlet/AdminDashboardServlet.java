package com.j4u.servlet;

import com.j4u.dao.AdminDAO;
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

@WebServlet("/AdminDashboard")
public class AdminDashboardServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(AdminDashboardServlet.class.getName());
    private final AdminDAO adminDAO = new AdminDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("aname") == null) {
            response.sendRedirect("Login.html");
            return;
        }

        try {
            Map<String, Integer> metrics = adminDAO.getDashboardMetrics();
            List<Map<String, Object>> pendingClients = adminDAO.getPendingClients(5);

            request.setAttribute("metrics", metrics);
            request.setAttribute("pendingClients", pendingClients);

            request.getRequestDispatcher("/admindashboard.jsp").forward(request, response);

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error retrieving admin dashboard metrics", e);
            throw new ServletException("Unable to load the Command Center successfully.", e);
        }
    }
}
