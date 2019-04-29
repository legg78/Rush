create or replace package body cst_smt_prc_cb_outgoing_pkg is
/************************************************************
 * Custom upload clearing file for CB of Tunisia
 ************************************************************/
 
    BULK_LIMIT      constant integer := 4000;
    
    function get_tran_channal (
        i_terminal_type com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_one_char
    result_cache 
    is
    l_return com_api_type_pkg.t_one_char := 'T';
    begin

        case i_terminal_type
            when acq_api_const_pkg.TERMINAL_TYPE_IMPRINTER 
                then l_return := 'M';
            when acq_api_const_pkg.TERMINAL_TYPE_ATM 
                then l_return := 'G';
            when acq_api_const_pkg.TERMINAL_TYPE_INTERNET 
                then l_return := 'I';
            when acq_api_const_pkg.TERMINAL_TYPE_MOBILE_POS
                then l_return := 'G';     
            when acq_api_const_pkg.TERMINAL_TYPE_MOBILE 
                then l_return := 'G';
        end case;    

        return l_return;
    end;

    function get_device_type (
        i_terminal_type com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_one_char
    result_cache 
    is
    l_return com_api_type_pkg.t_one_char := '6';
    begin

        case i_terminal_type 
            when acq_api_const_pkg.TERMINAL_TYPE_IMPRINTER 
                then l_return := '0';
            when acq_api_const_pkg.TERMINAL_TYPE_ATM 
                then l_return := '9';
            when acq_api_const_pkg.TERMINAL_TYPE_MOBILE_POS
                then l_return := '8';
            when acq_api_const_pkg.TERMINAL_TYPE_MOBILE 
                then l_return := '8';
        end case;    

        return l_return;
    end;
    
    function get_tran_code (
        i_oper_type                  com_api_type_pkg.t_dict_value
        , i_invoice                  com_api_type_pkg.t_name
        , i_is_domestic_file_type    com_api_type_pkg.t_boolean :=  com_api_const_pkg.TRUE 
    ) return com_api_type_pkg.t_byte_char
    result_cache 
    is
    l_return com_api_type_pkg.t_byte_char;
    begin

        If i_is_domestic_file_type = com_api_const_pkg.TRUE  then

            If i_oper_type in ( opr_api_const_pkg.OPERATION_TYPE_PURCHASE
                                , opr_api_const_pkg.OPERATION_TYPE_CASHBACK
                                , opr_api_const_pkg.OPERATION_TYPE_UNIQUE)  
                then l_return := '05';

            Elsif i_oper_type = opr_api_const_pkg.OPERATION_TYPE_POS_CASH 
                then l_return := '07';

            Elsif i_oper_type = opr_api_const_pkg.OPERATION_TYPE_REFUND 
                then l_return := '06';

            Elsif i_oper_type = opr_api_const_pkg.OPERATION_TYPE_ATM_CASH 
                then l_return := '08';

            Else l_return := substr(i_invoice,2,2);
            end if;
        else

            If i_oper_type in ( opr_api_const_pkg.OPERATION_TYPE_PURCHASE
                                , opr_api_const_pkg.OPERATION_TYPE_CASHBACK
                                , opr_api_const_pkg.OPERATION_TYPE_UNIQUE)  
                then l_return := '01';

            Elsif i_oper_type = opr_api_const_pkg.OPERATION_TYPE_POS_CASH 
                then l_return := '03';

            Elsif i_oper_type = opr_api_const_pkg.OPERATION_TYPE_REFUND 
                then l_return := '02';

            Elsif i_oper_type = opr_api_const_pkg.OPERATION_TYPE_ATM_CASH 
                then l_return := '04';
            Else l_return := substr(i_invoice,2,2);
            end if;        
        end if;

        return l_return;
    end;    
 
    function get_merchant_type (
        i_terminal_type       com_api_type_pkg.t_dict_value
        , i_oper_type         com_api_type_pkg.t_dict_value
        , i_merchant_param    com_api_type_pkg.t_name
    ) return com_api_type_pkg.t_one_char
    result_cache
    is
    l_merchant_type com_api_type_pkg.t_one_char;
    
    begin
        if i_terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM 
            then l_merchant_type := '4';

        elsif i_merchant_param = 'Z'
            then l_merchant_type := '5';

        elsif i_oper_type = opr_api_const_pkg.OPERATION_TYPE_POS_CASH
            then l_merchant_type := '2';
        else 
            l_merchant_type := '0';
        end if;
  
        return l_merchant_type;
    end;
    
    function get_convertation (
        i_array_type_id         in      com_api_type_pkg.t_tiny_id
        , i_array_id            in      com_api_type_pkg.t_short_id
        , i_elem_value          in      com_api_type_pkg.t_name
        , i_retun_def_value     in      com_api_type_pkg.t_name default null
    ) return com_api_type_pkg.t_name 
    result_cache relies_on(com_array_conv_elem)
    is
    i_return com_api_type_pkg.t_name; 
    begin
        begin
            i_return := com_api_array_pkg.conv_array_elem_v(
                                i_array_type_id => i_array_type_id
                                , i_array_id    => i_array_id
                                , i_elem_value  => i_elem_value);
        exception
            when NO_DATA_FOUND then
               i_return := i_retun_def_value; 
        end;

        return i_return;  
    end;
    
 
    function str_format (
        i_line varchar2 
        , i_length number
        , i_default varchar2
        , i_side number default 0 -- 0 - rpad,1- lpad
    ) return varchar2
    is
    begin
        if i_side = 0 then
                return rpad(substr(nvl(i_line,i_default),1,i_length),i_length,i_default);
            else
                return lpad(substr(nvl(i_line,i_default),1,i_length),i_length,i_default);
        end if;
            
    end;
 
    procedure upload_domestic_clearing (
        i_inst_id                 in com_api_type_pkg.t_inst_id := null
    ) is
    l_estimated_count               com_api_type_pkg.t_long_id := 0;
    l_record_count                  com_api_type_pkg.t_long_id;
    l_proc_name                     com_api_type_pkg.t_name    := 'CST_SMT_PRC_CB_OUTGOING_PKG.UPLOAD_DOMESTIC_CLEARING';
    l_bulk_limit                    com_api_type_pkg.t_count  := 1000;
    l_session_file_id               com_api_type_pkg.t_long_id;
    l_fetched_event_object_id_tab   num_tab_tpt                     := num_tab_tpt();
    l_fetched_oper_id_tab           num_tab_tpt                     := num_tab_tpt();    
    l_event_object_id_tab           num_tab_tpt                     := num_tab_tpt();
    l_oper_id_tab                   num_tab_tpt                     := num_tab_tpt();
    l_oper_id                       com_api_type_pkg.t_long_id;
    l_params                        com_api_type_pkg.t_param_tab;
    
    cursor cur_objects is
    select e_obj.id,
           e_obj.object_id 
      from evt_event_type e_type, evt_event_object e_obj
     where e_type.event_type in (cst_smt_api_const_pkg.DOMESTIC_ACQ_EVENT) 
       and e_type.ID = e_obj.event_id 
       and decode(e_obj.status,'EVST0001', e_obj.procedure_name,NULL) = l_proc_name 
       and e_obj.inst_id = nvl(i_inst_id, e_obj.inst_id)
       order by e_obj.inst_id
                , e_obj.object_id; 

    procedure register_session_file (
        i_inst_id               in com_api_type_pkg.t_inst_id
    ) is
    begin
        l_params.delete;
        rul_api_param_pkg.set_param (
            i_name       => 'INST_ID'
            , i_value    => to_char(i_inst_id)
            , io_params  => l_params
        );

        prc_api_file_pkg.open_file (
            o_sess_file_id  => l_session_file_id
            , i_file_type   => cst_smt_api_const_pkg.FILE_TYPE_CB_DOMESTIC_CLEARING
            , io_params     => l_params
        );

    end;
    
    procedure generate_detail
    is
     
    cursor cur_detail is
     select  oo.merchant_number     merchant_id           
             , aup_api_tag_pkg.get_tag_value(
                    i_auth_id           => oo.id
                    , i_tag_reference   => cst_smt_api_const_pkg.TAG_BATCH_NUMBER
               )                    batch_num            
             , substr(aup_api_tag_pkg.get_tag_value(
                         i_auth_id          => oo.id
                         , i_tag_reference  => cst_smt_api_const_pkg.TAG_INVOCE)
               , 4)                 invoce              
             , oo_card.card_number  pan
             , com_api_flexible_data_pkg.get_flexible_value(
                    i_field_name    => cst_smt_api_const_pkg.MERCHANT_ACTICITY_SECTOR    
                    , i_entity_type => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                    , i_object_id   => acq_part.merchant_id
                    )               merchant_sector     
             , cst_smt_prc_cb_outgoing_pkg.get_tran_channal(
                    i_terminal_type => term.terminal_type
               )                    transaction_channal
             , case com_api_array_pkg.is_element_in_array(
                    i_array_id      => opr_api_const_pkg.OPER_TYPE_CREDIT_ARRAY_ID 
                  , i_elem_value    => oo.oper_type) 
                  when com_api_const_pkg.TRUE then 'C'
                  else 'D' 
                 end                oper_code
             , cst_smt_prc_cb_outgoing_pkg.get_tran_code(
                    i_oper_type => oo.oper_type
                    , i_invoice => aup_api_tag_pkg.get_tag_value(
                                      i_auth_id         => oo.id
                                      , i_tag_reference => cst_smt_api_const_pkg.TAG_INVOCE
                                   )
                    )               transaction_code
             , oo.oper_amount       trnasaction_amount    
             , iss_part.card_expir_date card_expire_date
             , sysdate processing_date     
             , oo.oper_date         transaction_date    
             , iss_part.auth_code   auth_code
             , oo.oper_date         remittance_date     
             , oo.mcc               mcc                 
             , acq_part.inst_id     acquirer_id         
             , case com_api_const_pkg.TRUE 
                    when 
                     com_api_array_pkg.is_element_in_array(
                        i_array_id      => mcw_api_const_pkg.QR_CARD_TYPE_ARRAY 
                        , i_elem_value  => iss_part.card_type_id)
                     then '3'
                    when 
                     com_api_array_pkg.is_element_in_array(
                        i_array_id      => vis_api_const_pkg.QR_CARD_TYPE_ARRAY 
                        , i_elem_value  => iss_part.card_type_id) 
                    then '2'
                    else '1'
               end                  local_card_system                   
             , iss_part.inst_id     issuer_id           
             , aup_api_tag_pkg.get_tag_value(
                    i_auth_id           => oo.id
                    , i_tag_reference   => cst_smt_api_const_pkg.TAG_ARN
               )                    acquirer_refnum     
             , '00'                 usage_code         
             , oo.originator_refnum tran_reference_id   
             , oo.merchant_name     merchant_name     
             , oo.sttl_amount       sttl_amount    
       from opr_operation oo
          , opr_participant iss_part
          , opr_participant acq_part
          , opr_card oo_card
          , Acq_terminal term 
      where oo.id in (select column_value from table(cast(l_oper_id_tab as num_tab_tpt))) 
        and oo.id = iss_part.oper_id 
        and iss_part.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
        and oo.id = acq_part.oper_id 
        and acq_part.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
        and oo.id = oo_card.oper_id 
        and oo_card.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
        and acq_part.terminal_id = term.id;
      
        l_cur_detail cst_smt_api_type_pkg.t_domestic_clearing_tab;
        l_line       com_api_type_pkg.t_text;
     
    begin
    
        open cur_detail; 
        
        loop
            fetch cur_detail bulk collect into l_cur_detail
               limit BULK_LIMIT;
               
            for i in 1..l_cur_detail.count 
            loop 
                
                l_line := rpad(l_cur_detail(i).merchant_id,10,' ');              
                l_line := l_line || str_format(l_cur_detail(i).batch_num, 6, '0');               
                l_line := l_line || str_format(l_cur_detail(i).invoce, 6, '0');                 
                l_line := l_line || str_format(l_cur_detail(i).pan, 19, ' ');
                l_line := l_line || str_format(l_cur_detail(i).merchant_sector, 1, ' ');        
                l_line := l_line || str_format(l_cur_detail(i).transaction_channal,1,' ');    
                l_line := l_line || str_format(l_cur_detail(i).oper_code, 1, ' ');              
                l_line := l_line || str_format(l_cur_detail(i).transaction_code, 2, '0', 1);       
                l_line := l_line || str_format(l_cur_detail(i).trnasaction_amount, 9, '0', 1);     
                l_line := l_line || to_char(nvl(l_cur_detail(i).card_expire_date,sysdate),'MMYY');       
                l_line := l_line || to_char(nvl(l_cur_detail(i).processing_date,sysdate),'DDMMYY');        
                l_line := l_line || to_char(nvl(l_cur_detail(i).transaction_date,sysdate),'DDMMYY');      
                l_line := l_line || str_format(l_cur_detail(i).auth_code,6,' ');              
                l_line := l_line || to_char(nvl(l_cur_detail(i).remittance_date,sysdate),'DDMMYY'); 
                l_line := l_line || str_format(l_cur_detail(i).mcc,4,'0');
                l_line := l_line || '  ';                                   -- filler
                l_line := l_line || str_format(l_cur_detail(i).acquirer_id,5,'0',1);            
                l_line := l_line || str_format(l_cur_detail(i).local_card_system,1,' ');      
                l_line := l_line || str_format(l_cur_detail(i).issuer_id,5,'0',1);              
                l_line := l_line || str_format(l_cur_detail(i).acquirer_refnum,23,' ');
                l_line := l_line || str_format(l_cur_detail(i).usage_code,2,'0');     
                l_line := l_line || str_format(l_cur_detail(i).tran_reference_id,12,' ');      
                l_line := l_line || str_format(l_cur_detail(i).merchant_name,25,' ');          
                l_line := l_line || str_format(l_cur_detail(i).sttl_amount,9,'0',1);
                l_line := l_line || to_char(nvl(l_cur_detail(i).transaction_date,sysdate),'HH24MI');
                l_line := l_line || lpad(' ',4,' ');                        -- filler
                l_line := l_line || 'X';
            
                prc_api_file_pkg.put_line(
                    i_raw_data      => l_line
                  , i_sess_file_id  => l_session_file_id
                );
            end loop;

            exit when cur_detail%notfound;

        end loop;
        
        if cur_detail%isopen then
            close cur_detail;
        end if; 
    
        l_record_count:=l_record_count+l_oper_id_tab.count;
        l_oper_id_tab.delete;
    
        -- Mark processed event object
        evt_api_event_pkg.process_event_object(
            i_event_object_id_tab  => l_event_object_id_tab
        );
        
        l_event_object_id_tab.delete;
    end;
    
    begin

        trc_log_pkg.debug (
            i_text  => 'Upload domestict clearing start'
        );

        prc_api_stat_pkg.log_start;        
    
        -- estemate count records for upload
        select count(distinct e_obj.object_id)
          into l_estimated_count
          from evt_event_type e_type, evt_event_object e_obj
         where e_type.event_type in (cst_smt_api_const_pkg.DOMESTIC_ACQ_EVENT) 
           and e_type.ID = e_obj.event_id 
           and decode(e_obj.status,'EVST0001', e_obj.procedure_name,NULL) = l_proc_name 
           and e_obj.inst_id = nvl(i_inst_id, e_obj.inst_id);

        prc_api_stat_pkg.log_estimation (
            i_estimated_count  => l_estimated_count
        );
        
        trc_log_pkg.debug (
            i_text  => 'Estemated for upload:'||l_estimated_count
        );
        
        -- get event for upload
        
        open cur_objects;
        
        loop
            -- Select IDs of all event objects need to proceed
            fetch cur_objects
                bulk collect
                into l_fetched_event_object_id_tab
                   , l_fetched_oper_id_tab
               limit BULK_LIMIT;

            trc_log_pkg.debug('l_fetched_oper_id_tab.count  = ' || l_fetched_oper_id_tab.count);

            for i in 1 .. l_fetched_oper_id_tab.count loop
                -- All events for every single operation should be marked as processed
                l_event_object_id_tab.extend;
                l_event_object_id_tab(l_event_object_id_tab.count) := l_fetched_event_object_id_tab(i);

                -- Decrease operation count and remove the last operation id from previous iteration
                if l_fetched_oper_id_tab(i) != l_oper_id
                   or l_oper_id is null
                then
                    l_oper_id := l_fetched_oper_id_tab(i);

                    l_oper_id_tab.extend;
                    l_oper_id_tab(l_oper_id_tab.count) := l_oper_id;

                    if l_oper_id_tab.count >= l_bulk_limit then

                        if l_session_file_id is null then
                            register_session_file (
                                i_inst_id   => i_inst_id
                            );
                        end if;

                        -- Generate line to file for current portion of the "l_bulk_limit" records
                        generate_detail( );
                        
                       prc_api_stat_pkg.log_current (
                            i_current_count     => l_record_count
                            , i_excepted_count  => 0
                        );

                    end if;

                end if;

            end loop;

            trc_log_pkg.debug('events were processed, cnt = ' || l_fetched_event_object_id_tab.count);

            exit when cur_objects%notfound;

        end loop;
        
        if cur_objects%isopen then
            close cur_objects;
        end if;
        
        generate_detail;
        
        if l_session_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
            );
        end if;
       
        -- statistic summarize
        prc_api_stat_pkg.log_end(
            i_result_code        => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
            , i_processed_total  => l_record_count
        );

        trc_log_pkg.debug (
            i_text  => 'Upload domestict clearing end'
        );
        
    exception
        when others then
            if cur_objects%isopen then
                close cur_objects;
            end if;

            prc_api_stat_pkg.log_end (
                i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );

            if l_session_file_id is not null then
                prc_api_file_pkg.close_file (
                    i_sess_file_id  => l_session_file_id
                  , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
                );
            end if;

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
    
    procedure upload_international_clearing (
        i_inst_id                 in com_api_type_pkg.t_inst_id
    ) is
    l_estimated_count               com_api_type_pkg.t_long_id := 0;
    l_record_count                  com_api_type_pkg.t_long_id;
    l_proc_name                     com_api_type_pkg.t_name    := 'CST_SMT_PRC_CB_OUTGOING_PKG.UPLOAD_INTERNATIONAL_CLEARING';
    l_bulk_limit                    com_api_type_pkg.t_count  := 1000;
    l_session_file_id               com_api_type_pkg.t_long_id;
    l_fetched_event_object_id_tab   num_tab_tpt                     := num_tab_tpt();
    l_fetched_oper_id_tab           num_tab_tpt                     := num_tab_tpt();    
    l_oper_id_tab                   num_tab_tpt                     := num_tab_tpt();
    l_oper_id                       com_api_type_pkg.t_long_id;
    l_params                        com_api_type_pkg.t_param_tab;
    l_file_line_rec_num             com_api_type_pkg.t_long_id;
    l_line                          com_api_type_pkg.t_text;
    l_total_sttl_debit              com_api_type_pkg.t_money; 
    l_total_sttl_credit             com_api_type_pkg.t_money;
    l_brach_tag                     com_api_type_pkg.t_short_id;
    l_invoice_tag                   com_api_type_pkg.t_short_id;
    l_batch_id_tag                  com_api_type_pkg.t_short_id;
    l_arn_tag                       com_api_type_pkg.t_short_id;
    l_sysdate                       date    := sysdate;  
    
    -- header
    procedure put_header
    is 
    begin
        l_params.delete;
        rul_api_param_pkg.set_param (
            i_name       => 'INST_ID'
            , i_value    => to_char(i_inst_id)
            , io_params  => l_params
        );

        prc_api_file_pkg.open_file (
            o_sess_file_id  => l_session_file_id
            , i_file_type   => cst_smt_api_const_pkg.FILE_TYPE_CB_INTERNATIONAL_CL
            , io_params     => l_params
        );
        
        l_file_line_rec_num := 1;
        
        l_line := '01';              
        l_line := l_line || str_format(l_file_line_rec_num, 6, '0');               
        l_line := l_line || str_format('0', 2, '0');                        --Filler                 
        l_line := l_line || to_char(sysdate, 'DDMMYY');
        l_line := l_line || '222222';
        l_line := l_line || str_format(i_inst_id,5,'0');
        l_line := l_line || str_format(' ',415,' ');                        --Filler
        l_line := l_line || 'X';
 
        prc_api_file_pkg.put_line(
            i_raw_data      => l_line
          , i_sess_file_id  => l_session_file_id
        );        
        
    end;

    -- output batches
    procedure put_barchaes
    is 
    begin
 
        for rec in (
                select oper.merchant_number
                     , oper.batch_number
                     , oper.oper_code
                     , max(trim(oper.processing_date)) processing_date
                     , max(oper.merchant_rib) merchant_rib
                     , max(oper.merchant_name) merchant_name
                     , max(oper.merchant_address) merchant_address
                     , max(oper.territory_code) territory_code
                     , max(oper.merchant_type) merchant_type
                     , max(oper.branch_code) branch_code
                     , max(oper.batch_date) batch_date
                     , count(*) batch_oper_cnt
                     , sum(oper.oper_amount) oper_amount_sum
                     , sum(decode(oper.card_country
                                  , cst_smt_api_const_pkg.COUNTRY_CODE_TUNISIA, 0
                                  , oper.oper_amount
                           )
                       ) foreign_card_amount_sum
                     , max(oper.oper_currency) oper_currency
                     , sum(oper.merchant_comission) merchant_comission_sum
                     , sum(oper.tax_amount) tax_amount_sum
                     , sum(oper.interchange_fee) interchange_fee_sum 
                     , sum(oper.sttl_amount) sttl_amount_sum
                     , sum(decode(oper.card_country
                                  , cst_smt_api_const_pkg.COUNTRY_CODE_TUNISIA, oper.oper_amount
                                  , 0
                           )
                       ) local_card_amount_sum
                     , max(oper.device_type) device_type
                     , max(oper.batch_id) batch_id
                     , max(oper.acquirer_inst_id) acq_inast_id
                  from cst_smt_international_cl_tmp oper
                 where oper.batch_number is not null
                   and acquirer_inst_id = i_inst_id
                 group by oper.merchant_number 
                          , oper.batch_number
                          , oper.oper_code
                 order by oper.merchant_number 
                          , oper.batch_number        
            ) loop
            
                l_file_line_rec_num := l_file_line_rec_num+1;
                
                l_line := '10';              
                l_line := l_line || str_format(l_file_line_rec_num, 6, '0');
                l_line := l_line || str_format(rec.oper_code, 6, '0');
                l_line := l_line || to_char(rec.processing_date, 'DDMMYY');
                l_line := l_line || str_format(rec.merchant_number, 10,' ');
                l_line := l_line || str_format(rec.merchant_rib, 24,' ');
                l_line := l_line || str_format(rec.merchant_name, 25,' ');
                l_line := l_line || str_format(rec.merchant_address, 25,' ');
                l_line := l_line || str_format(' ', 12,' ');        --FILLER
                l_line := l_line || str_format(rec.territory_code, 1,' '); 
                l_line := l_line || str_format(rec.merchant_type, 1,' ');
                l_line := l_line || str_format(rec.branch_code, 5,' ');
                l_line := l_line || str_format(rec.batch_number, 6, '0', 1);
                l_line := l_line || to_char(rec.batch_date, 'DDMMYY');
                l_line := l_line || str_format(rec.batch_oper_cnt, 6, '0', 1);
                l_line := l_line || str_format(' ', 5,' ');        --FILLER
                l_line := l_line || str_format(rec.oper_amount_sum, 12, '0', 1);
                l_line := l_line || str_format(rec.foreign_card_amount_sum, 12, '0', 1);
                l_line := l_line || str_format(rec.oper_currency, 3, '0', 1);
                l_line := l_line || str_format(com_api_currency_pkg.get_currency_exponent(rec.oper_currency), 1, '0', 1);
                l_line := l_line || str_format(rec.merchant_comission_sum, 12, '0', 1);
                l_line := l_line || str_format(rec.tax_amount_sum, 12, '0', 1);
                l_line := l_line || str_format((rec.oper_amount_sum - rec.merchant_comission_sum - rec.tax_amount_sum), 12, '0', 1);
                l_line := l_line || str_format(rec.sttl_amount_sum, 12, '0', 1);
                l_line := l_line || str_format(rec.interchange_fee_sum, 12, '0', 1);
                l_line := l_line || str_format(0, 12, '0', 1);
                l_line := l_line || str_format(rec.local_card_amount_sum, 12, '0', 1);
                l_line := l_line || str_format(rec.device_type, 1, '0');
                l_line := l_line || str_format(' ', 5,' ');        --FILLER
                l_line := l_line || str_format(' ', 2,' ');        --FILLER
                l_line := l_line || str_format(rec.batch_id, 5,'0');
                l_line := l_line || str_format(' ', 10,' ');        --FILLER
                l_line := l_line || str_format(' ', 87,' ');        --FILLER
                l_line := l_line || str_format(com_api_flexible_data_pkg.get_flexible_value(
                                                i_field_name    => cst_smt_api_const_pkg.BANK_CTB    
                                                , i_entity_type => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                                                , i_object_id   => rec.acq_inast_id
                                                ), 2,' ');   
                l_line := l_line || str_format(rec.acq_inast_id, 5,' ');
                l_line := l_line || str_format(' ', 1,' ');        --FILLER
                l_line := l_line || str_format(' ', 58,' ');       --FILLER
                l_line := l_line || 'X';                

                prc_api_file_pkg.put_line(
                    i_raw_data      => l_line
                  , i_sess_file_id  => l_session_file_id
                );

            end loop;
        
    end;
        
    -- output details
    procedure put_details
    is 
    l_event_iss_id_tab          num_tab_tpt     := num_tab_tpt();
    l_event_acq_id_tab          num_tab_tpt     := num_tab_tpt();
    begin   
        l_record_count := 0;

        for rec in (select  oper.iss_event_id
                          , oper.acq_event_id  
                          , oper.oper_code
                          , trim(oper.processing_date) processing_date
                          , oper.merchant_number
                          , oper.merchant_rib
                          , oper.merchant_name
                          , oper.merchant_address
                          , oper.oper_channel
                          , oper.orinator_refnum
                          , oper.territory_code
                          , oper.pan
                          , com_api_flexible_data_pkg.get_flexible_value(
                                i_field_name    => cst_smt_api_const_pkg.CARD_RIB    
                                , i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARD
                                , i_object_id   => oper.pan
                            ) card_rib
                          , oper.card_expire_date
                          , oper.arn
                          , oper.batch_number
                          , oper.batch_date oper_date
                          , oper.invoice
                          , oper.auth_code
                          , oper.oper_amount
                          , decode(oper.card_country
                                , cst_smt_api_const_pkg.COUNTRY_CODE_TUNISIA,1
                                ,3
                            ) card_code_origin
                          , oper.oper_currency
                          , oper.sttl_amount
                          , oper.sttl_currency
                          , oper.interchange_fee
                          , oper.tax_on_interchange
                          , oper.merchant_comission
                          , oper.tax_on_merchant_comission
                          , com_api_array_pkg.is_element_in_array(
                                i_array_id      => opr_api_const_pkg.OPER_TYPE_CREDIT_ARRAY_ID 
                                 , i_elem_value => oper.oper_type
                            ) is_credit
                          , com_api_flexible_data_pkg.get_flexible_value(
                                i_field_name    => cst_smt_api_const_pkg.BANK_CTB    
                                , i_entity_type => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                                , i_object_id   => oper.issuer_inst_id
                            ) issuer_CTB                              
                          , oper.issuer_inst_id
                          , oper.issuer_agent_id
                          , com_api_flexible_data_pkg.get_flexible_value(
                                i_field_name    => cst_smt_api_const_pkg.BANK_CTB    
                                , i_entity_type => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                                , i_object_id   => oper.acquirer_inst_id
                            ) acquirer_CTB                              
                          , oper.acquirer_inst_id
                          , decode( oper.card_country
                                , cst_smt_api_const_pkg.COUNTRY_CODE_TUNISIA, oper.oper_amount
                                ,0
                            ) local_card_amount
                          , oper.mcc
                          , cst_smt_prc_cb_outgoing_pkg.get_convertation(
                              i_array_type_id       => cst_smt_api_const_pkg.CARD_TYPE_ARRAY_TYPE
                              , i_array_id          => cst_smt_api_const_pkg.CARD_TYPE_CONVERTER
                              , i_elem_value        => card_type_id
                              , i_retun_def_value   => cst_smt_api_const_pkg.DEFAULT_CARD_TYPE
                            ) card_sys
                          , cst_smt_prc_cb_outgoing_pkg.get_convertation(
                              i_array_type_id       => cst_smt_api_const_pkg.NETWORK_ARRAY_TYPE
                              , i_array_id          => cst_smt_api_const_pkg.NETWORK_CONVERTER
                              , i_elem_value        => card_network_id
                              , i_retun_def_value   => cst_smt_api_const_pkg.DEFAULT_NETWORK
                            )  card_network_id
                          , com_api_flexible_data_pkg.get_flexible_value(
                              i_field_name    => cst_smt_api_const_pkg.MERCHANT_ACTICITY_SECTOR    
                              , i_entity_type => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                              , i_object_id   => oper.merchant_id
                            ) merchant_sector                             
                      from cst_smt_international_cl_tmp oper
                     order by oper.acquirer_inst_id
                           , oper.merchant_number
                           , oper.batch_number
                           , oper.issuer_inst_id
        ) loop
            if rec.iss_event_id is not null then
                
                l_event_iss_id_tab.extend;
                l_event_iss_id_tab(l_event_iss_id_tab.count) := rec.iss_event_id;
                
            end if;

            if rec.acq_event_id is not null then
                
                l_event_acq_id_tab.extend;
                l_event_acq_id_tab(l_event_acq_id_tab.count) := rec.acq_event_id;
                
            end if;
            
            l_record_count := l_record_count+1;
            
            l_file_line_rec_num := l_file_line_rec_num+1;
                
            l_line := '20';
            l_line := l_line || str_format(l_file_line_rec_num, 6, '0');
            l_line := l_line || str_format(rec.oper_code, 2, '0');
            l_line := l_line || to_char(rec.processing_date, 'DDMMYY');
            l_line := l_line || str_format(rec.merchant_number, 10, '0');
            l_line := l_line || str_format(rec.merchant_rib, 24, '0');
            l_line := l_line || str_format(rec.merchant_name, 25, '0');
            l_line := l_line || str_format(rec.merchant_address, 25, '0');
            l_line := l_line || str_format(' ', 5,' ');       --FILLER
            l_line := l_line || str_format(' ', 2,' ');       --FILLER
            l_line := l_line || str_format(rec.oper_channel, 1, '0');
            l_line := l_line || str_format(rec.orinator_refnum, 12, '0');
            l_line := l_line || str_format(rec.territory_code, 1, '0');
            l_line := l_line || str_format(rec.pan, 19, ' ');
            l_line := l_line || str_format(rec.card_rib, 24, ' ');
            l_line := l_line || to_char(rec.card_expire_date, 'MMYY');
            l_line := l_line || str_format(' ', 2,' ');       --FILLER
            l_line := l_line || str_format(rec.arn, 23, ' ');
            l_line := l_line || str_format(rec.batch_number, 6, '0');
            l_line := l_line || to_char(rec.oper_date, 'DDMMYY');
            l_line := l_line || str_format(rec.invoice, 6, '0');
            l_line := l_line || to_char(rec.oper_date, 'DDMMYY');
            l_line := l_line || str_format(rec.auth_code, 6, ' ');
            l_line := l_line || str_format(rec.oper_amount, 12, '0', 1);
            l_line := l_line || str_format(rec.card_code_origin, 1, '3');
            l_line := l_line || str_format(' ', 6,' ');       --FILLER  
            l_line := l_line || str_format(rec.oper_amount, 12, '0', 1);
            l_line := l_line || str_format(rec.oper_currency, 3, '0');
            l_line := l_line || str_format(com_api_currency_pkg.get_currency_exponent(rec.oper_currency), 1, '0', 1);
            l_line := l_line || str_format(rec.sttl_amount, 12, '0', 1);
            l_line := l_line || str_format(rec.sttl_currency, 3, '0');
            l_line := l_line || str_format(com_api_currency_pkg.get_currency_exponent(rec.sttl_currency), 1, '0', 1);
            l_line := l_line || str_format(rec.interchange_fee, 12, '0', 1);
            l_line := l_line || str_format(rec.tax_on_interchange, 12, '0', 1);
            l_line := l_line || str_format((rec.interchange_fee - rec.tax_on_interchange), 12, '0', 1);
            l_line := l_line || str_format(case rec.is_credit 
                                                when com_api_const_pkg.TRUE then 0 
                                                else rec.oper_amount 
                                           end, 12, '0', 1);
            l_line := l_line || str_format((rec.oper_amount - rec.merchant_comission - rec.tax_on_merchant_comission), 12, '0', 1);
            l_line := l_line || str_format(rec.merchant_comission, 12, '0', 1);
            l_line := l_line || str_format(rec.tax_on_merchant_comission, 12, '0', 1);
            l_line := l_line || str_format(' ', 1,' ');       --FILLER
            l_line := l_line || str_format(rec.issuer_CTB, 3, ' ');
            l_line := l_line || str_format(rec.issuer_CTB, 2, ' ');
            l_line := l_line || str_format(rec.issuer_inst_id, 5, '0',1);
            l_line := l_line || str_format(rec.issuer_agent_id, 5, '0',1);
            l_line := l_line || str_format(rec.acquirer_CTB, 2, ' ');
            l_line := l_line || str_format(rec.acquirer_inst_id, 5, '0',1);
            l_line := l_line || '0';
            l_line := l_line || str_format(rec.local_card_amount, 12, '0',1);
            l_line := l_line || str_format(0, 12, '0',1);
            l_line := l_line || str_format(rec.interchange_fee, 12, '0',1);
            l_line := l_line || str_format(rec.card_code_origin, 1, ' ');
            l_line := l_line || str_format(rec.mcc, 4, '0',1);
            l_line := l_line || str_format(rec.oper_channel, 1, '0');
            l_line := l_line || str_format(rec.card_sys, 1, '0');
            l_line := l_line || str_format(rec.card_network_id, 1, '0');
            l_line := l_line || str_format(rec.merchant_sector, 1, '0');
            l_line := l_line || str_format(' ', 1,' ');       --FILLER
            l_line := l_line || str_format(rec.acquirer_CTB, 2, ' ');
            l_line := l_line || str_format(rec.acquirer_inst_id, 5, '0',1);            
            l_line := l_line || 'X';                

            prc_api_file_pkg.put_line(
                i_raw_data      => l_line
              , i_sess_file_id  => l_session_file_id
            );
            
            if rec.is_credit = com_api_const_pkg.TRUE then
                l_total_sttl_credit := l_total_sttl_credit + rec.oper_amount;
            else
                l_total_sttl_debit  := l_total_sttl_debit + rec.oper_amount;
            end if; 
            
            if l_event_iss_id_tab.count > l_bulk_limit then
                -- Mark processed event object
                evt_api_event_pkg.process_event_object(
                    i_event_object_id_tab  => l_event_iss_id_tab
                );

                evt_api_event_pkg.process_event_object(
                    i_event_object_id_tab  => l_event_acq_id_tab
                );                
                
                l_event_iss_id_tab.delete;
                l_event_acq_id_tab.delete;
                
                prc_api_stat_pkg.log_current (
                    i_current_count     => l_record_count
                    , i_excepted_count  => 0
                );                
            end if;
            
        end loop;
         
    end;
        
    -- trailer
    procedure put_trailer
    is 
    begin
        
        l_file_line_rec_num := l_file_line_rec_num+1;
        
        l_line := '99';              
        l_line := l_line || str_format(l_file_line_rec_num, 6, '0');               
        l_line := l_line || str_format('0', 2, '0');                        --Filler                 
        l_line := l_line || to_char(sysdate, 'DDMMYY');
        l_line := l_line || str_format(i_inst_id,5,'0');
        l_line := l_line || str_format(l_file_line_rec_num,6,'0');
        l_line := l_line || str_format(l_total_sttl_debit,12,'0');
        l_line := l_line || str_format(l_total_sttl_credit,12,'0');
        l_line := l_line || str_format(i_inst_id,5,'0');
        l_line := l_line || str_format(' ',515,' ');                        --Filler
        l_line := l_line || str_format(com_api_flexible_data_pkg.get_flexible_value(
                                        i_field_name    => cst_smt_api_const_pkg.BANK_CTB    
                                        , i_entity_type => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                                        , i_object_id   => i_inst_id
                                        ), 2, '0');
        l_line := l_line || str_format(i_inst_id,5,'0');
        l_line := l_line || str_format(' ',66,' ');                        --Filler
        l_line := l_line || 'X';
        
        prc_api_file_pkg.put_line(
            i_raw_data      => l_line
          , i_sess_file_id  => l_session_file_id
        ); 
    end;
    
    begin

        trc_log_pkg.debug (
            i_text  => 'Upload international clearing start'
        );

        prc_api_stat_pkg.log_start;        
    
        -- estemate count records for upload
        select count(distinct e_obj.object_id)
          into l_estimated_count
          from evt_event_type e_type, evt_event_object e_obj
         where e_type.event_type = cst_smt_api_const_pkg.INTERNATIONAL_ACQ_EVENT 
           and e_type.ID = e_obj.event_id 
           and decode(e_obj.status,'EVST0001', e_obj.procedure_name,NULL) = l_proc_name 
           and e_obj.inst_id = nvl(i_inst_id, e_obj.inst_id);

        prc_api_stat_pkg.log_estimation (
            i_estimated_count  => l_estimated_count
        );
        
        trc_log_pkg.debug (
            i_text  => 'Estemated for upload:'||l_estimated_count
        );
        
        -- get objects for upload in batch and detail sections
        l_brach_tag     := aup_api_tag_pkg.find_tag_by_reference(cst_smt_api_const_pkg.TAG_BATCH_NUMBER);    
        l_invoice_tag   := aup_api_tag_pkg.find_tag_by_reference(cst_smt_api_const_pkg.TAG_INVOCE);
        l_batch_id_tag  := aup_api_tag_pkg.find_tag_by_reference(cst_smt_api_const_pkg.TAG_BATCH_ID);
        l_arn_tag       := aup_api_tag_pkg.find_tag_by_reference(cst_smt_api_const_pkg.TAG_ARN);

        insert into cst_smt_international_cl_tmp
        select  oper_event.oper_id
                , oper_event.iss_event_id
                , oper_event.acq_event_id
                , cst_smt_prc_cb_outgoing_pkg.get_tran_code(
                    i_oper_type                 => oo.oper_type
                    , i_invoice                 => tag_i.tag_value
                    , i_is_domestic_file_type   => com_api_const_pkg.FALSE
                  ) oper_code
                , oo.merchant_number  
                , l_sysdate           
                , com_api_flexible_data_pkg.get_flexible_value(
                    i_field_name    => cst_smt_api_const_pkg.MERCHANT_RIB    
                    , i_entity_type => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                    , i_object_id   => i_inst_id
                  ) 
                , oo.merchant_name    
                , oo.merchant_street  
                , case oo.merchant_country
                    when cst_smt_api_const_pkg.COUNTRY_CODE_TUNISIA then 0
                    else 1
                  end 
                , cst_smt_prc_cb_outgoing_pkg.get_merchant_type(
                    i_terminal_type     => term.terminal_type
                    , i_oper_type       => oo.oper_type
                    , i_merchant_param  => com_api_flexible_data_pkg.get_flexible_value(
                                               i_field_name    => cst_smt_api_const_pkg.MERCHANT_ACTICITY_SECTOR    
                                               , i_entity_type => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                                               , i_object_id   => acq_part.merchant_id
                                           ) 
                  )     
                , contract.agent_id        
                , tag_b.tag_value          
                , oo.oper_date             
                , oo.oper_amount           
                , iss_part.card_country    
                , oo.oper_currency      
                , oo.sttl_amount
                , amounts.AMPR5001
                , amounts.AMPR5002         
                , null
                , cst_smt_prc_cb_outgoing_pkg.get_device_type(
                    i_terminal_type     => term.terminal_type
                  )
                , iss_part.inst_id         
                , acq_part.inst_id
                , tag_bi.tag_value
                , cst_smt_prc_cb_outgoing_pkg.get_tran_channal(
                    i_terminal_type => term.terminal_type
                  )
                , substr(oo.originator_refnum,12)
                , oc.card_number
                , iss_part.card_expir_date
                , tag_arn.tag_value
                , iss_part.auth_code 
                , tag_i.tag_value
                , oo.sttl_currency
                , amounts.AMPR5004
                , amounts.AMPR5005
                , amounts.AMPR5006
                , oo.oper_type
                , card_ins.agent_id
                , oo.mcc
                , iss_part.card_type_id
                , iss_part.card_network_id
                , acq_part.merchant_id
            from                
                (select e_obj.object_id oper_id
                        , null iss_event_id
                        , max(decode(e_type.event_type
                                     ,cst_smt_api_const_pkg.INTERNATIONAL_ACQ_EVENT, e_obj.id
                                     ,null
                              )
                          ) acq_event_id               
                   from evt_event_type e_type
                        , evt_event_object e_obj
                  where e_type.event_type in (
                                        cst_smt_api_const_pkg.INTERNATIONAL_ACQ_EVENT
                                        ) 
                    and e_type.ID = e_obj.event_id 
                    and decode(e_obj.status
                            , 'EVST0001', e_obj.procedure_name
                            , NULL
                        ) = l_proc_name 
                    and e_obj.inst_id = nvl(i_inst_id, e_obj.inst_id)
                  order by e_obj.object_id
                )                   oper_event
               , opr_operation      oo
               , opr_card           oc
               , aup_tag_value      tag_b
               , aup_tag_value      tag_i
               , aup_tag_value      tag_bi
               , aup_tag_value      tag_arn
               , opr_participant    acq_part
               , opr_participant    iss_part
               , acq_terminal       term
               , acq_merchant       merchant
               , prd_contract       contract
               , (select * from (
                      select * from opr_additional_amount 
                    )pivot(
                        sum(amount)
                        for amount_type in ( 'AMPR5001' as AMPR5001 
                                            ,'AMPR5002' as AMPR5002
                                            ,'AMPR5004' as AMPR5004
                                            ,'AMPR5005' as AMPR5005
                                            ,'AMPR5006' as AMPR5006
                                            )
                    )
                 ) amounts
               , iss_card_number    card
               , iss_card_instance  card_ins
          where oo.id = oper_event.oper_id
            and oo.id = oc.oper_id
            and oc.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
            and oo.id = tag_b.auth_id
            and tag_b.tag_id = l_brach_tag
            and oo.id = tag_i.auth_id(+)
            and tag_i.tag_id(+) = l_invoice_tag
            and oo.id = tag_bi.auth_id(+)
            and tag_bi.tag_id(+) = l_batch_id_tag
            and oo.id = tag_arn.auth_id(+)
            and tag_arn.tag_id(+) = l_arn_tag
            and acq_part.oper_id = oo.id
            and acq_part.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
            and iss_part.oper_id = oo.id
            and iss_part.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
            and term.id = acq_part.terminal_id
            and merchant.id = acq_part.merchant_id
            and merchant.contract_id = contract.id  
            and amounts.oper_id = oo.id
            and i_inst_id in (iss_part.inst_id, acq_part.inst_id)
            and card.card_number(+) = oc.card_number
            and card_ins.id(+) = card.card_id;

        put_header;        

        ----
        put_barchaes;
        
        ----
        put_details;
        
        ----
        put_trailer;
        
        if l_session_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_session_file_id
                , i_status      => prc_api_const_pkg.FILE_STATUS_ACCEPTED
            );
        end if;
       
        -- statistic summarize
        prc_api_stat_pkg.log_end(
            i_result_code        => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
            , i_processed_total  => l_record_count
        );

        trc_log_pkg.debug (
            i_text  => 'Upload international clearing end'
        );
        
    exception
        when others then

            prc_api_stat_pkg.log_end (
                i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );

            if l_session_file_id is not null then
                prc_api_file_pkg.close_file (
                    i_sess_file_id  => l_session_file_id
                    , i_status      => prc_api_const_pkg.FILE_STATUS_REJECTED
                );
            end if;

            if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
                raise;
            elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_fatal_error(
                    i_error         => 'UNHANDLED_EXCEPTION'
                    , i_env_param1  => sqlerrm
                );
            end if;

            raise;            
    end;

    procedure upload_settlement (
        i_sttl_date        in date := null
    ) is
    l_estimated_count         com_api_type_pkg.t_long_id := 0;
    l_record_count            com_api_type_pkg.t_long_id;
    l_session_file_id         com_api_type_pkg.t_long_id;
    l_line                    com_api_type_pkg.t_text;
    l_params                  com_api_type_pkg.t_param_tab;
    begin
    
        trc_log_pkg.debug (
            i_text  => 'Upload settlement start'
        );

        prc_api_stat_pkg.log_start;        
    
        -- estemate count records for upload
        select count(*)
          into l_estimated_count 
          from ost_institution 
         where inst_type = cst_smt_api_const_pkg.INSTITUTE_PROCESSING_TYPE;

        prc_api_stat_pkg.log_estimation (
            i_estimated_count  => l_estimated_count
        );
        
        trc_log_pkg.debug (
            i_text  => 'Estemated for upload:'||l_estimated_count
        );
        
        l_record_count := 1;       
        
        prc_api_file_pkg.open_file (
            o_sess_file_id  => l_session_file_id
            , i_file_type   => cst_smt_api_const_pkg.FILE_TYPE_CB_SETTLEMENT
            , io_params     => l_params
        ); 
        
        for rec in (
            select inst.id bank_id 
                   , count(
                            decode(
                                   nvl(ent.balance_impact,0)
                                   , -1, 1
                                   , null
                            )
                     ) cnt_debit  
                   , sum(
                         decode(
                                nvl(ent.balance_impact,0)
                                , -1, nvl(ent.amount,0)
                                , 0
                         )
                     ) sum_debit
                   , count(
                            decode(
                                   nvl(ent.balance_impact,0)
                                   , 1, 1
                                   , null
                            )
                     ) cnt_credit  
                   , sum(
                         decode(
                                nvl(ent.balance_impact,0)
                                , 1, nvl(ent.amount,0)
                                , 0
                         )
                     ) sum_credit 
                   , ent.sttl_date      
              from ost_institution inst
                 , acc_account acct
                 , ACC_ENTRY ent
             where inst.inst_type = cst_smt_api_const_pkg.INSTITUTE_PROCESSING_TYPE
               and inst.id = acct.inst_id(+)
               and acct.account_type(+) = cst_smt_api_const_pkg.INSTITUTE_PROCESSING_TYPE
               and ent.account_id(+) = acct.id
               and nvl(ent.sttl_date, i_sttl_date) = i_sttl_date
             group by inst.id
                      , ent.sttl_date
         )
         loop

            l_line := '94';                                 -- constant              
            l_line := l_line || substr(rec.bank_id, -2);               
            l_line := l_line || lpad('0',6,'0');            -- filler                 
            l_line := l_line || str_format(rec.sum_debit, 13, '0');
            l_line := l_line || lpad('0',4,'0');            -- filler
            l_line := l_line || str_format(rec.sum_credit, 13, '0');
            l_line := l_line || str_format(rec.cnt_debit, 6, '0');
            l_line := l_line || str_format(rec.cnt_credit, 6, '0');
            l_line := l_line || str_format(
                                    abs(rec.sum_debit - rec.sum_credit)
                                    , 13, '0'
                                );
            if rec.sum_credit > rec.sum_debit then
                    l_line := l_line || '-';
                else
                    l_line := l_line || '+';
            end if;
            l_line := l_line || lpad('0',52,'0');            -- filler
            l_line := l_line || to_char(rec.sttl_date, 'YYYYMMDD'); 
            l_line := l_line || str_format(l_record_count, 2,'0');                       
            
            l_record_count := l_record_count + 1;
            
            prc_api_file_pkg.put_line(
                i_raw_data      => l_line
              , i_sess_file_id  => l_session_file_id
            );  
            
         end loop;
        
        if l_session_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
            );
        end if;
       
        -- statistic summarize
        prc_api_stat_pkg.log_end(
            i_result_code        => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
            , i_processed_total  => l_record_count
        );

        trc_log_pkg.debug (
            i_text  => 'Upload settlement end'
        );
        
    exception
        when others then

            prc_api_stat_pkg.log_end (
                i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );

            if l_session_file_id is not null then
                prc_api_file_pkg.close_file (
                    i_sess_file_id  => l_session_file_id
                  , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
                );
            end if;

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
