<%@page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*"%>
<%@ include file="db_connection.jsp" %>
<%
  String userEmail = (String) session.getAttribute("cname"); // Client email
  String userRole = "client";
  String caseId = request.getParameter("case");
  if (userEmail == null) {
    userEmail = (String) session.getAttribute("lname"); // Lawyer email
    userRole = "lawyer";
  }
  if (userEmail == null) {
    response.sendRedirect("cust_login.jsp");
    return;
  }
  if (caseId == null) {
    response.sendRedirect("viewcases.jsp");
    return;
  }
  // Get case and chat partner details
  String partnerEmail = "";
  String partnerName = "";
  String caseTitle = "";
  try {
    // Class.forName("com.mysql.jdbc.Driver");
    Connection con = getDatabaseConnection();
    // SECURITY PATCH: IDOR Protection (Case Ownership Check)
    boolean isAuthorized = false;
    if ("client".equals(userRole)) {
        // Check if case belongs to this client
        PreparedStatement psAuth = con.prepareStatement("SELECT COUNT(*) FROM casetb WHERE cid = ? AND cname = ?");
        psAuth.setInt(1, Integer.parseInt(caseId));
        psAuth.setString(2, userEmail);
        ResultSet rsAuth = psAuth.executeQuery();
        if (rsAuth.next() && rsAuth.getInt(1) > 0) isAuthorized = true;
        rsAuth.close();
        psAuth.close();
    } else {
        // Check if lawyer is assigned to this case
        // Logic: Check customer_cases table for assignment OR generic 'lawyer' access if simplified mode
        PreparedStatement psAuth = con.prepareStatement(
            "SELECT COUNT(*) FROM customer_cases cc " +
            "JOIN lawyer_reg lr ON cc.assigned_lawyer_id = lr.lid " +
            "WHERE cc.case_id = ? AND lr.email = ?"
        );
        psAuth.setInt(1, Integer.parseInt(caseId));
        psAuth.setString(2, userEmail);
        ResultSet rsAuth = psAuth.executeQuery();
        if (rsAuth.next() && rsAuth.getInt(1) > 0) isAuthorized = true;
        rsAuth.close();
        psAuth.close();
    }
    if (!isAuthorized) {
        response.sendRedirect("viewcases.jsp?error=UnauthorizedAccess");
        if (con != null) con.close();
        return;
    }
    // Get case details
    PreparedStatement ps = con.prepareStatement("SELECT title FROM casetb WHERE cid = ?");
    ps.setInt(1, Integer.parseInt(caseId));
    ResultSet rs = ps.executeQuery();
    if (rs.next()) {
      caseTitle = rs.getString("title");
    }
    rs.close();
    ps.close();
    // Get chat partner
    if ("client".equals(userRole)) {
      ps = con.prepareStatement("SELECT lname FROM lawyer_reg WHERE email = (SELECT cname FROM casetb WHERE cid = ?)");
      ps.setInt(1, Integer.parseInt(caseId));
      rs = ps.executeQuery();
      if (rs.next()) {
        partnerName = rs.getString("lname");
        partnerEmail = rs.getString("email");
      }
    } else {
      ps = con.prepareStatement("SELECT name FROM casetb WHERE cid = ?");
      ps.setInt(1, Integer.parseInt(caseId));
      rs = ps.executeQuery();
      if (rs.next()) {
        partnerName = rs.getString("name");
        partnerEmail = rs.getString("email");
      }
    }
    rs.close();
    ps.close();
    con.close();
  } catch (Exception e) {
    // Handle error
  }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Justice4U · Secure Chat</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <!-- Bootstrap 5 -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <!-- Inter font -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
  
</head>
<body>
  <div class="chat-container">
    <div class="chat-header">
      <div>
        <button class="back-btn" onclick="history.back()">â†</button>
      </div>
      <div style="text-align: center;">
        <h3>Case #<%= caseId %> Chat</h3>
        <div class="case-info">Chatting with <%= partnerName %></div>
      </div>
      <div></div>
    </div>
    <div class="security-notice">
      ðŸ”’ <strong>Secure Communication:</strong> This chat is encrypted and monitored. All messages are case-specific and confidential.
    </div>
    <div class="chat-messages" id="messagesContainer">
      <%
        try {
          Connection con = getDatabaseConnection();
          // Get messages for this case
          PreparedStatement ps = con.prepareStatement(
            "SELECT * FROM discussions WHERE case_id = ? ORDER BY timestamp ASC"
          );
          ps.setInt(1, Integer.parseInt(caseId));
          ResultSet rs = ps.executeQuery();
          boolean hasMessages = false;
          while (rs.next()) {
            hasMessages = true;
            String senderEmail = rs.getString("sender_email");
            String messageText = rs.getString("message_text");
            String timestamp = rs.getString("timestamp");
            String messageClass = senderEmail.equals(userEmail) ? "sent" : "received";
            String avatarText = senderEmail.equals(userEmail) ? String.valueOf(userEmail.charAt(0)) : String.valueOf(partnerEmail.charAt(0));
      %>
      <div class="message <%= messageClass %>">
        <div class="message-avatar"><%= avatarText %></div>
        <div>
          <div class="message-content"><%= messageText.replace("\n", "<br>") %></div>
          <div class="message-meta"><%= timestamp %></div>
        </div>
      </div>
      <%
          }
          if (!hasMessages) {
      %>
      <div class="no-messages">
        <p>No messages yet. Start the conversation!</p>
      </div>
      <%
          }
          rs.close();
          ps.close();
          con.close();
        } catch (Exception e) {
      %>
      <div class="no-messages">
        <p>Error loading messages: <%= e.getMessage() %></p>
      </div>
      <%
        }
      %>
    </div>
    <div class="chat-input-area">
      <form id="messageForm" action="send_message.jsp" method="post">
        <input type="hidden" name="case_id" value="<%= caseId %>">
        <input type="hidden" name="sender_email" value="<%= userEmail %>">
        <input type="hidden" name="sender_role" value="<%= userRole %>">
        <input type="hidden" name="receiver_email" value="<%= partnerEmail %>">
        <input type="hidden" name="receiver_role" value="<%= "client".equals(userRole) ? "lawyer" : "client" %>">
        <div class="chat-input-container">
          <textarea
            class="chat-input"
            name="message_text"
            placeholder="Type your message..."
            required
            rows="1"
            onkeydown="handleKeyPress(event)"
          ></textarea>
          <button type="submit" class="btn-send" id="sendBtn">
            <svg width="20" height="20" fill="currentColor" viewBox="0 0 20 20">
              <path d="M10.894 2.553a1 1 0 00-1.788 0l-7 14a1 1 0 001.169 1.409l5-1.429A1 1 0 009 15.571V11a1 1 0 112 0v5.571a1 1 0 00.725.962l5 1.428a1 1 0 001.17-1.409l-7-14z"/>
            </svg>
          </button>
        </div>
      </form>
    </div>
  </div>
  <script>
    // Auto-resize textarea
    const textarea = document.querySelector('.chat-input');
    textarea.addEventListener('input', function() {
      this.style.height = 'auto';
      this.style.height = Math.min(this.scrollHeight, 120) + 'px';
    });
    // Send on Enter (but allow Shift+Enter for new lines)
    function handleKeyPress(event) {
      if (event.key === 'Enter' && !event.shiftKey) {
        event.preventDefault();
        document.getElementById('messageForm').submit();
      }
    }
    // Scroll to bottom on load
    window.addEventListener('load', function() {
      const container = document.getElementById('messagesContainer');
      container.scrollTop = container.scrollHeight;
    });
    // Form validation
    document.getElementById('messageForm').addEventListener('submit', function(e) {
      const message = textarea.value.trim();
      if (!message) {
        e.preventDefault();
        return false;
      }
      // Disable send button to prevent double submission
      document.getElementById('sendBtn').disabled = true;
    });
  </script>
</body>
</html>
