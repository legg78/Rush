create or replace package body opr_api_check_pkg is

    cursor all_checks is
        select
            s.oper_type
            , s.msg_type
            , s.party_type
            , s.inst_id
            , s.network_id
            , c.check_type
        from
            opr_check_selection s
            , opr_check c
        where
            s.check_group_id = c.check_group_id
        order by
            s.exec_order
            , c.exec_order;

    subtype t_check_rec is all_checks%rowtype;
    type t_check_tab is table of t_check_rec index by binary_integer;

    g_checks t_check_tab;
    g_date date;

    procedure load_cache is
    begin
        if g_date is null or com_api_sttl_day_pkg.get_sysdate() - g_date > 1/240 then
            open all_checks;
            fetch all_checks bulk collect into g_checks;
            close all_checks;
            g_date := com_api_sttl_day_pkg.get_sysdate();
        end if;
    exception
        when others then
            if all_checks%isopen then
                close all_checks;
            end if; 
    end;
    
    procedure get_checks (
        i_msg_type              in com_api_type_pkg.t_dict_value
        , i_oper_type           in com_api_type_pkg.t_dict_value
        , i_party_type          in com_api_type_pkg.t_dict_value
        , i_inst_id             in com_api_type_pkg.t_dict_value
        , i_network_id          in com_api_type_pkg.t_dict_value
        , o_checks              out com_api_type_pkg.t_dict_tab
    ) is
    begin
        load_cache;

        for i in 1 .. g_checks.count loop
            if (
                i_msg_type like g_checks(i).msg_type
                and i_oper_type like g_checks(i).oper_type 
                and i_party_type like g_checks(i).party_type 
                and i_inst_id like g_checks(i).inst_id
                and i_network_id like g_checks(i).network_id
            ) then
                o_checks(o_checks.count + 1) := g_checks(i).check_type;
            end if;
        end loop;
    end;

    procedure completion_check (
        i_terminal_id                   in com_api_type_pkg.t_short_id
        , i_original_date               in date
        , i_oper_date                   in date
        , i_original_currency           in com_api_type_pkg.t_curr_code
        , i_original_amount             in com_api_type_pkg.t_money
        , i_oper_currency               in com_api_type_pkg.t_curr_code
        , i_oper_amount                 in com_api_type_pkg.t_money
        , o_reason                      out com_api_type_pkg.t_dict_value
    ) is
        l_cycle_id                      com_api_type_pkg.t_long_id;
        l_fee_id                        com_api_type_pkg.t_long_id;
        l_product_id                    com_api_type_pkg.t_long_id;
        l_params                        com_api_type_pkg.t_param_tab;

        l_result_date                   date;
        l_result_amount                 com_api_type_pkg.t_amount_rec;
        l_original_currency             com_api_type_pkg.t_curr_code := i_original_currency;
    begin
        o_reason := aup_api_const_pkg.RESP_CODE_OK;
        
        l_product_id := prd_api_product_pkg.get_product_id (
            i_entity_type  => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
            , i_object_id  => i_terminal_id
        );

        l_cycle_id := prd_api_product_pkg.get_cycle_id (
            i_product_id     => l_product_id
            , i_entity_type  => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
            , i_object_id    => i_terminal_id
            , i_cycle_type   => opr_api_const_pkg.COMPLETION_TIMEOUT_CYCLE_TYPE
            , i_params       => l_params
            , i_eff_date     => com_api_sttl_day_pkg.get_sysdate
        );

        l_result_date := fcl_api_cycle_pkg.calc_next_date (
            i_cycle_id      => l_cycle_id
            , i_start_date  => i_original_date
        );
        if i_oper_date > l_result_date then
            o_reason := aup_api_const_pkg.RESP_CODE_COMPL_TIMEOUT;
            return;
        end if;

        l_fee_id := prd_api_product_pkg.get_fee_id (
            i_product_id     => l_product_id
            , i_entity_type  => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
            , i_object_id    => i_terminal_id
            , i_fee_type     => opr_api_const_pkg.COMPLETION_AMOUNT_GAP_FEE_TYPE
            , i_params       => l_params
            , i_eff_date     => com_api_sttl_day_pkg.get_sysdate
        );

        l_result_amount.currency := l_original_currency;
        l_result_amount.amount := round(fcl_api_fee_pkg.get_fee_amount (
            i_fee_id            => l_fee_id
            , i_base_amount     => i_original_amount
            , io_base_currency  => l_original_currency
            , i_entity_type     => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
            , i_object_id       => i_terminal_id
        ));

        if abs(i_original_amount - i_oper_amount) > l_result_amount.amount then
            o_reason := aup_api_const_pkg.RESP_CODE_ILLEG_SUM_COMPL;
            return;
        end if;
    end;

begin
    load_cache;
end;
/
