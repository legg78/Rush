create or replace package com_api_report_pkg is

procedure notification_with_attach_event(
    o_xml                  out clob
  , i_event_type        in     com_api_type_pkg.t_dict_value
  , i_eff_date          in     date
  , i_entity_type       in     com_api_type_pkg.t_dict_value
  , i_object_id         in     com_api_type_pkg.t_long_id
  , i_start_date        in     date
  , i_end_date          in     date
  , i_document_type     in     com_api_type_pkg.t_dict_value
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_lang              in     com_api_type_pkg.t_dict_value
);

end com_api_report_pkg;
/
