-- Create Kafka Table Engine
CREATE TABLE IF NOT EXISTS transactions_queue
(
    transaction_time String,
    merch String,
    cat_id String,
    amount Float64,
    name_1 String,
    name_2 String,
    gender String,
    street String,
    one_city String,
    us_state String,
    post_code Int64,
    lat Float64,
    lon Float64,
    population_city Int64,
    jobs String,
    merchant_lat Float64,
    merchant_lon Float64,
    target Int64
) ENGINE = Kafka
SETTINGS kafka_broker_list = 'kafka:29092',
         kafka_topic_list = 'transactions',
         kafka_group_name = 'transactions_group',
         kafka_format = 'JSONEachRow';

-- Create Optimized MergeTree Table
CREATE TABLE IF NOT EXISTS transactions
(
    transaction_time DateTime CODEC(Delta, ZSTD(1)),
    merch String CODEC(ZSTD(1)),
    cat_id LowCardinality(String) CODEC(ZSTD(1)),
    amount Float64,
    name_1 String CODEC(ZSTD(1)),
    name_2 String CODEC(ZSTD(1)),
    gender LowCardinality(String) CODEC(ZSTD(1)),
    street String CODEC(ZSTD(1)),
    one_city String CODEC(ZSTD(1)),
    us_state LowCardinality(String) CODEC(ZSTD(1)),
    post_code Int64,
    lat Float64,
    lon Float64,
    population_city Int64,
    jobs String CODEC(ZSTD(1)),
    merchant_lat Float64,
    merchant_lon Float64,
    target Int64
) ENGINE = MergeTree()
PARTITION BY toYYYYMM(transaction_time)
ORDER BY (us_state, transaction_time);

-- Materialized View
CREATE MATERIALIZED VIEW IF NOT EXISTS transactions_mv TO transactions
AS SELECT
    parseDateTimeBestEffortOrNull(transaction_time) AS transaction_time,
    merch,
    cat_id,
    amount,
    name_1,
    name_2,
    gender,
    street,
    one_city,
    us_state,
    post_code,
    lat,
    lon,
    population_city,
    jobs,
    merchant_lat,
    merchant_lon,
    target
FROM transactions_queue;
