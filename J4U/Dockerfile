# Use the official Tomcat 9 image with JDK 11 (or match your JDK version)
FROM tomcat:9.0-jdk11

# Delete default Tomcat applications to keep it clean
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy your generated WAR file to Tomcat's webapps directory 
# We name it ROOT.war so it serves from the root URL (/) instead of /J4U
COPY dist/J4U.war /usr/local/tomcat/webapps/ROOT.war

# Expose the default Tomcat port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
