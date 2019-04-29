create or replace package body acm_api_password_pkg as

function checking_password(
    i_user_name             in      com_api_type_pkg.t_name
    , i_password_hash       in      com_api_type_pkg.t_hash_value
) return com_api_type_pkg.t_boolean
is
    l_user_id           com_api_type_pkg.t_short_id;
    l_expire_date       date;  
begin
    l_user_id := acm_ui_user_pkg.get_user_id_by_name(i_user_name);

    select expire_date
      into l_expire_date
      from acm_user_password
     where user_id       = l_user_id
       and password_hash = i_password_hash
       and is_active     = com_api_type_pkg.TRUE;    

    if l_expire_date is not null and l_expire_date < get_sysdate then
        raise com_api_error_pkg.e_password_expired;
    end if;
    
    return acm_api_const_pkg.PASSWORD_IS_CORRECT;
exception
    when no_data_found then
        return acm_api_const_pkg.PASSWORD_IS_INCORRECT;
    when com_api_error_pkg.e_password_expired then
        return acm_api_const_pkg.PASSWORD_IS_EXPIRED;
end;

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
) is 
    LOG_PREFIX constant     com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.set_password: ';
    l_old_password_hash     com_api_type_pkg.t_hash_value;
    --l_psw_mask              com_api_type_pkg.t_name;
    l_psw_expire            pls_integer;
    l_warn_expire           pls_integer;
    l_depth_check           pls_integer;
    l_count                 com_api_type_pkg.t_count := 0;
    l_expire_date           date;  
    l_next_date             date;  
begin
    trc_log_pkg.debug(LOG_PREFIX || 'START with i_user_id [' || i_user_id
                                 || '], i_old_password_hash [' || i_old_password_hash
                                 || '], i_new_password_hash [' || i_new_password_hash
                                 || '], i_skip_check [' || i_skip_check || ']');
    begin
        select t.password_hash
          into l_old_password_hash
          from acm_user_password t
         where user_id       = i_user_id
           and is_active     = com_api_type_pkg.TRUE;
    exception
        when no_data_found then
            null;
        when too_many_rows then
            com_api_error_pkg.raise_error(
                i_error => 'WRONG_USER_PASSWORD'
            );
    end;

    -- Check old password's hash if it is necessary
    if  i_old_password_hash is not null
        and
        nvl(l_old_password_hash, '~') != i_old_password_hash
    then
        com_api_error_pkg.raise_error(
            i_error => 'WRONG_USER_PASSWORD'
        );
    end if;
    
    -- Compare new password's hash with some previous ones
    if nvl(i_skip_check, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE then
        l_depth_check := set_ui_value_pkg.get_system_param_n(
                             i_param_name => 'DEPTH_CHECK_UNIQUE'
                           , i_data_type  => com_api_const_pkg.DATA_TYPE_NUMBER
                         );

        select count(*)
          into l_count
          from (
              select password_hash
                   , row_number() over (order by expire_date desc nulls first, rowid desc) as rn
                from acm_user_password
               where user_id = i_user_id
          )
         where password_hash = i_new_password_hash
           and rn <= l_depth_check;
    end if;

    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error => 'PASSWORD_MATCHES_WITH_PREV'
        );
    else
        l_psw_expire :=  set_ui_value_pkg.get_system_param_n(
                             i_param_name => 'PASSWORD_EXPIRATION'
                           , i_data_type  => com_api_const_pkg.DATA_TYPE_NUMBER
                         );
        l_warn_expire := set_ui_value_pkg.get_system_param_n(
                             i_param_name => 'WARNING_EXPIRATION'
                           , i_data_type  => com_api_const_pkg.DATA_TYPE_NUMBER
                         );
        --l_psw_mask := set_ui_value_pkg.get_system_param_v(
        --    i_param_name       => 'PASSWORD_MASK'
        --    , i_data_type      => com_api_const_pkg.DATA_TYPE_CHAR
        --);

        if nvl(l_psw_expire, 0) > 0 then 
            l_expire_date := trunc(get_sysdate) + l_psw_expire;
            l_next_date   := l_expire_date - l_warn_expire;

            trc_log_pkg.debug(LOG_PREFIX || 'l_expire_date [' || com_api_type_pkg.convert_to_char(l_expire_date)
                                         || '], l_next_date [' || com_api_type_pkg.convert_to_char(l_next_date) || ']');
            
            fcl_api_cycle_pkg.add_cycle_counter(
                i_cycle_type        => acm_api_const_pkg.PASSWORD_EXPIRATION_CYCLE_TYPE
              , i_entity_type       => acm_api_const_pkg.ENTITY_TYPE_USER
              , i_object_id         => i_user_id
              , i_next_date         => l_next_date
              , i_inst_id           => acm_api_user_pkg.get_user_inst(i_user_id => i_user_id)
            );
        end if;
        
        if i_password_change_needed = com_api_const_pkg.TRUE then
            l_expire_date := trunc(get_sysdate) - 1;
            update acm_user
               set password_change_needed = com_api_const_pkg.FALSE
             where id = i_user_id;
        end if;

        -- Only 1 active password record is possible because of the check in the beginning
        update acm_user_password
           set is_active = com_api_type_pkg.FALSE 
         where user_id   = i_user_id
           and is_active = com_api_type_pkg.TRUE;
        
        trc_log_pkg.debug(LOG_PREFIX || '[' || sql%rowcount || '] records of acm_user_password have been updated');
        
        insert into acm_user_password(
            user_id
          , password_hash
          , is_active
          , expire_date
        ) values(
            i_user_id
          , i_new_password_hash
          , com_api_type_pkg.TRUE 
          , l_expire_date
        );

        trc_log_pkg.debug(LOG_PREFIX || 'new password has been changed');
    end if;
end set_password;

procedure set_password(
    i_user_name                 in      com_api_type_pkg.t_name
  , i_old_password_hash         in      com_api_type_pkg.t_hash_value
  , i_new_password_hash         in      com_api_type_pkg.t_hash_value
  , i_password_change_needed    in      com_api_type_pkg.t_boolean      default null
) is
begin
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.set_password: START with i_user_name [' || i_user_name
                                          || '], i_old_password_hash [' || i_old_password_hash || ']');
    set_password(
        i_user_id                   => acm_ui_user_pkg.get_user_id_by_name(i_user_name) 
      , i_old_password_hash         => i_old_password_hash
      , i_new_password_hash         => i_new_password_hash
      , i_password_change_needed    => i_password_change_needed
    );    
end set_password;

function get_password_hash(
    i_user_name             in     com_api_type_pkg.t_name
) return com_api_type_pkg.t_hash_value
is
    LOG_PREFIX constant     com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_password_hash: ';
    l_password_hash         com_api_type_pkg.t_hash_value;
begin
    trc_log_pkg.debug(LOG_PREFIX || 'START with i_user_name [' || i_user_name || ']');
    begin
        select t.password_hash
          into l_password_hash
          from acm_user_password t
         where user_id   = acm_ui_user_pkg.get_user_id_by_name(i_user_name)
           and is_active = com_api_type_pkg.TRUE;
    exception
        when no_data_found then
            return null;
        when too_many_rows then -- inconsistent data
            com_api_error_pkg.raise_error(i_error => 'WRONG_USER_PASSWORD');
    end;               
    return l_password_hash;
end get_password_hash;

function check_password_expired(
    i_user_name             in     com_api_type_pkg.t_name
) return com_api_type_pkg.t_boolean
is
    l_expire_date           date;
begin
    begin
        select expire_date
          into l_expire_date
          from acm_user_password t
         where user_id   = acm_ui_user_pkg.get_user_id_by_name(i_user_name)
           and is_active = com_api_type_pkg.TRUE;
    exception
        when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error      => 'USER_DOES_NOT_EXIST'
                  , i_env_param1 => i_user_name
                );
        when too_many_rows then -- inconsistent data
            com_api_error_pkg.raise_error(i_error => 'WRONG_USER_PASSWORD');
    end;
    if l_expire_date is not null and l_expire_date < com_api_sttl_day_pkg.get_sysdate() then
        return com_api_type_pkg.TRUE;
     else
        return com_api_type_pkg.FALSE;
    end if;
end check_password_expired;

procedure avoid_expire_date(
    i_user_id       in      com_api_type_pkg.t_short_id
) is
    l_expire_date   date;
begin
    l_expire_date := trunc(get_sysdate) - 1;

    update acm_user_password
        set expire_date = l_expire_date
      where user_id   = i_user_id
        and is_active = com_api_type_pkg.TRUE;
end avoid_expire_date;

procedure avoid_expire_date(
    i_user_name     in      com_api_type_pkg.t_name
) is
begin
    avoid_expire_date(
        i_user_id => acm_ui_user_pkg.get_user_id_by_name(i_user_name => i_user_name)
    );
end avoid_expire_date;

end acm_api_password_pkg;
/
