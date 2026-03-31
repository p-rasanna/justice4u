<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*, com.j4u.DatabaseConfig, java.util.Date, java.text.SimpleDateFormat" %>
<%
    String email = (String) session.getAttribute("cname");
    if (email == null) { response.sendRedirect("../auth/cust_login.jsp"); return; }
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="components/_head.jsp"><jsp:param name="title" value="My Legal Schedule"/></jsp:include>
<body class="layout-fixed sidebar-expand-lg bg-body-tertiary">
    <div class="app-wrapper">
        <jsp:include page="components/_sidebar.jsp" />
        <main class="app-main">
            <jsp:include page="components/_topbar.jsp">
                <jsp:param name="title" value="Hearing Schedule"/>
                <jsp:param name="subtitle" value="Upcoming & Past Proceedings"/>
            </jsp:include>
            
            <div class="app-content pt-4">
                <div class="container-fluid">
                    <div class="row g-4">
                        <div class="col-lg-8 mx-auto">
                            <!-- Upcoming Hearings -->
                            <div class="card border-0 shadow-sm rounded-4 overflow-hidden mb-4">
                                <div class="card-header bg-white border-0 py-4 px-4">
                                    <h5 class="card-title fw-bold mb-0 text-serif"><i class="bi bi-calendar-event text-gold me-2"></i>Upcoming Proceedings</h5>
                                </div>
                                <div class="card-body p-0">
                                    <div class="list-group list-group-flush">
<%
    boolean hu=false, hp=false; StringBuilder pS = new StringBuilder();
    try(Connection con=DatabaseConfig.getConnection()){
        try(PreparedStatement ps=con.prepareStatement("SELECT h.*, c.title FROM hearings h JOIN casetb c ON h.case_id=c.cid JOIN cust_reg cr ON cr.cname=c.cname WHERE cr.email=? ORDER BY h.hearing_date ASC")){
            ps.setString(1,email); 
            try(ResultSet rs=ps.executeQuery()){
                String tS = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
                while(rs.next()){
                    String hD=rs.getDate("hearing_date").toString();
                    String hT=rs.getTime("hearing_time")!=null ? rs.getTime("hearing_time").toString() : ""; 
                    if(hT.length()>5) hT=hT.substring(0,5);
                    
                    boolean isP = hD.compareTo(tS)<0;
                    String bdg=""; 
                    if(hD.equals(tS)) {
                        bdg="<span class='badge bg-danger'>Today</span>";
                    } else if(!isP) {
                        bdg="<span class='badge bg-gold-subtle text-gold border border-warning-subtle text-uppercase fw-bold' style='font-size:0.6rem;'>Confirmed</span>";
                    }

                    String html = 
                        "<div class='list-group-item p-4 border-light " + (isP ? "bg-light opacity-75" : "bg-white") + "'>" +
                            "<div class='d-flex align-items-center gap-3'>" +
                                "<div class='flex-shrink-0 text-center text-muted px-3 border-end border-light'>" +
                                    "<div class='h4 mb-0 fw-bold'>" + hD.substring(8) + "</div>" +
                                    "<div class='small text-uppercase fw-bold' style='font-size:0.6rem;'>" + hD.substring(5,7) + "</div>" +
                                "</div>" +
                                "<div class='flex-grow-1 ms-2'>" +
                                    "<h6 class='mb-1 fw-bold text-serif h5'>" + rs.getString("title") + "</h6>" +
                                    "<div class='d-flex align-items-center gap-3 text-muted small'>" +
                                        "<span><i class='bi bi-clock me-1'></i> " + hT + "</span>" +
                                        "<span><i class='bi bi-bank me-1'></i> " + rs.getString("court_name") + "</span>" +
                                        "<span>" + bdg + "</span>" +
                                    "</div>" +
                                "</div>" +
                            "</div>" +
                        "</div>";

                    if(isP){ hp=true; pS.append(html); } 
                    else { hu=true; out.println(html); }
                }
            }
        }
    } catch(Exception e) { e.printStackTrace(); }
    
    if(!hu) out.println("<div class='p-5 text-center text-muted'><i class='bi bi-calendar-x display-4 opacity-10'></i><p class='mt-3'>No upcoming hearings on your schedule.</p></div>");
%>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Past Hearings -->
                            <% if(hp){ %>
                                <div class="card border-0 shadow-sm rounded-4 overflow-hidden mb-4 opacity-75">
                                    <div class="card-header bg-white border-0 py-3 px-4">
                                        <h6 class="card-title fw-bold mb-0 text-muted small text-uppercase ls-1">Past Records</h6>
                                    </div>
                                    <div class="card-body p-0">
                                        <div class="list-group list-group-flush">
                                            <%= pS.toString() %>
                                        </div>
                                    </div>
                                </div>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>
            <jsp:include page="components/_footer.jsp" />
        </main>
    </div>
</body>
</html>
