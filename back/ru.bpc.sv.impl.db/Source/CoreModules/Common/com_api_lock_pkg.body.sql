create or replace package body com_api_lock_pkg as
/*
* API for DBMS_LOCK<br/>
* Created by Kryukov E.(krukov@bpc.ru)  at 08.04.2010<br/>
* Last changed by $Author$<br/>
* $LastChangedDate::                           $<br/>
* Revision: $LastChangedRevision$<br/>
* Module: COM_API_LOCK_PKG
* @headcom
*/

g_lockhandle com_api_type_pkg.t_param_tab;

function request_lock(
    i_entity_type        in  com_api_type_pkg.t_dict_value
  , i_object_key         in  com_api_type_pkg.t_semaphore_name
) return com_api_type_pkg.t_sign
is
    l_lockname               com_api_type_pkg.t_semaphore_name;
begin
    l_lockname := i_entity_type || i_object_key;

    return request_lock(
               i_lockname          => l_lockname
             , i_release_on_commit => com_api_const_pkg.TRUE
             , i_expiration_secs   => com_api_const_pkg.DAY_IN_SECONDS
           );
end request_lock;

function request_lock(
    i_lockname           in  com_api_type_pkg.t_semaphore_name
  , i_release_on_commit  in  com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE    
  , i_expiration_secs    in  com_api_type_pkg.t_short_id       default null
) return com_api_type_pkg.t_sign
is
    l_release_on_commit     boolean := false;

    function allocate(
        i_lockname           in  com_api_type_pkg.t_semaphore_name
      , i_expiration_secs    in  com_api_type_pkg.t_short_id
    ) return com_api_type_pkg.t_param_value
    is
        pragma autonomous_transaction;
        l_handle com_api_type_pkg.t_param_value;
    begin
        if i_expiration_secs is not null then
            dbms_lock.allocate_unique(
                lockname        => i_lockname
              , lockhandle      => l_handle
              , expiration_secs => i_expiration_secs
            );
        else
            -- Do not redefine the Oracle default value for "expiration_secs"
            -- which is equal to "10 days" now.
            dbms_lock.allocate_unique(
                lockname        => i_lockname
              , lockhandle      => l_handle
            );
        end if;

        return l_handle;
    end allocate;

  --  Return value:
  --    0 - success
  --    1 - timeout
  --    2 - deadlock
  --    3 - parameter error
  --    4 - already own lock specified by 'id' or 'lockhandle'
  --    5 - illegal lockhandle
begin  
    g_lockhandle(i_lockname) := allocate(
                                    i_lockname        => i_lockname
                                  , i_expiration_secs => i_expiration_secs
                                );

    if substr(i_lockname, 1, 8) = iss_api_const_pkg.ENTITY_TYPE_CARD then
        trc_log_pkg.debug('Set lockhandle ' || g_lockhandle(i_lockname) ||
                          ' for lockname ' || substr(i_lockname, 1, 8) ||
                          iss_api_card_pkg.get_card_mask(substr(i_lockname, 9)));
    else
        trc_log_pkg.debug('Set lockhandle ' || g_lockhandle(i_lockname) ||
                          ' for lockname ' || i_lockname);
    end if;

    if i_release_on_commit = com_api_const_pkg.TRUE then
        l_release_on_commit := true;
    end if;
    
    return dbms_lock.request(
               lockhandle        => g_lockhandle(i_lockname)
             , lockmode          => dbms_lock.x_mode
             , timeout           => 0
             , release_on_commit => l_release_on_commit
           );
end request_lock;

function release_lock(
    i_entity_type        in  com_api_type_pkg.t_dict_value
  , i_object_key         in  com_api_type_pkg.t_semaphore_name
) return com_api_type_pkg.t_sign
is
    l_lockname               com_api_type_pkg.t_semaphore_name;
begin
    l_lockname := i_entity_type || i_object_key;
  
    return release_lock(
               i_lockname => l_lockname
           );
end release_lock;

function release_lock(
    i_lockname           in  com_api_type_pkg.t_semaphore_name
) return com_api_type_pkg.t_sign
is
    l_out com_api_type_pkg.t_sign;
begin
    if g_lockhandle.exists(i_lockname) then
        l_out := dbms_lock.release(lockhandle => g_lockhandle(i_lockname));

        -- if success delete handle
        if l_out = 0 then
            g_lockhandle.delete(i_lockname);

            if substr(i_lockname, 1, 8) = iss_api_const_pkg.ENTITY_TYPE_CARD then
                trc_log_pkg.debug('Lockhandle ' || substr(i_lockname, 1, 8) ||
                                  iss_api_card_pkg.get_card_mask(substr(i_lockname, 9)) || ' is released!');
            else
                trc_log_pkg.debug('Lockhandle ' || i_lockname || ' is released!');
            end if;
        end if;
    else
        if substr(i_lockname, 1, 8) = iss_api_const_pkg.ENTITY_TYPE_CARD then
            trc_log_pkg.debug('Lockhandle for lockname ' ||
                              iss_api_card_pkg.get_card_mask(substr(i_lockname, 9)) || ' not found!');
        else
            trc_log_pkg.debug('Lockhandle for lockname [' || i_lockname || '] not found!');
        end if;

        l_out := 5; -- illegal lockhandle
    end if;

    return l_out;

end release_lock;

procedure release_locks(
    i_locks              in  com_api_type_pkg.t_name_tab
)
is
    retval              com_api_type_pkg.t_sign;
begin
    if i_locks.count > 0 then
        for i in i_locks.first .. i_locks.last loop
            if i_locks.exists(i) then
                retval := release_lock(i_locks(i));
            end if;
        end loop;
    end if;
end release_locks;

end com_api_lock_pkg;
/
