create or replace package com_api_lock_pkg as
/*
*------------------------------------------------------------------------<br/>
* API for DBMS_LOCK<br/>
* Created by Kryukov E.(krukov@bpc.ru)  at 08.04.2010<br/>
* Last changed by $Author$<br/>
* $LastChangedDate::                           $<br/>
* Revision: $LastChangedRevision$<br/>
* Module: COM_API_LOCK_PKG
* @headcom
*/

function request_lock(
    i_entity_type        in  com_api_type_pkg.t_dict_value
  , i_object_key         in  com_api_type_pkg.t_semaphore_name    
) return com_api_type_pkg.t_sign;

/*
*  Request lock
*    Return value:
*    0 - success
*    1 - timeout
*    2 - deadlock
*    3 - parameter error
*    4 - already own lock specified by 'id' or 'lockhandle'
*    5 - illegal lockhandle
*  @param i_lockname The name of lock   
*  @return lock value, see up
*/
function request_lock(
    i_lockname           in  com_api_type_pkg.t_semaphore_name
  , i_release_on_commit  in  com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE    
  , i_expiration_secs    in  com_api_type_pkg.t_short_id       default null
) return com_api_type_pkg.t_sign;  

function release_lock(
    i_entity_type        in  com_api_type_pkg.t_dict_value
  , i_object_key         in  com_api_type_pkg.t_semaphore_name    
) return com_api_type_pkg.t_sign;

/*
*  Release lock
    Return value:
*    0 - success
*    3 - parameter error
*    4 - don't own lock specified by 'id' or 'lockhandle'
*    5 - illegal lockhandle
*  @param i_lockname The name of lock
*  @return result release, see up
*/ 
function release_lock(
    i_lockname           in  com_api_type_pkg.t_semaphore_name
) return com_api_type_pkg.t_sign;
  
procedure release_locks(
    i_locks              in  com_api_type_pkg.t_name_tab
);

end com_api_lock_pkg;
/
