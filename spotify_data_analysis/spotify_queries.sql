-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);


-- EDA <Exploratory Data Analysis>

SELECT COUNT(*) FROM spotify; -- 20594 --> 20592

SELECT COUNT(DISTINCT artist) FROM spotify; -- 2074

SELECT DISTINCT album_type FROM spotify; -- album, compilation, single

SELECT MAX(duration_min) FROM spotify; -- 77.9343

SELECT MIN(duration_min) FROM spotify; -- before 0 after 0.5164

SELECT * FROM spotify
WHERE duration_min = 0;

DELETE FROM spotify
WHERE duration_min = 0;

SELECT DISTINCT channel FROM spotify; -- 6673

SELECT DISTINCT most_played_on FROM spotify; -- youtube, spotify

/*
-- -----------------------------
-- Data Analysis ---------------
-- -----------------------------

Easy Level
1.Retrieve the names of all tracks that have more than 1 billion streams.
2.List all albums along with their respective artists.
3.Get the total number of comments for tracks where licensed = TRUE.
4.Find all tracks that belong to the album type single.
5.Count the total number of tracks by each artist.
*/

--Q.1 Retrieve the names of all tracks that have more than 1 billion streams.

SELECT track
FROM spotify
WHERE stream > 1000000000; --385

--Q.2 List all albums along with their respective artists.

SELECT DISTINCT album, artist
FROM spotify; --14178

--Q.3 Get the total number of comments for tracks where licensed = TRUE.

SELECT SUM(comments) AS total_comments
FROM spotify
WHERE licensed = 'true'; --497015695

--Q.4 Find all tracks that belong to the album type single.

SELECT track
FROM spotify
WHERE album_type = 'single'; --4973

--Q.5 Count the total number of tracks by each artist.

SELECT DISTINCT artist, --1
    COUNT(track) AS no_of_tracks --2
FROM spotify
GROUP BY artist
ORDER BY 2 DESC; --2074

/*
Medium Level
1.Calculate the average danceability of tracks in each album.
2.Find the top 5 tracks with the highest energy values.
3.List all tracks along with their views and likes where official_video = TRUE.
4.For each album, calculate the total views of all associated tracks.
5.Retrieve the track names that have been streamed on Spotify more than YouTube.
*/

--Q.1 Calculate the average danceability of tracks in each album.

SELECT album, AVG(danceability) AS average_danceability
FROM spotify
GROUP BY 1
ORDER BY 2 DESC;--11853

--Q.2 Find the top 5 tracks with the highest energy values.

SELECT track, artist, energy
FROM spotify
ORDER BY energy DESC
LIMIT 5;

--Q.3 List all tracks along with their views and likes where official_video = TRUE.

SELECT 
    track,
    SUM(views) AS total_sum, 
    SUM(likes) AS total_likes
FROM spotify
WHERE official_video = 'true'
GROUP BY 1
ORDER BY 2 DESC;

--Q.4 For each album, calculate the total views of all associated tracks.

SELECT 
    album,
    track,
    SUM(views) AS total_views_tracks
FROM spotify
GROUP BY 1, 2
ORDER BY 3 DESC;

--Q.5 Retrieve the track names that have been streamed on Spotify more than YouTube.

SELECT * FROM
(SELECT 
    track,
    COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END), 0) AS streamed_on_youtube,
    COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END), 0)AS streamed_on_spotify
FROM spotify
GROUP BY 1
) AS subquery
WHERE streamed_on_spotify > streamed_on_youtube
    AND streamed_on_youtube <> 0;

/*
Advanced Level
1.Find the top 3 most-viewed tracks for each artist using window functions.
2.Write a query to find tracks where the liveness score is above the average.
3.Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
4.Find tracks where the energy-to-liveness ratio is greater than 1.2.
5.Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.*/

--Q.1 Find the top 3 most-viewed tracks for each artist using window functions.

WITH ranking_artist
AS
(SELECT
    artist,
    track,
    SUM(views) AS total_views,
    DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views) DESC) AS rnk
FROM spotify
GROUP BY 1, 2
ORDER BY 1, 3 DESC
)
SELECT *
FROM ranking_artist
WHERE rnk <= 3;

--Q.2 Write a query to find tracks where the liveness score is above the average.

SELECT
    track,
    artist,
    liveness
FROM spotify
WHERE liveness > (SELECT AVG(liveness)
FROM spotify)

--Q.3 Use a WITH clause to calculate the difference between 
--the highest and lowest energy values for tracks in each album.

WITH cte
AS( 
SELECT
    album,
    MAX(energy) AS highest_energy,
    MIN(energy) AS lowest_energy
FROM spotify
GROUP BY 1
)
SELECT
    album,
    highest_energy - lowest_energy AS energy_difference
FROM cte
ORDER BY 2 DESC;

--Q.4 Find tracks where the energy-to-liveness ratio is greater than 1.2.

SELECT
    track,
    energy,
    liveness,
    (energy / liveness) AS energy_liveness_ratio
FROM spotify
WHERE (energy / liveness) > 1.2;

--Q.5 Calculate the cumulative sum of likes for tracks 
--ordered by the number of views, using window functions.
SELECT 
    track,
    views,
    likes,
    SUM(likes) OVER (ORDER BY views DESC) AS cumulative_likes
FROM spotify;

-- Query Optimization
EXPLAIN ANALYZE --et: 17.455, pt:1.370|after et: 0.346, pt: 2.334
SELECT 
    artist,
    track,
    views
FROM spotify
WHERE artist = 'Gorillaz'
    AND most_played_on = 'Youtube'
ORDER BY stream DESC
LIMIT 25;

--create index

CREATE INDEX artist_index ON spotify(artist);
----------------x--------------------x--------------------x-----------------------