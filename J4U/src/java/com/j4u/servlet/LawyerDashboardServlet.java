package com.j4u.servlet;

import com.j4u.dao.LawyerDashboardDAO;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/LawyerDashboardServlet")
public class LawyerDashboardServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(LawyerDashboardServlet.class.getName());
    private final LawyerDashboardDAO dao = new LawyerDashboardDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("lname") == null) {
            response.sendRedirect("auth/Lawyer_login.html");
            return;
        }

        String username = (String) session.getAttribute("lname");

        try {
            int lawyerId = dao.getLawyerIdByEmail(username);

            if (lawyerId > 0) {
                List<Map<String, Object>> pendingRequests = dao.getPendingRequests(lawyerId);
                List<Map<String, Object>> assignedClients = dao.getAssignedClients(lawyerId, 5);
                List<Map<String, Object>> assignedInterns = dao.getAssignedInterns(lawyerId);
                List<Map<String, Object>> pendingInternWork = dao.getPendingInternWork(lawyerId);

                request.setAttribute("pendingRequests", pendingRequests);
                request.setAttribute("hasPending", !pendingRequests.isEmpty());

                request.setAttribute("assignedClients", assignedClients);
                request.setAttribute("hasClients", !assignedClients.isEmpty());

                request.setAttribute("assignedInterns", assignedInterns);
                request.setAttribute("pendingInternWork", pendingInternWork);

                // Dynamic metrics
                request.setAttribute("activeMattersCount", assignedClients.size());
                request.setAttribute("pendingRepliesCount", pendingRequests.size());
                request.setAttribute("hearingsTodayCount", pendingInternWork.size()); // Just as a placeholder for now
            } else {
                request.setAttribute("hasPending", false);
                request.setAttribute("hasClients", false);
                request.setAttribute("assignedInterns", new java.util.ArrayList<>());
                request.setAttribute("pendingInternWork", new java.util.ArrayList<>());
            }

            request.getRequestDispatcher("/lawyer/Lawyerdashboard.jsp").forward(request, response);

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in LawyerDashboardServlet", e);
            String errorMsg = e.getMessage() != null ? e.getMessage() : e.toString();
            response.sendRedirect("error.jsp?error=" + java.net.URLEncoder.encode(errorMsg, "UTF-8"));
        }
    }
}
