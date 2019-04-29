create or replace package cst_lvp_report_pkg as

procedure card_inventory(
    o_xml                  out clob
  , i_inst_id           in     com_api_type_pkg.t_inst_id       default null
  , i_date_start        in     date                             default null
  , i_date_end          in     date                             default null
  , i_report_id         in     com_api_type_pkg.t_short_id
  , i_lang              in     com_api_type_pkg.t_dict_value    default null
);

end;
/
