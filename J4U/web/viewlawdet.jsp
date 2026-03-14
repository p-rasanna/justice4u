<%-- 
    Document   : viewlawyers
    Created on : 3 Apr, 2025, 8:15:04 PM
    Author     : ZulkiflMugad
--%>


<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*"%>
<%@include file="db_connection.jsp" %>
<%!
    String safeEncode(String input) {
        if (input == null) return "";
        return input.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#x27;");
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Lawyers</title>
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css">
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"></script>
    <style>
 .table {
    width: 100%;
    background: white;
    border-radius: 8px;
    overflow: hidden;
    box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.1);
}
.table th {
    background: #007bff;
    color: white;
    padding: 10px;
}

.table-hover tbody tr:hover {
    background: #f1f1f1;
}
.btn-primary {
    background: #007bff;
    border: none;
    padding: 10px 20px;
    border-radius: 5px;
    font-size: 16px;
}
.btn-primary:hover {
    background: blueviolet;
}

</style>
    </head>
    <body>
        <table class="table table-hover">
            <tr>
                <th>Customer Id</th>
                <th>Customer Name</th>
                <th>Email</th>
                <th>Date Of Birth</th>
                <th>Mobile Number :</th>
                <th>Aadhar Number :</th>
                <th>Current Address</th>
                <th>Permanent Address</th>
                    
            </tr>
            <%
                try
                {
                    Connection con = getDatabaseConnection();
                    String id = request.getParameter("id");
                    if (id == null || id.trim().isEmpty()) {
                        id = "";
                    }
                    
                    PreparedStatement pst = con.prepareStatement("SELECT * FROM lawyer_reg WHERE email=?");
                    pst.setString(1, id);
                    ResultSet rs = pst.executeQuery();
        while(rs.next())
        {
            out.println("<tr>");
            int aa=rs.getInt(1);
            // Output encoding to prevent XSS
// Output encoding to prevent XSS is handled by the method defined above
            out.println("<td>"+safeEncode(String.valueOf(aa)));
            out.println("<td>"+rs.getString(2));
            out.println("<td>"+rs.getString(3));
            out.println("<td>"+rs.getString(5));
            out.println("<td>"+rs.getString(6));
            out.println("<td>"+rs.getString(7));
            out.println("<td>"+rs.getString(8));
            out.println("<td>"+rs.getString(9));
               }
        
                }
                catch(Exception e)
                {
                    out.println(e);
                }
            %>
        </table>
        <p align="center"><a href="customerdashboard.jsp" class="btn btn-primary">Dashboard</a>  &nbsp;  &nbsp; <a href="asignout.jsp" class="btn btn-primary" style="background-color: red;">Sign Out</a> &nbsp;  &nbsp; 
    </body>
</html>
