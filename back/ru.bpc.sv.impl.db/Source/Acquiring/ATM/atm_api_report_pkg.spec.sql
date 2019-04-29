create or replace package atm_api_report_pkg is

procedure report_atm_cnt
  ( o_xml          out clob
  , i_lang         in com_api_type_pkg.t_dict_value
  , i_inst_id      in com_api_type_pkg.t_tiny_id   default null
  , i_agent_id     in com_api_type_pkg.t_short_id  default null
  ) ;

procedure report_atm_turnover
  ( o_xml            out clob
  , i_lang           in com_api_type_pkg.t_dict_value
  , i_inst_id        in com_api_type_pkg.t_tiny_id    default null
  , i_agent_id       in com_api_type_pkg.t_short_id   default null
  , i_date_start     in date
  , i_date_end       in date
  , i_placement_type in com_api_type_pkg.t_dict_value default null
  ) ;

procedure report_atm_disp_empty_cnt
  ( o_xml          out clob
  , i_lang         in com_api_type_pkg.t_dict_value
  , i_inst_id      in com_api_type_pkg.t_tiny_id   default null
  , i_agent_id     in com_api_type_pkg.t_short_id  default null
  ) ;

end;
/
