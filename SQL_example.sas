/********************************************************************
* Name: Homeowrk 4.sas                                              *
* Date: February 21, 2019                                           *
*                                                                   *
* Purpose: Will create a new dataset from newcompetitros.sas7bdat   *
*          that only includes small stores, cleans up existing      *
*          variables and adds in variables Country and Store_Code   *
*                                                                   *
* Output: The SAS dataset NewComp_SmallRet with observational units *
*         only from only competitors considered small with variables*
*         Store_Code, Country, City, and Postal_Code;               *
*                                                                   *
********************************************************************/

libname SAM '/folders/myfolders' ; /* specify library */

Data NewComp_SmallRet;
	Set SAM.Newcompetitors; /* set source for data for new sas data set named NewComp_SmallRet */
	 
	Country = Substr(ID,1,2); /* create country varible by substringing ID var */
	Store_Code = Substr(ID,3);
	Store_Code = Compress(Store_Code,''); /* same method for Store Code with the addition of the comprees function set to remove all trailing and leading spaces */
	City = Propcase(City); /* puts the city names in a way to conform with the modern english lexicon */
	
	Store_Size = Substr(Store_Code,1,1); /* create a new variable store size that is used purely for use in the upcoming delete function */
	Store_Size = put(Store_Size, 1.); /* make Store size numeric for ease of use in Flow of control statements */
	if Store_Size > 1 then Delete; /* removes all stores that are not small sized as per instructions */
	Drop Store_Size; /* drop store size from the output data as its purpose has been fulfilled */ 
	
proc print;
	VAR Store_Code Country City Postal_Code;
	