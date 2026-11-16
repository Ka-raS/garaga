FROM maven:3.10.0-eclipse-temurin-25-noble AS build
WORKDIR /build
COPY pom.xml .
RUN mvn -B -q dependency:go-offline
COPY src src
RUN mvn -B -q package -DskipTests

FROM tomcat:11.0.27-jdk25-temurin-noble
RUN rm -rf /usr/local/tomcat/webapps/* && chown -R ubuntu:ubuntu /usr/local/tomcat
COPY --from=build --chown=ubuntu:ubuntu /build/target/garaga.war /usr/local/tomcat/webapps/ROOT.war
USER ubuntu
