# Dvofazni build: prvo Gradle, pa mali runtime image bez izvornog koda i bez Gradle-a.
FROM gradle:8.12-jdk21-alpine AS build
WORKDIR /build
# Zavisnosti u zaseban sloj — menjaju se retko, izvorni kod cesto.
COPY settings.gradle.kts build.gradle.kts ./
COPY gradle ./gradle
RUN gradle dependencies --no-daemon || true
COPY src ./src
RUN gradle bootJar --no-daemon -x test

FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
# Ne kao root.
RUN addgroup -S app && adduser -S app -G app
COPY --from=build /build/build/libs/*.jar app.jar
USER app
EXPOSE 8080
ENV JAVA_OPTS="-XX:MaxRAMPercentage=75 -XX:+UseContainerSupport"
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
