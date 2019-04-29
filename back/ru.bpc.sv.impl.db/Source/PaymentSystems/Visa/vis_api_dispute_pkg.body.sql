create or replace package body vis_api_dispute_pkg is

procedure update_dispute_id (
    i_id                            in     com_api_type_pkg.t_long_id
  , i_dispute_id                    in     com_api_type_pkg.t_long_id
) is
begin
    update vis_fin_message
       set dispute_id = i_dispute_id
     where id = i_id;

    update opr_operation
       set dispute_id = i_dispute_id
     where id = i_id;

end update_dispute_id;

/*
 * Try to calculate dispute due date by the reference table DSP_DUE_DATE_LIMIT
 * and set value of application element DUE_DATE and a new cycle counter (for notification).
 */
procedure update_due_date(
    i_dispute_id                    in     com_api_type_pkg.t_long_id
  , i_standard_id                   in     com_api_type_pkg.t_tiny_id
  , i_trans_code                    in     com_api_type_pkg.t_byte_char
  , i_usage_code                    in     com_api_type_pkg.t_byte_char
  , i_msg_type                      in     com_api_type_pkg.t_dict_value    default null
  , i_eff_date                      in     date
  , i_action                        in     com_api_type_pkg.t_name
  , i_reason_code                   in     com_api_type_pkg.t_dict_value    default null
) is
    l_msg_type                      com_api_type_pkg.t_dict_value;
    l_due_date                      date;
    l_standard_id                   com_api_type_pkg.t_tiny_id;
    l_case_rec                      csm_api_type_pkg.t_csm_case_rec;
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.update_due_date: ';
        
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'i_dispute_id [#1] trans_code [#2], usage_code [#3]'
      , i_env_param1 => i_dispute_id
      , i_env_param2 => i_trans_code
      , i_env_param3 => i_usage_code
    );
        
    csm_api_case_pkg.get_case(
        i_dispute_id  => i_dispute_id
      , o_case_rec    => l_case_rec
      , i_mask_error  => com_api_const_pkg.TRUE
    );
        
    if l_case_rec.case_id is null then
        trc_log_pkg.debug(
            i_text       => 'update_due_date; l_case_rec.case_id is null'
        );
        return;
    end if;
    
    l_standard_id := nvl(i_standard_id, vis_api_const_pkg.VISA_BASEII_STANDARD);
    l_msg_type    :=
        coalesce(
            i_msg_type
          , net_api_map_pkg.get_msg_type(
                i_network_msg_type => i_usage_code || i_trans_code
              , i_standard_id      => l_standard_id
              , i_mask_error       => com_api_type_pkg.TRUE
            )
        );

    if l_msg_type is not null then
        l_due_date := dsp_api_due_date_limit_pkg.get_due_date(
                          i_standard_id   => l_standard_id
                        , i_message_type  => l_msg_type
                        , i_eff_date      => i_eff_date
                        , i_is_incoming   => com_api_const_pkg.FALSE
                        , i_usage_code    => case when i_usage_code = '9' then i_usage_code end
                        , i_reason_code   => i_reason_code
                      );
    end if;

    if l_due_date is not null then
        dsp_api_due_date_limit_pkg.update_due_date(
            i_dispute_id  => i_dispute_id
          , i_appl_id     => null
          , i_due_date    => l_due_date
          , i_expir_notif => com_api_const_pkg.TRUE
          , i_mask_error  => com_api_const_pkg.FALSE
        );
            
        csm_api_case_pkg.add_history(
            i_case_id         => l_case_rec.case_id
          , i_action          => i_action
          , i_new_appl_status => l_case_rec.case_status
          , i_old_appl_status => l_case_rec.case_status
          , i_new_reject_code => l_case_rec.case_resolution
          , i_old_reject_code => l_case_rec.case_resolution
          , i_env_param1      => l_msg_type
          , i_env_param2      => l_case_rec.is_reversal
          , i_env_param3      => l_case_rec.reason_code
          , i_mask_error      => com_api_const_pkg.FALSE
        );
    end if;
end update_due_date;

/*
 *  find dispute fin message id  by original operation id , trans_code, usage_code, arn
 */ 
function get_fin_id(
    i_original_id       in      com_api_type_pkg.t_long_id
  , i_trans_code        in      com_api_type_pkg.t_byte_char        default null
  , i_usage_code        in      com_api_type_pkg.t_byte_char        default null
  , i_arn               in      varchar2                            default null
  , i_is_incoming       in      com_api_type_pkg.t_boolean          default null
  , i_is_reversal       in      com_api_type_pkg.t_boolean          default null
  , i_mask_error        in      com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_long_id
is
    l_id            com_api_type_pkg.t_long_id;
begin
    select max(id)
      into l_id
      from vis_fin_message
     where (trans_code    = i_trans_code  or i_trans_code  is null)            
       and (usage_code    = i_usage_code  or i_usage_code  is null)
       and (arn           = i_arn         or i_arn         is null)
       and (is_incoming   = i_is_incoming or i_is_incoming is null)
       and (is_reversal   = i_is_reversal or i_is_reversal is null)
       and id in (select id
                    from opr_operation
                   where dispute_id = (select dispute_id
                                         from opr_operation 
                                        where id = i_original_id)
                 );
    return l_id;
exception
    when no_data_found then
        if nvl(i_mask_error, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error      => 'NO_DISPUTE_FOUND'
            );                
        else
            trc_log_pkg.debug(
                i_text       => 'VISA get_fin_id: fin message not found for [#1]'
              , i_env_param1 => i_original_id
            );
            return l_id;
        end if; 
end get_fin_id;
    
/*
 *   Message status checker, fot the current moment only CLMS0010 is allowed
 */ 
procedure check_dispute_status(
    i_id                in      com_api_type_pkg.t_long_id
) is
    l_status    com_api_type_pkg.t_dict_value;
begin
    if i_id is null then
        com_api_error_pkg.raise_error(
            i_error         => 'NO_DISPUTE_FOUND'
        );
    end if;
        
    select status
      into l_status
      from vis_fin_message
     where id = i_id;
         
    if l_status != net_api_const_pkg.CLEARING_MSG_STATUS_READY then
        com_api_error_pkg.raise_error(
            i_error         => 'FIN_MSG_ALREADY_SEND'
          , i_env_param1    => i_id
        );
    end if;
exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error         => 'NO_DISPUTE_FOUND'
        );
end check_dispute_status;
    
/*
*  Opdate operation amount and currency
*/ 
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
end update_oper_amount;

procedure gen_message_draft (
    o_fin_id                         out com_api_type_pkg.t_long_id
  , i_select_item                 in     binary_integer
  , i_oper_amount                 in     com_api_type_pkg.t_money         default null
  , i_oper_currency               in     com_api_type_pkg.t_curr_code     default null
  , i_member_msg_text             in     com_api_type_pkg.t_name          default null
  , i_docum_ind                   in     com_api_type_pkg.t_name          default null
  , i_usage_code                  in     com_api_type_pkg.t_name          default null
  , i_spec_chargeback_ind         in     com_api_type_pkg.t_name          default null
  , i_reason_code                 in     com_api_type_pkg.t_name          default null
  , i_original_fin_id             in     com_api_type_pkg.t_long_id
  , i_message_reason_code         in     com_api_type_pkg.t_dict_value    default null
  , i_dispute_condition           in     com_api_type_pkg.t_dict_value    default null
  , i_vrol_financial_id           in     com_api_type_pkg.t_region_code   default null
  , i_vrol_case_number            in     com_api_type_pkg.t_postal_code   default null
  , i_vrol_bundle_number          in     com_api_type_pkg.t_postal_code   default null
  , i_client_case_number          in     com_api_type_pkg.t_attr_name     default null
  , i_dispute_status              in     com_api_type_pkg.t_dict_value
) is
    l_fin_rec                     vis_api_type_pkg.t_visa_fin_mes_rec;
    l_host_id                     com_api_type_pkg.t_tiny_id;
    l_standard_id                 com_api_type_pkg.t_tiny_id;
    l_dispute_id                  com_api_type_pkg.t_long_id;
    l_count                       com_api_type_pkg.t_boolean;
    l_visa_dialect                com_api_type_pkg.t_dict_value;
    l_param_tab                   com_api_type_pkg.t_param_tab;
    l_card_network_id             com_api_type_pkg.t_tiny_id;
    l_stage                       com_api_type_pkg.t_name;
begin
    trc_log_pkg.debug (
        i_text       => 'Generating/updating message draft'
    );
        
    vis_api_fin_message_pkg.get_fin_mes (
        i_id       => i_original_fin_id
      , o_fin_rec  => l_fin_rec
    );

    l_dispute_id := l_fin_rec.dispute_id;
    if l_fin_rec.dispute_id is null then
        l_fin_rec.dispute_id := dsp_api_shared_data_pkg.get_id;
    end if;

    -- update original mesage
    if l_dispute_id is null then
        update_dispute_id (
            i_id          => i_original_fin_id
          , i_dispute_id  => l_fin_rec.dispute_id
        );
    end if;

    if i_select_item in (1, 4, 13) then
        select case when count(id) > 0 then 1 else 0 end
          into l_count
          from vis_fin_message
         where dispute_id               = l_fin_rec.dispute_id
           and substr(trans_code, 1, 1) = '2';

        if l_count = com_api_type_pkg.TRUE then
            com_api_error_pkg.raise_error (
                i_error      => 'DISPUTE_DOUBLE_REVERSAL'
              , i_env_param1 => l_fin_rec.dispute_id
            );
        end if;
    elsif i_select_item in (5, 14) then
        select case when count(id) > 0 then 1 else 0 end
          into l_count
          from vis_fin_message
         where dispute_id               = l_fin_rec.dispute_id
           and substr(trans_code, 1, 1) = '3';

        if l_count = com_api_type_pkg.TRUE then
            com_api_error_pkg.raise_error (
                i_error        => 'DISPUTE_DOUBLE_REVERSAL'
                , i_env_param1 => l_fin_rec.dispute_id
            );
        end if;
    end if;

    -- checks
    case
    -- 1 - Reversal on First Presentment
    -- 4 - Reversal on Second Presentment
    -- 13 - VCR dispute response financial reversal
    -- 14 - VCR dispute financial reversal
    when i_select_item in (1, 4, 13, 14) then
        if nvl(l_fin_rec.oper_amount, 0) < nvl(i_oper_amount, 0) then
            com_api_error_pkg.raise_error (
                i_error       => 'REVERSAL_AMOUNT_GREATER_ORIGINAL_AMOUNT'
              , i_env_param1  => nvl(l_fin_rec.oper_amount, 0) 
              , i_env_param2  => nvl(i_oper_amount, 0)
            );
        end if;
            
    else
        null;
            
    end case;

    l_stage := 'visa_dialect';
    l_host_id     := net_api_network_pkg.get_default_host(
                         i_network_id  => l_fin_rec.network_id
                     );
    l_standard_id := net_api_network_pkg.get_offline_standard (
                         i_host_id     => l_host_id
                     );
    cmn_api_standard_pkg.get_param_value (
        i_inst_id      => l_fin_rec.inst_id
      , i_standard_id  => l_standard_id
      , i_object_id    => l_host_id
      , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
      , i_param_name   => vis_api_const_pkg.VISA_BASEII_DIALECT
      , o_param_value  => l_visa_dialect
      , i_param_tab    => l_param_tab
    );
       
    begin
        select card_network_id 
          into l_card_network_id
          from opr_participant p
         where p.oper_id          = i_original_fin_id
           and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER;
    exception
        when no_data_found then
            l_fin_rec.chargeback_reason_code := null;
    end;

    l_stage := 'init';
    -- init
        
    o_fin_id     := opr_api_create_pkg.get_id;
    l_fin_rec.id := o_fin_id;
        
    l_fin_rec.is_reversal := 
        case i_select_item
            when  1 then com_api_type_pkg.TRUE  --  1 - Reversal on First Presentment
            when  4 then com_api_type_pkg.TRUE  --  4 - Reversal on Second Presentment
            when  5 then com_api_type_pkg.TRUE  --  5 - Reversal on Presentment Chargeback
            when 13 then com_api_type_pkg.TRUE  -- 13 - VCR dispute response financial reversal
            when 14 then com_api_type_pkg.TRUE  -- 14 - VCR dispute financial reversal
            else com_api_type_pkg.FALSE
        end;

    l_fin_rec.is_returned := com_api_type_pkg.FALSE;
    l_fin_rec.is_incoming := com_api_type_pkg.FALSE;
    l_fin_rec.file_id     := null;
    l_fin_rec.batch_id    := null;
    l_fin_rec.status      := net_api_const_pkg.CLEARING_MSG_STATUS_READY;

    l_fin_rec.trans_code :=
        case i_select_item
            when  1 then '2' || substr(l_fin_rec.trans_code, 2)  --  1 - Reversal on First Presentment
            when  2 then '1' || substr(l_fin_rec.trans_code, 2)  --  2 - Chargeback on TC05, TC06, TC07
            when  3 then '0' || substr(l_fin_rec.trans_code, 2)  --  3 - 2-nd Presentment on TC05, TC06, TC07
            when  4 then '2' || substr(l_fin_rec.trans_code, 2)  --  4 - Reversal on Second Presentment
            when  5 then '3' || substr(l_fin_rec.trans_code, 2)  --  5 - Presentment Chargeback Reversal
            when  6 then '1' || substr(l_fin_rec.trans_code, 2)  --  6 - Chargeback on Second Presentment
            when 11 then '0' || substr(l_fin_rec.trans_code, 2)  -- 11 - VCR dispute response financial
            when 12 then '1' || substr(l_fin_rec.trans_code, 2)  -- 12 - VCR dispute financial
            when 13 then '2' || substr(l_fin_rec.trans_code, 2)  -- 13 - VCR dispute response financial reversal
            when 14 then '3' || substr(l_fin_rec.trans_code, 2)  -- 14 - VCR dispute financial reversal
            else l_fin_rec.trans_code
        end;

    l_fin_rec.sttl_amount   := case
                                   when i_select_item in (5, 14)
                                   then l_fin_rec.oper_amount
                                   else i_oper_amount
                               end;

    l_fin_rec.sttl_currency := case
                                   when i_select_item in (5, 14)
                                   then l_fin_rec.oper_currency
                                   else i_oper_currency
                               end;

    l_fin_rec.oper_amount   := case
                                   when i_select_item in (5, 13, 14)
                                   then l_fin_rec.oper_amount
                                   else i_oper_amount
                               end;

    l_fin_rec.oper_currency := case
                                   when i_select_item in (5, 13, 14)
                                   then l_fin_rec.oper_currency
                                   else i_oper_currency
                               end;
        
    l_fin_rec.usage_code    := case
                                   when i_select_item in (3)
                                   then '2'
                                   when i_select_item in (5)
                                   then l_fin_rec.usage_code
                                   when i_select_item in (1)
                                   then '1'
                                   when i_select_item in (4)
                                   then '2'
                                   when i_select_item in (11, 12, 13, 14)
                                   then '9'
                                   else i_usage_code
                               end;
        
    if i_select_item in (2, 6)
       and l_visa_dialect    = vis_api_const_pkg.VISA_DIALECT_OPENWAY
       and l_card_network_id = mcw_api_const_pkg.MCW_NETWORK_ID
    then
        l_fin_rec.chargeback_reason_code := i_reason_code;
    else
        l_fin_rec.reason_code    := case
                                        when i_select_item in (2, 6)
                                        then i_reason_code
                                        else l_fin_rec.reason_code
                                    end;
    end if;
        
    l_fin_rec.central_proc_date  := case
                                        when i_select_item in (1, 13)
                                        then l_fin_rec.central_proc_date
                                        else to_char(get_sysdate, 'YDDD')
                                    end;

    l_fin_rec.iss_workst_bin     := case
                                        when i_select_item in (3, 11)
                                        then l_fin_rec.iss_workst_bin
                                        else null
                                    end;

    l_fin_rec.chargeback_ref_num := case
                                        when i_select_item in (5, 3, 11, 14)
                                        then l_fin_rec.chargeback_ref_num
                                        when i_select_item in (12)
                                        then null
                                        when l_dispute_id is null and i_select_item in (1, 13)
                                        then lpad('0', 6, '0')
                                        when l_dispute_id is null and i_select_item not in (1, 13)
                                        then lpad(nvl(to_char(mod(l_fin_rec.dispute_id, 1000000)), '0'), 6, '0')
                                        else null
                                    end;

    l_fin_rec.docum_ind          := case
                                        when i_select_item in (5, 1, 4)
                                        then l_fin_rec.docum_ind
                                        when i_select_item in (11, 13, 12, 14)
                                        then null
                                        else replace(i_docum_ind, '[ ]', ' ')
                                    end;
        
    l_fin_rec.member_msg_text    := case 
                                        when i_select_item in (5, 1, 4, 13)
                                        then l_fin_rec.member_msg_text
                                        when i_select_item in (14)
                                        then nvl(i_member_msg_text, l_fin_rec.member_msg_text)
                                        else i_member_msg_text
                                    end;
        
    l_fin_rec.spec_chargeback_ind := case
                                         when i_select_item in (2, 6)
                                         then l_fin_rec.spec_chargeback_ind
                                         when i_select_item in (3, 11)
                                         then ' '
                                         when i_select_item in (12) and i_spec_chargeback_ind = '1'
                                         then 'P'
                                         else i_spec_chargeback_ind
                                     end;

    l_fin_rec.cashback := null;

    l_fin_rec.transaction_id      := case
                                         when i_select_item in (2, 3, 11, 12)
                                         then l_fin_rec.transaction_id
                                         else null
                                     end;

    l_fin_rec.reason_code         := case
                                         when i_select_item in (12)
                                         then substr(i_message_reason_code, -2)
                                         else l_fin_rec.reason_code
                                     end;
        
    l_fin_rec.message_reason_code := case 
                                         when i_select_item in (12)
                                         then i_message_reason_code
                                         when i_select_item in (11, 13, 14)
                                         then l_fin_rec.message_reason_code
                                         else null
                                     end;

    l_fin_rec.dispute_condition   := case 
                                         when i_select_item in (12)
                                         then substr(i_dispute_condition, -3)
                                         when i_select_item in (11, 13, 14)
                                         then l_fin_rec.dispute_condition
                                         else null
                                     end;
        
    l_fin_rec.vrol_financial_id   := case 
                                         when i_select_item in (12)
                                         then i_vrol_financial_id
                                         when i_select_item in (11, 13, 14)
                                         then l_fin_rec.vrol_financial_id
                                         else null
                                     end;
        
    l_fin_rec.vrol_case_number    := case 
                                         when i_select_item in (12)
                                         then i_vrol_case_number
                                         when i_select_item in (11, 13, 14)
                                         then l_fin_rec.vrol_case_number
                                         else null
                                     end;
        
    l_fin_rec.vrol_bundle_number  := case 
                                         when i_select_item in (12)
                                         then i_vrol_bundle_number
                                         when i_select_item in (11, 13, 14)
                                         then l_fin_rec.vrol_bundle_number
                                         else null
                                     end;

    l_fin_rec.client_case_number  := case 
                                         when i_select_item in (12)
                                         then i_client_case_number
                                         when i_select_item in (11, 13, 14)
                                         then l_fin_rec.client_case_number
                                         else null
                                     end;
        
    l_fin_rec.dispute_status      := case 
                                         when i_select_item in (11)
                                         then substr(i_dispute_status, -2)
                                         when i_select_item in (12, 13, 14)
                                         then l_fin_rec.dispute_status
                                         else null
                                     end;

    update_due_date(
        i_dispute_id  => l_fin_rec.dispute_id
      , i_standard_id => l_standard_id
      , i_trans_code  => l_fin_rec.trans_code
      , i_usage_code  => l_fin_rec.usage_code
      , i_eff_date    => com_api_sttl_day_pkg.get_sysdate()
      , i_action      => csm_api_const_pkg.CASE_ACTION_ITEM_CREATE_LABEL
      , i_reason_code => case 
                             when l_fin_rec.usage_code = '9' 
                             then l_fin_rec.dispute_condition  
                             else l_fin_rec.reason_code
                         end
    );

    l_stage := 'custom_message_processing';
    vis_cst_dispute_pkg.process_fin_message_draft(io_fin_message => l_fin_rec);
    
    l_stage := 'put_message';
    o_fin_id := vis_api_fin_message_pkg.put_message(i_fin_rec => l_fin_rec);
    
    l_stage := 'create_operation';
    vis_api_fin_message_pkg.create_operation(
        i_fin_rec          => l_fin_rec
      , i_standard_id      => l_standard_id
    );
        
    l_stage := 'done';

    trc_log_pkg.debug (
        i_text         => 'Generating message draft. Assigned id[#1]'
      , i_env_param1   => l_fin_rec.id
    );
        
exception
    when others then
        trc_log_pkg.error(
            i_text          => 'Error generating message draft on stage ' || l_stage || ': ' || sqlerrm
        );
        raise;
end gen_message_draft;

procedure gen_message_retrieval_request (
    o_fin_id                     out com_api_type_pkg.t_long_id
  , i_trans_code              in     com_api_type_pkg.t_byte_char
  , i_billing_amount          in     com_api_type_pkg.t_money
  , i_billing_currency        in     com_api_type_pkg.t_curr_code
  , i_reason_code             in     com_api_type_pkg.t_name
  , i_iss_rfc_bin             in     com_api_type_pkg.t_name
  , i_iss_rfc_subaddr         in     com_api_type_pkg.t_name
  , i_req_fulfill_method      in     com_api_type_pkg.t_boolean
  , i_used_fulfill_method     in     com_api_type_pkg.t_boolean
  , i_fax_number              in     com_api_type_pkg.t_name      default null
  , i_contact_info            in     com_api_type_pkg.t_name      default null
  , i_original_fin_id         in     com_api_type_pkg.t_long_id
) is
    l_original_fin_rec        vis_api_type_pkg.t_visa_fin_mes_rec;
    l_fin_rec                 vis_api_type_pkg.t_visa_fin_mes_rec;
    l_retrieval_rec           vis_api_type_pkg.t_retrieval_rec;
    l_dispute_id              com_api_type_pkg.t_long_id;
    l_stage                   varchar2(100);
    l_host_id                 com_api_type_pkg.t_tiny_id;
    l_standard_id             com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug (
        i_text         => 'Generating/updating message retrieval'
    );

    vis_api_fin_message_pkg.get_fin_mes (
        i_id         => i_original_fin_id
      , o_fin_rec    => l_original_fin_rec
    );

    l_dispute_id := l_original_fin_rec.dispute_id;
    if l_original_fin_rec.dispute_id is null then
        l_original_fin_rec.dispute_id := dsp_api_shared_data_pkg.get_id;
    end if;

    -- update original mesage
    if l_dispute_id is null then
        update_dispute_id (
            i_id            => i_original_fin_id
          , i_dispute_id    => l_original_fin_rec.dispute_id
        );
    end if;

    l_fin_rec.dispute_id := l_original_fin_rec.dispute_id;

    l_stage := 'init';
    -- init

    o_fin_id     := opr_api_create_pkg.get_id;
    l_fin_rec.id := o_fin_id;

    l_fin_rec.is_returned           := com_api_type_pkg.FALSE;
    l_fin_rec.is_incoming           := com_api_type_pkg.FALSE;
    l_fin_rec.is_reversal           := com_api_type_pkg.FALSE;
    l_fin_rec.is_invalid            := com_api_type_pkg.FALSE;
    l_fin_rec.file_id               := null;
    l_fin_rec.batch_id              := null;
    l_fin_rec.status                := net_api_const_pkg.CLEARING_MSG_STATUS_READY;

    l_fin_rec.trans_code            := i_trans_code;
    l_fin_rec.usage_code            := l_original_fin_rec.usage_code;
    l_fin_rec.card_number           := l_original_fin_rec.card_number;
    l_fin_rec.card_hash             := l_original_fin_rec.card_hash;
    l_fin_rec.card_mask             := l_original_fin_rec.card_mask;
    l_fin_rec.arn                   := l_original_fin_rec.arn;
    l_fin_rec.acq_business_id       := l_original_fin_rec.acq_business_id;
    l_fin_rec.merchant_name         := l_original_fin_rec.merchant_name;
    l_fin_rec.merchant_city         := l_original_fin_rec.merchant_city;
    l_fin_rec.merchant_country      := l_original_fin_rec.merchant_country;
    l_fin_rec.mcc                   := l_original_fin_rec.mcc;
    l_fin_rec.merchant_postal_code  := l_original_fin_rec.merchant_postal_code;
    l_fin_rec.merchant_region       := l_original_fin_rec.merchant_region;
    l_fin_rec.central_proc_date     := to_char(get_sysdate, 'YDDD');
    l_fin_rec.inst_id               := l_original_fin_rec.inst_id;
    l_fin_rec.network_id            := l_original_fin_rec.network_id;
    l_fin_rec.host_inst_id          := l_original_fin_rec.host_inst_id;
    l_fin_rec.proc_bin              :=l_original_fin_rec.proc_bin;
    l_fin_rec.settlement_flag       := l_original_fin_rec.settlement_flag;
    l_fin_rec.trans_code_qualifier  := l_original_fin_rec.trans_code_qualifier;
        
    l_fin_rec.token_assurance_level := l_original_fin_rec.token_assurance_level;
    l_fin_rec.pan_token             := l_original_fin_rec.pan_token;  
    l_fin_rec.account_selection     := l_original_fin_rec.account_selection;

    l_host_id := net_api_network_pkg.get_default_host(
        i_network_id  => l_fin_rec.network_id
    );
    l_standard_id := net_api_network_pkg.get_offline_standard (
        i_host_id       => l_host_id
    );

        
    l_stage := 'put_message';
    o_fin_id := vis_api_fin_message_pkg.put_message (
        i_fin_rec  => l_fin_rec
    );

    l_stage := 'set_retrieval';
    l_retrieval_rec.id := l_fin_rec.id;

    l_retrieval_rec.purchase_date            := l_original_fin_rec.oper_date;
    l_retrieval_rec.source_amount            := l_original_fin_rec.oper_amount;
    l_retrieval_rec.source_currency          := l_original_fin_rec.oper_currency;
    l_retrieval_rec.reason_code              := i_reason_code;
    l_retrieval_rec.national_reimb_fee       := l_original_fin_rec.national_reimb_fee;
    l_retrieval_rec.atm_account_sel          := '0';
    l_retrieval_rec.reimb_flag               := '0';
    l_retrieval_rec.fax_number               := i_fax_number;
    l_retrieval_rec.req_fulfill_method       := nvl(i_req_fulfill_method, 0);
    l_retrieval_rec.used_fulfill_method      := nvl(i_used_fulfill_method, 0);
    l_retrieval_rec.iss_rfc_bin              := i_iss_rfc_bin;
    l_retrieval_rec.iss_rfc_subaddr          := i_iss_rfc_subaddr;
    l_retrieval_rec.iss_billing_currency     := i_billing_currency;
    l_retrieval_rec.iss_billing_amount       := i_billing_amount;
    l_retrieval_rec.transaction_id           := l_original_fin_rec.transaction_id;
    l_retrieval_rec.excluded_trans_id_reason := null;
    l_retrieval_rec.crs_code                 := null;
    l_retrieval_rec.multiple_clearing_seqn   := '00';
    l_retrieval_rec.product_code             := '0000';
    l_retrieval_rec.contact_info             := i_contact_info;

    l_retrieval_rec.iss_inst_id := net_api_network_pkg.get_inst_id(l_original_fin_rec.network_id);
    l_retrieval_rec.acq_inst_id := l_original_fin_rec.inst_id;
        
    update_due_date(
        i_dispute_id  => l_fin_rec.dispute_id
      , i_standard_id => l_standard_id
      , i_trans_code  => l_fin_rec.trans_code
      , i_usage_code  => l_fin_rec.usage_code
      , i_eff_date    => com_api_sttl_day_pkg.get_sysdate()
      , i_action      => csm_api_const_pkg.CASE_ACTION_ITEM_CREATE_LABEL
    );

    l_stage := 'put_retrieval';
    vis_api_fin_message_pkg.put_retrieval(
        i_retrieval_rec  => l_retrieval_rec
    );
    
    l_stage := 'create_operation';
    vis_api_fin_message_pkg.create_operation(
        i_fin_rec          => l_fin_rec
      , i_standard_id      => l_standard_id
    );
        
    l_stage := 'done';

    trc_log_pkg.debug (
        i_text         => 'Generating message retrieval. Assigned id[#1]'
      , i_env_param1   => l_fin_rec.id
    );
exception
    when others then
        trc_log_pkg.error(
            i_text          => 'Error generating message retrieval on stage ' || l_stage || ': ' || sqlerrm
        );
        raise;
end gen_message_retrieval_request;

procedure gen_message_fee (
    o_fin_id                  out com_api_type_pkg.t_long_id
    , i_original_fin_id       in com_api_type_pkg.t_long_id := null
    , i_trans_code            in com_api_type_pkg.t_byte_char
    , i_inst_id               in com_api_type_pkg.t_inst_id
    , i_network_id            in com_api_type_pkg.t_tiny_id
    , i_destin_bin            in com_api_type_pkg.t_name
    , i_source_bin            in com_api_type_pkg.t_name
    , i_reason_code           in com_api_type_pkg.t_name
    , i_event_date            in date
    , i_card_number           in com_api_type_pkg.t_name
    , i_oper_amount           in com_api_type_pkg.t_money
    , i_oper_currency         in com_api_type_pkg.t_curr_code
    , i_country_code          in com_api_type_pkg.t_name
    , i_member_msg_text       in com_api_type_pkg.t_name
) is
    l_original_fin_rec        vis_api_type_pkg.t_visa_fin_mes_rec;
    l_fin_rec                 vis_api_type_pkg.t_visa_fin_mes_rec;
    l_fee_rec                 vis_api_type_pkg.t_fee_rec;
    l_standard_id             com_api_type_pkg.t_tiny_id;
    l_host_id                 com_api_type_pkg.t_tiny_id;
    l_param_tab               com_api_type_pkg.t_param_tab;
    l_dispute_id              com_api_type_pkg.t_long_id;
    l_stage                   varchar2(100);
begin
    trc_log_pkg.debug (
        i_text         => 'Generating/updating message fee'
    );
        
    if i_original_fin_id is not null then
        vis_api_fin_message_pkg.get_fin_mes (
            i_id         => i_original_fin_id
            , o_fin_rec  => l_original_fin_rec
        );

        l_dispute_id := l_original_fin_rec.dispute_id;
        if l_original_fin_rec.dispute_id is null then
            l_original_fin_rec.dispute_id := dsp_api_shared_data_pkg.get_id;
        end if;

        -- update original mesage
        if l_dispute_id is null then
            update_dispute_id (
                i_id            => i_original_fin_id
                , i_dispute_id  => l_original_fin_rec.dispute_id
            );
        end if;
            
        l_fin_rec.dispute_id := l_original_fin_rec.dispute_id;
    end if;
        
    l_stage := 'init';
    -- init
        
    o_fin_id     := opr_api_create_pkg.get_id;
    l_fin_rec.id := o_fin_id;
        
    l_fin_rec.is_returned := com_api_type_pkg.FALSE;
    l_fin_rec.is_incoming := com_api_type_pkg.FALSE;
    l_fin_rec.file_id     := null;
    l_fin_rec.batch_id    := null;
    l_fin_rec.status      := net_api_const_pkg.CLEARING_MSG_STATUS_READY;
        
    l_fin_rec.trans_code  := i_trans_code;
    l_fin_rec.is_reversal := com_api_type_pkg.FALSE;
    /*case when l_fin_rec.trans_code = vis_api_const_pkg.TC_FEE_COLLECTION then
        com_api_type_pkg.FALSE
    else
        com_api_type_pkg.TRUE
    end;*/
            
    l_stage := 'network_id & inst_id';
    l_fin_rec.inst_id       := i_inst_id;
    l_fin_rec.network_id    := i_network_id;
    l_fin_rec.host_inst_id  := net_api_network_pkg.get_inst_id(l_fin_rec.network_id);
    l_fin_rec.card_number   := i_card_number;
    l_fin_rec.card_id       := iss_api_card_pkg.get_card_id(i_card_number);
    l_fin_rec.card_hash     := com_api_hash_pkg.get_card_hash(i_card_number);
    l_fin_rec.card_mask     := iss_api_card_pkg.get_card_mask(i_card_number);
    l_fin_rec.oper_currency := i_oper_currency;
    l_fin_rec.oper_amount   := i_oper_amount;
    l_fin_rec.sttl_currency := i_oper_currency;
    l_fin_rec.sttl_amount   := i_oper_amount;
        
    l_stage := 'acq_business_id';
    l_host_id     := net_api_network_pkg.get_default_host(i_network_id => l_fin_rec.network_id);
    l_standard_id := net_api_network_pkg.get_offline_standard(i_network_id => l_fin_rec.network_id);
        
    l_fin_rec.acq_business_id := cmn_api_standard_pkg.get_varchar_value(
        i_inst_id        => l_fin_rec.inst_id
        , i_standard_id  => l_standard_id
        , i_object_id    => l_host_id
        , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
        , i_param_name   => vis_api_const_pkg.ACQ_BUSINESS_ID
        , i_param_tab    => l_param_tab
    );
    l_fin_rec.proc_bin := cmn_api_standard_pkg.get_varchar_value(
        i_inst_id        => l_fin_rec.inst_id
        , i_standard_id  => l_standard_id
        , i_object_id    => l_host_id
        , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
        , i_param_name   => vis_api_const_pkg.CMID
        , i_param_tab    => l_param_tab
    );
    l_fin_rec.arn := 
        case 
            when l_original_fin_rec.arn is null then
                acq_api_merchant_pkg.get_arn (
                    i_acquirer_bin  => l_fin_rec.proc_bin
                )
            else
                l_original_fin_rec.arn
        end;

    l_fin_rec.oper_date             := get_sysdate;
    l_fin_rec.central_proc_date     := to_char(get_sysdate, 'YDDD');
    l_fin_rec.settlement_flag       := '9';
    l_fin_rec.reimburst_attr        := '0';
    l_fin_rec.trans_code_qualifier  := '0';
    l_fin_rec.usage_code            := '1';
    l_fin_rec.token_assurance_level := l_original_fin_rec.token_assurance_level;
    l_fin_rec.pan_token             := l_original_fin_rec.pan_token;
        
    l_stage := 'put_message';
    o_fin_id := vis_api_fin_message_pkg.put_message (
        i_fin_rec  => l_fin_rec
    );

    l_stage := 'set_fee';
    l_fee_rec.id := l_fin_rec.id;

    l_fee_rec.file_id        := null;
    l_fee_rec.pay_fee        := 0;
    l_fee_rec.dst_bin        := i_destin_bin;
    l_fee_rec.src_bin        := i_source_bin;
    l_fee_rec.dst_inst_id    := net_api_network_pkg.get_inst_id(i_network_id => i_network_id);
    l_fee_rec.src_inst_id    := i_inst_id;
    l_fee_rec.reason_code    := i_reason_code;
    l_fee_rec.country_code   := i_country_code;
    l_fee_rec.event_date     := nvl(i_event_date, get_sysdate);
    l_fee_rec.pay_amount     := i_oper_amount;
    l_fee_rec.pay_currency   := i_oper_currency;
    l_fee_rec.src_amount     := i_oper_amount;
    l_fee_rec.src_currency   := i_oper_currency;
    l_fee_rec.message_text   := i_member_msg_text;
    l_fee_rec.trans_id       := null;
    l_fee_rec.reimb_attr     := '0';
    l_fee_rec.funding_source := null;

    update_due_date(
        i_dispute_id  => l_fin_rec.dispute_id
      , i_standard_id => l_standard_id
      , i_trans_code  => l_fin_rec.trans_code
      , i_usage_code  => l_fin_rec.usage_code
      , i_eff_date    => com_api_sttl_day_pkg.get_sysdate()
      , i_action      => csm_api_const_pkg.CASE_ACTION_ITEM_CREATE_LABEL
    );

    l_stage := 'put_fee';
    vis_api_fin_message_pkg.put_fee(
        i_fee_rec  => l_fee_rec
    );

    l_stage := 'create_operation';
    vis_api_fin_message_pkg.create_operation (
         i_fin_rec       => l_fin_rec
        , i_standard_id  => l_standard_id
        , i_fee_rec      => l_fee_rec
    );
        
    l_stage := 'done';

    trc_log_pkg.debug (
        i_text         => 'Generating message fee. Assigned id[#1]'
      , i_env_param1   => l_fin_rec.id
    );
exception
    when others then
        trc_log_pkg.error(
            i_text          => 'Error generating message fee on stage ' || l_stage || ': ' || sqlerrm
        );
        raise;
end gen_message_fee;
    
procedure gen_message_fraud (
    o_fin_id                     out com_api_type_pkg.t_long_id
    , i_original_fin_id          in com_api_type_pkg.t_long_id
    , i_source_bin               in com_api_type_pkg.t_name       default null
    , i_oper_amount              in com_api_type_pkg.t_money      default null
    , i_oper_currency            in com_api_type_pkg.t_curr_code  default null
    , i_notification_code        in com_api_type_pkg.t_name       default null
    , i_iss_gen_auth             in com_api_type_pkg.t_name       default null
    , i_account_seq_number       in com_api_type_pkg.t_name       default null
    , i_expir_date               in com_api_type_pkg.t_name       default null
    , i_fraud_type               in com_api_type_pkg.t_dict_value default null
    , i_fraud_inv_status         in com_api_type_pkg.t_name       default null
    , i_excluded_trans_id_reason in com_api_type_pkg.t_name       default null
) is
    l_fin_rec                 vis_api_type_pkg.t_visa_fin_mes_rec;
    l_fraud_rec               vis_api_type_pkg.t_visa_fraud_rec;
    l_dispute_id              com_api_type_pkg.t_long_id;
    l_stage                   com_api_type_pkg.t_name;
    l_host_id                 com_api_type_pkg.t_tiny_id;
    l_standard_id             com_api_type_pkg.t_tiny_id;
    l_visa_send_to_network_id com_api_type_pkg.t_network_id;
    l_visa_host_inst_id       com_api_type_pkg.t_inst_id;
    l_need_modify_proc_bin    com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug (
        i_text         => 'Generating/updating a fraud message'
    );

    vis_api_fin_message_pkg.get_fin_mes(
        i_id         => i_original_fin_id
      , o_fin_rec    => l_fin_rec
    );

    l_dispute_id := l_fin_rec.dispute_id;
        
    -- update original mesage
    if l_dispute_id is null then
        l_dispute_id := dsp_api_shared_data_pkg.get_id;
        update_dispute_id (
            i_id            => i_original_fin_id
            , i_dispute_id  => l_dispute_id
        );

        l_fin_rec.dispute_id := l_dispute_id;
    end if;
    trc_log_pkg.debug(
        i_text => 'gen_message_fraud: l_dispute_id=' || l_dispute_id
    );

    l_stage := 'init';
        
    o_fin_id       := opr_api_create_pkg.get_id;
    l_fraud_rec.id := o_fin_id;

    l_stage := 'set_fraud';
    l_fraud_rec.delete_flag     := 0;
    l_fraud_rec.is_rejected     := 0;
    l_fraud_rec.is_incoming     := 0;
    l_fraud_rec.status          := net_api_const_pkg.CLEARING_MSG_STATUS_READY;
        
    l_fraud_rec.dispute_id      := l_dispute_id;

    l_visa_send_to_network_id   := set_ui_value_pkg.get_system_param_n('VISA_FRAUD_SEND_TO_NETWORK_ID');
    l_visa_host_inst_id         := set_ui_value_pkg.get_system_param_n('VISA_FRAUD_HOST_INST_ID');
    l_need_modify_proc_bin      := set_ui_value_pkg.get_system_param_n('VISA_FRAUD_NEED_MODIFY_PROC_BIN');

    l_fin_rec.network_id        := nvl(l_visa_send_to_network_id, l_fin_rec.network_id);
    l_fin_rec.host_inst_id      := nvl(l_visa_host_inst_id,       l_fin_rec.host_inst_id);

    -- Need change for NSPK
    if l_need_modify_proc_bin = com_api_type_pkg.TRUE
       and substr(l_fin_rec.proc_bin, 1, 1) = '9'
    then
        l_fin_rec.proc_bin := '2' || substr(l_fin_rec.proc_bin, 2);
    end if;

    l_fraud_rec.inst_id         := l_fin_rec.inst_id;
    l_fraud_rec.network_id      := l_fin_rec.network_id;
    l_fraud_rec.host_inst_id    := l_fin_rec.host_inst_id;

    if i_fraud_type = vis_api_const_pkg.FRP_TYPE_ACQ_REP_COUNTERFEIT then
        l_fraud_rec.source_bin  := substr(l_fin_rec.acq_business_id, -6);
    else
        l_fraud_rec.source_bin  := i_source_bin;
    end if;
    l_fraud_rec.dest_bin        := '400050';
        
    l_fraud_rec.fraud_amount             := i_oper_amount;
    l_fraud_rec.fraud_currency           := i_oper_currency;
    l_fraud_rec.iss_gen_auth             := i_iss_gen_auth;
    l_fraud_rec.notification_code        := i_notification_code;
    l_fraud_rec.account_seq_number       := i_account_seq_number;
    l_fraud_rec.fraud_type               := i_fraud_type;
    l_fraud_rec.card_expir_date          := i_expir_date;
    l_fraud_rec.fraud_inv_status         := i_fraud_inv_status;
    l_fraud_rec.excluded_trans_id_reason := i_excluded_trans_id_reason;

    l_fraud_rec.account_number           := l_fin_rec.card_number;
    l_fraud_rec.purchase_date            := l_fin_rec.oper_date;
    l_fraud_rec.arn                      := l_fin_rec.arn;
        
    l_fraud_rec.merchant_name            := l_fin_rec.merchant_name;
    l_fraud_rec.merchant_city            := l_fin_rec.merchant_city;
    l_fraud_rec.merchant_country         := l_fin_rec.merchant_country;
    l_fraud_rec.merchant_postal_code     := l_fin_rec.merchant_postal_code;
    l_fraud_rec.state_province           := l_fin_rec.merchant_region;
    l_fraud_rec.mcc                      := l_fin_rec.mcc;
        
    l_fraud_rec.reimburst_attr           := nvl(l_fin_rec.reimburst_attr, 0);
    l_fraud_rec.acq_business_id          := l_fin_rec.acq_business_id;
    l_fraud_rec.vic_processing_date      := 
        case
            when nvl(l_fin_rec.central_proc_date, '0000') = '0000' then
                null
            else
                to_date(l_fin_rec.central_proc_date, 'YDDD')
        end;
    l_fraud_rec.transaction_id          := l_fin_rec.transaction_id;
    l_fraud_rec.merchant_number         := l_fin_rec.merchant_number;
    l_fraud_rec.terminal_number         := l_fin_rec.terminal_number;
    l_fraud_rec.auth_code               := l_fin_rec.auth_code;
    l_fraud_rec.crdh_id_method          := l_fin_rec.crdh_id_method;
    l_fraud_rec.pos_entry_mode          := l_fin_rec.pos_entry_mode;
    l_fraud_rec.pos_terminal_cap        := l_fin_rec.pos_terminal_cap;
    l_fraud_rec.cashback                := l_fin_rec.cashback;
    l_fraud_rec.electr_comm_ind         := l_fin_rec.electr_comm_ind;

    l_fraud_rec.last_update             := com_api_sttl_day_pkg.get_sysdate;

    l_fraud_rec.cashback_ind            := null;
    l_fraud_rec.card_capability         := null;
    l_fraud_rec.addendum_present        := 1;
    l_fraud_rec.reserved                := 'C';
    l_fraud_rec.multiple_clearing_seqn  := '00';
    l_fraud_rec.crdh_activated_term_ind := null;
    l_fraud_rec.agent_unique_id         := l_fin_rec.agent_unique_id;
    l_fraud_rec.payment_account_ref     := l_fin_rec.payment_acc_ref;
    l_fraud_rec.cashback_ind            :=
        case
            when l_fraud_rec.cashback <> 0 then 'Y'
            else 'N'
        end;

    for oper in (
        select iss_inst_id
             , acq_inst_id
          from opr_operation_participant_vw
         where id = i_original_fin_id
    ) loop
        l_fraud_rec.iss_inst_id := oper.iss_inst_id;
        l_fraud_rec.acq_inst_id := oper.acq_inst_id;
    end loop;

    l_stage := 'put_fraud';
    vis_api_fin_message_pkg.put_fraud(
        i_fraud_rec   => l_fraud_rec
    );
    
    l_host_id := net_api_network_pkg.get_default_host(
        i_network_id  => l_fin_rec.network_id
    );
    l_standard_id := net_api_network_pkg.get_offline_standard(
        i_host_id     => l_host_id
    );
    
    l_stage := 'create_operation';
    l_fin_rec.id          := o_fin_id;
    l_fin_rec.is_returned := com_api_type_pkg.FALSE;
    l_fin_rec.is_incoming := com_api_type_pkg.FALSE;
    l_fin_rec.is_reversal := com_api_type_pkg.FALSE;
    l_fin_rec.is_invalid  := com_api_type_pkg.FALSE;
    l_fin_rec.file_id     := null;
    l_fin_rec.batch_id    := null;
    l_fin_rec.status      := net_api_const_pkg.CLEARING_MSG_STATUS_READY;
    l_fin_rec.trans_code  := vis_api_const_pkg.TC_FRAUD_ADVICE;
    
    update_due_date(
        i_dispute_id  => l_fin_rec.dispute_id
      , i_standard_id => l_standard_id
      , i_trans_code  => null
      , i_usage_code  => null
      , i_msg_type    => opr_api_const_pkg.MESSAGE_TYPE_FRAUD_REPORT
      , i_eff_date    => com_api_sttl_day_pkg.get_sysdate()          
      , i_action      => csm_api_const_pkg.CASE_ACTION_ITEM_CREATE_LABEL
    );

    vis_api_fin_message_pkg.create_operation(
        i_fin_rec     => l_fin_rec
      , i_standard_id => l_standard_id
    );

    trc_log_pkg.debug(
        i_text         => 'Generating a fraud message. Assigned ID [#1]'
      , i_env_param1   => l_fraud_rec.id
    );
exception
    when others then
        trc_log_pkg.error(
            i_text => 'Error on generating a fraud message, stage [' || l_stage || ']: ' || sqlerrm
        );
        raise;
end gen_message_fraud;

procedure gen_message_adjustment (
    o_fin_id              out com_api_type_pkg.t_long_id
  , i_original_fin_id  in     com_api_type_pkg.t_long_id default null
  , i_inst_id          in     com_api_type_pkg.t_inst_id
  , i_network_id       in     com_api_type_pkg.t_tiny_id
  , i_destin_bin       in     com_api_type_pkg.t_name
  , i_source_bin       in     com_api_type_pkg.t_name
  , i_reason_code      in     com_api_type_pkg.t_name
  , i_event_date       in     date
  , i_card_number      in     com_api_type_pkg.t_name
  , i_oper_amount      in     com_api_type_pkg.t_money
  , i_oper_currency    in     com_api_type_pkg.t_curr_code
  , i_country_code     in     com_api_type_pkg.t_name
  , i_member_msg_text  in     com_api_type_pkg.t_name
  , i_oper_type        in     com_api_type_pkg.t_dict_value 
) is
    l_original_fin_rec        vis_api_type_pkg.t_visa_fin_mes_rec;
    l_fin_rec                 vis_api_type_pkg.t_visa_fin_mes_rec;
    l_fee_rec                 vis_api_type_pkg.t_fee_rec;
    l_standard_id             com_api_type_pkg.t_tiny_id;
    l_host_id                 com_api_type_pkg.t_tiny_id;
    l_param_tab               com_api_type_pkg.t_param_tab;
    l_dispute_id              com_api_type_pkg.t_long_id;
    l_stage                   varchar2(100);
begin
    trc_log_pkg.debug (
        i_text         => 'Generating/updating message adjustment'
    );
        
    if i_original_fin_id is not null then
        vis_api_fin_message_pkg.get_fin_mes (
            i_id       => i_original_fin_id
          , o_fin_rec  => l_original_fin_rec
        );

        l_dispute_id := l_original_fin_rec.dispute_id;
        if l_original_fin_rec.dispute_id is null then
            l_original_fin_rec.dispute_id := dsp_api_shared_data_pkg.get_id;
        end if;

        -- update original message
        if l_dispute_id is null then
            update_dispute_id (
                i_id          => i_original_fin_id
              , i_dispute_id  => l_original_fin_rec.dispute_id
            );
        end if;
            
        l_fin_rec.dispute_id := l_original_fin_rec.dispute_id;
    end if;
        
    l_stage := 'init';
    -- init
    o_fin_id     := opr_api_create_pkg.get_id;
    l_fin_rec.id := o_fin_id;
        
    l_fin_rec.is_returned := com_api_type_pkg.FALSE;
    l_fin_rec.is_incoming := com_api_type_pkg.FALSE;
    l_fin_rec.file_id     := null;
    l_fin_rec.batch_id    := null;
    l_fin_rec.status      := net_api_const_pkg.CLEARING_MSG_STATUS_READY;
        
    l_fin_rec.trans_code  := l_original_fin_rec.trans_code;
    l_fin_rec.is_reversal := com_api_type_pkg.FALSE;
    /*case when l_fin_rec.trans_code = vis_api_const_pkg.TC_FEE_COLLECTION then
        com_api_type_pkg.FALSE
    else
        com_api_type_pkg.TRUE
    end;*/
            
    l_stage                 := 'network_id & inst_id';
    l_fin_rec.inst_id       := i_inst_id;
    l_fin_rec.network_id    := i_network_id;
    l_fin_rec.host_inst_id  := net_api_network_pkg.get_inst_id(l_fin_rec.network_id);
    l_fin_rec.card_number   := i_card_number;
    l_fin_rec.card_id       := iss_api_card_pkg.get_card_id(i_card_number);
    l_fin_rec.card_hash     := com_api_hash_pkg.get_card_hash(i_card_number);
    l_fin_rec.card_mask     := iss_api_card_pkg.get_card_mask(i_card_number);
    l_fin_rec.oper_currency := i_oper_currency;
    l_fin_rec.oper_amount   := i_oper_amount;
    l_fin_rec.sttl_currency := i_oper_currency;
    l_fin_rec.sttl_amount   := i_oper_amount;
        
    l_stage       := 'acq_business_id';
    l_host_id     := net_api_network_pkg.get_default_host(i_network_id => l_fin_rec.network_id);
    l_standard_id := net_api_network_pkg.get_offline_standard(i_network_id => l_fin_rec.network_id);
        
    l_fin_rec.acq_business_id := cmn_api_standard_pkg.get_varchar_value(
        i_inst_id      => l_fin_rec.inst_id
      , i_standard_id  => l_standard_id
      , i_object_id    => l_host_id
      , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
      , i_param_name   => vis_api_const_pkg.ACQ_BUSINESS_ID
      , i_param_tab    => l_param_tab
    );
    l_fin_rec.proc_bin := cmn_api_standard_pkg.get_varchar_value(
        i_inst_id      => l_fin_rec.inst_id
      , i_standard_id  => l_standard_id
      , i_object_id    => l_host_id
      , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
      , i_param_name   => vis_api_const_pkg.CMID
      , i_param_tab    => l_param_tab
    );
    l_fin_rec.arn := 
        case 
            when l_original_fin_rec.arn is null then
                acq_api_merchant_pkg.get_arn (
                    i_acquirer_bin  => l_fin_rec.proc_bin
                )
            else
                l_original_fin_rec.arn
        end;

    l_fin_rec.oper_date             := get_sysdate;
    l_fin_rec.central_proc_date     := to_char(get_sysdate, 'YDDD');
    l_fin_rec.settlement_flag       := '9';
    l_fin_rec.reimburst_attr        := '0';
    l_fin_rec.trans_code_qualifier  := '0';
    l_fin_rec.usage_code            := '1';
    l_fin_rec.token_assurance_level := l_original_fin_rec.token_assurance_level;
    l_fin_rec.pan_token             := l_original_fin_rec.pan_token;
    l_fin_rec.merchant_name         := l_original_fin_rec.merchant_name;
    l_fin_rec.merchant_city         := l_original_fin_rec.merchant_city;
    l_fin_rec.merchant_country      := l_original_fin_rec.merchant_country;
    l_fin_rec.merchant_postal_code  := l_original_fin_rec.merchant_postal_code;
    l_fin_rec.merchant_region       := l_original_fin_rec.merchant_region;
    l_fin_rec.mcc                   := l_original_fin_rec.mcc;

    l_stage := 'put_message';
    o_fin_id := vis_api_fin_message_pkg.put_message (
        i_fin_rec  => l_fin_rec
    );

    l_stage      := 'set_fee';
    l_fee_rec.id := l_fin_rec.id;
        
    l_fee_rec.file_id      := null;
    l_fee_rec.pay_fee      := 0;
    l_fee_rec.dst_bin      := i_destin_bin;
    l_fee_rec.src_bin      := i_source_bin;
    l_fee_rec.dst_inst_id  := net_api_network_pkg.get_inst_id(i_network_id => i_network_id);
    l_fee_rec.src_inst_id  := i_inst_id;
    l_fee_rec.reason_code  := i_reason_code;
    l_fee_rec.country_code := i_country_code;

    l_fee_rec.event_date     := nvl(i_event_date, get_sysdate);
    l_fee_rec.pay_amount     := i_oper_amount;
    l_fee_rec.pay_currency   := i_oper_currency;
    l_fee_rec.src_amount     := i_oper_amount;
    l_fee_rec.src_currency   := i_oper_currency;
    l_fee_rec.message_text   := i_member_msg_text;
    l_fee_rec.trans_id       := null;
    l_fee_rec.reimb_attr     := '0';
    l_fee_rec.funding_source := null;

    update_due_date(
        i_dispute_id  => l_fin_rec.dispute_id
      , i_standard_id => l_standard_id
      , i_trans_code  => l_fin_rec.trans_code
      , i_usage_code  => l_fin_rec.usage_code
      , i_eff_date    => com_api_sttl_day_pkg.get_sysdate()
      , i_action      => csm_api_const_pkg.CASE_ACTION_ITEM_CREATE_LABEL
    );

    l_stage := 'put_fee';
    vis_api_fin_message_pkg.put_fee(
        i_fee_rec  => l_fee_rec
    );
    
    l_stage := 'create_operation';
    vis_api_fin_message_pkg.create_operation (
         i_fin_rec      => l_fin_rec
       , i_standard_id  => l_standard_id
       , i_fee_rec      => l_fee_rec
       , i_oper_type    => i_oper_type
    );
        
    l_stage := 'done';

    trc_log_pkg.debug (
        i_text         => 'Generating message fee. Assigned id[#1]'
      , i_env_param1   => l_fin_rec.id
    );
    
exception
    when others then
        trc_log_pkg.error(
            i_text          => 'Error generating message fee on stage ' || l_stage || ': ' || sqlerrm
        );
        raise;
end gen_message_adjustment;
    
function get_case_progress(
    i_usage_code      in  com_api_type_pkg.t_byte_char
  , i_trans_code      in  com_api_type_pkg.t_byte_char
) return com_api_type_pkg.t_dict_value as
    l_case_progress         com_api_type_pkg.t_dict_value;
begin
    -- representment
    if    i_trans_code in (vis_api_const_pkg.TC_SALES
                         , vis_api_const_pkg.TC_VOUCHER
                         , vis_api_const_pkg.TC_CASH) then
        l_case_progress :=
            case
                when i_usage_code = '2' then csm_api_const_pkg.CASE_PROGRESS_REPRESENTMENT
                when i_usage_code = '9' then csm_api_const_pkg.CASE_PROGRESS_DISPUTE_RESP
            end;
    -- representment reversal
    elsif i_trans_code in (vis_api_const_pkg.TC_SALES_REVERSAL
                         , vis_api_const_pkg.TC_VOUCHER_REVERSAL
                         , vis_api_const_pkg.TC_CASH_REVERSAL) then
        l_case_progress :=
            case
                when i_usage_code = '2' then csm_api_const_pkg.CASE_PROGRESS_REPRESENTM_REV
                when i_usage_code = '9' then csm_api_const_pkg.CASE_PROGRESS_DISPUTE_RESP_REV
            end;
    -- chargeback
    elsif i_trans_code in (vis_api_const_pkg.TC_SALES_CHARGEBACK
                         , vis_api_const_pkg.TC_VOUCHER_CHARGEBACK
                         , vis_api_const_pkg.TC_CASH_CHARGEBACK) then
        l_case_progress :=
            case
                when i_usage_code = '1' then csm_api_const_pkg.CASE_PROGRESS_CHARGEBACK
                when i_usage_code = '9' then csm_api_const_pkg.CASE_PROGRESS_DISPUTE
            end;
    -- chargeback reversal
    elsif i_trans_code in (vis_api_const_pkg.TC_SALES_CHARGEBACK_REV
                         , vis_api_const_pkg.TC_VOUCHER_CHARGEBACK_REV
                         , vis_api_const_pkg.TC_CASH_CHARGEBACK_REV) then
        l_case_progress :=
            case
                when i_usage_code = '1' then csm_api_const_pkg.CASE_PROGRESS_CHARGEBACK_REV
                when i_usage_code = '9' then csm_api_const_pkg.CASE_PROGRESS_DISPUTE_REV
            end;
    elsif i_trans_code in (vis_api_const_pkg.TC_REQUEST_ORIGINAL_PAPER
                         , vis_api_const_pkg.TC_REQUEST_FOR_PHOTOCOPY
                         , vis_api_const_pkg.TC_MAILING_CONFIRMATION) then
        l_case_progress := csm_api_const_pkg.CASE_PROGRESS_RETRIEVAL;
    end if;
        
    return l_case_progress;
end get_case_progress;
    
procedure change_case_status(
    i_dispute_id              in  com_api_type_pkg.t_long_id
  , i_usage_code              in  com_api_type_pkg.t_byte_char
  , i_trans_code              in  com_api_type_pkg.t_byte_char
  , i_reason_code             in  com_api_type_pkg.t_dict_value
  , i_msg_status              in  com_api_type_pkg.t_dict_value
  , i_dispute_condition       in  com_api_type_pkg.t_curr_code
  , i_msg_type                in     com_api_type_pkg.t_dict_value
  , i_is_reversal             in     com_api_type_pkg.t_boolean
) as
    l_case_progress           com_api_type_pkg.t_dict_value;
    l_seqnum                  com_api_type_pkg.t_seqnum;
    LOG_PREFIX       constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.change_case_status: ';
        
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'i_dispute_id [#1], trans_code [#2], usage_code [#3], i_msg_status [#4], i_msg_type [#5], i_is_reversal [#6]'
      , i_env_param1 => i_dispute_id
      , i_env_param2 => i_trans_code
      , i_env_param3 => i_usage_code
      , i_env_param4 => i_msg_status
      , i_env_param5 => i_msg_type
      , i_env_param6 => i_is_reversal
    );
        
    -- set proper case status and progress
    if   i_trans_code in (vis_api_const_pkg.TC_SALES
                        , vis_api_const_pkg.TC_VOUCHER
                        , vis_api_const_pkg.TC_CASH
                        , vis_api_const_pkg.TC_SALES_CHARGEBACK
                        , vis_api_const_pkg.TC_VOUCHER_CHARGEBACK
                        , vis_api_const_pkg.TC_CASH_CHARGEBACK
                        , vis_api_const_pkg.TC_SALES_CHARGEBACK_REV
                        , vis_api_const_pkg.TC_VOUCHER_CHARGEBACK_REV
                        , vis_api_const_pkg.TC_CASH_CHARGEBACK_REV)
     -- representment reversal
     or (
         i_trans_code in (vis_api_const_pkg.TC_SALES_REVERSAL
                        , vis_api_const_pkg.TC_VOUCHER_REVERSAL
                        , vis_api_const_pkg.TC_CASH_REVERSAL)
     and i_usage_code in ('2', '9')
    )
    then
        csm_api_case_pkg.change_case_status(
            i_dispute_id     => i_dispute_id
          , i_reason_code    => i_msg_status
        );
            
        csm_api_progress_pkg.get_case_progress(
            i_network_id    => vis_api_const_pkg.VISA_NETWORK_ID
          , i_msg_type      => i_msg_type
          , i_is_reversal   => i_is_reversal
          , i_mask_error    => com_api_const_pkg.FALSE
          , o_case_progress => l_case_progress
        );
            
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'l_case_progress [#1]'
          , i_env_param1 => l_case_progress
        );
            
        if l_case_progress is not null then
            csm_api_case_pkg.change_case_progress(
                i_dispute_id      => i_dispute_id
              , io_seqnum         => l_seqnum
              , i_case_progress   => l_case_progress
              , i_reason_code     => case 
                                         when i_usage_code = '9' 
                                             then i_dispute_condition
                                             else i_reason_code
                                     end
            );
        end if;
    end if;
end change_case_status;

procedure modify_first_chargeback(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_oper_amount                 in     com_api_type_pkg.t_money
  , i_oper_currency               in     com_api_type_pkg.t_curr_code
  , i_member_msg_text             in     com_api_type_pkg.t_name
  , i_docum_ind                   in     com_api_type_pkg.t_name
  , i_usage_code                  in     com_api_type_pkg.t_name
  , i_spec_chargeback_ind         in     com_api_type_pkg.t_name
  , i_reason_code                 in     com_api_type_pkg.t_name
) is
begin
    trc_log_pkg.debug (
        i_text         => 'vis_api_dispute_pkg.modify_first_chargeback Start'
    );
        
    vis_api_dispute_pkg.check_dispute_status(
        i_id => i_fin_id
    );

    update vis_fin_message
       set oper_amount         = i_oper_amount
         , oper_currency       = i_oper_currency
         , member_msg_text     = i_member_msg_text
         , docum_ind           = i_docum_ind
         , usage_code          = i_usage_code
         , spec_chargeback_ind = i_spec_chargeback_ind
         , reason_code         = i_reason_code
     where id = i_fin_id;

    opr_api_operation_pkg.update_oper_amount(
        i_id            => i_fin_id
      , i_oper_amount   => i_oper_amount
      , i_oper_currency => i_oper_currency
    );
    
    trc_log_pkg.debug (
        i_text         => 'vis_api_dispute_pkg.modify_first_chargeback Finish'
    );

end modify_first_chargeback;

procedure modify_second_chargeback(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_oper_amount                 in     com_api_type_pkg.t_money
  , i_oper_currency               in     com_api_type_pkg.t_curr_code
  , i_member_msg_text             in     com_api_type_pkg.t_name
  , i_docum_ind                   in     com_api_type_pkg.t_name
  , i_usage_code                  in     com_api_type_pkg.t_name
  , i_spec_chargeback_ind         in     com_api_type_pkg.t_name
  , i_reason_code                 in     com_api_type_pkg.t_name
) is
begin
    trc_log_pkg.debug (
        i_text         => 'vis_api_dispute_pkg.modify_second_chargeback Start'
    );
        
    vis_api_dispute_pkg.check_dispute_status(
        i_id => i_fin_id
    );

    update vis_fin_message
       set oper_amount         = i_oper_amount
         , oper_currency       = i_oper_currency
         , member_msg_text     = i_member_msg_text
         , docum_ind           = i_docum_ind
         , usage_code          = i_usage_code
         , spec_chargeback_ind = i_spec_chargeback_ind
         , reason_code         = i_reason_code
     where id = i_fin_id;

    opr_api_operation_pkg.update_oper_amount(
        i_id            => i_fin_id
      , i_oper_amount   => i_oper_amount
      , i_oper_currency => i_oper_currency
    );
    
    trc_log_pkg.debug (
        i_text         => 'vis_api_dispute_pkg.modify_second_chargeback Finish'
    );

end modify_second_chargeback;

procedure modify_first_pres_reversal(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_oper_amount                 in     com_api_type_pkg.t_money
  , i_oper_currency               in     com_api_type_pkg.t_curr_code
  , i_member_msg_text             in     com_api_type_pkg.t_name
) is
begin
    trc_log_pkg.debug (
        i_text         => 'vis_api_dispute_pkg.modify_first_pres_reversal Start'
    );
        
    vis_api_dispute_pkg.check_dispute_status(
        i_id => i_fin_id
    );

    update vis_fin_message
       set oper_amount         = i_oper_amount
         , oper_currency       = i_oper_currency
         , member_msg_text     = i_member_msg_text
     where id = i_fin_id;

    opr_api_operation_pkg.update_oper_amount(
        i_id            => i_fin_id
      , i_oper_amount   => i_oper_amount
      , i_oper_currency => i_oper_currency
    );
    
    trc_log_pkg.debug (
        i_text         => 'vis_api_dispute_pkg.modify_first_pres_reversal Finish'
    );

end modify_first_pres_reversal;

procedure modify_second_pres_reversal (
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_oper_amount                 in     com_api_type_pkg.t_money
  , i_oper_currency               in     com_api_type_pkg.t_curr_code
  , i_member_msg_text             in     com_api_type_pkg.t_name
) is
begin
    trc_log_pkg.debug (
        i_text         => 'vis_api_dispute_pkg.modify_second_pres_reversal Start'
    );
        
    vis_api_dispute_pkg.check_dispute_status(
        i_id => i_fin_id
    );

    update vis_fin_message
       set oper_amount         = i_oper_amount
         , oper_currency       = i_oper_currency
         , member_msg_text     = i_member_msg_text
     where id = i_fin_id;

    opr_api_operation_pkg.update_oper_amount(
        i_id            => i_fin_id
      , i_oper_amount   => i_oper_amount
      , i_oper_currency => i_oper_currency
    );
    
    trc_log_pkg.debug (
        i_text         => 'vis_api_dispute_pkg.modify_second_pres_reversal Finish'
    );

end modify_second_pres_reversal;

procedure modify_second_presentment(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_oper_amount                 in     com_api_type_pkg.t_money
  , i_oper_currency               in     com_api_type_pkg.t_curr_code
  , i_member_msg_text             in     com_api_type_pkg.t_name
  , i_docum_ind                   in     com_api_type_pkg.t_name
) is
begin
    trc_log_pkg.debug (
        i_text         => 'vis_api_dispute_pkg.modify_second_presentment Start'
    );
        
    vis_api_dispute_pkg.check_dispute_status(
        i_id => i_fin_id
    );

    update vis_fin_message
       set oper_amount         = i_oper_amount
         , oper_currency       = i_oper_currency
         , member_msg_text     = i_member_msg_text
         , docum_ind           = i_docum_ind
     where id = i_fin_id;

    opr_api_operation_pkg.update_oper_amount(
        i_id            => i_fin_id
      , i_oper_amount   => i_oper_amount
      , i_oper_currency => i_oper_currency
    );
    
    trc_log_pkg.debug (
        i_text         => 'vis_api_dispute_pkg.modify_second_presentment Finish'
    );

end modify_second_presentment;

procedure modify_retrieval_request (
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_billing_amount              in     com_api_type_pkg.t_money
  , i_billing_currency            in     com_api_type_pkg.t_curr_code
  , i_reason_code                 in     com_api_type_pkg.t_name
  , i_iss_rfc_bin                 in     com_api_type_pkg.t_name
  , i_iss_rfc_subaddr             in     com_api_type_pkg.t_name
  , i_req_fulfill_method          in     com_api_type_pkg.t_boolean
  , i_used_fulfill_method         in     com_api_type_pkg.t_boolean
  , i_fax_number                  in     com_api_type_pkg.t_name
  , i_contact_info                in     com_api_type_pkg.t_name
) is
begin
    trc_log_pkg.debug (
        i_text         => 'vis_api_dispute_pkg.modify_retrieval_request Start'
    );

    vis_api_dispute_pkg.check_dispute_status(
        i_id => i_fin_id
    );

    update vis_retrieval
       set iss_billing_amount   = i_billing_amount
         , iss_billing_currency = i_billing_currency
         , reason_code          = i_reason_code
         , iss_rfc_bin          = i_iss_rfc_bin
         , iss_rfc_subaddr      = i_iss_rfc_subaddr
         , req_fulfill_method   = i_req_fulfill_method
         , used_fulfill_method  = i_used_fulfill_method
         , fax_number           = i_fax_number
         , contact_info         = i_contact_info
     where id = i_fin_id;

    opr_api_operation_pkg.update_oper_amount(
        i_id            => i_fin_id
      , i_oper_amount   => i_billing_amount
      , i_oper_currency => i_billing_currency
    );
    
    trc_log_pkg.debug (
        i_text         => 'vis_api_dispute_pkg.modify_retrieval_request Finish'
    );

end modify_retrieval_request;

procedure modify_fee_collection(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_inst_id                     in     com_api_type_pkg.t_inst_id
  , i_network_id                  in     com_api_type_pkg.t_network_id
  , i_destin_bin                  in     com_api_type_pkg.t_name
  , i_source_bin                  in     com_api_type_pkg.t_name
  , i_reason_code                 in     com_api_type_pkg.t_name
  , i_event_date                  in     date
  , i_card_number                 in     com_api_type_pkg.t_card_number
  , i_oper_amount                 in     com_api_type_pkg.t_money
  , i_oper_currency               in     com_api_type_pkg.t_curr_code
  , i_country_code                in     com_api_type_pkg.t_name
  , i_member_msg_text             in     com_api_type_pkg.t_name
) is
begin
    trc_log_pkg.debug (
        i_text         => 'vis_api_dispute_pkg.modify_fee_collection Start'
    );

    vis_api_dispute_pkg.check_dispute_status(
        i_id => i_fin_id
    );

    update vis_fin_message
       set inst_id         = i_inst_id
         , network_id      = i_network_id
         , oper_amount     = i_oper_amount
         , oper_currency   = i_oper_currency
         , sttl_amount     = i_oper_amount
         , sttl_currency   = i_oper_currency
         , member_msg_text = i_member_msg_text
     where id = i_fin_id;

    update vis_fee
       set pay_amount      = i_oper_amount
         , pay_currency    = i_oper_currency
         , src_amount      = i_oper_amount
         , src_currency    = i_oper_currency
         , dst_bin         = i_destin_bin
         , src_bin         = i_source_bin
         , reason_code     = i_reason_code
         , event_date      = i_event_date
         , country_code    = i_country_code
     where id = i_fin_id;

    update vis_card
       set card_number     = iss_api_token_pkg.encode_card_number(i_card_number => i_card_number)
     where id = i_fin_id;

    opr_api_operation_pkg.update_oper_amount(
        i_id            => i_fin_id
      , i_oper_amount   => i_oper_amount
      , i_oper_currency => i_oper_currency
    );
    
    trc_log_pkg.debug (
        i_text         => 'vis_api_dispute_pkg.modify_fee_collection Finish'
    );

end modify_fee_collection;

procedure modify_funds_disbursement(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_inst_id                     in     com_api_type_pkg.t_inst_id
  , i_network_id                  in     com_api_type_pkg.t_network_id
  , i_destin_bin                  in     com_api_type_pkg.t_name
  , i_source_bin                  in     com_api_type_pkg.t_name
  , i_reason_code                 in     com_api_type_pkg.t_name
  , i_event_date                  in     date
  , i_card_number                 in     com_api_type_pkg.t_card_number
  , i_oper_amount                 in     com_api_type_pkg.t_money
  , i_oper_currency               in     com_api_type_pkg.t_curr_code
  , i_country_code                in     com_api_type_pkg.t_name
  , i_member_msg_text             in     com_api_type_pkg.t_name
) is
begin
    trc_log_pkg.debug (
        i_text         => 'vis_api_dispute_pkg.modify_funds_disbursement Start'
    );

    vis_api_dispute_pkg.check_dispute_status(
        i_id => i_fin_id
    );

    update vis_fin_message
       set inst_id         = i_inst_id
         , network_id      = i_network_id
         , oper_amount     = i_oper_amount
         , oper_currency   = i_oper_currency
         , sttl_amount     = i_oper_amount
         , sttl_currency   = i_oper_currency
         , member_msg_text = i_member_msg_text
     where id = i_fin_id;

    update vis_fee
       set pay_amount      = i_oper_amount
         , pay_currency    = i_oper_currency
         , src_amount      = i_oper_amount
         , src_currency    = i_oper_currency
         , dst_bin         = i_destin_bin
         , src_bin         = i_source_bin
         , reason_code     = i_reason_code
         , event_date      = i_event_date
         , country_code    = i_country_code
     where id = i_fin_id;

    update vis_card
       set card_number     = iss_api_token_pkg.encode_card_number(i_card_number => i_card_number)
     where id = i_fin_id;

    opr_api_operation_pkg.update_oper_amount(
        i_id            => i_fin_id
      , i_oper_amount   => i_oper_amount
      , i_oper_currency => i_oper_currency
    );
    
    trc_log_pkg.debug (
        i_text         => 'vis_api_dispute_pkg.modify_funds_disbursement Finish'
    );

end modify_funds_disbursement;

procedure modify_transmit_monetary_cred(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_inst_id                     in     com_api_type_pkg.t_inst_id
  , i_network_id                  in     com_api_type_pkg.t_network_id
  , i_destin_bin                  in     com_api_type_pkg.t_name
  , i_source_bin                  in     com_api_type_pkg.t_name
  , i_reason_code                 in     com_api_type_pkg.t_name
  , i_event_date                  in     date
  , i_card_number                 in     com_api_type_pkg.t_card_number
  , i_oper_amount                 in     com_api_type_pkg.t_money
  , i_oper_currency               in     com_api_type_pkg.t_curr_code
  , i_country_code                in     com_api_type_pkg.t_name
  , i_member_msg_text             in     com_api_type_pkg.t_name
) is
begin
    trc_log_pkg.debug (
        i_text         => 'vis_api_dispute_pkg.modify_transmit_monetary_cred Start'
    );

    vis_api_dispute_pkg.check_dispute_status(
        i_id => i_fin_id
    );

    update vis_fin_message
       set inst_id         = i_inst_id
         , network_id      = i_network_id
         , oper_amount     = i_oper_amount
         , oper_currency   = i_oper_currency
         , sttl_amount     = i_oper_amount
         , sttl_currency   = i_oper_currency
         , member_msg_text = i_member_msg_text
     where id = i_fin_id;

    update vis_fee
       set pay_amount      = i_oper_amount
         , pay_currency    = i_oper_currency
         , src_amount      = i_oper_amount
         , src_currency    = i_oper_currency
         , dst_bin         = i_destin_bin
         , src_bin         = i_source_bin
         , reason_code     = i_reason_code
         , event_date      = i_event_date
         , country_code    = i_country_code
     where id = i_fin_id;

    update vis_card
       set card_number     = iss_api_token_pkg.encode_card_number(i_card_number => i_card_number)
     where id = i_fin_id;

    opr_api_operation_pkg.update_oper_amount(
        i_id            => i_fin_id
      , i_oper_amount   => i_oper_amount
      , i_oper_currency => i_oper_currency
    );
    
    trc_log_pkg.debug (
        i_text         => 'vis_api_dispute_pkg.modify_transmit_monetary_cred Finish'
    );

end modify_transmit_monetary_cred;

procedure modify_fraud_reporting(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_source_bin                  in     com_api_type_pkg.t_name
  , i_oper_amount                 in     com_api_type_pkg.t_money
  , i_oper_currency               in     com_api_type_pkg.t_curr_code
  , i_notification_code           in     com_api_type_pkg.t_dict_value
  , i_iss_gen_auth                in     com_api_type_pkg.t_dict_value
  , i_account_seq_number          in     com_api_type_pkg.t_name
  , i_expir_date                  in     date
  , i_fraud_type                  in     com_api_type_pkg.t_name
  , i_fraud_inv_status            in     com_api_type_pkg.t_name
  , i_excluded_trans_id_reason    in     com_api_type_pkg.t_name
) is
begin
    trc_log_pkg.debug (
        i_text         => 'vis_api_dispute_pkg.modify_fraud_reporting Start'
    );

    vis_api_dispute_pkg.check_dispute_status(
        i_id => i_fin_id
    );

    update vis_fraud
       set fraud_amount             = i_oper_amount
         , fraud_currency           = i_oper_currency
         , source_bin               = i_source_bin
         , notification_code        = i_notification_code
         , iss_gen_auth             = i_iss_gen_auth
         , account_seq_number       = i_account_seq_number
         , card_expir_date          = i_expir_date
         , fraud_type               = i_fraud_type
         , fraud_inv_status         = i_fraud_inv_status
         , excluded_trans_id_reason = i_excluded_trans_id_reason
     where id = i_fin_id;

    opr_api_operation_pkg.update_oper_amount(
        i_id            => i_fin_id
      , i_oper_amount   => i_oper_amount
      , i_oper_currency => i_oper_currency
    );
    
    trc_log_pkg.debug (
        i_text         => 'vis_api_dispute_pkg.modify_fraud_reporting Finish'
    );

end modify_fraud_reporting;

procedure modify_vcr_disp_resp_financial(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_oper_amount                 in     com_api_type_pkg.t_money
  , i_oper_currency               in     com_api_type_pkg.t_curr_code
  , i_member_msg_text             in     com_api_type_pkg.t_name
  , i_spec_chargeback_ind         in     com_api_type_pkg.t_name
  , i_dispute_status              in     com_api_type_pkg.t_dict_value
) is
begin
    trc_log_pkg.debug (
        i_text         => 'vis_api_dispute_pkg.modify_vcr_disp_resp_financial Start'
    );

    vis_api_dispute_pkg.check_dispute_status(
        i_id => i_fin_id
    );

    update vis_fin_message
       set oper_amount         = i_oper_amount
         , oper_currency       = i_oper_currency
         , member_msg_text     = i_member_msg_text
         , spec_chargeback_ind = i_spec_chargeback_ind
     where id = i_fin_id;

    update vis_tcr4
       set dispute_status = substr(i_dispute_status, -2)
     where id = i_fin_id;

    opr_api_operation_pkg.update_oper_amount(
        i_id            => i_fin_id
      , i_oper_amount   => i_oper_amount
      , i_oper_currency => i_oper_currency
    );

    trc_log_pkg.debug (
        i_text         => 'vis_api_dispute_pkg.modify_vcr_disp_resp_financial Finish'
    );

end modify_vcr_disp_resp_financial;

procedure modify_vcr_disp_financial(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_oper_amount                 in     com_api_type_pkg.t_money
  , i_oper_currency               in     com_api_type_pkg.t_curr_code
  , i_member_msg_text             in     com_api_type_pkg.t_name
  , i_usage_code                  in     com_api_type_pkg.t_name
  , i_spec_chargeback_ind         in     com_api_type_pkg.t_tiny_id
  , i_message_reason_code         in     com_api_type_pkg.t_dict_value
  , i_dispute_condition           in     com_api_type_pkg.t_dict_value
  , i_vrol_financial_id           in     com_api_type_pkg.t_region_code
  , i_vrol_case_number            in     com_api_type_pkg.t_postal_code
  , i_vrol_bundle_number          in     com_api_type_pkg.t_postal_code
  , i_client_case_number          in     com_api_type_pkg.t_attr_name
) is
begin
    trc_log_pkg.debug (
        i_text         => 'vis_api_dispute_pkg.modify_vcr_disp_financial Start'
    );

    vis_api_dispute_pkg.check_dispute_status(
        i_id => i_fin_id
    );

    update vis_fin_message
       set oper_amount         = i_oper_amount
         , oper_currency       = i_oper_currency
         , member_msg_text     = i_member_msg_text
         , usage_code          = i_usage_code
         , spec_chargeback_ind = i_spec_chargeback_ind
     where id = i_fin_id;

    update vis_tcr4
       set message_reason_code = i_message_reason_code
         , dispute_condition   = i_dispute_condition
         , vrol_financial_id   = i_vrol_financial_id
         , vrol_case_number    = i_vrol_case_number
         , vrol_bundle_number  = i_vrol_bundle_number
         , client_case_number  = i_client_case_number
     where id = i_fin_id;

    opr_api_operation_pkg.update_oper_amount(
        i_id            => i_fin_id
      , i_oper_amount   => i_oper_amount
      , i_oper_currency => i_oper_currency
    );

    trc_log_pkg.debug (
        i_text         => 'vis_api_dispute_pkg.modify_vcr_disp_financial Finish'
    );

end modify_vcr_disp_financial;

procedure modify_vcr_disp_resp_fin_rev(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_member_msg_text             in     com_api_type_pkg.t_name
) is
begin
    trc_log_pkg.debug (
        i_text         => 'vis_api_dispute_pkg.modify_vcr_disp_resp_fin_rev Start'
    );

    vis_api_dispute_pkg.check_dispute_status(
        i_id => i_fin_id
    );

    update vis_fin_message
       set member_msg_text     = i_member_msg_text
     where id = i_fin_id;

    trc_log_pkg.debug (
        i_text         => 'vis_api_dispute_pkg.modify_vcr_disp_resp_fin_rev Finish'
    );

end modify_vcr_disp_resp_fin_rev;

procedure modify_vcr_disp_fin_reversal(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_member_msg_text             in     com_api_type_pkg.t_name
) is
begin
    trc_log_pkg.debug (
        i_text         => 'vis_api_dispute_pkg.modify_vcr_disp_fin_reversal Start'
    );

    vis_api_dispute_pkg.check_dispute_status(
        i_id => i_fin_id
    );

    update vis_fin_message
       set member_msg_text     = i_member_msg_text
     where id = i_fin_id;

    trc_log_pkg.debug (
        i_text         => 'vis_api_dispute_pkg.modify_vcr_disp_fin_reversal Finish'
    );

end modify_vcr_disp_fin_reversal;

procedure modify_sms_debit_adjustment(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_inst_id                     in     com_api_type_pkg.t_inst_id
  , i_network_id                  in     com_api_type_pkg.t_network_id
  , i_destin_bin                  in     com_api_type_pkg.t_name
  , i_source_bin                  in     com_api_type_pkg.t_name
  , i_reason_code                 in     com_api_type_pkg.t_name
  , i_event_date                  in     date
  , i_card_number                 in     com_api_type_pkg.t_card_number
  , i_oper_amount                 in     com_api_type_pkg.t_money
  , i_oper_currency               in     com_api_type_pkg.t_curr_code
  , i_country_code                in     com_api_type_pkg.t_name
  , i_member_msg_text             in     com_api_type_pkg.t_name
  , i_oper_type                   in     com_api_type_pkg.t_dict_value
) is
begin
    trc_log_pkg.debug (
        i_text         => 'vis_api_dispute_pkg.modify_sms_debit_adjustment Start'
    );

    vis_api_dispute_pkg.check_dispute_status(
        i_id => i_fin_id
    );

    update vis_fin_message
       set inst_id         = i_inst_id
         , network_id      = i_network_id
         , oper_amount     = i_oper_amount
         , oper_currency   = i_oper_currency
         , sttl_amount     = i_oper_amount
         , sttl_currency   = i_oper_currency
         , member_msg_text = i_member_msg_text
     where id = i_fin_id;

    update vis_fee
       set pay_amount      = i_oper_amount
         , pay_currency    = i_oper_currency
         , src_amount      = i_oper_amount
         , src_currency    = i_oper_currency
         , dst_bin         = i_destin_bin
         , src_bin         = i_source_bin
         , reason_code     = i_reason_code
         , event_date      = i_event_date
         , country_code    = i_country_code
     where id = i_fin_id;

    update vis_card
       set card_number     = iss_api_token_pkg.encode_card_number(i_card_number => i_card_number)
     where id = i_fin_id;

    update opr_operation
       set oper_type       = i_oper_type
     where id = i_fin_id
       and status in (opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
                    , opr_api_const_pkg.OPERATION_STATUS_DONT_PROCESS
                    , opr_api_const_pkg.OPERATION_STATUS_MANUAL);

    opr_api_operation_pkg.update_oper_amount(
        i_id            => i_fin_id
      , i_oper_amount   => i_oper_amount
      , i_oper_currency => i_oper_currency
    );

    trc_log_pkg.debug (
        i_text         => 'vis_api_dispute_pkg.modify_sms_debit_adjustment Finish'
    );

end modify_sms_debit_adjustment;

procedure modify_sms_credit_adjustment(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_inst_id                     in     com_api_type_pkg.t_inst_id
  , i_network_id                  in     com_api_type_pkg.t_network_id
  , i_destin_bin                  in     com_api_type_pkg.t_name
  , i_source_bin                  in     com_api_type_pkg.t_name
  , i_reason_code                 in     com_api_type_pkg.t_name
  , i_event_date                  in     date
  , i_card_number                 in     com_api_type_pkg.t_card_number
  , i_oper_amount                 in     com_api_type_pkg.t_money
  , i_oper_currency               in     com_api_type_pkg.t_curr_code
  , i_country_code                in     com_api_type_pkg.t_name
  , i_member_msg_text             in     com_api_type_pkg.t_name
  , i_oper_type                   in     com_api_type_pkg.t_dict_value
) is
begin
    trc_log_pkg.debug (
        i_text         => 'vis_api_dispute_pkg.modify_sms_credit_adjustment Start'
    );

    vis_api_dispute_pkg.check_dispute_status(
        i_id => i_fin_id
    );

    update vis_fin_message
       set inst_id         = i_inst_id
         , network_id      = i_network_id
         , oper_amount     = i_oper_amount
         , oper_currency   = i_oper_currency
         , sttl_amount     = i_oper_amount
         , sttl_currency   = i_oper_currency
         , member_msg_text = i_member_msg_text
     where id = i_fin_id;

    update vis_fee
       set pay_amount      = i_oper_amount
         , pay_currency    = i_oper_currency
         , src_amount      = i_oper_amount
         , src_currency    = i_oper_currency
         , dst_bin         = i_destin_bin
         , src_bin         = i_source_bin
         , reason_code     = i_reason_code
         , event_date      = i_event_date
         , country_code    = i_country_code
     where id = i_fin_id;

    update vis_card
       set card_number     = iss_api_token_pkg.encode_card_number(i_card_number => i_card_number)
     where id = i_fin_id;

    update opr_operation
       set oper_type       = i_oper_type
     where id = i_fin_id
       and status in (opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
                    , opr_api_const_pkg.OPERATION_STATUS_DONT_PROCESS
                    , opr_api_const_pkg.OPERATION_STATUS_MANUAL);

    opr_api_operation_pkg.update_oper_amount(
        i_id            => i_fin_id
      , i_oper_amount   => i_oper_amount
      , i_oper_currency => i_oper_currency
    );

    trc_log_pkg.debug (
        i_text         => 'vis_api_dispute_pkg.modify_sms_credit_adjustment Finish'
    );

end modify_sms_credit_adjustment;

procedure modify_sms_first_pres_reversal(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_oper_amount                 in     com_api_type_pkg.t_money
  , i_oper_currency               in     com_api_type_pkg.t_curr_code
  , i_member_msg_text             in     com_api_type_pkg.t_name
) is
begin
    trc_log_pkg.debug (
        i_text         => 'vis_api_dispute_pkg.modify_sms_first_pres_reversal Start'
    );
        
    vis_api_dispute_pkg.check_dispute_status(
        i_id => i_fin_id
    );

    update vis_fin_message
       set oper_amount         = i_oper_amount
         , oper_currency       = i_oper_currency
         , member_msg_text     = i_member_msg_text
     where id = i_fin_id;

    opr_api_operation_pkg.update_oper_amount(
        i_id            => i_fin_id
      , i_oper_amount   => i_oper_amount
      , i_oper_currency => i_oper_currency
    );
    
    trc_log_pkg.debug (
        i_text         => 'vis_api_dispute_pkg.modify_sms_first_pres_reversal Finish'
    );

end modify_sms_first_pres_reversal;

procedure modify_sms_second_pres_revers(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_oper_amount                 in     com_api_type_pkg.t_money
  , i_oper_currency               in     com_api_type_pkg.t_curr_code
  , i_member_msg_text             in     com_api_type_pkg.t_name
) is
begin
    trc_log_pkg.debug (
        i_text         => 'vis_api_dispute_pkg.modify_sms_second_pres_revers Start'
    );
        
    vis_api_dispute_pkg.check_dispute_status(
        i_id => i_fin_id
    );

    update vis_fin_message
       set oper_amount         = i_oper_amount
         , oper_currency       = i_oper_currency
         , member_msg_text     = i_member_msg_text
     where id = i_fin_id;

    opr_api_operation_pkg.update_oper_amount(
        i_id            => i_fin_id
      , i_oper_amount   => i_oper_amount
      , i_oper_currency => i_oper_currency
    );
    
    trc_log_pkg.debug (
        i_text         => 'vis_api_dispute_pkg.modify_sms_second_pres_revers Finish'
    );

end modify_sms_second_pres_revers;

procedure modify_sms_second_presentment(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_oper_amount                 in     com_api_type_pkg.t_money
  , i_oper_currency               in     com_api_type_pkg.t_curr_code
  , i_member_msg_text             in     com_api_type_pkg.t_name
  , i_docum_ind                   in     com_api_type_pkg.t_name
) is
begin
    trc_log_pkg.debug (
        i_text         => 'vis_api_dispute_pkg.modify_sms_second_presentment Start'
    );
        
    vis_api_dispute_pkg.check_dispute_status(
        i_id => i_fin_id
    );

    update vis_fin_message
       set oper_amount         = i_oper_amount
         , oper_currency       = i_oper_currency
         , member_msg_text     = i_member_msg_text
         , docum_ind           = i_docum_ind
     where id = i_fin_id;

    opr_api_operation_pkg.update_oper_amount(
        i_id            => i_fin_id
      , i_oper_amount   => i_oper_amount
      , i_oper_currency => i_oper_currency
    );
    
    trc_log_pkg.debug (
        i_text         => 'vis_api_dispute_pkg.modify_sms_second_presentment Finish'
    );

end modify_sms_second_presentment;

procedure modify_sms_fee_collection(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_trans_code                  in     com_api_type_pkg.t_byte_char
  , i_inst_id                     in     com_api_type_pkg.t_inst_id
  , i_network_id                  in     com_api_type_pkg.t_network_id
  , i_destin_bin                  in     com_api_type_pkg.t_name
  , i_source_bin                  in     com_api_type_pkg.t_name
  , i_reason_code                 in     com_api_type_pkg.t_name
  , i_event_date                  in     date
  , i_card_number                 in     com_api_type_pkg.t_card_number
  , i_oper_amount                 in     com_api_type_pkg.t_money
  , i_oper_currency               in     com_api_type_pkg.t_curr_code
  , i_country_code                in     com_api_type_pkg.t_name
  , i_member_msg_text             in     com_api_type_pkg.t_name
) is
begin
    trc_log_pkg.debug (
        i_text         => 'vis_api_dispute_pkg.modify_sms_fee_collection Start'
    );

    vis_api_dispute_pkg.check_dispute_status(
        i_id => i_fin_id
    );

    update vis_fin_message
       set inst_id         = i_inst_id
         , network_id      = i_network_id
         , oper_amount     = i_oper_amount
         , oper_currency   = i_oper_currency
         , sttl_amount     = i_oper_amount
         , sttl_currency   = i_oper_currency
         , member_msg_text = i_member_msg_text
     where id = i_fin_id;

    update vis_fee
       set pay_amount      = i_oper_amount
         , pay_currency    = i_oper_currency
         , src_amount      = i_oper_amount
         , src_currency    = i_oper_currency
         , dst_bin         = i_destin_bin
         , src_bin         = i_source_bin
         , reason_code     = i_reason_code
         , event_date      = i_event_date
         , country_code    = i_country_code
     where id = i_fin_id;

    update vis_card
       set card_number     = iss_api_token_pkg.encode_card_number(i_card_number => i_card_number)
     where id = i_fin_id;

    opr_api_operation_pkg.update_oper_amount(
        i_id            => i_fin_id
      , i_oper_amount   => i_oper_amount
      , i_oper_currency => i_oper_currency
    );
    
    trc_log_pkg.debug (
        i_text         => 'vis_api_dispute_pkg.modify_sms_fee_collection Finish'
    );

end modify_sms_fee_collection;

procedure modify_sms_funds_disbursement(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_trans_code                  in     com_api_type_pkg.t_byte_char
  , i_inst_id                     in     com_api_type_pkg.t_inst_id
  , i_network_id                  in     com_api_type_pkg.t_network_id
  , i_destin_bin                  in     com_api_type_pkg.t_name
  , i_source_bin                  in     com_api_type_pkg.t_name
  , i_reason_code                 in     com_api_type_pkg.t_name
  , i_event_date                  in     date
  , i_card_number                 in     com_api_type_pkg.t_card_number
  , i_oper_amount                 in     com_api_type_pkg.t_money
  , i_oper_currency               in     com_api_type_pkg.t_curr_code
  , i_country_code                in     com_api_type_pkg.t_name
  , i_member_msg_text             in     com_api_type_pkg.t_name
) is
begin
    trc_log_pkg.debug (
        i_text         => 'vis_api_dispute_pkg.modify_sms_funds_disbursement Start'
    );

    vis_api_dispute_pkg.check_dispute_status(
        i_id => i_fin_id
    );

    update vis_fin_message
       set inst_id         = i_inst_id
         , network_id      = i_network_id
         , oper_amount     = i_oper_amount
         , oper_currency   = i_oper_currency
         , sttl_amount     = i_oper_amount
         , sttl_currency   = i_oper_currency
         , member_msg_text = i_member_msg_text
     where id = i_fin_id;

    update vis_fee
       set pay_amount      = i_oper_amount
         , pay_currency    = i_oper_currency
         , src_amount      = i_oper_amount
         , src_currency    = i_oper_currency
         , dst_bin         = i_destin_bin
         , src_bin         = i_source_bin
         , reason_code     = i_reason_code
         , event_date      = i_event_date
         , country_code    = i_country_code
     where id = i_fin_id;

    update vis_card
       set card_number     = iss_api_token_pkg.encode_card_number(i_card_number => i_card_number)
     where id = i_fin_id;

    opr_api_operation_pkg.update_oper_amount(
        i_id            => i_fin_id
      , i_oper_amount   => i_oper_amount
      , i_oper_currency => i_oper_currency
    );
    
    trc_log_pkg.debug (
        i_text         => 'vis_api_dispute_pkg.modify_sms_funds_disbursement Finish'
    );

end modify_sms_funds_disbursement;

function has_dispute_msg(
    i_id                      in com_api_type_pkg.t_long_id
  , i_tc                      in com_api_type_pkg.t_byte_char
  , i_reversal                in com_api_type_pkg.t_boolean   default null
  , i_is_uploaded             in com_api_type_pkg.t_boolean   default null
) return com_api_type_pkg.t_boolean is
    l_result                  com_api_type_pkg.t_boolean;
    l_dispute_id              com_api_type_pkg.t_long_id;
begin
    select f.dispute_id
      into l_dispute_id
      from vis_fin_message f
     where f.id = i_id;

    select com_api_const_pkg.TRUE
      into l_result
      from opr_operation   op
      join vis_fin_message  f    on f.id = op.id
     where op.dispute_id = l_dispute_id
       and f.trans_code  = i_tc
       and f.is_reversal = nvl(i_reversal, f.is_reversal)
       and (    nvl(i_is_uploaded, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE
             or i_is_uploaded = com_api_const_pkg.TRUE
                and f.file_id is not null
           )
       and rownum = 1;

    return l_result;

exception
    when no_data_found then
        return com_api_const_pkg.FALSE;
end has_dispute_msg;

end vis_api_dispute_pkg;
/
