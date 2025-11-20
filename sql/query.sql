-- Query to find the category of the largest transaction per state

SELECT
    us_state,
    argMax(cat_id, amount) AS category_with_max_transaction,
    max(amount) AS max_transaction_amount
FROM transactions
GROUP BY us_state
ORDER BY us_state
INTO OUTFILE '/output/result.csv' FORMAT CSVWithNames;
