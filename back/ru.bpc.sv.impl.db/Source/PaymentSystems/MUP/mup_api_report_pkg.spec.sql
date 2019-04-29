create or replace package mup_api_report_pkg is

procedure run_rpt_form_1_iss_oper (
    o_xml           out clob
  , i_inst_id    in     com_api_type_pkg.t_tiny_id
  , i_agent_id   in     com_api_type_pkg.t_short_id  default null
  , i_date_start in     date
  , i_date_end   in     date
  , i_lang       in     com_api_type_pkg.t_dict_value default null
);

procedure run_rpt_form_2_2_acq_oper(
    o_xml           out clob
  , i_inst_id    in     com_api_type_pkg.t_tiny_id
  , i_agent_id   in     com_api_type_pkg.t_short_id  default null
  , i_date_start in     date
  , i_date_end   in     date
  , i_lang       in     com_api_type_pkg.t_dict_value default null
);

end mup_api_report_pkg;
/
