create or replace package body prc_api_lock_pkg as
/*
* API for DBMS_LOCK<br/>
* Created by Kryukov E.(krukov@bpc.ru)  at 08.04.2010<br/>
* Last changed by $Author$<br/>
* $LastChangedDate::                           $<br/>
* Revision: $LastChangedRevision$<br/>
* Module: PRC_API_LOCK_PKG
* @headcom
*/

function request_lock(
    i_session_id           in  com_api_type_pkg.t_long_id
  , i_semaphore_name       in  com_api_type_pkg.t_semaphore_name
) return com_api_type_pkg.t_sign is
    pragma autonomous_transaction;
begin

    -- create semaphore for the current semaphore_name.
    insert into prc_semaphore (
        session_id     
      , semaphore_name
    ) values (
        i_session_id     
      , i_semaphore_name
    );
    
    commit;
    
    trc_log_pkg.debug(
        i_text => 'Added semaphore_name [' || i_semaphore_name || '] by session [' || i_session_id || ']'
    );
    
    return 0;
exception
    when dup_val_on_index then
        rollback;
        return 1;    
end;  

function release_lock(
    i_session_id           in  com_api_type_pkg.t_long_id
  , i_semaphore_name       in  com_api_type_pkg.t_semaphore_name
) return com_api_type_pkg.t_sign is    
    pragma autonomous_transaction;
begin

    delete from prc_semaphore 
     where session_id     = i_session_id 
       and semaphore_name = i_semaphore_name;
    
    if sql%rowcount = 0 then
        rollback;
        return 1;
    else
        commit;

        trc_log_pkg.debug(
            i_text => 'Released semaphore_name [' || i_semaphore_name || '] by session [' || i_session_id || ']'
        );        
        return 0;
    end if;        
end;

end prc_api_lock_pkg;
/
