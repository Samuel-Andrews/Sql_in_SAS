/************************************
* Name: Getting total number of     *
*       fines and total amount of   *
*       fines without creating      *
*       extra tables along the way. *
*                                   *
* Date: March 18, 2019              *
*                                   *
* Author: April SAM               *
************************************/


******************************************************************
*                       STEP 1                                   *
*****************************************************************;

/** FOR CSV Files uploaded from Windows **/

FILENAME CSV "/folders/myfolders/ProviderInfo_Download.csv" TERMSTR=CRLF;

/** Import the CSV file.  **/

PROC IMPORT DATAFILE=CSV
		    OUT=SAM.ProviderInfo
		    DBMS=CSV
		    REPLACE;
		    
		    GETNAMES = Yes;
		    DATAROW = 2;
RUN;

FILENAME CSV;

PROC IMPORT	
	DATAFILE = "/folders/myfolders/Penalties_Download.csv"
	OUT = SAM.Penalties
	DBMS = CSV
	REPLACE;
	
	GETNAMES = Yes;
	DATAROW = 2;
RUN;


******************************************************************
*                       STEP 2                                   *
*****************************************************************;
PROC SQL;
	SELECT provnum, COUNT(provnum) AS NumFines, SUM(100*INPUT(fine_amt, DOLLAR12.2)) AS TotalFines FORMAT = DOLLAR12.2 /* notice formulas are not hardcoded */
		FROM (SELECT provnum, pnlty_type, pnlty_date, fine_amt
			FROM SAM.Penalties
				WHERE pnlty_type = 'Fine' AND SUBSTR(pnlty_date, 1, 4) = '2016') AS Fines2016
	GROUP BY provnum;
QUIT;


******************************************************************
*                       STEP 3                                   *
*****************************************************************;
PROC SQL;
	SELECT A.PROVNUM, A.OwnershipType, B.NumFines, B.TotalFines
		FROM (SELECT PROVNUM, SUBSTR(OWNERSHIP, 1, FIND(OWNERSHIP, '-', 1)-2) AS OwnershipType 
				FROM SAM.ProviderInfo) AS A
			LEFT JOIN (SELECT provnum, COUNT(provnum) AS NumFines, SUM(100*INPUT(fine_amt, DOLLAR12.2)) AS TotalFines FORMAT = DOLLAR12.2
					FROM (SELECT provnum, pnlty_type, pnlty_date, fine_amt
							FROM SAM.Penalties
							WHERE pnlty_type = 'Fine' AND SUBSTR(pnlty_date, 1, 4) = '2016') AS Fines2016
							GROUP BY provnum) AS B
			ON A.PROVNUM = B.provnum;
QUIT;


******************************************************************
*                       STEP 4                                   *
*****************************************************************;
PROC SQL;
	SELECT OwnershipType, 
	COUNT(*) AS GroupTotal LABEL 'Number of providers', 
	SUM(NumFines) AS Totfines LABEL 'Total Number of Fines',
	SUM(TotalFines) AS TotFineAmount LABEL 'Total Amount in Fines' FORMAT = DOLLAR12.2,
	
	CALCULATED GroupTotal/(SELECT COUNT(*) FROM (SELECT A.PROVNUM, A.OwnershipType, B.NumFines, B.TotalFines
													FROM (SELECT PROVNUM, SUBSTR(OWNERSHIP, 1, FIND(OWNERSHIP, '-', 1)-2) AS OwnershipType 
															FROM SAM.ProviderInfo) AS A
														LEFT JOIN (SELECT provnum, COUNT(provnum) AS NumFines, SUM(100*INPUT(fine_amt, DOLLAR12.2)) AS TotalFines FORMAT = DOLLAR12.2
																		FROM (SELECT provnum, pnlty_type, pnlty_date, fine_amt
																				FROM SAM.Penalties
																				WHERE pnlty_type = 'Fine' AND SUBSTR(pnlty_date, 1, 4) = '2016') AS Fines2016
																				GROUP BY provnum) AS B
														ON A.PROVNUM = B.provnum)) LABEL '% of Providers',
	
	
	CALCULATED Totfines/(SELECT SUM(NumFines) FROM (SELECT A.PROVNUM, A.OwnershipType, B.NumFines, B.TotalFines
														FROM (SELECT PROVNUM, SUBSTR(OWNERSHIP, 1, FIND(OWNERSHIP, '-', 1)-2) AS OwnershipType 
																FROM SAM.ProviderInfo) AS A
															LEFT JOIN (SELECT provnum, COUNT(provnum) AS NumFines, SUM(100*INPUT(fine_amt, DOLLAR12.2)) AS TotalFines FORMAT = DOLLAR12.2
																		FROM (SELECT provnum, pnlty_type, pnlty_date, fine_amt
																				FROM SAM.Penalties
																				WHERE pnlty_type = 'Fine' AND SUBSTR(pnlty_date, 1, 4) = '2016') AS Fines2016
																				GROUP BY provnum) AS B
															ON A.PROVNUM = B.provnum)) LABEL '% of Fines',
	
	
	CALCULATED TotfineAmount/(SELECT SUM(TotalFines) FROM (SELECT A.PROVNUM, A.OwnershipType, B.NumFines, B.TotalFines
															FROM (SELECT PROVNUM, SUBSTR(OWNERSHIP, 1, FIND(OWNERSHIP, '-', 1)-2) AS OwnershipType 
																	FROM SAM.ProviderInfo) AS A
															LEFT JOIN (SELECT provnum, COUNT(provnum) AS NumFines, SUM(100*INPUT(fine_amt, DOLLAR12.2)) AS TotalFines FORMAT = DOLLAR12.2
																		FROM (SELECT provnum, pnlty_type, pnlty_date, fine_amt
																				FROM SAM.Penalties
																				WHERE pnlty_type = 'Fine' AND SUBSTR(pnlty_date, 1, 4) = '2016') AS Fines2016
																				GROUP BY provnum) AS B
															ON A.PROVNUM = B.provnum)) LABEL '% of Fine Amount'
	
	FROM (SELECT A.PROVNUM, A.OwnershipType, B.NumFines, B.TotalFines
			FROM (SELECT PROVNUM, SUBSTR(OWNERSHIP, 1, FIND(OWNERSHIP, '-', 1)-2) AS OwnershipType 
					FROM SAM.ProviderInfo) AS A
				LEFT JOIN (SELECT provnum, COUNT(provnum) AS NumFines, SUM(100*INPUT(fine_amt, DOLLAR12.2)) AS TotalFines FORMAT = DOLLAR12.2
							FROM (SELECT provnum, pnlty_type, pnlty_date, fine_amt
									FROM SAM.Penalties
									WHERE pnlty_type = 'Fine' AND SUBSTR(pnlty_date, 1, 4) = '2016') AS Fines2016
									GROUP BY provnum) AS B
				ON A.PROVNUM = B.provnum)
		
	WHERE LENGTH(OwnershipType) > 1
	GROUP BY (OwnershipType);
QUIT;