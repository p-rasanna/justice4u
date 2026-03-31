package com.j4u;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String role = request.getParameter("role"); // e.g., "admin", "lawyer", "client"

        if (email == null || email.trim().isEmpty() ||
                password == null || password.trim().isEmpty() ||
                role == null || role.trim().isEmpty()) {
            response.sendRedirect("Login.html?error=missing_fields");
            return;
        }

        String loginPage = "auth/Login.jsp";
        if ("lawyer".equals(role)) {
            loginPage = "auth/Lawyer_login.html";
        } else if ("client".equals(role)) {
            loginPage = "auth/cust_login.html";
        } else if ("intern".equals(role)) {
            loginPage = "auth/internlogin.html";
        }

        if (!"admin".equals(role) && !email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
            response.sendRedirect(loginPage + "?error=Invalid email format");
            return;
        }

        if (password.length() < 3) {
            response.sendRedirect(loginPage + "?error=Password too short");
            return;
        }

        Connection con = null;
        PreparedStatement pst = null;
        ResultSet rs = null;

        try {
            con = DatabaseConfig.getConnection();
            String query = "";
            String tableName = "";
            String idColumn = "";
            String nameColumn = "";
            String redirectUrl = "";

            // Determine table and columns based on role
            // Admin Table Structure: email, pass (No ID or Name columns in basic schema)
            if ("admin".equals(role)) {
                query = "SELECT * FROM admin WHERE email = ?";
                redirectUrl = "AdminDashboard";
            }
            // Lawyer Table: lid, lname, email, pass, flag
            else if ("lawyer".equals(role)) {
                query = "SELECT lid, name, pass, flag FROM lawyer_reg WHERE email = ?";
                redirectUrl = "LawyerDashboardServlet";
            }
            // Client Table: cid, cname, email, pass, verification_status, profile_type
            else if ("client".equals(role)) {
                query = "SELECT cid, cname, pass, COALESCE(verification_status, 'PENDING') as verification_status, COALESCE(profile_type, 'manual') as profile_type FROM cust_reg WHERE email = ?";
                // Redirect URL will be decided dynamically after rs.next()
                redirectUrl = "clientdashboard_manual.jsp"; 
            }
            // Intern Table: internid, name, email, pass, flag
            else if ("intern".equals(role)) {
                query = "SELECT internid, name, pass, flag FROM intern WHERE email = ?";
                redirectUrl = "InternDashboardServlet";
            } else {
                response.sendRedirect(loginPage + "?error=invalid_role");
                return;
            }

            pst = con.prepareStatement(query);
            pst.setString(1, email);
            rs = pst.executeQuery();

            if (rs.next()) {
                String storedPass = rs.getString("pass");
                String normalizedProfileType = "manual";

                // Verify Password (Hash or Plain Text)
                if (PasswordUtil.verifyPassword(password, storedPass)) {

                    // Specific checks for flags/approval
                    if ("lawyer".equals(role) || "intern".equals(role)) {
                        int flag = rs.getInt("flag");
                        if (flag == 0) {
                            response.sendRedirect(loginPage + "?error=Account%20Pending%20Approval");
                            return;
                        } else if (flag == 2) {
                            response.sendRedirect(
                                    loginPage + "?error=Account%20Rejected.%20Please%20contact%20support.");
                            return;
                        }
                    } else if ("client".equals(role)) {
                        String verificationStatus = rs.getString("verification_status");
                        if (verificationStatus != null && verificationStatus.equalsIgnoreCase("REJECTED")) {
                            response.sendRedirect(
                                    loginPage + "?error=Account%20Rejected.%20Please%20contact%20support.");
                            return;
                        }
                        if (verificationStatus != null && verificationStatus.equalsIgnoreCase("PENDING")) {
                            response.sendRedirect(
                                    loginPage + "?error=Account%20Pending%20Admin%20Approval");
                            return;
                        }
                        
                        String cProfileType = rs.getString("profile_type");
                        normalizedProfileType = cProfileType == null ? "" : cProfileType.trim().toLowerCase();

                        // Treat common variants as admin-assigned to avoid incorrect fallback to manual dashboard.
                        if ("admin".equals(normalizedProfileType)
                                || "admin_assigned".equals(normalizedProfileType)
                                || "assigned".equals(normalizedProfileType)
                                || "auto".equals(normalizedProfileType)) {
                            redirectUrl = "client/customerdashboard.jsp"; // Admin assigned dashboard
                        } else {
                            redirectUrl = "client/clientdashboard_manual.jsp"; // Manual selection dashboard
                        }
                    }

                    // Ensure fresh session after login
                    HttpSession oldSession = request.getSession(false);
                    if (oldSession != null) {
                        oldSession.invalidate();
                    }

                    // Create Session
                    HttpSession session = request.getSession(true);
                    session.setAttribute("user", email);
                    session.setAttribute("role", role);

                    // Set specific session attributes per role
                    if ("admin".equals(role)) {
                        session.setAttribute("user_id", "admin");
                        session.setAttribute("name", "Administrator");
                        session.setAttribute("aname", email); // Legacy support
                    } else if ("lawyer".equals(role)) {
                        session.setAttribute("user_id", rs.getInt("lid"));
                        session.setAttribute("name", rs.getString("name"));
                        session.setAttribute("lid", rs.getInt("lid")); // Used in some JSPs
                        session.setAttribute("lname", email); // Legacy: Lawyer_login.jsp sets lname = email
                    } else if ("client".equals(role)) {
                        String clientName = rs.getString("cname");
                        int clientId = rs.getInt("cid");

                        session.setAttribute("user_id", clientId);
                        session.setAttribute("name", clientName);
                        session.setAttribute("cid", clientId);

                        // CRITICAL: clientdashboard_manual.jsp expects 'cname' to be the EMAIL/USERNAME
                        // for login check
                        session.setAttribute("cname", email);

                        // It also uses 'cemail' sometimes
                        session.setAttribute("cemail", email);

                        // And we store the real name as c_full_name for display if needed,
                        // though dashboard fetches it from DB again.
                        session.setAttribute("c_full_name", clientName);
                        session.setAttribute("profileType", normalizedProfileType);
                    } else if ("intern".equals(role)) {
                        session.setAttribute("user_id", rs.getInt("internid"));
                        session.setAttribute("name", rs.getString("name"));
                        session.setAttribute("intern_id", rs.getInt("internid"));
                        session.setAttribute("iname", email); // Legacy support
                    }

                    response.sendRedirect(redirectUrl);
                } else {
                    response.sendRedirect(loginPage + "?error=Invalid%20Credentials");
                }
            } else {
                response.sendRedirect(loginPage + "?error=User%20Not%20Found");
            }

        } catch (Exception e) {
            e.printStackTrace();
            String errorMsg = e.getMessage() != null ? e.getMessage() : e.toString();
            response.sendRedirect(
                    loginPage + "?error=Server%20Error:%20" + java.net.URLEncoder.encode(errorMsg, "UTF-8"));
        } finally {
            try {
                if (rs != null)
                    rs.close();
            } catch (Exception e) {
            }
            try {
                if (pst != null)
                    pst.close();
            } catch (Exception e) {
            }
            try {
                if (con != null)
                    con.close();
            } catch (Exception e) {
            }
        }
    }
}
