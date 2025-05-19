SELECT
    u.id AS customer_id,                                       -- Customer's unique ID.
    u.name,                                                     -- Customer's name.
    TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months, -- Customer's tenure in months.
    COUNT(s.id) AS total_transactions,                         -- Total number of transactions per customer.
    ROUND(                                                      -- Calculate and round the estimated Customer Lifetime Value (CLV).
        (COUNT(s.id) / NULLIF(TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()), 0)) -- Average monthly transactions.
        * 12                                                    -- Annualize the average monthly transactions.
        * 0.001                                                 -- Scaling factor for CLV calculation.
        * IFNULL(AVG(s.confirmed_amount), 0),                  -- Average transaction amount (or 0 if no transactions).
        2
    ) AS estimated_clv
FROM
    users_customuser u                                         -- Select from the users_customuser table (aliased as 'u').
JOIN
    savings_savingsaccount s ON u.id = s.owner_id              -- Join with the savings_savingsaccount table (aliased as 's') on matching user and owner IDs.
WHERE
    s.confirmed_amount IS NOT NULL                             -- Only include transactions with a non-null confirmed amount.
GROUP BY
    u.id, u.name, u.date_joined                                -- Group results by customer ID, name, and join date.
ORDER BY
    estimated_clv DESC;                                        -- Order the results by estimated CLV in descending order.