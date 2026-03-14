package com.j4u;

import javax.servlet.ServletException;

/**
 * Centralized input validation utility for Justice4U platform
 * Provides comprehensive validation methods for common input types
 */
public class ValidationHelper {

    /**
     * Validates integer parameters with positive number check
     */
    public static int validateIntParam(String param, String paramName) throws ServletException {
        if (param == null || param.trim().isEmpty()) {
            throw new ServletException("Missing required parameter: " + paramName);
        }
        try {
            int value = Integer.parseInt(param.trim());
            if (value <= 0) {
                throw new ServletException("Invalid " + paramName + ": must be positive number");
            }
            return value;
        } catch (NumberFormatException e) {
            throw new ServletException("Invalid " + paramName + ": must be a number");
        }
    }

    /**
     * Validates string parameters with null/empty check
     */
    public static String validateStringParam(String param, String paramName) throws ServletException {
        if (param == null || param.trim().isEmpty()) {
            throw new ServletException("Missing required parameter: " + paramName);
        }
        return param.trim();
    }

    /**
     * Validates and sanitizes string parameters for database usage
     */
    public static String validateAndSanitizeString(String param, String paramName) throws ServletException {
        if (param == null || param.trim().isEmpty()) {
            throw new ServletException("Missing required parameter: " + paramName);
        }
        // Basic sanitization to prevent SQL injection in string values
        // Note: This is additional protection - PreparedStatement should be primary defense
        return param.trim().replace("'", "''");
    }

    /**
     * Validates email format
     */
    public static String validateEmail(String email, String paramName) throws ServletException {
        String validatedEmail = validateStringParam(email, paramName);
        
        // Basic email validation
        if (!validatedEmail.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
            throw new ServletException("Invalid " + paramName + ": must be a valid email address");
        }
        
        return validatedEmail.toLowerCase();
    }

    /**
     * Validates action parameter against allowed values
     */
    public static String validateAction(String action, String[] allowedActions) throws ServletException {
        String validatedAction = validateStringParam(action, "action");
        
        for (String allowedAction : allowedActions) {
            if (allowedAction.equals(validatedAction)) {
                return validatedAction;
            }
        }
        
        throw new ServletException("Invalid action: must be one of " + String.join(", ", allowedActions));
    }

    /**
     * Validates date format (YYYY-MM-DD)
     */
    public static String validateDate(String date, String paramName) throws ServletException {
        String validatedDate = validateStringParam(date, paramName);
        
        if (!validatedDate.matches("^\\d{4}-\\d{2}-\\d{2}$")) {
            throw new ServletException("Invalid " + paramName + ": must be in YYYY-MM-DD format");
        }
        
        return validatedDate;
    }

    /**
     * Validates phone number format
     */
    public static String validatePhone(String phone, String paramName) throws ServletException {
        String validatedPhone = validateStringParam(phone, paramName);
        
        // Remove common formatting characters
        String cleanPhone = validatedPhone.replaceAll("[\\s\\-()]", "");
        
        // Check if it contains only digits and reasonable length
        if (!cleanPhone.matches("^\\d{10,15}$")) {
            throw new ServletException("Invalid " + paramName + ": must be 10-15 digits");
        }
        
        return validatedPhone;
    }

    /**
     * Validates parameter length
     */
    public static String validateLength(String param, String paramName, int maxLength) throws ServletException {
        String validatedParam = validateStringParam(param, paramName);
        
        if (validatedParam.length() > maxLength) {
            throw new ServletException("Invalid " + paramName + ": maximum length is " + maxLength + " characters");
        }
        
        return validatedParam;
    }
}
