<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
  String cp = request.getContextPath();
  boolean isAdmin  = session.getAttribute("aname") != null || "admin".equalsIgnoreCase((String)session.getAttribute("role"));
  boolean isLawyer = session.getAttribute("lname") != null || "lawyer".equalsIgnoreCase((String)session.getAttribute("role"));
  boolean isClient = session.getAttribute("cname") != null || "client".equalsIgnoreCase((String)session.getAttribute("role"));
  boolean isIntern = session.getAttribute("iname") != null || "intern".equalsIgnoreCase((String)session.getAttribute("role"));
  String sidebarProfileType = (String) session.getAttribute("profileType");
  boolean isManualClient = isClient && "manual".equalsIgnoreCase(sidebarProfileType);
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
      <a href="<%= cp %>/<%= isAdmin ? "AdminDashboard" : isLawyer ? "LawyerDashboardServlet" : isIntern ? "InternDashboardServlet" : "client/clientdashboard.jsp" %>" class="nav-link">
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
      <a href="<%= cp %>/shared/caseDiscussions.jsp" class="nav-link">
      <i class="nav-icon bi bi-chat-left-text"></i>
      <p>Case Discussions</p>
      </a>
    </li>
    <% } %>
    <% if (isClient) { %>
    <li class="nav-header text-uppercase fs-xs fw-bold opacity-50 ps-4 mt-4">Member Suite</li>
    <li class="nav-item">
      <a href="<%= cp %>/client/case.jsp" class="nav-link">
      <i class="nav-icon bi bi-plus-square"></i>
      <p>File New Case</p>
      </a>
    </li>
    <li class="nav-item">
      <a href="<%= cp %>/client/client_viewcases.jsp" class="nav-link">
      <i class="nav-icon bi bi-folder2-open"></i>
      <p>My Cases</p>
      </a>
    </li>
    <% if(isManualClient) { %>
    <li class="nav-item">
      <a href="<%= cp %>/client/findlawyer.jsp" class="nav-link">
      <i class="nav-icon bi bi-search"></i>
      <p>Find Lawyer</p>
      </a>
    </li>
    <% } %>
    <li class="nav-item">
      <a href="<%= cp %>/shared/caseDiscussions.jsp" class="nav-link">
      <i class="nav-icon bi bi-chat-dots"></i>
      <p>Case Discussion</p>
      </a>
    </li>
    <% } %>
    <% if (isIntern) { %>
    <li class="nav-header text-uppercase fs-xs fw-bold opacity-50 ps-4 mt-4">Intern Portal</li>
    <li class="nav-item">
      <a href="<%= cp %>/intern/interndashboard.jsp" class="nav-link">
      <i class="nav-icon bi bi-briefcase"></i>
      <p>My Cases</p>
      </a>
    </li>
    <li class="nav-item">
      <a href="<%= cp %>/shared/caseDiscussions.jsp" class="nav-link">
      <i class="nav-icon bi bi-chat-left-text"></i>
      <p>Case Discussions</p>
      </a>
    </li>
    <% } %>
    <li class="nav-header text-uppercase fs-xs fw-bold opacity-50 ps-4 mt-4">Security</li>
    <li class="nav-item">
      <a href="<%= cp %>/shared/signout.jsp?role=<%= isAdmin ? "admin" : isLawyer ? "lawyer" : isIntern ? "intern" : "client" %>" class="nav-link">
      <i class="nav-icon bi bi-power text-danger"></i>
      <p class="text-danger">End Session</p>
      </a>
    </li>
    </ul>
  </nav>
  </div>
</aside>