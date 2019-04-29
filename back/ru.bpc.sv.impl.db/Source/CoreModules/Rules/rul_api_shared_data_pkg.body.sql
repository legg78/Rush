create or replace package body rul_api_shared_data_pkg as
/*********************************************************
 *  API for rule shared data <br />
 *  Created by Fomichev E.(fomichev@bpcbt.com)  at 06.12.2011 <br />
 *  Module: rul_api_shared_data_pkg <br />
 *  @headcom
 **********************************************************/

procedure load_params(
    i_entity_type        in            com_api_type_pkg.t_dict_value
  , i_object_id          in            com_api_type_pkg.t_medium_id
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
  , i_full_set           in            com_api_type_pkg.t_boolean       default null
  , i_usage              in            com_api_type_pkg.t_dict_value    default null
) is
    l_merchant_id                      com_api_type_pkg.t_short_id;
    l_terminal_id                      com_api_type_pkg.t_short_id;
    l_account_id                       com_api_type_pkg.t_medium_id;
    l_card_id                          com_api_type_pkg.t_medium_id;
    l_instance_id                      com_api_type_pkg.t_medium_id;
    l_contract_id                      com_api_type_pkg.t_medium_id;
    l_customer_id                      com_api_type_pkg.t_medium_id;
    l_oper_id                          com_api_type_pkg.t_long_id;
    l_payment_order_id                 com_api_type_pkg.t_long_id;
    l_application_id                   com_api_type_pkg.t_long_id;
    l_entry_id                         com_api_type_pkg.t_long_id;
    l_identify_object_id               com_api_type_pkg.t_long_id;
    l_invoice_id                       com_api_type_pkg.t_long_id;
    l_document_id                      com_api_type_pkg.t_long_id;
begin
    if i_entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL then
        l_terminal_id := i_object_id;
        if nvl(i_full_set, com_api_const_pkg.FALSE) = com_api_type_pkg.TRUE then
            select t.merchant_id
                 , t.contract_id
                 , c.customer_id
              into l_merchant_id
                 , l_contract_id
                 , l_customer_id
              from acq_terminal t
                 , prd_contract c
             where t.contract_id = c.id
               and t.id = l_terminal_id;
        end if;
    elsif i_entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT then
        l_merchant_id := i_object_id;
        if nvl(i_full_set, com_api_const_pkg.FALSE) = com_api_type_pkg.TRUE then
            select m.contract_id
                 , c.customer_id
              into l_contract_id
                 , l_customer_id
              from acq_merchant m
                 , prd_contract c
             where m.contract_id = c.id
               and m.id = l_merchant_id;
        end if;
    elsif i_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
        l_card_id := i_object_id;
        if nvl(i_full_set, com_api_const_pkg.FALSE) = com_api_type_pkg.TRUE then
            select c.contract_id
                 , c.customer_id
              into l_contract_id
                 , l_customer_id
              from iss_card c
             where c.id = l_card_id;
        end if;
    elsif i_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE then
        l_instance_id := i_object_id;
        if nvl(i_full_set, com_api_const_pkg.FALSE) = com_api_type_pkg.TRUE then
            select c.contract_id
                 , c.customer_id
              into l_contract_id
                 , l_customer_id
              from iss_card c
                 , iss_card_instance i
             where c.id = i.card_id
               and i.id = l_instance_id;
        end if;
    elsif i_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_TOKEN then
        select t.card_instance_id
          into l_instance_id
          from iss_card_token t
         where t.id = i_object_id;
    elsif i_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        l_account_id := i_object_id;
        if nvl(i_full_set, com_api_const_pkg.FALSE) = com_api_type_pkg.TRUE then
            select a.contract_id
                 , a.customer_id
              into l_contract_id
                 , l_customer_id
              from acc_account a
             where a.id = l_account_id;
        end if;
    elsif i_entity_type = prd_api_const_pkg.ENTITY_TYPE_CONTRACT then
        l_contract_id := i_object_id;
        if nvl(i_full_set, com_api_const_pkg.FALSE) = com_api_type_pkg.TRUE then
            select c.customer_id
              into l_customer_id
              from prd_contract c
             where c.id = l_contract_id;
        end if;
    elsif i_entity_type = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER then
        l_customer_id := i_object_id;
    elsif i_entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION then
        l_oper_id := i_object_id;
        if nvl(i_full_set, com_api_const_pkg.FALSE) = com_api_type_pkg.TRUE then
            select payment_order_id
              into l_payment_order_id
              from opr_operation
             where id = l_oper_id;
        end if;
    elsif i_entity_type = pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER then
        l_payment_order_id := i_object_id;
        if nvl(i_full_set, com_api_const_pkg.FALSE) = com_api_type_pkg.TRUE then
            select max(id)
              into l_oper_id
              from opr_operation
             where payment_order_id = l_payment_order_id;
        end if;
    elsif i_entity_type = acc_api_const_pkg.ENTITY_TYPE_ENTRY then
        l_entry_id := i_object_id;
        --
        select account_id
          into l_account_id
          from acc_entry
         where id = i_object_id;
    elsif i_entity_type = app_api_const_pkg.ENTITY_TYPE_APPLICATION then
        l_application_id := i_object_id;
    elsif i_entity_type = com_api_const_pkg.ENTITY_TYPE_IDENTIFY_OBJECT then
        l_identify_object_id := i_object_id;
    elsif i_entity_type = crd_api_const_pkg.ENTITY_TYPE_INVOICE then
        l_invoice_id := i_object_id;
        select inv.account_id
             , acc.customer_id
             , acc.contract_id
          into l_account_id
             , l_customer_id
             , l_contract_id
          from crd_invoice inv
             , acc_account acc
         where inv.id = l_invoice_id
           and inv.account_id = acc.id;
    elsif i_entity_type = dpp_api_const_pkg.ENTITY_TYPE_PAYMENT_PLAN then
        load_dpp_params(
            i_dpp_id     => i_object_id
          , io_params    => io_params
        );

        l_oper_id := rul_api_param_pkg.get_param_num(
                         i_name    => 'ORIGINAL_OPERATION_ID'
                       , io_params => io_params
                     );
    elsif i_entity_type = rpt_api_const_pkg.ENTITY_TYPE_DOCUMENT then
        l_document_id := i_object_id;
    end if;

    if i_object_id is not null then
        load_object(
            i_entity_type  => i_entity_type
          , i_object_id    => i_object_id
          , io_params      => io_params
        );
    end if;
    if l_document_id is not null then
        load_document_params(
            i_documnet_id   => l_document_id
          , io_params       => io_params
        );
    end if;
    if l_terminal_id is not null then
        load_terminal_params(
            i_terminal_id   => l_terminal_id
          , io_params       => io_params
          , i_full_set      => i_full_set
        );
    end if;
    if l_merchant_id is not null then
        load_merchant_params(
            i_merchant_id   => l_merchant_id
          , io_params       => io_params
        );
    end if;
    if l_card_id is not null then
        load_card_params(
            i_card_id => l_card_id
          , io_params => io_params
        );
    end if;
    if l_instance_id is not null then
        select c.id
          into l_card_id
          from iss_card c
             , iss_card_instance i
         where c.id = i.card_id
           and i.id = l_instance_id;
        load_card_params(
            i_card_id => l_card_id
          , io_params => io_params
        );
    end if;
    if l_account_id is not null then
        load_account_params(
            i_account_id => l_account_id
          , io_params    => io_params
        );
    end if;
    if l_contract_id is not null then
        load_contract_params(
            i_contract_id => l_contract_id
          , io_params     => io_params
        );
    end if;
    if l_customer_id is not null then
        load_customer_params(
            i_customer_id => l_customer_id
          , io_params     => io_params
        );
    end if;
    if l_oper_id is not null then
        load_oper_params(
            i_oper_id       => l_oper_id
          , io_params       => io_params
        );
    end if;
    if l_payment_order_id is not null then
        load_payment_order_params(
            i_payment_order_id  => l_payment_order_id
          , io_params           => io_params
        );
    end if;
    if l_application_id is not null then
        load_application_params(
            i_application_id => l_application_id
          , io_params        => io_params
        );
    end if;
    if l_entry_id is not null then
        load_entry_params(
            i_entry_id       => l_entry_id
          , io_params        => io_params
        );
    end if;
    if l_invoice_id is not null then
        load_invoice_params(
            i_invoice_id     => l_invoice_id
          , io_params        => io_params
        );
    end if;

    load_flexible_fields(
        i_entity_type  => i_entity_type
      , i_object_id    => i_object_id
      , i_usage        => i_usage
      , io_params      => io_params
    );

    if l_identify_object_id is not null then
        load_id_object_params(
            i_id           => i_object_id
        );
    end if;

exception
    when others then
        trc_log_pkg.warn(
            i_text        => sqlerrm || ' [#1][#2]'
          , i_env_param1  => i_entity_type
          , i_env_param2  => i_object_id
        );
end load_params;

procedure load_linked_object_params(
    i_dst_entity_type    in            com_api_type_pkg.t_dict_value
  , i_party_type         in            com_api_type_pkg.t_dict_value    default null
  , i_entity_type        in            com_api_type_pkg.t_dict_value
  , i_object_id          in            com_api_type_pkg.t_medium_id
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
) is
    l_object_id                        com_api_type_pkg.t_long_id;
begin
    if i_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
        if i_dst_entity_type = prd_api_const_pkg.ENTITY_TYPE_CONTRACT then
            select contract_id into l_object_id from iss_card where id = i_object_id;
            load_contract_params(
                i_contract_id => l_object_id
              , io_params     => io_params
            );
        end if;

        if i_dst_entity_type = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER then
            select customer_id into l_object_id from iss_card where id = i_object_id;
            load_customer_params(
                i_customer_id => l_object_id
              , io_params     => io_params
            );
        end if;
    elsif i_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        if i_dst_entity_type = prd_api_const_pkg.ENTITY_TYPE_CONTRACT then
            select contract_id into l_object_id from acc_account where id = i_object_id;
            load_contract_params(
                i_contract_id => l_object_id
              , io_params     => io_params
            );
        elsif i_dst_entity_type = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER then
            select customer_id into l_object_id from acc_account where id = i_object_id;
            load_customer_params(
                i_customer_id => l_object_id
              , io_params     => io_params
            );
        end if;
    elsif i_entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION then
        if i_dst_entity_type = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER then
            if i_party_type = com_api_const_pkg.PARTICIPANT_ACQUIRER then
                select c.customer_id
                  into l_object_id
                  from opr_participant o
                     , acq_merchant m
                     , prd_contract c
                 where o.oper_id = i_object_id
                   and o.participant_type = i_party_type
                   and m.id = o.merchant_id
                   and c.id = m.contract_id;
            elsif i_party_type = com_api_const_pkg.PARTICIPANT_ISSUER then
                select c.customer_id
                  into l_object_id
                  from opr_participant o
                     , iss_card c
                 where o.oper_id = i_object_id
                   and o.participant_type = i_party_type
                   and c.id = o.card_id;
            end if;
            load_customer_params(
                i_customer_id => l_object_id
              , io_params     => io_params
            );
        end if;
    elsif i_entity_type = aut_api_const_pkg.ENTITY_TYPE_AUTHORIZATION then
        if i_dst_entity_type = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER then
            if i_party_type = com_api_const_pkg.PARTICIPANT_ACQUIRER then
                select c.customer_id
                  into l_object_id
                  from opr_participant o
                     , acq_merchant m
                     , prd_contract c
                 where o.oper_id = i_object_id
                   and o.participant_type = i_party_type
                   and m.id = o.merchant_id
                   and c.id = m.contract_id;
            elsif i_party_type = com_api_const_pkg.PARTICIPANT_ISSUER then
                select c.customer_id
                  into l_object_id
                  from opr_participant o
                     , iss_card c
                 where o.oper_id = i_object_id
                   and o.participant_type = i_party_type
                   and c.id = o.card_id;
            end if;
            load_customer_params(
                i_customer_id => l_object_id
              , io_params     => io_params
            );
        end if;
    elsif i_entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL then
        if i_dst_entity_type = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER then
            select customer_id
              into l_object_id
              from acq_terminal t
                 , prd_contract c
             where t.id = i_object_id
               and c.id = t.contract_id;
            load_contract_params(
                i_contract_id => l_object_id
              , io_params     => io_params
            );
        end if;
    elsif i_entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT then
        if i_dst_entity_type = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER then
            select c.customer_id
              into l_object_id
              from acq_merchant m
                 , prd_contract c
             where m.id = i_object_id
               and c.id = m.contract_id;

            load_customer_params(
                i_customer_id => l_object_id
              , io_params     => io_params
            );
        end if;
    end if;
end load_linked_object_params;

procedure load_card_params(
    i_card               in            iss_api_type_pkg.t_card
  , i_card_instance      in            iss_api_type_pkg.t_card_instance
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
) is
begin
    rul_api_param_pkg.set_param(
        i_name    => 'CARD_TYPE_ID'
      , i_value   => i_card.card_type_id
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'CARD_CATEGORY'
      , i_value   => i_card.category
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'SEQ_NUMBER'
      , i_value   => i_card_instance.seq_number
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'STATUS'
      , i_value   => i_card_instance.status
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'STATE'
      , i_value   => i_card_instance.state
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'REISSUE_REASON'
      , i_value   => i_card_instance.reissue_reason
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'PERSO_PRIORITY'
      , i_value   => i_card_instance.perso_priority
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'PRECEDING_CARD_INSTANCE_ID'
      , i_value   => i_card_instance.preceding_card_instance_id
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'EXPIR_DATE'
      , i_value   => i_card_instance.expir_date
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'CARD_ID'
      , i_value   => i_card_instance.card_id
      , io_params => io_params
    );
end load_card_params;

procedure load_card_params(
    i_card_id            in            com_api_type_pkg.t_medium_id
  , i_seq_number         in            com_api_type_pkg.t_tiny_id       default null
  , i_expir_date         in            date                             default null
  , i_card_instance_id   in            com_api_type_pkg.t_medium_id     default null
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
) is
    l_instance_id                      com_api_type_pkg.t_medium_id;
begin
    l_instance_id :=
        coalesce(
            i_card_instance_id
          , iss_api_card_instance_pkg.get_card_instance_id(
                i_card_id    => i_card_id
              , i_seq_number => i_seq_number
              , i_expir_date => i_expir_date
            )
        );
    for rec in (
        select c.card_type_id
             , c.category
             , s.seq_number
             , s.status
             , s.state
             , s.reissue_reason
             , s.perso_priority
             , s.preceding_card_instance_id
             , s.expir_date
             , c.id card_id
          from iss_card c
             , iss_card_instance s
         where c.id = s.card_id
           and s.id = l_instance_id
    ) loop
        rul_api_param_pkg.set_param(
            i_name    => 'CARD_TYPE_ID'
          , i_value   => rec.card_type_id
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'CARD_CATEGORY'
          , i_value   => rec.category
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'SEQ_NUMBER'
          , i_value   => rec.seq_number
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'STATUS'
          , i_value   => rec.status
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'STATE'
          , i_value   => rec.state
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'REISSUE_REASON'
          , i_value   => rec.reissue_reason
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'PERSO_PRIORITY'
          , i_value   => rec.perso_priority
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'PRECEDING_CARD_INSTANCE_ID'
          , i_value   => rec.preceding_card_instance_id
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'EXPIR_DATE'
          , i_value   => rec.expir_date
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'CARD_ID'
          , i_value   => rec.card_id
          , io_params => io_params
        );
    end loop;
end load_card_params;

procedure load_non_own_card_params(
    i_participant    in      opr_api_type_pkg.t_oper_part_rec
  , io_params        in out  com_api_type_pkg.t_param_tab
) is
begin
    rul_api_param_pkg.set_param(
        i_name    => 'CARD_TYPE_ID'
      , i_value   => i_participant.card_type_id
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'ISS_COUNTRY'
      , i_value   => i_participant.card_country
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'SEQ_NUMBER'
      , i_value   => i_participant.card_seq_number
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'EXPIR_DATE'
      , i_value   => i_participant.card_expir_date
      , io_params => io_params  
    );
                    
    rul_api_param_pkg.set_param(
        i_name    => 'SERVICE_CODE'
      , i_value   => i_participant.card_service_code
      , io_params => io_params  
    );
                    
    rul_api_param_pkg.set_param(
        i_name    => 'CARD_NETWORK_ID'
      , i_value   => i_participant.card_network_id
      , io_params => io_params  
    );
                    
    rul_api_param_pkg.set_param(
        i_name    => 'CARD_INST_ID'
      , i_value   => i_participant.card_inst_id
      , io_params => io_params  
    );
end load_non_own_card_params;

procedure load_account_params(
    i_account_id         in            com_api_type_pkg.t_medium_id
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
  , i_usage              in            com_api_type_pkg.t_dict_value    default null
) is
begin
    for rec in (
        select account_type
             , status
             , currency
          from acc_account
         where id = i_account_id
    ) loop
        rul_api_param_pkg.set_param(
            i_name    => 'ACCOUNT_TYPE'
          , i_value   => rec.account_type
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'STATUS'
          , i_value   => rec.status
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'CURRENCY'
          , i_value   => rec.currency
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'ACCOUNT_CURRENCY'
          , i_value   => rec.currency
          , io_params => io_params
        );

        load_flexible_fields(
            i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id    => i_account_id
          , i_usage        => i_usage
          , io_params      => io_params
        );
    end loop;
end load_account_params;

procedure load_account_params(
    i_account            in            acc_api_type_pkg.t_account_rec
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
  , i_usage              in            com_api_type_pkg.t_dict_value    default null
) is
begin
    rul_api_param_pkg.set_param(
        i_name    => 'ACCOUNT_TYPE'
      , i_value   => i_account.account_type
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'STATUS'
      , i_value   => i_account.status
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'CURRENCY'
      , i_value   => i_account.currency
      , io_params => io_params
    );

    load_flexible_fields(
        i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id    => i_account.account_id
      , i_usage        => i_usage
      , io_params      => io_params
    );
end load_account_params;

procedure load_contract_params(
    i_contract_id        in            com_api_type_pkg.t_medium_id
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
) is
begin
    for rec in (
        select contract_type
             , start_date
             , end_date
             , product_id
      from prd_contract
     where id = i_contract_id
    ) loop
        rul_api_param_pkg.set_param(
            i_name    => 'CONTRACT_TYPE'
          , i_value   => rec.contract_type
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'START_DATE'
          , i_value   => rec.start_date
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'END_DATE'
          , i_value   => rec.end_date
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'CONTRACT_ID'
          , i_value   => i_contract_id
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'PRODUCT_ID'
          , i_value   => rec.product_id
          , io_params => io_params
        );
    end loop;
end load_contract_params;

procedure load_contract_params(
    i_contract           in            prd_api_type_pkg.t_contract
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
) is
begin
    rul_api_param_pkg.set_param(
        i_name    => 'CONTRACT_TYPE'
      , i_value   => i_contract.contract_type
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'START_DATE'
      , i_value   => i_contract.start_date
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'END_DATE'
      , i_value   => i_contract.end_date
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'CONTRACT_ID'
      , i_value   => i_contract.id
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'PRODUCT_ID'
      , i_value   => i_contract.product_id
      , io_params => io_params
    );
end load_contract_params;

procedure load_customer_params(
    i_customer_id        in            com_api_type_pkg.t_medium_id
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
  , i_usage              in            com_api_type_pkg.t_dict_value    default null
) is
begin
    for rec in (
        select nvl(ext_entity_type, entity_type) as entity_type
             , resident
             , nationality
             , category
             , relation
             , customer_number
          from prd_customer
         where id = i_customer_id
    ) loop
        rul_api_param_pkg.set_param(
            i_name    => 'CUSTOMER_ENTITY_TYPE'
          , i_value   => rec.entity_type
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'RESIDENT'
          , i_value   => rec.resident
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'NATIONALITY'
          , i_value   => rec.nationality
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'CUSTOMER_CATEGORY'
          , i_value   => rec.category
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'RELATION'
          , i_value   => rec.relation
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'CUSTOMER_NUMBER'
          , i_value   => rec.customer_number
          , io_params => io_params
        );

        load_flexible_fields(
            i_entity_type  => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
          , i_object_id    => i_customer_id
          , i_usage        => i_usage
          , io_params      => io_params
        );
    end loop;
end load_customer_params;

procedure load_customer_params(
    i_customer           in            prd_api_type_pkg.t_customer
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
  , i_usage              in            com_api_type_pkg.t_dict_value    default null
) is
begin
    rul_api_param_pkg.set_param(
        i_name    => 'CUSTOMER_ENTITY_TYPE'
      , i_value   => i_customer.entity_type
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'RESIDENT'
      , i_value   => i_customer.resident
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'NATIONALITY'
      , i_value   => i_customer.nationality
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'CUSTOMER_CATEGORY'
      , i_value   => i_customer.category
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'RELATION'
      , i_value   => i_customer.relation
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'CUSTOMER_NUMBER'
      , i_value   => i_customer.customer_number
      , io_params => io_params
    );

    load_flexible_fields(
        i_entity_type  => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
      , i_object_id    => i_customer.id
      , i_usage        => i_usage
      , io_params      => io_params
    );
end load_customer_params;

procedure load_extended_terminal_params(
    i_terminal_id        in            com_api_type_pkg.t_medium_id
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
) is
    l_address_rec                      com_api_type_pkg.t_address_rec;
begin
    trc_log_pkg.debug('rul_api_shared_data_pkg.load_extended_terminal_params - started');

    l_address_rec.id := acq_api_terminal_pkg.get_terminal_address_id(i_terminal_id =>  i_terminal_id);

    select a.country
         , a.region
         , a.city
         , a.street
         , a.house
         , a.apartment
      into l_address_rec.country
         , l_address_rec.region
         , l_address_rec.city
         , l_address_rec.street
         , l_address_rec.house
         , l_address_rec.apartment
      from com_address a
     where a.id  = l_address_rec.id;

    rul_api_param_pkg.set_param(
        i_name     => 'TERMINAL_COUNTRY'
      , i_value    => l_address_rec.country
      , io_params  => io_params
    );
    rul_api_param_pkg.set_param(
        i_name     => 'TERMINAL_REGION'
      , i_value    => l_address_rec.region
      , io_params  => io_params
    );
    rul_api_param_pkg.set_param(
        i_name     => 'TERMINAL_CITY'
      , i_value    => l_address_rec.city
      , io_params  => io_params
    );
    rul_api_param_pkg.set_param(
        i_name     => 'TERMINAL_STREET'
      , i_value    => l_address_rec.street
      , io_params  => io_params
    );
    rul_api_param_pkg.set_param(
        i_name     => 'TERMINAL_HOUSE'
      , i_value    => l_address_rec.house
      , io_params  => io_params
    );

    rul_api_param_pkg.set_param(
        i_name     => 'TERMINAL_APARTMENT'
      , i_value    => l_address_rec.apartment
      , io_params  => io_params
    );

exception
    when no_data_found then
        trc_log_pkg.debug(
            i_text        => 'load_extended_terminal_params - no_data_found, address_id [#1]'
          , i_env_param1  => l_address_rec.id
        );
end load_extended_terminal_params;

procedure load_terminal_params(
    i_terminal_id        in            com_api_type_pkg.t_medium_id
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
  , i_full_set           in            com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
) is
begin
    for rec in (
        select t.terminal_type
             , t.status
             , t.card_data_input_cap
             , t.crdh_auth_cap
             , t.card_capture_cap
             , t.term_operating_env
             , t.crdh_data_present
             , t.card_data_present
             , t.card_data_input_mode
             , t.crdh_auth_method
             , t.crdh_auth_entity
             , t.card_data_output_cap
             , t.term_data_output_cap
             , t.pin_capture_cap
             , t.cat_level
             , t.gmt_offset
             , t.is_mac
             , t.mcc
             , t.pos_batch_support
          from acq_terminal t
         where t.id = i_terminal_id
    ) loop
        rul_api_param_pkg.set_param(
            i_name    => 'TERMINAL_TYPE'
          , i_value   => rec.terminal_type
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'STATUS'
          , i_value   => rec.status
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'CARD_DATA_INPUT_CAP'
          , i_value   => rec.card_data_input_cap
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'CRDH_AUTH_CAP'
          , i_value   => rec.crdh_auth_cap
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'CARD_CAPTURE_CAP'
          , i_value   => rec.card_capture_cap
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'TERM_OPERATING_ENV'
          , i_value   => rec.term_operating_env
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'CRDH_DATA_PRESENT'
          , i_value   => rec.crdh_data_present
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'CARD_DATA_PRESENT'
          , i_value   => rec.card_data_present
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'CARD_DATA_INPUT_MODE'
          , i_value   => rec.card_data_input_mode
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'CRDH_AUTH_METHOD'
          , i_value   => rec.crdh_auth_method
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'CRDH_AUTH_ENTITY'
          , i_value   => rec.crdh_auth_entity
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'CARD_DATA_OUTPUT_CAP'
          , i_value   => rec.card_data_output_cap
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'TERM_DATA_OUTPUT_CAP'
          , i_value   => rec.term_data_output_cap
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'PIN_CAPTURE_CAP'
          , i_value   => rec.pin_capture_cap
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'CAT_LEVEL'
          , i_value   => rec.cat_level
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'GMT_OFFSET'
          , i_value   => rec.gmt_offset
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'IS_MAC'
          , i_value   => rec.is_mac
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'MCC'
          , i_value   => rec.mcc
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'POS_BATCH_SUPPORT'
          , i_value   => rec.pos_batch_support
          , io_params => io_params
        );

        if nvl(i_full_set, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE then
            load_extended_terminal_params(
                i_terminal_id => i_terminal_id
              , io_params     => io_params
            );
        end if;
    end loop;
end load_terminal_params;

procedure load_terminal_params(
    i_terminal           in            aap_api_type_pkg.t_terminal
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
  , i_full_set           in            com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
) is
begin
    rul_api_param_pkg.set_param(
        i_name    => 'TERMINAL_TYPE'
      , i_value   => i_terminal.terminal_type
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'STATUS'
      , i_value   => i_terminal.status
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'CARD_DATA_INPUT_CAP'
      , i_value   => i_terminal.card_data_input_cap
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'CRDH_AUTH_CAP'
      , i_value   => i_terminal.crdh_auth_cap
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'CARD_CAPTURE_CAP'
      , i_value   => i_terminal.card_capture_cap
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'TERM_OPERATING_ENV'
      , i_value   => i_terminal.term_operating_env
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'CRDH_DATA_PRESENT'
      , i_value   => i_terminal.crdh_data_present
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'CARD_DATA_PRESENT'
      , i_value   => i_terminal.card_data_present
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'CARD_DATA_INPUT_MODE'
      , i_value   => i_terminal.card_data_input_mode
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'CRDH_AUTH_METHOD'
      , i_value   => i_terminal.crdh_auth_method
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'CRDH_AUTH_ENTITY'
      , i_value   => i_terminal.crdh_auth_entity
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'CARD_DATA_OUTPUT_CAP'
      , i_value   => i_terminal.card_data_output_cap
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'TERM_DATA_OUTPUT_CAP'
      , i_value   => i_terminal.term_data_output_cap
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'PIN_CAPTURE_CAP'
      , i_value   => i_terminal.pin_capture_cap
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'CAT_LEVEL'
      , i_value   => i_terminal.cat_level
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'GMT_OFFSET'
      , i_value   => i_terminal.gmt_offset
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'IS_MAC'
      , i_value   => i_terminal.is_mac
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'MCC'
      , i_value   => i_terminal.mcc
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'POS_BATCH_SUPPORT'
      , i_value   => i_terminal.pos_batch_support
      , io_params => io_params
    );

    if nvl(i_full_set, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE then
        load_extended_terminal_params(
            i_terminal_id => i_terminal.id
          , io_params     => io_params
        );
    end if;
end load_terminal_params;

procedure load_merchant_params(
    i_merchant_id        in            com_api_type_pkg.t_medium_id
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
) is
begin
    for rec in (
        select mcc
             , merchant_type
             , status
             , merchant_name
             , risk_indicator
          from acq_merchant
         where id = i_merchant_id
    ) loop
        rul_api_param_pkg.set_param(
            i_name    => 'MCC'
          , i_value   => rec.mcc
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'MERCHANT_TYPE'
          , i_value   => rec.merchant_type
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'STATUS'
          , i_value   => rec.status
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'MERCHANT_NAME'
          , i_value   => rec.merchant_name
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'RISK_INDICATOR'
          , i_value   => rec.risk_indicator
          , io_params => io_params
        );
    end loop;
end;

procedure load_merchant_params(
    i_merchant           in            aap_api_type_pkg.t_merchant
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
) is
begin
    rul_api_param_pkg.set_param(
        i_name    => 'MCC'
      , i_value   => i_merchant.mcc
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'MERCHANT_TYPE'
      , i_value   => i_merchant.merchant_type
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'STATUS'
      , i_value   => i_merchant.status
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'MERCHANT_NAME'
      , i_value   => i_merchant.merchant_name
      , io_params => io_params
    );
end;

procedure save_oper_params(
    io_params              in out nocopy com_api_type_pkg.t_param_tab
  , i_msg_type             in            com_api_type_pkg.t_dict_value
  , i_oper_type            in            com_api_type_pkg.t_dict_value
  , i_sttl_type            in            com_api_type_pkg.t_dict_value
  , i_status               in            com_api_type_pkg.t_dict_value
  , i_status_reason        in            com_api_type_pkg.t_dict_value
  , i_terminal_type        in            com_api_type_pkg.t_dict_value
  , i_mcc                  in            com_api_type_pkg.t_mcc
  , i_oper_currency        in            com_api_type_pkg.t_dict_value
  , i_is_reversal          in            com_api_type_pkg.t_boolean
  , i_iss_card_network_id  in            com_api_type_pkg.t_network_id
  , i_match_status         in            com_api_type_pkg.t_dict_value
  , i_merchant_number      in            com_api_type_pkg.t_merchant_number
  , i_auth_resp_code       in            com_api_type_pkg.t_dict_value
  , i_acq_resp_code        in            com_api_type_pkg.t_dict_value
  , i_payment_order_id     in            com_api_type_pkg.t_long_id
) is
begin
    rul_api_param_pkg.set_param(
        i_name    => 'MSG_TYPE'
      , i_value   => i_msg_type
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'OPER_TYPE'
      , i_value   => i_oper_type
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'STTL_TYPE'
      , i_value   => i_sttl_type
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'OPERATION_STATUS'
      , i_value   => i_status
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'STATUS_REASON'
      , i_value   => i_status_reason
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'TERMINAL_TYPE'
      , i_value   => i_terminal_type
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'MCC'
      , i_value   => i_mcc
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'OPER_CURRENCY'
      , i_value   => i_oper_currency
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'IS_REVERSAL'
      , i_value   => i_is_reversal
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'ISS_CARD_NETWORK_ID'
      , i_value   => i_iss_card_network_id
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'MATCH_STATUS'
      , i_value   => i_match_status
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'MERCHANT_NUMBER'
      , i_value   => i_merchant_number
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'AUTH_RESP_CODE'
      , i_value   => i_auth_resp_code
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'ACQ_RESP_CODE'
      , i_value   => i_acq_resp_code
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'PAYMENT_ORDER_ID'
      , i_value   => i_payment_order_id
      , io_params => io_params
    );

end save_oper_params;

procedure load_oper_params(
    i_oper_id            in            com_api_type_pkg.t_long_id
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
) is
begin
    for rec in (
        select o.msg_type
             , o.oper_type
             , o.sttl_type
             , o.terminal_type
             , o.status
             , o.status_reason
             , o.mcc
             , o.oper_currency
             , o.is_reversal
             , i.card_network_id as iss_card_network_id
             , o.match_status
             , o.merchant_number
             , a.resp_code       as auth_resp_code
             , a.acq_resp_code
             , o.payment_order_id
          from opr_operation   o,
               opr_participant i,
               aut_auth        a
         where o.id                  = i_oper_id
           and i.oper_id(+)          = o.id
           and i.participant_type(+) = com_api_const_pkg.PARTICIPANT_ISSUER
           and o.id                  = a.id(+)
    ) loop
        save_oper_params(
            io_params              => io_params
          , i_msg_type             => rec.msg_type
          , i_oper_type            => rec.oper_type
          , i_sttl_type            => rec.sttl_type
          , i_status               => rec.status
          , i_status_reason        => rec.status_reason
          , i_terminal_type        => rec.terminal_type
          , i_mcc                  => rec.mcc
          , i_oper_currency        => rec.oper_currency
          , i_is_reversal          => rec.is_reversal
          , i_iss_card_network_id  => rec.iss_card_network_id
          , i_match_status         => rec.match_status
          , i_merchant_number      => rec.merchant_number
          , i_auth_resp_code       => rec.auth_resp_code
          , i_acq_resp_code        => rec.acq_resp_code
          , i_payment_order_id     => rec.payment_order_id
        );
    end loop;

    rul_cst_shared_data_pkg.load_oper_params(
        i_oper_id => i_oper_id
      , io_params => io_params
    );
end load_oper_params;

procedure load_payment_order_params(
    i_payment_order_id   in            com_api_type_pkg.t_long_id
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
) is
begin
    for rec in (
        select p.param_name
             , d.param_value
          from pmo_order_data d
             , pmo_parameter p
         where d.order_id = i_payment_order_id
           and d.param_id = p.id
    ) loop
        rul_api_param_pkg.set_param(
            i_name    => rec.param_name
          , i_value   => rec.param_value
          , io_params => io_params
        );
    end loop;

    for rec in (
        select o.purpose_id
             , o.attempt_count
          from pmo_order o
         where o.id = i_payment_order_id
    ) loop
        rul_api_param_pkg.set_param(
            i_name    => 'PURPOSE_ID'
          , i_value   => rec.purpose_id
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'ATTEMPT_COUNT'
          , i_value   => rec.attempt_count
          , io_params => io_params
        );
    end loop;
end;

procedure load_object(
    i_entity_type        in            com_api_type_pkg.t_dict_value
  , i_object_id          in            com_api_type_pkg.t_long_id
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
) is
begin
    if rul_api_param_pkg.get_param_num(
           i_name       => 'OBJECT_ID'
         , io_params    => io_params
         , i_mask_error => com_api_const_pkg.TRUE
       ) is null
    then
        rul_api_param_pkg.set_param(
            i_name    => 'OBJECT_ID'
          , i_value   => i_object_id
          , io_params => io_params
        );
    end if;

    if rul_api_param_pkg.get_param_char(
           i_name       => 'ENTITY_TYPE'
         , io_params    => io_params
         , i_mask_error => com_api_const_pkg.TRUE
       ) is null
    then
        rul_api_param_pkg.set_param(
            i_name    => 'ENTITY_TYPE'
          , i_value   => i_entity_type
          , io_params => io_params
        );
    end if;
end;

procedure load_application_params(
    i_application        in            app_api_type_pkg.t_application_rec
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
) is
begin
    rul_api_param_pkg.set_param(
        i_name    => 'APPLICATION_TYPE'
      , i_value   => i_application.appl_type
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'APPL_PRIORITIZED'
      , i_value   => i_application.appl_prioritized
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'APPLICATION_STATUS'
      , i_value   => i_application.appl_status
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'APPLICATION_REJECT_CODE'
      , i_value   => i_application.reject_code
      , io_params => io_params
    );
end;

procedure load_application_params(
    i_application_id     in            com_api_type_pkg.t_long_id
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
) is
begin
    for rec in (
        select a.appl_type
             , a.appl_prioritized
             , a.appl_status
             , a.reject_code
          from app_application a
         where a.id = i_application_id
    ) loop
        rul_api_param_pkg.set_param(
            i_name    => 'APPLICATION_TYPE'
          , i_value   => rec.appl_type
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'APPL_PRIORITIZED'
          , i_value   => rec.appl_prioritized
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'APPLICATION_STATUS'
          , i_value   => rec.appl_status
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'APPLICATION_REJECT_CODE'
          , i_value   => rec.reject_code
          , io_params => io_params
        );
    end loop;
end;

procedure load_invoice_params(
    i_invoice_id         in            com_api_type_pkg.t_medium_id
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
) is
    l_invoice                          crd_api_type_pkg.t_invoice_rec;
begin
    l_invoice :=
        crd_invoice_pkg.get_invoice(
            i_invoice_id => i_invoice_id
          , i_mask_error => com_api_const_pkg.TRUE
        );

    rul_api_param_pkg.set_param(
        i_name    => 'INVOICE_ID'
      , i_value   => l_invoice.id
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'AGING_PERIOD'
      , i_value   => l_invoice.aging_period
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'IS_TAD_PAID'
      , i_value   => l_invoice.is_tad_paid
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'IS_MAD_PAID'
      , i_value   => l_invoice.is_mad_paid
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'INVOICE_START_DATE'
      , i_value   => l_invoice.start_date
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'INVOICE_DATE'
      , i_value   => l_invoice.invoice_date
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'GRACE_DATE'
      , i_value   => l_invoice.grace_date
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'DUE_DATE'
      , i_value   => l_invoice.due_date
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'OVERDUE_DATE'
      , i_value   => l_invoice.overdue_date
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'TOTAL_AMOUNT_DUE'
      , i_value   => l_invoice.total_amount_due
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'MIN_AMOUNT_DUE'
      , i_value   => l_invoice.min_amount_due
      , io_params => io_params
    );
end load_invoice_params;

procedure load_entry_params(
    i_entry_id           in            com_api_type_pkg.t_long_id
  , io_params            in out nocopy com_api_type_pkg.t_param_tab
) is
begin
    trc_log_pkg.debug(
        i_text       => 'load_entry_params: load for entry [#1]'
      , i_env_param1 => i_entry_id
    );

    for tab in (
        select balance_type
             , balance_impact
             , macros_type_id
             , transaction_type
          from acc_entry e
          left join acc_macros m on e.macros_id = m.id
           and m.entity_type = acc_api_const_pkg.ENTITY_TYPE_MACROS
         where e.id = i_entry_id
    )
    loop
        rul_api_param_pkg.set_param(
            i_name    => 'BALANCE_TYPE'
          , i_value   => tab.balance_type
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'MACROS_TYPE'
          , i_value   => tab.macros_type_id
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'TRANSACTION_TYPE'
          , i_value   => tab.transaction_type
          , io_params => io_params
        );
        rul_api_param_pkg.set_param(
            i_name    => 'BALANCE_IMPACT'
          , i_value   => tab.balance_impact
          , io_params => io_params
        );
    end loop;
end load_entry_params;

procedure load_flexible_fields(
    i_entity_type  in            com_api_type_pkg.t_dict_value
  , i_object_id    in            com_api_type_pkg.t_long_id
  , i_usage        in            com_api_type_pkg.t_dict_value
  , io_params      in out nocopy com_api_type_pkg.t_param_tab
) is
begin
    if i_usage is not null
        and com_api_flexible_data_pkg.get_usage(
                i_usage        => i_usage
              , i_entity_type  => i_entity_type
            ) = com_api_const_pkg.TRUE then

        for rec in (select f.name
                         , case f.data_type
                               when com_api_const_pkg.DATA_TYPE_NUMBER then to_char(d.field_value, com_api_const_pkg.NUMBER_FORMAT)
                               when com_api_const_pkg.DATA_TYPE_DATE   then to_char(d.field_value, com_api_const_pkg.DATE_FORMAT)
                               else d.field_value
                            end as field_value
                      from com_flexible_field       f
                         , com_flexible_field_usage u
                         , com_flexible_data        d
                     where f.entity_type = i_entity_type
                       and f.id          = u.field_id
                       and (u.usage      = i_usage or i_usage = com_api_const_pkg.FLEXIBLE_FIELD_PROC_ALL)
                       and f.id          = d.field_id
                       and d.object_id   = i_object_id)
        loop
            io_params(rec.name) := rec.field_value;
        end loop;

    end if;

end load_flexible_fields;

procedure load_id_object_params(
    i_id           in      com_api_type_pkg.t_long_id
) is
    l_param_tab         com_api_type_pkg.t_param_tab;
begin
    for rec in (
        select cu.id
             , cu.inst_id
             , cu.split_hash
             , pd.id as product_id
             , pd.product_type
             , cn.contract_type
             , io.entity_type
          from com_id_object io
             , prd_customer cu
             , prd_contract cn
             , prd_product pd
         where io.id          = i_id
           and cu.entity_type = io.entity_type
           and cu.object_id   = io.object_id
           and cn.id          = cu.contract_id
           and pd.id          = cn.product_id
    ) loop
        rul_api_param_pkg.set_param(
            i_name    => 'PRODUCT_ID'
          , i_value   => rec.product_id
          , io_params => l_param_tab
        );
        rul_api_param_pkg.set_param(
            i_name    => 'PRODUCT_TYPE'
          , i_value   => rec.product_type
          , io_params => l_param_tab
        );
        rul_api_param_pkg.set_param(
            i_name    => 'SRC_ENTITY_TYPE'
          , i_value   => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
          , io_params => l_param_tab
        );
        rul_api_param_pkg.set_param(
            i_name    => 'SRC_OBJECT_ID'
          , i_value   => rec.id
          , io_params => l_param_tab
        );
        rul_api_param_pkg.set_param(
            i_name    => 'CONTRACT_TYPE'
          , i_value   => rec.contract_type
          , io_params => l_param_tab
        );
        rul_api_param_pkg.set_param(
            i_name    => 'ENTITY_TYPE'
          , i_value   => rec.entity_type
          , io_params => l_param_tab
        );
    end loop;

end load_id_object_params;

procedure load_dpp_params(
    i_dpp_id               in            com_api_type_pkg.t_long_id
  , io_params              in out nocopy com_api_type_pkg.t_param_tab
) is
    l_dpp_rec                            dpp_api_type_pkg.t_dpp;
begin
    trc_log_pkg.debug(
        i_text       => 'load_dpp_params: i_dpp_id [#1]'
      , i_env_param1 => i_dpp_id
    );

    l_dpp_rec := dpp_api_payment_plan_pkg.get_dpp(
                     i_dpp_id     => i_dpp_id
                   , i_mask_error => com_api_const_pkg.TRUE
                 );

    rul_api_param_pkg.set_param(
        i_name    => 'ORIGINAL_OPERATION_ID'
      , i_value   => l_dpp_rec.oper_id
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'OPERATION_ID'
      , i_value   => l_dpp_rec.reg_oper_id
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'INSTALMENT_COUNT'
      , i_value   => l_dpp_rec.instalment_total
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'INSTALMENT_AMOUNT'
      , i_value   => l_dpp_rec.instalment_amount
      , io_params => io_params
    );
    rul_api_param_pkg.set_param(
        i_name    => 'DPP_ALGORITHM'
      , i_value   => l_dpp_rec.dpp_algorithm
      , io_params => io_params
    );
end load_dpp_params;

procedure load_document_params(
    i_documnet_id          in            com_api_type_pkg.t_long_id
  , io_params              in out nocopy com_api_type_pkg.t_param_tab
) is
    l_document_rec                       rpt_api_type_pkg.t_document_rec;
begin
    trc_log_pkg.debug(
        i_text       => 'load_document_params: i_documnet_id [#1]'
      , i_env_param1 => i_documnet_id
    );

    l_document_rec := rpt_api_document_pkg.get_document(
                          i_document_id   => i_documnet_id
                        , i_content_type  => rpt_api_const_pkg.CONTENT_TYPE_PRINT_FORM
                      );

    rul_api_param_pkg.set_param(
        i_name    => 'DOCUMENT_TYPE'
      , i_value   => l_document_rec.document_type
      , io_params => io_params
    );

    rul_api_param_pkg.set_param(
        i_name    => 'START_DATE'
      , i_value   => l_document_rec.start_date
      , io_params => io_params
    );

    rul_api_param_pkg.set_param(
        i_name    => 'END_DATE'
      , i_value   => l_document_rec.end_date
      , io_params => io_params
    );

    rul_api_param_pkg.set_param(
        i_name    => 'ENTITY_TYPE'
      , i_value   => l_document_rec.entity_type
      , io_params => io_params
    );

    rul_api_param_pkg.set_param(
        i_name    => 'OBJECT_ID'
      , i_value   => l_document_rec.object_id
      , io_params => io_params
    );

end load_document_params;

end rul_api_shared_data_pkg;
/
