create or replace package cst_api_form_250_pkg is

/**
*   Clear data for Report 250, sections 1
*/
procedure clear_data_250_1;

/**
*   Collect data for one step (from 1 to 12) for Report 250, sections 1
*/
procedure collect_data_form_250_1(
    i_lang              in com_api_type_pkg.t_dict_value
  , i_inst_id           in com_api_type_pkg.t_tiny_id
  , i_agent_id          in com_api_type_pkg.t_short_id
  , i_date_start        in date
  , i_date_end          in date
  , i_level_refresh     in com_api_type_pkg.t_tiny_id
  , i_one_region        in com_api_type_pkg.t_boolean
);

/**
*   Collect data for Report 250, sections 1 (execute all steps)
*/
procedure run_collect_250_1(
    i_lang              in com_api_type_pkg.t_dict_value
  , i_inst_id           in com_api_type_pkg.t_tiny_id
  , i_date_start        in date
  , i_date_end          in date
  , i_level_start       in com_api_type_pkg.t_tiny_id
  , i_level_end         in com_api_type_pkg.t_tiny_id
  , i_one_region        in com_api_type_pkg.t_boolean
);

/**
*   Run Report 250, sections 1
*/
procedure run_rpt_form_250_1(
    o_xml           out    clob
  , i_lang              in com_api_type_pkg.t_dict_value
  , i_inst_id           in com_api_type_pkg.t_tiny_id
  , i_agent_id          in com_api_type_pkg.t_short_id      default null
  , i_date_start        in date
  , i_date_end          in date
);

/**
*   Clear data for Report 250, sections 3
*/
procedure clear_data_250_3;

/**
*   Collect data for Report 250, sections 3
*/
procedure collect_data_form_250_3(
    i_lang              in com_api_type_pkg.t_dict_value
  , i_inst_id           in com_api_type_pkg.t_tiny_id
  , i_agent_id          in com_api_type_pkg.t_short_id
  , i_date_start        in date
  , i_date_end          in date
  , i_level_refresh     in com_api_type_pkg.t_tiny_id
);

/**
*   Run Report 250, sections 3
*/
procedure run_rpt_form_250_3(
    o_xml           out    clob
  , i_lang              in com_api_type_pkg.t_dict_value
  , i_inst_id           in com_api_type_pkg.t_tiny_id
  , i_agent_id          in com_api_type_pkg.t_short_id      default null
  , i_date_start        in date
  , i_date_end          in date
);

procedure run_collect_250_3(
    i_lang              in com_api_type_pkg.t_dict_value
  , i_inst_id           in com_api_type_pkg.t_tiny_id
  , i_agent_id          in com_api_type_pkg.t_short_id
  , i_date_start        in date
  , i_date_end          in date
);

end cst_api_form_250_pkg;
/
