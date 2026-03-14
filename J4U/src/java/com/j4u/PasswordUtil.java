package com.j4u;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

import java.util.Base64;
import java.util.logging.Level;
import java.util.logging.Logger;

public class PasswordUtil {

    private static final Logger LOGGER = Logger.getLogger(PasswordUtil.class.getName());
    private static final String HASH_ALGORITHM = "SHA-256";

    // Private constructor to hide implicit public one
    private PasswordUtil() {
        throw new IllegalStateException("Utility class");
    }

    /**
     * Hashes a password using SHA-256 and returns Base64 encoded hash
     * 
     * @param password The plain text password to hash
     * @return Base64 encoded string containing hash
     */
    public static String hashPassword(String password) {
        if (password == null) {
            return null;
        }
        try {
            MessageDigest md = MessageDigest.getInstance(HASH_ALGORITHM);
            byte[] hashedBytes = md.digest(password.getBytes(java.nio.charset.StandardCharsets.UTF_8));
            return Base64.getEncoder().encodeToString(hashedBytes);
        } catch (NoSuchAlgorithmException e) {
            LOGGER.log(Level.SEVERE, "Hashing algorithm not found", e);
            throw new RuntimeException("Error hashing password", e);
        }
    }

    /**
     * Verifies a password against a stored hash
     * 
     * @param password   The plain text password to check
     * @param storedHash The Base64 encoded hash from database
     * @return true if password matches, false otherwise
     */
    public static boolean verifyPassword(String password, String storedHash) {
        if (password == null || storedHash == null) {
            return false;
        }
        String hashedInput = hashPassword(password);
        return hashedInput.equals(storedHash);
    }
}
