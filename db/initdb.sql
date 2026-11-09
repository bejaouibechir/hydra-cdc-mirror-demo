-- Two databases on the same server: shop (the application) and analytics (the mirror).
-- Run once, on an empty server. The orders table exists only in shop:
-- Hydra ETL creates analytics.orders at the first run, with the same types.
CREATE DATABASE shop;
CREATE DATABASE analytics;

\connect shop
CREATE TABLE orders (
  order_id    bigint PRIMARY KEY,
  customer_id bigint NOT NULL,
  amount      numeric(12,2) NOT NULL,
  status      text NOT NULL,
  details     jsonb,
  updated_at  timestamptz NOT NULL DEFAULT now()
);
