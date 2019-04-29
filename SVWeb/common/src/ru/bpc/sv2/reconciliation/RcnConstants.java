package ru.bpc.sv2.reconciliation;

public interface RcnConstants {
    public static final String VIEW_RECONCILIATION      = "VIEW_RECONCILIATION";
    public static final String VIEW_RECONCILIATION_CBS  = "VIEW_RECONCILIATION_CBS";
    public static final String VIEW_RECONCILIATION_ATM  = "VIEW_RECONCILIATION_ATM";
    public static final String VIEW_RECONCILIATION_HOST = "VIEW_RECONCILIATION_HOST";
    public static final String VIEW_RECONCILIATION_SP   = "VIEW_RECONCILIATION_SP";

    public static final String VIEW_CBS_CONDITIONS      = "VIEW_RCN_CBS_CONDITIONS";
    public static final String VIEW_CBS_MESSAGES        = "VIEW_RCN_CBS_MESSAGES";

    public static final String VIEW_ATM_CONDITIONS      = "VIEW_RCN_ATM_CONDITIONS";
    public static final String VIEW_ATM_MESSAGES        = "VIEW_RCN_ATM_MESSAGES";

    public static final String VIEW_HOST_CONDITIONS     = "VIEW_RCN_HOST_CONDITIONS";
    public static final String VIEW_HOST_MESSAGES       = "VIEW_RCN_HOST_MESSAGES";

    public static final String VIEW_SP_CONDITIONS       = "VIEW_RCN_SP_CONDITIONS";
    public static final String VIEW_SP_MESSAGES         = "VIEW_RCN_SP_MESSAGES";
    public static final String VIEW_SP_PARAMETERS       = "VIEW_RCN_SP_PARAMETERS";

    public static final String ADD_CBS_CONDITIONS       = "ADD_RCN_CBS_CONDITIONS";
    public static final String MODIFY_CBS_CONDITIONS    = "MODIFY_RCN_CBS_CONDITIONS";
    public static final String REMOVE_CBS_CONDITIONS    = "REMOVE_RCN_CBS_CONDITIONS";

    public static final String ADD_CBS_MESSAGES         = "ADD_RCN_CBS_MESSAGES";
    public static final String MODIFY_CBS_MESSAGES      = "MODIFY_RCN_CBS_MESSAGES";
    public static final String REMOVE_CBS_MESSAGES      = "REMOVE_RCN_CBS_MESSAGES";

    public static final String ADD_ATM_CONDITIONS       = "ADD_RCN_ATM_CONDITIONS";
    public static final String MODIFY_ATM_CONDITIONS    = "MODIFY_RCN_ATM_CONDITIONS";
    public static final String REMOVE_ATM_CONDITIONS    = "REMOVE_RCN_ATM_CONDITIONS";

    public static final String ADD_ATM_MESSAGES         = "ADD_RCN_ATM_MESSAGES";
    public static final String MODIFY_ATM_MESSAGES      = "MODIFY_RCN_ATM_MESSAGES";
    public static final String REMOVE_ATM_MESSAGES      = "REMOVE_RCN_ATM_MESSAGES";

    public static final String ADD_HOST_CONDITIONS      = "ADD_RCN_HOST_CONDITIONS";
    public static final String MODIFY_HOST_CONDITIONS   = "MODIFY_RCN_HOST_CONDITIONS";
    public static final String REMOVE_HOST_CONDITIONS   = "REMOVE_RCN_HOST_CONDITIONS";

    public static final String ADD_HOST_MESSAGES        = "ADD_RCN_HOST_MESSAGES";
    public static final String MODIFY_HOST_MESSAGES     = "MODIFY_RCN_HOST_MESSAGES";
    public static final String REMOVE_HOST_MESSAGES     = "REMOVE_RCN_HOST_MESSAGES";

    public static final String ADD_SP_CONDITIONS        = "ADD_RCN_SP_CONDITIONS";
    public static final String MODIFY_SP_CONDITIONS     = "MODIFY_RCN_SP_CONDITIONS";
    public static final String REMOVE_SP_CONDITIONS     = "REMOVE_RCN_SP_CONDITIONS";

    public static final String ADD_SP_MESSAGES          = "ADD_RCN_SP_MESSAGES";
    public static final String MODIFY_SP_MESSAGES       = "MODIFY_RCN_SP_MESSAGES";
    public static final String REMOVE_SP_MESSAGES       = "REMOVE_RCN_SP_MESSAGES";

    public static final String ADD_SP_PARAMETERS        = "ADD_RCN_SP_PARAMETERS";
    public static final String MODIFY_SP_PARAMETERS     = "MODIFY_RCN_SP_PARAMETERS";
    public static final String REMOVE_SP_PARAMETERS     = "REMOVE_RCN_SP_PARAMETERS";

    public static final String NOT_RECONCILED              = "RNST0000";
    public static final String RECONCILIATION_FAILED       = "RNST0100";
    public static final String RECONCILIATION_REQUIRED     = "RNST0200";
    public static final String RECONCILIATION_NOT_REQUIRED = "RNST0300";
    public static final String RECONCILIATION_EXPIRED      = "RNST0400";
    public static final String RECONCILED_SUCCESSFULLY     = "RNST0500";
    public static final String MATCHED_WITH_ERRORS         = "RNST0600";
    public static final String MATCHED_WITH_DUPLICATES     = "RNST0700";

    public static final String MSG_SRC_PROCESSING_IN_SV    = "RMSC0000";
    public static final String MSG_SRC_CBS_RECONCILIATION  = "RMSC0001";
    public static final String MSG_SRC_SVFE_ATM_EJOURNAL   = "RMSC0002";
    public static final String MSG_SRC_HOST_RECONCILIATION = "RMSC0003";
    public static final String MSG_SRC_SRVP_RECONCILIATION = "RMSC0004";
    public static final String MSG_SRC_NTSW_RECONCILIATION = "RMSC0005";

    public static final String RECONCILIATION_TYPE_COMMON  = "RCNTCOMM";
    public static final String NATIONAL_SWITCH_RECON_TYPE  = "RCNTNTSW";

    public static final String MODULE_CBS  = "CBS";
    public static final String MODULE_ATM  = "ATM";
    public static final String MODULE_HOST = "HOST";
    public static final String MODULE_SP   = "SRVP";

    public static final String EXPORT_PREFIX_DEFAULT = "rcn_";
    public static final String EXPORT_PREFIX_CBS     = "rcn_cbs_";
    public static final String EXPORT_PREFIX_ATM     = "rcn_atm_";
    public static final String EXPORT_PREFIX_HOST    = "rcn_host_";
    public static final String EXPORT_PREFIX_SP      = "rcn_srvp_";
}
