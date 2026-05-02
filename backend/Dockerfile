# ── Stage 1: Build ──────────────────────────────────────────────────────────
FROM amazoncorretto:17 AS build
WORKDIR /app

# Install Maven 3.9 manually (yum version is too old)
RUN yum install -y wget tar gzip && \
    wget -q https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz && \
    tar -xzf apache-maven-3.9.6-bin.tar.gz && \
    mv apache-maven-3.9.6 /opt/maven && \
    rm apache-maven-3.9.6-bin.tar.gz

ENV PATH="/opt/maven/bin:$PATH"

COPY pom.xml .
COPY src ./src
RUN mvn package -DskipTests

# ── Stage 2: Runtime ────────────────────────────────────────────────────────
FROM amazoncorretto:17
WORKDIR /app
COPY --from=build /app/target/loantrack-backend-*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "-jar", "app.jar"]
