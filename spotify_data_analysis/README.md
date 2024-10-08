# Spotify SQL Project and Query Optimization 
Project Category: Advanced
[Click Here to get Dataset](https://www.kaggle.com/datasets/sanjanchaudhari/spotify-dataset)

![Spotify Logo](https://github.com/amadhavan0326/sql-database-project/blob/461ff927303a42d8f76f79cc82a17d5d8d533809/spotify_data_analysis/spotify_logo.png)

## Overview
This project involves analyzing a Spotify dataset with various attributes about tracks, albums, and artists using **SQL**. It covers an end-to-end process of normalizing a denormalized dataset, performing SQL queries of varying complexity (easy, medium, and advanced), and optimizing query performance. The primary goals of the project are to practice advanced SQL skills and generate valuable insights from the dataset.

```sql
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
```
## Project Steps

### 1. Data Exploration
Before diving into SQL, it’s important to understand the dataset thoroughly. The dataset contains attributes such as:
- `Artist`: The performer of the track.
- `Track`: The name of the song.
- `Album`: The album to which the track belongs.
- `Album_type`: The type of album (e.g., single or album).
- Various metrics such as `danceability`, `energy`, `loudness`, `tempo`, and more.

### 2. Querying the Data
After the data is inserted, various SQL queries can be written to explore and analyze the data. Queries are categorized into **easy**, **medium**, and **advanced** levels to help progressively develop SQL proficiency.

#### Easy Queries
- Simple data retrieval, filtering, and basic aggregations.
  
#### Medium Queries
- More complex queries involving grouping, aggregation functions, and joins.
  
#### Advanced Queries
- Nested subqueries, window functions, CTEs, and performance optimization.

### 5. Query Optimization
In advanced stages, the focus shifts to improving query performance. Some optimization strategies include:
- **Indexing**: Adding indexes on frequently queried columns.
- **Query Execution Plan**: Using `EXPLAIN ANALYZE` to review and refine query performance.
  
---

## 15 Practice Questions

### Easy Level
1. Retrieve the names of all tracks that have more than 1 billion streams.
```sql
SELECT track
FROM spotify
WHERE stream > 1000000000; --385
```
2. List all albums along with their respective artists.
```sql
SELECT DISTINCT album, artist
FROM spotify; --14178
```
3. Get the total number of comments for tracks where `licensed = TRUE`.
```sql
SELECT SUM(comments) AS total_comments
FROM spotify
WHERE licensed = 'true'; --497015695
```
4. Find all tracks that belong to the album type `single`.
```sql
SELECT track
FROM spotify
WHERE album_type = 'single'; --4973
```
5. Count the total number of tracks by each artist.
```sql
SELECT DISTINCT artist, --1
    COUNT(track) AS no_of_tracks --2
FROM spotify
GROUP BY artist
ORDER BY 2 DESC; --2074
```

### Medium Level
1. Calculate the average danceability of tracks in each album.
```sql
SELECT album, AVG(danceability) AS average_danceability
FROM spotify
GROUP BY 1
ORDER BY 2 DESC;--11853
```
2. Find the top 5 tracks with the highest energy values.
```sql
SELECT track, artist, energy
FROM spotify
ORDER BY energy DESC
LIMIT 5;
```
3. List all tracks along with their views and likes where `official_video = TRUE`.
```sql
SELECT 
    track,
    SUM(views) AS total_sum, 
    SUM(likes) AS total_likes
FROM spotify
WHERE official_video = 'true'
GROUP BY 1
ORDER BY 2 DESC;
```
4. For each album, calculate the total views of all associated tracks.
```sql
SELECT 
    album,
    track,
    SUM(views) AS total_views_tracks
FROM spotify
GROUP BY 1, 2
ORDER BY 3 DESC;
```
5. Retrieve the track names that have been streamed on Spotify more than YouTube.
```sql
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
```

### Advanced Level
1. Find the top 3 most-viewed tracks for each artist using window functions.
```sql
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
```
2. Write a query to find tracks where the liveness score is above the average.
```sql
SELECT
    track,
    artist,
    liveness
FROM spotify
WHERE liveness > (SELECT AVG(liveness)
FROM spotify)
```
3. **Use a `WITH` clause to calculate the difference between the highest and lowest energy values for tracks in each album.**
```sql
WITH cte
AS
(SELECT 
	album,
	MAX(energy) as highest_energy,
	MIN(energy) as lowest_energery
FROM spotify
GROUP BY 1
)
SELECT 
	album,
	highest_energy - lowest_energery as energy_difference
FROM cte
ORDER BY 2 DESC
```
   
4. Find tracks where the energy-to-liveness ratio is greater than 1.2.
```sql
SELECT
    track,
    energy,
    liveness,
    (energy / liveness) AS energy_liveness_ratio
FROM spotify
WHERE (energy / liveness) > 1.2;
```
5. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
```sql
SELECT 
    track,
    views,
    likes,
    SUM(likes) OVER (ORDER BY views DESC) AS cumulative_likes
FROM spotify;
```


Here’s an updated section for your **Spotify Advanced SQL Project and Query Optimization** README, focusing on the query optimization task you performed. You can include the specific screenshots and graphs as described.

---

## Query Optimization Technique 

To improve query performance, we carried out the following optimization process:

- **Initial Query Performance Analysis Using `EXPLAIN`**
    - We began by analyzing the performance of a query using the `EXPLAIN` function.
    - The query retrieved tracks based on the `artist` column, and the performance metrics were as follows:
        - Execution time (E.T.): **16.145 ms**
        - Planning time (P.T.): **2.012 ms**
    - Below is the **screenshot** of the `EXPLAIN` result before optimization:
      ![EXPLAIN Before Index](https://github.com/amadhavan0326/sql-database-project/blob/461ff927303a42d8f76f79cc82a17d5d8d533809/spotify_data_analysis/explain_befor_index.png)

- **Index Creation on the `artist` Column**
    - To optimize the query performance, we created an index on the `artist` column. This ensures faster retrieval of rows where the artist is queried.
    - **SQL command** for creating the index:
      ```sql
      CREATE INDEX idx_artist ON spotify_tracks(artist);
      ```

- **Performance Analysis After Index Creation**
    - After creating the index, we ran the same query again and observed significant improvements in performance:
        - Execution time (E.T.): **0.150 ms**
        - Planning time (P.T.): **2.O51 ms**
    - Below is the **screenshot** of the `EXPLAIN` result after index creation:
      ![EXPLAIN After Index](https://github.com/amadhavan0326/sql-database-project/blob/461ff927303a42d8f76f79cc82a17d5d8d533809/spotify_data_analysis/explain_after_index.png)

- **Graphical Performance Comparison**
    - A graph illustrating the comparison between the initial query execution time and the optimized query execution time after index creation.
    - **Graph view** shows the significant drop in both execution and planning times:
    
        **Before Optimization:**  
      ![Performance Graph](https://github.com/amadhavan0326/sql-database-project/blob/461ff927303a42d8f76f79cc82a17d5d8d533809/spotify_data_analysis/spotify_graphical%20view%202.png)
        **After Optimization:**
      ![Performance Graph](https://github.com/amadhavan0326/sql-database-project/blob/461ff927303a42d8f76f79cc82a17d5d8d533809/spotify_data_analysis/spotify_graphical%20view%201.png)

This optimization shows how indexing can drastically reduce query time, improving the overall performance of our database operations in the Spotify project.

---

## Visualize the Data using Power BI

We created a Power BI dashboard to visualize the analysis results. The key visuals include:

### 1.Table of Tracks with >1 Billion Streams:

This table lists all tracks that have surpassed 1 billion streams on Spotify. It provides insights into the most popular songs in the dataset, offering a quick reference to the top-performing music tracks based on stream count.

![Table](https://github.com/amadhavan0326/sql-database-project/blob/c257d18947d252c7d2e2077f7bee825949b864dc/spotify_data_analysis/tracks_with_over_1bn_streams.png)

### 2.Average Danceability by Album (Column Chart):

The column chart shows the average danceability score for each album, providing a visual comparison across different albums. Danceability scores indicate how suitable tracks are for dancing, which can highlight albums designed with energetic and rhythmic music.

![Column Chart](https://github.com/amadhavan0326/sql-database-project/blob/c257d18947d252c7d2e2077f7bee825949b864dc/spotify_data_analysis/Average_danceability_by_album.png)

### 3.Top 5 Tracks by Energy (Bar Chart):

This bar chart highlights the five tracks with the highest energy levels in the dataset. Energy measures the intensity and activity of a song, helping users quickly identify the most energetic and dynamic tracks.

![Bar Charty](https://github.com/amadhavan0326/sql-database-project/blob/c257d18947d252c7d2e2077f7bee825949b864dc/spotify_data_analysis/top_5_tracks_by_enegry.png)

### 4.Total tracks by Artist (Bar Chart):

This bar chart displays the total number of tracks produced by each artist in the dataset. It helps in identifying the most prolific artists, giving a sense of their contribution to the overall collection of music.

![Bar Chart](https://github.com/amadhavan0326/sql-database-project/blob/c257d18947d252c7d2e2077f7bee825949b864dc/spotify_data_analysis/total_tracks_by_each_artist.png)

### 5.Cumulative Likes by Views (Line Chart):

The line chart represents the cumulative likes for tracks as ordered by their view counts. This visual shows how engagement (likes) scales with track popularity (views), offering insights into user interaction trends with popular tracks.

![Line Chart](https://github.com/amadhavan0326/sql-database-project/blob/c257d18947d252c7d2e2077f7bee825949b864dc/spotify_data_analysis/cumulative_likes_vs_views.png)

### 6.Tracks Streamed More on Spotify than YouTube (Table):

This table lists the tracks that have more streams on Spotify than on YouTube. It allows for a direct comparison of platform performance, showing which tracks are more popular on Spotify relative to YouTube.

![Table](https://github.com/amadhavan0326/sql-database-project/blob/c257d18947d252c7d2e2077f7bee825949b864dc/spotify_data_analysis/tracks_streamed_more_on_spotify_than_youtube.png)

The dashboard is designed to showcase only the essential visuals, fitting efficiently within a single canvas for a clean, impactful presentation.




---

## Technology Stack
- **Database**: PostgreSQL
- **SQL Queries**: DDL, DML, Aggregations, Joins, Subqueries, Window Functions
- **Tools**: pgAdmin 4 (or any SQL editor), PostgreSQL (via Homebrew, Docker, or direct installation), VS code( code editor), Power BI

## How to Run the Project
1. Install PostgreSQL and pgAdmin (if not already installed).I used VScode as code editor by connecting postgress using SQL Tools extension.  
2. Set up the database schema and tables using the provided normalization structure.
3. Insert the sample data into the respective tables.
4. Execute SQL queries to solve the listed problems.
5. Explore query optimization techniques for large datasets.
6. Load the Power BI .pbix file to view the dashboard.

---

## Next Steps
- **Expand Dataset**: Add more rows to the dataset for broader analysis and scalability testing.
- **Advanced Querying**: Dive deeper into query optimization and explore the performance of SQL queries on larger datasets.
- **Performance Tuning**: Further optimize SQL queries on larger datasets.

---

## Contributing
If you would like to contribute to this project, feel free to fork the repository, submit pull requests, or raise issues.

---

## License
This project is licensed under the MIT License.