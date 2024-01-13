FROM ubuntu:20.04

RUN apt-get update -q && \
    apt-get install -y openjdk-8-jdk && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt

COPY staging/com/meportal/springboot-app/1.0/springboot-app-1.0.war welcomeapp.war

CMD ["java", "-jar", "welcomeapp.war"]
