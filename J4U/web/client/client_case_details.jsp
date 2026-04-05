<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
  String email=(String)session.getAttribute("cname");
  if(email==null){response.sendRedirect("../auth/cust_login.jsp");return;}
  String cidParam=request.getParameter("cid");
  String alidParam=request.getParameter("alid");
  if(cidParam==null || cidParam.isEmpty()){response.sendRedirect("client_viewcases.jsp");return;}
  int cid=0, alid=0;
  try { cid=Integer.parseInt(cidParam); } catch(NumberFormatException e) { response.sendRedirect("client_viewcases.jsp"); return; }
  if(alidParam!=null && !alidParam.isEmpty()) { try { alid=Integer.parseInt(alidParam); } catch(NumberFormatException e) {} }
  String title="", desc="", date="", court="", city="", lawyer=null, lawyerEmail=null;
  int flag=0;
  java.util.List<String[]> docs=new java.util.ArrayList<>();
  try(Connection con=DatabaseConfig.getConnection()){
    PreparedStatement ps=con.prepareStatement("SELECT title, des, curdate, courttype, city, flag FROM casetb WHERE cid=? AND cname=?");
    ps.setInt(1,cid); ps.setString(2,email);
    ResultSet rs=ps.executeQuery();
    if(rs.next()){
      title=rs.getString("title") != null ? rs.getString("title") : "Untitled";
      desc=rs.getString("des") != null ? rs.getString("des") : "No description";
      date=rs.getString("curdate") != null ? rs.getString("curdate") : "--";
      court=rs.getString("courttype") != null ? rs.getString("courttype") : "--";
      city=rs.getString("city") != null ? rs.getString("city") : "--";
      flag=rs.getInt("flag");
    } else {
      response.sendRedirect("client_viewcases.jsp?error=Case+not+found"); return;
    }
    try {
      ps=con.prepareStatement("SELECT lname FROM allotlawyer WHERE cid=? ORDER BY alid DESC LIMIT 1");
      ps.setInt(1,cid);
      rs=ps.executeQuery();
      if(rs.next()) {
        lawyerEmail=rs.getString("lname");
        ps=con.prepareStatement("SELECT name FROM lawyer_reg WHERE email=?");
        ps.setString(1,lawyerEmail);
        rs=ps.executeQuery();
        if(rs.next() && rs.getString("name")!=null) lawyer=rs.getString("name");
        else lawyer=lawyerEmail;
      }
    } catch(Exception e) {}
    try {
      ps=con.prepareStatement("SELECT file_name, file_path, uploaded_at FROM case_documents WHERE case_id=?");
      ps.setInt(1,cid);
      rs=ps.executeQuery();
      while(rs.next()) docs.add(new String[]{
        rs.getString("file_name") != null ? rs.getString("file_name") : "Document",
        rs.getString("uploaded_at") != null ? rs.getString("uploaded_at") : "--",
        rs.getString("file_path") != null ? rs.getString("file_path") : "#"
      });
    } catch(Exception e) {}
  }catch(Exception e){ e.printStackTrace(); }
  String statusLabel, badgeClass;
  if(flag==0) { statusLabel="Pending"; badgeClass="bg-warning-subtle text-warning"; }
  else if(flag==1) { statusLabel="Active"; badgeClass="bg-success-subtle text-success"; }
  else if(flag==2) { statusLabel="Closed"; badgeClass="bg-secondary-subtle text-secondary"; }
  else { statusLabel="Unknown"; badgeClass="bg-light text-muted"; }
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="../shared/_head.jsp"><jsp:param name="title" value="Case Details"/></jsp:include>
<body class="layout-fixed sidebar-expand-lg bg-body-tertiary">
<div class="app-wrapper">
  <jsp:include page="../shared/_sidebar.jsp" />
  <main class="app-main">
    <jsp:include page="../shared/_topbar.jsp"><jsp:param name="title" value="Case Details"/></jsp:include>
    <div class="app-content pt-4">
      <div class="container-fluid">
        <a href="client_viewcases.jsp" class="text-muted text-decoration-none small fw-semibold mb-3 d-inline-block">
          <i class="bi bi-arrow-left me-1"></i>Back to My Cases
        </a>
        <div class="card border-0 mb-4">
          <div class="card-body p-4">
            <div class="row align-items-center">
              <div class="col-lg-8">
                <div class="d-flex align-items-center gap-3 mb-2">
                  <span class="fw-bold" style="color:var(--gold);">#<%= cid %></span>
                  <span class="badge <%= badgeClass %> fw-normal px-2 py-1" style="font-size:0.7rem;"><%= statusLabel %></span>
                </div>
                <h3 class="text-serif fw-bold mb-1"><%= title %></h3>
                <div class="d-flex flex-wrap gap-3 text-muted small mt-2">
                  <span><i class="bi bi-calendar3 me-1"></i><%= date %></span>
                  <span><i class="bi bi-bank me-1"></i><%= court %></span>
                  <span><i class="bi bi-geo-alt me-1"></i><%= city %></span>
                </div>
              </div>
              <div class="col-lg-4 text-lg-end mt-3 mt-lg-0 d-flex gap-2 justify-content-lg-end">
                <a href="../shared/caseDiscussion.jsp?case_id=<%= cid %>" class="btn btn-sm px-4 py-2 fw-semibold" style="background:var(--gold);color:#111827;border:none;">
                  <i class="bi bi-chat-dots me-2"></i>Discussion
                </a>
              </div>
            </div>
          </div>
        </div>
        <div class="row g-4">
          <div class="col-lg-8">
            <div class="card border-0 mb-4">
              <div class="card-header bg-transparent border-0 py-3 px-4">
                <h5 class="card-title fw-bold mb-0 text-serif">
                  <i class="bi bi-file-text me-2" style="color:var(--gold);"></i>Case Description
                </h5>
              </div>
              <div class="card-body px-4 pb-4 pt-0">
                <p class="mb-0" style="line-height:1.8;"><%= desc %></p>
              </div>
            </div>
            <div class="card border-0">
              <div class="card-header bg-transparent border-0 py-3 px-4 d-flex justify-content-between align-items-center">
                <h5 class="card-title fw-bold mb-0 text-serif">
                  <i class="bi bi-paperclip me-2" style="color:var(--gold);"></i>Case Documents
                </h5>
                <a href="uploadClientDoc.jsp?cid=<%= cid %>" class="btn btn-sm btn-outline-dark rounded-pill px-3 fw-semibold" style="font-size:0.75rem;">
                  <i class="bi bi-plus me-1"></i>Upload
                </a>
              </div>
              <div class="card-body px-4 pb-4 pt-0">
                <% if(docs.isEmpty()){ %>
                  <div class="text-center py-4">
                    <i class="bi bi-folder2-open display-6 text-muted opacity-25"></i>
                    <p class="small text-muted mt-2 mb-0">No documents attached to this case yet.</p>
                  </div>
                <% } else { for(String[] d:docs){ %>
                  <a href="<%= d[2] %>" target="_blank" class="d-flex align-items-center p-3 mb-2 rounded-3 text-decoration-none text-dark" style="background:var(--bg);">
                    <i class="bi bi-file-earmark-pdf fs-4 me-3" style="color:var(--gold);"></i>
                    <div class="overflow-hidden flex-grow-1">
                      <p class="small fw-bold mb-0 text-truncate"><%= d[0] %></p>
                      <p class="small text-muted mb-0" style="font-size:0.7rem;"><%= d[1] %></p>
                    </div>
                    <i class="bi bi-download text-muted"></i>
                  </a>
                <% } } %>
              </div>
            </div>
          </div>
          <div class="col-lg-4">
            <div class="card border-0 mb-4">
              <div class="card-header bg-transparent border-0 py-3 px-4">
                <h5 class="card-title fw-bold mb-0 text-serif">
                  <i class="bi bi-person-badge me-2" style="color:var(--gold);"></i>Legal Counsel
                </h5>
              </div>
              <div class="card-body px-4 pb-4 pt-0">
                <% if(lawyer!=null){ %>
                  <div class="d-flex align-items-center gap-3 p-3 rounded-3" style="background:var(--gold-light);">
                    <div class="rounded-circle d-flex align-items-center justify-content-center text-white fw-bold text-serif" style="width:44px;height:44px;background:#111827;">
                      <%= lawyer.substring(0,1).toUpperCase() %>
                    </div>
                    <div>
                      <h6 class="mb-0 fw-bold">Adv. <%= lawyer %></h6>
                      <small class="text-muted">Assigned Counsel</small>
                    </div>
                  </div>
                <% } else { %>
                  <p class="text-muted small mb-0">No lawyer assigned to this case yet. The administration will allocate a counsel once your case is reviewed.</p>
                <% } %>
              </div>
            </div>
            <div class="card border-0">
              <div class="card-header bg-transparent border-0 py-3 px-4">
                <h5 class="card-title fw-bold mb-0 text-serif">
                  <i class="bi bi-info-circle me-2" style="color:var(--gold);"></i>Case Info
                </h5>
              </div>
              <div class="card-body px-4 pb-4 pt-0">
                <div class="mb-3">
                  <div class="text-muted small fw-bold text-uppercase" style="font-size:0.65rem;">Case ID</div>
                  <div class="small fw-semibold">#<%= cid %></div>
                </div>
                <div class="mb-3">
                  <div class="text-muted small fw-bold text-uppercase" style="font-size:0.65rem;">Date Filed</div>
                  <div class="small fw-semibold"><%= date %></div>
                </div>
                <div class="mb-3">
                  <div class="text-muted small fw-bold text-uppercase" style="font-size:0.65rem;">Court</div>
                  <div class="small fw-semibold"><%= court %></div>
                </div>
                <div class="mb-3">
                  <div class="text-muted small fw-bold text-uppercase" style="font-size:0.65rem;">City</div>
                  <div class="small fw-semibold"><%= city %></div>
                </div>
                <div class="mb-0">
                  <div class="text-muted small fw-bold text-uppercase" style="font-size:0.65rem;">Status</div>
                  <span class="badge <%= badgeClass %> fw-normal px-2 py-1 mt-1" style="font-size:0.7rem;"><%= statusLabel %></span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    <jsp:include page="../shared/_footer.jsp" />
  </main>
</div>
</body>
</html>