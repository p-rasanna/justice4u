<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Justice4U | Intern Registration</title>
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
        .practice-area-checkbox { display: flex; align-items: center; gap: 0.5rem; padding: 0.75rem; border: 1px solid #dee2e6; border-radius: 8px; cursor: pointer; transition: all 0.2s; }
        .practice-area-checkbox:hover { border-color: var(--gold); background: rgba(212,175,55,0.05); }
        .practice-area-checkbox input[type="checkbox"] { width: 1.25rem; height: 1.25rem; accent-color: var(--navy); }
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
            <div class="col-lg-10">
                <div class="registration-card">
                    <div class="form-header">
                        <h1 class="font-law display-5 fw-bold mb-2">Intern <span class="gold-accent">Registration</span></h1>
                        <p class="mb-0 opacity-75">Join as a legal intern and gain practical experience</p>
                    </div>
                    
                    <div class="p-4 p-md-5">
                        <% String error = request.getParameter("error"); if(error != null) { %>
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="bi bi-exclamation-triangle-fill me-2"></i><%= error %>
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                        <% } %>
                        <% String msg = request.getParameter("msg"); if(msg != null) { %>
                        <div class="alert alert-success alert-dismissible fade show" role="alert">
                            <i class="bi bi-check-circle-fill me-2"></i><%= msg %>
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                        <% } %>
                        
                        <form action="../ProcessInternServlet" method="post" enctype="multipart/form-data">
                            <!-- Personal Information -->
                            <h4 class="section-title"><i class="bi bi-person-fill me-2"></i>Personal Information</h4>
                            <div class="row g-3 mb-4">
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Full Name <span class="text-danger">*</span></label>
                                    <input type="text" name="fullName" class="form-control form-control-lg" required placeholder="Enter your full name">
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Email Address <span class="text-danger">*</span></label>
                                    <input type="email" name="email" class="form-control form-control-lg" required placeholder="name@college.edu">
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Contact Number <span class="text-danger">*</span></label>
                                    <input type="tel" name="phone" class="form-control form-control-lg" required placeholder="+91 00000 00000" pattern="[0-9]{10,15}">
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Student ID Number <span class="text-danger">*</span></label>
                                    <input type="text" name="studentId" class="form-control form-control-lg" required placeholder="College ID number">
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Password <span class="text-danger">*</span></label>
                                    <input type="password" name="password" class="form-control form-control-lg" required minlength="8" placeholder="Create password (min 8 chars)">
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Confirm Password <span class="text-danger">*</span></label>
                                    <input type="password" name="confirmPassword" class="form-control form-control-lg" required placeholder="Confirm password">
                                </div>
                            </div>

                            <!-- Academic Information -->
                            <h4 class="section-title"><i class="bi bi-mortarboard-fill me-2"></i>Academic Information</h4>
                            <div class="row g-3 mb-4">
                                <div class="col-12">
                                    <label class="form-label fw-semibold">Institution / University <span class="text-danger">*</span></label>
                                    <input type="text" name="collegeName" class="form-control form-control-lg" required placeholder="e.g., National Law School of India University">
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Degree Program <span class="text-danger">*</span></label>
                                    <select name="degreeProgram" class="form-select form-select-lg" required>
                                        <option value="">Select Program</option>
                                        <option value="LLB3">LLB (3 years)</option>
                                        <option value="LLB5" selected>LLB (5 years)</option>
                                        <option value="LLM">LLM (Masters)</option>
                                        <option value="PhD">PhD in Law</option>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Current Year/Semester <span class="text-danger">*</span></label>
                                    <input type="text" name="yearSemester" class="form-control form-control-lg" required placeholder="e.g., 3rd Year / 5th Semester">
                                </div>
                            </div>

                            <!-- Areas of Interest -->
                            <h4 class="section-title"><i class="bi bi-briefcase-fill me-2"></i>Areas of Interest</h4>
                            <div class="row g-2 mb-4">
                                <div class="col-md-4"><label class="practice-area-checkbox"><input type="checkbox" name="areasOfInterest" value="Criminal Law"> <span>Criminal Law</span></label></div>
                                <div class="col-md-4"><label class="practice-area-checkbox"><input type="checkbox" name="areasOfInterest" value="Civil Law"> <span>Civil Law</span></label></div>
                                <div class="col-md-4"><label class="practice-area-checkbox"><input type="checkbox" name="areasOfInterest" value="Family Law"> <span>Family Law</span></label></div>
                                <div class="col-md-4"><label class="practice-area-checkbox"><input type="checkbox" name="areasOfInterest" value="Corporate Law"> <span>Corporate Law</span></label></div>
                                <div class="col-md-4"><label class="practice-area-checkbox"><input type="checkbox" name="areasOfInterest" value="Constitutional Law"> <span>Constitutional Law</span></label></div>
                                <div class="col-md-4"><label class="practice-area-checkbox"><input type="checkbox" name="areasOfInterest" value="Intellectual Property"> <span>IP Law</span></label></div>
                            </div>

                            <!-- Skills -->
                            <h4 class="section-title"><i class="bi bi-tools me-2"></i>Skills</h4>
                            <div class="row g-2 mb-4">
                                <div class="col-md-4"><label class="practice-area-checkbox"><input type="checkbox" name="skills" value="Legal Research"> <span>Legal Research</span></label></div>
                                <div class="col-md-4"><label class="practice-area-checkbox"><input type="checkbox" name="skills" value="Drafting"> <span>Drafting</span></label></div>
                                <div class="col-md-4"><label class="practice-area-checkbox"><input type="checkbox" name="skills" value="Documentation"> <span>Documentation</span></label></div>
                                <div class="col-md-4"><label class="practice-area-checkbox"><input type="checkbox" name="skills" value="Case Analysis"> <span>Case Analysis</span></label></div>
                                <div class="col-md-4"><label class="practice-area-checkbox"><input type="checkbox" name="skills" value="Client Counselling"> <span>Client Counselling</span></label></div>
                                <div class="col-md-4"><label class="practice-area-checkbox"><input type="checkbox" name="skills" value="Other"> <span>Other</span></label></div>
                            </div>

                            <!-- Internship Preferences -->
                            <h4 class="section-title"><i class="bi bi-geo-alt-fill me-2"></i>Internship Preferences</h4>
                            <div class="row g-3 mb-4">
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Preferred City <span class="text-danger">*</span></label>
                                    <input type="text" name="preferredCity" class="form-control form-control-lg" required placeholder="e.g., Delhi, Mumbai, Bangalore">
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Availability Duration <span class="text-danger">*</span></label>
                                    <select name="availabilityDuration" class="form-select form-select-lg" required>
                                        <option value="">Select Duration</option>
                                        <option value="1 Month">1 Month</option>
                                        <option value="2 Months">2 Months</option>
                                        <option value="3 Months">3 Months</option>
                                        <option value="6 Months">6 Months</option>
                                        <option value="1 Year">1 Year</option>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Internship Mode <span class="text-danger">*</span></label>
                                    <select name="internMode" class="form-select form-select-lg" required>
                                        <option value="">Select Mode</option>
                                        <option value="Physical">Physical (In-office)</option>
                                        <option value="Virtual">Virtual (Remote)</option>
                                        <option value="Hybrid">Hybrid</option>
                                    </select>
                                </div>
                            </div>

                            <!-- Security Questions -->
                            <h4 class="section-title"><i class="bi bi-shield-lock-fill me-2"></i>Security Questions</h4>
                            <div class="row g-3 mb-4">
                                <div class="col-12">
                                    <label class="form-label fw-semibold">Security Question <span class="text-danger">*</span></label>
                                    <select name="securityQuestion" class="form-select form-select-lg" required>
                                        <option value="">Select a security question</option>
                                        <option value="What was your first pet's name?">What was your first pet's name?</option>
                                        <option value="What city were you born in?">What city were you born in?</option>
                                        <option value="What is your mother's maiden name?">What is your mother's maiden name?</option>
                                        <option value="What was the name of your first school?">What was the name of your first school?</option>
                                    </select>
                                </div>
                                <div class="col-12">
                                    <label class="form-label fw-semibold">Security Answer <span class="text-danger">*</span></label>
                                    <input type="text" name="securityAnswer" class="form-control form-control-lg" required placeholder="Enter your answer">
                                </div>
                            </div>

                            <!-- Document Uploads -->
                            <h4 class="section-title"><i class="bi bi-file-earmark-text-fill me-2"></i>Required Documents</h4>
                            <div class="row g-3 mb-4">
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">College ID Card (Front) <span class="text-danger">*</span></label>
                                    <input type="file" name="collegeIdFront" class="form-control" required accept="image/*,.pdf">
                                    <small class="text-muted">Clear photo of ID card front</small>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">College ID Card (Back) <span class="text-danger">*</span></label>
                                    <input type="file" name="collegeIdBack" class="form-control" required accept="image/*,.pdf">
                                    <small class="text-muted">Clear photo of ID card back</small>
                                </div>
                                <div class="col-12">
                                    <label class="form-label fw-semibold">Bonafide Certificate <span class="text-danger">*</span></label>
                                    <input type="file" name="bonafide" class="form-control" required accept="image/*,.pdf">
                                    <small class="text-muted">Current year bonafide certificate from your institution</small>
                                </div>
                            </div>

                            <div class="alert alert-info">
                                <i class="bi bi-info-circle-fill me-2"></i>
                                <strong>Note:</strong> Your registration will be reviewed by the admin. You'll receive access once approved.
                            </div>

                            <div class="d-grid gap-3 mt-4">
                                <button type="submit" class="btn btn-gold btn-lg">
                                    <i class="bi bi-person-plus-fill me-2"></i>Submit Application
                                </button>
                                <a href="../landing/role_select.html" class="btn btn-navy">
                                    <i class="bi bi-arrow-left me-2"></i>Back to Role Selection
                                </a>
                            </div>

                            <div class="text-center mt-4">
                                <p class="text-muted">Already registered? <a href="../auth/internlogin_form.jsp" class="fw-bold text-decoration-none" style="color: var(--navy);">Sign In</a></p>
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