import csv
import json
import time
import os

from kafka import KafkaProducer

# Environment Variables
KAFKA_TOPIC = os.getenv('KAFKA_TOPIC', 'transactions')
KAFKA_SERVER = os.getenv('KAFKA_SERVER', 'kafka:29092')
CSV_FILE_PATH = os.getenv('CSV_FILE_PATH', '/data/train.csv')


def send_csv_to_kafka():
    producer = KafkaProducer(
        bootstrap_servers=[KAFKA_SERVER],
        value_serializer=lambda v: json.dumps(v).encode('utf-8')
    )
    
    if not producer:
        print("Failed to connect to Kafka.")
        return

    print(f"Starting to load data from {CSV_FILE_PATH}...")
    try:
        with open(CSV_FILE_PATH, mode='r', encoding='utf-8') as csv_file:
            reader = csv.DictReader(csv_file)
            count = 0
            for row in reader:
                producer.send(KAFKA_TOPIC, value=row)
                count += 1
                if count % 1000 == 0:
                    print(f"Sent {count} records...")
            
            time.sleep(5)
            producer.flush()
            print(f"Sending to Kafka completed. Total records sent: {count}")

    except Exception as e:
        print(f"Error: {e}")
    finally:
        producer.close()
        time.sleep(5)

if __name__ == '__main__':
    try:
        send_csv_to_kafka()
    except Exception as e:
        print(f"Error in main: {e}")
