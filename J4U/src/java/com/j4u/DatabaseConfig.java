package com.j4u;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConfig {

    private static String getEnv(String key, String fallbackKey, String defaultValue) {
        String val = System.getenv(key);
        if (val != null && !val.isEmpty()) return val;
        // Try fallback key (Railway uses different env var names)
        if (fallbackKey != null) {
            val = System.getenv(fallbackKey);
            if (val != null && !val.isEmpty()) return val;
        }
        return defaultValue;
    }

    public static Connection getConnection() throws SQLException {
        // Primary keys: DB_HOST / DB_PORT / DB_NAME / DB_USER / DB_PASS
        // Fallback keys: Railway MySQL plugin uses MYSQLHOST / MYSQLPORT / MYSQLDATABASE / MYSQLUSER / MYSQLPASSWORD
        String dbHost = getEnv("DB_HOST",     "MYSQLHOST",     "localhost");
        String dbPort = getEnv("DB_PORT",     "MYSQLPORT",     "3306");
        String dbName = getEnv("DB_NAME",     "MYSQLDATABASE", "j4u");
        String dbUser = getEnv("DB_USER",     "MYSQLUSER",     "root");
        String dbPass = getEnv("DB_PASS",     "MYSQLPASSWORD", "");

        String url = "jdbc:mysql://" + dbHost + ":" + dbPort + "/" + dbName
                   + "?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC"
                   + "&connectTimeout=10000&socketTimeout=30000";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL JDBC Driver not found", e);
        }
        return DriverManager.getConnection(url, dbUser, dbPass);
    }
}