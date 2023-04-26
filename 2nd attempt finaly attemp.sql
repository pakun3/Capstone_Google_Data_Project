--Data Cleaning/ Replacing Colunm= Member Casual to USERTYPE:
--ROW= Member to Subscriber, Casual to Customer in table q_1_2020

Select *
from PortfolioProject.dbo.q_1_2020

Select Distinct member_casual, Count(member_casual)
From PortfolioProject.dbo.q_1_2020
Group by member_casual
Order by 2

Select member_casual, CASE When member_casual = 'member' Then 'Subscriber'
							When member_casual = 'casual' Then 'Customer'
							ELSE member_casual
							END
from PortfolioProject.dbo.q_1_2020

update q_1_2020
SET member_casual = CASE When member_casual = 'member' Then 'Subscriber'
							When member_casual = 'casual' Then 'Customer'
							ELSE member_casual
							END

ALTER TABLE PortfolioProject.dbo.q_1_2020
RENAME COLUMN member_casual TO usertype;

--Incorrect syntax near 'RENAME'. after some research synstax are not all the same. for MS.SQLSERVER
-- the proper syntax to update a colunm is 'sp_rename'

EXEC sp_rename 'PortfolioProject.dbo.q_1_2020.member_casual', 'usertype', 'COLUMN';

EXEC sp_rename 'PortfolioProject.dbo.q_1_2020.start_station_name', 'from_station_name', 'COLUMN';;

EXEC sp_rename 'PortfolioProject.dbo.q_1_2020.started_at', 'start_time', 'COLUMN';

EXEC sp_rename 'PortfolioProject.dbo.q_1_2020.ended_at', 'end_time', 'COLUMN';


--------------------------------------------------------------------------------------------------------------

-- Here's how I added trip duraiton in table q_1_2020
--by adding both start_time and end_time

SELECT CAST(start_time AS time) AS start_time_only, CAST(end_time AS time) AS end_time_only
FROM PortfolioProject.dbo.q_1_2020

ALTER TABLE PortfolioProject.dbo.q_1_2020
ADD tripduration INT;

UPDATE PortfolioProject.dbo.q_1_2020
SET tripduration = DATEDIFF(second, start_time, end_time);


Select *
from PortfolioProject.dbo.q_1_2020




---------------------------------------------------------------------------------------------------------

--Here's the process on how I combining the shared columns into 1 new table(CapsProjec_Clean_Data)

SELECT usertype, gender, birthyear, from_station_name, to_station_name, start_time, end_time, tripduration 
INTO CapsProject_2ndTry
FROM (
    SELECT usertype, NULL AS gender, NULL AS birthyear, from_station_name, to_station_name, start_time, end_time, tripduration 
    FROM PortfolioProject.DBO.q_1_2020
    UNION ALL
    SELECT usertype, gender, birthyear, from_station_name, to_station_name, start_time, end_time, tripduration 
    FROM PortfolioProject.DBO.q_4_2019
    UNION ALL
    SELECT usertype, gender, birthyear, from_station_name, to_station_name, start_time, end_time, tripduration 
    FROM PortfolioProject.DBO.q_3_2019
    UNION ALL
    SELECT usertype, gender, birthyear, from_station_name, to_station_name, start_time, end_time, tripduration 
    FROM PortfolioProject.DBO.q_2_2019
) AS combined_data;

---------------------------------------------------------------------------------------------
--- CREATED NEW TABLE. NOW ADD FINISHING TOUCHES LIKE SEPARATING THE DATES AND TIME FROM COLUMNS START_TIME & END_TIME

SELECT *
FROM CapsProject_2ndTry

SELECT CONVERT(VARCHAR(10), start_time, 23) AS start_date, CONVERT(VARCHAR(10), end_time, 23) AS end_date
FROM CapsProject_2ndTry

ALTER TABLE CapsProject_2ndTry
ADD start_date DATE

UPDATE CapsProject_2ndTry
SET start_date = CONVERT(DATE, start_time)


--------------------------------------------------------------------------------
--UPDATED RENAME COLUMNS

EXEC sp_rename 'CapsProject_2ndTry.tripduration', 'trip_duration', 'COLUMN'

EXEC sp_rename 'CapsProject_2ndTry.birthyear', 'birth_year', 'COLUMN'

EXEC sp_rename 'CapsProject_2ndTry.start_date', 'trip_date', 'COLUMN'

EXEC sp_rename 'CapsProject_2ndTry.usertype', 'user_type', 'COLUMN'

---------------------------------------------------------------------------------
----SEPARATED DATES FROM TIMES

SELECT CONVERT(varchar(8), start_time, 108) AS start_time_only
FROM CapsProject_2ndTry

ALTER TABLE CapsProject_2ndTry
ADD start_time_only TIME

UPDATE CapsProject_2ndTry
SET start_time_only = CONVERT(TIME, start_time)

SELECT CONVERT(varchar(8), end_time, 108) AS end_time_only
FROM CapsProject_2ndTry

ALTER TABLE CapsProject_2ndTry
ADD end_time_only TIME

UPDATE CapsProject_2ndTry
SET end_time_only = CONVERT(TIME, end_time)

SELECT *
FROM CapsProject_2ndTry
--------------------------------------------------------------------------------
--DELETED UNUSABLE COLUMNS

ALTER TABLE CapsProject_2ndTry
DROP COLUMN start_time, end_time

--------------------------------------------------------------------------------------------
SELECT *
FROM CapsProject_2ndTry
-----------------------------------------