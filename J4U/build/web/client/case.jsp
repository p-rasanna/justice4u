<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*, com.j4u.DatabaseConfig" %>
<%
  int hour = java.util.Calendar.getInstance().get(java.util.Calendar.HOUR_OF_DAY);
  String greet=(hour<12)?"Good Morning":(hour<16)?"Good Afternoon":(hour<21)?"Good Evening":"Safe Haven";
  String profileType=(String)session.getAttribute("profileType");
  if(profileType == null) profileType = "admin";
  boolean isManualFlow = "manual".equalsIgnoreCase(profileType);
  String dashURL="clientdashboard.jsp";
  String selLawyer=request.getParameter("lawyer_email"), selLawyerName=request.getParameter("lawyer_name");
  String email=(String)session.getAttribute("cname");
  if(email==null){ response.sendRedirect("../auth/cust_login.jsp"); return; }
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="../shared/_head.jsp"><jsp:param name="title" value="File New Case"/></jsp:include>
<body class="layout-fixed sidebar-expand-lg bg-body-tertiary">
<div class="app-wrapper">
  <jsp:include page="../shared/_sidebar.jsp" />
  <main class="app-main">
    <jsp:include page="../shared/_topbar.jsp"><jsp:param name="title" value="File New Case"/></jsp:include>
    <div class="app-content pt-4">
      <div class="container-fluid">
        <% if(request.getParameter("error")!=null){ %>
          <div class="alert alert-danger alert-dismissible fade show border-0 mb-4" style="border-left: 4px solid var(--error) !important;">
            <i class="bi bi-exclamation-triangle-fill me-2"></i><%=request.getParameter("error")%>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
          </div>
        <% } %>
        <div class="row justify-content-center">
          <div class="col-lg-9">
            <form action="${pageContext.request.contextPath}/AddCaseServlet" method="post" enctype="multipart/form-data">
              <%-- ── Flow Banner ──────────────────────────────────────────────── --%>
              <% if(isManualFlow) { %>
                <% if(selLawyer != null) { %>
                  <%-- Selected lawyer from findlawyer.jsp --%>
                  <div class="alert border-0 d-flex align-items-center gap-3 mb-4" style="background:var(--gold-light);">
                    <i class="bi bi-star-fill" style="color:var(--gold);font-size:1.5rem;"></i>
                    <div>
                      <h6 class="mb-0">Direct Request to <%=selLawyerName%></h6>
                      <p class="small mb-0 text-muted">This case will be sent directly to your chosen lawyer upon filing.</p>
                    </div>
                    <input type="hidden" name="selected_lawyer_email" value="<%=selLawyer%>">
                  </div>
                <% } else { %>
                  <%-- Manual flow without pre-selected lawyer — show selection dropdown --%>
                  <div class="card border-0 mb-4" style="background:rgba(13,110,253,0.03); border:1px dashed #0d6efd !important;">
                    <div class="card-header bg-transparent border-0 py-3 px-4">
                      <h6 class="mb-1 text-primary fw-bold"><i class="bi bi-person-badge-fill me-2"></i>Select Your Legal Counsel</h6>
                      <p class="small mb-0 text-muted">Choose a verified lawyer to send your case request to.</p>
                    </div>
                    <div class="card-body px-4 pb-4 pt-0">
                      <select name="selected_lawyer_email" class="form-select border-primary-subtle" required>
                        <option value="" disabled selected>Choose a lawyer...</option>
                        <%
                          try (Connection con = DatabaseConfig.getConnection();
                             PreparedStatement ps = con.prepareStatement("SELECT name, email FROM lawyer_reg WHERE flag=1 ORDER BY name ASC");
                             ResultSet rs = ps.executeQuery()) {
                            while (rs.next()) {
                        %>
                          <option value="<%= rs.getString("email") %>"><%= rs.getString("name") %> (<%= rs.getString("email") %>)</option>
                        <%
                            }
                          } catch (Exception e) { e.printStackTrace(); }
                        %>
                      </select>
                    </div>
                  </div>
                <% } %>
              <% } else { %>
                <%-- Admin flow --%>
                <div class="alert border-0 d-flex align-items-center gap-3 mb-4" style="background:rgba(180,151,90,0.08); border:1px dashed var(--gold) !important;">
                  <i class="bi bi-shield-check" style="color:var(--gold);font-size:1.5rem; flex-shrink:0;"></i>
                  <div>
                    <h6 class="mb-1 fw-bold" style="color:var(--gold);">Admin-Assigned Flow</h6>
                    <p class="small mb-0 text-muted">Our team will carefully review your case and assign the best available lawyer. You'll be notified once assigned.</p>
                  </div>
                </div>
              <% } %>
              <div class="card border-0 mb-4">
                <div class="card-header bg-transparent border-0 py-3 px-4">
                  <h5 class="card-title fw-bold mb-0 text-serif">
                    <i class="bi bi-file-earmark-text me-2" style="color:var(--gold);"></i>Case Information
                  </h5>
                </div>
                <div class="card-body px-4 pb-4 pt-0">
                  <div class="row g-3">
                    <div class="col-12">
                      <label class="form-label small fw-bold">Case Title</label>
                      <input type="text" name="title" class="form-control py-2" placeholder="Brief subject of the legal matter" required>
                    </div>
                    <div class="col-12">
                      <label class="form-label small fw-bold">Detailed Description</label>
                      <textarea name="description" class="form-control py-2" rows="4" placeholder="Describe the incident, names involved, and desired outcome..." required></textarea>
                    </div>
                    <div class="col-md-6">
                      <label class="form-label small fw-bold">Court Type</label>
                      <select name="courtType" class="form-select py-2" required>
                        <option value="" disabled selected>Select court type</option>
                        <option>District Court</option>
                        <option>High Court</option>
                        <option>Supreme Court</option>
                        <option>Consumer Court</option>
                        <option>Family Court</option>
                        <option>Labour Court</option>
                      </select>
                    </div>
                    <div class="col-md-6">
                      <label class="form-label small fw-bold">City / Jurisdiction</label>
                      <input type="text" name="city" class="form-control py-2" placeholder="Enter city" required>
                    </div>
                  </div>
                </div>
              </div>
              <div class="card border-0 mb-4">
                <div class="card-header bg-transparent border-0 py-3 px-4">
                  <h5 class="card-title fw-bold mb-0 text-serif">
                    <i class="bi bi-paperclip me-2" style="color:var(--gold);"></i>Supporting Documents
                  </h5>
                </div>
                <div class="card-body px-4 pb-4 pt-0">
                  <label class="form-label small fw-bold">Upload Evidence / Documents <span class="fw-normal text-muted">(Optional)</span></label>
                  <input type="file" name="documents" class="form-control py-2" accept=".pdf,.jpg,.jpeg,.png,.doc,.docx">
                  <div class="form-text small" style="font-size:0.7rem;">Allowed: PDF, Images, Word documents. Max 10MB.</div>
                </div>
              </div>
              <div class="d-flex align-items-center gap-2 mb-4">
                <input type="checkbox" id="terms" required class="form-check-input">
                <label for="terms" class="small text-muted">I certify that all provided details are accurate and authorize legal processing.</label>
              </div>
              <div class="row g-3 mb-5">
                <div class="col-md-8">
                  <button type="submit" class="btn w-100 py-2 fw-semibold" style="background:var(--gold);color:#111827;border:none;">
                    <i class="bi bi-send me-2"></i>Submit Case Filing
                  </button>
                </div>
                <div class="col-md-4">
                  <a href="<%=dashURL%>" class="btn btn-outline-dark w-100 py-2 fw-semibold">Cancel</a>
                </div>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
    <jsp:include page="../shared/_footer.jsp" />
  </main>
</div>
</body>
</html>