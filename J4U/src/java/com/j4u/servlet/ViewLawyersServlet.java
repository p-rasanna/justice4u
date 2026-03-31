package com.j4u.servlet;

import com.j4u.dao.LawyerDAO;
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

@WebServlet("/ViewLawyers")
public class ViewLawyersServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(ViewLawyersServlet.class.getName());
    private final LawyerDAO lawyerDAO = new LawyerDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("aname") == null) {
            response.sendRedirect("auth/Login.html");
            return;
        }

        try {
            List<Map<String, Object>> pendingLawyers = lawyerDAO.getPendingLawyers();
            request.setAttribute("pendingLawyers", pendingLawyers);
            request.getRequestDispatcher("/admin/viewlawyers.jsp").forward(request, response);

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error acquiring lawyers for admin review", e);
            throw new ServletException("Unable to retrieve lawyers securely.", e);
        }
    }
}
