create or replace package body h2h_prc_incoming_pkg as
/*********************************************************
 *  H2H incoming clearing <br />
 *  Created by Gerbeev I.(gerbeev@bpcbt.com)  at 22.06.2018 <br />
 *  Module: H2H_API_INCOMING_PKG <br />
 *  @headcom
 **********************************************************/

BULK_LIMIT            constant com_api_type_pkg.t_tiny_id := 100;

cursor cur_h2h(
    i_h2h_file_rec      in     h2h_api_type_pkg.t_h2h_file_rec
  , i_file_xml          in     xmltype
) is
    select null as id
         , null as split_hash
         , net_api_const_pkg.CLEARING_MSG_STATUS_LOADED
         , i_h2h_file_rec.inst_id
         , i_h2h_file_rec.network_id
         , i_h2h_file_rec.forw_inst_code
         , i_h2h_file_rec.receiv_inst_code
         , i_h2h_file_rec.orig_file_id
         , i_h2h_file_rec.file_type
         , i_h2h_file_rec.file_date
         , i_h2h_file_rec.is_incoming
         , t.is_reversal
         , com_api_const_pkg.FALSE as is_collection_only
         , i_h2h_file_rec.is_rejected
         , null as reject_id
         , null as dispute_id
         , t.oper_type
         , t.msg_type
         , to_date(t.oper_date, com_api_const_pkg.XML_DATETIME_FORMAT)
         , t.oper_amount_value
         , t.oper_amount_currency
         , t.oper_surcharge_amount_value
         , t.oper_surcharge_amount_currency
         , t.oper_cashback_amount_value
         , t.oper_cashback_amount_currency
         , t.sttl_amount_value
         , t.sttl_amount_currency
         , t.sttl_rate
         , t.crdh_bill_amount_value
         , t.crdh_bill_amount_currency
         , t.crdh_bill_rate
         , t.acq_inst_bin
         , t.arn
         , t.merchant_number
         , t.mcc
         , t.merchant_name
         , t.merchant_street
         , t.merchant_city
         , t.merchant_region
         , t.merchant_country
         , t.merchant_postcode
         , t.terminal_type
         , t.terminal_number
         , iss_api_token_pkg.decode_card_number(
               i_card_number  => t.card_number
             , i_mask_error   => com_api_const_pkg.TRUE
           ) as card_number
         , t.card_seq_num
         , to_date(t.card_expiry, com_api_const_pkg.XML_DATETIME_FORMAT)
         , t.service_code
         , t.approval_code
         , t.rrn
         , t.trn
         , t.oper_id
         , t.original_id
         , t.emv_5f2a
         , t.emv_5f34
         , t.emv_71
         , t.emv_72
         , t.emv_82
         , t.emv_84
         , t.emv_8a
         , t.emv_91
         , t.emv_95
         , t.emv_9a
         , t.emv_9c
         , t.emv_9f02
         , t.emv_9f03
         , t.emv_9f06
         , t.emv_9f09
         , t.emv_9f10
         , t.emv_9f18
         , t.emv_9f1a
         , t.emv_9f1e
         , t.emv_9f26
         , t.emv_9f27
         , t.emv_9f28
         , t.emv_9f29
         , t.emv_9f33
         , t.emv_9f34
         , t.emv_9f35
         , t.emv_9f36
         , t.emv_9f37
         , t.emv_9f41
         , t.emv_9f53
         , t.pdc_1
         , t.pdc_2
         , t.pdc_3
         , t.pdc_4
         , t.pdc_5
         , t.pdc_6
         , t.pdc_7
         , t.pdc_8
         , t.pdc_9
         , t.pdc_10
         , t.pdc_11
         , t.pdc_12
         , t.tags
         , t.flexible_fields
      from xmltable(
            xmlnamespaces(default 'http://bpc.ru/sv/SVXP/clearing')
          , '/clearing/operation' passing i_file_xml
                columns
                  oper_type                         varchar2(8)     path    'oper_type'
                , msg_type                          varchar2(8)     path    'msg_type'
                , oper_date                         varchar2(20)    path    'oper_date'
                , oper_amount_value                 number          path    'oper_amount/amount_value'
                , oper_amount_currency              number          path    'oper_amount/currency'
                , oper_surcharge_amount_value       number          path    'oper_surcharge_amount/amount_value'
                , oper_surcharge_amount_currency    number          path    'oper_surcharge_amount/currency'
                , oper_cashback_amount_value        number          path    'oper_cashback_amount/amount_value'
                , oper_cashback_amount_currency     number          path    'oper_cashback_amount/currency'
                , sttl_amount_value                 number          path    'sttl_amount/amount_value'
                , sttl_amount_currency              number          path    'sttl_amount/currency'
                , sttl_rate                         number          path    'sttl_rate'
                , crdh_bill_amount_value            number          path    'crdh_bill_amount/amount_value'
                , crdh_bill_amount_currency         number          path    'crdh_bill_amount/currency'
                , crdh_bill_rate                    number          path    'crdh_bill_rate'
                , acq_inst_bin                      varchar2(24)    path    'acq_inst_bin'
                , arn                               varchar2(23)    path    'arn'
                , is_reversal                       number          path    'is_reversal'
                , merchant_number                   varchar2(15)    path    'merchant_number'
                , mcc                               varchar2(6)     path    'mcc'
                , merchant_name                     varchar2(200)   path    'merchant_name'
                , merchant_street                   varchar2(200)   path    'merchant_street'
                , merchant_city                     varchar2(200)   path    'merchant_city'
                , merchant_region                   varchar2(6)     path    'merchant_region'
                , merchant_country                  varchar2(6)     path    'merchant_country'
                , merchant_postcode                 varchar2(10)    path    'merchant_postcode'
                , terminal_type                     varchar2(8)     path    'terminal_type'
                , terminal_number                   varchar2(8)     path    'terminal_number'
                , card_number                       varchar2(24)    path    'card_number'
                , card_seq_num                      number          path    'card_seq_num'
                , card_expiry                       varchar2(20)    path    'card_expiry'
                , service_code                      varchar2(3)     path    'service_code'
                , approval_code                     varchar2(6)     path    'approval_code'
                , rrn                               varchar2(12)    path    'rrn'
                , trn                               varchar2(16)    path    'trn'
                , oper_id                           number          path    'oper_id'
                , original_id                       number          path    'original_id'
                , emv_5f2a                          varchar2(4)     path    'emv_data/tag_5f2a'
                , emv_5f34                          varchar2(4)     path    'emv_data/tag_5f34'
                , emv_71                            varchar2(16)    path    'emv_data/tag_71'
                , emv_72                            varchar2(16)    path    'emv_data/tag_72'
                , emv_82                            varchar2(8)     path    'emv_data/tag_82'
                , emv_84                            varchar2(32)    path    'emv_data/tag_84'
                , emv_8a                            varchar2(32)    path    'emv_data/tag_8a'
                , emv_91                            varchar2(32)    path    'emv_data/tag_91'
                , emv_95                            varchar2(10)    path    'emv_data/tag_95'
                , emv_9a                            varchar2(6)     path    'emv_data/tag_9a'
                , emv_9c                            varchar2(2)     path    'emv_data/tag_9c'
                , emv_9f02                          varchar2(12)    path    'emv_data/tag_9f02'
                , emv_9f03                          varchar2(12)    path    'emv_data/tag_9f03'
                , emv_9f06                          varchar2(64)    path    'emv_data/tag_9f06'
                , emv_9f09                          varchar2(4)     path    'emv_data/tag_9f09'
                , emv_9f10                          varchar2(64)    path    'emv_data/tag_9f10'
                , emv_9f18                          varchar2(8)     path    'emv_data/tag_9f18'
                , emv_9f1a                          varchar2(4)     path    'emv_data/tag_9f1a'
                , emv_9f1e                          varchar2(16)    path    'emv_data/tag_9f1e'
                , emv_9f26                          varchar2(16)    path    'emv_data/tag_9f26'
                , emv_9f27                          varchar2(2)     path    'emv_data/tag_9f27'
                , emv_9f28                          varchar2(16)    path    'emv_data/tag_9f28'
                , emv_9f29                          varchar2(16)    path    'emv_data/tag_9f29'
                , emv_9f33                          varchar2(6)     path    'emv_data/tag_9f33'
                , emv_9f34                          varchar2(6)     path    'emv_data/tag_9f34'
                , emv_9f35                          varchar2(2)     path    'emv_data/tag_9f35'
                , emv_9f36                          varchar2(32)    path    'emv_data/tag_9f36'
                , emv_9f37                          varchar2(32)    path    'emv_data/tag_9f37'
                , emv_9f41                          varchar2(8)     path    'emv_data/tag_9f41'
                , emv_9f53                          varchar2(32)    path    'emv_data/tag_9f53'
                , pdc_1                             varchar2(8)     path    'pdc/pdc_1'
                , pdc_2                             varchar2(8)     path    'pdc/pdc_2'
                , pdc_3                             varchar2(8)     path    'pdc/pdc_3'
                , pdc_4                             varchar2(8)     path    'pdc/pdc_4'
                , pdc_5                             varchar2(8)     path    'pdc/pdc_5'
                , pdc_6                             varchar2(8)     path    'pdc/pdc_6'
                , pdc_7                             varchar2(8)     path    'pdc/pdc_7'
                , pdc_8                             varchar2(8)     path    'pdc/pdc_8'
                , pdc_9                             varchar2(8)     path    'pdc/pdc_9'
                , pdc_10                            varchar2(8)     path    'pdc/pdc_10'
                , pdc_11                            varchar2(8)     path    'pdc/pdc_11'
                , pdc_12                            varchar2(8)     path    'pdc/pdc_12'
                , tags                              xmltype         path    'tag'
                , flexible_fields                   xmltype         path    'flexible_field'
           ) t;

/*
 * Loading (import) of an incoming H2H clearing file.
 * @param i_use_institution - it defines which institution code from the file (forw_inst_code or
 *     receiv_inst_code) is used to determine H2H message isntitution ID.
 *     For example, if the forwarding (originator) institution (A) hasn't own CMID (Visa), then its
 *     fin. messages should be created with institution (inst_id) associated with receiving institution (B)
 *     that have to have some CMID value. In this case the parameter should be set to "Receiving institution".
 *     Therefore, Visa will get Visa fin. messages (are created by H2H messages) with CMID of institution (B).
 *     Another situation is when institution (A) has own CMID. In this case it is required to create Visa
 *     fin. messages with CMID of forwarding/originator institution (A). So the parameter should be set to
 *     value "Forwarding/originator institution".
 */
procedure process(
    i_network_id        in      com_api_type_pkg.t_network_id
  , i_use_institution   in      com_api_type_pkg.t_dict_value
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name         := lower($$PLSQL_UNIT) || '.process: ';
    l_host_id                   com_api_type_pkg.t_tiny_id;
    l_standard_id               com_api_type_pkg.t_tiny_id;
    l_resp_code                 com_api_type_pkg.t_dict_value;
    l_sess_file_id_tab          com_api_type_pkg.t_long_tab;
    l_file_estimated_count      com_api_type_pkg.t_count        := 0;
    l_estimated_count           com_api_type_pkg.t_count        := 0;
    l_processed_count           com_api_type_pkg.t_count        := 0;
    l_excepted_count            com_api_type_pkg.t_count        := 0;
    l_file_xml                  xmltype;
    l_h2h_file_rec              h2h_api_type_pkg.t_h2h_file_rec;
    l_inst_code                 h2h_api_type_pkg.t_inst_code;
    l_h2h_tab                   h2h_api_type_pkg.t_h2h_clearing_tab;
    l_tag_value_tab             h2h_api_type_pkg.t_h2h_tag_value_tab;
    l_flexible_data             com_api_type_pkg.t_flexible_data_tab;

    procedure process_tags(
        io_tags                 in out nocopy  xmltype
      , o_tag_value_tab            out         h2h_api_type_pkg.t_h2h_tag_value_tab
    ) is
    begin
        select null as id
             , null as tag_id
             , tag_name
             , tag_value
          bulk collect into o_tag_value_tab
          from xmltable(
                   xmlnamespaces('http://bpc.ru/sv/SVXP/clearing' as "svxp")
                 , '/svxp:tag' passing io_tags
                   columns tag_name    varchar2 (200)   path 'svxp:tag_name'
                         , tag_value   varchar2 (2000)  path 'svxp:tag_value'
               ) tags;
    end process_tags;

    procedure process_flexible_fields(
        io_flexible_fields      in out nocopy  xmltype
      , o_flexible_data            out         com_api_type_pkg.t_flexible_data_tab
    ) is
    begin
        select null as field_id
             , field_name
             , field_value
          bulk collect into
               l_flexible_data
          from xmltable(
                   xmlnamespaces('http://bpc.ru/sv/SVXP/clearing' as "svxp")
                 , '/svxp:flexible_field' passing io_flexible_fields
                   columns field_name    varchar2 (200)   path 'svxp:field_name'
                         , field_value   varchar2 (2000)  path 'svxp:field_value'
               ) ff;
    end process_flexible_fields;

    procedure register_events(
        io_h2h_rec              in out nocopy   h2h_api_type_pkg.t_h2h_clearing_rec
    ) is
        l_inst_id_tab                           com_api_type_pkg.t_inst_id_tab;
        l_split_hash_tab                        com_api_type_pkg.t_number_tab;
    begin
        select inst_id
             , split_hash
          bulk collect into
               l_inst_id_tab
             , l_split_hash_tab
          from opr_participant
         where oper_id = io_h2h_rec.id
         group by
               inst_id
             , split_hash;

        for i in 1 .. l_split_hash_tab.count() loop
            evt_api_event_pkg.register_event(
                i_event_type   => case
                                      when io_h2h_rec.status = net_api_const_pkg.CLEARING_MSG_STATUS_LOADED
                                      then opr_api_const_pkg.EVENT_LOADED_SUCCESSFULLY
                                      else opr_api_const_pkg.EVENT_LOADED_WITH_ERRORS
                                  end
              , i_eff_date     => io_h2h_rec.oper_date
              , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
              , i_object_id    => io_h2h_rec.id
              , i_inst_id      => l_inst_id_tab(i)
              , i_split_hash   => l_split_hash_tab(i)
            );
        end loop;
    end register_events;

begin
    savepoint h2h_incoming_start;

    prc_api_stat_pkg.log_start();

    l_host_id :=
        net_api_network_pkg.get_default_host(
            i_network_id  => i_network_id
        );
    l_standard_id :=
        net_api_network_pkg.get_offline_standard(
            i_host_id     => l_host_id
        );

    trc_log_pkg.debug(
        i_text          => LOG_PREFIX ||   'l_host_id [#1], l_standard_id [#2]'
      , i_env_param1    => l_host_id
      , i_env_param2    => l_standard_id
    );

    l_sess_file_id_tab :=
        prc_api_file_pkg.get_session_file_id(
            i_session_id  => prc_api_session_pkg.get_session_id()
          , i_file_type   => h2h_api_const_pkg.FILE_TYPE_H2H
        );

    l_h2h_file_rec.is_incoming      := com_api_const_pkg.TRUE;
    l_h2h_file_rec.is_rejected      := com_api_const_pkg.FALSE;
    l_h2h_file_rec.network_id       := i_network_id;

    for i in 1 .. l_sess_file_id_tab.count() loop
        l_h2h_file_rec.id               := com_api_id_pkg.get_id(i_seq => h2h_file_seq.nextval);
        l_h2h_file_rec.proc_date        := com_api_sttl_day_pkg.get_sysdate();
        l_h2h_file_rec.session_file_id  := l_sess_file_id_tab(i);

        l_file_xml := prc_api_file_pkg.get_xml_content(i_sess_file_id => l_sess_file_id_tab(i));

        select f.file_type
             , to_date(f.file_date, com_api_const_pkg.XML_DATE_FORMAT)
             , f.forw_inst_code
             , f.receiv_inst_code
             , f.file_id
          into l_h2h_file_rec.file_type
             , l_h2h_file_rec.file_date
             , l_h2h_file_rec.forw_inst_code
             , l_h2h_file_rec.receiv_inst_code
             , l_h2h_file_rec.orig_file_id
          from xmltable(
                   xmlnamespaces(default 'http://bpc.ru/sv/SVXP/clearing')
                 , '/clearing'
                   passing l_file_xml
                   columns file_type           varchar2(8)     path 'file_type'
                         , file_date           varchar2(20)    path 'file_date'
                         , forw_inst_code      varchar2(11)    path 'forw_inst_code'
                         , receiv_inst_code    varchar2(11)    path 'receiv_inst_code'
                         , file_id             number(16)      path 'file_id'
               ) f;

        l_inst_code :=
            case i_use_institution
                when h2h_api_const_pkg.USE_INSTITUTION_RECEIVING  then l_h2h_file_rec.receiv_inst_code
                when h2h_api_const_pkg.USE_INSTITUTION_FORWARDING then l_h2h_file_rec.forw_inst_code
            end;

        trc_log_pkg.debug(
            i_text        => LOG_PREFIX || 'session file ID [#5]; forw_inst_code [#1], receiv_inst_code [#2];'
                          || ' use institution code [#3] to determine H2H message institution ID due to [#4]'
          , i_env_param1  => l_h2h_file_rec.forw_inst_code
          , i_env_param2  => l_h2h_file_rec.receiv_inst_code
          , i_env_param3  => l_inst_code
          , i_env_param4  => i_use_institution
          , i_env_param5  => l_h2h_file_rec.session_file_id
        );

        l_h2h_file_rec.inst_id :=
            cmn_api_standard_pkg.find_value_owner(
                i_standard_id  => l_standard_id
              , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
              , i_object_id    => l_host_id
              , i_param_name   => h2h_api_const_pkg.H2H_INST_CODE
              , i_value_char   => l_inst_code
              , i_mask_error   => com_api_const_pkg.TRUE
            );

        if l_h2h_file_rec.inst_id is null then
            com_api_error_pkg.raise_error(
                i_error        => 'H2H_INVALID_INSTITUTION'
              , i_env_param1   => null
            );
        end if;

        select count(*) as oper_count
          into l_file_estimated_count
          from xmltable(
                   xmlnamespaces(default 'http://bpc.ru/sv/SVXP/clearing')
                 , '/clearing/operation' passing l_file_xml
               );

        l_estimated_count := l_estimated_count + l_file_estimated_count;

        prc_api_stat_pkg.log_estimation(
            i_estimated_count  => l_estimated_count
        );

        open cur_h2h(
            i_h2h_file_rec  => l_h2h_file_rec
          , i_file_xml      => l_file_xml
        );
        loop
            fetch cur_h2h bulk collect into l_h2h_tab limit BULK_LIMIT;

            for i in 1 .. l_h2h_tab.count() loop
                h2h_api_fin_message_pkg.validate_message(i_fin_rec => l_h2h_tab(i));

                process_tags(
                    io_tags            => l_h2h_tab(i).tags
                  , o_tag_value_tab    => l_tag_value_tab
                );
                process_flexible_fields(
                    io_flexible_fields => l_h2h_tab(i).flexible_fields
                  , o_flexible_data    => l_flexible_data
                );

                l_h2h_tab(i).id := opr_api_create_pkg.get_id(i_host_date => l_h2h_file_rec.proc_date);

                h2h_api_fin_message_pkg.create_operation(
                    i_fin_rec          => l_h2h_tab(i)
                  , i_host_id          => l_host_id
                  , i_standard_id      => l_standard_id
                  , io_tag_value_tab   => l_tag_value_tab
                  , o_resp_code        => l_resp_code
                );

                if l_resp_code = aup_api_const_pkg.RESP_CODE_OK then
                    l_h2h_tab(i).status := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
                else
                    l_h2h_tab(i).status := net_api_const_pkg.CLEARING_MSG_STATUS_INVALID;
                    l_excepted_count := l_excepted_count + 1;
                end if;

                l_h2h_tab(i).id := h2h_api_fin_message_pkg.put_message(i_fin_rec => l_h2h_tab(i));

                h2h_api_tag_pkg.save_tag_value(
                    i_fin_id           => l_h2h_tab(i).id
                  , io_tag_value_tab   => l_tag_value_tab
                );

                com_api_flexible_data_pkg.save_data(
                    io_flex_data_tab   => l_flexible_data
                  , i_entity_type      => h2h_api_const_pkg.ENTITY_TYPE_H2H
                  , i_object_id        => l_h2h_tab(i).id
                );

                register_events(
                    io_h2h_rec         => l_h2h_tab(i)
                );

                l_processed_count := l_processed_count + 1;

                if mod(l_processed_count, BULK_LIMIT) = 0 then
                    prc_api_stat_pkg.log_current(
                        i_current_count   => l_processed_count
                      , i_excepted_count  => l_excepted_count
                    );
                end if;
            end loop;

            exit when cur_h2h%notfound;
        end loop;

        close cur_h2h;

        if l_processed_count > 0 then
            l_h2h_file_rec.id := h2h_api_fin_message_pkg.put_file(i_file_rec => l_h2h_file_rec);
        end if;

        prc_api_stat_pkg.log_current(
            i_current_count   => l_processed_count
          , i_excepted_count  => l_excepted_count
        );
    end loop;

    prc_api_stat_pkg.log_end(
        i_excepted_total   => l_excepted_count
      , i_processed_total  => l_processed_count
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
exception
    when others then
        rollback to savepoint h2h_incoming_start;

        if cur_h2h%isopen then
            close cur_h2h;
        end if;

        prc_api_stat_pkg.log_end(
            i_excepted_total   => l_excepted_count
          , i_processed_total  => l_processed_count
          , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if     com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
            or com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
        then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error       => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
            );
        end if;
end process;

end;
/
