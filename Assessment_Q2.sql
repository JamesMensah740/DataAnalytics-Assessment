WITH transaction_summary AS (
    SELECT
        owner_id,                               -- User's ID.
        COUNT(*) AS total_transactions,         -- Total number of transactions per user.
        MIN(transaction_date) AS first_txn_date, -- First transaction date per user.
        MAX(transaction_date) AS last_txn_date   -- Last transaction date per user.
    FROM savings_savingsaccount
    WHERE confirmed_amount > 0                 -- Only consider transactions with a positive confirmed amount.
    GROUP BY owner_id                           -- Group results by user.
),
txn_with_tenure AS (
    SELECT
        owner_id,                               -- User's ID.
        total_transactions,                     -- Total transactions from the previous CTE.
        TIMESTAMPDIFF(MONTH, first_txn_date, last_txn_date) + 1 AS tenure_months, -- Calculate user tenure in months.
        ROUND(total_transactions / (TIMESTAMPDIFF(MONTH, first_txn_date, last_txn_date) + 1), 2) AS avg_txns_per_month -- Calculate average monthly transactions.
    FROM transaction_summary
),
categorized AS (
    SELECT
        CASE                                     -- Categorize users based on average monthly transactions.
            WHEN avg_txns_per_month >= 10 THEN 'High Frequency'
            WHEN avg_txns_per_month BETWEEN 4 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category,
        avg_txns_per_month                       -- Average monthly transactions.
    FROM txn_with_tenure
)
SELECT
    frequency_category,                       -- Transaction frequency category.
    COUNT(*) AS customer_count,              -- Number of customers in each category.
    ROUND(AVG(avg_txns_per_month), 2) AS avg_transactions_per_month -- Average monthly transactions for each category.
FROM categorized
GROUP BY frequency_category                  -- Group results by frequency category.
ORDER BY FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency'); -- Order results by the defined frequency categories.