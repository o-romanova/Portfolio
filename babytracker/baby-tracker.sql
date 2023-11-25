
--import data from csv files via DBeaver import: 30402 rows

--create schema and table
	
CREATE SCHEMA IF NOT EXISTS viz_baby;

DROP TABLE IF EXISTS viz_baby.tracker;

CREATE TABLE 
	viz_baby.tracker 
		(
		row_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
		activity VARCHAR(50) NOT NULL,
		category VARCHAR(50),
		beg_timestamp timestamp,
		end_timestamp timestamp,
		beg_time_num NUMERIC (5,3),
		end_time_num NUMERIC (5,3),
		duration NUMERIC(5,2),
		to_prev_activity NUMERIC(5,3),
		to_next_activity NUMERIC(5,3),
		details VARCHAR(150),
		note VARCHAR(300)
		);
	
TRUNCATE TABLE viz_baby.tracker;

-- insert data from source table, convert date/time columns from string to timestamp (total 30,326 rows)

INSERT INTO
	viz_baby.tracker
	(
	activity,
	category,
	beg_timestamp,
	end_timestamp,
	duration,
	details,
	note)
SELECT
	activity,
	"Type" AS category,
	--convert time of start and finish string values to timestamps
	TO_TIMESTAMP("Start", 'YYYY-MM-DD, HH:MI AM') AS beg_timestamp,
	TO_TIMESTAMP(finish, 'YYYY-MM-DD, HH:MI AM') AS end_timestamp,
	--calculate duration
	ROUND(EXTRACT(epoch FROM (TO_TIMESTAMP(finish, 'YYYY-MM-DD, HH:MI AM') - TO_TIMESTAMP("Start", 'YYYY-MM-DD, HH:MI AM'))) / 3600, 3) AS duration,
	--clean details so that medication name are uniform
	CASE
			WHEN details ILIKE '%tylenol%' THEN 'Tylenol'
			WHEN details ILIKE '%advil%' THEN 'Advil'
			WHEN details ILIKE 'Teva-%' THEN 'Teva-Cephalexin'
			ELSE details
		END,
	note
FROM
	baby.source_data AS sd
LEFT JOIN
	baby.source_notes AS sn
ON
	TO_DATE(sd."Start", 'YYYY-MM-DD') = sn."Date"::date;

--quality check (30,402 rows)

SELECT 
	COUNT(*) OVER(),
	*
FROM 
	viz_baby.tracker
ORDER BY
	beg_timestamp DESC;

-- manual insert of select values from notes (39 rows -> 30,441 total rows). The reason for this is that the app input was different in the beginning. Plus, adding vaccination information


INSERT INTO 
	viz_baby.tracker
	(activity, category, beg_timestamp, end_timestamp, duration, details, note)
VALUES
('Health', 'Medication', '2021-10-25 12:00:00.000', '2021-10-25 12:00:00.000', 0, 'Tylenol', 'Tylenol at 12 p.m.'),
('Health', 'Medication', '2021-10-24 10:50:00.000', '2021-10-24 10:50:00.000', 0, 'Tylenol', 'Tylenol at 10:50 a.m.'),
('Health', 'Medication', '2021-10-23 13:03:00.000', '2021-10-23 13:03:00.000', 0, 'Tylenol', 'Tylenol at 1:03 p.m.'),	
('Health', 'Medication', '2021-10-14 14:05:00.000', '2021-10-14 14:05:00.000', 0, 'Tylenol', 'Tylenol at 2:05 p.m.'),
('Health', 'Medication', '2021-10-12 12:05:00.000', '2021-10-12 12:05:00.000', 0, 'Tylenol', 'Tylenol at 12:05 p.m.'),
('Health', 'Medication', '2021-10-11 11:50:00.000', '2021-10-11 11:50:00.000', 0, 'Tylenol', 'Tylenol at 11:50 a.m.'),
('Health', 'Medication', '2021-10-08 14:20:00.000', '2021-10-08 14:20:00.000', 0, 'Tylenol', 'Tylenol at 2:20 p.m.'),
('Health', 'Medication', '2021-09-30 12:15:00.000', '2021-09-30 12:15:00.000', 0, 'Tylenol', 'Tylenol at 12:15 p.m.'),
('Health', 'Medication', '2021-09-27 22:10:00.000', '2021-09-27 22:10:00.000', 0, 'Tylenol', 'Tylenol at 10:10 p.m.'),
('Health', 'Medication', '2021-09-20 21:50:00.000', '2021-09-20 21:50:00.000', 0, 'Tylenol', 'Tylenol at 9:50 p.m.'),
('Health', 'Medication', '2021-09-10 23:15:00.000', '2021-09-10 23:15:00.000', 0, 'Tylenol', 'Tylenol at 11:15 p.m.'),
('Health', 'Medication', '2021-09-09 16:05:00.000', '2021-09-09 16:05:00.000', 0, 'Tylenol', 'Tylenol at 4:05 p.m.'),
('Health', 'Medication', '2021-09-09 22:00:00.000', '2021-09-09 22:00:00.000', 0, 'Tylenol', 'Tylenol at 10:00 p.m.'),
('Health', 'Temperature', '2021-08-19 00:00:00.000', '2021-08-19 00:00:00.000', 0, '39.1°C', 'Temperature at 12:00 a.m.'),
('Health', 'Medication', '2021-08-19 00:45:00.000', '2021-08-19 00:45:00.000', 0, 'Tylenol', 'Tylenol at 12:45 a.m.'),
('Health', 'Medication', '2021-07-30 18:07:00.000', '2021-07-30 18:07:00.000', 0, 'Tylenol', 'Tylenol at 6:07 p.m.'),
('Health', 'Temperature', '2021-07-27 10:20:00.000', '2021-07-27 10:20:00.000', 0, '39.1°C', 'Temperature after vaccination at 10:20 a.m.'),
('Health', 'Medication', '2021-07-27 10:28:00.000', '2021-07-27 10:28:00.000', 0, 'Tylenol', 'Tylenol at 10:28 a.m.'),
('Health', 'Medication', '2021-07-27 15:00:00.000', '2021-07-27 15:00:00.000', 0, 'Tylenol', 'Tylenol at 3:00 p.m.'),
('Health', 'Vaccination', '2021-07-26 15:00:00.000', '2021-07-26 15:00:00.000', 0, 'Vaccine', 'Vaccination'),
('Health', 'Medication', '2021-07-23 21:40:00.000', '2021-07-23 21:40:00.000', 0, 'Tylenol', 'Tylenol at 9:40 p.m.'),
('Health', 'Medication', '2021-07-22 02:10:00.000', '2021-07-22 02:10:00.000', 0, 'Tylenol', 'Tylenol at 2:10 a.m.'),
('Health', 'Medication', '2021-07-18 16:30:00.000', '2021-07-18 16:30:00.000', 0, 'Tylenol', 'Tylenol at 4:30 p.m.'),
('Health', 'Medication', '2021-07-11 23:20:00.000', '2021-07-11 23:20:00.000', 0, 'Tylenol', 'Tylenol at 11:20 p.m.'),
('Health', 'Medication', '2021-06-26 14:05:00.000', '2021-06-26 14:05:00.000', 0, 'Tylenol', 'Tylenol at 2:05 p.m.'),
('Health', 'Medication', '2021-06-19 10:40:00.000', '2021-06-19 10:40:00.000', 0, 'Tylenol', 'Tylenol at 10:40 a.m.'),
('Health', 'Medication', '2021-06-17 12:45:00.000', '2021-06-17 12:45:00.000', 0, 'Tylenol', 'Tylenol at 12:45 p.m.'),
('Health', 'Medication', '2021-04-19 19:00:00.000', '2021-04-19 19:00:00.000', 0, 'Tylenol', 'Tylenol at 7:00 p.m.'),
('Health', 'Medication', '2021-04-12 04:20:00.000', '2021-04-12 04:20:00.000', 0, 'Tylenol', 'Tylenol at 4:20 a.m.'),
('Health', 'Temperature', '2021-04-10 12:00:00.000', '2021-04-10 12:00:00.000', 0, '37.7°C', 'Temperature 37.7'),
('Health', 'Temperature', '2021-04-09 13:15:00.000', '2021-04-09 13:15:00.000', 0, '37.9°C', 'Temperature 37.9'),
('Health', 'Medication', '2021-04-09 13:20:00.000', '2021-04-09 13:20:00.000', 0, 'Tylenol', 'Tylenol at 1:20 p.m.'),
('Health', 'Temperature', '2021-02-27 12:15:00.000', '2021-02-27 12:15:00.000', 0, '38.5°C', 'Temperature 38.5 after vaccination'),
('Health', 'Vaccination', '2021-02-26 15:00:00.000', '2021-02-26 15:00:00.000', 0, 'Vaccine', 'Vaccination'),
('Health', 'Vaccination', '2020-03-17 15:00:00.000', '2020-03-17 15:00:00.000', 0, 'Vaccine', 'Vaccination'),
('Health', 'Vaccination', '2020-05-26 15:00:00.000', '2020-05-26 15:00:00.000', 0, 'Vaccine', 'Vaccination'),
('Health', 'Vaccination', '2020-07-27 15:00:00.000', '2020-07-27 15:00:00.000', 0, 'Vaccine', 'Vaccination'),
('Health', 'Vaccination', '2021-11-23 15:00:00.000', '2021-11-23 15:00:00.000', 0, 'Vaccine', 'Vaccination'),
('Health', 'Vaccination', '2022-11-03 15:00:00.000', '2022-11-03 15:00:00.000', 0, 'Vaccine', 'Vaccination');



--Split rows that span two days

-- Create temporary table 

CREATE TEMP TABLE 
	temp_activities AS
-- insert rows replacing end time with the same date as the beginning, but time 23:59
SELECT
	row_id,
	activity,
	category,
	beg_timestamp,
	DATE_TRUNC('DAY', beg_timestamp) + INTERVAL '1 DAY' - INTERVAL '1 SECOND' AS end_timestamp, 
	ROUND(EXTRACT(epoch FROM (DATE_TRUNC('DAY', beg_timestamp) + INTERVAL '1 DAY' - INTERVAL '1 SECOND') - beg_timestamp) / 3600, 2) AS duration,
	details,
	note
FROM 
	viz_baby.tracker
WHERE 
	DATE_TRUNC('DAY', beg_timestamp) != DATE_TRUNC('DAY', end_timestamp);

-- insert rows replacing beginning time with the same date as end, but time 00:00
INSERT INTO 
	temp_activities
SELECT 
	row_id, 
	activity,
	category,
	DATE_TRUNC('DAY', end_timestamp) AS beg_timestamp, 
	end_timestamp,
	ROUND(EXTRACT(epoch FROM end_timestamp - DATE_TRUNC('DAY', end_timestamp)) / 3600, 2) AS duration,
	details,
	note
FROM 
	viz_baby.tracker
WHERE 
	DATE_TRUNC('DAY', beg_timestamp) != DATE_TRUNC('DAY', end_timestamp);


-- delete rows that span two days from the original table (1049 rows)
DELETE FROM 
	viz_baby.tracker
WHERE 
	DATE_TRUNC('DAY', beg_timestamp) != DATE_TRUNC('DAY', end_timestamp);	

-- insert data back from the temp table

INSERT INTO 
	viz_baby.tracker
		(activity,
		category,
		beg_timestamp,
		end_timestamp,
		duration,
		details,
		note)
SELECT 
	activity,
	category,
	beg_timestamp,
	end_timestamp,
	duration,
	details,
	note
FROM 
	temp_activities;

-- quality check: 1049 rows that span two days -> 30441 + 1049 -> 31490 rows

SELECT 
	COUNT(*) OVER(),
	*
FROM 
	viz_baby.tracker
ORDER BY beg_timestamp DESC;
 


--update the table by extracting time from beginning and end timestamps and converting it to decimal for correct vizualization

UPDATE 
	viz_baby.tracker
SET 
	beg_time_num = ROUND(((DATE_PART('hour', beg_timestamp::time) * 60 + DATE_PART('minute', beg_timestamp::time))/ 60)::numeric, 3),
	end_time_num = ROUND(((DATE_PART('hour', end_timestamp::time) * 60 + DATE_PART('minute', end_timestamp::time))/ 60)::numeric, 3);


--Update the table with values for previous and next sleep instances in the corresponding columns (5167 rows updated):

--create a CTE to look for previous and next sleep instances
WITH
	prev_next_sleep AS
	(SELECT
		row_id,
		activity,
		beg_timestamp,
		end_timestamp,
		LAG(end_timestamp, 1, NULL) OVER(ORDER BY beg_timestamp) AS previous_end,
		LEAD(beg_timestamp, 1, NULL) OVER(ORDER BY beg_timestamp) AS next_beg
	FROM
		viz_baby.tracker
	WHERE 
		activity = 'Sleep'
	ORDER BY beg_timestamp)
--update sleep instances with calculations based on CTE fields
UPDATE
	viz_baby.tracker AS t
SET
	to_prev_activity = ROUND(EXTRACT(epoch FROM (t.beg_timestamp - pns.previous_end))/3600::numeric, 2),
	to_next_activity = ROUND(EXTRACT(epoch FROM (pns.next_beg - t.end_timestamp))/3600::numeric, 2)
FROM
	prev_next_sleep AS pns
WHERE 
	t.row_id = pns.row_id;

--quality check
SELECT 
	COUNT(*) OVER(),
	*
FROM 
	viz_baby.tracker
WHERE 
	activity = 'Sleep'
	--checking for outliers
/*AND
	to_prev_activity  > 15
OR
	to_next_activity > 15*/
ORDER BY beg_timestamp;
	

--Update the table with values for previous and next feeding instances in the corresponding columns (17714 rows updated):

--create a CTE to look for previous and next feeding instances
WITH
	prev_next_feeding AS
	(SELECT
		row_id,
		activity,
		beg_timestamp,
		end_timestamp,
		LAG(end_timestamp, 1, NULL) OVER(ORDER BY beg_timestamp) AS previous_end,
		LEAD(beg_timestamp, 1, NULL) OVER(ORDER BY beg_timestamp) AS next_beg
	FROM
		viz_baby.tracker
	WHERE 
		activity = 'Feeding'
	ORDER BY beg_timestamp)
--update feeding instances with calculations based on CTE fields
UPDATE
	viz_baby.tracker AS t
SET
	to_prev_activity = ROUND(EXTRACT(epoch FROM (t.beg_timestamp - pnf.previous_end))/3600::numeric, 2),
	to_next_activity = ROUND(EXTRACT(epoch FROM (pnf.next_beg - t.end_timestamp))/3600::numeric, 2)
FROM
	prev_next_feeding AS pnf
WHERE 
	t.row_id = pnf.row_id;


--Update the table with values for previous and next diaper changes in the corresponding columns (6306 rows updated):

--create a CTE to look for previous and next diaper changes
WITH
	prev_next_diaper AS
	(SELECT
		row_id,
		activity,
		beg_timestamp,
		end_timestamp,
		LAG(end_timestamp, 1, NULL) OVER(ORDER BY beg_timestamp) AS previous_end,
		LEAD(beg_timestamp, 1, NULL) OVER(ORDER BY beg_timestamp) AS next_beg
	FROM
		viz_baby.tracker
	WHERE 
		activity = 'Diapers'
	ORDER BY beg_timestamp)
--update diaper change instances with calculations based on CTE fields
UPDATE
	viz_baby.tracker AS t
SET
	to_prev_activity = ROUND(EXTRACT(epoch FROM (t.beg_timestamp - pnd.previous_end))/3600::numeric, 2),
	to_next_activity = ROUND(EXTRACT(epoch FROM (pnd.next_beg - t.end_timestamp))/3600::numeric, 2)
FROM
	prev_next_diaper AS pnd
WHERE 
	t.row_id = pnd.row_id;

--quality check
SELECT 
	COUNT(*) OVER(),
	*
FROM 
	viz_baby.tracker
--WHERE 
	--activity = 'Diapers'
ORDER BY beg_timestamp 
 
	
