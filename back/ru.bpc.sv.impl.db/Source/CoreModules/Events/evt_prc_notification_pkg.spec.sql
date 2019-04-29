create or replace package evt_prc_notification_pkg is
/**********************************************************
 * Creating notifications linked with defined events 
 * 
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 28.04.2017
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 * Module: EVT_PRC_NOTIFICATION_PKG
 * @headcom
 **********************************************************/

procedure gen_acq_min_amount_notifs(
    i_inst_id     in com_api_type_pkg.t_inst_id
);
    
end evt_prc_notification_pkg;
/
