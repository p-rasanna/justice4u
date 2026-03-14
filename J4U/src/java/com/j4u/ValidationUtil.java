package com.j4u;

import java.util.regex.Pattern;

public class ValidationUtil {

    public static boolean validateInput(String value, String pattern, int maxLength) {
        if (value == null || value.trim().isEmpty())
            return false;
        if (value.length() > maxLength)
            return false;
        return pattern == null || Pattern.matches(pattern, value);
    }

    public static String sanitize(String input) {
        if (input == null)
            return null;
        return input.replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#x27;");
    }
}
