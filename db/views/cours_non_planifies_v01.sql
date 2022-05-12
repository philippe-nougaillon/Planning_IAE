SELECT COUNT(*)
FROM "cours"
WHERE (id IN (
           SELECT "audits"."auditable_id"
           FROM "audits"
           WHERE "audits"."auditable_type" = 'Cour' AND "audits"."user_id" != 41
))
AND "cours"."etat" = 0
AND (cours.debut BETWEEN NOW() AND NOW() + interval '30 day')