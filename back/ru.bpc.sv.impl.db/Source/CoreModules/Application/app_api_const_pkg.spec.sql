create or replace package app_api_const_pkg as
/*********************************************************
*  Application constant <br />
*  Created by Filimonov A.(filimonov@bpc.ru)  at 01.02.2010 <br />
*  Last changed by Gogolev I.(i.gogolev@bpcbt.com) <br />
*  06.10.2016 17:59:00                             <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: APP_API_CONST_PKG <br />
*  @headcom
**********************************************************/

APPL_STATUS_INITIAL             constant    com_api_type_pkg.t_dict_value   := 'APST0001';
APPL_STATUS_AWAITING_CONFIRM    constant    com_api_type_pkg.t_dict_value   := 'APST0002';
APPL_STATUS_PROC_READY          constant    com_api_type_pkg.t_dict_value   := 'APST0006';
APPL_STATUS_PROC_SUCCESS        constant    com_api_type_pkg.t_dict_value   := 'APST0007';
APPL_STATUS_PROC_FAILED         constant    com_api_type_pkg.t_dict_value   := 'APST0008';
APPL_STATUS_PROC_DUPLICATED     constant    com_api_type_pkg.t_dict_value   := 'APST0010';
APPL_STATUS_READY_FOR_REVIEW    constant    com_api_type_pkg.t_dict_value   := 'APST0011';
APPL_STATUS_ACCEPTED            constant    com_api_type_pkg.t_dict_value   := 'APST0012';
APPL_STATUS_REJECTED            constant    com_api_type_pkg.t_dict_value   := 'APST0013';
APPL_STATUS_PENDING             constant    com_api_type_pkg.t_dict_value   := 'APST0014';
APPL_STATUS_IN_PROGRESS         constant    com_api_type_pkg.t_dict_value   := 'APST0015';
APPL_STATUS_RESOLVED            constant    com_api_type_pkg.t_dict_value   := 'APST0016';
APPL_STATUS_CLOSED              constant    com_api_type_pkg.t_dict_value   := 'APST0017';
APPL_STATUS_PRIORITY_OK         constant    com_api_type_pkg.t_dict_value   := 'APST0019';
APPL_STATUS_PRIORITY_FAILED     constant    com_api_type_pkg.t_dict_value   := 'APST0020';
APPL_STATUS_CLOSED_WO_INV       constant    com_api_type_pkg.t_dict_value   := 'APST0021';

APPL_REJECT_CODE_UNRESOLVED     constant    com_api_type_pkg.t_dict_value   := 'APRJ0011';

APPL_ELEMENT_TYPE_COMPLEX       constant    com_api_type_pkg.t_dict_value   := 'COMPLEX';
APPL_ELEMENT_TYPE_SIMPLE        constant    com_api_type_pkg.t_dict_value   := 'SIMPLE';

APPL_ELEMENT_NAME_ERROR         constant    com_api_type_pkg.t_name         := 'ERROR';

ENTITY_TYPE_APPLICATION         constant    com_api_type_pkg.t_dict_value   := 'ENTTAPPL';

EVENT_APPL_CREATED              constant    com_api_type_pkg.t_dict_value   := 'EVNT0001';
EVENT_APPL_PROCESS_SUCCESS      constant    com_api_type_pkg.t_dict_value   := 'EVNT0002';
EVENT_APPL_PROCESS_FAILED       constant    com_api_type_pkg.t_dict_value   := 'EVNT0003';
EVENT_APPL_CUST_REJECTED        constant    com_api_type_pkg.t_dict_value   := 'EVNT0006';
EVENT_APPL_CHANGED              constant    com_api_type_pkg.t_dict_value   := 'EVNT1930';

FILE_TYPE_APP_RESPONSE          constant    com_api_type_pkg.t_dict_value   := 'FLTPAPRS';
FILE_TYPE_APP_XML               constant    com_api_type_pkg.t_dict_value   := 'FLTPAPPS';

APPL_TYPE_ACQUIRING             constant    com_api_type_pkg.t_dict_value   := 'APTPACQA';
APPL_TYPE_ISSUING               constant    com_api_type_pkg.t_dict_value   := 'APTPISSA';
APPL_TYPE_PAYMENT_ORDERS        constant    com_api_type_pkg.t_dict_value   := 'APTPPMNO';
APPL_TYPE_USER_MANAGEMENT       constant    com_api_type_pkg.t_dict_value   := 'APTPUMGT';
APPL_TYPE_DISPUTE               constant    com_api_type_pkg.t_dict_value   := 'APTPDSPT';
APPL_TYPE_FIN_REQUEST           constant    com_api_type_pkg.t_dict_value   := 'APTPFREQ';
APPL_TYPE_ISS_PRODUCT           constant    com_api_type_pkg.t_dict_value   := 'APTPIPRD';
APPL_TYPE_ACQ_PRODUCT           constant    com_api_type_pkg.t_dict_value   := 'APTPAPRD';
APPL_TYPE_INSTITUTION           constant    com_api_type_pkg.t_dict_value   := 'APTPINSA';
APPL_TYPE_QUESTIONARY           constant    com_api_type_pkg.t_dict_value   := 'APTPQSTN';
APPL_TYPE_CAMPAIGN              constant    com_api_type_pkg.t_dict_value   := 'APTPCMPN';

COMMAND_CREATE_OR_PROCEED       constant    com_api_type_pkg.t_dict_value   := 'CMMDCRPR';
COMMAND_CREATE_OR_UPDATE        constant    com_api_type_pkg.t_dict_value   := 'CMMDCRUP';
COMMAND_CREATE_OR_EXCEPT        constant    com_api_type_pkg.t_dict_value   := 'CMMDCREX';
COMMAND_EXCEPT_OR_UPDATE        constant    com_api_type_pkg.t_dict_value   := 'CMMDEXUP';
COMMAND_EXCEPT_OR_REMOVE        constant    com_api_type_pkg.t_dict_value   := 'CMMDEXRE';
COMMAND_EXCEPT_OR_PROCEED       constant    com_api_type_pkg.t_dict_value   := 'CMMDEXPR';
COMMAND_PROCEED_OR_REMOVE       constant    com_api_type_pkg.t_dict_value   := 'CMMDPRRE';

FLOW_STAGE_PROCESS_SUCCESS      constant    com_api_type_pkg.t_dict_value   := 'STRT0010';
FLOW_STAGE_PROCESS_FAIL         constant    com_api_type_pkg.t_dict_value   := 'STRT0020';

APPL_XMLNS                      constant    com_api_type_pkg.t_name         := 'http://sv.bpc.in/SVAP';

PROCESS_APPLICATION_FORCE       constant    com_api_type_pkg.t_short_id     := 10000444;
PRIV_VIEW_HIDDEN_DSP_APPLCTN    constant    com_api_type_pkg.t_short_id     := 10000461;

APPL_ACTION_DATA_CHANGE         constant    com_api_type_pkg.t_name         := 'APPL_DATA_CHANGE';
APPL_ACTION_STATUS_CHANGE       constant    com_api_type_pkg.t_name         := 'APPL_STATUS_CHANGE';
APPL_ACTION_REFUSE_OWNER        constant    com_api_type_pkg.t_name         := 'APPL_OWNER_REFUSE';

ELEMENT_DISPUTE_ID              constant    com_api_type_pkg.t_short_id     := 10003137;
ELEMENT_DISPUTE_REASON          constant    com_api_type_pkg.t_short_id     := 10003099;
ELEMENT_DISPUTE_PROGRESS        constant    com_api_type_pkg.t_short_id     := 10003138;
ELEMENT_CUSTOMER_NUMBER         constant    com_api_type_pkg.t_short_id     := 10000177;
ELEMENT_ACCOUNT_NUMBER          constant    com_api_type_pkg.t_short_id     := 10000075;
ELEMENT_CARD_NUMBER             constant    com_api_type_pkg.t_short_id     := 10000180;
ELEMENT_PRODUCT_ID              constant    com_api_type_pkg.t_short_id     := 10000016;
ELEMENT_AGENT_ID                constant    com_api_type_pkg.t_short_id     := 10000010;
ELEMENT_DUE_DATE                constant    com_api_type_pkg.t_short_id     := 10003161;
ELEMENT_MERCHANT_NAME           constant    com_api_type_pkg.t_short_id     := 10000144;
ELEMENT_DISPUTED_AMOUNT         constant    com_api_type_pkg.t_short_id     := 10003357;
ELEMENT_DISPUTED_CURRENCY       constant    com_api_type_pkg.t_short_id     := 10003358;
ELEMENT_CASE_PROGRESS           constant    com_api_type_pkg.t_short_id     := 10003409;
ELEMENT_REASON_CODE             constant    com_api_type_pkg.t_short_id     := 10003331;
ELEMENT_OPER_DATE               constant    com_api_type_pkg.t_short_id     := 10003100;
ELEMENT_OPER_AMOUNT             constant    com_api_type_pkg.t_short_id     := 10003101;
ELEMENT_OPER_CURRENCY           constant    com_api_type_pkg.t_short_id     := 10003102;
ELEMENT_USER_NAME               constant    com_api_type_pkg.t_short_id     := 10001171;
ELEMENT_PERSON_NAME             constant    com_api_type_pkg.t_short_id     := 10000142;
ELEMENT_COMPANY_NAME            constant    com_api_type_pkg.t_short_id     := 10000191;
ELEMENT_CONTRACT_NUMBER         constant    com_api_type_pkg.t_short_id     := 10000376;
ELEMENT_MERCHANT_NUMBER         constant    com_api_type_pkg.t_short_id     := 10000013;
ELEMENT_TERMINAL_NUMBER         constant    com_api_type_pkg.t_short_id     := 10000081;
ELEMENT_USER_ID                 constant    com_api_type_pkg.t_short_id     := 10003003;
ELEMENT_ROLE_ID                 constant    com_api_type_pkg.t_short_id     := 10003008;
ELEMENT_ROLE_NAME               constant    com_api_type_pkg.t_short_id     := 10003009;
ELEMENT_CARD_COUNT              constant    com_api_type_pkg.t_short_id     := 10000200;
ELEMENT_BATCH_CARD_COUNT        constant    com_api_type_pkg.t_short_id     := 10003087;
ELEMENT_APPLICATION             constant    com_api_type_pkg.t_short_id     := 10000001;
ELEMENT_CARDHOLDER_NAME         constant    com_api_type_pkg.t_short_id     := 10000175;
ELEMENT_OPERATION_TYPE          constant    com_api_type_pkg.t_short_id     := 10001715;
ELEMENT_OPERATION               constant    com_api_type_pkg.t_short_id     := 10003582;
ELEMENT_OPER_REASON             constant    com_api_type_pkg.t_short_id     := 10003119;
ELEMENT_CONTRACT_TYPE           constant    com_api_type_pkg.t_short_id     := 10000681;

LOV_ID_DISPUTE_FLOWS            constant    com_api_type_pkg.t_tiny_id      := 524;

FLOW_ID_ACQ_DISPUTE_DOMESTIC    constant    com_api_type_pkg.t_tiny_id      := 1504;
FLOW_ID_ACQ_DISPUTE_INTERNTNL   constant    com_api_type_pkg.t_tiny_id      := 1506;
FLOW_ID_ISS_DISPUTE_DOMESTIC    constant    com_api_type_pkg.t_tiny_id      := 1503;
FLOW_ID_ISS_DISPUTE_INTERNTNL   constant    com_api_type_pkg.t_tiny_id      := 1505;
FLOW_ID_DISPUTE_INTERNAL        constant    com_api_type_pkg.t_tiny_id      := 1502;
FLOW_ID_ISS_POOL_CARD           constant    com_api_type_pkg.t_tiny_id      := 1009;

ACCOUNT_DEFAULT_IN_CURRENCY     constant    com_api_type_pkg.t_dict_value   := 'ACLTDFCR';
DEFAULT_POS_IN_CURRENCY         constant    com_api_type_pkg.t_dict_value   := 'DFCRPSCR';
DEFAULT_ATM_IN_CURRENCY         constant    com_api_type_pkg.t_dict_value   := 'DFCRATCR';

CASE_RESOLUTION_REPRESENTED     constant    com_api_type_pkg.t_dict_value   := 'ACCR0008';
CASE_RESOLUTION_UNRESOLVED      constant    com_api_type_pkg.t_dict_value   := 'ACCR0011';
CASE_RESOLUTION_RESPONDED       constant    com_api_type_pkg.t_dict_value   := 'ACCR0012';
MAX_SEQ_NUMBER                  constant    com_api_type_pkg.t_tiny_id      := 9999;

APPL_CONTEXT_PROCESS            constant    com_api_type_pkg.t_dict_value   := 'ACTXPRC';
APPL_CONTEXT_MIGRATING          constant    com_api_type_pkg.t_dict_value   := 'ACTXMIGR';
APPL_CONTEXT_WEB_SERVICE        constant    com_api_type_pkg.t_dict_value   := 'ACTXWSRV';
APPL_CONTEXT_WEB_FORM           constant    com_api_type_pkg.t_dict_value   := 'ACTXFORM';

end app_api_const_pkg;
/
