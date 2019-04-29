create or replace function get_date_value(
    i_data_type         in      com_api_type_pkg.t_dict_value
  , i_value             in      com_api_type_pkg.t_name
) return date is
begin
    return 
        com_api_type_pkg.get_date_value(
            i_data_type     => i_data_type
          , i_value         => i_value
        );
end;
/