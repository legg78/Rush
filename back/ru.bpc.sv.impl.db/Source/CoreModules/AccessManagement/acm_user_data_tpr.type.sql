create or replace type acm_user_data_tpr as object (
    user_id             number(8)
  , inst_command        varchar2(8)
  , user_inst_id        number(4)
  , is_entirely         number(1)
  , is_inst_default     number(1)
  , agent_command       varchar2(8)
  , user_agent_id       number(8)
  , is_agent_default    number(1)
  , role_command        varchar2(8)
  , user_role_id        number(4)
)
/
