create or replace package prc_api_const_pkg as
/*********************************************************************
 * The API for process constants<br />
 * Created by Filimonov A.(filimonov@bpc.ru)  at 02.12.2010 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: PRC_API_CONST_PKG <br />
 * @headcom
 ********************************************************************/
FILE_PURPOSE_IN                constant    com_api_type_pkg.t_dict_value := 'FLPSINCM';
FILE_PURPOSE_OUT               constant    com_api_type_pkg.t_dict_value := 'FLPSOUTG';

FILE_STATUS_ACCEPTED           constant    com_api_type_pkg.t_dict_value := 'FLSTACPT';
FILE_STATUS_REJECTED           constant    com_api_type_pkg.t_dict_value := 'FLSTRJCT';
FILE_STATUS_POSTPONED          constant    com_api_type_pkg.t_dict_value := 'FLSTPOST';

EVENT_TYPE_PROCESS_SUCCESS     constant    com_api_type_pkg.t_dict_value := 'EVNT0400';
EVENT_TYPE_PROCESS_FAIL        constant    com_api_type_pkg.t_dict_value := 'EVNT0401';
EVENT_SEND_FILE_PASSWORD       constant    com_api_type_pkg.t_dict_value := 'EVNT0402';

EVENT_TYPE_FILE_PROCESSED      constant    com_api_type_pkg.t_dict_value := 'EVNT2013';
EVENT_TYPE_FILE_FAIL_PROCESS   constant    com_api_type_pkg.t_dict_value := 'EVNT2014';
EVENT_TYPE_FILE_GENERATED      constant    com_api_type_pkg.t_dict_value := 'EVNT2015';
EVENT_TYPE_FILE_FAIL_GENERATE  constant    com_api_type_pkg.t_dict_value := 'EVNT2016';

ENTITY_TYPE_PROCESS            constant    com_api_type_pkg.t_dict_value := 'ENTTPRCS';
ENTITY_TYPE_SESSION            constant    com_api_type_pkg.t_dict_value := 'ENTTSESS';
ENTITY_TYPE_SESSION_FILE       constant    com_api_type_pkg.t_dict_value := 'ENTTSSFL';
ENTITY_TYPE_FILE               constant    com_api_type_pkg.t_dict_value := 'ENTTFILE';
ENTITY_TYPE_FILE_ATTRIBUTE     constant    com_api_type_pkg.t_dict_value := 'ENTTFLAT';

PROCESS_RESULT_LOCKED          constant    com_api_type_pkg.t_dict_value := 'PRSR0000';
PROCESS_RESULT_IN_PROGRESS     constant    com_api_type_pkg.t_dict_value := 'PRSR0001';
PROCESS_RESULT_SUCCESS         constant    com_api_type_pkg.t_dict_value := 'PRSR0002';
PROCESS_RESULT_FAILED          constant    com_api_type_pkg.t_dict_value := 'PRSR0003';
PROCESS_RESULT_REJECTED        constant    com_api_type_pkg.t_dict_value := 'PRSR0004';
PROCESS_RESULT_AWAITS_POST     constant    com_api_type_pkg.t_dict_value := 'PRSR0005';

FILE_NATURE_XML                constant    com_api_type_pkg.t_dict_value := 'FLNT0010';
FILE_NATURE_PLAINTEXT          constant    com_api_type_pkg.t_dict_value := 'FLNT0020';
FILE_NATURE_CLOB               constant    com_api_type_pkg.t_dict_value := 'FLNT0030';
FILE_NATURE_REPORT             constant    com_api_type_pkg.t_dict_value := 'FLNT0040';
FILE_NATURE_BLOB               constant    com_api_type_pkg.t_dict_value := 'FLNT0050';
    
DEFAULT_THREAD                 constant    com_api_type_pkg.t_tiny_id    := -1;

DIRECTORY_ENCR                 constant    com_api_type_pkg.t_dict_value := 'DENCTRUE'; 
DIRECTORY_NOTENCR              constant    com_api_type_pkg.t_dict_value := 'DENCFLSE'; 

INCOM_FILE_REC_SUCCESS         constant    com_api_type_pkg.t_dict_value := 'IFRR0001';
INCOM_FILE_REC_ERROR           constant    com_api_type_pkg.t_dict_value := 'IFRR0002';

ENTITY_TYPE_RESPONSE           constant    com_api_type_pkg.t_dict_value := 'FLTPRSPF';

FILE_TYPE_CARD_RESPONSE        constant    com_api_type_pkg.t_dict_value := 'FLTPCRDR';

ARRAY_PROCESS_USES_MODIFIER    constant    com_api_type_pkg.t_short_id   := 10000081;

NAME_PART_FILE_COUNT           constant    com_api_type_pkg.t_name       := '((FILE_COUNT))';

FILE_MERGE_NOT_MERGE           constant    com_api_type_pkg.t_dict_value := 'FMMDNMRG';
FILE_MERGE_IN_SAME_THREAD      constant    com_api_type_pkg.t_dict_value := 'FMMDMTRD';
FILE_MERGE_IN_PROCESS          constant    com_api_type_pkg.t_dict_value := 'FMMDMPRC';

EXECUTION_MODE_PRE_PROCESS     constant    com_api_type_pkg.t_dict_value := 'EXEMPRE';
EXECUTION_MODE_PARALLEL        constant    com_api_type_pkg.t_dict_value := 'EXEMPARL';
EXECUTION_MODE_POST_PROCESS    constant    com_api_type_pkg.t_dict_value := 'EXEMPOST';
EXECUTION_MODE_USER_INST       constant    com_api_type_pkg.t_dict_value := 'EXEMUIM';

end prc_api_const_pkg;
/
