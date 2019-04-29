create or replace package adr_api_check_pkg as
/*********************************************************
 *  Address classifier check API  <br />
 *  Created by Kondratyev A.(kondratyev@bpcbt.com)  at 31.10.2017 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: csm_api_check_pkg <br />
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
) return com_api_type_pkg.t_boolean;

end adr_api_check_pkg;
/
