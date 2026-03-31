<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String cp = request.getContextPath();
    boolean isAdmin = session.getAttribute("aname") != null || "admin".equalsIgnoreCase((String)session.getAttribute("role"));
    boolean isLawyer = session.getAttribute("lname") != null || "lawyer".equalsIgnoreCase((String)session.getAttribute("role"));
    boolean isClient = session.getAttribute("cname") != null || "client".equalsIgnoreCase((String)session.getAttribute("role"));
    boolean isIntern = session.getAttribute("iname") != null || "intern".equalsIgnoreCase((String)session.getAttribute("role"));
%>
<aside class="app-sidebar py-3" data-bs-theme="dark">
  <div class="sidebar-brand px-4 mb-4">
    <a href="<%= cp %>/index.jsp" class="text-decoration-none">
      <span class="text-serif fs-4 fw-bold text-white tracking-tight">Justice<span class="text-gold">4U</span></span>
    </a>
  </div>
  
  <div class="sidebar-wrapper px-2">
    <nav>
      <ul class="nav sidebar-menu flex-column" data-lte-toggle="treeview" role="navigation">
        
        <li class="nav-item">
          <a href="<%= cp %>/index.jsp" class="nav-link">
            <i class="nav-icon bi bi-grid-1x2"></i>
            <p>Dashboard</p>
          </a>
        </li>

        <% if (isAdmin) { %>
        <li class="nav-header text-uppercase fs-xs fw-bold opacity-50 ps-4 mt-4">Administration</li>
        <li class="nav-item">
          <a href="<%= cp %>/admin/viewcustomers.jsp" class="nav-link">
            <i class="nav-icon bi bi-people"></i>
            <p>Client Registry</p>
          </a>
        </li>
        <li class="nav-item">
          <a href="<%= cp %>/admin/viewlawyers.jsp" class="nav-link">
            <i class="nav-icon bi bi-shield-shaded"></i>
            <p>Legal Counsel</p>
          </a>
        </li>
        <li class="nav-item">
          <a href="<%= cp %>/admin/viewinterns.jsp" class="nav-link">
            <i class="nav-icon bi bi-mortarboard"></i>
            <p>Intern Program</p>
          </a>
        </li>
        <li class="nav-item">
          <a href="<%= cp %>/admin/viewcases.jsp" class="nav-link">
            <i class="nav-icon bi bi-archive"></i>
            <p>Case Repository</p>
          </a>
        </li>
        <% } %>

        <% if (isLawyer) { %>
        <li class="nav-header text-uppercase fs-xs fw-bold opacity-50 ps-4 mt-4">Legal Portal</li>
        <li class="nav-item">
          <a href="<%= cp %>/lawyer/viewcases.jsp" class="nav-link">
            <i class="nav-icon bi bi-briefcase"></i>
            <p>Allocated Matters</p>
          </a>
        </li>
        <li class="nav-item">
          <a href="<%= cp %>/shared/chat.jsp" class="nav-link">
            <i class="nav-icon bi bi-chat-left-text"></i>
            <p>Consultations</p>
          </a>
        </li>
        <% } %>

        <% if (isClient) { %>
        <li class="nav-header text-uppercase fs-xs fw-bold opacity-50 ps-4 mt-4">Member Suite</li>
        <li class="nav-item">
          <a href="<%= cp %>/client/requestlawyer.jsp" class="nav-link">
            <i class="nav-icon bi bi-plus-square"></i>
            <p>File New Mandate</p>
          </a>
        </li>
        <li class="nav-item">
          <a href="<%= cp %>/client/uploadClientDoc.jsp" class="nav-link">
            <i class="nav-icon bi bi-cloud-upload"></i>
            <p>Document Center</p>
          </a>
        </li>
        <li class="nav-item">
          <a href="<%= cp %>/shared/chat.jsp" class="nav-link">
            <i class="nav-icon bi bi-patch-check"></i>
            <p>Direct Inquiry</p>
          </a>
        </li>
        <% } %>

        <li class="nav-header text-uppercase fs-xs fw-bold opacity-50 ps-4 mt-4">Security</li>
        <li class="nav-item">
          <a href="<%= cp %>/shared/signout.jsp" class="nav-link">
            <i class="nav-icon bi bi-power text-danger"></i>
            <p class="text-danger">End Session</p>
          </a>
        </li>
      </ul>
    </nav>
  </div>
</aside>

