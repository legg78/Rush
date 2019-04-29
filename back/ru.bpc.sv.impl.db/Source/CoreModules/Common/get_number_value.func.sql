create or replace function get_number_value(
    i_data_type         in      com_api_type_pkg.t_dict_value
  , i_value             in      com_api_type_pkg.t_name
  , i_format            in      com_api_type_pkg.t_name         default null
) return number is
begin
    return 
        com_api_type_pkg.get_number_value(
            i_data_type     => i_data_type
          , i_value         => i_value
          , i_format        => i_format
        );
end;
/