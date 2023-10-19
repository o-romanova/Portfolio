-- to delete
SELECT 
	*
FROM 
	baby.veronica_source_file vsf;
	
SELECT 
	*
FROM 
	baby.veronica_source_file_notes vsfn;

--creating schema and table
	
CREATE SCHEMA IF NOT EXISTS dw_baby;

DROP TABLE IF EXISTS dw_baby.tracker;

CREATE TABLE 
	dw_baby.tracker 
		(
		row_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
		activity VARCHAR(50) NOT NULL,
		category VARCHAR(50),
		time_beg timestamp,
		time_end timestamp,
		duration NUMERIC(5,2),
		details VARCHAR(150),
		details_num NUMERIC(5,2),
		note VARCHAR(300)
		);
	
TRUNCATE TABLE dw_baby.tracker;

-- inserting data from source table, converting date/time columns from string to timestamp

INSERT INTO
	dw_baby.tracker
	(
	activity,
	category,
	time_beg,
	time_end,
	duration,
	details,
	details_num,
	note)
SELECT
	activity,
	"Type",
	--converting time of start and finish string values to timestamps
	TO_TIMESTAMP("Start", 'YYYY-MM-DD, HH:MI AM'),
	TO_TIMESTAMP(finish, 'YYYY-MM-DD, HH:MI AM'),
	--calculating duration
	EXTRACT(epoch FROM (TO_TIMESTAMP(finish, 'YYYY-MM-DD, HH:MI AM') - TO_TIMESTAMP("Start", 'YYYY-MM-DD, HH:MI AM'))) / 3600 AS duration,
	details,
	--separating numerical values and converting them to decimal. To define the patterns I first used 'SIMILAR TO '%[0-9]%'
	CASE 
		WHEN details SIMILAR TO '%[0-9]cm' THEN LEFT(details, -2)::decimal
		WHEN Details SIMILAR TO'%[0-9]kg' THEN LEFT(details, -2)::decimal 
		WHEN Details SIMILAR TO '%[0-9]°C' THEN LEFT(details, -2)::decimal
		ELSE NULL 
		END AS details_num,
	note
FROM
	baby.veronica_source_file AS sf
LEFT JOIN
	baby.veronica_source_file_notes AS n
ON
	TO_DATE(sf."Start", 'YYYY-MM-DD') = n."Date"::date;

--quality check

SELECT 
	COUNT(*) OVER(),
	*
FROM 
	dw_baby.tracker;

-- manual insertion of select values from notes (n rows -> total rows). The app input was different in the beginning. Adding vaccination information

SELECT 
	*
FROM
	dw_baby.tracker
WHERE 
	note IS NOT NULL;

INSERT INTO 
	dw_baby.tracker
	(activity, category, time_beg, time_end, duration, details, details_num, note)
VALUES
('Health', 'Medication', '2021-10-25 12:00:00.000', '2021-10-25 12:00:00.000', 0, 'Tylenol', NULL, 'Tylenol at 12 p.m.'),
('Health', 'Medication', '2021-10-24 10:50:00.000', '2021-10-24 10:50:00.000', 0, 'Tylenol', NULL, 'Tylenol at 10:50 a.m.'),
('Health', 'Medication', '2021-10-23 13:03:00.000', '2021-10-23 13:03:00.000', 0, 'Tylenol', NULL, 'Tylenol at 1:03 p.m.'),	
('Health', 'Medication', '2021-10-14 14:05:00.000', '2021-10-14 14:05:00.000', 0, 'Tylenol', NULL, 'Tylenol at 2:05 p.m.'),
('Health', 'Medication', '2021-10-12 12:05:00.000', '2021-10-12 12:05:00.000', 0, 'Tylenol', NULL, 'Tylenol at 12:05 p.m.'),
('Health', 'Medication', '2021-10-11 11:50:00.000', '2021-10-11 11:50:00.000', 0, 'Tylenol', NULL, 'Tylenol at 11:50 a.m.'),
('Health', 'Medication', '2021-10-08 14:20:00.000', '2021-10-08 14:20:00.000', 0, 'Tylenol', NULL, 'Tylenol at 2:20 p.m.'),
('Health', 'Medication', '2021-09-30 12:15:00.000', '2021-09-30 12:15:00.000', 0, 'Tylenol', NULL, 'Tylenol at 12:15 p.m.'),
('Health', 'Medication', '2021-09-27 22:10:00.000', '2021-09-27 22:10:00.000', 0, 'Tylenol', NULL, 'Tylenol at 10:10 p.m.'),
('Health', 'Medication', '2021-09-20 21:50:00.000', '2021-09-20 21:50:00.000', 0, 'Tylenol', NULL, 'Tylenol at 9:50 p.m.'),
('Health', 'Medication', '2021-09-10 23:15:00.000', '2021-09-10 23:15:00.000', 0, 'Tylenol', NULL, 'Tylenol at 11:15 p.m.'),
('Health', 'Medication', '2021-09-09 16:05:00.000', '2021-09-09 16:05:00.000', 0, 'Tylenol', NULL, 'Tylenol at 4:05 p.m.'),
('Health', 'Medication', '2021-09-09 22:00:00.000', '2021-09-09 22:00:00.000', 0, 'Tylenol', NULL, 'Tylenol at 10:00 p.m.'),
('Health', 'Temperature', '2021-08-19 00:00:00.000', '2021-08-19 00:00:00.000', 0, 'Temperature', 39.1, 'Temperature at 12:00 a.m.'),
('Health', 'Medication', '2021-08-19 00:45:00.000', '2021-08-19 00:45:00.000', 0, 'Tylenol', NULL, 'Tylenol at 12:45 a.m.'),
('Health', 'Medication', '2021-07-30 18:07:00.000', '2021-07-30 18:07:00.000', 0, 'Tylenol', NULL, 'Tylenol at 6:07 p.m.'),
('Health', 'Temperature', '2021-07-27 10:20:00.000', '2021-07-27 10:20:00.000', 0, 'Temperature', 39.1, 'Temperature after vaccination at 10:20 a.m.'),
('Health', 'Medication', '2021-07-27 10:28:00.000', '2021-07-27 10:28:00.000', 0, 'Tylenol', NULL, 'Tylenol at 10:28 a.m.'),
('Health', 'Medication', '2021-07-27 15:00:00.000', '2021-07-27 15:00:00.000', 0, 'Tylenol', NULL, 'Tylenol at 3:00 p.m.'),
('Health', 'Vaccination', '2021-07-26 15:00:00.000', '2021-07-26 15:00:00.000', 0, 'Vaccine', NULL, 'Vaccination'),
('Health', 'Medication', '2021-07-23 21:40:00.000', '2021-07-23 21:40:00.000', 0, 'Tylenol', NULL, 'Tylenol at 9:40 p.m.'),
('Health', 'Medication', '2021-07-22 02:10:00.000', '2021-07-22 02:10:00.000', 0, 'Tylenol', NULL, 'Tylenol at 2:10 a.m.'),
('Health', 'Medication', '2021-07-18 16:30:00.000', '2021-07-18 16:30:00.000', 0, 'Tylenol', NULL, 'Tylenol at 4:30 p.m.'),
('Health', 'Medication', '2021-07-11 23:20:00.000', '2021-07-11 23:20:00.000', 0, 'Tylenol', NULL, 'Tylenol at 11:20 p.m.'),
('Health', 'Medication', '2021-06-26 14:05:00.000', '2021-06-26 14:05:00.000', 0, 'Tylenol', NULL, 'Tylenol at 2:05 p.m.'),
('Health', 'Medication', '2021-06-19 10:40:00.000', '2021-06-19 10:40:00.000', 0, 'Tylenol', NULL, 'Tylenol at 10:40 a.m.'),
('Health', 'Medication', '2021-06-17 12:45:00.000', '2021-06-17 12:45:00.000', 0, 'Tylenol', NULL, 'Tylenol at 12:45 p.m.'),
('Health', 'Medication', '2021-04-19 19:00:00.000', '2021-04-19 19:00:00.000', 0, 'Tylenol', NULL, 'Tylenol at 7:00 p.m.'),
('Health', 'Medication', '2021-04-12 04:20:00.000', '2021-04-12 04:20:00.000', 0, 'Tylenol', NULL, 'Tylenol at 4:20 a.m.'),
('Health', 'Temperature', '2021-04-10 12:00:00.000', '2021-04-10 12:00:00.000', 0, 'Temperature', 37.7, 'Temperature 37.7'),
('Health', 'Temperature', '2021-04-09 13:15:00.000', '2021-04-09 13:15:00.000', 0, 'Temperature', 37.9, 'Temperature 37.9'),
('Health', 'Medication', '2021-04-09 13:20:00.000', '2021-04-09 13:20:00.000', 0, 'Tylenol', NULL, 'Tylenol at 1:20 p.m.'),
('Health', 'Temperature', '2021-02-27 12:15:00.000', '2021-02-27 12:15:00.000', 0, 'Temperature', 38.5, 'Temperature 38.5 after vaccination'),
('Health', 'Vaccination', '2021-02-26 15:00:00.000', '2021-02-26 15:00:00.000', 0, 'Vaccine', NULL, 'Vaccination'),