create or replace package body mup_api_report_pkg is

procedure get_header_footer (
    i_lang             in com_api_type_pkg.t_dict_value
    , i_inst_id        in com_api_type_pkg.t_tiny_id
    , i_agent_id       in com_api_type_pkg.t_short_id   default null
    , i_date_end       in date
    , o_header     out    xmltype
    , o_footer     out    xmltype
) is
    l_bank_name     com_api_type_pkg.t_name;
    l_bank_address  com_api_type_pkg.t_name;
    l_bic           com_api_type_pkg.t_name;
    l_code_okpo     com_api_type_pkg.t_name;
    l_reg_no        com_api_type_pkg.t_name;
    l_serial_no     com_api_type_pkg.t_name;
    l_code_okato    com_api_type_pkg.t_name;
    l_agent_name    com_api_type_pkg.t_name;
    l_phone         com_api_type_pkg.t_name;
    l_email         com_api_type_pkg.t_name;
begin
    begin
        select get_text('OST_INSTITUTION', com_api_const_pkg.TEXT_IN_NAME, i_inst_id, i_lang)
             , nvl(com_api_flexible_data_pkg.get_flexible_value('FLX_BANK_ID_CODE', ost_api_const_pkg.ENTITY_TYPE_INSTITUTION, i_inst_id), 99999)
             , com_api_flexible_data_pkg.get_flexible_value('RUS_OKPO', ost_api_const_pkg.ENTITY_TYPE_INSTITUTION, i_inst_id)
             , com_api_flexible_data_pkg.get_flexible_value('RUS_OGRN', ost_api_const_pkg.ENTITY_TYPE_INSTITUTION, i_inst_id)
             , com_api_flexible_data_pkg.get_flexible_value('RUS_REG_NUM', ost_api_const_pkg.ENTITY_TYPE_INSTITUTION, i_inst_id)
             , get_text('OST_AGENT', com_api_const_pkg.TEXT_IN_NAME, i_agent_id, i_lang)
          into l_bank_name
             , l_bic
             , l_code_okpo
             , l_reg_no
             , l_serial_no
             , l_agent_name
          from dual;
    exception
        when no_data_found
        then null;
    end;

    begin
        select com_api_address_pkg.get_address_string (o.address_id, i_lang ) address
             , a.region_code
          into l_bank_address
             , l_code_okato
          from com_address_object o
             , com_address a
         where o.entity_type = decode(
                                   i_agent_id, null
                                 , ost_api_const_pkg.ENTITY_TYPE_INSTITUTION, ost_api_const_pkg.ENTITY_TYPE_AGENT
                               )
           and o.object_id = decode(
                                 i_agent_id, null
                               , i_inst_id, i_agent_id
                             )
           and o.address_type = 'ADTPLGLA' --'ADTPBSNA'
           and a.id = o.address_id;
    exception
        when no_data_found or too_many_rows
        then null;
    end;

    begin
        select phone
             , email
          into l_phone
             , l_email
          from (
               select max(decode(
                              d.commun_method, com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                            , commun_address, null
                          )
                         ) as phone
                    , max(decode(
                              d.commun_method, com_api_const_pkg.COMMUNICATION_METHOD_EMAIL
                            , commun_address, null
                          )
                         ) as email
                 from com_contact_object o
                    , com_contact_data   d
                where o.object_id    = com_ui_user_env_pkg.get_person_id
                  and o.entity_type  = com_api_const_pkg.ENTITY_TYPE_PERSON
                  and o.contact_type = com_api_const_pkg.CONTACT_TYPE_PRIMARY
                  and d.contact_id   = o.contact_id
                  and commun_method in (com_api_const_pkg.COMMUNICATION_METHOD_MOBILE, com_api_const_pkg.COMMUNICATION_METHOD_EMAIL)
               );
    exception
        when no_data_found or too_many_rows
        then null;
    end;

    -- header
    select xmlelement("header"
               , xmlelement( "bank_name"    , l_bank_name    )
               , xmlelement( "bank_address" , l_bank_address )
               , xmlelement( "agent_name"   , l_agent_name   )
               , xmlelement( "bic"          , l_bic          )
               , xmlelement( "code_okpo"    , l_code_okpo    )
               , xmlelement( "reg_no"       , l_reg_no       )
               , xmlelement( "serial_no"    , l_serial_no    )
               , xmlelement( "code_okato"   , l_code_okato   )
               , xmlelement( "date"         , to_char(i_date_end + 1, 'dd month yyyy', 'nls_date_language = russian' ) )
           ) xml
      into o_header
      from dual;

    -- footer
    select xmlelement(
               "footer"
             , xmlelement("user_name", com_ui_person_pkg.get_person_name( acm_api_user_pkg.get_person_id( get_user_name), i_lang))
             , xmlelement("rpt_date" , to_char(com_api_sttl_day_pkg.get_sysdate,'dd.mm.yyyy hh24:mi'))
             , xmlelement("phone"    , l_phone)
             , xmlelement("email"    , l_email)
             ) xml
      into o_footer
      from dual;
exception
    when com_api_error_pkg.e_application_error then
        raise;
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => SQLERRM
        );
end get_header_footer;

procedure run_rpt_form_2_2_acq_oper(
    o_xml           out clob
  , i_inst_id    in     com_api_type_pkg.t_tiny_id
  , i_agent_id   in     com_api_type_pkg.t_short_id default null
  , i_date_start in     date
  , i_date_end   in     date
  , i_lang       in     com_api_type_pkg.t_dict_value default null
) is
    l_result        xmltype;
    l_part_1        xmltype;
    l_header        xmltype;
    l_footer        xmltype;
begin
    trc_log_pkg.debug (
        i_text         => 'mup_api_report_pkg.run_rpt_form_2_2_acq_oper [#1][#2][#3][#4][#5]'
      , i_env_param1 => i_lang
      , i_env_param2 => i_inst_id
      , i_env_param3 => i_agent_id
      , i_env_param4 => i_date_start
      , i_env_param5 => i_date_end
    );

    get_header_footer (
        i_lang        => i_lang
      , i_inst_id     => i_inst_id
      , i_agent_id    => i_agent_id
      , i_date_end    => i_date_end
      , o_header      => l_header
      , o_footer      => l_footer
    ) ;

    select xmlelement ( "part1", xmlagg (t.xml) )
      into l_part_1
      from (select xmlagg(
                       xmlelement("table"
                                , xmlelement("inst_id",                   x.inst_id)
                                , xmlelement("agent_id",                  x.agent_id)
                                , xmlelement("part",                      x.part)
                                , xmlelement("c0_region_code",            x.c0_region_code)
                                , xmlelement("c1_member_code",            x.c1_member_code)
                                , xmlelement("c2_bank_code",              x.c2_bank_code)
                                , xmlelement("c3_bank_name",              x.c3_bank_name)
                                , xmlelement("c4_count_pay",              x.c4_count_pay)
                                , xmlelement("c5_sum_pay",                to_char(x.c5_sum_pay/f.denominator, format))
                                , xmlelement("c6_count_pay_pos",          x.c6_count_pay_pos)
                                , xmlelement("c7_sum_pay_pos",            to_char(x.c7_sum_pay_pos/f.denominator, format))
                                , xmlelement("c8_count_pay_atm",          x.c8_count_pay_atm)
                                , xmlelement("c9_sum_pay_atm",            to_char(x.c9_sum_pay_atm/f.denominator, format))
                                , xmlelement("c10_count_pay_internet",    x.c10_count_pay_internet)
                                , xmlelement("c11_sum_pay_internet",      to_char(x.c11_sum_pay_internet/f.denominator, format))
                                , xmlelement("c12_count_cashout_atm",     x.c12_count_cashout_atm)
                                , xmlelement("c13_sum_cashout_atm",       to_char(x.c13_sum_cashout_atm/f.denominator, format))
                                , xmlelement("c14_count_cashout_pos",     x.c14_count_cashout_pos)
                                , xmlelement("c15_sum_cashout_pos",       to_char(x.c15_sum_cashout_pos/f.denominator, format))
                                , xmlelement("c16_count_cashin",          x.c16_count_cashin)
                                , xmlelement("c17_sum_cashin",            to_char(x.c17_sum_cashin/f.denominator, format))
                                , xmlelement("c18_count_transfer_credit", x.c18_count_transfer_credit)
                                , xmlelement("c19_sum_transfer_credit",   to_char(x.c19_sum_transfer_credit/f.denominator, format))
                                , xmlelement("c20_count_transfer_debit",  x.c20_count_transfer_debit)
                                , xmlelement("c21_sum_transfer_debit",    to_char(x.c21_sum_transfer_debit/f.denominator, format))
                                 )
                   ) xml
              from(select inst_id
                        , to_char(null) as agent_id
                        , part
                        , checked_successfully
                        , c0_region_code
                        , c1_member_code
                        , c2_bank_code
                        , c3_bank_name
                        , c4_count_pay
                        , c5_sum_pay
                        , c6_count_pay_pos
                        , c7_sum_pay_pos
                        , c8_count_pay_atm
                        , c9_sum_pay_atm
                        , c10_count_pay_internet
                        , c11_sum_pay_internet
                        , c12_count_cashout_atm
                        , c13_sum_cashout_atm
                        , c14_count_cashout_pos
                        , c15_sum_cashout_pos
                        , c16_count_cashin
                        , c17_sum_cashin
                        , c18_count_transfer_credit
                        , c19_sum_transfer_credit
                        , c20_count_transfer_debit
                        , c21_sum_transfer_debit 
                     from(select inst_id
                               , part
                               , checked_successfully
                               , c0_region_code
                               , c1_member_code
                               , c2_bank_code
                               , c3_bank_name
                               , sum(c4_count_pay) as c4_count_pay
                               , sum(c5_sum_pay) as c5_sum_pay
                               , sum(c6_count_pay_pos) as c6_count_pay_pos
                               , sum(c7_sum_pay_pos) as c7_sum_pay_pos
                               , sum(c8_count_pay_atm) as c8_count_pay_atm
                               , sum(c9_sum_pay_atm) as c9_sum_pay_atm
                               , sum(c10_count_pay_internet) as c10_count_pay_internet
                               , sum(c11_sum_pay_internet) as c11_sum_pay_internet
                               , sum(c12_count_cashout_atm) as c12_count_cashout_atm
                               , sum(c13_sum_cashout_atm) as c13_sum_cashout_atm
                               , sum(c14_count_cashout_pos) as c14_count_cashout_pos
                               , sum(c15_sum_cashout_pos) as c15_sum_cashout_pos
                               , sum(c16_count_cashin) as c16_count_cashin
                               , sum(c17_sum_cashin) as c17_sum_cashin
                               , sum(c18_count_transfer_credit) as c18_count_transfer_credit
                               , sum(c19_sum_transfer_credit) as c19_sum_transfer_credit
                               , sum(c20_count_transfer_debit) as c20_count_transfer_debit
                               , sum(c21_sum_transfer_debit) as c21_sum_transfer_debit
                           from mup_form_2_2_aggr t
                          where 1 = 1
                            and t.inst_id = i_inst_id
                            and (i_agent_id is null or i_agent_id = t.agent_id)
                          group by grouping sets
                               (
                                 (inst_id, part, checked_successfully, c0_region_code, c1_member_code, c2_bank_code, c3_bank_name)
                               , (inst_id, part, checked_successfully)
                               , (inst_id)
                               )
                         )
                      order by inst_id, part, c0_region_code nulls last
                    ) x,
                    (
                    select 1000 * power(10, nvl(exponent, 0)) denominator
                          , 'FM999999999999990D90' as format
                      from com_currency
                     where code = com_api_currency_pkg.RUBLE
                    ) f

          ) t;

    --if no data
    if l_part_1.getclobval() = '<part1></part1>' then
        select
            xmlelement("part1"
                , xmlagg(
                    xmlelement("table"
                        , xmlelement("inst_id", null)
                        , xmlelement("agent_id", null)
                        , xmlelement("part", null)
                        , xmlelement("c0_region_code", null)
                        , xmlelement("c1_member_code", null)
                        , xmlelement("c2_bank_code", null)
                        , xmlelement("c3_bank_name", null)
                        , xmlelement("c4_count_pay", null)
                        , xmlelement("c5_sum_pay", null)
                        , xmlelement("c6_count_pay_pos", null)
                        , xmlelement("c7_sum_pay_pos", null)
                        , xmlelement("c8_count_pay_atm", null)
                        , xmlelement("c9_sum_pay_atm", null)
                        , xmlelement("c10_count_pay_internet", null)
                        , xmlelement("c11_sum_pay_internet", null)
                        , xmlelement("c12_count_cashout_atm", null)
                        , xmlelement("c13_sum_cashout_atm", null)
                        , xmlelement("c14_count_cashout_pos", null)
                        , xmlelement("c15_sum_cashout_pos", null)
                        , xmlelement("c16_count_cashin", null)
                        , xmlelement("c17_sum_cashin", null)
                        , xmlelement("c18_count_transfer_credit", null)
                        , xmlelement("c19_sum_transfer_credit", null)
                        , xmlelement("c20_count_transfer_debit", null)
                        , xmlelement("c21_sum_transfer_debit", null)
                    )
                )
            )
        into l_part_1 from dual;
    end if;

    select xmlelement ( "report"
             , l_header
             , l_part_1
             , l_footer
           )
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug('mup_api_report_pkg.run_rpt_form_2_2_acq_oper - ok');
exception
    when com_api_error_pkg.e_application_error then
        raise;
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => SQLERRM
        );

end run_rpt_form_2_2_acq_oper;

procedure run_rpt_form_1_iss_oper (
    o_xml           out clob
  , i_inst_id    in     com_api_type_pkg.t_tiny_id
  , i_agent_id   in     com_api_type_pkg.t_short_id
  , i_date_start in     date
  , i_date_end   in     date
  , i_lang       in     com_api_type_pkg.t_dict_value default null
) is
    l_result     xmltype;
    l_part_1     xmltype;
    l_header     xmltype;
    l_footer     xmltype;
begin
    trc_log_pkg.debug (
          i_text       => 'mup_api_report_pkg.run_rpt_form_1_1_iss_oper [#1][#2][#3][#4][#5]'
        , i_env_param1 => i_lang
        , i_env_param2 => i_inst_id
        , i_env_param3 => i_agent_id
        , i_env_param4 => i_date_start
        , i_env_param5 => i_date_end
    );

    get_header_footer (
        i_lang        => i_lang
      , i_inst_id     => i_inst_id
      , i_agent_id    => i_agent_id
      , i_date_end    => i_date_end
      , o_header      => l_header
      , o_footer      => l_footer
    ) ;

    select xmlelement ( "part1", xmlagg (t.xml) )
      into l_part_1
      from(select xmlagg(
                      xmlelement(
                          "table"
                        , xmlelement("inst_id",                   x.inst_id)
                        , xmlelement("agent_id",                  x.agent_id)
                        , xmlelement("subsection",                x.subsection)
                        , xmlelement("member_code",               x.member_code)
                        , xmlelement("reg_num",                   x.reg_num)
                        , xmlelement("bank_name",                 x.bank_name)
                        , xmlelement("card_bin",                  x.card_bin)
                        , xmlelement("all_all_card_count",        x.all_all_card_count)
                        , xmlelement("all_all_active_card_count", x.all_all_active_card_count)
                        , xmlelement("all_card_count",            x.all_card_count)
                        , xmlelement("active_card_count",         x.active_card_count)
                        , xmlelement("cashout_rf_count",          x.cashout_rf_count)
                        , xmlelement("cashout_rf_amount",         to_char(x.cashout_rf_amount/f.denominator, format))
                        , xmlelement("cashout_foreign_count",     x.cashout_foreign_count)
                        , xmlelement("cashout_foreign_amount",    to_char(x.cashout_foreign_amount/f.denominator, format))
                        , xmlelement("cashin_count",              x.cashin_count)
                        , xmlelement("cashin_amount",             to_char(x.cashin_amount/f.denominator, format))
                        , xmlelement("purch_all_count",           x.purch_all_count)
                        , xmlelement("purch_all_amount",          to_char(x.purch_all_amount/f.denominator, format))
                        , xmlelement("purch_rf_count",            x.purch_rf_count)
                        , xmlelement("purch_rf_amount",           to_char(x.purch_rf_amount/f.denominator, format))
                        , xmlelement("purch_rf_int_count",        x.purch_rf_int_count)
                        , xmlelement("purch_rf_int_amount",       to_char(x.purch_rf_int_amount/f.denominator, format))
                        , xmlelement("purch_foreign_count",       x.purch_foreign_count)
                        , xmlelement("purch_foreign_amount",      to_char(x.purch_foreign_amount/f.denominator, format))
                        , xmlelement("purch_foreign_int_count",   x.purch_foreign_int_count)
                        , xmlelement("purch_foreign_int_amount",  to_char(x.purch_foreign_int_amount/f.denominator, format))
                        , xmlelement("p2p_debet_count",           x.p2p_debet_count)
                        , xmlelement("p2p_debet_amount",          to_char(x.p2p_debet_amount/f.denominator, format))
                        , xmlelement("p2p_credit_count",          x.p2p_credit_count)
                        , xmlelement("p2p_credit_amount",         to_char(x.p2p_credit_amount/f.denominator, format))
                      )
                  ) xml
             from(select a.inst_id
                       , a.agent_id
                       , a.subsection
                       , a.member_code
                       , a.reg_num
                       , a.bank_name
                       , a.card_bin
                       , all_card.all_all_card_count as all_all_card_count
                       , active_card.count_card as all_all_active_card_count
                       , sum(a.all_card_count) as all_card_count
                       , sum(a.active_card_count) as active_card_count
                       , sum(a.cashout_rf_count) as cashout_rf_count
                       , sum(a.cashout_rf_amount) as cashout_rf_amount
                       , sum(a.cashout_foreign_count) as cashout_foreign_count
                       , sum(a.cashout_foreign_amount) as cashout_foreign_amount
                       , sum(a.cashin_count) as cashin_count
                       , sum(a.cashin_amount) as cashin_amount
                       , sum(a.purch_all_count) as purch_all_count
                       , sum(a.purch_all_amount) as purch_all_amount
                       , sum(a.purch_rf_count) as purch_rf_count
                       , sum(a.purch_rf_amount) as purch_rf_amount
                       , sum(a.purch_rf_int_count) as purch_rf_int_count
                       , sum(a.purch_rf_int_amount) as purch_rf_int_amount
                       , sum(a.purch_foreign_count) as purch_foreign_count
                       , sum(a.purch_foreign_amount) as purch_foreign_amount
                       , sum(a.purch_foreign_int_count) as purch_foreign_int_count
                       , sum(a.purch_foreign_int_amount) as purch_foreign_int_amount
                       , sum(a.p2p_debet_count) as p2p_debet_count
                       , sum(a.p2p_debet_amount) as p2p_debet_amount
                       , sum(a.p2p_credit_count) as p2p_credit_count
                       , sum(a.p2p_credit_amount) as p2p_credit_amount
                    from mup_form_1_aggr a
                    join(select sum(count_bin) as all_all_card_count
                           from(select b.card_bin
                                     ,(select count(distinct c.id)
                                         from iss_card_vw c
                                         join iss_card_instance ci on ci.card_id = c.id 
                                        where c.card_number like b.card_bin||'%'
                                         and ci.status in (iss_api_const_pkg.CARD_STATUS_VALID_CARD) --'CSTS0000'
                                       ) as count_bin
                                  from (select distinct card_bin
                                          from mup_form_1_aggr
                                         where inst_id = i_inst_id
                                       ) b
                               )
                        ) all_card on 1 = 1
                    join(select count(distinct card_number) as count_card 
                           from mup_form_1_trans t
                          where inst_id = i_inst_id
                        ) active_card on 1 = 1
                     where 1 = 1
                       and a.subsection <> 9
                       and a.inst_id = i_inst_id
                     group by grouping sets
                          (
                            (inst_id, agent_id, subsection, member_code, reg_num, bank_name, a.card_bin, all_card.all_all_card_count, active_card.count_card)
                          , (inst_id, agent_id, subsection, all_card.all_all_card_count, active_card.count_card)
                          , (inst_id, all_card.all_all_card_count, active_card.count_card)
                          )
                    ) x,
                   (select 1000 * power(10, nvl(exponent, 0)) denominator
                         , 'FM999999999999990D90' as format
                      from com_currency
                     where code = com_api_currency_pkg.RUBLE
                   ) f
      ) t;

    --if no data
    if l_part_1.getclobval() = '<part1></part1>' then
        select
            xmlelement("part1"
                , xmlagg(
                    xmlelement("table"
                        , xmlelement("inst_id", null)
                        , xmlelement("agent_id", null)
                        , xmlelement("subsection", null)
                        , xmlelement("member_code", null)
                        , xmlelement("reg_num", null)
                        , xmlelement("bank_name", null)
                        , xmlelement("card_bin", null)
                        , xmlelement("all_all_card_count", null)
                        , xmlelement("all_all_active_card_count", null)
                        , xmlelement("all_card_count", null)
                        , xmlelement("active_card_count", null)
                        , xmlelement("cashout_rf_count", null)
                        , xmlelement("cashout_rf_amount", null)
                        , xmlelement("cashout_foreign_count", null)
                        , xmlelement("cashout_foreign_amount", null)
                        , xmlelement("cashin_count", null)
                        , xmlelement("cashin_amount", null)
                        , xmlelement("purch_all_count", null)
                        , xmlelement("purch_all_amount", null)
                        , xmlelement("purch_rf_count", null)
                        , xmlelement("purch_rf_amount", null)
                        , xmlelement("purch_rf_int_count", null)
                        , xmlelement("purch_rf_int_amount", null)
                        , xmlelement("purch_foreign_count", null)
                        , xmlelement("purch_foreign_amount", null)
                        , xmlelement("purch_foreign_int_count", null)
                        , xmlelement("purch_foreign_int_amount", null)
                        , xmlelement("p2p_debet_count", null)
                        , xmlelement("p2p_debet_amount", null)
                        , xmlelement("p2p_credit_count", null)
                        , xmlelement("p2p_credit_amount", null)
                    )
                )
            )
        into l_part_1 from dual;
    end if;

    select xmlelement ( "report"
             , l_header
             , l_part_1
             , l_footer
           )
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug('mup_api_report_pkg.run_rpt_form_1_1_iss_oper - ok');
exception
    when com_api_error_pkg.e_application_error then
        raise;
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => SQLERRM
        );
end run_rpt_form_1_iss_oper;

end mup_api_report_pkg;
/
