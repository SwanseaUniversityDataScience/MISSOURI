--Sensitivity analysis for trimethoprim only prescrition UTIs

CALL FNC.DROP_IF_EXISTS ('SESSION.VB_DAYS_IN_COHORT');
CALL FNC.DROP_IF_EXISTS ('SESSION.VB_MI_GP_UTI');
CALL FNC.DROP_IF_EXISTS ('SESSION.VB_MI_GP_ANTIBIOTIC');
CALL FNC.DROP_IF_EXISTS ('SESSION.V2_VB_MI_WRRS_ALL');
CALL FNC.DROP_IF_EXISTS ('SAILW0972V.V2_VB_MI_ALL_UTI_TRIM_ONLY');
CALL FNC.DROP_IF_EXISTS ('sailw0972v.V2_VB_MI_UTI_COMBINED_TRIM');
CALL FNC.DROP_IF_EXISTS ('sailw0972v.V2_VB_MI_UTI_CONFIRMED_TRIM');
CALL FNC.DROP_IF_EXISTS ('SAILW0972V.VB_MI_TRIM');
CALL FNC.DROP_IF_EXISTS ('SESSION.VB_STROKE_GP_UTI');
CALL FNC.DROP_IF_EXISTS ('SESSION.VB_STROKE_GP_ANTIBIOTIC');
CALL FNC.DROP_IF_EXISTS ('SESSION.V2_VB_STROKE_WRRS_ALL');
CALL FNC.DROP_IF_EXISTS ('SAILW0972V.V2_VB_STROKE_ALL_UTI_TRIM_ONLY');
CALL FNC.DROP_IF_EXISTS ('sailw0972v.V2_VB_STROKE_UTI_COMBINED_TRIM');
CALL FNC.DROP_IF_EXISTS ('sailw0972v.V2_VB_STROKE_UTI_CONFIRMED_TRIM');
CALL FNC.DROP_IF_EXISTS ('SAILW0972V.VB_STROKE_TRIM');

--generate table of inclusion start and end dates for first period of inclusion only

DECLARE GLOBAL TEMPORARY TABLE SESSION.VB_DAYS_IN_COHORT AS
	(SELECT ALF_PE,
			LATEST_START,
			EARLIEST_END
			FROM sailW0972V.V2_VB_WDSD_DAYS_IN_COHORT) 
DEFINITION ONLY
ON COMMIT PRESERVE ROWS;

Commit;

INSERT INTO SESSION.VB_DAYS_IN_COHORT
	(ALF_PE,
	LATEST_START,
	EARLIEST_END)
	SELECT dic.ALF_PE,
			min(dic.LATEST_START),
			min(dic.EARLIEST_END)
	FROM SAILW0972V.V2_VB_WDSD_DAYS_IN_COHORT AS dic
	GROUP BY dic. ALF_PE;

Commit;

DELETE FROM SESSION.VB_DAYS_IN_COHORT
	WHERE EARLIEST_END < LATEST_START;

/* identify where a UTI and Antibiotics readcode and confirmed microbiological UTI occur within 7 days of each other */

--Identifiy MI GP read UTIs

DECLARE GLOBAL TEMPORARY TABLE SESSION.VB_MI_GP_UTI  (
			row_id int NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 10000, increment BY 1),
			ALF_PE varchar(15),
			ALF_STS_CD integer,
			EVENT_CD varchar(5),
			EVENT_DT date)
ON COMMIT PRESERVE ROWS;

Commit;

INSERT INTO SESSION.VB_MI_GP_UTI (
			ALF_PE,
			ALF_STS_CD,
			EVENT_CD,
			EVENT_DT)
	SELECT	DISTINCT fe.ALF_PE,
			gp.ALF_STS_CD,
			gp.EVENT_CD,
			gp.EVENT_DT
	FROM SAILW0972V.V2_VB_PEDW_EPS_MI_FIRST_EVENT AS fe
	INNER JOIN SAIL0972V.WLGP_GP_EVENT_CLEANSED_20220301 AS gp
		ON fe.ALF_PE = gp.ALF_PE
		AND gp.ALF_STS_CD IN ('1','4','39')
		AND gp.EVENT_CD IN	('1J4..',
							'K190.',
							'1A55.',
							'K15..',
							'1A1..',
							'1AZ6.',
							'1AG..',
							'K1903',
							'K190z',
							'1A45.',
							'K1905',
							'1A44.',
							'1A12.',
							'K101.',
							'K150.',
							'K1973',
							'K10y0',
							'R081.',
							'K155.',
							'K1970',
							'R0842',
							'R0840',
							'R08..',
							'K15z.',
							'R081z',
							'R084.',
							'R0908',
							'K0A2.',
							'K1971',
							'SP07Q',
							'L1668',
							'K152y',
							'K101z',
							'R084z',
							'1A1Z.',
							'K15yz',
							'Kyu51',
							'K152.',
							'K152z')
		AND gp.EVENT_DT BETWEEN '2010-01-01' AND '2020-12-31';

Commit;

--identify MI GP read antibiotics

DECLARE GLOBAL TEMPORARY TABLE SESSION.VB_MI_GP_ANTIBIOTIC 
			(row_id int NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 10000, increment BY 1),
			ALF_PE VARCHAR(20),
			ALF_STS_CD INTEGER,
			EVENT_CD VARCHAR(5),
			EVENT_DT DATE)
ON COMMIT PRESERVE ROWS;

Commit;
		
INSERT INTO SESSION.VB_MI_GP_ANTIBIOTIC (
			ALF_PE,
			ALF_STS_CD,
			EVENT_CD,
			EVENT_DT)
	SELECT	DISTINCT fe.ALF_PE,
			gp.ALF_STS_CD,
			gp.EVENT_CD,
			gp.EVENT_DT
	FROM SAILW0972V.V2_VB_PEDW_EPS_MI_FIRST_EVENT AS fe
	INNER JOIN SAIL0972V.WLGP_GP_EVENT_CLEANSED_20220301 AS gp
		ON fe.ALF_PE = gp.ALF_PE
		AND gp.ALF_STS_CD IN ('1','4','39')
		AND gp.EVENT_CD IN ('eccb.',
							'ecc3.',
							'ecc..',
							'ecc1.',
							'ecc2.',
							'ecc4.'
							)
		AND gp.EVENT_DT BETWEEN '2010-01-01' AND '2020-12-31';
	
Commit;

--identify MI WRRS all UTI events regardless of outcome

DECLARE GLOBAL TEMPORARY TABLE SESSION.V2_VB_MI_WRRS_ALL
	(ALF_PE VARCHAR(20),
	SPCM_COLLECTED_DT date,
	WRRS_MAX_DT date,
	WRRS_MIN_DT date,
	UTI_OUTCOME VARCHAR(50))
ON COMMIT PRESERVE ROWS;

COMMIT;

INSERT INTO SESSION.V2_VB_MI_WRRS_ALL
	SELECT 	wrrs.ALF_PE,
			wrrs.SPCM_COLLECTED_DT,
			ADD_DAYS(wrrs.SPCM_COLLECTED_DT, 6) AS WRRS_MAX_DT,
			ADD_DAYS(wrrs.SPCM_COLLECTED_DT, -6) AS WRRS_MIN_DT,
			wrrs.UTI_OUTCOME 
		FROM SAILW0972V.VB_MI_COHORT_WRRS_RESULTS_AGREED AS wrrs
			WHERE uti_outcome <> 'Exclude NULL culture';
		
COMMIT;

--Identify the earliest out of the gp, antibiotic and wrrs dates within 7 day window

CREATE TABLE SAILW0972V.V2_VB_MI_ALL_UTI_TRIM_ONLY
	(ALF_PE VARCHAR(20),
	DIAG_ID integer,
	ABX_ID integer,
	DIAG_DT DATE,
	uti_end date,
	uti_outcome varchar(50),
	outcome_int integer);

INSERT INTO SAILW0972V.V2_VB_MI_ALL_UTI_TRIM_ONLY
	(ALF_PE,
	diag_id,
	abx_id,
	DIAG_DT,
	uti_end,
	UTI_OUTCOME,
	outcome_int)
WITH CTE AS 
(SELECT wrrs.ALF_PE,
		wrrs.SPCM_COLLECTED_DT,
		wrrs.uti_outcome,
		anti.EVENT_DT AS ANTI_DT,
		gp.row_id AS diag_id,
		anti.row_id AS abx_id,
		gp.EVENT_DT AS GP_DT
		FROM SESSION.V2_VB_MI_WRRS_ALL AS wrrs
	LEFT JOIN SESSION.VB_MI_GP_ANTIBIOTIC AS anti
		ON wrrs.ALF_PE = anti.ALF_PE
	LEFT JOIN SESSION.VB_MI_GP_UTI AS gp
		ON wrrs.ALF_PE = gp.ALF_PE
		WHERE anti.EVENT_DT BETWEEN wrrs.WRRS_MIN_DT AND wrrs.WRRS_MAX_DT
		AND gp.EVENT_DT BETWEEN wrrs.WRRS_MIN_DT AND wrrs.WRRS_MAX_DT)
	SELECT ALF_PE,
			diag_id,
			abx_id,
			min(SPCM_COLLECTED_DT,ANTI_DT,GP_DT) AS DIAG_DT,
			max(SPCM_COLLECTED_DT,ANTI_DT,GP_DT) AS uti_end,
			uti_outcome,
			CASE WHEN uti_outcome = 'Confirmed UTI'
					THEN 1
				WHEN uti_outcome = 'Possible UTI'
					THEN 2
				WHEN uti_outcome = 'Heavy mixed growth'
					THEN 3
				WHEN uti_outcome = 'Mixed growth'
					THEN 4
				WHEN uti_outcome = 'No microbiological evidence of UTI'
					THEN 5
				ELSE null
				end
			FROM CTE
		ORDER BY alf_pe, diag_dt;
	
------------------------------------------------------------------------------------
--assign UTI group and sequence number
	
CREATE TABLE sailw0972v.V2_VB_MI_UTI_COMBINED_TRIM
(alf_pe varchar(15),
diag_dt date,
uti_end date,
uti_outcome varchar (50),
outcome_int integer,
group_number integer,
group_sequence integer);

INSERT INTO sailw0972v.V2_VB_MI_UTI_COMBINED_TRIM
WITH cte AS (
SELECT uti.alf_pe,
		uti.diag_dt,
		uti.uti_end,
		uti_outcome,
		outcome_int,
		ROW_NUMBER() OVER (PARTITION BY uti.alf_pe ORDER BY diag_dt) AS Rn, 
       CASE WHEN LAG(uti.diag_dt,1) OVER (PARTITION BY uti.alf_pe ORDER BY uti.diag_dt, uti.uti_end, outcome_int desc) IS NULL OR 
                 LAG(uti.uti_end,1) OVER (PARTITION BY uti.alf_pe ORDER BY uti.diag_dt, uti.uti_end, outcome_int desc) < uti.diag_dt -7 DAYS THEN 1 
            ELSE 0 
        END AS new_group
  FROM SAILW0972V.V2_VB_MI_ALL_UTI_TRIM_ONLY AS uti
 ORDER BY alf_pe, diag_dt 
 ),
 cte2 as
 (SELECT cte.*,
 		lag(Rn) OVER (PARTITION BY alf_pe ORDER BY Rn) AS lag_rn,
		lag(alf_pe) OVER (PARTITION BY alf_pe ORDER BY alf_pe) AS lag_alf,
		lag(new_group) OVER (PARTITION BY alf_pe ORDER BY Rn) AS lag_group
	FROM cte
	ORDER BY alf_pe, diag_dt, uti_end, outcome_int DESC),	
 cte3 (alf_pe, diag_dt, uti_end, uti_outcome, outcome_int, Rn, group_seqeunce, group_number) as
(SELECT alf_pe,
		diag_dt,
		uti_end,
		uti_outcome,
		outcome_int,
		Rn,
		1 AS group_seqeunce,
		ROW_NUMBER() OVER (PARTITION BY alf_pe ORDER BY Rn) AS group_number
  FROM cte2
 WHERE new_group =  1
UNION ALL
SELECT a.alf_pe,
		b.diag_dt,
		b.uti_end,
		b.uti_outcome,
		b.outcome_int,
		b.Rn,
		a.group_seqeunce + 1,
		a.group_number
  FROM cte3 AS a,
  		cte AS b
  	WHERE 	a.alf_pe = b.alf_pe
  	AND 	a.Rn = b.Rn - 1
  	AND 	b.new_group = 0
)
SELECT alf_pe, diag_dt, uti_end, uti_outcome, outcome_int, group_number, group_seqeunce
  FROM cte3
 ORDER BY alf_pe, group_number, group_seqeunce;

---------------------------------------------------------------------
--create table for first UTI in group with a confirmed UTI

CREATE TABLE sailw0972v.V2_VB_MI_UTI_CONFIRMED_TRIM
AS (SELECT alf_pe,
		diag_dt,
		UTI_outcome,
		group_number
		FROM  sailw0972v.V2_VB_MI_UTI_COMBINED_TRIM)
WITH NO data;

INSERT INTO sailw0972v.V2_VB_MI_UTI_CONFIRMED_TRIM
SELECT alf_pe,
		min(diag_dt) AS diag_dt,
		UTI_outcome,
		group_number
		FROM  sailw0972v.V2_VB_MI_UTI_COMBINED_TRIM
WHERE uti_outcome = 'Confirmed UTI'
GROUP BY alf_pe,
		UTI_outcome,
		group_number
ORDER BY alf_pe, DIAG_DT
;

---create MI primary analysis table with start and end date of inclusion eligibility and week of birth----

CREATE TABLE SAILW0972V.VB_MI_TRIM AS (SELECT
		diag.ALF_PE,
		diag.DIAG_DT,
		dic.LATEST_START AS INC_START,
		dic.EARLIEST_END AS INC_END,
		yic.DOD,
		fe.WOB,
		fe.FIRST_EPI_STR_DT AS FIRST_EVENT_DT,
		fe.DIABETES
			FROM sailw0972v.V2_VB_MI_UTI_CONFIRMED_TRIM AS diag,
				SESSION.VB_DAYS_IN_COHORT AS dic,
				SAILW0972V.V2_VB_WDSD_AGE_IN_COHORT AS yic,
				SAILW0972V.V2_VB_PEDW_EPS_MI_FIRST_EVENT AS fe) WITH NO DATA;
					
INSERT INTO SAILW0972V.VB_MI_TRIM (
		ALF_PE,
		DIAG_DT,
		INC_START,
		INC_END,
		DOD,
		WOB,
		FIRST_EVENT_DT,
		DIABETES)
		SELECT 		diag.ALF_PE,
					diag.DIAG_DT,
					dic.LATEST_START AS INC_START,
					dic.EARLIEST_END AS INC_END,
					yic.DOD,
					fe.WOB,
					fe.FIRST_EPI_STR_DT,
					fe.DIABETES
			FROM sailw0972v.V2_VB_MI_UTI_CONFIRMED_TRIM AS diag
				LEFT JOIN SESSION.VB_DAYS_IN_COHORT AS dic
					ON diag.ALF_PE = dic.ALF_PE
				LEFT JOIN SAILW0972V.V2_VB_WDSD_AGE_IN_COHORT AS yic
					ON diag.ALF_PE = yic.ALF_PE
				LEFT JOIN SAILW0972V.V2_VB_PEDW_EPS_MI_FIRST_EVENT AS fe
					ON diag.ALF_PE = fe.ALF_PE;
				
--MI add flag to indicate if individual's cohort eligibility ended due to death
				
ALTER TABLE SAILW0972V.VB_MI_TRIM
	ADD COLUMN INC_END_DEATH_FG INTEGER;

UPDATE SAILW0972V.VB_MI_TRIM
	SET INC_END_DEATH_FG = CASE WHEN DOD = INC_END THEN '1'
							ELSE '0'
						END;
					
--delete cases where UTI does not occur within first period of inclusion from MI table

DELETE FROM SAILW0972V.VB_MI_TRIM
	WHERE DIAG_DT NOT BETWEEN INC_START AND INC_END;	

--delete duplicate rows

DELETE FROM 
	(SELECT ROWNUMBER()	OVER(PARTITION BY ALF_PE,
										DIAG_DT,
										INC_START,
										INC_END,
										DOD,
										WOB,
										FIRST_EVENT_DT,
										INC_END_DEATH_FG
								ORDER BY ALF_PE) AS rn
			FROM SAILW0972V.VB_MI_TRIM) AS mqo
			WHERE rn > 1;
		
ALTER TABLE SAILW0972V.VB_MI_TRIM
	ADD COLUMN PREV_EVENT_FG VARCHAR(5);

MERGE INTO SAILW0972V.VB_MI_TRIM AS prim
	USING (SELECT ALF_PE, PREVIOUS_EVENT FROM SAILW0972V.V2_VB_PEDW_EPS_MI_FIRST_EVENT) AS coh
		ON prim.ALF_PE = coh.ALF_PE
			WHEN MATCHED THEN
				UPDATE
				SET prim.PREV_EVENT_FG = coh.PREVIOUS_EVENT
			;
		
--Amend diabetes and previous event flags to binary

UPDATE SAILW0972V.VB_MI_TRIM
	SET DIABETES = CASE WHEN DIABETES = FALSE THEN 0
						ELSE 1
					END;
				
UPDATE SAILW0972V.VB_MI_TRIM
	SET PREV_EVENT_FG = CASE WHEN PREV_EVENT_FG = FALSE THEN 0
						ELSE 1
					END;
					
/*check for individuals with UTI diagnosis within 90 days of MI
 
 SELECT ALF_PE,
		DIAG_DT,
		FIRST_EVENT_DT,
		TIMESTAMPDIFF(16,TIMESTAMP(FIRST_EVENT_DT)-TIMESTAMP(DIAG_DT)) AS DAYS_DIF
		FROM SAILW0972V.VB_MI_TRIM
WHERE TIMESTAMPDIFF(16,TIMESTAMP(FIRST_EVENT_DT)-TIMESTAMP(DIAG_DT)) BETWEEN 0 AND 90;
 */
	
------------------------------------------------------------------------------------------------------
--Stroke Cohort

--Identify stroke GP read UTIs

DECLARE GLOBAL TEMPORARY TABLE SESSION.VB_STROKE_GP_UTI  (
			row_id int NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 10000, increment BY 1),
			ALF_PE varchar(15),
			ALF_STS_CD integer,
			EVENT_CD varchar(5),
			EVENT_DT date)
ON COMMIT PRESERVE ROWS;

Commit;
	
INSERT INTO SESSION.VB_STROKE_GP_UTI (
			ALF_PE,
			ALF_STS_CD,
			EVENT_CD,
			EVENT_DT)
	SELECT	DISTINCT fe.ALF_PE,
			gp.ALF_STS_CD,
			gp.EVENT_CD,
			gp.EVENT_DT
	FROM SAILW0972V.V2_VB_PEDW_EPS_STROKE_FIRST_EVENT AS fe
	INNER JOIN SAIL0972V.WLGP_GP_EVENT_CLEANSED_20220301 AS gp
		ON fe.ALF_PE = gp.ALF_PE
		AND gp.ALF_STS_CD IN ('1','4','39')
		AND gp.EVENT_CD IN ('1J4..',
							'K190.',
							'1A55.',
							'K15..',
							'1A1..',
							'1AZ6.',
							'1AG..',
							'K1903',
							'K190z',
							'1A45.',
							'K1905',
							'1A44.',
							'1A12.',
							'K101.',
							'K150.',
							'K1973',
							'K10y0',
							'R081.',
							'K155.',
							'K1970',
							'R0842',
							'R0840',
							'R08..',
							'K15z.',
							'R081z',
							'R084.',
							'R0908',
							'K0A2.',
							'K1971',
							'SP07Q',
							'L1668',
							'K152y',
							'K101z',
							'R084z',
							'1A1Z.',
							'K15yz',
							'Kyu51',
							'K152.',
							'K152z')
		AND gp.EVENT_DT BETWEEN '2010-01-01' AND '2020-12-31';
	
Commit;

--Identifiy stroke GP read antibiotics

DECLARE GLOBAL TEMPORARY TABLE SESSION.VB_STROKE_GP_ANTIBIOTIC 
			(row_id int NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 10000, increment BY 1),
			ALF_PE VARCHAR(20),
			ALF_STS_CD INTEGER,
			EVENT_CD VARCHAR(5),
			EVENT_DT DATE)
ON COMMIT PRESERVE ROWS;

Commit;
		
INSERT INTO SESSION.VB_STROKE_GP_ANTIBIOTIC (
			ALF_PE,
			ALF_STS_CD,
			EVENT_CD,
			EVENT_DT)
	SELECT	DISTINCT fe.ALF_PE,
			gp.ALF_STS_CD,
			gp.EVENT_CD,
			gp.EVENT_DT
	FROM SAILW0972V.V2_VB_PEDW_EPS_STROKE_FIRST_EVENT AS fe
	INNER JOIN SAIL0972V.WLGP_GP_EVENT_CLEANSED_20220301 AS gp
		ON fe.ALF_PE = gp.ALF_PE
		AND gp.ALF_STS_CD IN ('1','4','39')
		AND gp.EVENT_CD IN ('eccb.',
							'ecc3.',
							'ecc..',
							'ecc1.',
							'ecc2.',
							'ecc4.'
							)
		AND gp.EVENT_DT BETWEEN '2010-01-01' AND '2020-12-31';
		
COMMIT;

--identify STROKE WRRS all UTI events regardless of outcome

DECLARE GLOBAL TEMPORARY TABLE SESSION.V2_VB_STROKE_WRRS_ALL
	(ALF_PE VARCHAR(20),
	SPCM_COLLECTED_DT date,
	WRRS_MAX_DT date,
	WRRS_MIN_DT date,
	UTI_OUTCOME VARCHAR(50))
ON COMMIT PRESERVE ROWS;

COMMIT;

INSERT INTO SESSION.V2_VB_STROKE_WRRS_ALL
	SELECT 	wrrs.ALF_PE,
			wrrs.SPCM_COLLECTED_DT,
			ADD_DAYS(wrrs.SPCM_COLLECTED_DT, 6) AS WRRS_MAX_DT,
			ADD_DAYS(wrrs.SPCM_COLLECTED_DT, -6) AS WRRS_MIN_DT,
			wrrs.UTI_OUTCOME 
		FROM SAILW0972V.VB_STROKE_COHORT_WRRS_RESULTS_AGREED AS wrrs
			WHERE uti_outcome <> 'Exclude NULL culture';
		
COMMIT;

--Identify the earliest out of the gp, antibiotic and wrrs dates within 7 day window

CREATE TABLE SAILW0972V.V2_VB_STROKE_ALL_UTI_TRIM_ONLY
	(ALF_PE VARCHAR(20),
	DIAG_ID integer,
	ABX_ID integer,
	DIAG_DT DATE,
	uti_end date,
	uti_outcome varchar(50),
	outcome_int integer);

INSERT INTO SAILW0972V.V2_VB_STROKE_ALL_UTI_TRIM_ONLY
	(ALF_PE,
	diag_id,
	abx_id,
	DIAG_DT,
	uti_end,
	UTI_OUTCOME,
	outcome_int)
WITH CTE AS 
(SELECT wrrs.ALF_PE,
		wrrs.SPCM_COLLECTED_DT,
		wrrs.uti_outcome,
		anti.EVENT_DT AS ANTI_DT,
		gp.row_id AS diag_id,
		anti.row_id AS abx_id,
		gp.EVENT_DT AS GP_DT
		FROM SESSION.V2_VB_STROKE_WRRS_ALL AS wrrs
	LEFT JOIN SESSION.VB_STROKE_GP_ANTIBIOTIC AS anti
		ON wrrs.ALF_PE = anti.ALF_PE
	LEFT JOIN SESSION.VB_STROKE_GP_UTI AS gp
		ON wrrs.ALF_PE = gp.ALF_PE
		WHERE anti.EVENT_DT BETWEEN wrrs.WRRS_MIN_DT AND wrrs.WRRS_MAX_DT
		AND gp.EVENT_DT BETWEEN wrrs.WRRS_MIN_DT AND wrrs.WRRS_MAX_DT)
	SELECT ALF_PE,
			diag_id,
			abx_id,
			min(SPCM_COLLECTED_DT,ANTI_DT,GP_DT) AS DIAG_DT,
			max(SPCM_COLLECTED_DT,ANTI_DT,GP_DT) AS uti_end,
			uti_outcome,
			CASE WHEN uti_outcome = 'Confirmed UTI'
					THEN 1
				WHEN uti_outcome = 'Possible UTI'
					THEN 2
				WHEN uti_outcome = 'Heavy mixed growth'
					THEN 3
				WHEN uti_outcome = 'Mixed growth'
					THEN 4
				WHEN uti_outcome = 'No microbiological evidence of UTI'
					THEN 5
				ELSE null
				end
			FROM CTE
		ORDER BY alf_pe, diag_dt;
	
------------------------------------------------------------------------------------
--assign UTI group and sequence number
	
CREATE TABLE sailw0972v.V2_VB_STROKE_UTI_COMBINED_TRIM
(alf_pe varchar(15),
diag_dt date,
uti_end date,
uti_outcome varchar (50),
outcome_int integer,
group_number integer,
group_sequence integer);

INSERT INTO sailw0972v.V2_VB_STROKE_UTI_COMBINED_TRIM
WITH cte AS (
SELECT uti.alf_pe,
		uti.diag_dt,
		uti.uti_end,
		uti_outcome,
		outcome_int,
		ROW_NUMBER() OVER (PARTITION BY uti.alf_pe ORDER BY diag_dt) AS Rn, 
       CASE WHEN LAG(uti.diag_dt,1) OVER (PARTITION BY uti.alf_pe ORDER BY uti.diag_dt, uti.uti_end, outcome_int desc) IS NULL OR 
                 LAG(uti.uti_end,1) OVER (PARTITION BY uti.alf_pe ORDER BY uti.diag_dt, uti.uti_end, outcome_int desc) < uti.diag_dt -7 DAYS THEN 1 
            ELSE 0 
        END AS new_group
  FROM SAILW0972V.V2_VB_STROKE_ALL_UTI_TRIM_ONLY AS uti
 ORDER BY alf_pe, diag_dt 
 ),
 cte2 as
 (SELECT cte.*,
 		lag(Rn) OVER (PARTITION BY alf_pe ORDER BY Rn) AS lag_rn,
		lag(alf_pe) OVER (PARTITION BY alf_pe ORDER BY alf_pe) AS lag_alf,
		lag(new_group) OVER (PARTITION BY alf_pe ORDER BY Rn) AS lag_group
	FROM cte
	ORDER BY alf_pe, diag_dt, uti_end, outcome_int DESC),	
 cte3 (alf_pe, diag_dt, uti_end, uti_outcome, outcome_int, Rn, group_seqeunce, group_number) as
(SELECT alf_pe,
		diag_dt,
		uti_end,
		uti_outcome,
		outcome_int,
		Rn,
		1 AS group_seqeunce,
		ROW_NUMBER() OVER (PARTITION BY alf_pe ORDER BY Rn) AS group_number
  FROM cte2
 WHERE new_group =  1
UNION ALL
SELECT a.alf_pe,
		b.diag_dt,
		b.uti_end,
		b.uti_outcome,
		b.outcome_int,
		b.Rn,
		a.group_seqeunce + 1,
		a.group_number
  FROM cte3 AS a,
  		cte AS b
  	WHERE 	a.alf_pe = b.alf_pe
  	AND 	a.Rn = b.Rn - 1
  	AND 	b.new_group = 0
)
SELECT alf_pe, diag_dt, uti_end, uti_outcome, outcome_int, group_number, group_seqeunce
  FROM cte3
 ORDER BY alf_pe, group_number, group_seqeunce;

---------------------------------------------------------------------
--create table for first UTI in group with a confirmed UTI

CREATE TABLE sailw0972v.V2_VB_STROKE_UTI_CONFIRMED_TRIM
AS (SELECT alf_pe,
		diag_dt,
		UTI_outcome,
		group_number
		FROM  sailw0972v.V2_VB_STROKE_UTI_COMBINED_TRIM)
WITH NO data;

INSERT INTO sailw0972v.V2_VB_STROKE_UTI_CONFIRMED_TRIM
SELECT alf_pe,
		min(diag_dt) AS diag_dt,
		UTI_outcome,
		group_number
		FROM  sailw0972v.V2_VB_STROKE_UTI_COMBINED_TRIM
WHERE uti_outcome = 'Confirmed UTI'
GROUP BY alf_pe,
		UTI_outcome,
		group_number
ORDER BY alf_pe, DIAG_DT
;

---create STROKE primary analysis table with start and end date of inclusion eligibility and week of birth----

CREATE TABLE SAILW0972V.VB_STROKE_TRIM AS (SELECT
		diag.ALF_PE,
		diag.DIAG_DT,
		dic.LATEST_START AS INC_START,
		dic.EARLIEST_END AS INC_END,
		yic.DOD,
		fe.WOB,
		fe.FIRST_EPI_STR_DT AS FIRST_EVENT_DT,
		fe.DIABETES
			FROM sailw0972v.V2_VB_STROKE_UTI_CONFIRMED_TRIM AS diag,
				SESSION.VB_DAYS_IN_COHORT AS dic,
				SAILW0972V.V2_VB_WDSD_AGE_IN_COHORT AS yic,
				SAILW0972V.V2_VB_PEDW_EPS_STROKE_FIRST_EVENT AS fe) WITH NO DATA;
					
INSERT INTO SAILW0972V.VB_STROKE_TRIM (
		ALF_PE,
		DIAG_DT,
		INC_START,
		INC_END,
		DOD,
		WOB,
		FIRST_EVENT_DT,
		DIABETES)
		SELECT 		diag.ALF_PE,
					diag.DIAG_DT,
					dic.LATEST_START AS INC_START,
					dic.EARLIEST_END AS INC_END,
					yic.DOD,
					fe.WOB,
					fe.FIRST_EPI_STR_DT,
					fe.DIABETES
			FROM sailw0972v.V2_VB_STROKE_UTI_CONFIRMED_TRIM AS diag
				LEFT JOIN SESSION.VB_DAYS_IN_COHORT AS dic
					ON diag.ALF_PE = dic.ALF_PE
				LEFT JOIN SAILW0972V.V2_VB_WDSD_AGE_IN_COHORT AS yic
					ON diag.ALF_PE = yic.ALF_PE
				LEFT JOIN SAILW0972V.V2_VB_PEDW_EPS_STROKE_FIRST_EVENT AS fe
					ON diag.ALF_PE = fe.ALF_PE;
				
--add flag to indicate if individual's cohort eligibility ended due to death
				
ALTER TABLE SAILW0972V.VB_STROKE_TRIM
	ADD COLUMN INC_END_DEATH_FG INTEGER;

UPDATE SAILW0972V.VB_STROKE_TRIM
	SET INC_END_DEATH_FG = CASE WHEN DOD = INC_END THEN '1'
							ELSE '0'
						END;
					
-------------------------------------------------------------------------------------					
--delete cases where UTI does not occur within first period of inclusion from stroke table

DELETE FROM SAILW0972V.VB_STROKE_TRIM
	WHERE DIAG_DT NOT BETWEEN INC_START AND INC_END;

--delete duplicate rows

DELETE FROM 
	(SELECT ROWNUMBER()	OVER(PARTITION BY ALF_PE,
										DIAG_DT,
										INC_START,
										INC_END,
										DOD,
										WOB,
										FIRST_EVENT_DT,
										INC_END_DEATH_FG
								ORDER BY ALF_PE) AS rn
			FROM SAILW0972V.VB_STROKE_TRIM) AS mqo
			WHERE rn > 1;
		
ALTER TABLE SAILW0972V.VB_STROKE_TRIM
	ADD COLUMN PREV_EVENT_FG VARCHAR(5);

MERGE INTO SAILW0972V.VB_STROKE_TRIM AS prim
	USING (SELECT ALF_PE, PREVIOUS_EVENT FROM SAILW0972V.V2_VB_PEDW_EPS_STROKE_FIRST_EVENT) AS coh
		ON prim.ALF_PE = coh.ALF_PE
			WHEN MATCHED THEN
				UPDATE
				SET prim.PREV_EVENT_FG = coh.PREVIOUS_EVENT
			;	
		
--Amend diabetes and previous event flags to binary

UPDATE SAILW0972V.VB_STROKE_TRIM
	SET DIABETES = CASE WHEN DIABETES = FALSE THEN 0
						ELSE 1
					END;
				
UPDATE SAILW0972V.VB_STROKE_TRIM
	SET PREV_EVENT_FG = CASE WHEN PREV_EVENT_FG = FALSE THEN 0
						ELSE 1
					END;		
