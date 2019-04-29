create or replace package crd_api_dispute_pkg is

procedure set_debt_status (
    i_oper_id           in  com_api_type_pkg.t_long_id
    , i_status          in  com_api_type_pkg.t_dict_value     
);

end;
/
