create or replace package cst_amk_report_pkg as

procedure agents_awarding(
    o_xml                  out clob 
  , i_start_date        in     date
  , i_end_date          in     date
  , i_inst_id           in     com_api_type_pkg.t_inst_id        default null
  , i_lang              in     com_api_type_pkg.t_dict_value 
);

procedure agents_bonus_awarding(
    o_xml                  out clob 
  , i_start_date        in     date
  , i_end_date          in     date
  , i_inst_id           in     com_api_type_pkg.t_inst_id        default null
  , i_lang              in     com_api_type_pkg.t_dict_value 
);

end;
/
