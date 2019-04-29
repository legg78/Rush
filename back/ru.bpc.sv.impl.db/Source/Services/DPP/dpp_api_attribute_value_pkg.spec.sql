create or replace package dpp_api_attribute_value_pkg is
/*********************************************************
*  API for mod attribute values <br />
*  Created by  E. Kryukov(krukov@bpc.ru)  at 07.09.2011 <br />
*  Module: DPP_API_ATTRIBUTE_VALUE_PKG <br />
*  @headcom
**********************************************************/

procedure add(
    i_dpp_id        in     com_api_type_pkg.t_long_id
  , i_attr_id       in     com_api_type_pkg.t_short_id
  , i_mod_id        in     com_api_type_pkg.t_tiny_id
  , i_value         in     com_api_type_pkg.t_name
  , i_split_hash    in     com_api_type_pkg.t_tiny_id
);

procedure save_attribute_values(
    i_dpp           in     dpp_api_type_pkg.t_dpp_program
);

end;
/
