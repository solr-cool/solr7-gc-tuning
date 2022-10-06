FROM solr:7.7.3

# use a more recent jdk11
USER root
ENV JAVA_HOME=/usr/local/openjdk-11
COPY --from=eclipse-temurin:11-jdk /opt/java/openjdk $JAVA_HOME
ENV PATH="${JAVA_HOME}/bin:${PATH}"
USER solr
