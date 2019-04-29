create or replace package body prd_prc_referral_pkg as
/*********************************************************
 *  Acquiring/issuing application API  <br />
 *  Created by Sergey Ivanov (sr.ivanov@bpcbt.com)  at 28.09.2018 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: prd_prc_referral_pkg <br />
 *  @headcom
 **********************************************************/

procedure create_operation(
    i_entity_type          in     com_api_type_pkg.t_dict_value
  , i_inst_id              in     com_api_type_pkg.t_tiny_id
  , i_refarrer             in     com_api_type_pkg.t_tiny_id
  , i_refarrer_cust_number in     com_api_type_pkg.t_name
  , i_refarral             in     com_api_type_pkg.t_tiny_id
  , i_refarral_cust_number in     com_api_type_pkg.t_name
  , i_event_date           in     date
) is
    l_split_hash                  com_api_type_pkg.t_tiny_id;
    l_oper_id                     com_api_type_pkg.t_long_id;
    
    l_welcome_fee                 com_api_type_pkg.t_long_id;
    l_referrer_fee                com_api_type_pkg.t_long_id;
    l_welcome_fee_curr            com_api_type_pkg.t_curr_code;
    l_referrer_fee_curr           com_api_type_pkg.t_curr_code;
    l_fee_amount_welcome          com_api_type_pkg.t_money;
    l_fee_amount_referrer         com_api_type_pkg.t_money;
begin

    l_welcome_fee := 
        prd_api_product_pkg.get_attr_value_number(
            i_entity_type    => i_entity_type
          , i_object_id      => i_refarral
          , i_attr_name      => 'WELCOME_POINTS'
          , i_mask_error     => com_api_type_pkg.TRUE
        );
    l_referrer_fee := 
        prd_api_product_pkg.get_attr_value_number(
            i_entity_type    => i_entity_type
          , i_object_id      => i_refarrer
          , i_attr_name      => 'REFERRAL_POINTS'
          , i_mask_error     => com_api_type_pkg.TRUE
        );
    l_fee_amount_welcome := 
        fcl_api_fee_pkg.get_fee_amount( 
            i_fee_id          => l_welcome_fee
          , i_base_amount     => 0
          , io_base_currency  => l_welcome_fee_curr
          , i_eff_date        => i_event_date
        );
    l_fee_amount_referrer := 
        fcl_api_fee_pkg.get_fee_amount( 
            i_fee_id          => l_referrer_fee
          , i_base_amount     => 0
          , io_base_currency  => l_referrer_fee_curr
          , i_eff_date        => i_event_date
        );
    -- Welcome points
    opr_api_create_pkg.create_operation(
        io_oper_id             => l_oper_id
      , i_session_id           => get_session_id
      , i_status               => opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
      , i_sttl_type            => opr_api_const_pkg.SETTLEMENT_INTERNAL
      , i_msg_type             => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
      , i_oper_type            => opr_api_const_pkg.OPERATION_TYPE_REFERRAL_POINTS
      , i_oper_amount          => l_fee_amount_welcome
      , i_oper_currency        => l_welcome_fee_curr
      , i_is_reversal          => com_api_const_pkg.FALSE              
      , i_oper_date            => i_event_date
      , i_host_date            => i_event_date    
    );
    opr_api_create_pkg.add_participant(
        i_oper_id               => l_oper_id
      , i_msg_type              => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
      , i_oper_type             => opr_api_const_pkg.OPERATION_TYPE_REFERRAL_POINTS
      , i_participant_type      => com_api_const_pkg.PARTICIPANT_ISSUER
      , i_host_date             => i_event_date
      , i_inst_id               => i_inst_id
      , i_customer_id           => i_refarral
      , o_split_hash            => l_split_hash   
      , i_oper_currency         => l_welcome_fee_curr
      , i_is_reversal           => com_api_const_pkg.FALSE
      , i_iss_inst_id           => i_inst_id
      , i_client_id_type        => aup_api_const_pkg.CLIENT_ID_TYPE_CUSTOMER
      , i_client_id_value       => i_refarral_cust_number
    );
    l_oper_id := null;
    -- Referral points
    opr_api_create_pkg.create_operation(
        io_oper_id             => l_oper_id
      , i_session_id           => get_session_id
      , i_status               => opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
      , i_sttl_type            => opr_api_const_pkg.SETTLEMENT_INTERNAL
      , i_msg_type             => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
      , i_oper_type            => opr_api_const_pkg.OPERATION_TYPE_REFERRAL_POINTS
      , i_oper_amount          => l_fee_amount_referrer
      , i_oper_currency        => l_referrer_fee_curr
      , i_is_reversal          => com_api_const_pkg.FALSE              
      , i_oper_date            => i_event_date
      , i_host_date            => i_event_date    
    );
    opr_api_create_pkg.add_participant(
        i_oper_id               => l_oper_id
      , i_msg_type              => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
      , i_oper_type             => opr_api_const_pkg.OPERATION_TYPE_REFERRAL_POINTS
      , i_participant_type      => com_api_const_pkg.PARTICIPANT_ISSUER
      , i_host_date             => i_event_date
      , i_inst_id               => i_inst_id
      , i_customer_id           => i_refarrer
      , o_split_hash            => l_split_hash   
      , i_oper_currency         => l_referrer_fee_curr
      , i_is_reversal           => com_api_const_pkg.FALSE
      , i_iss_inst_id           => i_inst_id
      , i_client_id_type        => aup_api_const_pkg.CLIENT_ID_TYPE_CUSTOMER
      , i_client_id_value       => i_refarrer_cust_number
    );
end create_operation;


procedure calculate_rewards(
    i_inst_id              in     com_api_type_pkg.t_inst_id
) is
    l_eff_date                    date                          := get_sysdate;
    l_entity_type                 com_api_type_pkg.t_dict_value := prd_api_const_pkg.ENTITY_TYPE_CUSTOMER;
    l_oper_count                  com_api_type_pkg.t_tiny_id;
    l_record_count                com_api_type_pkg.t_long_id    := 0;
    l_success_count               com_api_type_pkg.t_long_id    := 0;
    l_errors_count                com_api_type_pkg.t_long_id    := 0;
    l_process_event               com_api_type_pkg.t_tiny_id    := com_api_const_pkg.TRUE;
    l_referral_service_id         com_api_type_pkg.t_short_id;
    l_referrer_service_id         com_api_type_pkg.t_short_id;
begin
    prc_api_stat_pkg.log_start;
    trc_log_pkg.debug('prd_prc_referral_pkg.calculate_rewards start');
    
    for j in (select cc.id as customer_id
                   , cc.customer_number
                   , prd_api_product_pkg.get_attr_value_char(
                         i_entity_type    => l_entity_type
                       , i_object_id      => cc.id
                       , i_attr_name      => prd_api_const_pkg.REFERR_CALCULATION_ALGORITHM
                       , i_mask_error     => com_api_type_pkg.TRUE
                     ) as rlra
                   , rr.referral_code
                   , cc.id
                   , nvl(i_inst_id, cc.inst_id) as inst_id
                   , eo.eff_date
                   , eo.event_id
                   , eo.event_type
                   , eo.entity_type
                   , eo.object_id
                   , eo.id as event_object_id
                   , rl.referrer_id 
                   , rl.customer_id as referral_customer_id
                   , prd_api_customer_pkg.get_customer_number(i_customer_id => rl.customer_id) as referral_customer_number
                   , cc.reg_date
                from evt_event_object eo
                   , prd_referral_vw rl
                   , prd_customer cc
                   , prd_ui_referrer_vw rr
               where cc.entity_type    = com_api_const_pkg.ENTITY_TYPE_PERSON
                 and cc.id             = rr.customer_id (+)
                 and eo.procedure_name = 'PRD_PRC_REFERRAL_PKG.CALCULATE_REWARDS'
                 and eo.status         = evt_api_const_pkg.EVENT_STATUS_READY
                 and eo.entity_type    = l_entity_type
                 and eo.object_id      = rl.id
                 and rr.id             = rl.referrer_id (+)
                 and cc.inst_id        = nvl(i_inst_id,cc.inst_id))
    loop
        l_record_count  := l_record_count + 1;
        l_process_event := com_api_const_pkg.TRUE;
        
        l_referrer_service_id := 
            prd_api_service_pkg.get_active_service_id(
                i_entity_type         => iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
              , i_object_id           => j.customer_id
              , i_attr_name           => null
              , i_service_type_id     => prd_api_const_pkg.CUSTOMER_REFERRER_CODE_SERVICE
              , i_eff_date            => l_eff_date
              , i_mask_error          => com_api_const_pkg.TRUE
              , i_inst_id             => j.inst_id
            );
        l_referral_service_id := 
            prd_api_service_pkg.get_active_service_id(
                i_entity_type         => iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
              , i_object_id           => j.referral_customer_id
              , i_attr_name           => null
              , i_service_type_id     => prd_api_const_pkg.CUSTOMER_REFERRER_CODE_SERVICE
              , i_eff_date            => l_eff_date
              , i_mask_error          => com_api_const_pkg.TRUE
            );

        if l_referrer_service_id is null  
        then
            trc_log_pkg.error(
                i_text       => 'REFERRER_SERVICE_NOT_FOUND'
              , i_env_param1 => j.customer_id
              , i_env_param2 => prd_api_const_pkg.CUSTOMER_REFERRER_CODE_SERVICE
            );
        end if;
        if l_referral_service_id is null  
        then
            trc_log_pkg.error(
                i_text       => 'REFERRAL_SERVICE_NOT_FOUND'
              , i_env_param1 => j.referral_customer_id
              , i_env_param2 => prd_api_const_pkg.CUSTOMER_REFERRER_CODE_SERVICE
            );
        end if;
            
        if l_referrer_service_id is null or l_referral_service_id is null
        then
            l_errors_count := l_errors_count + 1;
        else
            if j.rlra = 'RLRA0000'
            then
                begin
                    create_operation(
                        i_entity_type          => l_entity_type
                      , i_inst_id              => j.inst_id
                      , i_refarrer             => j.customer_id
                      , i_refarrer_cust_number => j.customer_number
                      , i_refarral             => j.referral_customer_id
                      , i_refarral_cust_number => j.referral_customer_number
                      , i_event_date           => l_eff_date
                    );
                    l_success_count := l_success_count + 1;
                exception when others then
                    trc_log_pkg.error(
                        i_text        => sqlerrm
                      , i_entity_type => l_entity_type
                      , i_object_id   => j.customer_id
                      , i_event_id    => j.event_id
                      , i_inst_id     => j.inst_id
                    ); 
                    l_errors_count := l_errors_count + 1;
                end;
            elsif j.rlra = 'RLRA0001' then
                select count(1)
                  into l_oper_count
                  from opr_operation oo
                     , opr_participant pp
                 where oo.id = pp.oper_id
                   and oo.oper_date >= j.reg_date
                   and oo.oper_type in (
                                         opr_api_const_pkg.OPERATION_TYPE_CASHIN
                                       , opr_api_const_pkg.OPERATION_TYPE_P2P_CREDIT
                                       , opr_api_const_pkg.OPERATION_TYPE_PAYMENT
                                       ) 
                   and pp.customer_id = j.referral_customer_id;
                if l_oper_count > 0 then
                    begin
                        create_operation(
                            i_entity_type          => l_entity_type
                          , i_inst_id              => j.inst_id
                          , i_refarrer             => j.customer_id
                          , i_refarrer_cust_number => j.customer_number
                          , i_refarral             => j.referral_customer_id
                          , i_refarral_cust_number => j.referral_customer_number
                          , i_event_date           => l_eff_date
                        );
                        l_success_count := l_success_count + 1;
                    exception when others then
                        trc_log_pkg.error(
                            i_text        => sqlerrm
                          , i_entity_type => l_entity_type
                          , i_object_id   => j.customer_id
                          , i_event_id    => j.event_id
                          , i_inst_id     => j.inst_id
                        );
                        l_errors_count := l_errors_count + 1;
                    end;
                else
                    l_process_event := com_api_const_pkg.FALSE;
                    l_errors_count := l_errors_count + 1;
                    trc_log_pkg.debug('Customer ' || j.referral_customer_id || ' hasn''t operations to earn welcome points');
                end if;
            else
                l_errors_count := l_errors_count + 1;
                trc_log_pkg.error('Customer ' || j.customer_id || ' hasn''t configured Reward calculation algorithm');
            end if;
        end if;
        
        if l_process_event = com_api_const_pkg.TRUE then
            evt_api_event_pkg.process_event_object(i_event_object_id => j.event_object_id);
        end if;
    end loop;
    
    prc_api_stat_pkg.log_estimation(i_estimated_count => l_record_count);

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_success_count
      , i_excepted_total    => l_errors_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    trc_log_pkg.debug('prd_prc_referral_pkg.calculate_rewards end');

exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        else
            -- Log useful local variables, and therefore log call stack for exception point
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end calculate_rewards;

end;
/
