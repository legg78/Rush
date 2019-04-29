create or replace package prc_api_report_pkg is
/*********************************************************************
 * The API for reports <br />
 * Created by Filimonov A.(filimonov@bpc.ru)  at 04.02.2011 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: PRC_API_REPORT_PKG <br />
 * @headcom
 ********************************************************************/
procedure run_report (
    o_xml                  out  clob
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_eff_date          in      date
);

procedure file_password_event (
    o_xml               out     clob
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_event_type        in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_eff_date          in      date
  , i_inst_id           in      com_api_type_pkg.t_inst_id
);

end;
/
