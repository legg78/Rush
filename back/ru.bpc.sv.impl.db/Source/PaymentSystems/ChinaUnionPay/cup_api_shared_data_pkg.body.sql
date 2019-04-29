create or replace package body cup_api_shared_data_pkg is

/*********************************************************
*  API for shared data of CUP messages
**********************************************************/

procedure collect_fin_message_params (
    io_params       in out nocopy   com_api_type_pkg.t_param_tab
) is
    l_oper_id                       com_api_type_pkg.t_long_id;
    l_pos_cond_code                 com_api_type_pkg.t_tag;
    l_cardholder_bill_amount        com_api_type_pkg.t_money;
    l_cardholder_acc_currency       com_api_type_pkg.t_curr_code;
    l_message_reason_code           com_api_type_pkg.t_tiny_id;
    l_fee_reason_code               com_api_type_pkg.t_tiny_id;
begin
    l_oper_id := opr_api_shared_data_pkg.g_operation.id;

    if l_oper_id is not null then
        begin
            select f.pos_cond_code
                 , f.cardholder_bill_amount
                 , f.cardholder_acc_currency
                 , f.reason_code
              into l_pos_cond_code
                 , l_cardholder_bill_amount
                 , l_cardholder_acc_currency
                 , l_message_reason_code
              from cup_fin_message f
             where f.id = l_oper_id;

            rul_api_param_pkg.set_param (
                i_value                 => l_pos_cond_code
              , i_name                  => 'POS_COND_CODE'
              , io_params               => io_params
            );

            rul_api_param_pkg.set_amount (
                i_name            => com_api_const_pkg.AMOUNT_PURPOSE_CARDHOLDER
              , i_amount          => l_cardholder_bill_amount
              , i_currency        => l_cardholder_acc_currency
              , i_conversion_rate => null
              , i_rate_type       => null
              , io_amount_tab     => opr_api_shared_data_pkg.g_amounts
            );
        exception
            when no_data_found then
                null;
        end;

        begin
            select f.reason_code
              into l_fee_reason_code
              from cup_fee f
             inner join opr_operation o on o.id = f.id
             where f.id = l_oper_id;

        exception
            when no_data_found then
                null;
        end;

        rul_api_param_pkg.set_param (
            i_value                 => to_char(coalesce(l_fee_reason_code, l_message_reason_code))
          , i_name                  => 'CUP_REASON_CODE'
          , io_params               => io_params
        );
    end if;

end collect_fin_message_params;

end cup_api_shared_data_pkg;
/
