create or replace package cst_woo_const_pkg as
/************************************************************
 * All constants for Woori bank custom packages    <br />
 * Created by:
    Chau Huynh (huynh@bpcbt.com)
    Man Do     (m.do@bpcbt.com)  at 2017-03-03     <br />
 * Last changed by $Author: Man Do               $ <br />
 * $LastChangedDate:        2017-10-24 15:00     $ <br />
 * Revision: $LastChangedRevision:  507          $ <br />
 * Module: CST_WOO_CONST_PKG <br />
 * @headcom
 *************************************************************/

    W_INST                          constant com_api_type_pkg.t_inst_id         := 1001;
    W_BANK_CODE                     constant com_api_type_pkg.t_dict_value      := 'W5970';
    F_HEADER                        constant com_api_type_pkg.t_dict_value      := 'HEADER';

    VIRT_ACC_INDEX_RANGE_ID         constant com_api_type_pkg.t_short_id        := -50000010;
    VIRT_ACC_RANGE_ID_CREDIT        constant com_api_type_pkg.t_short_id        := -50000019;
    VIRT_ACC_RANGE_ID_PREPAID       constant com_api_type_pkg.t_short_id        := -50000020;
    FILE_ID_45                      constant com_api_type_pkg.t_short_id        := -5050;
    FILE_ID_451                     constant com_api_type_pkg.t_short_id        := -5051;
    FILE_ID_46                      constant com_api_type_pkg.t_short_id        := -5052;
    FILE_ID_49                      constant com_api_type_pkg.t_short_id        := -5053;
    FILE_ID_51                      constant com_api_type_pkg.t_short_id        := -5054;
    FILE_ID_52                      constant com_api_type_pkg.t_short_id        := -5055;
    FILE_ID_53                      constant com_api_type_pkg.t_short_id        := -5056;
    FILE_ID_56                      constant com_api_type_pkg.t_short_id        := -5057;
    FILE_ID_58                      constant com_api_type_pkg.t_short_id        := -5058;
    FILE_ID_60                      constant com_api_type_pkg.t_short_id        := -5059;
    FILE_ID_61                      constant com_api_type_pkg.t_short_id        := -5060;
    FILE_ID_64                      constant com_api_type_pkg.t_short_id        := -5061;
    FILE_ID_66                      constant com_api_type_pkg.t_short_id        := -5062;
    FILE_ID_72                      constant com_api_type_pkg.t_short_id        := -5063;
    FILE_ID_75                      constant com_api_type_pkg.t_short_id        := -5064;
    FILE_ID_83                      constant com_api_type_pkg.t_short_id        := -5065;
    FILE_ID_87                      constant com_api_type_pkg.t_short_id        := -5066;
    FILE_ID_88                      constant com_api_type_pkg.t_short_id        := -5067;
    FILE_ID_89                      constant com_api_type_pkg.t_short_id        := -5068;
    FILE_ID_92                      constant com_api_type_pkg.t_short_id        := -5069;
    FILE_ID_99                      constant com_api_type_pkg.t_short_id        := -5070;
    FILE_ID_110                     constant com_api_type_pkg.t_short_id        := -5071;
    FILE_ID_62                      constant com_api_type_pkg.t_short_id        := -5072;
    FILE_ID_83_1                    constant com_api_type_pkg.t_short_id        := -5073;
    FILE_ID_65_1                    constant com_api_type_pkg.t_short_id        := -5074;
    FILE_ID_73_1                    constant com_api_type_pkg.t_short_id        := -5075;
    FILE_ID_78_1                    constant com_api_type_pkg.t_short_id        := -5076;
    FILE_ID_134                     constant com_api_type_pkg.t_short_id        := -5077;
    FILE_ID_137                     constant com_api_type_pkg.t_short_id        := -5078;
    FILE_ID_131                     constant com_api_type_pkg.t_short_id        := -5079;
    FILE_ID_133                     constant com_api_type_pkg.t_short_id        := -5080;
    FILE_ID_126                     constant com_api_type_pkg.t_short_id        := -5086;
    FILE_ID_93                      constant com_api_type_pkg.t_short_id        := -5090;

    FILE_JOB_45                     constant com_api_type_pkg.t_dict_value      := 'O28338V';
    FILE_JOB_451                    constant com_api_type_pkg.t_dict_value      := 'O28208V';
    FILE_JOB_46                     constant com_api_type_pkg.t_dict_value      := 'O28338V';
    FILE_JOB_49                     constant com_api_type_pkg.t_dict_value      := 'J28360V'; --updated 27.06.2017 Defect No.15
    FILE_JOB_51                     constant com_api_type_pkg.t_dict_value      := 'O28309V';
    FILE_JOB_52                     constant com_api_type_pkg.t_dict_value      := 'O28345V';
    FILE_JOB_53                     constant com_api_type_pkg.t_dict_value      := 'O28308V';
    FILE_JOB_56                     constant com_api_type_pkg.t_dict_value      := 'O28215V';
    FILE_JOB_58                     constant com_api_type_pkg.t_dict_value      := 'O28214V';
    FILE_JOB_60                     constant com_api_type_pkg.t_dict_value      := 'O28341V';
    FILE_JOB_61                     constant com_api_type_pkg.t_dict_value      := 'O28208V';
    FILE_JOB_62                     constant com_api_type_pkg.t_dict_value      := 'O28341V';
    FILE_JOB_64                     constant com_api_type_pkg.t_dict_value      := 'O28208V';
    FILE_JOB_66                     constant com_api_type_pkg.t_dict_value      := 'O28208V';
    FILE_JOB_72                     constant com_api_type_pkg.t_dict_value      := 'O28208V';
    FILE_JOB_75                     constant com_api_type_pkg.t_dict_value      := 'O28350V';
    FILE_JOB_83                     constant com_api_type_pkg.t_dict_value      := 'O28364V';
    FILE_JOB_87                     constant com_api_type_pkg.t_dict_value      := 'O28346V';
    FILE_JOB_88                     constant com_api_type_pkg.t_dict_value      := 'O28342V';
    FILE_JOB_89                     constant com_api_type_pkg.t_dict_value      := 'O28211V';
    FILE_JOB_92                     constant com_api_type_pkg.t_dict_value      := 'O28331V';
    FILE_JOB_99                     constant com_api_type_pkg.t_dict_value      := 'O28399V';
    FILE_JOB_110                    constant com_api_type_pkg.t_dict_value      := 'O28335V';
    FILE_JOB_83_1                   constant com_api_type_pkg.t_dict_value      := 'O28363V';
    FILE_JOB_65_1                   constant com_api_type_pkg.t_dict_value      := 'O28208V';
    FILE_JOB_73_1                   constant com_api_type_pkg.t_dict_value      := 'O28208V';
    FILE_JOB_78_1                   constant com_api_type_pkg.t_dict_value      := 'O28208V';
    FILE_JOB_134                    constant com_api_type_pkg.t_dict_value      := 'O28208V';
    FILE_JOB_137                    constant com_api_type_pkg.t_dict_value      := 'O28208V';
    FILE_JOB_131                    constant com_api_type_pkg.t_dict_value      := 'O28351V';
    FILE_JOB_133                    constant com_api_type_pkg.t_dict_value      := 'O28352V';
    FILE_JOB_126                    constant com_api_type_pkg.t_dict_value      := 'O28207V';
    FILE_JOB_93                     constant com_api_type_pkg.t_dict_value      := 'O28332V';

    DEBIT_CARD                      constant com_api_type_pkg.t_dict_value      := 'CFCHDEBT';
    CREDIT_CARD                     constant com_api_type_pkg.t_dict_value      := 'CFCHCRDT';
    VIRTUAL_CARD                    constant com_api_type_pkg.t_dict_value      := 'CFCHVIRT';
    PREPAID_CARD                    constant com_api_type_pkg.t_dict_value      := 'CFCHPRPD';

    PASSPORT                        constant com_api_type_pkg.t_dict_value      := 'IDTP0001';  --Passport
    FOREIGN_PASSPORT                constant com_api_type_pkg.t_dict_value      := 'IDTP0002';  --Foreign passport
    FAMILY_BOOK_ID                  constant com_api_type_pkg.t_dict_value      := 'IDTP0004';  --Family Book ID
    RESIDENT_BOOK                   constant com_api_type_pkg.t_dict_value      := 'IDTP0006';  --Resident Book
    BIRTH_CERT                      constant com_api_type_pkg.t_dict_value      := 'IDTP0030';  --Birth Certificate
    EMP_ID                          constant com_api_type_pkg.t_dict_value      := 'IDTP0044';  --Employee ID
    NATIONAL_ID                     constant com_api_type_pkg.t_dict_value      := 'IDTP0045';  --National ID

    SOCIAL_ID_NUM                   constant com_api_type_pkg.t_dict_value      := 'IDTP5001';  --Social ID Number
    OLD_SOCIAL_ID_NUM               constant com_api_type_pkg.t_dict_value      := 'IDTP5002';  --Old Social ID Number
    VISA_NUM                        constant com_api_type_pkg.t_dict_value      := 'IDTP5003';  --VISA Number
    TEMP_RESIDENT_NUM               constant com_api_type_pkg.t_dict_value      := 'IDTP5004';  --Temporary Resident Card Number
    KOREAN_ID_NUM                   constant com_api_type_pkg.t_dict_value      := 'IDTP5005';  --Korean ID Number
    BUSINESS_REG_NUM                constant com_api_type_pkg.t_dict_value      := 'IDTP5006';  --Business Registration Number
    HEAD_BUSSINESS_REG_NUM          constant com_api_type_pkg.t_dict_value      := 'IDTP5007';  --Head Quarter Business Registration Number
    SEAL_CERT_NUM                   constant com_api_type_pkg.t_dict_value      := 'IDTP5008';  --Seal Certificate number
    INVEST_LICENCE_NUM              constant com_api_type_pkg.t_dict_value      := 'IDTP5009';  --Investment license Number
    OPERATION_PERMIT                constant com_api_type_pkg.t_dict_value      := 'IDTP5010';  --Operation Permit from Authorities
    CERT_INCORP_NUM                 constant com_api_type_pkg.t_dict_value      := 'IDTP5011';  --Certificate of Incorporation Number

    ACCT_TYPE_SAVING_VND            constant com_api_type_pkg.t_dict_value      := 'ACTP0131';  --Saving Account VND
    ACCT_TYPE_PREPAID_VND           constant com_api_type_pkg.t_dict_value      := 'ACTP0140';  --Prepaid Account VND
    ACCT_TYPE_INSTITUTION           constant com_api_type_pkg.t_dict_value      := 'ACTP7002';
    ACCT_TYPE_LOYALTY               constant com_api_type_pkg.t_dict_value      := 'ACTPLOYT';
    ACCOUNT_STATUS_OVERDUE          constant com_api_type_pkg.t_dict_value      := 'ACSTBOVD';

    ATTR_ACC_VIRTUAL_NUMBER_FORMAT  constant com_api_type_pkg.t_name            := 'CST_ACC_VIRTUAL_NUMBER_FORMAT';
    FLEX_VIRTUAL_ACCOUNT_NUMBER     constant com_api_type_pkg.t_name            := 'CST_VIRTUAL_ACCOUNT_NUMBER';

    WOORI_ADDRESS_TYPE              constant com_api_type_pkg.t_name            := 'WOORI_ADDRESS_TYPE';
    WOORI_CITY_CODE                 constant com_api_type_pkg.t_short_id        := -50000001;
    WOORI_REGION_CODE               constant com_api_type_pkg.t_short_id        := -50000002;
    WOORI_JOB_CODE                  constant com_api_type_pkg.t_short_id        := -50000003;
    WOORI_PAYMENT_CODE              constant com_api_type_pkg.t_short_id        := -50000004;
    WOORI_COMP_POS_CODE             constant com_api_type_pkg.t_short_id        := -50000005;
    WOORI_ID_TYPE                   constant com_api_type_pkg.t_short_id        := -50000006;
    WOORI_RESIDENCE_TYPE            constant com_api_type_pkg.t_short_id        := 0; -- WAITING

    ARRAY_VAT_GL_BUNCH_TYPE         constant com_api_type_pkg.t_short_id        := -50000008;

    FEMALE_CODE                     constant com_api_type_pkg.t_dict_value      := 'GNDRFEML';
    MALE_CODE                       constant com_api_type_pkg.t_dict_value      := 'GNDRMALE';

    EVENT_TYPE_CARD_ACTIVATION      constant com_api_type_pkg.t_dict_value      := 'EVNT0102';
    EVENT_TYPE_CARD_TEMP_BLOCK      constant com_api_type_pkg.t_dict_value      := 'EVNT0166';
    EVENT_TYPE_CARD_PERM_BLOCK      constant com_api_type_pkg.t_dict_value      := 'EVNT0167';
    EVENT_TYPE_OPER_MARKED_AWAITED  constant com_api_type_pkg.t_dict_value      := 'EVNT5004';
    EVT_TYPE_ACC_ACTIVE_TO_OVERDUE  constant com_api_type_pkg.t_dict_value      := 'EVNT5011';
    EVT_TYPE_ACC_OVERDUE_TO_ACTIVE  constant com_api_type_pkg.t_dict_value      := 'EVNT5012';
    EVT_TYPE_UNLOADING_CARD_INFO    constant com_api_type_pkg.t_dict_value      := 'EVNT5013';

    OPERATION_STATUS_WAITING_BATCH  constant com_api_type_pkg.t_dict_value      := 'OPST5004';
    OPER_STATUS_AWAITING_CLS_INVCE  constant com_api_type_pkg.t_dict_value      := 'OPST5001';
    OPER_STATUS_AWAITING_CBS_CONFM  constant com_api_type_pkg.t_dict_value      := 'OPST5002';

    OPER_TYPE_CREDIT_LIMIT_CHANGE   constant com_api_type_pkg.t_dict_value      := 'OPTP7031';
    OPERATION_TYPE_CREDIT_REFUND    constant com_api_type_pkg.t_dict_value      := 'OPTP1003';
    OPERATION_PAYMENT_DD            constant com_api_type_pkg.t_dict_value      := 'OPTP7030'; -- Payment from CBS (Direct debit)
    OPERATION_PAYMENT_ORDER         constant com_api_type_pkg.t_dict_value      := 'OPTP7001'; -- Payment order
    OPERATION_PAYMENT               constant com_api_type_pkg.t_dict_value      := 'OPTP0028'; -- Payment transaction
    OPERATION_PAYMENT_NOTIFICATION  constant com_api_type_pkg.t_dict_value      := 'OPTP0027'; -- Payment notification
    OPERATION_GL_DEBIT_ADJUSTMENT   constant com_api_type_pkg.t_dict_value      := 'OPTP7033';
    OPERATION_GL_CREDIT_ADJUSTMENT  constant com_api_type_pkg.t_dict_value      := 'OPTP7032';

    LOYALTY_POINT_REDEMPTION        constant com_api_type_pkg.t_dict_value      := 'OPTP5001';

    MACROS_TYPE_ID_HOLD_AMOUNT      constant com_api_type_pkg.t_tiny_id         := 1019;
    MACROS_TYPE_ID_VAT              constant com_api_type_pkg.t_tiny_id         := 7011;
    MACROS_TYPE_ID_ORIG_FEE         constant com_api_type_pkg.t_tiny_id         := 7126;
    MACROS_TYPE_ID_DEBIT_ON_OPER    constant com_api_type_pkg.t_tiny_id         := 1004;
    MACROS_TYPE_ID_CREDIT_ON_OPER   constant com_api_type_pkg.t_tiny_id         := 1003;
    MACROS_TYPE_ID_DEBIT_FEE        constant com_api_type_pkg.t_tiny_id         := 1007;
    MACROS_TYPE_ID_CREDIT_FEE_CANC  constant com_api_type_pkg.t_tiny_id         := 1010;
    MACROS_TYPE_ID_POINT_TO_CASH    constant com_api_type_pkg.t_tiny_id         := 7133;

    BUNCH_TYPE_ID_VAT               constant com_api_type_pkg.t_tiny_id         := 7012;
    BUNCH_TYPE_ID_VAT_CANCEL        constant com_api_type_pkg.t_tiny_id         := 7186;
    BUNCH_TYPE_ID_ORIG_FEE          constant com_api_type_pkg.t_tiny_id         := 7132;
    BUNCH_TYPE_ID_ORIG_FEE_CANCEL   constant com_api_type_pkg.t_tiny_id         := 7185;
    BUNCH_TYPE_ID_DEBIT_ON_OPER     constant com_api_type_pkg.t_tiny_id         := 1004;
    BUNCH_TYPE_ID_CREDIT_ON_OPER    constant com_api_type_pkg.t_tiny_id         := 1003;
    BUNCH_TYPE_ID_DEBIT_FEE         constant com_api_type_pkg.t_tiny_id         := 1007;
    BUNCH_TYPE_ID_CREDIT_FEE_CANC   constant com_api_type_pkg.t_tiny_id         := 1010;
    BUNCH_GL_ROUTING                constant com_api_type_pkg.t_name            := 'BUNCH_GL_ROUTING';

    PROC_NAME_UNBLOCK_OPERATIONS    constant com_api_type_pkg.t_oracle_name     := 'CST_WOO_PRC_OPERATION_PKG.UNBLOCK_CREDIT_OPERATIONS';

    WOORI_DATE_FORMAT               constant com_api_type_pkg.t_name            := 'YYYYMMDD';
    WOORI_DATE_YYYYMM               constant com_api_type_pkg.t_name            := 'YYYYMM';

    RATE_TYPE_BANK_CUSTOMER         constant com_api_type_pkg.t_dict_value      := 'RTTPCUST';

    DELIVERY_STATUS_ISSUED          constant com_api_type_pkg.t_dict_value      := 'CRDS5001';
    DELIVERY_STATUS_DELIVERING      constant com_api_type_pkg.t_dict_value      := 'CRDS5002';
    DELIVERY_STATUS_DELIVERD        constant com_api_type_pkg.t_dict_value      := 'CRDS5003';
    DELIVERY_STATUS_RETURN          constant com_api_type_pkg.t_dict_value      := 'CRDS5004';
    DELIVERY_STATUS_DISCARD         constant com_api_type_pkg.t_dict_value      := 'CRDS5005';

    DELIVERY_CHANNEL_BRANCH         constant com_api_type_pkg.t_dict_value      := 'CRDC5003';
    DELIVERY_CHANNEL_PARTY          constant com_api_type_pkg.t_dict_value      := 'CRDC5001';
    DELIVERY_CHANNEL_STAFF          constant com_api_type_pkg.t_dict_value      := 'CRDC5002';
    DELIVERY_CHANNEL_CUSTOMER       constant com_api_type_pkg.t_dict_value      := 'CRDC5004';

    LIMIT_TYPE_CREDIT_CASH          constant com_api_type_pkg.t_dict_value      := 'LMTP7019';
    LIMIT_TYPE_ACCT_CREDIT_CASH     constant com_api_type_pkg.t_dict_value      := 'LMTP0408';

    ADJUSTMENT_MISC_DR              constant com_api_type_pkg.t_dict_value      := 'ACAR0005';
    ADJUSTMENT_MISC_CR              constant com_api_type_pkg.t_dict_value      := 'ACAR0006';

    VNDONG                          constant com_api_type_pkg.t_curr_code       := '704';

    ACCT_MAINTENANCE_FEE            constant com_api_type_pkg.t_dict_value      := 'FETP0301';
    MAINTENANCE_FEE                 constant com_api_type_pkg.t_dict_value      := 'FETP0202';
    VAT_FEE_CARD_LEVEL              constant com_api_type_pkg.t_dict_value      := 'FETP5017';
    VAT_FEE_ACCOUNT_LEVEL           constant com_api_type_pkg.t_dict_value      := 'FETP5030';
    BALANCE_TYPE_VAT                constant com_api_type_pkg.t_dict_value      := 'BLTP5002';
    BALANCE_TYPE_OVERDRAFT          constant com_api_type_pkg.t_dict_value      := acc_api_const_pkg.BALANCE_TYPE_OVERDRAFT;
    BALANCE_TYPE_INTEREST           constant com_api_type_pkg.t_dict_value      := crd_api_const_pkg.BALANCE_TYPE_INTEREST;
    BALANCE_TYPE_OVERDUE            constant com_api_type_pkg.t_dict_value      := acc_api_const_pkg.BALANCE_TYPE_OVERDUE;
    BALANCE_TYPE_OVERDUE_INTEREST   constant com_api_type_pkg.t_dict_value      := crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST;
    AMOUNT_FEE_ORIGINAL             constant com_api_type_pkg.t_dict_value      := com_api_const_pkg.AMOUNT_ORIGINAL_FEE;
    AMOUNT_PURPOSE_EQUIVALENT       constant com_api_type_pkg.t_dict_value      := 'AMPR0016';

    CONTRACT_DEBIT_CORPORATE        constant com_api_type_pkg.t_dict_value      := 'CNTPDCOR';
    CONTRACT_DEBIT_INDIVIDUAL       constant com_api_type_pkg.t_dict_value      := 'CNTPDIND';
    CONTRACT_CREDIT_CORPORATE       constant com_api_type_pkg.t_dict_value      := 'CNTPCRCR';
    CONTRACT_CREDIT_INDIVIDUAL      constant com_api_type_pkg.t_dict_value      := 'CNTPBANK';

    CBS_CODE_SUCCESS                constant com_api_type_pkg.t_dict_value      := '00000000';

    RUN_STATUS_FAIL                 constant com_api_type_pkg.t_short_id        := 0;
    RUN_STATUS_SUCCESS              constant com_api_type_pkg.t_short_id        := 1;

    VALUE_VAT                       constant com_api_type_pkg.t_dict_value      := 'VAT';
    VALUE_NON                       constant com_api_type_pkg.t_dict_value      := 'NON';
    VALUE_VND                       constant com_api_type_pkg.t_dict_value      := 'VND';
    VALUE_CR                        constant com_api_type_pkg.t_dict_value      := 'CR';
    VALUE_DR                        constant com_api_type_pkg.t_dict_value      := 'DR';

    -- Account subjects:
    GL_ACCOUNT_SUBJ_FEE             constant com_api_type_pkg.t_account_number  := '47509100000'; -- Fee (including VAT)
    GL_ACCOUNT_SUBJ_POSP_D_I        constant com_api_type_pkg.t_account_number  := '14411100020'; -- POS purchase Domestic individual
    GL_ACCOUNT_SUBJ_POSP_O_I        constant com_api_type_pkg.t_account_number  := '14415100020'; -- POS purchase Overseas individual
    GL_ACCOUNT_SUBJ_POSP_D_C        constant com_api_type_pkg.t_account_number  := '14411100040'; -- POS purchase Domestic corpopate
    GL_ACCOUNT_SUBJ_POSP_O_C        constant com_api_type_pkg.t_account_number  := '14415100040'; -- POS purchase Overseas corpopate
    GL_ACCOUNT_SUBJ_CASH_D_I        constant com_api_type_pkg.t_account_number  := '14431100190'; -- Cash advance Domestic individual
    GL_ACCOUNT_SUBJ_CASH_O_I        constant com_api_type_pkg.t_account_number  := '14435100190'; -- Cash advance Overseas individual
    GL_ACCOUNT_SUBJ_POSP_INTEREST   constant com_api_type_pkg.t_account_number  := '47431208020'; -- POS purchase Interest
    GL_ACCOUNT_SUBJ_CASH_INTEREST   constant com_api_type_pkg.t_account_number  := '47440112190'; -- Cash advance Interest

    GL_RCN_STATUS_MATCHED           constant com_api_type_pkg.t_dict_value      := 'RCNS0000';
    GL_RCN_STATUS_IMPORTED          constant com_api_type_pkg.t_dict_value      := 'RCNS0001';
    GL_RCN_STATUS_AGGREGATED        constant com_api_type_pkg.t_dict_value      := 'RCNS0002';

end cst_woo_const_pkg;
/
