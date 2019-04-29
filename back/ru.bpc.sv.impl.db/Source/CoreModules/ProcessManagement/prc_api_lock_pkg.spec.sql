create or replace package prc_api_lock_pkg as
/*
*------------------------------------------------------------------------<br/>
* API for DBMS_LOCK<br/>
* Created by Kryukov E.(krukov@bpc.ru)  at 08.04.2010<br/>
* Last changed by $Author$<br/>
* $LastChangedDate::                           $<br/>
* Revision: $LastChangedRevision$<br/>
* Module: PRC_API_LOCK_PKG
* @headcom
*/

/*
*  Request lock
*  @param i_session_id  Session identifier       
*  @param i_lockname The name of lock   
*  @return lock value, see up
*/
function request_lock(
    i_session_id           in  com_api_type_pkg.t_long_id
  , i_semaphore_name       in  com_api_type_pkg.t_semaphore_name
) return com_api_type_pkg.t_sign;  
/*
*  Release lock
*  @param i_session_id  Session identifier       
*  @param i_lockname The name of lock
*  @return result release, see up
*/ 
function release_lock(
    i_session_id           in  com_api_type_pkg.t_long_id
  , i_semaphore_name       in  com_api_type_pkg.t_semaphore_name
) return com_api_type_pkg.t_sign;
  
end prc_api_lock_pkg;
/
