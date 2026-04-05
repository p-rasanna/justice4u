<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig"%>
<%
  String user=(String)session.getAttribute("lname");
  if(user==null){ response.sendRedirect("../auth/Lawyer_login_form.jsp"); return; }
  String alidStr = request.getParameter("alid") != null ? request.getParameter("alid") : request.getParameter("id");
  if(alidStr == null) { response.sendRedirect("viewcases.jsp"); return; }
  int id=Integer.parseInt(alidStr);
  String title="", desc="", client="", cemail="", court="", city="", status="REQUESTED";
  try(Connection con=DatabaseConfig.getConnection()){
    PreparedStatement ps=con.prepareStatement("SELECT a.*, COALESCE(cs.status,'REQUESTED') FROM allotlawyer a LEFT JOIN case_status cs ON a.alid=cs.alid WHERE a.alid=? AND a.lname=?");
    ps.setInt(1,id); ps.setString(2,user);
    ResultSet rs=ps.executeQuery();
    if(rs.next()){
      title=rs.getString("title");
      desc=rs.getString("des");
      client=rs.getString("name");
      cemail=rs.getString("cname");
      court=rs.getString("courttype");
      city=rs.getString("city");
      status=rs.getString(9);
    }
  } catch(Exception e){ e.printStackTrace(); }
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="components/_head.jsp"><jsp:param name="title" value="Case File #<%=id%>"/></jsp:include>
<body class="layout-fixed sidebar-expand-lg bg-body-tertiary">
  <div class="app-wrapper">
    <jsp:include page="components/_sidebar.jsp" />
    <main class="app-main">
      <jsp:include page="components/_topbar.jsp">
        <jsp:param name="title" value="File Examination"/>
        <jsp:param name="subtitle" value="Case Management Center"/>
      </jsp:include>
      <div class="app-content pt-4">
        <div class="container-fluid text-start">
          <div class="row g-4">
            <div class="col-lg-8">
              <div class="card border-0 shadow-sm rounded-4 mb-4">
                <div class="card-header bg-white border-0 py-4 px-4 d-flex justify-content-between align-items-center">
                  <h4 class="card-title fw-bold mb-0 text-serif"><%= title %></h4>
                  <span class="badge bg-gold-subtle text-gold border border-warning-subtle px-3 text-uppercase fw-bold" style="font-size: 0.65rem;">
                    <%= status %>
                  </span>
                </div>
                <div class="card-body p-4 pt-0">
                  <div class="mb-4">
                    <p class="text-muted"><%= desc %></p>
                  </div>
                  <div class="row g-4 py-4 border-top border-light">
                    <div class="col-md-6">
                      <div class="text-muted small fw-bold text-uppercase ls-1 mb-2">Subject Identity / Client</div>
                      <div class="d-flex align-items-center gap-3 bg-light p-3 rounded-3 border border-light-subtle">
                        <div class="bg-white rounded-circle p-2 shadow-sm"><i class="bi bi-person-fill text-gold"></i></div>
                        <div>
                          <div class="fw-bold"><%= client %></div>
                          <div class="small text-muted"><%= cemail %></div>
                        </div>
                      </div>
                    </div>
                    <div class="col-md-6">
                      <div class="text-muted small fw-bold text-uppercase ls-1 mb-2">Jurisdiction / Location</div>
                      <div class="d-flex align-items-center gap-3 bg-light p-3 rounded-3 border border-light-subtle">
                        <div class="bg-white rounded-circle p-2 shadow-sm"><i class="bi bi-bank text-gold"></i></div>
                        <div>
                          <div class="fw-bold"><%= court %></div>
                          <div class="small text-muted"><%= city %></div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <div class="col-lg-4">
              <div class="card border-0 shadow-sm rounded-4 h-100">
                <div class="card-header bg-white border-0 py-4 px-4">
                  <h5 class="card-title fw-bold mb-0 text-serif"><i class="bi bi-command text-gold me-2"></i>Action Center</h5>
                </div>
                <div class="card-body p-4 pt-0">
                  <div class="d-grid gap-3">
                    <% if("REQUESTED".equals(status)||"Pending".equalsIgnoreCase(status)){ %>
                      <div class="alert alert-warning border-0 small mb-2">
                        <i class="bi bi-info-circle-fill me-2"></i> This case requires immediate acknowledgement.
                      </div>
                      <a href="acceptcase.jsp?alid=<%=id%>" class="btn btn-gold btn-lg py-3 rounded-3 fw-bold shadow-sm">
                        <i class="bi bi-check-circle-fill me-2"></i> Accept Mandate
                      </a>
                      <a href="rejectcase.jsp?alid=<%=id%>" class="btn btn-outline-danger btn-lg py-3 rounded-3 fw-semibold">
                        <i class="bi bi-x-circle-fill me-2"></i> Decline Case
                      </a>
                    <% } else { %>
                      <a href="client_messages.jsp?alid=<%=id%>" class="btn btn-dark btn-lg py-3 rounded-3 fw-bold">
                        <i class="bi bi-chat-left-dots-fill me-2"></i> Client Communication
                      </a>
                      <a href="view_case_documents.jsp?caseId=<%=id%>" class="btn btn-outline-dark py-3 rounded-3 text-start ps-4">
                        <i class="bi bi-file-earmark-pdf-fill text-gold me-3"></i> Document Repository
                      </a>
                      <a href="case_timeline.jsp?caseid=<%=id%>" class="btn btn-outline-dark py-3 rounded-3 text-start ps-4">
                        <i class="bi bi-clock-history text-gold me-3"></i> Procedural Timeline
                      </a>
                      <a href="add_case_note.jsp?alid=<%=id%>" class="btn btn-outline-dark py-3 rounded-3 text-start ps-4">
                        <i class="bi bi-pencil-square text-gold me-3"></i> Internal Case Notes
                      </a>
                      <div class="mt-4 pt-4 border-top border-light">
                        <a href="closecase.jsp?id=<%=id%>" class="btn btn-link text-danger w-100 text-decoration-none small fw-bold">
                          <i class="bi bi-archive-fill me-2"></i> Close This File
                        </a>
                      </div>
                    <% } %>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      <jsp:include page="components/_footer.jsp" />
    </main>
  </div>
</body>
</html>