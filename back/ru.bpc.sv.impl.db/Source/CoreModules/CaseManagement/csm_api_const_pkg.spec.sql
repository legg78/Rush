create or replace package csm_api_const_pkg as
/*********************************************************
*  Dispute case management constants <br />
*  Created by Alalykin A. (alalykin@bpc.ru)  at 21.01.2017 <br />
*  Module: CSM_API_CONST_PKG <br />
*  @headcom
**********************************************************/

GROUPING_PERIOD_MONTH             constant    com_api_type_pkg.t_dict_value   := 'DRGPMNTH';
GROUPING_PERIOD_DAY               constant    com_api_type_pkg.t_dict_value   := 'DRGPDAYL';

CASE_SOURCE_INCOMING_CLEARING     constant    com_api_type_pkg.t_dict_value   := 'DPSCINCF';
CASE_SOURCE_MANUALLY_CREATED      constant    com_api_type_pkg.t_dict_value   := 'DPSCMNAL';

DISPUTE_REASON_DISCLAIMED         constant    com_api_type_pkg.t_dict_value   := 'DSPRAGBC';

CASE_SOURCE_MANUAL_CASE           constant    com_api_type_pkg.t_dict_value   := 'DSCS0001';
CASE_SOURCE_INCOMING_FILE         constant    com_api_type_pkg.t_dict_value   := 'DSCS0002';
CASE_SOURCE_UNPAIRED_ITEM         constant    com_api_type_pkg.t_dict_value   := 'DSCS0003';
CASE_SOURCE_ORIGINAL_TRANS        constant    com_api_type_pkg.t_dict_value   := 'DSCS0004';
CASE_SOURCE_LOSS_ADVICE           constant    com_api_type_pkg.t_dict_value   := 'DSCS0005';

CASE_PROGRESS_PRE_ARBITRATION     constant    com_api_type_pkg.t_dict_value   := 'DSPP0003';
CASE_PROGRESS_PRESENTMENT         constant    com_api_type_pkg.t_dict_value   := 'DSPP0008';
CASE_PROGRESS_PRESENTMENT_REV     constant    com_api_type_pkg.t_dict_value   := 'DSPP0009';
CASE_PROGRESS_RETRIEVAL           constant    com_api_type_pkg.t_dict_value   := 'DSPP0010';
CASE_PROGRESS_RETRIEVAL_REV       constant    com_api_type_pkg.t_dict_value   := 'DSPP0011';
CASE_PROGRESS_CHARGEBACK          constant    com_api_type_pkg.t_dict_value   := 'DSPP0012';
CASE_PROGRESS_CHARGEBACK_REV      constant    com_api_type_pkg.t_dict_value   := 'DSPP0013';
CASE_PROGRESS_REPRESENTMENT       constant    com_api_type_pkg.t_dict_value   := 'DSPP0014';
CASE_PROGRESS_REPRESENTM_REV      constant    com_api_type_pkg.t_dict_value   := 'DSPP0015';
CASE_PROGRESS_ARB_CHARGEB         constant    com_api_type_pkg.t_dict_value   := 'DSPP0016';
CASE_PROGRESS_ARB_CHARGEB_REV     constant    com_api_type_pkg.t_dict_value   := 'DSPP0017';
CASE_PROGRESS_DISPUTE             constant    com_api_type_pkg.t_dict_value   := 'DSPP0020';
CASE_PROGRESS_DISPUTE_RESP        constant    com_api_type_pkg.t_dict_value   := 'DSPP0021';
CASE_PROGRESS_DISPUTE_REV         constant    com_api_type_pkg.t_dict_value   := 'DSPP0022';
CASE_PROGRESS_DISPUTE_RESP_REV    constant    com_api_type_pkg.t_dict_value   := 'DSPP0023';

CARD_CATEGORY_UNSUPPORTED         constant    com_api_type_pkg.t_tiny_id      := -1;
CARD_CATEGORY_VISA                constant    com_api_type_pkg.t_tiny_id      := 1;
CARD_CATEGORY_MASTERCARD          constant    com_api_type_pkg.t_tiny_id      := 2;
CARD_CATEGORY_MAESTRO             constant    com_api_type_pkg.t_tiny_id      := 3;

LOV_ID_CASE_DUE_DATE_DEFAULT      constant    com_api_type_pkg.t_tiny_id      := 556;
LOV_ID_CASE_DUE_DATE_ACQ          constant    com_api_type_pkg.t_tiny_id      := 561;

EVENT_TEAM_CHANGED                constant    com_api_type_pkg.t_dict_value   := 'EVNT2113';

EXCLUDE_OPER_PROCESSED_ARRAY      constant    com_api_type_pkg.t_medium_id    := 10000082;
DISPUTE_TEAM_ARRAY                constant    com_api_type_pkg.t_short_id     := 10000077;
DISPUTE_MESSAGE_TYPE_ARRAY        constant    com_api_type_pkg.t_short_id     := 10000112;
DISPUTE_OPERATION_TYPE_ARRAY      constant    com_api_type_pkg.t_short_id     := 10000111;

CSM_STTL_INTERNAL_ARRAY           constant    com_api_type_pkg.t_short_id     := 10000117;
CSM_STTL_ISS_INTERNATION_ARRAY    constant    com_api_type_pkg.t_short_id     := 10000118;
CSM_STTL_ISS_DOMESTIC_ARRAY       constant    com_api_type_pkg.t_short_id     := 10000119;
CSM_STTL_ACQ_INTERNATION_ARRAY    constant    com_api_type_pkg.t_short_id     := 10000120;
CSM_STTL_ACQ_DOMESTIC_ARRAY       constant    com_api_type_pkg.t_short_id     := 10000121;

CASE_ACTION_HIDE_LABEL            constant    com_api_type_pkg.t_name         := 'CASE_ACTION_HIDE';
CASE_ACTION_UNHIDE_LABEL          constant    com_api_type_pkg.t_name         := 'CASE_ACTION_UNHIDE';
CASE_ACTION_DUPLICATE_LABEL       constant    com_api_type_pkg.t_name         := 'CASE_ACTION_DUPLICATE';
CASE_ACTION_LETTER_LABEL          constant    com_api_type_pkg.t_name         := 'CASE_ACTION_LETTER';
CASE_ACTION_ATTACH_LABEL          constant    com_api_type_pkg.t_name         := 'CASE_ACTION_ATTACH';
CASE_ACTION_CH_DD_FRAUD_LABEL     constant    com_api_type_pkg.t_name         := 'CASE_ACTION_CHECK_DD_FRAUD';
CASE_ACTION_CH_DD_CHBCK_LABEL     constant    com_api_type_pkg.t_name         := 'CASE_ACTION_CHECK_DD_CHBCK';
CASE_ACTION_SET_DUE_DT_LABEL      constant    com_api_type_pkg.t_name         := 'CASE_ACTION_SET_DUE_DATE';
CASE_ACTION_SET_PROGR_LABEL       constant    com_api_type_pkg.t_name         := 'CASE_ACTION_SET_PROGRESS';
CASE_ACTION_ITEM_CREATE_LABEL     constant    com_api_type_pkg.t_name         := 'CASE_ACTION_ITEM_CREATE';
CASE_ACTION_ITEM_LOAD_LABEL       constant    com_api_type_pkg.t_name         := 'CASE_ACTION_ITEM_LOAD';
CASE_ACTION_CREATE_LABEL          constant    com_api_type_pkg.t_name         := 'CASE_ACTION_CREATE';
CASE_ACTION_STATUS_CHNG_LABEL     constant    com_api_type_pkg.t_name         := 'CASE_ACTION_STATUS_CHANGE';
CASE_ACTION_OWNER_CHNG_LABEL      constant    com_api_type_pkg.t_name         := 'CASE_ACTION_OWNER_CHANGE';
CASE_ACTION_TEAM_CHNG_LABEL       constant    com_api_type_pkg.t_name         := 'CASE_ACTION_TEAM_CHANGE';
CASE_ACTION_EDIT_LABEL            constant    com_api_type_pkg.t_name         := 'CASE_ACTION_EDIT';
CASE_ACTION_OWNER_TAKE            constant    com_api_type_pkg.t_name         := 'CASE_ACTION_OWNER_TAKE';
CASE_ACTION_OWNER_REFUSE          constant    com_api_type_pkg.t_name         := 'CASE_ACTION_OWNER_REFUSE';

CASE_CHARGEBACK_TEAM              constant    com_api_type_pkg.t_tiny_id      := 2;

end csm_api_const_pkg;
/
