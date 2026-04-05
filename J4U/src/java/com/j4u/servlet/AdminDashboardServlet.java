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
  @Override
  protected void doGet(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    HttpSession session = request.getSession(false);
    if (session == null || session.getAttribute("aname") == null) {
      response.sendRedirect(request.getContextPath() + "/auth/Login.jsp");
      return;
    }
    request.getRequestDispatcher("/admin/admindashboard.jsp").forward(request, response);
  }
}