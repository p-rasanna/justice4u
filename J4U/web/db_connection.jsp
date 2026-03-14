<%@ page import="java.sql.*" %>
<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>

<%!
/**
 * Database connection utility for JSP pages
 * Supports environment variables and JNDI lookup for production deployment
 */
public static Connection getDatabaseConnection() throws SQLException {
    return com.j4u.DatabaseConfig.getConnection();
}
%>
