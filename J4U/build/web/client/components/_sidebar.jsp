<aside class="sidebar">
    <div class="sidebar-header">
        <a href="clientdashboard.jsp" class="sidebar-brand">
            <i class="ph-fill ph-scales text-gold" style="font-size: 1.5rem;"></i> JUSTICE4U
        </a>
    </div>
    <nav class="sidebar-nav d-flex flex-column">
        <span class="nav-section-label">General</span>
        <a href="clientdashboard.jsp" class="nav-link <%= request.getRequestURI().contains("clientdashboard.jsp") ? "active":""%>"><i class="ph ph-squares-four"></i> Overview</a>
        
        <span class="nav-section-label">Services</span>
        <a href="requestHelp.jsp" class="nav-link <%= request.getRequestURI().contains("requestHelp") ? "active":""%>"><i class="ph ph-paper-plane-tilt"></i> Submit Request</a>
        <a href="manageCase.jsp" class="nav-link <%= request.getRequestURI().contains("manageCase") ? "active":""%>"><i class="ph ph-folder-open"></i> My Cases</a>
        
        <span class="nav-section-label">Settings</span>
        <a href="profile.jsp" class="nav-link <%= request.getRequestURI().contains("profile") ? "active":""%>"><i class="ph ph-user-circle"></i> Profile Details</a>
        
        <a href="../shared/signout.jsp" class="logout-link"><i class="ph ph-sign-out"></i> Log Out</a>
    </nav>
</aside>