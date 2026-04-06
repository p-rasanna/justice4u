# ─────────────────────────────────────────────────────────────────────────────
# Stage 1: Build — compile Java source with javac (no Ant/NetBeans needed)
# ─────────────────────────────────────────────────────────────────────────────
FROM tomcat:9.0-jdk11-temurin AS builder

WORKDIR /build

# Copy source code and web resources
COPY src/java/ ./src/
COPY web/ ./web/

# Create output directory
RUN mkdir -p ./classes

# Compile all Java source files against Tomcat's servlet/jsp APIs
RUN find ./src -name "*.java" > sources.txt && \
    javac \
      -cp "/usr/local/tomcat/lib/servlet-api.jar:/usr/local/tomcat/lib/jsp-api.jar:./web/WEB-INF/lib/*" \
      -d ./classes \
      -encoding UTF-8 \
      -source 8 -target 8 \
      @sources.txt

# ─────────────────────────────────────────────────────────────────────────────
# Stage 2: Runtime — Tomcat 9 (javax.* namespace, compatible with our code)
# ─────────────────────────────────────────────────────────────────────────────
FROM tomcat:9.0-jdk11-temurin

LABEL maintainer="Justice4U"
LABEL description="Justice4U Legal Services Platform"

# Performance tuning
ENV CATALINA_OPTS="-Xmx512m -Xms256m"
ENV JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom"

# Remove default Tomcat apps
RUN rm -rf /usr/local/tomcat/webapps/*

# Deploy as ROOT context (accessible at /)
COPY web/ /usr/local/tomcat/webapps/ROOT/

# Copy compiled Java classes
COPY --from=builder /build/classes/ /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/

# Copy runtime JARs
COPY web/WEB-INF/lib/ /usr/local/tomcat/webapps/ROOT/WEB-INF/lib/

# Copy deployment descriptor
COPY web/WEB-INF/web.xml /usr/local/tomcat/webapps/ROOT/WEB-INF/web.xml

# Create uploads directory with correct permissions
RUN mkdir -p /usr/local/tomcat/webapps/ROOT/uploads && \
    chmod -R 755 /usr/local/tomcat/webapps/ROOT

# Expose Tomcat port (Railway uses PORT env var)
EXPOSE 8080

CMD ["catalina.sh", "run"]
