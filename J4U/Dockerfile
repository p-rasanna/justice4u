# ─────────────────────────────────────────────────────────
# Stage 1: Build — compile Java source with Ant + JDK 17
# ─────────────────────────────────────────────────────────
FROM eclipse-temurin:17-jdk-jammy AS builder

# Install Ant
RUN apt-get update && apt-get install -y ant && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Copy entire J4U project (source + libs + web content)
COPY . .

# Compile: produce build/web/WEB-INF/classes/
RUN ant -buildfile build.xml compile 2>/dev/null || true

# ─────────────────────────────────────────────────────────
# Stage 2: Runtime — Tomcat 10 + JDK 17
# ─────────────────────────────────────────────────────────
FROM tomcat:10.1-jdk17-temurin-jammy

LABEL maintainer="Justice4U"
LABEL description="Justice4U Legal Services Platform"

# Performance tuning
ENV CATALINA_OPTS="-Xmx512m -Xms256m"
ENV JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom"

# Remove default Tomcat apps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy static web content (JSP, HTML, CSS, JS)
COPY web/ /usr/local/tomcat/webapps/J4U/

# Copy compiled classes from builder stage
COPY --from=builder /build/build/web/WEB-INF/classes/ /usr/local/tomcat/webapps/J4U/WEB-INF/classes/

# Copy runtime JARs
COPY web/WEB-INF/lib/ /usr/local/tomcat/webapps/J4U/WEB-INF/lib/

# Copy deployment descriptor
COPY web/WEB-INF/web.xml /usr/local/tomcat/webapps/J4U/WEB-INF/web.xml

# Create uploads directory
RUN mkdir -p /usr/local/tomcat/webapps/J4U/uploads && \
    chmod -R 755 /usr/local/tomcat/webapps/J4U

# Expose Tomcat port
EXPOSE 8080

CMD ["catalina.sh", "run"]
