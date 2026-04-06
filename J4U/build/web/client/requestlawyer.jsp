<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,java.util.*,com.j4u.DatabaseConfig" %>
<%
  String email=(String)session.getAttribute("cname");
  if(email==null){ response.sendRedirect("../auth/cust_login.jsp"); return; }
  String lEmail=request.getParameter("lawyer_email");
  if(lEmail==null || lEmail.isEmpty()){ response.sendRedirect("findlawyer.jsp"); return; }
  int custId=-1, lId=-1; String lName=""; List<Map<String, String>> cases=new ArrayList<>();
  try(Connection con=DatabaseConfig.getConnection()){
    PreparedStatement ps=con.prepareStatement("SELECT cid FROM cust_reg WHERE email=?");
    ps.setString(1,email);
    ResultSet rs=ps.executeQuery();
    if(rs.next()) custId=rs.getInt(1);
    ps=con.prepareStatement("SELECT lid, name, fname, lname FROM lawyer_reg WHERE email=?");
    ps.setString(1,lEmail);
    rs=ps.executeQuery();
    if(rs.next()){
      lId=rs.getInt(1);
      lName=rs.getString(2);
      if(lName==null||lName.isEmpty()) lName=rs.getString(3)+" "+rs.getString(4);
    }
    if("link_case".equals(request.getParameter("action"))){
      int cId=Integer.parseInt(request.getParameter("selected_case_id"));
      ps=con.prepareStatement("UPDATE customer_cases SET assigned_lawyer_id=?, status='REQUESTED' WHERE case_id=? AND customer_id=?");
      ps.setInt(1,lId); ps.setInt(2,cId); ps.setInt(3,custId); ps.executeUpdate();
      try{
        ps=con.prepareStatement("UPDATE casetb SET flag=1, lid=? WHERE cid=?");
        ps.setInt(1,lId); ps.setInt(2,cId); ps.executeUpdate();
      } catch(Exception e){}
      response.sendRedirect("clientdashboard.jsp?msg=Counsel Requested Successfully");
      return;
    }
    ps=con.prepareStatement("SELECT case_id, title FROM customer_cases WHERE customer_id=? AND status='OPEN' ORDER BY case_id DESC");
    ps.setInt(1,custId);
    rs=ps.executeQuery();
    while(rs.next()){
      Map<String,String> m=new HashMap<>();
      m.put("id",String.valueOf(rs.getInt(1)));
      m.put("title",rs.getString(2));
      cases.add(m);
    }
    if(cases.isEmpty()){
      response.sendRedirect("case.jsp?lawyer_email="+java.net.URLEncoder.encode(lEmail,"UTF-8")+"&lawyer_name="+java.net.URLEncoder.encode(lName,"UTF-8"));
      return;
    }
  } catch(Exception e){
    e.printStackTrace();
    response.sendRedirect("findlawyer.jsp");
    return;
  }
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="components/_head.jsp"><jsp:param name="title" value="Request Counsel"/></jsp:include>
<body class="bg-body-secondary d-flex align-items-center justify-content-center min-vh-100">
  <div class="container py-5">
    <div class="row justify-content-center">
      <div class="col-lg-5 col-md-8">
        <div class="card border-0 shadow-lg rounded-4 overflow-hidden">
          <div class="card-header bg-white border-0 text-center pt-5 pb-4 px-5">
            <div class="mb-4">
              <i class="bi bi-person-check-fill display-4 text-gold opacity-75"></i>
            </div>
            <h2 class="card-title fw-bold text-serif mb-2">Request <em>Counsel</em></h2>
            <p class="text-muted small px-lg-4">Assign your chosen legal representative to an active matter.</p>
          </div>
          <div class="card-body p-5 pt-0">
            <div class="bg-light rounded-3 p-3 mb-4 d-flex align-items-center gap-3 border border-light-subtle">
              <div class="bg-gold-subtle text-gold p-2 rounded-2">
                <i class="bi bi-briefcase-fill"></i>
              </div>
              <div>
                <div class="text-muted small fw-bold text-uppercase ls-1" style="font-size: 0.65rem;">Selected Attorney</div>
                <div class="fw-bold">Adv. <%= lName %></div>
              </div>
            </div>
            <form action="requestlawyer.jsp" method="POST">
              <input type="hidden" name="action" value="link_case">
              <input type="hidden" name="lawyer_email" value="<%= lEmail %>">
              <div class="mb-4">
                <label class="form-label small fw-bold text-uppercase text-muted ls-1 mb-2">Active Legal Matter</label>
                <select name="selected_case_id" class="form-select form-select-lg border-light-subtle" required>
                  <option value="" disabled selected>— Select Case —</option>
                  <% for(Map<String,String> c : cases){ %>
                    <option value="<%= c.get("id") %>">#<%= c.get("id") %>: <%= c.get("title") %></option>
                  <% } %>
                </select>
                <div class="form-text small text-muted">Only 'OPEN' cases are listed here.</div>
              </div>
              <div class="d-grid gap-2">
                <button type="submit" class="btn btn-gold btn-lg py-3 rounded-3 shadow-sm border-0 fw-bold">
                  Initiate Engagement <i class="bi bi-arrow-right ms-2"></i>
                </button>
                <a href="findlawyer.jsp" class="btn btn-link text-muted text-decoration-none small mt-2">
                  <i class="bi bi-arrow-left me-1"></i> Back to Directory
                </a>
              </div>
            </form>
          </div>
        </div>
        <div class="text-center mt-4">
          <p class="text-muted small">&copy; 2026 Justice4U Platform. Secure legal routing.</p>
        </div>
      </div>
    </div>
  </div>
</body>
</html>
</html>