create or replace package body pmo_api_rule_proc_pkg is
/*********************************************************
 *  API for event rule processing <br />
 *  Created by Fomichev A (fomichev@bpcbt.com)  at 04.04.2018 <br />
 *  Module: PMO_API_RULE_PROC_PKG <br />
 *  @headcom
 **********************************************************/

procedure add_payment_order is
    LOG_PREFIX     constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.change_objects: ';
    l_entity_type           com_api_type_pkg.t_name;
    l_object_id             com_api_type_pkg.t_long_id;
    l_amount_name           com_api_type_pkg.t_name;
    l_purpose_id            com_api_type_pkg.t_long_id;
    l_split_hash            com_api_type_pkg.t_tiny_id;
    l_event_date            date;
    l_inst_id               com_api_type_pkg.t_tiny_id;
    l_payment_order_id      com_api_type_pkg.t_long_id;
    l_amount_rec            com_api_type_pkg.t_amount_rec;
    l_customer_id           com_api_type_pkg.t_long_id;
    l_template_id           com_api_type_pkg.t_long_id;
    l_event_type            com_api_type_pkg.t_dict_value;
    l_param_tab             com_api_type_pkg.t_param_tab;
begin
    l_entity_type  := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_object_id    := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');
    l_amount_name  := evt_api_shared_data_pkg.get_param_char('AMOUNT_NAME');
    l_purpose_id   := evt_api_shared_data_pkg.get_param_num('PAYMENT_PURPOSE');
    l_split_hash   := evt_api_shared_data_pkg.get_param_num('SPLIT_HASH');
    l_event_date   := evt_api_shared_data_pkg.get_param_date('EVENT_DATE');
    l_inst_id      := evt_api_shared_data_pkg.get_param_num('INST_ID');
    l_event_type   := evt_api_shared_data_pkg.get_param_char('EVENT_TYPE');

    trc_log_pkg.debug(
        LOG_PREFIX
        || ' l_entity_type = '
        || l_entity_type
        || ', l_object_id = '
        || l_object_id
        || ', l_amount_name = '
        || l_amount_name
        || ', l_purpose_id = '
        || l_purpose_id
        || ', l_split_hash = '
        || l_split_hash
        || ', l_event_date = '
        || l_event_date
        || ', l_inst_id = '
        || l_inst_id
        || ', l_event_type = '
        || l_event_type
    );

    if l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
        l_customer_id := iss_api_card_pkg.get_card(i_card_id => l_object_id ).customer_id;

    elsif l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE then
        select c.customer_id
             , c.id
          into l_customer_id
             , l_object_id
          from iss_card_instance i
             , iss_card c
         where c.id = i.card_id
           and i.id = l_object_id;

        l_entity_type := iss_api_const_pkg.ENTITY_TYPE_CARD;

    elsif l_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        l_customer_id  := acc_api_account_pkg.get_account(i_account_id =>  l_object_id).customer_id;

    elsif l_entity_type = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER then
        l_customer_id := l_object_id;

    end if;

    evt_api_shared_data_pkg.get_amount(
        i_name        => l_amount_name
      , o_amount      => l_amount_rec.amount
      , o_currency    => l_amount_rec.currency
    );

    begin
        select order_id
          into l_template_id
          from pmo_schedule s
         where s.event_type     = l_event_type
           and s.object_id      = l_object_id
           and s.entity_type    = l_entity_type;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'PAYMENT_ORDER_NOT_FOUND'
              , i_env_param1    => l_event_type
              , i_env_param2    => l_object_id
              , i_env_param3    => l_entity_type
            );
        when dup_val_on_index then
            com_api_error_pkg.raise_error(
                i_error         => 'TOO_MANY_PAYMENT_ORDERS_FOUND'
            );
    end;

    pmo_api_order_pkg.add_order_with_params(
        io_payment_order_id     => l_payment_order_id
      , i_entity_type           => l_entity_type
      , i_object_id             => l_object_id
      , i_customer_id           => l_customer_id
      , i_split_hash            => l_split_hash
      , i_purpose_id            => l_purpose_id
      , i_template_id           => l_template_id
      , i_amount_rec            => l_amount_rec
      , i_eff_date              => l_event_date
      , i_order_status          => pmo_api_const_pkg.PMO_STATUS_AWAITINGPROC
      , i_inst_id               => l_inst_id
      , i_attempt_count         => 0
      , i_payment_order_number  => null
      , i_expiration_date       => null
      , i_register_event        => com_api_const_pkg.TRUE
      , i_param_tab             => l_param_tab
    );

end add_payment_order;

procedure stop_payment_order as
    l_entity_type       com_api_type_pkg.t_name;
    l_object_id         com_api_type_pkg.t_long_id;
    l_split_hash        com_api_type_pkg.t_tiny_id;
    l_cycle_type        com_api_type_pkg.t_dict_value;
    l_purpose_id        com_api_type_pkg.t_long_id;
begin
    l_entity_type  := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_object_id    := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');
    l_purpose_id   := evt_api_shared_data_pkg.get_param_num('PAYMENT_PURPOSE');
    l_split_hash   := evt_api_shared_data_pkg.get_param_num('SPLIT_HASH');
    l_cycle_type   := evt_api_shared_data_pkg.get_param_char('CYCLE_TYPE');

    for r in (
        select o.id
          from pmo_order o
         where decode(status, 'POSA0001', status, null) = pmo_api_const_pkg.PMO_STATUS_AWAITINGPROC
           and o.object_id   = l_object_id
           and o.entity_type = l_entity_type
           and o.split_hash  = l_split_hash
           and o.purpose_id  = l_purpose_id
    )
    loop
        trc_log_pkg.debug(
            i_text       => 'Found order [#1]'
          , i_env_param1 => r.id
        );
        
        pmo_api_order_pkg.set_order_status(
            i_order_id => r.id
          , i_status   => pmo_api_const_pkg.PMO_STATUS_CANCELED
        );
        
        fcl_api_cycle_pkg.remove_cycle_counter(
            i_cycle_type  => l_cycle_type
          , i_entity_type => pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER
          , i_object_id   => r.id
          , i_split_hash  => l_split_hash
        );
    end loop;
end;

procedure register_oper_detail is
    l_eff_date                      date;
    l_eff_date_name                 com_api_type_pkg.t_name;
    l_order_id                      com_api_type_pkg.t_long_id;
    l_template_id                   com_api_type_pkg.t_long_id;
    l_party_type                    com_api_type_pkg.t_dict_value;
    l_participant                   opr_api_type_pkg.t_oper_part_rec;
    l_entity_type                   com_api_type_pkg.t_dict_value;
    l_account_name                  com_api_type_pkg.t_dict_value;
    l_purpose_id                    com_api_type_pkg.t_short_id;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_inst_id                       com_api_type_pkg.t_short_id;
    l_customer_id                   com_api_type_pkg.t_medium_id;
    l_split_hash                    com_api_type_pkg.t_tiny_id;
    l_amount_rec                    com_api_type_pkg.t_amount_rec;
    l_param_tab                     com_api_type_pkg.t_param_tab;
    l_prepared_order_id             com_api_type_pkg.t_long_id;
    l_oper_id                       com_api_type_pkg.t_long_id;
begin
    l_oper_id := opr_api_shared_data_pkg.get_operation().id;

    for r in (
        select o.object_id
          from opr_oper_detail o
         where o.oper_id = l_oper_id
           and o.entity_type = pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER
    ) loop
        select customer_id
             , object_id
             , entity_type
             , inst_id
             , split_hash
             , purpose_id
          into l_customer_id
             , l_object_id
             , l_entity_type
             , l_inst_id
             , l_split_hash
             , l_purpose_id
          from pmo_order
         where id = r.object_id;

        pmo_api_order_pkg.add_oper_to_prepared_order(
            i_customer_id       => l_customer_id
          , i_purpose_id        => l_purpose_id
          , i_split_hash        => l_split_hash
          , i_inst_id           => l_inst_id
          , i_oper_id           => l_oper_id
          , o_prepared_order_id => l_prepared_order_id
        );

    end loop;

end register_oper_detail;

end pmo_api_rule_proc_pkg;
/
