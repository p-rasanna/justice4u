<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
  String email=(String)session.getAttribute("cname"); if(email==null){response.sendRedirect("../auth/Login.jsp");return;}
  String name="", avatar="U";
  try(Connection con=DatabaseConfig.getConnection()){
    PreparedStatement ps=con.prepareStatement("SELECT cname FROM cust_reg WHERE email=?"); ps.setString(1,email);
    ResultSet rs=ps.executeQuery(); if(rs.next()){ name=rs.getString(1); avatar=String.valueOf(name.charAt(0)).toUpperCase(); }
  }catch(Exception e){}
  String pt=(String)session.getAttribute("profileType");
  boolean isAdmin="admin".equalsIgnoreCase(pt)||"admin_assigned".equalsIgnoreCase(pt)||"assigned".equalsIgnoreCase(pt);
  String dashURL = "clientdashboard.jsp"; // unified dashboard for both flows
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="components/_head.jsp"><jsp:param name="title" value="Client Portal"/></jsp:include>
<body>
<div class="app-layout">
  <jsp:include page="components/_sidebar.jsp" />
  <main class="main-content">
    <jsp:include page="components/_topbar.jsp"><jsp:param name="title" value="Client"/><jsp:param name="subtitle" value="Portal"/></jsp:include>
    <div class="p-5">
      <div class="panel p-0 overflow-hidden">
        <div class="panel-head"><h3>Recent Invoices</h3></div>
        <div class="table-responsive">
          <table class="table table-hover mb-0">
            <thead class="bg-light"><tr><th class="ps-4">Invoice ID</th><th>Date</th><th>Service</th><th>Amount</th><th>Status</th><th class="text-end pe-4">Action</th></tr></thead>
              <tr><td colspan="6" class="text-center text-muted p-5">
                <i class="ph ph-receipt h1 text-gray-300 mb-3 d-block"></i>
                <h5>Billing Module Coming Soon</h5>
                <p class="mb-0">Secure payment gateway integration is currently under development.</p>
              </td></tr>
          </table>
        </div>
      </div>
      <div class="alert alert-secondary border-0 mt-4 p-4 d-flex gap-3">
        <i class="ph-fill ph-info h4 mb-0 text-gold"></i>
        <div class="small"><strong>Escrow Policy:</strong> All retainers are held securely and released only upon formal case acceptance by your counsel.</div>
      </div>
    </div>
  </main>
</div>
</body>
</html>