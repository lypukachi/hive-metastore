FROM ubuntu:18.04

RUN apt-get -y update && \
    apt-get install -y curl openjdk-8-jre-headless mysql-client libpostgresql-jdbc-java && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre
ENV HADOOP_HOME=/opt/hadoop-3.1.3
ENV HIVE_HOME=/opt/apache-hive-3.1.2-bin
# Include additional jars
ENV HADOOP_CLASSPATH=${HADOOP_HOME}/share/hadoop/tools/lib/aws-java-sdk-bundle-1.11.271.jar:${HADOOP_HOME}/share/hadoop/tools/lib/hadoop-aws-3.1.3.jar

RUN curl -L https://www-us.apache.org/dist/hive/hive-3.1.2/apache-hive-3.1.2-bin.tar.gz | tar zxf - && \
    curl -L https://www-us.apache.org/dist/hadoop/common/hadoop-3.1.3/hadoop-3.1.3.tar.gz | tar zxf - && \
    rm -f ${HIVE_HOME}/lib/guava-19.0.jar && \
    cp ${HADOOP_HOME}/share/hadoop/common/lib/guava-27.0-jre.jar ${HIVE_HOME}/lib/ && \
    curl -L https://downloads.mariadb.com/Connectors/java/latest/mariadb-java-client-2.3.0.jar > ${HIVE_HOME}/lib/mariadb-java-client-2.3.0.jar && \
    ln -s /usr/share/java/postgresql-jdbc4.jar ${HIVE_HOME}/lib/postgresql-jdbc4.jar

COPY conf/hive-site.xml ${HIVE_HOME}/conf

RUN groupadd -r hive --gid=1000 && \
    useradd -r -g hive --uid=1000 -d ${HIVE_HOME} hive && \
    chown hive:hive -R ${HIVE_HOME}

USER 1000
WORKDIR $HIVE_HOME
EXPOSE 9083

ENTRYPOINT ["bin/hive"]
CMD ["--service", "metastore"]
