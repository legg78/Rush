create or replace package body scr_api_external_pkg as

procedure add_bucket(
    io_id                   in  out nocopy com_api_type_pkg.t_medium_id
  , i_account_id            in  com_api_type_pkg.t_account_id
  , i_customer_id           in  com_api_type_pkg.t_medium_id
  , i_revised_bucket        in  com_api_type_pkg.t_byte_char
  , i_eff_date              in  date
  , i_expir_date            in  date
  , i_valid_period          in  com_api_type_pkg.t_byte_id
  , i_reason                in  com_api_type_pkg.t_name
  , i_user_id               in  com_api_type_pkg.t_name
) is
    l_id_tab                com_api_type_pkg.t_medium_tab;
    l_account_id_tab        com_api_type_pkg.t_medium_tab;
    l_customer_id_tab       com_api_type_pkg.t_medium_tab;
    l_revised_bucket_tab    com_api_type_pkg.t_byte_char_tab;
    l_eff_date_tab          com_api_type_pkg.t_date_tab;
    l_expir_date_tab        com_api_type_pkg.t_date_tab;
    l_valid_period_tab      com_api_type_pkg.t_number_tab;
    l_reason_tab            com_api_type_pkg.t_name_tab;
    l_user_id_tab           com_api_type_pkg.t_name_tab;
begin
    l_id_tab.delete;
    l_account_id_tab(1)         := i_account_id;
    l_customer_id_tab(1)        := i_customer_id;
    l_revised_bucket_tab(1)     := i_revised_bucket;
    l_eff_date_tab(1)           := i_eff_date;
    l_expir_date_tab(1)         := i_expir_date;
    l_valid_period_tab(1)       := i_valid_period;
    l_reason_tab(1)             := i_reason;
    l_user_id_tab(1)            := i_user_id;

    add_buckets(
        io_id_tab               => l_id_tab
      , i_account_id_tab        => l_account_id_tab
      , i_customer_id_tab       => l_customer_id_tab
      , i_revised_bucket_tab    => l_revised_bucket_tab
      , i_eff_date_tab          => l_eff_date_tab
      , i_expir_date_tab        => l_expir_date_tab
      , i_valid_period_tab      => l_valid_period_tab
      , i_reason_tab            => l_reason_tab
      , i_user_id_tab           => l_user_id_tab
    );
end add_bucket;

procedure add_buckets(
    io_id_tab               in  out nocopy com_api_type_pkg.t_medium_tab
  , i_account_id_tab        in  com_api_type_pkg.t_medium_tab
  , i_customer_id_tab       in  com_api_type_pkg.t_medium_tab
  , i_revised_bucket_tab    in  com_api_type_pkg.t_byte_char_tab
  , i_eff_date_tab          in  com_api_type_pkg.t_date_tab
  , i_expir_date_tab        in  com_api_type_pkg.t_date_tab
  , i_valid_period_tab      in  com_api_type_pkg.t_number_tab
  , i_reason_tab            in  com_api_type_pkg.t_name_tab
  , i_user_id_tab           in  com_api_type_pkg.t_name_tab
) is
begin
    trc_log_pkg.debug (
        i_text        => 'Going to add [#1] buckets'
      , i_env_param1  => i_revised_bucket_tab.count
    );
    savepoint sp_add_buckets;
    forall i in 1 .. i_revised_bucket_tab.count
        insert into scr_bucket_vw (
            id
          , account_id
          , customer_id
          , revised_bucket
          , eff_date
          , expir_date
          , valid_period
          , reason
          , user_id
          , log_date
          ) values
          (
            scr_bucket_seq.nextval
          , i_account_id_tab(i)
          , i_customer_id_tab(i)
          , i_revised_bucket_tab(i)
          , i_eff_date_tab(i)
          , i_expir_date_tab(i)
          , i_valid_period_tab(i)
          , i_reason_tab(i)
          , i_user_id_tab(i)
          , get_sysdate()
          ) returning id bulk collect into io_id_tab;

    trc_log_pkg.debug (
        i_text        => 'Added successfully [#1] buckets'
      , i_env_param1  => io_id_tab.count
    );
exception
    when others then
        trc_log_pkg.debug (
            i_text        => 'Failed to add into bucket'
        );
        rollback to savepoint sp_add_buckets;
        raise;
end add_buckets;

procedure add_buckets(
    io_scr_bucket_tab       in  out nocopy scr_api_type_pkg.t_scr_bucket_tab
) is
    l_id_tab                com_api_type_pkg.t_medium_tab;
    l_account_id_tab        com_api_type_pkg.t_medium_tab;
    l_customer_id_tab       com_api_type_pkg.t_medium_tab;
    l_revised_bucket_tab    com_api_type_pkg.t_byte_char_tab;
    l_eff_date_tab          com_api_type_pkg.t_date_tab;
    l_expir_date_tab        com_api_type_pkg.t_date_tab;
    l_valid_period_tab      com_api_type_pkg.t_number_tab;
    l_reason_tab            com_api_type_pkg.t_name_tab;
    l_user_id_tab           com_api_type_pkg.t_name_tab;
begin
    for i in 1 .. io_scr_bucket_tab.count loop
        l_account_id_tab(i)     := io_scr_bucket_tab(i).account_id;
        l_customer_id_tab(i)    := io_scr_bucket_tab(i).customer_id;
        l_revised_bucket_tab(i) := io_scr_bucket_tab(i).revised_bucket;
        l_eff_date_tab(i)       := io_scr_bucket_tab(i).eff_date;
        l_expir_date_tab(i)     := io_scr_bucket_tab(i).expir_date;
        l_valid_period_tab(i)   := io_scr_bucket_tab(i).valid_period;
        l_reason_tab(i)         := io_scr_bucket_tab(i).reason;
        l_user_id_tab(i)        := io_scr_bucket_tab(i).user_id;
    end loop;

    add_buckets(
        io_id_tab               => l_id_tab
      , i_account_id_tab        => l_account_id_tab
      , i_customer_id_tab       => l_customer_id_tab
      , i_revised_bucket_tab    => l_revised_bucket_tab
      , i_eff_date_tab          => l_eff_date_tab
      , i_expir_date_tab        => l_expir_date_tab
      , i_valid_period_tab      => l_valid_period_tab
      , i_reason_tab            => l_reason_tab
      , i_user_id_tab           => l_user_id_tab
    );
end add_buckets;

procedure get_scoring_data(
    i_inst_id               in  com_api_type_pkg.t_inst_id
  , i_agent_id              in  com_api_type_pkg.t_agent_id     default null
  , i_customer_id           in  com_api_type_pkg.t_medium_id    default null
  , i_account_id            in  com_api_type_pkg.t_account_id   default null
  , o_ref_cursor            out sys_refcursor
) is
begin
    open o_ref_cursor for
        select pc.customer_number
             , pc.id              as customer_id
             , aa.account_number
             , aa.id              as account_id
             , ic.id              as card_id
             , ic.split_hash
             , coalesce(
                   ic.card_mask
                 , iss_api_card_pkg.get_card_mask(i_card_number => cn.card_number)
               )                  as card_mask
             , decode(ic.category, iss_api_const_pkg.CARD_CATEGORY_PRIMARY, 1, 0) as category
             , ii.status
             , null               as sub_acct
        from acc_account          aa
           , acc_account_object   ao
           , prd_customer         pc
           , iss_card             ic
           , iss_card_instance    ii
           , iss_card_number      cn
       where aa.customer_id     = pc.id
         and aa.id              = ao.account_id
         and ao.entity_type     = iss_api_const_pkg.ENTITY_TYPE_CARD --'ENTTCARD'
         and ao.object_id       = ic.id
         and ii.card_id         = ic.id
         and ii.card_id         = cn.card_id
         and pc.id              = nvl(i_customer_id, pc.id)
         and pc.inst_id         = nvl(i_inst_id,     pc.inst_id)
         and aa.agent_id        = nvl(i_agent_id,    aa.agent_id)
         and aa.id              = nvl(i_account_id,  aa.id)
         and aa.account_type    = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT
         and ii.status         != cst_cfc_api_const_pkg.CARD_STATUS_INSTANT_CARD
         and ii.state          != iss_api_const_pkg.CARD_STATE_CLOSED
         and exists (
                 select 1
                   from prd_service_object p
                  where p.service_id  = cst_cfc_api_const_pkg.CREDIT_SERVICE_ID --70000018
                    and p.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                    and p.object_id   = aa.id
             );

exception
    when com_api_error_pkg.e_application_error then
        raise;
    when others then
        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
        raise;
end get_scoring_data;

procedure get_scoring_info_rec(
    io_scr_outgoing_rec     in out nocopy cst_cfc_api_type_pkg.t_scr_outgoing_rec
  , o_scr_info_rec             out nocopy cst_cfc_api_type_pkg.t_scr_info_rec
  , i_start_date            in            date
  , i_end_date              in            date
)
is
    l_revised_bucket        scr_api_type_pkg.t_scr_bucket_rec;
    l_account_reg_date      date;
begin
    o_scr_info_rec.gen_date := get_sysdate;
    l_account_reg_date      := cst_cfc_com_pkg.get_account_reg_date(
                                   i_account_id => io_scr_outgoing_rec.account_id
                               );

    o_scr_info_rec.card_limit   :=
        cst_cfc_com_pkg.get_balance_amount(
            i_account_id         => io_scr_outgoing_rec.account_id
          , i_balance_type       => crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED --'BLTP1001'
        );

    o_scr_info_rec.exceed_limit :=
        acc_api_balance_pkg.get_aval_balance_amount_only(
            i_account_id         => io_scr_outgoing_rec.account_id
        );

    o_scr_info_rec.sub_acct_bal :=
        cst_cfc_com_pkg.get_principal_amount(
            i_account_id         => io_scr_outgoing_rec.account_id
        );

    cst_cfc_com_pkg.get_total_trans(
        i_entity_type        => iss_api_const_pkg.ENTITY_TYPE_CARD --'ENTTCARD'
      , i_object_id          => io_scr_outgoing_rec.card_id
      , i_split_hash         => io_scr_outgoing_rec.split_hash
      , i_transaction_type   => opr_api_const_pkg.OPERATION_TYPE_ATM_CASH -- 'OPTP0001'
      , i_start_date         => i_start_date
      , i_end_date           => i_end_date
      , o_count              => o_scr_info_rec.atm_wdr_cnt
      , o_total_amount       => o_scr_info_rec.atm_wdr_amt
    );

    cst_cfc_com_pkg.get_total_trans(
        i_entity_type        => iss_api_const_pkg.ENTITY_TYPE_CARD --'ENTTCARD'
      , i_object_id          => io_scr_outgoing_rec.card_id
      , i_split_hash         => io_scr_outgoing_rec.split_hash
      , i_transaction_type   => opr_api_const_pkg.OPERATION_TYPE_PURCHASE -- 'OPTP0000'
      , i_start_date         => i_start_date
      , i_end_date           => i_end_date
      , o_count              => o_scr_info_rec.pos_cnt
      , o_total_amount       => o_scr_info_rec.pos_amt
    );

    cst_cfc_com_pkg.get_total_trans(
        i_entity_type        => iss_api_const_pkg.ENTITY_TYPE_CARD --'ENTTCARD'
      , i_object_id          => io_scr_outgoing_rec.card_id
      , i_split_hash         => io_scr_outgoing_rec.split_hash
      , i_start_date         => i_start_date
      , i_end_date           => i_end_date
      , o_count              => o_scr_info_rec.all_trx_cnt
      , o_total_amount       => o_scr_info_rec.total_trx_amt
    );

    o_scr_info_rec.daily_repayment :=
        cst_cfc_com_pkg.get_total_payment(
            i_account_id         => io_scr_outgoing_rec.account_id
        );

    o_scr_info_rec.current_dpd :=
        greatest(0, trunc(get_sysdate - cst_cfc_com_pkg.get_first_overdue_date(
                                            i_account_id  => io_scr_outgoing_rec.account_id
                                          , i_split_hash  => io_scr_outgoing_rec.split_hash
                                        )));

    l_revised_bucket := cst_cfc_com_pkg.get_current_revised_bucket(
                            i_customer_id   => io_scr_outgoing_rec.customer_id
                          , i_account_id    => io_scr_outgoing_rec.account_id
                        );

    o_scr_info_rec.revised_bucket := l_revised_bucket.revised_bucket;
    o_scr_info_rec.eff_date       := to_char(l_revised_bucket.eff_date,   cst_cfc_api_const_pkg.CST_SCR_DATE_FORMAT);
    o_scr_info_rec.expir_date     := to_char(l_revised_bucket.expir_date, cst_cfc_api_const_pkg.CST_SCR_DATE_FORMAT);
    o_scr_info_rec.valid_period   := l_revised_bucket.valid_period;
    o_scr_info_rec.reason         := l_revised_bucket.reason;

    o_scr_info_rec.highest_dpd    :=
        greatest(0, trunc(get_sysdate - cst_cfc_com_pkg.get_first_overdue_date(
                                            i_account_id  => io_scr_outgoing_rec.account_id
                                          , i_split_hash  => io_scr_outgoing_rec.split_hash
                                        )
        ));

    cst_cfc_com_pkg.get_total_trans(
        i_entity_type        => iss_api_const_pkg.ENTITY_TYPE_CARD --'ENTTCARD'
      , i_object_id          => io_scr_outgoing_rec.card_id
      , i_split_hash         => io_scr_outgoing_rec.split_hash
      , i_transaction_type   => opr_api_const_pkg.OPERATION_TYPE_ATM_CASH -- 'OPTP0001'
      , i_start_date         => l_account_reg_date
      , i_end_date           => get_sysdate
      , o_count              => o_scr_info_rec.life_wdr_cnt
      , o_total_amount       => o_scr_info_rec.life_wdr_amt
    );

    o_scr_info_rec.first_wdr_date :=
        cst_cfc_com_pkg.get_first_trx_date(
            i_entity_type        => com_api_const_pkg.ENTITY_TYPE_CUSTOMER --'ENTTCUST'
          , i_object_id          => io_scr_outgoing_rec.customer_id
          , i_transaction_type   => opr_api_const_pkg.OPERATION_TYPE_ATM_CASH -- 'OPTP0001'
        );

    o_scr_info_rec.tmp_crd_limit :=
        prd_api_product_pkg.get_attr_value_number(
            i_entity_type        => iss_api_const_pkg.ENTITY_TYPE_CARD --'ENTTCARD'
          , i_object_id          => io_scr_outgoing_rec.card_id
          , i_attr_name          => iss_api_const_pkg.ATTR_CARD_TEMP_CREDIT_LIMIT--'ISS_CARD_TEMPORARY_CREDIT_LIMIT_VALUE'
          , i_mask_error         => com_api_const_pkg.TRUE
        );

    o_scr_info_rec.limit_start_date :=
        cst_cfc_com_pkg.get_card_limit_valid_date(
            i_card_id            => io_scr_outgoing_rec.card_id
          , i_split_hash         => io_scr_outgoing_rec.split_hash
          , i_is_start           => com_api_const_pkg.TRUE
          , i_limit_type         => cst_cfc_api_const_pkg.CARD_TEMPORARY_CREDIT_LIMIT
        );

    o_scr_info_rec.limit_end_date :=
        cst_cfc_com_pkg.get_card_limit_valid_date(
            i_card_id            => io_scr_outgoing_rec.card_id
          , i_split_hash         => io_scr_outgoing_rec.split_hash
          , i_is_start           => com_api_const_pkg.FALSE
          , i_limit_type         => cst_cfc_api_const_pkg.CARD_TEMPORARY_CREDIT_LIMIT
        );

    o_scr_info_rec.overdue_interest :=
        cst_cfc_com_pkg.get_balance_amount(
            i_account_id         => io_scr_outgoing_rec.account_id
          , i_balance_type       => crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST
        );

    o_scr_info_rec.indue_interest :=
        cst_cfc_com_pkg.get_balance_amount(
            i_account_id         => io_scr_outgoing_rec.account_id
          , i_balance_type       => crd_api_const_pkg.BALANCE_TYPE_INTEREST
        );

    o_scr_info_rec.card_usage_limit      := round(o_scr_info_rec.life_wdr_amt);

    o_scr_info_rec.cycle_avg_wdr_amt     := round(o_scr_info_rec.cycle_wdr_amt/nullif(o_scr_info_rec.cycle_wdr_cnt, 0));

    o_scr_info_rec.avg_wdr               := round(o_scr_info_rec.life_wdr_amt/nullif(o_scr_info_rec.life_wdr_cnt, 0));

    o_scr_info_rec.daily_usage           := round(o_scr_info_rec.life_wdr_amt/ceil(get_sysdate - o_scr_info_rec.first_wdr_date));

    if months_between(get_sysdate, o_scr_info_rec.first_wdr_date) = 0 then
        o_scr_info_rec.monthly_usage     := 1;
    else
        o_scr_info_rec.monthly_usage     := ceil(months_between(get_sysdate, o_scr_info_rec.first_wdr_date));
    end if;

    for r in (
          select *
            from table(cast(cst_cfc_com_pkg.get_last_invoice(
                                i_entity_type     => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT--'ENTTACCT'
                              , i_object_id      => io_scr_outgoing_rec.account_id
                              , i_split_hash     => io_scr_outgoing_rec.split_hash
                           ) as crd_invoice_tpt)) v
           where v.account_id = io_scr_outgoing_rec.account_id
    )
    loop
        o_scr_info_rec.invoice_date   := r.invoice_date;
        o_scr_info_rec.due_date       := r.due_date;
        o_scr_info_rec.min_amount_due := r.min_amount_due;

        o_scr_info_rec.cycle_repayment :=
            cst_cfc_com_pkg.get_total_payment(
                i_account_id         => io_scr_outgoing_rec.account_id
              , i_start_date         => r.invoice_date
              , i_end_date           => add_months(r.invoice_date, 1)
            );

        o_scr_info_rec.bucket :=
            coalesce(substr(crd_invoice_pkg.get_converted_aging_period(i_aging_period => r.aging_period), -2)
                          , to_char(r.aging_period), '1a');

        o_scr_info_rec.highest_bucket_01 :=
            cst_cfc_com_pkg.get_highest_bucket(
                i_customer_id        => io_scr_outgoing_rec.customer_id
              , i_account_id         => io_scr_outgoing_rec.account_id
              , i_split_hash         => io_scr_outgoing_rec.split_hash
              , i_start_date         => r.invoice_date
              , i_end_date           => add_months(r.invoice_date, 1)
            );

        o_scr_info_rec.highest_bucket_03 :=
            cst_cfc_com_pkg.get_highest_bucket(
                i_customer_id        => io_scr_outgoing_rec.customer_id
              , i_account_id         => io_scr_outgoing_rec.account_id
              , i_split_hash         => io_scr_outgoing_rec.split_hash
              , i_start_date         => r.invoice_date
              , i_end_date           => add_months(r.invoice_date, 3)
            );

        o_scr_info_rec.highest_bucket_06 :=
            cst_cfc_com_pkg.get_highest_bucket(
                i_customer_id        => io_scr_outgoing_rec.customer_id
              , i_account_id         => io_scr_outgoing_rec.account_id
              , i_split_hash         => io_scr_outgoing_rec.split_hash
              , i_start_date         => r.invoice_date
              , i_end_date           => add_months(r.invoice_date, 6)
            );

        cst_cfc_com_pkg.get_total_trans(
            i_entity_type        => iss_api_const_pkg.ENTITY_TYPE_CARD --'ENTTCARD'
          , i_object_id          => io_scr_outgoing_rec.card_id
          , i_split_hash         => io_scr_outgoing_rec.split_hash
          , i_transaction_type   => opr_api_const_pkg.OPERATION_TYPE_ATM_CASH -- 'OPTP0001'
          , i_start_date         => r.invoice_date
          , i_end_date           => add_months(r.invoice_date, 1)
          , o_count              => o_scr_info_rec.cycle_wdr_cnt
          , o_total_amount       => o_scr_info_rec.cycle_wdr_amt
        );

        o_scr_info_rec.total_debit_amt :=
            cst_cfc_com_pkg.get_debit_amount(
                i_account_id         => io_scr_outgoing_rec.account_id
              , i_split_hash         => io_scr_outgoing_rec.split_hash
              , i_start_date         => r.invoice_date

              , i_end_date           => add_months(r.invoice_date, 1)
            );

        o_scr_info_rec.cycle_daily_avg_usage := round(o_scr_info_rec.cycle_wdr_amt/ceil(get_sysdate - r.invoice_date));

    end loop;

end get_scoring_info_rec;

end scr_api_external_pkg;
/
