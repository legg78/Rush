create or replace package body opr_api_operation_pkg is
/************************************************************
 * Provides an API for creating operation. <br />
 * Last changed by $Author: maslov $ <br />
 * $LastChangedDate:: #$ <br />
 * Revision: $LastChangedRevision:  $ <br />
 * Module: OPR_API_GET_PKG <br />
 * @headcom
 *************************************************************/


type t_type_tab is table of com_api_type_pkg.t_boolean index by com_api_type_pkg.t_dict_value;

g_type_list     t_type_tab;
g_is_loaded     com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;

procedure get_operation(
    i_oper_id             in  com_api_type_pkg.t_long_id
  , o_operation           out opr_api_type_pkg.t_oper_rec
) is
    l_operation opr_api_type_pkg.t_oper_rec;
begin
    begin
        select o.id
             , o.session_id
             , o.is_reversal
             , o.original_id
             , o.oper_type
             , o.oper_reason
             , o.msg_type
             , o.status
             , o.status_reason
             , o.sttl_type
             , o.terminal_type
             , o.acq_inst_bin
             , o.forw_inst_bin
             , o.merchant_number
             , o.terminal_number
             , o.merchant_name
             , o.merchant_street
             , o.merchant_city
             , o.merchant_region
             , o.merchant_country
             , o.merchant_postcode
             , o.mcc
             , o.originator_refnum
             , o.network_refnum
             , o.oper_count
             , o.oper_request_amount
             , o.oper_amount_algorithm
             , o.oper_amount
             , o.oper_currency
             , o.oper_cashback_amount
             , o.oper_replacement_amount
             , o.oper_surcharge_amount
             , o.oper_date
             , o.host_date
             , o.unhold_date
             , o.match_status
             , o.sttl_amount
             , o.sttl_currency
             , o.dispute_id
             , o.payment_order_id
             , o.payment_host_id
             , o.forced_processing
             , o.match_id
             , o.proc_mode
             , o.clearing_sequence_num
             , o.clearing_sequence_count
             , o.incom_sess_file_id
             , o.sttl_date
             , o.acq_sttl_date
          into l_operation.id
             , l_operation.session_id
             , l_operation.is_reversal
             , l_operation.original_id
             , l_operation.oper_type
             , l_operation.oper_reason
             , l_operation.msg_type
             , l_operation.status
             , l_operation.status_reason
             , l_operation.sttl_type
             , l_operation.terminal_type
             , l_operation.acq_inst_bin
             , l_operation.forw_inst_bin
             , l_operation.merchant_number
             , l_operation.terminal_number
             , l_operation.merchant_name
             , l_operation.merchant_street
             , l_operation.merchant_city
             , l_operation.merchant_region
             , l_operation.merchant_country
             , l_operation.merchant_postcode
             , l_operation.mcc
             , l_operation.originator_refnum
             , l_operation.network_refnum
             , l_operation.oper_count
             , l_operation.oper_request_amount
             , l_operation.oper_amount_algorithm
             , l_operation.oper_amount
             , l_operation.oper_currency
             , l_operation.oper_cashback_amount
             , l_operation.oper_replacement_amount
             , l_operation.oper_surcharge_amount
             , l_operation.oper_date
             , l_operation.host_date
             , l_operation.unhold_date
             , l_operation.match_status
             , l_operation.sttl_amount
             , l_operation.sttl_currency
             , l_operation.dispute_id
             , l_operation.payment_order_id
             , l_operation.payment_host_id
             , l_operation.forced_processing
             , l_operation.match_id
             , l_operation.proc_mode
             , l_operation.clearing_sequence_num
             , l_operation.clearing_sequence_count
             , l_operation.incom_sess_file_id
             , l_operation.sttl_date
             , l_operation.acq_sttl_date
          from opr_operation o
         where o.id = i_oper_id;
    exception
        when no_data_found then
            null;
    end;
    o_operation := l_operation;
end;

function get_operation(
    i_external_auth_id        in     com_api_type_pkg.t_attr_name
) return opr_api_type_pkg.t_oper_rec
is
    l_operation opr_api_type_pkg.t_oper_rec;
begin
        select o.id
             , o.session_id
             , o.is_reversal
             , o.original_id
             , o.oper_type
             , o.oper_reason
             , o.msg_type
             , o.status
             , o.status_reason
             , o.sttl_type
             , o.terminal_type
             , o.acq_inst_bin
             , o.forw_inst_bin
             , o.merchant_number
             , o.terminal_number
             , o.merchant_name
             , o.merchant_street
             , o.merchant_city
             , o.merchant_region
             , o.merchant_country
             , o.merchant_postcode
             , o.mcc
             , o.originator_refnum
             , o.network_refnum
             , o.oper_count
             , o.oper_request_amount
             , o.oper_amount_algorithm
             , o.oper_amount
             , o.oper_currency
             , o.oper_cashback_amount
             , o.oper_replacement_amount
             , o.oper_surcharge_amount
             , o.oper_date
             , o.host_date
             , o.unhold_date
             , o.match_status
             , o.sttl_amount
             , o.sttl_currency
             , o.dispute_id
             , o.payment_order_id
             , o.payment_host_id
             , o.forced_processing
             , o.match_id
             , o.proc_mode
             , o.clearing_sequence_num
             , o.clearing_sequence_count
             , o.incom_sess_file_id
             , o.sttl_date
             , o.acq_sttl_date
          into l_operation.id
             , l_operation.session_id
             , l_operation.is_reversal
             , l_operation.original_id
             , l_operation.oper_type
             , l_operation.oper_reason
             , l_operation.msg_type
             , l_operation.status
             , l_operation.status_reason
             , l_operation.sttl_type
             , l_operation.terminal_type
             , l_operation.acq_inst_bin
             , l_operation.forw_inst_bin
             , l_operation.merchant_number
             , l_operation.terminal_number
             , l_operation.merchant_name
             , l_operation.merchant_street
             , l_operation.merchant_city
             , l_operation.merchant_region
             , l_operation.merchant_country
             , l_operation.merchant_postcode
             , l_operation.mcc
             , l_operation.originator_refnum
             , l_operation.network_refnum
             , l_operation.oper_count
             , l_operation.oper_request_amount
             , l_operation.oper_amount_algorithm
             , l_operation.oper_amount
             , l_operation.oper_currency
             , l_operation.oper_cashback_amount
             , l_operation.oper_replacement_amount
             , l_operation.oper_surcharge_amount
             , l_operation.oper_date
             , l_operation.host_date
             , l_operation.unhold_date
             , l_operation.match_status
             , l_operation.sttl_amount
             , l_operation.sttl_currency
             , l_operation.dispute_id
             , l_operation.payment_order_id
             , l_operation.payment_host_id
             , l_operation.forced_processing
             , l_operation.match_id
             , l_operation.proc_mode
             , l_operation.clearing_sequence_num
             , l_operation.clearing_sequence_count
             , l_operation.incom_sess_file_id
             , l_operation.sttl_date
             , l_operation.acq_sttl_date
          from aut_auth aa
             , opr_operation o
         where aa.external_auth_id = i_external_auth_id
           and o.id                = aa.id
           and o.status           != opr_api_const_pkg.OPERATION_STATUS_DUPLICATE
    ;
    
    return l_operation;
exception
    when no_data_found then
        return l_operation;
end;

procedure get_participant(
    i_oper_id             in  com_api_type_pkg.t_long_id
  , i_participaint_type   in  com_api_type_pkg.t_dict_value
  , o_participant         out opr_api_type_pkg.t_oper_part_rec
)
is
    l_participant opr_api_type_pkg.t_oper_part_rec;
begin
    begin
        select op.oper_id
             , op.participant_type
             , op.client_id_type
             , op.client_id_value
             , op.inst_id
             , op.network_id
             , op.card_inst_id
             , op.card_network_id
             , op.card_id
             , op.card_instance_id
             , op.card_type_id
             , op.card_mask
             , op.card_hash
             , op.card_seq_number
             , op.card_expir_date
             , op.card_service_code
             , op.card_country
             , op.customer_id
             , op.account_id
             , op.account_type
             , op.account_number
             , op.account_amount
             , op.account_currency
             , op.auth_code
             , op.merchant_id
             , op.terminal_id
             , op.split_hash
             , iss_api_token_pkg.decode_card_number(i_card_number => c.card_number)
          into l_participant.oper_id
             , l_participant.participant_type
             , l_participant.client_id_type
             , l_participant.client_id_value
             , l_participant.inst_id
             , l_participant.network_id
             , l_participant.card_inst_id
             , l_participant.card_network_id
             , l_participant.card_id
             , l_participant.card_instance_id
             , l_participant.card_type_id
             , l_participant.card_mask
             , l_participant.card_hash
             , l_participant.card_seq_number
             , l_participant.card_expir_date
             , l_participant.card_service_code
             , l_participant.card_country
             , l_participant.customer_id
             , l_participant.account_id
             , l_participant.account_type
             , l_participant.account_number
             , l_participant.account_amount
             , l_participant.account_currency
             , l_participant.auth_code
             , l_participant.merchant_id
             , l_participant.terminal_id
             , l_participant.split_hash
             , l_participant.card_number
          from opr_participant op
             , opr_card c
         where op.oper_id          = i_oper_id
           and op.participant_type = i_participaint_type
           and c.oper_id(+)        = op.oper_id
           and c.participant_type(+) = op.participant_type;
    exception
        when no_data_found then
            null;
    end;
    o_participant := l_participant;
end;

procedure remove_operation(
    i_oper_id             in  com_api_type_pkg.t_long_id
) is
begin
    delete
      from opr_operation
     where id = i_oper_id;
     
    if sql%rowcount = 0 then
        trc_log_pkg.debug(
            i_text       => 'remove_operation: warning, operation [#1] is not exists'
          , i_env_param1 => i_oper_id
        );
    else
        delete
          from opr_participant
         where oper_id = i_oper_id;
        delete
          from opr_card
         where oper_id = i_oper_id;
     end if;
end;

procedure init_credit_operation is
    l_oper_type_tab    com_api_type_pkg.t_dict_tab;
begin
    select ae.element_value 
      bulk collect into l_oper_type_tab
      from com_array_element ae
     where ae.array_id = opr_api_const_pkg.OPER_TYPE_CREDIT_ARRAY_ID;

    for i in 1 .. l_oper_type_tab.count loop
        g_type_list(l_oper_type_tab(i)) := com_api_const_pkg.TRUE;
    end loop;

    g_is_loaded := com_api_const_pkg.TRUE;

end init_credit_operation;

-- This function is used in the matching process only as the "deterministic" function.
function is_credit_operation(
    i_oper_type         in      com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_boolean
is
begin
    if g_is_loaded = com_api_const_pkg.FALSE then
        init_credit_operation;
    end if;

    if not g_type_list.exists(i_oper_type) then
        g_type_list(i_oper_type) := com_api_const_pkg.FALSE;
    end if;

    return g_type_list(i_oper_type);
end is_credit_operation;

-- This function is used in the matching process only as the "deterministic" function.
function is_oper_type_same_group(
    i_a_oper_type       in      com_api_type_pkg.t_dict_value
  , i_b_oper_type       in      com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_boolean
is
begin
    if g_is_loaded = com_api_const_pkg.FALSE then
        init_credit_operation;
    end if;

    if not g_type_list.exists(i_a_oper_type) then
        g_type_list(i_a_oper_type) := com_api_const_pkg.FALSE;
    end if;

    if not g_type_list.exists(i_b_oper_type) then
        g_type_list(i_b_oper_type) := com_api_const_pkg.FALSE;
    end if;

    return case
               when g_type_list(i_a_oper_type) = g_type_list(i_b_oper_type)
               then com_api_const_pkg.TRUE
               else com_api_const_pkg.FALSE
           end;
end;                

procedure update_oper_amount(
    i_id                in      com_api_type_pkg.t_long_id
  , i_oper_amount       in      com_api_type_pkg.t_money
  , i_oper_currency     in      com_api_type_pkg.t_curr_code
  , i_raise_error       in      com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
) is
begin
    update opr_operation
       set oper_amount   = i_oper_amount
         , oper_currency = i_oper_currency
     where id = i_id
       and status in (opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
                    , opr_api_const_pkg.OPERATION_STATUS_DONT_PROCESS
                    , opr_api_const_pkg.OPERATION_STATUS_MANUAL);
                    
    if sql%rowcount = 0 then
        if nvl(i_raise_error, com_api_const_pkg.TRUE) = com_api_const_pkg.TRUE then
            com_api_error_pkg.raise_error(
                i_error      => 'OPER_ALREADY_PROCESSED'
              , i_env_param1 => i_id  
            );
        else
            trc_log_pkg.debug(
                i_text       => 'update_oper_amount: warning, oper [#1] is already processed'
              , i_env_param1 => i_id
            );          
        end if;
    end if;
end;

function check_operations_exist(
    i_card_id    in     com_api_type_pkg.t_medium_id
  , i_start_date in     date
  , i_end_date   in     date
  , i_oper_type  in     com_api_type_pkg.t_dict_value default null
  , i_split_hash in     com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_boolean is
    l_result            com_api_type_pkg.t_boolean;
begin
    select decode(count(1), 0, 0, 1)
      into l_result
      from opr_operation o
         , opr_participant p
     where o.id         = p.oper_id
       and p.card_id    = i_card_id
       and o.oper_date >= trunc(i_start_date)
       and o.oper_date <  trunc(i_end_date) + 1
       and p.split_hash = i_split_hash
       and (o.oper_type = i_oper_type or i_oper_type is null);
    
    return l_result;
end;

function check_operations_exist(
    i_object_id    in     com_api_type_pkg.t_long_id
  , i_entity_type  in     com_api_type_pkg.t_dict_value
  , i_split_hash   in     com_api_type_pkg.t_tiny_id
  , i_start_date   in     date
  , i_end_date     in     date
  , i_oper_type    in     com_dict_tpt default null
) return com_api_type_pkg.t_boolean is
    l_result            com_api_type_pkg.t_boolean;
    l_card_id           com_api_type_pkg.t_medium_id;
begin
    if i_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        select decode(count(1), 0, com_api_const_pkg.FALSE, com_api_const_pkg.TRUE)
          into l_result
          from acc_account_object ao
             , opr_operation o
             , opr_participant p
         where ao.account_id  = i_object_id
           and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
           and ao.split_hash  = i_split_hash
           and ao.object_id   = p.card_id
           and ao.split_hash  = p.split_hash
           and o.id           = p.oper_id
           and o.oper_date   >= trunc(i_start_date)
           and o.oper_date   <  trunc(i_end_date) + 1
           and (o.oper_type in (select x.column_value from table(cast(i_oper_type as com_dict_tpt)) x)
             or i_oper_type is null
               )
           and rownum <= 1;
    elsif i_entity_type in (iss_api_const_pkg.ENTITY_TYPE_CARD, iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE) then
        if i_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE then
            l_card_id :=
                iss_api_card_instance_pkg.get_instance(
                    i_id          => i_object_id
                  , i_raise_error => com_api_const_pkg.TRUE
                ).card_id;
        elsif i_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then 
            l_card_id := i_object_id;
        end if;
        
        select decode(count(1), 0, com_api_const_pkg.FALSE, com_api_const_pkg.TRUE)
          into l_result
          from opr_operation o
             , opr_participant p
         where o.id         = p.oper_id
           and p.card_id    = l_card_id
           and o.oper_date >= trunc(i_start_date)
           and o.oper_date <  trunc(i_end_date) + 1
           and p.split_hash = i_split_hash
           and (o.oper_type in (select x.column_value from table(cast(i_oper_type as com_dict_tpt)) x)
             or i_oper_type is null
               )
           and rownum <= 1;
    end if;
    
    return l_result;
end;

procedure link_payment_order(
    i_oper_id_tab           in      com_api_type_pkg.t_long_tab
  , i_payment_order_id      in      com_api_type_pkg.t_long_id
  , i_mask_error            in      com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
) is
begin    
    if i_oper_id_tab.count > 0 then

        forall i in 1 .. i_oper_id_tab.count
            update opr_operation
               set payment_order_id = i_payment_order_id
             where id = i_oper_id_tab(i);

        if sql%rowcount = 0 
            and i_mask_error = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_error(i_error => 'OPERATIONS_NOT_UPDATED');
        end if;

        trc_log_pkg.debug(
            i_text       => 'updated [#1] opeations: added payment order'
          , i_env_param1 => sql%rowcount
        );

    end if;
end;

end opr_api_operation_pkg;
/
