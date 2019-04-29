create or replace package rcn_api_const_pkg as

    RECON_TYPE_KEY                 constant com_api_type_pkg.t_dict_value := 'RCNT';
    RECON_TYPE_COMMON              constant com_api_type_pkg.t_dict_value := 'RCNTCOMM';
    RECON_TYPE_ATM_EJOURNAL        constant com_api_type_pkg.t_dict_value := 'RCNTATMJ';
    RECON_TYPE_HOST                constant com_api_type_pkg.t_dict_value := 'RCNTHOST';
    RECON_TYPE_SRVP                constant com_api_type_pkg.t_dict_value := 'RCNTSRVP';
    RECON_TYPE_NTSW                constant com_api_type_pkg.t_dict_value := 'RCNTNTSW';

    RECON_FILE_TYPE_SRVP           constant com_api_type_pkg.t_dict_value := 'FLTP2101';
    RECON_FILE_TYPE_HOST           constant com_api_type_pkg.t_dict_value := 'FLTP2102';

    RECON_MSG_SOURCE_KEY           constant com_api_type_pkg.t_dict_value := 'RMSC';
    RECON_MSG_SOURCE_INTERNAL      constant com_api_type_pkg.t_dict_value := 'RMSC0000';
    RECON_MSG_SOURCE_CBS           constant com_api_type_pkg.t_dict_value := 'RMSC0001';
    RECON_MSG_SOURCE_ATM_EJOURNAL  constant com_api_type_pkg.t_dict_value := 'RMSC0002';
    RECON_MSG_SOURCE_HOST          constant com_api_type_pkg.t_dict_value := 'RMSC0003';
    RECON_MSG_SOURCE_SRVP          constant com_api_type_pkg.t_dict_value := 'RMSC0004';
    RECON_MSG_SOURCE_NTSW          constant com_api_type_pkg.t_dict_value := 'RMSC0005';

    RECON_STATUS_KEY               constant com_api_type_pkg.t_dict_value := 'RNST';
    RECON_STATUS_FAILED            constant com_api_type_pkg.t_dict_value := 'RNST0100';
    RECON_STATUS_REQ_RECON         constant com_api_type_pkg.t_dict_value := 'RNST0200';
    RECON_STATUS_NOT_REQ_RECON     constant com_api_type_pkg.t_dict_value := 'RNST0300';
    RECON_STATUS_EXPIRED           constant com_api_type_pkg.t_dict_value := 'RNST0400';
    RECON_STATUS_SUCCESSFULL       constant com_api_type_pkg.t_dict_value := 'RNST0500';
    RECON_STATUS_MATCHED_COMP      constant com_api_type_pkg.t_dict_value := 'RNST0600';
    RECON_STATUS_MATCHED_DUPL      constant com_api_type_pkg.t_dict_value := 'RNST0700';

    RECON_CONDITION_KEY            constant com_api_type_pkg.t_dict_value := 'RCTP';
    RECON_CONDITION_CONNECTIVE     constant com_api_type_pkg.t_dict_value := 'RCTPCONN';
    RECON_CONDITION_COMPARATIVE    constant com_api_type_pkg.t_dict_value := 'RCTPCOMP';

    PROCESSING_INST                constant com_api_type_pkg.t_inst_id    := 1001;

    DEFAULT_EXPIRED_PERIOD         constant com_api_type_pkg.t_tiny_id    := 30;

    ENTITY_TYPE_CBS_RECON          constant com_api_type_pkg.t_dict_value := 'ENTT0155';
    ENTITY_TYPE_ATM_RECON          constant com_api_type_pkg.t_dict_value := 'ENTT0156';
    ENTITY_TYPE_HOST_RECON         constant com_api_type_pkg.t_dict_value := 'ENTT0157';

    EVENT_TYPE_RCN_SUCCESS         constant com_api_type_pkg.t_dict_value := 'EVNT2100'; -- Hosts reconciliation message successful
    EVENT_TYPE_RCN_FAILED          constant com_api_type_pkg.t_dict_value := 'EVNT2101'; -- Hosts reconciliation message failed
    EVENT_TYPE_RCN_EXPIRED         constant com_api_type_pkg.t_dict_value := 'EVNT2102'; -- Hosts reconciliation message expired
    EVENT_TYPE_RCN_COMP_ERR        constant com_api_type_pkg.t_dict_value := 'EVNT2103'; -- Hosts reconciliation message matched, has comparative errors
    EVENT_TYPE_RCN_DUPLICATED      constant com_api_type_pkg.t_dict_value := 'EVNT2104'; -- Hosts reconciliation message matched – duplicate

    EMV_TAGS_LIST_FOR_HOSTS        constant emv_api_type_pkg.t_emv_tag_type_tab := h2h_api_const_pkg.EMV_TAGS_LIST_FOR_H2H;

end rcn_api_const_pkg;
/
