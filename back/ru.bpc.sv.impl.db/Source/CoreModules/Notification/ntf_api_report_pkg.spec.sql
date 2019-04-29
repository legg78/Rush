create or replace package ntf_api_report_pkg is
/***********************************************************
* API for notification reports. <br>
* Created by Kryukov E. (krukov@bpcbt.com)  at 25.02.2013  <br>
* Last changed by $Author$ <br>
* $LastChangedDate::                           $  <br>
* Revision: $LastChangedRevision$ <br>
* Module: NTF_API_REPORT_PKG <br>
* @headcom
*************************************************************/
    
    procedure ntf_report (
        o_xml                  out  clob
        , i_event_type         in com_api_type_pkg.t_dict_value
        , i_eff_date           in date
        , i_entity_type        in com_api_type_pkg.t_dict_value
        , i_object_id          in com_api_type_pkg.t_long_id
        , i_inst_id            in com_api_type_pkg.t_inst_id
        , i_notify_party_type  in com_api_type_pkg.t_dict_value
        , i_lang               in com_api_type_pkg.t_dict_value
    );

-- Obsolete. Do not use ->
    procedure create_text_message_report(
        o_xml               out     clob
      , i_lang              in      com_api_type_pkg.t_dict_value  default null
    );

    procedure create_due_message_report(
        o_xml               out     clob
      , i_lang              in      com_api_type_pkg.t_dict_value  default null
    );

end;
-- <-Obsolete. Do not use

/
