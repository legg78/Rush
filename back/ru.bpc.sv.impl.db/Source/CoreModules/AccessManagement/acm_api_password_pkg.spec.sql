create or replace package acm_api_password_pkg as

function checking_password(
    i_user_name             in     com_api_type_pkg.t_name
    , i_password_hash       in     com_api_type_pkg.t_hash_value
) return com_api_type_pkg.t_boolean;    

procedure set_password(
    i_user_name                 in      com_api_type_pkg.t_name
  , i_old_password_hash         in      com_api_type_pkg.t_hash_value
  , i_new_password_hash         in      com_api_type_pkg.t_hash_value
  , i_password_change_needed    in      com_api_type_pkg.t_boolean      default null
);    

/*
 * Set new password's hash for user.
 * @param i_old_password_hash    hash value for old password, the parameter can be NULL
                                 when a password is set for the first time
 * @param i_skip_check           if this flag is set to true, new password's hash will not be
                                 checked for matching with one of previous passwords' hashes
 */
procedure set_password(
    i_user_id                   in      com_api_type_pkg.t_short_id
  , i_old_password_hash         in      com_api_type_pkg.t_hash_value
  , i_new_password_hash         in      com_api_type_pkg.t_hash_value
  , i_skip_check                in      com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_password_change_needed    in      com_api_type_pkg.t_boolean      default null
);    
    
function get_password_hash(
    i_user_name             in     com_api_type_pkg.t_name
) return com_api_type_pkg.t_hash_value;

function check_password_expired(
    i_user_name             in     com_api_type_pkg.t_name
) return com_api_type_pkg.t_boolean;

procedure avoid_expire_date(
    i_user_id       in      com_api_type_pkg.t_short_id
);

procedure avoid_expire_date(
    i_user_name     in      com_api_type_pkg.t_name
);

end acm_api_password_pkg;
/
