<aside class="sidebar">
  <div class="sidebar-header">
    <a href="internDashboard.jsp" class="sidebar-brand">
      <i class="ph-fill ph-scales text-gold" style="font-size: 1.5rem;"></i> JUSTICE4U
    </a>
  </div>
  <nav class="sidebar-nav d-flex flex-column">
    <span class="nav-section-label">General</span>
    <a href="internDashboard.jsp" class="nav-link <%= request.getRequestURI().contains("internDashboard.jsp") ? "active":""%>"><i class="ph ph-squares-four"></i> Workspace</a>
    <span class="nav-section-label">Tasks</span>
    <a href="RequestAssignment.jsp" class="nav-link <%= request.getRequestURI().contains("RequestAssignment") ? "active":""%>"><i class="ph ph-magnifying-glass"></i> Available Cases</a>
    <a href="internCase.jsp" class="nav-link <%= request.getRequestURI().contains("internCase") ? "active":""%>"><i class="ph ph-briefcase"></i> My Assignments</a>
    <a href="uploadInternWork.jsp" class="nav-link <%= request.getRequestURI().contains("uploadInternWork") ? "active":""%>"><i class="ph ph-upload-simple"></i> Submit Brief</a>
    <a href="../shared/signout.jsp" class="logout-link"><i class="ph ph-sign-out"></i> Log Out</a>
  </nav>
</aside>