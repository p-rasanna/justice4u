<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<% 
    String email=(String)session.getAttribute("cname"); 
    if(email==null){ response.sendRedirect("../auth/cust_login.jsp"); return; } 
    
    String msg="", msgT=""; 
    if("POST".equalsIgnoreCase(request.getMethod())){ 
        try(Connection con=DatabaseConfig.getConnection()){ 
            PreparedStatement ps=con.prepareStatement("UPDATE cust_reg SET cname=?, mobno=?, dob=?, cadd=?, padd=? WHERE email=?"); 
            ps.setString(1,request.getParameter("cname")); 
            ps.setString(2,request.getParameter("mobno")); 
            ps.setString(3,request.getParameter("dob")); 
            ps.setString(4,request.getParameter("cadd")); 
            ps.setString(5,request.getParameter("padd")); 
            ps.setString(6,email); 
            ps.executeUpdate(); 
            msg="Profile updated successfully."; 
            msgT="success"; 
        } catch(Exception e){ 
            msg=e.getMessage(); 
            msgT="danger"; 
        } 
    } 
    
    String name="", mob="", dob="", cadd="", padd=""; 
    try(Connection con=DatabaseConfig.getConnection()){ 
        PreparedStatement ps=con.prepareStatement("SELECT * FROM cust_reg WHERE email=?"); 
        ps.setString(1,email); 
        ResultSet rs=ps.executeQuery(); 
        if(rs.next()){ 
            name=rs.getString("cname"); 
            mob=rs.getString("mobno"); 
            dob=rs.getString("dob"); 
            cadd=rs.getString("cadd"); 
            padd=rs.getString("padd"); 
        } 
    } catch(Exception e){}
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="components/_head.jsp"><jsp:param name="title" value="My Profile Settings"/></jsp:include>
<body class="layout-fixed sidebar-expand-lg bg-body-tertiary">
    <div class="app-wrapper">
        <jsp:include page="components/_sidebar.jsp" />
        <main class="app-main">
            <jsp:include page="components/_topbar.jsp">
                <jsp:param name="title" value="Account Security"/>
                <jsp:param name="subtitle" value="Personal Credentials"/>
            </jsp:include>
            
            <div class="app-content pt-4">
                <div class="container-fluid">
                    <div class="row">
                        <div class="col-lg-8">
                            <% if(!msg.isEmpty()){ %>
                                <div class="alert alert-<%=msgT%> border-0 shadow-sm mb-4">
                                    <i class="bi <%= "success".equals(msgT) ? "bi-check-circle-fill" : "bi-exclamation-triangle-fill" %> me-2"></i>
                                    <%=msg%>
                                </div>
                            <% } %>
                            
                            <div class="card border-0 shadow-sm rounded-4">
                                <div class="card-header bg-white border-0 py-4 px-4">
                                    <h5 class="card-title fw-bold mb-0 text-serif"><i class="bi bi-person-circle text-gold me-2"></i>Profile Information</h5>
                                </div>
                                <div class="card-body p-4 pt-2">
                                    <form method="post" id="profileForm">
                                        <div class="row g-4">
                                            <div class="col-md-6 text-start">
                                                <label class="form-label small fw-bold text-uppercase text-muted ls-1 mb-2" for="cname">Client Name</label>
                                                <div class="input-group">
                                                    <span class="input-group-text bg-light border-light-subtle"><i class="bi bi-person"></i></span>
                                                    <input type="text" id="cname" name="cname" class="form-control border-light-subtle" value="<%=name%>" required>
                                                </div>
                                            </div>
                                            <div class="col-md-6 text-start">
                                                <label class="form-label small fw-bold text-uppercase text-muted ls-1 mb-2">Email Identity</label>
                                                <div class="input-group">
                                                    <span class="input-group-text bg-body-secondary border-light-subtle"><i class="bi bi-envelope"></i></span>
                                                    <input type="email" class="form-control bg-body-secondary border-light-subtle" value="<%=email%>" readonly>
                                                </div>
                                            </div>
                                            <div class="col-md-6 text-start">
                                                <label class="form-label small fw-bold text-uppercase text-muted ls-1 mb-2" for="mobno">Mobile Contact</label>
                                                <div class="input-group">
                                                    <span class="input-group-text bg-light border-light-subtle"><i class="bi bi-phone"></i></span>
                                                    <input type="tel" id="mobno" name="mobno" class="form-control border-light-subtle" value="<%=mob%>" required>
                                                </div>
                                            </div>
                                            <div class="col-md-6 text-start">
                                                <label class="form-label small fw-bold text-uppercase text-muted ls-1 mb-2" for="dob">Date of Birth</label>
                                                <div class="input-group">
                                                    <span class="input-group-text bg-light border-light-subtle"><i class="bi bi-calendar-event"></i></span>
                                                    <input type="date" id="dob" name="dob" class="form-control border-light-subtle" value="<%=dob%>" required>
                                                </div>
                                            </div>
                                            <div class="col-12 text-start">
                                                <label class="form-label small fw-bold text-uppercase text-muted ls-1 mb-2" for="cadd">Correspondence Address</label>
                                                <textarea id="cadd" name="cadd" class="form-control border-light-subtle" rows="3" required><%=cadd%></textarea>
                                            </div>
                                            <div class="col-12 text-start">
                                                <label class="form-label small fw-bold text-uppercase text-muted ls-1 mb-2" for="padd">Permanent Residence</label>
                                                <textarea id="padd" name="padd" class="form-control border-light-subtle" rows="3" required><%=padd%></textarea>
                                            </div>
                                            <div class="col-12 pt-3">
                                                <button type="submit" class="btn btn-gold btn-lg px-5 shadow-sm rounded-3 fw-bold">
                                                    Update Information <i class="bi bi-arrow-right ms-2"></i>
                                                </button>
                                            </div>
                                        </div>
                                    </form>
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
 