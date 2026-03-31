<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="com.j4u.DatabaseConfig" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    String myEmail = null;
    String myRole = null;
    if (session.getAttribute("cname") != null) { myEmail = (String) session.getAttribute("cname"); myRole = "client"; }
    else if (session.getAttribute("lname") != null) { myEmail = (String) session.getAttribute("lname"); myRole = "lawyer"; }
    else if (session.getAttribute("iname") != null) { myEmail = (String) session.getAttribute("iname"); myRole = "intern"; }

    if (myEmail == null) {
        response.sendRedirect("../auth/Login.jsp");
        return;
    }

    String caseIdStr = request.getParameter("case_id");
    if (caseIdStr == null || caseIdStr.trim().isEmpty()) {
        if ("client".equals(myRole)) response.sendRedirect("../client/clientdashboard.jsp");
        else if ("lawyer".equals(myRole)) response.sendRedirect("../lawyer/Lawyerdashboard.jsp");
        else response.sendRedirect("../intern/Interndashboard.jsp");
        return;
    }

    int caseId;
    try {
        caseId = Integer.parseInt(caseIdStr);
    } catch (NumberFormatException e) {
        response.sendRedirect("../shared/error.jsp");
        return;
    }

    String otherEmail = null, otherRole = null, caseTitle = "Case Chat";
    
    try (Connection con = DatabaseConfig.getConnection()) {
        try (PreparedStatement ps = con.prepareStatement("SELECT title FROM casetb WHERE cid=?")) {
            ps.setInt(1, caseId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) caseTitle = rs.getString("title");
            }
        }
        
        if ("client".equals(myRole)) {
            try (PreparedStatement ps = con.prepareStatement("SELECT lname FROM allotlawyer WHERE cid=?")) {
                ps.setInt(1, caseId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        otherEmail = rs.getString("lname");
                        otherRole = "lawyer";
                    }
                }
            }
        } else if ("lawyer".equals(myRole)) {
            try (PreparedStatement ps = con.prepareStatement("SELECT cname FROM casetb WHERE cid=?")) {
                ps.setInt(1, caseId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        otherEmail = rs.getString("cname");
                        otherRole = "client";
                    }
                }
            }
        } else if ("intern".equals(myRole)) {
            try (PreparedStatement ps = con.prepareStatement("SELECT lr.email FROM intern_assignments ia JOIN lawyer_reg lr ON ia.alid=lr.lid WHERE ia.intern_email=? AND ia.case_id=? LIMIT 1")) {
                ps.setString(1, myEmail);
                ps.setInt(2, caseId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        otherEmail = rs.getString("email");
                        otherRole = "lawyer";
                    }
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <% if ("client".equals(myRole)) { %>
        <jsp:include page="../client/components/_head.jsp" />
    <% } else if ("lawyer".equals(myRole)) { %>
        <jsp:include page="../lawyer/components/_head.jsp" />
    <% } else { %>
        <jsp:include page="../intern/components/_head.jsp" />
    <% } %>
    <title>Chat - <%= caseTitle %></title>
    
</head>
<body>
    <div class="app-layout">
        <% if ("client".equals(myRole)) { %>
            <jsp:include page="../client/components/_sidebar.jsp" />
        <% } else if ("lawyer".equals(myRole)) { %>
            <jsp:include page="../lawyer/components/_sidebar.jsp" />
        <% } else { %>
            <jsp:include page="../intern/components/_sidebar.jsp" />
        <% } %>
        <main class="main-content">
            <div class="container-fluid">
                <div class="card shadow">
                    <div class="card-header bg-white py-3 d-flex align-items-center">
                        <h6 class="m-0 font-weight-bold text-dark"><i class="ph ph-chat-circle-dots me-2"></i><%= caseTitle %> Chat</h6>
                    </div>
                    <div class="card-body p-0">
                        <div class="chat-container d-flex flex-column" id="chatBox">
<%
    int lastId = 0;
    boolean hasMessages = false;
    try (Connection con = DatabaseConfig.getConnection()) {
        try (PreparedStatement ps = con.prepareStatement("SELECT id, sender_email, sender_role, message_text, timestamp FROM discussions WHERE case_id=? ORDER BY timestamp ASC LIMIT 100")) {
            ps.setInt(1, caseId);
            try (ResultSet rs = ps.executeQuery()) {
                SimpleDateFormat sdf = new SimpleDateFormat("HH:mm");
                while (rs.next()) {
                    hasMessages = true;
                    lastId = rs.getInt("id");
                    String text = rs.getString("message_text");
                    boolean isOwn = rs.getString("sender_email").equals(myEmail);
                    String role = rs.getString("sender_role");
                    String time = sdf.format(rs.getTimestamp("timestamp"));
%>
                            <div class="chat-bubble <%= isOwn ? "own" : "other" %>">
                                <span class="chat-meta"><%= role.toUpperCase() %></span>
                                <div><%= text.replace("<", "&lt;").replace(">", "&gt;").replace("\n", "<br>") %></div>
                                <span class="chat-time"><%= time %></span>
                            </div>
<%
                }
            }
        }
    } catch (Exception e) {}
    if (!hasMessages) {
%>
                            <div class="text-center text-muted mt-5" id="emptyState">
                                <i class="ph ph-chat-centered-text" style="font-size:3rem"></i>
                                <p>No conversation yet &mdash; send a message to start.</p>
                            </div>
<%
    }
%>
                        </div>
                        <div class="card-footer bg-light p-3">
                            <div class="input-group">
                                <textarea id="msgInput" class="form-control" rows="2" placeholder="Type your message..." style="resize:none;"></textarea>
                                <button class="btn btn-dark px-4" id="sendBtn" type="button"><i class="ph ph-paper-plane-right pe-2"></i>Send</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <script>
        const caseId = <%= caseId %>;
        const myEmail = "<%= myEmail %>";
        const myRole = "<%= myRole %>";
        const otherEmail = "<%= otherEmail != null ? otherEmail : "" %>";
        const otherRole = "<%= otherRole != null ? otherRole : "" %>";
        let lastId = <%= lastId %>;

        const chatBox = document.getElementById('chatBox');
        const msgInput = document.getElementById('msgInput');
        const sendBtn = document.getElementById('sendBtn');
        const emptyState = document.getElementById('emptyState');

        function appendMessage(sender, role, text, time, isOwn) {
            if (emptyState) emptyState.remove();
            
            const div = document.createElement('div');
            div.className = 'chat-bubble ' + (isOwn ? 'own' : 'other');
            
            const meta = document.createElement('span');
            meta.className = 'chat-meta';
            meta.innerText = role.toUpperCase();
            
            const txt = document.createElement('div');
            txt.innerHTML = text.replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/\n/g, "<br>");
            
            const tm = document.createElement('span');
            tm.className = 'chat-time';
            tm.innerText = time;
            
            div.appendChild(meta);
            div.appendChild(txt);
            div.appendChild(tm);
            
            chatBox.appendChild(div);
            scrollToBottom();
        }

        function scrollToBottom() {
            chatBox.scrollTop = chatBox.scrollHeight;
        }

        function sendMessage() {
            const text = msgInput.value.trim();
            if (!text) return;

            const params = new URLSearchParams();
            params.append('case_id', caseId);
            params.append('message_text', text);
            if (otherEmail) params.append('receiver_email', otherEmail);
            if (otherRole) params.append('receiver_role', otherRole);

            fetch('../shared/send_message.jsp', {
                method: 'POST',
                body: params
            })
            .then(r => r.text())
            .then(result => {
                if (result.startsWith('success')) {
                    const parts = result.split(':');
                    if (parts.length > 1) {
                        lastId = Math.max(lastId, parseInt(parts[1]));
                    }
                    const now = new Date();
                    const hours = String(now.getHours()).padStart(2, '0');
                    const mins = String(now.getMinutes()).padStart(2, '0');
                    appendMessage(myEmail, myRole, text, hours + ':' + mins, true);
                    msgInput.value = '';
                } else {
                    alert('Error: ' + result);
                }
            })
            .catch(e => console.error(e));
        }

        sendBtn.addEventListener('click', sendMessage);
        msgInput.addEventListener('keydown', (e) => {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                sendMessage();
            }
        });

        setInterval(() => {
            fetch(`../shared/get_messages.jsp?case_id=${caseId}&last_id=${lastId}`)
                .then(r => r.json())
                .then(msgs => {
                    msgs.forEach(m => {
                        if (m.id > lastId) {
                            appendMessage(m.sender, m.role, m.text, m.time, m.isOwn);
                            lastId = m.id;
                        }
                    });
                })
                .catch(e => console.error(e));
        }, 4000);

        scrollToBottom();
    </script>
</body>
</html>
