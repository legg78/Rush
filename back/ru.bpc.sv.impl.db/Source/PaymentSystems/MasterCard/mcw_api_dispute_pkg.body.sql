create or replace package body mcw_api_dispute_pkg is
/********************************************************* 
 *  MasterCard dispute API  <br /> 
 *  Created by Kopachev (kopachev@bpcbt.com)  at 11.04.2013 <br /> 
 *  Last changed by $Author: truschelev $ <br /> 
 *  $LastChangedDate:: 2015-10-20 18:02:00 +0300#$ <br /> 
 *  Revision: $LastChangedRevision: 59935 $ <br /> 
 *  Module: mcw_api_dispute_pkg <br /> 
 *  @headcom 
 **********************************************************/

procedure sync_dispute_id (
    io_fin_rec              in out nocopy mcw_api_type_pkg.t_fin_rec
  , o_dispute_id               out        com_api_type_pkg.t_long_id
  , o_dispute_rn               out        com_api_type_pkg.t_long_id
) is
begin
    if io_fin_rec.dispute_id is null then
        io_fin_rec.dispute_id := dsp_api_shared_data_pkg.get_id;

        update_dispute_id (
            i_id            => io_fin_rec.id
            , i_dispute_id  => io_fin_rec.dispute_id
        );
    end if;

    o_dispute_id := io_fin_rec.dispute_id;
    o_dispute_rn := io_fin_rec.id;
end sync_dispute_id;

/*
*  find dispute fin message id  by original operation id , and, optional mcw
*/ 
function get_fin_id(
    i_original_id       in      com_api_type_pkg.t_long_id
  , i_mti               in      mcw_api_type_pkg.t_mti              default null
  , i_de024             in      mcw_api_type_pkg.t_de024            default null
  , i_is_incoming       in      com_api_type_pkg.t_boolean          default null
  , i_is_reversal       in      com_api_type_pkg.t_boolean          default null
  , i_mask_error        in      com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_long_id
is
    l_id            com_api_type_pkg.t_long_id;
begin
    select max(id)
      into l_id
      from mcw_fin
     where (mti           = i_mti         or i_mti         is null)            
       and (de024         = i_de024       or i_de024       is null)
       and (is_incoming   = i_is_incoming or i_is_incoming is null)
       and (is_reversal   = i_is_reversal or i_is_reversal is null)
       and id in (select id
                    from opr_operation
                   where original_id = i_original_id
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
                i_text       => 'MCW get_fin_id: fin message not found for [#1]'
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
      from mcw_fin
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
  , i_raise_error       in      com_api_type_pkg.t_boolean   default com_api_const_pkg.TRUE
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
    
/*
 * Try to calculate dispute due date by the reference table DSP_DUE_DATE_LIMIT
 * and set value of application element DUE_DATE and a new cycle counter (for notification).
 */
procedure update_due_date(
    i_fin_rec               in            mcw_api_type_pkg.t_fin_rec
  , i_standard_id           in            com_api_type_pkg.t_tiny_id
  , i_msg_type              in            com_api_type_pkg.t_dict_value
  , i_is_incoming           in            com_api_type_pkg.t_boolean
  , i_create_disp_case      in            com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
) is
    l_due_date                date;
    l_case_rec                csm_api_type_pkg.t_csm_case_rec;
begin
    if i_fin_rec.dispute_id is null then
        trc_log_pkg.debug(
            i_text       => 'update_due_date; dispute_id is null'
        );
        return;
    end if;
        
    csm_api_case_pkg.get_case(
        i_dispute_id  => i_fin_rec.dispute_id
      , o_case_rec    => l_case_rec
      , i_mask_error  => com_api_const_pkg.TRUE
    );
        
    if l_case_rec.case_id is null then
        trc_log_pkg.debug(
            i_text       => 'update_due_date; l_case_rec.case_id is null'
        );
        return;
    end if;
        
    l_due_date :=
        dsp_api_due_date_limit_pkg.get_due_date(
            i_standard_id   => i_standard_id
          , i_message_type  => i_msg_type
          , i_eff_date      => case i_fin_rec.is_incoming
                                   when com_api_const_pkg.TRUE
                                   then i_fin_rec.de012
                                   else com_api_sttl_day_pkg.get_sysdate()
                               end
          , i_is_incoming   => i_fin_rec.is_incoming
        );

    if l_due_date is not null then
        dsp_api_due_date_limit_pkg.update_due_date(
            i_dispute_id  => i_fin_rec.dispute_id
          , i_appl_id     => null
          , i_due_date    => l_due_date
          , i_expir_notif => com_api_const_pkg.TRUE
          , i_mask_error  => com_api_const_pkg.FALSE
        );
            
        if l_case_rec.case_id is null then
            csm_api_case_pkg.add_history(
                i_case_id          => l_case_rec.case_id
              , i_action           => case i_fin_rec.is_incoming
                                          when com_api_const_pkg.TRUE
                                              then csm_api_const_pkg.CASE_ACTION_ITEM_LOAD_LABEL
                                          else csm_api_const_pkg.CASE_ACTION_ITEM_CREATE_LABEL
                                      end
              , i_new_appl_status  => l_case_rec.case_status
              , i_old_appl_status  => l_case_rec.case_status
              , i_new_reject_code  => l_case_rec.case_resolution
              , i_old_reject_code  => l_case_rec.case_resolution
              , i_env_param1       => i_msg_type
              , i_env_param2       => i_fin_rec.is_reversal
              , i_env_param3       => i_fin_rec.de025
              , i_mask_error       => com_api_const_pkg.FALSE
            );
        end if;
    end if;
end update_due_date;

procedure gen_member_fee (
    o_fin_id                   out com_api_type_pkg.t_long_id
  , i_network_id            in     com_api_type_pkg.t_tiny_id
  , i_de004                 in     mcw_api_type_pkg.t_de004
  , i_de049                 in     mcw_api_type_pkg.t_de049
  , i_de025                 in     mcw_api_type_pkg.t_de025
  , i_de003                 in     mcw_api_type_pkg.t_de003
  , i_de072                 in     mcw_api_type_pkg.t_de072
  , i_de073                 in     mcw_api_type_pkg.t_de073
  , i_de093                 in     mcw_api_type_pkg.t_de093
  , i_de094                 in     mcw_api_type_pkg.t_de094
  , i_de002                 in     mcw_api_type_pkg.t_de002
  , i_original_fin_id       in     com_api_type_pkg.t_long_id        default null
  , i_ext_claim_id          in     mcw_api_type_pkg.t_ext_claim_id   default null
  , i_ext_message_id        in     mcw_api_type_pkg.t_ext_message_id default null
) is
    l_fin_rec                 mcw_api_type_pkg.t_fin_rec;
    l_host_id                 com_api_type_pkg.t_tiny_id;
    l_standard_id             com_api_type_pkg.t_tiny_id;
    l_original_fin_rec        mcw_api_type_pkg.t_fin_rec;
    l_param_tab               com_api_type_pkg.t_param_tab;
    l_stage                   varchar2(100);
begin
    trc_log_pkg.debug (
        i_text         => 'Generating member fee'
    );
        
    l_stage := 'get network communication standard';
    -- get network communication standard
    l_host_id := net_api_network_pkg.get_default_host(i_network_id);
    l_standard_id := net_api_network_pkg.get_offline_standard (
        i_host_id           => l_host_id
    );

    l_stage := 'init';
    -- init
        
    o_fin_id     := opr_api_create_pkg.get_id;
    l_fin_rec.id := o_fin_id;

    l_fin_rec.is_incoming := com_api_type_pkg.FALSE;
    l_fin_rec.is_reversal := com_api_type_pkg.FALSE;
    l_fin_rec.is_rejected := com_api_type_pkg.FALSE;
    l_fin_rec.is_fpd_matched := com_api_type_pkg.FALSE;
    l_fin_rec.is_fsum_matched := com_api_type_pkg.FALSE;
    l_fin_rec.file_id := null;
    l_fin_rec.status := net_api_const_pkg.CLEARING_MSG_STATUS_READY;

    l_stage := 'mti & de24';
    l_fin_rec.mti := mcw_api_const_pkg.MSG_TYPE_FEE;
    l_fin_rec.de024 := mcw_api_const_pkg.FUNC_CODE_MEMBER_FEE;

    if i_original_fin_id is not null then
        mcw_api_fin_pkg.get_fin (
            i_id         => i_original_fin_id
            , o_fin_rec  => l_original_fin_rec
        );

        l_fin_rec.de031 := l_original_fin_rec.de031;
        l_fin_rec.de030_1 := l_original_fin_rec.de030_1;
        if l_original_fin_rec.p0149_1 is null and l_original_fin_rec.p0149_2 is null then 
            l_fin_rec.de030_2 := null;                
        else
            l_fin_rec.de030_2 := 0;
        end if;
        l_fin_rec.p0149_1 := l_original_fin_rec.p0149_1;
        l_fin_rec.p0149_2 := lpad(nvl(l_original_fin_rec.p0149_2, '0'), 3, '0');
        l_fin_rec.p0230 := l_original_fin_rec.p0230;
        l_fin_rec.p0264 := l_original_fin_rec.p0264;
        l_fin_rec.local_message := l_original_fin_rec.local_message;

        l_stage := 'sync_dispute_id';
        sync_dispute_id (
            io_fin_rec      => l_original_fin_rec
          , o_dispute_id    => l_fin_rec.dispute_id
          , o_dispute_rn    => l_fin_rec.dispute_rn
        );
    end if;

    l_stage := 'network_id & inst_id';
    l_fin_rec.network_id := i_network_id;
    l_fin_rec.inst_id := cmn_api_standard_pkg.find_value_owner (
        i_standard_id    => l_standard_id
        , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
        , i_object_id    => l_host_id
        , i_param_name   => mcw_api_const_pkg.CMID
        , i_value_char   => i_de094
    );
    if l_fin_rec.inst_id is null then
        com_api_error_pkg.raise_error(
            i_error         => 'MCW_CMID_NOT_REGISTRED'
            , i_env_param1  => i_de094
            , i_env_param2  => i_network_id
        );
    end if;

    l_stage := 'de002 - de004';
    l_fin_rec.de002 := i_de002;
    l_fin_rec.de003_1 := i_de003;
    l_fin_rec.de003_2 := mcw_api_const_pkg.DEFAULT_DE003_2;
    l_fin_rec.de003_3 := mcw_api_const_pkg.DEFAULT_DE003_3;
    l_fin_rec.de004 := i_de004;

    l_stage := 'impact';
    l_fin_rec.impact := mcw_utl_pkg.get_message_impact (
        i_mti           => l_fin_rec.mti
        , i_de024       => l_fin_rec.de024
        , i_de003_1     => l_fin_rec.de003_1
        , i_is_reversal => l_fin_rec.is_reversal
        , i_is_incoming => l_fin_rec.is_incoming
    );

    l_stage := 'de033';
    l_fin_rec.de033 := cmn_api_standard_pkg.get_varchar_value (
        i_inst_id       => l_fin_rec.inst_id
        , i_standard_id => l_standard_id
        , i_object_id   => l_host_id
        , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
        , i_param_name  => mcw_api_const_pkg.FORW_INST_ID
        , i_param_tab   => l_param_tab
    );

    l_stage := 'de025 & de049';
    l_fin_rec.de025 := i_de025;
    l_fin_rec.de049 := i_de049;

    l_stage := 'add_curr_exp';
    mcw_utl_pkg.add_curr_exp (
        io_p0148       => l_fin_rec.p0148
        , i_curr_code  => l_fin_rec.de049
    );

    l_stage := 'add_curr_exp';
    mcw_utl_pkg.add_curr_exp (
        io_p0148       => l_fin_rec.p0148
        , i_curr_code  => l_fin_rec.p0149_1
    );

    if i_de072 is not null then
        l_fin_rec.de072 := mcw_utl_pkg.pad_char (
            i_data => i_de072
            , i_min_length => 100
            , i_max_length => 100
        );
    end if;
    l_fin_rec.de073 := i_de073;
    l_fin_rec.de093 := i_de093;
    l_fin_rec.de094 := i_de094;

    l_fin_rec.p0137 := lpad(to_char(l_fin_rec.id), 17, '0');
    l_fin_rec.p0165 := mcw_api_const_pkg.SETTLEMENT_TYPE_MASTERCARD;

    l_fin_rec.p0375 := l_fin_rec.id;
    l_fin_rec.ext_claim_id   := i_ext_claim_id;
    l_fin_rec.ext_message_id := i_ext_message_id;

    if csm_api_utl_pkg.is_mcom_enabled(
           i_network_id  => l_fin_rec.network_id
         , i_inst_id     => l_fin_rec.inst_id
         , i_host_id     => l_host_id
         , i_standard_id => l_standard_id
        ) = com_api_const_pkg.TRUE 
    then
        l_fin_rec.status := mup_api_const_pkg.MSG_STATUS_DO_NOT_UNLOAD;
    else
        l_fin_rec.status := net_api_const_pkg.CLEARING_MSG_STATUS_READY;
    end if;    

    l_stage := 'put_message';
    mcw_api_fin_pkg.put_message (
        i_fin_rec  => l_fin_rec
    );
    
    l_stage := 'create_operation';
    mcw_api_fin_pkg.create_operation(
        i_fin_rec      => l_fin_rec
      , i_standard_id  => l_standard_id
    );

    l_stage := 'done';

    trc_log_pkg.debug (
        i_text         => 'Generating member fee. Assigned id [#1]'
      , i_env_param1   => l_fin_rec.id
    );
exception
    when others then
        trc_log_pkg.debug(
            i_text          => 'Error generating member fee on stage ' || l_stage || ': ' || sqlerrm
        );
        com_api_error_pkg.raise_fatal_error(
            i_error         => 'UNHANDLED_EXCEPTION'
          , i_env_param1    => sqlerrm
        );
end gen_member_fee;

procedure gen_retrieval_fee (
    o_fin_id               out com_api_type_pkg.t_long_id
  , i_original_fin_id   in     com_api_type_pkg.t_long_id
  , i_de004             in     mcw_api_type_pkg.t_de004          default null
  , i_de030_1           in     mcw_api_type_pkg.t_de030s         default null
  , i_de049             in     mcw_api_type_pkg.t_de049          default null
  , i_de072             in     mcw_api_type_pkg.t_de072          default null
  , i_p0149_1           in     mcw_api_type_pkg.t_p0149_1        default null
  , i_p0149_2           in     mcw_api_type_pkg.t_p0149_2        default null
  , i_ext_claim_id      in     mcw_api_type_pkg.t_ext_claim_id   default null
  , i_ext_message_id    in     mcw_api_type_pkg.t_ext_message_id default null
) is
    l_original_fin_rec        mcw_api_type_pkg.t_fin_rec;
    l_fin_rec                 mcw_api_type_pkg.t_fin_rec;
    l_standard_id             com_api_type_pkg.t_tiny_id;
    l_host_id                 com_api_type_pkg.t_tiny_id;
    l_stage                   varchar2(100);
begin
    trc_log_pkg.debug (
        i_text         => 'Generating/updating retrieval fee'
    );
        
    l_stage := 'load original fin';

    mcw_api_fin_pkg.get_fin (
        i_id         => i_original_fin_id
      , o_fin_rec    => l_original_fin_rec
    );

    if l_original_fin_rec.mti             = mcw_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
       and l_original_fin_rec.de024       = mcw_api_const_pkg.FUNC_CODE_RETRIEVAL_REQUEST
       and l_original_fin_rec.is_reversal = com_api_const_pkg.FALSE
       and l_original_fin_rec.is_incoming = com_api_const_pkg.TRUE
       and l_original_fin_rec.p0228       = mcw_api_const_pkg.RETRIEVAL_DOCUMENT_HARDCOPY
    then
        l_stage := 'init';
        -- init
            
        o_fin_id     := opr_api_create_pkg.get_id;
        l_fin_rec.id := o_fin_id;

        l_fin_rec.inst_id     := l_original_fin_rec.inst_id;
        l_fin_rec.network_id  := l_original_fin_rec.network_id;

        l_fin_rec.is_incoming     := com_api_type_pkg.FALSE;
        l_fin_rec.is_reversal     := com_api_type_pkg.FALSE;
        l_fin_rec.is_rejected     := com_api_type_pkg.FALSE;
        l_fin_rec.is_fpd_matched  := com_api_type_pkg.FALSE;
        l_fin_rec.is_fsum_matched := com_api_type_pkg.FALSE;
        l_fin_rec.file_id         := null;

        l_stage := 'mti & de24';
        l_fin_rec.mti   := mcw_api_const_pkg.MSG_TYPE_FEE;
        l_fin_rec.de024 := mcw_api_const_pkg.FUNC_CODE_MEMBER_FEE;

        l_stage := 'sync_dispute_id';
        sync_dispute_id (
            io_fin_rec      => l_original_fin_rec
          , o_dispute_id    => l_fin_rec.dispute_id
          , o_dispute_rn    => l_fin_rec.dispute_rn
        );

        l_stage := 'de002 - de003_1';
        l_fin_rec.de002   := l_original_fin_rec.de002;
        l_fin_rec.de003_1 := mcw_api_const_pkg.PROC_CODE_CREDIT_FEE;

        l_fin_rec.de004   := i_de004;

        l_stage := 'de014 - de043_6';
        l_fin_rec.de014   := l_original_fin_rec.de014;
        l_fin_rec.de023   := l_original_fin_rec.de023;
        l_fin_rec.de025   := mcw_api_const_pkg.FEE_REASON_RETRIEVAL_RESP;
        l_fin_rec.de026   := l_original_fin_rec.de026;
        l_fin_rec.de030_1 := nvl(i_de030_1, l_original_fin_rec.de030_1);
        l_fin_rec.de030_2 := 0;
        l_fin_rec.de031   := l_original_fin_rec.de031;
        l_fin_rec.de033   := l_original_fin_rec.de100;
        l_fin_rec.de037   := l_original_fin_rec.de037;
        l_fin_rec.de038   := l_original_fin_rec.de038;
        l_fin_rec.de041   := l_original_fin_rec.de041;
        l_fin_rec.de042   := l_original_fin_rec.de042;
        l_fin_rec.de043_1 := l_original_fin_rec.de043_1;
        l_fin_rec.de043_2 := l_original_fin_rec.de043_2;
        l_fin_rec.de043_3 := l_original_fin_rec.de043_3;
        l_fin_rec.de043_4 := l_original_fin_rec.de043_4;
        l_fin_rec.de043_5 := l_original_fin_rec.de043_5;
        l_fin_rec.de043_6 := l_original_fin_rec.de043_6;

        l_stage := 'de049';
        l_fin_rec.de049   := i_de049;

        l_stage := 'de063';
        l_fin_rec.de063   := l_original_fin_rec.de063;
        l_stage := 'de072';
        l_fin_rec.de072   := i_de072;

        l_stage := 'de072';
        l_fin_rec.de073   := trunc(l_original_fin_rec.de012);
        if l_fin_rec.de073 is null then
            mcw_api_fin_pkg.get_processing_date (
                i_id                 => null
                , i_is_fpd_matched   => com_api_type_pkg.FALSE
                , i_is_fsum_matched  => com_api_type_pkg.FALSE
                , i_file_id          => l_original_fin_rec.file_id
                , o_p0025_2          => l_fin_rec.de073
            );
        end if;

        l_stage := 'de094 - de095';
        l_fin_rec.de094 := l_original_fin_rec.de093;
        l_fin_rec.de095 := l_original_fin_rec.de095;

        l_stage := 'p0137';
        l_fin_rec.p0137 := lpad(to_char(l_fin_rec.id), 17, '0');

        l_stage := 'p0149';
        l_fin_rec.p0149_1 := nvl(i_p0149_1, l_original_fin_rec.p0149_1);
        l_fin_rec.p0149_2 := lpad(nvl(i_p0149_2, l_original_fin_rec.p0149_2), 3, '0');

        l_stage := 'add_curr_exp';
        mcw_utl_pkg.add_curr_exp (
            io_p0148       => l_fin_rec.p0148
            , i_curr_code  => l_fin_rec.p0149_1
        );

        l_fin_rec.p0158_2 := l_original_fin_rec.p0158_2;
        l_fin_rec.p0158_3 := l_original_fin_rec.p0158_3;
        l_fin_rec.p0158_4 := l_original_fin_rec.p0158_4;

        l_fin_rec.p0165 := l_original_fin_rec.p0165;
        l_fin_rec.p0228 := l_original_fin_rec.p0228;
        l_fin_rec.p0230 := mcw_api_const_pkg.RETRIEVAL_DOCUMENT_HARDCOPY;
        l_fin_rec.p0264 := l_original_fin_rec.de025;

        l_fin_rec.p0375 := l_fin_rec.id;
        l_fin_rec.ext_claim_id   := i_ext_claim_id;
        l_fin_rec.ext_message_id := i_ext_message_id;

        l_fin_rec.local_message := l_original_fin_rec.local_message;

        if csm_api_utl_pkg.is_mcom_enabled(
               i_network_id  => l_fin_rec.network_id
             , i_inst_id     => l_fin_rec.inst_id
             , i_host_id     => l_host_id
             , i_standard_id => l_standard_id
            ) = com_api_const_pkg.TRUE 
        then
            l_fin_rec.status := mup_api_const_pkg.MSG_STATUS_DO_NOT_UNLOAD;
        else
            l_fin_rec.status := net_api_const_pkg.CLEARING_MSG_STATUS_READY;
        end if;

        l_stage := 'put_message';
        mcw_api_fin_pkg.put_message (
            i_fin_rec  => l_fin_rec
        );
    
        l_stage := 'create_operation';
    
        mcw_api_fin_pkg.create_operation(
            i_fin_rec      => l_fin_rec
          , i_standard_id  => l_standard_id
        );

        l_stage := 'done';
    else
        trc_log_pkg.warn(
            i_text       => 'MCW_DSP_NOT_GENERATED'
          , i_env_param1 => l_original_fin_rec.id
          , i_env_param2 => l_original_fin_rec.mti
          , i_env_param3 => l_original_fin_rec.de024
          , i_env_param5 => l_original_fin_rec.is_reversal
          , i_env_param6 => l_original_fin_rec.is_incoming
        );
    end if;

    trc_log_pkg.debug (
        i_text         => 'Generating retrieval fee. Assigned id [#1]'
      , i_env_param1   => l_fin_rec.id
    );
exception
    when others then
        trc_log_pkg.debug(
            i_text          => 'Error generating retrieval fee on stage ' || l_stage || ': ' || sqlerrm
        );
        com_api_error_pkg.raise_fatal_error(
            i_error         => 'UNHANDLED_EXCEPTION'
          , i_env_param1    => sqlerrm
        );
end gen_retrieval_fee;

procedure gen_retrieval_request (
    o_fin_id               out com_api_type_pkg.t_long_id
  , i_original_fin_id   in     com_api_type_pkg.t_long_id
  , i_de025             in     mcw_api_type_pkg.t_de025
  , i_p0228             in     mcw_api_type_pkg.t_p0228
  , i_ext_claim_id      in     mcw_api_type_pkg.t_ext_claim_id   default null
  , i_ext_message_id    in     mcw_api_type_pkg.t_ext_message_id default null
) is
    l_original_fin_rec        mcw_api_type_pkg.t_fin_rec;
    l_fin_rec                 mcw_api_type_pkg.t_fin_rec;
    l_standard_id             com_api_type_pkg.t_tiny_id;
    l_host_id                 com_api_type_pkg.t_tiny_id;
    l_stage                   varchar2(100);
begin
    trc_log_pkg.debug (
        i_text         => 'Generating/updating retrieval request'
    );

    l_stage := 'load original fin';

    mcw_api_fin_pkg.get_fin (
        i_id         => i_original_fin_id
        , o_fin_rec  => l_original_fin_rec
    );

    if l_original_fin_rec.mti             = mcw_api_const_pkg.MSG_TYPE_PRESENTMENT
       and l_original_fin_rec.de024       = mcw_api_const_pkg.FUNC_CODE_FIRST_PRES
       and l_original_fin_rec.is_reversal = com_api_type_pkg.FALSE
       and l_original_fin_rec.is_incoming = com_api_type_pkg.TRUE
    then
        l_stage := 'init';
        -- init

        o_fin_id     := opr_api_create_pkg.get_id;
        l_fin_rec.id := o_fin_id;

        l_fin_rec.inst_id         := l_original_fin_rec.inst_id;
        l_fin_rec.network_id      := l_original_fin_rec.network_id;

        l_fin_rec.is_incoming     := com_api_type_pkg.FALSE;
        l_fin_rec.is_reversal     := com_api_type_pkg.FALSE;
        l_fin_rec.is_rejected     := com_api_type_pkg.FALSE;
        l_fin_rec.is_fpd_matched  := com_api_type_pkg.FALSE;
        l_fin_rec.is_fsum_matched := com_api_type_pkg.FALSE;
        l_fin_rec.file_id         := null;

        l_stage := 'mti & de24';
        l_fin_rec.mti   := mcw_api_const_pkg.MSG_TYPE_ADMINISTRATIVE;
        l_fin_rec.de024 := mcw_api_const_pkg.FUNC_CODE_RETRIEVAL_REQUEST;

        sync_dispute_id (
            io_fin_rec      => l_original_fin_rec
          , o_dispute_id    => l_fin_rec.dispute_id
          , o_dispute_rn    => l_fin_rec.dispute_rn
        );

        l_stage := 'de002 - de022';
        l_fin_rec.de002    := l_original_fin_rec.de002;
        l_fin_rec.de003_1  := l_original_fin_rec.de003_1;
        l_fin_rec.de003_2  := l_original_fin_rec.de003_2;
        l_fin_rec.de003_3  := l_original_fin_rec.de003_3;
        l_fin_rec.de012    := l_original_fin_rec.de012;
        l_fin_rec.de014    := l_original_fin_rec.de014;

        l_fin_rec.de022_1  := l_original_fin_rec.de022_1;
        l_fin_rec.de022_2  := l_original_fin_rec.de022_2;
        l_fin_rec.de022_3  := l_original_fin_rec.de022_3;
        l_fin_rec.de022_4  := l_original_fin_rec.de022_4;
        l_fin_rec.de022_5  := l_original_fin_rec.de022_5;
        l_fin_rec.de022_6  := l_original_fin_rec.de022_6;
        l_fin_rec.de022_7  := l_original_fin_rec.de022_7;
        l_fin_rec.de022_8  := l_original_fin_rec.de022_8;
        l_fin_rec.de022_9  := l_original_fin_rec.de022_9;
        l_fin_rec.de022_10 := l_original_fin_rec.de022_10;
        l_fin_rec.de022_11 := l_original_fin_rec.de022_11;
        l_fin_rec.de022_12 := l_original_fin_rec.de022_12;

        l_stage := 'de023 - de094';
        l_fin_rec.de023    := l_original_fin_rec.de023;
        l_fin_rec.de025    := i_de025;
        l_fin_rec.de026    := l_original_fin_rec.de026;
        l_fin_rec.de030_1  := l_original_fin_rec.de004;
        l_fin_rec.de030_2  := 0;
        l_fin_rec.de031    := l_original_fin_rec.de031;
        l_fin_rec.de032    := l_original_fin_rec.de032;
        l_fin_rec.de033    := l_original_fin_rec.de100;
        l_fin_rec.de037    := l_original_fin_rec.de037;
        l_fin_rec.de038    := l_original_fin_rec.de038;
        l_fin_rec.de041    := l_original_fin_rec.de041;
        l_fin_rec.de042    := l_original_fin_rec.de042;
        l_fin_rec.de043_1  := l_original_fin_rec.de043_1;
        l_fin_rec.de043_2  := l_original_fin_rec.de043_2;
        l_fin_rec.de043_3  := l_original_fin_rec.de043_3;
        l_fin_rec.de043_4  := l_original_fin_rec.de043_4;
        l_fin_rec.de043_5  := l_original_fin_rec.de043_5;
        l_fin_rec.de043_6  := l_original_fin_rec.de043_6;
        l_fin_rec.de063    := l_original_fin_rec.de063;
        l_fin_rec.de094    := l_original_fin_rec.de093;

        l_stage := 'build_irn';
        l_fin_rec.de095    := mcw_utl_pkg.build_irn;

        l_stage := 'p0001_1 - p0149_2';
        l_fin_rec.p0001_1 := l_original_fin_rec.p0001_1;
        l_fin_rec.p0001_2 := l_original_fin_rec.p0001_2;
        l_fin_rec.p0058   := l_original_fin_rec.p0058;
        l_fin_rec.p0059   := l_original_fin_rec.p0059;
        l_fin_rec.p0149_1 := l_original_fin_rec.de049;
        l_fin_rec.p0149_2 := '000';

        l_stage := 'add_curr_exp';
        mcw_utl_pkg.add_curr_exp (
            io_p0148       => l_fin_rec.p0148
            , i_curr_code  => l_fin_rec.p0149_1
        );

        l_stage := 'p0158_4 - p0375';
        l_fin_rec.p0158_4 := l_original_fin_rec.p0158_4;
        l_fin_rec.p0165   := l_original_fin_rec.p0165;
        l_fin_rec.p0207   := l_original_fin_rec.p0207;
        l_fin_rec.p0228   := i_p0228;
        l_fin_rec.p0375   := l_fin_rec.id;

        l_stage := 'emv';
        l_fin_rec.emv_9f26 := l_original_fin_rec.emv_9f26;
        l_fin_rec.emv_9f02 := l_original_fin_rec.emv_9f02;
        l_fin_rec.emv_9F10 := l_original_fin_rec.emv_9F10;
        l_fin_rec.emv_9F36 := l_original_fin_rec.emv_9F36;
        l_fin_rec.emv_95 := l_original_fin_rec.emv_95;
        l_fin_rec.emv_82 := l_original_fin_rec.emv_82;
        l_fin_rec.emv_9a := l_original_fin_rec.emv_9a;
        l_fin_rec.emv_9c := l_original_fin_rec.emv_9c;
        l_fin_rec.emv_9f37 := l_original_fin_rec.emv_9f37;
        l_fin_rec.emv_5f2a := l_original_fin_rec.emv_5f2a;
        l_fin_rec.emv_9f33 := l_original_fin_rec.emv_9f33;
        l_fin_rec.emv_9f34 := l_original_fin_rec.emv_9f34;
        l_fin_rec.emv_9f1a := l_original_fin_rec.emv_9f1a;
        l_fin_rec.emv_9f35 := l_original_fin_rec.emv_9f35;
        l_fin_rec.emv_9f53 := l_original_fin_rec.emv_9f53;
        l_fin_rec.emv_84 := l_original_fin_rec.emv_84;
        l_fin_rec.emv_9f09 := l_original_fin_rec.emv_9f09;
        l_fin_rec.emv_9f03 := l_original_fin_rec.emv_9f03;
        l_fin_rec.emv_9f1e := l_original_fin_rec.emv_9f1e;
        l_fin_rec.emv_9f41 := l_original_fin_rec.emv_9f41;
        l_fin_rec.ext_claim_id   := i_ext_claim_id;
        l_fin_rec.ext_message_id := i_ext_message_id;
        l_fin_rec.local_message := l_original_fin_rec.local_message;

        l_host_id := net_api_network_pkg.get_default_host (
            i_network_id  => l_fin_rec.network_id
        );
        l_standard_id := net_api_network_pkg.get_offline_standard (
            i_host_id       => l_host_id
        );

        if csm_api_utl_pkg.is_mcom_enabled(
               i_network_id  => l_fin_rec.network_id
             , i_inst_id     => l_fin_rec.inst_id
             , i_host_id     => l_host_id
             , i_standard_id => l_standard_id
           ) = com_api_const_pkg.TRUE
        then
            l_fin_rec.status := mup_api_const_pkg.MSG_STATUS_DO_NOT_UNLOAD;
        else
            l_fin_rec.status := net_api_const_pkg.CLEARING_MSG_STATUS_READY;
        end if;

        l_stage := 'put_message';
        mcw_api_fin_pkg.put_message (
            i_fin_rec  => l_fin_rec
        );
    
        l_stage := 'create_operation';
    
        mcw_api_fin_pkg.create_operation (
            i_fin_rec      => l_fin_rec
          , i_standard_id  => l_standard_id
        );
            
        l_stage := 'done';
    else
        trc_log_pkg.warn(
            i_text       => 'MCW_DSP_NOT_GENERATED'
          , i_env_param1 => l_original_fin_rec.id
          , i_env_param2 => l_original_fin_rec.mti
          , i_env_param3 => l_original_fin_rec.de024
          , i_env_param5 => l_original_fin_rec.is_reversal
          , i_env_param6 => l_original_fin_rec.is_incoming
        );
    end if;

    trc_log_pkg.debug (
        i_text         => 'Generating retrieval request. Assigned id [#1]'
      , i_env_param1   => l_fin_rec.id
    );
exception
    when others then
        trc_log_pkg.debug(
            i_text          => 'Error generating retrieval request on stage ' || l_stage || ': ' || sqlerrm
        );
        com_api_error_pkg.raise_fatal_error(
            i_error         => 'UNHANDLED_EXCEPTION'
          , i_env_param1    => sqlerrm
        );
end gen_retrieval_request;

procedure update_dispute_id (
    i_id                      in com_api_type_pkg.t_long_id
  , i_dispute_id              in com_api_type_pkg.t_long_id
) is
begin
    update mcw_fin
       set dispute_id = i_dispute_id
     where id         = i_id;

    update opr_operation
       set dispute_id = i_dispute_id
     where id         = i_id;

end update_dispute_id;

procedure fetch_dispute_id (
    i_fin_cur            in     sys_refcursor
  , o_fin_rec               out mcw_api_type_pkg.t_fin_rec
) is
    l_fin_tab               mcw_api_type_pkg.t_fin_tab;
begin
    savepoint fetch_dispute_id;

    if i_fin_cur%isopen then
        fetch i_fin_cur bulk collect into l_fin_tab;

        for i in 1..l_fin_tab.count loop
            if i = 1 then
                if l_fin_tab(i).dispute_id is null then
                    l_fin_tab(i).dispute_id := dsp_api_shared_data_pkg.get_id;
                    update_dispute_id (
                        i_id            => l_fin_tab(i).id
                        , i_dispute_id  => l_fin_tab(i).dispute_id
                    );
                end if;

                o_fin_rec := l_fin_tab(i);
            else
                if l_fin_tab(i).dispute_id is null then
                    update_dispute_id (
                        i_id            => l_fin_tab(i).id
                        , i_dispute_id  => o_fin_rec.dispute_id
                    );

                elsif l_fin_tab(i).dispute_id != o_fin_rec.dispute_id then
                    trc_log_pkg.debug (
                        i_text => 'TOO_MANY_DISPUTES_FOUND'
                    );
                    o_fin_rec := null;
                    rollback to savepoint fetch_dispute_id;
                    return;

                end if;

            end if;
        end loop;

        if l_fin_tab.count = 0 then
            trc_log_pkg.debug (
                i_text  => 'NO_DISPUTE_FOUND'
            );
            o_fin_rec := null;
            rollback to savepoint fetch_dispute_id;
        end if;
    end if;
exception
    when others then
        rollback to savepoint fetch_dispute_id;
        raise;
end fetch_dispute_id;

procedure load_auth(
    i_id                    in            com_api_type_pkg.t_long_id
  , io_auth                 in out nocopy aut_api_type_pkg.t_auth_rec
) is
begin
    select
        min(o.id) id
        , min(o.sttl_type) sttl_type
        , min(o.match_status) match_status
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.inst_id, null)) iss_inst_id
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.network_id, null)) iss_network_id
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ACQUIRER, p.inst_id, null)) acq_inst_id
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ACQUIRER, p.network_id, null)) acq_network_id
            
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.card_inst_id, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.card_network_id, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.card_type_id, null))
        , min(decode(p.participant_type, com_api_const_pkg.PARTICIPANT_ISSUER, p.card_country, null))
    into
        io_auth.id
        , io_auth.sttl_type
        , io_auth.match_status
        , io_auth.iss_inst_id
        , io_auth.iss_network_id
        , io_auth.acq_inst_id
        , io_auth.acq_network_id
            
        , io_auth.card_inst_id
        , io_auth.card_network_id
        , io_auth.card_type_id
        , io_auth.card_country
    from
        opr_operation o
        , opr_participant p
        , opr_card c
    where
        o.id = i_id
        and p.oper_id = o.id
        and p.oper_id = c.oper_id(+)
        and p.participant_type = c.participant_type(+);

end load_auth;

procedure assign_dispute_id (
    io_fin_rec                in out nocopy mcw_api_type_pkg.t_fin_rec
  , o_auth                       out        aut_api_type_pkg.t_auth_rec
  , i_need_repeat             in            com_api_type_pkg.t_boolean   default com_api_type_pkg.FALSE
) is
    l_original_fin_rec        mcw_api_type_pkg.t_fin_rec;
    l_need_original_rec       com_api_type_pkg.t_boolean;
begin
    io_fin_rec.dispute_id := null;
    l_need_original_rec   := com_api_type_pkg.TRUE;

    if io_fin_rec.mti = mcw_api_const_pkg.MSG_TYPE_PRESENTMENT
       and io_fin_rec.de024 = mcw_api_const_pkg.FUNC_CODE_FIRST_PRES
       and io_fin_rec.is_reversal = com_api_type_pkg.FALSE
    then
        mcw_api_fin_pkg.get_original_fin (
            i_mti        => mcw_api_const_pkg.MSG_TYPE_PRESENTMENT
            , i_de002    => io_fin_rec.de002
            , i_de024    => mcw_api_const_pkg.FUNC_CODE_FIRST_PRES
            , i_de031    => io_fin_rec.de031
            , i_id       => io_fin_rec.id
            , o_fin_rec  => l_original_fin_rec
        );
            
        if l_original_fin_rec.id is not null then
            io_fin_rec.dispute_id := l_original_fin_rec.dispute_id;
        end if;
        l_need_original_rec := com_api_type_pkg.FALSE;

    elsif
        io_fin_rec.mti = mcw_api_const_pkg.MSG_TYPE_PRESENTMENT
        and io_fin_rec.de024 = mcw_api_const_pkg.FUNC_CODE_FIRST_PRES
        and io_fin_rec.is_reversal != com_api_type_pkg.FALSE
        or
        io_fin_rec.mti = mcw_api_const_pkg.MSG_TYPE_PRESENTMENT
        and io_fin_rec.de024 != mcw_api_const_pkg.FUNC_CODE_FIRST_PRES
        or
        io_fin_rec.mti = mcw_api_const_pkg.MSG_TYPE_CHARGEBACK
        or
        io_fin_rec.mti = mcw_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
        and io_fin_rec.de024 = mcw_api_const_pkg.FUNC_CODE_RETRIEVAL_REQUEST
        or
        io_fin_rec.mti = mcw_api_const_pkg.MSG_TYPE_FEE
        and io_fin_rec.de024 = mcw_api_const_pkg.FUNC_CODE_MEMBER_FEE
        and io_fin_rec.de025 = mcw_api_const_pkg.FEE_REASON_RETRIEVAL_RESP
    then
        mcw_api_fin_pkg.get_original_fin (
            i_mti        => mcw_api_const_pkg.MSG_TYPE_PRESENTMENT
            , i_de002    => io_fin_rec.de002
            , i_de024    => mcw_api_const_pkg.FUNC_CODE_FIRST_PRES
            , i_de031    => io_fin_rec.de031
            , o_fin_rec  => l_original_fin_rec
        );
        if l_original_fin_rec.id is not null then
            io_fin_rec.dispute_id := l_original_fin_rec.dispute_id;
            io_fin_rec.inst_id := l_original_fin_rec.inst_id;
            io_fin_rec.network_id := l_original_fin_rec.network_id;
                
            load_auth (
                i_id       => l_original_fin_rec.id
                , io_auth  => o_auth
            );
        end if;

    elsif
        io_fin_rec.mti = mcw_api_const_pkg.MSG_TYPE_FEE
        and io_fin_rec.de024 in (
            mcw_api_const_pkg.FUNC_CODE_MEMBER_FEE
            , mcw_api_const_pkg.FUNC_CODE_FEE_RETURN
            , mcw_api_const_pkg.FUNC_CODE_FEE_RESUBMITION
            , mcw_api_const_pkg.FUNC_CODE_FEE_SECOND_RETURN
        )
        and io_fin_rec.de025 in (
            mcw_api_const_pkg.FEE_REASON_HANDL_ISS_CHBK
            , mcw_api_const_pkg.FEE_REASON_HANDL_ACQ_PRES2
            , mcw_api_const_pkg.FEE_REASON_HANDL_ISS_CHBK2
            , mcw_api_const_pkg.FEE_REASON_HANDL_ISS_ADVICE
            , mcw_api_const_pkg.FEE_REASON_HANDL_MEMBER_SETTL
        )
    then
        mcw_api_fin_pkg.get_original_fin (
            i_mti        => mcw_api_const_pkg.MSG_TYPE_PRESENTMENT
            , i_de002    => io_fin_rec.de002
            , i_de024    => mcw_api_const_pkg.FUNC_CODE_FIRST_PRES
            , i_de031    => io_fin_rec.de031
            , o_fin_rec  => l_original_fin_rec
        );
        if l_original_fin_rec.id is null then
            trc_log_pkg.debug (
                i_text => 'Handling fee received, but original presentment not found - probably, you have the right to return the message'
            );

            mcw_api_fin_pkg.get_original_fee (
                i_mti        => io_fin_rec.mti
                , i_de002    => io_fin_rec.de002
                , i_de024    => mcw_api_const_pkg.FUNC_CODE_FIRST_PRES
                , i_de031    => io_fin_rec.de031
                , i_de094    => case when io_fin_rec.de024 in (mcw_api_const_pkg.FUNC_CODE_FEE_RETURN, mcw_api_const_pkg.FUNC_CODE_FEE_SECOND_RETURN) then io_fin_rec.de093 else io_fin_rec.de094 end
                , i_p0137    => io_fin_rec.p0137
                , o_fin_rec  => l_original_fin_rec
            );
        end if;
            
        if l_original_fin_rec.id is not null then
            io_fin_rec.dispute_id := l_original_fin_rec.dispute_id;
            io_fin_rec.inst_id := l_original_fin_rec.inst_id;
            io_fin_rec.network_id := l_original_fin_rec.network_id;
                
            load_auth (
                i_id       => l_original_fin_rec.id
                , io_auth  => o_auth
            );
        end if;

    elsif
        io_fin_rec.mti = mcw_api_const_pkg.MSG_TYPE_FEE
        and io_fin_rec.de024 in (
            mcw_api_const_pkg.FUNC_CODE_FEE_RETURN
            , mcw_api_const_pkg.FUNC_CODE_FEE_RESUBMITION
            , mcw_api_const_pkg.FUNC_CODE_FEE_SECOND_RETURN
        )
    then
        mcw_api_fin_pkg.get_original_fee (
            i_mti        => io_fin_rec.mti
            , i_de002    => io_fin_rec.de002
            , i_de024    => mcw_api_const_pkg.FUNC_CODE_FIRST_PRES
            , i_de031    => io_fin_rec.de031
            , i_de094    => case when io_fin_rec.de024 in (mcw_api_const_pkg.FUNC_CODE_FEE_RETURN, mcw_api_const_pkg.FUNC_CODE_FEE_SECOND_RETURN) then io_fin_rec.de093 else io_fin_rec.de094 end
            , i_p0137    => io_fin_rec.p0137
            , o_fin_rec  => l_original_fin_rec
        );
            
        if l_original_fin_rec.id is not null then
            io_fin_rec.dispute_id := l_original_fin_rec.dispute_id;
            io_fin_rec.inst_id := l_original_fin_rec.inst_id;
            io_fin_rec.network_id := l_original_fin_rec.network_id;
                
            load_auth (
                i_id       => l_original_fin_rec.id
                , io_auth  => o_auth
            );
        end if;

    else
        trc_log_pkg.debug (
            i_text          => 'No neccesseriry to assign dispute_id. [#1]'
            , i_env_param1  => io_fin_rec.id
        );
        l_need_original_rec := com_api_type_pkg.FALSE;

    end if;

    if io_fin_rec.dispute_id is not null then
        trc_log_pkg.debug (
            i_text          => 'Dispute id assigned [#1][#2]'
            , i_env_param1  => io_fin_rec.id
            , i_env_param2  => io_fin_rec.dispute_id
        );
            
    elsif io_fin_rec.dispute_id is null
          and l_need_original_rec = com_api_type_pkg.TRUE
          and i_need_repeat       = com_api_type_pkg.TRUE
    then
        trc_log_pkg.debug (
            i_text          => 'Need repeat for dispute id'
        );
        raise e_need_original_record;

    elsif io_fin_rec.dispute_id is null
          and l_need_original_rec = com_api_type_pkg.FALSE
    then
        trc_log_pkg.debug (
            i_text          => 'No dispute needed'
        );

    else
        io_fin_rec.status := mcw_api_const_pkg.MSG_STATUS_INVALID;

        trc_log_pkg.debug (
            i_text          => 'The dispute is need, but not found. Set message status = invalid'
        );
    end if;
exception
    when others then
        raise;
end assign_dispute_id;

procedure assign_dispute_id (
    io_fin_rec                in out nocopy mcw_api_type_pkg.t_fin_rec
) is
    l_auth                    aut_api_type_pkg.t_auth_rec;
begin
    assign_dispute_id (
        io_fin_rec  => io_fin_rec
        , o_auth    => l_auth
    );
end assign_dispute_id;

procedure gen_handling_fee (
    i_original_fin_rec      in     mcw_api_type_pkg.t_fin_rec
  , i_de004                 in     mcw_api_type_pkg.t_de004
  , i_de049                 in     mcw_api_type_pkg.t_de049
  , i_de072                 in     mcw_api_type_pkg.t_de072
  , i_de025                 in     mcw_api_type_pkg.t_de025
  , i_de093                 in     mcw_api_type_pkg.t_de093
  , o_fin_id                   out com_api_type_pkg.t_long_id
  , i_ext_claim_id          in     mcw_api_type_pkg.t_ext_claim_id
  , i_ext_message_id        in     mcw_api_type_pkg.t_ext_message_id
) is
    l_original_fin_rec        mcw_api_type_pkg.t_fin_rec := i_original_fin_rec;
    l_fin_rec                 mcw_api_type_pkg.t_fin_rec;
    l_standard_id             com_api_type_pkg.t_tiny_id;
    l_host_id                 com_api_type_pkg.t_tiny_id;
    l_stage                   varchar2(100);
begin
    trc_log_pkg.debug (
        i_text         => 'Generating/updating handling fee'
    );
        
    l_stage := 'init';
    o_fin_id     := opr_api_create_pkg.get_id;
    l_fin_rec.id := o_fin_id;

    l_fin_rec.inst_id         := i_original_fin_rec.inst_id;
    l_fin_rec.network_id      := i_original_fin_rec.network_id;

    l_fin_rec.is_rejected     := com_api_type_pkg.FALSE;
    l_fin_rec.is_fpd_matched  := com_api_type_pkg.FALSE;
    l_fin_rec.is_fsum_matched := com_api_type_pkg.FALSE;
    l_fin_rec.file_id         := null;
    l_fin_rec.status          := net_api_const_pkg.CLEARING_MSG_STATUS_READY;

    sync_dispute_id (
        io_fin_rec      => l_original_fin_rec
      , o_dispute_id    => l_fin_rec.dispute_id
      , o_dispute_rn    => l_fin_rec.dispute_rn
    );

    l_stage := 'mti and de24';
    l_fin_rec.mti         := mcw_api_const_pkg.MSG_TYPE_FEE;
    l_fin_rec.de024       := mcw_api_const_pkg.FUNC_CODE_MEMBER_FEE;
    l_fin_rec.is_reversal := com_api_const_pkg.FALSE;
    l_fin_rec.is_incoming := com_api_type_pkg.FALSE;

    l_fin_rec.de002       := l_original_fin_rec.de002;
    l_fin_rec.de003_1     := mcw_api_const_pkg.PROC_CODE_CREDIT_FEE;
    l_fin_rec.de003_2     := mcw_api_const_pkg.DEFAULT_DE003_2;
    l_fin_rec.de003_3     := mcw_api_const_pkg.DEFAULT_DE003_3;

    l_fin_rec.de004       := i_de004;
    l_fin_rec.de049       := i_de049;
    mcw_utl_pkg.add_curr_exp (
        io_p0148       => l_fin_rec.p0148
      , i_curr_code    => l_fin_rec.de049
    );


    l_fin_rec.de025   := i_de025;

    l_fin_rec.de026   := l_original_fin_rec.de026;
    l_fin_rec.de031   := l_original_fin_rec.de031;

    l_fin_rec.de033   := l_original_fin_rec.de033;

    l_fin_rec.de038   := l_original_fin_rec.de038;
    l_fin_rec.de041   := i_original_fin_rec.de041;
    l_fin_rec.de042   := i_original_fin_rec.de042;
    l_fin_rec.de043_1 := l_original_fin_rec.de043_1;
    l_fin_rec.de043_2 := l_original_fin_rec.de043_2;
    l_fin_rec.de043_3 := l_original_fin_rec.de043_3;
    l_fin_rec.de043_4 := l_original_fin_rec.de043_4;
    l_fin_rec.de043_5 := l_original_fin_rec.de043_5;
    l_fin_rec.de043_6 := l_original_fin_rec.de043_6;
    l_fin_rec.de063   := l_original_fin_rec.de063;

    l_fin_rec.de073   := com_api_sttl_day_pkg.get_sysdate();

    l_fin_rec.de093   := i_de093;
    l_fin_rec.de094   := l_original_fin_rec.de094;

    l_fin_rec.p0137   := lpad(to_char(l_fin_rec.id), 17, '0');

    if i_de072 is not null then
        l_fin_rec.de072 := rpad(i_de072, 100, ' ');
        if
        (   ltrim(substr(l_fin_rec.de072, 8, 10)) is null or
            ltrim(substr(l_fin_rec.de072, 8, 10), '0') is null
        ) then
            l_fin_rec.de072 := substr(l_fin_rec.de072, 1, 7) || rpad(nvl(l_original_fin_rec.de095, ' '), 10, ' ') || substr(l_fin_rec.de072, 18);
        end if;
        if l_fin_rec.de025 = mcw_api_const_pkg.FEE_REASON_HANDL_ISS_CHBK then
            if
            (   ltrim(substr(l_fin_rec.de072, 30, 20)) is null or
                ltrim(substr(l_fin_rec.de072, 30, 20), '0') is null
            ) then
                l_fin_rec.de072 := substr(l_fin_rec.de072, 1, 29) || lpad(nvl(l_fin_rec.p0137, '0'), 20, '0') || substr(l_fin_rec.de072, 50);
            end if;
        end if;
    end if;

    l_fin_rec.p0158_2 := l_original_fin_rec.p0158_2;
    l_fin_rec.p0158_3 := l_original_fin_rec.p0158_3;
    l_fin_rec.p0158_4 := l_original_fin_rec.p0158_4;

    l_fin_rec.p0165 := l_original_fin_rec.p0165;

    l_fin_rec.p0375 := l_fin_rec.id;

    l_fin_rec.local_message := l_original_fin_rec.local_message;
    l_fin_rec.ext_claim_id := i_ext_claim_id;
    l_fin_rec.ext_message_id := i_ext_message_id;

    l_host_id := net_api_network_pkg.get_default_host (
        i_network_id  => l_fin_rec.network_id
    );
    l_standard_id := net_api_network_pkg.get_offline_standard (
        i_host_id       => l_host_id
    );

    if csm_api_utl_pkg.is_mcom_enabled(
           i_network_id  => l_fin_rec.network_id
         , i_inst_id     => l_fin_rec.inst_id
         , i_host_id     => l_host_id
         , i_standard_id => l_standard_id
        ) = com_api_const_pkg.TRUE 
    then
        l_fin_rec.status := mup_api_const_pkg.MSG_STATUS_DO_NOT_UNLOAD;
    else
        l_fin_rec.status := net_api_const_pkg.CLEARING_MSG_STATUS_READY;
    end if;
        
    l_stage := 'put_message';
    mcw_api_fin_pkg.put_message (
        i_fin_rec  => l_fin_rec
    );

    l_stage := 'create_operation';
    mcw_api_fin_pkg.create_operation(
        i_fin_rec      => l_fin_rec
      , i_standard_id  => l_standard_id
    );
        
    l_stage := 'done';
    trc_log_pkg.debug (
        i_text         => 'Generating handling fee. Assigned id [#1]'
      , i_env_param1   => l_fin_rec.id
    );
        
exception
    when others then
        trc_log_pkg.debug(
            i_text          => 'Error generating handling fee on stage ' || l_stage || ': ' || sqlerrm
        );
        com_api_error_pkg.raise_fatal_error(
            i_error         => 'UNHANDLED_EXCEPTION'
          , i_env_param1    => sqlerrm
        );
end gen_handling_fee;

procedure gen_chargeback_fee (
    i_original_fin_id   in     com_api_type_pkg.t_long_id
  , i_de004             in     mcw_api_type_pkg.t_de004
  , i_de049             in     mcw_api_type_pkg.t_de049
  , i_de072             in     mcw_api_type_pkg.t_de072
  , o_fin_id               out com_api_type_pkg.t_long_id
  , i_ext_claim_id      in     mcw_api_type_pkg.t_ext_claim_id    default null
  , i_ext_message_id    in     mcw_api_type_pkg.t_ext_message_id  default null
) is
    l_original_fin_rec        mcw_api_type_pkg.t_fin_rec;
    l_pres_fin_rec            mcw_api_type_pkg.t_fin_rec;
    l_de025                   mcw_api_type_pkg.t_de025;
begin
    trc_log_pkg.debug (
        i_text         => 'Generating/updating chargeback fee'
    );

    mcw_api_fin_pkg.get_fin (
        i_id         => i_original_fin_id
      , o_fin_rec    => l_original_fin_rec
    );

    if  l_original_fin_rec.mti              = mcw_api_const_pkg.MSG_TYPE_CHARGEBACK
        and l_original_fin_rec.is_incoming  = com_api_const_pkg.FALSE
        and l_original_fin_rec.is_reversal  = com_api_const_pkg.FALSE
        and l_original_fin_rec.de025       in (mcw_api_const_pkg.CHBK_REASON_WARN_BULLETIN
                                             , mcw_api_const_pkg.CHBK_REASON_NO_AUTH
                                             , mcw_api_const_pkg.CHBK_REASON_NO_AUTH_FLOOR)
    then

        mcw_api_fin_pkg.get_fin (
            i_id         => l_original_fin_rec.dispute_rn
            , o_fin_rec  => l_pres_fin_rec
        );

        if l_original_fin_rec.de024 in
        (   mcw_api_const_pkg.FUNC_CODE_CHARGEBACK1_FULL,
            mcw_api_const_pkg.FUNC_CODE_CHARGEBACK1_PART
        ) then
            l_de025 := mcw_api_const_pkg.FEE_REASON_HANDL_ISS_CHBK;
        else
            l_de025 := mcw_api_const_pkg.FEE_REASON_HANDL_ISS_CHBK2;
        end if;

        gen_handling_fee (
            i_de004               => i_de004
            , i_de049             => i_de049
            , i_de072             => i_de072
            , i_de025             => l_de025
            , i_de093             => l_pres_fin_rec.de094
            , i_original_fin_rec  => l_original_fin_rec
            , o_fin_id            => o_fin_id
            , i_ext_claim_id      => i_ext_claim_id
            , i_ext_message_id    => i_ext_message_id
        );
    else
          trc_log_pkg.warn(
            i_text       => 'MCW_DSP_NOT_GENERATED'
          , i_env_param1 => l_original_fin_rec.id
          , i_env_param2 => l_original_fin_rec.mti
          , i_env_param4 => l_original_fin_rec.de025
          , i_env_param5 => l_original_fin_rec.is_reversal
          , i_env_param6 => l_original_fin_rec.is_incoming
        );
    end if;
        
    trc_log_pkg.debug (
        i_text         => 'Generating chargeback fee. Assigned id [#1]'
      , i_env_param1   => o_fin_id
    );
    
exception
    when others then
        trc_log_pkg.debug(
            i_text          => 'Error generating chargeback fee: ' || sqlerrm
        );
        com_api_error_pkg.raise_fatal_error(
            i_error         => 'UNHANDLED_EXCEPTION'
          , i_env_param1    => sqlerrm
        );
end gen_chargeback_fee;

procedure gen_second_presentment_fee (
    i_original_fin_id   in     com_api_type_pkg.t_long_id
  , i_de004             in     mcw_api_type_pkg.t_de004
  , i_de049             in     mcw_api_type_pkg.t_de049
  , i_de072             in     mcw_api_type_pkg.t_de072
  , o_fin_id               out com_api_type_pkg.t_long_id
  , i_ext_claim_id      in     mcw_api_type_pkg.t_ext_claim_id    default null
  , i_ext_message_id    in     mcw_api_type_pkg.t_ext_message_id  default null
) is
    l_original_fin_rec        mcw_api_type_pkg.t_fin_rec;
    l_chbk_fin_rec            mcw_api_type_pkg.t_fin_rec;
begin
    trc_log_pkg.debug (
        i_text         => 'Generating/updating second presentment fee'
    );        
        
    mcw_api_fin_pkg.get_fin (
        i_id         => i_original_fin_id
        , o_fin_rec  => l_original_fin_rec
    );

    if l_original_fin_rec.mti              = mcw_api_const_pkg.MSG_TYPE_PRESENTMENT
       and l_original_fin_rec.de024       in (mcw_api_const_pkg.FUNC_CODE_SECOND_PRES_FULL
                                            , mcw_api_const_pkg.FUNC_CODE_SECOND_PRES_PART)
       and l_original_fin_rec.is_incoming  = com_api_const_pkg.FALSE
       and l_original_fin_rec.is_reversal  = com_api_const_pkg.FALSE
       and l_original_fin_rec.dispute_rn  is not null
    then
        mcw_api_fin_pkg.get_fin (
            i_id       => l_original_fin_rec.dispute_rn
          , o_fin_rec  => l_chbk_fin_rec
        );

        if l_chbk_fin_rec.mti              = mcw_api_const_pkg.MSG_TYPE_CHARGEBACK
           and l_chbk_fin_rec.is_incoming  = com_api_const_pkg.TRUE 
           and l_chbk_fin_rec.is_reversal  = com_api_const_pkg.FALSE
           and l_chbk_fin_rec.de024       in (mcw_api_const_pkg.FUNC_CODE_CHARGEBACK1_FULL
                                            , mcw_api_const_pkg.FUNC_CODE_CHARGEBACK1_PART)
           and l_chbk_fin_rec.de025       in (mcw_api_const_pkg.CHBK_REASON_WARN_BULLETIN
                                            , mcw_api_const_pkg.CHBK_REASON_NO_AUTH
                                            , mcw_api_const_pkg.CHBK_REASON_NO_AUTH_FLOOR)
        then
            gen_handling_fee (
                i_de004             => i_de004
              , i_de049             => i_de049
              , i_de072             => i_de072
              , i_de025             => mcw_api_const_pkg.FEE_REASON_HANDL_ACQ_PRES2
              , i_de093             => l_chbk_fin_rec.de094
              , i_original_fin_rec  => l_original_fin_rec
              , o_fin_id            => o_fin_id
              , i_ext_claim_id      => i_ext_claim_id
              , i_ext_message_id    => i_ext_message_id
            );
        else
            trc_log_pkg.debug(
                i_text       => 'MCW gen_second_presentment_fee: Chargeback fin rec has unsupported data: [#1] mti [#2] de024 [#3] is_reversal [#4] is_incoming [#5] de025 [#6]'
              , i_env_param1 => l_original_fin_rec.id
              , i_env_param2 => l_original_fin_rec.mti
              , i_env_param3 => l_original_fin_rec.de024
              , i_env_param4 => l_original_fin_rec.is_reversal
              , i_env_param5 => l_original_fin_rec.is_incoming
              , i_env_param6 => l_original_fin_rec.de025
            );
        end if;
    else
        trc_log_pkg.warn(
            i_text       => 'MCW_DSP_NOT_GENERATED'
          , i_env_param1 => l_original_fin_rec.id
          , i_env_param2 => l_original_fin_rec.mti
          , i_env_param3 => l_original_fin_rec.de024
          , i_env_param5 => l_original_fin_rec.is_reversal
          , i_env_param6 => l_original_fin_rec.is_incoming
        );
    end if;
        
    trc_log_pkg.debug (
        i_text         => 'Generating second presentment fee. Assigned id [#1]'
      , i_env_param1   => o_fin_id
    );
exception
    when others then
        trc_log_pkg.debug(
            i_text          => 'Error second presentment fee: ' || sqlerrm
        );
        com_api_error_pkg.raise_fatal_error(
            i_error         => 'UNHANDLED_EXCEPTION'
          , i_env_param1    => sqlerrm
        );
end gen_second_presentment_fee;

procedure gen_fee_dispute (
    i_original_fin_id     in     com_api_type_pkg.t_long_id
  , i_de004               in     mcw_api_type_pkg.t_de004
  , i_de049               in     mcw_api_type_pkg.t_de049
  , i_de025               in     mcw_api_type_pkg.t_de025
  , i_de072               in     mcw_api_type_pkg.t_de072
  , i_de073               in     mcw_api_type_pkg.t_de073
  , o_fin_id                 out com_api_type_pkg.t_long_id
  , i_de024_check         in     mcw_api_type_pkg.t_de024
  , i_ext_claim_id        in     mcw_api_type_pkg.t_ext_claim_id
  , i_ext_message_id      in     mcw_api_type_pkg.t_ext_message_id
) is
    l_fin_rec                 mcw_api_type_pkg.t_fin_rec;
    l_standard_id             com_api_type_pkg.t_tiny_id;
    l_host_id                 com_api_type_pkg.t_tiny_id;
    l_original_fin_rec        mcw_api_type_pkg.t_fin_rec;
    l_stage                   varchar2(100);
begin
    trc_log_pkg.debug (
        i_text         => 'Generating/updating fee dispute'
    );
        
    l_stage := 'load original fin';
    mcw_api_fin_pkg.get_fin (
        i_id         => i_original_fin_id
        , o_fin_rec  => l_original_fin_rec
    );

    if l_original_fin_rec.mti             = mcw_api_const_pkg.MSG_TYPE_FEE
       and l_original_fin_rec.de024       = i_de024_check
       and l_original_fin_rec.is_reversal = com_api_const_pkg.FALSE
       and l_original_fin_rec.is_incoming = com_api_const_pkg.TRUE
    then
        l_stage := 'init';
        -- init
            
        o_fin_id     := opr_api_create_pkg.get_id;
        l_fin_rec.id := o_fin_id;

        l_fin_rec.inst_id         := l_original_fin_rec.inst_id;
        l_fin_rec.network_id      := l_original_fin_rec.network_id;

        l_fin_rec.is_incoming     := com_api_type_pkg.FALSE;
        l_fin_rec.is_rejected     := com_api_type_pkg.FALSE;
        l_fin_rec.is_fpd_matched  := com_api_type_pkg.FALSE;
        l_fin_rec.is_fsum_matched := com_api_type_pkg.FALSE;
        l_fin_rec.file_id         := null;
        l_fin_rec.status          := net_api_const_pkg.CLEARING_MSG_STATUS_READY;

        sync_dispute_id (
            io_fin_rec    => l_original_fin_rec
          , o_dispute_id  => l_fin_rec.dispute_id
          , o_dispute_rn  => l_fin_rec.dispute_rn
        );

        l_stage := 'mti and de024';
        l_fin_rec.mti := mcw_api_const_pkg.MSG_TYPE_FEE;
        l_fin_rec.de024 := mcw_api_const_pkg.FUNC_CODE_FEE_RETURN;
        l_fin_rec.is_reversal := com_api_const_pkg.FALSE;

        l_fin_rec.de003_1 := l_original_fin_rec.de003_1;
        l_fin_rec.de003_2 := mcw_api_const_pkg.DEFAULT_DE003_2;
        l_fin_rec.de003_3 := mcw_api_const_pkg.DEFAULT_DE003_3;


        l_fin_rec.de004 := i_de004;
        l_fin_rec.de049 := i_de049;
        mcw_utl_pkg.add_curr_exp (
            io_p0148       => l_fin_rec.p0148
            , i_curr_code  => l_fin_rec.de049
        );

        l_fin_rec.de025 := i_de025;

        l_fin_rec.de026 := l_original_fin_rec.de026;

        if l_fin_rec.de004 != l_original_fin_rec.de004 then
            l_fin_rec.de030_1 := l_original_fin_rec.de004;
            l_fin_rec.de030_2 := 0;
            l_fin_rec.p0149_1 := l_original_fin_rec.de049;
            l_fin_rec.p0149_2 := '000';

            mcw_utl_pkg.add_curr_exp (
                io_p0148       => l_fin_rec.p0148
                , i_curr_code  => l_fin_rec.p0149_1
            );
        end if;

        l_fin_rec.de031 := l_original_fin_rec.de031;
        l_fin_rec.de033 := l_original_fin_rec.de100;
        l_fin_rec.de038 := l_original_fin_rec.de038;
        l_fin_rec.de041 := l_original_fin_rec.de041;
        l_fin_rec.de042 := l_original_fin_rec.de042;

        l_fin_rec.de043_1 := l_original_fin_rec.de043_1;
        l_fin_rec.de043_2 := l_original_fin_rec.de043_2;
        l_fin_rec.de043_3 := l_original_fin_rec.de043_3;
        l_fin_rec.de043_4 := l_original_fin_rec.de043_4;
        l_fin_rec.de043_5 := l_original_fin_rec.de043_5;
        l_fin_rec.de043_6 := l_original_fin_rec.de043_6;

        if i_de072 is not null then
            l_fin_rec.de072 := rpad(i_de072, 100, ' ');
        end if;
        l_fin_rec.de073 := i_de073;

        l_fin_rec.de093 := l_original_fin_rec.de094;
        l_fin_rec.de094 := l_original_fin_rec.de093;

        l_fin_rec.p0137 := l_original_fin_rec.p0137;

        l_fin_rec.p0158_2 := l_original_fin_rec.p0158_2;
        l_fin_rec.p0158_3 := l_original_fin_rec.p0158_3;
        l_fin_rec.p0158_4 := l_original_fin_rec.p0158_4;

        l_fin_rec.p0165 := l_original_fin_rec.p0165;

        l_fin_rec.p0262 := l_original_fin_rec.p0262;

        if i_de024_check  = mcw_api_const_pkg.FUNC_CODE_MEMBER_FEE then
            if  l_original_fin_rec.de025 is not null or
                l_original_fin_rec.p0158_5 is not null or
                l_original_fin_rec.de072 is not null
            then
                l_fin_rec.p0265 :=
                    lpad(nvl(to_char(l_original_fin_rec.de025), '0'), 4, '0') ||
                    lpad(nvl(to_char(l_original_fin_rec.p0158_5, mcw_api_const_pkg.P0158_DATE_FORMAT), '0'), 6, '0') ||
                    l_fin_rec.p0265;
            else
                l_fin_rec.p0265 := null;
            end if;

        elsif i_de024_check = mcw_api_const_pkg.FUNC_CODE_FEE_RETURN then
            if  l_original_fin_rec.de025 is not null or
                l_original_fin_rec.p0158_5 is not null or
                l_original_fin_rec.de004 is not null or
                l_original_fin_rec.de049 is not null or
                l_original_fin_rec.de072 is not null
            then
                l_fin_rec.p0266 :=
                    lpad(nvl(to_char(l_original_fin_rec.de025), '0'), 4, '0') ||
                    lpad(nvl(to_char(l_original_fin_rec.p0158_5, mcw_api_const_pkg.P0158_DATE_FORMAT), '0'), 6, '0') ||
                    '  ' ||
                    lpad(nvl(to_char(l_original_fin_rec.de004), '0'), 12, '0') ||
                    lpad(nvl(to_char(l_original_fin_rec.de049), '0'), 3, '0') ||
                    l_original_fin_rec.de072;
            else
                l_fin_rec.p0266 := null;
            end if;

        elsif  i_de024_check = mcw_api_const_pkg.FUNC_CODE_FEE_RESUBMITION  then
            if  l_original_fin_rec.de025 is not null or
                l_original_fin_rec.p0158_5 is not null or
                l_original_fin_rec.de004 is not null or
                l_original_fin_rec.de049 is not null or
                l_original_fin_rec.de072 is not null
            then
                l_fin_rec.p0267 :=
                    lpad(nvl(to_char(l_original_fin_rec.de025), '0'), 4, '0') ||
                    lpad(nvl(to_char(l_original_fin_rec.p0158_5, mcw_api_const_pkg.P0158_DATE_FORMAT), '0'), 6, '0') ||
                    '  ' ||
                    lpad(nvl(to_char(l_original_fin_rec.de004), '0'), 12, '0') ||
                    lpad(nvl(to_char(l_original_fin_rec.de049), '0'), 3, '0') ||
                    l_original_fin_rec.de072;
            else
                l_fin_rec.p0267 := null;
            end if;
        end if;

        l_fin_rec.p0375 := l_fin_rec.id;

        l_fin_rec.local_message  := l_original_fin_rec.local_message;
        l_fin_rec.ext_claim_id   := i_ext_claim_id;
        l_fin_rec.ext_message_id := i_ext_message_id;

        l_host_id := net_api_network_pkg.get_default_host (
            i_network_id  => l_fin_rec.network_id
        );
        l_standard_id := net_api_network_pkg.get_offline_standard (
            i_host_id       => l_host_id
        );

        if csm_api_utl_pkg.is_mcom_enabled(
               i_network_id  => l_fin_rec.network_id
             , i_inst_id     => l_fin_rec.inst_id
             , i_host_id     => l_host_id
             , i_standard_id => l_standard_id
            ) = com_api_const_pkg.TRUE 
        then
            l_fin_rec.status := mup_api_const_pkg.MSG_STATUS_DO_NOT_UNLOAD;
        else
            l_fin_rec.status := net_api_const_pkg.CLEARING_MSG_STATUS_READY;
        end if;

        l_stage := 'put_message';
        mcw_api_fin_pkg.put_message (
            i_fin_rec  => l_fin_rec
        );

        l_stage := 'create_operation';
        mcw_api_fin_pkg.create_operation(
            i_fin_rec      => l_fin_rec
          , i_standard_id  => l_standard_id
        );
    else
        trc_log_pkg.warn(
            i_text       => 'MCW_DSP_NOT_GENERATED'
          , i_env_param1 => l_original_fin_rec.id
          , i_env_param2 => l_original_fin_rec.mti
          , i_env_param3 => l_original_fin_rec.de024
          , i_env_param5 => l_original_fin_rec.is_reversal
          , i_env_param6 => l_original_fin_rec.is_incoming
        );
    end if;
        
    trc_log_pkg.debug (
        i_text         => 'Generating fee dispute. Assigned id [#1]'
      , i_env_param1   => o_fin_id
    );
        
exception
    when others then
        trc_log_pkg.debug(
            i_text          => 'Error generating fee dispute on stage ' || l_stage || ': ' || sqlerrm
        );
        com_api_error_pkg.raise_fatal_error(
            i_error         => 'UNHANDLED_EXCEPTION'
          , i_env_param1    => sqlerrm
        );
end gen_fee_dispute;

procedure gen_fee_return (
    i_original_fin_id         in     com_api_type_pkg.t_long_id
  , i_de004                   in     mcw_api_type_pkg.t_de004
  , i_de049                   in     mcw_api_type_pkg.t_de049
  , i_de025                   in     mcw_api_type_pkg.t_de025
  , i_de072                   in     mcw_api_type_pkg.t_de072
  , i_de073                   in     mcw_api_type_pkg.t_de073
  , o_fin_id                     out com_api_type_pkg.t_long_id
 	, i_ext_claim_id            in     mcw_api_type_pkg.t_ext_claim_id    default null
 	, i_ext_message_id          in     mcw_api_type_pkg.t_ext_message_id  default null
) is
begin
    gen_fee_dispute (
        i_original_fin_id  => i_original_fin_id
        , i_de004          => i_de004
        , i_de049          => i_de049
        , i_de025          => i_de025
        , i_de072          => i_de072
        , i_de073          => i_de073
        , o_fin_id         => o_fin_id
        , i_de024_check    => mcw_api_const_pkg.FUNC_CODE_MEMBER_FEE
      	, i_ext_claim_id   => i_ext_claim_id
      	, i_ext_message_id => i_ext_message_id
    );
end gen_fee_return;

procedure gen_fee_resubmition (
    i_original_fin_id         in     com_api_type_pkg.t_long_id
  , i_de004                   in     mcw_api_type_pkg.t_de004
  , i_de049                   in     mcw_api_type_pkg.t_de049
  , i_de025                   in     mcw_api_type_pkg.t_de025
  , i_de072                   in     mcw_api_type_pkg.t_de072
  , i_de073                   in     mcw_api_type_pkg.t_de073
  , o_fin_id                     out com_api_type_pkg.t_long_id
  , i_ext_claim_id            in     mcw_api_type_pkg.t_ext_claim_id   default null
  , i_ext_message_id          in     mcw_api_type_pkg.t_ext_message_id default null
) is
begin
    gen_fee_dispute (
        i_original_fin_id  => i_original_fin_id
        , i_de004          => i_de004
        , i_de049          => i_de049
        , i_de025          => i_de025
        , i_de072          => i_de072
        , i_de073          => i_de073
        , o_fin_id         => o_fin_id
        , i_de024_check    => mcw_api_const_pkg.FUNC_CODE_FEE_RETURN
        , i_ext_claim_id   => i_ext_claim_id
        , i_ext_message_id => i_ext_message_id
    );
end gen_fee_resubmition;

procedure gen_fee_second_return (
    i_original_fin_id  in     com_api_type_pkg.t_long_id
  , i_de004            in     mcw_api_type_pkg.t_de004
  , i_de049            in     mcw_api_type_pkg.t_de049
  , i_de025            in     mcw_api_type_pkg.t_de025
  , i_de072            in     mcw_api_type_pkg.t_de072
  , i_de073            in     mcw_api_type_pkg.t_de073
  , o_fin_id              out com_api_type_pkg.t_long_id
  , i_ext_claim_id     in     mcw_api_type_pkg.t_ext_claim_id   default null
  , i_ext_message_id   in     mcw_api_type_pkg.t_ext_message_id default null
) is
begin
    gen_fee_dispute (
        i_original_fin_id  => i_original_fin_id
        , i_de004          => i_de004
        , i_de049          => i_de049
        , i_de025          => i_de025
        , i_de072          => i_de072
        , i_de073          => i_de073
        , o_fin_id         => o_fin_id
        , i_de024_check    => mcw_api_const_pkg.FUNC_CODE_FEE_RESUBMITION
        , i_ext_claim_id   => i_ext_claim_id
        , i_ext_message_id => i_ext_message_id

    );
end gen_fee_second_return;

procedure gen_fraud(
    i_original_fin_id  in     com_api_type_pkg.t_long_id
  , i_c01              in     com_api_type_pkg.t_dict_value default null
  , i_c02              in     com_api_type_pkg.t_name       default null
  , i_c04              in     com_api_type_pkg.t_name       default null
  , i_c14              in     com_api_type_pkg.t_name       default null
  , i_c15              in     com_api_type_pkg.t_name       default null
  , i_c28              in     com_api_type_pkg.t_dict_value default null
  , i_c29              in     com_api_type_pkg.t_dict_value default null
  , i_c30              in     com_api_type_pkg.t_dict_value default null
  , i_c31              in     com_api_type_pkg.t_dict_value default null
  , i_c44              in     com_api_type_pkg.t_dict_value default null
  , i_ext_claim_id     in     mcw_api_type_pkg.t_ext_claim_id   default null
  , i_ext_message_id   in     mcw_api_type_pkg.t_ext_message_id default null
) is
    l_fin_rec                 mcw_api_type_pkg.t_fin_rec;
    l_fraud_rec               mcw_api_type_pkg.t_fraud_rec;
    l_dispute_id              com_api_type_pkg.t_long_id;
    l_stage                   varchar2(100);
    l_host_id                 com_api_type_pkg.t_tiny_id;
    l_standard_id             com_api_type_pkg.t_tiny_id;
    l_fin_id                  com_api_type_pkg.t_long_id;
    l_auth_id                 com_api_type_pkg.t_long_id;
    l_auth_rec                aut_api_type_pkg.t_auth_rec;
    l_p0023                   mcw_api_type_pkg.t_p0023;
begin
    trc_log_pkg.debug ( i_text => 'Generating message fraud' );

    mcw_api_fin_pkg.get_fin (
        i_id       => i_original_fin_id
      , o_fin_rec  => l_fin_rec
    );

    l_dispute_id := l_fin_rec.dispute_id;

    -- update original mesage
    if l_dispute_id is null
    then
        l_dispute_id := dsp_api_shared_data_pkg.get_id;
        update_dispute_id (
              i_id          => i_original_fin_id
            , i_dispute_id  => l_dispute_id  --l_fin_rec.dispute_id
        );

        l_fin_rec.dispute_id := l_dispute_id;
    end if;

    l_stage := 'set_fraud';

    l_fraud_rec.dispute_id  := l_dispute_id;
    l_fraud_rec.status      := net_api_const_pkg.CLEARING_MSG_STATUS_READY;  --'CLMS0010'; 
    l_fraud_rec.is_rejected := com_api_type_pkg.FALSE;
    l_fraud_rec.is_incoming := com_api_type_pkg.FALSE;
    l_fraud_rec.file_id     := null;

    l_fraud_rec.c01    := i_c01;                              -- record type  
    l_fraud_rec.c02    := i_c02;                              -- issuer control number
   -- l_fraud_rec.c03    := substr( to_char(l_fin_rec.id), 2);  -- mcw_fin.id without first character
    l_fraud_rec.c03    := l_fin_rec.id; 
    l_fraud_rec.c04    := i_c04;                              -- acquirer
    l_fraud_rec.c05    := l_fin_rec.de031;                    -- acquire's reference number
    l_fraud_rec.c06    := com_api_sttl_day_pkg.get_sysdate;   -- fraud posted date
    l_fraud_rec.c07    := l_fin_rec.de002;                    -- cardholder number 
    l_fraud_rec.c08_10 := l_fin_rec.de012;                    -- trans date-time
    l_fraud_rec.c09    := null;                               -- amount u.s.dollar
    l_fraud_rec.c11    := l_fin_rec.de004;                    -- amount in currency of trans.
    l_fraud_rec.c12    := lpad(to_char(l_fin_rec.de049), 3, '0');       -- trans.currency code
    l_fraud_rec.c13    := com_api_currency_pkg.get_currency_exponent (  -- trans.currency exponent
                              i_curr_code => l_fraud_rec.c12
                          ) ;
    l_fraud_rec.c14    := i_c14;                              -- amount cardholder billing
    l_fraud_rec.c15    := i_c15;                              -- currency cardholder billing
    l_fraud_rec.c16    := com_api_currency_pkg.get_currency_exponent (  -- currency cardholder billing exponent
                              i_curr_code => i_c15
                          );
    l_fraud_rec.c17    := l_fin_rec.p0002;                    -- card type
    l_fraud_rec.c18    := l_fin_rec.de043_1;                  -- merchant name

    if l_fin_rec.p0158_1 in ('DMC','MCC')                     -- merchant number 
      then l_fraud_rec.c19 := rpad(nvl(l_fin_rec.de042, '*'), 15, ' ');
      else l_fraud_rec.c19 := null;  
    end if;

    l_fraud_rec.c20 := l_fin_rec.de043_3;                     -- merchant city

    if l_fin_rec.de043_6 = 'USA'                              -- merchant state/province
      then l_fraud_rec.c21 := rpad (ltrim(l_fin_rec.de043_5), 3, ' ');
      else l_fraud_rec.c21 := rpad (' ', 3, ' ');
    end if;

    l_fraud_rec.c22 := l_fin_rec.de043_6;                     -- merchant country

    if l_fin_rec.p0158_1 in ('DMC','MCC')                     -- merchant postal code
      then l_fraud_rec.c23 := rpad(nvl(l_fin_rec.de043_4, '*'), 10, ' ');
      else l_fraud_rec.c23 := null;  
    end if;

    l_fraud_rec.c24 := l_fin_rec.de026;                       -- mcc

    -- Load auth
    begin
        select id
          into l_auth_id
          from opr_operation
         where (id = i_original_fin_id or match_id = i_original_fin_id)
           and msg_type = opr_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION;
             
        opr_api_shared_data_pkg.load_auth(
            i_id        => l_auth_id
          , io_auth     => l_auth_rec
        );
    exception
        when no_data_found then
            l_auth_id := null;
    end;

    if l_auth_id is not null then
        l_p0023 := case l_auth_rec.terminal_operating_env
                       when 'F224000S' then 'CT1' 
                       when 'F224000T' then 'CT2' 
                       when 'F224000U' then 'CT3' 
                       when 'F224000V' then 'CT4'
                       else null
                   end;
        if l_auth_rec.card_data_input_mode in ('F227000U', 'F227000V', 'F227000S', 'F227000T') then
            l_p0023 := 'CT6';
        end if;

        if l_p0023 is null then
            case l_auth_rec.terminal_type
                when acq_api_const_pkg.TERMINAL_TYPE_ATM then l_p0023 := 'ATM';
                when acq_api_const_pkg.TERMINAL_TYPE_IMPRINTER then l_p0023 := 'MAN';
                else null;
            end case;
        end if;

        if l_p0023 is null then
            case l_auth_rec.cat_level
                when 'F22D0001' then l_fin_rec.p0023 := 'CT1';
                when 'F22D0002' then l_fin_rec.p0023 := 'CT2';
                when 'F22D0003' then l_fin_rec.p0023 := 'CT3';
                when 'F22D0004' then l_fin_rec.p0023 := 'CT4';
                when 'F22D0005' then l_fin_rec.p0023 := 'CT5';
                when 'F22D0006' then l_fin_rec.p0023 := 'CT6';
                when 'F22D0007' then l_fin_rec.p0023 := 'CT7';
                when 'F22D0009' then l_fin_rec.p0023 := 'CT9';
                else
                    if l_auth_rec.terminal_type in (acq_api_const_pkg.TERMINAL_TYPE_POS, acq_api_const_pkg.TERMINAL_TYPE_EPOS) then
                        if  l_auth_rec.card_data_input_cap = 'F2210001'
                            or
                            l_auth_rec.card_data_input_cap = 'F221000V' and l_auth_rec.card_data_input_mode = 'F2270001'
                        then
                            l_p0023 := 'MAN';
                        else
                            l_p0023 := 'POI';
                        end if;
                    else
                        l_p0023 := 'NA ';
                    end if;
            end case;
        end if;

        -- C25 (as in avb0302)
        -- 25A - pos terminal attendance ind.
        l_fraud_rec.c25 := case
                               when l_auth_rec.terminal_operating_env in ('F2240001', 'F2240003', 'F224000A')                                  
                               then '0'
                               when l_auth_rec.terminal_operating_env in ('F2240002', 'F2240004', 'F2240005', 'F2240006', 'F224000B')
                                 or (l_auth_rec.terminal_operating_env in ('F2240009', 'F224000S', 'F224000T', 'F224000U', 'F224000V')
                                     and l_p0023 in ('ATM','CT1','CT2','CT3','CT4','CT6','CT7','POI'))
                               then '1'
                               when l_auth_rec.terminal_operating_env in ('F2240000')
                                 or (l_auth_rec.terminal_operating_env in ('F2240009')
                                     and l_p0023 in ('MAN'))
                               then '2'
                               when l_auth_rec.terminal_operating_env in ('F2240009')
                                    and l_p0023 in ('NA ')
                               then '9'
                               else '9'
                           end;

        -- 25B - pos cardholder presence ind.
        l_fraud_rec.c25 := l_fraud_rec.c25
                        || case l_auth_rec.crdh_presence
                                when 'F2250000' then '0'
                                when 'F2250001' then '1'
                                when 'F2250002' then '2'
                                when 'F2250003' then '3'
                                when 'F2250004' then '4'
                                when 'F2250005' then '5'
                                when 'F2250009' then '9'
                                else '9'
                            end;

        -- 25C - cardholder activated terminal level ind.
        l_fraud_rec.c25 := l_fraud_rec.c25
                        || case                     
                             when l_p0023 = 'MAN'         then '0'
                             when l_p0023 in('ATM','CT1') then '1'
                             when l_p0023 = 'CT2'         then '2'
                             when l_p0023 = 'CT3'         then '3'
                             when l_p0023 = 'CT4'         then '4'
                             when l_p0023 in('CT6','POI') then '6'
                             when l_p0023 = 'CT7'         then '7'
                             when l_p0023 = 'CT9'         then '9'
                             else '*'
                           end;

        -- 25D - pos card data terminal inputcapability ind.
        l_fraud_rec.c25 := l_fraud_rec.c25
                        || case            
                             when l_auth_rec.card_data_input_cap in ('F2210000', 'F2210004', 'F221000V') then '0'
                             when l_auth_rec.card_data_input_cap = 'F2210001' then '1'
                             when l_auth_rec.card_data_input_cap = 'F2210002' then '2'
                             when l_auth_rec.card_data_input_cap = 'F221000M' then '3'
                             when l_auth_rec.card_data_input_cap = 'F221000A' then '4'
                             when l_auth_rec.card_data_input_cap = 'F221000D' then '5'
                             when l_auth_rec.card_data_input_cap = 'F2210006' then '6'
                             when l_auth_rec.card_data_input_cap = 'F221000B' then '7'
                             when l_auth_rec.card_data_input_cap = 'F221000C' then '8'
                             when l_auth_rec.card_data_input_cap in ('F2210005', 'F221000E') then '9'
                           end;

        -- 25E - electronic commerce ind.
        l_fraud_rec.c25 := l_fraud_rec.c25
                        || case substr(l_auth_rec.addl_data, 1, 2)
                               when '01' then '21'
                               when '02' then '91'
                               when '04' then '24'
                               else '* '
                           end;

        -- pos entry mode (as in avb0302)
        l_fraud_rec.c26 := case
                               when l_auth_rec.card_data_input_mode in ('F2270000', 'F2270003', 'F227000F') then '00'
                               when l_auth_rec.card_data_input_mode in ('F2270001', 'F2270006')             then '01'
                               when l_auth_rec.card_data_input_mode = 'F2270002'                            then '02'
                               when l_auth_rec.card_data_input_mode = 'F227000C'                            then '05'
                               when l_auth_rec.card_data_input_mode = 'F227000M'                            then '07'
                               when l_auth_rec.card_data_input_mode in ('F2270005', 'F2270007', 'F2270009', 'F227000S', 'F227000U', 'F227000V') then '81'
                               when l_auth_rec.card_data_input_mode = 'F227000T'                            then '82'
                               when l_auth_rec.card_data_input_mode = 'F227000B'                            then '90'
                               when l_auth_rec.card_data_input_mode = 'F227000A'                            then '91'
                               when l_auth_rec.card_data_input_mode = 'F227000N'                            then '92'
                           end;
    else
        --c25 (as in avb0302)
        l_fraud_rec.c25 := case                                   -- 25A - pos terminal attendance ind.
                             when l_fin_rec.de022_4 in ('1', '3') 
                                then '0'
                             when (l_fin_rec.de022_4 in ('2', '4', '5', '6')) or
                                  (l_fin_rec.de022_4 = '9' and l_fin_rec.p0023 in ('ATM','CT1','CT2','CT3','CT4','CT6','CT7','POI'))
                                then '1'
                             when (l_fin_rec.de022_4 in ('0')) or
                                  (l_fin_rec.de022_4 = '9' and l_fin_rec.p0023 in ('MAN'))
                                then '2'
                             else    '9'
                           end;

        l_fraud_rec.c25 := l_fraud_rec.c25 || nvl(l_fin_rec.de022_5, '9');  -- 25B - pos cardholder presence ind.

        l_fraud_rec.c25 := l_fraud_rec.c25                         -- 25C - cardholder activated terminal level ind.
                        || case                     
                             when l_fin_rec.p0023 = 'MAN'         then '0'
                             when l_fin_rec.p0023 in('ATM','CT1') then '1'
                             when l_fin_rec.p0023 = 'CT2'         then '2'
                             when l_fin_rec.p0023 = 'CT3'         then '3'
                             when l_fin_rec.p0023 = 'CT4'         then '4'
                             when l_fin_rec.p0023 in('CT6','POI') then '6'
                             when l_fin_rec.p0023 = 'CT7'         then '7'
                             when l_fin_rec.p0023 = 'CT9'         then '9'
                             else '*'
                           end;

        l_fraud_rec.c25 := l_fraud_rec.c25                          -- 25D - pos card data terminal inputcapability ind.
                        || case            
                             when l_fin_rec.de022_1 in('0', '4', 'V') then '0'
                             when l_fin_rec.de022_1 = '1' then '1'
                             when l_fin_rec.de022_1 = '2' then '2'
                             when l_fin_rec.de022_1 = 'M' then '3'
                             when l_fin_rec.de022_1 = 'A' then '4'
                             when l_fin_rec.de022_1 = 'D' then '5'
                             when l_fin_rec.de022_1 = '6' then '6'
                             when l_fin_rec.de022_1 = 'B' then '7'
                             when l_fin_rec.de022_1 = 'C' then '8'
                             when l_fin_rec.de022_1 in('5', 'E') then '9'
                           end;

        l_fraud_rec.c25 := l_fraud_rec.c25 ||                       -- 25E - electronic commerce ind.
                           nvl(substr(l_fin_rec.p0052, 1, 2), '* ');

        l_fraud_rec.c26 := case                                   -- pos entry mode (as in avb0302)
                             when l_fin_rec.de022_7 in('0','F') then '00'
                             when l_fin_rec.de022_7 in('1','6') then '01'
                             when l_fin_rec.de022_7 = '2'       then '02'
                             when l_fin_rec.de022_7 = 'C'       then '05'
                             when l_fin_rec.de022_7 = '06'      then '06'
                             when l_fin_rec.de022_7 = 'M'       then '07'
                             when l_fin_rec.de022_7 = '08'      then '08'
                             when l_fin_rec.de022_7 = 'S'       then '81'
                             when l_fin_rec.de022_7 = 'T'       then '82'
                             when l_fin_rec.de022_7 = 'B'       then '90'
                             when l_fin_rec.de022_7 = 'A'       then '91'
                             when l_fin_rec.de022_7 = 'N'       then '92'
                           end;
    end if;

    l_fraud_rec.c27 := nvl(l_fin_rec.de041,'99999999');       -- terminal number
    l_fraud_rec.c28 := i_c28;                                 -- fraud type code
    l_fraud_rec.c29 := i_c29;                                 -- sub-fraud type 
    l_fraud_rec.c30 := i_c30;                                 -- chargeback indicator

    if l_fin_rec.p0158_1 in ('DMC','MCC')
        and l_fraud_rec.c28 = 'MFTC0004'  -- counterfeit insurance eligibility
    then
        l_fraud_rec.c31 := i_c31;
    else
        l_fraud_rec.c31 := null;
    end if;

    l_fraud_rec.c32 := l_fin_rec.p0159_8;                     -- settlement date

    begin                                                     -- authorization response code
       select case when status in ('OPST0100','OPST0400','OPST0403') then '00' else '40' end   
         into l_fraud_rec.c33
         from opr_operation
        where id = l_fin_rec.id ;
    exception
        when others then
            l_fraud_rec.c33 := '40';
    end;

    l_fraud_rec.c34 := null;                               -- delete duplicates flag
    l_fraud_rec.c35 := null;                               -- date the cardholder first reported the fraud to the issuer
    l_fraud_rec.c36 := '*';                                -- positive approval response
    l_fraud_rec.c37 := null;                               -- date cardholder reported fraud 

    if l_fin_rec.p0158_1 in ('DMC','MCC')                  -- cvc indicator
      then l_fraud_rec.c39 := '*';
      else l_fraud_rec.c39 := null; 
    end if;

    l_fraud_rec.c44 := i_c44;                              -- account device type
    l_fraud_rec.c45 := case                                -- electronic commerce indicator
                           when substr(l_fin_rec.p0052, 1, 2) = '21' 
                           then substr(l_fin_rec.p0052, 3, 1)
                           else '9'
                       end;

    l_fraud_rec.c46     := 'U';                            -- avs response code
    l_fraud_rec.c47     := nvl(l_fin_rec.de022_6, '9');    -- card present
    l_fraud_rec.c48     := nvl(l_fin_rec.de022_4, '9');    -- terminal operating environment
    l_fraud_rec.inst_id := l_fin_rec.inst_id;
    l_fraud_rec.format  := null;                           -- enhancements indicator
    l_fraud_rec.ext_claim_id    := i_ext_claim_id;
    l_fraud_rec.ext_message_id  := i_ext_message_id;
    l_fin_id := opr_api_create_pkg.get_id;
    
    l_stage := 'put_fraud';
    mcw_api_fin_pkg.put_fraud(
        i_fraud_rec  => l_fraud_rec
      , i_id         => l_fin_id
    );

    l_host_id := net_api_network_pkg.get_default_host(
        i_network_id  => l_fin_rec.network_id
    );
    l_standard_id := net_api_network_pkg.get_offline_standard (
        i_host_id     => l_host_id
    );

    l_stage := 'create_operation';
    l_fin_rec.id                := l_fin_id;
    l_fin_rec.is_incoming       := com_api_type_pkg.FALSE;
    l_fin_rec.is_reversal       := com_api_type_pkg.FALSE;
    l_fin_rec.is_rejected       := com_api_type_pkg.FALSE;
    l_fin_rec.is_fpd_matched    := com_api_type_pkg.FALSE;
    l_fin_rec.is_fsum_matched   := com_api_type_pkg.FALSE;
    l_fin_rec.file_id           := null;

    if csm_api_utl_pkg.is_mcom_enabled(
           i_network_id  => l_fin_rec.network_id
         , i_inst_id     => l_fin_rec.inst_id
         , i_host_id     => l_host_id
         , i_standard_id => l_standard_id
        ) = com_api_const_pkg.TRUE 
    then
        l_fin_rec.status := mup_api_const_pkg.MSG_STATUS_DO_NOT_UNLOAD;
    else
        l_fin_rec.status := net_api_const_pkg.CLEARING_MSG_STATUS_READY;
    end if;

    mcw_api_fin_pkg.create_operation_fraud(
        i_fin_rec           => l_fin_rec
      , i_standard_id       => l_standard_id
      , i_host_id           => l_host_id
      , i_original_fin_id   => i_original_fin_id
    );

    l_stage := 'done';

    trc_log_pkg.debug (
        i_text       => 'Generating message fraud. Assigned id[#1]'
      , i_env_param1 => l_fin_rec.id
    );
exception
    when others then
        trc_log_pkg.debug(
            i_text => 'Error generating message fraud on stage ' || l_stage || ': ' || sqlerrm
        );
        com_api_error_pkg.raise_fatal_error(
            i_error         => 'UNHANDLED_EXCEPTION'
          , i_env_param1    => sqlerrm
        );
end gen_fraud;

procedure gen_retrieval_request_acknowl (
    o_fin_id              out com_api_type_pkg.t_long_id
  , i_original_fin_id  in     com_api_type_pkg.t_long_id
  , i_ext_claim_id     in     mcw_api_type_pkg.t_ext_claim_id    default null
  , i_ext_message_id   in     mcw_api_type_pkg.t_ext_message_id  default null
) is
    l_original_fin_rec        mcw_api_type_pkg.t_fin_rec;
    l_fin_rec                 mcw_api_type_pkg.t_fin_rec;
    l_standard_id             com_api_type_pkg.t_tiny_id;
    l_host_id                 com_api_type_pkg.t_tiny_id;
    l_stage                   varchar2(100);
begin
    trc_log_pkg.debug (
        i_text         => 'Generating/updating retrieval request acknowledgement'
    );

    l_stage := 'load original fin';

    mcw_api_fin_pkg.get_fin (
        i_id         => i_original_fin_id
      , o_fin_rec    => l_original_fin_rec
    );

    if l_original_fin_rec.mti             = mcw_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
       and l_original_fin_rec.de024       = mcw_api_const_pkg.FUNC_CODE_RETRIEVAL_REQUEST
       and l_original_fin_rec.is_reversal = com_api_type_pkg.FALSE
       and l_original_fin_rec.is_incoming = com_api_type_pkg.TRUE
    then
        l_stage := 'init';
        -- init
        o_fin_id     := opr_api_create_pkg.get_id;
        l_fin_rec.id := o_fin_id;

        l_fin_rec.inst_id         := l_original_fin_rec.inst_id;
        l_fin_rec.network_id      := l_original_fin_rec.network_id;

        l_fin_rec.is_incoming     := com_api_type_pkg.FALSE;
        l_fin_rec.is_reversal     := com_api_type_pkg.FALSE;
        l_fin_rec.is_rejected     := com_api_type_pkg.FALSE;
        l_fin_rec.is_fpd_matched  := com_api_type_pkg.FALSE;
        l_fin_rec.is_fsum_matched := com_api_type_pkg.FALSE;
        l_fin_rec.file_id := null;


        l_stage := 'mti & de24';
        l_fin_rec.mti   := mcw_api_const_pkg.MSG_TYPE_ADMINISTRATIVE;
        l_fin_rec.de024 := mcw_api_const_pkg.FUNC_CODE_RETRIEVAL_RQ_ACKNOWL;

        sync_dispute_id (
            io_fin_rec      => l_original_fin_rec
          , o_dispute_id    => l_fin_rec.dispute_id
          , o_dispute_rn    => l_fin_rec.dispute_rn
        );

        l_stage := 'de002 - de022';
        l_fin_rec.de002    := l_original_fin_rec.de002;
        l_fin_rec.de003_1  := l_original_fin_rec.de003_1;
        l_fin_rec.de003_2  := l_original_fin_rec.de003_2;
        l_fin_rec.de003_3  := l_original_fin_rec.de003_3;
        l_fin_rec.de012    := l_original_fin_rec.de012;
        l_fin_rec.de014    := l_original_fin_rec.de014;

        l_fin_rec.de022_1  := l_original_fin_rec.de022_1;
        l_fin_rec.de022_2  := l_original_fin_rec.de022_2;
        l_fin_rec.de022_3  := l_original_fin_rec.de022_3;
        l_fin_rec.de022_4  := l_original_fin_rec.de022_4;
        l_fin_rec.de022_5  := l_original_fin_rec.de022_5;
        l_fin_rec.de022_6  := l_original_fin_rec.de022_6;
        l_fin_rec.de022_7  := l_original_fin_rec.de022_7;
        l_fin_rec.de022_8  := l_original_fin_rec.de022_8;
        l_fin_rec.de022_9  := l_original_fin_rec.de022_9;
        l_fin_rec.de022_10 := l_original_fin_rec.de022_10;
        l_fin_rec.de022_11 := l_original_fin_rec.de022_11;
        l_fin_rec.de022_12 := l_original_fin_rec.de022_12;

        l_stage := 'de023 - de094';
        l_fin_rec.de023    := l_original_fin_rec.de023;
        l_fin_rec.de025    := l_original_fin_rec.de025;
        l_fin_rec.de026    := l_original_fin_rec.de026;
        l_fin_rec.de030_1  := l_original_fin_rec.de004;
        l_fin_rec.de030_2  := 0;
        l_fin_rec.de031    := l_original_fin_rec.de031;
        l_fin_rec.de032    := l_original_fin_rec.de032;
        l_fin_rec.de033    := l_original_fin_rec.de100;
        l_fin_rec.de037    := l_original_fin_rec.de037;
        l_fin_rec.de038    := l_original_fin_rec.de038;
        l_fin_rec.de041    := l_original_fin_rec.de041;
        l_fin_rec.de042    := l_original_fin_rec.de042;
        l_fin_rec.de043_1  := l_original_fin_rec.de043_1;
        l_fin_rec.de043_2  := l_original_fin_rec.de043_2;
        l_fin_rec.de043_3  := l_original_fin_rec.de043_3;
        l_fin_rec.de043_4  := l_original_fin_rec.de043_4;
        l_fin_rec.de043_5  := l_original_fin_rec.de043_5;
        l_fin_rec.de043_6  := l_original_fin_rec.de043_6;
        l_fin_rec.de063    := l_original_fin_rec.de063;
        l_fin_rec.de094    := l_original_fin_rec.de093;

        l_stage := 'build_irn';
        l_fin_rec.de095    := mcw_utl_pkg.build_irn;

        l_fin_rec.p0148    := l_original_fin_rec.p0148;
        l_fin_rec.p0149_1  := l_original_fin_rec.p0149_1;
        l_fin_rec.p0149_2  := l_original_fin_rec.p0149_2;

        l_fin_rec.p0158_2  := l_original_fin_rec.p0158_2;
        l_fin_rec.p0158_3  := l_original_fin_rec.p0158_3;
        l_fin_rec.p0158_4  := l_original_fin_rec.p0158_4;

        l_fin_rec.p0165    := l_original_fin_rec.p0165;

        l_fin_rec.p0228    := l_original_fin_rec.p0228;

        l_fin_rec.p0375    := l_fin_rec.id;

        l_stage := 'emv';
        l_fin_rec.emv_9f26 := l_original_fin_rec.emv_9f26;
        l_fin_rec.emv_9f02 := l_original_fin_rec.emv_9f02;
        l_fin_rec.emv_9F10 := l_original_fin_rec.emv_9F10;
        l_fin_rec.emv_9F36 := l_original_fin_rec.emv_9F36;
        l_fin_rec.emv_95   := l_original_fin_rec.emv_95;
        l_fin_rec.emv_82   := l_original_fin_rec.emv_82;
        l_fin_rec.emv_9a   := l_original_fin_rec.emv_9a;
        l_fin_rec.emv_9c   := l_original_fin_rec.emv_9c;
        l_fin_rec.emv_9f37 := l_original_fin_rec.emv_9f37;
        l_fin_rec.emv_5f2a := l_original_fin_rec.emv_5f2a;
        l_fin_rec.emv_9f33 := l_original_fin_rec.emv_9f33;
        l_fin_rec.emv_9f34 := l_original_fin_rec.emv_9f34;
        l_fin_rec.emv_9f1a := l_original_fin_rec.emv_9f1a;
        l_fin_rec.emv_9f35 := l_original_fin_rec.emv_9f35;
        l_fin_rec.emv_9f53 := l_original_fin_rec.emv_9f53;
        l_fin_rec.emv_84   := l_original_fin_rec.emv_84;
        l_fin_rec.emv_9f09 := l_original_fin_rec.emv_9f09;
        l_fin_rec.emv_9f03 := l_original_fin_rec.emv_9f03;
        l_fin_rec.emv_9f1e := l_original_fin_rec.emv_9f1e;
        l_fin_rec.emv_9f41 := l_original_fin_rec.emv_9f41;
        l_stage := 'dispute';
        l_fin_rec.ext_claim_id   := i_ext_claim_id;
        l_fin_rec.ext_message_id := i_ext_message_id;
        l_fin_rec.local_message  := l_original_fin_rec.local_message;

        l_host_id := net_api_network_pkg.get_default_host (
            i_network_id  => l_fin_rec.network_id
        );
        l_standard_id := net_api_network_pkg.get_offline_standard (
            i_host_id       => l_host_id
        );

        if csm_api_utl_pkg.is_mcom_enabled(
               i_network_id  => l_fin_rec.network_id
             , i_inst_id     => l_fin_rec.inst_id
             , i_host_id     => l_host_id
             , i_standard_id => l_standard_id
            ) = com_api_const_pkg.TRUE 
        then
            l_fin_rec.status := mup_api_const_pkg.MSG_STATUS_DO_NOT_UNLOAD;
        else
            l_fin_rec.status := net_api_const_pkg.CLEARING_MSG_STATUS_READY;
        end if;

        l_stage := 'put_message';
        mcw_api_fin_pkg.put_message (
            i_fin_rec  => l_fin_rec
        );
    
        l_stage := 'create_operation';

        mcw_api_fin_pkg.create_operation(
            i_fin_rec      => l_fin_rec
          , i_standard_id  => l_standard_id
        );

        l_stage := 'done';
    else
        trc_log_pkg.warn(
            i_text       => 'MCW_DSP_NOT_GENERATED'
          , i_env_param1 => l_original_fin_rec.id
          , i_env_param2 => l_original_fin_rec.mti
          , i_env_param3 => l_original_fin_rec.de024
          , i_env_param5 => l_original_fin_rec.is_reversal
          , i_env_param6 => l_original_fin_rec.is_incoming
        );
    end if;

    trc_log_pkg.debug (
        i_text         => 'Generating retrieval request acknowledgement. Assigned id [#1]'
      , i_env_param1   => l_fin_rec.id
    );
exception
    when others then
        trc_log_pkg.debug(
            i_text     => 'Error generating retrieval request acknowledgement on stage '
                       || l_stage || ': ' || sqlerrm
        );
        com_api_error_pkg.raise_fatal_error(
            i_error         => 'UNHANDLED_EXCEPTION'
          , i_env_param1    => sqlerrm
        );
end gen_retrieval_request_acknowl;

function has_dispute_msg(
    i_id                      in com_api_type_pkg.t_long_id
  , i_mti                     in mcw_api_type_pkg.t_mti
  , i_de024_1                 in mcw_api_type_pkg.t_de024
  , i_de024_2                 in mcw_api_type_pkg.t_de024    default null
  , i_reversal                in com_api_type_pkg.t_boolean  default null
  , i_is_uploaded             in com_api_type_pkg.t_boolean  default null
) return com_api_type_pkg.t_boolean is
    l_result                  com_api_type_pkg.t_boolean;
    l_dispute_id              com_api_type_pkg.t_long_id;
begin
    select f.dispute_id
      into l_dispute_id
      from mcw_fin f
     where f.id = i_id;

    select com_api_const_pkg.TRUE
      into l_result
      from opr_operation  op
      join mcw_fin        f    on f.id = op.id
     where op.dispute_id = l_dispute_id
       and f.mti = i_mti
       and f.de024 in (i_de024_1, i_de024_2)
       and f.is_reversal = nvl(i_reversal, f.is_reversal)
       and (    nvl(i_is_uploaded, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE
             or i_is_uploaded = com_api_const_pkg.TRUE
                and f.file_id is not null
           )
       and rownum = 1
    ;
    return l_result;

exception
    when no_data_found then
        return com_api_const_pkg.FALSE;
end has_dispute_msg;
    
procedure change_case_status(
    i_dispute_id              in  com_api_type_pkg.t_long_id
  , i_mti                     in  mcw_api_type_pkg.t_mti
  , i_de024                   in  mcw_api_type_pkg.t_de024
  , i_is_reversal             in  com_api_type_pkg.t_boolean
  , i_reason_code             in  com_api_type_pkg.t_dict_value
  , i_msg_status              in  com_api_type_pkg.t_dict_value
  , i_msg_type                in  com_api_type_pkg.t_dict_value
) as
    l_case_progress               com_api_type_pkg.t_dict_value;
    l_seqnum                      com_api_type_pkg.t_seqnum;
begin
    trc_log_pkg.debug(
        i_text       => 'mcw.change_case_status: dispute_id [#1], mti [#2], de024 [#3], is_reversal [#4], reason_code [#5], msg_type [#6]'
      , i_env_param1 => i_dispute_id
      , i_env_param2 => i_mti
      , i_env_param3 => i_de024
      , i_env_param4 => i_is_reversal
      , i_env_param5 => i_reason_code
      , i_env_param6 => i_msg_type
    );
    csm_api_case_pkg.change_case_status(
        i_dispute_id     => i_dispute_id
      , i_reason_code    => i_msg_status
    );
        
    csm_api_progress_pkg.get_case_progress(
        i_network_id    => mcw_api_const_pkg.MCW_NETWORK_ID
      , i_msg_type      => i_msg_type
      , i_is_reversal   => i_is_reversal
      , i_mask_error    => com_api_const_pkg.FALSE
      , o_case_progress => l_case_progress
    );
        
    trc_log_pkg.debug(
        i_text => 'l_case_progress = ' || l_case_progress
    );

    if l_case_progress is not null then
        csm_api_case_pkg.change_case_progress(
            i_dispute_id      => i_dispute_id
          , io_seqnum         => l_seqnum
          , i_case_progress   => l_case_progress
          , i_reason_code     => i_reason_code
        );
    end if;
end change_case_status;

procedure modify_member_fee(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_network_id                  in     com_api_type_pkg.t_network_id
  , i_de004                       in     mcw_api_type_pkg.t_de004
  , i_de049                       in     mcw_api_type_pkg.t_de049
  , i_de025                       in     mcw_api_type_pkg.t_de025
  , i_de003                       in     mcw_api_type_pkg.t_de003
  , i_de072                       in     mcw_api_type_pkg.t_de072
  , i_de073                       in     mcw_api_type_pkg.t_de073
  , i_de093                       in     mcw_api_type_pkg.t_de093
  , i_de094                       in     mcw_api_type_pkg.t_de094
  , i_de002                       in     mcw_api_type_pkg.t_de002
) is
begin
    trc_log_pkg.debug (
        i_text         => 'mcw_api_dispute_pkg.modify_member_fee Start'
    );

    mcw_api_dispute_pkg.check_dispute_status(
        i_id => i_fin_id
    );

    update mcw_fin
       set network_id   = i_network_id
         , de004        = i_de004
         , de049        = i_de049
         , de025        = i_de025
         , de003_1      = i_de003
         , de072        = i_de072
         , de073        = i_de073
         , de093        = i_de093
         , de094        = i_de094
     where id = i_fin_id;

    update mcw_card
       set card_number  = iss_api_token_pkg.encode_card_number(i_card_number => i_de002)
     where id = i_fin_id;

    opr_api_operation_pkg.update_oper_amount(
        i_id            => i_fin_id
      , i_oper_amount   => i_de004
      , i_oper_currency => i_de049
    );
    
    trc_log_pkg.debug (
        i_text         => 'mcw_api_dispute_pkg.modify_member_fee Finish'
    );

end modify_member_fee;

procedure modify_retrieval_fee(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_de004                       in     mcw_api_type_pkg.t_de004
  , i_de049                       in     mcw_api_type_pkg.t_de049
  , i_de072                       in     mcw_api_type_pkg.t_de072
) is
begin
    trc_log_pkg.debug (
        i_text         => 'mcw_api_dispute_pkg.modify_retrieval_fee Start'
    );

    mcw_api_dispute_pkg.check_dispute_status(
        i_id => i_fin_id
    );

    update mcw_fin
       set de004        = i_de004
         , de049        = i_de049
         , de072        = i_de072
     where id = i_fin_id;

    opr_api_operation_pkg.update_oper_amount(
        i_id            => i_fin_id
      , i_oper_amount   => i_de004
      , i_oper_currency => i_de049
    );
    
    trc_log_pkg.debug (
        i_text         => 'mcw_api_dispute_pkg.modify_retrieval_fee Finish'
    );

end modify_retrieval_fee;

procedure modify_retrieval_request(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_de025                       in     mcw_api_type_pkg.t_de025
  , i_p0228                       in     mcw_api_type_pkg.t_p0228
) is
begin
    trc_log_pkg.debug (
        i_text         => 'mcw_api_dispute_pkg.modify_retrieval_request Start'
    );

    mcw_api_dispute_pkg.check_dispute_status(
        i_id => i_fin_id
    );

    update mcw_fin
       set de025        = i_de025
         , p0228        = i_p0228
     where id = i_fin_id;

    trc_log_pkg.debug (
        i_text         => 'mcw_api_dispute_pkg.modify_retrieval_request Finish'
    );

end modify_retrieval_request;

procedure modify_first_pres_reversal(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_de004                       in     mcw_api_type_pkg.t_de004
  , i_de049                       in     mcw_api_type_pkg.t_de049
) is
begin
    trc_log_pkg.debug (
        i_text         => 'mcw_api_dispute_pkg.modify_first_pres_reversal Start'
    );

    mcw_api_dispute_pkg.check_dispute_status(
        i_id => i_fin_id
    );

    update mcw_fin
       set de004        = i_de004
         , de049        = i_de049
     where id = i_fin_id;

    opr_api_operation_pkg.update_oper_amount(
        i_id            => i_fin_id
      , i_oper_amount   => i_de004
      , i_oper_currency => i_de049
    );
    
    trc_log_pkg.debug (
        i_text         => 'mcw_api_dispute_pkg.modify_first_pres_reversal Finish'
    );

end modify_first_pres_reversal;

procedure modify_chargeback_fee(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_de004                       in     mcw_api_type_pkg.t_de004
  , i_de049                       in     mcw_api_type_pkg.t_de049
  , i_de072                       in     mcw_api_type_pkg.t_de072
) is
begin
    trc_log_pkg.debug (
        i_text         => 'mcw_api_dispute_pkg.modify_chargeback_fee Start'
    );

    mcw_api_dispute_pkg.check_dispute_status(
        i_id => i_fin_id
    );

    update mcw_fin
       set de004        = i_de004
         , de049        = i_de049
         , de072        = i_de072
     where id = i_fin_id;

    opr_api_operation_pkg.update_oper_amount(
        i_id            => i_fin_id
      , i_oper_amount   => i_de004
      , i_oper_currency => i_de049
    );
    
    trc_log_pkg.debug (
        i_text         => 'mcw_api_dispute_pkg.modify_chargeback_fee Finish'
    );

end modify_chargeback_fee;

procedure modify_second_presentment_fee(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_de004                       in     mcw_api_type_pkg.t_de004
  , i_de049                       in     mcw_api_type_pkg.t_de049
  , i_de072                       in     mcw_api_type_pkg.t_de072
) is
begin
    trc_log_pkg.debug (
        i_text         => 'mcw_api_dispute_pkg.modify_second_presentment_fee Start'
    );

    mcw_api_dispute_pkg.check_dispute_status(
        i_id => i_fin_id
    );

    update mcw_fin
       set de004        = i_de004
         , de049        = i_de049
         , de072        = i_de072
     where id = i_fin_id;

    opr_api_operation_pkg.update_oper_amount(
        i_id            => i_fin_id
      , i_oper_amount   => i_de004
      , i_oper_currency => i_de049
    );
    
    trc_log_pkg.debug (
        i_text         => 'mcw_api_dispute_pkg.modify_second_presentment_fee Finish'
    );

end modify_second_presentment_fee;

procedure modify_fee_return(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_de004                       in     mcw_api_type_pkg.t_de004
  , i_de049                       in     mcw_api_type_pkg.t_de049
  , i_de025                       in     mcw_api_type_pkg.t_de025
  , i_de072                       in     mcw_api_type_pkg.t_de072
  , i_de073                       in     mcw_api_type_pkg.t_de073
) is
begin
    trc_log_pkg.debug (
        i_text         => 'mcw_api_dispute_pkg.modify_fee_return Start'
    );

    mcw_api_dispute_pkg.check_dispute_status(
        i_id => i_fin_id
    );

    update mcw_fin
       set de004        = i_de004
         , de049        = i_de049
         , de025        = i_de025
         , de072        = i_de072
         , de073        = i_de073
     where id = i_fin_id;

    opr_api_operation_pkg.update_oper_amount(
        i_id            => i_fin_id
      , i_oper_amount   => i_de004
      , i_oper_currency => i_de049
    );
    
    trc_log_pkg.debug (
        i_text         => 'mcw_api_dispute_pkg.modify_fee_return Finish'
    );

end modify_fee_return;

procedure modify_fee_resubmition (
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_de004                       in     mcw_api_type_pkg.t_de004
  , i_de049                       in     mcw_api_type_pkg.t_de049
  , i_de025                       in     mcw_api_type_pkg.t_de025
  , i_de072                       in     mcw_api_type_pkg.t_de072
  , i_de073                       in     mcw_api_type_pkg.t_de073
) is
begin
    trc_log_pkg.debug (
        i_text         => 'mcw_api_dispute_pkg.modify_fee_resubmition Start'
    );

    mcw_api_dispute_pkg.check_dispute_status(
        i_id => i_fin_id
    );

    update mcw_fin
       set de004        = i_de004
         , de049        = i_de049
         , de025        = i_de025
         , de072        = i_de072
         , de073        = i_de073
     where id = i_fin_id;

    opr_api_operation_pkg.update_oper_amount(
        i_id            => i_fin_id
      , i_oper_amount   => i_de004
      , i_oper_currency => i_de049
    );
    
    trc_log_pkg.debug (
        i_text         => 'mcw_api_dispute_pkg.modify_fee_resubmition Finish'
    );

end modify_fee_resubmition;

procedure modify_fee_second_return (
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_de004                       in     mcw_api_type_pkg.t_de004
  , i_de049                       in     mcw_api_type_pkg.t_de049
  , i_de025                       in     mcw_api_type_pkg.t_de025
  , i_de072                       in     mcw_api_type_pkg.t_de072
  , i_de073                       in     mcw_api_type_pkg.t_de073
) is
begin
    trc_log_pkg.debug (
        i_text         => 'mcw_api_dispute_pkg.modify_fee_second_return Start'
    );

    mcw_api_dispute_pkg.check_dispute_status(
        i_id => i_fin_id
    );

    update mcw_fin
       set de004        = i_de004
         , de049        = i_de049
         , de025        = i_de025
         , de072        = i_de072
         , de073        = i_de073
     where id = i_fin_id;

    opr_api_operation_pkg.update_oper_amount(
        i_id            => i_fin_id
      , i_oper_amount   => i_de004
      , i_oper_currency => i_de049
    );
    
    trc_log_pkg.debug (
        i_text         => 'mcw_api_dispute_pkg.modify_fee_second_return Finish'
    );

end modify_fee_second_return;

procedure modify_fraud(
    i_fin_id                      in     com_api_type_pkg.t_long_id
  , i_c01                         in     com_api_type_pkg.t_dict_value
  , i_c02                         in     com_api_type_pkg.t_medium_id
  , i_c04                         in     com_api_type_pkg.t_medium_id
  , i_c14                         in     mcw_api_type_pkg.t_de004
  , i_c15                         in     mcw_api_type_pkg.t_de049
  , i_c28                         in     com_api_type_pkg.t_dict_value
  , i_c29                         in     com_api_type_pkg.t_dict_value
  , i_c30                         in     com_api_type_pkg.t_dict_value
  , i_c31                         in     com_api_type_pkg.t_dict_value
  , i_c44                         in     com_api_type_pkg.t_dict_value
) is
begin
    trc_log_pkg.debug (
        i_text         => 'mcw_api_dispute_pkg.modify_fraud Start'
    );

    mcw_api_dispute_pkg.check_dispute_status(
        i_id => i_fin_id
    );

    update mcw_fraud
       set c01          = i_c01
         , c02          = i_c02
         , c04          = i_c04
         , c14          = i_c14
         , c15          = i_c15
         , c28          = i_c28
         , c29          = i_c29
         , c30          = i_c30
         , c31          = i_c31
         , c44          = i_c44
     where id = i_fin_id;

    trc_log_pkg.debug (
        i_text         => 'mcw_api_dispute_pkg.modify_fraud Finish'
    );

end modify_fraud;

end mcw_api_dispute_pkg;
/
