<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
    /**
     * Database connection utility for JSP pages
     * Provides getDatabaseConnection() method that returns a Connection object
     */
    
    public Connection getDatabaseConnection() throws SQLException, ClassNotFoundException {
        return DatabaseConfig.getConnection();
    }
%>
