<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,com.j4u.DatabaseConfig" %>
<%
        <% if(request.getParameter("msg") != null) { %>
          <div class="alert alert-success alert-dismissible fade show border-0 mb-3" style="border-left: 4px solid var(--success) !important;">
            <i class="bi bi-check-circle-fill me-2"></i><%= request.getParameter("msg") %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
          </div>
        <% } %>
        <% if(request.getParameter("error") != null) { %>
          <div class="alert alert-danger alert-dismissible fade show border-0 mb-3" style="border-left: 4px solid var(--error) !important;">
            <i class="bi bi-exclamation-triangle-fill me-2"></i><%= request.getParameter("error") %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
          </div>
        <% } %>
        <div class="card border-0 mb-4" style="background: linear-gradient(135deg, #111827 0%, #1f2937 100%);">
          <div class="card-body p-4 text-white">
            <div class="row align-items-center">
              <div class="col-lg-8">
                <div class="d-flex align-items-center gap-2 mb-2">
                  <span class="badge fw-normal px-2 py-1" style="background:var(--gold);color:#111827;font-size:0.7rem;">#<%= caseId %></span>
                  <span class="badge bg-white bg-opacity-10 fw-normal px-2 py-1" style="font-size:0.7rem;"><%= caseCourt %></span>
                </div>
                <h4 class="text-serif fw-bold mb-1"><%= caseTitle %></h4>
                <p class="small opacity-75 mb-0">
                  <i class="bi bi-geo-alt me-1"></i><%= caseCity %>
                  <span class="mx-2">·</span>
                  <i class="bi bi-chat-dots me-1"></i><%= messages.size() %> message(s)
                </p>
              </div>
              <div class="col-lg-4 text-lg-end mt-3 mt-lg-0">
                <button onclick="document.getElementById('composeArea').scrollIntoView({behavior:'smooth'})" class="btn btn-sm px-4 py-2 fw-semibold" style="background:var(--gold);color:#111827;border:none;">
                  <i class="bi bi-pencil-square me-2"></i>New Message
                </button>
              </div>
            </div>
          </div>
        </div>
        <div class="row g-4">
          <div class="col-lg-8">
            <div class="card border-0">
              <div class="card-header bg-transparent border-0 py-3 px-4">
                <h5 class="card-title fw-bold mb-0 text-serif">
                  <i class="bi bi-chat-left-text me-2" style="color:var(--gold);"></i>Discussion Thread
                </h5>
              </div>
              <div class="card-body px-4 pb-4 pt-0">
                <% if (messages.isEmpty()) { %>
                  <div class="text-center py-5">
                    <i class="bi bi-chat-square-dots display-4 text-muted opacity-25"></i>
                    <h6 class="fw-bold text-serif mt-3">No Messages Yet</h6>
                    <p class="text-muted small mx-auto" style="max-width: 300px;">
                      Start the discussion by sending the first message about this case.
                    </p>
                  </div>
                <% } else { %>
                  <% for (int i = 0; i < messages.size(); i++) {
                    String[] msg = messages.get(i);
                    String msgSender = msg[0];
                    String msgRole = msg[1];
                    String msgText = msg[2];
                    String msgFileName = msg[3];
                    String msgFilePath = msg[4];
                    String msgTime = msg[5];
                    String msgDisplayName = msg[6];
                    boolean isOwnMessage = senderEmail.equals(msgSender);
                    String roleBadge, roleIcon;
                    if ("client".equals(msgRole)) { roleBadge = "bg-primary-subtle text-primary"; roleIcon = "bi-person"; }
                    else if ("lawyer".equals(msgRole)) { roleBadge = "background:var(--gold-light);color:var(--gold-dark);"; roleIcon = "bi-briefcase"; }
                    else if ("intern".equals(msgRole)) { roleBadge = "bg-info-subtle text-info"; roleIcon = "bi-mortarboard"; }
                    else { roleBadge = "bg-dark-subtle text-dark"; roleIcon = "bi-shield-check"; }
                    boolean isCSS = roleBadge.contains(":");
                  %>
                    <div class="mb-4 pb-4 <%= (i < messages.size()-1) ? "border-bottom" : "" %>" style="<%= (i < messages.size()-1) ? "border-color:rgba(0,0,0,0.04) !important;" : "" %>">
                      <div class="d-flex align-items-center gap-3 mb-2">
                        <div class="rounded-circle d-flex align-items-center justify-content-center fw-bold text-serif text-white" style="width:38px; height:38px; background:<%= isOwnMessage ? "var(--gold)" : "#111827" %>; font-size:0.85rem;">
                          <%= msgDisplayName.substring(0,1).toUpperCase() %>
                        </div>
                        <div class="flex-grow-1">
                          <div class="d-flex align-items-center gap-2">
                            <span class="fw-bold small"><%= msgDisplayName %></span>
                            <span class="badge fw-normal px-2 py-1 <%= isCSS ? "" : roleBadge %>" style="font-size:0.6rem; <%= isCSS ? roleBadge : "" %>">
                              <i class="bi <%= roleIcon %> me-1"></i><%= msgRole.substring(0,1).toUpperCase() + msgRole.substring(1) %>
                            </span>
                            <% if (isOwnMessage) { %>
                              <span class="badge bg-light text-muted fw-normal px-2 py-1" style="font-size:0.6rem;">You</span>
                            <% } %>
                          </div>
                          <span class="text-muted" style="font-size:0.7rem;"><i class="bi bi-clock me-1"></i><%= msgTime %></span>
                        </div>
                      </div>
                      <div class="ms-5 ps-1">
                        <% if (msgText != null && !msgText.isEmpty()) { %>
                          <p class="mb-2" style="line-height:1.7; white-space:pre-wrap;"><%= msgText %></p>
                        <% } %>
                        <% if (msgFileName != null && !msgFileName.isEmpty()) { %>
                          <a href="${pageContext.request.contextPath}/<%= msgFilePath %>" target="_blank" class="d-inline-flex align-items-center gap-2 px-3 py-2 rounded-3 text-decoration-none" style="background:var(--bg); border: 1px solid rgba(0,0,0,0.06);">
                            <% if (msgFileName.toLowerCase().endsWith(".pdf")) { %>
                              <i class="bi bi-file-earmark-pdf fs-5 text-danger"></i>
                            <% } else if (msgFileName.toLowerCase().matches(".*\\.(jpg|jpeg|png|gif)")) { %>
                              <i class="bi bi-file-earmark-image fs-5 text-success"></i>
                            <% } else if (msgFileName.toLowerCase().matches(".*\\.(doc|docx)")) { %>
                              <i class="bi bi-file-earmark-word fs-5 text-primary"></i>
                            <% } else { %>
                              <i class="bi bi-file-earmark fs-5 text-muted"></i>
                            <% } %>
                            <div>
                              <div class="small fw-semibold text-dark"><%= msgFileName %></div>
                              <div class="text-muted" style="font-size:0.65rem;">Click to download</div>
                            </div>
                            <i class="bi bi-download text-muted ms-2"></i>
                          </a>
                        <% } %>
                      </div>
                    </div>
                  <% } %>
                <% } %>
              </div>
            </div>
            <div class="card border-0 mt-4" id="composeArea">
              <div class="card-header bg-transparent border-0 py-3 px-4">
                <h5 class="card-title fw-bold mb-0 text-serif">
                  <i class="bi bi-pencil-square me-2" style="color:var(--gold);"></i>Send Message
                </h5>
              </div>
              <div class="card-body px-4 pb-4 pt-0">
                <form action="${pageContext.request.contextPath}/SendMessageServlet" method="post" enctype="multipart/form-data">
                  <input type="hidden" name="case_id" value="<%= caseId %>">
                  <div class="mb-3">
                    <label for="messageText" class="form-label small fw-bold">Your Message</label>
                    <textarea id="messageText" name="message_text" class="form-control" rows="4"
                          placeholder="Type your message regarding this case..." style="resize:vertical;"></textarea>
                  </div>
                  <div class="mb-3">
                    <label for="attachment" class="form-label small fw-bold">Attach File <span class="fw-normal text-muted">(Optional)</span></label>
                    <input type="file" id="attachment" name="attachment" class="form-control"
                         accept=".pdf,.jpg,.jpeg,.png,.gif,.doc,.docx,.xls,.xlsx,.txt">
                    <div class="form-text small" style="font-size:0.7rem;">
                      Allowed: PDF, Images, Word, Excel, Text. Max 10MB.
                    </div>
                  </div>
                  <div class="d-flex align-items-center justify-content-between">
                    <div class="text-muted small">
                      Sending as <strong><%= senderDisplayName %></strong>
                      <span class="badge bg-dark-subtle text-dark fw-normal ms-1" style="font-size:0.6rem;"><%= senderRole %></span>
                    </div>
                    <button type="submit" class="btn px-4 py-2 fw-semibold" style="background:var(--gold);color:#111827;border:none;">
                      <i class="bi bi-send me-2"></i>Send Message
                    </button>
                  </div>
                </form>
              </div>
            </div>
          </div>
          <div class="col-lg-4">
            <div class="card border-0 mb-4">
              <div class="card-header bg-transparent border-0 py-3 px-4">
                <h5 class="card-title fw-bold mb-0 text-serif">
                  <i class="bi bi-info-circle me-2" style="color:var(--gold);"></i>Case Info
                </h5>
              </div>
              <div class="card-body px-4 pb-4 pt-0">
                <div class="mb-3">
                  <div class="text-muted small fw-bold text-uppercase" style="font-size:0.65rem;">Case ID</div>
                  <div class="small fw-semibold">#<%= caseId %></div>
                </div>
                <div class="mb-3">
                  <div class="text-muted small fw-bold text-uppercase" style="font-size:0.65rem;">Title</div>
                  <div class="small fw-semibold"><%= caseTitle %></div>
                </div>
                <div class="mb-3">
                  <div class="text-muted small fw-bold text-uppercase" style="font-size:0.65rem;">Court</div>
                  <div class="small fw-semibold"><%= caseCourt.isEmpty() ? "N/A" : caseCourt %></div>
                </div>
                <div class="mb-0">
                  <div class="text-muted small fw-bold text-uppercase" style="font-size:0.65rem;">City</div>
                  <div class="small fw-semibold"><%= caseCity.isEmpty() ? "N/A" : caseCity %></div>
                </div>
              </div>
            </div>
            <div class="card border-0 mb-4">
              <div class="card-header bg-transparent border-0 py-3 px-4">
                <h5 class="card-title fw-bold mb-0 text-serif">
                  <i class="bi bi-people me-2" style="color:var(--gold);"></i>Participants
                </h5>
              </div>
              <div class="card-body px-4 pb-4 pt-0">
                <%
                  java.util.LinkedHashMap<String, String[]> participants = new java.util.LinkedHashMap<>();
                  for (String[] msg : messages) {
                    if (!participants.containsKey(msg[0])) {
                      participants.put(msg[0], new String[]{msg[6], msg[1]}); // displayName, role
                    }
                  }
                  if (participants.isEmpty()) {
                %>
                  <p class="text-muted small mb-0">No messages yet.</p>
                <% } else {
                  for (java.util.Map.Entry<String, String[]> entry : participants.entrySet()) {
                    String pName = entry.getValue()[0];
                    String pRole = entry.getValue()[1];
                %>
                  <div class="d-flex align-items-center gap-2 mb-3">
                    <div class="rounded-circle d-flex align-items-center justify-content-center fw-bold text-white text-serif" style="width:32px; height:32px; background:#111827; font-size:0.75rem;">
                      <%= pName.substring(0,1).toUpperCase() %>
                    </div>
                    <div>
                      <div class="small fw-semibold"><%= pName %></div>
                      <div class="text-muted" style="font-size:0.65rem;"><%= pRole.substring(0,1).toUpperCase() + pRole.substring(1) %></div>
                    </div>
                  </div>
                <% } } %>
              </div>
            </div>
            <div class="card border-0">
              <div class="card-body p-4">
                <div class="d-grid gap-2">
                  <a onclick="location.reload()" class="btn btn-sm btn-outline-dark py-2 fw-semibold" style="cursor:pointer;">
                    <i class="bi bi-arrow-clockwise me-2"></i>Refresh Messages
                  </a>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    <jsp:include page="../shared/_footer.jsp" />
  </main>
</div>
</body>
</html>