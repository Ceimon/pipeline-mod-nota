# Build the mod-nota module
FROM maven:3.6.3-jdk-11 as builder
WORKDIR /home/src
COPY pom.xml .
RUN mvn dependency:go-offline

COPY . /home/src

RUN mvn clean package -DskipTests

# add the module to the standard Pipeline v1.11.1 image
FROM daisyorg/pipeline-assembly:v1.13.4
COPY --from=builder /home/src/target/mod-nota-1.3.4-SNAPSHOT.jar /opt/daisy-pipeline2/modules/
