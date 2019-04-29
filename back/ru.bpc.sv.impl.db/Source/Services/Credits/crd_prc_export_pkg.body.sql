create or replace package body crd_prc_export_pkg is

procedure process_account(
    i_inst_id       in  com_api_type_pkg.t_inst_id      default ost_api_const_pkg.DEFAULT_INST
  , i_account_type  in  com_api_type_pkg.t_dict_value   default acc_api_const_pkg.ACCOUNT_TYPE_CREDIT
  , i_full_export   in  com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
) is
    l_processed_count           com_api_type_pkg.t_long_id := 0;
    l_excepted_count            com_api_type_pkg.t_long_id := 0;
    l_sess_file_id              com_api_type_pkg.t_long_id;
    l_xml                       xmltype;
    l_file                      clob;

    l_event_tab                 com_api_type_pkg.t_long_tab;
    l_account_id_tab            num_tab_tpt;
    l_account_number_tab        com_api_type_pkg.t_account_number_tab;
    l_currency_tab              com_api_type_pkg.t_curr_code_tab;
    c_crlf           constant   com_api_type_pkg.t_name := chr(13)||chr(10);

    l_alg_calc_intr             com_api_type_pkg.t_dict_value;
    l_sttl_date                 date;
    l_interests_num             com_api_type_pkg.t_money := 0;
    l_mad_amount                com_api_type_pkg.t_money := 0;
    l_unpaid_mad_amount         com_api_type_pkg.t_money := 0;
    l_overdue_age               com_api_type_pkg.t_tiny_id;
    l_mad_date                  date;
    l_grace_date                date;
    l_start_date                date;

    l_invoice_id                com_api_type_pkg.t_medium_id;
    l_service_id                com_api_type_pkg.t_short_id;

    l_product_id_tab            com_api_type_pkg.t_short_tab;
    l_split_hash_tab            com_api_type_pkg.t_tiny_tab;
    l_param_tab                 com_api_type_pkg.t_param_tab;

    l_total_interest            com_api_type_pkg.t_money;
    l_interest_amount           com_api_type_pkg.t_money;

    l_account_tab crd_account_tpt := crd_account_tpt();
    l_account_record  crd_account_tpr := crd_account_tpr(null, null, null, null, null, null, null, null, null, null);

    cursor cu_event_objects is
        select eo.id
             , a.id
             , a.account_number
             , a.currency
             , c.product_id
             , a.split_hash
          from evt_event_object eo
             , acc_account a
             , prd_contract c
         where eo.procedure_name  = 'CRD_PRC_EXPORT_PKG.PROCESS_ACCOUNT'
           and eo.entity_type     = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
           and eo.eff_date       <= com_api_sttl_day_pkg.get_sysdate
           and eo.object_id       = a.id
           and a.contract_id      = c.id
           and (a.account_type = i_account_type or i_account_type is null)
           and ost_api_institution_pkg.get_sandbox(eo.inst_id) = ost_api_institution_pkg.get_sandbox(i_inst_id);

    cursor cu_all_accounts is
        select a.id
             , a.account_number
             , a.currency
             , c.product_id
             , a.split_hash
          from acc_account a
             , prd_contract c
         where ost_api_institution_pkg.get_sandbox(a.inst_id) = ost_api_institution_pkg.get_sandbox(i_inst_id)
           and a.contract_id = c.id
           and (a.account_type = i_account_type or i_account_type is null);

begin
    trc_log_pkg.debug(
        i_text          => 'crd_prc_export_pkg.process_account; inst_id [#1], account_type [#2], full_export [#3]'
      , i_env_param1    => i_inst_id
      , i_env_param2    => i_account_type
      , i_env_param3    => i_full_export
    );

    prc_api_stat_pkg.log_start;

    savepoint sp_accounts_export;

    if i_full_export = com_api_const_pkg.TRUE then
        delete from evt_event_object
         where procedure_name  = 'CRD_PRC_EXPORT_PKG.PROCESS_ACCOUNT'
           and entity_type     = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
           and eff_date       <= com_api_sttl_day_pkg.get_sysdate
           and object_id      in (select id from acc_account where account_type = i_account_type or i_account_type is null)
           and ost_api_institution_pkg.get_sandbox(inst_id) = ost_api_institution_pkg.get_sandbox(i_inst_id);

        open cu_all_accounts;
        fetch cu_all_accounts bulk collect
         into l_account_id_tab
            , l_account_number_tab
            , l_currency_tab
            , l_product_id_tab
            , l_split_hash_tab;
        close cu_all_accounts;

    else
        open cu_event_objects;
        fetch cu_event_objects bulk collect
         into l_event_tab
            , l_account_id_tab
            , l_account_number_tab
            , l_currency_tab
            , l_product_id_tab
            , l_split_hash_tab;
        close cu_event_objects;

    end if;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count     => l_account_id_tab.count
    );

    -- Get settlement date
    l_sttl_date := com_api_sttl_day_pkg.get_open_sttl_date(i_inst_id);

    for i in 1 .. l_account_id_tab.count loop
        begin
            select id
                 , nvl(min_amount_due, 0)
                 , nvl(aging_period, 0)
                 , grace_date
                 , invoice_date
                 , due_date
              into l_invoice_id
                 , l_mad_amount
                 , l_overdue_age
                 , l_grace_date
                 , l_start_date
                 , l_mad_date
              from crd_invoice
             where id = (select max(id) from crd_invoice where account_id = l_account_id_tab(i) and invoice_date <= l_sttl_date and split_hash = l_split_hash_tab(i));

        exception
            when no_data_found then
                l_invoice_id    := null;
                l_overdue_age   := null;
                l_mad_amount    := null;
                l_grace_date    := null;
                l_mad_date      := null;
                --
                begin
                    select o.start_date
                      into l_start_date
                      from prd_service_object o
                         , prd_service s
                     where o.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                       and o.object_id = l_account_id_tab(i)
                       and s.id = o.service_id
                       and s.service_type_id = crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID;
                exception
                    when no_data_found then
                        com_api_error_pkg.raise_error (
                            i_error         => 'ACCOUNT_SERVICE_NOT_FOUND'
                            , i_env_param1  => l_account_id_tab(i)
                            , i_env_param2  => crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
                        );
                end;
        end;

        -- Get credit service ID
        l_service_id := prd_api_service_pkg.get_active_service_id (
            i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => l_account_id_tab(i)
          , i_attr_name         => null
          , i_service_type_id   => crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
          , i_split_hash        => l_split_hash_tab(i)
          , i_eff_date          => null
          , i_mask_error        => com_api_type_pkg.TRUE
          , i_inst_id           => i_inst_id
        );

        -- Load debt params
        crd_cst_debt_pkg.load_debt_param (
            i_account_id => l_account_id_tab(i)
          , i_product_id => l_product_id_tab(i)
          , i_split_hash => l_split_hash_tab(i)
          , io_param_tab => l_param_tab
        );

        -- Get algorithm ACIL
        begin
            l_alg_calc_intr := nvl(prd_api_product_pkg.get_attr_value_char (
                i_product_id    => l_product_id_tab(i)
              , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id     => l_account_id_tab(i)
              , i_attr_name     => crd_api_const_pkg.ALGORITHM_CALC_INTEREST
              , i_split_hash    => l_split_hash_tab(i)
              , i_service_id    => l_service_id
              , i_params        => l_param_tab
            ), crd_api_const_pkg.ALGORITHM_CALC_INTR_STANDARD);
        exception
            when com_api_error_pkg.e_application_error then
                if com_api_error_pkg.get_last_error = 'ATTRIBUTE_VALUE_NOT_DEFINED' then
                    trc_log_pkg.debug('Attribute value [CRD_ALGORITHM_CALC_INTEREST] not defined. Set algorithm = ACIL0001');
                    l_alg_calc_intr := crd_api_const_pkg.ALGORITHM_CALC_INTR_STANDARD;
                else
                    raise;
                end if;
            when others then
                trc_log_pkg.debug('Get attribute value error. '||sqlerrm);
                raise;
        end;

        -- Get sum of not charged interests
        l_interests_num := crd_api_report_pkg.calculate_interest (
            i_account_id    => l_account_id_tab(i)
          , i_eff_date      => l_sttl_date
          , i_split_hash    => l_split_hash_tab(i)
          , i_service_id    => l_service_id
          , i_product_id    => l_product_id_tab(i)
          , i_alg_calc_intr => l_alg_calc_intr
        );

        trc_log_pkg.debug('Add account into table l_account_tab.');
        l_account_tab.extend(1);
        l_account_tab(l_account_tab.count) := l_account_record;
        l_account_tab(l_account_tab.count).id := l_account_id_tab(i);
        l_account_tab(l_account_tab.count).account_number := l_account_number_tab(i);
        l_account_tab(l_account_tab.count).currency := l_currency_tab(i);
        l_account_tab(l_account_tab.count).sttl_date := l_sttl_date;
        l_account_tab(l_account_tab.count).unpaid_interest_amount := nvl(l_interests_num, 0);
        l_account_tab(l_account_tab.count).mad_amount := nvl(l_mad_amount, 0);
        l_account_tab(l_account_tab.count).unpaid_mad_amount := nvl(l_unpaid_mad_amount, 0);
        l_account_tab(l_account_tab.count).overdue_age := l_overdue_age;
        l_account_tab(l_account_tab.count).mad_date := l_mad_date;
        l_account_tab(l_account_tab.count).grace_date := l_grace_date;
        trc_log_pkg.debug('End add account into table l_account_tab.');

        l_processed_count   := l_processed_count + 1;

        if mod(i, 100) = 0 then
            prc_api_stat_pkg.log_current (
                i_current_count     => l_processed_count
              , i_excepted_count    => l_excepted_count
            );
        end if;

    end loop;

    trc_log_pkg.debug('Loaded l_account_tab. l_account_tab.count='||l_account_tab.count);

    if l_processed_count > 0 then
        if i_full_export = com_api_const_pkg.FALSE then
            forall i in 1 .. l_event_tab.count
                delete from evt_event_object where id = l_event_tab(i);

        end if;

        --generate xml
        select
            xmlagg(
              xmlelement("account"
                , xmlattributes(to_char(t.id, com_api_const_pkg.XML_NUMBER_FORMAT) as "id")
                , xmlelement("account_number", t.account_number)
                , xmlelement("currency", t.currency)
                , xmlelement("credit"
                    , xmlforest(
                        to_char(t.sttl_date,                      com_api_const_pkg.XML_DATE_FORMAT)   as "sttl_date"
                      , to_char(t.unpaid_interest_amount,         com_api_const_pkg.XML_NUMBER_FORMAT) as "unpaid_interest_amount"
                      , to_char(t.mad_amount,                     com_api_const_pkg.XML_NUMBER_FORMAT) as "mad_amount"
                      , to_char(t.unpaid_mad_amount,              com_api_const_pkg.XML_NUMBER_FORMAT) as "unpaid_mad_amount"
                      , to_char(t.overdue_age,                    com_api_const_pkg.XML_NUMBER_FORMAT) as "overdue_age"
                      , to_char(t.mad_date,                       com_api_const_pkg.XML_DATE_FORMAT)   as "mad_date"
                      , to_char(t.grace_date,                     com_api_const_pkg.XML_DATE_FORMAT)   as "grace_date"
                    )
                  )
              )
            )
            into l_xml
            from (select id
                       , account_number
                       , currency
                       , sttl_date
                       , unpaid_interest_amount
                       , mad_amount
                       , unpaid_mad_amount
                       , overdue_age
                       , mad_date
                       , grace_date
                    from table(cast(l_account_tab as crd_account_tpt))
            ) t;

        prc_api_file_pkg.open_file (
            o_sess_file_id  => l_sess_file_id
        );

        l_file  := com_api_const_pkg.XML_HEADER || c_crlf
                || '<accounts xmlns="http://bpc.ru/sv/SVXP/account">' || c_crlf
                    || '<file_id>' || l_sess_file_id || '</file_id>' || c_crlf
                    || '<file_type>' || acc_api_const_pkg.FILE_TYPE_ACCOUNTS || '</file_type>' || c_crlf
                    || l_xml.getclobval()
                || '</accounts>';

        prc_api_file_pkg.put_file (
            i_sess_file_id    => l_sess_file_id
            , i_clob_content  => l_file
        );

        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_sess_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );

    end if;

    prc_api_stat_pkg.log_end (
        i_excepted_total     => l_excepted_count
        , i_processed_total  => l_processed_count
        , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
    when others then
        rollback to savepoint sp_accounts_export;

        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
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

end process_account;

procedure export_closed_cards (
    i_card_inst_id          in com_api_type_pkg.t_inst_id
  , i_start_date            in date
  , i_end_date              in date
)
is
    -- For report 3 "Cards closed by overdued credit(aging>=5)" (Credit card close report.xls)
    LIMIT_SIZE       constant com_api_type_pkg.t_tiny_id := 100;

    l_start_date              date;
    l_end_date                date;
    l_processed_count         com_api_type_pkg.t_long_id;
    l_sess_file_id            com_api_type_pkg.t_long_id;
    l_file                    clob;
    l_card                    xmltype;
    l_cards                   xmltype;

    -- tabs for cursor
    l_card_instance_id        com_api_type_pkg.t_number_tab;
    l_card_id                 com_api_type_pkg.t_number_tab;
    l_card_mask               com_api_type_pkg.t_card_number_tab;
    l_bin                     com_api_type_pkg.t_name_tab;
    l_cardholder_name         com_api_type_pkg.t_name_tab;
    l_first_name              com_api_type_pkg.t_name_tab;
    l_surname                 com_api_type_pkg.t_name_tab;
    l_oper_id                 com_api_type_pkg.t_number_tab;
    l_oper_date               com_api_type_pkg.t_date_tab;
    l_terminal_number         com_api_type_pkg.t_name_tab;
    l_inst_id                 com_api_type_pkg.t_inst_id_tab;
    l_trans_type              com_api_type_pkg.t_dict_tab;
    l_oper_currency           com_api_type_pkg.t_curr_code_tab;
    l_oper_amount             com_api_type_pkg.t_money_tab;
    l_sttl_type               com_api_type_pkg.t_dict_tab;
    l_sttl_currency           com_api_type_pkg.t_curr_code_tab;
    l_sttl_amount             com_api_type_pkg.t_money_tab;
    l_account_id              com_api_type_pkg.t_number_tab;
    l_account_number          com_api_type_pkg.t_account_number_tab;
    l_event_object_id         com_api_type_pkg.t_number_tab;
    l_lang                    com_api_type_pkg.t_dict_value;

    cursor overdued_accounts_cur (
        p_start_date          in date
        , p_end_date          in date
    ) is
    with ev as (
        select
        v.id event_object_id
        , acc.id account_id
        , acc.account_number
    from
        evt_event_object v
        , evt_event e
        , crd_invoice inv
        , acc_account acc
        where
        --and DECODE(v.status, 'EVST0001', v.procedure_name, NULL) = 'CRD_API_REPORT_PKG.EXPORT_CLOSED_CARDS'
        v.procedure_name = 'CRD_API_REPORT_PKG.EXPORT_CLOSED_CARDS'
        and nvl(v.status, evt_api_const_pkg.EVENT_STATUS_READY) not in (
          evt_api_const_pkg.EVENT_STATUS_PROCESSED, evt_api_const_pkg.EVENT_STATUS_DO_NOT_PROCES
        )
        --and e.event_type  = crd_api_const_pkg.AGING_5_EVENT           -- 'EVNT1015' -- 'Registering agind period 5 (150-days)'
        --and a.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT     -- 'ENTTACCT'
        and e.event_type  = crd_api_const_pkg.INVOICE_CREATION_EVENT    -- 'EVNT1018' -- 'Credit invoice creation' -- 05.06.2014
        and v.entity_type = crd_api_const_pkg.ENTITY_TYPE_INVOICE       -- 'ENTTINVC' -- 05.06.2014
        and v.eff_date >= p_start_date
        and v.eff_date <= p_end_date
        and v.inst_id = i_card_inst_id
        and v.event_id  = e.id
        and v.object_id = inv.id
        and inv.account_id = acc.id
    )
    select
        a.card_instance_id
        , a.card_id
        , a.card_mask
        , a.bin
        , a.cardholder_name
        , a.first_name
        , a.surname
        , d.id as oper_id
        , d.oper_date
        , opr.terminal_number
        , d.inst_id
        , (select xa.transaction_type
             from acc_entry xa
                , acc_macros xm
            where xa.macros_id = xm.id
              and xm.object_id = opr.id
              and xm.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
            and rownum < 2
        ) as trans_type
        , opr.oper_currency
        , opr.oper_amount
        , opr.sttl_type
        , opr.sttl_currency
        , opr.sttl_amount
        , a.account_id
        , a.account_number
        , a.event_object_id
    from (
        select
            aco.account_id
            , ci.id as card_instance_id
            , crd.id as card_id
            , crd.card_mask
            , ib.bin
            , ch.cardholder_name
            , pt.first_name
            , pt.surname
            , v.account_number
            , v.event_object_id
        from
            ev v
            , acc_account_object aco
            , iss_card crd
            , iss_card_instance ci
            , iss_bin ib
            , iss_cardholder ch
            , (select id, min(lang) keep(dense_rank first order by decode(lang, l_lang, 1, 'LANGENG', 2, 3)) lang from com_person_vw group by id) pt2
            , com_person pt
        where
            aco.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD-- 'ENTTCARD'
            and ci.state = iss_api_const_pkg.CARD_STATE_CLOSED--'CSTE0300' -- include Closed cards
            and aco.account_id = v.account_id
            and aco.object_id = crd.id
            and crd.id = ci.card_id
            and ci.bin_id = ib.id
            and crd.cardholder_id = ch.id(+)
            and pt2.id(+) = ch.person_id
            and pt.id = pt2.id
            and pt.lang = pt2.lang
        ) a
        join crd_debt d on (d.account_id = a.account_id)
        left join opr_operation opr on (d.oper_id = opr.id)
    where
        d.id = (
          select max(dd.id)
            from crd_debt dd
           where dd.account_id = a.account_id
        );

begin
    savepoint export_closed_cards;
    prc_api_stat_pkg.log_start;

    l_processed_count := 0;

    l_start_date := trunc(nvl(i_start_date, get_sysdate));
    l_end_date   := trunc(nvl(i_end_date, l_start_date)) + 1 - com_api_const_pkg.ONE_SECOND;
    l_lang       := com_ui_user_env_pkg.get_user_lang;

    trc_log_pkg.debug ('start_date[' ||com_api_type_pkg.convert_to_char(l_start_date) || '] l_end_date[' || com_api_type_pkg.convert_to_char(l_end_date)||']');

    open overdued_accounts_cur (
        p_start_date  => l_start_date
        , p_end_date  => l_end_date
    );
    loop
        fetch overdued_accounts_cur
        bulk collect into
        l_card_instance_id
        , l_card_id
        , l_card_mask
        , l_bin
        , l_cardholder_name
        , l_first_name
        , l_surname
        , l_oper_id
        , l_oper_date
        , l_terminal_number
        , l_inst_id
        , l_trans_type
        , l_oper_currency
        , l_oper_amount
        , l_sttl_type
        , l_sttl_currency
        , l_sttl_amount
        , l_account_id
        , l_account_number
        , l_event_object_id
        limit LIMIT_SIZE;

        -- export cards
        for i in 1..l_event_object_id.count loop
            select
                xmlelement( "card"
                , xmlelement( "business_date",      to_char(l_oper_date(i), com_api_const_pkg.XML_DATETIME_FORMAT))
                , xmlelement( "txn_date",           to_char(l_oper_date(i), com_api_const_pkg.XML_DATETIME_FORMAT))
                , xmlelement( "cms_trx_n",          to_char(l_oper_id(i)))
                , xmlelement( "bin",                l_bin(i))
                , xmlelement( "card_number",        l_card_mask(i))
                , xmlelement( "cms_account",        l_account_id(i))
                , xmlelement( "branch",             l_inst_id(i))
                , xmlelement( "bank_account",       l_account_number(i))
                , xmlelement( "cardholder_name",    l_cardholder_name(i))
                , xmlelement( "family_name",        '')
                , xmlelement( "mmc",                'T')
                , xmlelement( "term_id",            l_terminal_number(i) )
                , xmlelement( "type_of_oper",       'C')
                , xmlelement( "trans_type",         l_trans_type(i))
                , xmlelement( "bill_curr",          l_oper_currency(i))
                , xmlelement( "bill_amnt",          to_char(nvl(l_oper_amount(i), 0),   com_api_const_pkg.XML_FLOAT_FORMAT))
                , xmlelement( "txn_fee",            to_char(0,   com_api_const_pkg.XML_FLOAT_FORMAT))
                , xmlelement( "source_curr",        l_sttl_currency(i))
                , xmlelement( "source_amnt",        to_char(nvl(l_sttl_amount(i), 0),   com_api_const_pkg.XML_FLOAT_FORMAT))
                , xmlelement( "fees",               to_char(0,   com_api_const_pkg.XML_FLOAT_FORMAT))
                , xmlelement( "interest",           to_char(0,   com_api_const_pkg.XML_FLOAT_FORMAT))
                , xmlelement( "network_curr",       l_sttl_currency(i))
                , xmlelement( "network_amnt",       to_char(nvl(l_sttl_amount(i), 0),   com_api_const_pkg.XML_FLOAT_FORMAT))
                , xmlelement( "from",               'O')
                , xmlelement( "auth_n",             '')
                , xmlelement( "txn_descript",       'ACCOUNT CLEARED')
                , xmlelement( "card_holder_settl",  l_sttl_type(i))
                , xmlelement( "card_acc_class",     '')
                , xmlelement( "repmethod",          '')
                , xmlelement( "montly_int",         '')
                )
            into
                l_card
            from
                dual;

            -- add node to detail
            select
                xmlconcat(l_cards, l_card) r
            into
                l_cards
            from
                dual;
        end loop;

        l_processed_count := l_processed_count + l_event_object_id.count;

        prc_api_stat_pkg.log_current (
            i_current_count     => l_processed_count
            , i_excepted_count  => 0
        );

        -- changes status of events to processed
        evt_api_event_pkg.process_event_object(
            i_event_object_id_tab  => l_event_object_id
        );
        --forall i in 1 .. l_event_id_tab.count
        --    delete from evt_event_object where id = l_event_tab(i);

        exit when overdued_accounts_cur%notfound;
    end loop;
    close overdued_accounts_cur;

    -- forming XML structure
    select
        xmlelement (
            "cards"
            , l_cards
        ) r
    into
        l_cards
    from
        dual;

    select
        (xmlelement (
            "cards_closed_by_aging"
            , xmlattributes('http://sv.bpc.in/SVAP' AS "xmlns")
            --, l_header
            , l_cards
        )).getclobval()
    into
        l_file
    from
        dual;

    l_file := com_api_const_pkg.XML_HEADER || l_file;

    -- savig file
    if l_processed_count > 0 then
        prc_api_file_pkg.open_file(
            o_sess_file_id      => l_sess_file_id
        );

        trc_log_pkg.debug (
            i_text          => 'l_sess_file_id [#1]'
            , i_env_param1  => l_sess_file_id
        );

        prc_api_file_pkg.put_file (
            i_sess_file_id   => l_sess_file_id
           , i_clob_content  => l_file
        );

        trc_log_pkg.debug (
            i_text          => 'file length [#1]'
            , i_env_param1  => length(l_file)
        );

        prc_api_file_pkg.close_file (
            i_sess_file_id  => l_sess_file_id
            , i_status      => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );
    end if;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count   => l_processed_count
    );

    prc_api_stat_pkg.log_end (
        i_excepted_total     => 0
        , i_processed_total  => l_processed_count
        , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
exception
    when others then
        rollback to export_closed_cards;
        if overdued_accounts_cur%isopen then
            close overdued_accounts_cur;
        end if;
        trc_log_pkg.error(sqlerrm);
        prc_api_stat_pkg.log_end (
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if l_sess_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_sess_file_id
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
end export_closed_cards;

procedure export_cards_with_overdue (
    i_card_inst_id          in com_api_type_pkg.t_inst_id
  , i_start_date            in date
  , i_end_date              in date
) is
    --Report 5 "Cards with debts in Grace date" (Grace overdue report.xls)
    LIMIT_SIZE       constant com_api_type_pkg.t_tiny_id := 100;

    l_start_date              date;
    l_end_date                date;
    l_processed_count         com_api_type_pkg.t_long_id;
    l_sess_file_id            com_api_type_pkg.t_long_id;
    l_file                    clob;
    l_card                    xmltype;
    l_cards                   xmltype;

    -- tabs for cursor
    l_card_instance_id        com_api_type_pkg.t_number_tab;
    l_card_id                 com_api_type_pkg.t_number_tab;
    l_card_mask               com_api_type_pkg.t_card_number_tab;
    l_bin                     com_api_type_pkg.t_name_tab;
    l_cardholder_name         com_api_type_pkg.t_name_tab;
    l_first_name              com_api_type_pkg.t_name_tab;
    l_surname                 com_api_type_pkg.t_name_tab;
    l_inst_id                 com_api_type_pkg.t_inst_id_tab;
    l_aging_period            com_api_type_pkg.t_number_tab;
    l_total_amount_due        com_api_type_pkg.t_money_tab;
    l_grace_date              com_api_type_pkg.t_date_tab;
    l_interest_sum            com_api_type_pkg.t_money_tab;
    l_avg_inv_prc             com_api_type_pkg.t_money_tab;
    l_avail_balance           com_api_type_pkg.t_money_tab;
    l_account_id              com_api_type_pkg.t_number_tab;
    l_account_number          com_api_type_pkg.t_account_number_tab;
    l_account_currency        com_api_type_pkg.t_curr_code_tab;
    l_account_status          com_api_type_pkg.t_dict_tab;
    l_event_object_id         com_api_type_pkg.t_number_tab;
    l_lang                    com_api_type_pkg.t_dict_value;

    cursor overdued_accounts_cur (
        p_start_date          in date
        , p_end_date          in date
    ) is
    with ev as (
        select
        v.id as event_object_id
        , a.id as account_id
        , a.account_number
        , a.currency
        , a.status
    from
        evt_event_object v
        , evt_event e
        , acc_account a
        where
        v.procedure_name = 'CRD_API_REPORT_PKG.EXPORT_CARDS_WITH_OVERDUE'
        and nvl(v.status, evt_api_const_pkg.EVENT_STATUS_READY) not in (
            evt_api_const_pkg.EVENT_STATUS_PROCESSED, evt_api_const_pkg.EVENT_STATUS_DO_NOT_PROCES
        )
        and e.event_type = crd_api_const_pkg.OVERDUE_EVENT -- 'EVNT1005' -- Overdue
        and v.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT -- 'ENTTACCT'
        and v.eff_date >= p_start_date
        and v.eff_date <= p_end_date
        and v.inst_id = i_card_inst_id
        and v.event_id = e.id
        and a.id = v.object_id
    )
    select
        a.card_instance_id
        , a.card_id
        , a.card_mask
        , a.bin
        , a.cardholder_name
        , a.first_name
        , a.surname
        , inv.inst_id
        , inv.aging_period
        , inv.total_amount_due
        , inv.grace_date
        , debt.interest_sum
        , debt.avg_inv_prc
        , acc_api_balance_pkg.get_aval_balance_amount_only (
            i_account_id   => a.account_id
            , i_date       => inv.invoice_date
            , i_date_type  => com_api_const_pkg.DATE_PURPOSE_PROCESSING
        ) avail_balance
        , a.account_id
        , a.account_number
        , a.currency
        , a.status
        , a.event_object_id
    from (
        select
            ci.id    as card_instance_id
            , crd.id as card_id
            , crd.card_mask
            , ib.bin
            , ch.cardholder_name
            , pt.first_name
            , pt.surname
            , (select max(id) keep (dense_rank last order by invoice_date)
                 from crd_invoice ii
                where ii.account_id = v.account_id
            ) last_invoice_id
            , v.event_object_id
            , v.account_id
            , v.account_number
            , v.currency
            , v.status
        from
            ev v
            , acc_account_object aco
            , iss_card crd
            , iss_card_instance ci
            , iss_bin ib
            , iss_cardholder ch
            , (select id, min(lang) keep(dense_rank first order by decode(lang, l_lang, 1, 'LANGENG', 2, 3)) lang from com_person_vw group by id) pt2
            , com_person pt
        where
            aco.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD-- 'ENTTCARD'
            and aco.account_id = v.account_id
            and aco.object_id = crd.id
            and crd.id = ci.card_id
            and ci.bin_id = ib.id
            and crd.cardholder_id = ch.id(+)
            and pt2.id(+) = ch.person_id
            and pt.id = pt2.id
            and pt.lang = pt2.lang
        ) a
        left join crd_invoice inv on (inv.id = a.last_invoice_id)
        left join (
            select
                cid.invoice_id
                , sum(cdi.amount)     as interest_sum
                , avg(f.percent_rate) as avg_inv_prc
            from
                crd_invoice_debt cid
            join crd_debt_interest cdi on (cid.debt_intr_id = cdi.id)
            left join fcl_fee_tier f   on (cdi.fee_id = f.fee_id)
        group by cid.invoice_id
        ) debt on (debt.invoice_id = inv.id
    );
begin
    savepoint export_cards_with_overdue;
    prc_api_stat_pkg.log_start;

    l_processed_count := 0;

    l_start_date := trunc(nvl(i_start_date, get_sysdate));
    l_end_date   := trunc(nvl(i_end_date, l_start_date)) + 1 - com_api_const_pkg.ONE_SECOND;
    l_lang       := com_ui_user_env_pkg.get_user_lang;

    trc_log_pkg.debug ('start_date[' ||com_api_type_pkg.convert_to_char(l_start_date) || '] l_end_date[' || com_api_type_pkg.convert_to_char(l_end_date)||']');

    open overdued_accounts_cur (
        p_start_date  => l_start_date
        , p_end_date  => l_end_date
    );
    loop
        fetch overdued_accounts_cur
        bulk collect into
        l_card_instance_id
        , l_card_id
        , l_card_mask
        , l_bin
        , l_cardholder_name
        , l_first_name
        , l_surname
        , l_inst_id
        , l_aging_period
        , l_total_amount_due
        , l_grace_date
        , l_interest_sum
        , l_avg_inv_prc
        , l_avail_balance
        , l_account_id
        , l_account_number
        , l_account_currency
        , l_account_status
        , l_event_object_id
        limit LIMIT_SIZE;

        -- export cards to report
        for i in 1 .. l_event_object_id.count loop
            select
                xmlelement( "card"
                    , xmlelement( "cycle",              l_aging_period(i))
                    , xmlelement( "gracedat",           to_char(l_grace_date(i), com_api_const_pkg.XML_DATETIME_FORMAT))
                    , xmlelement( "bin",                l_bin(i))
                    , xmlelement( "cms_account",        l_account_id(i))
                    , xmlelement( "card_number",        l_card_mask(i))
                    , xmlelement( "account_status",     l_account_status(i))
                    , xmlelement( "branch",             l_inst_id(i))
                    , xmlelement( "bank_account",       l_account_number(i))
                    , xmlelement( "currency",           l_account_currency(i))
                    , xmlelement( "montly_int",         to_char(nvl(l_avg_inv_prc(i), 0), com_api_const_pkg.XML_FLOAT_FORMAT))
                    , xmlelement( "unbill_amnt",        to_char(0                    , com_api_const_pkg.XML_FLOAT_FORMAT))
                    , xmlelement( "bill_amnt",          to_char(nvl(l_interest_sum(i), 0), com_api_const_pkg.XML_FLOAT_FORMAT))
                    , xmlelement( "odue_amnt",          to_char(nvl(l_total_amount_due(i), 0), com_api_const_pkg.XML_FLOAT_FORMAT))
                    , xmlelement( "ext_amnt",           to_char(0                    , com_api_const_pkg.XML_FLOAT_FORMAT))
                    , xmlelement( "acc_balance",        to_char(nvl(l_avail_balance(i), 0), com_api_const_pkg.XML_FLOAT_FORMAT))
                    , xmlelement( "mra",                '')
                    , xmlelement( "egn",                '')
                )
            into
                l_card
            from
                dual;

            -- add node to detail
            select
                xmlconcat(l_cards, l_card) r
            into
                l_cards
            from
                dual;
        end loop;

        l_processed_count := l_processed_count + l_event_object_id.count;

        prc_api_stat_pkg.log_current (
            i_current_count     => l_processed_count
            , i_excepted_count  => 0
        );

        -- changes status of events to processed
        evt_api_event_pkg.process_event_object (
            i_event_object_id_tab  => l_event_object_id
        );

        exit when overdued_accounts_cur%notfound;
    end loop;
    close overdued_accounts_cur;

    -- forming XML structure
    select
        xmlelement(
            "cards"
            , l_cards
        ) r
    into
        l_cards
    from
        dual;

    select
        (xmlelement (
            "cards_with_overdue"
            , xmlattributes('http://sv.bpc.in/SVAP' AS "xmlns")
            , l_cards
        )).getclobval()
    into
        l_file
    from
        dual;

    l_file := com_api_const_pkg.XML_HEADER || l_file;

    -- savig file
    if l_processed_count > 0 then
        prc_api_file_pkg.open_file (
            o_sess_file_id   => l_sess_file_id
        );

        trc_log_pkg.debug (
            i_text          => 'l_sess_file_id [#1]'
            , i_env_param1  => l_sess_file_id
        );

        prc_api_file_pkg.put_file (
            i_sess_file_id  => l_sess_file_id
            , i_clob_content  => l_file
        );

        trc_log_pkg.debug (
            i_text          => 'file length [#1]'
            , i_env_param1  => length(l_file)
        );

        prc_api_file_pkg.close_file (
            i_sess_file_id  => l_sess_file_id
            , i_status      => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );
    end if;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count   => l_processed_count
    );

    prc_api_stat_pkg.log_end (
        i_excepted_total     => 0
        , i_processed_total  => l_processed_count
        , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
exception
    when others then
        rollback to export_cards_with_overdue;
        if overdued_accounts_cur%isopen then
            close overdued_accounts_cur;
        end if;
        trc_log_pkg.error(sqlerrm);
        prc_api_stat_pkg.log_end (
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if l_sess_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_sess_file_id
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
end export_cards_with_overdue;

/*
 * Unloading credit statements in SVXP format.
 */
procedure process_credit_statement(
    i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_account_number    in     com_api_type_pkg.t_account_number
  , i_sttl_date         in     date
) is
    l_file                  clob;
    l_sess_file_id          com_api_type_pkg.t_long_id;

    -- Operations is defined only for account with credit service. We cannot calculate the estimated count for operations in common case.
    -- Therefore, we calculate estimated count for processed account.
    l_processed_count       com_api_type_pkg.t_count := 1;
    l_estimated_count       com_api_type_pkg.t_count := 1;
    --
    l_header                xmltype;
    l_detail                xmltype;
    l_interest              xmltype;
    l_interest_detail       xmltype;
    l_oper_detail           xmltype;
    l_account_rec           acc_api_type_pkg.t_account_rec;
    -- CRD_INVOICE
    l_invoice_id            com_api_type_pkg.t_medium_id;
    l_invoice_date          date;
    l_invoice_type          com_api_type_pkg.t_dict_value;
    l_grace_date            date;
    l_due_date              date;
    l_penalty_date          date;
    l_aging_period          com_api_type_pkg.t_long_id;
    l_serial_number         com_api_type_pkg.t_tiny_id;

    l_start_date            date;
    l_aval_balance          com_api_type_pkg.t_amount_rec;
    l_overdue_balance       com_api_type_pkg.t_amount_rec;
    l_overdue_intr_balance  com_api_type_pkg.t_amount_rec;
    l_ledger_balance        com_api_type_pkg.t_amount_rec;
    l_entry_balance         com_api_type_pkg.t_money := 0;
    l_output_balance        com_api_type_pkg.t_money := 0;
    l_total_income          com_api_type_pkg.t_money := 0;
    l_total_expence         com_api_type_pkg.t_money := 0;
    l_total_interest        com_api_type_pkg.t_money := 0;
    l_interest_amount       com_api_type_pkg.t_money := 0;
    l_debt_interest_amount  com_api_type_pkg.t_money := 0;
    l_exceed_limit          com_api_type_pkg.t_amount_rec;
    l_currency_id           com_api_type_pkg.t_tiny_id;
    l_currency              com_api_type_pkg.t_dict_value;
    l_settl_date            date;
    l_lang                  com_api_type_pkg.t_dict_value;
    l_debt_id               com_api_type_pkg.t_long_id;

    l_min_amount_due        com_api_type_pkg.t_money := 0;
    l_is_mad_paid           com_api_type_pkg.t_boolean;
    l_is_tad_paid           com_api_type_pkg.t_boolean;
    l_service_id            com_api_type_pkg.t_short_id;
    l_product_id            com_api_type_pkg.t_short_id;
    l_from_id               com_api_type_pkg.t_long_id;
    l_till_id               com_api_type_pkg.t_long_id;

    l_calc_interest_end_attr   com_api_type_pkg.t_dict_value;

    l_calc_interest_date_end   date;

    l_calc_due_date            date;

    procedure add_element_to_detail(
        i_oper_type             in com_api_type_pkg.t_dict_value
        , i_oper_description    in com_api_type_pkg.t_text
        , i_card_mask           in com_api_type_pkg.t_text
        , i_card_id             in com_api_type_pkg.t_long_id
        , i_posting_date        in date
        , i_oper_date           in date
        , i_oper_amount         in com_api_type_pkg.t_money
        , i_oper_currency       in com_api_type_pkg.t_curr_code
        , i_credit_oper_amount  in com_api_type_pkg.t_money
        , i_debit_oper_amount   in com_api_type_pkg.t_money
        , i_overdraft_amount    in com_api_type_pkg.t_money
        , i_repayment_amount    in com_api_type_pkg.t_money
        , i_interest_amount     in com_api_type_pkg.t_money
    ) is
    begin
        select
            xmlelement( "operation"
              , xmlelement( "oper_type",          i_oper_type )
              , xmlelement( "oper_description",   i_oper_description)
              , xmlelement( "card_mask",          i_card_mask )
              , xmlelement( "card_id",            i_card_id )
              , xmlelement( "posting_date",       to_char(l_settl_date, com_api_const_pkg.XML_DATE_FORMAT))
              , xmlelement( "oper_date",          to_char(l_settl_date, com_api_const_pkg.XML_DATE_FORMAT))
              , xmlelement( "oper_amount",        to_char(nvl(l_debt_interest_amount, 0), com_api_const_pkg.XML_FLOAT_FORMAT))
              , xmlelement( "oper_currency",      l_aval_balance.currency )
              , xmlelement( "credit_oper_amount", to_char(nvl(i_credit_oper_amount, 0),   com_api_const_pkg.XML_FLOAT_FORMAT))
              , xmlelement( "debit_oper_amount",  to_char(nvl(i_debit_oper_amount, 0),    com_api_const_pkg.XML_FLOAT_FORMAT))
              , xmlelement( "overdraft_amount",   to_char(nvl(i_overdraft_amount, 0),     com_api_const_pkg.XML_FLOAT_FORMAT))
              , xmlelement( "repayment_amount",   to_char(nvl(i_repayment_amount, 0),     com_api_const_pkg.XML_FLOAT_FORMAT))
              , xmlelement( "interest_amount",    to_char(nvl(i_interest_amount, 0),      com_api_const_pkg.XML_FLOAT_FORMAT))
              , xmlelement( "oper_type_interest", '1' )
           )
        into l_interest
        from dual;
        -- add node to detail
        select
            xmlconcat(l_interest_detail, l_interest) r
        into
            l_interest_detail
        from
            dual;
    end add_element_to_detail;

begin
    l_lang := com_ui_user_env_pkg.get_user_lang;

    trc_log_pkg.debug (
        i_text         => 'Run process_credit_statement [#1] [#2] [#3] [#4]'
        , i_env_param1 => i_inst_id
        , i_env_param2 => i_account_number
        , i_env_param3 => i_sttl_date
        , i_env_param4 => l_lang
    );

    l_settl_date  := nvl(trunc(i_sttl_date), com_api_sttl_day_pkg.get_sysdate) + 1 - com_api_const_pkg.ONE_SECOND;

    prc_api_stat_pkg.log_start;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_estimated_count
    );

    prc_api_stat_pkg.log_current(
        i_current_count  => l_estimated_count
      , i_excepted_count => 0
    );

    -- Searcing an account by its number and parent institution
    l_account_rec :=
        acc_api_account_pkg.get_account(
            i_account_id     => null
          , i_account_number => i_account_number
          , i_inst_id        => case -- Account should be searched only by exact institution identifier
                                    when i_inst_id = ost_api_const_pkg.DEFAULT_INST then null
                                                                                    else i_inst_id
                                end
          , i_mask_error     => com_api_type_pkg.FALSE
        );

    -- get last invoice
    select max(i.id)
      into l_invoice_id
      from crd_invoice_vw i
     where i.account_id = l_account_rec.account_id
       and i.invoice_date <= l_settl_date;

    -- calc start date
    if l_invoice_id is null then
        begin
            -- get start date of credit service on current account
            select
                o.start_date
            into
                l_start_date
            from
                prd_service_object o
                , prd_service s
            where
                o.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                and object_id = l_account_rec.account_id
                and s.id = o.service_id
                and s.service_type_id = crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID;
            --
            l_entry_balance := 0;
            l_invoice_type := 'IVTPNETW';
        exception
            when no_data_found then
                com_api_error_pkg.raise_error (
                    i_error         => 'ACCOUNT_SERVICE_NOT_FOUND'
                    , i_env_param1  => l_account_rec.account_id
                    , i_env_param2  => crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
                );
        end;
    else
        select nvl(invoice_date, l_start_date)
             , nvl(total_amount_due, 0)
             , nvl(invoice_type, 'IVTPNETW')
             , nvl(grace_date, l_start_date)
             , nvl(due_date, l_start_date)
             , nvl(penalty_date, l_start_date)
             , nvl(aging_period, 0)
             , nvl(serial_number, 0)
             , nvl(is_mad_paid, 0)
             , nvl(is_tad_paid, 0)
          into l_invoice_date
             , l_entry_balance
             , l_invoice_type
             , l_grace_date
             , l_due_date
             , l_penalty_date
             , l_aging_period
             , l_serial_number
             , l_is_mad_paid
             , l_is_tad_paid
          from crd_invoice_vw i
         where i.id = l_invoice_id;

        l_start_date := l_invoice_date;
    end if;

    -- Get credit service ID
    l_service_id := prd_api_service_pkg.get_active_service_id (
        i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id         => l_account_rec.account_id
      , i_attr_name         => null
      , i_service_type_id   => crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
      , i_split_hash        => l_account_rec.split_hash
      , i_eff_date          => null
      , i_mask_error        => com_api_type_pkg.TRUE
      , i_inst_id           => i_inst_id
    );

    l_product_id := prd_api_product_pkg.get_product_id(
        i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
        , i_object_id   => l_account_rec.account_id
    );

    -- get aval balance
    l_aval_balance := acc_api_balance_pkg.get_aval_balance_amount (
        i_account_id    => l_account_rec.account_id
        , i_date        => l_settl_date
        , i_date_type   => com_api_const_pkg.DATE_PURPOSE_PROCESSING
    );
    -- get overdue balance
    l_overdue_balance := acc_api_balance_pkg.get_balance_amount (
        i_account_id      => l_account_rec.account_id
        , i_balance_type  => crd_api_const_pkg.BALANCE_TYPE_OVERDUE
        , i_date          => l_settl_date
        , i_date_type     => com_api_const_pkg.DATE_PURPOSE_PROCESSING
    );
    -- get overdue intr balance
    l_overdue_intr_balance := acc_api_balance_pkg.get_balance_amount (
        i_account_id      => l_account_rec.account_id
        , i_balance_type  => crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST
        , i_date          => l_settl_date
        , i_date_type     => com_api_const_pkg.DATE_PURPOSE_PROCESSING
    );

    --get credit limit
    l_exceed_limit := acc_api_balance_pkg.get_balance_amount (
        i_account_id     => l_account_rec.account_id
      , i_balance_type   => crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED
      , i_date           => l_settl_date
      , i_date_type      => com_api_const_pkg.DATE_PURPOSE_BANK
      , i_mask_error     => com_api_const_pkg.TRUE
    );

    -- get currency
    select id
      into l_currency_id
      from com_currency
     where code = l_aval_balance.currency;

    -- get ledger balance
    l_ledger_balance :=
        acc_api_balance_pkg.get_balance_amount (
            i_account_id        => l_account_rec.account_id
          , i_balance_type      => acc_api_const_pkg.BALANCE_TYPE_LEDGER -- BLTP0001
          , i_date              => l_settl_date
          , i_date_type         => com_api_const_pkg.DATE_PURPOSE_PROCESSING
          , i_mask_error        => com_api_const_pkg.TRUE
        );

    l_from_id := com_api_id_pkg.get_from_id(l_start_date);
    l_till_id := com_api_id_pkg.get_till_id(l_settl_date);

    -- get output_balance and total_expence
    select sum (decode(b.balance_type, acc_api_const_pkg.BALANCE_TYPE_LEDGER, 0, nvl(b.amount, 0))) -- all except Assigned exceed limit
         , sum (nvl(d.amount, 0))
      into l_output_balance
         , l_total_expence
      from (
            select d.id debt_id
                 , d.amount
              from crd_debt d
             where decode(d.status, 'DBTSACTV', d.account_id, null) = l_account_rec.account_id
               and d.split_hash = l_account_rec.split_hash
               and d.is_new = com_api_type_pkg.TRUE
               and d.id between l_from_id and l_till_id
            union
            select d.id debt_id
                 , d.amount
              from crd_debt d
             where decode(d.is_new, 1, d.account_id, null) = l_account_rec.account_id
               and d.split_hash = l_account_rec.split_hash
               and d.is_new = com_api_type_pkg.TRUE
               and d.id between l_from_id and l_till_id
         ) d
         , crd_debt_balance b
     where b.debt_id(+)    = d.debt_id
       and b.split_hash(+) = l_account_rec.split_hash
       and b.id between l_from_id and l_till_id;

    -- get total_income
    select sum (amount)
      into l_total_income
      from crd_payment
     where account_id = l_account_rec.account_id
       and split_hash = l_account_rec.split_hash
       and id between l_from_id and l_till_id;

    -- Get calc interest end date ICED
    l_calc_interest_end_attr :=
        crd_interest_pkg.get_interest_calc_end_date(
            i_account_id  => l_account_rec.account_id
          , i_eff_date    => l_settl_date
          , i_split_hash  => l_account_rec.split_hash
          , i_inst_id     => l_account_rec.inst_id
        );

    -- Get Due Date
    l_calc_due_date :=
        crd_invoice_pkg.calc_next_invoice_due_date(
            i_service_id => l_service_id
          , i_account_id => l_account_rec.account_id
          , i_split_hash => l_account_rec.split_hash
          , i_inst_id    => l_account_rec.inst_id
          , i_eff_date   => l_settl_date
          , i_mask_error => case l_calc_interest_end_attr
                                when crd_api_const_pkg.INTER_CALC_END_DATE_BLNC
                                    then com_api_const_pkg.FALSE
                                when crd_api_const_pkg.INTER_CALC_END_DATE_DDUE
                                    then com_api_const_pkg.TRUE
                                else com_api_const_pkg.FALSE
                            end
        );

    -- get total_interest
    l_debt_id := null;
    l_min_amount_due := 0;
    for r in (
        select a.balance_type
             , a.fee_id
             , a.amount
             , a.min_amount_due
             , a.balance_date as start_date
             , lead(a.balance_date) over (partition by a.balance_type order by a.id) end_date
             , a.debt_id
             , a.id
             , d.inst_id
             , d.macros_type_id
             , d.oper_type
             , i.due_date
          from crd_debt_interest a
             , crd_debt d
             , crd_invoice i
         where decode(d.status, 'DBTSACTV', d.account_id, null) = l_account_rec.account_id
           and a.is_charged      = com_api_const_pkg.FALSE
           and d.is_grace_enable = com_api_const_pkg.FALSE
           and d.id              = a.debt_id
           and a.split_hash      = l_account_rec.split_hash
           and a.id between l_from_id and l_till_id
           and a.invoice_id      = i.id(+)
         order by d.id
    ) loop
        l_calc_interest_date_end :=
            case l_calc_interest_end_attr
                when crd_api_const_pkg.INTER_CALC_END_DATE_BLNC
                    then r.end_date
                when crd_api_const_pkg.INTER_CALC_END_DATE_DDUE
                    then nvl(r.due_date, l_calc_due_date)
                else r.end_date
            end;
        l_interest_amount := round(
            fcl_api_fee_pkg.get_fee_amount(
                i_fee_id            => r.fee_id
              , i_base_amount       => r.amount
              , io_base_currency    => l_currency
              , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id         => l_account_rec.account_id
              , i_split_hash        => l_account_rec.split_hash
              , i_eff_date          => r.start_date
              , i_start_date        => r.start_date
              , i_end_date          => l_calc_interest_date_end
            )
          , 4
        );
        trc_log_pkg.debug (
            i_text          => 'Calc interest [#1] [#2] [#3] [#4] [#5]'
            , i_env_param1  => r.fee_id
            , i_env_param2  => r.amount
            , i_env_param3  => r.debt_id
            , i_env_param4  => r.start_date
            , i_env_param5  => r.end_date
        );

        l_total_interest := l_total_interest + l_interest_amount;
        --
        if r.min_amount_due > l_min_amount_due then
            l_min_amount_due := r.min_amount_due;
        end if;
        -- create detail
        if l_debt_id = r.debt_id then
            l_debt_interest_amount := l_debt_interest_amount + l_interest_amount;
        else
            if l_debt_id is not null then
                -- create new element for previous debt
                add_element_to_detail(
                    i_oper_type             => r.oper_type
                    , i_oper_description    => null
                    , i_card_mask           => null
                    , i_card_id             => null
                    , i_posting_date        => l_settl_date
                    , i_oper_date           => l_settl_date
                    , i_oper_amount         => l_debt_interest_amount
                    , i_oper_currency       => l_aval_balance.currency
                    , i_credit_oper_amount  => 0
                    , i_debit_oper_amount   => 0
                    , i_overdraft_amount    => 0
                    , i_repayment_amount    => 0
                    , i_interest_amount     => l_debt_interest_amount
                );
            end if;
            -- save new debt
            l_debt_id := r.debt_id;
            l_debt_interest_amount := l_interest_amount;
        end if;
    end loop;
    -- create new element for last debt
    if l_debt_id is not null then
        add_element_to_detail(
            i_oper_type             => null
            , i_oper_description    => null
            , i_card_mask           => null
            , i_card_id             => null
            , i_posting_date        => l_settl_date
            , i_oper_date           => l_settl_date
            , i_oper_amount         => l_debt_interest_amount
            , i_oper_currency       => l_aval_balance.currency
            , i_credit_oper_amount  => 0
            , i_debit_oper_amount   => 0
            , i_overdraft_amount    => 0
            , i_repayment_amount    => 0
            , i_interest_amount     => l_debt_interest_amount
        );
    end if;
    -- header
    select
        xmlconcat(
            xmlelement( "account"
              , xmlelement( "account_number", t.customer_account )
              , xmlelement( "currency", t.account_currency)
              , xmlelement( "account_type", t.account_type )
              , xmlelement( "inst_id", t.inst_id )
              , xmlelement( "agent_id", t.agent_id )
              , xmlelement( "customer"
                  , xmlelement( "customer_number", t.customer_number )
                  , xmlelement( "customer_category", t.category )
                  , xmlelement( "resident", t.resident )
                  , xmlelement( "customer_relation", t.relation )
                  , xmlelement( "nationality", t.nationality )
                  , xmlelement( "person"
                      , xmlelement( "person_name"
                          , xmlelement( "surname", t.surname )
                          , xmlelement( "first_name", t.first_name )
                          , xmlelement( "second_name", t.second_name )
                        )
                      , xmlelement( "identity_card"
                          , xmlelement( "id_type", t.id_type )
                          , xmlelement( "id_series", t.id_series )
                          , xmlelement( "id_number", t.id_number )
                        )
                    )
                  , xmlelement( "contact"
                      , xmlelement( "contact_type", t.contact_type )
                      , xmlelement( "preferred_lang", t.preferred_lang )
                      , xmlelement( "contact_data"
                          , xmlelement( "commun_method", t.commun_method )
                          , xmlelement( "commun_address", t.commun_address )
                        )
                    )
                  , xmlelement( "address"
                      , xmlelement( "address_type", t.address_type )
                      , xmlelement( "country", t.country )
                      , xmlelement( "address_name"
                          , xmlelement( "region", t.region )
                          , xmlelement( "city", t.city )
                          , xmlelement( "street", t.street )
                        )
                      , xmlelement( "house", t.house )
                      , xmlelement( "apartment", t.apartment )
                    )
                )
              , xmlelement( "contract"
                  , xmlelement( "contract_type",   t.contract_type )
                  , xmlelement( "product_id",      t.product_id )
                  , xmlelement( "contract_number", t.contract_number )
                  , xmlelement( "start_date",      to_char(t.contract_date, com_api_const_pkg.XML_DATE_FORMAT) )
                  )
            )
          , xmlelement( "opening_balance",    to_char(nvl(t.entry_balance, 0),       com_api_const_pkg.XML_FLOAT_FORMAT) )
          , xmlelement( "closing_balance",    to_char(nvl(t.output_balance, 0),      com_api_const_pkg.XML_FLOAT_FORMAT) )
          , xmlelement( "start_date",         to_char(t.start_date,                  com_api_const_pkg.XML_DATE_FORMAT) )
          , xmlelement( "invoice_date",       to_char(t.invoice_date,                com_api_const_pkg.XML_DATE_FORMAT) )
          , xmlelement( "payment_sum",        to_char(nvl(t.total_income, 0),        com_api_const_pkg.XML_FLOAT_FORMAT) )
          , xmlelement( "interest_sum",       to_char(nvl(t.total_interest, 0),      com_api_const_pkg.XML_FLOAT_FORMAT) )
          , xmlelement( "available_credit",   to_char(nvl(l_aval_balance.amount, 0), com_api_const_pkg.XML_FLOAT_FORMAT) )
          , xmlelement( "serial_number",      nvl(l_serial_number, 0) )
          , xmlelement( "invoice_type",       l_invoice_type )
          , xmlelement( "exceed_limit",       to_char(nvl(t.credit_limit, 0),        com_api_const_pkg.XML_FLOAT_FORMAT) )
          , xmlelement( "total_amount_due",   to_char(nvl(t.total_expence, 0),       com_api_const_pkg.XML_FLOAT_FORMAT) )
          , xmlelement( "own_funds",          to_char(nvl(t.ledger_balance, 0),      com_api_const_pkg.XML_FLOAT_FORMAT) )
          , xmlelement( "min_amount_due",     to_char(nvl(l_min_amount_due, 0),      com_api_const_pkg.XML_FLOAT_FORMAT) )
          , xmlelement( "grace_date",         to_char(nvl(l_grace_date, t.start_date),   com_api_const_pkg.XML_DATE_FORMAT) )
          , xmlelement( "due_date",           to_char(nvl(l_due_date, t.start_date),     com_api_const_pkg.XML_DATE_FORMAT) )
          , xmlelement( "penalty_date",       to_char(nvl(l_penalty_date, t.start_date), com_api_const_pkg.XML_DATE_FORMAT) )
          , xmlelement( "aging_period",       to_char(nvl(l_aging_period, 0)) )
          , xmlelement( "is_mad_paid",        to_char(nvl(l_is_mad_paid,  0)) )
          , xmlelement( "is_tad_paid",        to_char(nvl(l_is_tad_paid,  0)) )
          , crd_cst_report_pkg.get_additional_amounts(
                i_account_id => l_account_rec.account_id
              , i_invoice_id => l_invoice_id
              , i_split_hash => l_account_rec.split_hash
              , i_product_id => l_product_id
              , i_service_id => l_service_id
              , i_eff_date   => l_settl_date
            )
        )
    into
        l_header
    from (
        select
            a.account_number as customer_account
            , a.currency as account_currency
            , a.account_type
            , a.inst_id
            , a.agent_id
            , c.customer_number
            , c.category
            , c.resident
            , c.relation
            , c.nationality
            , r.contract_type
            , r.product_id
            , r.contract_number
            , r.start_date as contract_date
            , p.surname
            , p.first_name
            , p.second_name
            , ob1.address_type
            , d.country
            , d.region
            , d.city
            , d.street
            , d.house
            , d.apartment
            , l_start_date as start_date
            , l_settl_date as invoice_date
            , l_exceed_limit.amount     as credit_limit
            , l_ledger_balance.amount   as ledger_balance
            , l_entry_balance   as entry_balance
            , l_output_balance  as output_balance
            , l_total_income    as total_income
            , l_total_expence   as total_expence
            , l_total_interest  as total_interest
            , io.id_type
            , io.id_series
            , io.id_number
            , contact.contact_type
            , contact.preferred_lang
            , contact.commun_method
            , contact.commun_address
         from acc_account_vw a
            , prd_customer_vw c
            , prd_contract r
            , com_person p
            , com_address_object_vw ob1
            , com_address d
            , com_id_object_vw io
            , (select co.object_id
                      , co.contact_type
                      , nvl(cc.preferred_lang, com_api_const_pkg.DEFAULT_LANGUAGE) as preferred_lang
                      , cd.commun_method
                      , cd.commun_address
                from com_contact_object co
                     , com_contact cc
                     , com_contact_data cd
               where co.entity_type(+) = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                 and co.contact_type   = com_api_const_pkg.CONTACT_TYPE_PRIMARY--CNTTPRMC
                 and cc.id = co.contact_id
                 and cd.contact_id = cc.id
              ) contact
        where a.id = l_account_rec.account_id
          and c.id = a.customer_id
          and r.id = a.contract_id
          and p.id = c.object_id
          and c.entity_type      = com_api_const_pkg.ENTITY_TYPE_PERSON
          and ob1.entity_type(+) = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
          and ob1.object_id(+)   = c.id
          and d.id = ob1.address_id
          and io.entity_type(+)  = com_api_const_pkg.ENTITY_TYPE_PERSON
          and io.object_id(+)    = p.id
          and contact.object_id(+) = c.id
          and rownum = 1
    ) t;
    --
    begin
        -- details
        select
            xmlagg(
                xmlelement( "operation"
                    , xmlelement( "oper_type",          oper_type)
                    , xmlelement( "oper_description",   oper_description)
                    , xmlelement( "card_mask",          object_ref )
                    , xmlelement( "card_id",            card_id )
                    , xmlelement( "posting_date",       to_char(posting_date,        com_api_const_pkg.XML_DATE_FORMAT) )
                    , xmlelement( "oper_date",          to_char(oper_date,           com_api_const_pkg.XML_DATE_FORMAT) )
                    , xmlelement( "oper_amount",        to_char(nvl(oper_amount, 0), com_api_const_pkg.XML_FLOAT_FORMAT) )
                    , xmlelement( "oper_currency",      oper_currency )
                    , xmlelement( "credit_oper_amount", to_char(nvl(oper_amount_in, 0),  com_api_const_pkg.XML_FLOAT_FORMAT) )
                    , xmlelement( "debit_oper_amount",  to_char(nvl(oper_amount_out, 0), com_api_const_pkg.XML_FLOAT_FORMAT) )
                    , xmlelement( "overdraft_amount",   to_char(nvl(oper_credit,   0),   com_api_const_pkg.XML_FLOAT_FORMAT) )
                    , xmlelement( "repayment_amount",   to_char(nvl(oper_payment,  0),   com_api_const_pkg.XML_FLOAT_FORMAT) )
                    , xmlelement( "interest_amount",    to_char(nvl(oper_interest, 0),   com_api_const_pkg.XML_FLOAT_FORMAT) )
                    , xmlelement( "oper_type_interest", '0' )
                )
            )
        into
            l_oper_detail
        from (
            select
                oper_type
                , nvl2(oper_type, oper_type || ' ', null) || nvl2(oper_date, oper_date || ' ', null) || merchant_address as oper_description
                , object_ref
                , card_id
                , posting_date
                , oper_date
                , nvl(oper_amount, 0) oper_amount
                , oper_currency
                , oper_amount_in
                , oper_amount_out
                , oper_credit
                , oper_payment
                , oper_interest
            from (
                -- debit
                select
                    o.oper_type
                    , nvl2(o.merchant_city, o.merchant_city || ', ', null) || o.merchant_street as merchant_address
                    , (select card_mask from iss_card where id = d.card_id) as object_ref
                    , d.card_id
                    , d.posting_date
                    , d.oper_date
                    , o.oper_amount
                    , o.oper_currency
                    , null oper_amount_in
                    , nvl(d.amount, 0) oper_amount_out
                    , nvl(d.debt_amount, 0) oper_credit
                    , null oper_payment
                    , null oper_interest
                from (
                    select d.id debt_id
                      from crd_debt d
                     where decode(d.status, 'DBTSACTV', d.account_id, null) = l_account_rec.account_id
                       and d.split_hash = l_account_rec.split_hash
                       and is_new = com_api_type_pkg.TRUE
                    union
                    select d.id debt_id
                      from crd_debt d
                     where decode(d.is_new, 1, d.account_id, null) = l_account_rec.account_id
                       and d.split_hash = l_account_rec.split_hash
                       and d.id between l_from_id and l_till_id
                    ) e
                    , crd_debt_vw d
                    , opr_operation_vw o
                where
                    d.id = e.debt_id
                    and o.id(+) = d.oper_id
                union all
                -- credit
                select
                    o.oper_type
                    , nvl2(o.merchant_city, o.merchant_city || ', ', null) || o.merchant_street as merchant_address
                    , (select card_mask from iss_card where id = o.card_id) as object_ref
                    , o.card_id
                    , m.posting_date
                    , o.oper_date
                    , o.oper_amount
                    , o.oper_currency
                    , nvl(m.amount, 0) oper_amount_in
                    , null oper_amount_out
                    , null oper_credit
                    , (nvl(m.amount, 0) - nvl(m.pay_amount, 0)) oper_payment
                    , null oper_interest
                from (
                   select id as pay_id
                     from crd_payment p
                    where p.account_id = l_account_rec.account_id
                      and p.split_hash = l_account_rec.split_hash
                      and p.id between l_from_id and l_till_id
                    ) p
                    , crd_payment_vw m
                    , opr_operation_participant_vw o
                where m.id = p.pay_id
                  and o.id(+) = m.oper_id
            )
        );
    exception
        when no_data_found then
            trc_log_pkg.debug (
                i_text  => 'Operations not found'
            );
    end;
    --
    select
        xmlelement(
            "operations"
            , l_oper_detail
            , l_interest_detail
        ) r
    into
        l_detail
    from
        dual;
    --
    select
        (xmlelement (
            "account_credit_statement"
            , xmlattributes('http://sv.bpc.in/SVAP' AS "xmlns")
            , l_header
            , l_detail
        )).getclobval()
    into
        l_file
    from
        dual;
    --
    l_file := com_api_const_pkg.XML_HEADER || l_file;
    -- saving XML to file
    prc_api_file_pkg.open_file(
        o_sess_file_id => l_sess_file_id
    );
    trc_log_pkg.debug(
        i_text          => 'l_sess_file_id [#1], file length [#1]'
      , i_env_param1    => l_sess_file_id
      , i_env_param2    => length(l_file)
    );
    prc_api_file_pkg.put_file(
        i_sess_file_id  => l_sess_file_id
      , i_clob_content  => l_file
    );
    prc_api_file_pkg.close_file(
        i_sess_file_id  => l_sess_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );
    trc_log_pkg.debug (
        i_text          => 'process_credit_statment finished'
    );
    --
    prc_api_stat_pkg.log_end(
        i_processed_total => l_processed_count
      , i_result_code   => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
exception
    when others then
        --
        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        --
        if l_sess_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_sess_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;
        --
        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
        --
        raise;
end process_credit_statement;

end crd_prc_export_pkg;
/
