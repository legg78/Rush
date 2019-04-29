create or replace package body cst_pvc_prc_pmo_process_pkg as

-- Update payment orders total amount for active orders belonging to the same customers
procedure update_total_by_customer (
    i_inst_id                 in     com_api_type_pkg.t_inst_id
  , i_purpose_id              in     com_api_type_pkg.t_short_id
) is
    l_estimated_count       com_api_type_pkg.t_long_id;
    l_processed_count       com_api_type_pkg.t_long_id := 0;
    l_purpose_count         com_api_type_pkg.t_short_id;
begin
    savepoint update_totals_start;
    trc_log_pkg.debug(
        i_text        => 'Start cst_pvc_prc_pmo_process_pkg.update_total_by_customer [#1] [#2]'
      , i_env_param1  => i_inst_id
      , i_env_param2  => i_purpose_id
    );

    select count(id)
      into l_purpose_count
      from pmo_purpose
     where id = i_purpose_id;

    if l_purpose_count = 0 then
        com_api_error_pkg.raise_error(
            i_error         => 'PAYMENT_PURPOSE_NOT_EXISTS'
          , i_env_param1    => i_purpose_id
        );
    end if;

    prc_api_stat_pkg.log_start;

    select count(id)
      into l_estimated_count
      from pmo_order
     where purpose_id = i_purpose_id
       and decode(status, 'POSA0001', status, null) = pmo_api_const_pkg.PMO_STATUS_AWAITINGPROC -- 'POSA0001'
       and (inst_id = i_inst_id or i_inst_id is null);
    
    prc_api_stat_pkg.log_estimation(
        i_estimated_count       => l_estimated_count
    );
    trc_log_pkg.debug(
        i_text        => 'Estimated count [#1]'
      , i_env_param1  => l_estimated_count
    );

    for rec in (
        select id
             , customer_id
             , sum(amount) over (partition by customer_id) as total_amount
          from pmo_order
         where purpose_id = i_purpose_id
           and decode(status, 'POSA0001', status, null) = pmo_api_const_pkg.PMO_STATUS_AWAITINGPROC -- 'POSA0001'
           and (inst_id = i_inst_id or i_inst_id is null)
    ) loop
        pmo_api_order_pkg.add_order_data(
            i_order_id       => rec.id
          , i_param_name     => cst_pvc_const_pkg.PMO_PARAM_TOTAL_AMNT_FOR_CUST
          , i_param_value    => rec.total_amount
          , i_purpose_id     => i_purpose_id
        );

        l_processed_count := l_processed_count + 1;

        if mod(l_processed_count, 100) = 0 then
            prc_api_stat_pkg.log_current (
                i_current_count     => l_processed_count
              , i_excepted_count    => 0
            );
        end if;
    end loop;

    prc_api_stat_pkg.log_end (
        i_excepted_total   => 0
      , i_processed_total  => l_processed_count
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug (
        i_text       => 'Totals for customers payment orders are updated [#1]'
      , i_env_param1 => l_processed_count
    );

exception
    when others then
        rollback to savepoint update_totals_start;

        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;

        raise;

end update_total_by_customer;

end cst_pvc_prc_pmo_process_pkg;
/
