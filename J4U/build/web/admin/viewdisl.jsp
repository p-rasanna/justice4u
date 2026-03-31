<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
    String lEmail=(String)session.getAttribute("lname"); 
    if(lEmail==null){response.sendRedirect("../auth/Login.jsp");return;}
%>
<!DOCTYPE html>
<html lang="en">
<title>Historical Archives | Justice4U</title>
<jsp:include page="../shared/_head.jsp">
    <jsp:param name="title" value="Historical Archives"/>
</jsp:include>
<body class="layout-fixed sidebar-expand-lg bg-body-tertiary">
    <div class="app-wrapper">
        <jsp:include page="../shared/_sidebar.jsp" />
        <jsp:include page="../shared/_topbar.jsp" />
        
        <main class="app-main">
            <div class="app-content-header mb-4">
                <div class="container-fluid">
                    <div class="row align-items-center">
                        <div class="col-sm-6">
                            <h2 class="mb-0 text-serif fw-bold">Matter Archives</h2>
                            <p class="text-muted small mb-0">Secure records of historical attorney-client correspondence</p>
                        </div>
                        <div class="col-sm-6 text-end">
                            <a href="../lawyer/Lawyerdashboard.jsp" class="btn btn-outline-dark btn-sm px-3">
                                <i class="bi bi-arrow-left me-1"></i> Dashboard
                            </a>
                        </div>
                    </div>
                </div>
            </div>

            <div class="app-content">
                <div class="container-fluid">
                    <div class="card border-0 bg-white">
                        <div class="card-header bg-transparent border-0 py-4 px-4 d-flex justify-content-between align-items-center">
                            <h5 class="card-title fw-bold mb-0 text-serif">Historical Registry</h5>
                            <div class="input-group input-group-sm w-auto">
                                <span class="input-group-text bg-light border-0"><i class="bi bi-search"></i></span>
                                <input type="text" id="arcSearch" class="form-control border-light" placeholder="Search archive..." onkeyup="filterTable()">
                            </div>
                        </div>
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table align-middle mb-0" id="arcTable">
                                    <thead>
                                        <tr>
                                            <th class="ps-4">Record ID</th>
                                            <th>Matter Narrative</th>
                                            <th>Client Reference</th>
                                            <th class="text-end pe-4">Instruments</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% try(Connection con=DatabaseConfig.getConnection()){
                                            PreparedStatement pst=con.prepareStatement("SELECT * FROM discussion WHERE lname=? ORDER BY cdate DESC"); 
                                            pst.setString(1, lEmail); 
                                            ResultSet rs=pst.executeQuery(); 
                                            boolean has=false;
                                            while(rs.next()){ 
                                                has=true; 
                                        %>
                                        <tr class="border-light text-nowrap">
                                            <td class="ps-4 font-monospace text-muted small">#LOG-<%=rs.getInt(1)%></td>
                                            <td>
                                                <div class="fw-semibold text-dark"><%=rs.getString(2)%></div>
                                                <div class="text-muted" style="font-size: 10px;"><i class="bi bi-clock me-1"></i> <%=rs.getString(3)%></div>
                                                <div class="text-muted small mt-1 opacity-75 text-wrap" style="max-width:300px;">"<%=rs.getString(4)%>"</div>
                                            </td>
                                            <td>
                                                <div class="small fw-medium text-dark"><%=rs.getString(5)%></div>
                                            </td>
                                            <td class="text-end pe-4">
                                                <a href="../shared/chat.jsp?case_id=<%=rs.getInt(1)%>" class="btn btn-sm btn-outline-dark border-0">
                                                    <i class="bi bi-chat-dots-fill me-1"></i> Transcribe
                                                </a>
                                            </td>
                                        </tr>
                                        <% } if(!has){ %>
                                        <tr>
                                            <td colspan="4" class="text-center py-5 text-muted small opacity-50">
                                                <i class="bi bi-archive fs-2 d-block mb-2"></i>
                                                Archive is empty.
                                            </td>
                                        </tr>
                                        <% }
                                        }catch(Exception e){out.print("<tr><td colspan='4'>Error: "+e.getMessage()+"</td></tr>");} %>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
        
        <jsp:include page="../shared/_footer.jsp" />
    </div>
    <script>
        function filterTable(){
            const f=document.getElementById("arcSearch").value.toUpperCase(), tr=document.getElementById("arcTable").getElementsByTagName("tr");
            for(let i=1;i<tr.length;i++){ let t=tr[i].textContent||tr[i].innerText; tr[i].style.display=t.toUpperCase().indexOf(f)>-1?"":"none"; }
        }
    </script>
</body>
</html>

