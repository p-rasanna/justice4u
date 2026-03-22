<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Justice4U | Legal Intern Registration</title>
  
  <script src="https://unpkg.com/@phosphor-icons/web"></script>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Instrument+Serif:ital@0;1&display=swap" rel="stylesheet">
  
  <style>
    :root {
      --bg: #FDFBF7; 
      --surface: #FFFFFF;
      --border: rgba(28, 25, 23, 0.08);
      --text-main: #1C1917; 
      --text-muted: #57534E;
      --accent-gold: #D4AF37; 
      --accent-gold-dark: #B48E2D;
      --font-sans: 'Inter', sans-serif;
      --font-serif: 'Instrument Serif', serif;
    }

    * { margin: 0; padding: 0; box-sizing: border-box; }

    body {
      background-color: var(--bg); color: var(--text-main); font-family: var(--font-sans);
      min-height: 100vh;
      background-image: radial-gradient(circle at 50% 0%, rgba(212, 175, 55, 0.05), transparent 70%);
      padding: 60px 20px;
    }

    .form-shell { max-width: 900px; margin: 0 auto; }

    .header-block { text-align: center; margin-bottom: 48px; }
    .header-block h1 { font-family: var(--font-serif); font-size: 3rem; color: var(--text-main); margin-bottom: 8px; }
    .header-block p { color: var(--text-muted); font-size: 1.05rem; }
    .logo { display: inline-flex; justify-content: center; align-items: center; gap: 8px; text-decoration: none; font-weight: 800; font-size: 1.2rem; color: var(--text-main); margin-bottom: 20px; }
    .logo i { color: var(--accent-gold); font-size: 1.8rem; }

    .panel {
      background: var(--surface); border: 1px solid var(--border); border-radius: 20px;
      padding: 40px; margin-bottom: 32px; box-shadow: 0 10px 40px rgba(0,0,0,0.02);
    }

    .panel-title { font-family: var(--font-serif); font-size: 1.8rem; border-bottom: 1px solid var(--border); padding-bottom: 16px; margin-bottom: 24px; display: flex; align-items: center; gap: 12px; }
    .panel-title i { color: var(--accent-gold); }

    .grid-half { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; }
    @media (max-width: 768px) { .grid-half { grid-template-columns: 1fr; } }
    
    .mb-4 { margin-bottom: 24px; }

    label { display: block; font-weight: 600; font-size: 0.9rem; margin-bottom: 8px; color: var(--text-main); }
    
    input[type="text"], input[type="email"], input[type="password"], input[type="tel"], input[type="date"], input[type="number"], select, input[type="file"] {
      width: 100%; padding: 14px 16px; border-radius: 12px; border: 1px solid var(--border);
      background: #FAFAFA; font-family: inherit; font-size: 0.95rem; transition: all 0.2s; color: var(--text-main);
    }
    input:focus, select:focus { outline: none; border-color: var(--accent-gold); background: #FFF; box-shadow: 0 0 0 3px rgba(212, 175, 55, 0.1); }
    input[type="file"] { padding: 10px 16px; }

    .custom-check-group { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 12px; margin-top: 8px; }
    .check-item { display: flex; align-items: center; gap: 10px; padding: 12px 16px; border-radius: 10px; border: 1px solid var(--border); cursor: pointer; transition: all 0.2s; font-size: 0.9rem; font-weight: 500;}
    .check-item:hover { border-color: var(--accent-gold); background: rgba(212, 175, 55, 0.05); }
    .check-item input[type="checkbox"], .check-item input[type="radio"] { accent-color: var(--accent-gold); transform: scale(1.1); }

    .btn-submit {
      width: 100%; background: var(--text-main); color: #fff; padding: 18px; border-radius: 16px;
      font-weight: 600; font-size: 1.1rem; border: none; cursor: pointer; transition: all 0.3s;
      display: flex; align-items: center; justify-content: center; gap: 10px; margin-top: 20px;
    }
    .btn-submit:hover { background: var(--accent-gold-dark); transform: translateY(-2px); box-shadow: 0 10px 25px rgba(212, 175, 55, 0.25); }

    .error-msg { color: #DC2626; text-align: center; font-size: 0.95rem; margin-bottom: 24px; display: none; padding: 16px; background: #FEF2F2; border-radius: 12px; font-weight: 500; }
    
    .auth-footer { text-align: center; margin-top: 32px; font-size: 0.95rem; color: var(--text-muted); }
    .auth-footer a { color: var(--text-main); font-weight: 600; text-decoration: none; border-bottom: 1px solid transparent; transition: border-color 0.2s; }
    .auth-footer a:hover { border-color: var(--text-main); }
  </style>
</head>
<body>

  <div class="form-shell">
    <div class="header-block">
      <a href="Home.html" class="logo"><i class="ph-fill ph-scales"></i> Justice4U</a>
      <h1>Intern Registry</h1>
      <p>Gain exposure, assist senior advocates, and build your career portfolio.</p>
    </div>

    <div id="errorBox" class="error-msg"></div>

    <form id="internRegistrationForm" action="ProcessInternServlet" method="post" enctype="multipart/form-data">
      
      <!-- Section 1: Identity -->
      <div class="panel">
        <h3 class="panel-title"><i class="ph-duotone ph-identification-card"></i> Account Identity</h3>
        <div class="mb-4">
          <label>Full Name</label>
          <input type="text" name="fullName" required placeholder="Legal full name">
        </div>
        
        <div class="grid-half">
          <div class="mb-4">
            <label>Email Address</label>
            <input type="email" name="email" required placeholder="academic@institute.edu">
          </div>
          <div class="mb-4">
            <label>Phone Number</label>
            <input type="tel" name="phone" required placeholder="10-digit mobile">
          </div>
        </div>

        <div class="grid-half">
          <div class="mb-4">
            <label>Security Question</label>
            <select name="securityQuestion" required>
              <option value="">Choose a question</option>
              <option>What city were you born in?</option>
              <option>What is your mother's maiden name?</option>
              <option>What was the name of your first pet?</option>
            </select>
          </div>
          <div class="mb-4">
            <label>Security Answer</label>
            <input type="text" name="securityAnswer" required placeholder="Secret answer">
          </div>
        </div>

        <div class="grid-half">
          <div class="mb-4">
            <label>Password</label>
            <input type="password" id="password" name="password" required minlength="8" placeholder="••••••••">
          </div>
          <div class="mb-4">
            <label>Confirm Password</label>
            <input type="password" id="confirmPassword" name="confirmPassword" required minlength="8" placeholder="••••••••">
          </div>
        </div>
      </div>

      <!-- Section 2: Academic Standing -->
      <div class="panel">
        <h3 class="panel-title"><i class="ph-duotone ph-books"></i> Academic Standing</h3>
        <div class="mb-4">
          <label>Institution Name</label>
          <input type="text" name="collegeName" required placeholder="University or Law School">
        </div>

        <div class="grid-half">
          <div class="mb-4">
            <label>Degree Program</label>
            <select name="degreeProgram" required>
              <option value="">Select program</option>
              <option value="LLB3">LLB (3 years)</option>
              <option value="LLB5">LLB (5 years)</option>
              <option value="LLM">LLM</option>
            </select>
          </div>
          <div class="mb-4">
            <label>Year/Semester</label>
            <input type="text" name="yearSemester" required placeholder="e.g. 3rd Year">
          </div>
        </div>

        <div class="mb-4">
          <label>Student ID Number</label>
          <input type="text" name="studentId" required placeholder="Institution enrollment ID">
        </div>

        <div class="grid-half">
          <div class="mb-4">
            <label>ID Card (Front)</label>
            <input type="file" name="collegeIdFront" required accept="image/*,.pdf">
          </div>
          <div class="mb-4">
            <label>ID Card (Back)</label>
            <input type="file" name="collegeIdBack" required accept="image/*,.pdf">
          </div>
        </div>

        <div class="mb-4">
          <label>Bonafide Certificate / Admission Proof</label>
          <input type="file" name="bonafide" required accept="image/*,.pdf">
        </div>
      </div>

      <!-- Section 3: Professional Focus -->
      <div class="panel">
        <h3 class="panel-title"><i class="ph-duotone ph-briefcase"></i> Professional Focus</h3>
        
        <div class="mb-4">
          <label>Practice Areas of Interest</label>
          <div class="custom-check-group">
            <label class="check-item"><input type="checkbox" name="areasOfInterest" value="Criminal"> Criminal Law</label>
            <label class="check-item"><input type="checkbox" name="areasOfInterest" value="Civil"> Civil Law</label>
            <label class="check-item"><input type="checkbox" name="areasOfInterest" value="Corporate"> Corporate Law</label>
            <label class="check-item"><input type="checkbox" name="areasOfInterest" value="Research"> Research</label>
          </div>
        </div>

        <div class="mb-4">
          <label>Specialized Skills</label>
          <div class="custom-check-group">
            <label class="check-item"><input type="checkbox" name="skills" value="LegalResearch"> Legal Research</label>
            <label class="check-item"><input type="checkbox" name="skills" value="CaseDrafting"> Case Drafting</label>
            <label class="check-item"><input type="checkbox" name="skills" value="ClientComm"> Client Communication</label>
            <label class="check-item"><input type="checkbox" name="skills" value="Documentation"> Documentation</label>
          </div>
        </div>

        <div class="grid-half">
          <div class="mb-4">
            <label>Preferred City / Court</label>
            <input type="text" name="preferredCity" required placeholder="e.g. Bengaluru, High Court">
          </div>
          <div class="mb-4">
            <label>Availability</label>
            <select name="availabilityDuration" required>
              <option value="1month">1 Month</option>
              <option value="3months">3 Months</option>
              <option value="6months">6 Months</option>
            </select>
          </div>
        </div>

        <div class="mb-4">
          <label>Internship Mode</label>
          <div class="custom-check-group">
            <label class="check-item"><input type="radio" name="internMode" value="Remote" checked> Remote</label>
            <label class="check-item"><input type="radio" name="internMode" value="InPerson"> On-site</label>
          </div>
        </div>
      </div>

      <!-- Section 4: Ethics & Confidentiality -->
      <div class="panel">
        <h3 class="panel-title"><i class="ph-duotone ph-hand-heart"></i> Ethics & Confidentiality</h3>
        <div class="mb-4">
          <label class="check-item w-100 mb-2">
            <input type="checkbox" name="confRestricted" required>
            <span>I agree to maintain strict confidentiality of all assigned cases.</span>
          </label>
          <label class="check-item w-100 mb-2 mt-2">
            <input type="checkbox" name="confCode" required>
            <span>I accept the Justice4U Intern Code of Professional Conduct.</span>
          </label>
        </div>
      </div>

      <button type="submit" class="btn-submit">Submit Application <i class="ph-bold ph-paper-plane-tilt"></i></button>

      <div class="auth-footer">
        Already part of the program? <a href="internlogin.jsp">Sign In</a>
      </div>
    </form>
  </div>

  <script>
    const urlParams = new URLSearchParams(window.location.search);
    const errorMsg = urlParams.get('error') || urlParams.get('msg');
    const msg = urlParams.get('message');
    
    if (errorMsg) {
      const errorDiv = document.getElementById('errorBox');
      errorDiv.innerText = decodeURIComponent(errorMsg);
      errorDiv.style.display = 'block';
      window.scrollTo({ top: 0, behavior: 'smooth' });
    } else if (msg) {
      const errorDiv = document.getElementById('errorBox');
      errorDiv.innerText = decodeURIComponent(msg);
      errorDiv.style.color = '#B48E2D';
      errorDiv.style.background = '#FEF9C3';
      errorDiv.style.display = 'block';
      window.scrollTo({ top: 0, behavior: 'smooth' });
    }
  </script>
</body>
</html>
