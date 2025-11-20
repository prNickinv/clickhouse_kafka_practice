FROM python:3.10-slim

WORKDIR /app

# Log directory
RUN mkdir -p /app/logs && \
    touch /app/logs/service.log && \
    chmod -R 777 /app/logs

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY kafka_producer.py .

CMD ["python", "kafka_producer.py"]
