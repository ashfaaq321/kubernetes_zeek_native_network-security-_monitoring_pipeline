# Use the zeek/zeek:latest base image
FROM zeek/zeek:latest

# Update the package repository and install net-tools
RUN apt-get update && \
    apt-get install -y net-tools curl jq build-essential make libpthread-stubs0-dev zlib1g-dev libssl-dev libsasl2-dev libzstd-dev  librdkafka-dev expect  cmake libpcap-dev && \
    apt-get clean

#build zeek-kafka plugin
#install requirements
RUN curl -L https://github.com/edenhill/librdkafka/archive/v1.4.4.tar.gz | tar xvz  \
    && cd librdkafka-1.4.4/ \
    && ./configure \
    && make \
    &&  make install

#copy execution file
COPY  start.sh /home/start.sh 
WORKDIR  /home
RUN sh start.sh 
RUN zeek -N Seiso::Kafka

#process captured file
COPY process.sh /data/process.sh
RUN mkdir -p /data/capture-files /data/log-files
WORKDIR /data
RUN chmod +x /data/process.sh


# Create an entry point script
RUN echo '#!/bin/bash' > /usr/local/zeek/entrypoint.sh \
    && echo '/usr/local/zeek/bin/zeekctl deploy' >> /usr/local/zeek/entrypoint.sh \
    && echo '/usr/local/zeek/bin/zeekctl start' >> /usr/local/zeek/entrypoint.sh \
    && echo '/data/process.sh &' >> /usr/local/zeek/entrypoint.sh \
    && echo 'tail -f /dev/null' >> /usr/local/zeek/entrypoint.sh

# Make the entry point script executable
RUN chmod +x /usr/local/zeek/entrypoint.sh

# Expose the default Zeek network interface
EXPOSE 47760/tcp

# Set the entry point
ENTRYPOINT ["/usr/local/zeek/entrypoint.sh"]

