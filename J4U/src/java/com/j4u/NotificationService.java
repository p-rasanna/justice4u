package com.j4u;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
public class NotificationService {
  public static void create(String userEmail, String message, String type, String link) {
    String sql = "INSERT INTO notifications (user_email, message, type, link) VALUES (?, ?, ?, ?)";
    try (Connection con = DatabaseConfig.getConnection();
       PreparedStatement ps = con.prepareStatement(sql)) {
      ps.setString(1, userEmail);
      ps.setString(2, message);
      ps.setString(3, type);
      ps.setString(4, link);
      ps.executeUpdate();
    } catch (SQLException e) {
      System.err.println("Error creating notification: " + e.getMessage());
    }
  }
  public static void create(String userEmail, String message) {
    create(userEmail, message, "general", null);
  }
  public static int getUnreadCount(String userEmail) {
    int count = 0;
    if (userEmail == null || userEmail.trim().isEmpty()) {
      return count;
    }
    String sql = "SELECT COUNT(*) FROM notifications WHERE user_email = ? AND is_read = 0";
    try (Connection con = DatabaseConfig.getConnection();
       PreparedStatement ps = con.prepareStatement(sql)) {
      ps.setString(1, userEmail);
      try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
          count = rs.getInt(1);
        }
      }
    } catch (SQLException e) {
      System.err.println("Error getting unread count: " + e.getMessage());
    }
    return count;
  }
}