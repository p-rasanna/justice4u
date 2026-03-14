package com.j4u.servlet;

import com.j4u.dao.InternDashboardDAO;

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

@WebServlet("/InternDashboardServlet")
public class InternDashboardServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(InternDashboardServlet.class.getName());
    private final InternDashboardDAO dao = new InternDashboardDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("iname") == null) {
            response.sendRedirect("internlogin.html");
            return;
        }

        String username = (String) session.getAttribute("iname");

        try {
            int assignedCasesCount = dao.getAssignedCasesCount(username);
            int pendingTasksCount = dao.getPendingTasksCount(username);
            List<Map<String, Object>> assignedCasesList = dao.getAssignedCasesList(username);
            List<Map<String, Object>> pendingTasksList = dao.getPendingTasksList(username);
            List<Map<String, Object>> uploadCaseList = dao.getActiveCasesForUpload(username);

            request.setAttribute("assignedCasesCount", assignedCasesCount);
            request.setAttribute("pendingTasksCount", pendingTasksCount);
            request.setAttribute("draftsUploadedCount", 0); // Static placeholder
            request.setAttribute("unreadMessagesCount", 0); // Static placeholder

            request.setAttribute("assignedCasesList", assignedCasesList);
            request.setAttribute("hasCases", !assignedCasesList.isEmpty());

            request.setAttribute("pendingTasksList", pendingTasksList);
            request.setAttribute("hasTasks", !pendingTasksList.isEmpty());

            request.setAttribute("uploadCaseList", uploadCaseList);

            request.getRequestDispatcher("/interndashboard.jsp").forward(request, response);

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error in InternDashboardServlet", e);
            response.sendRedirect("error.jsp");
        }
    }
}
