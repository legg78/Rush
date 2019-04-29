create or replace package rus_api_form_259_pkg is

procedure get_header_footer(
    i_lang             in     com_api_type_pkg.t_dict_value
  , i_inst_id          in     com_api_type_pkg.t_tiny_id
  , i_agent_id         in     com_api_type_pkg.t_short_id   default null
  , i_date_end         in     date
  , o_header              out xmltype
  , o_footer              out xmltype
);

procedure run_rpt_form_259_1(
    o_xml                 out clob
  , i_lang             in     com_api_type_pkg.t_dict_value
  , i_inst_id          in     com_api_type_pkg.t_tiny_id
  , i_agent_id         in     com_api_type_pkg.t_short_id   default null
  , i_start_date       in     date
  , i_end_date         in     date
);

procedure run_rpt_form_259_2(
    o_xml                 out clob
  , i_lang             in     com_api_type_pkg.t_dict_value
  , i_inst_id          in     com_api_type_pkg.t_tiny_id
  , i_agent_id         in     com_api_type_pkg.t_short_id   default null
  , i_start_date       in     date
  , i_end_date         in     date
);

end;
/
