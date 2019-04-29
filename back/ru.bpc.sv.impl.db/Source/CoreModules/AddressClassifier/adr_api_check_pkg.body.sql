create or replace package body adr_api_check_pkg as
/*********************************************************
 *  Address classifier check API  <br />
 *  Created by Kondratyev A.(kondratyev@bpcbt.com)  at 31.10.2017 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: adr_api_check_pkg <br />
 *  @headcom
 **********************************************************/

-- Perform check
function perform_check (
    i_place_code              in com_api_type_pkg.t_name              default null
  , i_place_name              in com_api_type_pkg.t_name              default null
  , i_comp_id                 in com_api_type_pkg.t_tiny_id           default null
  , i_comp_level              in com_api_type_pkg.t_tiny_id           default null
  , i_postal_code             in com_api_type_pkg.t_postal_code       default null
  , i_region_code             in com_api_type_pkg.t_region_code       default null
  , i_lang                    in com_api_type_pkg.t_dict_value        default null
) return com_api_type_pkg.t_boolean
is
    l_result                     com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
begin
    begin
        select com_api_const_pkg.TRUE
          into l_result
          from adr_place
         where place_code = i_place_code
           and comp_id    = i_comp_id
           and rownum     = 1;
    exception
        when no_data_found then
            begin
                select com_api_const_pkg.TRUE
                  into l_result
                  from adr_place
                 where place_name   = i_place_name
                   and comp_id      = i_comp_id
                   and (comp_level  = i_comp_level  or i_comp_level  is null)
                   and (postal_code = i_postal_code or i_postal_code is null)
                   and (region_code = i_region_code or i_region_code is null)
                   and (lang        = i_lang        or i_lang        is null)
                   and rownum      = 1;
            exception
                when no_data_found then
                    l_result := com_api_const_pkg.FALSE;
            end;
    end;
    
    return l_result;
end perform_check;

end adr_api_check_pkg;
/
