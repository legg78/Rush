create or replace function get_lov_value(
    i_data_type         in      com_api_type_pkg.t_dict_value
  , i_value             in      com_api_type_pkg.t_name
  , i_lov_id            in      com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_name is
begin
    return 
        com_api_type_pkg.get_lov_value(
            i_data_type     => i_data_type
          , i_value         => i_value
          , i_lov_id        => i_lov_id
        );
end;
/