create or replace package orq_api_const_pkg is
/*********************************************************
*  Financial Requests - list of constants <br />
*  Created by Fomichev A.(fomichev@bpcbt.com)  at 08.06.2018 <br />
*  Module: ORQ_API_CONST_PKG <br />
*  @headcom
**********************************************************/
FLOW_ID_UNHOLD_APP             constant    com_api_type_pkg.t_tiny_id   := 1601;
FLOW_ID_BALANCE_CORRECTION     constant    com_api_type_pkg.t_tiny_id   := 1602;
FLOW_ID_BALANCE_TRANSFER       constant    com_api_type_pkg.t_tiny_id   := 1603;
FLOW_ID_COMMON_OPERATION       constant    com_api_type_pkg.t_tiny_id   := 1604;
FLOW_ID_DISPUTE_WRITE_OFF      constant    com_api_type_pkg.t_tiny_id   := 1605;

FLOW_ID_REPROCESS_OPER         constant    com_api_type_pkg.t_tiny_id   := 1606;
FLOW_ID_CHANGE_OPER_STATUS     constant    com_api_type_pkg.t_tiny_id   := 1607;
FLOW_ID_MATCH_OPER_MANUALLY    constant    com_api_type_pkg.t_tiny_id   := 1608;
FLOW_ID_MATCH_REVERSAL_OPER    constant    com_api_type_pkg.t_tiny_id   := 1609;
FLOW_ID_FEE_COLLECTION         constant    com_api_type_pkg.t_tiny_id   := 1610;
FLOW_ID_SET_OPER_STAGE         constant    com_api_type_pkg.t_tiny_id   := 1611;
FLOW_ID_LTY_SPENT_OPERATION    constant    com_api_type_pkg.t_tiny_id   := 1612;

RUL_GEN_FEE_COLLECTION         constant    com_api_type_pkg.t_tiny_id   := 1545;
RUL_GEN_MEMBER_FEE             constant    com_api_type_pkg.t_tiny_id   := 1502;

end orq_api_const_pkg;
/
