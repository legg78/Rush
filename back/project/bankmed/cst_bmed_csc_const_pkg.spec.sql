create or replace package cst_bmed_csc_const_pkg as
/*********************************************************
*  Custom Bankmed constants <br />
*  Created by Kolodkina Y. (kolodkina@bpcbt.com) at 09.09.2016 <br />
*  Module: cst_bmed_csc_const_pkg <br />
*  @headcom
**********************************************************/

IDENTIFIER_HEADER                     constant com_api_type_pkg.t_byte_char  := 'FH';
IDENTIFIER_TRAILER                    constant com_api_type_pkg.t_byte_char  := 'FT';

CSC_INST                              constant com_api_type_pkg.t_inst_id    := 5001;
CSC_NETWORK                           constant com_api_type_pkg.t_inst_id    := 5001;
PROCESSING_CENTER_INST                constant com_api_type_pkg.t_inst_id    := 1001;
CSC_FILE_TYPE                         constant com_api_type_pkg.t_dict_value := 'FLTPCSC';

PROC_CODE_ATM                         constant com_api_type_pkg.t_auth_code  := '012000';

FILE_LABEL                            constant com_api_type_pkg.t_dict_value := 'CSC LOG';

ACQUIRER_INST_ID                      constant com_api_type_pkg.t_cmid       := '9422052225';
NETWORK_ID_ACQUIRER                   constant com_api_type_pkg.t_curr_code  := 'CSC';
PR_PROC_ID                            constant com_api_type_pkg.t_auth_code  := 'PRC076';
PROC_ID_ACQUIRER                      constant com_api_type_pkg.t_auth_code  := 'CSC';
PROCESS_ID_ACQUIRER                   constant com_api_type_pkg.t_auth_code  := '$ADT13';
INST_ID_ISSUER                        constant com_api_type_pkg.t_cmid       := '00000000076';
PR_RPT_INST_ID_ISSUER                 constant com_api_type_pkg.t_cmid       := '00000000076';
AUTH_BY                               constant com_api_type_pkg.t_byte_char  := 'I';

CURRENCY_CODE_US_DOLLAR               constant com_api_type_pkg.t_curr_code  := '840'; -- USD
CURRENCY_CODE_LEBANESE_POUND          constant com_api_type_pkg.t_curr_code  := '422'; -- LBP

REPORT_MERCHANT_RATE_TYPE             constant com_api_type_pkg.t_dict_value := 'RTTPACQ';

ARRAY_ID_ACQ_FEE_OPER_TYPES           constant com_api_type_pkg.t_short_id   := -50000009;
	
STMT_BALANCE_WO_PAYMENT_CYCLE         constant com_api_type_pkg.t_dict_value := 'ACIL5003';
STMT_BALANCE_WO_FULL_CYCLE            constant com_api_type_pkg.t_dict_value := 'ACIL5004';

end;
/
