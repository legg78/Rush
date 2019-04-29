create or replace package amx_api_const_pkg as

    MODULE_CODE_AMX              constant com_api_type_pkg.t_module_code := 'AMX';
    TARGET_NETWORK               constant com_api_type_pkg.t_tiny_id     := 1004;
    AMX_CLEARING_STANDARD        constant com_api_type_pkg.t_tiny_id     := 1024;    
    CMID_ACQUIRING               constant com_api_type_pkg.t_name        := 'ACQ_BUISNESS_ID';
    CMID_ACQUIRING_SINGLE        constant com_api_type_pkg.t_name        := 'ACQ_SINGLE_BUISNESS_ID';
    CMID_ISSUING                 constant com_api_type_pkg.t_name        := 'ISS_BUISNESS_ID';
    CMID_GLOBAL_NETWORK          constant com_api_type_pkg.t_name        := 'GLOBAL_NETWORK_ID';
    CMID_DEMOGRAPHIC             constant com_api_type_pkg.t_name        := 'DEMOGRAPHIC_BUISNESS_ID';
    CMID_ISS_PROCESSOR           constant com_api_type_pkg.t_name        := 'ISS_PROCESSOR_ID';
    CMID_ACQ_PROCESSOR           constant com_api_type_pkg.t_name        := 'ACQ_PROCESSOR_ID';
    MERCH_DISCOUNT_RATE          constant com_api_type_pkg.t_name        := 'MERCHANT_DISCOUNT_RATE_ATTRIBUTE';

    STANDARD_VERSION_ID_19Q2     constant com_api_type_pkg.t_tiny_id     := 1105;

    FILE_TYPE_CLEARING_AMEX      constant com_api_type_pkg.t_dict_value  := 'FLTPCLAE';
    FILE_NAME_CODE_SEDEMOV2      constant com_api_type_pkg.t_name        := 'SE.DEMO.V2';
    
    MTID_HEADER                  constant com_api_type_pkg.t_tiny_id     := '9824';
    MTID_TRAILER                 constant com_api_type_pkg.t_tiny_id     := '9825';
    
    MTID_PRESENTMENT             constant com_api_type_pkg.t_tiny_id     := '1240';
    FUNC_CODE_FIRST_PRES         constant com_api_type_pkg.t_curr_code   := '200';
    FUNC_CODE_SECOND_PRES        constant com_api_type_pkg.t_curr_code   := '205';
    
    MTID_ADDENDA                 constant com_api_type_pkg.t_tiny_id     := '9240';
    
    MTID_RETRIEVAL_REQUEST       constant com_api_type_pkg.t_tiny_id     := '1642';
    MTID_FULFILLMENT             constant com_api_type_pkg.t_tiny_id     := '1640';
    
    MTID_CHARGEBACK              constant com_api_type_pkg.t_tiny_id     := '1442';
    FUNC_CODE_FIRST_CHARGEBACK   constant com_api_type_pkg.t_curr_code   := '450';
    FUNC_CODE_FINAL_CHARGEBACK   constant com_api_type_pkg.t_curr_code   := '451';    
    
    MTID_NET_ACKNOWLEDGMENT      constant com_api_type_pkg.t_tiny_id     := '1844';
    MTID_ACKNOWLEDGMENT          constant com_api_type_pkg.t_tiny_id     := '1824';
    FUNC_CODE_ACKNOWLEDGMENT     constant com_api_type_pkg.t_curr_code   := '880';
    --MTID_PROGRAM_SPEC            constant com_api_type_pkg.t_tiny_id     := '9344';--??

    MTID_FEE_COLLECTION          constant com_api_type_pkg.t_tiny_id     := '1744';
    FUNC_CODE_ACQ_MEMBER_FEE     constant com_api_type_pkg.t_curr_code   := '780';
    FUNC_CODE_ISS_MEMBER_FEE     constant com_api_type_pkg.t_curr_code   := '781';

    MTID_ISS_ATM_FEE             constant com_api_type_pkg.t_tiny_id     := '1740';
    MTID_ACQ_ATM_FEE             constant com_api_type_pkg.t_tiny_id     := '1742';
    FUNC_CODE_ORIGINAL_FEE       constant com_api_type_pkg.t_curr_code   := '700';
        
    MTID_FRAUD_UPD_MESSAGE       constant com_api_type_pkg.t_tiny_id     := '9324';
    MTID_FRAUD_RESP_MESSAGE      constant com_api_type_pkg.t_tiny_id     := '9334';
    FUNC_CODE_ADD_RECORD         constant com_api_type_pkg.t_curr_code   := '301';
    FUNC_CODE_CHANGE_RECORD      constant com_api_type_pkg.t_curr_code   := '302';
    FUNC_CODE_DELETE_RECORD      constant com_api_type_pkg.t_curr_code   := '303';

    MTID_DC_HEADER               constant com_api_type_pkg.t_tiny_id     := '9844';
    MTID_DC_TRAILER              constant com_api_type_pkg.t_tiny_id     := '9845';
    MTID_ONUS_MESSAGE            constant com_api_type_pkg.t_tiny_id     := '1340';         
    MTID_DC_ADDENDA              constant com_api_type_pkg.t_tiny_id     := '9340';
    MTID_DC_DEMOGRAPHIC          constant com_api_type_pkg.t_tiny_id     := '9640';

    MTID_DAF_HEADER              constant com_api_type_pkg.t_tiny_id     := '1324';
    MTID_DAF_TRAILER             constant com_api_type_pkg.t_tiny_id     := '1325';
    MTID_DAF_MESSAGE             constant com_api_type_pkg.t_tiny_id     := '1644';
    FUNC_CODE_DAF                constant com_api_type_pkg.t_curr_code   := '890';

    PROC_CODE_DEBIT              constant com_api_type_pkg.t_auth_code   := '000000';
    PROC_CODE_ATM_CASH           constant com_api_type_pkg.t_auth_code   := '010000';
    PROC_CODE_CASH_DISB_DB       constant com_api_type_pkg.t_auth_code   := '014008';
    PROC_CODE_CREDIT             constant com_api_type_pkg.t_auth_code   := '200000';
    PROC_CODE_CASH_DISB_CR       constant com_api_type_pkg.t_auth_code   := '220000';
    PROC_CODE_NONFIN             constant com_api_type_pkg.t_auth_code   := '380000';
    PROC_CODE_DEMOGRAPHIC        constant com_api_type_pkg.t_auth_code   := '380000';
    PROC_CODE_EXCEPT_UPD         constant com_api_type_pkg.t_auth_code   := '920892';
    PROC_CODE_ATM_ACQ_STTL       constant com_api_type_pkg.t_auth_code   := '170808';     
    
    MSG_REASON_CODE_ACKNOWLEDG   constant com_api_type_pkg.t_mcc         := '8602';
    MSG_REASON_CODE_FIN_REJECT   constant com_api_type_pkg.t_mcc         := '8600';
    MSG_REASON_CODE_FIN_OK       constant com_api_type_pkg.t_mcc         := '8601';
    MSG_REASON_CODE_DC_REJECT    constant com_api_type_pkg.t_mcc         := '8603';
    MSG_REASON_CODE_DC_OK        constant com_api_type_pkg.t_mcc         := '8604';
    
    ACTION_CODE_PRODUCTION       constant com_api_type_pkg.t_curr_code   := '892';
    ACTION_CODE_TEST             constant com_api_type_pkg.t_curr_code   := '893';
    ACTION_CODE_PROD_RETRANS     constant com_api_type_pkg.t_curr_code   := '894';
    ACTION_CODE_TEST_RETRANS     constant com_api_type_pkg.t_curr_code   := '895';

    ACTION_CODE_INIT_DEMOGRAPH   constant com_api_type_pkg.t_curr_code   := '891';
    
    ACTION_CODE_FILE_REJECT      constant com_api_type_pkg.t_curr_code   := '900';
    ACTION_CODE_FULL_ACCEPT      constant com_api_type_pkg.t_curr_code   := '901';
    ACTION_CODE_PARTIAL_ACCEPT   constant com_api_type_pkg.t_curr_code   := '899';
          
    GLOBAL_INST_ID               constant com_api_type_pkg.t_cmid        := '90000000002'; --normal CMID of Amex
    --GLOBAL_INST_ID_FRAUD         constant com_api_type_pkg.t_cmid        := '90000000005'; -- for 9344 ?
    GLOBAL_INST_ID_DEMOGRAPHIC   constant com_api_type_pkg.t_cmid        := '90000000010';
    --GLOBAL_INST_ID_EXCEPT_REQ    constant com_api_type_pkg.t_cmid        := '11000000117'; -- for 9344 ?   
    
    FORMAT_RCN_HEADER_DATE       constant varchar2(20)                   := 'YY/MM/DDHH24:MI:SS';
    FORMAT_RCN_DATE              constant varchar2(16)                   := 'YYMMDDHH24:MI:SS';
    FORMAT_FILE_DATE             constant varchar2(16)                   := 'YYYYMMDDHH24MISS';
    FORMAT_SHORT_DATE            constant varchar2(8)                    := 'YYMMDD';
    FORMAT_OUT_DATE              constant varchar2(8)                    := 'YYYYMMDD';
    FORMAT_OUT_TIME              constant varchar2(8)                    := 'HH24MISS';
    DEFAULT_DATE                 constant varchar2(8)                    := '00010101';
    END_DATE                     constant varchar2(8)                    := '99991231';
    DEFAULT_TIME                 constant varchar2(8)                    := '000000';
    
    MAX_DIGIT_DRCR_COUNT_FIELD   constant number(2)                      :=  6;
    MAX_DIGIT_DRCR_AMOUNT_FIELD  constant number(2)                      := 16;
    MAX_DIGIT_TOTAL_AMOUNT_FIELD constant number(2)                      := 17;

    MESSAGE_IMPACT_CREDIT        constant com_api_type_pkg.t_sign        :=  1;
    MESSAGE_IMPACT_DEBIT         constant com_api_type_pkg.t_sign        := -1;
          
    -- format codes
    FORMAT_CODE_GENERAL          constant com_api_type_pkg.t_byte_char   := '20';    
    FORMAT_CODE_AIRLINE          constant com_api_type_pkg.t_byte_char   := '01'; 
    FORMAT_CODE_RETAIL           constant com_api_type_pkg.t_byte_char   := '02';
    FORMAT_CODE_INSURANCE        constant com_api_type_pkg.t_byte_char   := '04';
    FORMAT_CODE_RENTAL           constant com_api_type_pkg.t_byte_char   := '05';
    FORMAT_CODE_RAIL             constant com_api_type_pkg.t_byte_char   := '06';
    FORMAT_CODE_LODGING          constant com_api_type_pkg.t_byte_char   := '11';
    FORMAT_CODE_RESTAURANT       constant com_api_type_pkg.t_byte_char   := '12';
    FORMAT_CODE_COMM_SRV         constant com_api_type_pkg.t_byte_char   := '13';
    FORMAT_CODE_TRAVEL           constant com_api_type_pkg.t_byte_char   := '14';
    FORMAT_CODE_OIL              constant com_api_type_pkg.t_byte_char   := '21';
    FORMAT_CODE_TICKETING        constant com_api_type_pkg.t_byte_char   := '22';
    
    MEDIA_CODE_SIGNATURE         constant com_api_type_pkg.t_byte_char   := '01';
    MEDIA_CODE_PHONE_ORDER       constant com_api_type_pkg.t_byte_char   := '02';
    MEDIA_CODE_MAIL_ORDER        constant com_api_type_pkg.t_byte_char   := '03';
    MEDIA_CODE_ELECTRONIC_ORDER  constant com_api_type_pkg.t_byte_char   := '04';
    MEDIA_CODE_RECUR_BILLING     constant com_api_type_pkg.t_byte_char   := '05';
    MEDIA_CODE_POS               constant com_api_type_pkg.t_byte_char   := '10';
    MEDIA_CODE_IPOS              constant com_api_type_pkg.t_byte_char   := '11';
    MEDIA_CODE_INTERNET          constant com_api_type_pkg.t_byte_char   := '12';
    MEDIA_CODE_ATM               constant com_api_type_pkg.t_byte_char   := '13';
    MEDIA_CODE_MOTO              constant com_api_type_pkg.t_byte_char   := '14';
    MEDIA_CODE_ETICKET           constant com_api_type_pkg.t_byte_char   := '16';
    
    MSG_STATUS_INVALID           constant com_api_type_pkg.t_dict_value  := 'CLMS0080';

    ADDENDA_TYPE_INDUSTRY        constant com_api_type_pkg.t_byte_char   := '03';
    ADDENDA_TYPE_CHIP            constant com_api_type_pkg.t_byte_char   := '07';

    MESSAGE_TRANSACTION_SN       constant com_api_type_pkg.t_tag         := '000001';

    ROLE_TYPE_CODE_CARD_ACCEPT   constant com_api_type_pkg.t_curr_code   := '001';

    LEVEL_SE_LOCATION            constant com_api_type_pkg.t_byte_char   := '02';
    LEVEL_PARENT_SE              constant com_api_type_pkg.t_byte_char   := '05';
    LEVEL_GRANDPARENT_SE         constant com_api_type_pkg.t_byte_char   := '06';
    LEVEL_GRANDGRANDPARENT_SE    constant com_api_type_pkg.t_byte_char   := '07';
    LEVEL_HEADQUARTERS           constant com_api_type_pkg.t_byte_char   := '08';

    PARTICIPANT_CODE_TOP         constant com_api_type_pkg.t_byte_char   := '02';
    PARTICIPANT_CODE_DEPENDENT   constant com_api_type_pkg.t_byte_char   := '03';

    SE_STATUS_CODE_ACTIVE        constant com_api_type_pkg.t_one_char    := 'A';
    SE_STATUS_CODE_CANCELED      constant com_api_type_pkg.t_one_char    := 'C';
    SE_STATUS_CODE_REINSTATED    constant com_api_type_pkg.t_one_char    := 'R';

    VALUE_Y                      constant com_api_type_pkg.t_one_char    := 'Y';
    VALUE_N                      constant com_api_type_pkg.t_one_char    := 'N';

    AMX_PRC_MERCHANT_PKG_PROCESS constant com_api_type_pkg.t_oracle_name := 'AMX_PRC_MERCHANT_PKG.PROCESS';

    ST_REASON_CNCL_OUTOFBUSINESS constant com_api_type_pkg.t_byte_char   := '01';
    
    ATM_RCN_HEADER               constant com_api_type_pkg.t_one_char    := '0';
    ATM_RCN_DETAIL               constant com_api_type_pkg.t_one_char    := '1';
    ATM_RCN_TRAILER              constant com_api_type_pkg.t_one_char    := '9';
    
    PARAM_ORGANIZATION_ID        constant com_api_type_pkg.t_oracle_name := 'ORGANIZATION_ID';
end;
/

