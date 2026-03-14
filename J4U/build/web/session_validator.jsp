<%!
    /**
     * Standardized session validation utility for Justice4U platform
     * Provides consistent session management across all JSP pages
     */
    
    // Standard session attribute names
    public static final String SESSION_USER_EMAIL = "userEmail";
    public static final String SESSION_USER_ROLE = "userRole";
    public static final String SESSION_USER_ID = "userId";
    public static final String SESSION_USER_NAME = "userName";
    
    /**
     * Validates admin session
     */
    public static boolean validateAdminSession(HttpSession session) {
        String userEmail = (String) session.getAttribute(SESSION_USER_EMAIL);
        String userRole = (String) session.getAttribute(SESSION_USER_ROLE);
        
        return userEmail != null && "admin".equals(userRole);
    }
    
    /**
     * Validates client session
     */
    public static boolean validateClientSession(HttpSession session) {
        String userEmail = (String) session.getAttribute(SESSION_USER_EMAIL);
        String userRole = (String) session.getAttribute(SESSION_USER_ROLE);
        
        return userEmail != null && "client".equals(userRole);
    }
    
    /**
     * Validates lawyer session
     */
    public static boolean validateLawyerSession(HttpSession session) {
        String userEmail = (String) session.getAttribute(SESSION_USER_EMAIL);
        String userRole = (String) session.getAttribute(SESSION_USER_ROLE);
        
        return userEmail != null && "lawyer".equals(userRole);
    }
    
    /**
     * Validates intern session
     */
    public static boolean validateInternSession(HttpSession session) {
        String userEmail = (String) session.getAttribute(SESSION_USER_EMAIL);
        String userRole = (String) session.getAttribute(SESSION_USER_ROLE);
        
        return userEmail != null && "intern".equals(userRole);
    }
    
    /**
     * Validates any authenticated session
     */
    public static boolean validateAuthenticatedSession(HttpSession session) {
        String userEmail = (String) session.getAttribute(SESSION_USER_EMAIL);
        String userRole = (String) session.getAttribute(SESSION_USER_ROLE);
        
        return userEmail != null && userRole != null;
    }
    
    /**
     * Redirects to login if session is invalid for specified role
     */
    public static void requireRole(HttpSession session, String requiredRole, 
                                   HttpServletResponse response) throws IOException {
        String userEmail = (String) session.getAttribute(SESSION_USER_EMAIL);
        String userRole = (String) session.getAttribute(SESSION_USER_ROLE);
        
        if (userEmail == null || userRole == null || !requiredRole.equals(userRole)) {
            session.invalidate();
            response.sendRedirect("Login.html?msg=Unauthorized access");
            return;
        }
    }
    
    /**
     * Redirects to login if session is invalid for any authenticated user
     */
    public static void requireAuthentication(HttpSession session, 
                                            HttpServletResponse response) throws IOException {
        if (!validateAuthenticatedSession(session)) {
            session.invalidate();
            response.sendRedirect("Login.html?msg=Session expired");
            return;
        }
    }
    
    /**
     * Gets current user email from session
     */
    public static String getCurrentUserEmail(HttpSession session) {
        return (String) session.getAttribute(SESSION_USER_EMAIL);
    }
    
    /**
     * Gets current user role from session
     */
    public static String getCurrentUserRole(HttpSession session) {
        return (String) session.getAttribute(SESSION_USER_ROLE);
    }
    
    /**
     * Gets current user ID from session
     */
    public static Object getCurrentUserId(HttpSession session) {
        return session.getAttribute(SESSION_USER_ID);
    }
    
    /**
     * Gets current user name from session
     */
    public static String getCurrentUserName(HttpSession session) {
        return (String) session.getAttribute(SESSION_USER_NAME);
    }
%>
