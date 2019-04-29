create or replace package body rus_api_form_250_pkg is

procedure get_header_footer (
    i_lang             in com_api_type_pkg.t_dict_value
    , i_inst_id        in com_api_type_pkg.t_tiny_id
    , i_agent_id       in com_api_type_pkg.t_short_id   default null
    , i_date_end       in date
    , o_header     out    xmltype
    , o_footer     out    xmltype
)
is
    l_bank_name     com_api_type_pkg.t_name;
    l_bank_address  com_api_type_pkg.t_name;
    l_bic           com_api_type_pkg.t_name;
    l_code_okpo     com_api_type_pkg.t_name;
    l_reg_no        com_api_type_pkg.t_name;
    l_serial_no     com_api_type_pkg.t_name;
    l_code_okato    com_api_type_pkg.t_name;
    l_agent_name    com_api_type_pkg.t_name;
    l_contact_data  com_api_type_pkg.t_full_desc;
begin
    begin
        select get_text ('OST_INSTITUTION', 'NAME', i_inst_id, i_lang)
             , nvl(com_api_flexible_data_pkg.get_flexible_value('FLX_BANK_ID_CODE', ost_api_const_pkg.ENTITY_TYPE_INSTITUTION, i_inst_id), 99999)
             , com_api_flexible_data_pkg.get_flexible_value('RUS_OKPO', ost_api_const_pkg.ENTITY_TYPE_INSTITUTION, i_inst_id)
             , com_api_flexible_data_pkg.get_flexible_value('RUS_OGRN', ost_api_const_pkg.ENTITY_TYPE_INSTITUTION, i_inst_id)
             , com_api_flexible_data_pkg.get_flexible_value('RUS_REG_NUM', ost_api_const_pkg.ENTITY_TYPE_INSTITUTION, i_inst_id)
             , get_text ('OST_AGENT', 'NAME', i_agent_id, i_lang)
          into l_bank_name
             , l_bic
             , l_code_okpo
             , l_reg_no
             , l_serial_no
             , l_agent_name
          from dual;
    exception 
        when others 
        then null;
    end;

    begin
        select com_api_address_pkg.get_address_string (o.address_id, i_lang ) address
             , a.region_code
          into l_bank_address
             , l_code_okato
          from com_address_object o
             , com_address a
         where o.entity_type = decode (i_agent_id, null, ost_api_const_pkg.ENTITY_TYPE_INSTITUTION, ost_api_const_pkg.ENTITY_TYPE_AGENT)
           and o.object_id = decode (i_agent_id, null, i_inst_id, i_agent_id)
           and o.address_type = 'ADTPLGLA' --'ADTPBSNA'
           and a.id = o.address_id ;
    exception 
        when others 
        then null;
    end;

    begin
        select phone || decode(phone,null,null,', ') || e_mail
          into l_contact_data
          from (
               select max (decode(d.commun_method,com_api_const_pkg.COMMUNICATION_METHOD_MOBILE,commun_address,null) ) as phone
                    , max (decode(d.commun_method,com_api_const_pkg.COMMUNICATION_METHOD_EMAIL,commun_address,null) ) as e_mail
                 from com_contact_object o
                    , com_contact_data   d
                where o.object_id = com_ui_user_env_pkg.get_person_id
                  and o.entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON
                  and o.contact_type = com_api_const_pkg.CONTACT_TYPE_PRIMARY
                  and d.contact_id = o.contact_id
                  and commun_method in (com_api_const_pkg.COMMUNICATION_METHOD_MOBILE, com_api_const_pkg.COMMUNICATION_METHOD_EMAIL)  -- mobile phone, e-mail
               );
    exception 
        when others 
        then null;
    end;

    -- header
    select xmlelement( "header"
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
    select xmlelement( "footer"
               , xmlelement( "user_name", com_ui_person_pkg.get_person_name( acm_api_user_pkg.get_person_id( get_user_name ), i_lang ) )
               , xmlelement( "rpt_date" , to_char(com_api_sttl_day_pkg.get_sysdate,'dd.mm.yyyy hh24:mi' ) )
               , xmlelement( "phone"    , l_contact_data )
           ) xml
      into o_footer
      from dual;
end;

function get_reversal_amount (
    i_oper_id          in com_api_type_pkg.t_long_id
    , i_amount_rev     in com_api_type_pkg.t_money
    , i_inst_id        in com_api_type_pkg.t_tiny_id
    , i_date_start     in date
    , i_date_end       in date
) return com_api_type_pkg.t_money
is
    l_amount_origin     com_api_type_pkg.t_money;
    l_oper_date_origin  date;
begin
    select oper_date
         , decode ( oper_currency, '643', oper_amount
                                 , com_api_rate_pkg.convert_amount (
                                       i_src_amount        => oper_amount
                                       , i_src_currency    => oper_currency
                                       , i_dst_currency    => '643'
                                       , i_rate_type       => 'RTTPCBRF'
                                       , i_inst_id         => i_inst_id
                                       , i_eff_date        => oper_date
                                       , i_mask_exception  => 0
                                       , i_exception_value => 0
                                   )
                  )
      into l_oper_date_origin
         , l_amount_origin
      from opr_operation
     where id = i_oper_id;

    if l_amount_origin <> i_amount_rev then
        return l_amount_origin - i_amount_rev;
    else
        if l_oper_date_origin between i_date_start and i_date_end then
            return i_amount_rev * -1;
        else
            return i_amount_rev;
        end if;
    end if;

exception 
    when others 
    then return i_amount_rev;
end;

procedure run_rpt_form_250_1 (
    o_xml          out    clob
    , i_lang           in com_api_type_pkg.t_dict_value
    , i_inst_id        in com_api_type_pkg.t_tiny_id
    , i_agent_id       in com_api_type_pkg.t_short_id   default null
    , i_date_start     in date
    , i_date_end       in date
)
is
    l_result        xmltype;
    l_part_1        xmltype;
    l_header        xmltype;
    l_footer        xmltype;
begin
    trc_log_pkg.debug (
        i_text         => 'rus_api_form_250_pkg.run_rpt_form_250_1 [#1][#2][#3][#4]'
        , i_env_param1 => i_lang
        , i_env_param2 => i_inst_id
        , i_env_param3 => i_agent_id
        , i_env_param4 => i_date_start
    );

    get_header_footer (
        i_lang        => i_lang
      , i_inst_id     => i_inst_id
      , i_agent_id    => i_agent_id
      , i_date_end    => i_date_end
      , o_header      => l_header
      , o_footer      => l_footer
    ) ;

    -- data
    select xmlelement ( "part1", xmlagg (t.xml) )
      into l_part_1
      from (
           select xmlagg( 
                      xmlelement
                          ( "table"
                          , xmlelement( "region_code"           , x.region_code           )
                          , xmlelement( "customer_type"         , x.customer_type         )
                          , xmlelement( "row_type"              , x.row_type              )
                          , xmlelement( "card_type_column_name" , x.card_type_column_name )
                          , xmlelement( "customer_count"        , x.customer_count        )
                          , xmlelement( "card_count"            , x.card_count            )
                          , xmlelement( "active_card_count"     , x.active_card_count     )
                          , xmlelement( "oper_amount_debit"     , x.oper_amount_debit     )
                          , xmlelement( "oper_amount_credit"    , x.oper_amount_credit    )
                          , xmlelement( "domestic_cash_count"   , x.domestic_cash_count   )
                          , xmlelement( "domestic_cash_amount"  , x.domestic_cash_amount  )
                          , xmlelement( "foreign_cash_count"    , x.foreign_cash_count    )
                          , xmlelement( "foreign_cash_amount"   , x.foreign_cash_amout    )
                          , xmlelement( "domestic_purch_count"  , x.domestic_purch_count  )
                          , xmlelement( "domestic_purch_amount" , x.domestic_purch_amount )
                          , xmlelement( "foreign_purch_count"   , x.foreign_purch_count   )
                          , xmlelement( "foreign_purch_amount"  , x.foreign_purch_amount  )
                          , xmlelement( "customs_count"         , x.customs_count         )
                          , xmlelement( "customs_amount"        , x.customs_amount        )
                          , xmlelement( "other_count"           , x.other_count           )
                          , xmlelement( "other_amount"          , x.other_amount          )
                          , xmlelement( "internet_count"        , x.internet_count        )
                          , xmlelement( "internet_amount"       , x.internet_amount       )
                          , xmlelement( "mobile_unit_count"     , x.mobile_count          )
                          , xmlelement( "mobile_unit_amount"    , x.mobile_amount         )
                          , xmlelement( "nocash_total_count"    , x.nocash_total_count    )
                          , xmlelement( "nocash_total_amount"   , x.nocash_total_amount   )
                          , xmlelement( "internet_shop_count"   , x.internet_shop_count   )
                          , xmlelement( "internet_shop_amount"  , x.internet_shop_amount  )
                          )
                  ) xml
             from (
                    select region_code
                         , customer_type
                         , network_id
                         , case when customer_type is null and network_id is null then 3
                                when customer_type is not null then 1
                           end as row_type
                         , case when card_feature is not null then card_feature
                                when card_feature is null and network_id is not null then network_name
                                when card_feature is null and network_id is null and customer_type is not null then customer_type
                                when card_feature is null and network_id is null and customer_type is null and region_code is not null then region_name
                                when card_feature is null and network_id is null and customer_type is null and region_code is null then 'total'
                           end as card_type_column_name
                         , customer_count
                         , card_count
                         , active_card_count
                         , to_char( oper_amount_debit,     'FM999999999999999990.00' ) as oper_amount_debit
                         , to_char( oper_amount_credit,    'FM999999999999999990.00' ) as oper_amount_credit
                         , to_char( domestic_cash_count  )                             as domestic_cash_count
                         , to_char( domestic_cash_amount,  'FM999999999999999990.00' ) as domestic_cash_amount
                         , to_char( foreign_cash_count   )                             as foreign_cash_count
                         , to_char( foreign_cash_amout,    'FM999999999999999990.00' ) as foreign_cash_amout
                         , to_char( domestic_purch_count )                             as domestic_purch_count
                         , to_char( domestic_purch_amount, 'FM999999999999999990.00' ) as domestic_purch_amount
                         , to_char( foreign_purch_count  )                             as foreign_purch_count
                         , to_char( foreign_purch_amount,  'FM999999999999999990.00' ) as foreign_purch_amount
                         , to_char( customs_count        )                             as customs_count
                         , to_char( customs_amount,        'FM999999999999999990.00' ) as customs_amount
                         , to_char( other_count          )                             as other_count
                         , to_char( other_amount,          'FM999999999999999990.00' ) as other_amount
                         , to_char( nocash_total_count   )                             as nocash_total_count
                         , to_char( nocash_total_amount,   'FM999999999999999990.00' ) as nocash_total_amount
                         , to_char( internet_count       )                             as internet_count
                         , to_char( internet_amount,       'FM999999999999999990.00' ) as internet_amount
                         , to_char( internet_shop_count  )                             as internet_shop_count
                         , to_char( internet_shop_amount,  'FM999999999999999990.00' ) as internet_shop_amount
                         , to_char( mobile_count         )                             as mobile_count
                         , to_char( mobile_amount,         'FM999999999999999990.00' ) as mobile_amount
                      from ( select region_code
                                  , decode( region_code, null, null, 'region_code name for '||region_code ) as region_name
                                  , customer_type
                                  , network_id
                                  --, get_text ('net_network', 'name', network_id, i_lang ) as network_name
                                  , com_api_flexible_data_pkg.get_flexible_value (
                                          i_field_name      => 'NETWORK_NAME_CBRF250'
                                        , i_entity_type     => net_api_const_pkg.ENTITY_TYPE_NETWORK
                                        , i_object_id       => network_id
                                    ) as network_name
                                  , card_type as card_feature
                                  , customer_count
                                  , card_count          , active_card_count
                                  , oper_amount_debit   , oper_amount_credit
                                  , domestic_cash_count , domestic_cash_amount
                                  , foreign_cash_count  , foreign_cash_amout
                                  , domestic_purch_count, domestic_purch_amount
                                  , foreign_purch_count , foreign_purch_amount
                                  , customs_count       , customs_amount
                                  , other_count         , other_amount
                                  , domestic_purch_count + foreign_purch_count + customs_count + other_count     as nocash_total_count
                                  , domestic_purch_amount + foreign_purch_amount + customs_amount + other_amount as nocash_total_amount
                                  , internet_count      , internet_amount
                                  , internet_shop_count , internet_shop_amount
                                  , mobile_count        , mobile_amount
                                  , pmode
                               from rus_form_250_1_report
                              where inst_id = i_inst_id
                                and report_date = trunc(i_date_start, 'Q')
                              order by region_code nulls last
                                     , decode (customer_type, null, null
                                                            , com_api_const_pkg.ENTITY_TYPE_PERSON, 1
                                                            , com_api_const_pkg.ENTITY_TYPE_COMPANY, 2) nulls last
                                     , network_id  nulls last
                                     , decode (card_type, null, null
                                                        , net_api_const_pkg.CARD_FEATURE_STATUS_DEBIT, 1
                                                        , net_api_const_pkg.CARD_FEATURE_STATUS_OVERDRAFT, 2
                                                        , net_api_const_pkg.CARD_FEATURE_STATUS_CREDIT, 3
                                                        , net_api_const_pkg.CARD_FEATURE_STATUS_CNCTLESS, 4
                                                        , 'OPERCNTL', 5) nulls first
                           )
                  ) x
           ) t;

    select xmlelement ( "report"
             , l_header
             , l_part_1
             , l_footer
           )
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug ( i_text => 'rus_api_form_250_pkg.run_rpt_form_250_1 - ok' );

exception
    --when no_data_found then trc_log_pkg.debug ( i_text => sqlerrm );
    when others 
    then trc_log_pkg.debug ( i_text => sqlerrm );
         raise_application_error (-20001, sqlerrm);
end;


procedure run_rpt_form_250_2 (
    o_xml          out    clob
    , i_lang           in com_api_type_pkg.t_dict_value
    , i_inst_id        in com_api_type_pkg.t_tiny_id
    , i_agent_id       in com_api_type_pkg.t_short_id   default null
    , i_date_start     in date
    , i_date_end       in date
)
is
    l_result        xmltype;
    l_part_2        xmltype;
    l_header        xmltype;
    l_footer        xmltype;
begin
    trc_log_pkg.debug (
        i_text         => 'rus_api_form_250_pkg.run_rpt_form_250_2 [#1][#2][#3][#4][#5]]'
        , i_env_param1 => i_lang
        , i_env_param2 => i_inst_id
        , i_env_param3 => i_agent_id
        , i_env_param4 => i_date_start
        , i_env_param5 => i_date_end
    );

    get_header_footer (
        i_lang          => i_lang
        , i_inst_id     => i_inst_id
        , i_agent_id    => i_agent_id
        , i_date_end    => i_date_end
        , o_header      => l_header
        , o_footer      => l_footer
    );

    -- data
    select xmlelement ( "part2", xmlagg (t.xml) )
      into l_part_2
      from (      
           select xmlagg( 
                      xmlelement
                          ( "table"
                          , xmlelement( "row_type"          , x.row_type           )
                          , xmlelement( "region_code"       , x.region_code        )
                          , xmlelement( "region_name"       , decode( x.region_code, null, null, 'region '||x.region_code ) )
                          , xmlelement( "network_id"        , x.network_id         )
                          , xmlelement( "network_name"      , get_text ('net_network', 'name', x.network_id, i_lang ) )
                          , xmlelement( "atm_all"           , x.atm_all            )
                          , xmlelement( "atm_cashout_all"   , x.atm_cashout_all    )
                          , xmlelement( "atm_cashout_pmt"   , x.atm_cashout_pmt    )
                          , xmlelement( "atm_cashin_all"    , x.atm_cashin_all     )
                          , xmlelement( "atm_cashin_card"   , x.atm_cashin_card    )
                          , xmlelement( "atm_cashin_no_card", x.atm_cashin_no_card )
                          , xmlelement( "pos_commerce"      , x.pos_commerce       )
                          , xmlelement( "epos"              , x.epos               )
                          , xmlelement( "pos_cashpoint"     , x.pos_cashpoint      )
                          , xmlelement( "impr_commerce"     , x.impr_commerce      )
                          , xmlelement( "impr_cashpoint"    , x.impr_cashpoint     )
                          )
                  ) xml
             from ( 
                  with terms as
                     ( select region_code
                            , network_id
                            , case when (terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM)
                                   then id 
                                   else null 
                              end as atm_all            --atms all
                            , case when (terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM and is_cash_out = 1)
                                   then id 
                                   else null 
                              end as atm_cashout_all    --atms cashout all
                            , case when (terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM and is_cash_out = 1 and is_payment = 1)
                                   then id 
                                   else null 
                              end as atm_cashout_pmt    --atms cashout with payment
                            , case when (terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM and is_cash_in = 1)
                                   then id 
                                   else null 
                              end as atm_cashin_all     --atms cashin all
                            , case when (terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM and is_cash_in = 1 and is_card_use = 1)
                                   then id 
                                   else null 
                              end as atm_cashin_card    --atms cashin without card
                            , case when (terminal_type = acq_api_const_pkg.TERMINAL_TYPE_ATM and is_cash_in = 1 and is_card_use = 0)
                                   then id 
                                   else null 
                              end as atm_cashin_no_card --atms cashin with card
                            , case when (terminal_type = acq_api_const_pkg.TERMINAL_TYPE_POS and mcc <> 6010)
                                   then id 
                                   else null 
                              end as pos_commerce       --el.terms in trading organisation
                            , case when (terminal_type = acq_api_const_pkg.TERMINAL_TYPE_POS and mcc = 6010)
                                   then id 
                                   else null 
                              end as pos_cashpoint      --el.terms remote access
                            , case when (terminal_type = acq_api_const_pkg.TERMINAL_TYPE_EPOS)
                                   then id 
                                   else null 
                              end as epos               --el.terms in cash out point
                            , case when (terminal_type = acq_api_const_pkg.TERMINAL_TYPE_IMPRINTER and mcc <> 6010)
                                   then id 
                                   else null 
                              end as impr_commerce      --imprinters in trading organisation
                            , case when (terminal_type = acq_api_const_pkg.TERMINAL_TYPE_IMPRINTER and mcc = 6010)
                                   then id 
                                   else null 
                              end as impr_cashpoint     --imprinters in cash out point
                       from (
                              select a.id
                                   , nvl(adr.region_code, 'undefined') as region_code
                                   , com_api_type_pkg.convert_to_number(arr_e.element_value) as network_id
                                   , a.terminal_type
                                   , nvl( decode(a.mcc, null, (select mcc from acq_merchant where id=a.merchant_id), a.mcc), -1) mcc
                                   , decode( nvl(a.cash_dispenser_present, 0), 0, 0, 1 ) is_cash_out
                                   , decode( nvl(a.cash_in_present,        0), 0, 0, 1 ) is_cash_in
                                   , decode( nvl(a.payment_possibility,    0), 0, 0, 1 ) is_payment
                                   , decode( nvl(a.use_card_possibility,   0), 0, 0, 1 ) is_card_use
                                from acq_terminal       a
                                   , com_array          arr
                                   , com_array_element  arr_e
                                   , com_address_object adr_o
                                   , com_address        adr
                               where (  ( i_inst_id <> ost_api_const_pkg.DEFAULT_INST and (a.inst_id = i_inst_id) )
                                      or( i_inst_id = ost_api_const_pkg.DEFAULT_INST and exists (select 1 from ost_institution where network_id = 1001 and id = a.inst_id ) )
                                     )
                                 and a.status = acq_api_const_pkg.TERMINAL_STATUS_ACTIVE    -- active terminals
                                 and nvl(a.is_template, 0) <> 1
                                 and a.available_network = arr.id
                                 and arr.id = arr_e.array_id
                                 and arr_e.element_value in (select x.element_value        -- networks for form 250
                                                               from com_array_element x, com_array y
                                                              where x.array_id = y.id
                                                                and y.array_type_id = 4
                                                            )
                                 and (i_agent_id is null or i_agent_id = (select agent_id from prd_contract where id = a.contract_id))
                                 and adr_o.object_id(+) = a.id
                                 and adr_o.entity_type(+) = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                                 and adr_o.address_type(+) = 'ADTPBSNA'
                                 and adr.id(+) = adr_o.address_id
                            )
                     )
                  select
                         case when region_code is null and network_id is null then 'total'
                              when region_code is not null and network_id is null then 'region'
                              when region_code is not null and network_id is not null then 'network'
                         end as row_type
                       , region_code
                       , network_id
                       , count(distinct atm_all            ) atm_all
                       , count(distinct atm_cashout_all    ) atm_cashout_all
                       , count(distinct atm_cashout_pmt    ) atm_cashout_pmt
                       , count(distinct atm_cashin_all     ) atm_cashin_all
                       , count(distinct atm_cashin_card    ) atm_cashin_card
                       , count(distinct atm_cashin_no_card ) atm_cashin_no_card
                       , count(distinct pos_commerce       ) pos_commerce
                       , count(distinct epos               ) epos
                       , count(distinct pos_cashpoint      ) pos_cashpoint
                       , count(distinct impr_commerce      ) impr_commerce
                       , count(distinct impr_cashpoint     ) impr_cashpoint
                    from terms
                group by grouping sets
                      ( (region_code, network_id)
                      , (region_code )
                       --,()                 --it must be separately (after union)
                      )                      --to there were null rows "itogo" when data are absent
                   union
                  select
                         'total' as row_type
                       , null    --region_code
                       , null    --network_id
                       , count(distinct atm_all            ) atm_all
                       , count(distinct atm_cashout_all    ) atm_cashout_all
                       , count(distinct atm_cashout_pmt    ) atm_cashout_pmt
                       , count(distinct atm_cashin_all     ) atm_cashin_all
                       , count(distinct atm_cashin_card    ) atm_cashin_card
                       , count(distinct atm_cashin_no_card ) atm_cashin_no_card
                       , count(distinct pos_commerce       ) pos_commerce
                       , count(distinct epos               ) epos
                       , count(distinct pos_cashpoint      ) pos_cashpoint
                       , count(distinct impr_commerce      ) impr_commerce
                       , count(distinct impr_cashpoint     ) impr_cashpoint
                    from terms
                   order by 2, 3         --order by region_code, network_id
                  ) x
           ) t;

    select xmlelement ( "report"
             , l_header
             , l_part_2
             , l_footer
           )
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug ( i_text => 'rus_api_form_250_pkg.run_rpt_form_250_2 - ok' );

exception
    when others 
    then trc_log_pkg.debug ( i_text => sqlerrm );
         raise_application_error (-20001, sqlerrm);
end;


procedure get_data_form_250_3 (
    i_inst_id          in com_api_type_pkg.t_tiny_id
    , i_agent_id       in com_api_type_pkg.t_short_id   default null
    , i_date_start     in date
    , i_date_end       in date
    , i_lang           in com_api_type_pkg.t_dict_value default null
)
is
begin
    delete from rus_form_250_3;
  
    insert into rus_form_250_3 (
        region_code
        , subsection
        , network_id
        , payment_count_all,   payment_amount_all
        , payment_count_impr,  payment_amount_impr
        , payment_count_atm,   payment_amount_atm
        , payment_count_pos,   payment_amount_pos
        , payment_count_other, payment_amount_other
        , cash_count_all,      cash_amount_all
        , cash_count_atm,      cash_amount_atm
        , cash_count_foreign_curr, cash_amount_foreign_curr
    )
    select region_code
         , subsection
         , network_id
         , sum( case when oper_group = 5 
                     then actual_count
                     else 0
                end ) as pmt_count_all
         , round( sum( case when oper_group = 5 
                            then actual_amount 
                            else 0 
                       end )/ power(10, 5), 2) as pmt_amount_all
         , sum( case when oper_group = 5 and terminal_type in (acq_api_const_pkg.TERMINAL_TYPE_IMPRINTER) 
                     then actual_count
                     else 0 
                end ) as pmt_count_impr
         , round( sum( case when oper_group = 5 and terminal_type in (acq_api_const_pkg.TERMINAL_TYPE_IMPRINTER) 
                            then actual_amount 
                            else 0 
                       end )/ power(10, 5), 2) as pmt_amount_impr
         , sum( case when oper_group = 5 and terminal_type in (acq_api_const_pkg.TERMINAL_TYPE_ATM) 
                     then actual_count
                     else 0 
                end ) as pmt_count_atm
         , round( sum( case when oper_group = 5 and terminal_type in (acq_api_const_pkg.TERMINAL_TYPE_ATM) 
                            then actual_amount 
                            else 0 
                       end )/ power(10, 5), 2) as pmt_amount_atm
         , sum( case when oper_group = 5 and terminal_type in (acq_api_const_pkg.TERMINAL_TYPE_POS, acq_api_const_pkg.TERMINAL_TYPE_EPOS) 
                     then actual_count
                     else 0 
                end )as pmt_count_pos
         , round( sum( case when oper_group = 5 and terminal_type in (acq_api_const_pkg.TERMINAL_TYPE_POS, acq_api_const_pkg.TERMINAL_TYPE_EPOS) 
                            then actual_amount 
                            else 0 
                       end )/ power(10, 5), 2) as pmt_amount_pos
         , sum( case when oper_group = 5 and terminal_type not in (acq_api_const_pkg.TERMINAL_TYPE_IMPRINTER, acq_api_const_pkg.TERMINAL_TYPE_ATM
                                                                 , acq_api_const_pkg.TERMINAL_TYPE_POS, acq_api_const_pkg.TERMINAL_TYPE_EPOS) 
                     then actual_count
                     else 0 
                end ) as pmt_count_other
         , round( sum( case when oper_group = 5 and terminal_type not in (acq_api_const_pkg.TERMINAL_TYPE_IMPRINTER, acq_api_const_pkg.TERMINAL_TYPE_ATM
                                                                        , acq_api_const_pkg.TERMINAL_TYPE_POS, acq_api_const_pkg.TERMINAL_TYPE_EPOS)
                            then actual_amount 
                            else 0 
                       end )/ power(10, 5), 2) as pmt_amount_other
         , sum( case when oper_group = 4 
                     then actual_count
                     else 0 
                end ) as cash_count_all
         , round( sum( case when oper_group = 4 
                            then actual_amount 
                            else 0 
                       end )/ power(10, 5), 2) as cash_amount_all
         , sum( case when oper_group = 4 and terminal_type in (acq_api_const_pkg.TERMINAL_TYPE_ATM) 
                     then actual_count
                     else 0 
                end ) as cash_count_atm
         , round( sum( case when oper_group = 4 and terminal_type in (acq_api_const_pkg.TERMINAL_TYPE_ATM)
                            then actual_amount 
                            else 0 
                       end )/ power(10, 5), 2) as cash_amount_atm
         , sum( case when oper_group = 4 and foreign_currency = 1 
                     then actual_count
                     else 0 
                end ) as cash_count_foreign_curr
         , round( sum( case when oper_group = 4 and foreign_currency = 1 
                            then actual_amount 
                            else 0 
                       end )/ power(10, 5), 2) as cash_amount_foreign_curr
      from (
           select region_code
                , subsection
                , card_network_id as network_id
                , oper_group
                , terminal_type
                , foreign_currency
                , case when oper_amount = actual_amount * (-1) then -1 else 1 end as actual_count
                , actual_amount
                , oper_amount
             from (
                  select region_code
                       , card_network_id
                       , oper_group
                       , terminal_type
                       , foreign_currency
                       , case when card_us = 1 and term_us = 1 and country_opr_rf = 1 then 1
                              when card_us = 1 and term_us = 1 and country_opr_rf = 0 then 4
                              when card_us = 0 and country_iss_rf = 1 and term_us = 1 and country_opr_rf = 1 then 2
                              when card_us = 0 and country_iss_rf = 1 and term_us = 1 and country_opr_rf = 0 then 4
                              when card_us = 0 and country_iss_rf = 0 and term_us = 1 and country_opr_rf = 1 then 3
                              when card_us = 0 and country_iss_rf = 0 and term_us = 1 and country_opr_rf = 0 then 4
                              else 9
                         end as subsection
                       , oper_amount
                       , decode ( is_reversal, 0, oper_amount
                                                , rus_api_form_250_pkg.get_reversal_amount (
                                                      i_oper_id      => original_id
                                                      , i_amount_rev => oper_amount
                                                      , i_inst_id    => i_inst_id
                                                      , i_date_start => i_date_start
                                                      , i_date_end   => i_date_end + 1
                                                  )
                         ) as actual_amount
                    from (
                         select o.id as oper_id
                              , o.oper_type
                              , decode ( o.merchant_country
                                       , '643'
                                       , (
                                           select min(addr.region_code) keep(dense_rank first order by decode(addr.lang, i_lang, 1, 'LANGENG', 2, 3))
                                             from com_address addr
                                            where id = acq_api_terminal_pkg.get_terminal_address_id(opa.terminal_id, i_lang)
                                         )
                                       , null
                                ) as region_code
                              , case when o.oper_currency = '643' 
                                     then o.oper_amount
                                     when o.oper_currency in ('840', '978') 
                                     then com_api_rate_pkg.convert_amount (
                                              i_src_amount        => o.oper_amount
                                              , i_src_currency    => o.oper_currency
                                              , i_dst_currency    => '643'
                                              , i_rate_type       => 'RTTPCBRF'
                                              , i_inst_id         => i_inst_id
                                              , i_eff_date        => o.oper_date
                                              , i_mask_exception  => 0
                                              , i_exception_value => 0
                                          )
                                     when o.sttl_currency = '643' 
                                     then o.sttl_amount
                                     else com_api_rate_pkg.convert_amount (
                                              i_src_amount        => o.sttl_amount
                                              , i_src_currency    => o.sttl_currency
                                              , i_dst_currency    => '643'
                                              , i_rate_type       => 'RTTPCBRF'
                                              , i_inst_id         => i_inst_id
                                              , i_eff_date        => o.oper_date
                                              , i_mask_exception  => 0
                                              , i_exception_value => 0
                                          )
                                end  as oper_amount
                              , o.is_reversal
                              , o.original_id
                              , o.terminal_type
                              , o.oper_currency
                              , case when opi.card_country = '643' 
                                      and o.merchant_country = '643'
                                      and o.sttl_type not in (select element_value from com_array_element where array_id = 10000028)
                                     then nvl(
                                              com_api_array_pkg.conv_array_elem_v(
                                                  i_lov_id            => 1019
                                                  , i_array_type_id   => 4
                                                  , i_array_id        => 3
                                                  , i_inst_id         => ost_api_const_pkg.DEFAULT_INST
                                                  , i_elem_value      => opi.card_network_id
                                              )
                                            , to_char(opi.card_network_id)
                                          )
                                     else to_char(opi.card_network_id)
                                end
                                as card_network_id
                              , case when i_inst_id <> ost_api_const_pkg.DEFAULT_INST and nvl(opi.inst_id, -99) =  i_inst_id then 1
                                     when i_inst_id <> ost_api_const_pkg.DEFAULT_INST and nvl(opi.inst_id, -99) <> i_inst_id then 0
                                     when i_inst_id =  ost_api_const_pkg.DEFAULT_INST and nvl(ii.network_id, -99) =  1001 then 1
                                     when i_inst_id =  ost_api_const_pkg.DEFAULT_INST and nvl(ii.network_id, -99) <> 1001 then 0
                                end as card_us
                              , case when i_inst_id <> ost_api_const_pkg.DEFAULT_INST and nvl(opa.inst_id, -99) =  i_inst_id then 1
                                     when i_inst_id <> ost_api_const_pkg.DEFAULT_INST and nvl(opa.inst_id, -99) <> i_inst_id then 0
                                     when i_inst_id =  ost_api_const_pkg.DEFAULT_INST and nvl(ia.network_id, -99) =  1001 then 1
                                     when i_inst_id =  ost_api_const_pkg.DEFAULT_INST and nvl(ia.network_id, -99) <> 1001 then 0
                                end as term_us
                              , decode (opi.card_country,   '643', 1, 0) as country_iss_rf
                              , decode (o.merchant_country, '643', 1, 0) as country_opr_rf
                              , decode (o.oper_currency,    '643', 0, 1) as foreign_currency
                              , arr_oper.arr_oper_group as oper_group
                           from opr_operation   o
                              , opr_participant opi
                              , opr_participant opa
                              , ( select array_id as arr_oper_group, element_value as arr_oper_type   --operation: cash out\payments...
                                    from com_array_element where array_id in (4, 5)
                                ) arr_oper
                              , ost_institution ii
                              , ost_institution ia
                          where opi.oper_id(+) = o.id
                            and opi.participant_type(+) = com_api_const_pkg.PARTICIPANT_ISSUER
                            and opa.oper_id(+) = o.id
                            and opa.participant_type(+) = com_api_const_pkg.PARTICIPANT_ACQUIRER
                            and o.oper_date >= i_date_start
                            and o.oper_date <= i_date_end + 1 - com_api_const_pkg.ONE_SECOND
                            and ( ( i_inst_id <>ost_api_const_pkg.DEFAULT_INST and (opi.inst_id = i_inst_id or opa.inst_id = i_inst_id) )
                                 or
                                  ( i_inst_id = ost_api_const_pkg.DEFAULT_INST and exists
                                    (select 1 from ost_institution where network_id = 1001 and (id = opi.inst_id or id = opa.inst_id) )
                                  )
                                )
                            and ( o.match_status = opr_api_const_pkg.OPERATION_MATCH_DONT_REQ_MATCH or o.msg_type = opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT )
                            and o.status in (opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
                                           , opr_api_const_pkg.OPERATION_STATUS_PROCESSED
                                           , opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED)
                            and o.oper_type = arr_oper.arr_oper_type                 -- arr_oper: 4-cash out, 5-payments...
                            and opi.card_network_id in ( select com_api_type_pkg.convert_to_number (element_value)
                                                           from com_array_element
                                                          where array_id in (select id from com_array where array_type_id = 4)
                                                       )
                            and ( ( i_agent_id is null )
                                  or (   ( i_agent_id = ( select agent_id from acq_terminal a, prd_contract c
                                                           where a.id = opa.terminal_id and c.id = a.contract_id ) )
                                      or ( i_agent_id = ( select agent_id from iss_card_instance where card_id = opi.card_id ) )
                                   )
                                )
                            and ii.id(+) = opi.inst_id
                            and ia.id(+) = opa.inst_id
                         )
                   where term_us = 1 --( card_us = 1 or term_us = 1 )
                  )
            where subsection in (1, 2, 3, 4)
           ) opr
     group by region_code, subsection, network_id;

    commit;

    trc_log_pkg.debug ( i_text => 'rus_api_form_250_pkg.get_data_form_250_3 1' );

    --add unformed rows(subsection + network_id) into formed region
    insert into rus_form_250_3 (
        region_code
        , subsection
        , network_id
        , payment_count_all
        , payment_amount_all
        , payment_count_impr
        , payment_amount_impr
        , payment_count_atm
        , payment_amount_atm
        , payment_count_pos
        , payment_amount_pos
        , payment_count_other
        , payment_amount_other
        , cash_count_all
        , cash_amount_all
        , cash_count_atm
        , cash_amount_atm
        , cash_count_foreign_curr
        , cash_amount_foreign_curr
    )
    select region_code, subsection, network_id, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      from
           ( select region_code, subsection, network_id
               from ( select distinct region_code from rus_form_250_3 where subsection <> 4)
                  , ( select com_api_type_pkg.convert_to_number (element_value) network_id
                        from com_array_element
                       where array_id in (select id from com_array where array_type_id = 4)
                    )
                  , ( select rownum subsection from dual connect by level <= 3)
              union
             select null, subsection, network_id
               from ( select com_api_type_pkg.convert_to_number (element_value) network_id
                        from com_array_element
                       where array_id in (select id from com_array where array_type_id = 4)
                    )
                  , ( select 4 subsection from dual)
           ) a
     where not exists ( select 1 from rus_form_250_3 b
                         where nvl(a.region_code, '&') = nvl(b.region_code, '&')
                           and a.subsection = b.subsection
                          and a.network_id = b.network_id
                      );

    commit;

    trc_log_pkg.debug ( i_text => 'rus_api_form_250_pkg.get_data_form_250_3 - ok' );

exception 
    when others 
    then raise_application_error (-20001, sqlerrm);
end;

procedure run_rpt_form_250_3 (
    o_xml          out    clob
    , i_lang           in com_api_type_pkg.t_dict_value
    , i_inst_id        in com_api_type_pkg.t_tiny_id
    , i_agent_id       in com_api_type_pkg.t_short_id   default null
    , i_date_start     in date
    , i_date_end       in date
)
is
    l_result        xmltype;
    l_part_3        xmltype;
    l_header        xmltype;
    l_footer        xmltype;
begin
    trc_log_pkg.debug (
        i_text         => 'rus_api_form_250_pkg.run_rpt_form_250_3 [#1][#2][#3][#4][#5]]'
        , i_env_param1 => i_lang
        , i_env_param2 => i_inst_id
        , i_env_param3 => i_agent_id
        , i_env_param4 => i_date_start
        , i_env_param5 => i_date_end
    );

    get_data_form_250_3 (
        i_inst_id      => i_inst_id
        , i_agent_id   => i_agent_id
        , i_date_start => trunc(i_date_start)
        , i_date_end   => trunc(i_date_end)
        , i_lang       => i_lang
    );

    get_header_footer (
        i_lang         => i_lang
        , i_inst_id    => i_inst_id
        , i_agent_id   => i_agent_id
        , i_date_end   => i_date_end
        , o_header     => l_header
        , o_footer     => l_footer
    );

    -- data
    select xmlelement ( "part3", xmlagg (t.xml) )
      into l_part_3
      from (
           select xmlagg ( 
                      xmlelement ( 
                          "table"
                          , xmlelement( "region_code"       , x.region_code      )
                          , xmlelement( "subsection"        , x.subsection       )
                          , xmlelement( "network_id"        , x.network_id       )
                          , xmlelement( "network_name"      , x.network_name     )
                          , xmlelement( "region_name"       , x.region_name      )
                          , xmlelement( "row_type"          , x.row_type         )
                          , xmlelement( "pmt_count_all"     , x.pmt_count_all    )
                          , xmlelement( "pmt_amount_all"    , x.pmt_amount_all   )
                          , xmlelement( "pmt_count_impr"    , x.pmt_count_impr   )
                          , xmlelement( "pmt_amount_impr"   , x.pmt_amount_impr  )
                          , xmlelement( "pmt_count_atm"     , x.pmt_count_atm    )
                          , xmlelement( "pmt_amount_atm"    , x.pmt_amount_atm   )
                          , xmlelement( "pmt_count_pos"     , x.pmt_count_pos    )
                          , xmlelement( "pmt_amount_pos"    , x.pmt_amount_pos   )
                          , xmlelement( "pmt_count_other"   , x.pmt_count_other  )
                          , xmlelement( "pmt_amount_other"  , x.pmt_amount_other )
                          , xmlelement( "cash_count_all"    , x.cash_count_all   )
                          , xmlelement( "cash_amount_all"   , x.cash_amount_all  )
                          , xmlelement( "cash_count_atm"    , x.cash_count_atm   )
                          , xmlelement( "cash_amount_atm"   , x.cash_amount_atm  )
                          , xmlelement( "cash_count_foreign_curr"  , x.cash_count_foreign_curr  )
                          , xmlelement( "cash_amount_foreign_curr" , x.cash_amount_foreign_curr )
                      )
                  ) xml
             from (
                  select region_code
                       , subsection
                       , network_id
                       , case when network_id is not null
                              then com_api_flexible_data_pkg.get_flexible_value (
                                       i_field_name        => 'NETWORK_NAME_CBRF250'
                                       , i_entity_type     => net_api_const_pkg.ENTITY_TYPE_NETWORK
                                       , i_object_id       => network_id
                                   )
                              else null
                         end as network_name
                       , case when network_id is null and subsection is null and region_code is not null
                              then decode( region_code, null, null, 'region '||region_code )
                              else null
                         end as region_name
                       , case when region_code is null and subsection is null and network_id is null then 'total'
                              when region_code is not null and subsection is null then 'region'
                              when subsection in (1, 2, 3) then 'section123'
                              when subsection = 4          then 'section4'
                         end as row_type
                       , pmt_count_all
                       , to_char( pmt_amount_all,           'FM999999999999999990.00' ) as pmt_amount_all
                       , pmt_count_impr
                       , to_char( pmt_amount_impr,          'FM999999999999999990.00' ) as pmt_amount_impr
                       , pmt_count_atm
                       , to_char( pmt_amount_atm,           'FM999999999999999990.00' ) as pmt_amount_atm
                       , pmt_count_pos
                       , to_char( pmt_amount_pos,           'FM999999999999999990.00' ) as pmt_amount_pos
                       , pmt_count_other
                       , to_char( pmt_amount_other,         'FM999999999999999990.00' ) as pmt_amount_other
                       , cash_count_all
                       , to_char( cash_amount_all,          'FM999999999999999990.00' ) as cash_amount_all
                       , cash_count_atm
                       , to_char( cash_amount_atm,          'FM999999999999999990.00' ) as cash_amount_atm
                       , cash_count_foreign_curr
                       , to_char( cash_amount_foreign_curr, 'FM999999999999999990.00' ) as cash_amount_foreign_curr
                    from (
                         select region_code
                              , subsection
                              , network_id
                              , sum(payment_count_all   ) pmt_count_all
                              , sum(payment_amount_all  ) pmt_amount_all
                              , sum(payment_count_impr  ) pmt_count_impr
                              , sum(payment_amount_impr ) pmt_amount_impr
                              , sum(payment_count_atm   ) pmt_count_atm
                              , sum(payment_amount_atm  ) pmt_amount_atm
                              , sum(payment_count_pos   ) pmt_count_pos
                              , sum(payment_amount_pos  ) pmt_amount_pos
                              , sum(payment_count_other ) pmt_count_other
                              , sum(payment_amount_other) pmt_amount_other
                              , sum(cash_count_all      ) cash_count_all
                              , sum(cash_amount_all     ) cash_amount_all
                              , sum(cash_count_atm      ) cash_count_atm
                              , sum(cash_amount_atm     ) cash_amount_atm
                              , sum(cash_count_foreign_curr ) cash_count_foreign_curr
                              , sum(cash_amount_foreign_curr) cash_amount_foreign_curr
                           from rus_form_250_3
                          where subsection <> 4
                       group by grouping sets
                              ( (region_code, subsection, network_id)
                               ,(region_code, subsection)
                               ,(region_code )
                              )
                          union
                         select region_code
                              , subsection
                              , network_id
                              , sum(payment_count_all   ) pmt_count_all
                              , sum(payment_amount_all  ) pmt_amount_all
                              , sum(payment_count_impr  ) pmt_count_impr
                              , sum(payment_amount_impr ) pmt_amount_impr
                              , sum(payment_count_atm   ) pmt_count_atm
                              , sum(payment_amount_atm  ) pmt_amount_atm
                              , sum(payment_count_pos   ) pmt_count_pos
                              , sum(payment_amount_pos  ) pmt_amount_pos
                              , sum(payment_count_other ) pmt_count_other
                              , sum(payment_amount_other) pmt_amount_other
                              , sum(cash_count_all      ) cash_count_all
                              , sum(cash_amount_all     ) cash_amount_all
                              , sum(cash_count_atm      ) cash_count_atm
                              , sum(cash_amount_atm     ) cash_amount_atm
                              , sum(cash_count_foreign_curr ) cash_count_foreign_curr
                              , sum(cash_amount_foreign_curr) cash_amount_foreign_curr
                           from rus_form_250_3
                          where subsection = 4
                       group by grouping sets
                              ( (region_code, subsection, network_id)
                               ,(region_code, subsection)
                              )
                          union
                         select null as region_code
                              , null as subsection
                              , null as network_id
                              , sum(payment_count_all   ) pmt_count_all
                              , sum(payment_amount_all  ) pmt_amount_all
                              , sum(payment_count_impr  ) pmt_count_impr
                              , sum(payment_amount_impr ) pmt_amount_impr
                              , sum(payment_count_atm   ) pmt_count_atm
                              , sum(payment_amount_atm  ) pmt_amount_atm
                              , sum(payment_count_pos   ) pmt_count_pos
                              , sum(payment_amount_pos  ) pmt_amount_pos
                              , sum(payment_count_other ) pmt_count_other
                              , sum(payment_amount_other) pmt_amount_other
                              , sum(cash_count_all      ) cash_count_all
                              , sum(cash_amount_all     ) cash_amount_all
                              , sum(cash_count_atm      ) cash_count_atm
                              , sum(cash_amount_atm     ) cash_amount_atm
                              , sum(cash_count_foreign_curr ) cash_count_foreign_curr
                              , sum(cash_amount_foreign_curr) cash_amount_foreign_curr
                           from rus_form_250_3
                         )
                   order by region_code nulls last
                          , subsection
                          , case when region_code is not null and subsection is null   --for locating total by region in first row
                                 then decode (network_id, null, -9999, network_id)     --below - total by region + network
                                 else network_id
                            end
                  ) x
           ) t;

    select xmlelement ( "report"
             , l_header
             , l_part_3
             , l_footer
           )
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug ( i_text => 'rus_api_form_250_pkg.run_rpt_form_250_3 - ok' );

exception
    when others 
    then trc_log_pkg.debug ( i_text => sqlerrm );
         raise_application_error (-20011, sqlerrm);
end;

---------------------------
end;
/
