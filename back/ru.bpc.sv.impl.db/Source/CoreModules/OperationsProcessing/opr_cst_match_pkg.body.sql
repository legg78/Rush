create or replace package body opr_cst_match_pkg is

procedure after_matching(
    i_oper_id       in  com_api_type_pkg.t_long_id
    , i_auth_id     in  com_api_type_pkg.t_long_id
    , i_is_matched  in  com_api_type_pkg.t_boolean
)
is
begin
    trc_log_pkg.debug(
        i_text          => 'opr_cst_match_pkg.after_matching [#1] [#2] [#3]'
      , i_env_param1    => i_oper_id
      , i_env_param2    => i_auth_id
      , i_env_param3    => i_is_matched
    );
end;

end;
/