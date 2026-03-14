package com.j4u;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

/**
 * Centralized database configuration utility for Justice4U platform.
 * Supports both environment variables and JNDI datasource lookup for production
 * deployment.
 */
public class DatabaseConfig {

    private static final String DEFAULT_DB_URL = "jdbc:mysql://localhost:3306/j4u";
    private static final String DEFAULT_DB_USERNAME = "root";
    private static final String DEFAULT_DB_PASSWORD = "";

    private static final String JNDI_NAME = "java:comp/env/jdbc/j4u";

    /**
     * Get database connection using environment variables or JNDI fallback.
     * Priority: Environment variables > JNDI > Default hardcoded (for development
     * only)
     *
     * @return Database connection
     * @throws SQLException if connection cannot be established
     */
    public static Connection getConnection() throws SQLException {
        // Try environment variables first (production preferred)
        String dbUrl = System.getenv("DB_URL");
        String dbUsername = System.getenv("DB_USERNAME");
        String dbPassword = System.getenv("DB_PASSWORD");

        String driverClass = "com.mysql.cj.jdbc.Driver";

        if (dbUrl != null && !dbUrl.trim().isEmpty()) {
            try {
                Class.forName(driverClass);
                return DriverManager.getConnection(dbUrl, dbUsername, dbPassword);
            } catch (ClassNotFoundException e) {
                // Fallback to legacy driver
                try {
                    Class.forName("com.mysql.jdbc.Driver");
                    return DriverManager.getConnection(dbUrl, dbUsername, dbPassword);
                } catch (ClassNotFoundException ex) {
                    throw new SQLException("MySQL JDBC driver not found", ex);
                }
            }
        }

        // Try JNDI lookup (Tomcat-managed datasource)
        try {
            Context ctx = new InitialContext();
            DataSource ds = (DataSource) ctx.lookup(JNDI_NAME);
            return ds.getConnection();
        } catch (NamingException e) {
            // System.out.println("JNDI datasource not found, using default connection
            // (development mode)");
        }

        // Default connection for development
        try {
            try {
                Class.forName(driverClass);
            } catch (ClassNotFoundException e) {
                Class.forName("com.mysql.jdbc.Driver");
            }
            return DriverManager.getConnection(DEFAULT_DB_URL, DEFAULT_DB_USERNAME, DEFAULT_DB_PASSWORD);
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL JDBC driver not found", e);
        }
    }

    /**
     * Get database URL from environment or default
     */
    public static String getDatabaseUrl() {
        String dbUrl = System.getenv("DB_URL");
        return (dbUrl != null && !dbUrl.trim().isEmpty()) ? dbUrl : DEFAULT_DB_URL;
    }

    /**
     * Get database username from environment or default
     */
    public static String getDatabaseUsername() {
        String dbUsername = System.getenv("DB_USERNAME");
        return (dbUsername != null && !dbUsername.trim().isEmpty()) ? dbUsername : DEFAULT_DB_USERNAME;
    }

    /**
     * Get database password from environment or default
     */
    public static String getDatabasePassword() {
        String dbPassword = System.getenv("DB_PASSWORD");
        return (dbPassword != null) ? dbPassword : DEFAULT_DB_PASSWORD;
    }
}
