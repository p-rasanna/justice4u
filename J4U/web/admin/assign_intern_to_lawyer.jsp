<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
  String admin=(String)session.getAttribute("aname");
  if(admin==null){response.sendRedirect("../auth/Login.jsp");return;}
  String msg=request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="../shared/_head.jsp">
  <jsp:param name="title" value="Assign Intern to Lawyer"/>
</jsp:include>
<body class="layout-fixed sidebar-expand-lg bg-body-tertiary">
  <div class="app-wrapper">
    <jsp:include page="../shared/_topbar.jsp" />
    <jsp:include page="../shared/_sidebar.jsp" />
    <main class="app-main">
      <div class="app-content-header mb-4">
        <div class="container-fluid">
          <div class="row align-items-center">
            <div class="col-sm-6">
              <h2 class="mb-0 text-serif fw-bold">Assign Intern to Lawyer</h2>
              <p class="text-muted small mb-0">Link approved interns with legal counsel</p>
            </div>
            <div class="col-sm-6 text-end">
              <a href="admindashboard.jsp" class="btn btn-sm btn-outline-dark px-3">
                <i class="bi bi-arrow-left me-1"></i> Back
              </a>
            </div>
          </div>
        </div>
      </div>
      <div class="app-content">
        <div class="container-fluid">
          <% if(msg!=null){ %>
            <div class="alert alert-<%= msg.startsWith("Error") ? "danger" : "success" %> alert-dismissible fade show border-0 shadow-none mb-4">
              <i class="bi bi-<%= msg.startsWith("Error") ? "exclamation-triangle" : "check-circle" %>-fill me-2"></i>
              <%=msg%>
              <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
          <% } %>
          <div class="row g-4">
            <div class="col-lg-6">
              <div class="card border-0 bg-white">
                <div class="card-header bg-transparent border-0 py-4 px-4">
                  <h5 class="card-title fw-bold mb-0 text-serif">
                    <i class="bi bi-link-45deg text-gold me-2"></i>New Assignment
                  </h5>
                </div>
                <div class="card-body px-4 pb-4 pt-0">
                  <form action="process_assign_intern_lawyer.jsp" method="post">
                    <div class="mb-4">
                      <label class="form-label small fw-bold text-uppercase ls-1">Select Intern</label>
                      <select name="intern_email" class="form-select py-2" required>
                        <option value="" disabled selected>Choose an approved intern...</option>
                        <%
                          try(Connection con=DatabaseConfig.getConnection()){
                            PreparedStatement ps=con.prepareStatement(
                              "SELECT i.email, i.name FROM intern i WHERE i.flag=1 " +
                              "AND i.email NOT IN (SELECT intern_email FROM intern_lawyer_assignments WHERE status IN ('PENDING','ACCEPTED')) " +
                              "ORDER BY i.name"
                            );
                            ResultSet rs=ps.executeQuery();
                            while(rs.next()){
                        %>
                          <option value="<%=rs.getString("email")%>"><%=rs.getString("name")%> (<%=rs.getString("email")%>)</option>
                        <%      }
                          }catch(Exception e){}
                        %>
                      </select>
                      <div class="form-text small" style="font-size:0.7rem;">Only approved interns without active assignments shown</div>
                    </div>
                    <div class="mb-4">
                      <label class="form-label small fw-bold text-uppercase ls-1">Select Lawyer</label>
                      <select name="lawyer_email" class="form-select py-2" required>
                        <option value="" disabled selected>Choose a lawyer...</option>
                        <%
                          try(Connection con=DatabaseConfig.getConnection()){
                            PreparedStatement ps=con.prepareStatement(
                              "SELECT email, name FROM lawyer_reg WHERE flag=1 ORDER BY name"
                            );
                            ResultSet rs=ps.executeQuery();
                            while(rs.next()){
                        %>
                          <option value="<%=rs.getString("email")%>"><%=rs.getString("name")%> (<%=rs.getString("email")%>)</option>
                        <%      }
                          }catch(Exception e){}
                        %>
                      </select>
                    </div>
                    <button type="submit" class="btn btn-gold w-100 py-2 fw-semibold">
                      <i class="bi bi-send me-2"></i>Submit Assignment
                    </button>
                  </form>
                </div>
              </div>
            </div>
            <div class="col-lg-6">
              <div class="card border-0 bg-white">
                <div class="card-header bg-transparent border-0 py-4 px-4">
                  <h5 class="card-title fw-bold mb-0 text-serif">
                    <i class="bi bi-list-check text-gold me-2"></i>Current Assignments
                  </h5>
                </div>
                <div class="card-body p-0">
                  <div class="table-responsive">
                    <table class="table align-middle mb-0">
                      <thead>
                        <tr>
                          <th class="ps-4">Intern</th>
                          <th>Lawyer</th>
                          <th class="text-end pe-4">Status</th>
                        </tr>
                      </thead>
                      <tbody>
                        <%
                          boolean hasRows=false;
                          try(Connection con=DatabaseConfig.getConnection()){
                            PreparedStatement ps=con.prepareStatement(
                              "SELECT ila.intern_email, ila.lawyer_email, ila.status, ila.assigned_date, " +
                              "i.name as intern_name, lr.name as lawyer_name " +
                              "FROM intern_lawyer_assignments ila " +
                              "JOIN intern i ON ila.intern_email=i.email " +
                              "JOIN lawyer_reg lr ON ila.lawyer_email=lr.email " +
                              "ORDER BY ila.assigned_date DESC LIMIT 10"
                            );
                            ResultSet rs=ps.executeQuery();
                            while(rs.next()){
                              hasRows=true;
                              String st=rs.getString("status");
                              String badgeClass=st.equals("ACCEPTED")?"bg-success":st.equals("REJECTED")?"bg-danger":"bg-warning text-dark";
                        %>
                        <tr class="border-light">
                          <td class="ps-4">
                            <div class="fw-semibold text-dark"><%=rs.getString("intern_name")%></div>
                            <div class="text-muted small" style="font-size:0.7rem;"><%=rs.getString("intern_email")%></div>
                          </td>
                          <td>
                            <div class="small fw-medium text-dark"><%=rs.getString("lawyer_name")%></div>
                          </td>
                          <td class="text-end pe-4">
                            <span class="badge <%=badgeClass%> px-2 py-1" style="font-size:0.65rem;"><%=st%></span>
                          </td>
                        </tr>
                        <%      }
                          }catch(Exception e){}
                          if(!hasRows){
                        %>
                        <tr>
                          <td colspan="3" class="text-center py-5 text-muted small opacity-50">
                            <i class="bi bi-inbox fs-2 d-block mb-2"></i>
                            No assignments created yet.
                          </td>
                        </tr>
                        <% } %>
                      </tbody>
                    </table>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>
    <jsp:include page="../shared/_footer.jsp" />
  </div>
</body>
</html>