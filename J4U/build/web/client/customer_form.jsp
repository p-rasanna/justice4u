<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Justice4U | Client Registration</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@600;700&family=Plus+Jakarta+Sans:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        :root { --navy: #0B192C; --gold: #D4AF37; }
        body { font-family: 'Plus Jakarta Sans', sans-serif; background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%); min-height: 100vh; }
        .font-law { font-family: 'Playfair Display', serif; }
        .registration-card { background: #fff; border-radius: 16px; box-shadow: 0 20px 60px rgba(11,25,44,0.1); border: none; }
        .form-header { background: var(--navy); color: white; padding: 2rem; border-radius: 16px 16px 0 0; text-align: center; }
        .gold-accent { color: var(--gold); }
        .btn-gold { background: var(--gold); color: var(--navy); font-weight: 600; padding: 12px 32px; border: none; border-radius: 8px; }
        .btn-gold:hover { background: #c4a030; color: var(--navy); }
        .btn-navy { background: var(--navy); color: white; font-weight: 600; padding: 12px 32px; border: none; border-radius: 8px; }
        .btn-navy:hover { background: #1a2d47; color: white; }
        .form-control:focus, .form-select:focus { border-color: var(--gold); box-shadow: 0 0 0 0.2rem rgba(212,175,55,0.25); }
        .section-title { color: var(--navy); font-weight: 600; margin-bottom: 1.5rem; padding-bottom: 0.5rem; border-bottom: 2px solid var(--gold); display: inline-block; }
    </style>
</head>
<body>
    <nav class="py-3 bg-white shadow-sm">
        <div class="container d-flex justify-content-between align-items-center">
            <a class="text-decoration-none font-law fs-4 fw-bold" style="color: var(--navy);" href="../landing/Home.html">
                <i class="bi bi-scales me-2" style="color: var(--gold);"></i>Justice4U
            </a>
            <a href="../landing/role_select.html" class="text-muted text-decoration-none small fw-semibold">
                <i class="bi bi-arrow-left me-1"></i> Back to Role Selection
            </a>
        </div>
    </nav>

    <div class="container py-5">
        <div class="row justify-content-center">
            <div class="col-lg-8">
                <div class="registration-card">
                    <div class="form-header">
                        <h1 class="font-law display-5 fw-bold mb-2">Client <span class="gold-accent">Registration</span></h1>
                        <p class="mb-0 opacity-75">Create your account to access legal services</p>
                    </div>
                    
                    <div class="p-4 p-md-5">
                        <% String error = request.getParameter("error"); if(error != null) { %>
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="bi bi-exclamation-triangle-fill me-2"></i><%= error %>
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                        <% } %>
                        
                        <form action="customer.jsp" method="post">
                            <!-- Personal Information -->
                            <h4 class="section-title"><i class="bi bi-person-fill me-2"></i>Personal Information</h4>
                            <div class="row g-3 mb-4">
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Full Name <span class="text-danger">*</span></label>
                                    <input type="text" name="txtname" class="form-control form-control-lg" required placeholder="Enter your full name">
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Email Address <span class="text-danger">*</span></label>
                                    <input type="email" name="txtemail" class="form-control form-control-lg" required placeholder="your@email.com">
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Mobile Number <span class="text-danger">*</span></label>
                                    <input type="tel" name="txtmno" class="form-control form-control-lg" required placeholder="+91 00000 00000" pattern="[0-9]{10,15}">
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Date of Birth</label>
                                    <input type="date" name="txtdob" class="form-control form-control-lg">
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Aadhaar Number <span class="text-danger">*</span></label>
                                    <input type="text" name="txtadhar" class="form-control form-control-lg" required placeholder="12-digit Aadhaar" pattern="[0-9]{12}" maxlength="12">
                                </div>
                            </div>

                            <!-- Address Information -->
                            <h4 class="section-title"><i class="bi bi-geo-alt-fill me-2"></i>Address Information</h4>
                            <div class="row g-3 mb-4">
                                <div class="col-12">
                                    <label class="form-label fw-semibold">Current Address <span class="text-danger">*</span></label>
                                    <textarea name="txtadd" class="form-control" rows="2" required placeholder="Enter your current address"></textarea>
                                </div>
                                <div class="col-12">
                                    <label class="form-label fw-semibold">Permanent Address</label>
                                    <textarea name="txtper" class="form-control" rows="2" placeholder="Enter your permanent address (if different)"></textarea>
                                </div>
                            </div>

                            <!-- Security -->
                            <h4 class="section-title"><i class="bi bi-shield-lock-fill me-2"></i>Security</h4>
                            <div class="row g-3 mb-4">
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Password <span class="text-danger">*</span></label>
                                    <input type="password" name="txtpass" class="form-control form-control-lg" required minlength="6" placeholder="Create password">
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Confirm Password <span class="text-danger">*</span></label>
                                    <input type="password" name="txtpassconfirm" class="form-control form-control-lg" required minlength="6" placeholder="Confirm password">
                                </div>
                            </div>

                            <!-- Lawyer Assignment Preference -->
                            <h4 class="section-title"><i class="bi bi-briefcase-fill me-2"></i>Lawyer Assignment Preference</h4>
                            <div class="mb-4">
                                <label class="form-label fw-semibold">How would you like to select your lawyer?</label>
                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <div class="form-check card p-3 border">
                                            <input class="form-check-input" type="radio" name="assignmentPreference" id="adminAssign" value="admin" checked>
                                            <label class="form-check-label" for="adminAssign">
                                                <strong>Admin Assignment</strong><br>
                                                <small class="text-muted">Let the admin assign the best lawyer for your case</small>
                                            </label>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-check card p-3 border">
                                            <input class="form-check-input" type="radio" name="assignmentPreference" id="manualSelect" value="manual">
                                            <label class="form-check-label" for="manualSelect">
                                                <strong>Manual Selection</strong><br>
                                                <small class="text-muted">Browse and choose your preferred lawyer</small>
                                            </label>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="d-grid gap-3 mt-4">
                                <button type="submit" class="btn btn-gold btn-lg">
                                    <i class="bi bi-person-plus-fill me-2"></i>Register as Client
                                </button>
                                <a href="../landing/role_select.html" class="btn btn-navy">
                                    <i class="bi bi-arrow-left me-2"></i>Back to Role Selection
                                </a>
                            </div>

                            <div class="text-center mt-4">
                                <p class="text-muted">Already have an account? <a href="../auth/cust_login.html" class="fw-bold text-decoration-none" style="color: var(--navy);">Sign In</a></p>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <footer class="py-4 text-center">
        <p class="text-muted small mb-0">&copy; 2026 Justice4U. All rights reserved.</p>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
