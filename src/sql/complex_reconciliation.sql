-- 03_reconciliation_candidates.sql
-- Find invoices with no matching vendor_id and suggest candidate vendors by vendor_code similarity and latest activity.

SELECT
  i.invoice_id,
  i.invoice_number,
  i.payload ->> 'vendor_name' AS vendor_name_in_payload,
  i.vendor_id,
  cand.candidate_vendor_id,
  cand.vendor_name,
  cand.match_score
FROM billing.invoices i
LEFT JOIN LATERAL (
    -- Rank possible vendors based on text similarity (pg_trgm) and recency of vendor activity
    SELECT v.vendor_id AS candidate_vendor_id,
           v.vendor_name,
           (similarity(v.vendor_name, COALESCE(i.payload ->> 'vendor_name', '')) * 0.6
            + (CASE WHEN v.created_at > now() - INTERVAL '365 days' THEN 0.4 ELSE 0.0 END)) AS match_score
    FROM billing.vendors v
    WHERE v.vendor_name % COALESCE(i.payload ->> 'vendor_name', '')  -- requires pg_trgm extension
    ORDER BY match_score DESC
    LIMIT 1
) cand ON true
WHERE i.vendor_id IS NULL
ORDER BY cand.match_score DESC NULLS LAST;


