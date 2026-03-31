package com.j4u.servlet;

import com.j4u.dao.InternDAO;
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

@WebServlet("/ViewInterns")
public class ViewInternsServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(ViewInternsServlet.class.getName());
    private final InternDAO internDAO = new InternDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("aname") == null) {
            response.sendRedirect("auth/Login.html");
            return;
        }

        try {
            List<Map<String, Object>> pendingInterns = internDAO.getPendingInterns();
            request.setAttribute("pendingInterns", pendingInterns);
            request.getRequestDispatcher("/admin/viewinterns.jsp").forward(request, response);

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error acquiring interns for admin review", e);
            throw new ServletException("Unable to retrieve interns securely.", e);
        }
    }
}
