create or replace package body cst_api_opr_rule_pkg is
/*********************************************************
 *  Custom event processing API for Woori <br />
 **********************************************************/

procedure select_default_account
is
    l_account                       acc_api_type_pkg.t_account_rec;
    l_account_name                  com_api_type_pkg.t_name;
    l_party_type                    com_api_type_pkg.t_dict_value;
    l_entity_type                   com_api_type_pkg.t_name;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_account_number                com_api_type_pkg.t_account_number;
    l_participant_rec               opr_api_type_pkg.t_oper_part_rec;
    l_acc_object_id                 com_api_type_pkg.t_long_id;
    l_oper_id                       com_api_type_pkg.t_long_id;
begin
    l_account_name := opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME');
    l_entity_type  := opr_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_party_type   := opr_api_shared_data_pkg.get_param_char(
                          i_name          => 'PARTY_TYPE'
                        , i_mask_error    => get_true
                        , i_error_value   => com_api_const_pkg.PARTICIPANT_ISSUER
                      );
    l_party_type := nvl(l_party_type, com_api_const_pkg.PARTICIPANT_ISSUER);

    l_participant_rec := opr_api_shared_data_pkg.get_participant(i_participant_type => l_party_type);

    l_object_id := opr_api_shared_data_pkg.get_object_id(
                       i_entity_type     => l_entity_type
                     , i_account_name    => l_account_name
                     , i_party_type      => l_party_type
                     , o_account_number  => l_account_number
                   );
    l_oper_id   := opr_api_shared_data_pkg.get_operation().id;

    begin
        select f.object_id
          into l_acc_object_id
          from com_flexible_data  f
             , acc_account_object ao
         where ao.object_id   = l_object_id
           and ao.account_id  = f.object_id
           and f.field_value  = 'ACSD0001'
           and rownum         = 1
         order by f.id;

    exception
        when no_data_found then
            trc_log_pkg.debug('No default account is set in the flexible field.');
            select ao.account_id
              into l_acc_object_id
              from acc_account_object ao
             where ao.object_id = l_object_id
               and rownum = 1
             order by ao.id;
    end;

    select id
         , split_hash
         , account_type
         , account_number
         , currency
         , inst_id
         , agent_id
         , status
         , contract_id
         , customer_id
         , scheme_id
      into l_account.account_id
         , l_account.split_hash
         , l_account.account_type
         , l_account.account_number
         , l_account.currency
         , l_account.inst_id
         , l_account.agent_id
         , l_account.status
         , l_account.contract_id
         , l_account.customer_id
         , l_account.scheme_id  
      from acc_account
     where id = l_acc_object_id;

    trc_log_pkg.debug(
        i_text          => 'default_account_object is set '
      , i_env_param1    => l_acc_object_id
    );

    opr_api_shared_data_pkg.set_account(
        i_name              => opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME')
      , i_account_rec       => l_account
    );
    
    update opr_participant
       set account_id              = l_account.account_id
         , account_number          = l_account.account_number
     where oper_id                 = l_oper_id
       and participant_type        = l_party_type;

    l_participant_rec.account_number    := l_account.account_number;
    l_participant_rec.account_id        := l_account.account_id;
    opr_api_shared_data_pkg.set_participant(l_participant_rec);
exception
  when no_data_found then
      trc_log_pkg.debug(
          i_text          => 'No data found, so no account param is loaded!'
      );
end;

procedure load_credit_debit_flag
is
    l_account_name              com_api_type_pkg.t_name;
    l_credit_service_id         com_api_type_pkg.t_long_id;
    l_account_rec               acc_api_type_pkg.t_account_rec;
begin
    l_account_name := opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME');

    opr_api_shared_data_pkg.get_account(
        i_name              => l_account_name
      , o_account_rec       => l_account_rec
      , i_mask_error        => com_api_const_pkg.FALSE
      , i_error_value       => null
    );
        
    l_credit_service_id :=  
        prd_api_service_pkg.get_active_service_id(
            i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => l_account_rec.account_id
          , i_attr_name         => null
          , i_service_type_id   => crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
          , i_split_hash        => l_account_rec.split_hash
          , i_eff_date          => com_api_sttl_day_pkg.get_calc_date(i_inst_id => l_account_rec.inst_id)
          , i_mask_error        => com_api_const_pkg.TRUE
          , i_inst_id           => l_account_rec.inst_id
        );
        
    opr_api_shared_data_pkg.set_param(
        i_name   => 'CST_CREDIT_DEBIT_FLAG'
      , i_value  => case
                        when l_credit_service_id is not null
                        then com_api_const_pkg.TRUE
                        else com_api_const_pkg.FALSE
                    end
    );
end;

procedure load_loyalty_flag
is
    l_party_type                com_api_type_pkg.t_dict_value := com_api_const_pkg.PARTICIPANT_ISSUER;
    l_loyalty_service_id        com_api_type_pkg.t_long_id;
    l_card_id                   com_api_type_pkg.t_medium_id;
    l_product_id                com_api_type_pkg.t_long_id;
    l_cardholder_birthday       date;
    l_birthday_flag             com_api_type_pkg.t_boolean;
    l_param_tab                 com_api_type_pkg.t_param_tab;
begin
    l_card_id := opr_api_shared_data_pkg.get_participant(i_participant_type => l_party_type).card_id ;

    l_loyalty_service_id :=  
        prd_api_service_pkg.get_active_service_id(
            i_entity_type       => iss_api_const_pkg.ENTITY_TYPE_CARD
          , i_object_id         => l_card_id
          , i_attr_name         => lty_api_const_pkg.LOYALTY_ATTR_ACC_TYPE
          , i_service_type_id   => lty_api_const_pkg.LOYALTY_SERVICE_TYPE_ID
          , i_eff_date          => com_api_sttl_day_pkg.get_calc_date(i_inst_id => null)
          , i_mask_error        => com_api_const_pkg.TRUE
        );
        
    rul_api_param_pkg.set_param(
        i_value                 => l_loyalty_service_id
      , i_name                  => 'CST_LOYALTY_SERVICE_ID'
      , io_params               => opr_api_shared_data_pkg.g_params
    );      
        
    rul_api_param_pkg.set_param(
        i_value                 => case when l_loyalty_service_id is not null then com_api_const_pkg.TRUE else com_api_const_pkg.FALSE end
      , i_name                  => 'CST_LOYALTY_FLAG'
      , io_params               => opr_api_shared_data_pkg.g_params
    );
    
    trc_log_pkg.debug(
        i_text          => 'Loyaty service ID [#1]:  '
      , i_env_param1    => l_loyalty_service_id
    );
    
    if l_loyalty_service_id is not null then
       
        l_product_id := prd_api_product_pkg.get_product_id(
            i_entity_type       => iss_api_const_pkg.ENTITY_TYPE_CARD
          , i_object_id         => l_card_id
        );     
      
        l_cardholder_birthday := 
            prd_api_product_pkg.get_attr_value_date(
                i_product_id    => l_product_id
              , i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD
              , i_object_id     => l_card_id
              , i_attr_name     => 'CST_CARDHOLDER_BIRTHDAY'
              , i_service_id    => l_loyalty_service_id
              , i_params        => l_param_tab
              , i_eff_date      => get_sysdate()
              , i_inst_id       => null 
            );

        l_birthday_flag := case when to_char(get_sysdate(), 'DD/MM') = to_char(l_cardholder_birthday, 'DD/MM')
                           then com_api_const_pkg.TRUE
                           else com_api_const_pkg.FALSE
                           end;

        opr_api_shared_data_pkg.set_param(
            i_name   => 'CST_BIRTHDAY_FLAG'
          , i_value  => l_birthday_flag
        );
 
        trc_log_pkg.debug(
            i_text          => 'Birthday [#1] [#2]:'
          , i_env_param1    => l_cardholder_birthday
          , i_env_param2    => l_birthday_flag
        );
    end if;
end;

procedure select_linked_account
is
    l_account                       acc_api_type_pkg.t_account_rec;
    l_source_account                acc_api_type_pkg.t_account_rec;
    l_account_name                  com_api_type_pkg.t_name;
    l_dest_account_name             com_api_type_pkg.t_name;
    l_account_type                  com_api_type_pkg.t_dict_value;
    l_linked_account_id             com_api_type_pkg.t_long_id;
begin
    l_account_name      := opr_api_shared_data_pkg.get_param_char('ACCOUNT_NAME');
    l_account_type      := opr_api_shared_data_pkg.get_param_char('ACCOUNT_TYPE');
    l_dest_account_name := opr_api_shared_data_pkg.get_param_char('DESTINATION_ACCOUNT_NAME');
    
    opr_api_shared_data_pkg.get_account(
        i_name              => l_account_name 
      , o_account_rec       => l_source_account
    );
    
    select id
      into l_linked_account_id
      from acc_account 
     where account_type = l_account_type
       and id in (select account_id
                    from acc_account_object
                   where object_id = (select ao.object_id
                                        from acc_account_object ao
                                       where ao.account_id = l_source_account.account_id
                                     )
                 );
           
    select id
         , split_hash
         , account_type
         , account_number
         , currency
         , inst_id
         , agent_id
         , status
         , contract_id
         , customer_id
         , scheme_id
      into l_account.account_id
         , l_account.split_hash
         , l_account.account_type
         , l_account.account_number
         , l_account.currency
         , l_account.inst_id
         , l_account.agent_id
         , l_account.status
         , l_account.contract_id
         , l_account.customer_id
         , l_account.scheme_id  
      from acc_account
     where id = l_linked_account_id;

    trc_log_pkg.debug(
        i_text          => 'Linked acount id: [#1] '
      , i_env_param1    => l_linked_account_id
    );

    opr_api_shared_data_pkg.set_account(
        i_name              => opr_api_shared_data_pkg.get_param_char('DESTINATION_ACCOUNT_NAME')
      , i_account_rec       => l_account
    );
exception
    when no_data_found then
        trc_log_pkg.error(
            i_text          => 'No account with type [#1]'
          , i_env_param1    => l_account_type
        ); 
end;

procedure get_contract_type is
    l_card_id               com_api_type_pkg.t_medium_id;
    l_contract_type         com_api_type_pkg.t_dict_value;
begin
    l_card_id := opr_api_shared_data_pkg.get_participant(i_participant_type => com_api_const_pkg.PARTICIPANT_ISSUER).card_id;

    select t.contract_type 
      into l_contract_type
      from iss_card        c
         , prd_contract    t 
     where c.id     = l_card_id
       and t.id     = c.contract_id  
         ;

    opr_api_shared_data_pkg.set_param(
        i_name   => 'CONTRACT_TYPE'
      , i_value  => l_contract_type
    );

exception
    when no_data_found then
        trc_log_pkg.error(
            i_text          => 'No contract_type for card_id [#1]'
          , i_env_param1    => l_card_id
        ); 
end get_contract_type;

procedure load_credit_debit_flag_by_card
is
    l_card_id                   com_api_type_pkg.t_medium_id;
    l_credit_service_id         com_api_type_pkg.t_long_id;
begin
    l_card_id := opr_api_shared_data_pkg.get_participant(i_participant_type => com_api_const_pkg.PARTICIPANT_ISSUER).card_id;

    for r in (
        select o.account_id 
             , a.split_hash
             , a.inst_id
          from acc_account_object o
             , acc_account a
         where o.object_id   = l_card_id
           and o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
           and o.account_id  = a.id
           and a.status     != acc_api_const_pkg.ACCOUNT_STATUS_CLOSED        
    ) loop
    
        l_credit_service_id :=  
            prd_api_service_pkg.get_active_service_id(
                i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id         => r.account_id
              , i_attr_name         => null
              , i_service_type_id   => crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
              , i_split_hash        => r.split_hash
              , i_eff_date          => com_api_sttl_day_pkg.get_calc_date(i_inst_id => r.inst_id)
              , i_mask_error        => com_api_const_pkg.TRUE
              , i_inst_id           => r.inst_id
            );
    
        if l_credit_service_id is not null then
            
            exit;
        end if;
            
    end loop;

    opr_api_shared_data_pkg.set_param(
        i_name   => 'CST_CREDIT_DEBIT_FLAG'
      , i_value  => case
                        when l_credit_service_id is not null
                        then com_api_const_pkg.TRUE
                        else com_api_const_pkg.FALSE
                    end
    );
end;

end cst_api_opr_rule_pkg;
/
