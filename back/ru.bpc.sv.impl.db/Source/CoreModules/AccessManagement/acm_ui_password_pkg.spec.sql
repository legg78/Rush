create or replace package acm_ui_password_pkg as

procedure set_password(
    i_user_name                 in      com_api_type_pkg.t_name
  , i_old_password_hash         in      com_api_type_pkg.t_hash_value
  , i_new_password_hash         in      com_api_type_pkg.t_hash_value
  , i_password_change_needed    in      com_api_type_pkg.t_boolean      default null
);

procedure set_password(
    i_user_id                   in      com_api_type_pkg.t_short_id
  , i_old_password_hash         in      com_api_type_pkg.t_hash_value
  , i_new_password_hash         in      com_api_type_pkg.t_hash_value
  , i_skip_check                in      com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_password_change_needed    in      com_api_type_pkg.t_boolean      default null
);

end acm_ui_password_pkg;
/
