create or replace package csm_api_rule_proc_pkg is
/**********************************************************
 * Rules for disputes <br />
 *  <br />
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 08.12.2016 <br />
 * <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: CSM_API_RULE_PROC_PKG
 * @headcom
 **********************************************************/

procedure send_dispute_user_notification;
    
procedure calculate_hide_date;
    
end csm_api_rule_proc_pkg;
/
