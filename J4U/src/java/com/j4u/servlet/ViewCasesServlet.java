package com.j4u.servlet;

import com.j4u.dao.CaseManagementDAO;
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

@WebServlet("/ViewCases")
public class ViewCasesServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(ViewCasesServlet.class.getName());
    private final CaseManagementDAO caseDAO = new CaseManagementDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("aname") == null) {
            response.sendRedirect("auth/Login.html");
            return;
        }

        try {
            List<Map<String, Object>> unassignedCases = caseDAO.getUnassignedCases();
            request.setAttribute("unassignedCases", unassignedCases);
            request.getRequestDispatcher("/admin/viewcases.jsp").forward(request, response);

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error acquiring cases for admin view", e);
            throw new ServletException("Unable to retrieve cases securely due to server exception.", e);
        }
    }
}
