WITH last_transactions AS (
    SELECT
        plan_id,                                      -- Plan ID.
        MAX(transaction_date) AS last_transaction_date  -- Date of the most recent transaction for each plan.
    FROM savings_savingsaccount
    WHERE confirmed_amount > 0                      -- Only consider transactions with a positive confirmed amount.
    GROUP BY plan_id                                 -- Group by plan ID to find the latest transaction per plan.
),
active_plans AS (
    SELECT
        id AS plan_id,                                 -- Plan ID.
        owner_id,                                     -- Owner ID of the plan.
        CASE                                         -- Determine the plan type.
            WHEN is_regular_savings = 1 THEN 'Savings'
            WHEN is_a_fund = 1 THEN 'Investment'
            ELSE NULL
        END AS type,
        created_on                                   -- Date the plan was created.
    FROM plans_plan
    WHERE is_deleted = 0 AND is_archived = 0         -- Only include plans that are active (not deleted or archived).
),
inactivity_check AS (
    SELECT
        ap.plan_id,                                 -- Plan ID.
        ap.owner_id,                                 -- Owner ID.
        ap.type,                                     -- Plan type (Savings or Investment).
        lt.last_transaction_date,                     -- Date of the last transaction.
        DATEDIFF(CURDATE(), lt.last_transaction_date) AS inactivity_days -- Calculate days since the last transaction.
    FROM active_plans ap
    LEFT JOIN last_transactions lt ON ap.plan_id = lt.plan_id -- Join active plans with their last transaction dates.
    WHERE ap.type IS NOT NULL                         -- Exclude plans with an unknown type.
)
SELECT
    plan_id,                                      -- Plan ID.
    owner_id,                                     -- Owner ID.
    type,                                         -- Plan type.
    last_transaction_date,                        -- Date of the last transaction.
    inactivity_days                                -- Number of days since the last transaction.
FROM inactivity_check
WHERE last_transaction_date IS NULL OR inactivity_days > 365 -- Filter for plans with no transactions or inactivity longer than 365 days.
ORDER BY inactivity_days DESC;                    -- Order the results by inactivity duration.