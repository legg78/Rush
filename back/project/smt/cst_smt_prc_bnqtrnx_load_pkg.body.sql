create or replace package body cst_smt_prc_bnqtrnx_load_pkg is

    BULK_LIMIT              constant integer := 4000;
    DUMMY_XML               xmltype;
    DUMMY_XML_NOTNULL       xmltype;
    
    procedure pre_load 
    is
    l_estimated_count       com_api_type_pkg.t_long_id    := 0;
    l_processed_count       com_api_type_pkg.t_long_id    := 0;
    l_excepted_count        com_api_type_pkg.t_long_id    := 0;
    l_rejected_count        com_api_type_pkg.t_long_id    := 0;
    
    l_data_tab              com_api_type_pkg.t_varchar2_tab;
    l_recnum_tab            com_api_type_pkg.t_number_tab;
    l_data_count            number;
    
    l_data_row              com_api_type_pkg.t_text;

    l_session_file_id       com_api_type_pkg.t_long_id;
    l_session_files         com_api_type_pkg.t_number_tab;
    
    l_bnqtrnx_tab           cst_smt_api_type_pkg.t_bnqtrnx_tab;

    cursor cu_records_count is
        select count(1)
          from prc_file_raw_data a
             , prc_session_file b
         where b.session_id      = prc_api_session_pkg.get_session_id
           and a.session_file_id = b.id;
    
    cursor data_cur (
        i_session_file_id in com_api_type_pkg.t_long_id
    ) is
        select
            record_number
            , raw_data
        from
            prc_file_raw_data
        where
            session_file_id = i_session_file_id
        order by
            record_number;    

    procedure flash_data
    is
    begin
    
        trc_log_pkg.debug(i_text => 'Start flash_data ');

        forall i in 1..l_bnqtrnx_tab.count
          insert into cst_smt_bnqtrnx (id, record_type, batch_id, remittance_seq, merchant_id, batch_number, amount, currency, terminal_id, tran_count, batch_date, operation_code, sttl_amount, operation_source, merchant_name, card_number, card_exp_date,tran_date , appr_code, issuer_inst, acquirer_inst, pos_batch_sequence, tran_originator, status, split_hash, session_file_id)
            values (l_bnqtrnx_tab(i).id, l_bnqtrnx_tab(i).record_type, l_bnqtrnx_tab(i).batch_id, l_bnqtrnx_tab(i).remittance_seq, l_bnqtrnx_tab(i).merchant_id, l_bnqtrnx_tab(i).batch_number, l_bnqtrnx_tab(i).amount, l_bnqtrnx_tab(i).currency, l_bnqtrnx_tab(i).terminal_id, l_bnqtrnx_tab(i).tran_count, l_bnqtrnx_tab(i).batch_date, l_bnqtrnx_tab(i).operation_code, l_bnqtrnx_tab(i).sttl_amount, l_bnqtrnx_tab(i).operation_source, l_bnqtrnx_tab(i).merchant_name, l_bnqtrnx_tab(i).card_number, l_bnqtrnx_tab(i).card_exp_date, l_bnqtrnx_tab(i).tran_date, l_bnqtrnx_tab(i).appr_code, l_bnqtrnx_tab(i).issuer_inst, l_bnqtrnx_tab(i).acquirer_inst, l_bnqtrnx_tab(i).pos_batch_sequence, l_bnqtrnx_tab(i).tran_originator, l_bnqtrnx_tab(i).status, l_bnqtrnx_tab(i).split_hash, l_session_file_id);

        l_bnqtrnx_tab.delete;

    end; 

    procedure process_datail(i_row com_api_type_pkg.t_text
    ) is
    l_rec   cst_smt_api_type_pkg.t_bnqtrnx_rec;
    begin
        l_rec.id                := opr_api_create_pkg.get_id;
        l_rec.record_type       := substr(i_row, 1, 4);
        l_rec.batch_id          := substr(i_row, 5, 5);
        l_rec.remittance_seq    := substr(i_row, 10, 3);
        l_rec.merchant_id       := substr(i_row, 16, 10);
        l_rec.batch_number      := substr(i_row, 26, 6);
        l_rec.tran_count        := substr(i_row, 32, 6);
        l_rec.card_number       := substr(i_row, 38, 19);
        l_rec.amount            := substr(i_row, 61, 12);
        l_rec.card_exp_date     := to_date(substr(i_row, 99, 4),'MMYY');
        l_rec.appr_code         := substr(i_row, 103, 6);
        l_rec.tran_date         := to_date(substr(i_row, 109, 6),'DDMMYY');
        l_rec.sttl_amount       := substr(i_row, 115, 12);
        l_rec.operation_source  := substr(i_row, 132, 1);
        l_rec.issuer_inst       := substr(i_row, 133, 4);
        l_rec.operation_code    := substr(i_row, 141, 1);
        l_rec.acquirer_inst     := substr(i_row, 142, 4);
        l_rec.pos_batch_sequence:= substr(i_row, 148, 3);
        l_rec.currency          := substr(i_row, 153, 3);
        l_rec.tran_originator   := substr(i_row, 158, 1);
        l_rec.status            := cst_smt_api_const_pkg.BQNTRNX_RECORD_LOADED_STATUS;
        l_rec.split_hash        := com_api_hash_pkg.get_split_hash(l_rec.card_number);

        l_bnqtrnx_tab(nvl(l_bnqtrnx_tab.count,0)+1) := l_rec;
    end;
    
    procedure update_records
    is
    begin
        update cst_smt_bnqtrnx
           set status = cst_smt_api_const_pkg.BQNTRNX_RECORD_READY_STATUS
         where status = cst_smt_api_const_pkg.BQNTRNX_RECORD_LOADED_STATUS
           and session_file_id = l_session_file_id;
    end; 

    procedure process_remittance(i_row com_api_type_pkg.t_text
    ) is
    i number;
    begin
    
        trc_log_pkg.debug(i_text => 'Start process_remittance for '||l_bnqtrnx_tab.count);
    
        for j in 1..l_bnqtrnx_tab.count
        loop
            i := l_bnqtrnx_tab.count - j+1;

            if l_bnqtrnx_tab(i).merchant_name is null then
                l_bnqtrnx_tab(i).terminal_id    := substr(i_row, 856, 10);
                l_bnqtrnx_tab(i).merchant_name  := substr(i_row, 146, 14);
            else
                exit;
            end if;  
        end loop; 
 
    end;
    
    begin

        savepoint load_bnqtrnx_start;

        trc_log_pkg.info(
            i_text          => 'Pre load bnqtrnx file '
        );

        prc_api_stat_pkg.log_start;

        open cu_records_count;

        fetch cu_records_count into l_estimated_count;
        close cu_records_count;

        prc_api_stat_pkg.log_estimation(
            i_estimated_count       => l_estimated_count
        );

        trc_log_pkg.debug(
            i_text          => 'l_estimated_count [#1]'
          , i_env_param1    => l_estimated_count
        );

        if l_estimated_count > 0 then

            select id
              bulk collect into l_session_files
              from prc_session_file
             where session_id = get_session_id
            order by id;
                
            for i in 1..l_session_files.count loop
                
                l_session_file_id := l_session_files(i);

                trc_log_pkg.debug(i_text => 'Read session file :'||l_session_file_id);
                                
                open data_cur (
                    i_session_file_id  => l_session_file_id
                );

                loop
                    fetch data_cur bulk collect into l_recnum_tab, l_data_tab limit BULK_LIMIT;
                    
                    l_data_count := l_data_tab.count;

                    trc_log_pkg.debug(i_text => 'Process data :'||l_data_count);

                    for j in 1 .. l_data_count loop
                        
                        l_data_row := l_data_tab(j);
                        
                        if substr(l_data_row,1,2) = 'FA' then -- detail record
                            process_datail(l_data_row);

                        elsif substr(l_data_row,1,2) = 'BO' then -- detail remittance
                            process_remittance(l_data_row);

                            if l_bnqtrnx_tab.count>BULK_LIMIT then
                                flash_data;
                                
                                prc_api_stat_pkg.log_current (
                                    i_current_count    => l_processed_count
                                    , i_excepted_count => l_excepted_count
                                );                                
                            end if;

                        end if;
                        
                        l_processed_count := l_processed_count + 1;
                        
                    end loop;
                    
                    exit when data_cur%notfound;
                    
                end loop;
                
                flash_data;
                
                update_records;
                
                prc_api_stat_pkg.log_current (
                    i_current_count    => l_processed_count
                    , i_excepted_count => l_excepted_count
                );

                if data_cur%isopen then
                    close data_cur;
                end if;

            end loop;
            
            flash_data;

        end if;

        prc_api_stat_pkg.log_end(
            i_excepted_total   => l_excepted_count
          , i_processed_total  => l_processed_count
          , i_rejected_total   => l_rejected_count
          , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );

        trc_log_pkg.info(
            i_text  => 'Pre load bnqtrnx file finished'
        );

        com_api_sttl_day_pkg.unset_sysdate;

    exception
        when others then
            rollback to savepoint load_bnqtrnx_start;
            com_api_sttl_day_pkg.unset_sysdate;
            trc_log_pkg.clear_object;

            if data_cur%isopen then
                close data_cur;
            end if;

            prc_api_stat_pkg.log_end(
                i_excepted_total     => l_excepted_count
              , i_processed_total  => l_processed_count
              , i_rejected_total   => l_rejected_count
              , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );

            if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
                raise;

            elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_fatal_error(
                    i_error         => 'UNHANDLED_EXCEPTION'
                  , i_env_param1    => sqlerrm
                );

            end if;

            raise;
    end;
    
    procedure process_bnqtrnx
    is
    l_estimated_count       com_api_type_pkg.t_long_id    := 0;
    l_processed_count       com_api_type_pkg.t_long_id    := 0;
    l_excepted_count        com_api_type_pkg.t_long_id    := 0;
    l_rejected_count        com_api_type_pkg.t_long_id    := 0;
    
    l_bnqtrnx_tab           cst_smt_api_type_pkg.t_bnqtrnx_tab;
    
    l_error_id_tab          num_tab_tpt                   := num_tab_tpt();
    l_ok_id_tab             num_tab_tpt                   := num_tab_tpt();
    l_oper_id_tab           num_tab_tpt                   := num_tab_tpt();
    
    cursor cu_data is
      select * from cst_smt_bnqtrnx b
         where decode(b.status, 'BQST0001', b.split_hash, null) in (select split_hash from com_api_split_map_vw);

    function get_oper_type(i_code    in com_api_type_pkg.t_one_char
                          , i_source  in com_api_type_pkg.t_one_char
    ) return com_api_type_pkg.t_dict_value
    result_cache 
    is
    l_return    com_api_type_pkg.t_dict_value;
    begin
        if i_code = cst_smt_api_const_pkg.BQNTRNX_RECORD_DEBIT_CODE then
        
            if i_source = cst_smt_api_const_pkg.BQNTRNX_RECORD_POS_SOURCE then
                l_return := opr_api_const_pkg.OPERATION_TYPE_PURCHASE;

            elsif i_source in (cst_smt_api_const_pkg.BQNTRNX_RECORD_ATM1_SOURCE, cst_smt_api_const_pkg.BQNTRNX_RECORD_ATM2_SOURCE) then
                l_return := opr_api_const_pkg.OPERATION_TYPE_ATM_CASH;
                                
            elsif i_source in (cst_smt_api_const_pkg.BQNTRNX_RECORD_MANUAL1_SOURCE, cst_smt_api_const_pkg.BQNTRNX_RECORD_MANUAL2_SOURCE) then
                l_return := opr_api_const_pkg.OPERATION_TYPE_PURCHASE;
                                
            elsif i_source = cst_smt_api_const_pkg.BQNTRNX_RECORD_INTERNET_SOURCE then
                l_return := opr_api_const_pkg.OPERATION_TYPE_PURCHASE;
                                
            elsif i_source = cst_smt_api_const_pkg.BQNTRNX_RECORD_RECHARGE_SOURCE then
                l_return := opr_api_const_pkg.OPERATION_TYPE_PURCHASE;
                                
            end if;
        else
            if i_source = cst_smt_api_const_pkg.BQNTRNX_RECORD_POS_SOURCE then
                l_return := opr_api_const_pkg.OPERATION_TYPE_REFUND;

            elsif i_source in (cst_smt_api_const_pkg.BQNTRNX_RECORD_ATM1_SOURCE, cst_smt_api_const_pkg.BQNTRNX_RECORD_ATM2_SOURCE) then
                l_return := opr_api_const_pkg.OPERATION_TYPE_UNIQUE;
                                
            elsif i_source in (cst_smt_api_const_pkg.BQNTRNX_RECORD_MANUAL1_SOURCE, cst_smt_api_const_pkg.BQNTRNX_RECORD_MANUAL2_SOURCE) then
                l_return := opr_api_const_pkg.OPERATION_TYPE_REFUND;
                                
            elsif i_source = cst_smt_api_const_pkg.BQNTRNX_RECORD_INTERNET_SOURCE then
                l_return := opr_api_const_pkg.OPERATION_TYPE_REFUND;
                                
            elsif i_source = cst_smt_api_const_pkg.BQNTRNX_RECORD_RECHARGE_SOURCE then
                l_return := opr_api_const_pkg.OPERATION_TYPE_REFUND;
                                
            end if;            
        end if;
    
         return l_return;
    end;
    
    function get_terminal_type(i_source in com_api_type_pkg.t_one_char
    ) return com_api_type_pkg.t_dict_value
    result_cache 
    is
    l_return    com_api_type_pkg.t_dict_value;
    begin
        if i_source = cst_smt_api_const_pkg.BQNTRNX_RECORD_POS_SOURCE then
            l_return := acq_api_const_pkg.TERMINAL_TYPE_POS;

        elsif i_source in (cst_smt_api_const_pkg.BQNTRNX_RECORD_ATM1_SOURCE, cst_smt_api_const_pkg.BQNTRNX_RECORD_ATM2_SOURCE) then
            l_return := acq_api_const_pkg.TERMINAL_TYPE_ATM;
                                    
        elsif i_source in (cst_smt_api_const_pkg.BQNTRNX_RECORD_MANUAL1_SOURCE, cst_smt_api_const_pkg.BQNTRNX_RECORD_MANUAL2_SOURCE) then
            l_return := acq_api_const_pkg.TERMINAL_TYPE_UNKNOWN;
                                    
        elsif i_source = cst_smt_api_const_pkg.BQNTRNX_RECORD_INTERNET_SOURCE then
            l_return := acq_api_const_pkg.TERMINAL_TYPE_INTERNET;
                                    
        elsif i_source = cst_smt_api_const_pkg.BQNTRNX_RECORD_RECHARGE_SOURCE then
            l_return := acq_api_const_pkg.TERMINAL_TYPE_UNKNOWN;
                                    
        end if;

        return l_return;
    end;
    
    function get_inst_id(i_inst_code in cst_smt_api_type_pkg.t_inst_name
    ) return com_api_type_pkg.t_inst_id
    result_cache 
    is 
    l_inst_code  cst_smt_api_type_pkg.t_inst_name := trim(i_inst_code);
    l_return com_api_type_pkg.t_inst_id;
    begin
    
        if l_inst_code = cst_smt_api_const_pkg.BQNTRNX_RECORD_DNRS_INST then
            l_return := din_api_const_pkg.DIN_INSTITUTION_ID;
        elsif l_inst_code = cst_smt_api_const_pkg.BQNTRNX_RECORD_AMEX_INST then
            l_return := cst_smt_api_const_pkg.AMEX_NETWORK_INST;
        elsif l_inst_code = cst_smt_api_const_pkg.BQNTRNX_RECORD_MAESTRO_INST then
            l_return := cst_smt_api_const_pkg.MC_NETWORK_INST;
        elsif l_inst_code in (cst_smt_api_const_pkg.BQNTRNX_RECORD_VISA_INST, cst_smt_api_const_pkg.BQNTRNX_RECORD_VISASMS_INST) then
            l_return := cst_smt_api_const_pkg.VISA_NETWORK_INST;
        elsif l_inst_code = cst_smt_api_const_pkg.BQNTRNX_RECORD_MC_INST then
            l_return := cst_smt_api_const_pkg.MC_NETWORK_INST;
        else
            l_return := l_inst_code;
        end if;
    
        return l_return;
    end;
        
    function get_network_id(i_inst_code in cst_smt_api_type_pkg.t_inst_name
    ) return com_api_type_pkg.t_network_id
    result_cache 
    is
    l_inst_code  cst_smt_api_type_pkg.t_inst_name := trim(i_inst_code);
    l_return com_api_type_pkg.t_network_id;
    begin
    
        if l_inst_code = cst_smt_api_const_pkg.BQNTRNX_RECORD_DNRS_INST then
            l_return := din_api_const_pkg.DIN_NETWORK_ID;
        elsif l_inst_code = cst_smt_api_const_pkg.BQNTRNX_RECORD_AMEX_INST then
            l_return := cst_smt_api_const_pkg.AMEX_NETWORK;
        elsif l_inst_code = cst_smt_api_const_pkg.BQNTRNX_RECORD_MAESTRO_INST then
            l_return := cst_smt_api_const_pkg.MC_NETWORK;
        elsif l_inst_code in (cst_smt_api_const_pkg.BQNTRNX_RECORD_VISA_INST, cst_smt_api_const_pkg.BQNTRNX_RECORD_VISASMS_INST) then
            l_return := cst_smt_api_const_pkg.VISA_NETWORK;
        elsif l_inst_code = cst_smt_api_const_pkg.BQNTRNX_RECORD_MC_INST then
            l_return := cst_smt_api_const_pkg.MC_NETWORK;
        else
            l_return := l_inst_code;
        end if;
            
        return l_return;
    end;    
    
    procedure create_operation(i_bnqtrnx_rec cst_smt_api_type_pkg.t_bnqtrnx_rec
    ) is
    
    l_oper_rec          opr_prc_import_pkg.t_oper_clearing_rec;
    l_auth_data_rec     aut_api_type_pkg.t_auth_rec;
    l_auth_tag_tab      aut_api_type_pkg.t_auth_tag_tab;
    l_oper_status       com_api_type_pkg.t_dict_value;
    l_sttl_date         date;
    l_split_hash_tab    com_api_type_pkg.t_tiny_tab;
    l_inst_id_tab       com_api_type_pkg.t_inst_id_tab;
    l_resp_code         com_api_type_pkg.t_dict_value;
    l_merchant          acq_api_type_pkg.t_merchant;
    l_address           com_api_type_pkg.t_address_rec;
    l_match_status      com_api_type_pkg.t_dict_value;
    l_param             com_api_type_pkg.t_param_tab;
    l_event_params      com_api_type_pkg.t_param_tab;
    begin
        savepoint create_operation;
        
        trc_log_pkg.info(i_text  => 'Start(thread '||get_thread_number||') : '||i_bnqtrnx_rec.id);
        
        trc_log_pkg.set_object(
                    i_entity_type => null
                    , i_object_id => i_bnqtrnx_rec.id);
        
        l_oper_rec.oper_type                    := get_oper_type(i_code    => i_bnqtrnx_rec.operation_code 
                                                                 , i_source=> i_bnqtrnx_rec.operation_source);
        l_oper_rec.msg_type                     := aut_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION;
        
        l_oper_rec.oper_date                    := i_bnqtrnx_rec.tran_date;
        l_oper_rec.host_date                    := i_bnqtrnx_rec.tran_date;

        l_oper_rec.oper_amount_value            := i_bnqtrnx_rec.amount; 
        l_oper_rec.oper_amount_currency         := i_bnqtrnx_rec.currency;
        l_oper_rec.sttl_amount_value            := i_bnqtrnx_rec.sttl_amount; 
        l_oper_rec.sttl_amount_currency         := case i_bnqtrnx_rec.sttl_amount is not null 
                                                        when true then i_bnqtrnx_rec.currency
                                                        else null
                                                   end;
    
        l_oper_rec.is_reversal                  := 0; 
        l_oper_rec.acq_inst_bin                 := i_bnqtrnx_rec.acquirer_inst;
        l_oper_rec.merchant_number              := i_bnqtrnx_rec.merchant_id;
        l_oper_rec.acquirer_inst_id             := get_inst_id(i_inst_code => i_bnqtrnx_rec.acquirer_inst);        
        
        l_merchant := acq_api_merchant_pkg.get_merchant( i_inst_id          => l_oper_rec.acquirer_inst_id
                                                        , i_merchant_number => i_bnqtrnx_rec.merchant_id);
        
        l_oper_rec.mcc                          := l_merchant.mcc;
        l_oper_rec.merchant_name                := i_bnqtrnx_rec.merchant_name;
        
        l_address := com_api_address_pkg.get_address( i_object_id   => l_merchant.id
                                                    , i_entity_type => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                                                    , i_address_type => null);
        
        l_oper_rec.merchant_street              := l_address.street;
        l_oper_rec.merchant_city                := l_address.city;
        l_oper_rec.merchant_region              := l_address.region;
        l_oper_rec.merchant_country             := l_address.country;
        l_oper_rec.merchant_postcode            := l_address.postal_code;
        l_oper_rec.terminal_type                := get_terminal_type(i_source=> i_bnqtrnx_rec.operation_source);
        l_oper_rec.terminal_number              := i_bnqtrnx_rec.terminal_id;

        l_oper_rec.payment_parameters           := DUMMY_XML;
        l_oper_rec.issuer_client_id_type        := opr_api_const_pkg.CLIENT_ID_TYPE_CARD;
        l_oper_rec.issuer_client_id_value       := i_bnqtrnx_rec.card_number;
        l_oper_rec.issuer_card_number           := i_bnqtrnx_rec.card_number;
        l_oper_rec.issuer_card_expir_date       := i_bnqtrnx_rec.card_exp_date;
        
        l_oper_rec.issuer_inst_id               := get_inst_id(i_inst_code => i_bnqtrnx_rec.issuer_inst);
        l_oper_rec.issuer_network_id            := get_network_id(i_inst_code => i_bnqtrnx_rec.issuer_inst);
        l_oper_rec.issuer_auth_code             := i_bnqtrnx_rec.appr_code;

        l_oper_rec.acquirer_client_id_type      := opr_api_const_pkg.CLIENT_ID_TYPE_MERCHANT;
        l_oper_rec.acquirer_client_id_value     := l_merchant.id;
        l_oper_rec.acquirer_network_id          := get_network_id(i_inst_code => i_bnqtrnx_rec.acquirer_inst);

        net_api_sttl_pkg.get_sttl_type(
            i_iss_inst_id               => l_oper_rec.issuer_inst_id
            , i_acq_inst_id             => l_oper_rec.acquirer_inst_id
            , i_card_inst_id            => null
            , i_iss_network_id          => l_oper_rec.issuer_network_id
            , i_acq_network_id          => l_oper_rec.acquirer_network_id
            , i_card_network_id         => null
            , i_acq_inst_bin            => null
            , o_sttl_type               => l_oper_rec.sttl_type
            , o_match_status            => l_match_status
            , i_params                  => l_param
            );

        l_oper_rec.participant                  := DUMMY_XML; 
        l_oper_rec.payment_order_exists         := com_api_const_pkg.FALSE;
        l_oper_rec.issuer_exists                := com_api_const_pkg.TRUE;
        l_oper_rec.acquirer_exists              := com_api_const_pkg.TRUE;
        l_oper_rec.destination_exists           := com_api_const_pkg.FALSE;
        l_oper_rec.aggregator_exists            := com_api_const_pkg.FALSE;
        l_oper_rec.service_provider_exists      := com_api_const_pkg.FALSE;
        l_oper_rec.incom_sess_file_id           := i_bnqtrnx_rec.session_file_id;
        l_oper_rec.note                         := DUMMY_XML;
        l_oper_rec.auth_data                    := DUMMY_XML_NOTNULL;
        l_oper_rec.ipm_data                     := DUMMY_XML;
        l_oper_rec.baseii_data                  := DUMMY_XML;
        l_oper_rec.additional_amount            := DUMMY_XML; 
        l_oper_rec.processing_stage             := DUMMY_XML;
        l_oper_rec.flexible_data                := DUMMY_XML;
        
        l_auth_tag_tab(1).tag_name := cst_smt_api_const_pkg.TAG_BATCH_NUMBER;
        l_auth_tag_tab(1).tag_value := i_bnqtrnx_rec.batch_number; 
        
        l_resp_code := opr_prc_import_pkg.register_operation(
                           io_oper             => l_oper_rec
                         , io_auth_data_rec    => l_auth_data_rec
                         , io_auth_tag_tab     => l_auth_tag_tab
                         , i_import_clear_pan  => com_api_type_pkg.TRUE
                         , i_oper_status       => l_oper_status
                         , i_sttl_date         => l_sttl_date 
                         , i_without_checks    => com_api_const_pkg.TRUE
                         , io_split_hash_tab   => l_split_hash_tab
                         , io_inst_id_tab      => l_inst_id_tab
                         , i_use_auth_data_rec => com_api_const_pkg.TRUE
                         , io_event_params     => l_event_params
                       );        

        opr_prc_import_pkg.register_events(
            io_oper           => l_oper_rec
          , i_resp_code       => l_resp_code
          , io_split_hash_tab => l_split_hash_tab
          , io_inst_id_tab    => l_inst_id_tab
          , io_event_params   => l_event_params
        );

        trc_log_pkg.clear_object;
        
        trc_log_pkg.info(i_text  => 'Ok(thread '||get_thread_number||') : '||i_bnqtrnx_rec.id);
        
        l_ok_id_tab.extend;
        l_ok_id_tab(l_ok_id_tab.count) := i_bnqtrnx_rec.id;
        
        l_oper_id_tab.extend;
        l_oper_id_tab(l_oper_id_tab.count) := l_oper_rec.oper_id;
              
    exception
        when others then
            rollback to savepoint create_operation;

            l_error_id_tab.extend;
            l_error_id_tab(l_error_id_tab.count) := i_bnqtrnx_rec.id;
                
            trc_log_pkg.error(i_text  => 'Error(thread '||get_thread_number||' - '||i_bnqtrnx_rec.id||') : '||sqlerrm);
                
            trc_log_pkg.clear_object;
    end;
    
    procedure update_records
    is
    begin
        
        forall i in 1..l_ok_id_tab.count 
        update cst_smt_bnqtrnx
           set status = cst_smt_api_const_pkg.BQNTRNX_RECORD_PROCESSED_ST
             , oper_id = l_oper_id_tab(i)            
         where id = l_ok_id_tab(i);  

        l_processed_count := l_processed_count + l_ok_id_tab.count;
        
        l_ok_id_tab.delete;
        l_oper_id_tab.delete;

        update cst_smt_bnqtrnx
           set status = cst_smt_api_const_pkg.BQNTRNX_RECORD_ERROR_STATUS
         where id in (select column_value from table(cast(l_error_id_tab as num_tab_tpt)));
        
        l_excepted_count := l_excepted_count + l_error_id_tab.count;
        
        l_error_id_tab.delete; 

        prc_api_stat_pkg.log_current (
            i_current_count    => l_processed_count
            , i_excepted_count => l_excepted_count
        );
        
    end;
        
    begin

        savepoint load_process_bnqtrnx_start;    

        trc_log_pkg.info(i_text  => 'Pos-process bnqtrnx file start(thread '||get_thread_number||')');
        
        select xmlelement("dummy") into DUMMY_XML_NOTNULL from dual;

        select count(1)
          into l_estimated_count  
          from cst_smt_bnqtrnx b
         where decode(b.status, 'BQST0001', b.split_hash, null) in (select split_hash from com_api_split_map_vw);

        prc_api_stat_pkg.log_estimation(
            i_estimated_count       => l_estimated_count
        );

        trc_log_pkg.debug(
            i_text          => 'l_estimated_count [#1]'
          , i_env_param1    => l_estimated_count
        );
        
        open cu_data;

        loop
        
            fetch cu_data bulk collect into l_bnqtrnx_tab limit BULK_LIMIT;
            
            for i in 1..l_bnqtrnx_tab.count
            loop
                
                create_operation(i_bnqtrnx_rec => l_bnqtrnx_tab(i));

            end loop;
            
            update_records;
            
            exit when cu_data%notfound;
        
        end loop;
        
        close cu_data;

        prc_api_stat_pkg.log_end(
            i_excepted_total   => l_excepted_count
          , i_processed_total  => l_processed_count
          , i_rejected_total   => l_rejected_count
          , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );

        trc_log_pkg.info( i_text  => 'Pos-process bnqtrnx file finished' );

        com_api_sttl_day_pkg.unset_sysdate;
    
    exception
        when others then
            rollback to savepoint load_process_bnqtrnx_start;
            
            com_api_sttl_day_pkg.unset_sysdate;
            trc_log_pkg.clear_object;

            if cu_data%isopen then
                close cu_data;
            end if;

            prc_api_stat_pkg.log_end(
                i_excepted_total     => l_excepted_count
              , i_processed_total  => l_processed_count
              , i_rejected_total   => l_rejected_count
              , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );

            if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
                raise;

            elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_fatal_error(
                    i_error         => 'UNHANDLED_EXCEPTION'
                  , i_env_param1    => sqlerrm
                );

            end if;

            raise;
    end;    

end;
/
