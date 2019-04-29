create or replace package app_api_history_pkg is

procedure add_history (
    i_appl_id               in com_api_type_pkg.t_long_id
  , i_action                in com_api_type_pkg.t_name
  , i_comments              in com_api_type_pkg.t_full_desc
  , i_new_appl_status       in com_api_type_pkg.t_dict_value
  , i_old_appl_status       in com_api_type_pkg.t_dict_value
  , i_new_reject_code       in com_api_type_pkg.t_dict_value
  , i_old_reject_code       in com_api_type_pkg.t_dict_value
);
    
procedure remove_history (
    i_id                    in com_api_type_pkg.t_long_id
);
    
function get_previous_status (
    i_appl_id               in com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_dict_value;

end app_api_history_pkg;
/
