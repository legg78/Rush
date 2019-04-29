create or replace package opr_api_const_pkg is
/*********************************************************
 *  Operation processing constants API <br />
 *  Created by Khougaev A.(khougaev@bpcbt.com)  at 21.08.2009 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: opr_api_const_pkg <br />
 *  @headcom
 **********************************************************/
    OPERATION_STATUS_KEY           constant com_api_type_pkg.t_dict_value := 'OPST';
    OPERATION_STATUS_PROCESSING    constant com_api_type_pkg.t_dict_value := 'OPST0001';
    OPERATION_STATUS_PROCESS_READY constant com_api_type_pkg.t_dict_value := 'OPST0100';
    OPERATION_STATUS_DONT_PROCESS  constant com_api_type_pkg.t_dict_value := 'OPST0101';
    OPERATION_STATUS_MANUAL        constant com_api_type_pkg.t_dict_value := 'OPST0102';
    OPERATION_STATUS_DUPLICATE     constant com_api_type_pkg.t_dict_value := 'OPST0103';
    OPERATION_STATUS_MERGED        constant com_api_type_pkg.t_dict_value := 'OPST0107';
    OPERATION_STATUS_WAIT_CLEARING constant com_api_type_pkg.t_dict_value := 'OPST0110';
    OPERATION_STATUS_WAIT_SETTL    constant com_api_type_pkg.t_dict_value := 'OPST0120';
    OPERATION_STATUS_WAIT_ACTIV    constant com_api_type_pkg.t_dict_value := 'OPST0130';
    OPERATION_STATUS_WRONG_DATA    constant com_api_type_pkg.t_dict_value := 'OPST0200';
    OPERATION_STATUS_CORRECTED     constant com_api_type_pkg.t_dict_value := 'OPST0300';
    OPERATION_STATUS_PROCESSED     constant com_api_type_pkg.t_dict_value := 'OPST0400';
    OPERATION_STATUS_DONE_WO_PROC  constant com_api_type_pkg.t_dict_value := 'OPST0401';
    OPERATION_STATUS_UNHOLDED      constant com_api_type_pkg.t_dict_value := 'OPST0402';
    OPERATION_STATUS_AUTHORIZED    constant com_api_type_pkg.t_dict_value := 'OPST0403';
    OPERATION_STATUS_NO_ENTRIES    constant com_api_type_pkg.t_dict_value := 'OPST0404';
    OPERATION_STATUS_EXCEPTION     constant com_api_type_pkg.t_dict_value := 'OPST0500';
    OPERATION_STATUS_UNSUCCESSFUL  constant com_api_type_pkg.t_dict_value := 'OPST0501';
    OPERATION_STATUS_NO_RULES      constant com_api_type_pkg.t_dict_value := 'OPST0600';
    OPERATION_STATUS_AWAITS_UNHOLD constant com_api_type_pkg.t_dict_value := 'OPST0800';
    OPERATION_STATUS_PART_UNHOLD   constant com_api_type_pkg.t_dict_value := 'OPST0850';

    MESSAGE_TYPE_KEY               constant com_api_type_pkg.t_dict_value := 'MSGT';
    MESSAGE_TYPE_PREAUTHORIZATION  constant com_api_type_pkg.t_dict_value := 'MSGTPREU';
    MESSAGE_TYPE_COMPLETION        constant com_api_type_pkg.t_dict_value := 'MSGTCMPL';
    MESSAGE_TYPE_AUTHORIZATION     constant com_api_type_pkg.t_dict_value := 'MSGTAUTH';
    MESSAGE_TYPE_PRESENTMENT       constant com_api_type_pkg.t_dict_value := 'MSGTPRES';
    MESSAGE_TYPE_CHARGEBACK        constant com_api_type_pkg.t_dict_value := 'MSGTCHBK';
    MESSAGE_TYPE_REPRESENTMENT     constant com_api_type_pkg.t_dict_value := 'MSGTREPR';
    MESSAGE_TYPE_ROLLBACK          constant com_api_type_pkg.t_dict_value := 'MSGTRLBK';
    MESSAGE_TYPE_RETRIEVAL_REQUEST constant com_api_type_pkg.t_dict_value := 'MSGTRTRQ';
    MESSAGE_TYPE_WRITEOFF_POSITIVE constant com_api_type_pkg.t_dict_value := 'MSGTWFPS';
    MESSAGE_TYPE_WRITEOFF_NEGATIVE constant com_api_type_pkg.t_dict_value := 'MSGTWFNG';
    MESSAGE_TYPE_PARTIAL_AMOUNT    constant com_api_type_pkg.t_dict_value := 'MSGTPAMC';
    MESSAGE_TYPE_FRAUD_REPORT      constant com_api_type_pkg.t_dict_value := 'MSGTFRDR';
    MESSAGE_TYPE_PART_AMOUNT_COMPL constant com_api_type_pkg.t_dict_value := 'MSGTPACC';
    MESSAGE_TYPE_CANCELETION       constant com_api_type_pkg.t_dict_value := 'MSGTCNCL';
    MESSAGE_TYPE_CMPL_CANCELETION  constant com_api_type_pkg.t_dict_value := 'MSGTCMCL';
    MESSAGE_TYPE_CHRGBK_PERIOD_EXT constant com_api_type_pkg.t_dict_value := 'MSGTCPPE';
    MESSAGE_TYPE_POS_BATCH         constant com_api_type_pkg.t_dict_value := 'MSGTBTCH';
    MESSAGE_TYPE_SPLIT             constant com_api_type_pkg.t_dict_value := 'MSGTSPLT';

    PROCESSING_STAGE_KEY           constant com_api_type_pkg.t_dict_value := 'PSTG';
    PROCESSING_STAGE_COMMON        constant com_api_type_pkg.t_dict_value := 'PSTGCOMM';
    PROCESSING_STAGE_ONLINE        constant com_api_type_pkg.t_dict_value := 'PSTGONLN';
    PROCESSING_STAGE_PIN_OK        constant com_api_type_pkg.t_dict_value := 'PSTGPNOK';
    PROCESSING_STAGE_PIN_ERROR     constant com_api_type_pkg.t_dict_value := 'PSTGPNER';
    PROCESSING_STAGE_REJECTED      constant com_api_type_pkg.t_dict_value := 'PSTGRJCT';
    PROCESSING_STAGE_UDEFINED      constant com_api_type_pkg.t_dict_value := 'PSTGUNDF';
    PROCESSING_STAGE_INTERCH_FEE   constant com_api_type_pkg.t_dict_value := 'PSTGICHF';

    OPERATION_TYPE_KEY             constant com_api_type_pkg.t_dict_value := 'OPTP';
    OPERATION_TYPE_PURCHASE        constant com_api_type_pkg.t_dict_value := 'OPTP0000';
    OPERATION_TYPE_ATM_CASH        constant com_api_type_pkg.t_dict_value := 'OPTP0001';
    OPERATION_TYPE_CASHBACK        constant com_api_type_pkg.t_dict_value := 'OPTP0009';
    OPERATION_TYPE_P2P_DEBIT       constant com_api_type_pkg.t_dict_value := 'OPTP0010';
    OPERATION_TYPE_P2P             constant com_api_type_pkg.t_dict_value := 'OPTP0011';
    OPERATION_TYPE_POS_CASH        constant com_api_type_pkg.t_dict_value := 'OPTP0012';
    OPERATION_TYPE_UNIQUE          constant com_api_type_pkg.t_dict_value := 'OPTP0018';
    OPERATION_TYPE_FEE_CREDIT      constant com_api_type_pkg.t_dict_value := 'OPTP0019';
    OPERATION_TYPE_REFUND          constant com_api_type_pkg.t_dict_value := 'OPTP0020';
    OPERATION_TYPE_CASHIN          constant com_api_type_pkg.t_dict_value := 'OPTP0022';
    OPERATION_TYPE_P2P_CREDIT      constant com_api_type_pkg.t_dict_value := 'OPTP0026';
    OPERATION_PAYMENT_NOTIFICATION constant com_api_type_pkg.t_dict_value := 'OPTP0027';
    OPERATION_TYPE_PAYMENT         constant com_api_type_pkg.t_dict_value := 'OPTP0028';
    OPERATION_TYPE_FEE_DEBIT       constant com_api_type_pkg.t_dict_value := 'OPTP0029';
    OPERATION_TYPE_BALANCE_INQUIRY constant com_api_type_pkg.t_dict_value := 'OPTP0030';
    OPERATION_TYPE_CUSTOMER_INQUIR constant com_api_type_pkg.t_dict_value := 'OPTP0031';
    OPERATION_TYPE_CUSTOMER_CHECK  constant com_api_type_pkg.t_dict_value := 'OPTP0032';
    OPERATION_TYPE_STATEMENT       constant com_api_type_pkg.t_dict_value := 'OPTP0038';
    OPERATION_TYPE_STATEMENT_MINI  constant com_api_type_pkg.t_dict_value := 'OPTP0039';
    OPERATION_TYPE_FUNDS_TRANSFER  constant com_api_type_pkg.t_dict_value := 'OPTP0040';
    OPERATION_TYPE_INTERNAL_ACC_FT constant com_api_type_pkg.t_dict_value := 'OPTP0041';
    OPERATION_TYPE_FOREIGN_ACC_FT  constant com_api_type_pkg.t_dict_value := 'OPTP0042';
    OPER_TYPE_FT_TO_OTHER_BANK     constant com_api_type_pkg.t_dict_value := 'OPTP0044';
    OPER_TYPE_FT_TO_CASH_BY_CARD   constant com_api_type_pkg.t_dict_value := 'OPTP0045';
    OPER_TYPE_FT_TO_CASH_BY_CASH   constant com_api_type_pkg.t_dict_value := 'OPTP0046';
    OPER_TYPE_CASH_DEPO_BY_CASH    constant com_api_type_pkg.t_dict_value := 'OPTP0047';
    OPER_TYPE_CASH_BY_CODE         constant com_api_type_pkg.t_dict_value := 'OPTP0048';
    OPER_TYPE_SALE_GOODS_SERVICE   constant com_api_type_pkg.t_dict_value := 'OPTP0050';
    OPER_TYPE_CASH_OUT_AT_AGENT    constant com_api_type_pkg.t_dict_value := 'OPTP0051';
    OPERATION_TYPE_SRV_PRV_PAYMENT constant com_api_type_pkg.t_dict_value := 'OPTP0060';
    OPERATION_TYPE_SRV_PRV_PAY_AGT constant com_api_type_pkg.t_dict_value := 'OPTP0061';
    OPERATION_TYPE_PIN_CHANGE      constant com_api_type_pkg.t_dict_value := 'OPTP0070';
    OPERATION_TYPE_PIN_UNBLOCK     constant com_api_type_pkg.t_dict_value := 'OPTP0071';
    OPER_TYPE_FT_TO_EXTERNAL       constant com_api_type_pkg.t_dict_value := 'OPTP0111';
    OPER_TYPE_FT_TO_EXTERNAL_DEBIT constant com_api_type_pkg.t_dict_value := 'OPTP0110';
    OPER_TYPE_FT_TO_EXTERNAL_CREDI constant com_api_type_pkg.t_dict_value := 'OPTP0126';
    OPERATION_TYPE_VIRTUAL_CARD    constant com_api_type_pkg.t_dict_value := 'OPTP0690';
    OPERATION_TYPE_SETTL_TOTALS    constant com_api_type_pkg.t_dict_value := 'OPTP0250';
    OPERATION_TYPE_CLERK_TOTALS    constant com_api_type_pkg.t_dict_value := 'OPTP0251';
    OPERATION_TYPE_DEBIT_ADJUST    constant com_api_type_pkg.t_dict_value := 'OPTP0402';
    OPERATION_TYPE_CREDIT_ADJUST   constant com_api_type_pkg.t_dict_value := 'OPTP0422';
    OPERATION_TYPE_CR_ADJUST_ACCNT constant com_api_type_pkg.t_dict_value := 'OPTP0412';
    OPERATION_TYPE_UPD_TOKEN_CARD  constant com_api_type_pkg.t_dict_value := 'OPTP0558';
    OPERATION_TYPE_SUSP_CARD_TOKEN constant com_api_type_pkg.t_dict_value := 'OPTP0559';
    OPERATION_TYPE_DELT_CARD_TOKEN constant com_api_type_pkg.t_dict_value := 'OPTP0560';
    OPERATION_TYPE_RESM_CARD_TOKEN constant com_api_type_pkg.t_dict_value := 'OPTP0561';
    OPERATION_TYPE_REG_CARD_TOKEN  constant com_api_type_pkg.t_dict_value := 'OPTP0691';
    OPERATION_TYPE_ATM_CASS_SETUP1 constant com_api_type_pkg.t_dict_value := 'OPTP0801';
    OPERATION_TYPE_ATM_CASS_SETUP2 constant com_api_type_pkg.t_dict_value := 'OPTP0802';
    OPERATION_TYPE_ATM_SETTLEMENT  constant com_api_type_pkg.t_dict_value := 'OPTP0803';
    OPERATION_TYPE_ATM_RESET       constant com_api_type_pkg.t_dict_value := 'OPTP0804';
    OPERATION_TYPE_ATM_RECEIPTSSET constant com_api_type_pkg.t_dict_value := 'OPTP0805';
    OPERATION_TYPE_ATM_CASH_ADJST  constant com_api_type_pkg.t_dict_value := 'OPTP0806';
    OPERATION_TYPE_ISSUER_FEE      constant com_api_type_pkg.t_dict_value := 'OPTP0119';
    OPERATION_TYPE_ACQUIRER_FEE    constant com_api_type_pkg.t_dict_value := 'OPTP0219';
    OPERATION_TYPE_INSTITUTION_FEE constant com_api_type_pkg.t_dict_value := 'OPTP0319';
    OPERATION_TYPE_CARD_STATUS     constant com_api_type_pkg.t_dict_value := 'OPTP0171';
    OPERATION_TYPE_TERMINAL_STATUS constant com_api_type_pkg.t_dict_value := 'OPTP0252';
    OPERATION_TYPE_MERCHANT_STATUS constant com_api_type_pkg.t_dict_value := 'OPTP0253';
    OPERATION_TYPE_CREDIT_ACCOUNT  constant com_api_type_pkg.t_dict_value := 'OPTP0428';
    OPERATION_TYPE_PRY_PASS_LOUNGE constant com_api_type_pkg.t_dict_value := 'OPTP1600';
    OPERATION_TYPE_REJECT_CREDIT   constant com_api_type_pkg.t_dict_value := 'OPTP0701';
    OPERATION_TYPE_REJECT_DEBIT    constant com_api_type_pkg.t_dict_value := 'OPTP0702';
    OPERATION_TYPE_REFERRAL_POINTS constant com_api_type_pkg.t_dict_value := 'OPTP1700';
    OPERATION_TYPE_UNKNOWN         constant com_api_type_pkg.t_dict_value := 'OPTP9999';

    SETTLEMENT_TYPE_KEY            constant com_api_type_pkg.t_dict_value := 'STTT';
    SETTLEMENT_INTERNAL            constant com_api_type_pkg.t_dict_value := 'STTT0000';
    SETTLEMENT_INTERNAL_INTRAINST  constant com_api_type_pkg.t_dict_value := 'STTT0001';
    SETTLEMENT_INTERNAL_INTERINST  constant com_api_type_pkg.t_dict_value := 'STTT0002';
    SETTLEMENT_USONUS              constant com_api_type_pkg.t_dict_value := 'STTT0010';
    SETTLEMENT_USONUS_INTRAINST    constant com_api_type_pkg.t_dict_value := 'STTT0011';
    SETTLEMENT_USONUS_INTERINST    constant com_api_type_pkg.t_dict_value := 'STTT0012';
    SETTLEMENT_USONTHEM            constant com_api_type_pkg.t_dict_value := 'STTT0100';
    SETTLEMENT_THEMONUS            constant com_api_type_pkg.t_dict_value := 'STTT0200';
    SETTLEMENT_THEMONTHEM          constant com_api_type_pkg.t_dict_value := 'STTT0300';

    OPERATION_MATCH_KEY            constant com_api_type_pkg.t_dict_value := 'MTST';
    OPERATION_MATCH_NOT_MATCHED    constant com_api_type_pkg.t_dict_value := 'MTST0100';
    OPERATION_MATCH_REQ_MATCH      constant com_api_type_pkg.t_dict_value := 'MTST0200';
    OPERATION_MATCH_DONT_REQ_MATCH constant com_api_type_pkg.t_dict_value := 'MTST0300';
    OPERATION_MATCH_EXPIRED        constant com_api_type_pkg.t_dict_value := 'MTST0400';
    OPERATION_MATCH_MATCHED        constant com_api_type_pkg.t_dict_value := 'MTST0500';
    OPERATION_MATCH_PARTIAL_MATCHE constant com_api_type_pkg.t_dict_value := 'MTST0600';
    OPERATION_MATCH_AUTO_MATCHED   constant com_api_type_pkg.t_dict_value := 'MTST0700';

    DEFAULT_MATCH_DEPTH            constant com_api_type_pkg.t_tiny_id    := 30;

    ENTITY_TYPE_OPERATION          constant com_api_type_pkg.t_dict_value := 'ENTTOPER';
    ENTITY_TYPE_OPER_PARTICIPANT   constant com_api_type_pkg.t_dict_value := 'ENTTOPPR';

    CHECK_SKIP                     constant com_api_type_pkg.t_dict_value := 'OPCK0000';
    CHECK_SPLIT_BY_CARD_NUMBER     constant com_api_type_pkg.t_dict_value := 'OPCK0001';
    CHECK_FOREIGN_CARD             constant com_api_type_pkg.t_dict_value := 'OPCK0100';
    CHECK_OWN_CARD                 constant com_api_type_pkg.t_dict_value := 'OPCK0101';
    CHECK_ISS_HOST_CONSUMER        constant com_api_type_pkg.t_dict_value := 'OPCK0102';
    CHECK_ACQ_NET_BY_INST          constant com_api_type_pkg.t_dict_value := 'OPCK0200';
    CHECK_OWN_MERCHANT             constant com_api_type_pkg.t_dict_value := 'OPCK0201';
    CHECK_OWN_TERMINAL             constant com_api_type_pkg.t_dict_value := 'OPCK0202';
    CHECK_FIND_ISSUING_NETWORK     constant com_api_type_pkg.t_dict_value := 'OPCK0203';
    CHECK_FIND_ACCOUNT             constant com_api_type_pkg.t_dict_value := 'OPCK0204';
    CHECK_EMV_ATC                  constant com_api_type_pkg.t_dict_value := 'OPCK0300';
    CHECK_FIND_DESTINATION_NETWORK constant com_api_type_pkg.t_dict_value := 'OPCK0205';
    CHECK_TRY_DESTINATION_NETWORK  constant com_api_type_pkg.t_dict_value := 'OPCK0206';
    CHECK_FIND_INSTITUTION_CUST    constant com_api_type_pkg.t_dict_value := 'OPCK0207';
    CHECK_DEFINE_CUST_BY_MRCH_PAN  constant com_api_type_pkg.t_dict_value := 'OPCK0208';
    CHECK_BIN_INFO                 constant com_api_type_pkg.t_dict_value := 'OPCK0209';
    CHECK_ISS_TOKEN_THEM_ON_US     constant com_api_type_pkg.t_dict_value := 'OPCK0210';
    CHECK_ACQ_TOKEN_US_ON_THEM     constant com_api_type_pkg.t_dict_value := 'OPCK0211';
    CHECK_INSTITUTION_STATUS       constant com_api_type_pkg.t_dict_value := 'OPCK0212';
    CHECK_DEFINE_PAYMENT_PROVIDER  constant com_api_type_pkg.t_dict_value := 'OPCK1401';
    CHECK_DUPLICATE_OPERATION      constant com_api_type_pkg.t_dict_value := 'OPCK0400';
    CHECK_DEFINE_OPER_ORDERS       constant com_api_type_pkg.t_dict_value := 'OPCK1402';

    OPER_AMOUNT_ALG_REQUESTED      constant com_api_type_pkg.t_dict_value := 'OALG0010';
    OPER_AMOUNT_ALG_AVAL           constant com_api_type_pkg.t_dict_value := 'OALG0020';

    OPER_REASON_KEY                constant com_api_type_pkg.t_dict_value := 'OPSR';
    OPER_REASON_LIMIT_EXCEED       constant com_api_type_pkg.t_dict_value := 'OPSR0500';
    OPER_REASON_DST_LIMIT_EXCEED   constant com_api_type_pkg.t_dict_value := 'OPSR0501';
    OPER_REASON_NO_SELECT_ACCT     constant com_api_type_pkg.t_dict_value := 'OPSR0502';
    OPER_REASON_NOT_ENOUGH_FUNDS   constant com_api_type_pkg.t_dict_value := 'OPSR0503';

    COMPLETION_TIMEOUT_CYCLE_TYPE  constant com_api_type_pkg.t_dict_value := 'CYTP0204';
    COMPLETION_AMOUNT_GAP_FEE_TYPE constant com_api_type_pkg.t_dict_value := 'FETP0212';

    CLIENT_ID_TYPE_UNKNOWN         constant com_api_type_pkg.t_dict_value := 'CITPUNKN';
    CLIENT_ID_TYPE_NONE            constant com_api_type_pkg.t_dict_value := 'CITPNONE';
    CLIENT_ID_TYPE_CARD            constant com_api_type_pkg.t_dict_value := 'CITPCARD'; -- card number
    CLIENT_ID_TYPE_CARD_ID         constant com_api_type_pkg.t_dict_value := 'CITPCDID'; -- card identifier
    CLIENT_ID_TYPE_ACCOUNT         constant com_api_type_pkg.t_dict_value := 'CITPACCT';
    CLIENT_ID_TYPE_EMAIL           constant com_api_type_pkg.t_dict_value := 'CITPEMAI';
    CLIENT_ID_TYPE_MOBILE          constant com_api_type_pkg.t_dict_value := 'CITPMBPH';
    CLIENT_ID_TYPE_CUSTOMER        constant com_api_type_pkg.t_dict_value := 'CITPCUST';
    CLIENT_ID_TYPE_CONTRACT        constant com_api_type_pkg.t_dict_value := 'CITPCNTR';
    CLIENT_ID_TYPE_EXTCARD         constant com_api_type_pkg.t_dict_value := 'CITPXCRD';
    CLIENT_ID_TYPE_MERCHANT        constant com_api_type_pkg.t_dict_value := 'CITPMRCT';
    CLIENT_ID_TYPE_TERMINAL        constant com_api_type_pkg.t_dict_value := 'CITPTRMN';

    EVENT_ACTIVE_DELIVERY_ADDR     constant com_api_type_pkg.t_dict_value := 'EVNT1701';
    EVENT_DEACTIVE_DELIVERY_ADDR   constant com_api_type_pkg.t_dict_value := 'EVNT1702';
    EVENT_PROCESSED_SUCCESSFULLY   constant com_api_type_pkg.t_dict_value := 'EVNT1710';
    EVENT_PROCESSED_WITH_ERRORS    constant com_api_type_pkg.t_dict_value := 'EVNT1720';
    EVENT_SETTLEMENT_SUCCESSFUL    constant com_api_type_pkg.t_dict_value := 'EVNT1730';
    EVENT_SETTLEMENT_UNSUCCESSFUL  constant com_api_type_pkg.t_dict_value := 'EVNT1740';
    EVENT_OPERATION_STATUS_CHANGED constant com_api_type_pkg.t_dict_value := 'EVNT1750';
    EVENT_LOADED_SUCCESSFULLY      constant com_api_type_pkg.t_dict_value := 'EVNT1908';
    EVENT_LOADED_WITH_ERRORS       constant com_api_type_pkg.t_dict_value := 'EVNT1909';

    DATA_MISMATCH_WITH_ORIGINAL    constant com_api_type_pkg.t_dict_value := 'RESP0066';

    OPER_SELECTOR_CURRENT          constant com_api_type_pkg.t_dict_value := 'OPSLCURR';
    OPER_SELECTOR_ORIGINAL         constant com_api_type_pkg.t_dict_value := 'OPSLORIG';
    OPER_SELECTOR_MATCHING         constant com_api_type_pkg.t_dict_value := 'OPSLMTCH';
    OPER_SELECTOR_PARENT_AUTH      constant com_api_type_pkg.t_dict_value := 'OPSLPAUT';

    OPER_STATUS_ARRAY_ID           constant com_api_type_pkg.t_short_id   := 10000003;

    FILE_TYPE_LOADING              constant com_api_type_pkg.t_dict_value := 'FLTP1700';
    FILE_TYPE_UNLOADING            constant com_api_type_pkg.t_dict_value := 'FLTP1710';

    UNLOADING_OPER_STATUS_SUCCESS  constant com_api_type_pkg.t_dict_value := 'UOSTSUCC';
    UNLOADING_OPER_STATUS_DECLINE  constant com_api_type_pkg.t_dict_value := 'UOSTDECL';
    UNLOADING_OPER_STATUS_ALL      constant com_api_type_pkg.t_dict_value := 'UOSTALL';

    NDF_MODE_STOP_OPERATION        constant com_api_type_pkg.t_dict_value := 'NDFMSTOP';
    NDF_MODE_STOP_RULE_SET         constant com_api_type_pkg.t_dict_value := 'NDFMSTPR';
    NDF_MODE_CONTINUE_OPERATION    constant com_api_type_pkg.t_dict_value := 'NDFMCONT';

    OPER_TYPE_CREDIT_ARRAY_ID      constant com_api_type_pkg.t_short_id   := 10000011;
    STTL_TYPE_ISS_ARRAY_ID         constant com_api_type_pkg.t_medium_id  := 10000012;
    STTL_TYPE_ACQ_ARRAY_ID         constant com_api_type_pkg.t_medium_id  := 10000013;

    REVERSAL_UPLOAD_ALL            constant com_api_type_pkg.t_dict_value := 'UTORALL';
    REVERSAL_UPLOAD_ORIGINAL       constant com_api_type_pkg.t_dict_value := 'UTORORGN';
    REVERSAL_UPLOAD_WITHOUT_MERGED constant com_api_type_pkg.t_dict_value := 'UTORWMRG';
    
    OPER_STAGE_CMD_KEY             constant com_api_type_pkg.t_dict_value := 'OPCM';
    OPER_STAGE_CMD_PROC_NORMALLY   constant com_api_type_pkg.t_dict_value := 'OPCM0000';
    
    LOV_ID_PARTICIPATING_PARTIES   constant com_api_type_pkg.t_tiny_id    := 98;
    LOV_ID_OPERATION_TYPES         constant com_api_type_pkg.t_tiny_id    := 49;

    OPER_REASON_KEY                constant com_api_type_pkg.t_dict_value := 'OPRS';
    OPER_REASON_VSS_FEE_NEGATIVE   constant com_api_type_pkg.t_dict_value := 'OPRS0001';
    OPER_REASON_VSS_FEE_POSITIVE   constant com_api_type_pkg.t_dict_value := 'OPRS0002';

    OPER_MATCHING_AFTER            constant com_api_type_pkg.t_dict_value := 'RMCH0000';
    OPER_MATCHING_SAME_DAY         constant com_api_type_pkg.t_dict_value := 'RMCH0001';

end opr_api_const_pkg;
/
