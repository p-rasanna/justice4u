import java.security.MessageDigest;
import java.util.Base64;

public class HashTest {
    public static void main(String[] args) throws Exception {
        String password = args[0];
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        byte[] hashedBytes = md.digest(password.getBytes(java.nio.charset.StandardCharsets.UTF_8));
        System.out.println(Base64.getEncoder().encodeToString(hashedBytes));
    }
}
