SET SERVEROUTPUT ON

-------------------------------------------------------
--Input: class 1 or class 2, and the year you want to add records for

-- Cal_Instance records needed for it to work:
--- class future year
--- class past year
--- teaching periods past year
--- teaching periods future year

-- Cal_Instance_Relationships needed:
--- teaching periods/class past year

--'future' year is the one you enter
--'past' is future - 1

-------------------------------------------------------

DECLARE
  IN_YEAR VARCHAR2(4);
  CLASSNAME VARCHAR2(50);
  CLASS_SEQNUM_OLD NUMBER := NULL;
  CLASS_SEQNUM_NEW NUMBER := NULL;
  MIN_LENGTH NUMBER := 2;  -- minimum length of user string input
  MAX_LENGTH NUMBER := 20; -- maximum length of user string input
  input_err EXCEPTION;
  CAL_TYPE_NAME VARCHAR(10 BYTE) := NULL;
  i NUMBER := 0;
  
BEGIN

-----------------------------------------------------------------
-- user input for testing
-----------------------------------------------------------------

  -- Get user input for the year to be added
  IN_YEAR :=: input_year;

  -- Check if the year is within an acceptable range (e.g., not a past year)
 -- IF TO_NUMBER(IN_YEAR) < EXTRACT(YEAR FROM SYSDATE) THEN
 --   DBMS_OUTPUT.PUT_LINE('Invalid year input. Please enter a future or current year.');
  --  RAISE input_err;
  --END IF;
    
  -- Get user input for the CLASSNAME to be added
  CLASSNAME :=: classname;
    
  -- Trim leading and trailing whitespace and validate length
  CLASSNAME := TRIM(BOTH ' ' FROM CLASSNAME);
  
  -- Validate input length (adjust the length as needed)
  IF LENGTH(CLASSNAME) > MAX_LENGTH THEN
    DBMS_OUTPUT.PUT_LINE('Class name is too long. Maximum length is '|| MAX_LENGTH ||' characters.');
    RAISE input_err;
  END IF;

  IF LENGTH(CLASSNAME) < MIN_LENGTH THEN
    DBMS_OUTPUT.PUT_LINE('Class name must have at least ' || MIN_LENGTH || ' non-whitespace characters.');
    RAISE input_err;
  END IF;
  
  DBMS_OUTPUT.PUT_LINE('Year to add:  ' || IN_YEAR || '        Class to add:   ' || CLASSNAME);
  
  
  
-----------------------------------------------------------------
-- get teaching periods for the Class
-----------------------------------------------------------------
    --get sequence number of CI record matching user input class and new year
  SELECT CAL_INSTANCE.SEQUENCE_NUMBER INTO CLASS_SEQNUM_NEW         
  FROM CAL_INSTANCE
  WHERE UPPER(CAL_INSTANCE.CAL_TYPE) = UPPER(CLASSNAME)   
  AND EXTRACT(YEAR FROM CAL_INSTANCE.END_DT) = TO_NUMBER(IN_YEAR);          --get current input year
  
  
  --get sequence number of CI record matching user input class and previous year
  SELECT CAL_INSTANCE.SEQUENCE_NUMBER INTO CLASS_SEQNUM_OLD                 -- put SEQ_NUM data into CLASS_SEQNUM_OLD variable
  FROM CAL_INSTANCE
  WHERE UPPER(CAL_INSTANCE.CAL_TYPE) = UPPER(CLASSNAME)                     --make both uppercase so case insensitive match
  AND EXTRACT(YEAR FROM CAL_INSTANCE.END_DT) = (TO_NUMBER(IN_YEAR) - 1);    --get previous year from stored date, check if matches user input year



  IF  CLASS_SEQNUM_OLD IS NULL THEN
    DBMS_OUTPUT.PUT_LINE('No data found for the previous year''s class.');
    RAISE input_err;
  ELSE 
    DBMS_OUTPUT.PUT_LINE ('');
    DBMS_OUTPUT.PUT_LINE ('Previous year found, sequence number: ' || CLASS_SEQNUM_OLD );
  END IF;
   
  IF  CLASS_SEQNUM_NEW IS NULL THEN
    DBMS_OUTPUT.PUT_LINE('No data found for the future year''s class.');
    RAISE input_err;
  ELSE 
    DBMS_OUTPUT.PUT_LINE ('Future year found, sequence number: ' || CLASS_SEQNUM_NEW );
    DBMS_OUTPUT.PUT_LINE ('');
  END IF;
 
  
  FOR CI_Class IN (SELECT DISTINCT SUB_CAL_TYPE                -- get list of unique calendar types based on old version of class
                  FROM CAL_INSTANCE_RELATIONSHIP
                  WHERE SUP_CI_SEQUENCE_NUMBER = CLASS_SEQNUM_OLD)
  LOOP 
    CAL_TYPE_NAME := CI_Class.SUB_CAL_TYPE;
    --DBMS_OUTPUT.PUT_LINE(CAL_TYPE_NAME);
 
	FOR CI_TP IN (SELECT CAL_TYPE, SEQUENCE_NUMBER, END_DT     -- get new versions of teaching periods that match cal_type and new year
						FROM CAL_INSTANCE
						WHERE CAL_TYPE = CAL_TYPE_NAME
						AND EXTRACT(YEAR FROM END_DT) = TO_NUMBER(IN_YEAR))
	LOOP
--      uncomment to print full list of insert statements 
--		DBMS_OUTPUT.PUT_LINE('INSERT INTO CAL_INSTANCE_RELATIONSHIP (SUP_CAL_TYPE, SUP_CI_SEQUENCE_NUMBER, SUB_CAL_TYPE, SUB_CI_SEQUENCE_NUMBER, UPDATE_WHO)
--      VALUES (UPPER(CLASSNAME), CLASS_SEQNUM, CI_TP.CAL_TYPE, CI_TP.SEQUENCE_NUMBER, ''test_output'');');
      INSERT INTO CAL_INSTANCE_RELATIONSHIP (SUP_CAL_TYPE, SUP_CI_SEQUENCE_NUMBER, SUB_CAL_TYPE, SUB_CI_SEQUENCE_NUMBER, UPDATE_WHO)
        VALUES (UPPER(CLASSNAME), CLASS_SEQNUM_NEW, CI_TP.CAL_TYPE, CI_TP.SEQUENCE_NUMBER, 'test_output');
      i := i+ 1;  
	END LOOP;	
  END LOOP;
  
  
  IF CAL_TYPE_NAME IS NULL THEN 
    DBMS_OUTPUT.PUT_LINE('No matching teaching periods found');
  ELSE
    DBMS_OUTPUT.PUT_LINE( i || ' rows entered into CAL_INSTANCE_RELATIONSHIP');
  END IF;
 
 
  COMMIT;
  
  
EXCEPTION
  WHEN input_err THEN
    BEGIN
      DBMS_OUTPUT.PUT_LINE (SQLERRM);
      ROLLBACK;
    END;    
    
END;
/