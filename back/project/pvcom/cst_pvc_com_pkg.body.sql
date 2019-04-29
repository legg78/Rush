create or replace package body cst_pvc_com_pkg as

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
                                              when c.category = iss_api_const_pkg.CARD_CATEGORY_PRIMARY then 1
                                              when c.category = iss_api_const_pkg.CARD_CATEGORY_DOUBLE then 2
                                              when c.category = iss_api_const_pkg.CARD_CATEGORY_UNDEFINED then 3
                                              when c.category = iss_api_const_pkg.CARD_CATEGORY_VIRTUAL then 4
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


function iss_and_acq_agents_are_same (
    i_oper_id               in    com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean
is
    l_participant_iss         opr_api_type_pkg.t_oper_part_rec;
    l_participant_acq         opr_api_type_pkg.t_oper_part_rec;
    l_iss_agent_id            com_api_type_pkg.t_agent_id;
    l_merchant_contract       prd_api_type_pkg.t_contract;
begin
    opr_api_operation_pkg.get_participant(
        i_oper_id             => i_oper_id
      , i_participaint_type   => com_api_const_pkg.PARTICIPANT_ISSUER
      , o_participant         => l_participant_iss
    );
    
    opr_api_operation_pkg.get_participant(
        i_oper_id             => i_oper_id
      , i_participaint_type   => com_api_const_pkg.PARTICIPANT_ACQUIRER
      , o_participant         => l_participant_acq
    );

    begin
        select p.agent_id
          into l_iss_agent_id
          from iss_card     c
             , prd_contract p
         where c.id          = l_participant_iss.card_id
           and c.contract_id = p.id
           and c.split_hash  = p.split_hash;
    exception
        when no_data_found then
            null;
    end;

    l_merchant_contract :=
        acq_api_merchant_pkg.get_merchant_contract(
            i_merchant_id        => l_participant_acq.merchant_id
        );

    if l_merchant_contract.agent_id = l_iss_agent_id then
        return com_api_const_pkg.TRUE;
    else
        return com_api_const_pkg.FALSE;
    end if;

end iss_and_acq_agents_are_same;


function check_overlimit (
    i_entity_type           in    com_api_type_pkg.t_dict_value
  , i_object_id             in    com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean
is
    l_account_id         com_api_type_pkg.t_account_id;
    l_current_balance    com_api_type_pkg.t_money;
    l_assigned_limit     com_api_type_pkg.t_money;
    l_split_hash         com_api_type_pkg.t_tiny_id;
    l_result             com_api_type_pkg.t_boolean;
begin
    if i_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        l_account_id := i_object_id;
    else
        com_api_error_pkg.raise_error(
            i_error       => 'ENTITY_TYPE_NOT_SUPPORTED'
          , i_env_param1  => i_entity_type
        );
    end if;
    
    l_split_hash := 
        com_api_hash_pkg.get_split_hash (
            i_entity_type    => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id      => l_account_id
          , i_mask_error     => com_api_const_pkg.TRUE
        );
    
    select sum(cdb.amount)
      into l_current_balance
      from crd_debt_balance cdb
         , crd_debt cd
     where cd.id = cdb.debt_id
       and cdb.split_hash = l_split_hash
       and cd.split_hash = l_split_hash
       and cd.account_id = l_account_id
       and cdb.balance_type in (
               acc_api_const_pkg.BALANCE_TYPE_OVERDRAFT -- BLTP1002
             , acc_api_const_pkg.BALANCE_TYPE_OVERDUE   -- BLTP1004
             , acc_api_const_pkg.BALANCE_TYPE_OVERLIMIT -- BLTP1007
           )
       and nvl(cd.fee_type, '-') not in (
               crd_api_const_pkg.PENALTY_RATE_FEE_TYPE  -- FETP1003
             , cst_apc_const_pkg.FEE_TYPE_CARD_ANNUAL   -- FETP0102
           );

    l_assigned_limit :=
        acc_api_balance_pkg.get_balance_amount(
            i_account_id    => l_account_id
          , i_balance_type  => crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED
          , i_mask_error    => com_api_type_pkg.TRUE
        ).amount;
    
    if nvl(l_current_balance, 0) > nvl(l_assigned_limit, 0) then
        l_result := com_api_type_pkg.TRUE;
    else
        l_result := com_api_type_pkg.FALSE;
    end if;

    trc_log_pkg.debug (
        i_text          => 'cst_pvc_com_pkg.check_overlimit: account id [#1], current amount [#2], assigned limit [#3]'
      , i_env_param1    => l_account_id
      , i_env_param2    => l_current_balance
      , i_env_param3    => l_assigned_limit
    );
    
    return l_result;

end check_overlimit;


function check_annual_fee_is_charged (
    i_entity_type           in    com_api_type_pkg.t_dict_value
  , i_object_id             in    com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean
is
    l_result                    com_api_type_pkg.t_boolean;  
    l_card_id                   com_api_type_pkg.t_long_id;
    l_card_instance_id          com_api_type_pkg.t_long_id;
    l_card                      iss_api_type_pkg.t_card_rec;
    l_split_hash                com_api_type_pkg.t_tiny_id;
    l_previous_date             date;
    l_next_date                 date;
begin

    if i_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE then
        l_card :=
            iss_api_card_pkg.get_card(
                i_card_instance_id  => i_object_id
              , i_mask_error        => com_api_const_pkg.FALSE
            );
        l_card_id := l_card.id;
        l_split_hash := l_card.split_hash;
        l_card_instance_id := i_object_id;
    else
        com_api_error_pkg.raise_error(
            i_error       => 'ENTITY_TYPE_NOT_SUPPORTED'
          , i_env_param1  => i_entity_type
        );
    end if;
    
    fcl_api_cycle_pkg.get_cycle_date(
        i_cycle_type   => 'CYTP0104'
      , i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CARD
      , i_object_id    => l_card_id
      , i_split_hash   => l_split_hash
      , i_add_counter  => com_api_type_pkg.FALSE
      , o_prev_date    => l_previous_date
      , o_next_date    => l_next_date
    );
    
    select case when count(oo.id) > 0 
                then com_api_const_pkg.TRUE 
                else com_api_const_pkg.FALSE
           end
      into l_result
      from opr_operation oo
         , opr_participant op
     where oo.id = op.oper_id
       and op.split_hash = l_split_hash
       and oo.oper_type = opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE
       and oo.oper_reason = cst_apc_const_pkg.FEE_TYPE_CARD_ANNUAL -- 'FETP0102'
       and op.card_id in (
               select card_id
                 from iss_card_instance
                where split_hash = l_split_hash
                start with id = l_card_instance_id
              connect by prior preceding_card_instance_id = id
           )
       and oo.oper_date >= trunc(l_previous_date);

    trc_log_pkg.debug (
        i_text          => 'Annual fee charged [#1] [#2], entity type [#3], object id [#4], l_card_id [#5]'
      , i_env_param1    => l_result
      , i_env_param2    => to_char(l_previous_date, 'dd-mon-yyyy')
      , i_env_param3    => i_entity_type
      , i_env_param4    => i_object_id
      , i_env_param5    => l_card_id
    );

    return l_result;
end check_annual_fee_is_charged;

end cst_pvc_com_pkg;
/
