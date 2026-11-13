-- hn_etl analysis queries (ITBDA4-14, Q4.3)

SELECT post_type,
       COUNT(*)                                                    AS posts,
       ROUND(AVG(points)   FILTER (WHERE NOT points_imputed), 1)   AS avg_points,
       ROUND(AVG(comments) FILTER (WHERE NOT comments_imputed), 1) AS avg_comments,
       ROUND(AVG(points_per_hour), 1)                              AS avg_points_per_hour,
       ROUND(AVG(comments_per_point), 2)                           AS comments_per_point,
       SUM(is_viral::int)                                          AS viral_posts
FROM hn_posts
GROUP BY post_type
ORDER BY avg_points DESC NULLS LAST;

SELECT CASE WHEN is_ai_topic THEN 'AI-related title' ELSE 'Other title' END AS topic,
       COUNT(*) AS posts,
       ROUND(AVG(points) FILTER (WHERE NOT points_imputed), 1) AS avg_points,
       ROUND(AVG(comments), 1) AS avg_comments
FROM hn_posts
GROUP BY 1;


SELECT site,
       COUNT(*)                                                 AS posts,
       SUM(points)                                              AS total_points,
       ROUND(AVG(points), 1)                                    AS avg_points,
       RANK() OVER (ORDER BY SUM(points) DESC)                  AS points_rank,
       ROUND(100.0 * SUM(points) / SUM(SUM(points)) OVER (), 1) AS pct_of_all_points
FROM hn_posts
WHERE NOT points_imputed
GROUP BY site
ORDER BY points_rank
LIMIT 10;

SELECT ROUND(CORR(points, comments)::numeric, 3)    AS corr_points_comments,
       ROUND(CORR(points, age_hours)::numeric, 3)   AS corr_points_age,
       ROUND(CORR(points, title_words)::numeric, 3) AS corr_points_title_length
FROM hn_posts
WHERE NOT points_imputed;

