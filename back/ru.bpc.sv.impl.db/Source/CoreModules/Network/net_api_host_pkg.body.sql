create or replace package body net_api_host_pkg as
/**********************************************************
*  API for hosts <br />
*  Created by Fomichev A.(fomichev@bpcbt.com)  at 04.07.2012 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: net_api_host_pkg  <br />
*  @headcom
***********************************************************/

procedure get_host_param_value(
    i_param_name      in     com_api_type_pkg.t_name
  , i_host_member_id  in     com_api_type_pkg.t_tiny_id
  , o_param_value        out varchar2
) is
begin
    select param_value
      into o_param_value
      from (
            select param_value
              from net_api_interface_param_val_vw
             where param_name     = i_param_name  
               and host_member_id = i_host_member_id
               and data_type      = com_api_const_pkg.DATA_TYPE_CHAR
            union all
            select param_value
              from net_api_device_param_value_vw a
                 , net_device b
             where a.param_name     = i_param_name  
               and b.host_member_id = i_host_member_id
               and a.data_type      = com_api_const_pkg.DATA_TYPE_CHAR
               and b.device_id      = a.device_id
           )
     where rownum = 1;
exception
    when no_data_found then 
        o_param_value := null;
end;

procedure get_host_param_value(
    i_param_name      in     com_api_type_pkg.t_name
  , i_host_member_id  in     com_api_type_pkg.t_tiny_id
  , o_param_value        out number
) is
begin
    select to_number(param_value, com_api_const_pkg.NUMBER_FORMAT)
      into o_param_value
      from (
            select param_value
              from net_api_interface_param_val_vw
             where param_name     = i_param_name  
               and host_member_id = i_host_member_id
               and data_type      = com_api_const_pkg.DATA_TYPE_NUMBER
            union all
            select param_value
              from net_api_device_param_value_vw a
                 , net_device b
             where a.param_name     = i_param_name  
               and b.host_member_id = i_host_member_id
               and a.data_type      = com_api_const_pkg.DATA_TYPE_NUMBER
               and b.device_id      = a.device_id
           )
     where rownum = 1;
exception
    when no_data_found then 
        o_param_value := null;
end;

procedure get_host_param_value(
    i_param_name      in     com_api_type_pkg.t_name
  , i_host_member_id  in     com_api_type_pkg.t_tiny_id
  , o_param_value        out date
) is
begin
    select to_date(param_value, com_api_const_pkg.DATE_FORMAT)
      into o_param_value
      from (
            select param_value
              from net_api_interface_param_val_vw
             where param_name     = i_param_name  
               and host_member_id = i_host_member_id
               and data_type      = com_api_const_pkg.DATA_TYPE_DATE
            union all
            select param_value
              from net_api_device_param_value_vw a
                 , net_device b
             where a.param_name     = i_param_name  
               and b.host_member_id = i_host_member_id
               and a.data_type      = com_api_const_pkg.DATA_TYPE_DATE
               and b.device_id      = a.device_id
           )
     where rownum = 1;
exception
    when no_data_found then 
        o_param_value := null;
end;

end;
/
