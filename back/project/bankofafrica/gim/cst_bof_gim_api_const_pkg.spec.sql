create or replace package cst_bof_gim_api_const_pkg as

MODULE_CODE_GIM                 constant com_api_type_pkg.t_module_code := 'GIM';

GIM_INST                        constant com_api_type_pkg.t_inst_id     := 5012;
GIM_NETWORK_ID                  constant com_api_type_pkg.t_tiny_id     := 5012;
GIM_STANDARD_ID                 constant com_api_type_pkg.t_tiny_id     := 5001;
GIM_HOST_ID                     constant com_api_type_pkg.t_tiny_id     := -5002;

TC_SALES                        constant varchar2(2) := '05';
TC_VOUCHER                      constant varchar2(2) := '06';
TC_CASH                         constant varchar2(2) := '07';
TC_SALES_CHARGEBACK             constant varchar2(2) := '15';
TC_VOUCHER_CHARGEBACK           constant varchar2(2) := '16';
TC_CASH_CHARGEBACK              constant varchar2(2) := '17';
TC_SALES_CHARGEBACK_REV         constant varchar2(2) := '35';
TC_VOUCHER_CHARGEBACK_REV       constant varchar2(2) := '36';
TC_CASH_CHARGEBACK_REV          constant varchar2(2) := '37';

TC_SALES_REVERSAL               constant varchar2(2) := '25';
TC_VOUCHER_REVERSAL             constant varchar2(2) := '26';
TC_CASH_REVERSAL                constant varchar2(2) := '27';

TC_MONEY_TRANSFER               constant varchar2(2) := '09';
TC_MONEY_TRANSFER2              constant varchar2(2) := '19';
TC_FEE_COLLECTION               constant varchar2(2) := '10';
TC_FUNDS_DISBURSEMENT           constant varchar2(2) := '20';

TC_FRAUD_ADVICE                 constant varchar2(2) := '40';
TC_TRANSACTION_ADVICE           constant varchar2(2) := '49';

TC_FILE_HEADER                  constant varchar2(2) := '90';
TC_FILE_TRAILER                 constant varchar2(2) := '91';
TC_FM_HEADER                    constant varchar2(2) := '92';
TC_FM_TRAILER                   constant varchar2(2) := '93';
TC_FV_HEADER                    constant varchar2(2) := '94';
TC_FV_TRAILER                   constant varchar2(2) := '95';
TC_FMC_HEADER                   constant varchar2(2) := '96';
TC_FMC_TRAILER                  constant varchar2(2) := '97';
TC_FL_HEADER                    constant varchar2(2) := '98';
TC_FL_TRAILER                   constant varchar2(2) := '99';
TC_FSW_HEADER                   constant varchar2(2) := '80';
TC_FSW_TRAILER                  constant varchar2(2) := '81';

TC_REQUEST_ORIGINAL_PAPER       constant varchar2(2) := '51';
TC_REQUEST_FOR_PHOTOCOPY        constant varchar2(2) := '52';
TC_MAILING_CONFIRMATION         constant varchar2(2) := '53';

TT_CHRGBCK_REMITTANCE           constant cst_bof_gim_api_type_pkg.t_transaction_type := '00';
TT_CHRGBCK_CARDLESS_WITHDRAWAL  constant cst_bof_gim_api_type_pkg.t_transaction_type := '01';
TT_CHRGBCK_PURCHASE             constant cst_bof_gim_api_type_pkg.t_transaction_type := '02';
TT_CHRGBCK_CREDIT_VOUCHER       constant cst_bof_gim_api_type_pkg.t_transaction_type := '03';
TT_CHRGBCK_CASH_ADVANCE         constant cst_bof_gim_api_type_pkg.t_transaction_type := '07';
TT_CHRGBCK_WITHDRAWAL           constant cst_bof_gim_api_type_pkg.t_transaction_type := '08';

CMID                            constant com_api_type_pkg.t_name := 'CST_BOF_GIM_ACQ_PROC_BIN';
ACQ_BUSINESS_ID                 constant com_api_type_pkg.t_name := 'CST_BOF_GIM_ACQ_BUSINESS_ID';

GIM_RATE_TYPE                   constant com_api_type_pkg.t_dict_value  := 'RTTPGIMR';
FILE_TYPE_CLEARING_GIM          constant com_api_type_pkg.t_dict_value  := 'FLTP5561';

MCC_ATM                         constant com_api_type_pkg.t_mcc         := '6011';

GIM_CURR_CODE                   constant com_api_type_pkg.t_curr_code   := '952'; -- XOF - Central African CFA franc

DSP_ITEM_RVRSL_ON_FIRST_PRES    constant binary_integer := 1; -- Reversal on First Presentment
DSP_ITEM_FIRST_CHARGEBACK       constant binary_integer := 2; -- Chargeback on TC05, TC06, TC07
DSP_ITEM_SECOND_PRESENTMENT     constant binary_integer := 3; -- Second Presentment on TC05, TC06, TC07
DSP_ITEM_RVRSL_ON_SECOND_PRES   constant binary_integer := 4; -- Reversal on Second Presentment
DSP_ITEM_RVRSL_ON_PRES_CHRGBCK  constant binary_integer := 5; -- Presentment Chargeback Reversal
DSP_ITEM_SECOND_PRES_CHRGBCK    constant binary_integer := 6; -- Chargeback on Second Presentment

ARRAY_TYPE_GIM_PMNT_PROD_INDX   constant com_api_type_pkg.t_tiny_id     := -5024;

ARRAY_GIM_PMNT_PROD_INDX        constant com_api_type_pkg.t_short_id    := -50000055;

g_default_charset               com_api_type_pkg.t_oracle_name;
function init_default_charset return com_api_type_pkg.t_oracle_name;

end;
/
