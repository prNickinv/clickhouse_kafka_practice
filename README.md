# ClickHouse-Kafka Practice

by Nikita Artamonov

This repository contains a `clickhouse-kafka` containerized pipeline. It initializes the database, loads data from a CSV into Kafka, processes it into ClickHouse, runs a query, and exports the result to the host.

## Repository Structure


```
clickhouse_kafka_practice/
├── docker-compose.yml          # Orchestrates services
├── README.md
├── .gitignore
├── data/
│   └── .gitkeep    
│   └── train.csv               # Source data (absent in this repository)
├── output/
│   └── .gitkeep                
│   └── result.csv              # Resulting data (generated after running the pipeline)
├── kafka_procucer/
│   ├── Dockerfile              
│   ├── requirements.txt
│   └── kafka_producer.py       # Python script to load data from 'train.csv' into Kafka
└── sql/
    ├── init_tables.sql         # Script to initialize Kafka Engine Table, Materialized View and Optimized MergeTree Table
    └── query.sql               # Query to find the category of the largest transaction per state
```

## Services Overview

1. **Zookeeper & Kafka**: Message broker.
2. **ClickHouse**: Database. Tables (with optimized storage) are created via `sql/init_tables.sql` on startup.
3. **Kafka Producer**: Reads `data/train.csv` and pushes to Kafka.
4. **Query Executor**: Waits for the Producer to finish, runs `sql/query.sql`, and saves the result at `output/result.csv`.
5. **Kafka UI**: Access Kafka UI at `http://localhost:8080`

### Storage Optimization

In order to optimize storage, the `transcations` table was created with:

1. `ZSTD` compression codec for columns such as `merch`, `name_1`, `name_2`, `street`, `one_city`, `jobs`. 
2. Combination of `Delta` and `ZSTD` codecs for the `transaction_time` column.
3. Combination of `LowCardinality` option and `ZSTD` codec for columns such as `cat_id`, `gender`, `us_state`.
4. Ordering by `us_state` and `transaction_time`.

## How to Run

1. **Prepare Data**:
   Ensure the dataset ([Kaggle link](https://www.kaggle.com/competitions/teta-ml-1-2025/data?select=train.csv)) is located at `data/train.csv`.

2. **Launch Pipeline**:
   ```bash
   docker-compose up --build
   ```

After the pipeline completion, the results will appear at `output/result.csv`. 

Notice that given the larger size of the `train.csv`, the process of loading data from `train.csv` into Kafka may take several minutes.
