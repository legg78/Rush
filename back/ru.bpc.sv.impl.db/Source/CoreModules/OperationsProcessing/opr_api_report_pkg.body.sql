create or replace package body opr_api_report_pkg is

    procedure clearing_messages_card_absent (
        o_xml                   out clob
        , i_network_id          in com_api_type_pkg.t_tiny_id
        , i_inst_id             in com_api_type_pkg.t_inst_id := null
        , i_start_date          in date
        , i_end_date            in date
        , i_lang                in com_api_type_pkg.t_dict_value
    ) is
        l_start_date            date;
        l_end_date              date;
        l_lang                  com_api_type_pkg.t_dict_value;
        l_inst_id               com_api_type_pkg.t_inst_id;
        l_header                xmltype;
        l_detail                xmltype;
        l_result                xmltype;
    begin
        trc_log_pkg.debug (
            i_text          => 'clearing messages with card absent [#1][#2][#3]'
            , i_env_param1  => com_api_type_pkg.convert_to_char(trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate)))
            , i_env_param2  => com_api_type_pkg.convert_to_char(nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND)
            , i_env_param3  => nvl(i_lang, get_user_lang)
        );

        l_lang := nvl(i_lang, get_user_lang);
        l_start_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
        l_end_date := nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;

        l_inst_id := i_inst_id;
        if i_inst_id is null then
            l_inst_id := net_api_network_pkg.get_inst_id(i_network_id => i_network_id);
        end if;

        begin
            -- header
            select
                xmlconcat(
                    xmlelement("start_date", to_char(t.start_date, 'dd.mm.yyyy'))
                    , xmlelement("end_date", to_char(t.end_date, 'dd.mm.yyyy'))
                    , xmlelement("curr_date", to_char(t.curr_date, 'dd.mm.yyyy hh24:mi:ss'))
                    , xmlelement("network_name", t.network_name)
                    , xmlelement("inst_name", t.inst_name)
                )
            into
                l_header
            from (
                select
                    l_start_date start_date
                    , l_end_date end_date
                    , get_sysdate curr_date
                    , get_text('net_network','name', i_network_id, l_lang) network_name
                    , get_text('ost_institution', 'name', l_inst_id, l_lang) inst_name
                from
                    dual
            ) t;
        exception
            when no_data_found then
                null;
        end;

        -- details
        select
            xmlagg(
                xmlelement("operation"
                    , xmlelement("card_number", x.card_number)
                    , xmlelement("operation_id", x.operation_id)
                    , xmlelement("oper_date", to_char(x.oper_date, 'dd.mm.yyyy'))
                    , xmlelement("host_date", to_char(x.host_date, 'dd.mm.yyyy'))
                    , xmlelement("oper_amount", x.oper_amount)
                    , xmlelement("oper_currency", x.oper_currency)
                    , xmlelement("oper_desc", nvl(cst_api_operation_pkg.build_operation_desc(x.operation_id), x.oper_desc))
                    , xmlelement("network_desc", x.network_name)
                    , xmlelement("inst_desc", x.inst_name)
                )
                order by
                    x.oper_date
                    , x.operation_id
            )
        into
            l_detail
        from (
            select
                op.id operation_id
                , op.oper_date
                , op.host_date
                , com_api_currency_pkg.get_amount_str(op.oper_amount, op.oper_currency, com_api_type_pkg.TRUE) oper_amount
                , c.name oper_currency
                , op.network_id
                , get_text('net_network','name', op.network_id, l_lang) network_name
                , op.inst_id
                , get_text('ost_institution', 'name', op.inst_id, l_lang) inst_name
                , iss_api_card_pkg.get_card_mask(op.card_number) as card_number
                , get_article_desc(op.oper_type)
                  ||'-'||op.merchant_name
                  ||'\'||op.merchant_postcode
                  ||'\'||op.merchant_street
                  ||'\'||op.merchant_city
                  ||'\'||op.merchant_region
                  ||'\'||op.merchant_country
                oper_desc
            from (
                select
                    o.*
                    , i.network_id
                    , i.inst_id
                    , c.card_number
                from 
                    opr_operation o
                    , opr_participant i
                    , vis_fin_message f
                    , vis_card c
                where
                    i.oper_id = o.id 
                    and i.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                    and i.network_id = i_network_id
                    and i.inst_id = l_inst_id
                    and o.oper_date between l_start_date and l_end_date
                    and f.id = o.id
                    and c.id(+) = f.id
                    and f.is_incoming = com_api_type_pkg.TRUE
                    and nvl(o.proc_mode, aut_api_const_pkg.DEFAULT_AUTH_PROC_MODE) = aut_api_const_pkg.AUTH_PROC_MODE_CARD_ABSENT
                union all
                select
                    o.*
                    , i.network_id
                    , i.inst_id
                    , c.card_number
                from 
                    opr_operation o
                    , opr_participant i
                    , mcw_fin f
                    , mcw_card c
                where
                    i.oper_id = o.id 
                    and i.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                    and i.network_id = i_network_id
                    and i.inst_id = l_inst_id
                    and o.oper_date between l_start_date and l_end_date
                    and f.id = o.id
                    and c.id(+) = f.id
                    and f.is_incoming = com_api_type_pkg.TRUE
                    and nvl(o.proc_mode, aut_api_const_pkg.DEFAULT_AUTH_PROC_MODE) = aut_api_const_pkg.AUTH_PROC_MODE_CARD_ABSENT
                ) op
                , com_currency c
            where
                c.code(+) = op.oper_currency
        ) x;

        select
            xmlelement (
                "report"
                , l_header
                , xmlelement("operations", nvl(l_detail, xmlelement("operation", '')))
            ) r
        into
            l_result
        from
            dual;

        o_xml := l_result.getclobval();

        trc_log_pkg.debug (
            i_text => 'clearing messages with card absent - ok'
        );
    exception
        when others then
            trc_log_pkg.debug (
                i_text   => sqlerrm
            );
            raise;
    end;

    procedure merchant_purchase_totals(
        o_xml                 out clob
      , i_network_id        in    com_api_type_pkg.t_network_id
      , i_start_date        in    date                             default null
      , i_end_date          in    date                             default null
      , i_lang              in    com_api_type_pkg.t_dict_value
    ) is
        l_start_date              date;
        l_end_date                date;
        l_lang                    com_api_type_pkg.t_dict_value;
        l_header                  xmltype;
        l_detail                  xmltype;
        l_result                  xmltype;
        l_date                    date;
    begin

        l_lang          := coalesce(i_lang, get_user_lang, com_api_const_pkg.DEFAULT_LANGUAGE);
        l_start_date    := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
        l_end_date      := nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;
        l_date          := get_sysdate;

        begin
            select
                xmlelement("parameters"
                  , xmlconcat(
                        xmlelement("p_start_date",   to_char(l_start_date, rpt_api_const_pkg.DATE_FORMAT))
                      , xmlelement("p_end_date",     to_char(l_end_date,   rpt_api_const_pkg.DATE_FORMAT))
                      , xmlelement("p_curr_date",    to_char(curr_date,    rpt_api_const_pkg.DATETIME_FORMAT))
                      , xmlelement("p_network_id",   i_network_id)
                      , xmlelement("p_network_name", network_name)
                ))
            into
                l_header
            from(
                select
                    l_date                                                curr_date
                  , get_text('net_network', 'name', i_network_id, l_lang) network_name
                from
                    dual
            );
        exception
            when no_data_found then
                null;
        end;

        select xmlelement("operations",
                   nvl(
                       xmlagg(
                           xmlelement("operation"
                             , xmlelement("bin",                       xx.card_bin)
                             , xmlelement("currency",                  xx.oper_currency_name)
                             , xmlelement("transactions_count",        xx.count_oper_by_bin_currency)
                             , xmlelement("transactions_total_amount", to_char(xx.sum_oper_amount_by_bin_currenc / power(10, oper_currency_exponent), oper_currency_format))
                       ))
                     , xmlelement("operation")
                   )
               )
        into l_detail
        from(
             select distinct
                    iss_api_bin_pkg.get_bin_number(i_bin_id => ci.bin_id)                           card_bin
                  , cu.name                                                                         oper_currency_name
                  , com_api_const_pkg.XML_NUMBER_FORMAT || decode(nvl(cu.exponent,0), 0, null
                                                             , '.' || lpad('0',cu.exponent,'0'))    oper_currency_format
                  , cu.exponent                                                                     oper_currency_exponent
                  , sum(op.oper_amount) over(partition by ci.bin_id, op.oper_currency)              sum_oper_amount_by_bin_currenc
                  , count(1)            over(partition by ci.bin_id, op.oper_currency)              count_oper_by_bin_currency
               from opr_operation     op
                  , opr_participant   pa
                  , iss_card          ca
                  , iss_card_instance ci
                  , com_currency      cu
              where pa.network_id = i_network_id
                and op.oper_type in (
                        opr_api_const_pkg.OPER_TYPE_SALE_GOODS_SERVICE
                      , opr_api_const_pkg.OPER_TYPE_CASH_OUT_AT_AGENT
                                    )
                and pa.oper_id = op.id
                and pa.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                and pa.client_id_type = opr_api_const_pkg.CLIENT_ID_TYPE_CARD
                and ca.id = pa.card_id
                and ci.card_id = ca.id
                and cu.code = op.oper_currency
                and op.oper_date between l_start_date and l_end_date
                and op.status = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
              order by card_bin
        ) xx;

        select
            xmlelement("report"
              , l_header
              , l_detail
            )
        into
            l_result
        from
            dual;

        o_xml := l_result.getclobval();

        trc_log_pkg.debug('merchant_purchase_totals');

    end merchant_purchase_totals;

    procedure merchant_purchase_details(
        o_xml                 out clob
      , i_network_id        in    com_api_type_pkg.t_network_id
      , i_start_date        in    date                             default null
      , i_end_date          in    date                             default null
      , i_bin               in    com_api_type_pkg.t_bin
      , i_lang              in    com_api_type_pkg.t_dict_value
    ) is
        l_start_date              date;
        l_end_date                date;
        l_lang                    com_api_type_pkg.t_dict_value;
        l_header                  xmltype;
        l_detail                  xmltype;
        l_result                  xmltype;
        l_date                    date;
    begin

        l_lang          := coalesce(i_lang, get_user_lang, com_api_const_pkg.DEFAULT_LANGUAGE);
        l_start_date    := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
        l_end_date      := nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;
        l_date          := get_sysdate;

        begin
            select
                xmlelement("parameters"
                  , xmlconcat(
                        xmlelement("p_start_date",   to_char(l_start_date, rpt_api_const_pkg.DATE_FORMAT))
                      , xmlelement("p_end_date",     to_char(l_end_date,   rpt_api_const_pkg.DATE_FORMAT))
                      , xmlelement("p_curr_date",    to_char(curr_date,    rpt_api_const_pkg.DATETIME_FORMAT))
                      , xmlelement("p_network_id",   i_network_id)
                      , xmlelement("p_network_name", network_name)
                      , xmlelement("p_bin",          i_bin)
                ))
            into
                l_header
            from(
                select
                    l_date                                                curr_date
                  , get_text('net_network', 'name', i_network_id, l_lang) network_name
                from
                    dual
            );
        exception
            when no_data_found then
                null;
        end;

        select xmlelement("operations",
                   nvl(
                       xmlagg(
                           xmlelement("operation"
                             , xmlelement("bin",                   xx.bin)
                             , xmlelement("card_number",           xx.card_number)
                             , xmlelement("operation_type",        xx.oper_type)
                             , xmlelement("operation_date",        to_char(xx.oper_date, rpt_api_const_pkg.DATE_FORMAT))
                             , xmlelement("operation_amount",      to_char(xx.oper_amount / power(10, oper_currency_exponent), oper_currency_format))
                             , xmlelement("operation_currency",    xx.oper_currency_name)
                             , xmlelement("operation_id",          xx.oper_id)
                             , xmlelement("is_reversal",           xx.is_reversal)
                             , xmlelement("merchant_number",       xx.merchant_number)
                             , xmlelement("terminal_number",       xx.terminal_number)
                             , xmlelement("mcc",                   xx.mcc)
                             , xmlelement("merchant_address",      xx.merchant_address)
                       ))
                     , xmlelement("operation")
                   )
               )
        into l_detail
        from(
            select iss_api_bin_pkg.get_bin_number(i_bin_id => ci.bin_id)                           bin
                 , cn.card_number
                 , op.oper_type
                 , op.oper_date
                 , op.oper_amount
                 , op.oper_currency
                 , op.id                                                                           oper_id
                 , op.is_reversal
                 , op.merchant_number
                 , op.terminal_number
                 , op.merchant_region
                 , op.mcc
                 , com_api_address_pkg.get_address_string(
                       i_address_id    => acq_api_merchant_pkg.get_merchant_address_id(
                                              i_merchant_id => me.id
                                            , i_lang        => l_lang
                                          )
                     , i_lang          =>  l_lang
                   )                                                                               merchant_address
                 , cu.name                                                                         oper_currency_name
                 , com_api_const_pkg.XML_NUMBER_FORMAT || decode(nvl(cu.exponent,0), 0, null
                                                            , '.' || lpad('0',cu.exponent,'0'))    oper_currency_format
                 , cu.exponent                                                                     oper_currency_exponent
              from opr_operation     op
                 , opr_participant   pa
                 , iss_card          ca
                 , iss_card_instance ci
                 , iss_card_number   cn
                 , com_currency      cu
                 , acq_merchant      me
             where iss_api_bin_pkg.get_bin_number(i_bin_id => ci.bin_id) = i_bin
               and op.oper_type in(
                       opr_api_const_pkg.OPER_TYPE_SALE_GOODS_SERVICE
                     , opr_api_const_pkg.OPER_TYPE_CASH_OUT_AT_AGENT
                                  )
               and pa.oper_id = op.id 
               and pa.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
               and pa.client_id_type = opr_api_const_pkg.CLIENT_ID_TYPE_CARD
               and ca.id = pa.card_id
               and ci.card_id = ca.id
               and cn.card_id = ca.id
               and cu.code = op.oper_currency
               and op.oper_date between l_start_date and l_end_date
               and op.status = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
               and me.merchant_number = op.merchant_number
             order by op.oper_date
        ) xx;

        select
            xmlelement("report"
              , l_header
              , l_detail
            )
        into
            l_result
        from
            dual;

        o_xml := l_result.getclobval();

        trc_log_pkg.debug('merchant_purchase_totals');

    end merchant_purchase_details;

end;
/
