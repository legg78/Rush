create or replace function release_lock(i_lockname in com_api_type_pkg.t_semaphore_name) 
  return com_api_type_pkg.t_sign is
begin
  return  com_api_lock_pkg.release_lock(i_lockname => i_lockname);
end release_lock;
/
