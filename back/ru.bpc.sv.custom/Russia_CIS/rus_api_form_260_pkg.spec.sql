create or replace package rus_api_form_260_pkg is

function get_terminal_count(
    i_region_code  in com_api_type_pkg.t_region_code
  , i_inst_id      in com_api_type_pkg.t_tiny_id
  , i_agent_id     in com_api_type_pkg.t_short_id  default null
)return number;

function get_reversal_amount (
    i_oper_id      in com_api_type_pkg.t_long_id
  , i_amount_rev   in com_api_type_pkg.t_money
  , i_inst_id      in com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_money;

function correct_oper_count (
    i_oper_id      in com_api_type_pkg.t_long_id
  , i_amount_rev   in com_api_type_pkg.t_money
  , i_inst_id      in com_api_type_pkg.t_tiny_id
  , i_start_date   in date
  , i_end_date     in date
) return com_api_type_pkg.t_tiny_id;

procedure run_rpt_form_260_1 (
    o_xml          out clob
  , i_lang         in com_api_type_pkg.t_dict_value
  , i_inst_id      in com_api_type_pkg.t_tiny_id
  , i_agent_id     in com_api_type_pkg.t_short_id  default null
  , i_start_date   in date
  , i_end_date     in date
) ;

procedure run_rpt_form_260_2 (
    o_xml          out clob
  , i_lang         in com_api_type_pkg.t_dict_value
  , i_inst_id      in com_api_type_pkg.t_tiny_id
  , i_agent_id     in com_api_type_pkg.t_short_id  default null
  , i_start_date   in date
  , i_end_date     in date
) ;

procedure run_rpt_form_260_3 (
    o_xml          out clob
  , i_lang         in com_api_type_pkg.t_dict_value
  , i_inst_id      in com_api_type_pkg.t_tiny_id
  , i_agent_id     in com_api_type_pkg.t_short_id  default null
  , i_start_date   in date
  , i_end_date     in date
) ;

end;
/