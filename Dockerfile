# ---- Build Stage ----
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

# Copy pom.xml first and download dependencies
COPY pom.xml .
RUN mvn dependency:go-offline

# Copy all source code
COPY src ./src

# Build the project (skip tests for faster deploy)
RUN mvn clean package -DskipTests

# ---- Runtime Stage ----
FROM eclipse-temurin:17-jre
WORKDIR /app

# Copy built jar from build stage
COPY --from=build /app/target/*.jar app.jar

# Expose 3032 for local reference
EXPOSE 3032

# For Render: override port if $PORT is set, otherwise use 3032
ENTRYPOINT ["sh", "-c", "java -jar app.jar --server.port=${PORT:-3032}"]
