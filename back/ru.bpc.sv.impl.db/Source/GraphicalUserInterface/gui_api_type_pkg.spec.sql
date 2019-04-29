create or replace package gui_api_type_pkg as
/**********************************************************
 * Types for API external GUI <br />
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 22.02.2017 <br />
 * <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: GUI_API_TYPE_PKG
 * @headcom
 **********************************************************/
type flexible_fields_rec is record(
    field_id          com_api_type_pkg.t_short_id
  , field_name        com_api_type_pkg.t_name
  , field_short_name  com_api_type_pkg.t_attr_name
);

type flexible_fields_tbl        is table of flexible_fields_rec index by binary_integer;

type flexible_fields_entity_tbl is table of flexible_fields_tbl index by com_api_type_pkg.t_dict_value;

type t_customer_min_data_rec is record(
    customer_id        com_api_type_pkg.t_medium_id
  , customer_number    com_api_type_pkg.t_name
  , customer_name      com_api_type_pkg.t_name
);

end gui_api_type_pkg;
/
