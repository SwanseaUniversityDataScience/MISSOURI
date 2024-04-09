--sensitivity analysis for patients with a GP suspected and treated UTI (diagnosis and antibiotic read code) where WRRS microbiology result does not support the presence of a UTI
--This sensitivit includes only UTIs where there is no linked UTI result of any other type (mixed and heavy mixed are allowed to be linked in secondary analysis 3)

--Primary analysis 1.4 Primary_Analysis_V2.sql script must be run before this script
--Uses table sailw0972v.V2_VB_MI_UTI_COMBINED

--sensitivity no micro only includes individuals with a WLGP recorded UTI diagnosis read code and a WRRS microbiology result of
--no microbiological evidence of UTI. Only linked UTIs (occuring within 7 days of each other) which contain no other result type
--are included.

CALL FNC.DROP_IF_EXISTS ('SESSION.V2_VB_DAYS_IN_COHORT');
CALL FNC.DROP_IF_EXISTS ('sailw0972v.V2_VB_MI_UTI_NOMICRO_ONLY');
CALL FNC.DROP_IF_EXISTS ('SAILW0972V.V2_VB_MI_SENS_NOMICRO_ONLY');
CALL FNC.DROP_IF_EXISTS ('sailw0972v.V2_VB_STROKE_UTI_NOMICRO_ONLY');
CALL FNC.DROP_IF_EXISTS ('SAILW0972V.V2_VB_STROKE_SENS_NOMICRO_ONLY');

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

--------------------------------------------------------------------------------------

/* identify where a UTI and Antibiotics readcode and no evidence of microbiological UTI occur within 7 days of each other */

--create table for the UTI sequences where the result was no microbiological evidence of UTI
--i.e. no confirmed or possible UTI results identified in the surrounding combined UTI sequence (less than 7 days between UTIs)
--mixed growth can occur within the wider UTI sequence as this does not indicate evidence of a UTI

CREATE TABLE sailw0972v.V2_VB_MI_UTI_NOMICRO_ONLY
AS (SELECT alf_pe,
			diag_dt,
			group_number
	FROM sailw0972v.V2_VB_MI_UTI_COMBINED)
WITH NO data;

INSERT INTO sailw0972v.V2_VB_MI_UTI_NOMICRO_ONLY
WITH cte AS --find highest outcome in a linked UTI sequence
(SELECT alf_pe, group_number, min(outcome_int) AS highest_outcome
	FROM sailw0972v.V2_VB_MI_UTI_COMBINED
GROUP BY alf_pe, group_number),
cte2 AS --find only those linked sequences with no microbiological evidence of UTI
(SELECT * FROM cte WHERE highest_outcome = 5),
cte3 AS -- minimum diagnosis date fo no micro evidence UTI
(SELECT cte.alf_pe,
		cte.group_number,
		min(u.diag_dt) AS diag_dt
		FROM cte
		INNER JOIN sailw0972v.V2_VB_MI_UTI_COMBINED AS u
			ON cte.alf_pe = u.alf_pe
			AND cte.group_number = u.group_number
		WHERE cte.highest_outcome = 5
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
		AND uti.outcome_int = cte2.highest_outcome
	INNER JOIN cte3
		ON uti.alf_pe = cte3.alf_pe
		AND uti.diag_dt = cte3.diag_dt
	WHERE uti.outcome_int = 5
ORDER BY cte2.alf_pe, cte3.diag_dt;

-------------------------------------------------------------

---create MI no evidence of UTI analysis table with start and end date of inclusion eligibility and week of birth----

CREATE TABLE SAILW0972V.V2_VB_MI_SENS_NOMICRO_ONLY AS (SELECT
		diag.ALF_PE,
		diag.DIAG_DT,
		dic.LATEST_START AS INC_START,
		dic.EARLIEST_END AS INC_END,
		yic.DOD,
		fe.WOB,
		fe.FIRST_EPI_STR_DT AS FIRST_EVENT_DT,
		fe.DIABETES
			FROM sailw0972v.V2_VB_MI_UTI_NOMICRO_ONLY AS diag,
				SESSION.V2_VB_DAYS_IN_COHORT AS dic,
				SAILW0972V.V2_VB_WDSD_AGE_IN_COHORT AS yic,
				SAILW0972V.V2_VB_PEDW_EPS_MI_FIRST_EVENT AS fe) WITH NO DATA;
					
INSERT INTO SAILW0972V.V2_VB_MI_SENS_NOMICRO_ONLY (
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
			FROM sailw0972v.V2_VB_MI_UTI_NOMICRO_ONLY AS diag
				LEFT JOIN SESSION.V2_VB_DAYS_IN_COHORT AS dic
					ON diag.ALF_PE = dic.ALF_PE
				LEFT JOIN SAILW0972V.V2_VB_WDSD_AGE_IN_COHORT AS yic
					ON diag.ALF_PE = yic.ALF_PE
				LEFT JOIN SAILW0972V.V2_VB_PEDW_EPS_MI_FIRST_EVENT AS fe
					ON diag.ALF_PE = fe.ALF_PE;
				
--MI add flag to indicate if individual's cohort eligibility ended due to death
				
ALTER TABLE SAILW0972V.V2_VB_MI_SENS_NOMICRO_ONLY
	ADD COLUMN INC_END_DEATH_FG INTEGER;

UPDATE SAILW0972V.V2_VB_MI_SENS_NOMICRO_ONLY
	SET INC_END_DEATH_FG = CASE WHEN DOD = INC_END THEN '1'
							ELSE '0'
						END;
					
--delete cases where UTI does not occur within first period of inclusion from MI table

DELETE FROM SAILW0972V.V2_VB_MI_SENS_NOMICRO_ONLY
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
			FROM SAILW0972V.V2_VB_MI_SENS_NOMICRO_ONLY) AS mqo
			WHERE rn > 1;
		
ALTER TABLE SAILW0972V.V2_VB_MI_SENS_NOMICRO_ONLY
	ADD COLUMN PREV_EVENT_FG VARCHAR(5);

MERGE INTO SAILW0972V.V2_VB_MI_SENS_NOMICRO_ONLY AS prim
	USING (SELECT ALF_PE, PREVIOUS_EVENT FROM SAILW0972V.V2_VB_PEDW_EPS_MI_FIRST_EVENT) AS coh
		ON prim.ALF_PE = coh.ALF_PE
			WHEN MATCHED THEN
				UPDATE
				SET prim.PREV_EVENT_FG = coh.PREVIOUS_EVENT
			;
		
--Amend diabetes and previous event flags to binary

UPDATE SAILW0972V.V2_VB_MI_SENS_NOMICRO_ONLY
	SET DIABETES = CASE WHEN DIABETES = FALSE THEN 0
						ELSE 1
					END;
				
UPDATE SAILW0972V.V2_VB_MI_SENS_NOMICRO_ONLY
	SET PREV_EVENT_FG = CASE WHEN PREV_EVENT_FG = FALSE THEN 0
						ELSE 1
					END;
	
------------------------------------------------------------------------------------------------------
--Stroke Cohort

--------------------------------------------------------------------------------------

/* identify where a UTI and Antibiotics readcode and no evidence of microbiological UTI occur within 7 days of each other */

--create table for the UTI sequences where the result was no microbiological evidence of UTI
--i.e. no confirmed or possible UTI results identified in the surrounding combined UTI sequence (less than 7 days between UTIs)
--mixed growth can occur within the wider UTI sequence as this does not indicate evidence of a UTI

CREATE TABLE sailw0972v.V2_VB_STROKE_UTI_NOMICRO_ONLY
AS (SELECT alf_pe,
			diag_dt,
			group_number
	FROM sailw0972v.V2_VB_STROKE_UTI_COMBINED)
WITH NO data;

INSERT INTO sailw0972v.V2_VB_STROKE_UTI_NOMICRO_ONLY
WITH cte AS --find highest outcome in a linked UTI sequence
(SELECT alf_pe, group_number, min(outcome_int) AS highest_outcome
	FROM sailw0972v.V2_VB_STROKE_UTI_COMBINED
GROUP BY alf_pe, group_number),
cte2 AS --find only those linked sequences with no microbiological evidence of UTI
(SELECT * FROM cte WHERE highest_outcome = 5),
cte3 AS -- minimum diagnosis date fo no micro evidence UTI
(SELECT cte.alf_pe,
		cte.group_number,
		min(u.diag_dt) AS diag_dt
		FROM cte
		INNER JOIN sailw0972v.V2_VB_STROKE_UTI_COMBINED AS u
			ON cte.alf_pe = u.alf_pe
			AND cte.group_number = u.group_number
		WHERE cte.highest_outcome = 5
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
		AND uti.outcome_int = cte2.highest_outcome
	INNER JOIN cte3
		ON uti.alf_pe = cte3.alf_pe
		AND uti.diag_dt = cte3.diag_dt
	WHERE uti.outcome_int = 5
ORDER BY cte2.alf_pe, cte3.diag_dt;

-------------------------------------------------------------

---create STROKE no evidence of UTI analysis table with start and end date of inclusion eligibility and week of birth----

CREATE TABLE SAILW0972V.V2_VB_STROKE_SENS_NOMICRO_ONLY AS (SELECT
		diag.ALF_PE,
		diag.DIAG_DT,
		dic.LATEST_START AS INC_START,
		dic.EARLIEST_END AS INC_END,
		yic.DOD,
		fe.WOB,
		fe.FIRST_EPI_STR_DT AS FIRST_EVENT_DT,
		fe.DIABETES
			FROM sailw0972v.V2_VB_STROKE_UTI_NOMICRO_ONLY AS diag,
				SESSION.V2_VB_DAYS_IN_COHORT AS dic,
				SAILW0972V.V2_VB_WDSD_AGE_IN_COHORT AS yic,
				SAILW0972V.V2_VB_PEDW_EPS_STROKE_FIRST_EVENT AS fe) WITH NO DATA;
					
INSERT INTO SAILW0972V.V2_VB_STROKE_SENS_NOMICRO_ONLY (
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
			FROM sailw0972v.V2_VB_STROKE_UTI_NOMICRO_ONLY AS diag
				LEFT JOIN SESSION.V2_VB_DAYS_IN_COHORT AS dic
					ON diag.ALF_PE = dic.ALF_PE
				LEFT JOIN SAILW0972V.V2_VB_WDSD_AGE_IN_COHORT AS yic
					ON diag.ALF_PE = yic.ALF_PE
				LEFT JOIN SAILW0972V.V2_VB_PEDW_EPS_STROKE_FIRST_EVENT AS fe
					ON diag.ALF_PE = fe.ALF_PE;
				
--STROKE add flag to indicate if individual's cohort eligibility ended due to death
				
ALTER TABLE SAILW0972V.V2_VB_STROKE_SENS_NOMICRO_ONLY
	ADD COLUMN INC_END_DEATH_FG INTEGER;

UPDATE SAILW0972V.V2_VB_STROKE_SENS_NOMICRO_ONLY
	SET INC_END_DEATH_FG = CASE WHEN DOD = INC_END THEN '1'
							ELSE '0'
						END;
					
--delete cases where UTI does not occur within first period of inclusion from STROKE table

DELETE FROM SAILW0972V.V2_VB_STROKE_SENS_NOMICRO_ONLY
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
			FROM SAILW0972V.V2_VB_STROKE_SENS_NOMICRO_ONLY) AS mqo
			WHERE rn > 1;
		
ALTER TABLE SAILW0972V.V2_VB_STROKE_SENS_NOMICRO_ONLY
	ADD COLUMN PREV_EVENT_FG VARCHAR(5);

MERGE INTO SAILW0972V.V2_VB_STROKE_SENS_NOMICRO_ONLY AS prim
	USING (SELECT ALF_PE, PREVIOUS_EVENT FROM SAILW0972V.V2_VB_PEDW_EPS_STROKE_FIRST_EVENT) AS coh
		ON prim.ALF_PE = coh.ALF_PE
			WHEN MATCHED THEN
				UPDATE
				SET prim.PREV_EVENT_FG = coh.PREVIOUS_EVENT
			;
		
--Amend diabetes and previous event flags to binary

UPDATE SAILW0972V.V2_VB_STROKE_SENS_NOMICRO_ONLY
	SET DIABETES = CASE WHEN DIABETES = FALSE THEN 0
						ELSE 1
					END;
				
UPDATE SAILW0972V.V2_VB_STROKE_SENS_NOMICRO_ONLY
	SET PREV_EVENT_FG = CASE WHEN PREV_EVENT_FG = FALSE THEN 0
						ELSE 1
					END;