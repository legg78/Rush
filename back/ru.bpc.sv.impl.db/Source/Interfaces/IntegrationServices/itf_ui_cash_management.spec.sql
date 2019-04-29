create or replace package itf_ui_cash_management as

procedure get_institution_list (
    i_lang                in     com_api_type_pkg.t_dict_value    default null
    , o_ref_cursor        out    sys_refcursor 
);

procedure get_atm_list (
    o_ref_cursor        out    sys_refcursor 
); 

procedure get_atm_transactions (
    i_oper_id           in     com_api_type_pkg.t_long_id
    , i_atm_id_list     in     num_tab_tpt
    , i_max_count       in     com_api_type_pkg.t_tiny_id
    , o_ref_cursor      out    sys_refcursor 
);

procedure get_atm_downtime (
    i_terminal_id       in     com_api_type_pkg.t_medium_id
    , i_last_date       in     date
    , o_ref_cursor      out    sys_refcursor 
);

procedure get_currency_rates (
    i_inst_id_list      in     num_tab_tpt
    , o_ref_cursor      out    sys_refcursor 
);

end;
/
