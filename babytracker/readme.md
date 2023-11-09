# BABY ROUTINE: (MORE THAN) A FULL TIME JOB

[Interactive visualization](https://public.tableau.com/app/profile/olga.romanova7546/viz/Baby_routine/Babyroutine)

The goal of this project is to answer the question: where did all time go when my daughter was younger, and what it takes to raise a child up to 3,5 years.

From my child's birth, I used the app "Baby Tracker" to keep the track of multiple areas of her life (`30,402` entries during approximately `3.8 years`). The app provides export into .xlsx file. Since the app was evolving througout those years, and I was not using it quite consistently, some cleaning was required to work with data.

## DATA CLEANING
[See the .sql script for details](baby-tracker.sql)
1. Imported .csv files via DBeaver into the staging schema:
- 30,402 rows in baby.veronica_source_file
- 63 rows in baby.veronica_source_file_notes

2. Created a separate schema viz_baby and a tracker table inside.

3. Inserted data from source tables:
    3.1 Converted date/time columns from string to timestamp.
    3.2 Added a calculation of duration.
    3.3 ensured that all medication names are entered in the uniform way.

4. Manually inserted select values from notes (no single pattern to automate). Added 39 rows -> 30,441 rows total. 
The reason for this is that the app input was different in the beginning. Plus, decided to add vaccination information.

5. Split rows that spanned two days in two parts (each row into two rows) for correct visualization. 
I used a temporary table for that: 
    5.1 Inserted rows replacing end time with the same date as the beginning, but time 23:59.
    5.2 Inserted rows replacing start time with the same date as the end, but time 00:00.
    5.3 Deleted the rows that span two days from the original table (1049 rows)
    5.4 Inserted data from the temporary table to the original table -> **31490 rows**.
6. Updated the table by extacting time from start and end timestamps and converting it to decimal for correct visualization.
7. Calculated time since previous and to next activities for:
    7.1 sleep (5167 rows),
    7.2 feeding (17714 rows),
    7.3 diaper changes (6306 rows).

## VISUALIZING

