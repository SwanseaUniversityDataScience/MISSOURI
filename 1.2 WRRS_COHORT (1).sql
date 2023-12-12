/*no crossover found between the various culture test results so these have been combined into a single field
 * cross over between some weight of growth and culture values, where this occurs the weight of growth takes priority
no crossover found between Org_Organism and Org_organism1 and Organism_Organism so these have been combined into a single field.	
Organism2 was found to have crossover with organism1 so organism2 has been kept as a separate data field
no crossover was found between URBCR_Redbloodcellcount and URBC_Redbloodcells so these have been combined into a single field
no crossover was found between UWBCR_WhiteBloodCellCount, UWBC_WhiteBloodCells, UWBC_UrineWBC and UWBC_WBCS so these have been combined into a single field
no crossover was found between TRI and Trimethoprim so these have been combined into a single field
no crossover was found between NIT and Nitrofurantoin so these have been combined into a single field*/			

CALL FNC.DROP_IF_EXISTS ('SAILW0972V.VB_STROKE_COHORT_WRRS_REQUESTS');

CALL FNC.DROP_IF_EXISTS ('SAILW0972V.VB_STROKE_COHORT_WRRS_RESULTS');

CALL FNC.DROP_IF_EXISTS ('SAILW0972V.VB_STROKE_COHORT_WRRS_RESULTS_AGREED');

CALL FNC.DROP_IF_EXISTS ('SAILW0972V.VB_MI_COHORT_WRRS_REQUESTS');

CALL FNC.DROP_IF_EXISTS ('SAILW0972V.VB_MI_COHORT_WRRS_RESULTS');

CALL FNC.DROP_IF_EXISTS ('SAILW0972V.VB_MI_COHORT_WRRS_RESULTS_AGREED');

--STROKE COHORT UTI RESULTS TABLE

--summary TABLE OF stroke cohort results linked TO the request codes OF interest
--Create table linking stroke cohort to WRRS request table				

CREATE TABLE SAILW0972V.VB_STROKE_COHORT_WRRS_REQUESTS AS (
	SELECT	*
		FROM SAIL0972V.WRRS_OBSERVATION_REQUEST_20211019) WITH NO DATA;

INSERT INTO SAILW0972V.VB_STROKE_COHORT_WRRS_REQUESTS
	SELECT	req.*
		FROM SAIL0972V.WRRS_OBSERVATION_REQUEST_20211019 AS req
	RIGHT JOIN SAILW0972V.VB_PEDW_EPS_STROKE_FIRST_EVENT AS fe
		ON req.ALF_PE = fe.ALF_PE
		WHERE req.SPCM_COLLECTED_DT BETWEEN '2010-01-01' AND '2020-12-31'
		AND req.ALF_STS_CD IN ('1','4','39')
		AND req.NAME IN (	'Urine MC&S',				
							'Urine M+C+S',
							'Urine Microscopy',
							'Urine culture Mid-stream urine',
							'Mid Stream Urine',
							'Midstream Urine',
							'Urine  Urine Culture',
							'Urine M+C+S CMH',
							'Urine Mid-stream',
							'Urine culture Urine - TYPE NOT STATED',
							'Urine Culture',
							'Urine Micro. Cult. & Sens.',
							'Urine  Urine Culture 1',
							'Urine  Urine MCS',
							'Urine Mid Stream',
							'Urine microscopy.',
							'Urine',
							'Urine :',
							'Clean catch urine',
							'URINE',
							'Clean Catch Urine',
							'Urine  Urine Microscopy',
							'urine'
										)
						ORDER BY req.ALF_PE,
								req.SPCM_COLLECTED_DT,
								req.REQUEST_SEQ;
										
						
--Link WRRS requests to WRRS results, combining tests into agreed groups										
							
CREATE TABLE SAILW0972V.VB_STROKE_COHORT_WRRS_RESULTS
	(	ALF_PE VARCHAR(20),
		SPCM_COLLECTED_DT DATE,
		REPORT_SEQ INTEGER,
		REQUEST_SEQ INTEGER,
		REQUEST_NAME VARCHAR(50),
		CULTURE VARCHAR(50),
		WEIGHT_OF_GROWTH1 VARCHAR(50),
		WEIGHT_OF_GROWTH2 VARCHAR(50),
		WEIGHT_OF_GROWTH3 VARCHAR(50),
		ORGANISM VARCHAR(50),
		ORGANISM2 VARCHAR(50),
		ORGANISM3 VARCHAR(50),
		RED_BLOOD_CELL_COUNT VARCHAR(100),
		WHITE_BLOOD_CELL_COUNT VARCHAR(100),
		TRIMETHOPRIM VARCHAR(50),
		NITROFURANTOIN VARCHAR(50),
		GENTAMICIN VARCHAR(50),
		AMOXICILLIN VARCHAR(50),
		AMOXICILLIN_CLAVULANATE VARCHAR(50),
		CEPHALEXIN VARCHAR(50));
	
ALTER TABLE SAILW0972V.VB_STROKE_COHORT_WRRS_RESULTS activate NOT logged INITIALLY;
				
INSERT INTO SAILW0972V.VB_STROKE_COHORT_WRRS_RESULTS
	(	ALF_PE,
		SPCM_COLLECTED_DT,
		REPORT_SEQ,
		REQUEST_SEQ,
		REQUEST_NAME,
		CULTURE,
		WEIGHT_OF_GROWTH1,
		WEIGHT_OF_GROWTH2,
		WEIGHT_OF_GROWTH3,
		ORGANISM,
		ORGANISM2,
		ORGANISM3,
		RED_BLOOD_CELL_COUNT,
		WHITE_BLOOD_CELL_COUNT,
		TRIMETHOPRIM,
		NITROFURANTOIN,
		GENTAMICIN,
		AMOXICILLIN,
		AMOXICILLIN_CLAVULANATE,
		CEPHALEXIN)
SELECT	req.ALF_PE,
		req.SPCM_COLLECTED_DT,
		req.REPORT_SEQ,
		req.REQUEST_SEQ,
		req.NAME AS REQUEST_NAME,
		max(CASE WHEN res.CODE = 'Culture' THEN VAL 
				WHEN res.CODE = 'Urine Culture' THEN VAL 
				WHEN res.CODE = 'CULT' THEN VAL 
				WHEN res.CODE = 'UGR' THEN VAL END),
		max(CASE WHEN res.CODE = 'UVC' THEN VAL END),
		max(CASE WHEN res.CODE = 'UVC2' THEN VAL END),	
		max(CASE WHEN res.CODE = 'UVC3' THEN VAL END),	
		max(CASE WHEN res.CODE = 'ORGANISM' THEN VAL 
				WHEN res.CODE = 'ORG' THEN VAL END),
		max(CASE WHEN res.CODE = 'ORG2' THEN VAL END),
		max(CASE WHEN res.CODE = 'ORG3' THEN VAL END),
		max(CASE WHEN res.CODE = 'URBCR' THEN VAL 
				WHEN res.CODE = 'URBC' THEN VAL END),		
		max(CASE WHEN res.CODE = 'UWBCR' THEN VAL 
				WHEN res.CODE = 'UWBC' THEN VAL END),
		max(CASE WHEN res.CODE = 'TRI' THEN VAL 
				WHEN res.CODE = 'Trimethoprim' THEN VAL END),
		max(CASE WHEN res.CODE = 'NIT' THEN VAL 
				WHEN res.CODE = 'Nitrofurantoin' THEN VAL END),
		max(CASE WHEN res.CODE = 'GEN' THEN VAL END),
		max(CASE WHEN res.CODE = 'AMO' THEN VAL END),		
		max(CASE WHEN res.CODE = 'AUG' THEN VAL END),
		max(CASE WHEN res.CODE = 'CLX' THEN VAL END)
	FROM SAILW0972V.VB_STROKE_COHORT_WRRS_REQUESTS AS req
		INNER JOIN SAIL0972V.WRRS_OBSERVATION_RESULT_20211019 AS res
			ON req.ALF_PE = res.ALF_PE
			AND req.REQUEST_SEQ = res.REQUEST_SEQ
			AND req.REPORT_SEQ = res.REPORT_SEQ
			WHERE ((res.CODE LIKE 'TRI' AND res.NAME LIKE 'Trimethoprim')
			OR (res.CODE LIKE 'NIT' AND res.NAME LIKE 'Nitrofurantoin')
			OR (res.CODE LIKE 'ORG2' AND res.NAME LIKE 'Organism 2')
			OR (res.CODE LIKE 'ORG3' AND res.NAME LIKE 'Organism 3')
			OR (res.CODE LIKE 'Culture' AND res.NAME LIKE 'Culture')
			OR (res.CODE LIKE 'URBCR' AND res.NAME LIKE 'Red Blood Cell Count - Urine Range')
			OR (res.CODE LIKE 'GEN' AND res.NAME LIKE 'Gentamicin')
			OR (res.CODE LIKE 'AUG' AND res.NAME LIKE 'Amoxicillin/Clavulanate')
			OR (res.CODE LIKE 'Urine Culture' AND res.NAME LIKE 'Urine Culture')
			OR (res.CODE LIKE 'CULT' AND res.NAME LIKE 'Culture' AND res.VAL NOT LIKE ':')
			OR (res.CODE LIKE 'UWBCR' AND res.NAME LIKE 'White Blood Cell Count - Urine')
			OR (res.CODE LIKE 'CLX' AND res.NAME LIKE 'Cephalexin')
			OR (res.CODE LIKE 'Nitrofurantoin' AND res.NAME LIKE 'Nitrofurantoin')
			OR (res.CODE LIKE 'UVC' AND res.NAME LIKE 'Weight of Growth')
			OR (res.CODE LIKE 'UVC2' AND res.NAME LIKE 'Weight of Growth 2')
			OR (res.CODE LIKE 'UVC3' AND res.NAME LIKE 'Weight of Growth 3')
			OR (res.CODE LIKE 'ORG' AND res.NAME LIKE 'Organism 1')
			OR (res.CODE LIKE 'AMO' AND res.NAME LIKE 'Amoxicillin')
			OR (res.CODE LIKE 'Trimethoprim' AND res.NAME LIKE 'Trimethoprim')
			OR (res.CODE LIKE 'ORGANISM' AND res.NAME LIKE 'ORGANISM')
			OR (res.CODE LIKE 'URBC' AND res.NAME LIKE 'Red blood cells:')
			OR (res.CODE LIKE 'UWBC' AND res.NAME LIKE 'White blood cells:')
			OR (res.CODE LIKE 'UGR' AND res.NAME LIKE 'Viable count:')
			OR (res.CODE LIKE 'UWBC' AND res.NAME LIKE 'Urine WBC')
			OR (res.CODE LIKE 'ORG' AND res.NAME LIKE 'ORGANISM')
			OR (res.CODE LIKE 'UWBC' AND res.NAME LIKE 'Wbc''s'))
			GROUP BY	req.ALF_PE,
						req.SPCM_COLLECTED_DT,
						req.REPORT_SEQ,
						req.REQUEST_SEQ,
						req.NAME
				ORDER BY 	req.ALF_PE,
							req.SPCM_COLLECTED_DT,
							req.REQUEST_SEQ;
						
COMMIT;				

SELECT * FROM SAILW0972V.VB_STROKE_COHORT_WRRS_RESULTS
WHERE CULTURE IS NOT NULL AND (WEIGHT_OF_GROWTH1 IS NOT NULL OR WEIGHT_OF_GROWTH2 IS NOT NULL OR WEIGHT_OF_GROWTH3 IS NOT NULL);

SELECT * FROM SAILW0972V.VB_STROKE_COHORT_WRRS_RESULTS;

--Create WRRS Table with results grouped into agreed UTI result groupings				

CREATE TABLE SAILW0972V.VB_STROKE_COHORT_WRRS_RESULTS_AGREED 
(		ALF_PE VARCHAR(20),
		SPCM_COLLECTED_DT DATE,
		REPORT_SEQ INTEGER,
		REQUEST_SEQ INTEGER,
		REQUEST_NAME VARCHAR(50),
		CULTURE VARCHAR(50),
		CULTURE2 VARCHAR(50),
		CULTURE3 VARCHAR(50),
		ORGANISM VARCHAR(50),
		ORGANISM2 VARCHAR(50),
		ORGANISM3 VARCHAR(50),
		RED_BLOOD_CELL_COUNT VARCHAR(100),
		WHITE_BLOOD_CELL_COUNT VARCHAR(100),
		TRIMETHOPRIM VARCHAR(50),
		NITROFURANTOIN VARCHAR(50),
		GENTAMICIN VARCHAR(50),
		AMOXICILLIN VARCHAR(50),
		AMOXICILLIN_CLAVULANATE VARCHAR(50),
		CEPHALEXIN VARCHAR(50));

alter table SAILW0972V.VB_STROKE_COHORT_WRRS_RESULTS_AGREED activate not logged INITIALLY;

INSERT INTO SAILW0972V.VB_STROKE_COHORT_WRRS_RESULTS_AGREED 
	(ALF_PE,
	SPCM_COLLECTED_DT,
	REPORT_SEQ,
	REQUEST_SEQ,
	REQUEST_NAME,
	CULTURE,
	CULTURE2,
	CULTURE3,
	ORGANISM,
	ORGANISM2,
	ORGANISM3,
	RED_BLOOD_CELL_COUNT,
	WHITE_BLOOD_CELL_COUNT,
	TRIMETHOPRIM,
	NITROFURANTOIN,
	GENTAMICIN,
	AMOXICILLIN,
	AMOXICILLIN_CLAVULANATE,
	CEPHALEXIN)
	SELECT ALF_PE,
		SPCM_COLLECTED_DT,
		REPORT_SEQ,
		REQUEST_SEQ,
		REQUEST_NAME,
		(CASE WHEN (CULTURE = 'Predominant growth of' AND 
							(WEIGHT_OF_GROWTH1 = '10^7 - 10^8' OR WEIGHT_OF_GROWTH1 IS NULL))
					OR (CULTURE IS NULL AND WEIGHT_OF_GROWTH1 = '10^7 - 10^8') THEN 'growth'
			WHEN ((CULTURE IN ('>100,000 orgs/ml',
							'>100,000') AND
							(WEIGHT_OF_GROWTH1 = '>= 10^8' OR WEIGHT_OF_GROWTH1 IS NULL)))
					OR 	(CULTURE = 'Predominant growth of' AND WEIGHT_OF_GROWTH1 = '>= 10^8')
					OR (CULTURE IS NULL AND WEIGHT_OF_GROWTH1 = '>= 10^8') THEN 'growth>10^8'
			WHEN CULTURE IN ('Mixed growth',
							'Mixed growth <10^7 cfu/L',
							'Mixed growth 10^7 - 10^8 cfu/L',
							'Mixed growth including',
							'10,000 Mixed',
							'10,000 Mixed 10,000 Mixed',
							'10-100,000 MIXED',
							'10-100000 MIXED',
							'Mixed growth') AND
							(WEIGHT_OF_GROWTH1 = '10^7 - 10^8' OR WEIGHT_OF_GROWTH1 IS NULL)
					THEN 'mixed growth'
			WHEN CULTURE IN ('Heavy mixed growth.',
							'Mixed growth >=10^8 cfu/L',
							'>100,000 Mixed',
							'>100,000 Mixed >100,000 Mixed',
							'100,000 Mixed growth') AND
							(WEIGHT_OF_GROWTH1 = '>= 10^8' OR WEIGHT_OF_GROWTH1 IS NULL)
				OR 	(CULTURE IN ('Mixed growth',
								'Mixed growth including',
								'Mixed growth') AND 
							(WEIGHT_OF_GROWTH1 = '>= 10^8')) THEN 'mixed growth>10^8'
			WHEN (CULTURE IN ('Negative',
							'No growth',
							'No significant growth',
							'10000',
							'<10,000',
							'<10,000<10,000',
							'No Growth',
							'No GrowthNo Growth',
							'No Growth',
							'No GrowthNo Growth',
							'No significant growth.',
							'Yeasts NOT isolated',
							'No growth after 5 days incubation.',
							'Bacterial pathogens NOT isolated. Yeasts NOT isolated.') AND
							(WEIGHT_OF_GROWTH1 IN ('<10^5','>= 10^6','10^5-10^6','10^6-10^7') OR WEIGHT_OF_GROWTH1 IS NULL))
						OR (CULTURE IS NULL AND WEIGHT_OF_GROWTH1 IN ('<10^5','>= 10^6','10^5-10^6','10^6-10^7')) THEN 'no growth'
			ELSE 'N/A'
				END) AS CULTURE,
		(CASE WHEN (CULTURE = 'Predominant growth of' AND 
							(WEIGHT_OF_GROWTH2 = '10^7 - 10^8'))
					OR (CULTURE IS NULL AND WEIGHT_OF_GROWTH2 = '10^7 - 10^8') THEN 'growth'
			WHEN (CULTURE IN ('>100,000 orgs/ml',
							'>100,000',
							'Predominant growth of') AND
							(WEIGHT_OF_GROWTH2 = '>= 10^8'))
					OR (CULTURE IS NULL AND WEIGHT_OF_GROWTH2 = '>= 10^8') THEN 'growth>10^8'
			WHEN CULTURE IN ('Mixed growth',
							'Mixed growth <10^7 cfu/L',
							'Mixed growth 10^7 - 10^8 cfu/L',
							'Mixed growth including',
							'10,000 Mixed',
							'10,000 Mixed 10,000 Mixed',
							'10-100,000 MIXED',
							'10-100000 MIXED',
							'Mixed growth') AND
							(WEIGHT_OF_GROWTH2 = '10^7 - 10^8') THEN 'mixed growth'
			WHEN CULTURE IN ('Heavy mixed growth.',
							'Mixed growth >=10^8 cfu/L',
							'>100,000 Mixed',
							'>100,000 Mixed >100,000 Mixed',
							'100,000 Mixed growth',
							'Mixed growth',
							'Mixed growth including',
							'Mixed growth') AND
							(WEIGHT_OF_GROWTH2 = '>= 10^8')  THEN 'mixed growth>10^8'
			WHEN (CULTURE IN ('Negative',
							'No growth',
							'No significant growth',
							'10000',
							'<10,000',
							'<10,000<10,000',
							'No Growth',
							'No GrowthNo Growth',
							'No Growth',
							'No GrowthNo Growth',
							'No significant growth.',
							'Yeasts NOT isolated',
							'No growth after 5 days incubation.',
							'Bacterial pathogens NOT isolated. Yeasts NOT isolated.') AND
							(WEIGHT_OF_GROWTH2 IN ('<10^5','>= 10^6','10^5-10^6','10^6-10^7')))
				OR (CULTURE IS NULL AND WEIGHT_OF_GROWTH2 IN ('<10^5','>= 10^6','10^5-10^6','10^6-10^7')) THEN 'no growth'
			ELSE 'N/A'
				END) AS CULTURE2,
		(CASE WHEN (CULTURE = 'Predominant growth of' AND 
							(WEIGHT_OF_GROWTH3 = '10^7 - 10^8'))
				OR (CULTURE IS NULL AND WEIGHT_OF_GROWTH3 = '10^7 - 10^8') THEN 'growth'
			WHEN (CULTURE IN ('>100,000 orgs/ml',
							'>100,000',
							'Predominant growth of') AND
							(WEIGHT_OF_GROWTH3 = '>= 10^8') )
				OR (CULTURE IS NULL AND WEIGHT_OF_GROWTH3 = '>= 10^8') THEN 'growth>10^8'
			WHEN CULTURE IN ('Mixed growth',
							'Mixed growth <10^7 cfu/L',
							'Mixed growth 10^7 - 10^8 cfu/L',
							'Mixed growth including',
							'10,000 Mixed',
							'10,000 Mixed 10,000 Mixed',
							'10-100,000 MIXED',
							'10-100000 MIXED',
							'Mixed growth') AND
							(WEIGHT_OF_GROWTH3 = '10^7 - 10^8') THEN 'mixed growth'
			WHEN CULTURE IN ('Heavy mixed growth.',
							'Mixed growth >=10^8 cfu/L',
							'>100,000 Mixed',
							'>100,000 Mixed >100,000 Mixed',
							'100,000 Mixed growth',
							'Mixed growth',
							'Mixed growth including',
							'Mixed growth') AND
							(WEIGHT_OF_GROWTH3 = '>= 10^8') THEN 'mixed growth>10^8'
			WHEN (CULTURE IN ('Negative',
							'No growth',
							'No significant growth',
							'10000',
							'<10,000',
							'<10,000<10,000',
							'No Growth',
							'No GrowthNo Growth',
							'No Growth',
							'No GrowthNo Growth',
							'No significant growth.',
							'Yeasts NOT isolated',
							'No growth after 5 days incubation.',
							'Bacterial pathogens NOT isolated. Yeasts NOT isolated.') AND
							(WEIGHT_OF_GROWTH3 IN ('<10^5','>= 10^6','10^5-10^6','10^6-10^7')))
				OR (CULTURE IS NULL AND WEIGHT_OF_GROWTH3 IN ('<10^5','>= 10^6','10^5-10^6','10^6-10^7')) THEN 'no growth'
			ELSE 'N/A'
				END) AS CULTURE3,
		(CASE WHEN ORGANISM IN ('Candida albicans',
								'Candida species',
								'Candida albicans ({abbr})',
								'Candida sp ({abbr})',
								'Yeast ({abbr})',
								'Candida albicans',
								'Candida sp') THEN 'candida'
				WHEN ORGANISM IN ('Coliform',
								'Coliform - KESC group (KESC)',
								'Coliform ({abbr})',
								'Mixed coliforms ({abbr})',
								'Coliform bacilli') THEN 'coliform'
				WHEN ORGANISM IN ('Escherichia coli',
								'Escherichia coli ({abbr})',
								'Escherichia coli',
								'Escherichia coli (2)') THEN 'ecoli'
				WHEN ORGANISM IN ('Enterococcus species',
								'Enterococcus faecalis ({abbr})',
								'Enterococcus sp ({abbr})',
								'Enterococcus species') THEN 'enterococcus'
				WHEN ORGANISM IN ('Klebsiella pneumoniae',
								'Klebsiella pneumoniae ({abbr})',
								'Klebsiella pneumoniae') THEN 'klebsiella'
				WHEN ORGANISM IN ('No Growth.',
								'No significant growth') THEN 'no growth'
				WHEN ORGANISM IN ('Proteus species',
								'Proteus mirabilis ({abbr})',
								'Proteus sp ({abbr})') THEN 'proteus'
				WHEN ORGANISM IN ('Pseudomonas aeruginosa',
								'Pseudomonas species',
								'Pseudomonas aeruginosa ({abbr})',
								'Pseudomonas sp ({abbr})',
								'Pseudomonas aeruginosa') THEN 'pseudomonas'
				WHEN ORGANISM IN ('Staphylococcus aureus',
								'Staphylococcus aureus ({abbr})',
								'Staphylococcus aureus') THEN 'saureus'
				WHEN ORGANISM IN ('Staphylococcus coagulase negative ({abbr})',
								'Coag Negative Staphylococcus',
								'Staphylococcus Coagulase Negative') THEN 'staphcoagneg'
				WHEN ORGANISM IN ('Streptococcus agalactiae group B ({abbr})',
								'Streptococcus group A ({abbr})',
								'Streptococcus group B ({abbr})',
								'Beta-haemolytic Streptococcus') THEN 'strep'
			ELSE 'N/A'
				END) AS ORGANISM,
		(CASE WHEN ORGANISM2 IN ('Candida albicans ({abbr})',
								'Candida sp ({abbr})',
								'Yeast ({abbr})') THEN 'candida'
				WHEN ORGANISM2 IN ('Coliform - KESC group (KESC)',
									'Coliform ({abbr})',
									'Mixed coliforms ({abbr})') THEN 'coliform'
				WHEN ORGANISM2 = 'Escherichia coli ({abbr})' THEN 'ecoli'
				WHEN ORGANISM2 IN ('Enterococcus faecalis ({abbr})',
									'Enterococcus sp ({abbr})') THEN 'enterococcus'
				WHEN ORGANISM2 = 'Klebsiella pneumoniae ({abbr})' THEN 'klebsiella'
				WHEN ORGANISM2 IN ('Proteus mirabilis ({abbr})',
									'Proteus sp ({abbr})') THEN 'proteus'
				WHEN ORGANISM2 IN (	'Pseudomonas aeruginosa ({abbr})',
									'Pseudomonas sp ({abbr})') THEN 'pseudomonas'
				WHEN ORGANISM2 = 'Staphylococcus aureus ({abbr})' THEN 'saureus'
				WHEN ORGANISM2 = 'Staphylococcus coagulase negative ({abbr})' THEN 'staphcoagneg'
				WHEN ORGANISM2 IN (	'Streptococcus agalactiae group B ({abbr})',
									'Streptococcus group B ({abbr})') THEN 'strep'
			ELSE 'N/A'
				END) AS ORGANISM2,
		(CASE WHEN ORGANISM3 IN ('Candida albicans ({abbr})',
								'Candida sp ({abbr})',
								'Yeast ({abbr})') THEN 'candida'
				WHEN ORGANISM3 IN ('Coliform - KESC group (KESC)',
									'Coliform ({abbr})',
									'Mixed coliforms ({abbr})') THEN 'coliform'
				WHEN ORGANISM3 = 'Escherichia coli ({abbr})' THEN 'ecoli'
				WHEN ORGANISM3 IN ('Enterococcus faecalis ({abbr})',
									'Enterococcus sp ({abbr})') THEN 'enterococcus'
				WHEN ORGANISM3 = 'Klebsiella pneumoniae ({abbr})' THEN 'klebsiella'
				WHEN ORGANISM3 IN ('Proteus mirabilis ({abbr})',
									'Proteus sp ({abbr})') THEN 'proteus'
				WHEN ORGANISM3 IN (	'Pseudomonas aeruginosa ({abbr})',
									'Pseudomonas sp ({abbr})') THEN 'pseudomonas'
				WHEN ORGANISM3 = 'Staphylococcus aureus ({abbr})' THEN 'saureus'
				WHEN ORGANISM3 = 'Staphylococcus coagulase negative ({abbr})' THEN 'staphcoagneg'
				WHEN ORGANISM3 IN (	'Streptococcus agalactiae group B ({abbr})',
									'Streptococcus group B ({abbr})') THEN 'strep'
			ELSE 'N/A'
				END) AS ORGANISM3,
		(CASE WHEN RED_BLOOD_CELL_COUNT IN ('1',
														'2',
														'3',
														'4',
														'5',
														'6',
														'7',
														'8',
														'9',
														'10',
														'11',
														'12',
														'13',
														'14',
														'15',
														'16',
														'17',
														'18',
														'19',
														'20',
														'21',
														'22',
														'23',
														'24',
														'25',
														'26',
														'27',
														'28',
														'29',
														'30',
														'31',
														'32',
														'33',
														'34',
														'35',
														'36',
														'37',
														'38',
														'39',
														'40',
														'41',
														'42',
														'43',
														'44',
														'<1',
														'<5   x10^6/L',
														'5-99  x10^6/L') THEN '<100'
				WHEN RED_BLOOD_CELL_COUNT = '>=100 x10^6/L' THEN '>100'
			ELSE 'N/A'
				END) AS RED_BLOOD_CELL_COUNT,
			(CASE WHEN WHITE_BLOOD_CELL_COUNT IN ('Greater than 20 White Blood Cells per cubic millimetre',
														'Less than 10 White Blood Cells per cubic millimetre',
														'<10   x10^6/L',
														'10-99 x10^6/L') THEN '<10^8'
				WHEN WHITE_BLOOD_CELL_COUNT = '>=100 x10^6/L' THEN '>10^8'
			ELSE 'N/A'
				END) AS WHITE_BLOOD_CELL_COUNT,
	TRIMETHOPRIM,
	NITROFURANTOIN,
	GENTAMICIN,
	AMOXICILLIN,
	AMOXICILLIN_CLAVULANATE,
	CEPHALEXIN
		FROM SAILW0972V.VB_STROKE_COHORT_WRRS_RESULTS;
	
COMMIT;

ALTER TABLE SAILW0972V.VB_STROKE_COHORT_WRRS_RESULTS_AGREED
	ADD COLUMN ORGANISM_COUNT VARCHAR(10);

UPDATE SAILW0972V.VB_STROKE_COHORT_WRRS_RESULTS_AGREED
	SET ORGANISM_COUNT = CASE WHEN (CULTURE <> 'N/A'-----------------------------CULTURE has values not candida
									AND ORGANISM <> 'N/A'
									AND ORGANISM <> 'candida')
									AND ((CULTURE2 <> 'N/A' ----------------------CULTURE2 has values not candida
										AND ORGANISM2 <> 'N/A'
										AND ORGANISM2 <> 'candida'
										AND CULTURE3 = 'N/A'----------------------CULTURE3 does not have values
										AND (ORGANISM3 = 'N/A'
										OR ORGANISM3 = 'candida'))
										OR (CULTURE3 <> 'N/A'
										AND ORGANISM3 <> 'N/A'
										AND ORGANISM3 <> 'candida'
										AND CULTURE2 = 'N/A'
										AND (ORGANISM2 = 'N/A'
										OR ORGANISM2 = 'candida')))
								THEN '2 Orgs'
							WHEN  (CULTURE2 <> 'N/A'-----------------------------CULTURE2 has values
									AND ORGANISM2 <> 'N/A'
									AND ORGANISM2 <> 'candida')
									AND ((CULTURE3 <> 'N/A' ----------------------CULTURE3 has values not candida
										AND ORGANISM3 <> 'N/A'
										AND ORGANISM3 <> 'candida'
										AND CULTURE = 'N/A'----------------------CULTURE does not have values 
										AND (ORGANISM = 'N/A'
										OR ORGANISM = 'candida'))
										OR (CULTURE <> 'N/A'
										AND ORGANISM <> 'N/A'
										AND ORGANISM <> 'candida'
										AND CULTURE3 = 'N/A'
										AND (ORGANISM3 = 'N/A'
										OR ORGANISM3 = 'candida')))
								THEN '2 Orgs'
							WHEN ((CULTURE <> 'N/A' -----------------------------When all organism and culture fields have a value but more than one organism value is candida
								AND ORGANISM <> 'N/A'
								AND CULTURE2 <> 'N/A'
								AND ORGANISM2 <> 'N/A'
								AND CULTURE3 <> 'N/A'
								AND ORGANISM3 <> 'N/A')
									AND ((ORGANISM = 'candida'
										AND ORGANISM2 = 'candida')
									OR (ORGANISM = 'candida'
										AND ORGANISM3 = 'candida')
									OR (ORGANISM2 = 'candida'
										AND ORGANISM3 = 'candida')))
								THEN NULL
							WHEN ((CULTURE <> 'N/A' -----------------------------When all organism and culture fields have a value and one or none is candida
								AND ORGANISM <> 'N/A'
								AND CULTURE2 <> 'N/A'
								AND ORGANISM2 <> 'N/A'
								AND CULTURE3 <> 'N/A'
								AND ORGANISM3 <> 'N/A')
									AND (ORGANISM = 'candida'
									OR ORGANISM = 'candida'
									OR ORGANISM2 = 'candida'))
								THEN '2 Orgs'
						END;	
					
ALTER TABLE SAILW0972V.VB_STROKE_COHORT_WRRS_RESULTS_AGREED
	ADD COLUMN UTI_OUTCOME VARCHAR(50);
					
UPDATE SAILW0972V.VB_STROKE_COHORT_WRRS_RESULTS_AGREED
	SET UTI_OUTCOME = CASE WHEN (CULTURE = 'no growth' -------------------No Growth. When one culture value is no growth and all others are no growth or N/A
								AND (CULTURE2 = 'no growth'
									OR CULTURE2 = 'N/A')
								AND (CULTURE3 = 'no growth'
									OR CULTURE3 = 'N/A'))
							OR (CULTURE2 = 'no growth'
								AND (CULTURE3 = 'no growth'
									OR CULTURE3 = 'N/A')
								AND (CULTURE = 'no growth'
									OR CULTURE = 'N/A'))
							OR (CULTURE3 = 'no growth'
								AND (CULTURE = 'no growth'
									OR CULTURE = 'N/A')
								AND (CULTURE2 = 'no growth'
									OR CULTURE2 = 'N/A'))
						THEN 'No microbiological evidence of UTI'
					WHEN ((CULTURE = 'mixed growth>10^8' ----------------Heavy Mixed Growth (not candida)
								OR CULTURE2 = 'mixed growth>10^8'
								OR CULTURE3 = 'mixed growth>10^8')
							AND (ORGANISM <> 'candida'
								OR ORGANISM <> 'N/A')
							AND (ORGANISM2 <> 'candida'
								OR ORGANISM2 <> 'N/A')
							AND (ORGANISM3 <> 'candida'
								OR ORGANISM3 <> 'N/A'))
						THEN 'Heavy mixed growth'
					WHEN (ORGANISM <> 'N/A'
							AND ORGANISM <> 'candida'----------------Heavy Mixed Growth based on 3 organisms (not candida)
							AND CULTURE <> 'N/A'
							AND ORGANISM2 <> 'N/A'
							AND ORGANISM2 <> 'candida'
							AND CULTURE2 <> 'N/A'
							AND ORGANISM3 <> 'N/A'
							AND ORGANISM3 <> 'candida'
							AND CULTURE3 <> 'N/A')
						AND (CULTURE = 'growth>10^8'
							OR CULTURE2 = 'growth>10^8'
							OR CULTURE3 = 'growth>10^8')
						THEN 'Heavy mixed growth'
					WHEN ((CULTURE = 'mixed growth' ----------------Mixed Growth (not candida)
								OR CULTURE2 = 'mixed growth'
								OR CULTURE3 = 'mixed growth')
							AND (ORGANISM <> 'candida'
								OR ORGANISM <> 'N/A')
							AND (ORGANISM2 <> 'candida'
								OR ORGANISM2 <> 'N/A')
							AND (ORGANISM3 <> 'candida'
								OR ORGANISM3 <> 'N/A'))
						THEN 'Mixed growth'
					WHEN (ORGANISM <> 'N/A'
							AND ORGANISM <> 'candida'----------------Mixed Growth based on 3 organisms (not candida)
							AND CULTURE <> 'N/A'
							AND ORGANISM2 <> 'N/A'
							AND ORGANISM2 <> 'candida'
							AND CULTURE2 <> 'N/A'
							AND ORGANISM3 <> 'N/A'
							AND ORGANISM3 <> 'candida'
							AND CULTURE3 <> 'N/A')
						AND (CULTURE = 'growth'
							OR CULTURE2 = 'growth'
							OR CULTURE3 = 'growth')
						THEN 'Mixed growth'
					WHEN ((CULTURE = 'growth>10^8' ---------------Confirmed UTI, Organism not candida, growth >10^8 and WBC >10^8
								AND ORGANISM <> 'N/A'
								AND ORGANISM <> 'candida')
							OR (CULTURE2 = 'growth>10^8'
								AND ORGANISM2 <> 'N/A'
								AND ORGANISM2 <> 'candida')
							OR (CULTURE3 = 'growth>10^8'
								AND ORGANISM3 <> 'N/A'
								AND ORGANISM3 <> 'candida'))
							AND WHITE_BLOOD_CELL_COUNT = '>10^8'
						THEN 'Confirmed UTI'
					WHEN ((CULTURE = 'growth' ---------------Possible UTI, Organism not candida, growth >10^7
								AND ORGANISM <> 'N/A'
								AND ORGANISM <> 'candida')
							OR (CULTURE2 = 'growth'
								AND ORGANISM2 <> 'N/A'
								AND ORGANISM2 <> 'candida')
							OR (CULTURE3 = 'growth'
								AND ORGANISM3 <> 'N/A'
								AND ORGANISM3 <> 'candida'))
						THEN 'Possible UTI'
					WHEN ((CULTURE = 'growth>10^8' ---------------Possible UTI, Growth>10^8 WBC <10^8 or WBC NULL
								AND ORGANISM <> 'N/A'
								AND ORGANISM <> 'candida')
							OR (CULTURE2 = 'growth>10^8'
								AND ORGANISM2 <> 'N/A'
								AND ORGANISM2 <> 'candida')
							OR (CULTURE3 = 'growth>10^8'
								AND ORGANISM3 <> 'N/A'
								AND ORGANISM3 <> 'candida'))
							AND (WHITE_BLOOD_CELL_COUNT = '<10^8'
								OR WHITE_BLOOD_CELL_COUNT = 'N/A')
						THEN 'Possible UTI'
					WHEN ((CULTURE = 'growth' ---------------Possible UTI, Growth WBC <10^8 or WBC NULL
								AND ORGANISM <> 'N/A'
								AND ORGANISM <> 'candida')
							OR (CULTURE2 = 'growth'
								AND ORGANISM2 <> 'N/A'
								AND ORGANISM2 <> 'candida')
							OR (CULTURE3 = 'growth'
								AND ORGANISM3 <> 'N/A'
								AND ORGANISM3 <> 'candida'))
							AND (WHITE_BLOOD_CELL_COUNT = '<10^8'
								OR WHITE_BLOOD_CELL_COUNT = 'N/A')
						THEN 'Possible UTI'
					WHEN (CULTURE = 'N/A' --------------------All culture NULL
								AND CULTURE2 = 'N/A'
								AND CULTURE3 = 'N/A')
						THEN 'Exclude NULL culture'
					WHEN (ORGANISM = 'N/A' -----------------------All organism NULL
								AND ORGANISM2 = 'N/A'
								AND ORGANISM3 = 'N/A')
						THEN 'Possible UTI'
					WHEN (ORGANISM = 'candida' -------------------Any organism candida
							AND (ORGANISM2 = 'N/A'
							OR ORGANISM2 = 'candida')
							AND (ORGANISM3 = 'N/A'
							OR ORGANISM3 = 'candida')
								OR (ORGANISM2 = 'candida'
									AND (ORGANISM = 'N/A'
									OR ORGANISM = 'candida')
									AND (ORGANISM3 = 'N/A'
									OR ORGANISM3 = 'candida'))
								OR (ORGANISM3 = 'candida'
									AND (ORGANISM = 'N/A'
									OR ORGANISM = 'candida')
									AND (ORGANISM2 = 'N/A'
									OR ORGANISM2 = 'candida')))
						THEN 'No microbiological evidence of UTI'
					WHEN (((CULTURE = 'growth'
							OR CULTURE = 'growth>10^8')
							AND ORGANISM <> 'candida')
						OR ((CULTURE2 = 'growth'
							OR CULTURE2 = 'growth>10^8')
							AND ORGANISM2 <> 'candida')
						OR ((CULTURE3 = 'growth'
							OR CULTURE3 = 'growth>10^8')
							AND ORGANISM3 <> 'candida'))
						THEN 'Possible UTI'
					ELSE 'No microbiological evidence of UTI'
				END;
			
ALTER TABLE SAILW0972V.VB_STROKE_COHORT_WRRS_RESULTS_AGREED
	ADD COLUMN DIAG_ORGANISM VARCHAR(20);

UPDATE SAILW0972V.VB_STROKE_COHORT_WRRS_RESULTS_AGREED
	SET DIAG_ORGANISM = CASE WHEN ORGANISM_COUNT IS NULL
							AND (UTI_OUTCOME = 'Possible UTI'
								OR UTI_OUTCOME = 'Confirmed UTI')
							THEN CASE WHEN ORGANISM <> 'N/A'
										AND ORGANISM <> 'candida'
										AND CULTURE <> 'N/A'
										THEN ORGANISM
									WHEN ORGANISM2 <> 'N/A'
										AND ORGANISM2 <> 'candida'
										AND CULTURE2 <> 'N/A'
										THEN ORGANISM2
									ELSE ORGANISM3
								END
							WHEN ORGANISM_COUNT IS NOT NULL
								AND (UTI_OUTCOME = 'Possible UTI'
								OR UTI_OUTCOME = 'Confirmed UTI')
								THEN CASE WHEN ORGANISM = ORGANISM2
										AND ORGANISM3 = 'N/A'
										THEN ORGANISM
									WHEN ORGANISM2 = ORGANISM3
										AND ORGANISM = 'N/A'
										THEN ORGANISM2
									WHEN ORGANISM = ORGANISM3
										AND ORGANISM2 = 'N/A'
										THEN ORGANISM
								ELSE '>1 Organism'
							END
						END;
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
					
--MI COHORT UTI RESULTS TABLE

--summary TABLE OF MI cohort results linked TO the request codes OF interest
--Create table linking MI cohort to WRRS request table	
						
CALL FNC.DROP_IF_EXISTS ('SAILW0972V.VB_MI_COHORT_WRRS_REQUESTS');

CALL FNC.DROP_IF_EXISTS ('SAILW0972V.VB_MI_COHORT_WRRS_RESULTS');

CALL FNC.DROP_IF_EXISTS ('SAILW0972V.VB_MI_COHORT_WRRS_RESULTS_AGREED');

CALL FNC.DROP_IF_EXISTS ('SAILW0972V.VB_MI_COHORT_WRRS_REQUESTS');

CALL FNC.DROP_IF_EXISTS ('SAILW0972V.VB_MI_COHORT_WRRS_RESULTS');

CALL FNC.DROP_IF_EXISTS ('SAILW0972V.VB_MI_COHORT_WRRS_RESULTS_AGREED');

--MI COHORT UTI RESULTS TABLE

--summary TABLE OF MI cohort results linked TO the request codes OF interest
--Create table linking MI cohort to WRRS request table				
						
CREATE TABLE SAILW0972V.VB_MI_COHORT_WRRS_REQUESTS AS (
	SELECT	*
		FROM SAIL0972V.WRRS_OBSERVATION_REQUEST_20211019) WITH NO DATA;

INSERT INTO SAILW0972V.VB_MI_COHORT_WRRS_REQUESTS
	SELECT	req.*
		FROM SAIL0972V.WRRS_OBSERVATION_REQUEST_20211019 AS req
	RIGHT JOIN SAILW0972V.VB_PEDW_EPS_MI_FIRST_EVENT AS fe
		ON req.ALF_PE = fe.ALF_PE
		WHERE req.SPCM_COLLECTED_DT BETWEEN '2010-01-01' AND '2020-12-31'
		AND req.ALF_STS_CD IN ('1','4','39')
		AND req.NAME IN (	'Urine MC&S',				
							'Urine M+C+S',
							'Urine Microscopy',
							'Urine culture Mid-stream urine',
							'Mid Stream Urine',
							'Midstream Urine',
							'Urine  Urine Culture',
							'Urine M+C+S CMH',
							'Urine Mid-stream',
							'Urine culture Urine - TYPE NOT STATED',
							'Urine Culture',
							'Urine Micro. Cult. & Sens.',
							'Urine  Urine Culture 1',
							'Urine  Urine MCS',
							'Urine Mid Stream',
							'Urine microscopy.',
							'Urine',
							'Urine :',
							'Clean catch urine',
							'URINE',
							'Clean Catch Urine',
							'Urine  Urine Microscopy',
							'urine'
										)
						ORDER BY req.ALF_PE,
								req.SPCM_COLLECTED_DT,
								req.REQUEST_SEQ;
										
						
--Link WRRS requests to WRRS results, combining tests into agreed groups										
							
CREATE TABLE SAILW0972V.VB_MI_COHORT_WRRS_RESULTS
	(	ALF_PE VARCHAR(20),
		SPCM_COLLECTED_DT DATE,
		REPORT_SEQ INTEGER,
		REQUEST_SEQ INTEGER,
		REQUEST_NAME VARCHAR(50),
		CULTURE VARCHAR(50),
		WEIGHT_OF_GROWTH1 VARCHAR(50),
		WEIGHT_OF_GROWTH2 VARCHAR(50),
		WEIGHT_OF_GROWTH3 VARCHAR(50),
		ORGANISM VARCHAR(50),
		ORGANISM2 VARCHAR(50),
		ORGANISM3 VARCHAR(50),
		RED_BLOOD_CELL_COUNT VARCHAR(100),
		WHITE_BLOOD_CELL_COUNT VARCHAR(100),
		TRIMETHOPRIM VARCHAR(50),
		NITROFURANTOIN VARCHAR(50),
		GENTAMICIN VARCHAR(50),
		AMOXICILLIN VARCHAR(50),
		AMOXICILLIN_CLAVULANATE VARCHAR(50),
		CEPHALEXIN VARCHAR(50));
	
ALTER TABLE SAILW0972V.VB_MI_COHORT_WRRS_RESULTS activate NOT logged INITIALLY;
				
INSERT INTO SAILW0972V.VB_MI_COHORT_WRRS_RESULTS
	(	ALF_PE,
		SPCM_COLLECTED_DT,
		REPORT_SEQ,
		REQUEST_SEQ,
		REQUEST_NAME,
		CULTURE,
		WEIGHT_OF_GROWTH1,
		WEIGHT_OF_GROWTH2,
		WEIGHT_OF_GROWTH3,
		ORGANISM,
		ORGANISM2,
		ORGANISM3,
		RED_BLOOD_CELL_COUNT,
		WHITE_BLOOD_CELL_COUNT,
		TRIMETHOPRIM,
		NITROFURANTOIN,
		GENTAMICIN,
		AMOXICILLIN,
		AMOXICILLIN_CLAVULANATE,
		CEPHALEXIN)
SELECT	req.ALF_PE,
		req.SPCM_COLLECTED_DT,
		req.REPORT_SEQ,
		req.REQUEST_SEQ,
		req.NAME AS REQUEST_NAME,
		max(CASE WHEN res.CODE = 'Culture' THEN VAL 
				WHEN res.CODE = 'Urine Culture' THEN VAL 
				WHEN res.CODE = 'CULT' THEN VAL 
				WHEN res.CODE = 'UGR' THEN VAL END),
		max(CASE WHEN res.CODE = 'UVC' THEN VAL END),
		max(CASE WHEN res.CODE = 'UVC2' THEN VAL END),	
		max(CASE WHEN res.CODE = 'UVC3' THEN VAL END),	
		max(CASE WHEN res.CODE = 'ORGANISM' THEN VAL 
				WHEN res.CODE = 'ORG' THEN VAL END),
		max(CASE WHEN res.CODE = 'ORG2' THEN VAL END),
		max(CASE WHEN res.CODE = 'ORG3' THEN VAL END),
		max(CASE WHEN res.CODE = 'URBCR' THEN VAL 
				WHEN res.CODE = 'URBC' THEN VAL END),		
		max(CASE WHEN res.CODE = 'UWBCR' THEN VAL 
				WHEN res.CODE = 'UWBC' THEN VAL END),
		max(CASE WHEN res.CODE = 'TRI' THEN VAL 
				WHEN res.CODE = 'Trimethoprim' THEN VAL END),
		max(CASE WHEN res.CODE = 'NIT' THEN VAL 
				WHEN res.CODE = 'Nitrofurantoin' THEN VAL END),
		max(CASE WHEN res.CODE = 'GEN' THEN VAL END),
		max(CASE WHEN res.CODE = 'AMO' THEN VAL END),		
		max(CASE WHEN res.CODE = 'AUG' THEN VAL END),
		max(CASE WHEN res.CODE = 'CLX' THEN VAL END)
	FROM SAILW0972V.VB_MI_COHORT_WRRS_REQUESTS AS req
		INNER JOIN SAIL0972V.WRRS_OBSERVATION_RESULT_20211019 AS res
			ON req.ALF_PE = res.ALF_PE
			AND req.REQUEST_SEQ = res.REQUEST_SEQ
			AND req.REPORT_SEQ = res.REPORT_SEQ
			WHERE ((res.CODE LIKE 'TRI' AND res.NAME LIKE 'Trimethoprim')
			OR (res.CODE LIKE 'NIT' AND res.NAME LIKE 'Nitrofurantoin')
			OR (res.CODE LIKE 'ORG2' AND res.NAME LIKE 'Organism 2')
			OR (res.CODE LIKE 'ORG3' AND res.NAME LIKE 'Organism 3')
			OR (res.CODE LIKE 'Culture' AND res.NAME LIKE 'Culture')
			OR (res.CODE LIKE 'URBCR' AND res.NAME LIKE 'Red Blood Cell Count - Urine Range')
			OR (res.CODE LIKE 'GEN' AND res.NAME LIKE 'Gentamicin')
			OR (res.CODE LIKE 'AUG' AND res.NAME LIKE 'Amoxicillin/Clavulanate')
			OR (res.CODE LIKE 'Urine Culture' AND res.NAME LIKE 'Urine Culture')
			OR (res.CODE LIKE 'CULT' AND res.NAME LIKE 'Culture' AND res.VAL NOT LIKE ':')
			OR (res.CODE LIKE 'UWBCR' AND res.NAME LIKE 'White Blood Cell Count - Urine')
			OR (res.CODE LIKE 'CLX' AND res.NAME LIKE 'Cephalexin')
			OR (res.CODE LIKE 'Nitrofurantoin' AND res.NAME LIKE 'Nitrofurantoin')
			OR (res.CODE LIKE 'UVC' AND res.NAME LIKE 'Weight of Growth')
			OR (res.CODE LIKE 'UVC2' AND res.NAME LIKE 'Weight of Growth 2')
			OR (res.CODE LIKE 'UVC3' AND res.NAME LIKE 'Weight of Growth 3')
			OR (res.CODE LIKE 'ORG' AND res.NAME LIKE 'Organism 1')
			OR (res.CODE LIKE 'AMO' AND res.NAME LIKE 'Amoxicillin')
			OR (res.CODE LIKE 'Trimethoprim' AND res.NAME LIKE 'Trimethoprim')
			OR (res.CODE LIKE 'ORGANISM' AND res.NAME LIKE 'ORGANISM')
			OR (res.CODE LIKE 'URBC' AND res.NAME LIKE 'Red blood cells:')
			OR (res.CODE LIKE 'UWBC' AND res.NAME LIKE 'White blood cells:')
			OR (res.CODE LIKE 'UGR' AND res.NAME LIKE 'Viable count:')
			OR (res.CODE LIKE 'UWBC' AND res.NAME LIKE 'Urine WBC')
			OR (res.CODE LIKE 'ORG' AND res.NAME LIKE 'ORGANISM')
			OR (res.CODE LIKE 'UWBC' AND res.NAME LIKE 'Wbc''s'))
			GROUP BY	req.ALF_PE,
						req.SPCM_COLLECTED_DT,
						req.REPORT_SEQ,
						req.REQUEST_SEQ,
						req.NAME
				ORDER BY 	req.ALF_PE,
							req.SPCM_COLLECTED_DT,
							req.REQUEST_SEQ;
						
COMMIT;				

SELECT * FROM SAILW0972V.VB_MI_COHORT_WRRS_RESULTS
WHERE CULTURE IS NOT NULL AND (WEIGHT_OF_GROWTH1 IS NOT NULL OR WEIGHT_OF_GROWTH2 IS NOT NULL OR WEIGHT_OF_GROWTH3 IS NOT NULL);

SELECT * FROM SAILW0972V.VB_MI_COHORT_WRRS_RESULTS;

--Create WRRS Table with results grouped into agreed UTI result groupings				

CREATE TABLE SAILW0972V.VB_MI_COHORT_WRRS_RESULTS_AGREED 
(		ALF_PE VARCHAR(20),
		SPCM_COLLECTED_DT DATE,
		REPORT_SEQ INTEGER,
		REQUEST_SEQ INTEGER,
		REQUEST_NAME VARCHAR(50),
		CULTURE VARCHAR(50),
		CULTURE2 VARCHAR(50),
		CULTURE3 VARCHAR(50),
		ORGANISM VARCHAR(50),
		ORGANISM2 VARCHAR(50),
		ORGANISM3 VARCHAR(50),
		RED_BLOOD_CELL_COUNT VARCHAR(100),
		WHITE_BLOOD_CELL_COUNT VARCHAR(100),
		TRIMETHOPRIM VARCHAR(50),
		NITROFURANTOIN VARCHAR(50),
		GENTAMICIN VARCHAR(50),
		AMOXICILLIN VARCHAR(50),
		AMOXICILLIN_CLAVULANATE VARCHAR(50),
		CEPHALEXIN VARCHAR(50));

alter table SAILW0972V.VB_MI_COHORT_WRRS_RESULTS_AGREED activate not logged INITIALLY;

INSERT INTO SAILW0972V.VB_MI_COHORT_WRRS_RESULTS_AGREED 
	(ALF_PE,
	SPCM_COLLECTED_DT,
	REPORT_SEQ,
	REQUEST_SEQ,
	REQUEST_NAME,
	CULTURE,
	CULTURE2,
	CULTURE3,
	ORGANISM,
	ORGANISM2,
	ORGANISM3,
	RED_BLOOD_CELL_COUNT,
	WHITE_BLOOD_CELL_COUNT,
	TRIMETHOPRIM,
	NITROFURANTOIN,
	GENTAMICIN,
	AMOXICILLIN,
	AMOXICILLIN_CLAVULANATE,
	CEPHALEXIN)
	SELECT ALF_PE,
		SPCM_COLLECTED_DT,
		REPORT_SEQ,
		REQUEST_SEQ,
		REQUEST_NAME,
		(CASE WHEN (CULTURE = 'Predominant growth of' AND 
							(WEIGHT_OF_GROWTH1 = '10^7 - 10^8' OR WEIGHT_OF_GROWTH1 IS NULL))
					OR (CULTURE IS NULL AND WEIGHT_OF_GROWTH1 = '10^7 - 10^8') THEN 'growth'
			WHEN ((CULTURE IN ('>100,000 orgs/ml',
							'>100,000') AND
							(WEIGHT_OF_GROWTH1 = '>= 10^8' OR WEIGHT_OF_GROWTH1 IS NULL)))
					OR 	(CULTURE = 'Predominant growth of' AND WEIGHT_OF_GROWTH1 = '>= 10^8')
					OR (CULTURE IS NULL AND WEIGHT_OF_GROWTH1 = '>= 10^8') THEN 'growth>10^8'
			WHEN CULTURE IN ('Mixed growth',
							'Mixed growth <10^7 cfu/L',
							'Mixed growth 10^7 - 10^8 cfu/L',
							'Mixed growth including',
							'10,000 Mixed',
							'10,000 Mixed 10,000 Mixed',
							'10-100,000 MIXED',
							'10-100000 MIXED',
							'Mixed growth') AND
							(WEIGHT_OF_GROWTH1 = '10^7 - 10^8' OR WEIGHT_OF_GROWTH1 IS NULL)
					THEN 'mixed growth'
			WHEN CULTURE IN ('Heavy mixed growth.',
							'Mixed growth >=10^8 cfu/L',
							'>100,000 Mixed',
							'>100,000 Mixed >100,000 Mixed',
							'100,000 Mixed growth') AND
							(WEIGHT_OF_GROWTH1 = '>= 10^8' OR WEIGHT_OF_GROWTH1 IS NULL)
				OR 	(CULTURE IN ('Mixed growth',
								'Mixed growth including',
								'Mixed growth') AND 
							(WEIGHT_OF_GROWTH1 = '>= 10^8')) THEN 'mixed growth>10^8'
			WHEN (CULTURE IN ('Negative',
							'No growth',
							'No significant growth',
							'10000',
							'<10,000',
							'<10,000<10,000',
							'No Growth',
							'No GrowthNo Growth',
							'No Growth',
							'No GrowthNo Growth',
							'No significant growth.',
							'Yeasts NOT isolated',
							'No growth after 5 days incubation.',
							'Bacterial pathogens NOT isolated. Yeasts NOT isolated.') AND
							(WEIGHT_OF_GROWTH1 IN ('<10^5','>= 10^6','10^5-10^6','10^6-10^7') OR WEIGHT_OF_GROWTH1 IS NULL))
						OR (CULTURE IS NULL AND WEIGHT_OF_GROWTH1 IN ('<10^5','>= 10^6','10^5-10^6','10^6-10^7')) THEN 'no growth'
			ELSE 'N/A'
				END) AS CULTURE,
		(CASE WHEN (CULTURE = 'Predominant growth of' AND 
							(WEIGHT_OF_GROWTH2 = '10^7 - 10^8'))
					OR (CULTURE IS NULL AND WEIGHT_OF_GROWTH2 = '10^7 - 10^8') THEN 'growth'
			WHEN (CULTURE IN ('>100,000 orgs/ml',
							'>100,000',
							'Predominant growth of') AND
							(WEIGHT_OF_GROWTH2 = '>= 10^8'))
					OR (CULTURE IS NULL AND WEIGHT_OF_GROWTH2 = '>= 10^8') THEN 'growth>10^8'
			WHEN CULTURE IN ('Mixed growth',
							'Mixed growth <10^7 cfu/L',
							'Mixed growth 10^7 - 10^8 cfu/L',
							'Mixed growth including',
							'10,000 Mixed',
							'10,000 Mixed 10,000 Mixed',
							'10-100,000 MIXED',
							'10-100000 MIXED',
							'Mixed growth') AND
							(WEIGHT_OF_GROWTH2 = '10^7 - 10^8') THEN 'mixed growth'
			WHEN CULTURE IN ('Heavy mixed growth.',
							'Mixed growth >=10^8 cfu/L',
							'>100,000 Mixed',
							'>100,000 Mixed >100,000 Mixed',
							'100,000 Mixed growth',
							'Mixed growth',
							'Mixed growth including',
							'Mixed growth') AND
							(WEIGHT_OF_GROWTH2 = '>= 10^8')  THEN 'mixed growth>10^8'
			WHEN (CULTURE IN ('Negative',
							'No growth',
							'No significant growth',
							'10000',
							'<10,000',
							'<10,000<10,000',
							'No Growth',
							'No GrowthNo Growth',
							'No Growth',
							'No GrowthNo Growth',
							'No significant growth.',
							'Yeasts NOT isolated',
							'No growth after 5 days incubation.',
							'Bacterial pathogens NOT isolated. Yeasts NOT isolated.') AND
							(WEIGHT_OF_GROWTH2 IN ('<10^5','>= 10^6','10^5-10^6','10^6-10^7')))
				OR (CULTURE IS NULL AND WEIGHT_OF_GROWTH2 IN ('<10^5','>= 10^6','10^5-10^6','10^6-10^7')) THEN 'no growth'
			ELSE 'N/A'
				END) AS CULTURE2,
		(CASE WHEN (CULTURE = 'Predominant growth of' AND 
							(WEIGHT_OF_GROWTH3 = '10^7 - 10^8'))
				OR (CULTURE IS NULL AND WEIGHT_OF_GROWTH3 = '10^7 - 10^8') THEN 'growth'
			WHEN (CULTURE IN ('>100,000 orgs/ml',
							'>100,000',
							'Predominant growth of') AND
							(WEIGHT_OF_GROWTH3 = '>= 10^8') )
				OR (CULTURE IS NULL AND WEIGHT_OF_GROWTH3 = '>= 10^8') THEN 'growth>10^8'
			WHEN CULTURE IN ('Mixed growth',
							'Mixed growth <10^7 cfu/L',
							'Mixed growth 10^7 - 10^8 cfu/L',
							'Mixed growth including',
							'10,000 Mixed',
							'10,000 Mixed 10,000 Mixed',
							'10-100,000 MIXED',
							'10-100000 MIXED',
							'Mixed growth') AND
							(WEIGHT_OF_GROWTH3 = '10^7 - 10^8') THEN 'mixed growth'
			WHEN CULTURE IN ('Heavy mixed growth.',
							'Mixed growth >=10^8 cfu/L',
							'>100,000 Mixed',
							'>100,000 Mixed >100,000 Mixed',
							'100,000 Mixed growth',
							'Mixed growth',
							'Mixed growth including',
							'Mixed growth') AND
							(WEIGHT_OF_GROWTH3 = '>= 10^8') THEN 'mixed growth>10^8'
			WHEN (CULTURE IN ('Negative',
							'No growth',
							'No significant growth',
							'10000',
							'<10,000',
							'<10,000<10,000',
							'No Growth',
							'No GrowthNo Growth',
							'No Growth',
							'No GrowthNo Growth',
							'No significant growth.',
							'Yeasts NOT isolated',
							'No growth after 5 days incubation.',
							'Bacterial pathogens NOT isolated. Yeasts NOT isolated.') AND
							(WEIGHT_OF_GROWTH3 IN ('<10^5','>= 10^6','10^5-10^6','10^6-10^7')))
				OR (CULTURE IS NULL AND WEIGHT_OF_GROWTH3 IN ('<10^5','>= 10^6','10^5-10^6','10^6-10^7')) THEN 'no growth'
			ELSE 'N/A'
				END) AS CULTURE3,
		(CASE WHEN ORGANISM IN ('Candida albicans',
								'Candida species',
								'Candida albicans ({abbr})',
								'Candida sp ({abbr})',
								'Yeast ({abbr})',
								'Candida albicans',
								'Candida sp') THEN 'candida'
				WHEN ORGANISM IN ('Coliform',
								'Coliform - KESC group (KESC)',
								'Coliform ({abbr})',
								'Mixed coliforms ({abbr})',
								'Coliform bacilli') THEN 'coliform'
				WHEN ORGANISM IN ('Escherichia coli',
								'Escherichia coli ({abbr})',
								'Escherichia coli',
								'Escherichia coli (2)') THEN 'ecoli'
				WHEN ORGANISM IN ('Enterococcus species',
								'Enterococcus faecalis ({abbr})',
								'Enterococcus sp ({abbr})',
								'Enterococcus species') THEN 'enterococcus'
				WHEN ORGANISM IN ('Klebsiella pneumoniae',
								'Klebsiella pneumoniae ({abbr})',
								'Klebsiella pneumoniae') THEN 'klebsiella'
				WHEN ORGANISM IN ('No Growth.',
								'No significant growth') THEN 'no growth'
				WHEN ORGANISM IN ('Proteus species',
								'Proteus mirabilis ({abbr})',
								'Proteus sp ({abbr})') THEN 'proteus'
				WHEN ORGANISM IN ('Pseudomonas aeruginosa',
								'Pseudomonas species',
								'Pseudomonas aeruginosa ({abbr})',
								'Pseudomonas sp ({abbr})',
								'Pseudomonas aeruginosa') THEN 'pseudomonas'
				WHEN ORGANISM IN ('Staphylococcus aureus',
								'Staphylococcus aureus ({abbr})',
								'Staphylococcus aureus') THEN 'saureus'
				WHEN ORGANISM IN ('Staphylococcus coagulase negative ({abbr})',
								'Coag Negative Staphylococcus',
								'Staphylococcus Coagulase Negative') THEN 'staphcoagneg'
				WHEN ORGANISM IN ('Streptococcus agalactiae group B ({abbr})',
								'Streptococcus group A ({abbr})',
								'Streptococcus group B ({abbr})',
								'Beta-haemolytic Streptococcus') THEN 'strep'
			ELSE 'N/A'
				END) AS ORGANISM,
		(CASE WHEN ORGANISM2 IN ('Candida albicans ({abbr})',
								'Candida sp ({abbr})',
								'Yeast ({abbr})') THEN 'candida'
				WHEN ORGANISM2 IN ('Coliform - KESC group (KESC)',
									'Coliform ({abbr})',
									'Mixed coliforms ({abbr})') THEN 'coliform'
				WHEN ORGANISM2 = 'Escherichia coli ({abbr})' THEN 'ecoli'
				WHEN ORGANISM2 IN ('Enterococcus faecalis ({abbr})',
									'Enterococcus sp ({abbr})') THEN 'enterococcus'
				WHEN ORGANISM2 = 'Klebsiella pneumoniae ({abbr})' THEN 'klebsiella'
				WHEN ORGANISM2 IN ('Proteus mirabilis ({abbr})',
									'Proteus sp ({abbr})') THEN 'proteus'
				WHEN ORGANISM2 IN (	'Pseudomonas aeruginosa ({abbr})',
									'Pseudomonas sp ({abbr})') THEN 'pseudomonas'
				WHEN ORGANISM2 = 'Staphylococcus aureus ({abbr})' THEN 'saureus'
				WHEN ORGANISM2 = 'Staphylococcus coagulase negative ({abbr})' THEN 'staphcoagneg'
				WHEN ORGANISM2 IN (	'Streptococcus agalactiae group B ({abbr})',
									'Streptococcus group B ({abbr})') THEN 'strep'
			ELSE 'N/A'
				END) AS ORGANISM2,
		(CASE WHEN ORGANISM3 IN ('Candida albicans ({abbr})',
								'Candida sp ({abbr})',
								'Yeast ({abbr})') THEN 'candida'
				WHEN ORGANISM3 IN ('Coliform - KESC group (KESC)',
									'Coliform ({abbr})',
									'Mixed coliforms ({abbr})') THEN 'coliform'
				WHEN ORGANISM3 = 'Escherichia coli ({abbr})' THEN 'ecoli'
				WHEN ORGANISM3 IN ('Enterococcus faecalis ({abbr})',
									'Enterococcus sp ({abbr})') THEN 'enterococcus'
				WHEN ORGANISM3 = 'Klebsiella pneumoniae ({abbr})' THEN 'klebsiella'
				WHEN ORGANISM3 IN ('Proteus mirabilis ({abbr})',
									'Proteus sp ({abbr})') THEN 'proteus'
				WHEN ORGANISM3 IN (	'Pseudomonas aeruginosa ({abbr})',
									'Pseudomonas sp ({abbr})') THEN 'pseudomonas'
				WHEN ORGANISM3 = 'Staphylococcus aureus ({abbr})' THEN 'saureus'
				WHEN ORGANISM3 = 'Staphylococcus coagulase negative ({abbr})' THEN 'staphcoagneg'
				WHEN ORGANISM3 IN (	'Streptococcus agalactiae group B ({abbr})',
									'Streptococcus group B ({abbr})') THEN 'strep'
			ELSE 'N/A'
				END) AS ORGANISM3,
		(CASE WHEN RED_BLOOD_CELL_COUNT IN ('1',
														'2',
														'3',
														'4',
														'5',
														'6',
														'7',
														'8',
														'9',
														'10',
														'11',
														'12',
														'13',
														'14',
														'15',
														'16',
														'17',
														'18',
														'19',
														'20',
														'21',
														'22',
														'23',
														'24',
														'25',
														'26',
														'27',
														'28',
														'29',
														'30',
														'31',
														'32',
														'33',
														'34',
														'35',
														'36',
														'37',
														'38',
														'39',
														'40',
														'41',
														'42',
														'43',
														'44',
														'<1',
														'<5   x10^6/L',
														'5-99  x10^6/L') THEN '<100'
				WHEN RED_BLOOD_CELL_COUNT = '>=100 x10^6/L' THEN '>100'
			ELSE 'N/A'
				END) AS RED_BLOOD_CELL_COUNT,
			(CASE WHEN WHITE_BLOOD_CELL_COUNT IN ('Greater than 20 White Blood Cells per cubic millimetre',
														'Less than 10 White Blood Cells per cubic millimetre',
														'<10   x10^6/L',
														'10-99 x10^6/L') THEN '<10^8'
				WHEN WHITE_BLOOD_CELL_COUNT = '>=100 x10^6/L' THEN '>10^8'
			ELSE 'N/A'
				END) AS WHITE_BLOOD_CELL_COUNT,
	TRIMETHOPRIM,
	NITROFURANTOIN,
	GENTAMICIN,
	AMOXICILLIN,
	AMOXICILLIN_CLAVULANATE,
	CEPHALEXIN
		FROM SAILW0972V.VB_MI_COHORT_WRRS_RESULTS;
	
COMMIT;

ALTER TABLE SAILW0972V.VB_MI_COHORT_WRRS_RESULTS_AGREED
	ADD COLUMN ORGANISM_COUNT VARCHAR(10);

UPDATE SAILW0972V.VB_MI_COHORT_WRRS_RESULTS_AGREED
	SET ORGANISM_COUNT = CASE WHEN (CULTURE <> 'N/A'-----------------------------CULTURE has values not candida
									AND ORGANISM <> 'N/A'
									AND ORGANISM <> 'candida')
									AND ((CULTURE2 <> 'N/A' ----------------------CULTURE2 has values not candida
										AND ORGANISM2 <> 'N/A'
										AND ORGANISM2 <> 'candida'
										AND CULTURE3 = 'N/A'----------------------CULTURE3 does not have values
										AND (ORGANISM3 = 'N/A'
										OR ORGANISM3 = 'candida'))
										OR (CULTURE3 <> 'N/A'
										AND ORGANISM3 <> 'N/A'
										AND ORGANISM3 <> 'candida'
										AND CULTURE2 = 'N/A'
										AND (ORGANISM2 = 'N/A'
										OR ORGANISM2 = 'candida')))
								THEN '2 Orgs'
							WHEN  (CULTURE2 <> 'N/A'-----------------------------CULTURE2 has values
									AND ORGANISM2 <> 'N/A'
									AND ORGANISM2 <> 'candida')
									AND ((CULTURE3 <> 'N/A' ----------------------CULTURE3 has values not candida
										AND ORGANISM3 <> 'N/A'
										AND ORGANISM3 <> 'candida'
										AND CULTURE = 'N/A'----------------------CULTURE does not have values 
										AND (ORGANISM = 'N/A'
										OR ORGANISM = 'candida'))
										OR (CULTURE <> 'N/A'
										AND ORGANISM <> 'N/A'
										AND ORGANISM <> 'candida'
										AND CULTURE3 = 'N/A'
										AND (ORGANISM3 = 'N/A'
										OR ORGANISM3 = 'candida')))
								THEN '2 Orgs'
							WHEN ((CULTURE <> 'N/A' -----------------------------When all organism and culture fields have a value but more than one organism value is candida
								AND ORGANISM <> 'N/A'
								AND CULTURE2 <> 'N/A'
								AND ORGANISM2 <> 'N/A'
								AND CULTURE3 <> 'N/A'
								AND ORGANISM3 <> 'N/A')
									AND ((ORGANISM = 'candida'
										AND ORGANISM2 = 'candida')
									OR (ORGANISM = 'candida'
										AND ORGANISM3 = 'candida')
									OR (ORGANISM2 = 'candida'
										AND ORGANISM3 = 'candida')))
								THEN NULL
							WHEN ((CULTURE <> 'N/A' -----------------------------When all organism and culture fields have a value and one or none is candida
								AND ORGANISM <> 'N/A'
								AND CULTURE2 <> 'N/A'
								AND ORGANISM2 <> 'N/A'
								AND CULTURE3 <> 'N/A'
								AND ORGANISM3 <> 'N/A')
									AND (ORGANISM = 'candida'
									OR ORGANISM = 'candida'
									OR ORGANISM2 = 'candida'))
								THEN '2 Orgs'
						END;	
					
ALTER TABLE SAILW0972V.VB_MI_COHORT_WRRS_RESULTS_AGREED
	ADD COLUMN UTI_OUTCOME VARCHAR(50);
					
UPDATE SAILW0972V.VB_MI_COHORT_WRRS_RESULTS_AGREED
	SET UTI_OUTCOME = CASE WHEN (CULTURE = 'no growth' -------------------No Growth. When one culture value is no growth and all others are no growth or N/A
								AND (CULTURE2 = 'no growth'
									OR CULTURE2 = 'N/A')
								AND (CULTURE3 = 'no growth'
									OR CULTURE3 = 'N/A'))
							OR (CULTURE2 = 'no growth'
								AND (CULTURE3 = 'no growth'
									OR CULTURE3 = 'N/A')
								AND (CULTURE = 'no growth'
									OR CULTURE = 'N/A'))
							OR (CULTURE3 = 'no growth'
								AND (CULTURE = 'no growth'
									OR CULTURE = 'N/A')
								AND (CULTURE2 = 'no growth'
									OR CULTURE2 = 'N/A'))
						THEN 'No microbiological evidence of UTI'
					WHEN ((CULTURE = 'mixed growth>10^8' ----------------Heavy Mixed Growth (not candida)
								OR CULTURE2 = 'mixed growth>10^8'
								OR CULTURE3 = 'mixed growth>10^8')
							AND (ORGANISM <> 'candida'
								OR ORGANISM <> 'N/A')
							AND (ORGANISM2 <> 'candida'
								OR ORGANISM2 <> 'N/A')
							AND (ORGANISM3 <> 'candida'
								OR ORGANISM3 <> 'N/A'))
						THEN 'Heavy mixed growth'
					WHEN (ORGANISM <> 'N/A'
							AND ORGANISM <> 'candida'----------------Heavy Mixed Growth based on 3 organisms (not candida)
							AND CULTURE <> 'N/A'
							AND ORGANISM2 <> 'N/A'
							AND ORGANISM2 <> 'candida'
							AND CULTURE2 <> 'N/A'
							AND ORGANISM3 <> 'N/A'
							AND ORGANISM3 <> 'candida'
							AND CULTURE3 <> 'N/A')
						AND (CULTURE = 'growth>10^8'
							OR CULTURE2 = 'growth>10^8'
							OR CULTURE3 = 'growth>10^8')
						THEN 'Heavy mixed growth'
					WHEN ((CULTURE = 'mixed growth' ----------------Mixed Growth (not candida)
								OR CULTURE2 = 'mixed growth'
								OR CULTURE3 = 'mixed growth')
							AND (ORGANISM <> 'candida'
								OR ORGANISM <> 'N/A')
							AND (ORGANISM2 <> 'candida'
								OR ORGANISM2 <> 'N/A')
							AND (ORGANISM3 <> 'candida'
								OR ORGANISM3 <> 'N/A'))
						THEN 'Mixed growth'
					WHEN (ORGANISM <> 'N/A'
							AND ORGANISM <> 'candida'----------------Mixed Growth based on 3 organisms (not candida)
							AND CULTURE <> 'N/A'
							AND ORGANISM2 <> 'N/A'
							AND ORGANISM2 <> 'candida'
							AND CULTURE2 <> 'N/A'
							AND ORGANISM3 <> 'N/A'
							AND ORGANISM3 <> 'candida'
							AND CULTURE3 <> 'N/A')
						AND (CULTURE = 'growth'
							OR CULTURE2 = 'growth'
							OR CULTURE3 = 'growth')
						THEN 'Mixed growth'
					WHEN ((CULTURE = 'growth>10^8' ---------------Confirmed UTI, Organism not candida, growth >10^8 and WBC >10^8
								AND ORGANISM <> 'N/A'
								AND ORGANISM <> 'candida')
							OR (CULTURE2 = 'growth>10^8'
								AND ORGANISM2 <> 'N/A'
								AND ORGANISM2 <> 'candida')
							OR (CULTURE3 = 'growth>10^8'
								AND ORGANISM3 <> 'N/A'
								AND ORGANISM3 <> 'candida'))
							AND WHITE_BLOOD_CELL_COUNT = '>10^8'
						THEN 'Confirmed UTI'
					WHEN ((CULTURE = 'growth' ---------------Possible UTI, Organism not candida, growth >10^7
								AND ORGANISM <> 'N/A'
								AND ORGANISM <> 'candida')
							OR (CULTURE2 = 'growth'
								AND ORGANISM2 <> 'N/A'
								AND ORGANISM2 <> 'candida')
							OR (CULTURE3 = 'growth'
								AND ORGANISM3 <> 'N/A'
								AND ORGANISM3 <> 'candida'))
						THEN 'Possible UTI'
					WHEN ((CULTURE = 'growth>10^8' ---------------Possible UTI, Growth>10^8 WBC <10^8 or WBC NULL
								AND ORGANISM <> 'N/A'
								AND ORGANISM <> 'candida')
							OR (CULTURE2 = 'growth>10^8'
								AND ORGANISM2 <> 'N/A'
								AND ORGANISM2 <> 'candida')
							OR (CULTURE3 = 'growth>10^8'
								AND ORGANISM3 <> 'N/A'
								AND ORGANISM3 <> 'candida'))
							AND (WHITE_BLOOD_CELL_COUNT = '<10^8'
								OR WHITE_BLOOD_CELL_COUNT = 'N/A')
						THEN 'Possible UTI'
					WHEN ((CULTURE = 'growth' ---------------Possible UTI, Growth WBC <10^8 or WBC NULL
								AND ORGANISM <> 'N/A'
								AND ORGANISM <> 'candida')
							OR (CULTURE2 = 'growth'
								AND ORGANISM2 <> 'N/A'
								AND ORGANISM2 <> 'candida')
							OR (CULTURE3 = 'growth'
								AND ORGANISM3 <> 'N/A'
								AND ORGANISM3 <> 'candida'))
							AND (WHITE_BLOOD_CELL_COUNT = '<10^8'
								OR WHITE_BLOOD_CELL_COUNT = 'N/A')
						THEN 'Possible UTI'
					WHEN (CULTURE = 'N/A' --------------------All culture NULL
								AND CULTURE2 = 'N/A'
								AND CULTURE3 = 'N/A')
						THEN 'Exclude NULL culture'
					WHEN (ORGANISM = 'N/A' -----------------------All organism NULL
								AND ORGANISM2 = 'N/A'
								AND ORGANISM3 = 'N/A')
						THEN 'Possible UTI'
					WHEN (ORGANISM = 'candida' -------------------Any organism candida
							AND (ORGANISM2 = 'N/A'
							OR ORGANISM2 = 'candida')
							AND (ORGANISM3 = 'N/A'
							OR ORGANISM3 = 'candida')
								OR (ORGANISM2 = 'candida'
									AND (ORGANISM = 'N/A'
									OR ORGANISM = 'candida')
									AND (ORGANISM3 = 'N/A'
									OR ORGANISM3 = 'candida'))
								OR (ORGANISM3 = 'candida'
									AND (ORGANISM = 'N/A'
									OR ORGANISM = 'candida')
									AND (ORGANISM2 = 'N/A'
									OR ORGANISM2 = 'candida')))
						THEN 'No microbiological evidence of UTI'
					WHEN (((CULTURE = 'growth'
							OR CULTURE = 'growth>10^8')
							AND ORGANISM <> 'candida')
						OR ((CULTURE2 = 'growth'
							OR CULTURE2 = 'growth>10^8')
							AND ORGANISM2 <> 'candida')
						OR ((CULTURE3 = 'growth'
							OR CULTURE3 = 'growth>10^8')
							AND ORGANISM3 <> 'candida'))
						THEN 'Possible UTI'
					ELSE 'No microbiological evidence of UTI'
				END;
			
ALTER TABLE SAILW0972V.VB_MI_COHORT_WRRS_RESULTS_AGREED
	ADD COLUMN DIAG_ORGANISM VARCHAR(20);

UPDATE SAILW0972V.VB_MI_COHORT_WRRS_RESULTS_AGREED
	SET DIAG_ORGANISM = CASE WHEN ORGANISM_COUNT IS NULL
							AND (UTI_OUTCOME = 'Possible UTI'
								OR UTI_OUTCOME = 'Confirmed UTI')
							THEN CASE WHEN ORGANISM <> 'N/A'
										AND ORGANISM <> 'candida'
										AND CULTURE <> 'N/A'
										THEN ORGANISM
									WHEN ORGANISM2 <> 'N/A'
										AND ORGANISM2 <> 'candida'
										AND CULTURE2 <> 'N/A'
										THEN ORGANISM2
									ELSE ORGANISM3
								END
							WHEN ORGANISM_COUNT IS NOT NULL
								AND (UTI_OUTCOME = 'Possible UTI'
								OR UTI_OUTCOME = 'Confirmed UTI')
								THEN CASE WHEN ORGANISM = ORGANISM2
										AND ORGANISM3 = 'N/A'
										THEN ORGANISM
									WHEN ORGANISM2 = ORGANISM3
										AND ORGANISM = 'N/A'
										THEN ORGANISM2
									WHEN ORGANISM = ORGANISM3
										AND ORGANISM2 = 'N/A'
										THEN ORGANISM
								ELSE '>1 Organism'
							END
						END;