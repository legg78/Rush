create or replace package rus_api_form_250_pkg is

function get_reversal_amount (
    i_oper_id          in com_api_type_pkg.t_long_id
    , i_amount_rev     in com_api_type_pkg.t_money
    , i_inst_id        in com_api_type_pkg.t_tiny_id
    , i_date_start     in date
    , i_date_end       in date
) return com_api_type_pkg.t_money;

procedure run_rpt_form_250_1 (
    o_xml          out    clob
    , i_lang           in com_api_type_pkg.t_dict_value
    , i_inst_id        in com_api_type_pkg.t_tiny_id
    , i_agent_id       in com_api_type_pkg.t_short_id   default null
    , i_date_start     in date
    , i_date_end       in date
);

procedure run_rpt_form_250_2 (
    o_xml          out    clob
    , i_lang           in com_api_type_pkg.t_dict_value
    , i_inst_id        in com_api_type_pkg.t_tiny_id
    , i_agent_id       in com_api_type_pkg.t_short_id   default null
    , i_date_start     in date
    , i_date_end       in date
);

procedure get_data_form_250_3 (
    i_inst_id          in com_api_type_pkg.t_tiny_id
    , i_agent_id       in com_api_type_pkg.t_short_id   default null
    , i_date_start     in date
    , i_date_end       in date
    , i_lang           in com_api_type_pkg.t_dict_value default null
);

procedure run_rpt_form_250_3 (
    o_xml          out    clob
    , i_lang           in com_api_type_pkg.t_dict_value
    , i_inst_id        in com_api_type_pkg.t_tiny_id
    , i_agent_id       in com_api_type_pkg.t_short_id   default null
    , i_date_start     in date
    , i_date_end       in date
);

end;
/
