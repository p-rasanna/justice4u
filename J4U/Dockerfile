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

# Copy WAR file or exploded webapp
# First copy the web content and classes
COPY web/ /usr/local/tomcat/webapps/J4U/
COPY build/web/WEB-INF/classes/ /usr/local/tomcat/webapps/J4U/WEB-INF/classes/ 2>/dev/null || true
COPY build/web/WEB-INF/lib/ /usr/local/tomcat/webapps/J4U/WEB-INF/lib/ 2>/dev/null || true

# Copy web.xml
COPY web/WEB-INF/web.xml /usr/local/tomcat/webapps/J4U/WEB-INF/ 2>/dev/null || true

# Create context.xml for database connection if needed
RUN mkdir -p /usr/local/tomcat/conf/Catalina/localhost

# Set permissions
RUN chmod -R 755 /usr/local/tomcat/webapps/J4U

# Expose port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
