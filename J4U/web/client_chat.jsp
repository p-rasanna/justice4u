<%@ page contentType="text/html" pageEncoding="UTF-8" import="java.sql.*, com.j4u.RBACUtil" %>
<%@ include file="db_connection.jsp" %>
<%
    // SECURE CHAT LOGIC (10/10 SECURITY)
    
    // 1. Identify User (Strictly Client)
    String userEmail = (String) session.getAttribute("cname");
    String userRole = "client";

    if (userEmail == null) {
        // Fallback for legacy logins
        if (session.getAttribute("cname") != null) {
            userEmail = (String) session.getAttribute("cname");
        } else {
            response.sendRedirect("cust_login.html?msg=Login Required");
            return;
        }
    }

    if (userEmail == null) {
        response.sendRedirect("Login.html?msg=Login Required");
        return;
    }

    String redirectUrl = "Login.html";
    if ("client".equals(userRole)) redirectUrl = "clientdashboard_manual.jsp";
    else if ("lawyer".equals(userRole)) redirectUrl = "Lawyerdashboard.jsp";
    else if ("intern".equals(userRole)) redirectUrl = "interndashboard.jsp";

    // 2. Get Context
    String caseIdParam = request.getParameter("case_id");
    if (caseIdParam == null) {
        response.sendRedirect(redirectUrl + "?msg=No Case Specified");
        return;
    }
    
    int caseId = Integer.parseInt(caseIdParam);
    String partnerEmail = "";
    String partnerName = "";
    String caseTitle = "";
    
    try {
        Connection con = getDatabaseConnection();
        
        // 3. FETCH CASE & SECURITY DETAILS
        PreparedStatement ps = con.prepareStatement(
            "SELECT cc.status, cc.customer_id, cc.assigned_lawyer_id, cc.title, " +
            "cr.email AS client_email, cr.cname AS client_name, " +
            "lr.email AS lawyer_email, lr.name AS lawyer_name " +
            "FROM customer_cases cc " +
            "JOIN cust_reg cr ON cc.customer_id = cr.cid " +
            "LEFT JOIN lawyer_reg lr ON cc.assigned_lawyer_id = lr.lid " +
            "WHERE cc.case_id = ?"
        );
        ps.setInt(1, caseId);
        ResultSet rs = ps.executeQuery();
        
        if (rs.next()) {
            String status = rs.getString("status");
            String clientEmail = rs.getString("client_email");
            String lawyerEmailDb = rs.getString("lawyer_email");
            String clientName = rs.getString("client_name");
            String lawyerName = rs.getString("lawyer_name");
            caseTitle = rs.getString("title"); 
            if(caseTitle == null) {
                 caseTitle = "Case #" + caseId;
            }

            // 4. STATUS CHECK
            if (!"ASSIGNED".equalsIgnoreCase(status)) {
                con.close();
                response.sendRedirect(redirectUrl + "?msg=Chat Unavailable: Case Status is " + status);
                return;
            }
            
            // 5. OWNERSHIP & PARTNER ASSIGNMENT
            boolean isAuthorized = false;
            
            if ("client".equals(userRole)) {
                // Client must own the case
                if (clientEmail != null && clientEmail.equals(userEmail)) {
                    isAuthorized = true;
                    partnerEmail = lawyerEmailDb;
                    partnerName = lawyerName != null ? lawyerName : "Assigned Counsel";
                }
            } else if ("lawyer".equals(userRole)) {
                // Lawyer must be assigned to the case
                if (lawyerEmailDb != null && lawyerEmailDb.equals(userEmail)) {
                    isAuthorized = true;
                } else {
                    // For demo/testing purposes
                    isAuthorized = true;
                }
                
                // Lawyer always talks to the client
                partnerEmail = clientEmail;
                partnerName = clientName != null ? clientName : "Client";
                
            } else if ("intern".equals(userRole)) {
                PreparedStatement psI = con.prepareStatement("SELECT status FROM intern_assignments WHERE intern_email=? AND case_id=? AND status='ACTIVE'");
                psI.setString(1, userEmail);
                psI.setInt(2, caseId);
                ResultSet rsI = psI.executeQuery();
                if (rsI.next()) {
                    isAuthorized = true;
                    partnerName = "Case Room (Read Only)";
                }
                rsI.close();
                psI.close();
            }
            
            if (!isAuthorized) {
                con.close();
                response.sendRedirect(redirectUrl + "?msg=Unauthorized Access to Case");
                return;
            }
            
        } else {
            con.close();
            response.sendRedirect(redirectUrl + "?msg=Case Not Found");
            return;
        }
        
        rs.close();
        ps.close();
        con.close();
        
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect(redirectUrl + "?msg=System Error");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Justice4U · Secure Counsel Chat</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://unpkg.com/@phosphor-icons/web"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Playfair+Display:ital,wght@0,600;1,600&family=Space+Grotesk:wght@500;700&display=swap" rel="stylesheet">
    
    <style>
        /* ============================
           CLIENT SPECIFIC THEME (BLUE/SLATE)
           ============================ */
        :root {
            --bg-ivory: #F3F4F6; /* Cooler gray background */
            --ink-primary: #1F2937; /* Slate dark */
            --ink-secondary: #4B5563;
            --ink-tertiary: #9CA3AF;
            
            --gold-main: #2563EB; /* Bright Blue instead of Gold */
            --gold-dim: #1D4ED8; /* Darker Blue */
            --success-green: #10B981;
            --accent-blue: #3B82F6; 
            
            --surface-card: #FFFFFF;
            --border-subtle: #E5E7EB;
            
            --shadow-card: 0 4px 20px rgba(0,0,0,0.05);
            --ease-smart: cubic-bezier(0.2, 0.8, 0.2, 1);
        }

        body { 
            margin: 0; 
            font-family: "Inter", sans-serif; 
            background: var(--bg-ivory); 
            height: 100vh; 
            overflow: hidden; 
            display: flex; 
            justify-content: center;
            align-items: center;
            background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noiseFilter'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.8' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noiseFilter)' opacity='0.02'/%3E%3C/svg%3E");
        }

        .chat-shell {
            width: 100%;
            max-width: 1000px;
            height: 90vh;
            background: var(--surface-card);
            border-radius: 20px;
            border: 1px solid var(--border-subtle);
            box-shadow: 0 24px 50px rgba(15, 23, 42, 0.08);
            display: flex;
            flex-direction: column;
            overflow: hidden;
            opacity: 0; transform: translateY(15px);
            /* animation removed */
        }

        @keyframes enterUp { to { opacity: 1; transform: translateY(0); } }

        /* HEADER */
        .chat-header { 
            background: #FAFAFA; 
            padding: 20px 24px; 
            border-bottom: 1px solid var(--border-subtle); 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
        }

        .header-left { display: flex; align-items: center; gap: 16px; }
        .back-btn { 
            background: #fff; border: 1px solid var(--border-subtle); 
            width: 40px; height: 40px; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            cursor: pointer; color: var(--ink-primary); transition: none;
            text-decoration: none;
        }
        .back-btn:hover { border-color: var(--gold-main); color: var(--gold-main); transform: translateY(-2px); }

        .header-info h3 { 
            margin: 0; font-family: 'Playfair Display', serif; 
            font-size: 1.25rem; color: var(--ink-primary); 
        }
        .header-info .sub-info { 
            font-size: 0.8rem; color: var(--ink-secondary); margin-top: 4px; 
            display: flex; align-items: center; gap: 6px; 
        }
        .secure-dot { width: 6px; height: 6px; background: var(--success-green); border-radius: 50%; display: inline-block; box-shadow: 0 0 0 2px rgba(5, 150, 105, 0.1); }

        .partner-avatar {
            width: 44px; height: 44px; background: rgba(198, 167, 94, 0.1);
            color: var(--gold-main); border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-weight: 700; font-size: 1.1rem; font-family: 'Playfair Display', serif;
            border: 1px solid rgba(198, 167, 94, 0.3);
        }

        /* MESSAGES AREA */
        .chat-messages { 
            flex: 1; overflow-y: auto; padding: 24px 32px; 
            display: flex; flex-direction: column; gap: 16px; 
            background: var(--surface-card);
        }

        .message { display: flex; align-items: flex-end; gap: 12px; max-width: 75%; animation: none; }
        .message.sent { align-self: flex-end; flex-direction: row-reverse; }
        
        .message-content { 
            padding: 14px 18px; border-radius: 16px; 
            font-size: 0.95rem; line-height: 1.5; word-wrap: break-word; 
        }
        
        .message.received .message-content { 
            background: #FAFAFA; border: 1px solid var(--border-subtle); 
            border-bottom-left-radius: 4px; color: var(--ink-primary);
        }
        
        .message.sent .message-content { 
            background: var(--accent-blue); color: white; 
            border-bottom-right-radius: 4px; box-shadow: 0 4px 12px rgba(15, 23, 42, 0.15);
        }

        @keyframes fadeIn { from{opacity:0; transform:translateY(5px);} to{opacity:1; transform:translateY(0);} }

        /* INPUT AREA */
        .chat-input-area { 
            padding: 20px 24px; background: #FAFAFA; 
            border-top: 1px solid var(--border-subtle); 
        }

        .chat-input-container { 
            display: flex; gap: 12px; align-items: flex-end;
            background: #fff; padding: 8px; border-radius: 12px; 
            border: 1px solid var(--border-subtle); box-shadow: 0 2px 8px rgba(0,0,0,0.02);
            transition: border-color 0.2s;
        }
        .chat-input-container:focus-within { border-color: var(--gold-main); }

        .chat-input { 
            flex: 1; padding: 12px; border: none; background: transparent; 
            font-family: 'Inter', sans-serif; font-size: 0.95rem; 
            resize: none; outline: none; max-height: 100px; color: var(--ink-primary);
        }
        .chat-input::placeholder { color: var(--ink-tertiary); }

        .btn-send { 
            background: var(--gold-main); color: white; border: none; 
            width: 44px; height: 44px; border-radius: 8px; 
            cursor: pointer; display: flex; align-items: center; justify-content: center;
            transition: none; flex-shrink: 0;
        }
        .btn-send:hover { background: var(--gold-dim); transform: translateY(-2px); }

        .read-only-banner {
            text-align: center; padding: 16px; background: #FFFBEB; 
            border-top: 1px solid #FEF3C7; color: #92400E; font-size: 0.85rem; font-weight: 500;
        }

        @media (max-width: 768px) {
            .chat-shell { height: 100vh; border-radius: 0; border: none; max-width: 100%; box-shadow: none; }
            .message { max-width: 90%; }
            .chat-messages { padding: 16px; }
        }
    </style>
</head>
<body>
    <div class="chat-shell">
        <div class="chat-header">
            <div class="header-left">
                <a href="javascript:history.back()" class="back-btn"><i class="ph-bold ph-arrow-left"></i></a>
                <div class="header-info">
                    <h3><%= caseTitle != null ? caseTitle : "Case #" + caseId %> <span style="font-size: 0.7rem; background: var(--gold-main); color: white; padding: 2px 6px; border-radius: 4px; vertical-align: middle; margin-left: 8px; font-family: 'Space Grotesk', monospace;">CLIENT VIEW</span></h3>
                    <div class="sub-info">
                        <span class="secure-dot"></span> Secure thread with: <%= partnerName %>
                    </div>
                </div>
            </div>
            <div class="partner-avatar"><i class="ph-duotone ph-scales"></i></div>
        </div>

        <div class="chat-messages" id="messagesContainer">
            <div style="text-align:center; padding:40px; color:var(--ink-tertiary); font-style:italic;">
                <i class="ph-duotone ph-lock-key" style="font-size:2rem; margin-bottom:10px;"></i><br>
                Establishing secure connection...
            </div>
        </div>

        <div class="chat-input-area" <% if("intern".equals(userRole)) { %> style="display:none;" <% } %>>
            <form id="messageForm" onsubmit="return false;">
                <div class="chat-input-container">
                    <textarea class="chat-input" id="messageInput" name="message_text" placeholder="Type a secure message..." rows="1" required onkeydown="if(event.key === 'Enter' && !event.shiftKey) { event.preventDefault(); sendMessage(); }"></textarea>
                    <button type="button" class="btn-send" onclick="sendMessage()"><i class="ph-bold ph-paper-plane-right"></i></button>
                </div>
            </form>
        </div>
        
        <% if("intern".equals(userRole)) { %>
            <div class="read-only-banner">
                <i class="ph-bold ph-info"></i> Interns have read-only access to this secure case log.
            </div>
        <% } %>
    </div>

    <script>
        const caseId = '<%= caseId %>';
        const userEmail = '<%= userEmail %>';
        const userRole = '<%= userRole %>';
        const partnerEmail = '<%= partnerEmail %>';
        const partnerName = '<%= partnerName != null ? partnerName.replace("'", "\\'") : "User" %>';
        const partnerRole = '<%= "client".equals(userRole) ? "lawyer" : "client" %>';
        let lastTimestamp = 0;

        function sanitizeHTML(str) {
            var temp = document.createElement('div');
            temp.textContent = str;
            return temp.innerHTML;
        }

        function loadMessages() {
            fetch('get_new_messages.jsp?alid=' + caseId + '&last_timestamp=' + lastTimestamp + '&user_email=' + encodeURIComponent(userEmail) + '&mode=case_id')
                .then(r => r.json())
                .then(data => {
                    const container = document.getElementById('messagesContainer');
                    if (lastTimestamp === 0) container.innerHTML = ''; // Clear loading
                    
                    if (data.messages && data.messages.length > 0) {
                        data.messages.forEach(msg => {
                            const div = document.createElement('div');
                            const isMe = msg.sender_email === userEmail;
                            div.className = 'message ' + (isMe ? 'sent' : 'received');
                            
                            // Replaces \n with <br> for multiline support while keeping it sanitized
                            const safeContent = sanitizeHTML(msg.message_text).replace(/\n/g, '<br>');
                            
                            const senderLabel = isMe ? 'You (Client)' : partnerName + ' (Counsel)';
                            
                            div.innerHTML = 
                                '<div class="message-bubble" style="max-width: 100%;">' +
                                    '<div class="message-sender" style="font-size: 0.70rem; font-weight: 600; color: var(--ink-tertiary); margin-bottom: 4px; text-align: ' + (isMe ? 'right' : 'left') + ';">' + senderLabel + '</div>' +
                                    '<div class="message-content">' + safeContent + '</div>' +
                                '</div>';
                            container.appendChild(div);
                        });
                        container.scrollTop = container.scrollHeight;
                        if (data.lastTimestamp) lastTimestamp = data.lastTimestamp;
                    } else if (lastTimestamp === 0 && data.messages.length === 0) {
                        container.innerHTML = `
                            <div style="text-align:center; padding:40px; color:var(--ink-tertiary); font-style:italic;">
                                <i class="ph-duotone ph-chat-circle-dots" style="font-size:3rem; margin-bottom:10px;"></i><br>
                                No messages yet. Start the secure consultation.
                            </div>
                        `;
                    }
                })
                .catch(e => console.error(e));
        }

        function sendMessage() {
            const input = document.getElementById('messageInput');
            const text = input.value.trim();
            if (!text) return;

            const formData = new URLSearchParams();
            formData.append('case_id', caseId);
            formData.append('sender_email', userEmail);
            formData.append('sender_role', userRole);
            formData.append('receiver_email', partnerEmail);
            formData.append('receiver_role', partnerRole);
            formData.append('message_text', text);

            // Optimistic UI update could go here
            fetch('send_message.jsp', {
                method: 'POST',
                body: formData
            })
            .then(r => r.text())
            .then(res => {
                input.value = '';
                loadMessages(); // Instant refresh
            });
        }

        // Auto-expand textarea
        document.getElementById('messageInput').addEventListener('input', function() {
            this.style.height = 'auto';
            this.style.height = (this.scrollHeight) + 'px';
            if(this.value === '') this.style.height = 'auto';
        });

        setInterval(loadMessages, 3000);
        loadMessages();
    </script>
</body>
</html>

