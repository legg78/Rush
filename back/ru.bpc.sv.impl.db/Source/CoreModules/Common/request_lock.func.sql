create or replace function request_lock(
    i_lockname           in  com_api_type_pkg.t_semaphore_name
  , i_release_on_commit  in  com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE    
  , i_expiration_secs    in  com_api_type_pkg.t_short_id       default null
) return com_api_type_pkg.t_sign is
begin
  return com_api_lock_pkg.request_lock(
             i_lockname          => i_lockname
           , i_release_on_commit => i_release_on_commit
           , i_expiration_secs   => i_expiration_secs
         );
end request_lock;  
/
