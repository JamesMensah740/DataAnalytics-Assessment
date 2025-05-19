SELECT
    u.id AS owner_id,             -- Selects the user ID from the users_customuser table and aliases it as owner_id.
    u.name,                       -- Selects the name of the user.
    COUNT(DISTINCT CASE             -- Counts the number of distinct savings accounts for each user.
        WHEN p.is_regular_savings = 1 THEN s.id -- If the plan is a regular savings plan, count the savings account ID.
    END) AS savings_count,
    COUNT(DISTINCT CASE             -- Counts the number of distinct investment accounts for each user.
        WHEN p.is_a_fund = 1 THEN s.id       -- If the plan is an investment fund, count the savings account ID.
    END) AS investment_count,
    ROUND(SUM(s.confirmed_amount) / 100, 2) AS total_deposits -- Calculates the total confirmed deposit amount for each user, divides by 100 (likely for currency conversion), and rounds to 2 decimal places.
FROM savings_savingsaccount s      -- Selects from the savings_savingsaccount table and aliases it as 's'.
JOIN plans_plan p ON s.plan_id = p.id -- Joins savings_savingsaccount with the plans_plan table (aliased as 'p') based on matching plan IDs.
JOIN users_customuser u ON s.owner_id = u.id -- Joins savings_savingsaccount with the users_customuser table (aliased as 'u') based on matching owner IDs.
WHERE s.confirmed_amount > 0      -- Filters out savings accounts where the confirmed amount is not positive.
GROUP BY u.id, u.name              -- Groups the results by user ID and name to aggregate data per user.
HAVING savings_count >= 1          -- Filters the grouped results to include only users who have at least one regular savings account.
   AND investment_count >= 1      -- And also have at least one investment account.
ORDER BY total_deposits DESC;     -- Orders the final result set by the total deposits in descending order, showing users with the highest total deposits first.
