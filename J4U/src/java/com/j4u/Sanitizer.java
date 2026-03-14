package com.j4u;

/**
 * Basic utility for XSS sanitization.
 * Used to clean user input before displaying it in JSPs.
 */
public class Sanitizer {

    /**
     * Sanitizes a string for safe HTML display.
     * Escapes standard HTML characters: <, >, &, ", '
     * 
     * @param input The raw input string
     * @return Sanitized string or empty string if input is null
     */
    public static String clean(String input) {
        if (input == null) {
            return "";
        }
        StringBuilder safe = new StringBuilder();
        for (int i = 0; i < input.length(); i++) {
            char c = input.charAt(i);
            switch (c) {
                case '<':
                    safe.append("&lt;");
                    break;
                case '>':
                    safe.append("&gt;");
                    break;
                case '&':
                    safe.append("&amp;");
                    break;
                case '"':
                    safe.append("&quot;");
                    break;
                case '\'':
                    safe.append("&#x27;");
                    break;
                case '/':
                    safe.append("&#x2F;");
                    break;
                default:
                    safe.append(c);
            }
        }
        return safe.toString();
    }

    public static String sanitize(String input) {
        return clean(input);
    }
}
