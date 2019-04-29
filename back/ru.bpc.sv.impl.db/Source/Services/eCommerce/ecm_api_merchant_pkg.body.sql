create or replace package body ecm_api_merchant_pkg as

procedure auth_merchant (
    i_merchant_number       in      com_api_type_pkg.t_merchant_number
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_merchant_login        in      com_api_type_pkg.t_name
  , i_merchant_password     in      com_api_type_pkg.t_name
  , o_merchant_id              out  com_api_type_pkg.t_short_id
) is
    l_result    com_api_type_pkg.t_boolean  default com_api_const_pkg.false;    
begin

    select m.id
      into o_merchant_id
      from ecm_merchant e
         , acq_merchant m
     where m.merchant_number   = i_merchant_number
       and m.inst_id           = i_inst_id
       and m.id                = e.id
       and e.merchant_login    = i_merchant_login
       and e.merchant_password = i_merchant_password;
        
exception
    when no_data_found then
        null;
end;

end ecm_api_merchant_pkg;
/
