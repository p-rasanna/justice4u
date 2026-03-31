<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String currentUserName = (String)session.getAttribute("name");
    if(currentUserName == null) currentUserName = "User";
    
    String cp = request.getContextPath();
%>
<nav class="app-header navbar navbar-expand bg-white border-bottom shadow-none">
  <div class="container-fluid px-4">
    <ul class="navbar-nav align-items-center">
      <li class="nav-item me-3">
        <a class="nav-link text-dark p-0" data-lte-toggle="sidebar" href="#" role="button">
          <i class="bi bi-list fs-4"></i>
        </a>
      </li>
      <li class="nav-item d-none d-md-block">
        <span class="text-serif fw-bold text-dark fs-5"><%= param.title != null ? param.title : "Workspace" %></span>
      </li>
    </ul>

    <ul class="navbar-nav ms-auto align-items-center">
      <!-- Notification Placeholder -->
      <li class="nav-item me-3">
        <a class="nav-link text-muted p-0 position-relative" href="#">
          <i class="bi bi-bell"></i>
          <span class="position-absolute top-0 start-100 translate-middle p-1 bg-gold border border-light rounded-circle"></span>
        </a>
      </li>
      
      <li class="nav-item dropdown user-menu">
        <a href="#" class="nav-link d-flex align-items-center gap-2 p-0" data-bs-toggle="dropdown">
          <div class="bg-dark text-white rounded-circle d-flex align-items-center justify-content-center text-serif fw-bold" style="width:32px; height:32px; font-size:0.8rem;">
            <%= currentUserName.substring(0,1).toUpperCase() %>
          </div>
          <span class="d-none d-md-inline text-dark fw-medium small"><%= currentUserName %></span>
        </a>
        <ul class="dropdown-menu dropdown-menu-end shadow-lg border-0 mt-3 p-2" style="min-width: 200px; border-radius: 12px;">
          <li class="px-3 py-2 mb-2">
            <p class="mb-0 fw-bold small text-dark"><%= currentUserName %></p>
            <p class="mb-0 text-muted small" style="font-size: 0.7rem;">Justice4U Premium Member</p>
          </li>
          <li><hr class="dropdown-divider opacity-50"></li>
          <li><a class="dropdown-item rounded-3 py-2 small" href="#"><i class="bi bi-person me-2"></i> Account Settings</a></li>
          <li><a class="dropdown-item rounded-3 py-2 small" href="#"><i class="bi bi-shield-lock me-2"></i> Security</a></li>
          <li><hr class="dropdown-divider opacity-50"></li>
          <li>
            <a href="<%= cp %>/shared/signout.jsp" class="dropdown-item rounded-3 py-2 small text-danger">
              <i class="bi bi-power me-2"></i> Sign Out
            </a>
          </li>
        </ul>
      </li>
    </ul>
  </div>
</nav>

