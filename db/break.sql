-- The mirror refuses negative amounts; the shop records 500 updates and one wrong order.
\connect analytics
ALTER TABLE orders ADD CONSTRAINT amount_not_negative CHECK (amount >= 0);
\connect shop
UPDATE orders SET amount = amount + 1 WHERE order_id <= 500;
INSERT INTO orders (order_id, customer_id, amount, status) VALUES (1021, 1001, -15.00, 'paid');
