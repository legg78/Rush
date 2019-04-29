create or replace package body cst_cfc_com_pkg as

function get_substr(
    i_string                in  com_api_type_pkg.t_text
  , i_position              in  com_api_type_pkg.t_tiny_id
  , i_delimiter             in  com_api_type_pkg.t_tag default ','
) return com_api_type_pkg.t_text
is
  l_subtr                   com_api_type_pkg.t_text    := '';
  l_deli_count              com_api_type_pkg.t_tiny_id := 0;
begin
    select length(i_string) - length(replace(i_string, i_delimiter, null))
      into l_deli_count
      from dual;

    case
      when i_position = 1 then
        select substr(i_string, 1, instr(i_string, i_delimiter, 1, 1) - 1)
          into l_subtr
          from dual;
      when i_position = l_deli_count + 1 then
        select substr(i_string, instr(i_string, i_delimiter, 1, i_position - 1) + 1
                     , length(i_string) - instr(i_string, i_delimiter, 1, i_position - 1))
          into l_subtr
          from dual;
      when (i_position > 1 and i_position <= l_deli_count + 1) then
        select substr(i_string, instr(i_string, i_delimiter, 1, i_position - 1) + 1
                     , instr(i_string, i_delimiter, 1, i_position)
                     - instr(i_string, i_delimiter, 1, i_position - 1) - 1)
          into l_subtr
          from dual;
      else
        l_subtr := null;
    end case;

    return l_subtr;
exception
    when others then
        null;
end get_substr;

function get_account_reg_date(
    i_account_id            in  com_api_type_pkg.t_account_id
) return date deterministic
is
    l_reg_date              date;
begin
    select min(change_date)
      into l_reg_date
      from evt_status_log
     where event_type       = acc_api_const_pkg.EVENT_ACCOUNT_CREATION
       and object_id        = i_account_id
       and entity_type      = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT;

    return l_reg_date;
end get_account_reg_date;

function get_first_trx_date(
    i_entity_type           in  com_api_type_pkg.t_dict_value
  , i_object_id             in  com_api_type_pkg.t_long_id
  , i_transaction_type      in  com_api_type_pkg.t_dict_value    default null
)return date deterministic
is
    l_first_date            date;
    l_account_id_tab        num_tab_tpt := num_tab_tpt();
    l_card_id_tab           num_tab_tpt := num_tab_tpt();
begin
    case i_entity_type
    when com_api_const_pkg.ENTITY_TYPE_CUSTOMER then
        select id
          bulk collect into l_account_id_tab
          from acc_account a
         where a.customer_id    = i_object_id;

        select id
          bulk collect into l_card_id_tab
          from iss_card c
         where c.customer_id    = i_object_id;

    when iss_api_const_pkg.ENTITY_TYPE_CARD then
        select a.id
          bulk collect into l_account_id_tab
          from acc_account a
             , acc_account_object ao
         where ao.account_id    = a.id
           and ao.entity_type   = iss_api_const_pkg.ENTITY_TYPE_CARD
           and ao.object_id     = i_object_id;

        l_card_id_tab.extend();
        l_card_id_tab(1) :=  i_object_id;

    when acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        select object_id
          bulk collect into l_card_id_tab
          from acc_account_object
         where entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD
           and account_id   = i_object_id;

        l_account_id_tab.extend();
        l_account_id_tab(1) :=  i_object_id;
    end case;

    select min(opr.oper_date)
      into l_first_date
      from opr_operation            opr
         , opr_participant          opp
     where opr.id                   = opp.oper_id
       and opr.oper_type            = nvl(i_transaction_type, opr.oper_type)
       and opr.status               = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
       and opp.participant_type     = com_api_const_pkg.PARTICIPANT_ISSUER
       and (case when (i_transaction_type in (opr_api_const_pkg.OPERATION_TYPE_ATM_CASH, opr_api_const_pkg.OPERATION_TYPE_PURCHASE)
                      and opp.card_id in (select column_value from table(cast(l_card_id_tab as num_tab_tpt)))
                      and i_transaction_type = opr.oper_type)
                 then 1
                 when (opr.oper_type = nvl(i_transaction_type, opr.oper_type)
                      and (opp.card_id in (select column_value from table(cast(l_card_id_tab as num_tab_tpt)))
                           or
                           opp.account_id in (select column_value from table(cast(l_account_id_tab as num_tab_tpt)))))
                 then 1
                 else 0
            end
           ) = 1
       and opr.is_reversal = 0
       and not exists (select 1
                         from opr_operation
                        where original_id = opr.id
                          and is_reversal = 1);
    return l_first_date;
end get_first_trx_date;

function get_last_trx_date(
    i_entity_type           in  com_api_type_pkg.t_dict_value
  , i_object_id             in  com_api_type_pkg.t_long_id
  , i_transaction_type      in  com_api_type_pkg.t_dict_value    default null
)return date
is
    l_last_date             date;
    l_account_id_tab        num_tab_tpt := num_tab_tpt();
    l_card_id_tab           num_tab_tpt := num_tab_tpt();
begin
    case i_entity_type
    when com_api_const_pkg.ENTITY_TYPE_CUSTOMER then
        select id
          bulk collect into l_account_id_tab
          from acc_account a
         where a.customer_id    = i_object_id;

        select id
          bulk collect into l_card_id_tab
          from iss_card c
         where c.customer_id    = i_object_id;

    when iss_api_const_pkg.ENTITY_TYPE_CARD then
        select a.id
          bulk collect into l_account_id_tab
          from acc_account a
             , acc_account_object ao
         where ao.account_id    = a.id
           and ao.entity_type   = iss_api_const_pkg.ENTITY_TYPE_CARD
           and ao.object_id     = i_object_id;

        l_card_id_tab.extend();
        l_card_id_tab(1) :=  i_object_id;

    when acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        select object_id
          bulk collect into l_card_id_tab
          from acc_account_object
         where entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD
           and account_id   = i_object_id;

        l_account_id_tab.extend();
        l_account_id_tab(1) :=  i_object_id;
    end case;

    select max(opr.oper_date)
      into l_last_date
      from opr_operation            opr
         , opr_participant          opp
     where opr.id                   = opp.oper_id
       and opr.oper_type            = nvl(i_transaction_type, opr.oper_type)
       and opr.status               = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
       and opp.participant_type     = com_api_const_pkg.PARTICIPANT_ISSUER
       and (case when (i_transaction_type in (opr_api_const_pkg.OPERATION_TYPE_ATM_CASH, opr_api_const_pkg.OPERATION_TYPE_PURCHASE)
                      and opp.card_id in (select column_value from table(cast(l_card_id_tab as num_tab_tpt)))
                      and i_transaction_type = opr.oper_type)
                 then 1
                 when (opr.oper_type = nvl(i_transaction_type, opr.oper_type)
                      and (opp.card_id in (select column_value from table(cast(l_card_id_tab as num_tab_tpt)))
                           or
                           opp.account_id in (select column_value from table(cast(l_account_id_tab as num_tab_tpt)))))
                 then 1
                 else 0
            end
           ) = 1
       and opr.is_reversal = 0
       and not exists (select 1
                         from opr_operation
                        where original_id = opr.id
                          and is_reversal = 1);
    return l_last_date;
end get_last_trx_date;

function get_card_limit_valid_date(
    i_card_id               in  com_api_type_pkg.t_medium_id
  , i_split_hash            in  com_api_type_pkg.t_tiny_id
  , i_is_start              in  com_api_type_pkg.t_boolean
  , i_limit_type            in  com_api_type_pkg.t_dict_value
) return date
is
    PROC_NAME               constant     com_api_type_pkg.t_name := $$PLSQL_UNIT || '.get_card_limit_valid_date';
    LOG_PREFIX              constant     com_api_type_pkg.t_name := lower(PROC_NAME) || ': ';
    l_start_date            date;
    l_end_date              date;
    l_sysdate               date := get_sysdate;

begin
    with products as (
        select connect_by_root id product_id
             , level level_priority
             , id parent_id
             , product_type
             , case when parent_id is null then 1 else 0 end top_flag
          from prd_product
       connect by prior parent_id = id
               --start with id = i_product_id
    )
    select start_date
         , end_date
     into  l_start_date
         , l_end_date
    from (
    select row_number() over (partition by card_id order by decode(level_priority, 0, 0, 1)
                                                          , level_priority
                                                          , start_date desc
                                                          , register_timestamp desc) rn
         , card_id
         , split_hash
         , start_date
         , end_date
      from (
            select v.attr_value limit_id
                 , 0 level_priority
                 , a.object_type limit_type
                 , v.register_timestamp
                 , v.start_date
                 , v.end_date
                 , v.object_id  card_id
                 , v.split_hash
              from prd_attribute_value v
                 , prd_attribute a
             where v.entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD
               and a.entity_type  = fcl_api_const_pkg.ENTITY_TYPE_LIMIT
               and a.id           = v.attr_id
               and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
         union all
            select v.attr_value
                 , p.level_priority
                 , a.object_type as limit_type
                 , v.register_timestamp
                 , v.start_date
                 , v.end_date
                 , ac.id as card_id
                 , ac.split_hash
              from products p
                 , prd_attribute_value v
                 , prd_attribute a
                 , prd_service_type st
                 , prd_service s
                 , prd_product_service ps
                 , prd_contract c
                 , iss_card ac
             where v.service_id      = s.id
               and v.object_id       = decode(a.definition_level, 'SADLSRVC', s.id, p.parent_id)
               and v.entity_type     = decode(a.definition_level, 'SADLSRVC', decode(top_flag, 1, 'ENTTSRVC', '-'), 'ENTTPROD')
               and v.attr_id         = a.id
               and l_sysdate between nvl(v.start_date, l_sysdate) and nvl(v.end_date, trunc(l_sysdate)+1)
               and a.service_type_id = s.service_type_id
               and a.entity_type     = fcl_api_const_pkg.ENTITY_TYPE_LIMIT  --'ENTTLIMT'
               and st.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CARD
               and st.id             = s.service_type_id
               and p.product_id      = ps.product_id
               and s.id              = ps.service_id
               and ps.product_id     = c.product_id
               and c.id              = ac.contract_id
               and c.split_hash      = ac.split_hash
        ) tt
            where limit_type = i_limit_type
        )limits
     where limits.card_id    = i_card_id
       and limits.split_hash = i_split_hash
       and limits.rn         = 1;

    if i_is_start = com_api_type_pkg.TRUE then
        return l_start_date;
    else
        return l_end_date;
    end if;

exception 
    when no_data_found then
        trc_log_pkg.debug(
            i_text => LOG_PREFIX
                      || 'No data found - i_card_id [#1] i_split_hash [#2] i_is_start [#3] i_limit_type [#4]'
          , i_env_param1 => i_card_id
          , i_env_param2 => i_split_hash
          , i_env_param3 => i_is_start
          , i_env_param4 => i_limit_type
        );
        return null;
end get_card_limit_valid_date;

function get_last_invoice(
    i_entity_type           in  com_api_type_pkg.t_dict_value
  , i_object_id             in  com_api_type_pkg.t_long_id
  , i_split_hash            in  com_api_type_pkg.t_tiny_id       default null
  , i_mask_error            in  com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
) return crd_invoice_tpt
is
    l_invoice               crd_api_type_pkg.t_invoice_rec;
    l_crd_invoice_tab       crd_invoice_tpt := crd_invoice_tpt();
    l_service_start_date    date;
begin
    l_invoice := crd_invoice_pkg.get_last_invoice(
                     i_entity_type  => i_entity_type
                   , i_object_id    => i_object_id
                   , i_split_hash   => i_split_hash
                   , i_mask_error   => i_mask_error
                 );

    select trunc(p.start_date)
      into l_service_start_date
      from prd_service_object p
     where p.service_id  = cst_cfc_api_const_pkg.CREDIT_SERVICE_ID
       and p.entity_type = i_entity_type
       and p.object_id   = i_object_id;

    l_crd_invoice_tab.extend();
    l_crd_invoice_tab(1) := crd_invoice_tpr(
                                l_invoice.id
                              , nvl(l_invoice.account_id, i_object_id)
                              , l_invoice.serial_number
                              , l_invoice.invoice_type
                              , l_invoice.exceed_limit
                              , l_invoice.total_amount_due
                              , l_invoice.own_funds
                              , l_invoice.min_amount_due
                              , nvl(l_invoice.invoice_date, l_service_start_date)
                              , l_invoice.grace_date
                              , l_invoice.due_date
                              , l_invoice.penalty_date
                              , l_invoice.aging_period
                              , l_invoice.is_tad_paid
                              , l_invoice.is_mad_paid
                              , l_invoice.inst_id
                              , l_invoice.agent_id
                              , l_invoice.split_hash
                            );
    return l_crd_invoice_tab;
end;

procedure get_total_trans(
    i_entity_type           in  com_api_type_pkg.t_dict_value
  , i_object_id             in  com_api_type_pkg.t_long_id
  , i_split_hash            in  com_api_type_pkg.t_tiny_id       default null
  , i_transaction_type      in  com_api_type_pkg.t_dict_value    default null
  , i_terminal_type         in  com_api_type_pkg.t_dict_value    default null
  , i_mask_error            in  com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
  , i_start_date            in  date                             default null
  , i_end_date              in  date                             default null
  , o_count                out  com_api_type_pkg.t_long_id
  , o_total_amount         out  com_api_type_pkg.t_money
)
is
    l_account_id_tab        num_tab_tpt := num_tab_tpt();
    l_card_id_tab           num_tab_tpt := num_tab_tpt();
    l_from_id               com_api_type_pkg.t_long_id;
    l_till_id               com_api_type_pkg.t_long_id;
begin

    case i_entity_type
        when com_api_const_pkg.ENTITY_TYPE_CUSTOMER then
            select id
              bulk collect into l_account_id_tab
              from acc_account a
             where a.customer_id    = i_object_id;

            select id
              bulk collect into l_card_id_tab
              from iss_card c
             where c.customer_id    = i_object_id;

        when iss_api_const_pkg.ENTITY_TYPE_CARD then
            select ao.account_id
              bulk collect into l_account_id_tab
              from acc_account_object ao
             where ao.entity_type   = iss_api_const_pkg.ENTITY_TYPE_CARD
               and ao.object_id     = i_object_id
               and ao.split_hash    = i_split_hash;

            l_card_id_tab.extend();
            l_card_id_tab(1) :=  i_object_id;

        when acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
            select ao.object_id
              bulk collect into l_card_id_tab
              from acc_account_object ao
             where ao.entity_type   = iss_api_const_pkg.ENTITY_TYPE_CARD
               and ao.account_id    = i_object_id
               and ao.split_hash    = i_split_hash;

            l_account_id_tab.extend();
            l_account_id_tab(1) :=  i_object_id;
        end case;

    l_from_id := com_api_id_pkg.get_from_id(i_start_date);
    l_till_id := com_api_id_pkg.get_till_id(i_end_date);

    select /*+ ordered use_nl(t, o) full(t) index(o opr_operation_pk) */
           count(1)
         , nvl(sum(o.oper_amount), 0)
      into o_count
         , o_total_amount
      from (
               select /*+ cardinality(m 10) ordered use_nl(m, p) full(m) index(p opr_participant_card_id_ndx) */
                      p.oper_id
                    , p.card_id
                 from (select column_value as card_id from table(cast(l_card_id_tab as num_tab_tpt))) m
                    , opr_participant p
                where p.participant_type  = com_api_const_pkg.PARTICIPANT_ISSUER
                  and p.card_id     = m.card_id
                  and p.split_hash  = i_split_hash
                  and p.oper_id     between l_from_id and l_till_id
               union
               select /*+ cardinality(m 10) ordered use_nl(m, p) full(m) index(p opr_participant_acct_id_ndx) */
                      p.oper_id
                    , p.card_id
                 from (select column_value as account_id from table(cast(l_account_id_tab as num_tab_tpt))) m
                    , opr_participant p
                where p.participant_type  = com_api_const_pkg.PARTICIPANT_ISSUER
                  and p.account_id  = m.account_id
                  and p.split_hash  = i_split_hash
                  and p.oper_id     between l_from_id and l_till_id
           ) t
         , opr_operation o
     where o.id            = t.oper_id
       and o.is_reversal   = com_api_const_pkg.FALSE
       and o.status        = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
       and (o.terminal_type = i_terminal_type    or i_terminal_type is null)
       and o.oper_date     between i_start_date and i_end_date
       and not exists (
                   select /*+ index(orig opr_oper_original_id_ndx) */
                          1
                     from opr_operation orig
                    where orig.original_id = o.id
                      and orig.is_reversal = com_api_const_pkg.TRUE
               )
        and (case when i_transaction_type     in (opr_api_const_pkg.OPERATION_TYPE_ATM_CASH, opr_api_const_pkg.OPERATION_TYPE_PURCHASE)
                       and t.card_id          in (select column_value from table(cast(l_card_id_tab as num_tab_tpt)))
                       and i_transaction_type  = o.oper_type
                  then com_api_const_pkg.TRUE
                  when o.oper_type = i_transaction_type
                       or i_transaction_type is null
                  then com_api_const_pkg.TRUE
                  else com_api_const_pkg.FALSE
             end
            ) = com_api_const_pkg.TRUE;

end get_total_trans;

function get_total_trans_count(
    i_entity_type           in  com_api_type_pkg.t_dict_value
  , i_object_id             in  com_api_type_pkg.t_long_id
  , i_split_hash            in  com_api_type_pkg.t_tiny_id       default null
  , i_transaction_type      in  com_api_type_pkg.t_dict_value    default null
  , i_terminal_type         in  com_api_type_pkg.t_dict_value    default null
  , i_mask_error            in  com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
  , i_start_date            in  date                             default null
  , i_end_date              in  date                             default null
) return com_api_type_pkg.t_long_id
is
    l_count                     com_api_type_pkg.t_long_id;
    l_total_amount              com_api_type_pkg.t_money;
begin
    get_total_trans(
         i_entity_type       => i_entity_type
       , i_object_id         => i_object_id
       , i_split_hash        => i_split_hash
       , i_transaction_type  => i_transaction_type
       , i_terminal_type     => i_terminal_type
       , i_mask_error        => i_mask_error
       , i_start_date        => i_start_date
       , i_end_date          => i_end_date
       , o_count             => l_count
       , o_total_amount      => l_total_amount
     );

    return l_count;

end get_total_trans_count;

function get_total_trans_amount(
    i_entity_type           in  com_api_type_pkg.t_dict_value
  , i_object_id             in  com_api_type_pkg.t_long_id
  , i_split_hash            in  com_api_type_pkg.t_tiny_id       default null
  , i_transaction_type      in  com_api_type_pkg.t_dict_value    default null
  , i_terminal_type         in  com_api_type_pkg.t_dict_value    default null
  , i_mask_error            in  com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
  , i_start_date            in  date                             default null
  , i_end_date              in  date                             default null
) return com_api_type_pkg.t_money
is
    l_count                     com_api_type_pkg.t_long_id;
    l_total_amount              com_api_type_pkg.t_money;
begin
    get_total_trans(
         i_entity_type       => i_entity_type
       , i_object_id         => i_object_id
       , i_split_hash        => i_split_hash
       , i_transaction_type  => i_transaction_type
       , i_terminal_type     => i_terminal_type
       , i_mask_error        => i_mask_error
       , i_start_date        => i_start_date
       , i_end_date          => i_end_date
       , o_count             => l_count
       , o_total_amount      => l_total_amount
    );

    return l_total_amount;

end get_total_trans_amount;

function get_total_payment(
    i_account_id            in  com_api_type_pkg.t_long_id
  , i_spent                 in  com_api_type_pkg.t_boolean  default null
  , i_start_date            in  date                        default null
  , i_end_date              in  date                        default null
) return com_api_type_pkg.t_money
is
    l_payment_amt           com_api_type_pkg.t_money;
    l_start_date            date;
    l_end_date              date;
begin
    l_start_date := coalesce(i_start_date, trunc(get_sysdate));
    l_end_date := coalesce(i_end_date, trunc(get_sysdate) + 1 -  com_api_const_pkg.ONE_SECOND);

    select nvl(sum(amount), 0)
      into l_payment_amt
      from crd_payment
     where account_id       = i_account_id
       and is_reversal      = com_api_const_pkg.FALSE
       --and decode(is_new, 1, account_id, null) = i_account_id
       and posting_date between l_start_date and l_end_date
       and decode(i_spent
                  , 1, crd_api_const_pkg.PAYMENT_STATUS_SPENT --'PMTSSPNT'
                  , 0, crd_api_const_pkg.PAYMENT_STATUS_ACTIVE --'PMTSACTV'
                  , status
                 ) = status;

    return l_payment_amt;
end get_total_payment;

function get_highest_bucket(
    i_customer_id           in  com_api_type_pkg.t_medium_id
  , i_account_id            in  com_api_type_pkg.t_account_id   default null
  , i_split_hash            in  com_api_type_pkg.t_tiny_id
  , i_start_date            in  date                        default null
  , i_end_date              in  date                        default null
) return com_api_type_pkg.t_byte_char
is
    l_start_date            date := i_start_date;
    l_end_date              date := i_end_date;
    l_revised_bucket        com_api_type_pkg.t_byte_char;
    l_account_id            com_api_type_pkg.t_account_id;
begin

    l_account_id := coalesce(i_account_id, acc_api_account_pkg.get_account(
                                i_customer_id   => i_customer_id
                              , i_account_type  => acc_api_const_pkg.ACCOUNT_TYPE_CREDIT --ACTP0130
                            ).account_id);
    if l_start_date is null or l_end_date is null then
        l_start_date := crd_invoice_pkg.get_last_invoice_date(
                            i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
                          , i_object_id         => l_account_id
                          , i_split_hash        => i_split_hash
                          , i_mask_error        => com_api_const_pkg.TRUE
                        );
        l_end_date   := add_months(l_start_date, 1) - com_api_const_pkg.ONE_SECOND;

    end if;
    select max(revised_bucket)
      into l_revised_bucket
      from scr_bucket_vw
     where eff_date between l_start_date and l_end_date
       and customer_id  = i_customer_id
       and account_id   = nvl(i_account_id, account_id);

    return l_revised_bucket;
end get_highest_bucket;

function get_current_revised_bucket(
    i_customer_id           in  com_api_type_pkg.t_medium_id
  , i_account_id            in  com_api_type_pkg.t_account_id
) return scr_api_type_pkg.t_scr_bucket_rec
is
    l_scr_bucket_rec        scr_api_type_pkg.t_scr_bucket_rec;
    l_sysdate               date := get_sysdate;
begin
    begin
        select id
             , account_id
             , customer_id
             , revised_bucket
             , eff_date
             , expir_date
             , valid_period
             , reason
             , user_id
          into l_scr_bucket_rec
          from (select row_number() over(order by b.eff_date desc, b.log_date desc) rn
                     , b.id
                     , b.account_id
                     , b.customer_id
                     , b.revised_bucket
                     , b.eff_date
                     , b.expir_date
                     , b.valid_period
                     , b.reason
                     , b.user_id
                  from scr_bucket_vw b
                 where l_sysdate between b.eff_date and b.expir_date
                   and (b.customer_id = i_customer_id
                        or
                        b.account_id  = i_account_id
                       )
               )
         where rn = 1;
    exception
        when no_data_found then
            null;
    end;

    return l_scr_bucket_rec;
end;

function get_revised_bucket_attr(
    i_customer_id           in  com_api_type_pkg.t_medium_id
  , i_account_id            in  com_api_type_pkg.t_account_id
  , i_attr                  in  varchar2
)return varchar2
is
    l_revised_bucket        scr_api_type_pkg.t_scr_bucket_rec;
    l_revised_value         varchar2(128);
begin
    l_revised_bucket := get_current_revised_bucket(
                            i_customer_id   => i_customer_id
                          , i_account_id    => i_account_id
                        );
    case i_attr
        when 'revised_bucket' then
            l_revised_value := l_revised_bucket.revised_bucket;
        when 'eff_date' then
            l_revised_value := to_char(l_revised_bucket.eff_date, cst_cfc_api_const_pkg.CST_SCR_DATE_FORMAT);
        when 'expir_date' then
            l_revised_value := to_char(l_revised_bucket.expir_date, cst_cfc_api_const_pkg.CST_SCR_DATE_FORMAT);
        when 'valid_period' then
            l_revised_value := l_revised_bucket.valid_period;
        when 'reason' then
            l_revised_value := l_revised_bucket.reason;
    end case;
    return nvl(l_revised_value, '');
end;

function get_first_overdue_date(
    i_account_id            in  com_api_type_pkg.t_account_id
  , i_split_hash            in  com_api_type_pkg.t_tiny_id
) return date
is
    l_last_invoice_id       com_api_type_pkg.t_medium_id;
    l_aging_period          com_api_type_pkg.t_tiny_id;
    l_first_overdue_date    date;
    l_recent_indue_date     date;
begin
    l_last_invoice_id := crd_invoice_pkg.get_last_invoice_id(
                             i_account_id    => i_account_id
                           , i_split_hash    => i_split_hash
                           , i_mask_error    => com_api_const_pkg.TRUE
                         );
    select aging_period
         , due_date
      into l_aging_period
         , l_first_overdue_date
      from crd_invoice
     where id = l_last_invoice_id;

    if l_aging_period = 0 then
        return null;
    elsif l_aging_period >= 1 then
        select max(due_date)
          into l_recent_indue_date
          from crd_invoice
         where account_id   = i_account_id
           and split_hash   = i_split_hash
           and aging_period = 0;

        select min(due_date)
          into l_first_overdue_date
          from crd_invoice
         where account_id   = i_account_id
           and split_hash   = i_split_hash
           and due_date     >= nvl(l_recent_indue_date, due_date)
           and aging_period >= 1;
    end if;

    return l_first_overdue_date;
exception
    when no_data_found then
        return null;
end get_first_overdue_date;

function get_total_debt(
    i_account_id            in  com_api_type_pkg.t_account_id
) return com_api_type_pkg.t_money
is
    l_total_account_debt    com_api_type_pkg.t_money := 0;
    l_balances              com_api_type_pkg.t_amount_by_name_tab;
begin
    -- total_account_debt
    acc_api_balance_pkg.get_account_balances(
        i_account_id    => i_account_id
      , o_balances      => l_balances
    );

    l_total_account_debt := l_balances(acc_api_const_pkg.BALANCE_TYPE_OVERDRAFT).amount             --BLTP1002
                            + l_balances(acc_api_const_pkg.BALANCE_TYPE_OVERDUE).amount             --BLTP1004
                            + l_balances(crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST).amount    --BLTP1007
                            + l_balances(acc_api_const_pkg.BALANCE_TYPE_OVERLIMIT).amount
                            + l_balances(crd_api_const_pkg.BALANCE_TYPE_INTR_OVERLIMIT).amount      --BLTP1008
                            + l_balances(crd_api_const_pkg.BALANCE_TYPE_INTEREST).amount            --BLTP1003
                            + l_balances(crd_api_const_pkg.BALANCE_TYPE_PENALTY).amount             --BLTP1006
                            + l_balances(acc_api_const_pkg.BALANCE_TYPE_FEES).amount                --BLTP0003
                            ;

    return abs(l_total_account_debt);
end get_total_debt;

function get_overdue_amount(
    i_account_id            in  com_api_type_pkg.t_account_id
  , i_split_hash            in  com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_money
is
    l_last_invoice_id       com_api_type_pkg.t_medium_id;
    l_aging_period          com_api_type_pkg.t_tiny_id;
    l_overdue_amount        com_api_type_pkg.t_money    default 0;

begin
    l_last_invoice_id := crd_invoice_pkg.get_last_invoice_id(
                             i_account_id    => i_account_id
                           , i_split_hash    => i_split_hash
                           , i_mask_error    => com_api_const_pkg.TRUE
                         );

    select aging_period
      into l_aging_period
      from crd_invoice
     where id = l_last_invoice_id;

    if l_aging_period > 0 then
        l_overdue_amount := get_principal_amount(
                                i_account_id    => i_account_id
                            );
    end if;
    return l_overdue_amount;
end get_overdue_amount;

function get_debit_amount(
    i_account_id            in  com_api_type_pkg.t_account_id
  , i_split_hash            in  com_api_type_pkg.t_tiny_id
  , i_start_date            in  date                        default null
  , i_end_date              in  date                        default null
)return com_api_type_pkg.t_money
is
    l_amt                   com_api_type_pkg.t_money;
    l_start_date            date := i_start_date;
    l_end_date              date := i_end_date;
begin

    l_start_date := nvl(i_start_date, trunc(get_sysdate) - 31);
    l_end_date   := nvl(i_end_date, trunc(get_sysdate) + 1 - com_api_const_pkg.ONE_SECOND);    
    
    select nvl(sum(debt_amount), 0)
      into l_amt
      from crd_debt
     where account_id       = i_account_id
       and id between com_api_id_pkg.get_from_id(l_start_date)
                  and com_api_id_pkg.get_till_id(l_end_date)
       and macros_type_id   in (select numeric_value
                                  from com_array_element
                                 where array_id = 10000059)
       and oper_id not in (select original_id
                             from opr_operation
                            where is_reversal = 1
                              and original_id is not null);
    return l_amt;
end;

function get_applied_payment(
    i_pay_id                in  com_api_type_pkg.t_long_id
  , i_balance_type          in  com_api_type_pkg.t_dict_value   default null
)return com_api_type_pkg.t_money
is
    l_pay_amount            com_api_type_pkg.t_money;
begin
    select sum(pay_amount)
      into l_pay_amount
      from crd_debt_payment
     where pay_id           = i_pay_id
       and balance_type     = nvl(i_balance_type, balance_type);

    return l_pay_amount;
end get_applied_payment;

function get_card_expire_date(
    i_card_id               in  com_api_type_pkg.t_medium_id
  , i_split_hash            in  com_api_type_pkg.t_tiny_id      default null
)return date
is
    l_expir_date            date;
begin

    select max(expir_date)
      into l_expir_date
      from iss_card_instance
     where card_id      = i_card_id
       and split_hash   = nvl(i_split_hash, split_hash)
       and state        != iss_api_const_pkg.CARD_STATE_CLOSED  --'CSTE0300'
    ;

    return l_expir_date;
end get_card_expire_date;

function get_app_element_v(
    i_appl_id               in  com_api_type_pkg.t_long_id
  , i_element_name          in  com_api_type_pkg.t_name
)return com_api_type_pkg.t_full_desc
is
    l_result                com_api_type_pkg.t_full_desc;
begin
    select element_char_value
      into l_result
      from app_ui_data_vw
     where appl_id  = i_appl_id
       and name     = i_element_name
       and rownum   = 1;

    return l_result;
end get_app_element_v;

function get_main_card_id (
    i_account_id            in  com_api_type_pkg.t_account_id
  , i_split_hash            in  com_api_type_pkg.t_tiny_id     default null
)return com_api_type_pkg.t_medium_id
is
    l_split_hash            com_api_type_pkg.t_tiny_id;
begin
    l_split_hash := i_split_hash;
    if l_split_hash is null then
        l_split_hash := com_api_hash_pkg.get_split_hash(
                            i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                          , i_object_id     => i_account_id
                        );
    end if;

    for rec in (
        select t.id as card_id
          from (
                select c.id
                     , row_number() over (order by
                                          case
                                              when c.category = 'CRCG0800' then 1
                                              when c.category = 'CRCG0600' then 2
                                              when c.category = 'CRCG0200' then 3
                                              when c.category = 'CRCG0900' then 4
                                          end) as seqnum
                  from iss_card_vw c
                     , acc_account_object ao
                 where ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                   and ao.object_id = c.id
                   and ao.account_id = i_account_id
                   and ao.split_hash = l_split_hash
               ) t
         order by t.seqnum
    ) loop
        return rec.card_id;
    end loop;

    return com_api_const_pkg.FALSE;
end get_main_card_id;

function get_charged_interest(
    i_account_id            in  com_api_type_pkg.t_long_id
  , i_debt_id               in  com_api_type_pkg.t_long_id  default null
  , i_start_date            in  date    default null
  , i_end_date              in  date    default null
)return com_api_type_pkg.t_money
is
    l_charged_interest      com_api_type_pkg.t_money := 0;
    l_start_date            date;
    l_end_date              date;
begin
    l_start_date    := coalesce(i_start_date, trunc(get_sysdate));
    l_end_date      := coalesce(i_end_date, trunc(get_sysdate) + 1 - com_api_const_pkg.ONE_SECOND);

    if i_debt_id is not null then
        select sum(interest_amount)
          into l_charged_interest
          from crd_debt_interest
         where debt_id          = i_debt_id
           and balance_date     between l_start_date and l_end_date
           and balance_type     in (acc_api_const_pkg.BALANCE_TYPE_OVERDRAFT, acc_api_const_pkg.BALANCE_TYPE_OVERDUE);

    elsif i_account_id is not null then
        select sum(ci.interest_amount)
          into l_charged_interest
          from crd_debt_interest    ci
             , crd_debt             cd
         where cd.id            = ci.debt_id
           and cd.account_id    = i_account_id
           and ci.balance_date  between l_start_date and l_end_date
           and balance_type     in (acc_api_const_pkg.BALANCE_TYPE_OVERDRAFT, acc_api_const_pkg.BALANCE_TYPE_OVERDUE);
    end if;
    return l_charged_interest;
exception
    when no_data_found then
        return 0;
end;

function get_total_waived_interest(
    i_account_id            in  com_api_type_pkg.t_long_id
  , i_split_hash            in  com_api_type_pkg.t_tiny_id
  , i_start_date            in  date    default null
  , i_end_date              in  date    default null
)
return com_api_type_pkg.t_money
is
    l_interest_amount       com_api_type_pkg.t_money;
    l_alg_calc_intr         com_api_type_pkg.t_dict_value;
    l_start_date            date := i_start_date;
    l_end_date              date := i_end_date;
begin
    if l_start_date is null or l_end_date is null then
        l_start_date := crd_invoice_pkg.get_last_invoice_date(
                            i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
                          , i_object_id     => i_account_id
                          , i_split_hash    => i_split_hash
                          , i_mask_error    => com_api_const_pkg.TRUE
                        );
        l_end_date   := add_months(l_start_date, 1) - com_api_const_pkg.ONE_SECOND;

    end if;

    select round(sum(i.interest_amount), 0)
      into l_interest_amount
      from crd_debt d
         , crd_debt_interest i
         , crd_event_bunch_type b
     where d.id             = i.debt_id
       and d.split_hash     = i.split_hash
       and d.account_id     = i_account_id
       and d.split_hash     = i_split_hash
       and i.is_waived      = com_api_const_pkg.TRUE
       and i.balance_type   = b.balance_type(+)
       and d.inst_id        = b.inst_id(+)
       and d.posting_date   between l_start_date and l_end_date
       and b.event_type(+)  = crd_api_const_pkg.WAIVE_INTEREST_CYCLE_TYPE;

    return nvl(l_interest_amount, 0);
end get_total_waived_interest;

function get_tran_fee(
    i_account_id            in  com_api_type_pkg.t_long_id
  , i_start_date            in  date                        default null
  , i_end_date              in  date                        default null
)return com_api_type_pkg.t_money
is
    l_total_fee_amt         com_api_type_pkg.t_money;
    l_start_date            date;
    l_end_date              date;

begin
    l_start_date    := coalesce(i_start_date, trunc(get_sysdate));
    l_end_date      := coalesce(i_end_date, trunc(get_sysdate) + 1 - com_api_const_pkg.ONE_SECOND);

    select sum(fee_amount)
      into l_total_fee_amt
      from (
            select case when d.macros_type_id in (1007, 1009, 7001, 7002)
                        then d.amount
                        when d.macros_type_id in (1008, 1010)
                        then -d.amount
                        else 0
                   end as fee_amount
              from crd_debt d
             where d.status in (
                                 crd_api_const_pkg.DEBT_STATUS_PAID
                               , crd_api_const_pkg.DEBT_STATUS_ACTIVE
                               )
               and d.account_id     = i_account_id
               and d.posting_date   between l_start_date and l_end_date
            )
    ;

   return l_total_fee_amt;
exception
    when no_data_found then
        return 0;
end get_tran_fee;

function get_service_start_date(
    i_account_id            in  com_api_type_pkg.t_account_id
  , i_split_hash            in  com_api_type_pkg.t_tiny_id      default null
  , i_service_type_id       in  com_api_type_pkg.t_short_id
)return date
is
    l_start_date            date;
begin
    select min(o.start_date)
          into l_start_date
          from prd_service_object o
             , prd_service s
         where s.id             = o.service_id
           and o.object_id      = i_account_id
           and o.split_hash     = nvl(i_split_hash, o.split_hash)
           and o.entity_type    = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
           and s.service_type_id = i_service_type_id;
exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error       => 'ACCOUNT_SERVICE_NOT_FOUND'
          , i_env_param1  => i_account_id
          , i_env_param2  => i_service_type_id)
        ;
end get_service_start_date;

--get_credit_limit_amount
function get_balance_amount(
    i_account_id            in  com_api_type_pkg.t_account_id
  , i_balance_type          in  com_api_type_pkg.t_dict_value
  , i_is_abs                in  com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
)return com_api_type_pkg.t_money
is
    l_balance_amt           com_api_type_pkg.t_money;
begin
    l_balance_amt   := acc_api_balance_pkg.get_balance_amount(
                           i_account_id    => i_account_id
                         , i_balance_type  => i_balance_type
                         , i_mask_error    => com_api_const_pkg.TRUE
                         , i_lock_balance  => com_api_const_pkg.FALSE
                       ).amount;

    if i_is_abs = com_api_const_pkg.TRUE then
        l_balance_amt := abs(l_balance_amt);
    end if;

    return l_balance_amt;
end;

function get_total_outstanding_amount(
    i_account_id            in  com_api_type_pkg.t_account_id
  , i_split_hash            in  com_api_type_pkg.t_tiny_id
)return com_api_type_pkg.t_money
is
    l_total_outstanding com_api_type_pkg.t_money;
begin
        select nvl(sum(nvl(b.amount, 0)), 0)
          into l_total_outstanding
          from (select d.id debt_id
                  from crd_debt d
                 where decode(d.status, 'DBTSACTV', d.account_id, null) = i_account_id
                   and d.split_hash = i_split_hash
                  -- and is_new       = com_api_type_pkg.TRUE
                   --and d.id between l_from_id and l_till_id
                 union
                select d.id debt_id
                  from crd_debt d
                 where decode(d.is_new, 1, d.account_id, null) = i_account_id
                   and d.split_hash = i_split_hash
                 --  and is_new = com_api_type_pkg.TRUE
                  -- and d.id between l_from_id and l_till_id
             ) d
             , crd_debt_balance b
         where b.debt_id    = d.debt_id
           and b.split_hash = i_split_hash
           and b.balance_type not in ( acc_api_const_pkg.BALANCE_TYPE_LEDGER, crd_api_const_pkg.BALANCE_TYPE_LENDING)
           --and b.id between l_from_id and l_till_id
           ;
    return l_total_outstanding;
end;

function get_latest_payment_dt(
    i_account_id            in  com_api_type_pkg.t_long_id
)return date
is
    l_post_dt   date;
begin
    select max(posting_date)
      into l_post_dt
      from crd_payment
     where account_id   = i_account_id
       and is_reversal  = 0;

    return l_post_dt;
end get_latest_payment_dt;

function get_latest_payment_amount(
    i_account_id            in  com_api_type_pkg.t_long_id
)return com_api_type_pkg.t_money
is
    l_payment_amt           com_api_type_pkg.t_money;
begin
    select nvl(sum(amount), 0)
      into l_payment_amt
      from crd_payment
     where account_id       = i_account_id
       and is_reversal      = com_api_const_pkg.FALSE
       and posting_date     >= cst_cfc_com_pkg.get_latest_payment_dt(i_account_id => account_id);

    return l_payment_amt;
end get_latest_payment_amount;

function get_cycle_date(
    i_account_id            in  com_api_type_pkg.t_long_id
  , i_cycle_type            in  com_api_type_pkg.t_dict_value
  , i_is_next_date          in  com_api_type_pkg.t_boolean
)return date
is
    l_date date;
begin
    select decode(i_is_next_date, 1, c.next_date, c.prev_date)
      into l_date
      from fcl_cycle_counter c
         , fcl_cycle_type t
     where c.split_hash in (select split_hash from com_api_split_map_vw)
       and c.cycle_type = t.cycle_type
      --and c.next_date <= l_eff_date
      and not exists (select null from fcl_limit_type l where l.cycle_type = t.cycle_type)
      --and (i_inst_id = ost_api_const_pkg.DEFAULT_INST or c.inst_id = i_inst_id)
      and c.cycle_type = i_cycle_type
       and c.object_id = i_account_id;

    return l_date;
end;

function get_interest_rate(
    i_account_id            in  com_api_type_pkg.t_long_id
  , i_split_hash            in  com_api_type_pkg.t_tiny_id
  , i_operation_type        in  com_api_type_pkg.t_dict_value
  , i_is_add_int_rate       in  com_api_type_pkg.t_boolean
  , i_is_welcome_rate       in  com_api_type_pkg.t_boolean
)return com_api_type_pkg.t_short_desc
is
    l_param_tab             com_api_type_pkg.t_param_tab;
    l_fee_id                com_api_type_pkg.t_short_id;
    l_rate                  com_api_type_pkg.t_short_desc;
    l_product_id            com_api_type_pkg.t_short_id;
begin
    l_product_id :=
    prd_api_product_pkg.get_product_id(
        i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id     => i_account_id
      , i_eff_date      => get_sysdate()
    );

    rul_api_param_pkg.set_param(
        io_params => l_param_tab
      , i_name    => 'OPER_TYPE'
      , i_value   => i_operation_type
    );
    rul_api_param_pkg.set_param (
        io_params => l_param_tab
      , i_name    => 'MACROS_TYPE'
      , i_value   => 1004          -- Cardholder debit on operation
    );

    rul_api_param_pkg.set_param (
        io_params => l_param_tab
      , i_name    => 'ACCOUNT_ID'
      , i_value   => i_account_id
    );

    rul_api_param_pkg.set_param (
        io_params => l_param_tab
      , i_name    => 'CFC_IS_WELCOME_LETTER'
      , i_value   => i_is_welcome_rate
    );
    if i_is_add_int_rate = com_api_const_pkg.FALSE then
        l_fee_id :=
        prd_api_product_pkg.get_fee_id (
            i_product_id    => l_product_id
          , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id     => i_account_id
          , i_fee_type      => crd_api_const_pkg.INTEREST_RATE_FEE_TYPE
          , i_split_hash    => i_split_hash
          , i_params        => l_param_tab
          , i_eff_date      => get_sysdate()
        );
    else
        rul_api_param_pkg.set_param (
            io_params => l_param_tab
          , i_name    => 'BALANCE_TYPE'
          , i_value   => crd_api_const_pkg.BALANCE_TYPE_OVERDUE
        );
        l_fee_id :=
            prd_api_product_pkg.get_fee_id (
                i_product_id    => l_product_id
              , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id     => i_account_id
              , i_fee_type      => crd_api_const_pkg.ADDIT_INTEREST_RATE_FEE_TYPE
              , i_split_hash    => i_split_hash
              , i_params        => l_param_tab
              , i_eff_date      => get_sysdate()
            );
    end if;
    if l_fee_id is not null then
        --return fcl_ui_fee_pkg.get_fee_desc(l_fee_id);
        select percent_rate
          into l_rate
          from fcl_fee_tier_vw
         where fee_id = l_fee_id
           and rownum = 1;
    end if;
    return nvl(l_rate, 0);
exception
    when com_api_error_pkg.e_application_error then
        return 0;
end;

function get_latest_change_status_dt (
    i_event_type_tab        in  com_dict_tpt
  , i_object_id             in  com_api_type_pkg.t_long_id
) return date
is
    l_eff_date date;
begin
    select max(change_date)
      into l_eff_date
      from evt_status_log
     where object_id = i_object_id
       and event_type in (select column_value
                            from table(cast(i_event_type_tab  as com_dict_tpt)))
       and status like 'CSTS%';

    return l_eff_date;
end get_latest_change_status_dt;

function get_overdue_fee(
    i_account_id            in  com_api_type_pkg.t_account_id
  , i_split_hash            in  com_api_type_pkg.t_tiny_id
  , i_is_dom                in  com_api_type_pkg.t_boolean       default null
  , i_is_dpp                in  com_api_type_pkg.t_boolean       default null
  , i_trx_type              in  com_api_type_pkg.t_dict_value    default null
  , i_bill_date             in  date                             default null
) return com_api_type_pkg.t_money
is
    l_overdue_fee           com_api_type_pkg.t_money := 0;
begin
    select nvl(sum(d.amount), 0)
      into l_overdue_fee
      from crd_debt d
         , opr_participant prt
         , opr_operation opr
     where d.oper_id        = opr.id
       and d.oper_id        = prt.oper_id
       and d.fee_type       = crd_api_const_pkg.PENALTY_RATE_FEE_TYPE --'FETP1003'
       --and v.is_new       = 1
       and (case
            when i_is_dom = com_api_type_pkg.TRUE
                and (opr.sttl_type in (
                      opr_api_const_pkg.SETTLEMENT_USONUS           --'STTT0010'
                    , opr_api_const_pkg.SETTLEMENT_INTERNAL         --'STTT0000'
                    , opr_api_const_pkg.SETTLEMENT_USONUS_INTRAINST --'STTT0011'
                    , opr_api_const_pkg.SETTLEMENT_USONUS_INTERINST --'STTT0012'
                    )
                or (opr.merchant_country = prt.card_country)) then 1
            when i_is_dom = com_api_type_pkg.TRUE
                and opr.merchant_country != prt.card_country  then 0
            when i_is_dom = com_api_type_pkg.FALSE
                and  (opr.sttl_type in (
                      opr_api_const_pkg.SETTLEMENT_USONUS           --'STTT0010'
                    , opr_api_const_pkg.SETTLEMENT_INTERNAL         --'STTT0000'
                    , opr_api_const_pkg.SETTLEMENT_USONUS_INTRAINST --'STTT0011'
                    , opr_api_const_pkg.SETTLEMENT_USONUS_INTERINST --'STTT0012'
                    )
                or (opr.merchant_country  = prt.card_country)) then 0
             when i_is_dom = com_api_type_pkg.FALSE
                and opr.merchant_country != prt.card_country then 1
            else 1
            end) = 1
       and (case
               when (i_is_dpp is not null and
                     i_is_dpp = com_api_type_pkg.TRUE) then dpp_api_const_pkg.OPERATION_TYPE_DPP_PURCHASE  --'OPTP1500'
               else d.oper_type
               end
           ) = d.oper_type
       and (case
                when (i_bill_date is not null)
                     and d.oper_date between i_bill_date and add_months(i_bill_date, 1)
                     then 1
                else 0
                end
           ) = 1
       and not (i_is_dpp = com_api_type_pkg.FALSE and d.oper_type = dpp_api_const_pkg.OPERATION_TYPE_DPP_PURCHASE) --'OPTP1500'
       and nvl (i_trx_type, opr.oper_type)  = opr.oper_type
       and opr.status                       = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
       and d.account_id                     = i_account_id
       ;

    return l_overdue_fee;
end get_overdue_fee;

function get_overdue_interest(
    i_account_id            in  com_api_type_pkg.t_account_id
  , i_split_hash            in  com_api_type_pkg.t_tiny_id
  , i_is_dom                in  com_api_type_pkg.t_boolean       default null
  , i_is_dpp                in  com_api_type_pkg.t_boolean       default null
  , i_trx_type              in  com_api_type_pkg.t_dict_value    default null
) return com_api_type_pkg.t_money
is
    l_interest_amount       com_api_type_pkg.t_money := 0;
begin
    select round(sum(n.interest_amount))
      into l_interest_amount
      from (select debt_id
                 , sum(interest_amount) as interest_amount
              from crd_debt_interest
             where 1 = 1--invoice_id = i_invoice_id
             --and balance_type = crd_api_const_pkg.BALANCE_TYPE_INTEREST --'BLTP1003'
             group by debt_id
            ) n
         , crd_debt d
         , opr_operation opr
         , opr_participant prt
      where n.debt_id       = d.id
        and d.oper_id       = opr.id
        and opr.status      = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
        and (case
            when i_is_dom = com_api_type_pkg.TRUE
                and (opr.sttl_type in (
                      opr_api_const_pkg.SETTLEMENT_USONUS           --'STTT0010'
                    , opr_api_const_pkg.SETTLEMENT_INTERNAL         --'STTT0000'
                    , opr_api_const_pkg.SETTLEMENT_USONUS_INTRAINST --'STTT0011'
                    , opr_api_const_pkg.SETTLEMENT_USONUS_INTERINST --'STTT0012'
                    )
                or (opr.merchant_country = prt.card_country)) then 1
            when i_is_dom = com_api_type_pkg.TRUE
                and opr.merchant_country != prt.card_country  then 0
            when i_is_dom = com_api_type_pkg.FALSE
                and (opr.sttl_type in (
                      opr_api_const_pkg.SETTLEMENT_USONUS           --'STTT0010'
                    , opr_api_const_pkg.SETTLEMENT_INTERNAL         --'STTT0000'
                    , opr_api_const_pkg.SETTLEMENT_USONUS_INTRAINST --'STTT0011'
                    , opr_api_const_pkg.SETTLEMENT_USONUS_INTERINST --'STTT0012'
                    )
                or (opr.merchant_country  = prt.card_country)) then 0
             when i_is_dom = com_api_type_pkg.FALSE
                and opr.merchant_country != prt.card_country then 1
                    else 1
            end) = 1
        and (case
                when (i_is_dpp    is not null and
                      i_is_dpp    = com_api_type_pkg.TRUE) then dpp_api_const_pkg.OPERATION_TYPE_DPP_PURCHASE --'OPTP1500'
                else d.oper_type
             end
            ) = d.oper_type
        and not(i_is_dpp                 = com_api_type_pkg.FALSE and d.oper_type = dpp_api_const_pkg.OPERATION_TYPE_DPP_PURCHASE)
        and nvl(i_trx_type, d.oper_type) = d.oper_type
        and d.account_id                 = i_account_id
        and d.split_hash                 = i_split_hash
        ;

    return l_interest_amount;
end get_overdue_interest;

function get_latest_tran_amt(
    i_account_id            in  com_api_type_pkg.t_account_id
  , i_split_hash            in  com_api_type_pkg.t_tiny_id
  , i_trx_type              in  com_api_type_pkg.t_dict_value    default null
)return com_api_type_pkg.t_money
is
    l_amount                com_api_type_pkg.t_money := 0;
begin
    select oper_amount
      into l_amount
      from
          opr_operation opr
         , (
            select max(oper_id) oper_id
            from  crd_debt
            where nvl(i_trx_type, oper_type) = oper_type
               and account_id                = i_account_id
               and split_hash                = i_split_hash
           )d
      where opr.id          = d.oper_id
        and opr.status      = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
        ;
   return l_amount;
end;

function get_tran_fee(
    i_account_id            in  com_api_type_pkg.t_account_number
  , i_split_hash            in  com_api_type_pkg.t_tiny_id
  , i_oper_typ              in  com_dict_tpt                     default null
  , i_fee_typ               in  com_dict_tpt                     default null
  , i_start_date            in  date                             default null
  , i_end_date              in  date                             default null
) return com_api_type_pkg.t_money
is
    l_total_fee_amt         com_api_type_pkg.t_money;
begin

    select sum(amount)
      into l_total_fee_amt
      from crd_debt
     where macros_type_id = 1007
       and account_id = i_account_id
       and split_hash = i_split_hash
       and (i_oper_typ is null
            or oper_type in (select column_value
                               from table(cast(i_oper_typ as com_dict_tpt))
                            )
           )
       and (i_fee_typ is null
            or fee_type in (select column_value
                              from table(cast(i_fee_typ as com_dict_tpt))
                           )
           )
       and posting_date between nvl(i_start_date, posting_date) and nvl(i_end_date, posting_date)
    ;

   return l_total_fee_amt;
end get_tran_fee;

function get_daily_mad(
    i_account_id            in  com_api_type_pkg.t_account_id
  , i_use_rounding          in  com_api_type_pkg.t_boolean       default null
) return com_api_type_pkg.t_money
as
    pragma autonomous_transaction;
    l_daily_mad             com_api_type_pkg.t_money;
    l_skip_mad              com_api_type_pkg.t_boolean;
    l_extra_due_date        date;
begin
    cst_apc_crd_algo_proc_pkg.calculate_daily_mad(
        i_account_id           => i_account_id
      , i_check_mad_algorithm  => com_api_const_pkg.TRUE
      , i_use_rounding         => i_use_rounding
      , o_daily_mad            => l_daily_mad
      , o_skip_mad             => l_skip_mad
      , o_extra_due_date       => l_extra_due_date
    );
    commit;
    return l_daily_mad;
exception
    when com_api_error_pkg.e_application_error then
        return null;
end get_daily_mad;

function get_highest_tad(
    i_account_id            in  com_api_type_pkg.t_account_id
  , i_split_hash            in  com_api_type_pkg.t_tiny_id
  , i_bill_num              in  com_api_type_pkg.t_tiny_id
  , i_mask_error            in  com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
)return com_api_type_pkg.t_money
as
    l_serial_num            com_api_type_pkg.t_tiny_id;
    l_tad                   com_api_type_pkg.t_money;
begin
    select max(serial_number) keep (dense_rank last order by invoice_date)
      into l_serial_num
      from crd_invoice
     where account_id = i_account_id
       and split_hash = nvl(i_split_hash, split_hash);

    if l_serial_num is null and i_mask_error = com_api_const_pkg.FALSE then
        com_api_error_pkg.raise_error(
            i_error         => 'ACCOUNT_HAS_NO_INVOICES'
          , i_env_param1    => i_account_id
        );
    elsif l_serial_num is null then
        return 0;
    else
        select max(total_amount_due)
          into l_tad
          from crd_invoice
         where account_id = i_account_id
           and split_hash = nvl(i_split_hash, split_hash)
           and serial_number between greatest(l_serial_num - i_bill_num, 0) and l_serial_num;
    end if;
    return l_tad;
end get_highest_tad;

function get_principal_amount(
    i_account_id            in  com_api_type_pkg.t_account_id
)return com_api_type_pkg.t_money
is
    l_principal_amt     com_api_type_pkg.t_money;
begin
    l_principal_amt :=
        cst_cfc_com_pkg.get_balance_amount(
            i_account_id    => i_account_id
          , i_balance_type  => acc_api_const_pkg.BALANCE_TYPE_OVERDRAFT)
        +
        cst_cfc_com_pkg.get_balance_amount(
            i_account_id    => i_account_id
          , i_balance_type  => acc_api_const_pkg.BALANCE_TYPE_OVERDUE);

    return abs(l_principal_amt);
end;

function get_md5hash(
    i_text                  in com_api_type_pkg.t_text
  , i_password              in com_api_type_pkg.t_name
  , i_network_id            in com_api_type_pkg.t_network_id
)return com_api_type_pkg.t_md5
is
    l_host_id               com_api_type_pkg.t_tiny_id;
    l_standard_id           com_api_type_pkg.t_tiny_id;
    l_inst_id               com_api_type_pkg.t_tiny_id;
    l_proc_bin              com_api_type_pkg.t_name;
    l_param_tab             com_api_type_pkg.t_param_tab;

    function md5hash(
        i_line       in com_api_type_pkg.t_text
      , i_password   in com_api_type_pkg.t_name
    )return com_api_type_pkg.t_md5
    is
        l_result     com_api_type_pkg.t_md5;
        l_password   com_api_type_pkg.t_name;
        l_buffer     com_api_type_pkg.t_text;
        l_num        com_api_type_pkg.t_tiny_id;
        l_pos        com_api_type_pkg.t_tiny_id;
        l_length     com_api_type_pkg.t_tiny_id;
    begin
        l_result    := lower(to_char(rawtohex(dbms_obfuscation_toolkit.md5(input => utl_raw.cast_to_raw(i_line)))));
        l_password  := '5' || i_password || '5';
        l_num       := length(l_password) - 1;

        for i in 1 .. l_num
        loop
            l_pos       := to_number(substr(l_password, i, 1)) + 1;
            l_length    := 20 - to_number(substr(l_password, i + 1, 1));
            l_buffer    := l_buffer || substr(l_result, l_pos, l_length);
        end loop;

        l_result := lower(to_char(rawtohex(dbms_obfuscation_toolkit.md5(input => utl_raw.cast_to_raw(l_buffer)))));

        return l_result;
    end md5hash;

begin
    if i_password is null then
        begin
            select m.id host_id
                 , r.inst_id
                 , s.standard_id
              into l_host_id
                 , l_inst_id
                 , l_standard_id
              from net_network n
                 , net_member m
                 , net_interface i
                 , net_member r
                 , cmn_standard_object s
             where n.id             = i_network_id
               and n.id             = m.network_id
               and n.inst_id        = m.inst_id
               and s.object_id      = m.id
               and s.entity_type    = net_api_const_pkg.ENTITY_TYPE_HOST
               and s.standard_type  = cmn_api_const_pkg.STANDART_TYPE_NETW_CLEARING
               and r.id             = i.consumer_member_id
               and i.host_member_id = m.id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error (
                    i_error         => 'NO_NETWORK_DEFAULT_HOST'
                    , i_env_param1  => i_network_id
                );
        end;

        cmn_api_standard_pkg.get_param_value(
            i_inst_id       => l_inst_id
          , i_standard_id   => l_standard_id
          , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_object_id     => l_host_id
          , i_param_name    => nps_api_const_pkg.CMID
          , o_param_value   => l_proc_bin
          , i_param_tab     => l_param_tab
        );
    end if;

    return md5hash(
               i_line       => i_text
             , i_password   => nvl(i_password, l_proc_bin));
end get_md5hash;

function get_limit_value(
    i_entity_type           in  com_api_type_pkg.t_dict_value
  , i_object_id             in  com_api_type_pkg.t_long_id
  , i_attr_name             in  com_api_type_pkg.t_name
)return com_api_type_pkg.t_money
is
    l_limit_id              com_api_type_pkg.t_long_id;
    l_credit_limit_value    com_api_type_pkg.t_money;
    l_credit_limit_counter  com_api_type_pkg.t_long_id;
begin
    l_limit_id := prd_api_product_pkg.get_attr_value_number(
                      i_entity_type  => i_entity_type
                    , i_object_id    => i_object_id
                    , i_attr_name    => i_attr_name
                    , i_eff_date     => get_sysdate()
                    , i_mask_error   => com_api_const_pkg.TRUE
                  );
    if l_limit_id is not null then
       fcl_api_limit_pkg.get_limit_value(
           i_limit_id       => l_limit_id
         , o_sum_value      => l_credit_limit_value
         , o_count_value    => l_credit_limit_counter
       );
    end if;
    return nvl(l_credit_limit_value, 0);
end get_limit_value;

function get_direct_debit_info(
    i_customer_id           in  com_api_type_pkg.t_medium_id
)return com_api_type_pkg.t_name
is
    l_result                varchar2(255);
begin
    select substr(listagg(get_text('pmo_parameter', 'label', d.param_id, 'LANGENG') || ':' || d.param_value, '/ ')
           within group (order by d.id), 0, 255) into l_result
      from pmo_order_vw o
         , pmo_order_data d
     where o.is_template = 1
       and o.customer_id = i_customer_id
       and o.templ_status = 'POTSVALD'
       and d.order_id = o.id;

    return l_result;

end get_direct_debit_info;

function get_prev_contact_info(
    i_contact_id            in  com_api_type_pkg.t_medium_id
  , i_commun_method         in  com_api_type_pkg.t_dict_value
  , i_start_date            in  date  default null
)return com_api_type_pkg.t_full_desc
is
    l_result                com_api_type_pkg.t_full_desc;
begin
    select commun_address
      into l_result
      from com_contact_data c1
     where c1.contact_id    = i_contact_id
       and c1.commun_method = i_commun_method
       and c1.start_date in (
           select nth_value(c2.start_date, 2) over (order by c2.end_date desc nulls first,
                  c2.start_date desc range between unbounded preceding and unbounded following)
             from com_contact_data  c2
            where c2.contact_id     = c1.contact_id
              and c2.commun_method  = c1.commun_method
              and c2.start_date     <= nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate)
           )
       and rownum = 1;
    return l_result;
end get_prev_contact_info;

function get_unbill_amount(
    i_account_id            in  com_api_type_pkg.t_account_id
  , i_split_hash            in  com_api_type_pkg.t_tiny_id
)return com_api_type_pkg.t_money
is
    l_unbill_amount         com_api_type_pkg.t_money;
begin
    select nvl(sum(nvl(b.amount, 0)), 0)
      into l_unbill_amount
      from crd_debt d
         , crd_debt_balance b
     where decode(d.is_new, 1, d.account_id, null) = i_account_id
       and d.split_hash = i_split_hash
       and b.debt_id    = d.id
       and b.balance_type not in ( acc_api_const_pkg.BALANCE_TYPE_LEDGER, crd_api_const_pkg.BALANCE_TYPE_LENDING);

    return l_unbill_amount;    
end get_unbill_amount;

--later move evt_api_status_pkg
procedure change_event_status(
    i_event_object_id_tab   in  com_api_type_pkg.t_number_tab
  , i_event_status          in  com_api_type_pkg.t_dict_value
)is
    l_dict                  com_api_type_pkg.t_dict_value;
begin
    l_dict := substr(i_event_status, 1, 4);
    if l_dict != evt_api_const_pkg.EVENT_STATUS_KEY then
        com_api_error_pkg.raise_error(
            i_error      => 'CODE_NOT_CORRESPOND_TO_DICT'
          , i_env_param1 => i_event_status
          , i_env_param2 => evt_api_const_pkg.EVENT_STATUS_KEY
        );
    else
        com_api_dictionary_pkg.check_article(
            i_dict => l_dict
          , i_code => i_event_status
        );
    end if;

    if i_event_object_id_tab.count > 0 then
        forall i in i_event_object_id_tab.first .. i_event_object_id_tab.last
            update evt_event_object
               set status = i_event_status
                   , proc_session_id = get_session_id
             where id = i_event_object_id_tab(i);
    end if;
end;

function get_extra_due_date(
    i_account_id            in  com_api_type_pkg.t_account_id
) return com_api_type_pkg.t_byte_char
is
    l_daily_mad             com_api_type_pkg.t_money;
    l_skip_mad              com_api_type_pkg.t_boolean;
    l_extra_due_date        com_api_type_pkg.t_byte_char;
    l_extra_due_date_d      date;
begin
    l_extra_due_date := com_api_flexible_data_pkg.get_flexible_value(
                            i_field_name    => 'CST_DUE_DATE_1'
                          , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                          , i_object_id     => i_account_id
                        );
    if l_extra_due_date is null then
        select due_date
          into l_extra_due_date
          from (
                select lpad(trunc(d.element_value), 2, '0') due_date, row_number() over (partition by d.appl_id order by d.id) rn
                  from app_object   o
                  join app_data     d   on d.appl_id = o.appl_id
                  join app_element  e   on e.id      = d.element_id
                 where o.object_id      = i_account_id
                   and o.entity_type    = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                   and e.id in (app_api_element_pkg.get_element_id('SHIFT_LENGTH'))
                   and exists (
                       select 1
                         from app_data a
                        where a.appl_id = d.appl_id
                          and level = 3
                          and trunc(element_value) in (select id
                                                         from prd_attribute
                                                        where attr_name = 'CRD_INVOICING_PERIOD')
                         start with id = d.id
                       connect by a.id = prior a.parent_id
                       )
                )
         where rn = 1;

        com_api_flexible_data_pkg.set_flexible_value(
            i_field_name    => 'CST_DUE_DATE_1'
          , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id     => i_account_id
          , i_field_value   => l_extra_due_date
        );
    end if;

    return l_extra_due_date;
exception
    when no_data_found then
        cst_apc_crd_algo_proc_pkg.calculate_daily_mad(
            i_account_id           => i_account_id
          , i_check_mad_algorithm  => com_api_const_pkg.FALSE
          , o_daily_mad            => l_daily_mad
          , o_skip_mad             => l_skip_mad
          , o_extra_due_date       => l_extra_due_date_d
        );
    return to_char(l_extra_due_date_d, 'DD');
end;

function get_delinquency_str(
    i_account_id            in  com_api_type_pkg.t_account_id
  , i_split_hash            in  com_api_type_pkg.t_tiny_id
  , i_serial_number         in  com_api_type_pkg.t_tiny_id
  , i_month_period          in  com_api_type_pkg.t_tiny_id
)return com_api_type_pkg.t_name
is
    l_result                com_api_type_pkg.t_name;
begin
    select listagg(nvl(crd_invoice_pkg.get_converted_aging_period(i_aging_period => aging_period), to_char(aging_period)), ',')
           within group (order by serial_number) delinquency_str
      into l_result
      from crd_invoice
     where account_id    = i_account_id
       and split_hash    = i_split_hash
       and serial_number > (i_serial_number - i_month_period);

    return nvl(l_result, 'N/A');
end;

function get_contract_due_date(
    i_product_id            in  com_api_type_pkg.t_short_id
 ) return date
is
    l_contract_due_date     date;
begin
    --initial first date of month
    l_contract_due_date := trunc(sysdate, 'month');
    select (case fcs.shift_type
                when fcl_api_const_pkg.CYCLE_SHIFT_MONTH_DAY then
                     l_contract_due_date + (fcs.shift_sign * fcs.shift_length) - 1
            end
           ) into l_contract_due_date
      from fcl_cycle_shift fcs
         , fcl_cycle fc
     where 1 = 1
       and fcs.cycle_id = fc.id
       and fc.id = (select distinct convert_to_number(first_value(attr_value) over (order by register_timestamp desc)) as attr_value
                      from prd_attribute_value
                     where 1 = 1
                       and attr_id      = (select id from prd_attribute where attr_name = 'CRD_DUE_DATE_PERIOD')
                       and entity_type  = prd_api_const_pkg.ENTITY_TYPE_PRODUCT --'ENTTPROD'
                       and object_id    in (select id
                                              from prd_product
                                             start with id = i_product_id
                                           connect by id   = prior parent_id)
                    )
       and rownum = 1;
    return l_contract_due_date;
exception
    when no_data_found then
        return null;
end get_contract_due_date;

function get_phone_number(
    i_customer_id           in  com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_name
is
    l_mobile_phone          com_api_type_pkg.t_name;
    l_landline_phone        com_api_type_pkg.t_name;
begin

    select com_api_contact_pkg.get_contact_string(
               i_contact_id     => contact_id
             , i_commun_method  => com_api_const_pkg.COMMUNICATION_METHOD_MOBILE --'CMNM0001'
             , i_start_date     => get_sysdate)
         , com_api_contact_pkg.get_contact_string(
               i_contact_id     => contact_id
             , i_commun_method  => com_api_const_pkg.COMMUNICATION_METHOD_PHONE --'CMNM0012'
             , i_start_date     => get_sysdate)
      into l_mobile_phone
         , l_landline_phone
      from com_contact_object
     where object_id        = i_customer_id
       and entity_type      = com_api_const_pkg.ENTITY_TYPE_CUSTOMER --'ENTTCUST'
       and contact_type     = com_api_const_pkg.CONTACT_TYPE_PRIMARY --'CNTTPRMC'
    ;
    return nvl(l_mobile_phone, l_landline_phone);
exception
    when no_data_found then
        return null;
end get_phone_number;

function add_cycle_length(
    i_start_date            in  date
  , i_inst_id               in  com_api_type_pkg.t_inst_id
  , i_length_type           in  com_api_type_pkg.t_dict_value
  , i_cycle_length          in  com_api_type_pkg.t_tiny_id
  , i_forward               in  com_api_type_pkg.t_boolean
  , i_workdays_only         in  com_api_type_pkg.t_boolean
) return date is
    l_sign                  pls_integer;
begin
    l_sign:= case when i_forward = com_api_type_pkg.TRUE then 1 else -1 end;

    return
        case i_length_type
            when fcl_api_const_pkg.CYCLE_LENGTH_MONTH   then
                add_months(i_start_date, l_sign * i_cycle_length)
            when fcl_api_const_pkg.CYCLE_LENGTH_YEAR    then
                add_months(i_start_date, l_sign * i_cycle_length * 12)
            when fcl_api_const_pkg.CYCLE_LENGTH_DAY     then
                case
                    when i_workdays_only = com_api_type_pkg.TRUE then
                        com_api_holiday_pkg.get_shifted_working_day(
                            i_day               => i_start_date
                          , i_forward           => i_forward
                          , i_day_shift         => i_cycle_length
                          , i_inst_id           => i_inst_id
                        )
                    else
                        i_start_date + l_sign * i_cycle_length
                end
            when fcl_api_const_pkg.CYCLE_LENGTH_WEEK    then
                i_start_date + l_sign * (i_cycle_length * 7)
            when fcl_api_const_pkg.CYCLE_LENGTH_HOUR    then
                i_start_date + l_sign * (i_cycle_length * 1/24)
            when fcl_api_const_pkg.CYCLE_LENGTH_MINUTE  then
                i_start_date + l_sign * (i_cycle_length * 1/24/60)
            when fcl_api_const_pkg.CYCLE_LENGTH_SECOND  then
                i_start_date + l_sign * (i_cycle_length * 1/24/60/60)
        end;
end add_cycle_length;

function get_cycle_prev_date(
    i_start_date            in  date
  , i_inst_id               in  com_api_type_pkg.t_inst_id
  , i_cycle_type            in  com_api_type_pkg.t_dict_value
) return date
is
    l_length_type           com_api_type_pkg.t_dict_value;
    l_cycle_length          com_api_type_pkg.t_tiny_id;
    l_workdays_only         com_api_type_pkg.t_boolean;
    l_prev_date             date;
begin
    select length_type
         , cycle_length
         , workdays_only
      into l_length_type
         , l_cycle_length
         , l_workdays_only
      from fcl_cycle
     where cycle_type = i_cycle_type;

    l_prev_date :=
    add_cycle_length(
        i_start_date           => i_start_date
      , i_inst_id              => i_inst_id
      , i_length_type          => l_length_type
      , i_cycle_length         => l_cycle_length
      , i_forward              => com_api_type_pkg.FALSE
      , i_workdays_only        => l_workdays_only
    );
    return l_prev_date;
exception
    when no_data_found or too_many_rows then
        return i_start_date;
end;

function is_link_application(
    i_object_id             in  com_api_type_pkg.t_medium_id
  , i_entity_type           in  com_api_type_pkg.t_dict_value
)return com_api_type_pkg.t_boolean
is
begin
    if i_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
        return case
               when com_api_flexible_data_pkg.get_flexible_value(
                        i_field_name   => cst_cfc_api_const_pkg.CST_CFC_RESERVED_ACC_NUMBER
                      , i_entity_type  => i_entity_type
                      , i_object_id    => i_object_id
                    ) is not null then com_api_const_pkg.TRUE
               else com_api_const_pkg.FALSE
               end;
    end if;

    return com_api_const_pkg.FALSE;
end;

end cst_cfc_com_pkg;
/
