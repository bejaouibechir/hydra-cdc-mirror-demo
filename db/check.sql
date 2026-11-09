-- Compare the source and the mirror: the same numbers are expected.
\connect shop
SELECT 'shop.orders' AS "table", count(*) AS rows, sum(amount) AS total,
       count(*) FILTER (WHERE status = 'refunded') AS refunded FROM orders;
\connect analytics
SELECT 'analytics.orders' AS "table", count(*) AS rows, sum(amount) AS total,
       count(*) FILTER (WHERE status = 'refunded') AS refunded FROM orders;
