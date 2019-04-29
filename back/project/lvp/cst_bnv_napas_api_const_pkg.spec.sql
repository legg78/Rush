create or replace package cst_bnv_napas_api_const_pkg as

MODULE_CODE_BNV                 constant com_api_type_pkg.t_module_code := 'BNV';

BNV_INST                        constant com_api_type_pkg.t_inst_id     := 5015;
BNV_NETWORK_ID                  constant com_api_type_pkg.t_tiny_id     := 5015;
BNV_STANDARD_ID                 constant com_api_type_pkg.t_tiny_id     := 5004;

TC_FILE_HEADER                  constant varchar2(2) := 'HR';
TC_FILE_TRAILER                 constant varchar2(2) := 'TR';
TC_DRAFT                        constant varchar2(2) := 'DR';

CMID                            constant com_api_type_pkg.t_name := 'CST_NAPAS_BANK_CODE';

BNV_CURR_CODE                   constant com_api_type_pkg.t_curr_code   := '704'; -- VND - Viet nam dong

MSG_STATUS_LOADED               constant com_api_type_pkg.t_dict_value := 'CLMS0040';
MSG_STATUS_RECONCILED           constant com_api_type_pkg.t_dict_value := 'CLMS0110';
MSG_STATUS_NOT_FOUND_IN_NAPAS   constant com_api_type_pkg.t_dict_value := 'CLMS0230';
MSG_STATUS_NOT_FOUND_IN_SV      constant com_api_type_pkg.t_dict_value := 'CLMS0220';
MSG_STATUS_DIFFERENCE           constant com_api_type_pkg.t_dict_value := 'CLMS0150';
MSG_STATUS_DISPUTE              constant com_api_type_pkg.t_dict_value := 'CLMS0130';

MCC_ATM                         constant com_api_type_pkg.t_mcc := '6011';

XML_DATETIME_FORMAT             constant com_api_type_pkg.t_name := 'dd/mm/yyyy hh24:mi:ss';

FILE_TYPE_RECON_INCOMING        constant com_api_type_pkg.t_dict_value   := 'FLTPLVBP';
FILE_TYPE_RECON_ISS             constant com_api_type_pkg.t_dict_value   := 'FLTPBNVI';
FILE_TYPE_RECON_ACQ             constant com_api_type_pkg.t_dict_value   := 'FLTPBNVA';
FILE_TYPE_RECON_BNB             constant com_api_type_pkg.t_dict_value   := 'FLTPBNVB';

PARTICIPANT_TYPE_ISS            constant varchar2(3) := 'ISS';
PARTICIPANT_TYPE_ACQ            constant varchar2(3) := 'ACQ';
PARTICIPANT_TYPE_BNB            constant varchar2(3) := 'BNB';

end;
/
