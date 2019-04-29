create or replace package evt_api_notif_report_pkg is
/**********************************************************
 * Create reports for send event notification
 * 
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 05.10.2016
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: EVT_API_NOTIFICATION_PKG
 * @headcom
 **********************************************************/

/* Obsolete. Do not use */
procedure create_report(
    o_xml               out     clob
  , i_event_type        in      com_api_type_pkg.t_dict_value
  , i_eff_date          in      date
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_lang              in      com_api_type_pkg.t_dict_value  default null
);
    
end;
/
