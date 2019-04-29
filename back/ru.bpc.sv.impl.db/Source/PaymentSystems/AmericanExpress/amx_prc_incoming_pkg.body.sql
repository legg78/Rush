create or replace package body amx_prc_incoming_pkg as

g_error_flag        com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
g_errors_count      com_api_type_pkg.t_long_id := 0;

function get_inst_id_by_cmid(
    i_iss_business_id       in     com_api_type_pkg.t_name
  , i_network_id            in     com_api_type_pkg.t_tiny_id
  , i_param_name            in     com_api_type_pkg.t_name
) return com_api_type_pkg.t_inst_id is
    l_iss_business_id       com_api_type_pkg.t_name;
    l_result                com_api_type_pkg.t_inst_id;
    l_param_tab             com_api_type_pkg.t_param_tab;
begin
    trc_log_pkg.debug (
        i_text          => 'amx_prc_incoming_pkg.get_inst_id_by_cmid start'
    );

    for r in (
        select m.inst_id
             , i.host_member_id host_id
          from net_interface i
             , net_member m
         where m.network_id = i_network_id
           and m.id         = i.consumer_member_id
    ) loop
        begin
            cmn_api_standard_pkg.get_param_value(
                i_inst_id      => r.inst_id
              , i_standard_id  => amx_api_const_pkg.AMX_CLEARING_STANDARD
              , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
              , i_object_id    => r.host_id
              , i_param_name   => i_param_name--amx_api_const_pkg.CMID_ISSUING
              , o_param_value  => l_iss_business_id
              , i_param_tab    => l_param_tab
            );
        exception
            when com_api_error_pkg.e_application_error then
                null;
        end;

        if l_iss_business_id = i_iss_business_id then
            l_result :=  r.inst_id;
            exit;
        end if;

    end loop;

    trc_log_pkg.debug (
        i_text          => 'amx_prc_incoming_pkg.get_inst_id_by_cmid end'
    );

    return l_result;
end;

function get_message_impact(   
    i_mtid                  in     com_api_type_pkg.t_tiny_id
  , i_func_code             in     com_api_type_pkg.t_curr_code
  , i_proc_code             in     com_api_type_pkg.t_auth_code 
  , i_incoming              in     com_api_type_pkg.t_boolean
  , i_raise_error           in     com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
) return com_api_type_pkg.t_sign is
    l_result                com_api_type_pkg.t_sign;
begin
    select i.impact
      into l_result
      from amx_msg_impact i
     where i.mtid = i_mtid 
       and i.func_code = i_func_code 
       and i.proc_code = i_proc_code 
       and i.incoming = i_incoming;

    return l_result;
exception
    when no_data_found then
        if i_raise_error = com_api_type_pkg.TRUE then
            com_api_error_pkg.raise_error (
                i_error         => 'AMX_INVALID_MESSAGE_IMPACT'
                , i_env_param1  => i_mtid
                , i_env_param2  => i_func_code
                , i_env_param3  => i_proc_code
                , i_env_param4  => i_incoming
            );
        else
            trc_log_pkg.debug (
                i_text         => 'Message impact not found [#1][#2][#3][#4]'
                , i_env_param1  => i_mtid
                , i_env_param2  => i_func_code
                , i_env_param3  => i_proc_code
                , i_env_param4  => i_incoming
            );

            return null;
        end if;
end;

function date_yymm (
    p_date                  in     com_api_type_pkg.t_date_long
) return date is
begin
    if p_date is null or p_date = '0000' then
        return null;
    end if;

    return to_date(p_date, 'YYMM');
end;

procedure process_file_header(
    i_header_data           in     com_api_type_pkg.t_raw_data
  , i_mtid                  in     com_api_type_pkg.t_tiny_id
  , i_network_id            in     com_api_type_pkg.t_tiny_id
  , i_host_id               in     com_api_type_pkg.t_tiny_id
  , i_standard_id           in     com_api_type_pkg.t_tiny_id
  , i_action_code           in     com_api_type_pkg.t_curr_code 
  , i_incom_sess_file_id    in     com_api_type_pkg.t_long_id
  , o_amx_file                 out amx_api_type_pkg.t_amx_file_rec
)is
    l_file_date             com_api_type_pkg.t_date_long;
    l_msg_number            com_api_type_pkg.t_short_id;
    l_global_netw_id        com_api_type_pkg.t_cmid;
    l_demogr_buisness_id    com_api_type_pkg.t_cmid;
    l_param_tab             com_api_type_pkg.t_param_tab;
    
begin
    trc_log_pkg.debug (
        i_text          => 'amx_prc_incoming_pkg.process_file_header start'
    );

    o_amx_file.is_incoming         := com_api_type_pkg.TRUE;   
    o_amx_file.is_rejected         := com_api_type_pkg.FALSE;       
    o_amx_file.network_id          := i_network_id;
    l_file_date                    := substr(i_header_data, 112, 8) || substr(i_header_data, 120, 6);        
    o_amx_file.transmittal_date    := to_date(l_file_date, amx_api_const_pkg.FORMAT_FILE_DATE);
    o_amx_file.forw_inst_code      := substr(i_header_data, 212, 11);        
    o_amx_file.action_code         := substr(i_header_data, 252, 3);        
    o_amx_file.receipt_file_id     := null;

    if i_mtid = amx_api_const_pkg.MTID_HEADER then
        o_amx_file.file_number         := substr(i_header_data, 1000, 6);
        l_msg_number                   := to_number(substr(i_header_data, 1032, 8));
        o_amx_file.receiv_inst_code    := substr(i_header_data, 1040, 11);
        o_amx_file.reject_code         := substr(i_header_data, 1279, 40);
        if trim(o_amx_file.reject_code) is null then
            o_amx_file.reject_code := null;
        end if;
        o_amx_file.org_identifier      := o_amx_file.receiv_inst_code;
        o_amx_file.func_code           := amx_api_const_pkg.FUNC_CODE_ACKNOWLEDGMENT;

    elsif i_mtid = amx_api_const_pkg.MTID_DAF_HEADER then
        o_amx_file.file_number         := substr(i_header_data, 13, 6);
        l_msg_number                   := to_number(substr(i_header_data, 5, 8));
        o_amx_file.receiv_inst_code    := substr(i_header_data, 80, 11);
        o_amx_file.reject_code         := null;
        o_amx_file.org_identifier      := substr(i_header_data, 201, 11);
        o_amx_file.func_code           := amx_api_const_pkg.FUNC_CODE_DAF;

    else
        trc_log_pkg.warn(
            i_text => 'Not supported header mtid [' || i_mtid || ']'
        );
    end if;
       
    -- checks
    amx_api_file_pkg.check_file_processed(
        i_amx_file  =>  o_amx_file
        );
     
    if i_standard_id is null then
        com_api_error_pkg.raise_error(
            i_error         => 'UNKNOWN_NETWORK'
            , i_env_param1  => i_network_id
        );
    end if;
       
    -- check msg number
    if l_msg_number != lpad('1', 8, '0') then
        com_api_error_pkg.raise_error (
            i_error         => 'AMX_INVALID_MESSAGE_NUMBER'
            , i_env_param1  => l_msg_number
        );            
    end if;
        
    -- check action code
    if o_amx_file.action_code not in (amx_api_const_pkg.ACTION_CODE_PRODUCTION
                                     , amx_api_const_pkg.ACTION_CODE_TEST
                                     , amx_api_const_pkg.ACTION_CODE_PROD_RETRANS
                                     , amx_api_const_pkg.ACTION_CODE_TEST_RETRANS)
    then
        com_api_error_pkg.raise_error (
            i_error         => 'AMX_INVALID_ACTION_CODE'
            , i_env_param1  => o_amx_file.action_code
        );            
    end if;    
    
    if nvl(i_action_code, ' ') != nvl(o_amx_file.action_code, ' ') then
        com_api_error_pkg.raise_error(
            i_error       => 'AMX_WRONG_TEST_OPTION_PARAMETER'
          , i_env_param1  => i_action_code
          , i_env_param2  => o_amx_file.action_code
        );
    end if;    

    -- search inst_id use receiv_inst_code 
    begin
        o_amx_file.inst_id  := cmn_api_standard_pkg.find_value_owner (
            i_standard_id         => i_standard_id
            , i_entity_type       => net_api_const_pkg.ENTITY_TYPE_HOST
            , i_object_id         => i_host_id
            , i_param_name        => amx_api_const_pkg.CMID_ACQ_PROCESSOR
            , i_value_char        => o_amx_file.receiv_inst_code
            , i_mask_error        => com_api_type_pkg.TRUE  
        );
        
    exception
        when com_api_error_pkg.e_application_error then
            null;      
    end;
    
    trc_log_pkg.debug (
        i_text          => amx_api_const_pkg.CMID_ACQ_PROCESSOR||'.inst_id = ' || o_amx_file.inst_id
    );
    
    if o_amx_file.inst_id is null then
    
        begin
            o_amx_file.inst_id  := cmn_api_standard_pkg.find_value_owner (
                i_standard_id         => i_standard_id
                , i_entity_type       => net_api_const_pkg.ENTITY_TYPE_HOST
                , i_object_id         => i_host_id
                , i_param_name        => amx_api_const_pkg.CMID_ACQUIRING
                , i_value_char        => o_amx_file.receiv_inst_code
                , i_mask_error        => com_api_type_pkg.TRUE  
            );
            
        exception
            when com_api_error_pkg.e_application_error then
                null;    
        end;
    
        trc_log_pkg.debug (
            i_text          => amx_api_const_pkg.CMID_ACQUIRING||'.inst_id = ' || o_amx_file.inst_id
        );

        if o_amx_file.inst_id is null then

            trc_log_pkg.debug (
                i_text          => amx_api_const_pkg.CMID_ACQUIRING_SINGLE||' last get inst_id'
            );

            o_amx_file.inst_id  := cmn_api_standard_pkg.find_value_owner (
                i_standard_id         => i_standard_id
                , i_entity_type       => net_api_const_pkg.ENTITY_TYPE_HOST
                , i_object_id         => i_host_id
                , i_param_name        => amx_api_const_pkg.CMID_ACQUIRING_SINGLE
                , i_value_char        => o_amx_file.receiv_inst_code
                , i_mask_error        => com_api_type_pkg.FALSE
            );

        end if;
    end if;

    --check forw_inst
    cmn_api_standard_pkg.get_param_value(
        i_inst_id           => o_amx_file.inst_id
      , i_standard_id       => i_standard_id
      , i_entity_type       => net_api_const_pkg.ENTITY_TYPE_HOST
      , i_object_id         => i_host_id
      , i_param_name        => amx_api_const_pkg.CMID_GLOBAL_NETWORK
      , i_param_tab         => l_param_tab
      , o_param_value       => l_global_netw_id
    );
    
    cmn_api_standard_pkg.get_param_value(
        i_inst_id           => o_amx_file.inst_id
      , i_standard_id       => i_standard_id
      , i_entity_type       => net_api_const_pkg.ENTITY_TYPE_HOST
      , i_object_id         => i_host_id
      , i_param_name        => amx_api_const_pkg.CMID_DEMOGRAPHIC
      , i_param_tab         => l_param_tab
      , o_param_value       => l_demogr_buisness_id
    );     
         
    if o_amx_file.forw_inst_code not in (l_global_netw_id
                                        , l_demogr_buisness_id
                                        , amx_api_const_pkg.GLOBAL_INST_ID
                                        , amx_api_const_pkg.GLOBAL_INST_ID_DEMOGRAPHIC )
    then
        com_api_error_pkg.raise_error (
            i_error         => 'AMX_INVALID_FORW_INST'
            , i_env_param1  => o_amx_file.forw_inst_code
        );            
    end if;
       
    o_amx_file.id := amx_file_seq.nextval;
    o_amx_file.session_file_id := i_incom_sess_file_id;

    trc_log_pkg.debug (
        i_text          => 'o_amx_file.id = ' || o_amx_file.id
    );                
    
    trc_log_pkg.debug (
        i_text          => 'amx_prc_incoming_pkg.process_file_header end'
    );    
end;

procedure process_file_trailer (
    i_trailer_data          in     com_api_type_pkg.t_raw_data
  , io_amx_file             in out amx_api_type_pkg.t_amx_file_rec
  , i_mtid                  in     com_api_type_pkg.t_tiny_id
  , i_credit_count          in     com_api_type_pkg.t_long_id
  , i_debit_count           in     com_api_type_pkg.t_long_id
  , i_credit_amount         in     com_api_type_pkg.t_money
  , i_debit_amount          in     com_api_type_pkg.t_money
  , i_total_amount          in     com_api_type_pkg.t_money
  , i_is_acknowledgment     in     com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
  , o_trailer_load             out com_api_type_pkg.t_boolean
) is
    l_file_date                 date;
    l_file_number               com_api_type_pkg.t_auth_code;   
    l_forw_inst                 com_api_type_pkg.t_cmid;
    l_receiv_inst               com_api_type_pkg.t_cmid;
    l_action_code               com_api_type_pkg.t_curr_code;     
    l_msg_number                com_api_type_pkg.t_short_id;
    l_reject_code               com_api_type_pkg.t_original_data;
    
begin
    trc_log_pkg.debug (
        i_text          => 'amx_prc_incoming_pkg.process_file_trailer start'
    );
    o_trailer_load := com_api_type_pkg.FALSE;

    l_file_date   := to_date(substr(i_trailer_data, 112, 8) || substr(i_trailer_data, 120, 6), amx_api_const_pkg.FORMAT_FILE_DATE);
    l_forw_inst   := substr(i_trailer_data, 212, 11);  
    l_action_code := substr(i_trailer_data, 252, 3);        
    l_file_number := substr(i_trailer_data, 1000, 6); 
    l_msg_number  := substr(i_trailer_data, 1032, 8);
    l_receiv_inst := substr(i_trailer_data, 1040, 11);   
    io_amx_file.hash_total_amount := substr(i_trailer_data, 983, 17);
    
    if io_amx_file.transmittal_date != l_file_date then
    
        com_api_error_pkg.raise_error (
            i_error         => 'AMX_FILE_CORRUPTED_INCORRECT_TRAILER_DATE'
            , i_env_param1  => io_amx_file.transmittal_date
            , i_env_param2  => to_date(l_file_date, amx_api_const_pkg.FORMAT_FILE_DATE)
        );
    end if;

    if i_mtid = amx_api_const_pkg.MTID_TRAILER then
        l_file_number                  := substr(i_trailer_data, 1000, 6);
        l_msg_number                   := to_number(substr(i_trailer_data, 1032, 8));
        l_receiv_inst                  := substr(i_trailer_data, 1040, 11);
        io_amx_file.hash_total_amount  := substr(i_trailer_data, 983, 17);
        l_reject_code                  := trim(substr(i_trailer_data, 1279, 40));

    elsif i_mtid = amx_api_const_pkg.MTID_DAF_TRAILER then
        l_file_number                  := substr(i_trailer_data, 13, 6);
        l_msg_number                   := to_number(substr(i_trailer_data, 5, 8));
        l_receiv_inst                  := substr(i_trailer_data, 86, 11);
        io_amx_file.hash_total_amount  := substr(i_trailer_data, 69, 17);

    else
        trc_log_pkg.warn(
            i_text => 'Not supported trailer mtid [' || i_mtid || ']'
        );
        return;

    end if;
    
    if l_reject_code is not null then
    
        trc_log_pkg.warn(
            i_text => 'Rejected trailer skipped, reason code is [' || l_reject_code || ']'
        );
        return;

    end if;

    if io_amx_file.file_number != l_file_number then

        com_api_error_pkg.raise_error (
            i_error         => 'AMX_FILE_CORRUPTED_INCORRECT_TRAILER_FILE_NUMBER'
            , i_env_param1  => io_amx_file.file_number
            , i_env_param2  => l_file_number
        );
    end if;  
          
    if io_amx_file.action_code != l_action_code then
    
        com_api_error_pkg.raise_error (
            i_error         => 'AMX_FILE_CORRUPTED_INCORRECT_TRAILER_ACTION_CODE'
            , i_env_param1  => io_amx_file.action_code
            , i_env_param2  => l_action_code
        );
    end if;
    
    if io_amx_file.forw_inst_code != l_forw_inst then
    
        com_api_error_pkg.raise_error (
            i_error         => 'AMX_FILE_CORRUPTED_INCORRECT_TRAILER_FORW_INST'
            , i_env_param1  => io_amx_file.forw_inst_code
            , i_env_param2  => l_forw_inst
        );
    end if;
    
    if io_amx_file.receiv_inst_code != l_receiv_inst then
    
        com_api_error_pkg.raise_error (
            i_error         => 'AMX_FILE_CORRUPTED_INCORRECT_TRAILER_RECEIV_INST'
            , i_env_param1  => io_amx_file.receiv_inst_code
            , i_env_param2  => l_receiv_inst
        );
    end if;           

    --check debits and credits only for not acknowledgment!
    if i_is_acknowledgment = com_api_type_pkg.FALSE then
    
        if i_mtid = amx_api_const_pkg.MTID_TRAILER then
            io_amx_file.credit_count   := to_number(substr(i_trailer_data, 939, 6));
            io_amx_file.debit_count    := to_number(substr(i_trailer_data, 945, 6));
            io_amx_file.credit_amount  := to_number(substr(i_trailer_data, 951, 16));
            io_amx_file.debit_amount   := to_number(substr(i_trailer_data, 967, 16));
            io_amx_file.total_amount   := to_number(substr(i_trailer_data, 983, 17));

        elsif i_mtid = amx_api_const_pkg.MTID_DAF_TRAILER then
            io_amx_file.credit_count   := to_number(substr(i_trailer_data, 19, 8));
            io_amx_file.debit_count    := to_number(substr(i_trailer_data, 27, 8));
            io_amx_file.credit_amount  := to_number(substr(i_trailer_data, 35, 17));
            io_amx_file.debit_amount   := to_number(substr(i_trailer_data, 52, 17));
            io_amx_file.total_amount   := to_number(substr(i_trailer_data, 69, 17));

        end if;

        if i_mtid != amx_api_const_pkg.MTID_DAF_TRAILER then -- todo: enable DAF validation

            if io_amx_file.credit_count != i_credit_count then

                trc_log_pkg.warn(
                    i_text          => 'AMX_FILE_CORRUPTED_INCORRECT_TRAILER_CR_COUNT'
                    , i_env_param1  => io_amx_file.credit_count
                    , i_env_param2  => i_credit_count
                );
                com_api_error_pkg.raise_error (
                    i_error         => 'AMX_FILE_CORRUPTED_INCORRECT_TRAILER_CR_COUNT'
                    , i_env_param1  => io_amx_file.credit_count
                    , i_env_param2  => i_credit_count
                );
            end if;

            if io_amx_file.debit_count != i_debit_count then
                com_api_error_pkg.raise_error (
                    i_error         => 'AMX_FILE_CORRUPTED_INCORRECT_TRAILER_DT_COUNT'
                    , i_env_param1  => io_amx_file.debit_count
                    , i_env_param2  => i_debit_count
                );
            end if;

            if io_amx_file.credit_amount != i_credit_amount then
                com_api_error_pkg.raise_error (
                    i_error         => 'AMX_FILE_CORRUPTED_INCORRECT_TRAILER_CR_AMOUNT'
                    , i_env_param1  => io_amx_file.credit_amount
                    , i_env_param2  => i_credit_amount
                );
            end if;

            if io_amx_file.debit_amount != i_debit_amount then
                com_api_error_pkg.raise_error (
                    i_error         => 'AMX_FILE_CORRUPTED_INCORRECT_TRAILER_DT_AMOUNT'
                    , i_env_param1  => io_amx_file.debit_amount
                    , i_env_param2  => i_debit_amount
                );
            end if;

            if io_amx_file.total_amount != i_total_amount then
                com_api_error_pkg.raise_error (
                    i_error         => 'AMX_FILE_CORRUPTED_INCORRECT_TRAILER_TOTAL_AMOUNT'
                    , i_env_param1  => io_amx_file.total_amount
                    , i_env_param2  => i_total_amount
                );
            end if;
        end if;
    end if;
        
    insert into amx_file (
        id              
        , is_incoming       
        , is_rejected           
        , network_id             
        , transmittal_date    
        , inst_id                 
        , forw_inst_code          
        , receiv_inst_code        
        , action_code             
        , file_number         
        , reject_code         
        , msg_total           
        , credit_count        
        , debit_count         
        , credit_amount        
        , debit_amount         
        , total_amount             
        , receipt_file_id
        , session_file_id
        , hash_total_amount
        , func_code
        , org_identifier
    )
    values(
        io_amx_file.id
        , io_amx_file.is_incoming   
        , io_amx_file.is_rejected       
        , io_amx_file.network_id
        , io_amx_file.transmittal_date
        , io_amx_file.inst_id
        , io_amx_file.forw_inst_code        
        , io_amx_file.receiv_inst_code        
        , io_amx_file.action_code        
        , io_amx_file.file_number
        , io_amx_file.reject_code
        , l_msg_number
        , io_amx_file.credit_count
        , io_amx_file.debit_count 
        , io_amx_file.credit_amount 
        , io_amx_file.debit_amount 
        , io_amx_file.total_amount  
        , io_amx_file.receipt_file_id
        , io_amx_file.session_file_id
        , io_amx_file.hash_total_amount
        , io_amx_file.func_code
        , io_amx_file.org_identifier
    );
    
    o_trailer_load := com_api_type_pkg.TRUE;

    trc_log_pkg.debug (
        i_text          => 'amx_prc_incoming_pkg.process_file_trailer end'
    );
end;

procedure calc_debit_credit(
    io_amx_fin_rec          in out nocopy  amx_api_type_pkg.t_amx_fin_mes_rec    
  , i_impact                in     com_api_type_pkg.t_sign 
  , i_trans_amount          in     com_api_type_pkg.t_money
  , io_credit_count         in out com_api_type_pkg.t_long_id
  , io_debit_count          in out com_api_type_pkg.t_long_id
  , io_credit_amount        in out com_api_type_pkg.t_money
  , io_debit_amount         in out com_api_type_pkg.t_money
  , io_total_amount         in out com_api_type_pkg.t_money
) is
begin
    if i_impact = amx_api_const_pkg.MESSAGE_IMPACT_CREDIT then
        io_credit_count := io_credit_count + 1;
        io_credit_amount := io_credit_amount + i_trans_amount;
    elsif i_impact = amx_api_const_pkg.MESSAGE_IMPACT_DEBIT then
        io_debit_count := io_debit_count + 1;
        io_debit_amount := io_debit_amount + i_trans_amount;
    end if;
    io_total_amount := io_total_amount + i_trans_amount;
end;

procedure process_presentment(
    i_tc_buffer             in     com_api_type_pkg.t_raw_data
  , i_amx_file              in     amx_api_type_pkg.t_amx_file_rec
  , i_mtid                  in     com_api_type_pkg.t_tiny_id
  , i_standard_id           in     com_api_type_pkg.t_tiny_id
  , io_credit_count         in out com_api_type_pkg.t_long_id
  , io_debit_count          in out com_api_type_pkg.t_long_id
  , io_credit_amount        in out com_api_type_pkg.t_money
  , io_debit_amount         in out com_api_type_pkg.t_money
  , io_total_amount         in out com_api_type_pkg.t_money
  , i_incom_sess_file_id    in     com_api_type_pkg.t_long_id
  , i_create_operation      in     com_api_type_pkg.t_boolean    
  , o_amx_fin_rec              out amx_api_type_pkg.t_amx_fin_mes_rec
)is
    l_amx_fin_rec           amx_api_type_pkg.t_amx_fin_mes_rec;  
    l_date                  com_api_type_pkg.t_name;  
    l_auth                  aut_api_type_pkg.t_auth_rec;
    l_pos_data_code         com_api_type_pkg.t_cmid;
        
    function get_field (
        i_start       in pls_integer
        , i_length    in pls_integer
    ) return varchar2 is
    begin
        return trim(substr(i_tc_buffer, i_start, i_length));
    end;

begin
    trc_log_pkg.debug (
        i_text          => 'amx_prc_incoming_pkg.process_presentment start'
    );
    -- init_record
    l_amx_fin_rec.status                      := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    l_amx_fin_rec.inst_id                     := i_amx_file.inst_id;
    l_amx_fin_rec.network_id                  := i_amx_file.network_id;
    l_amx_fin_rec.file_id                     := i_amx_file.id;
    l_amx_fin_rec.is_invalid                  := com_api_type_pkg.FALSE;  
    l_amx_fin_rec.is_incoming                 := com_api_type_pkg.TRUE;
    l_amx_fin_rec.is_reversal                 := com_api_type_pkg.FALSE;
    l_amx_fin_rec.is_rejected                 := com_api_type_pkg.FALSE;
    l_amx_fin_rec.dispute_id                  := null;
    
    l_amx_fin_rec.id                          := opr_api_create_pkg.get_id;    
    l_amx_fin_rec.mtid                        := i_mtid;       
    
    l_amx_fin_rec.func_code                   := get_field(167, 3);
    l_amx_fin_rec.proc_code                   := get_field(26, 6);
    l_amx_fin_rec.impact                      := get_message_impact(   
                                                     i_mtid          => i_mtid
                                                     , i_func_code   => l_amx_fin_rec.func_code
                                                     , i_proc_code   => l_amx_fin_rec.proc_code
                                                     , i_incoming    => com_api_type_pkg.TRUE
                                                     , i_raise_error => com_api_type_pkg.FALSE
                                                 );
    l_amx_fin_rec.pan_length                  := get_field(5, 2);
    l_amx_fin_rec.card_number                 := get_field(7, 19);
    l_amx_fin_rec.card_mask                   := iss_api_card_pkg.get_card_mask(l_amx_fin_rec.card_number);
    l_amx_fin_rec.card_hash                   := com_api_hash_pkg.get_card_hash(l_amx_fin_rec.card_number);
    l_amx_fin_rec.split_hash                   := com_api_hash_pkg.get_split_hash(l_amx_fin_rec.card_number);
    l_amx_fin_rec.trans_amount                := to_number(get_field(32, 15));
    l_date                                    := get_field(112, 8) || get_field(120, 6);        
    l_amx_fin_rec.trans_date                  := to_date(l_date, amx_api_const_pkg.FORMAT_FILE_DATE);
    l_amx_fin_rec.card_expir_date             := get_field(126, 4);
    l_date                                    := get_field(134, 8) || get_field(897, 6);
    l_amx_fin_rec.capture_date                := to_date(l_date, amx_api_const_pkg.FORMAT_FILE_DATE);
    l_amx_fin_rec.mcc                         := get_field(142, 4);
    l_pos_data_code                           := get_field(155, 12);
    l_amx_fin_rec.pdc_1                       := substr(l_pos_data_code, 1, 1); 
    l_amx_fin_rec.pdc_2                       := substr(l_pos_data_code, 2, 1); 
    l_amx_fin_rec.pdc_3                       := substr(l_pos_data_code, 3, 1); 
    l_amx_fin_rec.pdc_4                       := substr(l_pos_data_code, 4, 1); 
    l_amx_fin_rec.pdc_5                       := substr(l_pos_data_code, 5, 1); 
    l_amx_fin_rec.pdc_6                       := substr(l_pos_data_code, 6, 1); 
    l_amx_fin_rec.pdc_7                       := substr(l_pos_data_code, 7, 1); 
    l_amx_fin_rec.pdc_8                       := substr(l_pos_data_code, 8, 1); 
    l_amx_fin_rec.pdc_9                       := substr(l_pos_data_code, 9, 1); 
    l_amx_fin_rec.pdc_10                      := substr(l_pos_data_code, 10, 1); 
    l_amx_fin_rec.pdc_11                      := substr(l_pos_data_code, 11, 1); 
    l_amx_fin_rec.pdc_12                      := substr(l_pos_data_code, 12, 1);     
    l_amx_fin_rec.approval_code_length        := get_field(174, 1); 
    l_date                                    := get_field(175, 8) || get_field(903, 6);
    l_amx_fin_rec.iss_sttl_date               := to_date(l_date, amx_api_const_pkg.FORMAT_FILE_DATE);
    l_amx_fin_rec.eci                         := get_field(182, 2); -- for POS only
    l_amx_fin_rec.fp_trans_amount             := to_number(get_field(186, 15));
    l_amx_fin_rec.ain                         := get_field(201, 11);
    l_amx_fin_rec.apn                         := get_field(212, 11);
    l_amx_fin_rec.arn                         := get_field(223, 23);
    l_amx_fin_rec.approval_code               := get_field(246, 6);    
    l_amx_fin_rec.terminal_number             := get_field(255, 8);
    l_amx_fin_rec.merchant_number             := get_field(263, 15);
    l_amx_fin_rec.merchant_name               := get_field(278, 38);
    l_amx_fin_rec.merchant_addr1              := get_field(316, 38);
    l_amx_fin_rec.merchant_addr2              := get_field(354, 38);
    l_amx_fin_rec.merchant_city               := get_field(392, 21);
    l_amx_fin_rec.merchant_postal_code        := get_field(413, 15);    
    l_amx_fin_rec.merchant_country            := get_field(428, 3);
    l_amx_fin_rec.merchant_region             := get_field(431, 3);
    
    l_amx_fin_rec.iss_rate_amount             := to_number(get_field(449, 15));
    l_amx_fin_rec.matching_key_type           := get_field(510, 2);
    l_amx_fin_rec.matching_key                := get_field(512, 21);
    l_amx_fin_rec.iss_sttl_currency           := get_field(599, 3);
    l_amx_fin_rec.iss_sttl_decimalization     := to_number(get_field(602, 1));
    
    l_amx_fin_rec.fp_pres_amount              := get_field(607, 15);
    l_amx_fin_rec.fp_pres_conversion_rate     := to_number(get_field(622, 8)) / 100000000;
    l_amx_fin_rec.fp_pres_currency            := get_field(637, 3);
    l_amx_fin_rec.fp_pres_decimalization      := to_number(get_field(640, 1));
    l_amx_fin_rec.merchant_multinational      := get_field(641, 1);
    l_amx_fin_rec.trans_currency              := get_field(642, 3);
    l_amx_fin_rec.add_acc_eff_type1           := get_field(652, 1);
    l_amx_fin_rec.add_amount1                 := to_number(get_field(653, 15));
    l_amx_fin_rec.add_amount_type1            := get_field(668, 3);
    l_amx_fin_rec.add_acc_eff_type2           := get_field(671, 1);
    l_amx_fin_rec.add_amount2                 := to_number(get_field(672, 15));
    l_amx_fin_rec.add_amount_type2            := get_field(687, 3);
    l_amx_fin_rec.add_acc_eff_type3           := get_field(690, 1);
    l_amx_fin_rec.add_amount3                 := to_number(get_field(691, 15));
    l_amx_fin_rec.add_amount_type3            := get_field(706, 3);
    l_amx_fin_rec.add_acc_eff_type4           := get_field(709, 1);
    l_amx_fin_rec.add_amount4                 := to_number(get_field(710, 15));
    l_amx_fin_rec.add_amount_type4            := get_field(725, 3);
    l_amx_fin_rec.add_acc_eff_type5           := get_field(728, 1);
    l_amx_fin_rec.add_amount5                 := to_number(get_field(729, 15));
    l_amx_fin_rec.add_amount_type5            := get_field(744, 3);
    l_amx_fin_rec.alt_merchant_number_length  := to_number(get_field(747, 2));
    l_amx_fin_rec.alt_merchant_number         := get_field(749, 15);
    l_amx_fin_rec.card_capability             := get_field(786, 1);
    l_date                                    := get_field(787, 8) || get_field(795, 6);
    l_amx_fin_rec.network_proc_date           := to_date(l_date, amx_api_const_pkg.FORMAT_FILE_DATE);
    l_amx_fin_rec.tax_reason_code             := get_field(894, 2);
    l_amx_fin_rec.format_code                 := get_field(923, 2);
    l_amx_fin_rec.iin                         := get_field(925, 11);
    l_amx_fin_rec.media_code                  := get_field(936, 2);
    l_amx_fin_rec.message_seq_number          := to_number(get_field(938, 3));
    l_amx_fin_rec.merchant_location_text      := get_field(941, 40);
    l_amx_fin_rec.transaction_id              := to_number(get_field(1006, 15));
    l_amx_fin_rec.ext_payment_data            := to_number(get_field(1021, 2));
    l_amx_fin_rec.message_number              := to_number(get_field(1032, 8));
    l_amx_fin_rec.ipn                         := get_field(1040, 11);
    l_amx_fin_rec.invoice_number              := get_field(1231, 30);
    l_amx_fin_rec.reject_reason_code          := get_field(1279, 40);
    
    if l_amx_fin_rec.func_code = amx_api_const_pkg.FUNC_CODE_FIRST_PRES then

        l_amx_fin_rec.trans_decimalization    := to_number(get_field(606, 1)); 
        l_amx_fin_rec.icc_pin_indicator       := get_field(784, 2);
        l_amx_fin_rec.program_indicator       := get_field(892, 2);
     
        if l_amx_fin_rec.proc_code = amx_api_const_pkg.PROC_CODE_ATM_CASH then
        
            l_amx_fin_rec.iss_net_sttl_amount   := to_number(get_field(434, 15));  --Issuer Authorized Amount for ATM
            l_amx_fin_rec.iss_gross_sttl_amount := to_number(get_field(569, 15));  
        else --pos
            l_amx_fin_rec.iss_gross_sttl_amount := to_number(get_field(434, 15)); 
            l_amx_fin_rec.iss_net_sttl_amount   := to_number(get_field(569, 15));
        end if;  
    
    elsif l_amx_fin_rec.func_code = amx_api_const_pkg.FUNC_CODE_SECOND_PRES then
    
        l_amx_fin_rec.reason_code             := get_field(170, 4);
        l_amx_fin_rec.fp_trans_currency       := get_field(603, 3);
        l_amx_fin_rec.fp_trans_decimalization := to_number(get_field(606, 1)); 
        l_date                                := get_field(766, 8) || get_field(774, 6);
        l_amx_fin_rec.fp_trans_date           := to_date(l_date, amx_api_const_pkg.FORMAT_FILE_DATE);
        l_amx_fin_rec.trans_decimalization    := to_number(get_field(801, 1)); 
        l_date                                := get_field(909, 8) || get_field(917, 6);
        l_amx_fin_rec.fp_network_proc_date    := to_date(l_date, amx_api_const_pkg.FORMAT_FILE_DATE);
        l_amx_fin_rec.itemized_doc_code       := get_field(981, 2);
        l_amx_fin_rec.itemized_doc_ref_number := get_field(983, 23);
        
        -- for ATM & POS SP        
        l_amx_fin_rec.iss_gross_sttl_amount := to_number(get_field(434, 15));                    
        l_amx_fin_rec.iss_net_sttl_amount   := to_number(get_field(569, 15));
        
    end if;
       
    -- calculate debit and credit                        
    calc_debit_credit(
        io_amx_fin_rec      => l_amx_fin_rec    
        , i_impact          => l_amx_fin_rec.impact
        , i_trans_amount    => l_amx_fin_rec.trans_amount
        , io_credit_count   => io_credit_count
        , io_debit_count    => io_debit_count
        , io_credit_amount  => io_credit_amount
        , io_debit_amount   => io_debit_amount
        , io_total_amount   => io_total_amount
    );

    amx_api_dispute_pkg.assign_dispute(
        io_amx_fin_rec  => l_amx_fin_rec  
        , o_auth        => l_auth 
    );        
       
    if nvl(i_create_operation, com_api_type_pkg.TRUE) = com_api_type_pkg.TRUE then    

        amx_api_fin_message_pkg.create_operation(
            i_fin_rec            => l_amx_fin_rec
          , i_standard_id        => i_standard_id 
          , i_auth               => l_auth
          , i_incom_sess_file_id => i_incom_sess_file_id
        );
    end if;
    
    if l_amx_fin_rec.is_invalid = com_api_type_pkg.TRUE then
        g_error_flag := com_api_type_pkg.TRUE;
        l_amx_fin_rec.status := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
    end if;

    l_amx_fin_rec.id := amx_api_fin_message_pkg.put_message (
        i_fin_rec => l_amx_fin_rec
    );      
    
    o_amx_fin_rec := l_amx_fin_rec;
    
    trc_log_pkg.debug (
        i_text          => 'amx_prc_incoming_pkg.process_presentment end'
    );    
end;

procedure process_chargeback(
    i_tc_buffer             in     com_api_type_pkg.t_raw_data
  , i_amx_file              in     amx_api_type_pkg.t_amx_file_rec
  , i_mtid                  in     com_api_type_pkg.t_tiny_id 
  , i_standard_id           in     com_api_type_pkg.t_tiny_id
  , io_credit_count         in out com_api_type_pkg.t_long_id
  , io_debit_count          in out com_api_type_pkg.t_long_id
  , io_credit_amount        in out com_api_type_pkg.t_money
  , io_debit_amount         in out com_api_type_pkg.t_money
  , io_total_amount         in out com_api_type_pkg.t_money
  , i_incom_sess_file_id    in     com_api_type_pkg.t_long_id
  , i_create_operation      in     com_api_type_pkg.t_boolean    
) is
    l_amx_fin_rec           amx_api_type_pkg.t_amx_fin_mes_rec;    
    l_date                  com_api_type_pkg.t_name;
    l_auth                  aut_api_type_pkg.t_auth_rec;

    function get_field (
        i_start       in pls_integer
        , i_length    in pls_integer
    ) return varchar2 is
    begin
        return trim(substr(i_tc_buffer, i_start, i_length));
    end;
    
begin
    trc_log_pkg.debug (
        i_text          => 'amx_prc_incoming_pkg.process_chargeback start'
    );
                     
    -- init_record
    l_amx_fin_rec.status                      := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    l_amx_fin_rec.inst_id                     := i_amx_file.inst_id;
    l_amx_fin_rec.network_id                  := i_amx_file.network_id;
    l_amx_fin_rec.file_id                     := i_amx_file.id;
    l_amx_fin_rec.is_invalid                  := com_api_type_pkg.FALSE;  
    l_amx_fin_rec.is_incoming                 := com_api_type_pkg.TRUE;
    l_amx_fin_rec.is_reversal                 := com_api_type_pkg.FALSE;
    l_amx_fin_rec.is_rejected                 := com_api_type_pkg.FALSE;
    l_amx_fin_rec.dispute_id                  := null;
    
    l_amx_fin_rec.id                          := opr_api_create_pkg.get_id;    
    l_amx_fin_rec.mtid                        := i_mtid;       
    
    l_amx_fin_rec.func_code                   := get_field(167, 3);
    l_amx_fin_rec.proc_code                   := get_field(26, 6);
    l_amx_fin_rec.impact                      := get_message_impact(   
                                                     i_mtid          => i_mtid
                                                     , i_func_code   => l_amx_fin_rec.func_code
                                                     , i_proc_code   => l_amx_fin_rec.proc_code
                                                     , i_incoming    => com_api_type_pkg.TRUE
                                                     , i_raise_error => com_api_type_pkg.FALSE
                                                 );
    l_amx_fin_rec.pan_length                  := get_field(5, 2);
    l_amx_fin_rec.card_number                 := get_field(7, 19);
    l_amx_fin_rec.card_mask                   := iss_api_card_pkg.get_card_mask(l_amx_fin_rec.card_number);
    l_amx_fin_rec.card_hash                   := com_api_hash_pkg.get_card_hash(l_amx_fin_rec.card_number);
    l_amx_fin_rec.split_hash                  := com_api_hash_pkg.get_split_hash(l_amx_fin_rec.card_number);
    l_amx_fin_rec.trans_amount                := to_number(get_field(32, 15));
    l_date                                    := get_field(112, 8) || get_field(120, 6);        
    l_amx_fin_rec.trans_date                  := to_date(l_date, amx_api_const_pkg.FORMAT_FILE_DATE);
    l_amx_fin_rec.card_expir_date             := get_field(126, 4);
    l_date                                    := get_field(134, 8) || get_field(897, 6);
    l_amx_fin_rec.capture_date                := to_date(l_date, amx_api_const_pkg.FORMAT_FILE_DATE);
    l_amx_fin_rec.mcc                         := get_field(142, 4);
    l_amx_fin_rec.reason_code                 := get_field(170, 4);
    l_amx_fin_rec.fp_trans_amount             := to_number(get_field(186, 15));
    l_amx_fin_rec.ain                         := get_field(201, 11);
    l_amx_fin_rec.ipn                         := get_field(212, 11);
    l_amx_fin_rec.arn                         := get_field(223, 23);
    l_amx_fin_rec.merchant_number             := get_field(263, 15);
    
    if l_amx_fin_rec.proc_code = amx_api_const_pkg.PROC_CODE_ATM_CASH then
    
        l_amx_fin_rec.terminal_number         := get_field(255, 8);
    else
        l_amx_fin_rec.alt_merchant_number_length  := to_number(get_field(278, 2));
        l_amx_fin_rec.alt_merchant_number     := get_field(280, 15);
    end if;
    
    l_amx_fin_rec.iss_net_sttl_amount         := to_number(get_field(569, 15));  --Acquirer Settlement Amount
    l_amx_fin_rec.iss_sttl_currency           := get_field(599, 3);              --Acquirer Settlement Currency Code
    l_amx_fin_rec.iss_sttl_decimalization     := to_number(get_field(602, 1));   --Acquirer Settlement Decimalization
    l_amx_fin_rec.fp_trans_currency           := get_field(603, 3);
    l_amx_fin_rec.trans_decimalization        := to_number(get_field(606, 1));   --two fields? In position 801 - the same.
    l_amx_fin_rec.fp_pres_amount              := get_field(607, 15);
    l_amx_fin_rec.fp_pres_conversion_rate     := to_number(get_field(622, 8)) / 100000000;
    l_amx_fin_rec.fp_pres_currency            := get_field(637, 3);
    l_amx_fin_rec.fp_pres_decimalization      := to_number(get_field(640, 1));
    l_amx_fin_rec.trans_currency              := get_field(642, 3);
    l_date                                    := get_field(766, 8) || get_field(774, 6);
    l_amx_fin_rec.fp_trans_date               := to_date(l_date, amx_api_const_pkg.FORMAT_FILE_DATE);
    l_date                                    := get_field(787, 8) || get_field(795, 6);
    l_amx_fin_rec.network_proc_date           := to_date(l_date, amx_api_const_pkg.FORMAT_FILE_DATE);
    l_amx_fin_rec.trans_decimalization        := to_number(get_field(801, 1)); --two fields? In position 606 - the same.
    l_amx_fin_rec.chbck_reason_text           := get_field(802, 95);
    l_date                                    := get_field(909, 8) || get_field(917, 6);
    l_amx_fin_rec.fp_network_proc_date        := to_date(l_date, amx_api_const_pkg.FORMAT_FILE_DATE);
    l_amx_fin_rec.iin                         := get_field(925, 11);
    l_amx_fin_rec.message_seq_number          := to_number(get_field(938, 3));
    l_amx_fin_rec.transaction_id              := to_number(get_field(1006, 15));
    l_amx_fin_rec.message_number              := to_number(get_field(1032, 8));
    l_amx_fin_rec.apn                         := get_field(1040, 11);
    l_amx_fin_rec.reject_reason_code          := get_field(1279, 40);

    calc_debit_credit(
        io_amx_fin_rec      => l_amx_fin_rec    
        , i_impact          => l_amx_fin_rec.impact
        , i_trans_amount    => l_amx_fin_rec.trans_amount
        , io_credit_count   => io_credit_count
        , io_debit_count    => io_debit_count
        , io_credit_amount  => io_credit_amount
        , io_debit_amount   => io_debit_amount
        , io_total_amount   => io_total_amount
    );
                                 
    amx_api_dispute_pkg.assign_dispute(
        io_amx_fin_rec  => l_amx_fin_rec  
        , o_auth        => l_auth 
    );        
       
    if nvl(i_create_operation, com_api_type_pkg.TRUE) = com_api_type_pkg.TRUE then    

        amx_api_fin_message_pkg.create_operation(
            i_fin_rec            => l_amx_fin_rec
          , i_standard_id        => i_standard_id 
          , i_auth               => l_auth
          , i_incom_sess_file_id => i_incom_sess_file_id
        );
    end if;

    if l_amx_fin_rec.is_invalid = com_api_type_pkg.TRUE then
        g_error_flag := com_api_type_pkg.TRUE;
        l_amx_fin_rec.status := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
    end if;


    l_amx_fin_rec.id := amx_api_fin_message_pkg.put_message (
        i_fin_rec => l_amx_fin_rec
    );        

    trc_log_pkg.debug (
        i_text          => 'amx_prc_incoming_pkg.process_chargeback end'
    );    
end;

procedure process_retrieval_request(
    i_tc_buffer             in     com_api_type_pkg.t_raw_data
  , i_amx_file              in     amx_api_type_pkg.t_amx_file_rec
  , i_mtid                  in     com_api_type_pkg.t_tiny_id
  , i_standard_id           in     com_api_type_pkg.t_tiny_id
  , i_incom_sess_file_id    in     com_api_type_pkg.t_long_id
  , i_create_operation      in     com_api_type_pkg.t_boolean    
)
is
    l_amx_fin_rec           amx_api_type_pkg.t_amx_fin_mes_rec;    
    l_date                  com_api_type_pkg.t_name;
    l_auth                  aut_api_type_pkg.t_auth_rec;

    function get_field (
        i_start       in pls_integer
        , i_length    in pls_integer
    ) return varchar2 is
    begin
        return trim(substr(i_tc_buffer, i_start, i_length));
    end;
    
begin
    trc_log_pkg.debug (
        i_text          => 'amx_prc_incoming_pkg.process_retrival_request start'
    );

    -- init_record
    l_amx_fin_rec.status                      := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    l_amx_fin_rec.inst_id                     := i_amx_file.inst_id;
    l_amx_fin_rec.network_id                  := i_amx_file.network_id;
    l_amx_fin_rec.file_id                     := i_amx_file.id;
    l_amx_fin_rec.is_invalid                  := com_api_type_pkg.FALSE;  
    l_amx_fin_rec.is_incoming                 := com_api_type_pkg.TRUE;
    l_amx_fin_rec.is_reversal                 := com_api_type_pkg.FALSE;
    l_amx_fin_rec.is_rejected                 := com_api_type_pkg.FALSE;
    l_amx_fin_rec.dispute_id                  := null;
    
    l_amx_fin_rec.id                          := opr_api_create_pkg.get_id;    
    l_amx_fin_rec.mtid                        := i_mtid;       
    
    l_amx_fin_rec.func_code                   := get_field(167, 3);
    l_amx_fin_rec.proc_code                   := get_field(26, 6);
    l_amx_fin_rec.impact                      := get_message_impact(   
                                                     i_mtid          => i_mtid
                                                     , i_func_code   => l_amx_fin_rec.func_code
                                                     , i_proc_code   => l_amx_fin_rec.proc_code
                                                     , i_incoming    => com_api_type_pkg.TRUE
                                                     , i_raise_error => com_api_type_pkg.FALSE
                                                 );
    l_amx_fin_rec.pan_length                  := get_field(5, 2);
    l_amx_fin_rec.card_number                 := get_field(7, 19);
    l_amx_fin_rec.card_mask                   := iss_api_card_pkg.get_card_mask(l_amx_fin_rec.card_number);
    l_amx_fin_rec.card_hash                   := com_api_hash_pkg.get_card_hash(l_amx_fin_rec.card_number);
    l_amx_fin_rec.split_hash                  := com_api_hash_pkg.get_split_hash(l_amx_fin_rec.card_number);
    l_date                                    := get_field(112, 8) || get_field(120, 6);        
    l_amx_fin_rec.trans_date                  := to_date(l_date, amx_api_const_pkg.FORMAT_FILE_DATE);
    l_amx_fin_rec.card_expir_date             := get_field(126, 4);
    l_date                                    := get_field(134, 8) || get_field(897, 6);
    l_amx_fin_rec.capture_date                := to_date(l_date, amx_api_const_pkg.FORMAT_FILE_DATE);
    l_amx_fin_rec.mcc                         := get_field(142, 4);
    l_amx_fin_rec.reason_code                 := get_field(170, 4);
    l_amx_fin_rec.fp_trans_amount             := to_number(get_field(186, 15));
    
    if l_amx_fin_rec.mtid = amx_api_const_pkg.MTID_RETRIEVAL_REQUEST then 
    
        l_amx_fin_rec.ain                     := get_field(201, 11);
        l_amx_fin_rec.ipn                     := get_field(212, 11);
        l_amx_fin_rec.arn                     := get_field(223, 23);
    else --fulfillment
        l_amx_fin_rec.ain                     := get_field(201, 11);
        l_amx_fin_rec.apn                     := get_field(212, 11);
        l_amx_fin_rec.arn                     := get_field(223, 23);
    end if;
    
    l_amx_fin_rec.merchant_number             := get_field(263, 15);
    
    if l_amx_fin_rec.proc_code = amx_api_const_pkg.PROC_CODE_ATM_CASH then
    
        l_amx_fin_rec.terminal_number         := get_field(255, 8);
    else
        l_amx_fin_rec.alt_merchant_number_length  := to_number(get_field(278, 2));
        l_amx_fin_rec.alt_merchant_number     := get_field(280, 15);
    end if;
    
    l_amx_fin_rec.fp_trans_currency           := get_field(603, 3);
    l_amx_fin_rec.fp_trans_decimalization     := to_number(get_field(606, 1)); --two fields? In position 606 - the same.
    l_amx_fin_rec.fp_pres_amount              := get_field(607, 15);
    l_amx_fin_rec.fp_pres_currency            := get_field(637, 3);
    l_amx_fin_rec.fp_pres_decimalization      := to_number(get_field(640, 1));
    l_date                                    := get_field(766, 8) || get_field(774, 6);
    l_amx_fin_rec.fp_trans_date               := to_date(l_date, amx_api_const_pkg.FORMAT_FILE_DATE);
    l_amx_fin_rec.chbck_reason_code           := get_field(783, 4);
    l_date                                    := get_field(787, 8) || get_field(795, 6);
    l_amx_fin_rec.network_proc_date           := to_date(l_date, amx_api_const_pkg.FORMAT_FILE_DATE);
    l_date                                    := get_field(909, 8) || get_field(917, 6);
    l_amx_fin_rec.fp_network_proc_date        := to_date(l_date, amx_api_const_pkg.FORMAT_FILE_DATE);
    l_amx_fin_rec.iin                         := get_field(925, 11);
    l_amx_fin_rec.message_seq_number          := to_number(get_field(938, 3));
    l_amx_fin_rec.itemized_doc_code           := get_field(981, 2);
    l_amx_fin_rec.transaction_id              := to_number(get_field(1006, 15));
    l_amx_fin_rec.message_number              := to_number(get_field(1032, 8));
    
    if l_amx_fin_rec.mtid = amx_api_const_pkg.MTID_RETRIEVAL_REQUEST then 
    
        l_amx_fin_rec.apn                     := get_field(1040, 11);
    else --fulfillment
        l_amx_fin_rec.itemized_doc_ref_number := get_field(983, 23);
        l_amx_fin_rec.ipn                     := get_field(1040, 11);
    end if;
        
    l_amx_fin_rec.reject_reason_code          := get_field(1279, 40);
       
    amx_api_dispute_pkg.assign_dispute(
        io_amx_fin_rec  => l_amx_fin_rec  
        , o_auth        => l_auth 
    );        
       
    if nvl(i_create_operation, com_api_type_pkg.TRUE) = com_api_type_pkg.TRUE then    

        amx_api_fin_message_pkg.create_operation(
            i_fin_rec            => l_amx_fin_rec
          , i_standard_id        => i_standard_id 
          , i_auth               => l_auth
          , i_incom_sess_file_id => i_incom_sess_file_id
        );
    end if;

    if l_amx_fin_rec.is_invalid = com_api_type_pkg.TRUE then
        g_error_flag := com_api_type_pkg.TRUE;
        l_amx_fin_rec.status := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
    end if;


    l_amx_fin_rec.id := amx_api_fin_message_pkg.put_message (
        i_fin_rec => l_amx_fin_rec
    );        

    trc_log_pkg.debug (
        i_text          => 'amx_prc_incoming_pkg.process_retrival_request end'
    );    
end;

procedure process_fee(
    i_tc_buffer             in     com_api_type_pkg.t_raw_data
  , i_amx_file              in     amx_api_type_pkg.t_amx_file_rec
  , i_mtid                  in     com_api_type_pkg.t_tiny_id
  , i_standard_id           in     com_api_type_pkg.t_tiny_id
  , io_credit_count         in out com_api_type_pkg.t_long_id
  , io_debit_count          in out com_api_type_pkg.t_long_id
  , io_credit_amount        in out com_api_type_pkg.t_money
  , io_debit_amount         in out com_api_type_pkg.t_money
  , io_total_amount         in out com_api_type_pkg.t_money
  , i_incom_sess_file_id    in     com_api_type_pkg.t_long_id
  , i_create_operation      in     com_api_type_pkg.t_boolean    
)
is
    l_amx_fin_rec           amx_api_type_pkg.t_amx_fin_mes_rec;    
    l_date                  com_api_type_pkg.t_name;
    l_auth                  aut_api_type_pkg.t_auth_rec;

    function get_field (
        i_start       in pls_integer
        , i_length    in pls_integer
    ) return varchar2 is
    begin
        return trim(substr(i_tc_buffer, i_start, i_length));
    end;
    
begin
    trc_log_pkg.debug (
        i_text          => 'amx_prc_incoming_pkg.process_fee start'
    );
    
    -- init_record
    l_amx_fin_rec.status                      := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
    l_amx_fin_rec.inst_id                     := i_amx_file.inst_id;
    l_amx_fin_rec.network_id                  := i_amx_file.network_id;
    l_amx_fin_rec.file_id                     := i_amx_file.id;
    l_amx_fin_rec.is_invalid                  := com_api_type_pkg.FALSE;  
    l_amx_fin_rec.is_incoming                 := com_api_type_pkg.TRUE;
    l_amx_fin_rec.is_reversal                 := com_api_type_pkg.FALSE;
    l_amx_fin_rec.is_rejected                 := com_api_type_pkg.FALSE;
    l_amx_fin_rec.dispute_id                  := null;
    
    l_amx_fin_rec.id                          := opr_api_create_pkg.get_id;    
    l_amx_fin_rec.mtid                        := i_mtid;       
    
    l_amx_fin_rec.func_code                   := get_field(167, 3);
    l_amx_fin_rec.proc_code                   := get_field(26, 6);
    l_amx_fin_rec.impact                      := get_message_impact(   
                                                     i_mtid          => i_mtid
                                                     , i_func_code   => l_amx_fin_rec.func_code
                                                     , i_proc_code   => l_amx_fin_rec.proc_code
                                                     , i_incoming    => com_api_type_pkg.TRUE
                                                     , i_raise_error => com_api_type_pkg.FALSE
                                                 );    
                                                 
    if l_amx_fin_rec.mtid in (amx_api_const_pkg.MTID_ISS_ATM_FEE, amx_api_const_pkg.MTID_ACQ_ATM_FEE) then
    
        l_amx_fin_rec.pan_length                  := get_field(5, 2);
        l_amx_fin_rec.card_number                 := get_field(7, 19);
        l_amx_fin_rec.card_mask                   := iss_api_card_pkg.get_card_mask(l_amx_fin_rec.card_number);
        l_amx_fin_rec.card_hash                   := com_api_hash_pkg.get_card_hash(l_amx_fin_rec.card_number);
    end if;
                                                                                                  
    l_amx_fin_rec.split_hash                  := com_api_hash_pkg.get_split_hash(l_amx_fin_rec.card_number);
    l_amx_fin_rec.trans_amount                := to_number(get_field(32, 15));    
    l_date                                    := get_field(112, 8) || get_field(120, 6);        
    l_amx_fin_rec.trans_date                  := to_date(l_date, amx_api_const_pkg.FORMAT_FILE_DATE);
    l_amx_fin_rec.valid_bill_unit_code        := get_field(172, 3);
    l_date                                    := get_field(175, 8) || get_field(903, 6);
    l_amx_fin_rec.sttl_date                   := to_date(l_date, amx_api_const_pkg.FORMAT_FILE_DATE);
    
    if l_amx_fin_rec.mtid in (amx_api_const_pkg.MTID_ISS_ATM_FEE, amx_api_const_pkg.MTID_ACQ_ATM_FEE) then
    
        l_amx_fin_rec.send_inst_code              := get_field(201, 11);
        l_amx_fin_rec.send_proc_code              := get_field(212, 11);                      
        l_amx_fin_rec.trans_currency              := get_field(642, 3);
        l_amx_fin_rec.receiving_inst_code         := get_field(925, 11);
        l_amx_fin_rec.receiving_proc_code         := get_field(1040, 11);
    else
        l_amx_fin_rec.ain                         := get_field(201, 11);
        l_amx_fin_rec.forw_inst_code              := get_field(212, 11);              
        l_amx_fin_rec.trans_currency              := get_field(603, 3);
        l_amx_fin_rec.iin                         := get_field(925, 11);
        l_amx_fin_rec.receiving_inst_code         := get_field(1040, 11);
    end if;
    
    l_amx_fin_rec.fee_reason_text             := get_field(246, 95);    
    l_amx_fin_rec.fee_type_code               := get_field(434, 2);
    l_amx_fin_rec.iss_net_sttl_amount         := to_number(get_field(569, 15));   --Settlement Amount 
    l_amx_fin_rec.iss_sttl_currency           := get_field(599, 2);               --Settlement Currency Code
    l_amx_fin_rec.iss_sttl_decimalization     := to_number(get_field(602, 1));    --Settlement Decimalization 
    l_amx_fin_rec.trans_decimalization        := to_number(get_field(606, 1)); 
    l_amx_fin_rec.fp_pres_amount              := to_number(get_field(607, 15));
    l_amx_fin_rec.fp_pres_conversion_rate     := to_number(get_field(622, 8)) / 100000000;
    l_amx_fin_rec.fp_pres_currency            := get_field(637, 3);
    l_amx_fin_rec.fp_pres_decimalization      := to_number(get_field(640, 1));
    
    l_date                                    := get_field(787, 8) || get_field(795, 6);
    l_amx_fin_rec.network_proc_date           := to_date(l_date, amx_api_const_pkg.FORMAT_FILE_DATE);
    l_amx_fin_rec.message_seq_number          := to_number(get_field(938, 3));
    l_amx_fin_rec.transaction_id              := to_number(get_field(1006, 15));
    l_amx_fin_rec.message_number              := to_number(get_field(1032, 8));
    
    l_amx_fin_rec.reject_reason_code          := get_field(1279, 40);
       
    -- calculate debit and credit                        
    calc_debit_credit(
        io_amx_fin_rec      => l_amx_fin_rec    
        , i_impact          => l_amx_fin_rec.impact
        , i_trans_amount    => l_amx_fin_rec.trans_amount
        , io_credit_count   => io_credit_count
        , io_debit_count    => io_debit_count
        , io_credit_amount  => io_credit_amount
        , io_debit_amount   => io_debit_amount
        , io_total_amount   => io_total_amount
    );

    amx_api_dispute_pkg.assign_dispute(
        io_amx_fin_rec  => l_amx_fin_rec  
        , o_auth        => l_auth 
    );        
       
    if nvl(i_create_operation, com_api_type_pkg.TRUE) = com_api_type_pkg.TRUE then    

        amx_api_fin_message_pkg.create_operation(
            i_fin_rec            => l_amx_fin_rec
          , i_standard_id        => i_standard_id 
          , i_auth               => l_auth
          , i_incom_sess_file_id => i_incom_sess_file_id
        );
    end if;

    if l_amx_fin_rec.is_invalid = com_api_type_pkg.TRUE then
        g_error_flag := com_api_type_pkg.TRUE;
        l_amx_fin_rec.status := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
    end if;

    l_amx_fin_rec.id := amx_api_fin_message_pkg.put_message (
        i_fin_rec => l_amx_fin_rec
    );      
    
    trc_log_pkg.debug (
        i_text          => 'amx_prc_incoming_pkg.process_fee end'
    );    
end;

procedure process (
    i_network_id            in     com_api_type_pkg.t_tiny_id
  , i_amx_action_code       in     com_api_type_pkg.t_curr_code  default null -- possible value 'TEST' for test processing
  , i_create_operation      in     com_api_type_pkg.t_boolean    := null
) is
    LOG_PREFIX              constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process: ';
    l_host_id               com_api_type_pkg.t_tiny_id;
    l_standard_id           com_api_type_pkg.t_tiny_id;

    l_record_count          com_api_type_pkg.t_long_id := 0;
    l_errors_count          com_api_type_pkg.t_long_id := 0;

    l_credit_count          com_api_type_pkg.t_long_id := 0;
    l_debit_count           com_api_type_pkg.t_long_id := 0;
    l_credit_amount         com_api_type_pkg.t_money   := 0;
    l_debit_amount          com_api_type_pkg.t_money   := 0;
    l_total_amount          com_api_type_pkg.t_money   := 0;

    l_tc_buffer             com_api_type_pkg.t_raw_data;
    l_amx_file              amx_api_type_pkg.t_amx_file_rec;
    l_mtid                  com_api_type_pkg.t_tiny_id;

    l_trailer_load          com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
        
    -- for ack - file. Original file id 
    l_original_file_id      com_api_type_pkg.t_long_id;
    l_is_acknowledgment     com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
    l_amx_fin_rec           amx_api_type_pkg.t_amx_fin_mes_rec;  

    cursor cu_records_count is
        select count(1)
          from prc_file_raw_data a
             , prc_session_file b
         where b.session_id      = prc_api_session_pkg.get_session_id
           and a.session_file_id = b.id;
begin
    trc_log_pkg.debug (
        i_text          => 'starting loading Amex clearing'
    );
    
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'i_network_id [' || i_network_id
                             || '], i_test_option [' || i_amx_action_code || ']'
                             --|| '], i_create_operation [' || i_create_operation || ']'
    );
    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug (
        i_text          => 'enumerating messages'
    );
    open cu_records_count;
    fetch cu_records_count into l_record_count;
    close cu_records_count;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count     => l_record_count
    );

    trc_log_pkg.debug (
        i_text          => 'estimation record = ' || l_record_count
    );

    -- get network communication standard
    l_host_id := net_api_network_pkg.get_default_host(i_network_id);
    l_standard_id := net_api_network_pkg.get_offline_standard(i_network_id => i_network_id);

    trc_log_pkg.debug(
        i_text => 'l_host_id [' || l_host_id || '], l_standard_id [' || l_standard_id || ']'
    );

    l_record_count := 0;
    g_errors_count := 0;

    for p in (
        select id session_file_id
             , record_count
          from prc_session_file
         where session_id = prc_api_session_pkg.get_session_id
         order by id
    ) loop
    
        trc_log_pkg.debug(
            i_text => 'Processing session_file_id [' || p.session_file_id || '], record_count [' || p.record_count || ']'
        );
        
        begin
            savepoint sp_amx_incoming_file;

            -- reset counts before loading next file
            l_credit_count      := 0;
            l_debit_count       := 0;
            l_credit_amount     := 0;
            l_debit_amount      := 0;
            l_total_amount      := 0;     
            l_trailer_load      := com_api_type_pkg.FALSE;
            l_original_file_id  := null;
            l_is_acknowledgment := com_api_type_pkg.FALSE;
            l_errors_count := 0;
            
            for r in (
                select
                    record_number
                    , raw_data
                    , count(*) over() cnt
                from
                    prc_file_raw_data
                where
                    session_file_id = p.session_file_id
                order by
                    record_number 
            ) loop

                g_error_flag := com_api_type_pkg.FALSE;
                l_tc_buffer  := r.raw_data;
                l_mtid       := to_number(substr(r.raw_data, 1, 4));                
                trc_log_pkg.debug(
                    i_text => 'l_mtid [' || l_mtid || ']'
                );
                          
                if l_mtid = amx_api_const_pkg.MTID_HEADER or l_mtid = amx_api_const_pkg.MTID_DAF_HEADER then
                    
                    process_file_header(
                        i_header_data          => l_tc_buffer
                        , i_mtid               => l_mtid
                        , i_network_id         => i_network_id
                        , i_host_id            => l_host_id
                        , i_standard_id        => l_standard_id
                        , i_action_code        => i_amx_action_code
                        , i_incom_sess_file_id => p.session_file_id
                        , o_amx_file           => l_amx_file
                    );
                    l_amx_fin_rec := null;
                    
                elsif l_mtid = amx_api_const_pkg.MTID_NET_ACKNOWLEDGMENT then

                    l_is_acknowledgment := com_api_type_pkg.TRUE;

                    trc_log_pkg.debug (
                        i_text          => 'File is net acknowledgment'
                    );
                    
                    amx_api_rejected_pkg.process_acknowledgment(
                        i_ack_message          => l_tc_buffer
                        , i_amx_file           => l_amx_file
                        , o_original_file_id   => l_original_file_id
                    );
                    l_amx_file.receipt_file_id := l_original_file_id;
                    l_amx_fin_rec := null;
                        
                elsif l_mtid = amx_api_const_pkg.MTID_TRAILER or l_mtid = amx_api_const_pkg.MTID_DAF_TRAILER then
                    
                    amx_api_file_pkg.format_trailer_counts_amounts(
                        io_credit_count        => l_credit_count
                        , io_debit_count       => l_debit_count
                        , io_credit_amount     => l_credit_amount
                        , io_debit_amount      => l_debit_amount
                        , io_total_amount      => l_total_amount
                    );    
                        
                    process_file_trailer (
                        i_trailer_data        => l_tc_buffer
                        , io_amx_file         => l_amx_file
                        , i_mtid              => l_mtid
                        , i_credit_count      => l_credit_count
                        , i_debit_count       => l_debit_count
                        , i_credit_amount     => l_credit_amount
                        , i_debit_amount      => l_debit_amount
                        , i_total_amount      => l_total_amount
                        , i_is_acknowledgment => l_is_acknowledgment
                        , o_trailer_load      => l_trailer_load
                    );     
                    l_amx_fin_rec  := null;
                    
                elsif l_is_acknowledgment = com_api_type_pkg.TRUE then
                
                    --msg record. No check mtid. All rejected
                    amx_api_rejected_pkg.process_rejected_message(
                        i_ack_message         => l_tc_buffer
                        , i_amx_file          => l_amx_file
                        , i_original_file_id  => l_original_file_id
                    );
                    l_amx_fin_rec := null;
                
                elsif l_mtid = amx_api_const_pkg.MTID_PRESENTMENT then
                    
                    if l_trailer_load = com_api_type_pkg.TRUE then
                        com_api_error_pkg.raise_error(
                            i_error          => 'PRESENTMENT_AFTER_TRAILER'
                            , i_env_param1   => p.session_file_id
                        );  
                    end if;      
                    
                    --process_presentment  
                    process_presentment(
                        i_tc_buffer            => l_tc_buffer
                        , i_amx_file           => l_amx_file
                        , i_mtid               => l_mtid
                        , i_standard_id        => l_standard_id
                        , io_credit_count      => l_credit_count
                        , io_debit_count       => l_debit_count
                        , io_credit_amount     => l_credit_amount
                        , io_debit_amount      => l_debit_amount
                        , io_total_amount      => l_total_amount
                        , i_incom_sess_file_id => p.session_file_id
                        , i_create_operation   => i_create_operation     
                        , o_amx_fin_rec        => l_amx_fin_rec
                    );                              
                        
                elsif l_mtid = amx_api_const_pkg.MTID_CHARGEBACK then
                    
                    process_chargeback(
                        i_tc_buffer            => l_tc_buffer
                        , i_amx_file           => l_amx_file
                        , i_mtid               => l_mtid
                        , i_standard_id        => l_standard_id
                        , io_credit_count      => l_credit_count
                        , io_debit_count       => l_debit_count
                        , io_credit_amount     => l_credit_amount
                        , io_debit_amount      => l_debit_amount
                        , io_total_amount      => l_total_amount
                        , i_incom_sess_file_id => p.session_file_id
                        , i_create_operation   => i_create_operation    
                    );
                    l_amx_fin_rec := null;
                        
                elsif l_mtid = amx_api_const_pkg.MTID_RETRIEVAL_REQUEST or l_mtid = amx_api_const_pkg.MTID_FULFILLMENT then
                    
                    process_retrieval_request(
                        i_tc_buffer            => l_tc_buffer
                        , i_amx_file           => l_amx_file
                        , i_mtid               => l_mtid
                        , i_standard_id        => l_standard_id
                        , i_incom_sess_file_id => p.session_file_id
                        , i_create_operation   => i_create_operation    
                    );
                    l_amx_fin_rec := null;

                elsif l_mtid in (amx_api_const_pkg.MTID_FEE_COLLECTION, amx_api_const_pkg.MTID_ISS_ATM_FEE, amx_api_const_pkg.MTID_ACQ_ATM_FEE) then
                    
                    process_fee(
                        i_tc_buffer            => l_tc_buffer
                        , i_amx_file           => l_amx_file
                        , i_mtid               => l_mtid
                        , i_standard_id        => l_standard_id
                        , io_credit_count      => l_credit_count
                        , io_debit_count       => l_debit_count
                        , io_credit_amount     => l_credit_amount
                        , io_debit_amount      => l_debit_amount
                        , io_total_amount      => l_total_amount
                        , i_incom_sess_file_id => p.session_file_id
                        , i_create_operation   => i_create_operation    
                    );
                    l_amx_fin_rec := null;
                    
                elsif l_mtid = amx_api_const_pkg.MTID_ADDENDA then
                
                    amx_api_add_pkg.create_incoming_addenda (
                        i_tc_buffer            => l_tc_buffer
                        , i_file_id            => l_amx_file.id
                        , i_fin_id             => l_amx_fin_rec.id
                    );                

                elsif l_mtid = amx_api_const_pkg.MTID_DAF_MESSAGE then

                    trc_log_pkg.info(
                        i_text => 'DAF message [' || l_mtid || '/' || substr(r.raw_data, 155, 4) || '/' || substr(r.raw_data, 159, 3) || '] skipped'
                    );

                else
                    trc_log_pkg.warn(
                        i_text => 'Not supported message with mtid [' || l_mtid || ']'
                    );                    
                    
                end if;
                          
                l_record_count  := l_record_count + 1;                    

                if g_error_flag = com_api_type_pkg.TRUE then
                    l_errors_count := l_errors_count + 1;
                end if;               
                    
                if mod(l_record_count, 100) = 0 then
                    
                    prc_api_stat_pkg.log_current(
                        i_current_count  => l_record_count
                      , i_excepted_count => g_errors_count + l_errors_count
                    );
                end if;
                    
                -- last record of file
                if r.record_number = r.cnt then 
                
                    g_errors_count := g_errors_count + l_errors_count;
                    
                    prc_api_stat_pkg.log_current(
                        i_current_count  => l_record_count
                      , i_excepted_count => g_errors_count
                    );
                    
                end if;
                    
            end loop;

            -- check trailer exists
            if l_trailer_load = com_api_type_pkg.FALSE or l_trailer_load is null then
                com_api_error_pkg.raise_error(
                    i_error         => 'TRAILER_NOT_FOUND'
                    , i_env_param1  => p.session_file_id
                );            
            end if;
            
        exception
            when com_api_error_pkg.e_application_error then
            
                rollback to sp_amx_incoming_file;

                g_errors_count := g_errors_count + p.record_count;
                l_errors_count := 0;
                l_record_count := l_record_count + p.record_count;

                prc_api_stat_pkg.log_current(
                    i_current_count  => l_record_count
                  , i_excepted_count => g_errors_count
                );

        end;
        
    end loop;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_record_count
      , i_excepted_total    => g_errors_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(LOG_PREFIX || 'END');

exception
    when others then
        if cu_records_count%isopen then
            close cu_records_count;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        else
            -- Log useful local variables, and therefore log call stack for exception point
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'FAILED with l_mtid [#1]'
              , i_env_param1 => l_mtid
            );
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm||' '||dbms_utility.format_error_backtrace
            );
        end if;
end;

end;
/

