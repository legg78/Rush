create or replace package ost_api_const_pkg as

UNIDENTIFIED_INST               constant    com_api_type_pkg.t_inst_id      := 9998;
DEFAULT_INST                    constant    com_api_type_pkg.t_inst_id      := 9999;
DEFAULT_AGENT                   constant    com_api_type_pkg.t_agent_id     := 99999999;

INSTITUTION_TYPE_KEY            constant    com_api_type_pkg.t_dict_value   := 'INTP';

ENTITY_TYPE_INSTITUTION         constant    com_api_type_pkg.t_dict_value   := 'ENTTINST';
ENTITY_TYPE_AGENT               constant    com_api_type_pkg.t_dict_value   := 'ENTTAGNT';

CONTRACT_TYPE_INSTITUTION       constant    com_api_type_pkg.t_dict_value   := 'CNTPINST';

AGENT_NAME_FORMAT_ID            constant    com_api_type_pkg.t_tiny_id      := 1294;
AGENT_NAME_FORMAT_INST_ID       constant    com_api_type_pkg.t_name         := 'INST_ID';
AGENT_NAME_FORMAT_AGENT_ID      constant    com_api_type_pkg.t_name         := 'AGENT_ID';
AGENT_NAME_FORMAT_EFF_DATE      constant    com_api_type_pkg.t_name         := 'SYS_DATE';

end;
/
