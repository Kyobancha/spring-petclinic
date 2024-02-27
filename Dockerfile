FROM amazoncorretto:17.0.10 AS build
WORKDIR /app
COPY gradlew build.gradle settings.gradle ./
COPY gradle gradle
RUN --mount=type=cache,id=gradle-cache,target=/root/.gradle ./gradlew --no-daemon --write-verification-metadata sha256 help && rm gradle/verification-metadata.xml
COPY src src
RUN --mount=type=cache,id=gradle-cache,target=/root/.gradle ./gradlew --no-daemon --build-cache -x test build

# makes a reference to the corresponding SHA, but doesn't download the content itself.
# Only the runner needs the .jar-file
FROM eclipse-temurin:17.0.10_7-jre-jammy AS final
EXPOSE 8080
COPY --from=build --link /app/build/libs/spring-petclinic-3.2.0.jar /petclinic.jar
CMD [ "java", "-jar", "/petclinic.jar" ]