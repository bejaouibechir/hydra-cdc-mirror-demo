-- 1,000 orders in shop.orders (deterministic: same rows on every machine).
\connect shop
INSERT INTO orders (order_id, customer_id, amount, status, details, updated_at)
SELECT g, 1000 + g % 50, round((g * 7.31)::numeric % 900 + 10, 2), 'paid',
       jsonb_build_object('channel', CASE WHEN g % 3 = 0 THEN 'store' ELSE 'web' END),
       '2026-11-01 09:00:00+01'
FROM generate_series(1, 1000) g;
