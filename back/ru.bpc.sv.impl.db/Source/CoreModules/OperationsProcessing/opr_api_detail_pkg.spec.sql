create or replace package opr_api_detail_pkg is

function get_oper_detail(
    i_oper_id            in     com_api_type_pkg.t_long_id
) return opr_api_type_pkg.t_oper_detail_tab;

procedure set_oper_detail(
    i_oper_id            in     com_api_type_pkg.t_long_id
  , i_object_tab         in     opr_api_type_pkg.t_oper_detail_tab
  , i_date               in     date
);

procedure set_oper_detail(
    i_oper_id               in      com_api_type_pkg.t_long_id
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
);

procedure remove_oper_detail(
    i_id_tab             in     com_api_type_pkg.t_long_tab
);

procedure remove_oper_detail(
    i_oper_id            in     com_api_type_pkg.t_long_id
);

end opr_api_detail_pkg;
/
