package com.j4u;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConfig {

    private static String getEnv(String key, String defaultValue) {
        String val = System.getenv(key);
        return (val != null && !val.isEmpty()) ? val : defaultValue;
    }

    public static Connection getConnection() throws SQLException {
        String dbHost = getEnv("DB_HOST", "localhost");
        String dbPort = getEnv("DB_PORT", "3306");
        String dbName = getEnv("DB_NAME", "j4u");
        String dbUser = getEnv("DB_USER", "root");
        String dbPass = getEnv("DB_PASS", "");

        String url = "jdbc:mysql://" + dbHost + ":" + dbPort + "/" + dbName
                   + "?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL JDBC Driver not found", e);
        }
        return DriverManager.getConnection(url, dbUser, dbPass);
    }
}