<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
  String user=(String)session.getAttribute("cname");
  boolean logged=user!=null;
  String lid=request.getParameter("id");
  if(lid==null || lid.isEmpty()){ response.sendRedirect("findlawyer.jsp"); return; }
  String name="Advocate", spec="General", exp="0", loc="N/A", bar="N/A", about="";
  try(Connection con=DatabaseConfig.getConnection()){
    PreparedStatement ps=con.prepareStatement("SELECT * FROM lawyer_reg WHERE email=?");
    ps.setString(1,lid);
    ResultSet rs=ps.executeQuery();
    if(rs.next()){
      name=rs.getString("name");
      if(name==null || name.isEmpty()) name=rs.getString("fname")+" "+rs.getString("lname");
      spec=rs.getString("specialization");
      loc=rs.getString("cadd");
      bar=rs.getString("bar_council_number");
      exp=rs.getString("experience_years");
      about="Expertise in " + (spec!=null?spec:"legal practice") + " with " + exp + " years of experience in " + (loc!=null?loc:"the field") + ". Committed to rigorous advocacy and judicial integrity.";
    } else {
      response.sendRedirect("findlawyer.jsp");
      return;
    }
  } catch(Exception e){ e.printStackTrace(); }
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="components/_head.jsp"><jsp:param name="title" value="Counsel Profile"/></jsp:include>
<body class="bg-body-secondary py-5">
  <div class="container py-5">
    <div class="row justify-content-center">
      <div class="col-lg-10">
        <nav class="mb-4 d-flex justify-content-between align-items-center">
          <a href="../landing/Home.html" class="text-decoration-none text-dark fw-bold d-flex align-items-center gap-2">
            <i class="bi bi-arrow-left"></i> Return Home
          </a>
          <div class="small text-muted text-uppercase ls-1 fw-bold">Legal Directory / Professional Identity</div>
        </nav>
        <div class="card border-0 shadow-lg rounded-4 overflow-hidden">
          <div class="bg-dark text-white p-5 position-relative overflow-hidden">
            <div class="position-absolute translate-middle opacity-10" style="top:50%; right:-10%; font-size: 20rem;">
              <i class="bi bi-scales"></i>
            </div>
            <div class="row align-items-center position-relative">
              <div class="col-auto">
                <div class="bg-gold text-dark rounded-circle d-flex align-items-center justify-content-center shadow-lg" style="width:100px; height:100px; font-size:2.5rem; font-family: 'DM Serif Display', serif;">
                  <%= name.charAt(0) %>
                </div>
              </div>
              <div class="col mt-4 mt-md-0 ms-md-4">
                <span class="badge bg-gold-subtle text-gold border border-warning-subtle px-3 mb-2 text-uppercase ls-1">Verified Associate</span>
                <h1 class="display-4 fw-bold text-serif mb-1">Adv. <%= name %></h1>
                <div class="d-flex align-items-center gap-4 text-white-50">
                  <span><i class="bi bi-mortarboard me-1"></i> <%= spec != null ? spec : "General Practice" %></span>
                  <span><i class="bi bi-geo-alt me-1"></i> <%= loc != null ? loc : "Pan India" %></span>
                </div>
              </div>
            </div>
          </div>
          <div class="card-body p-lg-5">
            <div class="row g-5">
              <div class="col-lg-7 text-start">
                <section class="mb-5">
                  <h5 class="fw-bold text-serif border-bottom border-light-subtle pb-3 mb-4">Professional Biography</h5>
                  <p class="lead text-muted"><%= about %></p>
                  <p class="text-muted">Specializing in high-stakes litigation and procedural advisory, focusing on client-centric outcomes and strict adherence to constitutional frameworks.</p>
                </section>
                <section>
                  <h5 class="fw-bold text-serif border-bottom border-light-subtle pb-3 mb-4">Areas of Expertise</h5>
                  <div class="d-flex flex-wrap gap-2">
                    <% if(spec!=null) for(String s : spec.split(",")){ %>
                      <span class="badge bg-light text-dark border border-light-subtle px-3 py-2 fw-normal fs-6 rounded-pill">
                        <i class="bi bi-patch-check-fill text-gold me-2"></i><%= s.trim() %>
                      </span>
                    <% } %>
                  </div>
                </section>
              </div>
              <div class="col-lg-5">
                <div class="card bg-light border-0 rounded-4 shadow-sm h-100">
                  <div class="card-body p-4 text-start">
                    <h5 class="fw-bold text-serif mb-4">Engagement Details</h5>
                    <div class="d-flex justify-content-between align-items-center py-3 border-bottom border-white">
                      <span class="text-muted small text-uppercase ls-1 fw-bold">Experience Grade</span>
                      <span class="fw-bold h5 mb-0 text-dark"><%= exp %> Years</span>
                    </div>
                    <div class="d-flex justify-content-between align-items-center py-3 border-bottom border-white">
                      <span class="text-muted small text-uppercase ls-1 fw-bold">Bar License</span>
                      <span class="badge bg-white text-dark border fw-bold text-uppercase"><%= bar %></span>
                    </div>
                    <div class="d-flex justify-content-between align-items-center py-3 border-bottom border-white">
                      <span class="text-muted small text-uppercase ls-1 fw-bold">Response Rate</span>
                      <span class="text-success"><i class="bi bi-lightning-fill me-1"></i> Excellent</span>
                    </div>
                    <div class="mt-5 pt-2">
                      <% if(logged){ %>
                        <a href="../client/requestlawyer.jsp?lawyer_email=<%= lid %>" class="btn btn-gold btn-lg w-100 py-3 rounded-3 shadow-sm border-0 fw-bold">
                          Initialize Case Request <i class="bi bi-arrow-right-circle ms-2"></i>
                        </a>
                      <% } else { %>
                        <a href="../auth/cust_login.jsp?msg=Identity verification required to request counsel" class="btn btn-dark btn-lg w-100 py-3 rounded-3 shadow-sm border-0 fw-bold">
                          Login to Request <i class="bi bi-shield-lock ms-2"></i>
                        </a>
                        <p class="text-center mt-3 small text-muted">A valid client account is required for routing.</p>
                      <% } %>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="text-center mt-5">
          <p class="text-muted small">&copy; 2026 Justice4U Platform. All legal interactions are encrypted and logged for compliance.</p>
        </div>
      </div>
    </div>
  </div>
</body>
</html>