create or replace package cst_ibbl_api_const_pkg as

NUM_FORMAT                 constant com_api_type_pkg.t_short_desc  := 'FM999G999G999G999G999G990D0099';

CHECKBOOK_STATUS_ACTIVE    constant com_api_type_pkg.t_dict_value  := 'CHBS0000'; -- Active
CHECKBOOK_STATUS_ORDERED   constant com_api_type_pkg.t_dict_value  := 'CHBS0010'; -- Ordered
CHECKBOOK_STATUS_BLOCKED   constant com_api_type_pkg.t_dict_value  := 'CHBS0100'; -- Blocked
CHECKBOOK_STATUS_SPENT     constant com_api_type_pkg.t_dict_value  := 'CHBS1000'; -- Spent

LEAFLET_STATUS_ACTIVE      constant com_api_type_pkg.t_dict_value  := 'CBLS0000'; -- Active
LEAFLET_STATUS_USED        constant com_api_type_pkg.t_dict_value  := 'CBLS1000'; -- Used

ENTITY_TYPE_CHECKBOOK      constant com_api_type_pkg.t_dict_value  := 'ENTTCHKB'; -- Checkbook

EVENT_TYPE_CHECKBOOK_REG   constant com_api_type_pkg.t_dict_value  := 'EVNT5100';

NOTE_TYPE_CB_LEAFLET       constant com_api_type_pkg.t_dict_value  := 'NTTPCHBL';

TAG_AGENT_NUMBER           constant com_api_type_pkg.t_medium_id   := 35880;
TAG_LEAFLET_COUNT          constant com_api_type_pkg.t_medium_id   := 35879;

OPERATION_PAYMENT_CBS      constant com_api_type_pkg.t_dict_value  := 'OPTP7030'; -- Payment from CBS
BDT_CURR_CODE              constant com_api_type_pkg.t_dict_value  := '050';

end cst_ibbl_api_const_pkg;
/
