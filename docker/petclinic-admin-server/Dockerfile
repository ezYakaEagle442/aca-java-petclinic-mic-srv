# TODO : study https://spring.io/guides/gs/spring-boot-docker/
# ==> with this maven plugin, there is no more need of Dockerfile
# ./mvnw spring-boot:build-image -Dspring-boot.build-image.imageName=springio/gs-spring-boot-docker

# Multi-Stage pipeline: 

# docker build --build-arg --no-cache -t "petclinic-admin-server" -f "./docker/petclinic-admin-server/Dockerfile" .
# docker image ls
# docker run -p 8080:8080 -p 8081:8081 -p 8888:8888 -p 9090:9090 petclinic-admin-server 
# docker container ls
# docker ps
# docker exec -it b177880414c5 /bin/sh
# docker inspect --format '{{ .NetworkSettings.Networks.bridge.IPAddress }}' <container>  
# docker images --filter reference=petclinic-admin-server --format "{{.Tag}}"

# https://docs.microsoft.com/en-us/java/openjdk/containers
FROM mcr.microsoft.com/openjdk/jdk:11-mariner as builder
ENV APP_INSIGHTS_AGENT_JAR_FILE_PATH  = "/tmp/app/applicationinsights-agent-3.3.0.jar"

LABEL Maintainer="pinpin <noname@microsoft.com>"
LABEL Description="PetClinic admin-server: Java Spring Boot microservice built from MS OpenJDK 11-Mariner"

# ARG MAVEN_VERSION=3.8.4  

RUN java -version
RUN ls -al /usr/lib/jvm/msopenjdk-11

RUN mkdir /tmp/app
WORKDIR /tmp/app

COPY "spring-petclinic-admin-server/target/*.jar" /tmp/app/app.jar

# RUN yum install maven -y

# RUN wget https://dlcdn.apache.org/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz
# RUN unzip apache-maven-$MAVEN_VERSION-bin.zip
# "RUN tar xzvf apache-maven-$MAVEN_VERSION-bin.tar.gz
# RUN export PATH=apache-maven-$MAVEN_VERSION/bin:$PATH

# RUN mvn clean spring-javaformat:apply 
# RUN mvn package -DskipTests

# https://spring.io/blog/2020/01/27/creating-docker-images-with-spring-boot-2-3-0-m1
# https://www.baeldung.com/docker-layers-spring-boot

# https://docs.docker.com/engine/reference/builder/#environment-replacement

# Spring Cloud for Azure params required to get secrets from Key Vault.
# those secrets will be injected from Bicep while creating the ACA Apps
# ENV AZURE_CLIENT_ID=ThisIsASecretValue
# ENV AZURE_CLIENT_SECRET=ThisIsASecretValue
# ENV AZURE_KEY_VAULT_ENDPOINT=ThisIsASecretValue
# ENV AZURE_TENANT_ID=ThisIsASecretValue


RUN curl -SL --output ${APP_INSIGHTS_AGENT_JAR_FILE_PATH} https://github.com/microsoft/ApplicationInsights-Java/releases/download/3.3.0/applicationinsights-agent-3.3.0.jar
RUN java -Djarmode=layertools -jar "/tmp/app/app.jar" extract

# wget is not installed on adoptopenjdk:11-jre-hotspot
FROM mcr.microsoft.com/openjdk/jdk:11-mariner
WORKDIR /tmp/app
# VOLUME /tmp
COPY --from=builder ${APP_INSIGHTS_AGENT_JAR_FILE_PATH} ./
COPY --from=builder /tmp/app/dependencies/ ./
COPY --from=builder /tmp/app/snapshot-dependencies/ ./
COPY --from=builder /tmp/app/spring-boot-loader/ ./
COPY --from=builder /tmp/app/application/ ./
# COPY --from=builder /tmp/app/target/*.jar app.jar
# COPY target/*.jar app.jar
# RUN touch /app.jar
EXPOSE 80 8080 8081 8082 8083 8084 8888 9090

ENV APP_INSIGHTS_AGENT_JAR_FILE_PATH = "/tmp/app/applicationinsights-agent-3.3.0.jar"
ENV SPRING_PROFILES_ACTIVE = "docker,mysql"

ENTRYPOINT ["java", "-javaagent:${APP_INSIGHTS_AGENT_JAR_FILE_PATH}", "org.springframework.boot.loader.JarLauncher", "--server.port=9090", "--spring.profiles.active=docker,mysql"]
# ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "/tmp/app/app.jar"]