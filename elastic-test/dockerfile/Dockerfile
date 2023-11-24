# Use the Bitnami Logstash image as the base image
FROM bitnami/logstash:latest

# Copy your Logstash configuration file to the container
COPY apache.conf /opt/bitnami/logstash/config/apache.conf



CMD ["logstash", "-f", "/opt/bitnami/logstash/config/apache.conf"]

EXPOSE 9600
