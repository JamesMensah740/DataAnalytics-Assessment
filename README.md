# DataAnalytics-Assessment

Question 1: High-Value Customers with Multiple Products
Goal: Identify customers who hold both regular savings and investment accounts and have a significant total deposit amount. This helps in recognizing valuable customers with diversified engagement.
My query steps:

Joins Tables: It combines data from three tables: savings_savingsaccount, plans_plan and users_customuser
Filters Confirmed Deposits: It only considers accounts with a confirmed_amount greater than zero.
Counts Product Types: For each customer, it counts the number of distinct regular savings accounts and distinct investment accounts using conditional aggregation (CASE statements within COUNT(DISTINCT)).
Calculates Total Deposits: It sums the confirmed_amount for each customer and rounds it to two decimal places.
Groups by Customer: It groups the results by customer ID and name to perform the aggregate calculations per customer.
Filters for Multiple Products: It uses the HAVING clause to include only customers who have at least one regular savings account (savings_count >= 1) AND at least one investment account (investment_count >= 1).
Orders by Value: Finally, it orders the results by the total_deposits in descending order, placing the highest-value customers at the top.

Question 2: Transaction Frequency Analysis
Goal: Categorize customers based on how frequently they make transactions on their savings accounts. This helps in understanding user engagement levels.

steps:
This process uses a series of Common Table Expressions (CTEs) to break down the analysis:

transaction_summary: Calculates the total number of transactions, the first transaction date, and the last transaction date for each customer with confirmed deposits.
txn_with_tenure: Calculates the tenure of each customer in months (based on the difference between their first and last transaction dates, plus one).
Calculates the average number of transactions per month for each customer.
categorized: Assigns a frequency category ('High Frequency', 'Medium Frequency', or 'Low Frequency') to each customer based on their avg_txns_per_month using a CASE statement.
Final SELECT: Groups the categorized customers by their frequency_category.
Counts the number of customers in each category (customer_count).
Calculates the average avg_txns_per_month for each category.
Orders the results by the frequency categories in a specific order ('High Frequency', 'Medium Frequency', 'Low Frequency')

Question 3: Account Inactivity Alert
Goal: Identify dormant accounts

last_transactions:
Finds the latest transaction date for each plan_id in the savings_savingsaccount table with a confirmed amount greater than zero.
active_plans:
Selects active plans from the plans_plan table (those not deleted or archived).
Determines the type of each plan ('Savings' or 'Investment') based on the is_regular_savings and is_a_fund flags.
inactivity_check:
Joins active_plans with last_transactions on plan_id using a LEFT JOIN to include all active plans.
Calculates the inactivity_days by finding the difference between the current date and the last_transaction_date.
Final SELECT:
Filters the results to include plans where last_transaction_date is NULL (never had a transaction) or inactivity_days is greater than 365.
Orders the results by inactivity_days in descending order to show the most inactive accounts first.

Question 4: Customer Lifetime Value (CLV) Estimation
Goal: Estimate the potential future value of each customer based on their past transaction behavior and tenure.

Joins Tables: It combines users_customuser and savings_savingsaccount tables based on the owner_id.
Calculates Tenure: It determines the customer's tenure in months from their date_joined to the current date.
Counts Total Transactions: It counts the total number of transactions for each customer.
Calculates Estimated CLV: The CLV is estimated using the formula: (Total Transactions / Tenure in Months) * 12 * 0.001 * Average Confirmed Amount
This formula essentially calculates the annualized average transaction value, scaled by a factor of 0.001 (the specific meaning of this factor would depend on the business context and CLV model).
Averages Transaction Amount: It calculates the average confirmed_amount for each customer. IFNULL handles cases with no transactions by using 0 as the average.
Groups by Customer: It groups the results by customer ID, name, and join date to perform calculations per customer.
Orders by CLV: It orders the results by the estimated_clv in descending order, showing customers with the highest estimated value first.