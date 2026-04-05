package com.j4u.servlet;
import com.j4u.dao.CaseDAO;
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
@WebServlet("/ClientDashboard")
public class ClientDashboardServlet extends HttpServlet {
  private static final Logger LOGGER = Logger.getLogger(ClientDashboardServlet.class.getName());
  private final CaseDAO caseDAO = new CaseDAO();
  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    HttpSession session = request.getSession(false);
    String email = (String) session.getAttribute("cemail");
    String username = (String) session.getAttribute("cname");
    if (email == null && username != null && username.contains("@")) {
      email = username;
    }
    if (email == null) {
      response.sendRedirect("auth/cust_login.html?msg=Session expired");
      return;
    }
    try {
      List<Map<String, Object>> caseList = caseDAO.getCasesByClientEmail(email);
      request.setAttribute("caseList", caseList);
      request.getRequestDispatcher("/client/client_viewcases.jsp").forward(request, response);
    } catch (SQLException e) {
      LOGGER.log(Level.SEVERE, "Database error acquiring cases for client dashboard", e);
      throw new ServletException("Unable to retrieve dashboard data securely due to server exception.", e);
    }
  }
}