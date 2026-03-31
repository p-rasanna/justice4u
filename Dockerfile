# Tomcat 10 with JDK 17
FROM tomcat:10.1-jdk17-temurin-jammy

LABEL maintainer="Justice4U"
LABEL description="Justice4U Legal Services Platform"

# Install required packages
RUN apt-get update && apt-get install -y \
    default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV CATALINA_OPTS="-Xmx512m -Xms256m"
ENV JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom"

# Remove default Tomcat apps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy web content from J4U directory
COPY J4U/web/ /usr/local/tomcat/webapps/J4U/
COPY J4U/build/web/WEB-INF/classes/ /usr/local/tomcat/webapps/J4U/WEB-INF/classes/ 2>/dev/null || true
COPY J4U/build/web/WEB-INF/lib/ /usr/local/tomcat/webapps/J4U/WEB-INF/lib/ 2>/dev/null || true
COPY J4U/web/WEB-INF/web.xml /usr/local/tomcat/webapps/J4U/WEB-INF/ 2>/dev/null || true

# Set permissions
RUN chmod -R 755 /usr/local/tomcat/webapps/J4U

# Expose port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
