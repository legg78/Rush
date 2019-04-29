create or replace package body net_api_standard_pkg is
    
    g_basic_standard_id         com_api_type_pkg.t_tiny_id;

function get_inst_id (
    i_value             in com_api_type_pkg.t_name
    , i_name            in com_api_type_pkg.t_name
    , i_network_id      in com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_inst_id is
begin
    null;
end;
    
function get_basic_standard return com_api_type_pkg.t_tiny_id
is 
begin
    if g_basic_standard_id is null then
        begin
            select id
              into g_basic_standard_id
              from cmn_standard
             where standard_type = cmn_api_const_pkg.STANDART_TYPE_NETW_BASIC;
         
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error         => 'BASIC_STANDARD_NOT_DEFINED'
                ); 
                
            when too_many_rows then
                com_api_error_pkg.raise_error(
                    i_error         => 'CMN_DUPLICATE_STANDARD'
                  , i_env_param2    => cmn_api_const_pkg.STANDART_TYPE_NETW_BASIC  
                );
        end;         
    end if;
    
    return g_basic_standard_id;
end;

end;
/