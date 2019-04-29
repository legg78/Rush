create or replace package app_api_report_pkg is
/*********************************************************
 *  API for Report Document in application <br />
 *  Created by Kryukov E.(krukov@bpcbt.com)  at 19.07.2012 <br />
 *  Last changed by Gogolev I.(i.gogolev@bpcbt.com) <br />
 *  at 30.09.2016 18:34:00                          <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: APP_API_REPORT_PKG  <br />
 *  @headcom
 **********************************************************/
procedure process_report(
    i_appl_data_id        in            com_api_type_pkg.t_long_id
  , i_entity_type         in            com_api_type_pkg.t_dict_value
  , i_object_id           in            com_api_type_pkg.t_long_id
);

procedure appl_response(
    o_xml                  out   clob
  , i_application_id    in       com_api_type_pkg.t_long_id     default null
  , i_lang              in       com_api_type_pkg.t_dict_value  default null
);

procedure process_rejected_application(
    o_xml                  out   clob
  , i_event_type        in       com_api_type_pkg.t_dict_value  default null
  , i_eff_date          in       date                           default null
  , i_entity_type       in       com_api_type_pkg.t_dict_value
  , i_object_id         in       com_api_type_pkg.t_long_id
  , i_inst_id           in       com_api_type_pkg.t_inst_id     default null
  , i_lang              in       com_api_type_pkg.t_dict_value  default null  
);

end app_api_report_pkg;
/
