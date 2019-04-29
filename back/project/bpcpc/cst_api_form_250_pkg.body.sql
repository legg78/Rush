create or replace package body cst_api_form_250_pkg is

procedure get_header_footer(
    i_lang             in com_api_type_pkg.t_dict_value
  , i_inst_id          in com_api_type_pkg.t_tiny_id
  , i_agent_id         in com_api_type_pkg.t_short_id  default null
  , i_date_end         in date
  , o_header       out    xmltype
  , o_footer       out    xmltype
) is
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
        select get_text(
                   i_table_name  => 'OST_INSTITUTION'
                 , i_column_name => 'NAME'
                 , i_object_id   => i_inst_id
                 , i_lang        => i_lang
               )
             , nvl(com_api_flexible_data_pkg.get_flexible_value(
                    i_field_name  => 'FLX_BANK_ID_CODE'
                  , i_entity_type => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                  , i_object_id   => i_inst_id
                  ), 99999)
             , com_api_flexible_data_pkg.get_flexible_value(
                   i_field_name  => 'RUS_OKPO'
                 , i_entity_type => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                 , i_object_id   => i_inst_id
               )
             , com_api_flexible_data_pkg.get_flexible_value(
                   i_field_name  => 'RUS_OGRN'
                 , i_entity_type => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                 , i_object_id   => i_inst_id
               )
             , com_api_flexible_data_pkg.get_flexible_value(
                   i_field_name  => 'RUS_REG_NUM'
                 , i_entity_type => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                 , i_object_id   => i_inst_id
               )
             , get_text(i_table_name  => 'OST_AGENT'
                 , i_column_name => 'NAME'
                 , i_object_id   => i_agent_id
                 , i_lang        => i_lang
               )
          into l_bank_name
             , l_bic
             , l_code_okpo
             , l_reg_no
             , l_serial_no
             , l_agent_name
          from dual;
    exception
        when others then
            null;
    end;

    begin
        select com_api_address_pkg.get_address_string(
                   i_address_id => o.address_id
                 , i_lang       => i_lang
               ) address
             , a.region_code
          into l_bank_address
             , l_code_okato
          from com_address_object o
             , com_address a
         where o.entity_type = decode(i_agent_id, null, ost_api_const_pkg.ENTITY_TYPE_INSTITUTION, ost_api_const_pkg.ENTITY_TYPE_AGENT)
           and o.object_id = decode (i_agent_id, null, i_inst_id, i_agent_id)
           and o.address_type = com_api_const_pkg.ADDRESS_TYPE_BUSINESS
           and a.id = o.address_id;
    exception
        when others then
            null;
    end;

    begin
        select phone || decode(phone, null, null, ', ') || e_mail
          into l_contact_data
          from (
              select max(decode(d.commun_method, com_api_const_pkg.COMMUNICATION_METHOD_MOBILE, commun_address, null)) as phone
                   , max(decode(d.commun_method, com_api_const_pkg.COMMUNICATION_METHOD_EMAIL, commun_address, null)) as e_mail
                from com_contact_object o
                   , com_contact_data   d
               where o.object_id = com_ui_user_env_pkg.get_person_id
                 and o.entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON
                 and o.contact_type = com_api_const_pkg.CONTACT_TYPE_PRIMARY
                 and d.contact_id = o.contact_id
                 and commun_method in (com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                                     , com_api_const_pkg.COMMUNICATION_METHOD_EMAIL)
          );
    exception
        when others then
            null;
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

end get_header_footer;

procedure clear_data_250_1 is
    l_rowcount number;
begin
    delete from cst_250_1_cfiles;
    l_rowcount := sql%rowcount;
    trc_log_pkg.debug(i_text => 'Deleted from cst_250_1_cfiles ' || l_rowcount || ' recs.');

    delete from cst_250_1_file_tran;
    l_rowcount := sql%rowcount;
    trc_log_pkg.debug(i_text => 'Deleted from cst_250_1_file_tran ' || l_rowcount || ' recs.');

    delete from cst_250_overdraft_card;
    l_rowcount := sql%rowcount;
    trc_log_pkg.debug(i_text => 'Deleted from cst_250_overdraft_card ' || l_rowcount || ' recs.');

    delete from cst_250_1_oper_tran1;
    l_rowcount := sql%rowcount;
    trc_log_pkg.debug(i_text => 'Deleted from cst_250_1_oper_tran1 ' || l_rowcount || ' recs.');

    delete from cst_250_1_oper_tran2;
    l_rowcount := sql%rowcount;
    trc_log_pkg.debug(i_text => 'Deleted from cst_250_1_oper_tran2 ' || l_rowcount || ' recs.');

    delete from cst_250_1_oper_tran3;
    l_rowcount := sql%rowcount;
    trc_log_pkg.debug(i_text => 'Deleted from cst_250_1_oper_tran3 ' || l_rowcount || ' recs.');

    delete from cst_250_1_aggr_tran;
    l_rowcount := sql%rowcount;
    trc_log_pkg.debug(i_text => 'Deleted from cst_250_1_aggr_tran ' || l_rowcount || ' recs.');
end clear_data_250_1;

procedure i_put(
    i_msg in varchar2
  , i_is_delimeter in number default 0) is
begin
    if i_is_delimeter = 1 then
        trc_log_pkg.debug(i_text => '----------------------------------------------------------');
    end if;

    trc_log_pkg.debug(
        i_text        => i_msg || ' [#1]'
      , i_env_param1  => 250
    );
end i_put;

procedure collect_data_form_250_1(
    i_lang              in com_api_type_pkg.t_dict_value
  , i_inst_id           in com_api_type_pkg.t_tiny_id
  , i_agent_id          in com_api_type_pkg.t_short_id
  , i_date_start        in date
  , i_date_end          in date
  , i_level_refresh     in com_api_type_pkg.t_tiny_id
  , i_one_region        in com_api_type_pkg.t_boolean
) is
    l_rowcount number;

    procedure refresh_cst_250_overdraft_card is
    begin
        delete from cst_250_overdraft_card;

        l_rowcount := sql%rowcount;
        i_put('Deleted from cst_250_overdraft_card '||l_rowcount||' recs.', 1);

        insert into cst_250_overdraft_card
        select distinct ao.object_id as card_id
          from acc_balance_vw b
          join acc_account_object_vw ao on ao.account_id = b.account_id and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
          join iss_card c on c.id = ao.object_id
         where b.inst_id = i_inst_id
           and b.balance_type = crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED
           and c.card_type_id not in (5004, 5012, 5022, 5030, 1009, 1021)
           and b.balance > 0;

        l_rowcount := sql%rowcount;
        i_put('Inserted into cst_250_overdraft_card ' || l_rowcount || ' recs.');
    exception
        when others then
            i_put('ERROR! refresh_cst_250_overdraft_card ' || SQLERRM, 1);
    end refresh_cst_250_overdraft_card;

    procedure refresh_cst_250_1_cfiles is
    begin
        delete from cst_250_1_cfiles f
         where f.session_file_id between com_api_id_pkg.get_from_id(i_date_start) and com_api_id_pkg.get_till_id(i_date_end);

        l_rowcount := sql%rowcount;
        i_put('Deleted from cst_250_1_cfiles ' || l_rowcount || ' recs.', 1);

        insert into cst_250_1_cfiles
        select distinct f.session_file_id, sf.file_name
          from cst_oper_file f
          join prc_session_file sf on sf.id = f.session_file_id
         where f.session_file_id between com_api_id_pkg.get_from_id(i_date_start) and com_api_id_pkg.get_till_id(i_date_end)
           and f.file_type = 'FLTPOWC'; -- TODO this type of file is not supported now

        l_rowcount := sql%rowcount;
        i_put('Inserted into cst_250_1_cfiles ' || l_rowcount || ' recs.');
    exception
        when others then
            i_put('ERROR! refresh_cst_250_1_cfiles ' || SQLERRM, 1);
    end refresh_cst_250_1_cfiles;

    procedure refresh_cst_250_1_file_tran is
    begin
        delete from cst_250_1_file_tran;

        l_rowcount := sql%rowcount;
        i_put('Deleted from cst_250_1_file_tran ' || l_rowcount || ' recs.', 1);

        insert /*+ append */ into cst_250_1_file_tran
        select c.file_name
             , c.session_file_id as file_name_id
             , rd.record_number
             , to_number(substr(rd.raw_data, 95, 16)) as oper_id
             , substr(rd.raw_data, 57, 2) as tran_code
             , nvl2(trim(substr(rd.raw_data, 59, 1)), 1, 0) as is_reversal
             , trim(substr(rd.raw_data, 71, 24)) as card_number
             , trim(substr(rd.raw_data, 260, 3)) as oper_currency
             , trim(substr(rd.raw_data, 269, 15)) as oper_amount
             , trim(substr(rd.raw_data, 263, 3)) as sttl_currency
             , trim(substr(rd.raw_data, 284, 15)) as sttl_amount
             , trim(substr(rd.raw_data, 266, 3)) as actual_currency
             , trim(substr(rd.raw_data, 299, 15)) as actual_amount
             , trim(substr(rd.raw_data, 259, 1)) as debet_credit
             , trim(substr(rd.raw_data, 355, 3)) as merchant_country
             , 1 is_use
             , rd.raw_data
          from cst_250_1_cfiles c
          join prc_file_raw_data rd on rd.session_file_id = c.session_file_id
         where substr(rd.raw_data, 1, 2) = 'RD';

        l_rowcount := sql%rowcount;
        i_put('Inserted into cst_250_1_file_tran ' || l_rowcount || ' recs.');
    exception
        when others then
            i_put('ERROR! refresh_cst_250_1_file_tran ' || SQLERRM, 1);
    end refresh_cst_250_1_file_tran;

    procedure refresh_cst_250_1_oper_tran1 is
    begin
        delete from cst_250_1_oper_tran1
         where session_file_id between com_api_id_pkg.get_from_id(i_date_start) and com_api_id_pkg.get_till_id(i_date_end);

        l_rowcount := sql%rowcount;
        i_put('Deleted from cst_250_1_opr_tran1 ' || l_rowcount || ' recs.', 1);

        insert into cst_250_1_oper_tran1
        select to_date(substr(f.file_name_id, 1, 6), 'YYMMDD') as file_date
             , f.file_name
             , f.file_name_id as session_file_id
             , f.oper_id
             , f.card_number
             , cn.id as card_id
             , f.tran_code
             , o.oper_type
             , f.is_reversal
             , f.debet_credit
             , nvl(opi.card_network_id, ct.network_id) as network_id
             , f.sttl_currency
             , f.sttl_amount
             , nvl(f.merchant_country, o.merchant_country) as merchant_country
             , o.mcc
             , o.terminal_number
             , case
                    when a.card_data_input_mode in ('F2270005', 'F2270007', 'F2270009', 'F227000S') then 1
                    when (o.terminal_number in ('10000018', '10000019', '10000020') or o.terminal_number like 'REBHB%') then 1
                    else 0
               end is_internet
             , nvl(o2.id, o3.id) as pres_id
             , 1 as is_use
             , f.record_number
             , cn.contract_id
             , cn.card_type_id
             , 0 as is_card_contactless
             , 0 as is_oper_contactless
          from cst_250_1_file_tran f
          join iss_card_vw cn on reverse(cn.card_number) = reverse(f.card_number)
          join opr_operation o on o.id = f.oper_id
          left join opr_participant opi on opi.oper_id = f.oper_id
                                       and opi.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
          left join net_card_type_vw ct on ct.id = opi.card_type_id
          left join aut_auth a on a.id = f.oper_id
          left join opr_operation o2 on o2.match_id = f.oper_id
          left join opr_operation o3 on o3.original_id = f.oper_id
                                    and o3.msg_type = opr_api_const_pkg.MESSAGE_TYPE_COMPLETION
         where f.file_name_id between com_api_id_pkg.get_from_id(i_date_start) And com_api_id_pkg.get_till_id(i_date_end);

        l_rowcount := sql%rowcount;
        i_put('Inserted into cst_250_1_oper_tran1 ' || l_rowcount || ' recs.');
    exception
        when others then
            i_put('ERROR! refresh_cst_250_1_oper_tran1 ' || SQLERRM, 1);
    end refresh_cst_250_1_oper_tran1;

    procedure refresh_cst_250_1_oper_tran2 is
    begin
        delete from cst_250_1_oper_tran2
         where file_date between i_date_start and i_date_end;

        l_rowcount := sql%rowcount;
        i_put('Deleted from cst_250_1_oper_tran2 '||l_rowcount||' recs.', 1);

        insert into cst_250_1_oper_tran2
        select region_code
             , file_name
             , session_file_id
             , file_date
             , customer_type
             , card_feature
             , oper_id
             , oper_type
             , is_mobile
             , is_internet
             , case
                    when is_mobile = 1 then 'mobile'
                    when oper_type in (opr_api_const_pkg.OPERATION_TYPE_ATM_CASH
                                     , opr_api_const_pkg.OPERATION_TYPE_POS_CASH) then 'cashout'
                    when oper_type in (opr_api_const_pkg.OPERATION_TYPE_P2P_DEBIT
                                     , opr_api_const_pkg.OPERATION_TYPE_P2P
                                     , opr_api_const_pkg.OPERATION_TYPE_FUNDS_TRANSFER
                                     , opr_api_const_pkg.OPERATION_TYPE_INTERNAL_ACC_FT
                                     , opr_api_const_pkg.OPERATION_TYPE_FOREIGN_ACC_FT) then 'others'
                    when oper_type in (opr_api_const_pkg.OPERATION_TYPE_PURCHASE)
                         then case
                                   when is_internet = 1 then decode(merchant_country, '643', 'internet', 'internet_shop')
                                   else 'purchases'
                              end
                    when oper_type in (opr_api_const_pkg.OPERATION_TYPE_CASHBACK
                                     , opr_api_const_pkg.OPERATION_TYPE_UNIQUE
                                     , opr_api_const_pkg.OPERATION_TYPE_REFUND
                                     , opr_api_const_pkg.OPERATION_TYPE_PAYMENT
                                     , opr_api_const_pkg.OPERATION_TYPE_SRV_PRV_PAYMENT)
                         then decode(is_internet, 1, 'internet', 'purchases')
                    else null
               end column_type
             , tran_code
             , is_reversal
             , card_number
             , card_id
             , contract_id
             , sttl_currency
             , sttl_amount
             , conv_amount
             , case
                    when card_feature = net_api_const_pkg.CARD_FEATURE_STATUS_OVERDRAFT and credit_amount > 0 then credit_amount * oper_sign
                    else 0
               end as credit_amount
             , oper_sign
             , debet_credit
             , is_use
             , card_network_id
             , merchant_country
             , terminal_number
             , pres_id
             , mcc
             , decode(credit_amount, 0, crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED, acc_api_const_pkg.BALANCE_TYPE_USED_EXCEED_LIMIT) as balance_type
             , is_card_contactless
             , is_oper_contactless
          from (select /*+ leading(o c) */
                       o.file_name
                     , o.session_file_id
                     , o.file_date
                     , o.oper_id
                     , case
                            when o.tran_code = '55' and o.terminal_number not in ('REBHB003', 'REBHB004', 'REBHB008', 'REBHB011')
                                 then opr_api_const_pkg.OPERATION_TYPE_PURCHASE
                            when o.tran_code = '82' and o.debet_credit = 'D'
                                 then opr_api_const_pkg.OPERATION_TYPE_P2P_DEBIT -- others
                            when o.tran_code = 'X3' and o.oper_type = opr_api_const_pkg.OPERATION_TYPE_SRV_PRV_PAYMENT
                                 then opr_api_const_pkg.OPERATION_TYPE_P2P_DEBIT -- others
                            else o.oper_type
                       end oper_type
                     , o.tran_code
                     , o.is_reversal
                     , o.card_number
                     , o.card_id
                     , o.sttl_currency
                     , to_number(o.sttl_amount) sttl_amount
                     , round(to_number(com_api_rate_pkg.convert_amount(
                                           i_src_amount      => o.sttl_amount
                                         , i_src_currency    => o.sttl_currency
                                         , i_dst_currency    => '643'
                                         , i_rate_type       => 'RTTPCBRF'
                                         , i_inst_id         => i_inst_id
                                         , i_eff_date        => o.file_date
                                         , i_mask_exception  => 1
                                         , i_exception_value => 0
                       ))) as conv_amount
                     , (select to_number(nvl(max(nvl(com_api_rate_pkg.convert_amount(
                                                         i_src_amount      => ae.amount
                                                       , i_src_currency    => ae.currency
                                                       , i_dst_currency    => '643'
                                                       , i_rate_type       => 'RTTPCBRF'
                                                       , i_inst_id         => i_inst_id
                                                       , i_eff_date        => ae.posting_date
                                                       , i_mask_exception  => 1
                                                       , i_exception_value => 0),
                                                     0)),
                                             0))
                          from acc_macros am
                          join acc_entry ae on ae.macros_id = am.id
                         where ae.balance_type = acc_api_const_pkg.BALANCE_TYPE_USED_EXCEED_LIMIT
                           and am.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                           and am.amount_purpose = com_api_const_pkg.AMOUNT_PURPOSE_ACCOUNT
                           and am.cancel_indicator = com_api_const_pkg.INDICATOR_NOT_CANCELED
                           and o.oper_type not in (opr_api_const_pkg.OPERATION_TYPE_REFUND
                                                 , opr_api_const_pkg.OPERATION_TYPE_CASHIN
                                                 , opr_api_const_pkg.OPERATION_TYPE_P2P_CREDIT
                                                 , opr_api_const_pkg.OPERATION_TYPE_PAYMENT
                                                 , opr_api_const_pkg.OPERATION_TYPE_CREDIT_ACCOUNT)
                           and o.terminal_number != '10000017'
                           and am.object_id = nvl(o.pres_id, o.oper_id)) as credit_amount
                     , case
                            when o.is_reversal = 1
                              or o.oper_type = opr_api_const_pkg.OPERATION_TYPE_REFUND
                              or (o.is_reversal = 0 and o.tran_code in ('15', '16', '17', '18', '19', '35', '36', 'B3', 'B5', 'B6', 'B7', 'B8', 'B9', 'E5', 'E6')) -- chargeback
                              or (o.is_reversal = 0 and substr(o.tran_code, 2, 1) = '6')
                            then -1
                            else 1
                       end oper_sign
                     , o.debet_credit
                     , o.is_use
                     , case
                            when nvl(o.network_id, -1) = 7017 and o.card_number like '22%'
                                 then o.network_id -- MIR
                            when substr(o.tran_code, 1, 1) in ('N', 'B', 'E', 'C')
                                 then case
                                           when o.network_id = 1002 then 7003 -- nspk MC
                                           else 1008 -- nspk VISA
                                      end
                            when o.network_id is not null then o.network_id
                            else decode(substr(o.card_number, 1, 1), '4', 1003, 1002)
                       end card_network_id
                     , case
                            when nvl(o.merchant_country, '643') in ('RUS') then '643'
                            when substr(o.tran_code, 1, 1) in ('0', '1', '2', '3') then '999'
                            when substr(o.tran_code, 1, 1) in ('A', 'N', 'B') then '643'
                            when nvl(o.merchant_country, '643') in ('643', '000', '276') then '643'
                            else o.merchant_country
                       end as merchant_country
                     , o.terminal_number
                     , o.pres_id as pres_id
                     , decode(o.terminal_number, '10000023', 1, 0) as is_mobile
                     , case
                            when (o.terminal_number in ('10000018'
                                                      , '10000019'
                                                      , '10000020') and substr(tran_code, 2, 1) = '5') or
                                 (o.terminal_number like 'REBHB%' and o.terminal_number not in ('REBHB003'
                                                                                              , 'REBHB004'
                                                                                              , 'REBHB008'
                                                                                              , 'REBHB011') and substr(tran_code, 2, 1) = '5') or
                                 (tran_code = 'A5' and o.terminal_number like 'A0%') or
                                 (tran_code = 'A5' and o.terminal_number like 'INT%') or
                                 (tran_code in ('05', '08', 'N5') and o.is_internet = 1)
                            then 1
                            else 0
                       end is_internet
                     , o.mcc
                     , case
                            when corp_card.card_type_id is not null then com_api_const_pkg.ENTITY_TYPE_COMPANY
                            else com_api_const_pkg.ENTITY_TYPE_PERSON
                       end as customer_type
                     , nvl2(overd.card_id, net_api_const_pkg.CARD_FEATURE_STATUS_OVERDRAFT
                                         , net_api_const_pkg.CARD_FEATURE_STATUS_DEBIT) as card_feature
                     , nvl(a.region_code, '45') region_code
                     , o.contract_id
                     , o.is_card_contactless
                     , o.is_oper_contactless
                  from cst_250_1_oper_tran1 o
                  join com_address_object ao on ao.object_id = (select max(ci.agent_id)
                                                                  from iss_card_instance ci
                                                                 where ci.card_id = o.card_id)
                                            and ao.entity_type = ost_api_const_pkg.ENTITY_TYPE_AGENT and ao.address_type = com_api_const_pkg.ADDRESS_TYPE_BUSINESS
                  join com_address a on a.id = ao.address_id
                  left join cst_250_overdraft_card overd on overd.card_id = o.card_id
                  left join (select distinct ct.card_type_id
                               from prd_contract_type c
                               join prd_product p on p.contract_type = c.contract_type
                               join iss_product_card_type ct on ct.product_id = p.id
                               join com_i18n i on table_name = 'NET_CARD_TYPE' and object_id = ct.card_type_id
                              where c.customer_entity_type = com_api_const_pkg.ENTITY_TYPE_COMPANY
                                and p.inst_id = i_inst_id
                                and i.text not like ('%Unembossed%')
                                and i.text not like ('%Instant%')
                                and i.text not like ('%Collectors%')
                            ) corp_card on corp_card.card_type_id = o.card_type_id
                 where o.file_date between i_date_start and i_date_end
                   and nvl(to_number(o.sttl_amount), 0) > 0
                   and (o.terminal_number != '10000017' or o.terminal_number is null)
                   and o.is_use = 1
               );

        l_rowcount := sql%rowcount;
        i_put('Inserted into cst_250_1_oper_tran2 ' || l_rowcount || ' recs.');

        update cst_250_1_oper_tran3 o
           set o.card_network_id = 7017
         where o.card_network_id <> 7017
           and o.oper_id in (select o.id oper_id
                               from iss_card_vw c
                               join opr_card oc on c.card_number = oc.card_number
                               join opr_operation o on o.id = oc.oper_id
                              where card_type_id in (1041, 1045));

        l_rowcount := sql%rowcount;
        i_put('Update network to 7017 for cst_250_1_oper_tran2 ' || l_rowcount || ' recs.');
    exception
        when others then
            i_put('ERROR! refresh_cst_250_1_oper_tran2 ' || SQLERRM, 1);
    end refresh_cst_250_1_oper_tran2;

    procedure refresh_cst_250_1_oper_tran3 is
    begin
        delete from cst_250_1_oper_tran3;
        l_rowcount := sql%rowcount;
        i_put('Deleted from cst_250_1_oper_tran3 ' || l_rowcount || ' recs.', 1);

        insert into cst_250_1_oper_tran3
        select distinct *
          from cst_250_1_oper_tran2 o
         where o.column_type is not null
           and o.is_use = 1
           and o.oper_sign = 1
           and o.tran_code in ('05'
                             , '07'
                             , '08'
                             , '09'
                             , '13'
                             , '15'
                             , '16'
                             , '17'
                             , '18'
                             , '19'
                             , '53'
                             , '55'
                             , '57'
                             , '58'
                             , '59'
                             , '65'
                             , '73'
                             , '75'
                             , '77'
                             , '79'
                             , '82'
                             , 'A5'
                             , 'A7'
                             , 'A9'
                             , 'B3'
                             , 'B5'
                             , 'B6'
                             , 'B7'
                             , 'B8'
                             , 'B9'
                             , 'C3'
                             , 'N3'
                             , 'N5'
                             , 'N7'
                             , 'N8'
                             , 'N9'
                             , 'X3'
                             , 'X4'
                             , 'X7'
                             );

        l_rowcount := sql%rowcount;
        i_put('Inserted into cst_250_1_oper_tran3 ' || l_rowcount || ' recs.');
        i_put('Please check data by running view cst_250_1_oper_tran3_check_vw');
    exception
        when others then
            i_put('ERROR! cst_250_1_oper_tran3 ' || SQLERRM, 1);
    end refresh_cst_250_1_oper_tran3;

    procedure refresh_cst_250_1_aggr_tran1 is
    begin
        delete from cst_250_1_aggr_tran;

        l_rowcount := sql%rowcount;
        i_put('Deleted from cst_250_1_aggr_tran ' || l_rowcount || ' recs.', 1);

        -- 1. rows of report, set of region_code, customer_type, network_id, card_type(card_feature)
        insert into cst_250_1_aggr_tran(
            region_code
          , customer_type
          , network_id
          , card_type
          , customer_count
          , card_type_count
          , card_count
          , active_card_count
          , oper_amount_debit
          , oper_amount_credit
          , domestic_cash_count
          , domestic_cash_amount
          , foreign_cash_count
          , foreign_cash_amout
          , domestic_purch_count
          , domestic_purch_amount
          , foreign_purch_count
          , foreign_purch_amount
          , customs_count
          , customs_amount
          , other_count
          , other_amount
          , internet_count
          , internet_amount
          , internet_shop_count
          , internet_shop_amount
          , mobile_count
          , mobile_amount
          )
        select a.*
          from (
              with dict as (
                  select region_code
                       , customer_type
                       , network_id
                       , card_feature
                       , 0 as customer_count
                       , 0 as card_type_count
                       , 0 as card_count
                       , 0 as active_card_count
                       , 0 as oper_amount_debit
                       , 0 as oper_amount_credit
                       , 0 as domestic_cash_count
                       , 0 as domestic_cash_amount
                       , 0 as foreign_cash_count
                       , 0 as foreign_cash_amout
                       , 0 as domestic_purch_count
                       , 0 as domestic_purch_amount
                       , 0 as foreign_purch_count
                       , 0 as foreign_purch_amount
                       , 0 as customs_count
                       , 0 as customs_amount
                       , 0 as other_count
                       , 0 as other_amount
                       , 0 as internet_count
                       , 0 as internet_amount
                       , 0 as internet_shop_count
                       , 0 as internet_shop_amount
                       , 0 as mobile_count
                       , 0 as mobile_amount
                    from
                    ( -- regions
                      select nvl(decode(i_one_region, 1, '45', '77', '45', adr.region_code), '45') region_code
                        from ost_institution    i
                           , ost_agent          a
                           , com_address_object adr_o
                           , com_address        adr
                       where (i_inst_id <> 9999 and i.id = i_inst_id or i_inst_id = 9999 and i.network_id = 1001)
                         and a.inst_id = i.id
                         and adr_o.object_id(+) = a.id
                         and adr_o.entity_type(+) = ost_api_const_pkg.ENTITY_TYPE_AGENT
                         and adr.id(+) = adr_o.address_id
                         and adr.region_code is not null
                    )
                  , ( -- customer types
                      select com_api_const_pkg.ENTITY_TYPE_PERSON as customer_type from dual
                      union all
                      select com_api_const_pkg.ENTITY_TYPE_COMPANY from dual
                    )
                  , ( -- card features
                      select net_api_const_pkg.CARD_FEATURE_STATUS_DEBIT as card_feature from dual
                      union all
                      select net_api_const_pkg.CARD_FEATURE_STATUS_OVERDRAFT from dual
                      union all
                      select net_api_const_pkg.CARD_FEATURE_STATUS_CREDIT from dual
                    )
                  , ( -- networks
                      select 1002 as network_id from dual -- MC
                      union all
                      select 1003 as network_id from dual -- VISA
                      union all
                      select 7003 as network_id from dual -- NSPK MC
                      union all
                      select 1008 as network_id from dual -- NSPK VISA
                      union all
                      select 7017 as network_id from dual -- MIR
                    )
              ) -- dict
              select region_code
                   , customer_type
                   , network_id
                   , card_feature
                   , nvl(sum(customer_count), 0)
                   , nvl(sum(card_type_count), 0)
                   , nvl(sum(card_count), 0)
                   , nvl(sum(active_card_count), 0)
                   , nvl(sum(oper_amount_debit), 0)
                   , nvl(sum(oper_amount_credit), 0)
                   , nvl(sum(domestic_cash_count), 0)
                   , nvl(sum(domestic_cash_amount),0)
                   , nvl(sum(foreign_cash_count), 0)
                   , nvl(sum(foreign_cash_amout), 0)
                   , nvl(sum(domestic_purch_count), 0)
                   , nvl(sum(domestic_purch_amount), 0)
                   , nvl(sum(foreign_purch_count), 0)
                   , nvl(sum(foreign_purch_amount), 0)
                   , nvl(sum(customs_count), 0)
                   , nvl(sum(customs_amount), 0)
                   , nvl(sum(other_count), 0)
                   , nvl(sum(other_amount), 0)
                   , nvl(sum(internet_count), 0)
                   , nvl(sum(internet_amount), 0)
                   , nvl(sum(internet_shop_count), 0)
                   , nvl(sum(internet_shop_amount), 0)
                   , nvl(sum(mobile_count), 0)
                   , nvl(sum(mobile_amount), 0)
                from dict
                group by grouping sets
                            ( (region_code, customer_type, network_id, card_feature)
                            , (region_code, customer_type, network_id)
                            , (region_code, customer_type, card_feature)
                            , (region_code, customer_type)
                            , (region_code, card_feature)
                            , (region_code)
                            , (card_feature)
                            ) -- to there were null rows "itogo" when data are absent
              union
              select null region_code
                   , null customer_type
                   , null network_id
                   , null card_feature
                   , nvl(sum(customer_count), 0)
                   , nvl(sum(card_type_count), 0)
                   , nvl(sum(card_count), 0)
                   , nvl(sum(active_card_count), 0)
                   , nvl(sum(oper_amount_debit), 0)
                   , nvl(sum(oper_amount_credit), 0)
                   , nvl(sum(domestic_cash_count), 0)
                   , nvl(sum(domestic_cash_amount), 0)
                   , nvl(sum(foreign_cash_count), 0)
                   , nvl(sum(foreign_cash_amout), 0)
                   , nvl(sum(domestic_purch_count), 0)
                   , nvl(sum(domestic_purch_amount), 0)
                   , nvl(sum(foreign_purch_count), 0)
                   , nvl(sum(foreign_purch_amount), 0)
                   , nvl(sum(customs_count), 0)
                   , nvl(sum(customs_amount), 0)
                   , nvl(sum(other_count), 0)
                   , nvl(sum(other_amount), 0)
                   , nvl(sum(internet_count), 0)
                   , nvl(sum(internet_amount), 0)
                   , nvl(sum(internet_shop_count), 0)
                   , nvl(sum(internet_shop_amount), 0)
                   , nvl(sum(mobile_count), 0)
                   , nvl(sum(mobile_amount), 0)
                from dict
          ) a
          order by region_code nulls last
                 , decode(customer_type
                                      , com_api_const_pkg.ENTITY_TYPE_PERSON, 1
                                      , com_api_const_pkg.ENTITY_TYPE_COMPANY, 2
                                      , null) nulls last
                 , network_id nulls last
                 , decode(card_feature
                                     , net_api_const_pkg.CARD_FEATURE_STATUS_DEBIT, 1
                                     , net_api_const_pkg.CARD_FEATURE_STATUS_OVERDRAFT, 2
                                     , net_api_const_pkg.CARD_FEATURE_STATUS_CREDIT, 3
                                     , null) nulls first;

        l_rowcount := sql%rowcount;
        i_put('Inserted into refresh_cst_250_1_aggr_tran1 ' || l_rowcount || ' recs.');
    exception
        when others then
            i_put('ERROR! refresh_cst_250_1_aggr_tran1 ' || SQLERRM, 1);
    end refresh_cst_250_1_aggr_tran1;

    procedure refresh_cst_250_1_aggr_tran2 is
    begin
        -- 2. filling of rows: amount\count of transactions and count of active cards
        for rc in (
            select decode(region_code, '77', '45', region_code)                         as region_code
                 , customer_type
                 , card_network_id                                                      as network_id
                 , card_feature                                                         as card_type
                 , balance_type                                                         as balance_type
                 , nvl(active_card_count, 0)                                            as active_card_count
                 , decode(column_type, 'cashout', domestic_count, 0)                    as domestic_cash_count
                 , decode(column_type, 'cashout', domestic_amount, 0)                   as domestic_cash_amount
                 , decode(column_type, 'cashout', foreign_count, 0)                     as foreign_cash_count
                 , decode(column_type, 'cashout', foreign_amount, 0)                    as foreign_cash_amount
                 , decode(column_type, 'purchases', domestic_count, 0)                  as domestic_purch_count
                 , decode(column_type, 'purchases', domestic_amount, 0)                 as domestic_purch_amount
                 , decode(column_type, 'purchases', foreign_count, 0)                   as foreign_purch_count
                 , decode(column_type, 'purchases', foreign_amount, 0)                  as foreign_purch_amount
                 , decode(column_type, 'customs', domestic_count + foreign_count, 0)    as customs_count
                 , decode(column_type, 'customs', domestic_amount + foreign_amount, 0)  as customs_amount
                 , decode(column_type, 'others', domestic_count + foreign_count, 0)     as other_count
                 , decode(column_type, 'others', domestic_amount + foreign_amount, 0)   as other_amount
                 , decode(column_type, 'internet', domestic_count + foreign_count, 0)   as internet_count
                 , decode(column_type, 'internet', domestic_amount + foreign_amount, 0) as internet_amount
                 , decode(column_type, 'internet', foreign_count, 0)                    as internet_foreign_count
                 , decode(column_type, 'internet', foreign_amount, 0)                   as internet_foreign_amount
                 , decode(column_type, 'internet_shop', foreign_count, 0)               as internet_shop_count
                 , decode(column_type, 'internet_shop', foreign_amount, 0)              as internet_shop_amount
                 , decode(column_type, 'mobile', domestic_count + foreign_count, 0)     as mobile_count
                 , decode(column_type, 'mobile', domestic_amount + foreign_amount, 0)   as mobile_amount
                 , credit_amount
              from (
                  with oper as (
                      select nvl(decode(i_one_region, 1, '45', nvl(opr.region_code, '45')), '45') region_code
                           , opr.customer_type
                           , opr.card_network_id
                           , opr.card_feature
                           , opr.balance_type
                           , credit_amount
                           , decode (opr.merchant_country, '643', opr.oper_sign, 0) as domestic_count
                           , decode (opr.merchant_country, '643', 0, opr.oper_sign) as foreign_count
                           , decode (opr.merchant_country, '643', opr.conv_amount * opr.oper_sign, 0) as domestic_amount
                           , decode (opr.merchant_country, '643', 0, opr.conv_amount * opr.oper_sign) as foreign_amount
                           , column_type
                           -- counts of active card in the context of rows type
                           , count(distinct opr.card_id) over (partition by opr.region_code, opr.customer_type, opr.card_network_id)                   as active_card_cnt_n
                           , count(distinct opr.card_id) over (partition by opr.region_code, opr.customer_type, opr.card_network_id, opr.card_feature) as active_card_cnt_n_f
                           , count(distinct opr.card_id) over (partition by opr.region_code, opr.customer_type)                                        as active_card_cnt_c
                           , count(distinct opr.card_id) over (partition by opr.region_code, opr.customer_type, opr.card_feature)                      as active_card_cnt_c_f
                           , count(distinct opr.card_id) over (partition by opr.region_code)                                                           as active_card_cnt_r
                           , count(distinct opr.card_id) over (partition by opr.region_code, opr.card_feature)                                         as active_card_cnt_r_f
                           , count(distinct opr.card_id) over ()                                                                                       as active_card_cnt
                           , count(distinct opr.card_id) over (partition by opr.card_feature)                                                          as active_card_cnt_f
                           -- counts of same value oper_id in the context of rows type,
                           -- then used to calculate amount for appropriate rows type
                           , count(opr.oper_id) over (partition by opr.oper_id, opr.region_code, opr.customer_type, opr.card_network_id, balance_type) as cnt_oper_n
                           , count(opr.oper_id) over (partition by opr.oper_id, opr.region_code, opr.customer_type, balance_type)                      as cnt_oper_c
                           , count(opr.oper_id) over (partition by opr.oper_id, opr.region_code, opr.customer_type, opr.card_feature, balance_type)    as cnt_oper_c_f
                           , count(opr.oper_id) over (partition by opr.oper_id, opr.region_code, balance_type)                                         as cnt_oper_r
                           , count(opr.oper_id) over (partition by opr.oper_id, opr.region_code, opr.card_feature, balance_type)                       as cnt_oper_r_f
                           , count(opr.oper_id) over (partition by opr.oper_id, balance_type)                                                          as cnt_oper
                           , count(opr.oper_id) over (partition by opr.oper_id, opr.card_feature, balance_type)                                        as cnt_oper_f
                        from cst_250_1_oper_tran3 opr
                  ) -- oper
                  -- network feature
                  select region_code
                       , customer_type
                       , card_network_id
                       , card_feature
                       , balance_type
                       , column_type
                       , active_card_cnt_n_f  as active_card_count
                       , sum(domestic_count)  as domestic_count
                       , sum(domestic_amount) as domestic_amount
                       , sum(foreign_count)   as foreign_count
                       , sum(foreign_amount)  as foreign_amount
                       , sum(credit_amount)   as credit_amount
                    from oper
                    group by grouping sets (region_code, customer_type, card_network_id, card_feature, balance_type, column_type, active_card_cnt_n_f)
                  union  -- network all
                  select region_code
                       , customer_type
                       , card_network_id
                       , null as card_feature
                       , balance_type
                       , column_type
                       , active_card_cnt_n                      as active_card_count
                       , round(sum(domestic_count /cnt_oper_n)) as domestic_count
                       , round(sum(domestic_amount/cnt_oper_n)) as domestic_amount
                       , round(sum(foreign_count  /cnt_oper_n)) as foreign_count
                       , round(sum(foreign_amount /cnt_oper_n)) as foreign_amount
                       , round(sum(credit_amount  /cnt_oper_n)) as credit_amount
                    from oper
                    group by grouping sets (region_code, customer_type, card_network_id, balance_type, column_type, active_card_cnt_n)
                  union   -- customer feature
                  select region_code
                       , customer_type
                       , null as card_network_id
                       , card_feature
                       , balance_type
                       , column_type
                       , active_card_cnt_c_f                      as active_card_count
                       , round(sum(domestic_count /cnt_oper_c_f)) as domestic_count
                       , round(sum(domestic_amount/cnt_oper_c_f)) as domestic_amount
                       , round(sum(foreign_count  /cnt_oper_c_f)) as foreign_count
                       , round(sum(foreign_amount /cnt_oper_c_f)) as foreign_amount
                       , round(sum(credit_amount  /cnt_oper_c_f)) as credit_amount
                    from oper
                    group by grouping sets (region_code, customer_type, column_type, card_feature, balance_type, active_card_cnt_c_f)
                  union -- customer all
                  select region_code
                       , customer_type
                       , null as card_network_id
                       , null as card_feature
                       , balance_type
                       , column_type
                       , active_card_cnt_c                      as active_card_count
                       , round(sum(domestic_count /cnt_oper_c)) as domestic_count
                       , round(sum(domestic_amount/cnt_oper_c)) as domestic_amount
                       , round(sum(foreign_count  /cnt_oper_c)) as foreign_count
                       , round(sum(foreign_amount /cnt_oper_c)) as foreign_amount
                       , round(sum(credit_amount  /cnt_oper_c)) as credit_amount
                    from oper
                    group by grouping sets (region_code, customer_type, balance_type, column_type, active_card_cnt_c)
                  union -- region feature
                  select region_code
                       , null as customer_type
                       , null as card_network_id
                       , card_feature
                       , balance_type
                       , column_type
                       , active_card_cnt_r_f                      as active_card_count
                       , round(sum(domestic_count /cnt_oper_r_f)) as domestic_count
                       , round(sum(domestic_amount/cnt_oper_r_f)) as domestic_amount
                       , round(sum(foreign_count  /cnt_oper_r_f)) as foreign_count
                       , round(sum(foreign_amount /cnt_oper_r_f)) as foreign_amount
                       , round(sum(credit_amount  /cnt_oper_r_f)) as credit_amount
                    from oper
                    group by grouping sets (region_code, column_type, card_feature, balance_type, active_card_cnt_r_f)
                  union -- region all
                  select region_code
                       , null as customer_type
                       , null as card_network_id
                       , null as card_feature
                       , balance_type
                       , column_type
                       , active_card_cnt_r                      as active_card_count
                       , round(sum(domestic_count /cnt_oper_r)) as domestic_count
                       , round(sum(domestic_amount/cnt_oper_r)) as domestic_amount
                       , round(sum(foreign_count  /cnt_oper_r)) as foreign_count
                       , round(sum(foreign_amount /cnt_oper_r)) as foreign_amount
                       , round(sum(credit_amount  /cnt_oper_r)) as credit_amount
                    from oper
                    group by grouping sets (region_code, balance_type, column_type, active_card_cnt_r)
                  union -- total feature
                  select null as region_code
                       , null as customer_type
                       , null as card_network_id
                       , card_feature
                       , balance_type
                       , column_type
                       , active_card_cnt_f                      as active_card_count
                       , round(sum(domestic_count /cnt_oper_f)) as domestic_count
                       , round(sum(domestic_amount/cnt_oper_f)) as domestic_amount
                       , round(sum(foreign_count  /cnt_oper_f)) as foreign_count
                       , round(sum(foreign_amount /cnt_oper_f)) as foreign_amount
                       , round(sum(credit_amount  /cnt_oper_f)) as credit_amount
                    from oper
                    group by grouping sets (column_type, card_feature, balance_type, active_card_cnt_f)
                  union -- total all
                  select null as region_code
                       , null as customer_type
                       , null as card_network_id
                       , null as card_feature
                       , balance_type
                       , column_type
                       , active_card_cnt                      as active_card_count
                       , round(sum(domestic_count /cnt_oper)) as domestic_count
                       , round(sum(domestic_amount/cnt_oper)) as domestic_amount
                       , round(sum(foreign_count  /cnt_oper)) as foreign_count
                       , round(sum(foreign_amount /cnt_oper)) as foreign_amount
                       , round(sum(credit_amount  /cnt_oper)) as credit_amount
                    from oper
                    group by grouping sets (balance_type, column_type, active_card_cnt)
              )
        ) loop
            update cst_250_1_aggr_tran
               set active_card_count     = rc.active_card_count
                 , domestic_cash_amount  = domestic_cash_amount + rc.domestic_cash_amount
                 , foreign_cash_amout    = foreign_cash_amout + rc.foreign_cash_amount
                 , domestic_purch_amount = domestic_purch_amount + rc.domestic_purch_amount  + rc.internet_amount - rc.internet_foreign_amount + rc.mobile_amount
                 , foreign_purch_amount  = foreign_purch_amount + rc.foreign_purch_amount + rc.internet_foreign_amount + rc.internet_shop_amount
                 , customs_amount        = customs_amount + rc.customs_amount
                 , other_amount          = other_amount + rc.other_amount
                 , internet_amount       = internet_amount + rc.internet_amount  + rc.internet_shop_amount
                 , internet_shop_amount  = internet_shop_amount + rc.internet_shop_amount
                 , mobile_amount         = mobile_amount + rc.mobile_amount
                 , oper_amount_debit     = oper_amount_debit + decode(rc.balance_type , crd_api_const_pkg.balance_type_assigned_exceed, 1 , 0)
                                                               * decode(nvl(rc.card_type, '&'), '&', 0, 1)
                                                               * (rc.domestic_cash_amount
                                                                + rc.foreign_cash_amount
                                                                + rc.domestic_purch_amount
                                                                + rc.foreign_purch_amount
                                                                + rc.internet_amount
                                                                + rc.mobile_amount
                                                                + rc.other_amount
                                                                + rc.internet_shop_amount
                                                                )
                                                             + decode(rc.balance_type, acc_api_const_pkg.BALANCE_TYPE_USED_EXCEED_LIMIT, 1, 0)
                                                               * decode(nvl(rc.card_type, '&'), '&', 0, 1)
                                                               * (rc.domestic_cash_amount
                                                                + rc.foreign_cash_amount
                                                                + rc.domestic_purch_amount
                                                                + rc.foreign_purch_amount
                                                                + rc.internet_amount
                                                                + rc.mobile_amount
                                                                + rc.other_amount
                                                                + rc.internet_shop_amount
                                                                - rc.credit_amount
                                                               )
                 , oper_amount_credit    = oper_amount_credit + decode(nvl(rc.card_type, '&'), '&', 0, 1) * rc.credit_amount
             where nvl(region_code,   '&') = nvl(rc.region_code,   '&')
               and nvl(customer_type, '&') = nvl(rc.customer_type, '&')
               and nvl(network_id,    -99) = nvl(rc.network_id,    -99)
               and (
                     nvl(card_type, 'x') = nvl(rc.card_type, 'y') or
                     card_type is null and rc.card_type in (net_api_const_pkg.CARD_FEATURE_STATUS_DEBIT
                                                          , net_api_const_pkg.CARD_FEATURE_STATUS_OVERDRAFT) or
                     card_type = net_api_const_pkg.CARD_FEATURE_STATUS_DEBIT and rc.card_type in (net_api_const_pkg.CARD_FEATURE_STATUS_DEBIT
                                                                                                , net_api_const_pkg.CARD_FEATURE_STATUS_OVERDRAFT)
                   )
               and rc.card_type is not null;

        end loop;
    exception
        when others then
            i_put('ERROR! refresh_cst_250_1_aggr_tran2 ' || sqlerrm, 1);
    end refresh_cst_250_1_aggr_tran2;

    procedure refresh_cst_250_1_aggr_tran3 is
    begin
        for rc in (
            select decode(region_code, '77', '45', region_code)                         as region_code
                 , customer_type
                 , card_network_id                                                      as network_id
                 , card_feature                                                         as card_type
                 , null                                                                 as balance_type
                 , nvl(active_card_count, 0)                                            as active_card_count
                 , decode(column_type ,'cashout', domestic_count, 0)                    as domestic_cash_count
                 , decode(column_type, 'cashout', foreign_count, 0)                     as foreign_cash_count
                 , decode(column_type, 'purchases', domestic_count, 0)                  as domestic_purch_count
                 , decode(column_type, 'purchases', foreign_count, 0)                   as foreign_purch_count
                 , decode(column_type, 'customs', domestic_count + foreign_count, 0)    as customs_count
                 , decode(column_type, 'others', domestic_count + foreign_count, 0)     as other_count
                 , decode(column_type, 'internet', domestic_count + foreign_count, 0)   as internet_count
                 , decode(column_type, 'internet', foreign_count, 0)                    as internet_foreign_count
                 , decode(column_type, 'internet_shop', foreign_count, 0)               as internet_shop_count
                 , decode(column_type, 'mobile', domestic_count +foreign_count, 0)  as mobile_count
              from (
                  with oper as (
                      select nvl(decode(i_one_region, 1, '45', nvl(opr.region_code, '45')), '45') region_code
                           , opr.customer_type
                           , opr.card_network_id
                           , opr.card_feature
                           , decode (opr.merchant_country, '643', opr.oper_sign, 0)       as domestic_count
                           , decode (opr.merchant_country, '643', 0, opr.oper_sign)       as foreign_count
                           , column_type
                           -- counts of active card in the context of rows type
                           , count(distinct opr.card_id) over (partition by opr.region_code, opr.customer_type, opr.card_network_id)                   as active_card_cnt_n
                           , count(distinct opr.card_id) over (partition by opr.region_code, opr.customer_type, opr.card_network_id, opr.card_feature) as active_card_cnt_n_f
                           , count(distinct opr.card_id) over (partition by opr.region_code, opr.customer_type)                                        as active_card_cnt_c
                           , count(distinct opr.card_id) over (partition by opr.region_code, opr.customer_type, opr.card_feature)                      as active_card_cnt_c_f
                           , count(distinct opr.card_id) over (partition by opr.region_code)                                                           as active_card_cnt_r
                           , count(distinct opr.card_id) over (partition by opr.region_code, opr.card_feature)                                         as active_card_cnt_r_f
                           , count(distinct opr.card_id) over ()                                                                                       as active_card_cnt
                           , count(distinct opr.card_id) over (partition by opr.card_feature)                                                          as active_card_cnt_f
                           -- counts of same value oper_id in the context of rows type,
                           -- then used to calculate amount for appropriate rows type
                           , count(opr.oper_id) over (partition by opr.oper_id, opr.region_code, opr.customer_type, opr.card_network_id) as cnt_oper_n
                           , count(opr.oper_id) over (partition by opr.oper_id, opr.region_code, opr.customer_type)                      as cnt_oper_c
                           , count(opr.oper_id) over (partition by opr.oper_id, opr.region_code, opr.customer_type, opr.card_feature)    as cnt_oper_c_f
                           , count(opr.oper_id) over (partition by opr.oper_id, opr.region_code)                                         as cnt_oper_r
                           , count(opr.oper_id) over (partition by opr.oper_id, opr.region_code, opr.card_feature)                       as cnt_oper_r_f
                           , count(opr.oper_id) over (partition by opr.oper_id)                                                          as cnt_oper
                           , count(opr.oper_id) over (partition by opr.oper_id, opr.card_feature)                                        as cnt_oper_f
                        from cst_250_1_oper_tran3 opr
                  ) -- oper
                  -- network feature
                  select region_code
                       , customer_type
                       , card_network_id
                       , card_feature
                       , column_type
                       , active_card_cnt_n_f  as active_card_count
                       , sum(domestic_count)  as domestic_count
                       , sum(foreign_count)   as foreign_count
                    from oper
                    group by grouping sets (region_code, customer_type, card_network_id, card_feature, column_type, active_card_cnt_n_f)
                  union -- network all
                  select region_code
                       , customer_type
                       , card_network_id
                       , null as card_feature
                       , column_type
                       , active_card_cnt_n                      as active_card_count
                       , round(sum(domestic_count /cnt_oper_n)) as domestic_count
                       , round(sum(foreign_count  /cnt_oper_n)) as foreign_count
                    from oper
                    group by grouping sets (region_code, customer_type, card_network_id, column_type, active_card_cnt_n)
                  union -- customer feature
                  select region_code
                       , customer_type
                       , null as card_network_id
                       , card_feature
                       , column_type
                       , active_card_cnt_c_f                      as active_card_count
                       , round(sum(domestic_count /cnt_oper_c_f)) as domestic_count
                       , round(sum(foreign_count  /cnt_oper_c_f)) as foreign_count
                    from oper
                    group by grouping sets (region_code, customer_type, column_type, card_feature, active_card_cnt_c_f)
                  union -- customer all
                  select region_code
                       , customer_type
                       , null as card_network_id
                       , null as card_feature
                       , column_type
                       , active_card_cnt_c                      as active_card_count
                       , round(sum(domestic_count /cnt_oper_c)) as domestic_count
                       , round(sum(foreign_count  /cnt_oper_c)) as foreign_count
                    from oper
                    group by grouping sets (region_code, customer_type, column_type, active_card_cnt_c)
                  union -- region feature
                  select region_code
                       , null as customer_type
                       , null as card_network_id
                       , card_feature
                       , column_type
                       , active_card_cnt_r_f                      as active_card_count
                       , round(sum(domestic_count /cnt_oper_r_f)) as domestic_count
                       , round(sum(foreign_count  /cnt_oper_r_f)) as foreign_count
                    from oper
                    group by grouping sets (region_code, column_type, card_feature, active_card_cnt_r_f)
                  union -- region all
                  select region_code
                       , null as customer_type
                       , null as card_network_id
                       , null as card_feature
                       , column_type
                       , active_card_cnt_r                      as active_card_count
                       , round(sum(domestic_count /cnt_oper_r)) as domestic_count
                       , round(sum(foreign_count  /cnt_oper_r)) as foreign_count
                    from oper
                    group by grouping sets (region_code, column_type, active_card_cnt_r)
                  union -- total feature
                  select null as region_code
                       , null as customer_type
                       , null as card_network_id
                       , card_feature
                       , column_type
                       , active_card_cnt_f                      as active_card_count
                       , round(sum(domestic_count /cnt_oper_f)) as domestic_count
                       , round(sum(foreign_count  /cnt_oper_f)) as foreign_count
                    from oper
                    group by grouping sets (column_type, card_feature, active_card_cnt_f)
                  union -- total all
                  select null as region_code
                       , null as customer_type
                       , null as card_network_id
                       , null as card_feature
                       , column_type
                       , active_card_cnt                      as active_card_count
                       , round(sum(domestic_count /cnt_oper)) as domestic_count
                       , round(sum(foreign_count  /cnt_oper)) as foreign_count
                    from oper
                    group by grouping sets (column_type, active_card_cnt)
              )
        ) loop
            update cst_250_1_aggr_tran
               set domestic_cash_count   = domestic_cash_count + rc.domestic_cash_count
                 , foreign_cash_count    = foreign_cash_count + rc.foreign_cash_count
                 , domestic_purch_count  = domestic_purch_count + rc.domestic_purch_count + rc.internet_count - rc.internet_foreign_count + rc.mobile_count
                 , foreign_purch_count   = foreign_purch_count + rc.foreign_purch_count + rc.internet_foreign_count + rc.internet_shop_count
                 , customs_count         = customs_count + rc.customs_count
                 , other_count           = other_count + rc.other_count
                 , internet_count        = internet_count + rc.internet_count + rc.internet_shop_count
                 , internet_shop_count   = internet_shop_count + rc.internet_shop_count
                 , mobile_count          = mobile_count + rc.mobile_count
             where nvl(region_code,   '&') = nvl(rc.region_code,   '&')
               and nvl(customer_type, '&') = nvl(rc.customer_type, '&')
               and nvl(network_id,    -99) = nvl(rc.network_id,    -99)
               and (
                     nvl(card_type, 'x') = nvl(rc.card_type, 'y') or
                     card_type is null and rc.card_type in (net_api_const_pkg.CARD_FEATURE_STATUS_DEBIT
                                                          , net_api_const_pkg.CARD_FEATURE_STATUS_OVERDRAFT) or
                     card_type = net_api_const_pkg.CARD_FEATURE_STATUS_DEBIT and rc.card_type in (net_api_const_pkg.CARD_FEATURE_STATUS_DEBIT
                                                                                                , net_api_const_pkg.CARD_FEATURE_STATUS_OVERDRAFT)
                   )
               and rc.card_type is not null;
        end loop;
    exception
        when others then
            i_put('ERROR! refresh_cst_250_1_aggr_tran3 ' || SQLERRM, 1);
    end refresh_cst_250_1_aggr_tran3;

    -- contactless
    procedure refresh_cst_250_1_aggr_tran4 is
        l_customer_count        com_api_type_pkg.t_long_id;
        l_card_count            com_api_type_pkg.t_long_id;
        l_card_type             com_api_type_pkg.t_dict_value;
    begin
        delete from cst_250_1_aggr_tran
         where card_type in ('CFCHCNTL', 'OPERCNTL');

        select count(c.id) as count_card
             , count(distinct c.customer_id) as count_customer
          into l_card_count
             , l_customer_count
          from iss_card c
          join net_card_type_feature ctf on ctf.card_type_id = c.card_type_id
          join iss_card_instance ci on ci.card_id = c.id
         where c.inst_id = i_inst_id
           and ctf.card_feature = 'CFCHCNTL'
           and ci.status = iss_api_const_pkg.CARD_STATUS_VALID_CARD;

        insert into cst_250_1_aggr_tran(
            card_type
          , customer_count
          , card_count
          , active_card_count
          , domestic_cash_count
          , domestic_cash_amount
          , foreign_cash_count
          , foreign_cash_amout
          , domestic_purch_count
          , domestic_purch_amount
          , foreign_purch_count
          , foreign_purch_amount
          , other_count
          , other_amount
        ) values (
            'CFCHCNTL'
          , l_customer_count
          , l_card_count
          , 0
          , 0
          , 0
          , 0
          , 0
          , 0
          , 0
          , 0
          , 0
          , 0
          , 0
        );

        insert into cst_250_1_aggr_tran(
            card_type
          , domestic_cash_count
          , domestic_cash_amount
          , foreign_cash_count
          , foreign_cash_amout
          , domestic_purch_count
          , domestic_purch_amount
          , foreign_purch_count
          , foreign_purch_amount
          , other_count
          , other_amount
        ) values (
            'OPERCNTL'
          , 0
          , 0
          , 0
          , 0
          , 0
          , 0
          , 0
          , 0
          , 0
          , 0
        );

        for rec in (
            select o.column_type
                 , o.merchant_country
                 , o.is_oper_contactless
                 , count(o.oper_id) as count_oper
                 , sum(o.conv_amount) as sum_oper
              from cst_250_1_oper_tran3 o
             where o.is_card_contactless = 1
               and o.column_type in ('cashout', 'purchases', 'others')
              group by o.column_type
                  , o.merchant_country
                  , o.is_oper_contactless
        ) loop
            if rec.is_oper_contactless = 1 then
                l_card_type := 'OPERCNTL';
            else
                l_card_type := 'CFCHCNTL';
            end if;

            if rec.column_type = 'cashout' then
                if rec.merchant_country = '643' then
                    update cst_250_1_aggr_tran a
                       set a.domestic_cash_count = a.domestic_cash_count + rec.count_oper,
                           a.domestic_cash_amount = a.domestic_cash_amount + rec.sum_oper
                     where l_card_type = 'CFCHCNTL' and a.card_type = l_card_type
                        or l_card_type = 'OPERCNTL' and a.card_type in ('CFCHCNTL', 'OPERCNTL');
                else
                    update cst_250_1_aggr_tran a
                       set a.foreign_cash_count = a.foreign_cash_count + rec.count_oper,
                           a.foreign_cash_amout = a.foreign_cash_amout + rec.sum_oper
                     where l_card_type = 'CFCHCNTL' and a.card_type = l_card_type
                        or l_card_type = 'OPERCNTL' and a.card_type in ('CFCHCNTL', 'OPERCNTL');
                end if;
            elsif rec.column_type = 'purchases' then
                if rec.merchant_country = '643' then
                    update cst_250_1_aggr_tran a
                       set a.domestic_purch_count = a.domestic_purch_count + rec.count_oper,
                           a.domestic_purch_amount = a.domestic_purch_amount + rec.sum_oper
                     where l_card_type = 'CFCHCNTL' and a.card_type = l_card_type
                        or l_card_type = 'OPERCNTL' and a.card_type in ('CFCHCNTL', 'OPERCNTL');
                else
                    update cst_250_1_aggr_tran a
                       set a.foreign_purch_count = a.foreign_purch_count + rec.count_oper,
                           a.foreign_purch_amount = a.foreign_purch_amount + rec.sum_oper
                     where l_card_type = 'CFCHCNTL' and a.card_type = l_card_type
                        or l_card_type = 'OPERCNTL' and a.card_type in ('CFCHCNTL', 'OPERCNTL');
                end if;
            elsif rec.column_type = 'others' then
                update cst_250_1_aggr_tran a
                   set a.other_count = rec.count_oper,
                       a.other_amount = rec.sum_oper
                     where l_card_type = 'CFCHCNTL' and a.card_type = l_card_type
                        or l_card_type = 'OPERCNTL' and a.card_type in ('CFCHCNTL', 'OPERCNTL');
            end if;

        end loop;

        update cst_250_1_aggr_tran a
           set a.active_card_count = (select count(distinct o.card_id)
                                        from cst_250_1_oper_tran3 o
                                       where o.is_card_contactless = 1)
         where a.card_type = 'CFCHCNTL';

        update cst_250_1_aggr_tran a
           set a.active_card_count = (select count(distinct o.card_id)
                                        from cst_250_1_oper_tran3 o
                                       where o.is_card_contactless = 1
                                         and o.is_oper_contactless = 1)
         where a.card_type = 'OPERCNTL';

    exception
        when others then
            i_put('ERROR! refresh_cst_250_1_aggr_tran4 ' || SQLERRM, 1);
    end refresh_cst_250_1_aggr_tran4;

    procedure fix_card_count is
    begin
        for i in (
            select region_code
                 , customer_type
                 , card_feature
                 , card_network
                 , count(card_id) card_count
                 , count(distinct contract_id) as contract_count
              from (
                  select distinct
                         nvl(decode(i_one_region, 1, '45', a2.region_code), '45') region_code
                       , case
                              when corp_card.card_type_id is not null then com_api_const_pkg.ENTITY_TYPE_COMPANY
                              else com_api_const_pkg.ENTITY_TYPE_PERSON
                         end as customer_type
                       , ci.card_id
                       , case
                              when ao.card_id is not null then net_api_const_pkg.CARD_FEATURE_STATUS_OVERDRAFT
                              else net_api_const_pkg.CARD_FEATURE_STATUS_DEBIT
                         end card_feature
                       , decode(substr(c.card_number, 1, 1), '4', 1003, 1002) as card_network
                       , c.contract_id
                    from iss_card_vw            c
                       , iss_card_instance      ci
                       , prd_customer           cust
                       , com_address_object     ao2
                       , com_address            a2
                       , cst_250_overdraft_card ao
                       , ( select distinct ct.card_type_id
                             from prd_contract_type c
                             join prd_product p on p.contract_type = c.contract_type
                             join iss_product_card_type ct on ct.product_id = p.id
                             join com_i18n i on table_name = 'NET_CARD_TYPE' and object_id = ct.card_type_id
                            where c.customer_entity_type = com_api_const_pkg.ENTITY_TYPE_COMPANY
                              and p.inst_id = i_inst_id
                              and i.text not like ('%Unembossed%')
                              and i.text not like ('%Instant%')
                              and i.text not like ('%Collectors%')
                         ) corp_card
                   where c.inst_id = i_inst_id
                     and c.id = ci.card_id
                     and c.customer_id = cust.id
                     and ao2.object_id(+) = ci.agent_id
                     and c.card_type_id = corp_card.card_type_id(+)
                     and ao2.entity_type(+) = ost_api_const_pkg.ENTITY_TYPE_AGENT
                     and ao2.address_type(+) = com_api_const_pkg.ADDRESS_TYPE_BUSINESS
                     and a2.id(+) = ao2.address_id
                     and ao.card_id(+) = ci.card_id
                     and ci.status = iss_api_const_pkg.CARD_STATUS_VALID_CARD
              )
              group by region_code
                     , customer_type
                     , card_feature
                     , card_network
        ) loop
            update cst_250_1_aggr_tran a
              set a.card_count = i.card_count,
                  a.customer_count = i.contract_count
              where region_code = i.region_code
                and network_id = i.card_network
                and card_type = i.card_feature
                and customer_type = i.customer_type;
        end loop;

        for i in (
            select customer_type
                 , region_code
                 , network_id
                 , sum(card_count) as card_count
                 , sum(customer_count) as customer_count
              from cst_250_1_aggr_tran
             where card_type = net_api_const_pkg.CARD_FEATURE_STATUS_DEBIT
             group by customer_type
                    , region_code
                    , network_id
        )
        loop
            update cst_250_1_aggr_tran a
              set card_count = i.card_count,
                  customer_count = i.customer_count
            where a.card_type is null
              and a.customer_type = i.customer_type
              and a.region_code = i.region_code
              and a.network_id = i.network_id;
        end loop;


        delete from cst_250_1_aggr_tran
         where region_code in (
             select region_code
               from (
                   select region_code
                        , sum (customer_count
                             + card_type_count
                             + card_count
                             + active_card_count
                             + domestic_cash_count
                             + domestic_cash_amount
                             + foreign_cash_count
                             + foreign_cash_amout
                             + domestic_purch_count
                             + domestic_purch_amount
                             + foreign_purch_count
                             + foreign_purch_amount
                             + customs_count
                             + customs_amount
                             + other_count
                             + other_amount
                             + internet_count
                             + internet_amount
                             + internet_shop_count
                             + internet_shop_amount
                          ) as all_amt
                     from cst_250_1_aggr_tran
                    group by region_code
               )
              where all_amt = 0
         );
    exception
        when others then
            i_put('ERROR! fix_card_count '||SQLERRM, 1);
    end fix_card_count;

    procedure fix_total is
    begin
        for i1 in (
            select region_code
                 , customer_type
                 , sum (decode(network_id, 1008, 0, 7003, 0, customer_count)) customer_count
                 , sum (decode(network_id, 1008, 0, 7003, 0, card_type_count)) card_type_count
                 , sum (decode(network_id, 1008, 0, 7003, 0, card_count)) card_count
                 , sum (active_card_count) active_card_count
                 , sum (oper_amount_debit) oper_amount_debit
                 , sum (oper_amount_credit) oper_amount_credit
                 , sum (domestic_cash_count) domestic_cash_count
                 , sum (domestic_cash_amount) domestic_cash_amount
                 , sum (foreign_cash_count) foreign_cash_count
                 , sum (foreign_cash_amout) foreign_cash_amout
                 , sum (domestic_purch_count) domestic_purch_count
                 , sum (domestic_purch_amount) domestic_purch_amount
                 , sum (foreign_purch_count) foreign_purch_count
                 , sum (foreign_purch_amount) foreign_purch_amount
                 , sum (customs_count) customs_count
                 , sum (customs_amount) customs_amount
                 , sum (other_count) other_count
                 , sum (other_amount) other_amount
                 , sum (internet_count) internet_count
                 , sum (internet_amount) internet_amount
                 , sum (internet_shop_count) internet_shop_count
                 , sum (internet_shop_amount) internet_shop_amount
                 , sum (mobile_count) mobile_count
                 , sum (mobile_amount) mobile_amount
              from cst_250_1_aggr_tran
             where region_code is not null
               and customer_type is not null
               and card_type is null
               and network_id is not null
             group by region_code
                    , customer_type
        ) loop
            update cst_250_1_aggr_tran
               set customer_count = i1.customer_count
                 , card_type_count = i1.card_type_count
                 , card_count = i1.card_count
                 , oper_amount_debit = i1.oper_amount_debit
                 , oper_amount_credit = i1.oper_amount_credit
                 , domestic_cash_count = i1.domestic_cash_count
                 , domestic_cash_amount = i1.domestic_cash_amount
                 , foreign_cash_count = i1.foreign_cash_count
                 , foreign_cash_amout = i1.foreign_cash_amout
                 , domestic_purch_count = i1.domestic_purch_count
                 , domestic_purch_amount = i1.domestic_purch_amount
                 , foreign_purch_count = i1.foreign_purch_count
                 , foreign_purch_amount = i1.foreign_purch_amount
                 , customs_count = i1.customs_count
                 , customs_amount = i1.customs_amount
                 , other_count = i1.other_count
                 , other_amount = i1.other_amount
                 , internet_count = i1.internet_count
                 , internet_amount = i1.internet_amount
                 , internet_shop_count = i1.internet_shop_count
                 , internet_shop_amount = i1.internet_shop_amount
                 , mobile_count = i1.mobile_count
                 , mobile_amount = i1.mobile_amount
            where region_code = i1.region_code
              and customer_type = i1.customer_type
              and card_type is null
              and network_id is null;
        end loop;

        for i2 in (
            select region_code
                 , customer_type
                 , card_type
                 , sum (decode(network_id, 1008, 0, 7003, 0, customer_count)) customer_count
                 , sum (decode(network_id, 1008, 0, 7003, 0, card_type_count)) card_type_count
                 , sum (decode(network_id, 1008, 0, 7003, 0, card_count)) card_count
                 , sum (active_card_count) active_card_count
                 , sum (oper_amount_debit) oper_amount_debit
                 , sum (oper_amount_credit) oper_amount_credit
                 , sum (domestic_cash_count) domestic_cash_count
                 , sum (domestic_cash_amount) domestic_cash_amount
                 , sum (foreign_cash_count) foreign_cash_count
                 , sum (foreign_cash_amout) foreign_cash_amout
                 , sum (domestic_purch_count) domestic_purch_count
                 , sum (domestic_purch_amount) domestic_purch_amount
                 , sum (foreign_purch_count) foreign_purch_count
                 , sum (foreign_purch_amount) foreign_purch_amount
                 , sum (customs_count) customs_count
                 , sum (customs_amount) customs_amount
                 , sum (other_count) other_count
                 , sum (other_amount) other_amount
                 , sum (internet_count) internet_count
                 , sum (internet_amount) internet_amount
                 , sum (internet_shop_count) internet_shop_count
                 , sum (internet_shop_amount) internet_shop_amount
                 , sum (mobile_count) mobile_count
                 , sum (mobile_amount) mobile_amount
              from cst_250_1_aggr_tran
             where region_code is not null
               and customer_type is not null
               and card_type is not null
               and network_id is not null
             group by region_code
                    , customer_type
                    , card_type
             order by 1, 2 desc, 3
        ) loop
            update cst_250_1_aggr_tran
               set customer_count = i2.customer_count,
                   card_type_count = i2.card_type_count,
                   card_count = i2.card_count,
                   oper_amount_debit = i2.oper_amount_debit,
                   oper_amount_credit = i2.oper_amount_credit,
                   domestic_cash_count = i2.domestic_cash_count,
                   domestic_cash_amount = i2.domestic_cash_amount,
                   foreign_cash_count = i2.foreign_cash_count,
                   foreign_cash_amout = i2.foreign_cash_amout,
                   domestic_purch_count = i2.domestic_purch_count,
                   domestic_purch_amount = i2.domestic_purch_amount,
                   foreign_purch_count = i2.foreign_purch_count,
                   foreign_purch_amount = i2.foreign_purch_amount,
                   customs_count = i2.customs_count,
                   customs_amount = i2.customs_amount,
                   other_count = i2.other_count,
                   other_amount = i2.other_amount,
                   internet_count = i2.internet_count,
                   internet_amount = i2.internet_amount,
                   internet_shop_count = i2.internet_shop_count,
                   internet_shop_amount = i2.internet_shop_amount,
                   mobile_count = i2.mobile_count,
                   mobile_amount = i2.mobile_amount
            where region_code = i2.region_code
              and customer_type = i2.customer_type
              and card_type = i2.card_type
              and network_id is null;
        end loop;

        for i3 in (
            select region_code
                 , card_type
                 , sum (decode(network_id, 1008, 0, 7003, 0, customer_count)) customer_count
                 , sum (decode(network_id, 1008, 0, 7003, 0, card_type_count)) card_type_count
                 , sum (decode(network_id, 1008, 0, 7003, 0, card_count)) card_count
                 , sum (active_card_count) active_card_count
                 , sum (oper_amount_debit) oper_amount_debit
                 , sum (oper_amount_credit) oper_amount_credit
                 , sum (domestic_cash_count) domestic_cash_count
                 , sum (domestic_cash_amount) domestic_cash_amount
                 , sum (foreign_cash_count) foreign_cash_count
                 , sum (foreign_cash_amout) foreign_cash_amout
                 , sum (domestic_purch_count) domestic_purch_count
                 , sum (domestic_purch_amount) domestic_purch_amount
                 , sum (foreign_purch_count) foreign_purch_count
                 , sum (foreign_purch_amount) foreign_purch_amount
                 , sum (customs_count) customs_count
                 , sum (customs_amount) customs_amount
                 , sum (other_count) other_count
                 , sum (other_amount) other_amount
                 , sum (internet_count) internet_count
                 , sum (internet_amount) internet_amount
                 , sum (internet_shop_count) internet_shop_count
                 , sum (internet_shop_amount) internet_shop_amount
                 , sum (mobile_count) mobile_count
                 , sum (mobile_amount) mobile_amount
              from cst_250_1_aggr_tran
             where network_id is not null
               and region_code is not null
             group by region_code
                    , card_type
             order by 1, 2 desc, 3
        ) loop
            update cst_250_1_aggr_tran
               set customer_count = i3.customer_count
                 , card_type_count = i3.card_type_count
                 , card_count = i3.card_count
                 , oper_amount_debit = i3.oper_amount_debit
                 , oper_amount_credit = i3.oper_amount_credit
                 , domestic_cash_count = i3.domestic_cash_count
                 , domestic_cash_amount = i3.domestic_cash_amount
                 , foreign_cash_count = i3.foreign_cash_count
                 , foreign_cash_amout = i3.foreign_cash_amout
                 , domestic_purch_count = i3.domestic_purch_count
                 , domestic_purch_amount = i3.domestic_purch_amount
                 , foreign_purch_count = i3.foreign_purch_count
                 , foreign_purch_amount = i3.foreign_purch_amount
                 , customs_count = i3.customs_count
                 , customs_amount = i3.customs_amount
                 , other_count = i3.other_count
                 , other_amount = i3.other_amount
                 , internet_count = i3.internet_count
                 , internet_amount = i3.internet_amount
                 , internet_shop_count = i3.internet_shop_count
                 , internet_shop_amount = i3.internet_shop_amount
                 , mobile_count = i3.mobile_count
                 , mobile_amount = i3.mobile_amount
             where region_code = i3.region_code
               and nvl(card_type, 1) = nvl(i3.card_type, 1)
               and network_id is null
               and customer_type is null;
        end loop;

        for i4 in (
            select nvl(card_type, '1') card_type
                 , sum (customer_count) customer_count
                 , sum (card_type_count) card_type_count
                 , sum (card_count) card_count
                 , sum (active_card_count) active_card_count
                 , sum (oper_amount_debit) oper_amount_debit
                 , sum (oper_amount_credit) oper_amount_credit
                 , sum (domestic_cash_count) domestic_cash_count
                 , sum (domestic_cash_amount) domestic_cash_amount
                 , sum (foreign_cash_count) foreign_cash_count
                 , sum (foreign_cash_amout) foreign_cash_amout
                 , sum (domestic_purch_count) domestic_purch_count
                 , sum (domestic_purch_amount) domestic_purch_amount
                 , sum (foreign_purch_count) foreign_purch_count
                 , sum (foreign_purch_amount) foreign_purch_amount
                 , sum (customs_count) customs_count
                 , sum (customs_amount) customs_amount
                 , sum (other_count) other_count
                 , sum (other_amount) other_amount
                 , sum (internet_count) internet_count
                 , sum (internet_amount) internet_amount
                 , sum (internet_shop_count) internet_shop_count
                 , sum (internet_shop_amount) internet_shop_amount
                 , sum (mobile_count) mobile_count
                 , sum (mobile_amount) mobile_amount
              from cst_250_1_aggr_tran
             where network_id is null
               and customer_type is null
               and region_code is not null
             group by nvl(card_type, '1')
             order by 1, 2 desc, 3
        ) loop
            update cst_250_1_aggr_tran
               set customer_count = i4.customer_count
                 , card_type_count = i4.card_type_count
                 , card_count = i4.card_count
                 , oper_amount_debit = i4.oper_amount_debit
                 , oper_amount_credit = i4.oper_amount_credit
                 , domestic_cash_count = i4.domestic_cash_count
                 , domestic_cash_amount = i4.domestic_cash_amount
                 , foreign_cash_count = i4.foreign_cash_count
                 , foreign_cash_amout = i4.foreign_cash_amout
                 , domestic_purch_count = i4.domestic_purch_count
                 , domestic_purch_amount = i4.domestic_purch_amount
                 , foreign_purch_count = i4.foreign_purch_count
                 , foreign_purch_amount = i4.foreign_purch_amount
                 , customs_count = i4.customs_count
                 , customs_amount = i4.customs_amount
                 , other_count = i4.other_count
                 , other_amount = i4.other_amount
                 , internet_count = i4.internet_count
                 , internet_amount = i4.internet_amount
                 , internet_shop_count = i4.internet_shop_count
                 , internet_shop_amount = i4.internet_shop_amount
                 , mobile_count = i4.mobile_count
                 , mobile_amount = i4.mobile_amount
             where region_code is null
               and nvl(card_type, '1') = nvl(i4.card_type, '1')
               and network_id is null
               and customer_type is null;
        end loop;

        for i in (
            select customer_count
                 , card_count
                 , customer_type
                 , region_code
                 , card_type
              from cst_250_1_aggr_tran
             where network_id = 1003
        ) loop
            update cst_250_1_aggr_tran
               set customer_count = i.customer_count
                 , card_count = i.card_count
             where customer_type = i.customer_type
               and region_code = i.region_code
               and nvl(card_type, '1') = nvl(i.card_type, '1')
               and network_id = 1008;
        end loop;



        for i in (
            select customer_count
                 , card_count
                 , customer_type
                 , region_code
                 , card_type
              from cst_250_1_aggr_tran
             where network_id = 1002
        ) loop
            update cst_250_1_aggr_tran
               set customer_count = i.customer_count
                 , card_count = i.card_count
             where customer_type = i.customer_type
               and region_code = i.region_code
               and nvl(card_type, '1') = nvl(i.card_type, '1')
               and network_id = 7003;
        end loop;


        for i in (
            select region_code
                 , customer_type
                 , card_feature
                 , card_network_id
                 , count (distinct card_id) as count_card
              from cst_250_1_oper_tran3
             group by grouping sets (region_code, customer_type, card_network_id, card_feature)
                                  , (region_code, customer_type, card_network_id)
                                  , (region_code, customer_type, card_feature)
                                  , (region_code, customer_type )
                                  , (region_code, card_feature)
                                  , (region_code )
                                  , (card_feature)
                                  , ()

        ) loop
            update cst_250_1_aggr_tran
               set active_card_count = active_card_count + i.count_card
             where nvl(region_code, '-') = nvl(i.region_code, '-')
               and nvl(customer_type, '-') = nvl(i.customer_type, '-')
               and (nvl(card_type, '-') = nvl(i.card_feature, '-') or
                   (card_type = net_api_const_pkg.CARD_FEATURE_STATUS_DEBIT and i.card_feature = net_api_const_pkg.CARD_FEATURE_STATUS_OVERDRAFT))
               and nvl(network_id, 0) = nvl(i.card_network_id, 0);
        end loop;
    exception
        when others then
            i_put('ERROR! fix_total ' || sqlerrm, 1);
    end fix_total;

    procedure fix_active_card is
    begin
        update cst_250_1_aggr_tran
           set active_card_count = 0;

        for i in (
            select region_code
                 , customer_type
                 , card_feature
                 , card_network_id
                 , count (distinct card_id) as count_card
              from cst_250_1_oper_tran3
             group by grouping sets (region_code, customer_type, card_network_id, card_feature)
                                  , (region_code, customer_type, card_network_id)
                                  , (region_code, customer_type, card_feature)
                                  , (region_code, customer_type)
                                  , (region_code, card_feature)
                                  , (region_code)
                                  , (card_feature)
                                  , ()

        ) loop
            update cst_250_1_aggr_tran
               set active_card_count = active_card_count + i.count_card
             where nvl(region_code, '-') = nvl(i.region_code, '-')
               and nvl(customer_type, '-') = nvl(i.customer_type, '-')
               and (nvl(card_type, '-') = nvl(i.card_feature, '-') or
                   (card_type = net_api_const_pkg.CARD_FEATURE_STATUS_DEBIT and i.card_feature = net_api_const_pkg.CARD_FEATURE_STATUS_OVERDRAFT))
               and nvl(network_id, 0) = nvl(i.card_network_id, 0);
        end loop;
    exception
        when others then
            i_put('ERROR! fix_active_card '||SQLERRM, 1);
    end fix_active_card;

begin
    i_put('-----------------------------------------------------------');
    i_put('Start collect_data_form_250_1');
    i_put('i_level_refresh = '||i_level_refresh);
    i_put('i_date_start = '||i_date_start);
    i_put('i_date_end = '||i_date_end);

    case i_level_refresh
         when 0 then refresh_cst_250_overdraft_card;
         when 1 then null;
         when 2 then refresh_cst_250_1_cfiles;
         when 3 then refresh_cst_250_1_file_tran;
         when 4 then refresh_cst_250_1_oper_tran1;
         when 5 then refresh_cst_250_1_oper_tran2;
         when 6 then refresh_cst_250_1_oper_tran3;
         when 7 then refresh_cst_250_1_aggr_tran1;
         when 8 then refresh_cst_250_1_aggr_tran2;
         when 9 then refresh_cst_250_1_aggr_tran3;
         when 10 then refresh_cst_250_1_aggr_tran4;
         when 11 then fix_card_count;
         when 12 then fix_total;
         else i_put('Incorrect Level Refresh = ' || i_level_refresh);
    end case;

    i_put('Finish', 1);
exception
    when others then
        i_put('ERROR! collect_data_form_250_1 '||SQLERRM, 1);
        raise;
end collect_data_form_250_1;

procedure run_collect_250_1(
    i_lang              in com_api_type_pkg.t_dict_value
  , i_inst_id           in com_api_type_pkg.t_tiny_id
  , i_date_start        in date
  , i_date_end          in date
  , i_level_start       in com_api_type_pkg.t_tiny_id
  , i_level_end         in com_api_type_pkg.t_tiny_id
  , i_one_region        in com_api_type_pkg.t_boolean
) is
    l_level_start    number(2);
    l_level_end      number(2);
    l_date_start     date;
    l_date_end       date;
    is_one_region    com_api_type_pkg.t_boolean;
    is_split_date    com_api_type_pkg.t_boolean := 1;
    l_split_date     date;
    l_increment_days number(2) := 1;
    l_schema         varchar2(30);
begin
    l_level_start := i_level_start;
    l_level_end   := i_level_end;
    l_date_start  := i_date_start;
    l_date_end    := i_date_end;
    is_one_region := i_one_region;
    l_split_date  := i_date_start;

    select sys_context('userenv', 'CURRENT_SCHEMA')
      into l_schema
      from dual;

    for i in l_level_start .. l_level_end loop
        trc_log_pkg.debug(i_text => 'Refresh level = ' || i || ' was started');
        if is_split_date = 1 and i in (4, 5) then
            trc_log_pkg.debug(i_text => '1 - l_split_date = ' || l_split_date);
            trc_log_pkg.debug(i_text => '1 - l_date_end = ' || l_date_end);

            while l_split_date <= l_date_end loop
                collect_data_form_250_1(
                    i_lang          => i_lang
                  , i_inst_id       => i_inst_id
                  , i_agent_id      => null
                  , i_date_start    => l_split_date
                  , i_date_end      => l_split_date
                  , i_level_refresh => i
                  , i_one_region    => is_one_region
                );
                l_split_date := l_split_date + l_increment_days;

                i_put('2 - l_split_date = ' || l_split_date);
                commit;
            end loop;
        else
            collect_data_form_250_1(
                i_lang          => i_lang
              , i_inst_id       => i_inst_id
              , i_agent_id      => null
              , i_date_start    => l_date_start
              , i_date_end      => l_date_end
              , i_level_refresh => i
              , i_one_region    => is_one_region
            );
            commit;
        end if;

        trc_log_pkg.debug(i_text => 'Refresh level = ' || i || ' was finished');

        if i = 0 then
            dbms_stats.gather_table_stats(ownname => l_schema, tabname => 'CST_250_OVERDRAFT_CARD');
            trc_log_pkg.debug(i_text => 'Statistics for ' || l_schema || '.CST_250_OVERDRAFT_CARD was collected.');
        elsif i = 2 then
            dbms_stats.gather_table_stats(ownname => l_schema, tabname => 'CST_250_1_CFILES');
            trc_log_pkg.debug(i_text => 'Statistics for ' || l_schema || '.CST_250_1_CFILES was collected.');
        elsif i = 3 then
            dbms_stats.gather_table_stats(ownname => l_schema, tabname => 'CST_250_1_FILE_TRAN');
            trc_log_pkg.debug(i_text => 'Statistics for ' || l_schema || '.CST_250_1_FILE_TRAN was collected.');
        elsif i = 4 then
            dbms_stats.gather_table_stats(ownname => l_schema, tabname => 'CST_250_1_OPER_TRAN1');
            trc_log_pkg.debug(i_text => 'Statistics for ' || l_schema || '.CST_250_1_OPER_TRAN1 was collected.');
        elsif i = 5 then
            dbms_stats.gather_table_stats(ownname => l_schema, tabname => 'CST_250_1_OPER_TRAN2');
            trc_log_pkg.debug(i_text => 'Statistics for ' || l_schema || '.CST_250_1_OPER_TRAN2 was collected.');
        elsif i = 6 then
            dbms_stats.gather_table_stats(ownname => l_schema, tabname => 'CST_250_1_OPER_TRAN3');
            trc_log_pkg.debug(i_text => 'Statistics for ' || l_schema || '.CST_250_1_OPER_TRAN3 was collected.');
        end if;
    end loop;
end run_collect_250_1;

procedure run_rpt_form_250_1(
    o_xml           out    clob
  , i_lang              in com_api_type_pkg.t_dict_value
  , i_inst_id           in com_api_type_pkg.t_tiny_id
  , i_agent_id          in com_api_type_pkg.t_short_id      default null
  , i_date_start        in date
  , i_date_end          in date
) is
    l_result        xmltype;
    l_part_1        xmltype;
    l_header        xmltype;
    l_footer        xmltype;
begin
    trc_log_pkg.debug(
        i_text         => 'cst_api_form_250_pkg.run_rpt_form250_1 [#1][#2][#3][#4][#5]]'
      , i_env_param1   => i_lang
      , i_env_param2   => i_inst_id
      , i_env_param3   => i_agent_id
      , i_env_param4   => i_date_start
      , i_env_param5   => i_date_end
    );
    get_header_footer(
        i_lang       => i_lang
      , i_inst_id    => i_inst_id
      , i_agent_id   => i_agent_id
      , i_date_end   => i_date_end
      , o_header     => l_header
      , o_footer     => l_footer
    );

   -- data
   select xmlelement ( "part1", xmlagg (t.xml) )
   into l_part_1
   from (
     select xmlagg( xmlelement
                    ("table"
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
                    , xmlelement( "internet_shop_count"   , x.internet_shop_count   )
                    , xmlelement( "internet_shop_amount"  , x.internet_shop_amount  )
                    , xmlelement( "mobile_unit_count"     , x.mobile_count          )
                    , xmlelement( "mobile_unit_amount"    , x.mobile_amount         )
                    , xmlelement( "nocash_total_count"    , x.nocash_total_count    )
                    , xmlelement( "nocash_total_amount"   , x.nocash_total_amount   )
                    )
            ) xml
     from (
            select region_code
                 , customer_type
                 , network_id
                 , case when region_code is null and customer_type is null and network_id is null then 3
                        when region_code is not null and customer_type is null and network_id is null then 2
                        when region_code is not null and customer_type is not null then 1
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
                 , to_char( oper_amount_debit    /power(10,0),'FM999999999999999990,00' ) as oper_amount_debit
                 , to_char( oper_amount_credit   /power(10,0),'FM999999999999999990,00' ) as oper_amount_credit
                 , to_char( domestic_cash_count  )                                        as domestic_cash_count
                 , to_char( domestic_cash_amount /power(10,0),'FM999999999999999990,00' ) as domestic_cash_amount
                 , to_char( foreign_cash_count   )                                        as foreign_cash_count
                 , to_char( foreign_cash_amout   /power(10,0),'FM999999999999999990,00' ) as foreign_cash_amout
                 , to_char( domestic_purch_count )                                        as domestic_purch_count
                 , to_char( domestic_purch_amount/power(10,0),'FM999999999999999990,00' ) as domestic_purch_amount
                 , to_char( foreign_purch_count  )                                        as foreign_purch_count
                 , to_char( foreign_purch_amount /power(10,0),'FM999999999999999990,00' ) as foreign_purch_amount
                 , to_char( customs_count        )                                        as customs_count
                 , to_char( customs_amount       /power(10,0),'FM999999999999999990,00' ) as customs_amount
                 , to_char( other_count          )                                        as other_count
                 , to_char( other_amount         /power(10,0),'FM999999999999999990,00' ) as other_amount
                 , to_char( internet_count       )                                        as internet_count
                 , to_char( internet_amount      /power(10,0),'FM999999999999999990,00' ) as internet_amount
                 , to_char( internet_shop_count  )                                        as internet_shop_count
                 , to_char( internet_shop_amount /power(10,0),'FM999999999999999990,00' ) as internet_shop_amount
                 , to_char( mobile_count         )                                        as mobile_count
                 , to_char( mobile_amount        /power(10,0),'FM999999999999999990,00' ) as mobile_amount
                 , to_char( nocash_total_count   )                                        as nocash_total_count
                 , to_char( nocash_total_amount  ,'FM999999999999999990,00' ) as nocash_total_amount
              from ( select distinct
                            region_code
                          , decode( region_code, null, null, 'region_code name for ' || region_code ) as region_name
                          , customer_type
                          , network_id
                          , case network_id
                              when 7003 then 'NSPK MC'
                              when 1008 then 'NSPK VISA'
                              when 7017 then 'MIR'
                              else get_text(
                                       i_table_name  => 'net_network'
                                     , i_column_name => 'name'
                                     , i_object_id   => network_id
                                     , i_lang        => i_lang
                                   )
                            end as network_name
                          , card_type as card_feature
                          , customer_count
                          , card_count
                          , active_card_count
                          , oper_amount_debit
                          , oper_amount_credit
                          , domestic_cash_count
                          , domestic_cash_amount
                          , foreign_cash_count
                          , foreign_cash_amout
                          , domestic_purch_count
                          , domestic_purch_amount
                          , foreign_purch_count
                          , foreign_purch_amount
                          , customs_count
                          , customs_amount
                          , other_count
                          , other_amount
                          , internet_count
                          , internet_amount
                          , internet_shop_count
                          , internet_shop_amount
                          , mobile_count
                          , mobile_amount
                          , (domestic_purch_count + foreign_purch_count + nvl(customs_count, 0) + other_count)
                               as nocash_total_count
                          , (round(domestic_purch_amount/power(10,0), 2) + round(foreign_purch_amount/power(10,0), 2)
                             + round(nvl(customs_amount, 0)/power(10,0), 2) + round(other_amount/power(10,0), 2))
                               as nocash_total_amount
                       from cst_250_1_aggr_tran
                      where network_id in (1002, 1003, 1008, 7003, 7017) or network_id is null
                      order by region_code nulls last
                             , decode(customer_type,
                                                    null, null,
                                                    com_api_const_pkg.ENTITY_TYPE_PERSON, 1,
                                                    com_api_const_pkg.ENTITY_TYPE_COMPANY, 2) nulls last
                             , network_id  nulls last
                             , decode(card_type,
                                                null, null,
                                                net_api_const_pkg.CARD_FEATURE_STATUS_DEBIT, 1,
                                                net_api_const_pkg.CARD_FEATURE_STATUS_OVERDRAFT, 2,
                                                net_api_const_pkg.CARD_FEATURE_STATUS_CREDIT, 3,
                                                net_api_const_pkg.CARD_FEATURE_STATUS_CNCTLESS, 4,
                                                'OPERCNTL', 5) nulls first
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

    trc_log_pkg.debug ( i_text => 'cst_api_form_250_pkg.run_rpt_form250_1 - ok' );

exception
    when others then
        trc_log_pkg.debug( i_text => sqlerrm );
        raise_application_error(-20001, sqlerrm);
end;

procedure clear_data_250_3 is
    l_rowcount number;
begin
    delete from cst_250_3_mfiles;
    l_rowcount := sql%rowcount;
    i_put('Deleted from cst_mfile_session_file_id ' || l_rowcount || ' recs.');

    delete from cst_250_3_file_tran;
    l_rowcount := sql%rowcount;
    i_put('Deleted from cst_250_3_file_tran ' || l_rowcount || ' recs.');

    delete from cst_250_3_oper_tran1;
    l_rowcount := sql%rowcount;
    i_put('Deleted from cst_250_3_oper_tran1 ' || l_rowcount || ' recs.');

    delete from cst_250_3_oper_tran2;
    l_rowcount := sql%rowcount;
    i_put('Deleted from cst_250_3_oper_tran2 ' || l_rowcount || ' recs.');

    delete from cst_250_3_aggr_tran;
    l_rowcount := sql%rowcount;
    i_put('Deleted from cst_250_3_aggr_tran ' || l_rowcount || ' recs.');
end clear_data_250_3;

procedure collect_data_form_250_3(
    i_lang              in com_api_type_pkg.t_dict_value
  , i_inst_id           in com_api_type_pkg.t_tiny_id
  , i_agent_id          in com_api_type_pkg.t_short_id
  , i_date_start        in date
  , i_date_end          in date
  , i_level_refresh     in com_api_type_pkg.t_tiny_id
) is
    l_rowcount number;

    procedure refresh_cst_250_3_mfiles is
    begin
        delete from cst_250_3_mfiles;

        l_rowcount := sql%rowcount;
        i_put('Deleted from cst_mfile_session_file_id ' || l_rowcount || ' recs.', 1);

        insert into cst_250_3_mfiles
        select distinct sf.id
             , sf.file_name
             , sf.file_type
          from prc_session_file sf
          join prc_session s on s.id = sf.session_id
          join evt_event_object e on e.proc_session_id = sf.session_id
         where sf.file_type in ('FLTPOWMA', 'FLTPOWMP', 'FLTPOWME') -- TODO these types of file are not supported now
           and e.status = evt_api_const_pkg.EVENT_STATUS_PROCESSED
           and s.inst_id = i_inst_id
           and e.inst_id = i_inst_id
           and trunc(file_date) between i_date_start - 1 and i_date_end + 1;

        l_rowcount := sql%rowcount;
        i_put('Inserted into cst_250_3_mfiles ' || l_rowcount || ' recs.');
    exception
        when others then
            i_put('ERROR! refresh_cst_250_3_mfiles ' || sqlerrm, 1);
    end refresh_cst_250_3_mfiles;

    procedure refresh_cst_250_3_file_tran is
    begin
        delete from cst_250_3_file_tran
         where file_date between i_date_start - 1 and i_date_end + 1;

        l_rowcount := sql%rowcount;
        i_put('Deleted from cst_250_3_file_tran '||l_rowcount||' recs.', 1);

        insert into cst_250_3_file_tran
        select sf.file_name
             , sf.id as session_file_id
             , trunc(sf.file_date) as file_date
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
             , decode(nvl2(trim(substr(rd.raw_data, 59, 1)), 1, 0), 1, -1, 1) as oper_sign
             , trim(substr(rd.raw_data, 127, 8)) as terminal_number
             , 1 is_use
             , rd.raw_data
          from prc_session_file sf
          join prc_file_raw_data rd on rd.session_file_id = sf.id
          join cst_250_3_mfiles s on s.session_file_id = sf.id
         where substr(rd.raw_data, 1, 2) = 'RD'
           and trim(substr(rd.raw_data, 284, 15)) is not null
           and trunc(sf.file_date) between i_date_start - 1 and i_date_end + 1;

        l_rowcount := sql%rowcount;
        i_put('Inserted into cst_250_3_file_tran ' || l_rowcount || ' recs.');
    exception
        when others then
            i_put('ERROR! refresh_cst_250_3_file_tran '||SQLERRM, 1);
    end refresh_cst_250_3_file_tran;

    procedure delete_waste_trans is
    begin
        i_put('Start delete_waste_trans');

        update cst_250_3_file_tran
           set is_use = 0
         where file_date = i_date_start - 1
           and file_name like 'M_ATM%';

        l_rowcount := sql%rowcount;
        i_put('Exclude from cst_250_3_file_tran ' || l_rowcount || ' recs.', 1);

        update cst_250_3_file_tran
           set is_use = 0
         where (file_date = i_date_start - 1 and (file_name like '%_040000_2000%' or file_name like 'M_ATM%'))
            or (file_date = i_date_start and file_name like 'M_ATM%_040000_2000%' and substr(tran_code, 2, 1) in ('7', '9'))
            or (file_date = i_date_end and file_name not like '%_040000_2000%' and file_name not like 'M_ATM%')
            or (file_date = i_date_end + 1 and (
                      (file_name not like 'M_ATM%') or
                      (file_name like 'M_ATM%' and file_name not like '%_040000_2000%') or
                      (file_name like 'M_ATM%_040000_2000%') and (substr(tran_code, 2, 1) not in ('7', '9'))
                     )
                 );

        l_rowcount := sql%rowcount;
        i_put('Exclude from cst_250_3_file_tran ' || l_rowcount || ' recs.', 1);

    end delete_waste_trans;

    procedure refresh_cst_250_3_oper_tran1 is
    begin

        delete from cst_250_3_oper_tran1 f
         where file_date between i_date_start - 1 and i_date_end + 1;

        l_rowcount := sql%rowcount;
        i_put('Deleted from cst_250_3_oper_tran1 ' || l_rowcount || ' recs.', 1);

        insert into cst_250_3_oper_tran1
        select distinct
               f.oper_id
             , f.file_name
             , f.session_file_id
             , f.file_date
             , coalesce(trim(com_api_flexible_data_pkg.get_flexible_value('CST_TERMINAL_REGION_CODE_FORM_250', 'ENTTTRMN', t.id)), -- TODO what
                        trim(a.region_code),
                        '45') as region_code
             , f.tran_code
             , case
                    when opi.inst_id = 9969 then 7017
                    when f.contra_entry_channel in ('E', 'V') then decode(f.contra_entry_channel, 'E', 1002, 1003)
                    when f.contra_entry_channel = 'N' or f.sttl_currency = '643'
                         then case
                                   when opi.card_network_id = 1002 or f.card_type in ('EC', 'MC')
                                        then decode(decode(nvl(opi.inst_id, -99), i_inst_id, 1, 0), 1, 1002, 7003) -- nspk MC
                                   when opi.card_network_id = 1003 or f.card_type in ('PC', 'VC')
                                        then decode(decode(nvl(opi.inst_id, -99), i_inst_id, 1, 0), 1, 1003, 1008) -- nspk VISA
                                   else decode(substr(card_number, 1, 1), '4', 1008, 7003)
                              end
                    else decode(substr(card_number, 1, 1), '4', 1003, 1002)
               end card_network_id
             , o.oper_type
             , f.oper_sign
             , t.terminal_type
             , decode(nvl(f.terminal_number, o.terminal_number), '10000023', 1, 0) as is_mobile
             , case
                    when o.oper_type = opr_api_const_pkg.OPERATION_TYPE_REFUND or f.tran_code = 'CB' then -1
                    else f.oper_sign
               end as actual_count
             , case
                    when f.tran_code in ('N5', 'N6') then 5
                    else arr_oper.oper_group
               end oper_group
             , decode(nvl(opi.inst_id, -99), i_inst_id, 1, 0) as card_us
             , decode(nvl(opa.inst_id, -99), i_inst_id, 1, 0) as term_us
             , case
                    when opi.card_country  in ('643', 'RUS') then 1
                    when substr(f.tran_code, 1, 1) in ('4', 'N', 'B') then 1
                    else 0
               end as country_iss_rf
             , case
                    when o.merchant_country  in ('643', 'RUS') then 1
                    when substr(f.tran_code, 1, 1) in ('4', 'N', 'B') then 1
                    else 0
               end as country_opr_rf
             , decode(o.oper_currency, '643', 0, 1) as foreign_currency
             , case
                    when f.actual_currency = '643' then to_number(f.actual_amount)
                    when f.oper_currency = '643' then f.oper_amount
                    when f.oper_currency in ('840', '978') then com_api_rate_pkg.convert_amount(
                                                                    i_src_amount      => f.oper_amount
                                                                  , i_src_currency    => f.oper_currency
                                                                  , i_dst_currency    => '643'
                                                                  , i_rate_type       => 'RTTPCBRF'
                                                                  , i_inst_id         => i_inst_id
                                                                  , i_eff_date        => f.file_date
                                                                  , i_mask_exception  => 0
                                                                  , i_exception_value => 0
                                                                )
                    when f.sttl_currency = '643' then f.sttl_amount
                    when f.sttl_currency in ('840', '978') then com_api_rate_pkg.convert_amount(
                                                                    i_src_amount      => f.sttl_amount
                                                                  , i_src_currency    => f.sttl_currency
                                                                  , i_dst_currency    => '643'
                                                                  , i_rate_type       => 'RTTPCBRF'
                                                                  , i_inst_id         => i_inst_id
                                                                  , i_eff_date        => f.file_date
                                                                  , i_mask_exception  => 0
                                                                  , i_exception_value => 0
                                                                )
                    when o.oper_currency = '643' then o.oper_amount
                    when o.oper_currency in ('840', '978') then com_api_rate_pkg.convert_amount(
                                                                    i_src_amount      => o.oper_amount
                                                                  , i_src_currency    => o.oper_currency
                                                                  , i_dst_currency    => '643'
                                                                  , i_rate_type       => 'RTTPCBRF'
                                                                  , i_inst_id         => i_inst_id
                                                                  , i_eff_date        => f.file_date
                                                                  , i_mask_exception  => 0
                                                                  , i_exception_value => 0
                                                                )
                    when o.sttl_currency = '643' then o.sttl_amount
                    else com_api_rate_pkg.convert_amount(
                             i_src_amount      => o.sttl_amount
                           , i_src_currency    => o.sttl_currency
                           , i_dst_currency    => '643'
                           , i_rate_type       => 'RTTPCBRF'
                           , i_inst_id         => i_inst_id
                           , i_eff_date        => f.file_date
                           , i_mask_exception  => 0
                           , i_exception_value => 0
                         )
               end as actual_amount
             , nvl(f.terminal_number, o.terminal_number) as terminal_number
             , f.contra_entry_channel
          from cst_250_3_file_tran f
          join opr_operation o on o.id = f.oper_id
          join (select array_id as oper_group
                     , element_value as arr_oper_type   --operation: cash out\payments...
                  from com_array_element where array_id in (4, 5)
                union
                select 5 as oper_group
                     , 'OPTP0010' as arr_oper_type
                  from dual
               ) arr_oper on arr_oper.arr_oper_type = o.oper_type
          join opr_participant opi on opi.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                                  and opi.oper_id = o.id
          join opr_participant opa on opa.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
                                  and opa.oper_id = o.id
          left join acq_terminal t on t.terminal_number = f.terminal_number
          left join com_address_object ao on ao.object_id = t.id
                                         and ao.entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
          left join com_address a on a.id = ao.address_id
         where is_use = 1
           and file_date between i_date_start - 1 and i_date_end + 1
           and decode(nvl(opa.inst_id, -99), 2000, 1, 0) = 1
           and o.terminal_number not in ('REBHB003', 'REBHB004', 'REBHB011', 'REBHB008')
           and f.tran_code != 'X3'
           and (o.oper_type <> opr_api_const_pkg.OPERATION_TYPE_P2P_DEBIT
                or o.terminal_number like 'REBHB%');

        l_rowcount := sql%rowcount;
        i_put('Inserted into cst_250_3_oper_tran1 ' || l_rowcount || ' recs.');

        -- deleting incorrect m_tran_code=55 which c_tran_code=X3
        delete cst_250_3_oper_tran1 o33
         where o33.oper_id in ( select o3.oper_id
                                  from cst_250_3_oper_tran1 o3
                                  left join cst_250_1_oper_tran3 o1 on o1.oper_id = o3.oper_id
                                where --> usonus
                                     card_us = 1
                                 and oper_group = 5
                                 and (terminal_type not in ('TRMT0003', 'TRMT0002') or o3.terminal_number = '10000020')
                                 and o3.is_mobile = 0
                                 --< usonus
                                 and o1.tran_code <> o3.tran_code
                               );

        l_rowcount := sql%rowcount;
        i_put('Deleting incorrect m_tran_code=55 which c_tran_code=X3 [' || l_rowcount || '] recs.');
    exception
        when others then
            i_put('ERROR! refresh_cst_250_3_oper_tran1 '|| sqlerrm, 1);
    end refresh_cst_250_3_oper_tran1;

    procedure refresh_cst_250_3_oper_tran2 is
    begin
        delete from cst_250_3_oper_tran2;

        l_rowcount := sql%rowcount;
        i_put('Deleted from cst_250_3_oper_tran2 ' || l_rowcount || ' recs.', 1);

        insert into cst_250_3_oper_tran2
        select oper_id
             , region_code
             , subsection
             , card_network_id as network_id
             , oper_group
             , terminal_type
             , foreign_currency
             , oper_type
             , actual_count
             , actual_amount
             , is_mobile
             , terminal_number
             , file_name
             , session_file_id
             , file_date
             , tran_code
             , card_us
             , country_iss_rf
             , country_opr_rf
             , contra_entry_channel
             , agent_id
          from (select region_code as region_code
                     , case
                            when card_us = 1 and term_us = 1 and country_opr_rf = 1 then 1
                            when card_us = 1 and term_us = 1 and country_opr_rf = 0 then 4
                            when card_us = 0 and country_iss_rf = 1 and term_us = 1 and country_opr_rf = 1 then 2
                            when card_us = 0 and country_iss_rf = 1 and term_us = 1 and country_opr_rf = 0 then 4
                            when card_us = 0 and country_iss_rf = 0 and term_us = 1 and country_opr_rf = 1
                                                                    and card_network_id not in (1002, 1003) then 2
                            when card_us = 0 and country_iss_rf = 0 and term_us = 1 and country_opr_rf = 1
                                                                    and card_network_id in (1002, 1003) then 3
                            when card_us = 0 and country_iss_rf = 0 and term_us = 1 and country_opr_rf = 0 then 4
                            else 9
                        end as subsection
                      , card_network_id
                      , oper_group
                      , o.terminal_type
                      , foreign_currency
                      , (actual_amount * actual_count) as actual_amount
                      , actual_count as actual_count
                      , oper_type
                      , is_mobile
                      , o.terminal_number
                      , oper_id
                      , file_name
                      , session_file_id
                      , file_date
                      , tran_code
                      , card_us
                      , country_iss_rf
                      , country_opr_rf
                      , contra_entry_channel
                      , c.agent_id
                  from cst_250_3_oper_tran1 o
                  join acq_terminal t on t.terminal_number = o.terminal_number
                                     and t.inst_id = i_inst_id
                  join prd_contract c on c.id = t.contract_id
                 where o.actual_count >= 1
               )
         where subsection in (1, 2, 3, 4);

        l_rowcount := sql%rowcount;
        i_put('Inserted into cst_250_3_oper_tran2 ' || l_rowcount || ' recs.');

        update cst_250_3_oper_tran2
           set subsection = 3
         where subsection = 4;

        l_rowcount := sql%rowcount;
        i_put('Migrate from 4 to 3 subsection ' || l_rowcount || ' recs in table cst_250_3_oper_tran2.');


        update cst_250_3_oper_tran2
           set subsection = 3
         where network_id in (1002, 1003)
           and subsection = 2
           and foreign_currency = 0;

        l_rowcount := sql%rowcount;
        i_put('Migrate from 2 to 3 subsection ' || l_rowcount || ' recs in table cst_250_3_oper_tran2.');


        update cst_250_3_oper_tran2 o
           set o.network_id = 7017
         where o.oper_id in (select o.id oper_id
                               from iss_card_vw c
                               join opr_card oc on c.card_number = oc.card_number
                               join opr_operation o on o.id = oc.oper_id
                              where card_type_id in (1041, 1045));

        l_rowcount := sql%rowcount;
        i_put('Update network to MIR for ' || l_rowcount || ' recs in table cst_250_3_oper_tran2.');


        update cst_250_3_oper_tran2
           set agent_id = case terminal_number
                               when 'ATM01546' then 50000007
                               when 'ATM03728' then 50000007
                               when 'ATM01621' then 50000003
                               when 'ATM01626' then 10000011
                               else agent_id
                          end
         where terminal_number in ('ATM01546', 'ATM03728', 'ATM01621', 'ATM01626');

    exception
        when others then
            i_put('ERROR! refresh_cst_250_3_oper_tran2 ' || sqlerrm, 1);
    end refresh_cst_250_3_oper_tran2;

    procedure refresh_cst_250_3_aggr_tran is
    begin
        delete from cst_250_3_aggr_tran;

        l_rowcount := sql%rowcount;
        i_put('Deleted from cst_250_3_aggr_tran ' || l_rowcount || ' recs.', 1);

        insert into cst_250_3_aggr_tran
        select nvl(region_code, '45') as region_code
             , subsection
             , network_id
             , sum(case when oper_group = 5 then actual_count  else 0 end )                                           as pmt_count_all
             , sum(case when oper_group = 5 then actual_amount else 0 end )                                           as pmt_amount_all
             , sum(case when oper_group = 5 and terminal_type = 'TRMT0001' then actual_count  else 0 end )            as pmt_count_impr
             , sum(case when oper_group = 5 and terminal_type = 'TRMT0001' then actual_amount else 0 end )            as pmt_amount_impr
             , sum(case when oper_group = 5 and terminal_type = 'TRMT0002' then actual_count  else 0 end )            as pmt_count_atm
             , sum(case when oper_group = 5 and terminal_type = 'TRMT0002' then actual_amount else 0 end )            as pmt_amount_atm
             , sum(case when oper_group = 5 and terminal_type = 'TRMT0003' then actual_count  else 0 end )            as pmt_count_pos
             , sum(case when oper_group = 5 and terminal_type = 'TRMT0003' then actual_amount else 0 end )            as pmt_amount_pos
             , sum(case when oper_group = 5 and (terminal_type not in ('TRMT0001', 'TRMT0002', 'TRMT0003') or terminal_number = '10000020')
                                            and is_mobile = 0
                                            and terminal_number <> '10000023' then actual_count  else 0 end )         as pmt_count_other
             , sum(case when oper_group = 5 and (terminal_type not in ('TRMT0001', 'TRMT0002', 'TRMT0003') or terminal_number = '10000020')
                                            and is_mobile = 0
                                            and terminal_number <> '10000023' then actual_amount else 0 end )         as pmt_amount_other
             , sum(case when oper_group = 4 then actual_count  else 0 end )                                           as cash_count_all
             , sum(case when oper_group = 4 then actual_amount else 0 end )                                           as cash_amount_all
             , sum(case when oper_group = 4 and terminal_type = 'TRMT0002' and oper_type = 'OPTP0001' then actual_count  else 0 end ) as cash_count_atm
             , sum(case when oper_group = 4 and terminal_type = 'TRMT0002' and oper_type = 'OPTP0001' then actual_amount else 0 end ) as cash_amount_atm
             , sum(case when oper_group = 4 and foreign_currency = 1 then actual_count  else 0 end )                  as cash_count_foreign_curr
             , sum(case when oper_group = 4 and foreign_currency = 1 then actual_amount else 0 end )                  as cash_amount_foreign_curr
             , null as agent_id
          from cst_250_3_oper_tran2 opr
         group by nvl(region_code, '45')
                , subsection
                , network_id
                , agent_id;

        l_rowcount := sql%rowcount;
        i_put('Inserted into cst_250_3_aggr_tran ' || l_rowcount || ' recs.');
    exception
        when others then
            i_put('ERROR! refresh_cst_250_3_aggr_tran ' || sqlerrm, 1);
    end refresh_cst_250_3_aggr_tran;

begin
    i_put('Start collect_data_form_250_3');
    i_put('i_level_refresh = ' || i_level_refresh);
    i_put('i_date_start = ' || i_date_start);
    i_put('i_date_end = ' || i_date_end);

    case i_level_refresh
         when 0 then refresh_cst_250_3_mfiles;
         when 1 then refresh_cst_250_3_file_tran;
         when 2 then delete_waste_trans;
         when 3 then refresh_cst_250_3_oper_tran1;
         when 4 then refresh_cst_250_3_oper_tran2;
         when 5 then refresh_cst_250_3_aggr_tran;
         when 6 then null;
         else i_put('Incorrect Level Refresh = ' || i_level_refresh);
    end case;

    i_put('Finish', 1);
exception
    when others then
        i_put('ERROR! collect_data_form_250_3 ' || sqlerrm, 1);
end collect_data_form_250_3;

procedure run_rpt_form_250_3(
    o_xml           out    clob
  , i_lang              in com_api_type_pkg.t_dict_value
  , i_inst_id           in com_api_type_pkg.t_tiny_id
  , i_agent_id          in com_api_type_pkg.t_short_id      default null
  , i_date_start        in date
  , i_date_end          in date
) is
    l_result        xmltype;
    l_part_3        xmltype;
    l_header        xmltype;
    l_footer        xmltype;
begin
    trc_log_pkg.debug(
        i_text         => '++ cst_api_form_250_pkg.run_rpt_form250_3 [#1][#2][#3][#4][#5]]'
      , i_env_param1   => i_lang
      , i_env_param2   => i_inst_id
      , i_env_param3   => i_agent_id
      , i_env_param4   => i_date_start
      , i_env_param5   => i_date_end
    );

    get_header_footer(
        i_lang        => i_lang
      , i_inst_id     => i_inst_id
      , i_agent_id    => i_agent_id
      , i_date_end    => i_date_end
      , o_header      => l_header
      , o_footer      => l_footer
    );

    -- data
    select xmlelement("part3", xmlagg(t.xml))
      into l_part_3
      from (
          select xmlagg( xmlelement ( "table"
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
                     , case nvl(network_id, 9999)
                            when 7003 then 'NSPK MC'
                            when 1008 then 'NSPK VISA'
                            when 7017 then 'MIR'
                            when 9999 then null
                            else get_text(
                                     i_table_name  => 'net_network'
                                   , i_column_name => 'name'
                                   , i_object_id   => network_id
                                   , i_lang        => i_lang
                                 )
                       end as network_name
                     , case
                            when network_id is null and subsection is null and region_code is not null
                                 then decode( region_code, null, null, 'region '||region_code )
                            else null
                       end as region_name
                     , case
                            when region_code is null and subsection is null and network_id is null then 'total'
                            when region_code is not null and subsection is null then 'region'
                            when subsection in (1, 2, 3) then 'section123'
                            when subsection = 4 then 'section4'
                       end as row_type
                     , pmt_count_all
                     , to_char( pmt_amount_all  /power(10,0), 'FM999999999999999990,00' ) as pmt_amount_all
                     , pmt_count_impr
                     , to_char( pmt_amount_impr /power(10,0), 'FM999999999999999990,00' ) as pmt_amount_impr
                     , pmt_count_atm
                     , to_char( pmt_amount_atm  /power(10,0), 'FM999999999999999990,00' ) as pmt_amount_atm
                     , pmt_count_pos
                     , to_char( pmt_amount_pos  /power(10,0), 'FM999999999999999990,00' ) as pmt_amount_pos
                     , pmt_count_other
                     , to_char( pmt_amount_other/power(10,0), 'FM999999999999999990,00' ) as pmt_amount_other
                     , cash_count_all
                     , to_char( cash_amount_all /power(10,0), 'FM999999999999999990,00' ) as cash_amount_all
                     , cash_count_atm
                     , to_char( cash_amount_atm /power(10,0), 'FM999999999999999990,00' ) as cash_amount_atm
                     , cash_count_foreign_curr
                     , to_char( cash_amount_foreign_curr/power(10,0),'FM999999999999999990,00' ) as cash_amount_foreign_curr
                  from (
                      select agent_id
                           , region_code
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
                        from cst_250_3_aggr_tran
                       where subsection <> 4
                         and network_id in (1002, 1003, 1008, 7003, 7017) or network_id is null
                       group by grouping sets (agent_id, region_code, subsection, network_id)
                                            , (agent_id, region_code, subsection)
                                            , (agent_id, region_code, network_id)
                                            , (agent_id, region_code)
                      union
                      select agent_id
                           , region_code
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
                        from cst_250_3_aggr_tran
                       where subsection = 4
                         and network_id in (1002, 1003, 1008, 7003) or network_id is null
                       group by grouping sets (agent_id, region_code, subsection, network_id)
                                            , (agent_id, region_code, subsection)
                      union
                      select null
                           , null
                           , null
                           , null
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
                        from cst_250_3_aggr_tran
                       where network_id in (1002, 1003, 1008, 7003) or network_id is null
                  )
                 where 1 = 1
                order by region_code nulls last
                       , subsection
                       , case
                              when region_code is not null and subsection is null   --for locating total by region in first row
                                   then decode (network_id,null,-99999,network_id)          --below - total by region + network
                              else network_id
                         end
            ) x
        ) t;

    select xmlelement("report"
             , l_header
             , l_part_3
             , l_footer
           )
    into l_result
    from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug(i_text => 'cst_api_form_250_pkg.run_rpt_form250_3 - ok' );

exception
    when others then
        trc_log_pkg.debug(i_text => sqlerrm );
        raise_application_error(-20011, sqlerrm);
end run_rpt_form_250_3;

procedure run_collect_250_3(
    i_lang              in com_api_type_pkg.t_dict_value
  , i_inst_id           in com_api_type_pkg.t_tiny_id
  , i_agent_id          in com_api_type_pkg.t_short_id
  , i_date_start        in date
  , i_date_end          in date
) is
begin
    for i in 0..5 loop
        collect_data_form_250_3(
            i_lang            => i_lang
          , i_inst_id         => i_inst_id
          , i_agent_id        => i_agent_id
          , i_date_start      => i_date_start
          , i_date_end        => i_date_end
          , i_level_refresh   => i
        );

        commit;
    end loop;
end run_collect_250_3;

end cst_api_form_250_pkg;
/
