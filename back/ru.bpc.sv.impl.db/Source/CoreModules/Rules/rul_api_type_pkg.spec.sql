create or replace package rul_api_type_pkg is
/*********************************************************
*  Rules types <br />
*  Created by Kopachev D.(kopachev@bpc.ru)  at 20.05.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate:: 2010-04-08 17:36:45 +0400$ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: RUL_API_TYPE_PKG <br />
*  @headcom
**********************************************************/
    type t_param_rec            is record (
        param_name              com_api_type_pkg.t_name
        , param_value           com_api_type_pkg.t_param_value
        , property              com_api_type_pkg.t_param_tab
    );
    type t_param_tab is table of t_param_rec index by binary_integer;

    type t_name_part_rec            is record (
        id                    com_api_type_pkg.t_short_id
      , format_id             com_api_type_pkg.t_tiny_id
      , part_order            com_api_type_pkg.t_tiny_id
      , base_value_type       com_api_type_pkg.t_dict_value
      , base_value            com_api_type_pkg.t_name
      , transformation_type   com_api_type_pkg.t_dict_value
      , transformation_mask   com_api_type_pkg.t_name
      , part_length           com_api_type_pkg.t_tiny_id
      , pad_type              com_api_type_pkg.t_dict_value
      , pad_string            com_api_type_pkg.t_name
      , check_part            com_api_type_pkg.t_boolean
    );
    type t_name_part_tab is table of t_name_part_rec index by binary_integer;
    
end rul_api_type_pkg;
/
