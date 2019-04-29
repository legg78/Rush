create or replace package body acm_ui_password_pkg as

procedure set_password(
    i_user_name                 in      com_api_type_pkg.t_name
  , i_old_password_hash         in      com_api_type_pkg.t_hash_value
  , i_new_password_hash         in      com_api_type_pkg.t_hash_value
  , i_password_change_needed    in      com_api_type_pkg.t_boolean      default null
) 
  as
begin
    acm_api_password_pkg.set_password(
        i_user_name                 => i_user_name
      , i_old_password_hash         => i_old_password_hash
      , i_new_password_hash         => i_new_password_hash
      , i_password_change_needed    => i_password_change_needed
    );
    
    adt_api_trail_pkg.put_audit_trail(
        i_trail_id    => adt_api_trail_pkg.get_trail_id
      , i_entity_type => acm_api_const_pkg.ENTITY_TYPE_USER
      , i_object_id   => acm_ui_user_pkg.get_user_id_by_name(i_user_name => i_user_name)
      , i_action_type => acm_api_const_pkg.ACTION_TYPE_INSERT
      , i_priv_id     => acm_api_const_pkg.PRIV_CHANGE_PASSWORD
    );
end;

procedure set_password(
    i_user_id                   in      com_api_type_pkg.t_short_id
  , i_old_password_hash         in      com_api_type_pkg.t_hash_value
  , i_new_password_hash         in      com_api_type_pkg.t_hash_value
  , i_skip_check                in      com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_password_change_needed    in      com_api_type_pkg.t_boolean      default null
) 
  as
begin
    acm_api_password_pkg.set_password(
        i_user_id                   => i_user_id
      , i_old_password_hash         => i_old_password_hash
      , i_new_password_hash         => i_new_password_hash
      , i_skip_check                => i_skip_check
      , i_password_change_needed    => i_password_change_needed
    );
    
    adt_api_trail_pkg.put_audit_trail(
        i_trail_id    => adt_api_trail_pkg.get_trail_id
      , i_entity_type => acm_api_const_pkg.ENTITY_TYPE_USER
      , i_object_id   => i_user_id
      , i_action_type => acm_api_const_pkg.ACTION_TYPE_INSERT
      , i_priv_id     => acm_api_const_pkg.PRIV_CHANGE_PASSWORD
    );
end;

end acm_ui_password_pkg;
/
