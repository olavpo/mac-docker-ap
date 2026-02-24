FROM ubuntu:24.04

RUN apt update

RUN apt install curl gnupg -y

RUN curl -fsSL 'https://packages.clickhouse.com/rpm/lts/repodata/repomd.xml.key' | \
    gpg --dearmor -o /usr/share/keyrings/clickhouse-keyring.gpg

RUN echo "deb [signed-by=/usr/share/keyrings/clickhouse-keyring.gpg] \
    https://packages.clickhouse.com/deb stable main" | \
    tee /etc/apt/sources.list.d/clickhouse.list

WORKDIR /app

RUN apt update && apt upgrade -y

RUN apt install -y openjdk-17-jdk apt-transport-https wget postgresql-client-common postgresql-client-16 clickhouse-client

RUN wget https://bao-products-builds.s3.us-east-1.amazonaws.com/analytics-platform/master/bao-data-pipeline.jar

RUN chmod +x bao-data-pipeline.jar

# Create system user/group first
RUN addgroup --system --gid 1001 bao-admin \
 && adduser  --system --uid 1001 --ingroup bao-admin bao-admin

# Create directories with correct permissions BEFORE switching user
RUN mkdir -p /opt/bao-data-pipeline/logs \
    && mkdir -p /opt/bao-data-pipeline/data-pipeline \
    && chown -R 1001:1001 /opt/bao-data-pipeline /app \
    && chmod -R 755 /opt/bao-data-pipeline


USER bao-admin

EXPOSE 8084

ENV JAVA_OPTS="-Xms1024M -Xmx2048M -Dlogging.file.path=/opt/bao-data-pipeline/logs"

ENV CACHE_DIR="/opt/bao-data-pipeline/data-pipeline"

CMD ["java", "-jar", "bao-data-pipeline.jar"]