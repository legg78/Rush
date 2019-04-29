create or replace package body lty_api_acq_operation_pkg is

procedure get_operations(
    i_inst_id               com_api_type_pkg.t_inst_id
  , i_merchant_id           com_api_type_pkg.t_medium_id
  , i_status                com_api_type_pkg.t_dict_value
  , i_card_number           com_api_type_pkg.t_card_number
  , i_auth_code             com_api_type_pkg.t_auth_code   default null
  , i_start_date            date                           default null
  , i_end_date              date                           default null
  , i_spent_operation       com_api_type_pkg.t_long_id     default null
  , o_ref_cursor       out  sys_refcursor
) as
    l_params              com_api_type_pkg.t_param_tab;
    l_cycle_id            com_api_type_pkg.t_short_id;
    l_eff_date            date;
    l_date                date;
    l_from_id             com_api_type_pkg.t_long_id;
    l_till_id             com_api_type_pkg.t_long_id;
    l_card_number         com_api_type_pkg.t_card_number;
begin
    trc_log_pkg.debug(
        i_text       => 'get_operations: i_card_number [#1], i_merchant_id [#2], i_status [#3]'
      , i_env_param1 => iss_api_card_pkg.get_card_mask(i_card_number)
      , i_env_param2 => i_merchant_id
      , i_env_param3 => i_status
    );

    l_eff_date := com_api_sttl_day_pkg.get_sysdate;
    l_from_id  := com_api_id_pkg.get_from_id(i_start_date);
    l_till_id  := com_api_id_pkg.get_till_id(i_end_date);
    l_card_number := iss_api_token_pkg.encode_card_number(i_card_number => i_card_number);

    begin
        l_cycle_id :=
            prd_api_product_pkg.get_cycle_id(
                i_product_id   => prd_api_product_pkg.get_product_id(
                                      i_entity_type => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                                    , i_object_id   => i_merchant_id
                                    , i_eff_date    => l_eff_date
                                    , i_inst_id     => i_inst_id
                                  )
              , i_entity_type  => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
              , i_object_id    => i_merchant_id
              , i_cycle_type   => lty_api_const_pkg.LTY_MRCH_RWRD_RDMPT_CYC_TYPE
              , i_params       => l_params
              , i_eff_date     => l_eff_date
              , i_inst_id      => i_inst_id
            );
    exception when com_api_error_pkg.e_application_error then
        l_cycle_id := null;
    end;

    if l_cycle_id is not null then
        fcl_api_cycle_pkg.calc_next_date(
            i_cycle_id    => l_cycle_id
          , i_start_date  => l_eff_date
          , o_next_date   => l_date
        );
    end if;

    trc_log_pkg.debug(
        i_text       => 'get_operations: l_date [#1]'
      , i_env_param1 => l_date
    );

    open o_ref_cursor for
        select o.id as oper_id
             , o.oper_type
             , o.oper_date
             , o.oper_amount
             , a.merchant_id
             , a.inst_id
             , o.merchant_number
             , o.merchant_name
             , ci.card_number
             , i.auth_code
             , m.amount as reward_amount
          from opr_operation o
             , opr_participant a
             , opr_participant i
             , opr_card ci
             , acc_macros m
             , lty_spent_operation so
         where a.oper_id           = o.id
           and a.participant_type  = com_api_const_pkg.PARTICIPANT_ACQUIRER
           and i.oper_id           = o.id
           and i.participant_type  = com_api_const_pkg.PARTICIPANT_ISSUER
           and ci.oper_id          = o.id
           and ci.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
           and m.entity_type       = opr_api_const_pkg.ENTITY_TYPE_OPERATION
           and m.object_id         = o.id
           and m.macros_type_id    = lty_api_const_pkg.LTY_RWRD_ENROLL_MACROS_TYPE_ID
           and o.id                = so.id(+)
           and a.merchant_id       = i_merchant_id
           and reverse(ci.card_number) like reverse(l_card_number)
           and (
                   (  i_status = lty_api_const_pkg.LTY_RWRD_STATUS_ACTIVE
                  and so.id is null
               )
               or
                   (  i_status = lty_api_const_pkg.LTY_RWRD_STATUS_SPENT
                  and so.id is not null
               )
           )
           and (
                   i_spent_operation is null
                or (o.id in (select id from lty_spent_operation where spent_oper_id = i_spent_operation))
           )
           and (i.auth_code = i_auth_code or i_auth_code is null)
           and (o.id >= l_from_id or i_start_date is null)
           and (o.id <= l_till_id or i_end_date is null)
           and (o.oper_date <= l_date or l_date is null)
           ;
end;

procedure add_spent_operation(
    i_oper_id_tab        num_tab_tpt
  , i_spent_operation    com_api_type_pkg.t_long_id
) as
begin
    trc_log_pkg.debug(
        i_text       => 'add_spent_operation: i_spent_operation [#1], i_oper_id_tab.count [#2]'
      , i_env_param1 => i_spent_operation
      , i_env_param2 => i_oper_id_tab.count
    );
    
    if i_oper_id_tab.count > 0 then
        forall i in i_oper_id_tab.first .. i_oper_id_tab.last 
            insert into lty_spent_operation(id, spent_oper_id)
                 values (i_oper_id_tab(i), i_spent_operation);
    end if;
end;

end;
/
