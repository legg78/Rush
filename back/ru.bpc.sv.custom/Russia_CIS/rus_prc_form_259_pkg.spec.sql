create or replace package rus_prc_form_259_pkg is

function get_reversal_amount(
    i_oper_id        in com_api_type_pkg.t_long_id
  , i_amount_rev     in com_api_type_pkg.t_money
  , i_inst_id        in com_api_type_pkg.t_tiny_id
  , i_date_start     in date
  , i_date_end       in date
) return com_api_type_pkg.t_money;

function get_reversal_count(
    i_oper_id        in com_api_type_pkg.t_long_id
  , i_inst_id        in com_api_type_pkg.t_tiny_id
  , i_date_start     in date
  , i_date_end       in date
) return com_api_type_pkg.t_tiny_id;

procedure process_form_259_1(
    i_inst_id        in com_api_type_pkg.t_tiny_id
  , i_agent_id       in com_api_type_pkg.t_short_id  default null
  , i_start_date     in date
  , i_end_date       in date
);

procedure process_form_259_2(
    i_inst_id        in com_api_type_pkg.t_tiny_id
  , i_agent_id       in com_api_type_pkg.t_short_id  default null
  , i_start_date     in date
  , i_end_date       in date
);

end;
/
