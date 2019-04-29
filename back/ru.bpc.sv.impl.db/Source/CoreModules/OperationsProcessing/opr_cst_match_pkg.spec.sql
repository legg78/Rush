create or replace package opr_cst_match_pkg is

procedure after_matching(
    i_oper_id       in  com_api_type_pkg.t_long_id
    , i_auth_id     in  com_api_type_pkg.t_long_id
    , i_is_matched  in  com_api_type_pkg.t_boolean
);

end;
/