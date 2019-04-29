create or replace package frp_api_const_pkg as
/************************************************************* 
* 
*   Constants for FRP module
*
* Created by Fomichev A.(fomichev@bpc.ru)  at 12.05.2011
* Last changed by $Author: fomichev $ 
* $LastChangedDate:: 2011-05-12 16:55:00 +0400#$
* Revision: $LastChangedRevision: 9399 $
* Module: FRP_API_CONST_PKG
* @headcom
*
*************************************************************/ 

    ALERT_TYPE_ALWAYS      constant   com_api_type_pkg.t_dict_value := 'ALTPALWS';
    ALERT_TYPE_IF_USED     constant   com_api_type_pkg.t_dict_value := 'ALTPIFUS';
    ALERT_TYPE_NEVER       constant   com_api_type_pkg.t_dict_value := 'ALTPNVER';

    CHECK_TYPE_EXPRESSION  constant   com_api_type_pkg.t_dict_value := 'CHTPEXPR';
    CHECK_TYPE_MATRIX      constant   com_api_type_pkg.t_dict_value := 'CHTPMTRX';
    CHECK_TYPE_EXP_MATRIX  constant   com_api_type_pkg.t_dict_value := 'CHTPEXMT';
    
    MATRIX_TYPE_RISK_SCORE constant   com_api_type_pkg.t_dict_value := 'MTTPRISK';
    MATRIX_TYPE_BOOL_VALUE constant   com_api_type_pkg.t_dict_value := 'MTTPBOOL';

    EVENT_LEGAL_AUTH_REG   constant   com_api_type_pkg.t_dict_value := 'EVNT1201';
    EVENT_SUSP_AUTH_REG    constant   com_api_type_pkg.t_dict_value := 'EVNT1202';
    EVENT_SOFT_FRAUD_REG   constant   com_api_type_pkg.t_dict_value := 'EVNT1203';
    EVENT_FRAUD_REG        constant   com_api_type_pkg.t_dict_value := 'EVNT1204';

end;
/
