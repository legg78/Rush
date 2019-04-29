create or replace package body h2h_prc_outgoing_pkg as
/*********************************************************
 *  H2H outgoing clearing <br />
 *  Created by Gerbeev I.(gerbeev@bpcbt.com)  at 22.06.2018 <br />
 *  Module: H2H_PRC_OUTGOING_PKG <br />
 *  @headcom
 **********************************************************/

BULK_LIMIT             constant com_api_type_pkg.t_count := 100;

cursor cur_file(
    i_network_id         in     com_api_type_pkg.t_network_id
  , i_inst_id            in     com_api_type_pkg.t_inst_id
  , i_receiv_inst_code   in     h2h_api_type_pkg.t_inst_code
) is
select f.forw_inst_code
     , count(*) over() as cnt
  from h2h_fin_message f
 where f.network_id       = i_network_id
   and f.inst_id          = i_inst_id
   and f.receiv_inst_code = i_receiv_inst_code
   and decode(f.status, 'CLMS0010', 'CLMS0010', null) = net_api_const_pkg.CLEARING_MSG_STATUS_READY
   and f.split_hash in (select t.split_hash from com_api_split_map_vw t)
 group by
       f.forw_inst_code
 order by
       f.forw_inst_code
;

cursor cur_fin_id(
    i_file_rec           in     h2h_api_type_pkg.t_h2h_file_rec
) is
select f.id
  from h2h_fin_message f
 where f.network_id       = i_file_rec.network_id
   and f.inst_id          = i_file_rec.inst_id
   and f.receiv_inst_code = i_file_rec.receiv_inst_code
   and f.forw_inst_code   = i_file_rec.forw_inst_code
   and decode(f.status, 'CLMS0010', 'CLMS0010', null) = net_api_const_pkg.CLEARING_MSG_STATUS_READY
   and f.split_hash in (select t.split_hash from com_api_split_map_vw t)
;

cursor cur_fin_message_xml(
    i_fin_id_tab         in     num_tab_tpt
) is
select xmlagg(xmlelement("operation"
         , xmlforest(
               fm.oper_type                    as "oper_type"
             , fm.msg_type                     as "msg_type"
             , to_char(fm.oper_date, com_api_const_pkg.XML_DATETIME_FORMAT) as "oper_date"
             , case when fm.oper_amount_value is not null then
                   xmlforest(
                       fm.oper_amount_value                 as "amount_value"
                     , fm.oper_amount_currency              as "currency"
                   )
               end                             as "oper_amount"
             , case when fm.oper_surcharge_amount_value is not null then
                   xmlforest(
                       fm.oper_surcharge_amount_value       as "amount_value"
                     , fm.oper_surcharge_amount_currency    as "currency"
                   )
               end                             as "oper_surcharge_amount"
             , case when fm.oper_cashback_amount_value is not null then
                   xmlforest(
                       fm.oper_cashback_amount_value        as "amount_value"
                     , fm.oper_cashback_amount_currency     as "currency"
                   )
               end                             as "oper_cashback_amount"

             , case when fm.sttl_amount_value is not null then
                   xmlforest(
                       fm.sttl_amount_value                 as "amount_value"
                     , fm.sttl_amount_currency              as "currency"
                   )
               end                             as "sttl_amount"
             , fm.sttl_rate                    as "sttl_rate"
             , case when fm.crdh_bill_amount_value is not null then
                   xmlforest(
                       fm.crdh_bill_amount_value            as "amount_value"
                     , fm.crdh_bill_amount_currency         as "currency"
                   )
               end                             as "crdh_bill_amount"
             , fm.crdh_bill_rate               as "crdh_bill_rate"
             , fm.acq_inst_bin                 as "acq_inst_bin"
             , fm.arn                          as "arn"
             , fm.is_reversal                  as "is_reversal"
             , fm.merchant_number              as "merchant_number"
             , fm.mcc                          as "mcc"
             , fm.merchant_name                as "merchant_name"
             , fm.merchant_street              as "merchant_street"
             , fm.merchant_city                as "merchant_city"
             , fm.merchant_region              as "merchant_region"
             , fm.merchant_country             as "merchant_country"
             , fm.merchant_postcode            as "merchant_postcode"
             , fm.terminal_type                as "terminal_type"
             , fm.terminal_number              as "terminal_number"
             , iss_api_token_pkg.decode_card_number(
                   i_card_number => c.card_number
               )                               as "card_number"
             , fm.card_seq_num                 as "card_seq_num"
             , fm.card_expiry                  as "card_expiry"
             , fm.service_code                 as "service_code"
             , fm.approval_code                as "approval_code"
             , fm.rrn                          as "rrn"
             , fm.trn                          as "trn"
             , fm.oper_id                      as "oper_id"
             , fm.original_id                  as "original_id"
             , xmlforest(
                   fm.emv_5f2a     as "tag_5f2a"
                 , fm.emv_5f34     as "tag_5f34"
                 , fm.emv_71       as "tag_71"
                 , fm.emv_72       as "tag_72"
                 , fm.emv_82       as "tag_82"
                 , fm.emv_84       as "tag_84"
                 , fm.emv_8a       as "tag_8a"
                 , fm.emv_91       as "tag_91"
                 , fm.emv_95       as "tag_95"
                 , fm.emv_9a       as "tag_9a"
                 , fm.emv_9c       as "tag_9c"
                 , fm.emv_9f02     as "tag_9f02"
                 , fm.emv_9f03     as "tag_9f03"
                 , fm.emv_9f06     as "tag_9f06"
                 , fm.emv_9f09     as "tag_9f09"
                 , fm.emv_9f10     as "tag_9f10"
                 , fm.emv_9f18     as "tag_9f18"
                 , fm.emv_9f1a     as "tag_9f1a"
                 , fm.emv_9f1e     as "tag_9f1e"
                 , fm.emv_9f26     as "tag_9f26"
                 , fm.emv_9f27     as "tag_9f27"
                 , fm.emv_9f28     as "tag_9f28"
                 , fm.emv_9f29     as "tag_9f29"
                 , fm.emv_9f33     as "tag_9f33"
                 , fm.emv_9f34     as "tag_9f34"
                 , fm.emv_9f35     as "tag_9f35"
                 , fm.emv_9f36     as "tag_9f36"
                 , fm.emv_9f37     as "tag_9f37"
                 , fm.emv_9f41     as "tag_9f41"
                 , fm.emv_9f53     as "tag_9f53"
               ) as "emv_data"
             , xmlforest(
                   fm.pdc_1        as "pdc_1"
                 , fm.pdc_2        as "pdc_2"
                 , fm.pdc_3        as "pdc_3"
                 , fm.pdc_4        as "pdc_4"
                 , fm.pdc_5        as "pdc_5"
                 , fm.pdc_6        as "pdc_6"
                 , fm.pdc_7        as "pdc_7"
                 , fm.pdc_8        as "pdc_8"
                 , fm.pdc_9        as "pdc_9"
                 , fm.pdc_10       as "pdc_10"
                 , fm.pdc_11       as "pdc_11"
                 , fm.pdc_12       as "pdc_12"
               ) as "pdc"
           )
         , ff.flexible_fields_xml
         , tg.tags_xml
       )).getclobval()
  from h2h_fin_message fm
     , h2h_card        c
     , (
        select fd.object_id
             , xmlagg(
                   xmlelement("flexible_field"
                     , xmlelement("field_name",  ff.name)
                     , xmlelement("field_value", fd.field_value)
                   )
               ) as flexible_fields_xml
          from com_flexible_field ff
             , com_flexible_data fd
         where fd.field_id = ff.id
           and fd.field_value is not null
           and fd.object_id in (select column_value from table(cast(i_fin_id_tab as num_tab_tpt)))
         group by
               fd.object_id
       ) ff
     , (
        select tv.fin_id
             , xmlagg(
                   xmlelement("tag"
                     , xmlelement("tag_name",  t.tag)
                     , xmlelement("tag_value", tv.tag_value)
                   )
               ) as tags_xml
          from h2h_tag t
             , h2h_tag_value tv
         where t.id = tv.tag_id
           and tv.fin_id in (select column_value from table(cast(i_fin_id_tab as num_tab_tpt)))
         group by
               tv.fin_id
       ) tg
 where fm.id in (select column_value from table(cast(i_fin_id_tab as num_tab_tpt)))
   and fm.id  = ff.object_id(+)
   and fm.id  = tg.fin_id(+)
   and fm.id  = c.id(+)
;

function get_xml_header(
    i_file_rec          in      h2h_api_type_pkg.t_h2h_file_rec
) return clob
is
begin
    return com_api_const_pkg.XML_HEADER
        || '<clearing xmlns="http://bpc.ru/sv/SVXP/clearing">'
        || '<file_type>'      || i_file_rec.file_type        || '</file_type>'
        || '<file_date>'      || to_char(i_file_rec.file_date, com_api_const_pkg.XML_DATE_FORMAT) || '</file_date>'
        || '<forw_inst_code>'   || i_file_rec.forw_inst_code   || '</forw_inst_code>'
        || '<receiv_inst_code>' || i_file_rec.receiv_inst_code || '</receiv_inst_code>'
        || '<file_id>'        || i_file_rec.id               || '</file_id>';
end;

function get_xml_trailer
return clob is
begin
    return '</clearing>';
end;

/*
 * Unloading (export) of an outgoing H2H clearing file.
 * @param i_inst_id - it defines for which institution an outgoing file(s) is(are) created;
 *     the process gets a value of H2H standard parameter H2H_INST_CODE by the host
 *     of the institution (i_inst_id), then it unloads H2H messages by creating a separate
 *     outgoing file for every forwarding institution (h2h_fin_message.forw_inst_code)
 */
procedure process(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_network_id        in      com_api_type_pkg.t_network_id
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name       := lower($$PLSQL_UNIT) || '.process';
    l_record_count              com_api_type_pkg.t_count      := 0;
    l_current_count             com_api_type_pkg.t_count      := 0;
    l_host_id                   com_api_type_pkg.t_tiny_id;
    l_standard_id               com_api_type_pkg.t_tiny_id;
    l_xml                       clob;
    l_file_rec                  h2h_api_type_pkg.t_h2h_file_rec;
    l_forw_inst_code_tab        h2h_api_type_pkg.t_inst_code_tab;
    l_cnt_tab                   num_tab_tpt                   := new num_tab_tpt();
    l_fin_id_tab                num_tab_tpt                   := num_tab_tpt();
    l_param_tab                 com_api_type_pkg.t_param_tab;
begin
    savepoint h2h_outgoing_start;

    prc_api_stat_pkg.log_start();

    if i_inst_id in (ost_api_const_pkg.DEFAULT_INST, ost_api_const_pkg.UNIDENTIFIED_INST) then
        com_api_error_pkg.raise_error(
            i_error      => 'H2H_INVALID_INSTITUTION'
          , i_env_param1 => i_inst_id
        );
    else
        l_file_rec.inst_id    := i_inst_id; -- receiving institution
        l_file_rec.network_id := i_network_id;
    end if;

    l_host_id :=
        net_api_network_pkg.get_default_host(
            i_network_id  => i_network_id
        );
    l_standard_id :=
        net_api_network_pkg.get_offline_standard(
            i_host_id     => l_host_id
        );

    l_file_rec.receiv_inst_code :=
        cmn_api_standard_pkg.get_varchar_value(
            i_inst_id      => i_inst_id
          , i_standard_id  => l_standard_id
          , i_object_id    => l_host_id
          , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_param_name   => h2h_api_const_pkg.H2H_INST_CODE
          , i_param_tab    => l_param_tab
        );

    if l_file_rec.receiv_inst_code is null then
        com_api_error_pkg.raise_error(
            i_error        => 'STANDARD_PARAM_NOT_FOUND'
          , i_env_param1   => h2h_api_const_pkg.H2H_INST_CODE
          , i_env_param2   => i_inst_id
          , i_env_param3   => l_standard_id
          , i_env_param4   => l_host_id
        );
    end if;

    l_file_rec.file_type   := h2h_api_const_pkg.FILE_TYPE_H2H;
    l_file_rec.is_incoming := com_api_type_pkg.FALSE;
    l_file_rec.is_rejected := com_api_type_pkg.FALSE;
    l_file_rec.network_id  := i_network_id;
    l_file_rec.inst_id     := i_inst_id;

    open cur_file(
        i_network_id       => i_network_id
      , i_inst_id          => i_inst_id
      , i_receiv_inst_code => l_file_rec.receiv_inst_code
    );
    fetch cur_file
     bulk collect
     into l_forw_inst_code_tab
        , l_cnt_tab
    ;
    close cur_file;

    l_record_count := case when l_cnt_tab.exists(1) then l_cnt_tab(1) else 0 end;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_record_count
    );

    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || ': [#1] H2H messages in [#2] forwarding institutions were fetched'
      , i_env_param1  => l_record_count
      , i_env_param2  => l_forw_inst_code_tab.count()
    );

    for i in 1 .. l_forw_inst_code_tab.count() loop
        -- Fetch and save H2H messages with every new <forw_inst_code> in a separate file
        l_file_rec.forw_inst_code   := l_forw_inst_code_tab(i);
        l_file_rec.file_date        := com_api_sttl_day_pkg.get_sysdate();
        l_file_rec.proc_date        := l_file_rec.file_date;
        l_file_rec.session_file_id  := null;

        l_record_count := 0;

        open cur_fin_id(i_file_rec => l_file_rec);

        loop
            fetch cur_fin_id
             bulk collect
             into l_fin_id_tab
            limit BULK_LIMIT;

            open  cur_fin_message_xml(i_fin_id_tab => l_fin_id_tab);
            fetch cur_fin_message_xml into l_xml;
            close cur_fin_message_xml;

            if l_file_rec.session_file_id is null then
                prc_api_file_pkg.open_file(
                    o_sess_file_id  => l_file_rec.session_file_id
                );

                l_file_rec.id := h2h_api_fin_message_pkg.put_file(i_file_rec => l_file_rec);

                prc_api_file_pkg.put_file(
                    i_sess_file_id  => l_file_rec.session_file_id
                  , i_clob_content  => get_xml_header(i_file_rec => l_file_rec)
                  , i_add_to        => com_api_const_pkg.FALSE
                );

                trc_log_pkg.debug(
                    i_text          => LOG_PREFIX || ': session file ID [#1] was opened for forw_inst_code [#2]'
                  , i_env_param1    => l_file_rec.session_file_id
                  , i_env_param2    => l_file_rec.forw_inst_code
                );
            end if;

            l_record_count  := l_record_count  + l_fin_id_tab.count();
            l_current_count := l_current_count + l_fin_id_tab.count();

            prc_api_file_pkg.put_file(
                i_sess_file_id   => l_file_rec.session_file_id
              , i_clob_content   => l_xml
              , i_add_to         => com_api_const_pkg.TRUE
            );

            prc_api_stat_pkg.log_current(
                i_current_count  => l_current_count
              , i_excepted_count => 0
            );

            forall i in 1 .. l_fin_id_tab.count()
                update h2h_fin_message m
                   set status  = net_api_const_pkg.CLEARING_MSG_STATUS_UPLOADED
                     , file_id = l_file_rec.id
                 where m.id    = l_fin_id_tab(i);

            trc_log_pkg.debug(
                i_text        => LOG_PREFIX || ': [#1] messages added to session file ID [#2]; [#3] messages in total'
              , i_env_param1  => l_fin_id_tab.count()
              , i_env_param2  => l_file_rec.session_file_id
              , i_env_param3  => l_record_count
            );

            l_fin_id_tab.delete();

            exit when cur_fin_id%notfound;
        end loop;

        close cur_fin_id;

        prc_api_file_pkg.put_file(
            i_sess_file_id  => l_file_rec.session_file_id
          , i_clob_content  => get_xml_trailer()
          , i_add_to        => com_api_const_pkg.TRUE
        );
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_file_rec.session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
          , i_record_count  => l_record_count
        );

        trc_log_pkg.debug(
            i_text          => LOG_PREFIX || ': session file ID [#1] was closed'
          , i_env_param1    => l_file_rec.session_file_id
        );
    end loop;

    prc_api_stat_pkg.log_end(
        i_processed_total  => l_current_count
      , i_excepted_total   => 0
      , i_rejected_total   => 0
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
    when others then
        rollback to savepoint h2h_outgoing_start;

        if cur_file%isopen then
            close cur_file;
        end if;
        if cur_fin_id%isopen then
            close cur_fin_id;
        end if;
        if cur_fin_message_xml%isopen then
            close cur_fin_message_xml;
        end if;

        prc_api_stat_pkg.log_end(
            i_processed_total  => l_current_count
          , i_excepted_total   => 0
          , i_rejected_total   => 0
          , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if  com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
            or
            com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
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
