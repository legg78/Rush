create or replace package body cst_api_form_260_pkg is

procedure get_header_footer (
    i_lang       in com_api_type_pkg.t_dict_value
  , i_inst_id    in com_api_type_pkg.t_tiny_id
  , i_agent_id   in com_api_type_pkg.t_short_id default null
  , i_date_end   in date
  , o_header     out xmltype
  , o_footer     out xmltype
) is
    l_bank_name      com_api_type_pkg.t_name;
    l_bank_address   com_api_type_pkg.t_name;
    l_bic            com_api_type_pkg.t_name;
    l_code_okpo      com_api_type_pkg.t_name;
    l_reg_no         com_api_type_pkg.t_name;
    l_serial_no      com_api_type_pkg.t_name;
    l_code_okato     com_api_type_pkg.t_name;
    l_agent_name     com_api_type_pkg.t_name;
    l_contact_data   com_api_type_pkg.t_full_desc;
begin
    begin
        select get_text('OST_INSTITUTION', 'NAME', i_inst_id, i_lang)
             , com_api_flexible_data_pkg.get_flexible_value('RUS_OKPO',
                                                            ost_api_const_pkg.ENTITY_TYPE_INSTITUTION,
                                                            i_inst_id)
             , nvl(com_api_flexible_data_pkg.get_flexible_value('RUS_REG_NUM',
                                                                ost_api_const_pkg.ENTITY_TYPE_INSTITUTION,
                                                                i_inst_id),
                   3137)
             , get_text('OST_AGENT', 'NAME', i_agent_id, i_lang)
          into l_bank_name, l_code_okpo, l_serial_no, l_agent_name
          from dual;
    exception
        when others then
            null;
    end;

    begin
        select com_api_address_pkg.get_address_string(o.address_id, i_lang) address
             , a.region_code
          into l_bank_address
             , l_code_okato
          from com_address_object o, com_address a
         where o.entity_type = decode(i_agent_id,
                                      null, ost_api_const_pkg.ENTITY_TYPE_INSTITUTION,
                                      ost_api_const_pkg.ENTITY_TYPE_AGENT)
           and o.object_id = decode(i_agent_id, null, i_inst_id, i_agent_id)
           and o.address_type = 'ADTPLGLA'
           and a.id = o.address_id;
    exception
        when others then
            null;
    end;

    begin
        select phone || decode(phone, null, null, ', ') || e_mail
          into l_contact_data
          from (select max(decode(d.commun_method,
                                  com_api_const_pkg.COMMUNICATION_METHOD_MOBILE,
                                  commun_address,
                                  null)) as phone,
                       max(decode(d.commun_method,
                                  com_api_const_pkg.COMMUNICATION_METHOD_EMAIL,
                                  commun_address,
                                  null)) as e_mail
                  from com_contact_object o, com_contact_data d
                 where o.object_id = com_ui_user_env_pkg.get_person_id
                   and o.entity_type =
                       com_api_const_pkg.ENTITY_TYPE_PERSON
                   and o.contact_type =
                       com_api_const_pkg.CONTACT_TYPE_PRIMARY
                   and d.contact_id = o.contact_id
                   and commun_method in
                       (com_api_const_pkg.COMMUNICATION_METHOD_MOBILE,
                        com_api_const_pkg.COMMUNICATION_METHOD_EMAIL) -- mobile phone, e-mail
                );
    exception
        when others then
            null;
    end;

    -- header
    select xmlelement("header",
                      xmlelement("bank_name", l_bank_name),
                      xmlelement("bank_address", l_bank_address),
                      xmlelement("agent_name", l_agent_name),
                      xmlelement("code_okpo", l_code_okpo),
                      xmlelement("serial_no", l_serial_no),
                      xmlelement("code_okato", l_code_okato),
                      xmlelement("date", to_char(i_date_end + 1, 'dd month yyyy', 'nls_date_language = russian'))) xml
      into o_header
      from dual;

    -- footer
    select xmlelement("footer",
                      xmlelement("user_name",
                                 com_ui_person_pkg.get_person_name(acm_api_user_pkg.get_person_id(get_user_name), i_lang)),
                      xmlelement("rpt_date",
                                 to_char(com_api_sttl_day_pkg.get_sysdate, 'dd.mm.yyyy hh24:mi')),
                      xmlelement("phone", l_contact_data)) xml
      into o_footer
      from dual;
end;

function get_reversal_amount (
    i_oper_id           in com_api_type_pkg.t_long_id
  , i_amount_rev        in com_api_type_pkg.t_money
  , i_inst_id           in com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_money is
    l_amount_origin        com_api_type_pkg.t_money;
    l_oper_date_origin     date;
begin
    select oper_date
         , decode(oper_currency
                , 643, oper_amount
                , com_api_rate_pkg.convert_amount(
                      i_src_amount        => oper_amount
                    , i_src_currency      => oper_currency
                    , i_dst_currency      => 643
                    , i_rate_type         => 'RTTPCBRF'
                    , i_inst_id           => i_inst_id
                    , i_eff_date          => oper_date
                    , i_mask_exception    => 0
                    , i_exception_value   => 0
                  )
           )
    into
        l_oper_date_origin
      , l_amount_origin
    from opr_operation
    where id = i_oper_id;

    if l_amount_origin <> i_amount_rev then
        return l_amount_origin - i_amount_rev;
    else
        return i_amount_rev * -1;
    end if;

exception
    when others then
        return i_amount_rev;
end;

function correct_oper_count (
    i_oper_id           in com_api_type_pkg.t_long_id
  , i_amount_rev        in com_api_type_pkg.t_money
  , i_inst_id           in com_api_type_pkg.t_tiny_id
  , i_start_date        in date
  , i_end_date          in date
) return com_api_type_pkg.t_tiny_id is
    l_amount_origin        com_api_type_pkg.t_money;
    l_oper_date_origin     date;
begin
    select decode(oper_currency,
                  643,
                  oper_amount,
                  com_api_rate_pkg.convert_amount(i_src_amount      => oper_amount,
                                                  i_src_currency    => oper_currency,
                                                  i_dst_currency    => 643,
                                                  i_rate_type       => 'RTTPCBRF',
                                                  i_inst_id         => i_inst_id,
                                                  i_eff_date        => oper_date,
                                                  i_mask_exception  => 0,
                                                  i_exception_value => 0)),
           (select min(posting_date)
              from acc_macros
             where object_id = o.id
               and entity_type = 'ENTTOPER')
      into l_amount_origin, l_oper_date_origin
      from opr_operation o
     where o.id = i_oper_id;

    if l_amount_origin <> i_amount_rev then
        return 0;
    else
        if l_oper_date_origin between i_start_date and i_end_date then
            return 2;
        else
            return 1;
        end if;
    end if;

exception
    when others then
        return 0;
end;

procedure collect_data_form_260 (
    i_lang              in com_api_type_pkg.t_dict_value
  , i_inst_id           in com_api_type_pkg.t_tiny_id
  , i_agent_id          in com_api_type_pkg.t_short_id
  , i_date_start        in date
  , i_date_end          in date
  , i_level_refresh     in com_api_type_pkg.t_tiny_id
) is
    l_rowcount number;

    procedure i_put(
        i_msg in varchar2
      , i_is_delimeter in number default 0) is
    begin
        if i_is_delimeter = 1 then
            trc_log_pkg.debug(i_text => '----------------------------------------------------------');
        end if;

        trc_log_pkg.debug(
            i_text        => i_msg || ' [#1]'
          , i_env_param1  => 260
        );
    end i_put;

    procedure refresh_cst_260_file_tran is
    begin
        delete from cst_260_file_tran
         where file_date between i_date_start and i_date_end + 1;

        l_rowcount := sql%rowcount;
        i_put('Deleted from cst_260_file_tran ' || l_rowcount || ' recs.', 1);

        insert into cst_260_file_tran
        select sf.file_name
             , sf.id as session_file_id
             , trunc(file_date) as file_date
             , to_number(substr(rd.raw_data, 9, 16)) as oper_id
             , substr(rd.raw_data, 161, 2) as card_type
             , substr(rd.raw_data, 57, 2) as tran_code
             , nvl2(trim(substr(rd.raw_data, 59, 1)), 1, 0) as is_reversal
             , trim(substr(rd.raw_data, 221, 24)) as card_number
             , substr(rd.raw_data, 260, 3) as oper_currency
             , trim(substr(rd.raw_data, 269, 15)) as oper_amount
             , substr(rd.raw_data, 263, 3) as sttl_currency
             , trim(substr(rd.raw_data, 284, 15)) as sttl_amount
             , substr(rd.raw_data, 266, 3) as actual_currency
             , trim(substr(rd.raw_data, 299, 15)) as actual_amount
             , trim(substr(rd.raw_data, 455, 1)) as contra_entry_channel
             , decode(nvl2(trim(substr(rd.raw_data, 59, 1)), 1, 0),
                      1,
                      -1,
                      1) as oper_sign
             , trim(substr(rd.raw_data, 127, 24)) as terminal_number
             , rd.raw_data
          from prc_session_file sf
          join cst_250_3_mfiles m
            on m.session_file_id = sf.id
          join prc_file_raw_data rd
            on rd.session_file_id = sf.id
         where sf.file_type in ('FLTPOWMA', 'FLTPOWMP', 'FLTPOWME')
           and substr(rd.raw_data, 1, 2) = 'RD'
           and trunc(sf.file_date) between i_date_start and
               i_date_end + 1;

        l_rowcount := sql%rowcount;
        i_put('Inserted into CST_260_FILE_TRAN ' || l_rowcount ||
              ' recs.');

    end refresh_cst_260_file_tran;

    procedure refresh_cst_260_term is
    begin
        execute immediate 'delete from cst_260_term';

        l_rowcount := sql%rowcount;
        i_put('Deleted from cst_260_term ' || l_rowcount || ' recs.', 1);

        insert into cst_260_term
        select rownum as rn
             , inst_id
             , agent_id
             , region_code
             , terminal_type
             , terminal_id
             , terminal_number
             , start_date
             , end_date
             , postal_code
             , postal_address
             , placement_type
             , property_indicator
             , fiscal_number
             , phone_number
          from (select rownum as rn
                     , t2.inst_id
                     , t2.agent_id
                     , t2.region_code
                     , case
                           when t2.terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM then 'Atm'
                           when t2.terminal_type in (acq_api_const_pkg.TERMINAL_TYPE_POS
                                                   , acq_api_const_pkg.TERMINAL_TYPE_EPOS) then 'Pos'
                           else t2.terminal_type
                       end terminal_type
                     , t2.terminal_id
                     , t2.terminal_number
                     , t2.start_date
                     , t2.end_date
                     , a.postal_code
                     , com_api_address_pkg.get_address_string(
                           i_address_id => ao.address_id
                         , i_lang       => com_api_const_pkg.LANGUAGE_ENGLISH
                         , i_inst_id    =>  t2.inst_id
                       ) as postal_address
                     , nvl(get_article_text(
                               t2.placement_type
                             , com_api_const_pkg.LANGUAGE_ENGLISH
                           ), '') placement_type
                     , 'C' as property_indicator
                     , to_char(null) as phone_number
                     , to_char(null) as fiscal_number
                  from (select distinct t.inst_id
                                      , c.agent_id
                                      , nvl(o.region_code, '45') as region_code
                                      , t.terminal_type
                                      , t.id as terminal_id
                                      , o.terminal_number
                                      , so.start_date
                                      , so.end_date
                                      , atm.placement_type
                          from cst_250_3_oper_tran2 o
                          join acq_terminal t on t.terminal_number = o.terminal_number
                           and t.inst_id = i_inst_id
                          join prd_contract c on c.id = t.contract_id
                          join prd_service_object so on so.object_id = t.id
                           and so.entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                          left join atm_terminal atm on atm.id = t.id
                         where o.file_date between i_date_start - 1 and i_date_end + 1
                           and o.oper_type in (opr_api_const_pkg.OPERATION_TYPE_ATM_CASH
                                             , opr_api_const_pkg.OPERATION_TYPE_POS_CASH
                                             , opr_api_const_pkg.OPERATION_TYPE_CASHIN)
                         order by nvl(o.region_code, '45'),
                                  so.start_date,
                                  so.end_date nulls last) t2
                  join com_address_object ao on ao.object_id = t2.terminal_id
                   and ao.entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                  join com_address a on a.id = ao.address_id
                 order by t2.region_code,
                          t2.start_date,
                          t2.end_date nulls last) t3;

        l_rowcount := sql%rowcount;
        i_put('Inserted into cst_260_term ' || l_rowcount || ' recs.');

    end refresh_cst_260_term;

    procedure refresh_cst_260_aggr_tran is
        l_count       number;
        l_sum         number;
        l_region_code varchar2(2);
    begin
        delete from cst_260_aggr_tran;

        l_rowcount := sql%rowcount;
        i_put('Deleted from cst_260_aggr_tran ' || l_rowcount || ' recs.', 1);

        insert into cst_260_aggr_tran
        select 1 as record_type
             , (select count(*)
                  from cst_260_term t
                 where t.terminal_type = 'Atm'
                   and (t.inst_id = i_inst_id or i_inst_id is null)
                   and t.agent_id = agent_id_x
                   and t.region_code = region_code_x) as atm_count
             , (select count(*)
                  from cst_260_term t
                 where t.terminal_type = 'Pos'
                   and (t.inst_id = i_inst_id or i_inst_id is null)
                   and t.agent_id = agent_id_x
                   and t.region_code = region_code_x) term_count
             , agent_id_x agent_id
             , region_code_x
             , (nvl(ci_cnt, 0) - nvl(ci_corr_cnt, 0)) ci_cnt
             , (nvl(cl_cnt, 0) - nvl(cl_corr_cnt, 0)) cl_cnt
             , (nvl(cw_cnt, 0) - nvl(cw_corr_cnt, 0)) cw_cnt
             , nvl(ci_amount, 0) ci_amount
             , nvl(cl_amount, 0) cl_amount
             , nvl(cw_amount, 0) cw_amount
             , nvl(ci_corr_cnt, 0) ci_corr_cnt
             , nvl(cl_corr_cnt, 0) cl_corr_cnt
             , nvl(cw_corr_cnt, 0) cw_corr_cnt
          from (select case
                            when o.oper_type in (opr_api_const_pkg.OPERATION_TYPE_ATM_CASH
                                               , opr_api_const_pkg.OPERATION_TYPE_POS_CASH) and
                                 terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM then 'cw'
                            else 'ci'
                       end oper_type
                     , o.agent_id as agent_id_x
                     , o.region_code as region_code_x
                     , o.actual_amount
                     , o.actual_count
                  from cst_250_3_oper_tran2 o
                 where o.oper_type in (opr_api_const_pkg.OPERATION_TYPE_ATM_CASH
                                     , opr_api_const_pkg.OPERATION_TYPE_POS_CASH
                                     , opr_api_const_pkg.OPERATION_TYPE_CASHIN)
                   and o.file_date between i_date_start - 1 and i_date_end + 1) x

        pivot (sum(actual_count) as cnt
             , sum(actual_amount * actual_count) as amount
             , sum(actual_count) as corr_cnt
               for oper_type in ('cw' as cw
                               , 'ci' as ci
                               , 'cl' as cl)
              );

        l_rowcount := sql%rowcount;
        i_put('Inserted into cst_260_aggr_tran ' || l_rowcount || ' recs.');

    end refresh_cst_260_aggr_tran;

begin
    i_put('Start collect_data_form_260', 1);
    i_put('i_level_refresh = ' || i_level_refresh);
    i_put('i_date_start = ' || i_date_start);
    i_put('i_date_end = ' || i_date_end);

    case i_level_refresh
         when 1 then refresh_cst_260_term;
         when 2 then refresh_cst_260_aggr_tran;
    end case;

    i_put('Finish', 1);
exception
    when others then
        i_put('ERROR! collect_data_form_260 ' || sqlerrm, 1);
end collect_data_form_260;

procedure run_rpt_form_260 (
    o_xml          out     clob
  , i_lang              in com_api_type_pkg.t_dict_value
  , i_inst_id           in com_api_type_pkg.t_tiny_id
  , i_agent_id          in com_api_type_pkg.t_short_id default null
  , i_start_date        in date
  , i_end_date          in date
) is
    l_start_date    date;
    l_end_date      date;
    l_lang          com_api_type_pkg.t_dict_value;
    l_inst_id       com_api_type_pkg.t_inst_id;
    l_part_1        xmltype;
    l_part_2        xmltype;
    l_part_3        xmltype;
    l_header        xmltype;
    l_footer        xmltype;
    l_result        xmltype;
begin
    trc_log_pkg.debug(
        i_text         => 'api_form_260_pkg.run_rpt_form_260 [#1][#2][#3][#4][#5]]'
      , i_env_param1   => i_lang
      , i_env_param2   => i_inst_id
      , i_env_param3   => i_agent_id
      , i_env_param4   => i_start_date
      , i_env_param5   => i_end_date
    );

    l_lang       := nvl(i_lang, get_user_lang);
    l_start_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
    l_end_date   := nvl(trunc(i_end_date), l_start_date) + 1 - (1 / 86400);
    l_inst_id    := nvl(i_inst_id, 0);

    get_header_footer(
        i_lang       => i_lang
      , i_inst_id    => i_inst_id
      , i_agent_id   => i_agent_id
      , i_date_end   => l_end_date
      , o_header     => l_header
      , o_footer     => l_footer
    );

    select xmlelement("part_1",
                      xmlagg(xmlelement("record",
                                        xmlelement("record_type", record_type),
                                        xmlelement("atm_count", atm_count),
                                        xmlelement("term_count", term_count),
                                        xmlelement("region_code", region_code),
                                        xmlelement("ci_cnt", ci_corr_cnt),
                                        xmlelement("cl_cnt", cl_corr_cnt),
                                        xmlelement("cw_cnt", cw_corr_cnt),
                                        xmlelement("ci_amount",
                                                   com_api_currency_pkg.get_amount_str(
                                                             i_amount            => trunc(ci_amount / 1000, 2)
                                                           , i_curr_code         => '643'
                                                           , i_mask_curr_code    => com_api_type_pkg.TRUE
                                                         )),
                                        xmlelement("cl_amount",
                                                   com_api_currency_pkg.get_amount_str(
                                                             i_amount            => trunc(cl_amount / 1000, 2)
                                                           , i_curr_code         => '643'
                                                           , i_mask_curr_code    => com_api_type_pkg.TRUE
                                                         )),
                                        xmlelement("cw_amount",
                                                   com_api_currency_pkg.get_amount_str(
                                                             i_amount            => trunc(cw_amount / 1000, 2)
                                                           , i_curr_code         => '643'
                                                           , i_mask_curr_code    => com_api_type_pkg.TRUE
                                                         ) ))
                             order by region_code)
                      -- total
                      ,
                      xmlelement("record",
                                 xmlelement("record_type", 2),
                                 xmlelement("atm_count", 0),
                                 xmlelement("term_count", 0),
                                 xmlelement("region_code", ''),
                                 xmlelement("ci_cnt", 0),
                                 xmlelement("cl_cnt", 0),
                                 xmlelement("cw_cnt", 0),
                                 xmlelement("ci_amount", 0),
                                 xmlelement("cl_amount", 0),
                                 xmlelement("cw_amount", 0)))
      into l_part_1
      from cst_260_aggr_tran a
     where a.agent_id = i_agent_id;

    --part_2
    select xmlelement("part_2",
                      xmlagg(xmlelement("record",
                                        xmlelement("rn", rn),
                                        xmlelement("terminal_type", terminal_type),
                                        xmlelement("start_date", to_char(start_date, 'dd.mm.yyyy')),
                                        xmlelement("end_date", to_char(end_date, 'dd.mm.yyyy')),
                                        xmlelement("region_code", region_code),
                                        xmlelement("postal_code", postal_code),
                                        xmlelement("postal_address", postal_address),
                                        xmlelement("placement_type", placement_type),
                                        xmlelement("phone_number", phone_number),
                                        xmlelement("property_indicator", property_indicator),
                                        xmlelement("fiscal_number", fiscal_number)) order by rn))
      into l_part_2
      from cst_260_term t
     where t.agent_id = i_agent_id;

    --part_3
    select xmlelement("part_3") into l_part_3 from dual;

    select xmlelement("report",
                      l_header,
                      l_part_1,
                      l_part_2,
                      l_part_3,
                      l_footer)
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.info(i_text => 'api_form_260_pkg.run_rpt_form_260 - ok');

exception
    when others then
        trc_log_pkg.debug(i_text => sqlerrm);
        raise_application_error(-20001, sqlerrm);
end;

procedure run_collect_260 (
    i_lang              in com_api_type_pkg.t_dict_value
  , i_inst_id           in com_api_type_pkg.t_tiny_id
  , i_agent_id          in com_api_type_pkg.t_short_id
  , i_date_start        in date
  , i_date_end          in date
) is
begin
    for i in 1..2 loop
        collect_data_form_260(
            i_lang            => i_lang
          , i_inst_id         => i_inst_id
          , i_agent_id        => i_agent_id
          , i_date_start      => i_date_start
          , i_date_end        => i_date_end
          , i_level_refresh   => i
        );

        commit;
    end loop;
end run_collect_260;

end cst_api_form_260_pkg;
/
