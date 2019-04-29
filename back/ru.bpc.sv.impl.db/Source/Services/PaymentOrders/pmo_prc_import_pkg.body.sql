create or replace package body pmo_prc_import_pkg as
/*********************************************************
 *  Process for payment orders export to XML file <br />
 *  Created by Fomichev A.(fomichev@bpcbt.com)  at 02.04.2018 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: pmo_prc_import_pkg  <br />
 *  @headcom
 **********************************************************/

procedure add_oper_to_prepared_order(
    i_customer_id           in com_api_type_pkg.t_medium_id
  , i_purpose_id            in com_api_type_pkg.t_short_id
  , i_split_hash            in com_api_type_pkg.t_tiny_id
  , i_inst_id               in com_api_type_pkg.t_inst_id
  , i_oper_id               in com_api_type_pkg.t_long_id
  , o_prepared_order_id     out com_api_type_pkg.t_long_id
) is
    l_entity_type           com_api_type_pkg.t_dict_value;
    l_object_id             com_api_type_pkg.t_long_id;
    l_order_id              com_api_type_pkg.t_long_id;
    l_cycle_type            com_api_type_pkg.t_dict_value;
    l_template_id           com_api_type_pkg.t_long_id;
    l_params                com_api_type_pkg.t_param_tab;
    l_order_date            date;
    l_prev_date             date;
    l_amount_rec            com_api_type_pkg.t_amount_rec;
begin
    begin
      select t.id
           , s.entity_type
           , s.object_id
           , s.event_type
        into l_template_id
           , l_entity_type
           , l_object_id
           , l_cycle_type
        from pmo_order t
           , pmo_schedule s
       where t.customer_id  = i_customer_id
         and s.order_id     = t.id
         and t.purpose_id   = i_purpose_id
         and t.templ_status in (
                                 pmo_api_const_pkg.PAYMENT_TMPL_STATUS_VALD
                               , pmo_api_const_pkg.PAYMENT_TMPL_STATUS_SUSP
                               )
         and t.is_template  = com_api_const_pkg.TRUE
         and rownum = 1;

    exception
        when no_data_found then
            null;
    end;

    if l_template_id is null then
        trc_log_pkg.debug(
            i_text  => 'Template not found customer_id = ' || i_customer_id || ', purpose_id = ' || i_purpose_id
        );
        return;
    end if;

    -- get order cycle date
    fcl_api_cycle_pkg.get_cycle_date(
        i_cycle_type     => l_cycle_type
      , i_entity_type    => l_entity_type
      , i_object_id      => l_object_id
      , i_split_hash     => i_split_hash
      , o_prev_date      => l_prev_date
      , o_next_date      => l_order_date
    );

    -- find/create prepared payment order
    begin
      select t.id
        into o_prepared_order_id
        from pmo_order t
       where t.status       = pmo_api_const_pkg.PMO_STATUS_PREPARATION
         and t.event_date   = l_order_date
         and t.template_id  = l_template_id;

        trc_log_pkg.debug(
            i_text  => 'Found order order_id = ' || l_order_id
        );

    exception
        when no_data_found then

            l_amount_rec.amount     := null;
            l_amount_rec.currency   := null;

            pmo_api_order_pkg.add_order_with_params(
                io_payment_order_id     => o_prepared_order_id
              , i_entity_type           => l_entity_type
              , i_object_id             => l_object_id
              , i_customer_id           => i_customer_id
              , i_split_hash            => i_split_hash
              , i_purpose_id            => i_purpose_id
              , i_template_id           => l_template_id
              , i_amount_rec            => l_amount_rec
              , i_eff_date              => l_order_date
              , i_order_status          => pmo_api_const_pkg.PMO_STATUS_PREPARATION
              , i_inst_id               => i_inst_id
              , i_attempt_count         => 0
              , i_payment_order_number  => null
              , i_expiration_date       => null
              , i_register_event        => com_api_const_pkg.TRUE
              , i_is_prepared_order     => com_api_type_pkg.TRUE
              , i_param_tab             => l_params
            );

            trc_log_pkg.debug(
                i_text  => 'Created order order_id = ' || o_prepared_order_id
            );
    end;

    -- link operation
    pmo_api_order_pkg.add_order_detail(
        i_order_id       => o_prepared_order_id
        , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
        , i_object_id    => i_oper_id
    );
end;

procedure create_order_operation(
    i_order_id              in      com_api_type_pkg.t_long_id
) is
    l_order_rec             pmo_api_type_pkg.t_payment_order_rec;
    l_oper_type             com_api_type_pkg.t_dict_value;
    l_card_id               com_api_type_pkg.t_medium_id;
    l_account_number        com_api_type_pkg.t_account_number;
    l_account_id            com_api_type_pkg.t_medium_id;
    l_client_id_type        com_api_type_pkg.t_dict_value;
    l_client_id_value       com_api_type_pkg.t_name;
    l_sysdate               date                            := com_api_sttl_day_pkg.get_sysdate;
    l_oper_id               com_api_type_pkg.t_long_id;
    l_customer_id           com_api_type_pkg.t_medium_id;
    l_party_type            com_api_type_pkg.t_dict_value   := com_api_const_pkg.PARTICIPANT_ISSUER;
begin
    l_order_rec :=
        pmo_api_order_pkg.get_order(
            i_order_id          => i_order_id
        );

    select min(oper_type)
      into l_oper_type
      from pmo_purpose
     where id      = l_order_rec.purpose_id;

    if l_oper_type is null then

        trc_log_pkg.debug('Operation type is not configured. Operation can not be created');
        return;
    end if;

    case l_order_rec.entity_type
        when acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then

            l_account_id     := l_order_rec.object_id;
            l_account_number :=
                acc_api_account_pkg.get_account(
                    i_account_id         => l_order_rec.object_id
                  , i_inst_id            => l_order_rec.inst_id
                  , i_mask_error         => com_api_const_pkg.FALSE
                ).account_number;

            l_client_id_type   := opr_api_const_pkg.CLIENT_ID_TYPE_ACCOUNT;
            l_client_id_value  := l_account_number;

        when iss_api_const_pkg.ENTITY_TYPE_CARD  then

            l_card_id          := l_order_rec.object_id;
            l_client_id_type   := opr_api_const_pkg.CLIENT_ID_TYPE_CARD_ID;
            l_client_id_value  := l_order_rec.object_id;

        else
            l_client_id_type   := opr_api_const_pkg.CLIENT_ID_TYPE_CUSTOMER;
            l_client_id_value  := prd_api_customer_pkg.get_customer_number(
                                        i_customer_id  => l_order_rec.customer_id
                                      , i_inst_id      => l_order_rec.inst_id
                                      , i_mask_error   => com_api_const_pkg.FALSE
                                    );

            -- try to find service provider
            prd_api_customer_pkg.find_customer(
                i_acq_inst_id       => l_order_rec.inst_id
              , i_payment_order_id  => l_order_rec.id
              , o_customer_id       => l_customer_id
            );

            if l_customer_id is not null then
                l_party_type := com_api_const_pkg.PARTICIPANT_SERVICE_PROVIDER;
            end if;
    end case;

    l_oper_id := com_api_id_pkg.get_id(opr_operation_seq.nextval, l_sysdate);

    opr_api_create_pkg.add_participant(
        i_oper_id           => l_oper_id
      , i_msg_type          => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
      , i_oper_type         => l_oper_type
      , i_participant_type  => l_party_type
      , i_host_date         => l_sysdate
      , i_client_id_type    => l_client_id_type
      , i_client_id_value   => l_client_id_value
      , i_inst_id           => l_order_rec.inst_id
      , i_card_id           => l_card_id
      , i_customer_id       => l_order_rec.customer_id
      , i_account_number    => l_account_number
      , i_account_id        => l_account_id
      , i_without_checks    => com_api_const_pkg.TRUE
      , i_payment_order_id  => i_order_id
      , i_split_hash        => l_order_rec.split_hash
    );

    opr_api_create_pkg.create_operation(
        io_oper_id          => l_oper_id
      , i_status            => opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
      , i_sttl_type         => opr_api_const_pkg.SETTLEMENT_INTERNAL
      , i_msg_type          => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
      , i_oper_type         => l_oper_type
      , i_oper_amount       => nvl(l_order_rec.resp_amount, l_order_rec.amount)
      , i_oper_currency     => l_order_rec.currency
      , i_is_reversal       => com_api_const_pkg.FALSE
      , i_oper_date         => l_sysdate
      , i_host_date         => l_sysdate
      , i_payment_order_id  => i_order_id
    );

end;

procedure import_pmo_response(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_create_operation  in      com_api_type_pkg.t_boolean  default null
) is
    LOG_PREFIX               constant com_api_type_pkg.t_name   := lower($$PLSQL_UNIT) || '.import_pmo_response: ';
    l_record_count           com_api_type_pkg.t_long_id         := 0;
    l_errors_count           com_api_type_pkg.t_long_id         := 0;
    l_file_id_tab            com_api_type_pkg.t_number_tab;
    l_order_id_tab           com_api_type_pkg.t_number_tab;
    l_resp_code_tab          com_api_type_pkg.t_dict_tab;
    l_resp_amount_tab        com_api_type_pkg.t_money_tab;
    l_amount_tab             com_api_type_pkg.t_money_tab;
    l_currency_tab           com_api_type_pkg.t_varchar2_tab;
    l_resp_amount_rec        com_api_type_pkg.t_amount_rec;
begin
    trc_log_pkg.debug (i_text => 'starting import PMO response' );

    prc_api_stat_pkg.log_start;

    begin
        select f.id             as session_file_id
             , b.order_id       as order_id
             , b.amount         as amount
             , b.currency       as currency
             , b.resp_code      as resp_code
             , b.resp_amount    as resp_amount
          bulk collect into
               l_file_id_tab
             , l_order_id_tab
             , l_amount_tab
             , l_currency_tab
             , l_resp_code_tab
             , l_resp_amount_tab
          from prc_session_file f
                , xmltable(xmlnamespaces(default 'http://bpc.ru/sv/SVXP/payment_order')
                       , '/payment_orders/payment_order' passing f.file_xml_contents
                       columns
                           order_id                 number      path 'order_id'
                         , amount                   number      path 'amount'
                         , currency                 varchar2(3) path 'currency'
                         , resp_code                varchar2(8) path 'resp_code'
                         , resp_amount              number      path 'resp_amount/amount_value'
                  ) b
         where f.session_id = get_session_id
         order by order_id;
    exception
        when no_data_found then
            null;
    end;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count => l_order_id_tab.count
    );

    trc_log_pkg.debug(
        'l_file_id_tab.count = '          || l_file_id_tab.count
        || ', l_order_id_tab.count = '    || l_order_id_tab.count
        || ', l_amount_tab.count = '      || l_amount_tab.count
        || ', l_currency_tab.count = '    || l_currency_tab.count
        || ', l_resp_code_tab.count = '   || l_resp_code_tab.count
        || ', l_resp_amount_tab.count = ' || l_resp_amount_tab.count
    );

    if l_order_id_tab.count > 0 then
         for i in l_order_id_tab.first .. l_order_id_tab.last  loop

            trc_log_pkg.debug(i_text => 'Processing session_file_id [' || l_file_id_tab(i) || ']' );
            begin
                savepoint sp_order;

                trc_log_pkg.debug('processing payment order, id=' || l_order_id_tab(i));

                l_resp_amount_rec           := null;
                l_resp_amount_rec.amount    := l_resp_amount_tab(i);

                pmo_api_order_pkg.process_pmo_response(
                    i_order_id          => l_order_id_tab(i)
                  , i_resp_code         => l_resp_code_tab(i)
                  , i_resp_amount_rec   => l_resp_amount_rec
                );

                if nvl(i_create_operation, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE
                    and l_resp_code_tab(i) = pmo_api_const_pkg.PMO_RESPONSE_CODE_PROCESSED
                then
                    create_order_operation(
                        i_order_id          => l_order_id_tab(i)
                    );
                end if;

                l_record_count  := l_record_count + 1;

                if mod(l_record_count, 100) = 0 then
                    prc_api_stat_pkg.log_current(
                        i_current_count  => l_record_count
                      , i_excepted_count => l_errors_count
                    );
                end if;

            exception
                when com_api_error_pkg.e_application_error then

                    rollback to sp_order;

                    l_errors_count := l_errors_count + 1;
                    l_record_count := l_record_count + 1;

                    prc_api_stat_pkg.log_current(
                        i_current_count  => l_record_count
                      , i_excepted_count => l_errors_count
                    );
            end;

        end loop;
    end if;

    prc_api_stat_pkg.log_current(
        i_current_count  => l_record_count
      , i_excepted_count => l_errors_count
    );

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_record_count
      , i_excepted_total    => l_errors_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(LOG_PREFIX || 'END');

exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end import_pmo_response;

procedure import_orders(
    i_inst_id           in      com_api_type_pkg.t_inst_id
) is
    type t_order_data_rec is record (
        order_id                        com_api_type_pkg.t_long_id
      , customer_number                 com_api_type_pkg.t_name
      , amount                          com_api_type_pkg.t_money
      , currency                        com_api_type_pkg.t_curr_code
      , order_date                      date
      , purpose_id                      com_api_type_pkg.t_short_id
      , purpose_number                  com_api_type_pkg.t_name
      , status                          com_api_type_pkg.t_dict_value
      , order_number                    com_api_type_pkg.t_name
      , originator_refnum               com_api_type_pkg.t_rrn
      , parameter                       xmltype
    );

    type t_order_data_tab is table of t_order_data_rec index by binary_integer;

    LOG_PREFIX                  constant com_api_type_pkg.t_name    := lower($$PLSQL_UNIT) || '.import_pmo_response: ';
    l_record_count              com_api_type_pkg.t_long_id          := 0;
    l_errors_count              com_api_type_pkg.t_long_id          := 0;
    l_customer_id               com_api_type_pkg.t_medium_id;
    l_oper_id                   com_api_type_pkg.t_long_id;
    l_split_hash                com_api_type_pkg.t_tiny_id;
    l_file_inst_id              com_api_type_pkg.t_inst_id;
    l_file_date                 date;
    l_file_number               com_api_type_pkg.t_name;
    l_payment_order_id          com_api_type_pkg.t_long_id;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_status                    com_api_type_pkg.t_dict_value;
    l_params                    com_api_type_pkg.t_param_tab;
    l_prepared_order_id         com_api_type_pkg.t_long_id;
    l_session_id                com_api_type_pkg.t_long_id      := get_session_id;
    l_session_file_id           com_api_type_pkg.t_long_id;
    l_order_data_tab            t_order_data_tab;
    l_purpose_exists            com_api_type_pkg.t_boolean;
    l_param_id_tab              com_api_type_pkg.t_number_tab;
    l_param_val_tab             com_api_type_pkg.t_desc_tab;
begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'starting import PMO response'
    );

    prc_api_stat_pkg.log_start;

    if l_file_inst_id <> i_inst_id then
        com_api_error_pkg.raise_error(
            i_error         => 'INSTITUTIONS_DONT_MATCH'
          , i_env_param1    => i_inst_id
          , i_env_param2    => l_file_inst_id
        );
    end if;

    begin
        -- Parse file header
        select f.id                                                     as session_file_id
             , b.inst_id                                                as inst_id
             , to_date(b.file_date, com_api_const_pkg.XML_DATE_FORMAT)  as file_date
             , b.file_number                                            as file_number
          into l_session_file_id
             , l_file_inst_id
             , l_file_date
             , l_file_number
          from prc_session_file f
             , xmltable(xmlnamespaces(default 'http://bpc.ru/sv/SVXP/payment_order')
                 , '/' passing f.file_xml_contents
                   columns
                       inst_id                  number(4)       path 'inst_id'
                     , file_date                varchar2(20)    path 'file_date'
                     , file_number              varchar2(200)   path 'file_number'
               ) b
         where f.session_id = l_session_id;

        -- Parse payment order data
        select b.order_id                                           as order_id
             , b.customer_number                                    as customer_number
             , b.amount                                             as amount
             , b.currency                                           as currency
             , to_date(b.order_date, com_api_const_pkg.XML_DATETIME_FORMAT) as order_date
             , b.purpose_id                                         as purpose_id
             , b.purpose_number                                     as purpose_number
             , b.status                                             as status
             , b.order_number                                       as order_number
             , b.originator_refnum                                  as originator_refnum
             , b.parameter                                          as parameter
          bulk collect into
               l_order_data_tab
          from prc_session_file f
             , xmltable(xmlnamespaces(default 'http://bpc.ru/sv/SVXP/payment_order')
                 , '/payment_orders/payment_order' passing f.file_xml_contents
                   columns
                       order_id                        number          path 'order_id'
                     , customer_number                 varchar2(200)   path 'customer_number'
                     , amount                          number          path 'amount'
                     , currency                        varchar2(3)     path 'currency'
                     , order_date                      varchar2(20)    path 'order_date'
                     , purpose_id                      number          path 'purpose_id'
                     , purpose_number                  varchar2(200)   path 'purpose_number'
                     , status                          varchar2(8)     path 'status'
                     , order_number                    varchar2(200)   path 'order_number'
                     , originator_refnum               varchar2(36)    path 'originator_refnum'
                     , parameter                       xmltype         path 'parameter'
               ) b
         where f.session_id = l_session_id;

    exception
        when no_data_found then
            null;
    end;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count       => l_order_data_tab.count
    );

    trc_log_pkg.debug(
        'l_order_data_tab.count = '        || l_order_data_tab.count
    );

    if l_order_data_tab.count > 0 then
         for i in l_order_data_tab.first .. l_order_data_tab.last  loop

            trc_log_pkg.debug(i_text => 'Processing session_file_id [' || l_session_file_id || ']' );
            begin
                savepoint sp_order;

                trc_log_pkg.debug('processing payment order, id = ' || l_order_data_tab(i).order_id);

                -- Find order customer
                l_customer_id :=
                    prd_api_customer_pkg.get_customer_id(
                        i_customer_number  => l_order_data_tab(i).customer_number
                      , i_inst_id          => l_inst_id
                      , i_mask_error       => com_api_const_pkg.FALSE
                    );

                -- Check purpose exists
                if l_order_data_tab(i).purpose_id is not null then
                    l_purpose_exists :=
                        pmo_api_order_pkg.check_purpose_exists(
                            i_purpose_id        => l_order_data_tab(i).purpose_id
                          , i_mask_error        => com_api_type_pkg.FALSE
                        );
                elsif l_order_data_tab(i).purpose_number is not null then
                    l_purpose_exists :=
                        pmo_api_order_pkg.check_purpose_exists(
                            i_purpose_number    => l_order_data_tab(i).purpose_number
                          , i_mask_error        => com_api_type_pkg.FALSE
                        );
                end if;

                -- Check is needed to match order with operation
                if l_order_data_tab(i).originator_refnum is not null and l_order_data_tab(i).status = pmo_api_const_pkg.PMO_STATUS_REQUIRE_MATCHING then

                    -- Search main operation
                    l_oper_id :=
                        pmo_api_order_pkg.match_order_with_operation(
                            i_originator_refnum => l_order_data_tab(i).originator_refnum
                          , i_order_date        => l_order_data_tab(i).order_date
                        );

                    -- Add operation into prepared order and Update status of loaded orders if operation is found
                    if l_oper_id is not null then

                        pmo_api_order_pkg.add_oper_to_prepared_order(
                            i_customer_id       => l_customer_id
                          , i_purpose_id        => l_order_data_tab(i).purpose_id
                          , i_split_hash        => l_split_hash
                          , i_inst_id           => l_inst_id
                          , i_oper_id           => l_oper_id
                          , o_prepared_order_id => l_prepared_order_id
                        );

                        l_status := pmo_api_const_pkg.PMO_STATUS_PROCESSED;
                    end if;
                end if;

                pmo_api_order_pkg.add_order(
                    o_id                        => l_payment_order_id
                  , i_customer_id               => l_customer_id
                  , i_entity_type               => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
                  , i_object_id                 => l_customer_id
                  , i_purpose_id                => l_order_data_tab(i).purpose_id
                  , i_template_id               => null
                  , i_amount                    => l_order_data_tab(i).amount
                  , i_currency                  => l_order_data_tab(i).currency
                  , i_event_date                => l_order_data_tab(i).order_date
                  , i_status                    => nvl(l_status, l_order_data_tab(i).status)
                  , i_inst_id                   => l_inst_id
                  , i_attempt_count             => null
                  , i_is_prepared_order         => com_api_type_pkg.FALSE
                  , i_is_template               => com_api_type_pkg.FALSE
                  , i_split_hash                => l_split_hash
                  , i_payment_order_number      => l_order_data_tab(i).order_number
                  , i_order_originator_refnum   => l_order_data_tab(i).originator_refnum -- new field for matching
                );

                begin
                    -- Parse order parameters
                    select p.id as param_id
                         , param_value
                      bulk collect into
                           l_param_id_tab
                         , l_param_val_tab
                      from xmltable(
                               xmlnamespaces(default 'http://bpc.ru/sv/SVXP/clearing'), '/' passing l_order_data_tab(i).parameter
                               columns param_name    varchar2 (200)   path 'param_name'
                                     , param_value   varchar2 (2000)  path 'param_value'
                           ) par
                         , pmo_parameter p
                     where upper(par.param_name) = p.param_name;

                exception
                    when no_data_found then
                        null;
                end;

                pmo_api_order_pkg.register_payment_parameter(
                    i_order_id          => l_payment_order_id
                  , i_purpose_id        => l_order_data_tab(i).purpose_id
                  , i_param_id_tab      => l_param_id_tab
                  , i_param_val_tab     => l_param_val_tab
                );

                -- Link order with original operation. Add data into opr_operation_detail
                if l_oper_id is not null then
                    opr_api_detail_pkg.set_oper_detail(
                        i_oper_id           => l_oper_id
                      , i_entity_type       => pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER
                      , i_object_id         => l_payment_order_id
                    );
                end if;

                -- Register event of loaded order
                evt_api_event_pkg.register_event(
                    i_event_type     => pmo_api_const_pkg.EVENT_TYPE_PMO_LOADED
                  , i_eff_date       => get_sysdate
                  , i_entity_type    => pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER
                  , i_object_id      => l_payment_order_id
                  , i_inst_id        => i_inst_id
                  , i_split_hash     => l_split_hash
                  , i_param_tab      => l_params
                  , i_is_used_cache  => com_api_type_pkg.FALSE
                );

                l_record_count  := l_record_count + 1;

                if mod(l_record_count, 100) = 0 then
                    prc_api_stat_pkg.log_current(
                        i_current_count  => l_record_count
                      , i_excepted_count => l_errors_count
                    );
                end if;

            exception
                when com_api_error_pkg.e_application_error then

                    rollback to sp_order;

                    l_errors_count := l_errors_count + 1;
                    l_record_count := l_record_count + 1;

                    prc_api_stat_pkg.log_current(
                        i_current_count  => l_record_count
                      , i_excepted_count => l_errors_count
                    );
            end;

        end loop;
    end if;

    prc_api_stat_pkg.log_current(
        i_current_count  => l_record_count
      , i_excepted_count => l_errors_count
    );

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_record_count
      , i_excepted_total    => l_errors_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(LOG_PREFIX || 'END');

exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end import_orders;

end pmo_prc_import_pkg;
/
