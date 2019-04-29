create or replace package rus_api_form_407_pkg is

procedure run_rpt_form_407_3 (
    o_xml                 out clob
  , i_lang             in     com_api_type_pkg.t_dict_value
  , i_inst_id          in     com_api_type_pkg.t_tiny_id
  , i_agent_id         in     com_api_type_pkg.t_short_id   default null
  , i_start_date       in     date
  , i_end_date         in     date
);

end;
/
