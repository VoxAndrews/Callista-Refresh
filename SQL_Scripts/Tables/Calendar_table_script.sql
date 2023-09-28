
CREATE TABLE CAL_INSTANCE
(
  CAL_TYPE                   VARCHAR2(10 BYTE)  NOT NULL,
  SEQUENCE_NUMBER            NUMBER(6)          NOT NULL,
  START_DT                   DATE               NOT NULL,
  END_DT                     DATE               NOT NULL,
  CAL_STATUS                 VARCHAR2(10 BYTE)  NOT NULL,
  ALTERNATE_CODE             VARCHAR2(10 BYTE),
  SUP_CAL_STATUS_DIFFER_IND  VARCHAR2(1 BYTE)   DEFAULT 'N'                   NOT NULL,
  UPDATE_WHO                 VARCHAR2(30 BYTE)  DEFAULT SYS_CONTEXT('CALLISTA_CTX','USERNAME') NOT NULL,
  UPDATE_ON                  DATE               DEFAULT SYSDATE               NOT NULL,
  PRIOR_CI_SEQUENCE_NUMBER   NUMBER(6),
  EXPLANATION                VARCHAR2(2000 BYTE)
)


CREATE TABLE CAL_INSTANCE_RELATIONSHIP
(
  SUB_CAL_TYPE             		 VARCHAR2(10 BYTE)     NOT NULL,
  SUB_CI_SEQUENCE_NUMBER    NUMBER(6)           	NOT NULL,
  SUP_CAL_TYPE              		 VARCHAR2(10 BYTE)     NOT NULL,
  SUP_CI_SEQUENCE_NUMBER    NUMBER(6)                     NOT NULL,
  LOAD_RESEARCH_PERCENTAGE                                          NUMBER(5,2),
  UPDATE_ON                                    DATE                               DEFAULT SYSDATE               NOT NULL,
  UPDATE_WHO                                 VARCHAR2(30 BYTE)   DEFAULT SYS_CONTEXT('CALLISTA_CTX','USERNAME') NOT NULL
)
