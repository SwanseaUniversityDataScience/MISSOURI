--script to produce all UTIs and antibiotic prescriptions recorded in WRRS, WLGP and PEDW during the study period 2010-01-01 to 2020-12-31
--separate journey tables are produced for both the MI and stroke cohorts

CALL FNC.DROP_IF_EXISTS ('SAILW0972V.STROKE_UTI_JOURNEY');

CALL FNC.DROP_IF_EXISTS ('SAILW0972V.MI_UTI_JOURNEY');

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

/* identify where a UTI and Antibiotics readcode and confirmed microbiological UTI occur within 7 days of each other */

--Identifiy MI GP read UTIs

DECLARE GLOBAL TEMPORARY TABLE SESSION.V2_VB_MI_GP_UTI AS (
	SELECT	ALF_PE,
			ALF_STS_CD,
			EVENT_CD,
			EVENT_DT
		FROM SAIL0972V.WLGP_GP_EVENT_CLEANSED_20220301)
DEFINITION ONLY
ON COMMIT PRESERVE ROWS;

Commit;

INSERT INTO SESSION.V2_VB_MI_GP_UTI (
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

DECLARE GLOBAL TEMPORARY TABLE SESSION.V2_VB_MI_GP_ANTIBIOTIC 
			(ALF_PE VARCHAR(20),
			ALF_STS_CD INTEGER,
			EVENT_CD VARCHAR(5),
			EVENT_DT DATE)
ON COMMIT PRESERVE ROWS;

Commit;
		
INSERT INTO SESSION.V2_VB_MI_GP_ANTIBIOTIC (
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
		AND gp.EVENT_CD IN ('e31B.',
							'e319.',
							'e31a.',
							'e31d.',
							'e31R.',
							'e31i.',
							'e69e.',
							'eg68.',
							'e31v.',
							'e31u.',
							'egA3.',
							'eg17.',
							'eg16.',
							'eccb.',
							'egA1.',
							'ecc3.',
							'e3z5.',
							'e3z6.',
							'e3zo.',
							'e3zk.',
							'e3zm.',
							'e311.',
							'e3zu.',
							'e3zn.',
							'e312.',
							'e3zq.',
							'e315.',
							'e316.',
							'e31k.',
							'e31P.',
							'e31h.',
							'e31T.',
							'e31Y.',
							'e61C.',
							'e615.',
							'e614.',
							'e61D.',
							'e616.',
							'e61a.',
							'e618.',
							'e69..',
							'e695.',
							'e69v.',
							'e691.',
							'e693.',
							'e696.',
							'e69w.',
							'e692.',
							'e694.',
							'e697.',
							'e69f.',
							'e698.',
							'e69a.',
							'e69g.',
							'e699.',
							'e69b.',
							'e69h.',
							'eg6..',
							'eg67.',
							'eg6x.',
							'eg6w.',
							'eg69.',
							'eg6v.',
							'eg61.',
							'eg64.',
							'eg6A.',
							'eg65.',
							'e31Q.',
							'e31z.',
							'e31X.',
							'e612.',
							'e613.',
							'e617.',
							'e619.',
							'ebI..',
							'eg14.',
							'eg13.',
							'eg1C.',
							'eg1B.',
							'e69m.',
							'e69i.',
							'e69k.',
							'e69n.',
							'e69j.',
							'e69l.',
							'eg1A.',
							'eg1x.',
							'eg1..',
							'eg1z.',
							'eg1w.',
							'eg12.',
							'eg1y.',
							'eg11.',
							'e52w.',
							'e521.',
							'ecc..',
							'ecc1.',
							'ecc2.',
							'ecc4.')
		AND gp.EVENT_DT BETWEEN '2010-01-01' AND '2020-12-31';
	
Commit;

--identify MI WRRS confirmed UTIs

DECLARE GLOBAL TEMPORARY TABLE SESSION.V2_VB_MI_WRRS_CONFIRMED
	(ALF_PE VARCHAR(20),
	SPCM_COLLECTED_DT date,
	WRRS_MAX_DT date,
	WRRS_MIN_DT date,
	UTI_OUTCOME VARCHAR(50))
ON COMMIT PRESERVE ROWS;

COMMIT;

INSERT INTO SESSION.V2_VB_MI_WRRS_CONFIRMED
	SELECT 	wrrs.ALF_PE,
			wrrs.SPCM_COLLECTED_DT,
			ADD_DAYS(wrrs.SPCM_COLLECTED_DT, 6) AS WRRS_MAX_DT,
			ADD_DAYS(wrrs.SPCM_COLLECTED_DT, -6) AS WRRS_MIN_DT,
			wrrs.UTI_OUTCOME 
		FROM SAILW0972V.VB_MI_COHORT_WRRS_RESULTS_AGREED AS wrrs
			WHERE wrrs.UTI_OUTCOME = 'Confirmed UTI';
		
COMMIT;

----------------------------------------------------------------------------------------------------------------------------------------------------------
--identify people with a UTI from PEDW ICD-10 codes during study period
	
CALL FNC.DROP_IF_EXISTS('SESSION.VB_PEDW_DIAG_UTI');

DECLARE GLOBAL TEMPORARY TABLE SESSION.VB_PEDW_DIAG_UTI
	AS (SELECT * FROM SAIL0972V.PEDW_DIAG_20211101) DEFINITION ONLY
ON COMMIT PRESERVE ROWS;

Commit;

INSERT INTO SESSION.VB_PEDW_DIAG_UTI
	SELECT * FROM SAIL0972V.PEDW_DIAG_20211101 AS diag
		WHERE diag.DIAG_CD_1234 LIKE '%N10%'
		OR diag.DIAG_CD_1234 LIKE '%N12%'
		OR diag.DIAG_CD_1234 LIKE '%N300%'
		OR diag.DIAG_CD_1234 LIKE '%N308%'
		OR diag.DIAG_CD_1234 LIKE '%N309%'
		OR diag.DIAG_CD_1234 LIKE '%N390%';
	
Commit;

CALL FNC.DROP_IF_EXISTS('SESSION.VB_PEDW_EPS_UTI');

DECLARE GLOBAL TEMPORARY TABLE SESSION.VB_PEDW_EPS_UTI
	AS (SELECT	eps.PROV_UNIT_CD,
				eps.SPELL_NUM_PE,
				eps.EPI_NUM,
				diag.DIAG_CD_1234,
				diag.DIAG_NUM,
				eps.EPI_STR_DT,
				eps.EPI_END_DT,
				eps.EPI_DUR
			FROM SAIL0972V.PEDW_EPISODE_20211101 AS EPS,
				SAIL0972V.PEDW_DIAG_20211101 AS diag) DEFINITION ONLY
ON COMMIT PRESERVE ROWS;

Commit;

INSERT INTO SESSION.VB_PEDW_EPS_UTI
		(PROV_UNIT_CD,
		SPELL_NUM_PE,
		EPI_NUM,
		DIAG_CD_1234,
		DIAG_NUM,
		EPI_STR_DT,
		EPI_END_DT,
		EPI_DUR)
		SELECT	eps.PROV_UNIT_CD,
				eps.SPELL_NUM_PE,
				eps.EPI_NUM,
				diag.DIAG_CD_1234,
				diag.DIAG_NUM,
				eps.EPI_STR_DT,
				eps.EPI_END_DT,
				eps.EPI_DUR
			FROM SESSION.VB_PEDW_DIAG_UTI AS diag
				LEFT JOIN SAIL0972V.PEDW_EPISODE_20211101 AS eps
					ON diag.PROV_UNIT_CD = eps.PROV_UNIT_CD
					AND diag.SPELL_NUM_PE = eps.SPELL_NUM_PE
					AND diag.EPI_NUM = eps.EPI_NUM
		WHERE eps.EPI_STR_DT BETWEEN '2010-01-01' AND '2020-12-31';
	
Commit;

CALL FNC.DROP_IF_EXISTS('SESSION.VB_PEDW_UTI');

DECLARE GLOBAL TEMPORARY TABLE SESSION.VB_PEDW_UTI AS (SELECT
		sp.ALF_PE,
		sp.ALF_STS_CD,
		sp.PROV_UNIT_CD,
		sp.SPELL_NUM_PE,
		sp.GNDR_CD AS PEDW_GNDR_CD,
		sp.ADMIS_DT,
		sp.DISCH_DT,
		sp.SPELL_DUR,
		eps.EPI_NUM,
		eps.EPI_STR_DT AS EVENT_STR_DT,
		eps.EPI_END_DT AS EVENT_END_DT,
		eps.EPI_DUR AS EVENT_DUR,
		diag.DIAG_CD_1234,
		diag.DIAG_NUM
			FROM SAIL0972V.PEDW_SPELL_20211101 AS sp,
				SAIL0972V.PEDW_EPISODE_20211101 AS eps,
				SAIL0972V.PEDW_DIAG_20211101 AS diag) DEFINITION ONLY
ON COMMIT PRESERVE ROWS;
			
INSERT INTO SESSION.VB_PEDW_UTI
		(ALF_PE,
		ALF_STS_CD,
		PROV_UNIT_CD,
		SPELL_NUM_PE,
		PEDW_GNDR_CD,
		ADMIS_DT,
		DISCH_DT,
		SPELL_DUR,
		EPI_NUM,
		EVENT_STR_DT,
		EVENT_END_DT,
		EVENT_DUR,
		DIAG_CD_1234,
		DIAG_NUM)
	SELECT 	sp.ALF_PE,
			sp.ALF_STS_CD,
			sp.PROV_UNIT_CD,
			sp.SPELL_NUM_PE,
			sp.GNDR_CD,
			sp.ADMIS_DT,
			sp.DISCH_DT,
			sp.SPELL_DUR,
			eps.EPI_NUM,
			eps.EPI_STR_DT,
			eps.EPI_END_DT,
			eps.EPI_DUR,
			eps.DIAG_CD_1234,
			eps.DIAG_NUM
		FROM SAIL0972V.PEDW_SPELL_20211101 AS sp
			RIGHT JOIN SESSION.VB_PEDW_EPS_UTI AS eps
				ON sp.PROV_UNIT_CD = eps.PROV_UNIT_CD
				AND sp.SPELL_NUM_PE = eps.SPELL_NUM_PE;
			
COMMIT;

----------------------------------------------------------------------------------------------------------------------------------------------------------
--create table containing all events of interest for MI cohort from WLGP and WRRS and PEDW

CREATE TABLE SAILW0972V.MI_UTI_JOURNEY
(ALF_PE VARCHAR(20),
EVENT_DT DATE,
DATA_SOURCE VARCHAR(12),
OUTCOME_CODE VARCHAR(40));

INSERT INTO SAILW0972V.MI_UTI_JOURNEY
	SELECT ALF_PE,
			EVENT_DT,
			'UTI WLGP',
			EVENT_CD
		FROM SESSION.V2_VB_MI_GP_UTI;
	
INSERT INTO SAILW0972V.MI_UTI_JOURNEY
	SELECT ALF_PE,
			EVENT_DT,
			'ANTIBX WLGP',
			EVENT_CD
		FROM SESSION.V2_VB_MI_GP_ANTIBIOTIC;
	
INSERT INTO SAILW0972V.MI_UTI_JOURNEY
	SELECT DISTINCT ALF_PE,
			EVENT_STR_DT,
			'UTI_PEDW',
			DIAG_CD_1234
		FROM SESSION.VB_PEDW_UTI;
	
ALTER TABLE SAILW0972V.MI_UTI_JOURNEY
ADD COLUMN REPORT_SEQ INTEGER
ADD COLUMN REQUEST_SEQ INTEGER;
	
INSERT INTO SAILW0972V.MI_UTI_JOURNEY
	SELECT ALF_PE,
			SPCM_COLLECTED_DT,
			'WRRS',
			UTI_OUTCOME,
			REPORT_SEQ,
			REQUEST_SEQ
		FROM SAILW0972V.VB_MI_COHORT_WRRS_RESULTS_AGREED;
	
ALTER TABLE SAILW0972V.MI_UTI_JOURNEY
	ADD COLUMN WRRS INTEGER
	ADD COLUMN UTI_WLGP INTEGER
	ADD COLUMN UTI_PEDW INTEGER
	ADD COLUMN ANTIBX_WLGP INTEGER;

UPDATE SAILW0972V.MI_UTI_JOURNEY
	SET WRRS = CASE WHEN DATA_SOURCE = 'WRRS'
					THEN 1
					ELSE 0
				END;
			
UPDATE SAILW0972V.MI_UTI_JOURNEY
	SET UTI_WLGP = CASE WHEN DATA_SOURCE = 'UTI WLGP'
					THEN 1
					ELSE 0
				END;
			
UPDATE SAILW0972V.MI_UTI_JOURNEY
	SET UTI_PEDW = CASE WHEN DATA_SOURCE = 'UTI_PEDW'
					THEN 1
					ELSE 0
				END;
			
UPDATE SAILW0972V.MI_UTI_JOURNEY
	SET ANTIBX_WLGP = CASE WHEN DATA_SOURCE = 'ANTIBX WLGP'
					THEN 1
					ELSE 0
				END;

--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
--Stroke

CALL FNC.DROP_IF_EXISTS('SESSION.V2_VB_STROKE_GP_UTI');		
		
DECLARE GLOBAL TEMPORARY TABLE SESSION.V2_VB_STROKE_GP_UTI AS (
	SELECT	ALF_PE,
			ALF_STS_CD,
			EVENT_CD,
			EVENT_DT
		FROM SAIL0972V.WLGP_GP_EVENT_CLEANSED_20220301)
DEFINITION ONLY
ON COMMIT PRESERVE ROWS;

Commit;
	
INSERT INTO SESSION.V2_VB_STROKE_GP_UTI (
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

CALL FNC.DROP_IF_EXISTS('SESSION.V2_VB_STROKE_GP_ANTIBIOTIC');

DECLARE GLOBAL TEMPORARY TABLE SESSION.V2_VB_STROKE_GP_ANTIBIOTIC 
			(ALF_PE VARCHAR(20),
			ALF_STS_CD INTEGER,
			EVENT_CD VARCHAR(5),
			EVENT_DT DATE)
ON COMMIT PRESERVE ROWS;

Commit;
		
INSERT INTO SESSION.V2_VB_STROKE_GP_ANTIBIOTIC (
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
		AND gp.EVENT_CD IN ('e31B.',
							'e319.',
							'e31a.',
							'e31d.',
							'e31R.',
							'e31i.',
							'e69e.',
							'eg68.',
							'e31v.',
							'e31u.',
							'egA3.',
							'eg17.',
							'eg16.',
							'eccb.',
							'egA1.',
							'ecc3.',
							'e3z5.',
							'e3z6.',
							'e3zo.',
							'e3zk.',
							'e3zm.',
							'e311.',
							'e3zu.',
							'e3zn.',
							'e312.',
							'e3zq.',
							'e315.',
							'e316.',
							'e31k.',
							'e31P.',
							'e31h.',
							'e31T.',
							'e31Y.',
							'e61C.',
							'e615.',
							'e614.',
							'e61D.',
							'e616.',
							'e61a.',
							'e618.',
							'e69..',
							'e695.',
							'e69v.',
							'e691.',
							'e693.',
							'e696.',
							'e69w.',
							'e692.',
							'e694.',
							'e697.',
							'e69f.',
							'e698.',
							'e69a.',
							'e69g.',
							'e699.',
							'e69b.',
							'e69h.',
							'eg6..',
							'eg67.',
							'eg6x.',
							'eg6w.',
							'eg69.',
							'eg6v.',
							'eg61.',
							'eg64.',
							'eg6A.',
							'eg65.',
							'e31Q.',
							'e31z.',
							'e31X.',
							'e612.',
							'e613.',
							'e617.',
							'e619.',
							'ebI..',
							'eg14.',
							'eg13.',
							'eg1C.',
							'eg1B.',
							'e69m.',
							'e69i.',
							'e69k.',
							'e69n.',
							'e69j.',
							'e69l.',
							'eg1A.',
							'eg1x.',
							'eg1..',
							'eg1z.',
							'eg1w.',
							'eg12.',
							'eg1y.',
							'eg11.',
							'e52w.',
							'e521.',
							'ecc..',
							'ecc1.',
							'ecc2.',
							'ecc4.')
		AND gp.EVENT_DT BETWEEN '2010-01-01' AND '2020-12-31';
		
COMMIT;

--identify STROKE WRRS confirmed UTIs

CALL FNC.DROP_IF_EXISTS('SESSION.V2_VB_STROKE_WRRS_CONFIRMED');

DECLARE GLOBAL TEMPORARY TABLE SESSION.V2_VB_STROKE_WRRS_CONFIRMED
	(ALF_PE VARCHAR(20),
	SPCM_COLLECTED_DT date,
	WRRS_MAX_DT date,
	WRRS_MIN_DT date,
	UTI_OUTCOME VARCHAR(50))
ON COMMIT PRESERVE ROWS;

COMMIT;

INSERT INTO SESSION.V2_VB_STROKE_WRRS_CONFIRMED
	SELECT 	wrrs.ALF_PE,
			wrrs.SPCM_COLLECTED_DT,
			ADD_DAYS(wrrs.SPCM_COLLECTED_DT, 6) AS WRRS_MAX_DT,
			ADD_DAYS(wrrs.SPCM_COLLECTED_DT, -6) AS WRRS_MIN_DT,
			wrrs.UTI_OUTCOME 
		FROM SAILW0972V.VB_STROKE_COHORT_WRRS_RESULTS_AGREED AS wrrs
			WHERE wrrs.UTI_OUTCOME = 'Confirmed UTI';
		
COMMIT;


----------------------------------------------------------------------------------------------------------------------------------------------------------
--identify people with a UTI from PEDW ICD-10 codes during study period
	
CALL FNC.DROP_IF_EXISTS('SESSION.VB_PEDW_DIAG_UTI');

DECLARE GLOBAL TEMPORARY TABLE SESSION.VB_PEDW_DIAG_UTI
	AS (SELECT * FROM SAIL0972V.PEDW_DIAG_20211101) DEFINITION ONLY
ON COMMIT PRESERVE ROWS;

Commit;

INSERT INTO SESSION.VB_PEDW_DIAG_UTI
	SELECT * FROM SAIL0972V.PEDW_DIAG_20211101 AS diag
		WHERE diag.DIAG_CD_1234 LIKE '%N10%'
		OR diag.DIAG_CD_1234 LIKE '%N12%'
		OR diag.DIAG_CD_1234 LIKE '%N300%'
		OR diag.DIAG_CD_1234 LIKE '%N308%'
		OR diag.DIAG_CD_1234 LIKE '%N309%'
		OR diag.DIAG_CD_1234 LIKE '%N390%';
	
Commit;

CALL FNC.DROP_IF_EXISTS('SESSION.VB_PEDW_EPS_UTI');

DECLARE GLOBAL TEMPORARY TABLE SESSION.VB_PEDW_EPS_UTI
	AS (SELECT	eps.PROV_UNIT_CD,
				eps.SPELL_NUM_PE,
				eps.EPI_NUM,
				diag.DIAG_CD_1234,
				diag.DIAG_NUM,
				eps.EPI_STR_DT,
				eps.EPI_END_DT,
				eps.EPI_DUR
			FROM SAIL0972V.PEDW_EPISODE_20211101 AS EPS,
				SAIL0972V.PEDW_DIAG_20211101 AS diag) DEFINITION ONLY
ON COMMIT PRESERVE ROWS;

Commit;

INSERT INTO SESSION.VB_PEDW_EPS_UTI
		(PROV_UNIT_CD,
		SPELL_NUM_PE,
		EPI_NUM,
		DIAG_CD_1234,
		DIAG_NUM,
		EPI_STR_DT,
		EPI_END_DT,
		EPI_DUR)
		SELECT	eps.PROV_UNIT_CD,
				eps.SPELL_NUM_PE,
				eps.EPI_NUM,
				diag.DIAG_CD_1234,
				diag.DIAG_NUM,
				eps.EPI_STR_DT,
				eps.EPI_END_DT,
				eps.EPI_DUR
			FROM SESSION.VB_PEDW_DIAG_UTI AS diag
				LEFT JOIN SAIL0972V.PEDW_EPISODE_20211101 AS eps
					ON diag.PROV_UNIT_CD = eps.PROV_UNIT_CD
					AND diag.SPELL_NUM_PE = eps.SPELL_NUM_PE
					AND diag.EPI_NUM = eps.EPI_NUM
		WHERE eps.EPI_STR_DT BETWEEN '2010-01-01' AND '2020-12-31';
	
Commit;

CALL FNC.DROP_IF_EXISTS('SESSION.VB_PEDW_UTI');

DECLARE GLOBAL TEMPORARY TABLE SESSION.VB_PEDW_UTI AS (SELECT
		sp.ALF_PE,
		sp.ALF_STS_CD,
		sp.PROV_UNIT_CD,
		sp.SPELL_NUM_PE,
		sp.GNDR_CD AS PEDW_GNDR_CD,
		sp.ADMIS_DT,
		sp.DISCH_DT,
		sp.SPELL_DUR,
		eps.EPI_NUM,
		eps.EPI_STR_DT AS EVENT_STR_DT,
		eps.EPI_END_DT AS EVENT_END_DT,
		eps.EPI_DUR AS EVENT_DUR,
		diag.DIAG_CD_1234,
		diag.DIAG_NUM
			FROM SAIL0972V.PEDW_SPELL_20211101 AS sp,
				SAIL0972V.PEDW_EPISODE_20211101 AS eps,
				SAIL0972V.PEDW_DIAG_20211101 AS diag) DEFINITION ONLY
ON COMMIT PRESERVE ROWS;
			
INSERT INTO SESSION.VB_PEDW_UTI
		(ALF_PE,
		ALF_STS_CD,
		PROV_UNIT_CD,
		SPELL_NUM_PE,
		PEDW_GNDR_CD,
		ADMIS_DT,
		DISCH_DT,
		SPELL_DUR,
		EPI_NUM,
		EVENT_STR_DT,
		EVENT_END_DT,
		EVENT_DUR,
		DIAG_CD_1234,
		DIAG_NUM)
	SELECT 	sp.ALF_PE,
			sp.ALF_STS_CD,
			sp.PROV_UNIT_CD,
			sp.SPELL_NUM_PE,
			sp.GNDR_CD,
			sp.ADMIS_DT,
			sp.DISCH_DT,
			sp.SPELL_DUR,
			eps.EPI_NUM,
			eps.EPI_STR_DT,
			eps.EPI_END_DT,
			eps.EPI_DUR,
			eps.DIAG_CD_1234,
			eps.DIAG_NUM
		FROM SAIL0972V.PEDW_SPELL_20211101 AS sp
			RIGHT JOIN SESSION.VB_PEDW_EPS_UTI AS eps
				ON sp.PROV_UNIT_CD = eps.PROV_UNIT_CD
				AND sp.SPELL_NUM_PE = eps.SPELL_NUM_PE;
			
COMMIT;

---------------------------------------------------------------------------------------------------------------------
		
--create table containing all events of interest for stroke cohort from WLGP and WRRS and PEDW

CREATE TABLE SAILW0972V.STROKE_UTI_JOURNEY
(ALF_PE VARCHAR(20),
EVENT_DT DATE,
DATA_SOURCE VARCHAR(12),
OUTCOME_CODE VARCHAR(40));

INSERT INTO SAILW0972V.STROKE_UTI_JOURNEY
	SELECT ALF_PE,
			EVENT_DT,
			'UTI WLGP',
			EVENT_CD
		FROM SESSION.V2_VB_STROKE_GP_UTI;
	
INSERT INTO SAILW0972V.STROKE_UTI_JOURNEY
	SELECT ALF_PE,
			EVENT_DT,
			'ANTIBX WLGP',
			EVENT_CD
		FROM SESSION.V2_VB_STROKE_GP_ANTIBIOTIC;
	
INSERT INTO SAILW0972V.STROKE_UTI_JOURNEY
	SELECT DISTINCT ALF_PE,
			EVENT_STR_DT,
			'UTI_PEDW',
			DIAG_CD_1234
		FROM SESSION.VB_PEDW_UTI;
	
ALTER TABLE SAILW0972V.STROKE_UTI_JOURNEY
ADD COLUMN REPORT_SEQ INTEGER
ADD COLUMN REQUEST_SEQ INTEGER;
	
INSERT INTO SAILW0972V.STROKE_UTI_JOURNEY
	SELECT ALF_PE,
			SPCM_COLLECTED_DT,
			'WRRS',
			UTI_OUTCOME,
			REPORT_SEQ,
			REQUEST_SEQ
		FROM SAILW0972V.VB_STROKE_COHORT_WRRS_RESULTS_AGREED;
	
ALTER TABLE SAILW0972V.STROKE_UTI_JOURNEY
	ADD COLUMN WRRS INTEGER
	ADD COLUMN UTI_WLGP INTEGER
	ADD COLUMN UTI_PEDW INTEGER
	ADD COLUMN ANTIBX_WLGP INTEGER;

UPDATE SAILW0972V.STROKE_UTI_JOURNEY
	SET WRRS = CASE WHEN DATA_SOURCE = 'WRRS'
					THEN 1
					ELSE 0
				END;
			
UPDATE SAILW0972V.STROKE_UTI_JOURNEY
	SET UTI_WLGP = CASE WHEN DATA_SOURCE = 'UTI WLGP'
					THEN 1
					ELSE 0
				END;
			
UPDATE SAILW0972V.STROKE_UTI_JOURNEY
	SET UTI_PEDW = CASE WHEN DATA_SOURCE = 'UTI_PEDW'
					THEN 1
					ELSE 0
				END;
			
UPDATE SAILW0972V.STROKE_UTI_JOURNEY
	SET ANTIBX_WLGP = CASE WHEN DATA_SOURCE = 'ANTIBX WLGP'
					THEN 1
					ELSE 0
				END;