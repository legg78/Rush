create or replace package dsp_api_const_pkg as
/*********************************************************
*  Application constant <br />
*  Created by Alalykin A.(alalykin@bpc.ru) at 02.12.2016 <br />
*  Module: DSP_API_CONST_PKG <br />
*  @headcom
**********************************************************/

DUE_DATE_REASON_CODE_ANY           constant com_api_type_pkg.t_dict_value := 'Any';

DISPUTE_EXPIR_NOTIF_GAP            constant com_api_type_pkg.t_name       := 'DISPUTE_EXPIRATION_NOTIFICATION_GAP';

CYCLE_TYPE_EXPIR_NOTIF_GAP         constant com_api_type_pkg.t_dict_value := 'CYTP1503';

EVENT_DISPUTE_CASE_REGISTERED      constant com_api_type_pkg.t_dict_value := 'EVNT1919';
EVENT_DISPUTE_IN_PROGRESS          constant com_api_type_pkg.t_dict_value := 'EVNT1920';
EVENT_DISPUTE_RESOLVED_INVLD       constant com_api_type_pkg.t_dict_value := 'EVNT1921';
EVENT_DISPUTE_RESOLVED_CRD_CH      constant com_api_type_pkg.t_dict_value := 'EVNT1922';
EVENT_DISPUTE_RESOLVED_TRS_CH      constant com_api_type_pkg.t_dict_value := 'EVNT1923';
EVENT_DISPUTE_WRITE_OFF            constant com_api_type_pkg.t_dict_value := 'EVNT1924';
EVENT_DISPUTE_CLOSED               constant com_api_type_pkg.t_dict_value := 'EVNT1925';
EVENT_DISPUTE_CHANGE_STATUS        constant com_api_type_pkg.t_dict_value := 'EVNT1928';
EVENT_AUTOM_DISPUTE_CASE_REG       constant com_api_type_pkg.t_dict_value := 'EVNT1929';
EVENT_DISPUTE_ASSIGNED_USER        constant com_api_type_pkg.t_dict_value := 'EVNT1926';
EVENT_ADD_DISPUTE_COMMENT          constant com_api_type_pkg.t_dict_value := 'EVNT1927';
EVENT_DISPUTE_ACCEPT               constant com_api_type_pkg.t_dict_value := 'EVNT2114';
EVENT_DISPUTE_REJECT               constant com_api_type_pkg.t_dict_value := 'EVNT2115';
EVENT_DISPUTE_CASE_DUPLICATED      constant com_api_type_pkg.t_dict_value := 'EVNT2116';

SCALE_TYPE_DSP_VISA                constant com_api_type_pkg.t_dict_value := 'SCTPDSPV';
SCALE_TYPE_DSP_MASTERCARD          constant com_api_type_pkg.t_dict_value := 'SCTPDSPM';
SCALE_TYPE_DSP_JCB                 constant com_api_type_pkg.t_dict_value := 'SCTPDSPJ';
SCALE_TYPE_DSP_BORICA              constant com_api_type_pkg.t_dict_value := 'SCTPDSPB';
SCALE_TYPE_DSP_MIR                 constant com_api_type_pkg.t_dict_value := 'SCTPDSPP';
SCALE_TYPE_DSP_AMX                 constant com_api_type_pkg.t_dict_value := 'SCTPDSPA';

DISPUTE_PROGRESS_PRE_COMPLNCE      constant com_api_type_pkg.t_dict_value := 'DSPP0001';
DISPUTE_PROGRESS_COMPLIANCE        constant com_api_type_pkg.t_dict_value := 'DSPP0002';
DISPUTE_PROGRESS_PRE_ARBITRAT      constant com_api_type_pkg.t_dict_value := 'DSPP0003';
DISPUTE_PROGRESS_ARBITRATION       constant com_api_type_pkg.t_dict_value := 'DSPP0004';

DISPUTE_RATE_TYPE_BASE_PARAM       constant com_api_type_pkg.t_name       := 'DISPUTE_RATE_TYPE_TO_BASE_CURRENCY';

PARAM_EDIT                         constant com_api_type_pkg.t_name       := 'EDITING';

ENTITY_TYPE_DISPUTE_CASE           constant com_api_type_pkg.t_dict_value := 'ENTT0158';

end;
/
