<aside class="sidebar">
  <div class="sidebar-header">
    <a href="Lawyerdashboard.jsp" class="sidebar-brand">
      <i class="ph-fill ph-scales text-gold" style="font-size: 1.5rem;"></i> JUSTICE4U
    </a>
  </div>
  <nav class="sidebar-nav d-flex flex-column">
    <span class="nav-section-label">General</span>
    <a href="Lawyerdashboard.jsp" class="nav-link <%= request.getRequestURI().contains("Lawyerdashboard.jsp") ? "active":""%>"><i class="ph ph-squares-four"></i> Workbench</a>
    <span class="nav-section-label">Casework</span>
    <a href="lawyerCases.jsp" class="nav-link <%= request.getRequestURI().contains("lawyerCases") ? "active":""%>"><i class="ph ph-briefcase"></i> Active Cases</a>
    <a href="viewcustdetails.jsp" class="nav-link <%= request.getRequestURI().contains("viewcustdetails") ? "active":""%>"><i class="ph ph-users"></i> Client Records</a>
    <a href="case_repository.jsp" class="nav-link <%= request.getRequestURI().contains("case_repository") ? "active":""%>"><i class="ph ph-books"></i> Repository</a>
    <a href="../shared/signout.jsp" class="logout-link"><i class="ph ph-sign-out"></i> Log Out</a>
  </nav>
</aside>