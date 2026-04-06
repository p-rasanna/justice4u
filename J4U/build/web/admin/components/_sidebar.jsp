<aside class="sidebar">
  <div class="sidebar-header">
    <a href="admindashboard.jsp" class="sidebar-brand">
      <i class="ph-fill ph-scales text-gold" style="font-size: 1.5rem;"></i> JUSTICE4U
    </a>
  </div>
  <nav class="sidebar-nav d-flex flex-column">
    <span class="nav-section-label">General</span>
    <a href="admindashboard.jsp" class="nav-link <%= request.getRequestURI().contains("admindashboard.jsp") ? "active":""%>"><i class="ph ph-squares-four"></i> Dashboard</a>
    <span class="nav-section-label">Records</span>
    <a href="viewcases.jsp" class="nav-link <%= request.getRequestURI().contains("viewcases") ? "active":""%>"><i class="ph ph-folders"></i> Case Repository</a>
    <a href="viewcust.jsp" class="nav-link <%= request.getRequestURI().contains("viewcust") ? "active":""%>"><i class="ph ph-users"></i> Client Registry</a>
    <a href="viewlawyers.jsp" class="nav-link <%= request.getRequestURI().contains("viewlawyers") ? "active":""%>"><i class="ph ph-briefcase"></i> Attorney Directory</a>
    <a href="viewinterns.jsp" class="nav-link <%= request.getRequestURI().contains("viewinterns") ? "active":""%>"><i class="ph ph-graduation-cap"></i> Associate Directory</a>
    <a href="../shared/signout.jsp" class="logout-link"><i class="ph ph-sign-out"></i> Log Out</a>
  </nav>
</aside>