create or replace package body lty_cst_prc_bonus_pkg as

procedure process_expired_bonus (
    i_inst_id           in  com_api_type_pkg.t_inst_id
  , i_service_id        in  com_api_type_pkg.t_tiny_id
  , i_eff_date          in  date
  , i_rate_type         in  com_api_type_pkg.t_dict_value
  , i_conversion_type   in  com_api_type_pkg.t_dict_value
) is
    l_account           acc_api_type_pkg.t_account_rec;
    l_bunch_type_id     com_api_type_pkg.t_tiny_id;
    l_bunch_id          com_api_type_pkg.t_long_id;
    l_params            com_api_type_pkg.t_param_tab;
    l_param_tab         com_api_type_pkg.t_param_tab;

    l_excepted_count    com_api_type_pkg.t_long_id := 0;
    l_processed_count   com_api_type_pkg.t_long_id := 0;

    l_dest_currency     com_api_type_pkg.t_curr_code;
    l_amount            com_api_type_pkg.t_money;
    l_eff_date          date;
begin
    l_eff_date := nvl(i_eff_date, get_sysdate);
    trc_log_pkg.debug ('Process outdated bonuses. inst_id='||i_inst_id||', service_id='|| i_service_id
                    || ', eff_date=' || to_char(l_eff_date, 'YYYYMMDDHH24MISS') );
    prc_api_stat_pkg.log_start;

    for rec in (
        select b.id
             , b.account_id
             , b.product_id
             , b.service_id
             , b.amount - nvl(b.spent_amount,0) amount
             , a.currency
             , row_number() over(order by b.id) rn
             , count(*) over() cnt
             , a.account_type
             , c.card_type_id
             , nvl(b.entity_type, iss_api_const_pkg.ENTITY_TYPE_CARD) as entity_type
             , nvl(b.object_id, b.card_id) as object_id
             , a.customer_id
             , a.agent_id
             , a.inst_id
          from lty_bonus b
             , acc_account a
             , iss_card c
         where b.service_id  = i_service_id
           and b.inst_id     = i_inst_id
           and a.id          = b.account_id
           and b.card_id     = c.id(+)
           and b.expire_date < l_eff_date
           and decode(b.status, 'BNST0100', b.status, null) = lty_api_const_pkg.BONUS_TRANSACTION_ACTIVE
           for update of b.status
    ) loop
        if rec.rn = 1 then
            prc_api_stat_pkg.log_estimation (i_estimated_count => rec.cnt);

            l_bunch_type_id := prd_api_product_pkg.get_attr_value_number(
                i_product_id   => rec.product_id
              , i_entity_type  => rec.entity_type
              , i_object_id    => rec.object_id
              , i_attr_name    => lty_api_bonus_pkg.decode_attr_name(
                                      i_attr_name   => lty_api_const_pkg.LOYALTY_OUTDATE_BUNCH_TYPE
                                    , i_entity_type => rec.entity_type
                                  )
              , i_params       => l_params
              , i_service_id   => rec.service_id
              , i_eff_date     => l_eff_date
              , i_inst_id      => i_inst_id
            );
        end if;
        begin
            savepoint process_outdated_bonuses;

            rul_api_param_pkg.set_param (
                i_name       => 'CARD_TYPE_ID'
              , io_params    => l_param_tab
              , i_value      => rec.card_type_id
            );
            for rec1 in (
                select s.dest_entity_type
                     , s.dest_account_type
                  from
                       acc_entry_tpl s
                     , acc_macros m
                     , rul_mod r
                 where
                       s.bunch_type_id  = l_bunch_type_id
                   and m.id             = rec.id
                   and s.mod_id         = r.id(+)
                   and balance_impact   = 1
                   and rownum           = 1
            ) loop
                if rec1.dest_entity_type = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER then

                    l_account :=
                        acc_api_account_pkg.get_account(
                            i_customer_id   => rec.customer_id
                          , i_account_type  => rec1.dest_account_type
                        );
                    l_dest_currency := l_account.currency;
                else
                    begin
                        select currency
                          into l_dest_currency
                          from acc_gl_account_mvw
                         where entity_id    = decode(rec1.dest_entity_type, ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                                                    , rec.inst_id, ost_api_const_pkg.ENTITY_TYPE_AGENT, rec.agent_id)
                           and entity_type  = rec1.dest_entity_type
                           and account_type = rec1.dest_account_type
                           and rownum       = 1;
                    exception
                    when no_data_found then
                        com_api_error_pkg.raise_error (
                            i_error         => 'ENTITY_ACCOUNT_NOT_FOUND'
                          , i_env_param1    => rec1.dest_entity_type
                          , i_env_param2    => rec.account_id
                          , i_env_param3    => rec1.dest_account_type
                        );
                    end;

                    if l_dest_currency != rec.currency then
                        l_amount :=
                            com_api_rate_pkg.convert_amount(
                                i_src_amount      => rec.amount
                              , i_src_currency    => rec.currency
                              , i_dst_currency    => l_dest_currency
                              , i_rate_type       => i_rate_type
                              , i_inst_id         => i_inst_id
                              , i_eff_date        => l_eff_date
                              , i_conversion_type => i_conversion_type
                            );
                        trc_log_pkg.debug('Successful converted loyalty account [ ' || rec.account_id || ' ] original amount:[ '||rec.amount||'-'
                        ||rec.currency||' ] Destination amount:[ '|| l_amount ||'-' || l_dest_currency || ' ]');
                    else
                        l_amount := rec.amount;

                    end if;
                    acc_api_entry_pkg.put_bunch (
                        o_bunch_id       => l_bunch_id
                      , i_bunch_type_id  => l_bunch_type_id
                      , i_macros_id      => rec.id
                      , i_amount         => l_amount
                      , i_currency       => l_dest_currency
                      , i_account_type   => rec.account_type
                      , i_account_id     => rec.account_id
                      , i_posting_date   => l_eff_date
                      , i_param_tab      => l_param_tab
                    );


                end if;
            end loop;
            -- set bonus status outdated
            update lty_bonus
               set status = lty_api_const_pkg.BONUS_TRANSACTION_OUTDATED
             where id     = rec.id;

            l_processed_count := l_processed_count + 1;

        exception
            when com_api_error_pkg.e_application_error then
                l_excepted_count := l_excepted_count + 1;
                trc_log_pkg.debug('outdated_bonus: error, id= '||rec.id||' '||sqlerrm);
            when com_api_error_pkg.e_fatal_error then
                raise;
            when others then
                rollback to savepoint process_outdated_bonuses;

                com_api_error_pkg.raise_fatal_error(
                    i_error         => 'UNHANDLED_EXCEPTION'
                  , i_env_param1    => sqlerrm
                );
            end;

            prc_api_stat_pkg.log_current (
                i_current_count   => l_processed_count
              , i_excepted_count  => l_excepted_count
            );
    end loop;

    trc_log_pkg.debug ('Process outdated bonuses finished, '||l_processed_count||' processed, '
                     ||l_excepted_count||' excepted.' );

    prc_api_stat_pkg.log_end (
        i_excepted_total  => l_excepted_count
      , i_processed_total => l_processed_count
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
exception
    when others then
        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
        raise;
end;
end lty_cst_prc_bonus_pkg;
/
