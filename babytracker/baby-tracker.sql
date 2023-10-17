DROP TABLE baby.veronica_source_file, baby.veronica_source_file_notes; 

SELECT 
	*
FROM 
	baby.veronica_source_file vsf;
	
SELECT 
	*
FROM 
	baby.veronica_source_file_notes vsfn;
	
CREATE SCHEMA IF NOT EXISTS dw_baby;

DROP TABLE IF EXISTS dw_baby.tracker;

CREATE TABLE 
	dw_baby.tracker 
		(
		row_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
		activity VARCHAR(50) NOT NULL,
		type VARCHAR(50),
		start timestamp,
		finish timestamp,
		details VARCHAR(150),
		note VARCHAR(300)
		);
	
TRUNCATE TABLE dw_baby.tracker;

INSERT INTO
	dw_baby.tracker
	(
	activity,
	type,
	start
	finish,
	details)
SELECT
	activity,
	Type,
	TO_TIMESTAMP(Start, 'YYYY-MM-DD, HH:MM AM'),
	TO_TIMESTAMP(finish, 'YYYY-MM-DD, HH:MM AM'),
	details
FROM
	baby.veronica_source_file AS sf
JOIN
	baby.veronica_source_file_notes AS n
ON
	TO_DATE(sf.Start, 'YYYY-MM-DD') = n."Date" 
	
		