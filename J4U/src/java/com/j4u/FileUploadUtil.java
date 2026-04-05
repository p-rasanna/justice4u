package com.j4u;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.http.Part;
public class FileUploadUtil {
  private static final Logger LOGGER = Logger.getLogger(FileUploadUtil.class.getName());
  private static final List<String> ALLOWED_EXTENSIONS = Arrays.asList(
      "pdf", "doc", "docx", "txt", "rtf", // Documents
      "jpg", "jpeg", "png", "gif", "bmp", // Images
      "xls", "xlsx", "csv" // Spreadsheets
  );
  private static final long MAX_FILE_SIZE = 50L * 1024 * 1024; // 50MB
  private static final long MAX_IMAGE_SIZE = 10L * 1024 * 1024; // 10MB for images
  private static final List<String> ALLOWED_CONTENT_TYPES = Arrays.asList(
      "application/pdf",
      "application/msword",
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
      "text/plain",
      "text/rtf",
      "image/jpeg",
      "image/png",
      "image/gif",
      "image/bmp",
      "application/vnd.ms-excel",
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
      "text/csv");
  private FileUploadUtil() {
    throw new IllegalStateException("Utility class");
  }
  public static ValidationResult validateFile(Part filePart) throws IOException {
    if (filePart == null) {
      return new ValidationResult(false, "No file provided");
    }
    String fileName = getFileName(filePart);
    if (fileName == null || fileName.trim().isEmpty()) {
      return new ValidationResult(false, "Invalid file name");
    }
    String extension = getFileExtension(fileName);
    if (!ALLOWED_EXTENSIONS.contains(extension.toLowerCase())) {
      return new ValidationResult(false,
          "File type not allowed. Allowed types: " + String.join(", ", ALLOWED_EXTENSIONS));
    }
    String contentType = filePart.getContentType();
    if (contentType != null && !ALLOWED_CONTENT_TYPES.contains(contentType.toLowerCase())) {
      return new ValidationResult(false, "Invalid content type: " + contentType);
    }
    long fileSize = filePart.getSize();
    if (fileSize > MAX_FILE_SIZE) {
      return new ValidationResult(false, "File too large. Maximum size: 50MB");
    }
    if (isImageFile(extension) && fileSize > MAX_IMAGE_SIZE) {
      return new ValidationResult(false, "Image file too large. Maximum size: 10MB");
    }
    if (containsMaliciousContent(filePart)) {
      return new ValidationResult(false, "File contains potentially malicious content");
    }
    return new ValidationResult(true, "File validation successful");
  }
  public static UploadResult saveFile(Part filePart, String uploadDir) throws IOException {
    ValidationResult validation = validateFile(filePart);
    if (!validation.isValid()) {
      return new UploadResult(false, validation.getMessage(), null, null);
    }
    Path uploadPath = Paths.get(uploadDir);
    if (!Files.exists(uploadPath)) {
      Files.createDirectories(uploadPath);
    }
    String originalFileName = getFileName(filePart);
    String extension = getFileExtension(originalFileName);
    String secureFileName = generateSecureFileName(extension);
    Path filePath = uploadPath.resolve(secureFileName);
    Files.copy(filePart.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
    return new UploadResult(true, "File uploaded successfully", secureFileName, filePath.toString());
  }
  private static String generateSecureFileName(String extension) {
    String uuid = UUID.randomUUID().toString().replace("-", "");
    return uuid + "." + extension;
  }
  private static String getFileExtension(String fileName) {
    int lastDotIndex = fileName.lastIndexOf('.');
    if (lastDotIndex > 0 && lastDotIndex < fileName.length() - 1) {
      return fileName.substring(lastDotIndex + 1);
    }
    return "";
  }
  private static boolean isImageFile(String extension) {
    return Arrays.asList("jpg", "jpeg", "png", "gif", "bmp").contains(extension.toLowerCase());
  }
  private static String getFileName(Part part) {
    String contentDisp = part.getHeader("content-disposition");
    if (contentDisp != null) {
      for (String content : contentDisp.split(";")) {
        if (content.trim().startsWith("filename")) {
          return content.substring(content.indexOf('=') + 1).trim().replace("\"", "");
        }
      }
    }
    return null;
  }
  private static boolean containsMaliciousContent(Part filePart) throws IOException {
    byte[] buffer = new byte[1024];
    int bytesRead = filePart.getInputStream().read(buffer);
    if (bytesRead > 0) {
      String content = new String(buffer, 0, bytesRead);
      String[] maliciousPatterns = {
          "<script", "<%", "<jsp", "<asp",
          "javascript:", "vbscript:", "onload=", "onerror="
      };
      for (String pattern : maliciousPatterns) {
        if (content.toLowerCase().contains(pattern.toLowerCase())) {
          return true;
        }
      }
    }
    return false;
  }
  public static boolean deleteFile(String filePath) {
    try {
      Path path = Paths.get(filePath);
      return Files.deleteIfExists(path);
    } catch (Exception e) {
      LOGGER.log(Level.SEVERE, "Error deleting file: {0}", e.getMessage());
      return false;
    }
  }
  public static String formatFileSize(long bytes) {
    if (bytes < 1024)
      return bytes + " B";
    int exp = (int) (Math.log(bytes) / Math.log(1024));
    String pre = "KMGTPE".charAt(exp - 1) + "";
    return String.format("%.1f %sB", bytes / Math.pow(1024, exp), pre);
  }
  public static class ValidationResult {
    private final boolean valid;
    private final String message;
    public ValidationResult(boolean valid, String message) {
      this.valid = valid;
      this.message = message;
    }
    public boolean isValid() {
      return valid;
    }
    public String getMessage() {
      return message;
    }
  }
  public static class UploadResult {
    private final boolean success;
    private final String message;
    private final String fileName;
    private final String filePath;
    public UploadResult(boolean success, String message, String fileName, String filePath) {
      this.success = success;
      this.message = message;
      this.fileName = fileName;
      this.filePath = filePath;
    }
    public boolean isSuccess() {
      return success;
    }
    public String getMessage() {
      return message;
    }
    public String getFileName() {
      return fileName;
    }
    public String getFilePath() {
      return filePath;
    }
  }
}