<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Justice4U – Legal Intern Registration</title>

    <!-- Icons & Fonts -->
    <script src="https://unpkg.com/@phosphor-icons/web"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600&family=Playfair+Display:ital,wght@0,600;1,600&family=Space+Grotesk:wght@500;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        :root {
            --bg-ivory: #FAFAF8;
            --ink-primary: #121212;
            --ink-secondary: #555555;
            --ink-tertiary: #888888;
            --gold-main: #C6A75E;
            --gold-dim: #9C824A;
            --success-green: #059669;
            --danger-red: #DC2626;
            --surface-card: #FFFFFF;
            --border-subtle: #E6E6E6;
            --shadow-card: 0 4px 20px rgba(0,0,0,0.02);
            --ease-smart: cubic-bezier(0.2, 0.8, 0.2, 1);
        }

        body {
            margin: 0;
            background-color: var(--bg-ivory);
            color: var(--ink-primary);
            font-family: 'Inter', sans-serif;
            min-height: 100vh;
            background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noiseFilter'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.8' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noiseFilter)' opacity='0.02'/%3E%3C/svg%3E");
        }

        .auth-shell {
            max-width: 900px;
            margin: 0 auto;
            padding: 60px 24px;
        }

        /* Entrance Stagger */
        .smart-enter {
            opacity: 0; transform: translateY(15px);
            /* animation removed */
        }
        .d-1 { animation-delay: 0.1s; }
        .d-2 { animation-delay: 0.2s; }

        @keyframes enterUp { to { opacity: 1; transform: translateY(0); } }

        /* Header */
        .auth-header {
            text-align: center;
            margin-bottom: 48px;
        }

        .auth-header h1 {
            font-family: 'Playfair Display', serif;
            font-size: 2.8rem;
            margin-bottom: 8px;
            color: var(--ink-primary);
        }

        .header-meta {
            font-family: 'Space Grotesk', monospace;
            font-size: 0.85rem;
            color: var(--ink-secondary);
            display: flex;
            justify-content: center;
            gap: 20px;
        }

        /* Panel Styling */
        .panel {
            background: var(--surface-card);
            border: 1px solid var(--border-subtle);
            border-radius: 16px;
            padding: 40px;
            box-shadow: var(--shadow-card);
            margin-bottom: 32px;
        }

        .panel-title {
            font-family: 'Playfair Display', serif;
            font-size: 1.5rem;
            margin-bottom: 24px;
            padding-bottom: 12px;
            border-bottom: 1px solid var(--border-subtle);
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .panel-icon { color: var(--gold-main); }

        /* Form Controls */
        .form-label {
            font-size: 0.85rem;
            font-weight: 600;
            color: var(--ink-secondary);
            margin-bottom: 8px;
            display: block;
        }

        .form-control, .form-select {
            border: 1px solid var(--border-subtle);
            border-radius: 8px;
            padding: 12px 16px;
            font-size: 0.9rem;
            transition: all 0.2s;
            background-color: #FAFAFA;
        }

        .form-control:focus, .form-select:focus {
            border-color: var(--gold-main);
            background-color: #FFF;
            box-shadow: 0 0 0 4px rgba(198, 167, 94, 0.1);
            outline: none;
        }

        .password-wrapper {
            position: relative;
        }

        .password-toggle {
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            color: var(--ink-tertiary);
            cursor: pointer;
            font-size: 1.2rem;
            display: flex;
            align-items: center;
        }

        /* Multi-column Layout */
        .grid-half {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 24px;
        }

        @media (max-width: 768px) {
            .grid-half { grid-template-columns: 1fr; }
        }

        /* Checkbox/Radio Styling */
        .custom-check-group {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
            gap: 12px;
            margin-top: 8px;
        }

        .check-item {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 0.9rem;
            cursor: pointer;
            padding: 10px 14px;
            border-radius: 8px;
            border: 1px solid var(--border-subtle);
            transition: all 0.2s;
        }

        .check-item:hover {
            border-color: var(--gold-main);
            background: rgba(198, 167, 94, 0.05);
        }

        .check-item input {
            accent-color: var(--gold-main);
        }

        /* Buttons */
        .btn-submit {
            background: var(--ink-primary);
            color: #fff;
            border: none;
            padding: 16px 32px;
            border-radius: 100px;
            font-weight: 600;
            width: 100%;
            font-size: 1rem;
            transition: all 0.2s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 12px;
            box-shadow: 0 10px 20px rgba(0,0,0,0.1);
        }

        .btn-submit:hover {
            background: var(--gold-main);
            transform: translateY(-2px);
            box-shadow: 0 15px 30px rgba(198, 167, 94, 0.3);
        }

        .auth-footer {
            text-align: center;
            margin-top: 24px;
            font-size: 0.9rem;
            color: var(--ink-secondary);
        }

        .auth-footer a {
            color: var(--gold-main);
            font-weight: 600;
            text-decoration: none;
        }

        .error-hint {
            color: var(--danger-red);
            font-size: 0.75rem;
            margin-top: 4px;
            display: none;
        }

        .form-control.is-invalid {
            border-color: var(--danger-red);
        }
    </style>
</head>

<body>
    <div class="auth-shell">
        <header class="auth-header smart-enter d-1">
            <h1>Intern Registry</h1>
            <div class="header-meta">
                <span><i class="ph ph-shield-check"></i> Verified Counsel Oversight</span>
                <span><i class="ph ph-graduation-cap"></i> Professional Mentorship</span>
            </div>
        </header>

        <form id="internRegistrationForm" action="ProcessInternServlet" method="post" enctype="multipart/form-data" class="smart-enter d-2">
            
            <!-- Section 1: Identity -->
            <div class="panel">
                <h3 class="panel-title"><i class="ph ph-identification-card panel-icon"></i> Account Identity</h3>
                <div class="mb-4">
                    <label for="fullName" class="form-label">Full Name</label>
                    <input type="text" id="fullName" name="fullName" class="form-control w-100" required placeholder="Legal full name">
                </div>
                
                <div class="grid-half">
                    <div class="mb-4">
                        <label for="email" class="form-label">Email Address</label>
                        <input type="email" id="email" name="email" class="form-control w-100" required placeholder="academic@institute.edu">
                    </div>
                    <div class="mb-4">
                        <label for="phone" class="form-label">Phone Number</label>
                        <input type="tel" id="phone" name="phone" class="form-control w-100" required placeholder="10-digit mobile">
                    </div>
                </div>

                <div class="grid-half">
                    <div class="mb-4">
                        <label for="securityQuestion" class="form-label">Security Question</label>
                        <select id="securityQuestion" name="securityQuestion" class="form-select w-100" required>
                            <option value="">Choose a question</option>
                            <option>What city were you born in?</option>
                            <option>What is your mother's maiden name?</option>
                            <option>What was the name of your first pet?</option>
                        </select>
                    </div>
                    <div class="mb-4">
                        <label for="securityAnswer" class="form-label">Security Answer</label>
                        <input type="text" id="securityAnswer" name="securityAnswer" class="form-control w-100" required placeholder="Secret answer">
                    </div>
                </div>

                <div class="grid-half">
                    <div class="mb-4">
                        <label for="password" class="form-label">Password</label>
                        <div class="password-wrapper">
                            <input type="password" id="password" name="password" class="form-control w-100" required minlength="8">
                            <button type="button" class="password-toggle" onclick="togglePass('password')">
                                <i class="ph ph-eye"></i>
                            </button>
                        </div>
                    </div>
                    <div class="mb-4">
                        <label for="confirmPassword" class="form-label">Confirm Password</label>
                        <div class="password-wrapper">
                            <input type="password" id="confirmPassword" name="confirmPassword" class="form-control w-100" required minlength="8">
                            <button type="button" class="password-toggle" onclick="togglePass('confirmPassword')">
                                <i class="ph ph-eye"></i>
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Section 2: Academic Standing -->
            <div class="panel">
                <h3 class="panel-title"><i class="ph ph-books panel-icon"></i> Academic Standing</h3>
                <div class="mb-4">
                    <label for="collegeName" class="form-label">Institution Name</label>
                    <input type="text" id="collegeName" name="collegeName" class="form-control w-100" required placeholder="University or Law School">
                </div>

                <div class="grid-half">
                    <div class="mb-4">
                        <label for="degreeProgram" class="form-label">Degree Program</label>
                        <select id="degreeProgram" name="degreeProgram" class="form-select w-100" required>
                            <option value="">Select program</option>
                            <option value="LLB3">LLB (3 years)</option>
                            <option value="LLB5">LLB (5 years)</option>
                            <option value="LLM">LLM</option>
                        </select>
                    </div>
                    <div class="mb-4">
                        <label for="yearSemester" class="form-label">Year/Semester</label>
                        <input type="text" id="yearSemester" name="yearSemester" class="form-control w-100" required placeholder="e.g. 3rd Year">
                    </div>
                </div>

                <div class="mb-4">
                    <label for="studentId" class="form-label">Student ID Number</label>
                    <input type="text" id="studentId" name="studentId" class="form-control w-100" required placeholder="Institution enrollment ID">
                </div>

                <div class="grid-half">
                    <div class="mb-4">
                        <label for="collegeIdFront" class="form-label">ID Card (Front)</label>
                        <input type="file" id="collegeIdFront" name="collegeIdFront" class="form-control w-100" required accept="image/*,.pdf">
                    </div>
                    <div class="mb-4">
                        <label for="collegeIdBack" class="form-label">ID Card (Back)</label>
                        <input type="file" id="collegeIdBack" name="collegeIdBack" class="form-control w-100" required accept="image/*,.pdf">
                    </div>
                </div>

                <div class="mb-4">
                    <label for="bonafide" class="form-label">Bonafide Certificate / Admission Proof</label>
                    <input type="file" id="bonafide" name="bonafide" class="form-control w-100" required accept="image/*,.pdf">
                </div>
            </div>

            <!-- Section 3: Professional Focus -->
            <div class="panel">
                <h3 class="panel-title"><i class="ph ph-briefcase panel-icon"></i> Professional Focus</h3>
                
                <fieldset class="mb-4 border-0 p-0">
                    <legend class="form-label mb-2">Practice Areas of Interest</legend>
                    <div class="custom-check-group">
                        <label class="check-item"><input type="checkbox" name="areasOfInterest" value="Criminal"> Criminal Law</label>
                        <label class="check-item"><input type="checkbox" name="areasOfInterest" value="Civil"> Civil Law</label>
                        <label class="check-item"><input type="checkbox" name="areasOfInterest" value="Corporate"> Corporate Law</label>
                        <label class="check-item"><input type="checkbox" name="areasOfInterest" value="Research"> Research</label>
                    </div>
                </fieldset>

                <fieldset class="mb-4 border-0 p-0">
                    <legend class="form-label mb-2">Specialized Skills</legend>
                    <div class="custom-check-group">
                        <label class="check-item"><input type="checkbox" name="skills" value="LegalResearch"> Legal Research</label>
                        <label class="check-item"><input type="checkbox" name="skills" value="CaseDrafting"> Case Drafting</label>
                        <label class="check-item"><input type="checkbox" name="skills" value="ClientComm"> Client Communication</label>
                        <label class="check-item"><input type="checkbox" name="skills" value="Documentation"> Documentation</label>
                    </div>
                </fieldset>

                <div class="grid-half">
                    <div class="mb-4">
                        <label for="preferredCity" class="form-label">Preferred City / Court</label>
                        <input type="text" id="preferredCity" name="preferredCity" class="form-control w-100" required placeholder="e.g. Bengaluru, High Court">
                    </div>
                    <fieldset class="mb-4 border-0 p-0">
                        <legend class="form-label mb-2">Internship Mode</legend>
                        <div class="d-flex gap-3">
                            <label class="check-item"><input type="radio" name="internMode" value="Remote" checked> Remote</label>
                            <label class="check-item"><input type="radio" name="internMode" value="InPerson"> On-site</label>
                        </div>
                    </fieldset>
                </div>

                <div class="mb-4">
                    <label for="availabilityDuration" class="form-label">Availability</label>
                    <select id="availabilityDuration" name="availabilityDuration" class="form-select w-100" required>
                        <option value="1month">1 Month</option>
                        <option value="3months">3 Months</option>
                        <option value="6months">6 Months</option>
                    </select>
                </div>
            </div>

            <!-- Section 4: Ethics & Confidentiality -->
            <div class="panel">
                <h3 class="panel-title"><i class="ph ph-hand-heart panel-icon"></i> Ethics & Confidentiality</h3>
                <div class="mb-4">
                    <label class="check-item w-100 mb-2">
                        <input type="checkbox" name="confRestricted" required>
                        <span>I agree to maintain strict confidentiality of all assigned cases.</span>
                    </label>
                    <label class="check-item w-100 mb-2">
                        <input type="checkbox" name="confCode" required>
                        <span>I accept the Justice4U Intern Code of Professional Conduct.</span>
                    </label>
                </div>
            </div>

            <button type="submit" class="btn-submit">
                Submit Application <i class="ph ph-paper-plane-tilt"></i>
            </button>

            <div class="auth-footer">
                Already part of the program? <a href="internlogin.jsp">Sign In</a>
            </div>
        </form>
    </div>

    <script>
        function togglePass(id) {
            const el = document.getElementById(id);
            const icon = el.nextElementSibling.querySelector('i');
            if (el.type === 'password') {
                el.type = 'text';
                icon.className = 'ph ph-eye-slash';
            } else {
                el.type = 'password';
                icon.className = 'ph ph-eye';
            }
        }
    </script>
</body>
</html>
