create or replace package atm_api_notification_pkg as
/*********************************************************
 * API for ATM event notification reports<br>
 * Created by Alalykin A.(alalykin@bpc.ru) at 05.08.2014 <br>
 * Last changed by $Author: alalykin $ <br>
 * $LastChangedDate:: 2014-08-05 13:00:00 +0400#$  <br>
 * Revision: $LastChangedRevision: 45000 $ <br>
 * Module: ATM_API_NOTIFICATION_PKG <br>
 * @headcom
 **********************************************************/

procedure report_atm_event(
    o_xml                  out clob
  , i_event_type        in     com_api_type_pkg.t_dict_value
  , i_eff_date          in     date
  , i_entity_type       in     com_api_type_pkg.t_dict_value
  , i_object_id         in     com_api_type_pkg.t_long_id
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_lang              in     com_api_type_pkg.t_dict_value
  , i_notify_party_type in     com_api_type_pkg.t_dict_value    default null
);

end;
/

