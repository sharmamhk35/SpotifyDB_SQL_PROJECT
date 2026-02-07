/********************************************************************************
* Phase-3: SpotifyDB - Advanced Queries
* Sections:
*  A. Joins (25)
*  B. Subqueries (25)
*  C. Built-in Functions (25)
*  D. User-Defined Functions & Uses (25)  -- includes CREATE FUNCTION and sample calls
*
* Note: Some statements (FULL JOIN, WINDOW functions, JSON functions) depend on your RDBMS.
* If using MySQL, FULL JOIN is simulated using UNION of LEFT and RIGHT joins.
********************************************************************************/

----------------------------
-- A. JOINS (25)
----------------------------

-- 1. INNER JOIN: tracks with their primary album and primary artist
SELECT t.track_id, t.track_title, al.album_name, ar.stage_name
FROM tracks t
INNER JOIN albums al ON t.album_id = al.album_id
INNER JOIN album_artists aa ON aa.album_id = al.album_id AND aa.role = 'Primary'
INNER JOIN artists ar ON ar.artist_id = aa.artist_id;

-- 2. LEFT JOIN: users and their subscriptions (include users without subscriptions)
SELECT u.user_id, u.username, s.plan_name, s.start_date
FROM users u
LEFT JOIN subscriptions s ON s.user_id = u.user_id;

-- 3. RIGHT JOIN: payments and subscriptions (payments that may not have subscriptions)
-- Note: MySQL supports RIGHT JOIN; some DBs treat RIGHT JOIN as INNER with swapped tables
SELECT p.payment_id, p.user_id, s.subscription_id, s.plan_name
FROM payments p
RIGHT JOIN subscriptions s ON s.subscription_id = p.subscription_id;

-- 4. FULL JOIN (simulated): advertisers with ad_plays (include advertisers with zero plays and plays with missing advertisers)
SELECT a.advertiser_id, a.company_name, ap.ad_play_id
FROM advertisers a
LEFT JOIN ad_plays ap ON ap.advertiser_id = a.advertiser_id
UNION
SELECT a.advertiser_id, a.company_name, ap.ad_play_id
FROM advertisers a
RIGHT JOIN ad_plays ap ON ap.advertiser_id = a.advertiser_id;

-- 5. SELF JOIN: find pairs of users who follow each other (mutual followers)
SELECT uf1.follower_user_id AS user_a, uf1.user_id AS follows_a, uf2.follower_user_id AS user_b
FROM user_followers uf1
JOIN user_followers uf2 ON uf1.follower_user_id = uf2.user_id AND uf1.user_id = uf2.follower_user_id;

-- 6. CROSS JOIN: cartesian example - small sample of top 3 artists x top 3 playlists
SELECT ar.stage_name, p.playlist_name
FROM (SELECT * FROM artists ORDER BY monthly_listeners DESC LIMIT 3) ar
CROSS JOIN (SELECT * FROM playlists ORDER BY followers_count DESC LIMIT 3) p;

-- 7. INNER JOIN with aggregate: albums and count of tracks
SELECT al.album_id, al.album_name, COUNT(t.track_id) AS track_count
FROM albums al
JOIN tracks t ON t.album_id = al.album_id
GROUP BY al.album_id;

-- 8. LEFT JOIN with condition on child: playlists and favorite tracks count
SELECT p.playlist_id, p.playlist_name, COUNT(pt.playlist_track_id) AS fav_count
FROM playlists p
LEFT JOIN playlist_tracks pt ON pt.playlist_id = p.playlist_id AND pt.is_favorite = TRUE
GROUP BY p.playlist_id;

-- 9. Multi-way join across listening_history -> users -> devices -> tracks -> artists
SELECT lh.played_at, u.username, d.device_name, t.track_title, ar.stage_name
FROM listening_history lh
JOIN users u ON u.user_id = lh.user_id
LEFT JOIN devices d ON d.device_id = lh.device_id
JOIN tracks t ON t.track_id = lh.track_id
JOIN albums al ON al.album_id = t.album_id
JOIN album_artists aa ON aa.album_id = al.album_id AND aa.role = 'Primary'
JOIN artists ar ON ar.artist_id = aa.artist_id
ORDER BY lh.played_at DESC
LIMIT 50;

-- 10. JOIN with filtering on joined table: tracks that belong to genre 'Pop'
SELECT t.track_id, t.track_title
FROM tracks t
JOIN track_genres tg ON tg.track_id = t.track_id
JOIN genres g ON g.genre_id = tg.genre_id
WHERE g.genre_name = 'Pop';

-- 11. LEFT JOIN and IS NULL: find tracks not assigned to any genre
SELECT t.track_id, t.track_title
FROM tracks t
LEFT JOIN track_genres tg ON tg.track_id = t.track_id
WHERE tg.genre_id IS NULL;

-- 12. SELF JOIN on artists to find artists sharing same label
SELECT a1.artist_id AS artist1, a1.stage_name AS name1, a2.artist_id AS artist2, a2.stage_name AS name2, a1.label
FROM artists a1
JOIN artists a2 ON a1.label = a2.label AND a1.artist_id <> a2.artist_id
WHERE a1.label IS NOT NULL;

-- 13. LEFT JOIN with derived table: top 10 tracks and their playlist counts
SELECT t.track_id, t.track_title, COALESCE(pt_counts.cnt,0) AS playlist_count
FROM (SELECT * FROM tracks ORDER BY popularity_score DESC LIMIT 10) t
LEFT JOIN (
  SELECT track_id, COUNT(*) AS cnt FROM playlist_tracks GROUP BY track_id
) pt_counts ON pt_counts.track_id = t.track_id;

-- 14. JOIN to get users who bought tickets with concert and artist info
SELECT u.username, c.concert_name, ar.stage_name, t.price
FROM tickets t
JOIN users u ON u.user_id = t.user_id
JOIN concerts c ON c.concert_id = t.concert_id
JOIN artists ar ON ar.artist_id = c.artist_id;

-- 15. RIGHT JOIN to show all albums and any album_artists info (albums without artists show NULL)
SELECT al.album_id, al.album_name, aa.artist_id, aa.role
FROM album_artists aa
RIGHT JOIN albums al ON al.album_id = aa.album_id;

-- 16. FULL JOIN simulation: users and advertisers (example unrelated join) to show all records
SELECT u.user_id AS uid, u.username, a.advertiser_id AS aid, a.company_name
FROM users u
LEFT JOIN advertisers a ON a.country = u.country
UNION
SELECT u.user_id AS uid, u.username, a.advertiser_id AS aid, a.company_name
FROM users u
RIGHT JOIN advertisers a ON a.country = u.country;

-- 17. INNER JOIN with window aggregate: track and rank per album by popularity (DB-dependent; window function used)
SELECT t.track_id, t.track_title, t.album_id, RANK() OVER (PARTITION BY t.album_id ORDER BY t.popularity_score DESC) AS rank_in_album
FROM tracks t;

-- 18. JOIN across podcasts & episodes to get host name (using episode_hosts)
SELECT pe.episode_id, pe.title AS episode_title, eh.host_name
FROM podcast_episodes pe
LEFT JOIN episode_hosts eh ON eh.episode_id = pe.episode_id;

-- 19. JOIN advertisers to ad_plays and group by advertiser with average revenue per play
SELECT a.advertiser_id, a.company_name, AVG(ap.revenue_generated) AS avg_revenue
FROM advertisers a
JOIN ad_plays ap ON ap.advertiser_id = a.advertiser_id
GROUP BY a.advertiser_id;

-- 20. JOIN playlists -> playlist_tracks -> tracks to list a playlist with top 5 most-played tracks (by play_count)
SELECT p.playlist_name, t.track_title, pt.play_count
FROM playlists p
JOIN playlist_tracks pt ON pt.playlist_id = p.playlist_id
JOIN tracks t ON t.track_id = pt.track_id
WHERE p.playlist_id = 9
ORDER BY pt.play_count DESC
LIMIT 5;

-- 21. JOIN with aggregation: artist monthly_listeners vs total album streams (assuming albums.streams exists)
SELECT ar.artist_id, ar.stage_name, SUM(al.streams) AS total_album_streams, ar.monthly_listeners
FROM artists ar
LEFT JOIN album_artists aa ON aa.artist_id = ar.artist_id
LEFT JOIN albums al ON al.album_id = aa.album_id
GROUP BY ar.artist_id
ORDER BY total_album_streams DESC;

-- 22. Multi-join with filtering: find premium users who listened to an explicit track in last 30 days
SELECT DISTINCT u.user_id, u.username
FROM users u
JOIN listening_history lh ON lh.user_id = u.user_id
JOIN tracks t ON t.track_id = lh.track_id AND t.is_explicit = TRUE
WHERE u.is_premium = TRUE AND lh.played_at >= DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY);

-- 23. LEFT JOIN with COALESCE: playlist follower counts with default zero
SELECT p.playlist_id, p.playlist_name, COALESCE(p.followers_count,0) AS followers_count
FROM playlists p
LEFT JOIN playlist_tracks pt ON pt.playlist_id = p.playlist_id;

-- 24. JOIN across concerts -> tickets -> users to list attendees for a given concert
SELECT c.concert_name, u.username, t.seat_number, t.status
FROM concerts c
JOIN tickets t ON t.concert_id = c.concert_id
JOIN users u ON u.user_id = t.user_id
WHERE c.concert_id = 1;

-- 25. JOIN tracks to song_credits to show contributors and their shares
SELECT t.track_title, sc.contributor_name, sc.role, sc.contribution_percent
FROM tracks t
LEFT JOIN song_credits sc ON sc.track_id = t.track_id
ORDER BY t.track_id, sc.contribution_percent DESC;

----------------------------
-- B. SUBQUERIES (25)
----------------------------

-- 26. Scalar subquery: show each user with their last payment amount (NULL if none)
SELECT u.user_id, u.username,
  (SELECT p.amount FROM payments p WHERE p.user_id = u.user_id ORDER BY p.payment_date DESC LIMIT 1) AS last_payment_amount
FROM users u;

-- 27. Correlated subquery: find tracks whose popularity is above the album average
SELECT t.track_id, t.track_title, t.popularity_score
FROM tracks t
WHERE t.popularity_score > (
  SELECT AVG(t2.popularity_score) FROM tracks t2 WHERE t2.album_id = t.album_id
);

-- 28. IN subquery: users who have playlist(s) with more than 20 tracks
SELECT u.user_id, u.username
FROM users u
WHERE u.user_id IN (
  SELECT p.user_id FROM playlists p WHERE p.total_tracks > 20
);

-- 29. EXISTS correlated subquery: artists who have at least one album released after 2020
SELECT ar.artist_id, ar.stage_name
FROM artists ar
WHERE EXISTS (
  SELECT 1 FROM album_artists aa JOIN albums al ON al.album_id = aa.album_id
  WHERE aa.artist_id = ar.artist_id AND al.release_date > '2020-01-01'
);

-- 30. Subquery in FROM: average play_count per playlist
SELECT ps.playlist_id, ps.avg_play_count
FROM (
  SELECT playlist_id, AVG(play_count) AS avg_play_count FROM playlist_tracks GROUP BY playlist_id
) ps
ORDER BY ps.avg_play_count DESC
LIMIT 10;

-- 31. ALL/ANY example: find tracks with popularity greater than ANY album average (at least greater than one album avg)
SELECT t.track_id, t.track_title FROM tracks t
WHERE t.popularity_score > ANY (SELECT AVG(popularity_score) FROM tracks GROUP BY album_id);

-- 32. Subquery with HAVING: find users who saved more than 5 items
SELECT user_id
FROM user_library
GROUP BY user_id
HAVING COUNT(*) > 5;

-- 33. NOT EXISTS: find users who have not made any payments
SELECT u.user_id, u.username FROM users u
WHERE NOT EXISTS (SELECT 1 FROM payments p WHERE p.user_id = u.user_id);

-- 34. Correlated scalar subquery in SELECT to get total tracks count per user (via playlists)
SELECT u.user_id, u.username,
  (SELECT COUNT(DISTINCT pt.track_id) FROM playlists p JOIN playlist_tracks pt ON pt.playlist_id = p.playlist_id WHERE p.user_id = u.user_id) AS distinct_tracks_in_playlists
FROM users u;

-- 35. Subquery in WHERE with BETWEEN: find concerts where total ticket sales between range (use subquery to compute sales)
SELECT c.concert_id, c.concert_name FROM concerts c
WHERE (SELECT COALESCE(SUM(t.price),0) FROM tickets t WHERE t.concert_id = c.concert_id) BETWEEN 1000 AND 100000;

-- 36. Nested subqueries: find artists whose followers are greater than average followers of all artists
SELECT artist_id, stage_name FROM artists
WHERE followers > (SELECT AVG(followers) FROM artists);

-- 37. Subquery with LIMIT in MySQL: find the most recent episode for each podcast (example using correlated subquery)
SELECT p.podcast_id, p.title,
  (SELECT pe.title FROM podcast_episodes pe WHERE pe.podcast_id = p.podcast_id ORDER BY pe.release_date DESC LIMIT 1) AS latest_episode
FROM podcasts p;

-- 38. Use subquery to find tracks that appear in top playlists (playlists with >1000 followers)
SELECT DISTINCT pt.track_id, t.track_title
FROM playlist_tracks pt
JOIN tracks t ON t.track_id = pt.track_id
WHERE pt.playlist_id IN (SELECT playlist_id FROM playlists WHERE followers_count > 1000);

-- 39. Correlated subquery in WHERE with aggregation: users whose average listened duration > 200 sec
SELECT u.user_id, u.username
FROM users u
WHERE (SELECT AVG(lh.duration_played) FROM listening_history lh WHERE lh.user_id = u.user_id) > 200;

-- 40. Subquery used to compute ranking: tracks in top 10% of popularity
SELECT t.track_id, t.track_title, t.popularity_score
FROM tracks t
WHERE t.popularity_score >= (SELECT PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY popularity_score) FROM tracks) -- vendor-specific; fallback using approximate method below

-- 41. Fallback approximate 90th percentile using ORDER BY and LIMIT (MySQL style)
SELECT t.track_id, t.track_title FROM tracks t
WHERE t.popularity_score >= (
  SELECT popularity_score FROM tracks ORDER BY popularity_score DESC LIMIT GREATEST(1, (SELECT CEIL(0.1 * COUNT(*)) FROM tracks) - 1), 1
);

-- 42. Subquery to find artists featured on more than 5 albums
SELECT artist_id, stage_name FROM artists
WHERE artist_id IN (
  SELECT artist_id FROM album_artists GROUP BY artist_id HAVING COUNT(album_id) > 5
);

-- 43. Scalar subquery to compute user's lifetime value (sum payments)
SELECT u.user_id, u.username, (SELECT COALESCE(SUM(amount),0) FROM payments p WHERE p.user_id = u.user_id) AS lifetime_value
FROM users u
ORDER BY lifetime_value DESC
LIMIT 20;

-- 44. Subquery in JOIN (derived table) for top listeners
SELECT u.username, top_listens.listen_count
FROM users u
JOIN (
  SELECT user_id, COUNT(*) AS listen_count FROM listening_history GROUP BY user_id ORDER BY listen_count DESC LIMIT 50
) top_listens ON top_listens.user_id = u.user_id;

-- 45. Correlated subquery using EXISTS to find playlists that contain a specific artist's tracks
SELECT p.playlist_id, p.playlist_name FROM playlists p
WHERE EXISTS (
  SELECT 1 FROM playlist_tracks pt JOIN tracks t ON t.track_id = pt.track_id JOIN album_artists aa ON aa.album_id = t.album_id
  WHERE pt.playlist_id = p.playlist_id AND aa.artist_id = 3
);

-- 46. Subquery in WHERE with NOT IN: find tracks that are not credited to any contributor
SELECT t.track_id, t.track_title FROM tracks t
WHERE t.track_id NOT IN (SELECT track_id FROM song_credits);

-- 47. Correlated subquery getting last played timestamp per user
SELECT u.user_id, u.username,
  (SELECT MAX(lh.played_at) FROM listening_history lh WHERE lh.user_id = u.user_id) AS last_played
FROM users u;

-- 48. Subquery for ad performance: advertisers whose average ad revenue per play > X
SELECT a.advertiser_id, a.company_name
FROM advertisers a
WHERE (SELECT AVG(ap.revenue_generated) FROM ad_plays ap WHERE ap.advertiser_id = a.advertiser_id) > 3.0;

-- 49. Subquery in HAVING: albums whose tracks have average popularity above overall average
SELECT al.album_id, al.album_name, AVG(t.popularity_score) AS avg_pop
FROM albums al
JOIN tracks t ON t.album_id = al.album_id
GROUP BY al.album_id
HAVING AVG(t.popularity_score) > (SELECT AVG(popularity_score) FROM tracks);

-- 50. Use subquery in SELECT to get number of active devices per user
SELECT u.user_id, u.username,
  (SELECT COUNT(*) FROM devices d WHERE d.user_id = u.user_id AND d.is_active = TRUE) AS active_devices
FROM users u
ORDER BY active_devices DESC
LIMIT 20;

----------------------------
-- C. BUILT-IN FUNCTIONS (25)
----------------------------

-- 51. String functions: uppercase name and substring of username
SELECT user_id, UPPER(full_name) AS name_upper, SUBSTRING(username,1,5) AS user_short FROM users LIMIT 20;

-- 52. CONCAT and formatting contact card
SELECT user_id, CONCAT(full_name, ' <', email, '>') AS contact_card FROM users LIMIT 20;

-- 53. Numeric functions: round average album streams to 2 decimals
SELECT al.album_id, al.album_name, ROUND(AVG(al.streams),2) AS avg_streams_est FROM albums al GROUP BY al.album_id LIMIT 20;

-- 54. Date functions: users' age calculation
SELECT user_id, username, TIMESTAMPDIFF(YEAR, dob, CURDATE()) AS age FROM users WHERE dob IS NOT NULL LIMIT 20;

-- 55. DATEDIFF: days since signup
SELECT user_id, username, DATEDIFF(CURDATE(), signup_date) AS days_since_signup FROM users LIMIT 20;

-- 56. COALESCE: prefer phone else 'N/A'
SELECT user_id, username, COALESCE(phone, 'N/A') AS phone_display FROM users LIMIT 20;

-- 57. Aggregate functions: average track duration per album
SELECT album_id, AVG(duration_seconds) AS avg_track_sec FROM tracks GROUP BY album_id;

-- 58. GROUP_CONCAT (MySQL) to list artists on an album
SELECT al.album_id, al.album_name, GROUP_CONCAT(ar.stage_name SEPARATOR ', ') AS artists
FROM albums al
JOIN album_artists aa ON aa.album_id = al.album_id
JOIN artists ar ON ar.artist_id = aa.artist_id
GROUP BY al.album_id;

-- 59. JSON functions example: create JSON object of user summary (MySQL)
SELECT user_id, JSON_OBJECT('username', username, 'email', email, 'premium', is_premium) AS user_json FROM users LIMIT 10;

-- 60. Window function: running total of album streams by release_date (DB-dependent)
SELECT album_id, album_name, release_date, SUM(streams) OVER (ORDER BY release_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_streams
FROM albums
ORDER BY release_date;

-- 61. TRIM / REPLACE example cleaning artist names
SELECT artist_id, TRIM(REPLACE(stage_name, '  ', ' ')) AS clean_name FROM artists LIMIT 20;

-- 62. LPAD/RPAD example: formatted IDs
SELECT artist_id, LPAD(artist_id,6,'0') AS artist_code FROM artists LIMIT 20;

-- 63. FLOOR/CEIL example on duration in minutes
SELECT track_id, track_title, FLOOR(duration_seconds/60) AS minutes_floor, CEIL(duration_seconds/60) AS minutes_ceil FROM tracks LIMIT 20;

-- 64. NULLIF example: avoid division by zero
SELECT t.track_id, t.track_title, COALESCE(t.popularity_score / NULLIF(t.duration_seconds,0),0) AS pop_per_sec FROM tracks t LIMIT 20;

-- 65. CASE expression for user segments based on lifetime payments
SELECT u.user_id, u.username,
  CASE
    WHEN (SELECT COALESCE(SUM(amount),0) FROM payments p WHERE p.user_id = u.user_id) >= 100 THEN 'High Value'
    WHEN (SELECT COALESCE(SUM(amount),0) FROM payments p WHERE p.user_id = u.user_id) >= 20 THEN 'Medium Value'
    ELSE 'Low Value'
  END AS customer_segment
FROM users u LIMIT 50;

-- 66. LENGTH and CHAR_LENGTH for string metrics
SELECT username, LENGTH(username) AS bytes_len, CHAR_LENGTH(username) AS chars_len FROM users LIMIT 20;

-- 67. DATE_FORMAT example (MySQL) for readable dates
SELECT user_id, username, DATE_FORMAT(signup_date, '%W, %M %d, %Y') AS signup_readable FROM users LIMIT 10;

-- 68. CONCAT_WS and COALESCE to display full address (placeholder columns)
SELECT user_id, CONCAT_WS(', ', COALESCE(country,'')) AS address_sample FROM users LIMIT 20;

-- 69. Mathematical function: POWER and SQRT on streams (example)
SELECT album_id, album_name, SQRT(GREATEST(streams,0)) AS sqrt_streams FROM albums LIMIT 20;

-- 70. REGEXP / RLIKE example: artists with digits in their name (MySQL)
SELECT artist_id, stage_name FROM artists WHERE stage_name RLIKE '[0-9]' LIMIT 20;

-- 71. SUBSTRING_INDEX example: get first word of stage_name
SELECT artist_id, SUBSTRING_INDEX(stage_name, ' ', 1) AS first_word FROM artists LIMIT 20;

-- 72. UNIX_TIMESTAMP conversion and FROM_UNIXTIME (MySQL)
SELECT user_id, signup_date, UNIX_TIMESTAMP(signup_date) AS signup_unix FROM users LIMIT 10;

-- 73. JSON_ARRAYAGG example for tracks per playlist (MySQL)
SELECT pt.playlist_id, JSON_ARRAYAGG(pt.track_id) AS track_ids_json
FROM playlist_tracks pt
GROUP BY pt.playlist_id LIMIT 10;

-- 74. CONCAT and ROUND to make a summary string
SELECT album_id, CONCAT(album_name, ' (', ROUND(streams/1000000,2), 'M streams)') AS summary FROM albums LIMIT 20;

-- 75. COALESCE with multiple columns (example fallback)
SELECT user_id, COALESCE(phone, email, username) AS contact_prefer FROM users LIMIT 20;

----------------------------
-- D. USER-DEFINED FUNCTIONS & USAGE (25)
-- We'll create several UDFs and then show queries that use them.
-- Note: DDL for functions differs across DBMS. Below is MySQL-style.
----------------------------

-- 76. UDF: Calculate annual subscription cost given monthly price
DROP FUNCTION IF EXISTS GetAnnualCost;
DELIMITER $$
CREATE FUNCTION GetAnnualCost(monthly_price DECIMAL(8,2)) RETURNS DECIMAL(10,2) DETERMINISTIC
BEGIN
  RETURN ROUND(monthly_price * 12,2);
END$$
DELIMITER ;

-- 77. Use GetAnnualCost to show plan annual cost
SELECT plan_id, plan_name, price, GetAnnualCost(price) AS annual_cost FROM subscription_plans LIMIT 20;

-- 78. UDF: Calculate user age from DOB
DROP FUNCTION IF EXISTS GetUserAge;
DELIMITER $$
CREATE FUNCTION GetUserAge(d DATE) RETURNS INT DETERMINISTIC
BEGIN
  RETURN TIMESTAMPDIFF(YEAR, d, CURDATE());
END$$
DELIMITER ;

-- 79. Use GetUserAge
SELECT user_id, username, GetUserAge(dob) AS age FROM users LIMIT 20;

-- 80. UDF: Revenue share split (platform vs advertiser) - returns platform share
DROP FUNCTION IF EXISTS PlatformShare;
DELIMITER $$
CREATE FUNCTION PlatformShare(revenue DECIMAL(10,2)) RETURNS DECIMAL(10,2) DETERMINISTIC
BEGIN
  RETURN ROUND(revenue * 0.70,2);
END$$
DELIMITER ;

-- 81. Use PlatformShare in ad_plays
SELECT ad_play_id, revenue_generated, PlatformShare(revenue_generated) AS platform_share FROM ad_plays LIMIT 20;

-- 82. UDF: Classify popularity tier (numeric input)
DROP FUNCTION IF EXISTS PopTier;
DELIMITER $$
CREATE FUNCTION PopTier(pop INT) RETURNS VARCHAR(10) DETERMINISTIC
BEGIN
  RETURN CASE
    WHEN pop >= 90 THEN 'Platinum'
    WHEN pop >= 75 THEN 'Gold'
    WHEN pop >= 50 THEN 'Silver'
    ELSE 'Bronze'
  END;
END$$
DELIMITER ;

-- 83. Use PopTier
SELECT track_id, track_title, popularity_score, PopTier(popularity_score) AS tier FROM tracks LIMIT 20;

-- 84. UDF: Convert seconds to mm:ss string
DROP FUNCTION IF EXISTS SecToMMSS;
DELIMITER $$
CREATE FUNCTION SecToMMSS(sec INT) RETURNS VARCHAR(10) DETERMINISTIC
BEGIN
  RETURN LPAD(FLOOR(sec/60),2,'0') || ':' || LPAD(sec % 60,2,'0');
END$$
DELIMITER ;

-- 85. Use SecToMMSS (note: string concatenation operator may vary; MySQL uses CONCAT, use fallback)
SELECT track_id, track_title, CONCAT(LPAD(FLOOR(duration_seconds/60),2,'0'),':',LPAD(duration_seconds % 60,2,'0')) AS duration_mmss FROM tracks LIMIT 20;

-- 86. UDF: Compute lifetime value for a user (sum payments)
DROP FUNCTION IF EXISTS GetLifetimeValue;
DELIMITER $$
CREATE FUNCTION GetLifetimeValue(uid INT) RETURNS DECIMAL(12,2) DETERMINISTIC
BEGIN
  DECLARE total DECIMAL(12,2);
  SELECT COALESCE(SUM(amount),0) INTO total FROM payments WHERE user_id = uid;
  RETURN ROUND(total,2);
END$$
DELIMITER ;

-- 87. Use GetLifetimeValue
SELECT user_id, username, GetLifetimeValue(user_id) AS lifetime_value FROM users LIMIT 20;

-- 88. UDF: Simple recommendation score (example using listens and follows)
DROP FUNCTION IF EXISTS RecommendScore;
DELIMITER $$
CREATE FUNCTION RecommendScore(uid INT) RETURNS DECIMAL(6,2) DETERMINISTIC
BEGIN
  DECLARE listens INT DEFAULT 0;
  DECLARE follows INT DEFAULT 0;
  SELECT COUNT(*) INTO listens FROM listening_history WHERE user_id = uid;
  SELECT COUNT(*) INTO follows FROM user_followers WHERE follower_user_id = uid;
  RETURN ROUND(listens * 0.01 + follows * 0.5,2);
END$$
DELIMITER ;

-- 89. Use RecommendScore
SELECT user_id, username, RecommendScore(user_id) AS rec_score FROM users LIMIT 20;

-- 90. UDF: Format currency (prefix)
DROP FUNCTION IF EXISTS FormatUSD;
DELIMITER $$
CREATE FUNCTION FormatUSD(x DECIMAL(12,2)) RETURNS VARCHAR(30) DETERMINISTIC
BEGIN
  RETURN CONCAT('$', FORMAT(x,2));
END$$
DELIMITER ;

-- 91. Use FormatUSD on monthly_revenue_cache
SELECT year_month, FormatUSD(revenue) AS revenue_formatted FROM monthly_revenue_cache LIMIT 20;

-- 92. UDF: Safe divide to avoid division by zero
DROP FUNCTION IF EXISTS SafeDiv;
DELIMITER $$
CREATE FUNCTION SafeDiv(a DECIMAL(12,4), b DECIMAL(12,4)) RETURNS DECIMAL(12,4) DETERMINISTIC
BEGIN
  IF b = 0 THEN RETURN 0; ELSE RETURN a / b; END IF;
END$$
DELIMITER ;

-- 93. Use SafeDiv to compute avg revenue per play for advertisers
SELECT a.advertiser_id, a.company_name, SafeDiv(SUM(ap.revenue_generated), COUNT(ap.ad_play_id)) AS avg_rev_per_play
FROM advertisers a
LEFT JOIN ad_plays ap ON ap.advertiser_id = a.advertiser_id
GROUP BY a.advertiser_id;

-- 94. UDF: Check if user is high-value (simple boolean)
DROP FUNCTION IF EXISTS IsHighValueUser;
DELIMITER $$
CREATE FUNCTION IsHighValueUser(uid INT) RETURNS BOOLEAN DETERMINISTIC
BEGIN
  RETURN (SELECT COALESCE(SUM(amount),0) FROM payments WHERE user_id = uid) > 100;
END$$
DELIMITER ;

-- 95. Use IsHighValueUser
SELECT user_id, username FROM users WHERE IsHighValueUser(user_id) = TRUE LIMIT 20;

-- 96. UDF: Normalize string to remove extra spaces (example using TRIM)
DROP FUNCTION IF EXISTS NormalizeName;
DELIMITER $$
CREATE FUNCTION NormalizeName(s VARCHAR(255)) RETURNS VARCHAR(255) DETERMINISTIC
BEGIN
  RETURN TRIM(REPLACE(s, '  ', ' '));
END$$
DELIMITER ;

-- 97. Use NormalizeName
SELECT artist_id, NormalizeName(stage_name) AS clean_name FROM artists LIMIT 20;

-- 98. UDF: Calculate percentage share given two numbers
DROP FUNCTION IF EXISTS PercentShare;
DELIMITER $$
CREATE FUNCTION PercentShare(part DECIMAL(12,2), whole DECIMAL(12,2)) RETURNS DECIMAL(5,2) DETERMINISTIC
BEGIN
  IF whole = 0 THEN RETURN 0; END IF;
  RETURN ROUND((part/whole)*100,2);
END$$
DELIMITER ;

-- 99. Use PercentShare to compute each album's share of artist total streams (example)
SELECT al.album_id, al.album_name, PercentShare(al.streams, COALESCE( (SELECT SUM(al2.streams) FROM albums al2 WHERE al2.album_id IN (SELECT aa.album_id FROM album_artists aa WHERE aa.artist_id = (SELECT artist_id FROM album_artists WHERE album_id = al.album_id LIMIT 1)) ), al.streams)) AS pct_share
FROM albums al LIMIT 20;

-- 100. Clean-up example: drop demo function if exists (cleanup)
DROP FUNCTION IF EXISTS DemoCleanup;