create or replace package body cst_woo_api_teller_pkg as

function get_reissue_reason(
    i_card_id               in      com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_dict_value
is
    l_reason_code               com_api_type_pkg.t_dict_value;
begin
    select t.reason into l_reason_code
      from (
            select esl.reason
              from evt_status_log     esl
                 , iss_card_instance  ici
             where esl.object_id = ici.id
               and entity_type   = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE --'ENTTCINS'
               and event_type in (  'EVNT0192'  --Change card status due to lost
                                  , 'EVNT0201'  --Change card status due to damage
                                  , 'EVNT0111'  --Card reissuance
                                  )
               and (ici.id = (select i_ci.preceding_card_instance_id
                                from iss_card_instance i_ci
                               where i_ci.card_id = i_card_id
                             )
                    or
                    ici.card_id = i_card_id
                   )
             order by change_date desc
            )t
     where rownum = 1;
     
    return l_reason_code;

end get_reissue_reason;

procedure get_card_acct_link(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_app_id            in      com_api_type_pkg.t_name
  , o_ref_cur           out     com_api_type_pkg.t_ref_cur
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_card_acct_link';
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_card_number               com_api_type_pkg.t_name;
    l_reissued_card_number      com_api_type_pkg.t_name;
    l_lang                      com_api_type_pkg.t_dict_value;
begin
    l_inst_id := nvl(i_inst_id, cst_woo_const_pkg.W_INST);
    l_lang    := nvl(get_user_lang(), com_api_const_pkg.LANGUAGE_ENGLISH);

    --Reissue application
    begin
    select t.card_number into l_card_number
      from (
            select iss_api_token_pkg.decode_card_number(i_card_number => i_cn.card_number) as card_number
              from iss_card_instance i_ci
                 , iss_card_number   i_cn
             where i_ci.card_id    = i_cn.card_id
               and i_ci.preceding_card_instance_id in (select ici.id
                                                         from iss_card_instance ici
                                                            , iss_card_number   icn
                                                        where icn.card_id     = ici.card_id
                                                          and ici.state       = iss_api_const_pkg.CARD_STATE_ACTIVE --'CSTE0200'
                                                          and icn.card_number in (select d.element_value
                                                                                    from app_data        d
                                                                                       , app_element     e
                                                                                       , app_history     h
                                                                                   where e.id            = d.element_id
                                                                                     and h.appl_id       = d.appl_id
                                                                                     and h.appl_status   = app_api_const_pkg.APPL_STATUS_PROC_SUCCESS  --'APST0007'
                                                                                     and e.name          = 'CARD_NUMBER'
                                                                                     and d.appl_id       = i_app_id
                                                                                 )
                                                        )
            order by i_ci.reg_date desc
            )t
    where rownum = 1;
    exception
        when no_data_found then
            l_card_number := null;
    end;

    --Issuing application
    if l_card_number is null then
        select iss_api_token_pkg.decode_card_number(i_card_number => d1.element_value)
          into l_card_number
          from app_data         d1
             , app_data         d2
             , app_element     e
             , app_history     h
         where e.id             = d1.element_id
           and h.appl_id        = d1.appl_id
           and h.appl_status   = app_api_const_pkg.APPL_STATUS_PROC_SUCCESS  --'APST0007'
           and e.name          = 'CARD_NUMBER'
           and d1.appl_id       = i_app_id
           and d2.id            = d1.parent_id
           and d2.serial_number = 1;
    end if;

    begin
        select iss_api_token_pkg.decode_card_number(i_card_number => d1.element_value)
          into l_reissued_card_number
          from app_data         d1
             , app_data         d2
             , app_element      e
             , app_history      h
         where e.id             = d1.element_id
           and h.appl_id        = d1.appl_id
           and h.appl_status    = app_api_const_pkg.APPL_STATUS_PROC_SUCCESS  --'APST0007'
           and e.name           = 'CARD_NUMBER'
           and d1.appl_id       = i_app_id
           and d2.id            = d1.parent_id
           and d2.serial_number = 2;
    exception
        when no_data_found then
            l_reissued_card_number := null;
    end;

    open o_ref_cur for
    select cus.customer_number                                                  as cus_num
         , convert_to_number(com_api_flexible_data_pkg.get_flexible_value(
                                 i_field_name   => 'CST_RECRUITER_ID'
                               , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                               , i_object_id    => decode(ctf.card_feature
                                                          , cst_woo_const_pkg.DEBIT_CARD, acct.saving_acct_id
                                                          , cst_woo_const_pkg.CREDIT_CARD, acct.credit_acct_id
                                                          , cst_woo_const_pkg.PREPAID_CARD, acct.prepaid_acct_id
                                                         )
                             )
                            )                                                   as inviter_num
         , agt.agent_number                                                     as branch_code
         , ci.expir_date                                                        as card_expire_date
         , (select product_number
              from prd_product
             where id = ctr.product_id)                                         as product_code
         , decode(ctf.card_feature
                    , cst_woo_const_pkg.DEBIT_CARD, '01'
                    , cst_woo_const_pkg.CREDIT_CARD, '03'
                    , cst_woo_const_pkg.PREPAID_CARD, '04'
                 )                                                              as card_class
         , 3                                                                    as brand_code
         , (case
                 when lower(com_api_i18n_pkg.get_text(
                                i_table_name  => 'NET_CARD_TYPE'
                              , i_column_name => 'NAME'
                              , i_object_id   => crd.card_type_id
                             )
                            ) like '%classic%'
                 then 'C'
                 when lower(com_api_i18n_pkg.get_text(
                                i_table_name  => 'NET_CARD_TYPE'
                              , i_column_name => 'NAME'
                              , i_object_id   => crd.card_type_id
                             )
                            ) like '%gold%'
                 then 'G'
                 when lower(com_api_i18n_pkg.get_text(
                                i_table_name  => 'NET_CARD_TYPE'
                              , i_column_name => 'NAME'
                              , i_object_id   => crd.card_type_id
                             )
                            ) like '%platinum%'
                 then 'P'
                 else ''
            end
            )                                                                   as card_grade
         , (case
                when ci.status in ( iss_api_const_pkg.CARD_STATUS_VALID_CARD
                                  , iss_api_const_pkg.CARD_STATUS_NOT_ACTIVATED
                                  , iss_api_const_pkg.CARD_STATUS_PIN_ACTIVATION
                                  , iss_api_const_pkg.CARD_STATUS_FORCED_PIN_CHANGE)
                    then '05'
                when ci.status in (iss_api_const_pkg.CARD_STATUS_LOST_CARD)
                    then '01'
                when ci.status in (iss_api_const_pkg.CARD_STATUS_STOLEN_CARD)
                    then '03'
                else '06'
            end
            )                                                                   as card_status
         , cst_woo_com_pkg.get_contract_due_date(ctr.product_id)                as due_date
         , decode(cus.entity_type
                , com_api_const_pkg.ENTITY_TYPE_PERSON, 'I3'
                , 'C2')                                                         as billing_place
         , nvl(acct.prepaid_acct_num, acct.saving_acct_num)                     as sv_acct_num
         , nvl(acct.saving_acct_num, acct.credit_acct_num)                      as ext_acct_num
         , com_api_flexible_data_pkg.get_flexible_value(
              i_field_name   => 'CST_VIRTUAL_ACCOUNT_NUMBER'
            , i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
            , i_object_id    => nvl(acct.credit_acct_id, acct.prepaid_acct_id)) as vir_acct_num
         , com_ui_person_pkg.get_person_name(
            (select person_id
               from iss_cardholder
              where id = (select cardholder_id from iss_card where id = crd.id)
             )
            , l_lang)                                                           as card_holder_name
         , decode(cus.entity_type
                , com_api_const_pkg.ENTITY_TYPE_PERSON, '01'
                , '05')                                                         as card_relations
         , acct.card_number                                                     as card_num
         , nvl(
           (select iss_api_token_pkg.decode_card_number(i_card_number => icn.card_number) as card_number
              from iss_card_number    icn
                 , iss_card_instance  ici
              where ici.card_id = icn.card_id
               and ici.id = ( select i_ci.preceding_card_instance_id
                                from iss_card_instance i_ci
                               where i_ci.card_id = acct.card_id
                            )
            ), l_reissued_card_number)                                          as reissued_card_num
         , get_reissue_reason(acct.card_id)                                     as reissued_reason
         , acct.card_id                                                         as card_id
         , decode(ctr.contract_type, C_PREPAID_ANONYMOUS, 1
                                   , C_PREPAID_NON_ANONYMOUS, 2)                as prepaid_card_type
         , cus.entity_type                                                      as customer_type
         , ctr.contract_number                                                  as contract_number
         , (select comp.embossed_name
              from com_company comp
             where comp.id = cus.object_id
           )                                                                    as corp_short_name
      from iss_card                   crd
         , iss_card_instance          ci
         , ost_agent                  agt
         , prd_customer               cus
         , prd_contract               ctr
         , net_card_type_feature      ctf
         , (select icn.card_id
                 , iss_api_token_pkg.decode_card_number(i_card_number => icn.card_number) as card_number
                 , act.split_hash
                 , max(decode(act.account_type, cst_woo_const_pkg.ACCT_TYPE_SAVING_VND, act.id))              as saving_acct_id   --'ACTP0131'
                 , max(decode(act.account_type, acc_api_const_pkg.ACCOUNT_TYPE_CREDIT, act.id))               as credit_acct_id   --'ACTP0130'
                 , max(decode(act.account_type, cst_woo_const_pkg.ACCT_TYPE_SAVING_VND, act.account_number))  as saving_acct_num  --'ACTP0131'
                 , max(decode(act.account_type, acc_api_const_pkg.ACCOUNT_TYPE_CREDIT, act.account_number))   as credit_acct_num  --'ACTP0130'
                 , max(decode(act.account_type, cst_woo_const_pkg.ACCT_TYPE_PREPAID_VND, act.account_number)) as prepaid_acct_num --'ACTP0140'
                 , max(decode(act.account_type, cst_woo_const_pkg.ACCT_TYPE_PREPAID_VND, act.id))             as prepaid_acct_id  --'ACTP0140'
              from acc_account_object aao
                 , iss_card_number    icn
                 , acc_account        act
             where aao.object_id    = icn.card_id
               and aao.entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD --'ENTTCARD'
               and aao.account_id   = act.id
               and act.inst_id      = l_inst_id
             group by icn.card_id, icn.card_number, act.split_hash
            )                         acct
     where crd.id                   = acct.card_id
       and crd.id                   = ci.card_id
       and ci.agent_id              = agt.id
       and crd.contract_id          = ctr.id
       and crd.customer_id          = cus.id
       and ctf.card_type_id         = crd.card_type_id
       and acct.card_number         = l_card_number
       ;

exception
    when no_data_found then
        null;
    when others then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || ' FAILED: i_inst_id [#2], sqlerrm [#1]'
          , i_env_param1 => sqlerrm
          , i_env_param2 => i_inst_id
        );
        raise;
end get_card_acct_link;

procedure get_account(
    i_account_number    in      com_api_type_pkg.t_account_number
  , o_account_status    out     com_api_type_pkg.t_dict_value
  , o_account_type      out     com_api_type_pkg.t_dict_value
) is
begin
    select a.status
         , a.account_type
      into o_account_status
         , o_account_type
      from acc_account a
     where a.account_number = i_account_number;
exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error      => 'ACCOUNT_NOT_FOUND'
          , i_env_param1 => i_account_number
        );
    when too_many_rows then
        com_api_error_pkg.raise_error(
            i_error      => 'ACCOUNT_NUMBER_NOT_UNIQUE'
          , i_env_param1 => i_account_number
        );
end get_account;

procedure get_account_balances(
      i_account_number          in  com_api_type_pkg.t_account_number
    , i_balance_type            in  com_api_type_pkg.t_dict_value
    , o_balance_amount          out com_api_type_pkg.t_money
    , o_balance_currency        out com_api_type_pkg.t_curr_code
    , o_aval_balance            out com_api_type_pkg.t_money
    , o_aval_balance_currency   out com_api_type_pkg.t_curr_code
) is
    l_account_id                 com_api_type_pkg.t_account_id;
    l_account                    acc_api_type_pkg.t_account_rec;
    l_balance_amount             com_api_type_pkg.t_amount_rec;
    l_aval_balance               com_api_type_pkg.t_amount_rec;
begin
    l_account := acc_api_account_pkg.get_account(
                        i_account_id     => null
                      , i_account_number => i_account_number
                      , i_mask_error     => com_api_type_pkg.FALSE
                    );

    l_account_id := l_account.account_id;

    l_balance_amount := acc_api_balance_pkg.get_balance_amount (
                            i_account_id            => l_account_id
                            , i_balance_type        => i_balance_type
                            , i_mask_error          => com_api_type_pkg.FALSE
                            , i_lock_balance        => com_api_type_pkg.FALSE
                        );
    l_aval_balance := acc_api_balance_pkg.get_aval_balance_amount (
                          i_account_id            => l_account_id
                      );

    o_balance_amount        := l_balance_amount.amount;
    o_balance_currency      := l_balance_amount.currency;
    o_aval_balance          := l_aval_balance.amount;
    o_aval_balance_currency := l_aval_balance.currency;
exception
    when others then
        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error       => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
            );
        end if;
end get_account_balances;

procedure get_customer_marketing_info(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_customer_id       in      com_api_type_pkg.t_medium_id
  , o_ref_cur           out     com_api_type_pkg.t_ref_cur
) is
begin
    open o_ref_cur for
    select account_type
         , sum(pos_amt)  as sum_pos
         , sum(cash_amt) as sum_cash
    from (
            select case when aa.account_type = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT    --'ACTP0130'
                        then 'Credit'
                        when aa.account_type = cst_woo_const_pkg.ACCT_TYPE_SAVING_VND   --'ACTP0131'
                        then 'Saving'
                        when aa.account_type = cst_woo_const_pkg.ACCT_TYPE_PREPAID_VND  --'ACTP0140'
                        then 'Prepaid'
                    end as account_type
                 , case when oo.oper_type = opr_api_const_pkg.OPERATION_TYPE_PURCHASE   --'OPTP0000'
                   then sum(oo.oper_amount) else 0
                    end as pos_amt
                 , case when oo.oper_type = opr_api_const_pkg.OPERATION_TYPE_ATM_CASH   --'OPTP0001'
                   then sum(oo.oper_amount) else 0
                    end as cash_amt
              from opr_operation        oo
                 , opr_participant      op
                 , prc_session          ps
                 , acc_account          aa
             where 1 = 1
               and oo.id                = op.oper_id
               and ps.id                = oo.session_id
               and aa.id                = op.account_id
               and oo.is_reversal       = com_api_const_pkg.FALSE --0
               and oo.status            = opr_api_const_pkg.OPERATION_STATUS_PROCESSED  -- 'OPST0400'
               and op.participant_type  = com_api_const_pkg.PARTICIPANT_ISSUER          -- 'PRTYISS'
               and aa.account_type      in (
                                              acc_api_const_pkg.ACCOUNT_TYPE_CREDIT     -- 'ACTP0130'
                                            , cst_woo_const_pkg.ACCT_TYPE_SAVING_VND    -- 'ACTP0131'
                                            , cst_woo_const_pkg.ACCT_TYPE_PREPAID_VND   -- 'ACTP0140'
                                           )
               and oo.oper_type         in (
                                              opr_api_const_pkg.OPERATION_TYPE_PURCHASE -- 'OPTP0000'
                                            , opr_api_const_pkg.OPERATION_TYPE_ATM_CASH -- 'OPTP0001'
                                            )
               and ps.start_time between add_months(sysdate, -3) and sysdate
               and op.customer_id       = i_customer_id
               and aa.inst_id           = i_inst_id
               and not exists (select 1 from opr_operation where original_id = oo.id)
             group by oo.oper_type, aa.account_type
            union all
            select 'Credit', 0, 0 from dual
            union all
            select 'Saving', 0, 0 from dual
            union all
            select 'Prepaid', 0, 0 from dual
        )t
    group by account_type
    order by account_type
    ;
exception
    when no_data_found then
        null;
    when others then
        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error       => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
            );
        end if;
end get_customer_marketing_info;

procedure get_card_account_from_account(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_account_number        in      com_api_type_pkg.t_account_number
  , o_ref_cur               out     com_api_type_pkg.t_ref_cur
)is
begin
    open o_ref_cur for
    select distinct
           aa.account_type      as account_type
         , aa.agent_id          as account_agent
         , nc.card_feature      as card_type
         , ii.agent_id          as card_agent
         , pc.product_id        as card_product_id
         , pc.contract_type     as card_contract_type
         , pc.contract_number   as card_contract_number
         , pu.customer_number   as customer_number
         , (
            select a.account_number
              from acc_account a
                 , acc_account_object o
             where a.id         = o.account_id
             and a.account_type = cst_woo_const_pkg.ACCT_TYPE_SAVING_VND --'ACTP0131'
             and o.entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD     --'ENTTCARD'
             and o.object_id    = ic.id
           )                    as saving_acct
         , (
            select a.account_number
              from acc_account a
                 , acc_account_object o
             where a.id         = o.account_id
             and a.account_type = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT -- 'ACTP0130'
             and o.entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD    --'ENTTCARD'
             and o.object_id    = ic.id
           )                    as credit_acct
         , cn.card_number       as card_number
      from acc_account_object   ao
         , acc_account          aa
         , iss_card             ic
         , net_card_type_feature nc
         , prd_contract         pc
         , iss_card_instance    ii
         , iss_card_number      cn
         , prd_customer         pu
     where aa.id                = ao.account_id
       and ii.card_id           = ic.id
       and ii.card_id           = cn.card_id
       and aa.customer_id       = pu.id
       and ao.entity_type       = iss_api_const_pkg.ENTITY_TYPE_CARD --'ENTTCARD'
       and ao.object_id         = ic.id
       and ic.card_type_id      = nc.card_type_id
       and ic.contract_id       = pc.id
       and aa.inst_id           = i_inst_id
       and aa.account_number    = i_account_number;
exception
    when no_data_found then
        null;
    when others then
        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error       => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
            );
        end if;
end get_card_account_from_account;

procedure get_customer_credit_account(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_customer_number       in      com_api_type_pkg.t_cmid
  , o_ref_cur               out     com_api_type_pkg.t_ref_cur
) is
begin
    open o_ref_cur for
        select a.account_number
          from acc_account a
             , prd_customer c
         where a.customer_id     = c.id
           and a.account_type    = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT   --'ACTP0130'
           and a.status         != acc_api_const_pkg.ACCOUNT_STATUS_CLOSED --'ACSTCLSD'
           and c.customer_number = i_customer_number;
exception
    when no_data_found then
        null;
    when others then
        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error       => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
            );
        end if;
end get_customer_credit_account;

function get_dpp_threshold(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_account_number        in      com_api_type_pkg.t_account_number
) return com_api_type_pkg.t_long_id
is
    l_account_id            com_api_type_pkg.t_long_id;
    l_fixed_rate            com_api_type_pkg.t_long_id;
begin

    select id
      into l_account_id
      from acc_account
     where inst_id = i_inst_id
       and account_number = i_account_number;

    select fixed_rate
      into l_fixed_rate
      from fcl_fee_tier
     where fee_id = (
                    select distinct convert_to_number(first_value(attr_value) over (order by start_date desc)) as attr_value
                      from prd_attribute_value
                     where 1 = 1
                       and attr_id      = (select id from prd_attribute where attr_name = 'DPP_AUTOCREATION_THRESHOLD')
                       and entity_type  = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
                       and object_id    = l_account_id
                       and start_date < get_sysdate
                       and (end_date > get_sysdate or end_date is null)
                    );
    return l_fixed_rate;
exception
    when no_data_found then
        null;
end get_dpp_threshold;

function get_collateral_account(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_account_number        in      com_api_type_pkg.t_account_number
) return com_api_type_pkg.t_account_number
is
    l_collateral_account    com_api_type_pkg.t_account_number;
begin

    select d.field_value
      into l_collateral_account
      from com_flexible_field f
         , com_flexible_data d
         , acc_account a
     where f.id = d.field_id
       and f.name = 'CST_COLLATERAL_ACCOUNT'
       and a.id = d.object_id
       and a.account_number = i_account_number
       and a.inst_id = i_inst_id
       and rownum = 1;
    return l_collateral_account;
exception
    when no_data_found then
        null;
end get_collateral_account;

function get_statement_delivery_method(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_account_number        in      com_api_type_pkg.t_account_number
) return com_api_type_pkg.t_text
is
    l_delivery_method       com_api_type_pkg.t_dict_value;
    l_lang                  com_api_type_pkg.t_dict_value := nvl(get_user_lang(), com_api_const_pkg.LANGUAGE_ENGLISH);
begin

    select distinct first_value(attr_value) over (order by start_date desc)
      into l_delivery_method
      from prd_attribute_value
     where attr_id     = (select id
                            from prd_attribute
                           where attr_name = 'CRD_INVOICING_DELIVERY_STATEMENT_METHOD')
       and object_id   = acc_api_account_pkg.get_account_id(i_account_number)
       and entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
       and start_date <= get_sysdate;

    return l_delivery_method || ' - ' || com_api_dictionary_pkg.get_article_text(l_delivery_method, l_lang);
exception
    when no_data_found then
        null;
end get_statement_delivery_method;

procedure get_card_acct_for_sup_card(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_card_number           in      com_api_type_pkg.t_card_number
  , i_account_number        in      com_api_type_pkg.t_account_number
  , o_ref_cur               out     com_api_type_pkg.t_ref_cur
) is
    l_card_id               com_api_type_pkg.t_medium_id;
    l_account_id            com_api_type_pkg.t_medium_id;
    l_product_id            com_api_type_pkg.t_medium_id;
    l_inst_id               com_api_type_pkg.t_inst_id;
begin

    l_inst_id := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

    l_card_id := iss_api_card_pkg.get_card_id(i_card_number);

    l_account_id := acc_api_account_pkg.get_account_id(i_account_number);

    l_product_id := prd_api_product_pkg.get_product_id(
                        i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD
                      , i_object_id     => l_card_id
                      , i_inst_id       => l_inst_id
                    );       

    open o_ref_cur for
    select sum(notif_channel)       as notif_channel
         , sum(enable_hybrid)       as enable_hybrid
         , sum(hybrid_threshold)    as hybrid_threshold
         , sum(auto_dpp)            as auto_dpp
         , sum(dpp_threshold)       as dpp_threshold
         , sum(dpp_fixed_count)     as dpp_fixed_count
      from (
            select nce.channel_id   as notif_channel
                 , null             as enable_hybrid
                 , null             as hybrid_threshold
                 , null             as auto_dpp
                 , null             as dpp_threshold
                 , null             as dpp_fixed_count
              from iss_card         ica
                 , iss_cardholder   ich
                 , ntf_custom_event nce
             where 1 = 1
               and ica.cardholder_id = ich.id
               and nce.object_id = ich.id
               and nce.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER --'ENTTCRDH'
               and ica.id = l_card_id
               and ica.inst_id = l_inst_id
               and rownum = 1

            union all

            select null as notif_channel
                 , nvl(
                        (
                        select distinct
                               convert_to_number(first_value(attr_value) over (order by start_date desc)) as enable_hybrid
                          from prd_attribute_value
                         where 1 = 1
                           and attr_id = (select id
                                            from prd_attribute
                                           where attr_name = 'ISS_USAGE_HYBRID_THRESHOLD')
                           and entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD --'ENTTCARD'
                           and object_id = l_card_id
                           and start_date < get_sysdate
                           and (end_date > get_sysdate or end_date is null)
                        ),
                        (
                        select distinct
                               convert_to_number(first_value(attr_value) over (order by start_date desc)) as enable_hybrid
                          from prd_attribute_value
                         where 1 = 1
                           and attr_id = (select id
                                            from prd_attribute
                                           where attr_name = 'ISS_USAGE_HYBRID_THRESHOLD')
                           and entity_type = prd_api_const_pkg.ENTITY_TYPE_PRODUCT -- ENTTPROD
                           and object_id in (select id
                                               from prd_product
                                              start with id = l_product_id
                                              connect by id = prior parent_id)
                           and start_date < get_sysdate
                           and (end_date > get_sysdate or end_date is null)
                        )
                      ) as enable_hybrid
                 , null as hybrid_threshold
                 , null as auto_dpp
                 , null as dpp_threshold
                 , null as dpp_fixed_count
            from dual

            union all

            select null         as notif_channel
                 , null         as enable_hybrid
                 , sum_limit    as hybrid_threshold
                 , null         as auto_dpp
                 , null         as dpp_threshold
                 , null         as dpp_fixed_count
              from fcl_limit
             where id = (
                        select distinct
                               convert_to_number(first_value(attr_value) over (order by start_date desc)) as hybrid_threshold
                          from prd_attribute_value
                         where 1 = 1
                           and attr_id = (select id
                                            from prd_attribute
                                           where attr_name = 'ISS_HYBRID_THREDHOLD_VALUE')
                           and entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD --'ENTTCARD'
                           and object_id = l_card_id
                           and start_date < get_sysdate
                           and (end_date > get_sysdate or end_date is null)
                        )

            union all

            select null as notif_channel
                 , null as enable_hybrid
                 , null as hybrid_threshold
                 , nvl(
                        (
                        select distinct
                               convert_to_number(first_value(attr_value) over (order by start_date desc)) as auto_dpp
                          from prd_attribute_value
                         where 1 = 1
                           and attr_id = (select id
                                            from prd_attribute
                                           where attr_name = 'DPP_USE_AUTOCREATION')
                           and entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
                           and object_id = l_account_id
                           and start_date < get_sysdate
                           and (end_date > get_sysdate or end_date is null)
                        ),
                        (
                        select distinct
                               convert_to_number(first_value(attr_value) over (order by start_date desc)) as auto_dpp
                          from prd_attribute_value
                         where 1 = 1
                           and attr_id = (select id
                                            from prd_attribute
                                           where attr_name = 'DPP_USE_AUTOCREATION')
                           and entity_type = prd_api_const_pkg.ENTITY_TYPE_PRODUCT -- ENTTPROD
                           and object_id in (select id
                                               from prd_product
                                              start with id = l_product_id
                                              connect by id = prior parent_id)
                           and start_date < get_sysdate
                           and (end_date > get_sysdate or end_date is null)
                        )
                      ) as auto_dpp
                 , null as dpp_threshold
                 , null as dpp_fixed_count
              from dual

            union all

            select null         as notif_channel
                 , null         as enable_hybrid
                 , null         as hybrid_threshold
                 , null         as auto_dpp
                 , fixed_rate   as dpp_threshold
                 , null         as dpp_fixed_count
              from fcl_fee_tier
             where fee_id = (
                            select distinct
                                   convert_to_number(first_value(attr_value) over (order by start_date desc)) as dpp_threshold
                              from prd_attribute_value
                             where 1 = 1
                               and attr_id = (select id
                                                from prd_attribute
                                               where attr_name = 'DPP_AUTOCREATION_THRESHOLD')
                               and entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
                               and object_id = l_account_id
                               and start_date < get_sysdate
                               and (end_date > get_sysdate or end_date is null)
                            )

            union all

            select null as notif_channel
                 , null as enable_hybrid
                 , null as hybrid_threshold
                 , null as auto_dpp
                 , null as dpp_threshold
                 , nvl(
                        (
                        select distinct
                               convert_to_number(first_value(attr_value) over (order by start_date desc)) as dpp_fixed_count
                          from prd_attribute_value
                         where 1 = 1
                           and attr_id = (select id
                                            from prd_attribute
                                           where attr_name = 'DPP_INSTALMENT_COUNT')
                           and entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT --'ENTTACCT'
                           and object_id = l_account_id
                           and start_date < get_sysdate
                           and (end_date > get_sysdate or end_date is null)
                        ),
                        (
                        select distinct
                               convert_to_number(first_value(attr_value) over (order by start_date desc)) as dpp_fixed_count
                          from prd_attribute_value
                         where 1 = 1
                           and attr_id = (select id
                                            from prd_attribute
                                           where attr_name = 'DPP_INSTALMENT_COUNT')
                           and entity_type = prd_api_const_pkg.ENTITY_TYPE_PRODUCT -- ENTTPROD
                           and object_id in (select id
                                               from prd_product
                                              start with id = l_product_id
                                              connect by id = prior parent_id)
                           and start_date < get_sysdate
                           and (end_date > get_sysdate or end_date is null)
                        )
                      ) as dpp_fixed_count
              from dual
            );
exception
    when no_data_found then
        null;
end get_card_acct_for_sup_card;

procedure get_customer_crd_invoice_info(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_customer_id           in      com_api_type_pkg.t_medium_id
  , o_ref_cursor            out     com_api_type_pkg.t_ref_cur
)
is
    l_inst_id               com_api_type_pkg.t_inst_id;
begin

    l_inst_id := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

    open o_ref_cursor for
    select iv.invoice_id
         , a.account_number as credit_account_number
         , iv.total_amount_due as total_amount_due
         , iv.min_amount_due as min_amount_due
         , om.overdue_balance
         , pm.amount as payment_amount
         , iv.due_date
         , iv.expense_amount
      from prd_customer cu
         , prd_contract pc
         , prd_service s
         , prd_service_object so
         , acc_account a
         , (select i.id as invoice_id
                 , i.account_id
                 , i.total_amount_due
                 , i.min_amount_due
                 , i.due_date
                 , i.expense_amount
                 , row_number() over(partition by i.account_id order by i.serial_number desc) as rng
              from crd_invoice i
           ) iv
         , (select sum(amount) as amount
                 , invoice_id
              from (select cp.amount
                         , cid.invoice_id
                      from crd_debt_payment dp
                         , crd_invoice_debt cid
                         , crd_payment cp
                         , opr_operation oo
                     where dp.pay_id = cp.id
                       and dp.debt_id = cid.debt_id
                       and oo.id = cp.oper_id
                       and cp.is_reversal = com_api_const_pkg.FALSE
                       and not exists (select 1
                                         from opr_operation
                                        where original_id = oo.id
                                          and is_reversal = com_api_const_pkg.TRUE)
                  group by oo.id
                         , cp.amount
                         , cid.invoice_id)
             group by invoice_id
           ) pm
         , (select sum(amount) as overdue_balance
                 , invoice_id
              from (select cdb.amount
                         , cid.invoice_id
                      from crd_debt cd
                         , crd_debt_balance cdb
                         , crd_invoice_debt cid
                     where cd.id = cdb.debt_id
                       and cd.id = cid.debt_id
                       and cdb.balance_type in ( cst_woo_const_pkg.BALANCE_TYPE_OVERDUE          --'BLTP1004'
                                               , cst_woo_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST --'BLTP1005'
                                               )
                       and cd.status = crd_api_const_pkg.DEBT_STATUS_ACTIVE --'DBTSACTV'
                  group by cd.id
                         , cdb.amount
                         , cid.invoice_id)
             group by invoice_id
           ) om
     where 1 = 1
       and cu.id = i_customer_id
       and cu.inst_id = l_inst_id
       and pc.customer_id = cu.id
       and s.service_type_id = crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID --10000403
       and so.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT       --'ENTTACCT'
       and so.service_id = s.id
       and so.contract_id = pc.id
       and so.object_id = a.id
       and a.id = iv.account_id(+)
       and 4 > iv.rng(+)
       and iv.invoice_id = pm.invoice_id(+)
       and iv.invoice_id = om.invoice_id(+)
       ;
end get_customer_crd_invoice_info;

procedure get_crd_invoice_payments_info(
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_invoice_id            in      com_api_type_pkg.t_medium_id
  , o_ref_cursor            out     com_api_type_pkg.t_ref_cur
)
is
    l_inst_id               com_api_type_pkg.t_inst_id;
begin

    l_inst_id := nvl(i_inst_id, cst_woo_const_pkg.W_INST);

    open o_ref_cursor for
    select oper_date, amount
      from (
            select distinct 
                   dp.pay_amount
                 , cid.debt_id
                 , oo.oper_date
                 , oo.id as oper_id
                 , cp.amount
              from crd_debt_payment dp
                 , crd_invoice_debt cid
                 , crd_payment cp
                 , opr_operation oo
             where dp.pay_id = cp.id
               and dp.debt_id = cid.debt_id
               and oo.id = cp.oper_id
               and cp.inst_id = l_inst_id
               and cid.invoice_id = i_invoice_id
               and cp.is_reversal = com_api_const_pkg.FALSE
               and not exists (select 1 
                                 from opr_operation 
                                where original_id = oo.id 
                                  and is_reversal = com_api_const_pkg.TRUE)
           )
     group by oper_date
            , oper_id
            , amount
     order by oper_date
            , oper_id
            ;
end get_crd_invoice_payments_info;

function check_special_card_number(
    i_card_number           in      com_api_type_pkg.t_card_number
) return com_api_type_pkg.t_boolean
is
    l_is_used               com_api_type_pkg.t_boolean;
begin
    --Check special card number is used or not
    begin
        select is_used
          into l_is_used
          from cst_woo_card_chosen
         where reverse(card_number) = reverse(i_card_number); -- support indexes
    exception
        when no_data_found then
            l_is_used := com_api_const_pkg.FALSE;
    end;

    if l_is_used = com_api_const_pkg.FALSE and iss_api_card_pkg.get_card_id(i_card_number) is null then
        return com_api_const_pkg.TRUE;
    else
        return com_api_const_pkg.FALSE;
    end if;

end check_special_card_number;

procedure update_card_number_used(
    i_card_number           in      com_api_type_pkg.t_card_number
)
is
begin
    update cst_woo_card_chosen
       set is_used = com_api_const_pkg.TRUE
     where reverse(card_number) = reverse(i_card_number); -- support indexes
exception
    when others then
        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error       => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
            );
        end if;
end update_card_number_used;

function get_contract_by_card_number(
    i_card_number           in      com_api_type_pkg.t_card_number
) return com_api_type_pkg.t_name
is
begin
    return prd_api_contract_pkg.get_contract_number(
               i_contract_id => iss_api_card_pkg.get_card(i_card_number => i_card_number).contract_id
           );
end get_contract_by_card_number;

procedure get_services_by_card_number(
    i_card_number           in      com_api_type_pkg.t_card_number
  , o_ref_cursor            out     com_api_type_pkg.t_ref_cur
)
is
begin
    open o_ref_cursor for
    select distinct service_id
      from prd_service_object so
         , iss_card_number cn
     where so.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD --'ENTTCARD'
       and so.object_id = cn.card_id
       and so.status = prd_api_const_pkg.SERVICE_OBJECT_STATUS_ACTIVE --'SROS0020'
       and reverse(cn.card_number) = reverse(i_card_number); -- support indexes
end get_services_by_card_number;

procedure get_dpp_intr_rate_by_account(
    i_account_id            in      com_api_type_pkg.t_medium_id
  , o_ref_cursor            out     com_api_type_pkg.t_ref_cur
)
is
    l_account_id            com_api_type_pkg.t_medium_id;
    l_product_id            com_api_type_pkg.t_medium_id;
    l_count                 com_api_type_pkg.t_count := 0;
begin

    l_product_id := prd_api_product_pkg.get_product_id(
                        i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                      , i_object_id     => i_account_id
                    );

    select count(1)
      into l_count
      from prd_attribute_value a
         , fcl_fee_tier f
     where 1 = 1
       and f.fee_id = convert_to_number(a.attr_value)
       and a.attr_id = (select id
                          from prd_attribute
                         where attr_name = 'DPP_INTEREST_RATE')
       and a.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
       and a.object_id   = i_account_id
       and (a.end_date > get_sysdate or a.end_date is null)
     order by f.id;

    if l_count > 0 then
        open o_ref_cursor for
        select a.mod_id
             , get_text('RUL_MOD','NAME', a.mod_id) as mod_name
             , f.fee_id
             , fcl_ui_fee_pkg.get_fee_desc(f.fee_id) as fee_desc
          from prd_attribute_value a
             , fcl_fee_tier f
         where 1 = 1
           and f.fee_id = convert_to_number(a.attr_value)
           and a.attr_id = (select id
                              from prd_attribute
                             where attr_name = 'DPP_INTEREST_RATE')
           and a.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
           and a.object_id   = i_account_id
           and (a.end_date > get_sysdate or a.end_date is null)
         order by f.id;
    else
        open o_ref_cursor for
        select a.mod_id
             , get_text('RUL_MOD','NAME', a.mod_id) as mod_name
             , f.fee_id
             , fcl_ui_fee_pkg.get_fee_desc(f.fee_id) as fee_desc
          from prd_attribute_value a
             , fcl_fee_tier f
         where 1 = 1
           and f.fee_id = convert_to_number(a.attr_value)
           and a.attr_id = (select id
                              from prd_attribute
                             where attr_name = 'DPP_INTEREST_RATE')
           and a.entity_type = prd_api_const_pkg.ENTITY_TYPE_PRODUCT
           and a.object_id   = l_product_id
           and (a.end_date > get_sysdate or a.end_date is null)
         order by f.id;
    end if;

end get_dpp_intr_rate_by_account;

procedure get_dpp_opr_selection(
    i_account_number        in      com_api_type_pkg.t_account_number
  , i_from_date             in      date
  , i_to_date               in      date
  , o_ref_cur               out     com_api_type_pkg.t_ref_cur
) is
begin
    open o_ref_cur for
    select mc.account_id
         , mc.account_number
         , mc.card_id
         , mc.card_number
         , mc.macros_id
         , mc.macros_type_id
         , mc.macros_type_name
         , mc.macros_type_description
         , mc.macros_type_details
         , mc.oper_date
         , mc.macros_amount
         , mc.macros_currency
         , mc.posting_date
         , mc.oper_id
         , mc.oper_type
         , mc.oper_description
         , mc.lang
         , op.merchant_name
      from dpp_ui_macros_vw mc
	 , opr_operation op
     where case when i_account_number is not null then
                reverse(mc.account_number)
           else
                '1'
           end like reverse('%'||nvl(i_account_number, '1')|| '%')
       and mc.oper_date between i_from_date and nvl(i_to_date, get_sysdate)
       and mc.macros_type_id = cst_woo_const_pkg.MACROS_TYPE_ID_DEBIT_ON_OPER --1004
       and mc.lang = com_api_const_pkg.LANGUAGE_ENGLISH
       and op.id = mc.oper_id;
end get_dpp_opr_selection;

procedure get_dpp_registration(
    i_card_number           in      com_api_type_pkg.t_card_number
  , i_account_number        in      com_api_type_pkg.t_account_number
  , i_from_date             in      date
  , i_to_date               in      date
  , o_ref_cur               out     com_api_type_pkg.t_ref_cur
) is
begin
    open o_ref_cur for
    select pp.id
         , pp.oper_id
         , pp.oper_type
         , pp.oper_desc
         , pp.merchant_name
         , pp.merchant_city
         , pp.merchant_street
         , pp.instalment_amount
         , pp.instalment_total
         , pp.instalment_billed
         , pp.next_instalment_date
         , pp.debt_balance
         , pp.account_id
         , pp.account_number
         , pp.card_id
         , pp.card_mask
         , pp.product_id
         , pp.oper_date
         , pp.oper_amount
         , pp.oper_currency
         , pp.currency
         , pp.dpp_amount
         , pp.interest_amount
         , pp.status
         , pp.inst_id
         , pp.split_hash
         , pp.lang
         , av.value
      from dpp_ui_payment_plan_vw pp
         , dpp_ui_attribute_value_vw av
     where pp.id    = av.dpp_id(+)
       and pp.lang  = av.lang(+)
       and av.attr_name = dpp_api_const_pkg.ATTR_ALGORITHM
       and pp.lang  = com_api_const_pkg.LANGUAGE_ENGLISH
       and case when i_account_number is not null then
                reverse(pp.account_number)
           else
                '1'
           end like reverse('%'||nvl(i_account_number, '1')|| '%')
       and case when i_card_number is not null then
                reverse(pp.card_mask)
           else
                '1'
           end like reverse('%'||nvl(iss_api_card_pkg.get_card_mask (i_card_number), '1')|| '%')
       and pp.oper_date between i_from_date and nvl(i_to_date, get_sysdate);
exception
    when no_data_found then
        null;
end get_dpp_registration;

procedure get_dpp_installment_detail(
    i_dpp_id                in     com_api_type_pkg.t_long_id
  , o_ref_cur               out     com_api_type_pkg.t_ref_cur
) is
begin
    open o_ref_cur for
    select iv.id
         , iv.dpp_id
         , iv.instalment_number
         , iv.instalment_date
         , iv.instalment_amount - iv.interest_amount as instalment_amount
         , iv.payment_amount
         , iv.interest_amount
         , iv.macros_id
         , iv.is_bill
         , iv.acceleration_type
         , iv.split_hash
         , iv.currency
      from dpp_ui_instalment_vw iv
     where iv.dpp_id = i_dpp_id
     order by iv.instalment_number;
exception
    when no_data_found then
        null;
end get_dpp_installment_detail;

procedure get_dpp_amount_detail(
    i_dpp_id            in     com_api_type_pkg.t_long_id
  , o_dpp_amount        out    com_api_type_pkg.t_money
  , o_dpp_adv_amount    out    com_api_type_pkg.t_money
  , o_dpp_remain_amount out    com_api_type_pkg.t_money
) is
begin
    select dpp_amount
      into o_dpp_amount
      from dpp_payment_plan
     where id = i_dpp_id
       and rownum = 1;

    select sum(instalment_amount)
      into o_dpp_remain_amount
      from dpp_instalment
     where dpp_id = i_dpp_id
       and macros_id is null;

    select sum(payment_amount)
      into o_dpp_adv_amount
      from dpp_instalment
     where dpp_id = i_dpp_id
       and acceleration_type is not null
       and payment_amount is not null;
exception
    when no_data_found then
        null;
end get_dpp_amount_detail;

procedure accelerate_dpp(
    i_dpp_id                in     com_api_type_pkg.t_long_id
  , i_new_count             in     com_api_type_pkg.t_tiny_id    default null
  , i_payment_amount        in     com_api_type_pkg.t_money      default null
  , i_acceleration_type     in     com_api_type_pkg.t_dict_value
) is
begin
    dpp_api_payment_plan_pkg.accelerate_dpp(
        i_dpp_id            => i_dpp_id
      , i_new_count         => i_new_count
      , i_payment_amount    => i_payment_amount
      , i_acceleration_type => i_acceleration_type
    );

    insert into cst_woo_dpp_payment_his(
        dpp_id
      , new_count
      , payment_date
      , payment_amount
      , acceleration_type
    )
    values (
        i_dpp_id
      , i_new_count
      , get_sysdate
      , i_payment_amount
      , i_acceleration_type
    );
end accelerate_dpp;

procedure get_dpp_early_payment_his(
    i_dpp_id                in      com_api_type_pkg.t_long_id
  , o_ref_cur               out     com_api_type_pkg.t_ref_cur
) is
begin

    open o_ref_cur for
    select pay.dpp_id
         , pay.new_count
         , pay.payment_date
         , pay.payment_amount
         , pay.acceleration_type ||' - '|| com_api_dictionary_pkg.get_article_text(pay.acceleration_type) as acceleration_type
         , cst_woo_com_pkg.get_cycle_date(
                    i_cycle_type      => crd_api_const_pkg.OVERDUE_DATE_CYCLE_TYPE  --'CYTP1008'
                  , i_entity_type     => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT      --'ENTTACCT'
                  , i_object_id       => aac.id
                  , i_split_hash      => aac.split_hash
                  , i_from_date       => com_api_const_pkg.FALSE
           ) as next_due_date
      from cst_woo_dpp_payment_his pay
         , dpp_payment_plan dpp
         , acc_account aac
     where dpp.id = pay.dpp_id
       and aac.id = dpp.account_id
       and aac.split_hash = dpp.split_hash
       and pay.dpp_id = i_dpp_id
  order by pay.payment_date desc;
exception
    when no_data_found then
        null;
end get_dpp_early_payment_his;

procedure change_card_status(
    i_card_number           in      com_api_type_pkg.t_card_number
  , i_reason                in      com_api_type_pkg.t_dict_value
  , o_result                out     com_api_type_pkg.t_boolean
)
is
    l_card_instace_id       com_api_type_pkg.t_medium_id;
    l_card_id               com_api_type_pkg.t_medium_id;
    l_event_type            com_api_type_pkg.t_dict_value;
    l_params                com_api_type_pkg.t_param_tab;
begin

    l_card_id := iss_api_card_pkg.get_card_id(i_card_number => i_card_number);
    l_card_instace_id := iss_api_card_instance_pkg.get_card_instance_id(i_card_id => l_card_id);
    l_event_type := i_reason;

    if l_event_type is null then
        o_result := com_api_type_pkg.FALSE;
    else
        o_result := com_api_type_pkg.TRUE;
        begin
            evt_api_status_pkg.change_status (
                i_event_type    => l_event_type
              , i_initiator     => evt_api_const_pkg.INITIATOR_OPERATOR
              , i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
              , i_object_id     => l_card_instace_id
              , i_reason        => i_reason
              , i_params        => l_params
            );
        exception
            when others then
                o_result := com_api_type_pkg.FALSE;
        end;
    end if;

end change_card_status;

procedure get_repayment_priorities(
    i_card_number           in      com_api_type_pkg.t_card_number
  , i_lang                  in      com_api_type_pkg.t_dict_value       default null
  , o_ref_cur                  out  sys_refcursor
) 
is
    l_card_id               com_api_type_pkg.t_medium_id;
    l_account_rec           acc_api_type_pkg.t_account_rec;
    l_sysdate               date;
begin
    l_sysdate := com_api_sttl_day_pkg.get_sysdate;

    l_card_id :=
        iss_api_card_pkg.get_card_id(
            i_card_number   => i_card_number
        );

    l_account_rec :=
        acc_api_account_pkg.get_account(
            i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD
          , i_object_id     => l_card_id
          , i_account_type  => acc_api_const_pkg.ACCOUNT_TYPE_CREDIT
        );

    open o_ref_cur for
    select mod_name             as repay_priority_mod_name
         , attr_number_value    as repay_priority
      from prd_ui_attribute_value_vw
     where 1 = 1
       and attr_name    = crd_api_const_pkg.REPAYMENT_PRIORITY
       and lang         = nvl(i_lang, get_user_lang)
       and entity_type  = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
       and object_id    = l_account_rec.account_id
       and start_date   < l_sysdate
       and (end_date    > l_sysdate
            or end_date is null)
      order by mod_name;

exception
    when no_data_found then
        null;
end get_repayment_priorities;

procedure get_debts_prioritize(
    i_card_number           in      com_api_type_pkg.t_card_number
  , i_low_repay_priority    in      com_api_type_pkg.t_dict_value       default null
  , o_ref_cur                  out  sys_refcursor
)
is
    l_cur_debts             sys_refcursor;
    l_sysdate               date;
    l_card_id               com_api_type_pkg.t_medium_id;
    l_account_rec           acc_api_type_pkg.t_account_rec;
    l_debt_tab              crd_api_type_pkg.t_payment_debt_tab;
    l_debt_balance_id_tab   num_tab_tpt := num_tab_tpt();
begin
    l_sysdate := com_api_sttl_day_pkg.get_sysdate;

    l_card_id :=
        iss_api_card_pkg.get_card_id(
            i_card_number   => i_card_number
        );

    l_account_rec :=
        acc_api_account_pkg.get_account(
            i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD
          , i_object_id     => l_card_id
          , i_account_type  => acc_api_const_pkg.ACCOUNT_TYPE_CREDIT
        );

    crd_payment_pkg.enum_debt_order(
        o_cur_debts         => l_cur_debts
      , i_account_id        => l_account_rec.account_id
      , i_split_hash        => l_account_rec.split_hash
      , i_eff_date          => l_sysdate
      , i_inst_id           => l_account_rec.inst_id
    );

    fetch l_cur_debts bulk collect into l_debt_tab;

    for i in 1 .. l_debt_tab.count loop
        l_debt_balance_id_tab.extend;
        l_debt_balance_id_tab(l_debt_balance_id_tab.count) := l_debt_tab(i).debt_balance_id;
    end loop;

    close l_cur_debts;

    open o_ref_cur for
    select db.repay_priority as mod_name
         , db.repay_priority as repay_priority
         , db.amount         as debt_amount
         , d.currency        as debt_currency
         , d.oper_date       as oper_date
         , d.posting_date    as posting_date
         , o.merchant_name   as merchant_name
         , o.oper_amount     as oper_amount
         , o.oper_currency   as oper_currency
     from crd_debt_balance db
        , crd_debt d
        , opr_operation o
    where 1 = 1
      and d.id  = db.debt_id
      and d.oper_id = o.id
      and db.repay_priority <= i_low_repay_priority
      and db.id in (select column_value from table(cast(l_debt_balance_id_tab as num_tab_tpt)))
 order by db.repay_priority
        , d.oper_date;

exception
    when no_data_found then
        null;
end get_debts_prioritize;

procedure get_projected_debt_repayment(
    i_card_number           in      com_api_type_pkg.t_card_number
  , i_payment_amount        in      com_api_type_pkg.t_money        default null
  , o_ref_cur                  out  sys_refcursor
)
is
    l_cur_debts             sys_refcursor;
    l_sysdate               date;
    l_card_id               com_api_type_pkg.t_medium_id;
    l_account_rec           acc_api_type_pkg.t_account_rec;
    l_debt_tab              crd_api_type_pkg.t_payment_debt_tab;
    l_repay_amount_tab      com_param_map_tpt           := com_param_map_tpt();
    l_payment_amount        com_api_type_pkg.t_money    := 0; 
    l_count                 com_api_type_pkg.t_count    := 0;
begin
    l_sysdate := com_api_sttl_day_pkg.get_sysdate;

    l_card_id :=
        iss_api_card_pkg.get_card_id(
            i_card_number   => i_card_number
        );

    l_account_rec :=
        acc_api_account_pkg.get_account(
            i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD
          , i_object_id     => l_card_id
          , i_account_type  => acc_api_const_pkg.ACCOUNT_TYPE_CREDIT
        );

    crd_payment_pkg.enum_debt_order(
        o_cur_debts         => l_cur_debts
      , i_account_id        => l_account_rec.account_id
      , i_split_hash        => l_account_rec.split_hash
      , i_eff_date          => l_sysdate
      , i_inst_id           => l_account_rec.inst_id
    );

    fetch l_cur_debts bulk collect into l_debt_tab;

    l_payment_amount := i_payment_amount;

    l_count := 1;
    while l_payment_amount > 0 and l_count <= l_debt_tab.count
    loop
        l_repay_amount_tab.extend;
        l_repay_amount_tab(l_repay_amount_tab.count) :=
            com_param_map_tpr(
                to_char(l_debt_tab(l_count).debt_balance_id)
              , null
              , least(l_debt_tab(l_count).amount, l_payment_amount)
              , null
              , null
            );
        l_payment_amount    := l_payment_amount - l_debt_tab(l_count).amount;
        l_count             := l_count + 1;
    end loop;

    close l_cur_debts;

    open o_ref_cur for
    select db.repay_priority as mod_name
         , db.repay_priority as repay_priority
         , db.amount         as debt_amount
         , d.currency        as debt_currency
         , d.oper_date       as oper_date
         , d.posting_date    as posting_date
         , o.merchant_name   as merchant_name
         , o.oper_amount     as oper_amount
         , o.oper_currency   as oper_currency
         , ra.number_value   as repay_amount
     from crd_debt_balance db
        , crd_debt d
        , opr_operation o
        , table(cast(l_repay_amount_tab as com_param_map_tpt)) ra
    where 1 = 1
      and d.id  = db.debt_id
      and d.oper_id = o.id
      and db.id = to_number(ra.name)
 order by db.repay_priority
        , d.oper_date;

exception
    when no_data_found then
        null;
end get_projected_debt_repayment;

end;
/
