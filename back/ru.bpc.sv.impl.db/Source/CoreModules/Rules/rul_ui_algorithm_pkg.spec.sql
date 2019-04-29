create or replace package rul_ui_algorithm_pkg is

procedure add(
    o_id                       out com_api_type_pkg.t_tiny_id
  , o_seqnum                   out com_api_type_pkg.t_seqnum
  , i_proc_id               in     com_api_type_pkg.t_tiny_id
  , i_algorithm             in     com_api_type_pkg.t_dict_value
  , i_entry_point           in     com_api_type_pkg.t_dict_value
);

procedure modify(
    i_id                    in     com_api_type_pkg.t_tiny_id
  , io_seqnum               in out com_api_type_pkg.t_seqnum
  , i_proc_id               in     com_api_type_pkg.t_tiny_id
  , i_algorithm             in     com_api_type_pkg.t_dict_value
  , i_entry_point           in     com_api_type_pkg.t_dict_value
);

procedure remove(
    i_id                    in     com_api_type_pkg.t_tiny_id
);

end;
/
