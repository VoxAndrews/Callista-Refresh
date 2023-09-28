SET SERVEROUTPUT ON

DECLARE
  IN_YEAR VARCHAR2(4);
  CLASSNAME VARCHAR2(50);
  CLASS_SEQNUM NUMBER;
  MIN_LENGTH NUMBER := 2;  -- minimum length of user string input
  MAX_LENGTH NUMBER := 20; -- maximum length of user string input
  input_err EXCEPTION;
  CAL_TYPE_NAME VARCHAR(10 BYTE) := NULL;
  
  
BEGIN
  -- Get user input for the year
  --DBMS_OUTPUT.PUT_LINE('Enter a year');
  --DBMS_OUTPUT.NEW_LINE;
  --ACCEPT NEW_YEAR VARCHAR(4) PROMPT 'Year: ';       ---not working, trying other method
  IN_YEAR :=: input_year;


  -- Check if the year is within an acceptable range (e.g., not a future year)
  IF TO_NUMBER(IN_YEAR) > EXTRACT(YEAR FROM SYSDATE) THEN
    DBMS_OUTPUT.PUT_LINE('Invalid year input. Please enter a year in the past or the current year.');
    RAISE input_err;
  END IF;
  
  
  -- Get user input for the CLASSNAME
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
  
  DBMS_OUTPUT.PUT_LINE('Year entered:  ' || IN_YEAR || '        Class entered:   ' || CLASSNAME);
  
  
  --get sequence number of CI record matching user input class and year
  SELECT CAL_INSTANCE.SEQUENCE_NUMBER INTO CLASS_SEQNUM          -- put SEQ_NUM data into CLASS_SEQNUM variable
  FROM CAL_INSTANCE
  WHERE UPPER(CAL_INSTANCE.CAL_TYPE) = UPPER(CLASSNAME)    --make both uppercase so case insensitive match
  AND EXTRACT(YEAR FROM CAL_INSTANCE.END_DT) = TO_NUMBER(IN_YEAR);   --get year from stored date, check if matches user input year
 
  DBMS_OUTPUT.PUT_LINE ('Sequence number: ' || CLASS_SEQNUM );
  DBMS_OUTPUT.PUT_LINE ('');
  
  
  FOR CI_record IN (SELECT DISTINCT SUB_CAL_TYPE  -- get list of unique calendar types for the above class
                  FROM CAL_INSTANCE_RELATIONSHIP
                  WHERE SUP_CI_SEQUENCE_NUMBER = CLASS_SEQNUM)
  LOOP 
    CAL_TYPE_NAME := CI_record.SUB_CAL_TYPE;
    DBMS_OUTPUT.PUT_LINE(CAL_TYPE_NAME);
  END LOOP;
  
  IF CAL_TYPE_NAME = NULL THEN
    DBMS_OUTPUT.PUT_LINE('No records found');
  END IF;
  
EXCEPTION
    WHEN input_err THEN
    DBMS_OUTPUT.PUT_LINE (SQLERRM);

END;
/