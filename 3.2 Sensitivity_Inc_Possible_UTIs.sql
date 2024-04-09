--Sensitiivty analysis to wider the WRRS microbiological UTIs to include those with possible UTIs.
--growth >10^7 irrespective of White Blood Cell counts

CALL FNC.DROP_IF_EXISTS ('SESSION.V2_VB_DAYS_IN_COHORT');
CALL FNC.DROP_IF_EXISTS ('sailw0972v.V2_VB_MI_UTI_SENS_PUTI');
CALL FNC.DROP_IF_EXISTS ('SAILW0972V.V2_VB_MI_SENS_PUTI');
CALL FNC.DROP_IF_EXISTS ('sailw0972v.V2_VB_STROKE_UTI_SENS_PUTI');
CALL FNC.DROP_IF_EXISTS ('SAILW0972V.V2_VB_STROKE_SENS_PUTI');

--generate table of inclusion start and end dates for first period of inclusion only

DECLARE GLOBAL TEMPORARY TABLE SESSION.V2_VB_DAYS_IN_COHORT AS
	(SELECT ALF_PE,
			LATEST_START,
			EARLIEST_END
			FROM sailW0972V.V2_VB_WDSD_DAYS_IN_COHORT) 
DEFINITION ONLY
ON COMMIT PRESERVE ROWS;

Commit;

INSERT INTO SESSION.V2_VB_DAYS_IN_COHORT
	(ALF_PE,
	LATEST_START,
	EARLIEST_END)
	SELECT dic.ALF_PE,
			min(dic.LATEST_START),
			min(dic.EARLIEST_END)
	FROM SAILW0972V.V2_VB_WDSD_DAYS_IN_COHORT AS dic
	GROUP BY dic. ALF_PE;

Commit;

DELETE FROM SESSION.V2_VB_DAYS_IN_COHORT
	WHERE EARLIEST_END < LATEST_START;

/* identify where a UTI and Antibiotics readcode and no evidence of microbiological UTI occur within 7 days of each other */

--Identifiy MI GP read UTIs

---------------------------------------------------------------------
--create table for first UTI in group with a confirmed or possible UTI

CREATE TABLE sailw0972v.V2_VB_MI_UTI_SENS_PUTI
AS (SELECT alf_pe,
			diag_dt,
			group_number
	FROM sailw0972v.V2_VB_MI_UTI_COMBINED)
WITH NO data;

INSERT INTO sailw0972v.V2_VB_MI_UTI_SENS_PUTI
WITH cte AS --find highest outcome in a linked UTI sequence
(SELECT alf_pe, group_number, min(outcome_int) AS highest_outcome
	FROM sailw0972v.V2_VB_MI_UTI_COMBINED
GROUP BY alf_pe, group_number),
cte2 AS --find only those linked sequences with highest outcome 1 or 2 (confirmed or possible)
(SELECT * FROM cte WHERE highest_outcome IN (1,2)),
cte3 AS -- minimum diagnosis date 
(SELECT cte.alf_pe,
		cte.group_number,
		min(u.diag_dt) AS diag_dt
		FROM cte
		INNER JOIN sailw0972v.V2_VB_MI_UTI_COMBINED AS u
			ON cte.alf_pe = u.alf_pe
			AND cte.group_number = u.group_number
		WHERE u.outcome_int IN (1,2)
	GROUP BY cte.alf_pe,
			cte.group_number)
SELECT DISTINCT 
		cte2.alf_pe,
		cte3.diag_dt,
		cte2.group_number
	FROM sailw0972v.V2_VB_MI_UTI_COMBINED AS uti
	INNER JOIN cte2
		ON uti.alf_pe = cte2.alf_pe
		AND uti.group_number = cte2.group_number
	INNER JOIN cte3
		ON uti.alf_pe = cte3.alf_pe
		AND uti.diag_dt = cte3.diag_dt
ORDER BY cte2.alf_pe, cte3.diag_dt;

----------------------------------------------------------------------------------------

---create confirmed or possible analysis table with start and end date of inclusion eligibility and week of birth----

CREATE TABLE SAILW0972V.V2_VB_MI_SENS_PUTI AS (SELECT
		diag.ALF_PE,
		diag.DIAG_DT,
		dic.LATEST_START AS INC_START,
		dic.EARLIEST_END AS INC_END,
		yic.DOD,
		fe.WOB,
		fe.FIRST_EPI_STR_DT AS FIRST_EVENT_DT,
		fe.DIABETES
			FROM sailw0972v.V2_VB_MI_UTI_SENS_PUTI AS diag,
				SESSION.V2_VB_DAYS_IN_COHORT AS dic,
				SAILW0972V.V2_VB_WDSD_AGE_IN_COHORT AS yic,
				SAILW0972V.V2_VB_PEDW_EPS_MI_FIRST_EVENT AS fe) WITH NO DATA;
					
INSERT INTO SAILW0972V.V2_VB_MI_SENS_PUTI (
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
			FROM sailw0972v.V2_VB_MI_UTI_SENS_PUTI AS diag
				LEFT JOIN SESSION.V2_VB_DAYS_IN_COHORT AS dic
					ON diag.ALF_PE = dic.ALF_PE
				LEFT JOIN SAILW0972V.V2_VB_WDSD_AGE_IN_COHORT AS yic
					ON diag.ALF_PE = yic.ALF_PE
				LEFT JOIN SAILW0972V.V2_VB_PEDW_EPS_MI_FIRST_EVENT AS fe
					ON diag.ALF_PE = fe.ALF_PE;
				
--MI add flag to indicate if individual's cohort eligibility ended due to death
				
ALTER TABLE SAILW0972V.V2_VB_MI_SENS_PUTI
	ADD COLUMN INC_END_DEATH_FG INTEGER;

UPDATE SAILW0972V.V2_VB_MI_SENS_PUTI
	SET INC_END_DEATH_FG = CASE WHEN DOD = INC_END THEN '1'
							ELSE '0'
						END;
					
--delete cases where UTI does not occur within first period of inclusion from MI table

DELETE FROM SAILW0972V.V2_VB_MI_SENS_PUTI
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
			FROM SAILW0972V.V2_VB_MI_SENS_PUTI) AS mqo
			WHERE rn > 1;
		
ALTER TABLE SAILW0972V.V2_VB_MI_SENS_PUTI
	ADD COLUMN PREV_EVENT_FG VARCHAR(5);

MERGE INTO SAILW0972V.V2_VB_MI_SENS_PUTI AS prim
	USING (SELECT ALF_PE, PREVIOUS_EVENT FROM SAILW0972V.V2_VB_PEDW_EPS_MI_FIRST_EVENT) AS coh
		ON prim.ALF_PE = coh.ALF_PE
			WHEN MATCHED THEN
				UPDATE
				SET prim.PREV_EVENT_FG = coh.PREVIOUS_EVENT
			;
		
--Amend diabetes and previous event flags to binary

UPDATE SAILW0972V.V2_VB_MI_SENS_PUTI
	SET DIABETES = CASE WHEN DIABETES = FALSE THEN 0
						ELSE 1
					END;
				
UPDATE SAILW0972V.V2_VB_MI_SENS_PUTI
	SET PREV_EVENT_FG = CASE WHEN PREV_EVENT_FG = FALSE THEN 0
						ELSE 1
					END;
					
/*check for individuals with UTI diagnosis within 90 days of MI
 
 SELECT ALF_PE,
		DIAG_DT,
		FIRST_EVENT_DT,
		TIMESTAMPDIFF(16,TIMESTAMP(FIRST_EVENT_DT)-TIMESTAMP(DIAG_DT)) AS DAYS_DIF
		FROM SAILW0972V.V2_VB_MI_SENS_PUTI
WHERE TIMESTAMPDIFF(16,TIMESTAMP(FIRST_EVENT_DT)-TIMESTAMP(DIAG_DT)) BETWEEN 0 AND 90;
 */
	
------------------------------------------------------------------------------------------------------
--Stroke Cohort

--Identify stroke GP read UTIs

---------------------------------------------------------------------
--create table for first UTI in group with a confirmed or possible UTI

CREATE TABLE sailw0972v.V2_VB_STROKE_UTI_SENS_PUTI
AS (SELECT alf_pe,
			diag_dt,
			group_number
	FROM sailw0972v.V2_VB_STROKE_UTI_COMBINED)
WITH NO data;

INSERT INTO sailw0972v.V2_VB_STROKE_UTI_SENS_PUTI
WITH cte AS --find highest outcome in a linked UTI sequence
(SELECT alf_pe, group_number, min(outcome_int) AS highest_outcome
	FROM sailw0972v.V2_VB_STROKE_UTI_COMBINED
GROUP BY alf_pe, group_number),
cte2 AS --find only those linked sequences with highest outcome 1 or 2 (confirmed or possible)
(SELECT * FROM cte WHERE highest_outcome IN (1,2)),
cte3 AS -- minimum diagnosis date 
(SELECT cte.alf_pe,
		cte.group_number,
		min(u.diag_dt) AS diag_dt
		FROM cte
		INNER JOIN sailw0972v.V2_VB_STROKE_UTI_COMBINED AS u
			ON cte.alf_pe = u.alf_pe
			AND cte.group_number = u.group_number
		WHERE u.outcome_int IN (1,2)
	GROUP BY cte.alf_pe,
			cte.group_number)
SELECT DISTINCT 
		cte2.alf_pe,
		cte3.diag_dt,
		cte2.group_number
	FROM sailw0972v.V2_VB_STROKE_UTI_COMBINED AS uti
	INNER JOIN cte2
		ON uti.alf_pe = cte2.alf_pe
		AND uti.group_number = cte2.group_number
	INNER JOIN cte3
		ON uti.alf_pe = cte3.alf_pe
		AND uti.diag_dt = cte3.diag_dt
ORDER BY cte2.alf_pe, cte3.diag_dt;

----------------------------------------------------------------------------------------

---create confirmed or possible analysis table with start and end date of inclusion eligibility and week of birth----

CREATE TABLE SAILW0972V.V2_VB_STROKE_SENS_PUTI AS (SELECT
		diag.ALF_PE,
		diag.DIAG_DT,
		dic.LATEST_START AS INC_START,
		dic.EARLIEST_END AS INC_END,
		yic.DOD,
		fe.WOB,
		fe.FIRST_EPI_STR_DT AS FIRST_EVENT_DT,
		fe.DIABETES
			FROM sailw0972v.V2_VB_STROKE_UTI_SENS_PUTI AS diag,
				SESSION.V2_VB_DAYS_IN_COHORT AS dic,
				SAILW0972V.V2_VB_WDSD_AGE_IN_COHORT AS yic,
				SAILW0972V.V2_VB_PEDW_EPS_STROKE_FIRST_EVENT AS fe) WITH NO DATA;
					
INSERT INTO SAILW0972V.V2_VB_STROKE_SENS_PUTI (
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
			FROM sailw0972v.V2_VB_STROKE_UTI_SENS_PUTI AS diag
				LEFT JOIN SESSION.V2_VB_DAYS_IN_COHORT AS dic
					ON diag.ALF_PE = dic.ALF_PE
				LEFT JOIN SAILW0972V.V2_VB_WDSD_AGE_IN_COHORT AS yic
					ON diag.ALF_PE = yic.ALF_PE
				LEFT JOIN SAILW0972V.V2_VB_PEDW_EPS_STROKE_FIRST_EVENT AS fe
					ON diag.ALF_PE = fe.ALF_PE;
				
--STROKE add flag to indicate if individual's cohort eligibility ended due to death
				
ALTER TABLE SAILW0972V.V2_VB_STROKE_SENS_PUTI
	ADD COLUMN INC_END_DEATH_FG INTEGER;

UPDATE SAILW0972V.V2_VB_STROKE_SENS_PUTI
	SET INC_END_DEATH_FG = CASE WHEN DOD = INC_END THEN '1'
							ELSE '0'
						END;
					
--delete cases where UTI does not occur within first period of inclusion from STROKE table

DELETE FROM SAILW0972V.V2_VB_STROKE_SENS_PUTI
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
			FROM SAILW0972V.V2_VB_STROKE_SENS_PUTI) AS mqo
			WHERE rn > 1;
		
ALTER TABLE SAILW0972V.V2_VB_STROKE_SENS_PUTI
	ADD COLUMN PREV_EVENT_FG VARCHAR(5);

MERGE INTO SAILW0972V.V2_VB_STROKE_SENS_PUTI AS prim
	USING (SELECT ALF_PE, PREVIOUS_EVENT FROM SAILW0972V.V2_VB_PEDW_EPS_STROKE_FIRST_EVENT) AS coh
		ON prim.ALF_PE = coh.ALF_PE
			WHEN MATCHED THEN
				UPDATE
				SET prim.PREV_EVENT_FG = coh.PREVIOUS_EVENT
			;
		
--Amend diabetes and previous event flags to binary

UPDATE SAILW0972V.V2_VB_STROKE_SENS_PUTI
	SET DIABETES = CASE WHEN DIABETES = FALSE THEN 0
						ELSE 1
					END;
				
UPDATE SAILW0972V.V2_VB_STROKE_SENS_PUTI
	SET PREV_EVENT_FG = CASE WHEN PREV_EVENT_FG = FALSE THEN 0
						ELSE 1
					END;
					