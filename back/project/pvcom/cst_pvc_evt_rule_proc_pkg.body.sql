create or replace package body cst_pvc_evt_rule_proc_pkg as

function get_max_invoice_aging 
return com_api_type_pkg.t_tiny_id
is
    l_result                com_api_type_pkg.t_tiny_id;  
    l_object_id             com_api_type_pkg.t_long_id;
    l_entity_type           com_api_type_pkg.t_name;
    l_account_id            com_api_type_pkg.t_long_id;  
    l_split_hash            com_api_type_pkg.t_tiny_id;  
begin
    l_entity_type   := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_object_id     := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');    
    l_split_hash    := com_api_hash_pkg.get_split_hash (
                           i_entity_type    => l_entity_type
                         , i_object_id      => l_object_id
                         , i_mask_error     => com_api_const_pkg.TRUE
                       );
                    
    trc_log_pkg.debug (
        i_text          => 'Start getting max invoice aging, entity type [#1], object id [#2], split_hash [#3]'
      , i_env_param1    => l_entity_type
      , i_env_param2    => l_object_id
      , i_env_param3    => l_split_hash
    );

    if l_entity_type = crd_api_const_pkg.ENTITY_TYPE_INVOICE then
        begin
            select account_id
              into l_account_id
              from crd_invoice
             where id = l_object_id
               and split_hash = l_split_hash;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error         => 'ENTITY_TYPE_NOT_FOUND'
                  , i_env_param1    => l_object_id
                );
        end;
    elsif l_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        l_account_id := l_object_id;
    else
        l_account_id := l_object_id;
    end if;

    select max(ca.aging_period) 
      into l_result
      from crd_aging ca
         , crd_invoice ci
     where ca.invoice_id = ci.id
       and ca.split_hash = ci.split_hash
       and ca.split_hash in (select split_hash from com_api_split_map_vw)
       and ca.split_hash = l_split_hash
       and ci.account_id = l_account_id
       ;

    trc_log_pkg.debug (
        i_text          => 'Return max invoice aging [#1], entity type [#2], object id [#3]'
      , i_env_param1    => l_result
      , i_env_param2    => l_entity_type
      , i_env_param3    => l_object_id
    );

    return l_result;
end get_max_invoice_aging;

procedure get_unpaid_mad_amount is
    l_object_id                 com_api_type_pkg.t_long_id;
    l_entity_type               com_api_type_pkg.t_dict_value;
    l_account_id                com_api_type_pkg.t_medium_id;
    l_account                   acc_api_type_pkg.t_account_rec;
    l_split_hash                com_api_type_pkg.t_tiny_id;
    l_min_amount_due            com_api_type_pkg.t_money;
    l_event_date                date;
    l_total_payment_amount      com_api_type_pkg.t_money;
    l_last_invoice              crd_api_type_pkg.t_invoice_rec;
    l_min_amount_due_unpaid     com_api_type_pkg.t_money := 0;
begin

    l_object_id   := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');
    l_entity_type := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_event_date  := evt_api_shared_data_pkg.get_param_date('EVENT_DATE');

    if l_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        l_account_id := l_object_id;

    else
        com_api_error_pkg.raise_error(
            i_error       => 'ENTITY_TYPE_NOT_SUPPORTED'
          , i_env_param1  => l_entity_type
        );
    end if;

    l_account :=
        acc_api_account_pkg.get_account(
            i_account_id => l_account_id
          , i_mask_error => com_api_const_pkg.FALSE
        );

    l_last_invoice :=
        crd_invoice_pkg.get_last_invoice(
            i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id     => l_account_id
          , i_split_hash    => l_account.split_hash
          , i_mask_error    => com_api_const_pkg.TRUE
        );

    select nvl(sum(p.amount), 0)
      into l_total_payment_amount
      from crd_payment p
     where decode(p.is_new, 1, p.account_id, null) = l_account_id
       and posting_date <= l_event_date
       and split_hash = l_account.split_hash
       and is_reversal = com_api_const_pkg.FALSE
       and not exists (select 1
                         from dpp_payment_plan d
                        where d.reg_oper_id  = p.oper_id
                          and d.split_hash   = p.split_hash
                      );

    l_min_amount_due_unpaid := greatest(0, nvl(l_last_invoice.min_amount_due, 0) - l_total_payment_amount);

    trc_log_pkg.debug(
        i_text       => 'Unpaid mad amount for object [#1] [#2] on event_date [#3] is [#4]'
      , i_env_param1 => l_entity_type
      , i_env_param2 => l_object_id
      , i_env_param3 => l_event_date
      , i_env_param4 => l_min_amount_due_unpaid
    );

    evt_api_shared_data_pkg.set_amount(
        i_name      => evt_api_shared_data_pkg.get_param_char('RESULT_AMOUNT_NAME')
      , i_amount    => l_min_amount_due_unpaid
      , i_currency  => l_account.currency
    );

end get_unpaid_mad_amount;

end cst_pvc_evt_rule_proc_pkg;
/
