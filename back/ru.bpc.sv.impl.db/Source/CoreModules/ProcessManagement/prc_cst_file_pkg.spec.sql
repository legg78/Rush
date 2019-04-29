create or replace package prc_cst_file_pkg is

procedure get_next_file(
    i_file_type             in     com_api_type_pkg.t_dict_value
  , io_inst_id              in out com_api_type_pkg.t_inst_id
  , i_file_purpose          in     com_api_type_pkg.t_dict_value
);

end;
/
