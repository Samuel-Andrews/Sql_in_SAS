/********************************************************************
* Name: Project 1.sas                                               *
* Date: March 29, 2019                                              *
*                                                                   *
* Purpose: Solve the various problems given in DSCI 325 project 1   *
*          without the creation of any unesssecary tables           *
*                                                                   *
* Output: Temporary SAS outputs resulting from SQL Queries that     *
*         Correlate to the project questions                        *
********************************************************************/


/* Question 1 A Pitching data */
FILENAME CSV "/folders/myfolders/Pitching.csv" 
       TERMSTR=CRLF;



PROC IMPORT	
	DATAFILE = "/folders/myfolders/Pitching.csv"
	OUT = SAM.Pitching
	DBMS = CSV
	REPLACE;
	
	GETNAMES = Yes;
	DATAROW = 2;
RUN;


FILENAME CSV;

PROC CONTENTS DATA = SAM.pitching;
QUIT;

/* question 1 A */
Proc sql outobs = 1000;
	/* IPOuts divided by three quickly calculates total innings from SaM.pitching
	   where team was either Wisonsin (MIL) or Minnesota (MIN) in the year 2000
	    and ERA is considered good (<= 4.0) */
	select YearID, TeamID, ER, IPOuts, ERA, IPOuts/3 AS Innings_Played,
		9*(ER/CALCULATED Innings_played) AS ERA2 /* calculation */
		From SAM.pitching
		where (TeamID = "MIL" or TeamID = "MIN")  and yearID = 2000 and ERA <= 4.0 ; 
	
quit;


/* question 1 B Teams Data */
/** FOR CSV Files uploaded from Windows **/
FILENAME CSV "/folders/myfolders/Teams.csv" 
       TERMSTR=CRLF;



PROC IMPORT	
	DATAFILE = "/folders/myfolders/Teams.csv"
	OUT = SAM.Teams
	DBMS = CSV
	REPLACE;
	
	GETNAMES = Yes;
	DATAROW = 2;
RUN;


FILENAME CSV;



/* question 1 B  */
Proc sql outobs = 1000;
	/* Calculates the ERA and then compares it to the existing calculation, our calc
	is labeled as ERA2 */
	
	select YearID, TeamID, ERA,
		9*(ER/(IPOuts/3)) AS ERA2
		From SAM.Teams
		where (TeamID = "MIL" or TeamID = "MIN")  and yearID in(2000, 2005, 2010, 2015) ; 
		/* use parenthesis to manipulate order of operations for desired output */

quit;

/* Question 2 read ins */

/*Salary dataset */
FILENAME CSV "/folders/myfolders/Salaries.csv" 
       TERMSTR=CRLF;



PROC IMPORT	
	DATAFILE = "/folders/myfolders/Salaries.csv"
	OUT = SAM.salary
	DBMS = CSV
	REPLACE;
	
	GETNAMES = Yes;
	DATAROW = 2;
RUN;


FILENAME CSV;

PROC CONTENTS DATA = SAM.salary;
QUIT;


/* Franchise dataset */
FILENAME CSV "/folders/myfolders/TeamsFranchises.csv" 
       TERMSTR=CRLF;



PROC IMPORT	
	DATAFILE = "/folders/myfolders/TeamsFranchises.csv"
	OUT = SAM.TeamsFranchises
	DBMS = CSV
	REPLACE;
	
	GETNAMES = Yes;
	DATAROW = 2;
RUN;


FILENAME CSV;

/* Teams */
PROC CONTENTS DATA = SAM.TeamsFranchises;
QUIT;


FILENAME CSV "/folders/myfolders/Teams.csv" 
       TERMSTR=CRLF;



PROC IMPORT	
	DATAFILE = "/folders/myfolders/Teams.csv"
	OUT = SAM.Teams
	DBMS = CSV
	REPLACE;
	
	GETNAMES = Yes;
	DATAROW = 2;
RUN;


FILENAME CSV;








/* Question 2 part A */
Proc sql  /*outobs=10*/;
	/* the joins work in order, with Letters signifiying home table, otherwise
	it is standard afair as far as organization, note that second join is on a  
	different variable. While it was orignally intended to use the Letter A. B. C. system
	to join the tables, that method was found to join all tables at the same time
	which ended up returning wrong data, so it was done more traditionally below*/
	
select distinct A.YearID as Year, A.TeamID as Team, A.AverageSalary as Average_Salary, C.franchName as Franchise /* as's really noly matter up here */
From 
(select distinct A.YearID, A.TeamID, A.AverageSalary, B.TeamID, B.FranchID, C.FranchID, C.FranchName 
 from(
 select YearID, Salary, TeamID, avg(salary) as AverageSalary
       from SAM.Salary 
          group by TeamID, yearID) as A 
          INNER JOIN (
			select TeamID, FranchID
        	FROM SAM.Teams
       				) /* end first join */
      as B
on A.TeamID = B.TeamID
INNER JOIN (
select FranchID, FranchName
  from SAM.TeamsFranchises
  			) as C
on B.FranchID = C.FranchID
) /*ens second join
/*overall the joins go Inner Sal -> Team and then that output to -> Franchise */
Where A.yearID = 2006 or A.yearID = 2012
;

quit;
	

/* Question 2 part B */

/* fundamentally the same as the previous problem, only we swapped out
	where statement for an order by */

Proc sql /*outobs=1*/;
select distinct A.YearID as Year, A.TeamID as Team, A.AverageSalary as Average_Salary, C.franchName as Franchise /* as's really noly matter up here */
From 
(select distinct A.YearID, A.TeamID, A.AverageSalary, B.TeamID, B.FranchID, C.FranchID, C.FranchName 
 from(
 select YearID, Salary, TeamID, avg(salary) as AverageSalary
       from SAM.Salary 
          group by TeamID, yearID) as A 
          INNER JOIN (
			select TeamID, FranchID
        	FROM SAM.Teams
       				) /* end first join */
      as B
on A.TeamID = B.TeamID
INNER JOIN (
select FranchID, FranchName
  from SAM.TeamsFranchises
  			) as C
on B.FranchID = C.FranchID
) /*ens second join
/*overall the joins go Inner Sal -> Team and then that output to -> Franchise */
Order by CALCULATED AverageSalary DESC /*only chagne */
;

quit;


	





/* question 3 People table */
FILENAME CSV "/folders/myfolders/People.csv" 
       TERMSTR=CRLF;



PROC IMPORT	
	DATAFILE = "/folders/myfolders/People.csv"
	OUT = SAM.People
	DBMS = CSV
	REPLACE;
	
	GETNAMES = Yes;
	DATAROW = 2;
RUN;


FILENAME CSV;


/* question 3 Batting table */
FILENAME CSV "/folders/myfolders/Batting.csv" 
       TERMSTR=CRLF;



PROC IMPORT	
	DATAFILE = "/folders/myfolders/Batting.csv"
	OUT = SAM.Batting
	DBMS = CSV
	REPLACE;
	
	GETNAMES = Yes;
	DATAROW = 2;
RUN;


FILENAME CSV;


/* Project 1 question 3 */
Proc Sql outobs = 1000;
/* put names in Lastname, Firstname format to keep it in line with normal database standards,
	additionally this allows it to be organized as desired easily */
	
	select distinct B.TeamID, cat(a.namelast,a.namefirst) as Player_Name_Lastname_Firstname 
	from SAM.People A INNER JOIN SAM.Batting B on A.playerID = B.playerID
	Where B.yearID >= 1980 and B.TeamID = "DET"      
	Order by UPPER(CALCULATED Player_Name_Lastname_Firstname) DESC;
	/* the UPPER command made all characters uppercase for the Order By statement, otherwise
	   lower case letters starting in last names break the organization (ex. Matt den Dekker) */
	
quit;


/* question 4 Batting table */
FILENAME CSV "/folders/myfolders/Batting.csv" 
       TERMSTR=CRLF;



PROC IMPORT	
	DATAFILE = "/folders/myfolders/Batting.csv"
	OUT = SAM.Batting
	DBMS = CSV
	REPLACE;
	
	GETNAMES = Yes;
	DATAROW = 2;
RUN;


FILENAME CSV;

PROC CONTENTS DATA = SAM.Batting;
QUIT;


FILENAME CSV "/folders/myfolders/Batting.csv" 
       TERMSTR=CRLF;




/* Question 4 */
proc sql /* outobs= 10 */;
OPTIONS MISSING = 0; /* changes all nulls to zeros, needed for our where statement */
	select playerID,  
		/* inputs were used to change data that wasn't read in as numeric, otherwise just standard
		fair for writing equations*/
		((H + BB + INPUT(HBP, 8.))/(AB + BB + INPUT(SH,8.) + INPUT(HBP, 8.))) as OBP, /*opb formual */
		
		(H + 2*(_2B) + 3*(_3B) + 4*(HR))/(AB) as SLG, /* slg formula*/
		
		((H + BB + INPUT(HBP, 8.))/(AB + BB + INPUT(SH,8.) + INPUT(HBP, 8.)))
		+
		(H + 2*(_2B) + 3*(_3B) + 4*(HR))/(AB) /* combined previous equations */
		as OPS
		
		from SAM.Batting
		Where yearID >= 2010 and CALCULATED OPS > 0 /* works cause of OPTIONs MISSING */
		;
		
	quit;
		

/* question 5 Schools table */
FILENAME CSV "/folders/myfolders/Schools.csv" 
       TERMSTR=CRLF;



PROC IMPORT	
	DATAFILE = "/folders/myfolders/Schools.csv"
	OUT = SAM.Schools
	DBMS = CSV
	REPLACE;
	
	GETNAMES = Yes;
	DATAROW = 2;
RUN;


FILENAME CSV;

PROC CONTENTS DATA = SAM.Schools;
QUIT;


FILENAME CSV "/folders/myfolders/Schools.csv" 
       TERMSTR=CRLF;
       
       
       
       
/* question 5 CollegePlaying table */
FILENAME CSV "/folders/myfolders/CollegePlaying.csv" 
       TERMSTR=CRLF;



PROC IMPORT	
	DATAFILE = "/folders/myfolders/CollegePlaying.csv"
	OUT = SAM.CollegePlaying
	DBMS = CSV
	REPLACE;
	
	GETNAMES = Yes;
	DATAROW = 2;
RUN;


FILENAME CSV;

PROC CONTENTS DATA = SAM.CollegePlaying;
QUIT;


FILENAME CSV "/folders/myfolders/CollegePlaying.csv" 
       TERMSTR=CRLF;
       

/* question 5 */
Proc Sql ;
	/* an inner join prior to a count filter on players by connecting collegePlaying to Schools, followed by a where (2009) and group by
	 (name) were used */
	
	select distinct B.name_full, Count(playerID) as Players_Sent
	from SAM.CollegePlaying A INNER JOIN SAM.Schools B on A.SchoolID = B.SchoolID
	Where A.yearID = 2009       
	Group By B.name_full
	;
	
quit;
   
       
/* Extra credit */       
Proc Sql ;
	/* We took all schools in the MIAA and pit them against each other, we checked the spelling using proc
		contents of the school dataset, some were not found at all but still kept in code for future proofing */
	select distinct B.name_full, Count(playerID) as Players_Sent
	from SAM.CollegePlaying A INNER JOIN SAM.Schools B on A.SchoolID = B.SchoolID
	
	/* this is the list from https://www.miaa.org/about_the_miaa/schools */
	Where B.name_full =  "Adrian College" or B.name_full = "Albion College" 
	or B.name_full = "Alma College" or B.name_full = "Calvin College" 
	or B.name_full = "Hope College" or B.name_full = "Kalamazoo College"
	or B.name_full = "Olivet College" or B.name_full =  "St. Mary's College" /* not Saint Mary's */
	or B.name_full = "Trine University" or B.name_full = "Finlandia University"
	
	Group By B.name_full
	Order by CALCULATED Players_Sent DESC
	;
quit;
       


