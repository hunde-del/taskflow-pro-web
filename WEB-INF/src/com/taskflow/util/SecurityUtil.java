package com.taskflow.util;

import org.mindrot.jbcrypt.BCrypt;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.util.Base64;

/**
 * SecurityUtil - Handles BCrypt hashing, token generation, and HMAC verification.
 */
public class SecurityUtil {

    private static final SecureRandom RANDOM = new SecureRandom();
    private static final String APP_SECRET   = "TaskFlowPro@SecretKey2025!XYZ";
    private static final int    BCRYPT_ROUNDS = 12;

    // ----------------------------------------------------------------
    // BCrypt Password Hashing
    // ----------------------------------------------------------------

    /** Hash a plain-text password using BCrypt. */
    public static String hashPassword(String plainPassword) {
        return BCrypt.hashpw(plainPassword, BCrypt.gensalt(BCRYPT_ROUNDS));
    }

    /** Check if a plain-text password matches the stored BCrypt hash. */
    public static boolean checkPassword(String plainPassword, String hashedPassword) {
        if (plainPassword == null || hashedPassword == null) return false;
        try {
            return BCrypt.checkpw(plainPassword, hashedPassword);
        } catch (Exception e) {
            return false;
        }
    }

    // ----------------------------------------------------------------
    // Secure Token Generation
    // ----------------------------------------------------------------

    /** Generate a cryptographically secure random token (URL-safe Base64). */
    public static String generateToken(int byteLength) {
        byte[] bytes = new byte[byteLength];
        RANDOM.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    /** Generate a simple 6-digit OTP (for email verification). */
    public static String generateOTP() {
        int otp = 100000 + RANDOM.nextInt(900000);
        return String.valueOf(otp);
    }

    // ----------------------------------------------------------------
    // CSRF Protection
    // ----------------------------------------------------------------

    /** Generate a CSRF token and store it in the user's session. */
    public static String generateCsrfToken() {
        return generateToken(24);
    }

    /** Validate CSRF token (constant-time comparison). */
    public static boolean validateCsrfToken(String expected, String actual) {
        if (expected == null || actual == null) return false;
        if (expected.length() != actual.length()) return false;
        int diff = 0;
        for (int i = 0; i < expected.length(); i++) {
            diff |= expected.charAt(i) ^ actual.charAt(i);
        }
        return diff == 0;
    }

    // ----------------------------------------------------------------
    // HMAC Signature (for simple API tokens)
    // ----------------------------------------------------------------

    /** Create an HMAC-SHA256 signature for data. */
    public static String hmacSign(String data) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            SecretKeySpec keySpec = new SecretKeySpec(
                    APP_SECRET.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
            mac.init(keySpec);
            byte[] sig = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
            return Base64.getUrlEncoder().withoutPadding().encodeToString(sig);
        } catch (Exception e) {
            throw new RuntimeException("HMAC signing failed", e);
        }
    }

    // ----------------------------------------------------------------
    // XSS Sanitization
    // ----------------------------------------------------------------

    /** Escape HTML special characters to prevent XSS. */
    public static String escapeHtml(String input) {
        if (input == null) return "";
        return input
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#x27;")
                .replace("/", "&#x2F;");
    }

    /** Strip all HTML tags from user input. */
    public static String stripHtml(String input) {
        if (input == null) return "";
        return input.replaceAll("<[^>]*>", "").trim();
    }

    // ----------------------------------------------------------------
    // Input Validation
    // ----------------------------------------------------------------

    public static boolean isValidEmail(String email) {
        if (email == null) return false;
        return email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    }

    public static boolean isValidUsername(String username) {
        if (username == null) return false;
        return username.matches("^[A-Za-z0-9_]{3,50}$");
    }

    public static boolean isStrongPassword(String password) {
        if (password == null || password.length() < 8) return false;
        boolean hasUpper = password.chars().anyMatch(Character::isUpperCase);
        boolean hasLower = password.chars().anyMatch(Character::isLowerCase);
        boolean hasDigit = password.chars().anyMatch(Character::isDigit);
        return hasUpper && hasLower && hasDigit;
    }
}
