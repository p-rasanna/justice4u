## 📧 Email Approval System Test Guide

### ✅ **System Status: READY FOR TESTING**

I've created a comprehensive email test system for you. Here's how to test the approval and rejection emails:

---

### 🔧 **Step 1: Configure Email Settings**

**File to update:** `src/java/EmailUtil.java`

**Current configuration:**
```java
final String username = "your-email@gmail.com"; // Replace with your email
final String password = "your-app-password"; // Replace with app password
```

**What you need to do:**
1. Replace `"your-email@gmail.com"` with your actual Gmail address
2. Replace `"your-app-password"` with your Gmail App Password
3. **Important:** Use an App Password, not your regular Gmail password

**How to get Gmail App Password:**
1. Go to Google Account settings
2. Enable 2-factor authentication
3. Go to Security → App Passwords
4. Generate new app password for "Mail"
5. Use that 16-character password

---

### 🧪 **Step 2: Test the Email System**

**Access the test page:** `http://localhost:8080/J4U/emailtest.jsp`

**Features available:**
- ✅ View all customers with their current status
- ✅ Test approval emails (updates status to VERIFIED)
- ✅ Test rejection emails (updates status to REJECTED)
- ✅ Real-time feedback on email sending status
- ✅ Professional email templates for both scenarios

---

### 📋 **Step 3: Test Workflow**

**For Approval Test:**
1. Find a customer with "PENDING" status
2. Click "✅ Test Approve" 
3. Email sent with content:
   ```
   Subject: Account Approved - Justice4U
   Body: Congratulations! Your account has been approved and is now active.
   ```

**For Rejection Test:**
1. Find a customer with "PENDING" status  
2. Click "❌ Test Reject"
3. Email sent with content:
   ```
   Subject: Account Registration Status - Justice4U
   Body: We regret to inform you that your registration has been rejected...
   ```

---

### 🔄 **Complete Email Workflow**

**Registration → Approval/Rejection → Email Notification:**

1. **Client registers** → Status = "PENDING"
2. **Admin reviews** → Uses `viewcustomers.jsp` or `emailtest.jsp`
3. **Admin decides** → Clicks Approve/Reject
4. **System updates** → Database status changes
5. **Email sent** → Client receives notification
6. **Client can login** → If approved, access granted

---

### 📁 **Files Involved**

- **`emailtest.jsp`** - New comprehensive testing interface
- **`approvecustomer.jsp`** - Approval with email (✅ Working)
- **`rejectcustomer.jsp`** - Rejection with email (✅ Fixed)
- **`EmailUtil.java`** - Email sending utility (⚠️ Needs credentials)
- **`verification_pending.jsp`** - Customer registration confirmation (✅ Fixed)

---

### 🚀 **Ready to Test!**

1. **Update EmailUtil.java** with your Gmail credentials
2. **Restart your server** to compile changes
3. **Visit** `http://localhost:8080/J4U/emailtest.jsp`
4. **Test approval and rejection emails**

The system will show you exactly which emails are being sent and to whom, with real-time success/failure feedback!
