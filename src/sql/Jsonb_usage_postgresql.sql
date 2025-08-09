jsonb_line_items.sql
-- invoices.payload contains a JSON array "line_items": [{ "sku": "...", "qty": 1, "unit_price": 10.0 }, ...]
-- Flatten and aggregate totals by SKU.

SELECT
  li.sku,
  SUM((li->>'qty')::int) AS total_qty,
  SUM(((li->>'qty')::int * (li->>'unit_price')::numeric)) AS total_amount
FROM billing.invoices i
CROSS JOIN LATERAL jsonb_array_elements(i.payload -> 'line_items') li
GROUP BY li.sku
ORDER BY total_amount DESC;