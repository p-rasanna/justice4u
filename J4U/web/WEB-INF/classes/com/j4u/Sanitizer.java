package com.j4u;

public class Sanitizer {
    /**
     * Sanitizes input string to prevent XSS attacks by escaping HTML special
     * characters.
     * 
     * @param input The string to sanitize
     * @return The sanitized string safe for HTML display
     */
    public static String sanitize(String input) {
        if (input == null) {
            return "";
        }
        return input.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#x27;")
                .replace("/", "&#x2F;");
    }
}
