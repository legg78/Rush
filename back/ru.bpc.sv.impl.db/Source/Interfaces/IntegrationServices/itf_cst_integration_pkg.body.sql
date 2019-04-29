create or replace package body itf_cst_integration_pkg as

procedure get_remote_banking_activity(
    i_customer_number       in      com_api_type_pkg.t_name
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , o_banking_activity     out      com_api_type_pkg.t_boolean
) is
begin
    o_banking_activity := com_api_const_pkg.TRUE;
end get_remote_banking_activity;

end;
/
