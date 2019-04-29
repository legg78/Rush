create or replace package cst_ap_api_const_pkg is
/************************************************************
 * Processes for loading TP files <br />
 * Created by Vasilyeva Y.(vasilieva@bpcbt.com)  at 25.02.2019 <br />
 * Last changed by $Author: Vasilyeva Y. $ <br />
 * $LastChangedDate:: #$ <br />
 * Revision: $LastChangedRevision:  $ <br />
 * Module: cst_ap_api_const_pkg <br />
 * @headcom
 **********************************************************/
OPERATION_TYPE_CUSTOMS_PAYMENT  constant    com_api_type_pkg.t_dict_value   := 'OPTP5001';

AMOUNT_CARDHOLDER               constant    com_api_type_pkg.t_dict_value   := 'AMPR7205';
AMOUNT_INTERCHANGE              constant    com_api_type_pkg.t_dict_value   := 'AMPR7206';
AMOUNT_MERCHANT                 constant    com_api_type_pkg.t_dict_value   := 'AMPR7207';
AMOUNT_SATIM                    constant    com_api_type_pkg.t_dict_value   := 'AMPR7208';

CURRENCY_TP                     constant    com_api_type_pkg.t_curr_code    := '012';
CURRENCY_ALGERIAN_DINAR         constant    com_api_type_pkg.t_curr_code    := '012';

AP_INST_ID                      constant    com_api_type_pkg.t_inst_id      := '1001';
SAT_INST_ID                     constant    com_api_type_pkg.t_inst_id      := '1101';

STTT_US_ON_SATIM                constant    com_api_type_pkg.t_dict_value   := 'STTT5010';
STTT_SATIM_ON_US                constant    com_api_type_pkg.t_dict_value   := 'STTT5011';

NETWORK_ID                      constant    com_api_type_pkg.t_network_id   := '1001';
ADT                             constant    com_api_type_pkg.t_oracle_name  := 'INTER-ADT';
AST                             constant    com_api_type_pkg.t_oracle_name  := 'AVISSORTPOSITIF-INTER';

STATUS_TP_FILE_LOADED           constant    com_api_type_pkg.t_dict_value   := 'MTST5000'; -- "TP file loaded"
STATUS_RCP_FILE_LOADED          constant    com_api_type_pkg.t_dict_value   := 'MTST5001'; -- "RCP file load"
STATUS_ENV_FILE_UPL_NOT_CONF    constant    com_api_type_pkg.t_dict_value   := 'MTST5002'; -- "ENV file upload Not Confirmed"
ENV_LOADED                      constant    com_api_type_pkg.t_dict_value   := 'MTST5003'; -- "ENV file upload" -- STATUS_ENV_FILE_UPLOAD
CRO_ASP_PROCDESSED              constant    com_api_type_pkg.t_dict_value   := 'MTST5004'; -- "CRO-ASP processed"
CRO_ADT_PROCDESSED              constant    com_api_type_pkg.t_dict_value   := 'MTST5005'; -- "CRO-ADT processed"
STATUS_RCP_TRANS_ABSENT_IN_TP   constant    com_api_type_pkg.t_dict_value   := 'MTST5006'; -- "RCP transaction absent in TP"

FILE_OPERATION_TYPE_ATM         constant    com_api_type_pkg.t_byte_char    := '40';
FILE_OPERATION_TYPE_POS         constant    com_api_type_pkg.t_byte_char    := '50';
FILE_OPERATION_TYPE_REFUND      constant    com_api_type_pkg.t_byte_char    := '51';

FILE_REC_EXTENSION              constant    com_api_type_pkg.t_name         := 'REC';

ENV_EXPORT_SIGN                 constant    com_api_type_pkg.t_byte_char    := '1';
RCP_IMPORT_SIGN                 constant    com_api_type_pkg.t_byte_char    := '2';

OPER_TYPE_DEBIT_NOTIF           constant    com_api_type_pkg.t_dict_value   := 'OPTP0002';

PAYM_TYPE_PAYMENT               constant    com_api_type_pkg.t_byte_char    := '01';
PAYM_TYPE_CASH_ADVANCE          constant    com_api_type_pkg.t_byte_char    := '02';
PAYM_TYPE_BILL_PAYM_VIA_INT     constant    com_api_type_pkg.t_byte_char    := '03';
PAYM_TYPE_OTHER_PAYM_VIA_INT    constant    com_api_type_pkg.t_byte_char    := '04';
PAYM_TYPE_BILL_PAYM_VIA_POS     constant    com_api_type_pkg.t_byte_char    := '05';

FILETYPE_ENV_ATM                constant    com_api_type_pkg.t_dict_value   := 'FLTPENVA';
FILETYPE_ENV_POS                constant    com_api_type_pkg.t_dict_value   := 'FLTPENVP';
FILETYPE_ENV_REFUND             constant    com_api_type_pkg.t_dict_value   := 'FLTPENVR';

ENV_UPLOAD_DELAY                constant    com_api_type_pkg.t_byte_char    := 5;

TAG_SESSION_DAY                 constant    com_api_type_pkg.t_name         := 'CST_SESSION_DAY';

TAG_ID_ACQ_PART_CODE            constant    com_api_type_pkg.t_long_id      := 2001;
TAG_ID_ISS_PART_CODE            constant    com_api_type_pkg.t_long_id      := 2003;
TAG_ID_SESSION_DAY              constant    com_api_type_pkg.t_long_id      := 2005;

FILE_TYPE_SYNTI                 constant    com_api_type_pkg.t_dict_value   := 'FLTP5011';
FILE_TYPE_SYNTO                 constant    com_api_type_pkg.t_dict_value   := 'FLTP5012';
FILE_TYPE_SYNTR                 constant    com_api_type_pkg.t_dict_value   := 'FLTP5013';

SYNTI_IN_HEADER_SPEC            constant    com_api_type_pkg.t_dict_value   := 'SYNTI';
SYNTO_IN_HEADER_SPEC            constant    com_api_type_pkg.t_dict_value   := 'SYNTO';
SYNTR_IN_HEADER_SPEC            constant    com_api_type_pkg.t_dict_value   := 'SYNTR';

SESSION_CLOSE                   constant    com_api_type_pkg.t_sign         := 0;
SESSION_ACTIVE                  constant    com_api_type_pkg.t_sign         := 1;
SESSION_FUTURE                  constant    com_api_type_pkg.t_sign         := 2;

ARRAY_ID_TP_OPER_TYPE_SV_CODE   constant    com_api_type_pkg.t_long_id      := -50000071;

ENV_FILE_OPERATION_TYPE_PRES    constant    com_api_type_pkg.t_dict_value   := 'ENVOTPPR';
ENV_FILE_OPERATION_TYPE_REJECT  constant    com_api_type_pkg.t_dict_value   := 'ENVOTPRJ';

ENV_OPERATION_TYPE_CODE_PRES    constant    com_api_type_pkg.t_byte_char    := '21';
ENV_OPERATION_TYPE_CODE_REJECT  constant    com_api_type_pkg.t_byte_char    := '22';

TAG_CST_ISS_PART_CODE           constant    com_api_type_pkg.t_short_desc   := 'CST_ISS_PART_CODE';
TAG_CST_ACQ_PART_CODE           constant    com_api_type_pkg.t_short_desc   := 'CST_ACQ_PART_CODE';


RESP_CODE_ACCEPT                constant    com_api_type_pkg.t_dict_value   := 'RESP6000';
RESP_CODE_DOUBLE_OPERATION      constant    com_api_type_pkg.t_dict_value   := 'RESP6001';
RESP_CODE_INVALID_BANK_INFO     constant    com_api_type_pkg.t_dict_value   := 'RESP6002';
RESP_CODE_FRAUD_OPERATION       constant    com_api_type_pkg.t_dict_value   := 'RESP6008';
RESP_CODE_FRAUD_OPER_SUPCON     constant    com_api_type_pkg.t_dict_value   := 'RESP6009';
RESP_CODE_POS_BLOCK_ON_CARD     constant    com_api_type_pkg.t_dict_value   := 'RESP6501';
RESP_CODE_POS_CARD_LOCK         constant    com_api_type_pkg.t_dict_value   := 'RESP6502';
RESP_CODE_POS_UNAUTH_TRANS      constant    com_api_type_pkg.t_dict_value   := 'RESP6503';
RESP_CODE_POS_EXPIRED_CARD      constant    com_api_type_pkg.t_dict_value   := 'RESP6504';
RESP_CODE_POS_LATE_PRESENT      constant    com_api_type_pkg.t_dict_value   := 'RESP6505';
RESP_CODE_POS_PRESUM_OF_FRAUD   constant    com_api_type_pkg.t_dict_value   := 'RESP6506';
RESP_CODE_ATM_BLOCK_ON_CARD     constant    com_api_type_pkg.t_dict_value   := 'RESP6401';
RESP_CODE_ATM_CARD_LOCK         constant    com_api_type_pkg.t_dict_value   := 'RESP6402';
RESP_CODE_ATM_UNAUTH_TRANS      constant    com_api_type_pkg.t_dict_value   := 'RESP6403';
RESP_CODE_ATM_EXPIRED_CARD      constant    com_api_type_pkg.t_dict_value   := 'RESP6404';
RESP_CODE_ATM_LATE_PRESENT      constant    com_api_type_pkg.t_dict_value   := 'RESP6405';
RESP_CODE_ATM_PRESUM_OF_FRAUD   constant    com_api_type_pkg.t_dict_value   := 'RESP6406';
RESP_CODE_REF_BLOCK_ON_CARD     constant    com_api_type_pkg.t_dict_value   := 'RESP6511';
RESP_CODE_REF_CARD_LOCK         constant    com_api_type_pkg.t_dict_value   := 'RESP6512';
RESP_CODE_REF_UNAUTH_TRANS      constant    com_api_type_pkg.t_dict_value   := 'RESP6513';
RESP_CODE_REF_EXPIRED_CARD      constant    com_api_type_pkg.t_dict_value   := 'RESP6514';
RESP_CODE_REF_LATE_PRESENT      constant    com_api_type_pkg.t_dict_value   := 'RESP6515';
RESP_CODE_REF_PRESUM_OF_FRAUD   constant    com_api_type_pkg.t_dict_value   := 'RESP6516';

end cst_ap_api_const_pkg;
/
