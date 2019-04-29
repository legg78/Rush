create or replace package aut_api_const_pkg is

    AUTH_PROC_TYPE_KEY                  com_api_type_pkg.t_dict_value := 'AUPT';
    AUTH_PROC_TYPE_LOAD                 com_api_type_pkg.t_dict_value := 'AUPTLOAD';
    AUTH_PROC_TYPE_REJECT               com_api_type_pkg.t_dict_value := 'AUPTREJ';
    AUTH_PROC_TYPE_IGNORE               com_api_type_pkg.t_dict_value := 'AUPTIGNR';
    DEFAULT_AUTH_PROC_TYPE              com_api_type_pkg.t_dict_value := AUTH_PROC_TYPE_LOAD; 

    AUTH_PROC_MODE_KEY                  com_api_type_pkg.t_dict_value := 'AUPM';
    AUTH_PROC_MODE_NORMAL               com_api_type_pkg.t_dict_value := 'AUPMNORM';
    AUTH_PROC_MODE_DECLINED             com_api_type_pkg.t_dict_value := 'AUPMDECL';
    AUTH_PROC_MODE_FRAUD                com_api_type_pkg.t_dict_value := 'AUPMFRD';
    AUTH_PROC_MODE_CARD_ABSENT          com_api_type_pkg.t_dict_value := 'AUPMCABS';
    DEFAULT_AUTH_PROC_MODE              com_api_type_pkg.t_dict_value := AUTH_PROC_MODE_NORMAL; 
    
    AUTH_REASON_KEY                     com_api_type_pkg.t_dict_value := 'AUSR';
    AUTH_REASON_NO_RESP_CODE            com_api_type_pkg.t_dict_value := 'AUSR0100';   
    AUTH_REASON_DUE_TO_RESP_CODE        com_api_type_pkg.t_dict_value := 'AUSR0101';
    AUTH_REASON_DUE_TO_FORCED_FLAG      com_api_type_pkg.t_dict_value := 'AUSR0102';
    AUTH_REASON_DUE_TO_COMPLT_FLAG      com_api_type_pkg.t_dict_value := 'AUSR0103';
    AUTH_REASON_WRONG_ISS_INST          com_api_type_pkg.t_dict_value := 'AUSR0210';
    AUTH_REASON_WRONG_ISS_NETW          com_api_type_pkg.t_dict_value := 'AUSR0211';
    AUTH_REASON_WRONG_ACQ_INST          com_api_type_pkg.t_dict_value := 'AUSR0212';
    AUTH_REASON_WRONG_ACQ_NETW          com_api_type_pkg.t_dict_value := 'AUSR0213';
    AUTH_REASON_WRONG_CARD_INST         com_api_type_pkg.t_dict_value := 'AUSR0214';
    AUTH_REASON_WRONG_CARD_NETW         com_api_type_pkg.t_dict_value := 'AUSR0215';
    AUTH_REASON_WRONG_TERMINAL          com_api_type_pkg.t_dict_value := 'AUSR0216';
    AUTH_REASON_WRONG_MERCHANT          com_api_type_pkg.t_dict_value := 'AUSR0217';
    AUTH_REASON_WRONG_STTL_TYPE         com_api_type_pkg.t_dict_value := 'AUSR0218';
    AUTH_REASON_UNHOLD_PRESENT          com_api_type_pkg.t_dict_value := 'AUSR0401';
    AUTH_REASON_UNHOLD_AUTO             com_api_type_pkg.t_dict_value := 'AUSR0402';
    AUTH_REASON_UNHOLD_OPERAT           com_api_type_pkg.t_dict_value := 'AUSR0403';
    AUTH_REASON_UNHOLD_CUSTOMER         com_api_type_pkg.t_dict_value := 'AUSR0404';
    AUTH_REASON_UNHOLD_PRES_ERR         com_api_type_pkg.t_dict_value := 'AUSR0405';
    AUTH_REASON_LIMIT_EXCEED            com_api_type_pkg.t_dict_value := 'AUSR0500';
    AUTH_REASON_DST_LIMIT_EXCEED        com_api_type_pkg.t_dict_value := 'AUSR0501';
    AUTH_REASON_NO_SELECT_ACCT          com_api_type_pkg.t_dict_value := 'AUSR0502';
    AUTH_REASON_NOT_ENOUGH_FUNDS        com_api_type_pkg.t_dict_value := 'AUSR0503';

    ENTITY_TYPE_AUTHORIZATION           com_api_type_pkg.t_dict_value := 'ENTTAUTH';

    MESSAGE_TYPE_ARBITR_CHARGEBACK      com_api_type_pkg.t_dict_value := 'MSGTACBK';
    MESSAGE_TYPE_AUTHORIZATION          com_api_type_pkg.t_dict_value := 'MSGTAUTH';
    MESSAGE_TYPE_CHARGEBACK             com_api_type_pkg.t_dict_value := 'MSGTCHBK';
    MESSAGE_TYPE_COMPLETION             com_api_type_pkg.t_dict_value := 'MSGTCMPL';
    MESSAGE_TYPE_PRESENTMENT            com_api_type_pkg.t_dict_value := 'MSGTPRES';
    MESSAGE_TYPE_PREATHORIZATION        com_api_type_pkg.t_dict_value := 'MSGTPREU';
    MESSAGE_TYPE_REPRESENTMENT          com_api_type_pkg.t_dict_value := 'MSGTREPR';
    MESSAGE_TYPE_SCHEDULE_REGISTR       com_api_type_pkg.t_dict_value := 'MSGTSCDL';
    MESSAGE_TYPE_VALIDATION             com_api_type_pkg.t_dict_value := 'MSGTVALD';
    MESSAGE_TYPE_FORCED_POST            com_api_type_pkg.t_dict_value := 'MSGTFPST';

    AUTH_COMPLETED_KNOWN_STATUS         com_api_type_pkg.t_dict_value := 'CMPF0010';
    AUTH_COMPLETED_UNKNOWN_STATUS       com_api_type_pkg.t_dict_value := 'CMPF0020';
    AUTH_DURING_EXECUTION               com_api_type_pkg.t_dict_value := 'CMPF0030';
    AUTH_NOT_COMPLETED_AN_ERROR         com_api_type_pkg.t_dict_value := 'CMPF0040';
    AUTH_NOT_COMPLETE_STAGE_CNCL        com_api_type_pkg.t_dict_value := 'CMPF0050';
    AUTH_NOT_COMPLETE_STAGE_CONF        com_api_type_pkg.t_dict_value := 'CMPF0060';
    
    EVENT_UNHOLD_AUTO                   constant com_api_type_pkg.t_dict_value := 'EVNT1907';
    EVENT_AUTH_BY_CARD                  constant com_api_type_pkg.t_dict_value := 'EVNT0170';

    
    MERGE_REVERSAL_NO_MERGE             constant com_api_type_pkg.t_dict_value := 'MRVA0000';
    MERGE_REVERSAL_BY_AMOUNT            constant com_api_type_pkg.t_dict_value := 'MRVA0001';
    MERGE_REVERSAL_BY_AMOUNT_STTT       constant com_api_type_pkg.t_dict_value := 'MRVA0002';

end;
/
