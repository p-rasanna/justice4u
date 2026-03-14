package util;

import javax.mail.*;
import javax.mail.internet.*;
import java.util.Properties;

public class EmailUtil {

    public static void sendEmail(String to, String subject, String body) {
        // SMTP server properties
        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.ssl.protocols", "TLSv1.2 TLSv1.3");
        props.put("mail.smtp.ssl.trust", "smtp.gmail.com");

        // Sender's credentials
        final String username = "info.justice4u@gmail.com";
        
        // Get password from system properties (safer than hardcoding)
        String password = System.getProperty("email.password");
        
        if (password == null) {
            // Try environment variable as fallback
            password = System.getenv("EMAIL_PASSWORD");
        }
        
        if (password == null || password.isEmpty()) {
            throw new RuntimeException("Email password not configured. "
                + "Set it via -Demail.password=yourpassword or EMAIL_PASSWORD env variable");
        }

        Session session = Session.getInstance(props, new javax.mail.Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(username, password);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(username));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
            message.setSubject(subject);
            message.setText(body);

            Transport.send(message);
            System.out.println("Email sent successfully to " + to);
        } catch (MessagingException e) {
            System.err.println("Failed to send email: " + e.getMessage());
            throw new RuntimeException("Email sending failed", e);
        }
    }
    
    // Test method
    public static void main(String[] args) {
        if (args.length < 3) {
            System.out.println("Usage: java util.EmailUtil <to> <subject> <body>");
            System.out.println("Example: java util.EmailUtil test@example.com \"Test\" \"Hello\"");
            return;
        }
        
        try {
            sendEmail(args[0], args[1], args[2]);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}