create or replace package body pmo_prc_export_pkg as
/********************************************************* 
 *  Process for payment orders export to XML file <br /> 
 *  Created by Fomichev A.(fomichev@bpcbt.com)  at 31.10.2011 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: pmo_prc_export_pkg  <br /> 
 *  @headcom 
 **********************************************************/ 

CRLF                     constant com_api_type_pkg.t_name     := chr(13) || chr(10);

procedure process(
    i_inst_id                 in     com_api_type_pkg.t_inst_id    default null
  , i_purpose_id              in     com_api_type_pkg.t_short_id   default null
  , i_host_id                 in     com_api_type_pkg.t_tiny_id    default null
  , i_unload_file             in     com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , i_create_operation        in     com_api_type_pkg.t_boolean    default null
  , i_pmo_status_change_mode  in     com_api_type_pkg.t_dict_value default null
  , i_service_provider_id     in     com_api_type_pkg.t_short_id   default null
) is

    l_sysdate       date;
    l_split_hash    com_api_type_pkg.t_tiny_id;

    cursor cu_order is
        select o.id
             , o.split_hash
             , o.customer_id
             , c.customer_number
             , o.amount
             , o.currency
             , o.inst_id
             , o.event_date
             , o.entity_type
             , o.object_id
             , o.purpose_id
             , o.expiration_date
             , count(1) over() cnt
          from pmo_order o
             , prd_customer c
             , pmo_purpose p
         where (o.inst_id     = i_inst_id or i_inst_id is null or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
           and (o.purpose_id  = i_purpose_id or i_purpose_id is null)
           and decode(o.status, 'POSA0001', o.status, null) = pmo_api_const_pkg.PMO_STATUS_AWAITINGPROC
           and o.customer_id  = c.id
           and o.amount > 0
           and o.event_date  <= l_sysdate
           and p.id           = o.purpose_id
           and (p.provider_id = i_service_provider_id or i_service_provider_id is null)
         order by o.id;

    l_order_id_tab              com_api_type_pkg.t_number_tab;
    l_split_hash_tab            com_api_type_pkg.t_number_tab;
    l_customer_id_tab           com_api_type_pkg.t_number_tab;
    l_customer_number_tab       com_api_type_pkg.t_varchar2_tab;
    l_amount_tab                com_api_type_pkg.t_money_tab;
    l_currency_tab              com_api_type_pkg.t_curr_code_tab;
    l_inst_id_tab               com_api_type_pkg.t_number_tab;
    l_event_date_tab            com_api_type_pkg.t_date_tab;
    l_entity_type_tab           com_api_type_pkg.t_dict_tab;
    l_object_id_tab             com_api_type_pkg.t_number_tab;
    l_purpose_id_tab            com_api_type_pkg.t_number_tab;
    l_expiration_date_tab       com_api_type_pkg.t_date_tab;
    l_count_tab                 com_api_type_pkg.t_number_tab;

    l_host_member_id            com_api_type_pkg.t_tiny_id;
    l_execution_type            com_api_type_pkg.t_dict_value;
    l_host_next                 com_api_type_pkg.t_boolean;
    l_responce_code             com_api_type_pkg.t_dict_value;
    l_terminal_id               com_api_type_pkg.t_short_id;
    l_merchant_id               com_api_type_pkg.t_short_id;
    l_card_id                   com_api_type_pkg.t_medium_id;
    l_session_file_id           com_api_type_pkg.t_long_id;
    l_file                      clob;
    l_is_created_file           com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
    l_estimated_count           com_api_type_pkg.t_long_id := null;
    l_excepted_count            com_api_type_pkg.t_long_id := 0;
    l_processed_count           com_api_type_pkg.t_long_id := 0;

    l_merchant_number           com_api_type_pkg.t_merchant_number;
    l_terminal_number           com_api_type_pkg.t_merchant_number;
    l_acq_inst_id               com_api_type_pkg.t_inst_id;
    l_mcc                       com_api_type_pkg.t_mcc;
    l_customer_id               com_api_type_pkg.t_medium_id;
    l_card_number               com_api_type_pkg.t_card_number;
    l_account_number            com_api_type_pkg.t_account_number;
    l_client_id_type            com_api_type_pkg.t_dict_value;
    l_client_id_value           com_api_type_pkg.t_name;
    l_purpose_id                com_api_type_pkg.t_short_id;
    l_payment_param_id_tab      com_api_type_pkg.t_number_tab;
    l_payment_param_val_tab     com_api_type_pkg.t_varchar2_tab;
    l_oper_type                 com_api_type_pkg.t_dict_value;
    l_dst_customer_id           com_api_type_pkg.t_medium_id;
    l_dst_card_number           com_api_type_pkg.t_card_number;
    l_dst_account_number        com_api_type_pkg.t_account_number;
    l_dst_client_id_type        com_api_type_pkg.t_dict_value;
    l_dst_client_id_value       com_api_type_pkg.t_name;
    l_oper_amount               com_api_type_pkg.t_money;
    l_oper_request_amount       com_api_type_pkg.t_money;
    l_oper_currency             com_api_type_pkg.t_curr_code;
    l_oper_surcharge_amount     com_api_type_pkg.t_money;
    l_oper_amount_algorithm     com_api_type_pkg.t_dict_value;
    l_oper_id                   com_api_type_pkg.t_long_id;
    l_oper_date                 date;
    l_cardseqnumber             com_api_type_pkg.t_tiny_id;
    l_cardexpirdate             date;
    l_dstaccounttype            com_api_type_pkg.t_dict_value;
    l_oper_reason               com_api_type_pkg.t_dict_value;
    l_resp_code                 com_api_type_pkg.t_dict_value;
    l_xml_block                 clob;
    l_file_number               com_api_type_pkg.t_long_id := 0;
    l_param_tab                 com_api_type_pkg.t_param_tab;
    l_oper_count                com_api_type_pkg.t_short_id;
    l_is_date_expired           com_api_type_pkg.t_boolean;
    l_pmo_status_change_mode    com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug('pmo_prc_export_pkg.process - started, pmo_status_change_mode=' || i_pmo_status_change_mode);
    
    l_sysdate := com_api_sttl_day_pkg.get_sysdate;

    prc_api_stat_pkg.log_start;

    if i_unload_file = com_api_type_pkg.TRUE then
        select count(1) + 1
          into l_file_number
          from prc_session_file f
             , prc_file_attribute a
         where a.container_id = prc_api_session_pkg.get_container_id
           and f.file_attr_id = a.id
           and f.id between com_api_id_pkg.get_from_id(prc_api_session_pkg.get_session_id) and com_api_id_pkg.get_till_id(prc_api_session_pkg.get_session_id);

        -- Create temporary LOB
        dbms_lob.createtemporary(lob_loc => l_file,
                                 cache   => true,
                                 dur     => dbms_lob.session);

        if dbms_lob.isopen(l_file) = 0 then
          dbms_lob.open(l_file, dbms_lob.lob_readwrite);
        end if;

        l_xml_block := com_api_const_pkg.XML_HEADER || CRLF
                       || '<payment_orders>'
                       || '<inst_id>'     || to_char(i_inst_id,     com_api_const_pkg.XML_NUMBER_FORMAT) || '</inst_id>'
                       || '<file_date>'   || to_char(l_sysdate,     com_api_const_pkg.XML_DATE_FORMAT)   || '</file_date>'
                       || '<file_number>' || to_char(l_file_number, com_api_const_pkg.XML_NUMBER_FORMAT) || '</file_number>';

        if l_xml_block is not null then
            dbms_lob.writeappend(l_file, dbms_lob.getlength(l_xml_block), l_xml_block);
        end if;
    end if;

    open cu_order;

    loop
        fetch cu_order bulk collect into
            l_order_id_tab
          , l_split_hash_tab
          , l_customer_id_tab
          , l_customer_number_tab
          , l_amount_tab
          , l_currency_tab
          , l_inst_id_tab
          , l_event_date_tab
          , l_entity_type_tab
          , l_object_id_tab
          , l_purpose_id_tab
          , l_expiration_date_tab
          , l_count_tab
        limit 100;
        
        if l_estimated_count is null then

            if l_count_tab.exists(1) then
                l_estimated_count := l_count_tab(1);
            else
                l_estimated_count := 0;
            end if;

            prc_api_stat_pkg.log_estimation (
                i_estimated_count  => l_estimated_count
            );

        end if;

        for i in 1..l_order_id_tab.count loop
            savepoint process_order;
            
            begin
                l_oper_id := null;
                l_terminal_id    := null;
                l_merchant_id    := null;
                l_card_id        := null;
                l_account_number := null;

                l_is_date_expired :=
                    pmo_api_order_pkg.check_is_pmo_expired(
                        i_expiration_date   => l_expiration_date_tab(i)
                      , i_order_id          => l_order_id_tab(i)
                      , i_entity_type       => l_entity_type_tab(i)
                      , i_object_id         => l_object_id_tab(i)
                      , i_inst_id           => l_inst_id_tab(i)
                      , i_split_hash        => l_split_hash_tab(i)
                      , i_param_tab         => l_param_tab
                    );

                if l_is_date_expired = com_api_const_pkg.TRUE then
                    continue;
                end if;

                pmo_api_order_pkg.choose_host(
                    i_purpose_id        => l_purpose_id_tab(i)
                  , o_host_member_id    => l_host_member_id
                  , io_execution_type   => l_execution_type
                  , o_host_next         => l_host_next 
                  , o_response_code     => l_responce_code
                  , i_choose_host_mode  => pmo_api_const_pkg.CHOOSE_HOST_MODE_ALG
                );

                if     l_execution_type = pmo_api_const_pkg.PAYMENT_ORD_EXC_TYPE_OFFLN
                   and l_host_member_id = nvl(i_host_id, l_host_member_id)
                then

                    l_resp_code :=
                        pmo_api_search_pkg.get_payment_params(
                            i_payment_order_id      => l_order_id_tab(i)
                          , o_merchant_number       => l_merchant_number
                          , o_terminal_number       => l_terminal_number
                          , o_acq_inst_id           => l_acq_inst_id
                          , o_mcc                   => l_mcc
                          , o_customer_id           => l_customer_id
                          , o_card_number           => l_card_number
                          , o_account_number        => l_account_number
                          , o_client_id_type        => l_client_id_type
                          , o_client_id_value       => l_client_id_value
                          , o_purpose_id            => l_purpose_id
                          , o_payment_param_id_tab  => l_payment_param_id_tab
                          , o_payment_param_val_tab => l_payment_param_val_tab
                          , o_oper_type             => l_oper_type
                          , o_dst_customer_id       => l_dst_customer_id
                          , o_dst_card_number       => l_dst_card_number
                          , o_dst_account_number    => l_dst_account_number
                          , o_dst_client_id_type    => l_dst_client_id_type
                          , o_dst_client_id_value   => l_dst_client_id_value
                          , o_oper_amount           => l_oper_amount
                          , o_oper_request_amount   => l_oper_request_amount
                          , o_oper_currency         => l_oper_currency
                          , o_oper_surcharge_amount => l_oper_surcharge_amount
                          , o_oper_amount_algorithm => l_oper_amount_algorithm
                          , o_oper_id               => l_oper_id
                          , o_oper_date             => l_oper_date
                          , o_cardseqnumber         => l_cardseqnumber
                          , o_cardexpirdate         => l_cardexpirdate
                          , o_dstaccounttype        => l_dstaccounttype
                          , o_oper_reason           => l_oper_reason
                          , o_split_hash            => l_split_hash
                          , i_need_payment_params   => com_api_const_pkg.FALSE
                        );

                    if l_resp_code != aup_api_const_pkg.RESP_CODE_ERROR then
                        if nvl(i_create_operation, com_api_type_pkg.TRUE) = com_api_type_pkg.TRUE then
                                
                            l_oper_id := com_api_id_pkg.get_id(opr_operation_seq.nextval, com_api_sttl_day_pkg.get_sysdate); 
                                
                            if l_account_number is not null or l_customer_id is not null then
                                opr_api_create_pkg.add_participant(
                                    i_oper_id               => l_oper_id
                                  , i_msg_type              => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
                                  , i_oper_type             => l_oper_type
                                  , i_oper_reason           => l_oper_reason
                                  , i_participant_type      => com_api_const_pkg.PARTICIPANT_ISSUER
                                  , i_host_date             => l_sysdate
                                  , i_client_id_type        => l_client_id_type
                                  , i_client_id_value       => l_client_id_value
                                  , i_inst_id               => l_inst_id_tab(i)
                                  , i_card_id               => l_card_id
                                  , i_card_number           => l_card_number
                                  , i_customer_id           => l_customer_id
                                  , i_account_number        => l_account_number
                                  , i_without_checks        => com_api_const_pkg.FALSE
                                  , i_payment_order_id      => l_order_id_tab(i)
                                  , i_acq_inst_id           => l_acq_inst_id
                                  , i_split_hash            => l_split_hash_tab(i)
                                );
                            end if;

                            if l_terminal_number is not null then
                                opr_api_create_pkg.add_participant(
                                    i_oper_id               => l_oper_id
                                  , i_msg_type              => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
                                  , i_oper_type             => l_oper_type
                                  , i_oper_reason           => l_oper_reason
                                  , i_participant_type      => com_api_const_pkg.PARTICIPANT_ACQUIRER
                                  , i_host_date             => l_sysdate
                                  , i_client_id_type        => l_client_id_type
                                  , i_client_id_value       => l_client_id_value
                                  , i_inst_id               => l_inst_id_tab(i)
                                  , i_card_id               => l_card_id
                                  , i_card_number           => l_card_number
                                  , i_customer_id           => l_customer_id
                                  , i_account_number        => l_account_number
                                  , i_merchant_number       => l_merchant_number
                                  , i_terminal_number       => l_terminal_number
                                  , i_without_checks        => com_api_const_pkg.FALSE
                                  , i_payment_order_id      => l_order_id_tab(i)
                                  , i_acq_inst_id           => l_acq_inst_id
                                  , i_split_hash            => l_split_hash_tab(i)
                                );
                            end if;

                            if l_dst_account_number is not null or l_dst_customer_id is not null then
                                opr_api_create_pkg.add_participant(
                                    i_oper_id               => l_oper_id
                                  , i_msg_type              => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
                                  , i_oper_type             => l_oper_type
                                  , i_oper_reason           => l_oper_reason
                                  , i_participant_type      => com_api_const_pkg.PARTICIPANT_DEST
                                  , i_host_date             => l_sysdate
                                  , i_client_id_type        => l_dst_client_id_type
                                  , i_client_id_value       => l_dst_client_id_value
                                  , i_inst_id               => l_inst_id_tab(i)
                                  , i_card_id               => l_card_id
                                  , i_card_number           => l_dst_card_number
                                  , i_customer_id           => l_dst_customer_id
                                  , i_account_number        => l_dst_account_number
                                  , i_merchant_number       => l_merchant_number
                                  , i_terminal_number       => l_terminal_number
                                  , i_without_checks        => com_api_const_pkg.FALSE
                                  , i_payment_order_id      => l_order_id_tab(i)
                                  , i_acq_inst_id           => l_acq_inst_id
                                  , i_split_hash            => l_split_hash_tab(i)
                                );
                            end if;

                            select count(*)
                              into l_oper_count
                              from opr_participant
                             where oper_id = l_oper_id;
                                
                            if l_oper_count > 0 then
                                opr_api_create_pkg.create_operation(
                                    io_oper_id          => l_oper_id
                                  , i_status            => opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
                                  , i_sttl_type         => opr_api_const_pkg.SETTLEMENT_INTERNAL
                                  , i_msg_type          => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
                                  , i_oper_type         => l_oper_type
                                  , i_oper_reason       => l_oper_reason
                                  , i_oper_amount       => l_amount_tab(i)
                                  , i_oper_currency     => l_currency_tab(i)
                                  , i_is_reversal       => com_api_const_pkg.FALSE
                                  , i_oper_date         => l_event_date_tab(i)
                                  , i_host_date         => l_sysdate
                                  , i_payment_order_id  => l_order_id_tab(i)
                                );
                            else
                                com_api_error_pkg.raise_error(
                                    i_error             => 'PARTICIPANT_NOT_EXIST'
                                  , i_env_param1        => l_oper_id
                                  , i_entity_type       => pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER
                                  , i_object_id         => l_order_id_tab(i)
                                );
                            end if;
                        end if;

                        if i_unload_file = com_api_type_pkg.TRUE then
                            select xmlelement("payment_order"
                                     , xmlelement("order_id",        to_char(l_order_id_tab(i),   com_api_const_pkg.XML_NUMBER_FORMAT)) 
                                     , xmlelement("customer_number", l_customer_number_tab(i))
                                     , xmlelement("amount",          to_char(l_amount_tab(i),     com_api_const_pkg.XML_NUMBER_FORMAT))
                                     , xmlelement("currency",        l_currency_tab(i))
                                     , xmlelement("order_date",      to_char(l_event_date_tab(i), com_api_const_pkg.XML_DATETIME_FORMAT))
                                     , xmlagg(
                                           xmlelement("parameter"
                                             , xmlelement("param_name", p.param_name)
                                             , xmlelement(
                                                   "param_value"
                                                 , decode(
                                                       p.param_name
                                                     , 'CARD_NUMBER'
                                                     , iss_api_token_pkg.decode_card_number(
                                                           i_card_number =>
                                                               iss_api_card_pkg.get_card_number(
                                                                   i_card_id => to_number(d.param_value, com_api_const_pkg.NUMBER_FORMAT)
                                                               )
                                                       )
                                                     , 'INVOICE_MAD'
                                                     , to_char(to_number(d.param_value, com_api_const_pkg.NUMBER_FORMAT), com_api_const_pkg.XML_NUMBER_FORMAT)
                                                     , 'INVOICE_DUE_DATE'
                                                     , to_char(to_date(d.param_value, com_api_const_pkg.DATE_FORMAT),     com_api_const_pkg.XML_DATETIME_FORMAT)
                                                     , d.param_value
                                                   )
                                               )
                                           )
                                       )
                                     , xmlelement("purpose_id",      to_char(l_purpose_id_tab(i), com_api_const_pkg.XML_NUMBER_FORMAT))
                                   ).getclobval()
                              into l_xml_block
                              from pmo_order_data d
                                 , pmo_parameter p
                             where d.order_id = l_order_id_tab(i)
                               and d.param_id = p.id
                               and d.param_value is not null;

                            if l_xml_block is not null then
                                dbms_lob.writeappend(l_file, dbms_lob.getlength(l_xml_block), l_xml_block);
                                l_is_created_file := com_api_const_pkg.TRUE;
                            end if;
                        end if;

                        trc_log_pkg.debug('processed order ' || l_order_id_tab(i) || ', created operation ' || l_oper_id);

                        l_pmo_status_change_mode := nvl(i_pmo_status_change_mode, pmo_api_const_pkg.PMO_SCM_MARK_ORDER_PROCESSED);

                        if l_pmo_status_change_mode = pmo_api_const_pkg.PMO_SCM_MARK_ORDER_PROCESSED then
                            update pmo_order
                              set status = pmo_api_const_pkg.PMO_STATUS_PROCESSED
                            where id     = l_order_id_tab(i);
                        else
                            trc_log_pkg.debug(
                                i_text          => 'Status of the payment order [#1] is not changed for pmo_status_change_mode [#2]'
                              , i_env_param1    => l_order_id_tab(i)
                              , i_env_param2    => l_pmo_status_change_mode
                            );
                        end if;

                    else
                        trc_log_pkg.error(
                            i_text          => 'Error in get_payment_params_by_order_id. Order_id = ' || l_order_id_tab(i)
                        );
                        l_excepted_count := l_excepted_count + 1;

                    end if;
                else
                    l_excepted_count := l_excepted_count + 1;
                end if;

            exception
                when others then
                    rollback to savepoint process_order;
                        
                    trc_log_pkg.error(
                        i_text          => 'Error processing order: [#1]'
                      , i_env_param1    => l_order_id_tab(i)
                    );

                    if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE then
                        l_excepted_count := l_excepted_count + 1;
                    else
                        raise;
                    end if;
            end;
        end loop;
        l_processed_count := l_processed_count + l_order_id_tab.count;

        prc_api_stat_pkg.log_current(
            i_current_count  => l_processed_count
          , i_excepted_count => l_excepted_count
        );

        exit when cu_order%notfound;

    end loop;

    close cu_order;

    if i_unload_file = com_api_type_pkg.TRUE and l_is_created_file = com_api_const_pkg.TRUE then

        rul_api_param_pkg.set_param (
            i_name     => 'FILE_NUMBER'
          , i_value    => l_file_number
          , io_params  => l_param_tab
        );

        prc_api_file_pkg.open_file(
            o_sess_file_id  => l_session_file_id
          , i_file_purpose  => prc_api_const_pkg.FILE_PURPOSE_OUT
          , io_params       => l_param_tab
        );

        l_xml_block := '</payment_orders>';

        if l_xml_block is not null then
            dbms_lob.writeappend(l_file, dbms_lob.getlength(l_xml_block), l_xml_block);
        end if;

        prc_api_file_pkg.put_file(
            i_sess_file_id  => l_session_file_id
          , i_clob_content  => l_file
          , i_add_to        => com_api_const_pkg.FALSE
        );

        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );

        if dbms_lob.isopen(l_file) = 1 then
          dbms_lob.close(l_file);
        end if;
          
        dbms_lob.freetemporary(lob_loc => l_file);
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code  => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug('pmo_prc_export_pkg.process - end.');

exception
    when others then
        rollback;
            
        if cu_order%isopen then
            close cu_order;
        end if;
            
        prc_api_stat_pkg.log_end(
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if l_session_file_id is not null then
            prc_api_file_pkg.close_file(
                i_sess_file_id  => l_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );

            raise;
        end if;
end process;

end pmo_prc_export_pkg;
/
