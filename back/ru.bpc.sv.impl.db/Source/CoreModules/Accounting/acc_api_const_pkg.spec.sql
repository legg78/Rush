create or replace package acc_api_const_pkg is
/*********************************************************
 *  Constants for accounts <br />
 *  Created by Khougaev A.(khougaev@bpcbt.com)  at 21.08.2009 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: ACC_API_CONST_PKG  <br />
 *  @headcom
 **********************************************************/

    ACCOUNT_STATUS_KEY              constant com_api_type_pkg.t_dict_value := 'ACST';
    ACCOUNT_STATUS_ACTIVE           constant com_api_type_pkg.t_dict_value := 'ACSTACTV';
    ACCOUNT_STATUS_CLOSED           constant com_api_type_pkg.t_dict_value := 'ACSTCLSD';
    ACCOUNT_STATUS_PENDING          constant com_api_type_pkg.t_dict_value := 'ACSTPEND';
    ACCOUNT_STATUS_CREDITS          constant com_api_type_pkg.t_dict_value := 'ACSTCRED';
    ACCOUNT_STATUS_INCOLLECTION     constant com_api_type_pkg.t_dict_value := 'ACSTCOLL';
    ACCOUNT_STATUS_DEBT_RESTRUCT    constant com_api_type_pkg.t_dict_value := 'ACSTDRST';
    ACCOUNT_STATUS_ACTIVE_REQUIRED  constant com_api_type_pkg.t_dict_value := 'ACSTACRQ';

    BALANCE_STATUS_KEY              constant com_api_type_pkg.t_dict_value := 'BLST';
    BALANCE_STATUS_ACTIVE           constant com_api_type_pkg.t_dict_value := 'BLSTACTV';
    BALANCE_STATUS_INACTIVE         constant com_api_type_pkg.t_dict_value := 'BLSTINCT';
    BALANCE_STATUS_FIRST_USAGE      constant com_api_type_pkg.t_dict_value := 'BLSTFRST';
    BALANCE_STATUS_CLOSED           constant com_api_type_pkg.t_dict_value := 'BLSTCLSD';

    POSTING_METHOD_KEY              constant com_api_type_pkg.t_dict_value := 'POST';
    POSTING_METHOD_IMMEDIATE        constant com_api_type_pkg.t_dict_value := 'POSTIMDT';
    POSTING_METHOD_BULK             constant com_api_type_pkg.t_dict_value := 'POSTBULK';
    POSTING_METHOD_BUFFERED         constant com_api_type_pkg.t_dict_value := 'POSTBUFF';
    POSTING_METHOD_PENDING          constant com_api_type_pkg.t_dict_value := 'POSTPEND';
    POSTING_METHOD_RESERV           constant com_api_type_pkg.t_dict_value := 'POSTRSRV';

    DEFAULT_ACCOUNT_NAME            constant com_api_type_pkg.t_oracle_name := com_api_const_pkg.ACCOUNT_PURPOSE_MACROS;
    DEFAULT_AMOUNT_NAME             constant com_api_type_pkg.t_oracle_name := com_api_const_pkg.AMOUNT_PURPOSE_MACROS;
    DEFAULT_DATE_NAME               constant com_api_type_pkg.t_oracle_name := com_api_const_pkg.DATE_PURPOSE_MACROS;

    ACCOUNT_TYPE_KEY                constant com_api_type_pkg.t_dict_value := 'ACTP';
    ACCOUNT_TYPE_FEES               constant com_api_type_pkg.t_dict_value := 'ACTP0300';
    ACCOUNT_TYPE_LIABILITIES        constant com_api_type_pkg.t_dict_value := 'ACTP0303';
    ACCOUNT_TYPE_NESP_EXCEED_A      constant com_api_type_pkg.t_dict_value := 'ACTP0304';
    ACCOUNT_TYPE_NESP_EXCEED_P      constant com_api_type_pkg.t_dict_value := 'ACTP0305';
    ACCOUNT_TYPE_CARD               constant com_api_type_pkg.t_dict_value := 'ACTP0100';
    ACCOUNT_TYPE_SAVING             constant com_api_type_pkg.t_dict_value := 'ACTP0110';
    ACCOUNT_TYPE_CREDIT             constant com_api_type_pkg.t_dict_value := 'ACTP0130';
    ACCOUNT_TYPE_MERCHANT           constant com_api_type_pkg.t_dict_value := 'ACTP0200';
    ACCOUNT_TYPE_PAYM_PROV_DEPOSIT  constant com_api_type_pkg.t_dict_value := 'ACTP1401'; -- Payment provider deposit account
    ACCOUNT_TYPE_SAVINGS_ACCOUNT    constant com_api_type_pkg.t_dict_value := 'ACTP0110';
    ACCOUNT_TYPE_CHECKING_ACCOUNT   constant com_api_type_pkg.t_dict_value := 'ACTP0120';

    BALANCE_TYPE_KEY                constant com_api_type_pkg.t_dict_value := 'BLTP';
    BALANCE_TYPE_LEDGER             constant com_api_type_pkg.t_dict_value := 'BLTP0001';
    BALANCE_TYPE_HOLD               constant com_api_type_pkg.t_dict_value := 'BLTP0002';
    BALANCE_TYPE_FEES               constant com_api_type_pkg.t_dict_value := 'BLTP0003';
    BALANCE_TYPE_DISPUTE            constant com_api_type_pkg.t_dict_value := 'BLTP0004';
    BALANCE_TYPE_FROZEN             constant com_api_type_pkg.t_dict_value := 'BLTP0005';
    BALANCE_TYPE_OVERDRAFT          constant com_api_type_pkg.t_dict_value := 'BLTP1002';
    BALANCE_TYPE_OVERDUE            constant com_api_type_pkg.t_dict_value := 'BLTP1004';
    BALANCE_TYPE_OVERDUE_INTEREST   constant com_api_type_pkg.t_dict_value := 'BLTP1005';
    BALANCE_TYPE_OVERLIMIT          constant com_api_type_pkg.t_dict_value := 'BLTP1007';
    BALANCE_TYPE_USED_EXCEED_LIMIT  constant com_api_type_pkg.t_dict_value := 'BLTP1013';
    BALANCE_TYPE_DEPOSIT            constant com_api_type_pkg.t_dict_value := 'BLTP1010';

    ENTITY_TYPE_ENTRY               constant com_api_type_pkg.t_dict_value := 'ENTTENTR';
    ENTITY_TYPE_ACCOUNT             constant com_api_type_pkg.t_dict_value := 'ENTTACCT';
    ENTITY_TYPE_BALANCE             constant com_api_type_pkg.t_dict_value := 'ENTTBLNC';
    ENTITY_TYPE_MACROS              constant com_api_type_pkg.t_dict_value := 'ENTTMACR';
    ENTITY_TYPE_BUNCH               constant com_api_type_pkg.t_dict_value := 'ENTTBNCH';
    ENTITY_TYPE_TRANSACTION         constant com_api_type_pkg.t_dict_value := 'ENTTTRSC';

    EVENT_ACCOUNT_CREATION          constant com_api_type_pkg.t_dict_value := 'EVNT0320';
    EVENT_ACCOUNT_CLOSING           constant com_api_type_pkg.t_dict_value := 'EVNT0390';
    EVENT_BALANCE_CREATION          constant com_api_type_pkg.t_dict_value := 'EVNT0340';
    EVENT_BALANCE_ACCOUNT_CREATION  constant com_api_type_pkg.t_dict_value := 'EVNT0341';
    EVENT_BALANCE_ACCOUNT_CLOSED    constant com_api_type_pkg.t_dict_value := 'EVNT0342';
    EVENT_ENTRY_POSTING             constant com_api_type_pkg.t_dict_value := 'EVNT0360';
    EVENT_TRANSACTION_REGISTERED    constant com_api_type_pkg.t_dict_value := 'EVNT0361';
    EVENT_ENTRY_IS_CLEARED          constant com_api_type_pkg.t_dict_value := 'EVNT0362';
    EVENT_ACCOUNT_SRV_ACTIVATION    constant com_api_type_pkg.t_dict_value := 'EVNT0300';
    EVENT_ACCOUNT_SRV_DEACTIVATION  constant com_api_type_pkg.t_dict_value := 'EVNT0301';
    EVENT_ACCOUNT_STATUS_CHANGE     constant com_api_type_pkg.t_dict_value := 'EVNT0310';
    EVENT_MIN_THRESHOLD_OVERCOMING  constant com_api_type_pkg.t_dict_value := 'EVNT2009';

    -- Write-off without accept activate and deactivate
    EVENT_DIRECT_DEBITING_ACTIVE    constant com_api_type_pkg.t_dict_value := 'EVNT0321';
    EVENT_DIRECT_DEBITING_INACTIVE  constant com_api_type_pkg.t_dict_value := 'EVNT0322';

    EVENT_ATTRIBUTE_CHANGE_ACCOUNT  constant com_api_type_pkg.t_dict_value := 'EVNT0380';
    EVENT_ACCOUNT_ATTR_END_CHANGE   constant com_api_type_pkg.t_dict_value := 'EVNT0381';

    ENTRY_EXCEPTION_NO_BALANCE      constant com_api_type_pkg.t_dict_value := 'ENER0001';
    ENTRY_EXCEPTION_NO_ACCOUNT      constant com_api_type_pkg.t_dict_value := 'ENER0002';

    SELECTION_STEP_ACCOUNT          constant com_api_type_pkg.t_dict_value := 'ALGS0010';
    SELECTION_STEP_ISO_TYPE         constant com_api_type_pkg.t_dict_value := 'ALGS0020';
    SELECTION_STEP_USAGE_ORDER      constant com_api_type_pkg.t_dict_value := 'ALGS0030';
    SELECTION_STEP_PRIORITY         constant com_api_type_pkg.t_dict_value := 'ALGS0040';
    SELECTION_STEP_OPR_CURRENCY     constant com_api_type_pkg.t_dict_value := 'ALGS0050';
    SELECTION_STEP_STTL_CURRENCY    constant com_api_type_pkg.t_dict_value := 'ALGS0060';
    SELECTION_STEP_BIN_CURRENCY     constant com_api_type_pkg.t_dict_value := 'ALGS0070';
    SELECTION_STEP_EXACT_ACCOUNT    constant com_api_type_pkg.t_dict_value := 'ALGS0080';
    SELECTION_STEP_EXACT_OPR_CURR   constant com_api_type_pkg.t_dict_value := 'ALGS0090';
    SELECTION_STEP_TERMINAL_TYPE    constant com_api_type_pkg.t_dict_value := 'ALGS0100';
    SELECTION_STEP_DEF_CURRENCY     constant com_api_type_pkg.t_dict_value := 'ALGS0110';
    SELECTION_STEP_DEF_ACCOUNT      constant com_api_type_pkg.t_dict_value := 'ALGS0120';
    SELECTION_STEP_ATM_DEFAULT      constant com_api_type_pkg.t_dict_value := 'ALGS0130';
    SELECTION_STEP_POS_DEFAULT      constant com_api_type_pkg.t_dict_value := 'ALGS0140';
    SELECTION_STEP_ACC_SEQ_NUMBER   constant com_api_type_pkg.t_dict_value := 'ALGS0150';

    SELECTION_ALGORITHM_DEFAULT     constant com_api_type_pkg.t_tiny_id    := 1;

    ENTRY_SOURCE_BUFFER             constant com_api_type_pkg.t_dict_value := 'BUSTBUFF';
    ENTRY_SOURCE_PENDING            constant com_api_type_pkg.t_dict_value := 'BUSTPEND';
    ENTRY_SOURCE_EXCEPTION          constant com_api_type_pkg.t_dict_value := 'BUSTEXCE';
    ENTRY_SOURCE_RESERV             constant com_api_type_pkg.t_dict_value := 'BUSTRSRV';

    MACROS_STATUS_POSTED            constant com_api_type_pkg.t_dict_value := 'MCSTPOST';
    MACROS_STATUS_HOLDED            constant com_api_type_pkg.t_dict_value := 'MCSTHOLD';

    ENTRY_STATUS_POSTED             constant com_api_type_pkg.t_dict_value := 'ENTRPOST';
    ENTRY_STATUS_CANCELED           constant com_api_type_pkg.t_dict_value := 'ENTRCNCL';
    ENTRY_STATUS_REVERSED           constant com_api_type_pkg.t_dict_value := 'ENTRRVRS';

    LOV_SELECTION_ALGORITHM         constant com_api_type_pkg.t_tiny_id    := 1006;

    STATEMENT_ACCOUNT_FEE           constant com_api_type_pkg.t_dict_value := 'FETP0307';
    
    LIMIT_ACCOUNT_CREDIT            constant com_api_type_pkg.t_dict_value := 'LMTP0402';

    FILE_TYPE_POSTINGS              constant com_api_type_pkg.t_dict_value := 'FLTPENTR';
    FILE_TYPE_ACCOUNTS              constant com_api_type_pkg.t_dict_value := 'FLTPACCT';
    FILE_TYPE_SETTLEMENT            constant com_api_type_pkg.t_dict_value := 'FLTPMSTT';

    AVAIL_ALGORITHM_OWN             constant com_api_type_pkg.t_dict_value := 'ABCA0000';
    AVAIL_ALGORITHM_CARD            constant com_api_type_pkg.t_dict_value := 'ABCA0001';

    TRANSACTION_TYPE_KEY            constant com_api_type_pkg.t_dict_value := 'TRNT';
    TRAN_TYPE_STTLMNT_WITH_CLIENT   constant com_api_type_pkg.t_dict_value := 'TRNT0101';
    TRAN_TYPE_FEE_FROM_CLIENT       constant com_api_type_pkg.t_dict_value := 'TRNT0102';
    TRAN_TYPE_BACKUP_CLIENT_ACC     constant com_api_type_pkg.t_dict_value := 'TRNT0103';
    TRAN_TYPE_CANCEL_OF_PAY_CLIENT  constant com_api_type_pkg.t_dict_value := 'TRNT0104';
    TRAN_TYPE_CANCEL_FEES_CLIENT    constant com_api_type_pkg.t_dict_value := 'TRNT0105';
    TRAN_TYPE_CANCEL_RESERVATION    constant com_api_type_pkg.t_dict_value := 'TRNT0106';
    TRAN_TYPE_CBS_TOP_UP            constant com_api_type_pkg.t_dict_value := 'TRNT0107';
    TRAN_TYPE_CBS_WRITE_OFF         constant com_api_type_pkg.t_dict_value := 'TRNT0108';
    TRAN_TYPE_STTLMNT_WITH_MERCHNT  constant com_api_type_pkg.t_dict_value := 'TRNT0201';
    TRAN_TYPE_FEE_FROM_MERCHANT     constant com_api_type_pkg.t_dict_value := 'TRNT0202';
    TRAN_TYPE_CANCEL_OF_PAY_MERCHN  constant com_api_type_pkg.t_dict_value := 'TRNT0203';
    TRAN_TYPE_CANCEL_FEES_MERCHANT  constant com_api_type_pkg.t_dict_value := 'TRNT0204';
    
    ATTR_ACCOUNT_CREDIT_LIMIT       constant com_api_type_pkg.t_name       := 'ACC_ACCOUNT_CREDIT_LIMIT_VALUE';
    ATTR_ACCOUNT_CREDIT_OVERLIMIT   constant com_api_type_pkg.t_name       := 'ACC_ACCOUNT_CREDIT_OVERLIMIT_VALUE';
    
    LIMIT_TYPE_MIN_TRESHOLD         constant com_api_type_pkg.t_dict_value := 'LMTP0418';

    TAG_REF_ACCOUNT_SEQ_NUMBER      constant com_api_type_pkg.t_name       := 'DF8107';

    ROUNDING_METHOD_DEFAULT         constant com_api_type_pkg.t_dict_value := 'RNDM0401';
    ROUNDING_METHOD_TWO_DECIMALS    constant com_api_type_pkg.t_dict_value := 'RNDM0402';

end acc_api_const_pkg;
/
