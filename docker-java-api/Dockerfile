# Build da aplicação com Maven
FROM eclipse-temurin:21-jdk-alpine AS builder
WORKDIR /app
COPY . .
RUN chmod +x mvnw
RUN ./mvnw clean package -DskipTests


# Execução leve apenas com o JRE
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app


RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=builder /app/target/*.jar app.jar


RUN chown appuser:appgroup app.jar


USER appuser

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
