create or replace package body crd_cst_payment_pkg as

procedure apply_payment(
    i_payment_id        in      com_api_type_pkg.t_long_id
  , i_eff_date          in      date
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_account_id        in      com_api_type_pkg.t_account_id
  , i_currency          in      com_api_type_pkg.t_curr_code
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_account_type      in      com_api_type_pkg.t_dict_value
  , i_product_id        in      com_api_type_pkg.t_short_id
  , i_service_id        in      com_api_type_pkg.t_short_id
  , io_payment_amount   in out  com_api_type_pkg.t_money
) is
    l_param_tab                 com_api_type_pkg.t_param_tab;
    l_param_tab_evt             com_api_type_pkg.t_param_tab;
    l_bunch_id                  com_api_type_pkg.t_long_id;
    l_bunch_type_id             com_api_type_pkg.t_long_id;
    l_bunch_type                varchar(2000);
    l_save_mask_error           com_api_type_pkg.t_boolean;
    l_product_exist             com_api_type_pkg.t_boolean;

    cursor cur_payment_gl(
        i_payment_id    com_api_type_pkg.t_long_id
      , i_account_id    com_api_type_pkg.t_account_id
    ) is
    select o.id
         , cdp.balance_type
         , con.contract_type
         , o.merchant_country
         , cd.oper_type
         , o.sttl_type
         , cd.macros_type_id
         , cd.fee_type
         , o.oper_reason
         , o.msg_type
         , null is_reversal
         , sum(cdp.pay_amount)  pay_amount
      from crd_payment          cp
         , crd_debt_payment     cdp
         , crd_debt             cd
         , opr_operation        o
         , acc_account          a
         , prd_contract         con
     where cd.account_id        = i_account_id
       and cd.id                = cdp.debt_id
       and cp.id                = cdp.pay_id
       and cp.id                = i_payment_id
       and o.id                 = decode(cd.oper_type, dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER
                                       , cd.original_id, cd.oper_id)
       and cd.account_id        = a.id
       and a.contract_id        = con.id
       and (case when (cp.is_reversal = 1 and cp.original_oper_id is not null
                  and cp.original_oper_id = cd.oper_id)
                 then 0
                 else 1
            end) = 1
       and not exists (select 1
                        from opr_operation
                       where oper_type  = dpp_api_const_pkg.OPERATION_TYPE_DPP_REGISTER -- 'OPTP1501'
                         and id         = cp.oper_id
                      )
     group by
           o.id
         , cdp.balance_type
         , con.contract_type
         , o.merchant_country
         , cd.oper_type
         , o.sttl_type
         , cd.macros_type_id
         , cd.fee_type
         , o.oper_reason
         , o.msg_type
    union all
    select o.id
         , null balance_type
         , con.contract_type
         , o.merchant_country
         , o.oper_type
         , o.sttl_type
         , null macros_type_id
         , null fee_type
         , o.oper_reason
         , o.msg_type
         , o.is_reversal
         , sum(cdp.pay_amount)  pay_amount
      from crd_payment          cp
         , crd_debt_payment     cdp
         , crd_debt             cd
         , opr_operation        o
         , acc_account          a
         , prd_contract         con
     where cd.account_id        = i_account_id
       and cd.id                = cdp.debt_id
       and cp.id                = cdp.pay_id
       and cp.id                = i_payment_id
       and cd.account_id        = a.id
       and a.contract_id        = con.id
       and cp.oper_id           = o.id
       and o.original_id        is null
       and (o.is_reversal       = com_api_type_pkg.TRUE
            or
            o.oper_type         = opr_api_const_pkg.OPERATION_TYPE_REFUND --'OPTP0020'
           )
     group by
           o.id
         , con.contract_type
         , o.merchant_country
         , o.oper_type
         , o.sttl_type
         , o.oper_reason
         , o.msg_type
         , o.is_reversal
    ;
begin
    trc_log_pkg.debug(
        i_text => 'GL routing payment: product id [' || i_product_id
               || '], i_service_id [' || i_service_id || '], account id [' || i_account_id
               || '], i_payment_id [' || i_payment_id
               || '], io_payment_amount [' || io_payment_amount || ']'
    );

    begin
        select com_api_const_pkg.TRUE
          into l_product_exist
          from prd_attribute        pa
             , prd_attribute_value  pav
         where pa.attr_name         = cst_woo_const_pkg.BUNCH_GL_ROUTING
           and pa.id                = pav.attr_id
           and pav.entity_type      = prd_api_const_pkg.ENTITY_TYPE_PRODUCT --'ENTTPROD'
           and pav.object_id        in (select id
                                          from prd_product
                                         start with id = i_product_id
                                       connect by id   = prior parent_id)
           and rownum               = 1;
    exception
        when no_data_found then
            l_product_exist := com_api_const_pkg.FALSE;
    end;

    if l_product_exist = com_api_const_pkg.TRUE then
        for rec in cur_payment_gl(
            i_payment_id
          , i_account_id
        ) loop
            rul_api_param_pkg.set_param (
                io_params         => l_param_tab
              , i_name            => 'BALANCE_TYPE'
              , i_value           => rec.balance_type
            );

            rul_api_param_pkg.set_param (
                io_params         => l_param_tab
              , i_name            => 'CONTRACT_TYPE'
              , i_value           => rec.contract_type
            );

            rul_api_param_pkg.set_param (
                io_params         => l_param_tab
              , i_name            => 'CST_CREDIT_DEBIT_FLAG'
              , i_value           => com_api_type_pkg.TRUE
            );

            rul_api_param_pkg.set_param (
                io_params         => l_param_tab
              , i_name            => 'MERCHANT_COUNTRY'
              , i_value           => rec.merchant_country
            );

            rul_api_param_pkg.set_param (
                io_params         => l_param_tab
              , i_name            => 'OPER_TYPE'
              , i_value           => rec.oper_type
            );

            rul_api_param_pkg.set_param (
                io_params         => l_param_tab
              , i_name            => 'STTL_TYPE'
              , i_value           => rec.sttl_type
            );

            rul_api_param_pkg.set_param (
                io_params         => l_param_tab
              , i_name            => 'MACROS_TYPE'
              , i_value           => rec.macros_type_id
            );

            rul_api_param_pkg.set_param (
                io_params         => l_param_tab
              , i_name            => 'OPER_REASON'
              , i_value           => rec.oper_reason
            );

            if rec.is_reversal is not null then
                rul_api_param_pkg.set_param (
                    io_params     => l_param_tab
                  , i_name        => 'IS_REVERSAL'
                  , i_value       => rec.is_reversal
                );
            end if;

            begin
                l_save_mask_error := com_api_error_pkg.get_mask_error;
                com_api_error_pkg.set_mask_error (
                    i_mask_error  => com_api_type_pkg.FALSE
                );

                l_bunch_type :=
                    prd_api_product_pkg.get_attr_value_char(
                        i_product_id    => i_product_id
                      , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                      , i_object_id     => i_account_id
                      , i_attr_name     => cst_woo_const_pkg.BUNCH_GL_ROUTING
                      , i_service_id    => i_service_id
                      , i_split_hash    => i_split_hash
                      , i_params        => l_param_tab
                      , i_eff_date      => i_eff_date
                      , i_inst_id       => i_inst_id
                    );

                com_api_error_pkg.set_mask_error (
                    i_mask_error  => l_save_mask_error
                );
            exception
                when com_api_error_pkg.e_application_error then
                    trc_log_pkg.debug('Bunch type id does not exist.');
                    l_bunch_type := null;
                    insert into cst_woo_payment_gl_routing_log (
                        payment_id
                      , oper_id
                      , balance_type
                      , contract_type
                      , merchant_country
                      , oper_type
                      , sttl_type
                      , macros_type_id
                      , fee_type
                      , oper_reason
                      , msg_type
                      , is_reversal
                      , pay_amount
                      , eff_date
                      ) values (
                        i_payment_id
                      , rec.id
                      , rec.balance_type
                      , rec.contract_type
                      , rec.merchant_country
                      , rec.oper_type
                      , rec.sttl_type
                      , rec.macros_type_id
                      , rec.fee_type
                      , rec.oper_reason
                      , rec.msg_type
                      , rec.is_reversal
                      , rec.pay_amount
                      , i_eff_date
                    );
            end;

            if l_bunch_type is not null then
                l_bunch_type_id := to_number(l_bunch_type);
                trc_log_pkg.debug('Bunch type =[' || l_bunch_type_id || ']');
                acc_api_entry_pkg.put_bunch (
                    o_bunch_id          => l_bunch_id
                  , i_bunch_type_id     => l_bunch_type_id
                  , i_macros_id         => i_payment_id
                  , i_amount            => rec.pay_amount
                  , i_currency          => i_currency
                  , i_account_type      => i_account_type
                  , i_account_id        => i_account_id
                  , i_posting_date      => i_eff_date
                  , i_param_tab         => l_param_tab
                );
            end if;
        end loop;
    end if;

    trc_log_pkg.debug(
        i_text => 'Register event [' || cst_woo_const_pkg.EVT_TYPE_UNLOADING_CARD_INFO
               || '] upload card info after payment id [' || i_payment_id || ']'
    );

    for rec1 in (
        select a.object_id
             , o.oper_type
          from crd_payment     cp
             , opr_operation   o
             , acc_account_object a
         where cp.id           = i_payment_id
           and cp.account_id   = i_account_id
           and cp.oper_id      = o.id
           and cp.account_id   = a.account_id
           and a.entity_type   = iss_api_const_pkg.ENTITY_TYPE_CARD
    )loop
        rul_api_param_pkg.set_param (
            io_params       => l_param_tab_evt
          , i_name          => 'OPER_TYPE'
          , i_value         => rec1.oper_type
        );

        evt_api_event_pkg.register_event(
            i_event_type    => cst_woo_const_pkg.EVT_TYPE_UNLOADING_CARD_INFO
          , i_eff_date      => i_eff_date
          , i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD
          , i_object_id     => rec1.object_id
          , i_inst_id       => i_inst_id
          , i_split_hash    => i_split_hash
          , i_param_tab     => l_param_tab_evt
        );
    end loop;

exception
    when com_api_error_pkg.e_application_error then
        trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.apply_payment - FAILED');
end;

procedure enum_debt_order(
    io_cur_debts        in out  com_api_type_pkg.t_ref_cur
  , io_query            in out  com_api_type_pkg.t_text
  , io_order_by         in out  com_api_type_pkg.t_text
  , i_account_id        in      com_api_type_pkg.t_account_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_product_id        in      com_api_type_pkg.t_short_id
  , i_service_id        in      com_api_type_pkg.t_short_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_eff_date          in      date
  , i_original_oper_id  in      com_api_type_pkg.t_long_id
  , i_payment_condition in      com_api_type_pkg.t_dict_value
  , i_repay_mad_first   in      com_api_type_pkg.t_boolean
) is
begin
    null;
end;

end;
/
