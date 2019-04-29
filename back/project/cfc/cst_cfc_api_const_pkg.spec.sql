create or replace package cst_cfc_api_const_pkg as
/*********************************************************
*  CFC custom API constants <br />
*  Created by Gogolev I. (i.gogolev@bpcbt.com) at 14.11.2017 <br />
*  Module: CST_CFC_API_CONST_PKG <br />
*  @headcom
**********************************************************/

DEFAULT_INST                        constant    com_api_type_pkg.t_inst_id  := 1001;
DEBIT_CARD                          constant com_api_type_pkg.t_dict_value  := 'CFCHDEBT';
CREDIT_CARD                         constant com_api_type_pkg.t_dict_value  := 'CFCHCRDT';
CARD_STATUS_INSTANT_CARD            constant com_api_type_pkg.t_dict_value := 'CSTS0026';

CST_CUSTOMER_ID_TAG                 constant com_api_type_pkg.t_short_id    := 50000001;
CST_NATIONAL_ID_TAG                 constant com_api_type_pkg.t_short_id    := 50000002;
CST_ACCOUNT_HOLDER_NAME_TAG         constant com_api_type_pkg.t_short_id    := 50000003;
CST_PAYMENT_CHANNEL_TAG             constant com_api_type_pkg.t_short_id    := null;

CST_DATE_FORMAT                     constant com_api_type_pkg.t_name        := 'DD.MM.YYYY';
CST_SCR_DATE_FORMAT                 constant com_api_type_pkg.t_name        := 'DDMMYYYY';
CST_PRT_DATE_FORMAT                 constant com_api_type_pkg.t_name        := 'DD/MM/YYYY';

ARRAY_APPL_APPROVED_STATUSES        constant com_api_type_pkg.t_short_id    := 10000069;

WAIVE_INTEREST                      constant com_api_type_pkg.t_name        := 'WAIVE_INTEREST';
REVISED_BUCKET                      constant com_api_type_pkg.t_name        := 'Revised bucket';
CST_CFC_REVISED_BUCKET_PERIOD       constant com_api_type_pkg.t_name        := 'CST_CFC_REVISED_BUCKET_PERIOD';
CST_CFC_REVISED_BUCKET_VALUE        constant com_api_type_pkg.t_name        := 'CST_CFC_REVISED_BUCKET_VALUE';
CST_CFC_RESERVED_ACC_NUMBER         constant com_api_type_pkg.t_name        := 'CST_CFC_RESERVED_ACC_NUMBER';
CST_CFC_POOL_ACC_NUM_FORMAT         constant com_api_type_pkg.t_name        := 'CST_CFC_POOL_ACC_NUMBER_FORMAT';

-- Event type for custom configuration interest charging (Credit life cycle) for overdue accounts
OVERDUE_INTEREST_CHARGE_EVENT       constant com_api_type_pkg.t_dict_value  := 'EVNT5035';
DEBT_LEVEL_1                        constant com_api_type_pkg.t_dict_value  := 'DBTL0001';
DEBT_LEVEL_2                        constant com_api_type_pkg.t_dict_value  := 'DBTL0002';
DEBT_LEVEL_3                        constant com_api_type_pkg.t_dict_value  := 'DBTL0003';
DEBT_LEVEL_4                        constant com_api_type_pkg.t_dict_value  := 'DBTL0004';
DEBT_LEVEL_FLEXIBLE_FIELD           constant com_api_type_pkg.t_name        := 'CST_CFC_ACC_DEBT_LEVEL';
CARD_TEMPORARY_CREDIT_LIMIT         constant com_api_type_pkg.t_dict_value  := 'LMTP0141';
CREDIT_SERVICE_ID                   constant com_api_type_pkg.t_short_id    := 70000018;
CARD_MAINTENANCE_SERVICE_ID         constant com_api_type_pkg.t_short_id    := 70000002;

NAPAS_NETWORK_ID                    constant com_api_type_pkg.t_network_id  := 7003;
MACROS_DEBIT_OPR                    constant com_api_type_pkg.t_network_id  := 1004;
MACROS_DEBIT_FEE_OPR                constant com_api_type_pkg.t_network_id  := 1007;  

GL_ACC_NUM_DETAIL_FILE_HEADER       constant com_api_type_pkg.t_raw_data    :=
    'Acount_Number|Card_Number|National_ID|GL_Account|Name_of_Accounting|Transaction_Date|Posting_Date|Amount|Bucket|Indue_Overdue';
GL_ACC_BAL_DATA_FILE_HEADER         constant com_api_type_pkg.t_raw_data    :=
    'Acount_Number|Card_Number|National_ID|Product_Code|Term|Indue_Overdue|Risk_Group|Day_Past_Due|Interest_Rate|Outstanding_Principal|General_Provision|Specific_Provision|Interest|Available_Credit_Limit|Lended_Limit|ATM_Fee|Other_Fee|Off_Balance_Sheet_Principal|Off_Balance_Sheet_Interest|Off_Balance_Sheet_Fee|Recovery_Pincipal|Recovery_Interest|Recovery_Fee|Small_Debt|Overpayment|Debt_Sale_Principal|Debt_Sale_Interest|Debt_Sale_Fee|Risk_Group_Revised_Bucket|General_Provision_Revised_Bucket|Specific_Provision_Revised_Bucket';
SCORING_DATA_FILE_HEADER            constant com_api_type_pkg.t_raw_data    :=
    'Generate_Date|Customer_Number|Account_Number|Card_Mask|Category|Status|Card_Limit|Invoce_Date|Due_Date_Min_Amt_Due|Min_Amt_Due2|Exceed_Limit|Sub_Account|Sub_Account_Balance|ATM_Withdraw_Count|Pos_Count|All_Transaction_Count|ATM_Withdraw_Amt|POS_Amt|Total_Transaction_Amt|Daily_Repayment|Cycle_Repayment|Current_Dpd|Bucket|Revised_Bucket|Effective_Date|Expired_Date|Valid_Period|Reason|Highest_Bucket_01|Highest_Bucket_03|Highest_Bucket_06|Highest_Dpd|Cycle_Withdraw_Amt|Total_Debt_Amt|Cycle_Avg_Withdraw_Amt|Cycle_Daily_Avg_Usage|Life_Withdr_Amt|Life_Withdraw_Count|Avg_Withdraw|Daily_Usage|Monthly_Usage|Temp_Credit_Limit|Limit_Start_Date|Limit_End_Date|Card_Usage_Limit|Overdue_Interest|Indue_Interest';
COA_DATA_FILE_HEADER                constant com_api_type_pkg.t_raw_data    :=
    'Channel|Date|Account_Number|Status|Total_Payment|Lending_Payment|Principal_Payment|Overdue_Payment|Interest_Payment|Overdue_Interest_Payment|Fee_Payment|Over_Payment|Write-off_Principal_Payment|Write-off_Interest_Payment|Write-off_Fee_Payment|Small_Debt_Amount';
APPL_RESPOND_FILE_HEADER            constant com_api_type_pkg.t_raw_data    :=
    'Application_Number,Customer_ID,Result_Code,Card_Number,Account_Number,Expired_Date,Process_Error';
PAYMENT_BATCH_FILE_HEADER           constant com_api_type_pkg.t_raw_data    := 
    'National_ID,Customer_ID,Card_mask,Cardholder_Name,Account_Number,MAD1,Due_Date1,MAD2,Due_Date2,Total_Outstanding_balance,Last_Payment_Flag';

FLEX_ID_ISSUE_PLACE                 constant com_api_type_pkg.t_name        := 'CST_ID_ISSUE_PLACE';
FLEX_NET_SALARY                     constant com_api_type_pkg.t_name        := 'CST_NET_SALARY';
FLEX_EMPLOYED_DEPARTMENT            constant com_api_type_pkg.t_name        := 'CST_EMPLOYED_DEPARTMENT';
FLEX_CARD_SCHEME_NAME               constant com_api_type_pkg.t_name        := 'CST_CARD_SCHEME_NAME';
FLEX_CLIENT_TARIFF                  constant com_api_type_pkg.t_name        := 'CST_CLIENT_TARIFF';
FLEX_REFERENCE_NAME                 constant com_api_type_pkg.t_name        := 'CST_REFERENCE_NAME';
FLEX_REFERENCE_RELATION             constant com_api_type_pkg.t_name        := 'CST_REFERENCE_RELATION';
FLEX_REFERENCE_ADDRESS              constant com_api_type_pkg.t_name        := 'CST_REFERENCE_ADDRESS';
FLEX_REFERENCE_PHONE                constant com_api_type_pkg.t_name        := 'CST_REFERENCE_PHONE';
FLEX_IS_MAD_PAID                    constant com_api_type_pkg.t_name        := 'CST_CFC_IS_MAD_PAID';

BUNCH_GL_ROUTING                    constant com_api_type_pkg.t_name        := 'BUNCH_GL_ROUTING';
EVT_TYPE_UNLOADING_CARD_INFO        constant com_api_type_pkg.t_dict_value  := 'EVNT5013';

ENABLE_COLLECTION                   constant com_api_type_pkg.t_name        := 'CST_CFC_ENABLE_COLLECTION';
YES                                 constant com_api_type_pkg.t_dict_value  := 'BOOL0001';

CREDIT_STATEMENT_SUBJECT            constant com_api_type_pkg.t_name        := 'CST_CREDIT_STATEMENT_SUBJECT';
EXTRA_DUE_DATE_SHIFT                constant com_api_type_pkg.t_tiny_id     := 1;

CR_ADJ_OVERDRAFT_BAL                constant com_api_type_pkg.t_dict_value  := 'DCAR0001';
CR_ADJ_OVERDUE_BAL                  constant com_api_type_pkg.t_dict_value  := 'DCAR0002'; 
CR_ADJ_INTEREST_BAL                 constant com_api_type_pkg.t_dict_value  := 'DCAR0003';
CR_ADJ_OVERDUE_INTEREST_BAL         constant com_api_type_pkg.t_dict_value  := 'DCAR0004';
CR_ADJ_FEE_BAL                      constant com_api_type_pkg.t_dict_value  := 'DCAR0005';

end cst_cfc_api_const_pkg;
/
