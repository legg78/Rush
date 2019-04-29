create or replace package body vis_prc_vcf_pkg as

DELIMITER        constant com_api_type_pkg.t_oracle_name := chr(09); -- Tab
--CRLF             constant com_api_type_pkg.t_name        := chr(13) || chr(10); 
DATE_FORMAT      constant com_api_type_pkg.t_oracle_name := 'MMDDCCYY';

procedure prc_api_file_pkg_pl(
    i_raw_data               in     com_api_type_pkg.t_text
  , i_sess_file_id        in     com_api_type_pkg.t_long_id
) is
begin
dbms_output.put_line(i_raw_data);
end;

procedure put_header(
    i_inst_id                in     com_api_type_pkg.t_inst_id
  , i_company_id             in     com_api_type_pkg.t_short_id
  , i_eff_date               in     date
  , i_trans_code             in     com_api_type_pkg.t_byte_char
  , i_record_type            in     com_api_type_pkg.t_byte_char
  , i_cmid                   in     com_api_type_pkg.t_bin
  , i_acq_business_id        in     com_api_type_pkg.t_bin
  , i_record_count           in     com_api_type_pkg.t_short_id         default 0
  , i_total_amount           in     com_api_type_pkg.t_short_id         default 0
  , i_session_file_id        in     com_api_type_pkg.t_long_id
) is
    l_line                          com_api_type_pkg.t_text;
begin
    l_line := i_trans_code                     || DELIMITER  -- Transaction code / header for a transaction set
           || lpad(i_company_id, 10, '0')      || DELIMITER
           || lpad(1, 5, '0')                  || DELIMITER -- Sequence number
           || to_char(i_eff_date, DATE_FORMAT) || DELIMITER -- Processing date
           || i_record_type                    || DELIMITER -- Record type code
           || lpad(i_record_count, 10, '0')    || DELIMITER -- Record count
           || lpad(i_total_amount, 16, '0')    || DELIMITER -- Total amount
           || rpad('4.0', 10, ' ')             || DELIMITER -- Load file format
           || lpad(i_cmid, 10, '0')            || DELIMITER
           || rpad(i_acq_business_id, 10, '0') || DELIMITER
           || 4                                || DELIMITER -- Visa region identification (Asia-Pacific)
           || rpad('UNIX', 10, ' ')            || DELIMITER -- Processor platform reference
           || rpad(' ', 26, ' ')               || DELIMITER -- Optional field #1
           || rpad(' ', 26, ' ')               || DELIMITER -- Optional field #2
           || rpad(' ', 26, ' ')               || DELIMITER -- Optional field #3
           || rpad(' ', 26, ' ')                            -- Optional field #4
    ;
    prc_api_file_pkg_pl(
        i_raw_data      => l_line
      , i_sess_file_id  => i_session_file_id
    );
end put_header;

procedure put_t6(
    i_inst_id                in     com_api_type_pkg.t_inst_id
  , i_company_id             in     com_api_type_pkg.t_short_id
  , i_eff_date               in     date
  , i_session_file_id        in     com_api_type_pkg.t_long_id
) is
    l_line                          com_api_type_pkg.t_text;
begin
    select '1'                                || DELIMITER  -- Load transaction code
        || lpad(i_company_id, 10, '0')        || DELIMITER
        || rpad(comp.embossed_name, 80, ' ')  || DELIMITER
        || rpad(addr.street || ', ' || addr.house, 80, ' ')  || DELIMITER
        || rpad(addr.apartment, 80, ' ')      || DELIMITER
        || rpad(addr.city, 20, ' ')           || DELIMITER
        || rpad(' ', 4, ' ')                  || DELIMITER
        || lpad(addr.country, 5, '0')         || DELIMITER
        || rpad(addr.postal_code, 14, ' ')    || DELIMITER
        || to_char(add_months(trunc(i_eff_date, 'yyyy'), 12) - 5, DATE_FORMAT) || DELIMITER
        || lpad('0', 16, '0')                 || DELIMITER
        || '2'                                || DELIMITER -- Card type = 2
        || com_api_i18n_pkg.get_text(
               i_table_name  => 'ost_institution'
             , i_column_name => 'name'
             , i_object_id   => i_inst_id
           )
        || '1'
        || to_char(i_eff_date, DATE_FORMAT)   || DELIMITER
        || rpad(' ', 80, ' ')                 || DELIMITER
        || '0'
        || rpad(' ', 26, ' ')               || DELIMITER -- Optional field #1
        || rpad(' ', 26, ' ')               || DELIMITER -- Optional field #2
        || rpad(' ', 26, ' ')               || DELIMITER -- Optional field #3
        || rpad(' ', 26, ' ')                            -- Optional field #4
      into l_line
      from      com_company         comp
      join      prd_customer        cust    on cust.entity_type = com_api_const_pkg.ENTITY_TYPE_COMPANY
                                           and cust.object_id   = comp.id
      left join com_address_object  obj     on obj.entity_type  = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                           and obj.object_id    = cust.id
      left join com_address         addr    on addr.id          = obj.address_id
     where comp.id = i_company_id
       and rownum  = 1;

    prc_api_file_pkg_pl(
        i_raw_data      => l_line
      , i_sess_file_id  => i_session_file_id
    );
end put_t6;

procedure put_t10(
    i_inst_id                in     com_api_type_pkg.t_inst_id
  , i_company_id             in     com_api_type_pkg.t_short_id
  , i_eff_date               in     date
  , i_session_file_id        in     com_api_type_pkg.t_long_id
  , o_record_count              out com_api_type_pkg.t_short_id
) is
    l_line                          com_api_type_pkg.t_text;
begin
    o_record_count := 0;

    for department in (
        select *
          from crp_department dep
         where dep.corp_company_id = i_company_id
       connect by parent_id = prior id
         start with parent_id is null
         order siblings by id
    ) loop
        l_line := '1'                                 || DELIMITER  -- Load transaction code
               || lpad(i_company_id, 10, '0')         || DELIMITER
               || rpad(department.id, 40, ' ')        || DELIMITER
               || rpad(department.parent_id, 40, ' ') || DELIMITER
               || to_char(i_eff_date, DATE_FORMAT)    || DELIMITER
               || com_api_i18n_pkg.get_text(
                      i_table_name  => 'crp_department'
                    , i_column_name => 'label'
                    , i_object_id   => department.id
                  )
               || rpad(' ', 20, ' ')                  || DELIMITER
               || rpad(' ', 20, ' ')                  || DELIMITER
               || rpad(' ', 40, ' ')                  || DELIMITER
               || lpad('0', 8, '0')                   || DELIMITER
               || rpad(' ', 14, ' ')                  || DELIMITER
               || rpad(' ', 26, ' ')                  || DELIMITER
               || rpad(' ', 20, ' ')                  || DELIMITER
               || rpad(' ', 20, ' ')                  || DELIMITER
               || rpad(' ', 40, ' ')                  || DELIMITER
               || rpad(' ', 40, ' ')                  || DELIMITER
               || rpad(' ', 40, ' ')                  || DELIMITER
               || rpad(' ', 20, ' ')                  || DELIMITER
               || rpad(' ', 4, ' ')                   || DELIMITER
               || rpad(' ', 5, ' ')                   || DELIMITER
               || rpad(' ', 14, ' ')                  || DELIMITER
               || rpad(' ', 16, ' ')                  || DELIMITER
               || rpad(' ', 16, ' ')                  || DELIMITER
               || rpad(' ', 140, ' ')                 || DELIMITER
               || rpad(' ', 56, ' ')                  || DELIMITER
               || rpad(' ', 56, ' ')                  || DELIMITER
               || rpad(' ', 2, ' ')                   || DELIMITER
               || rpad(' ', 50, ' ')                  || DELIMITER
               || rpad(' ', 76, ' ')                  || DELIMITER
               || rpad(' ', 26, ' ')                  || DELIMITER -- Optional field #1
               || rpad(' ', 26, ' ')                  || DELIMITER -- Optional field #2
               || rpad(' ', 26, ' ')                  || DELIMITER -- Optional field #3
               || rpad(' ', 26, ' ')                               -- Optional field #4
        ;
        prc_api_file_pkg_pl(
            i_raw_data      => l_line
          , i_sess_file_id  => i_session_file_id
        );
        o_record_count := o_record_count + 1;
    end loop;
end put_t10;

procedure put_t3(
    i_inst_id                in     com_api_type_pkg.t_inst_id
  , i_company_id             in     com_api_type_pkg.t_short_id
  , i_eff_date               in     date
  , i_session_file_id        in     com_api_type_pkg.t_long_id
  , o_record_count              out com_api_type_pkg.t_short_id
) is
    l_line                          com_api_type_pkg.t_text;
begin
    o_record_count := 0;

    for r in (
        select card.cardholder_id
             , crdh.cardholder_number
             , dep.id as department_id
--             , dep_acc.account_number
             , iss_api_token_pkg.decode_card_number(i_card_number => crdn.card_number) as card_number
             , (select min(b.open_date)
                  from acc_balance b
                 where b.account_id = dep_acc.id
                   and b.balance_type = 'BLTP0001'
               ) as account_open_date
             , (select distinct first_value(i.expir_date) over (order by i.seq_number desc)
                  from iss_card_instance i
                 where i.card_id = card.id
               ) as expir_date
          from crp_department     dep
          join acc_account_object dep_ao    on dep_ao.entity_type  = 'ENTTDPRT'
                                           and dep_ao.object_id    = dep.id
          join acc_account        dep_acc   on dep_acc.id          = dep_ao.account_id
          join acc_account_object card_ao   on card_ao.account_id  = dep_acc.id
                                           and card_ao.entity_type = 'ENTTCARD'
          join iss_card           card      on card.id             = card_ao.object_id
          join iss_cardholder     crdh      on crdh.id             = card.cardholder_id
          join iss_card_number    crdn      on crdn.card_id        = card.id
         where dep.corp_company_id = i_company_id
      order by dep.id
    ) loop
        l_line := '1'                                       || DELIMITER  -- Load transaction code
               || rpad(r.cardholder_number, 20, ' ')        || DELIMITER
               || rpad(r.card_number, 19, ' ')              || DELIMITER
               || rpad(r.department_id, 40, ' ')            || DELIMITER
               || to_char(i_eff_date, DATE_FORMAT)          || DELIMITER
               || to_char(r.account_open_date, DATE_FORMAT) || DELIMITER
               || lpad('0', 8, '0')                         || DELIMITER
               || to_char(r.expir_date, DATE_FORMAT)        || DELIMITER
               || '2'                                       || DELIMITER  -- Card type
               || lpad('0', 16, '0')                        || DELIMITER
               || '3'                                       || DELIMITER  -- Statement type = Monthly
               || lpad('0', 8, '0')                         || DELIMITER
               || lpad('0', 16, '0')                        || DELIMITER
               || '0'                                       || DELIMITER
               || rpad(' ', 19, ' ')                        || DELIMITER
               || rpad(' ', 50, ' ')                        || DELIMITER
               || rpad(' ', 76, ' ')                        || DELIMITER
               || lpad('0', 8, '0')                         || DELIMITER
               || lpad('0', 8, '0')                         || DELIMITER
               || lpad('0', 16, '0')                        || DELIMITER
               || '02'                                      || DELIMITER  -- Account status = Opened
               || '00'                                      || DELIMITER
               || lpad('0', 8, '0')                         || DELIMITER
               || '0'                                       || DELIMITER
               || '0'                                       || DELIMITER
               || rpad(' ', 26, ' ')                        || DELIMITER
               || '0'                                       || DELIMITER
               || '  '                                      || DELIMITER
               || lpad('0', 8, '0')                         || DELIMITER
               || '0'                                       || DELIMITER
               || '00'                                      || DELIMITER
               || '0'                                       || DELIMITER
               || '0'                                       || DELIMITER
               || '1'                                       || DELIMITER  -- Account type flag = Corporate
               || lpad('0', 8, '0')                         || DELIMITER
               || lpad('0', 8, '0')                         || DELIMITER
               || lpad('0', 16, '0')                        || DELIMITER
               || rpad(' ', 19, ' ')                        || DELIMITER
               || '  '                                      || DELIMITER
               || rpad(' ', 50, ' ')                        || DELIMITER
               || rpad(' ', 50, ' ')                        || DELIMITER
               || lpad('0', 8, '0')                         || DELIMITER
               || lpad('0', 8, '0')                         || DELIMITER
               || rpad(' ', 26, ' ')                        || DELIMITER -- Optional field #1
               || rpad(' ', 26, ' ')                        || DELIMITER -- Optional field #2
               || rpad(' ', 26, ' ')                        || DELIMITER -- Optional field #3
               || rpad(' ', 26, ' ')                                     -- Optional field #4
        ;
        prc_api_file_pkg_pl(
            i_raw_data      => l_line
          , i_sess_file_id  => i_session_file_id
        );
        o_record_count := o_record_count + 1;
    end loop;
end put_t3;

procedure put_t4(
    i_inst_id                in     com_api_type_pkg.t_inst_id
  , i_company_id             in     com_api_type_pkg.t_short_id
  , i_eff_date               in     date
  , i_session_file_id        in     com_api_type_pkg.t_long_id
  , o_record_count              out com_api_type_pkg.t_short_id
) is
    l_line                          com_api_type_pkg.t_text;
begin
    o_record_count := 0;

    for r in (
        select card.cardholder_id
             , crdh.cardholder_number
             , dep.id as department_id
             , (select min(b.open_date)
                  from acc_balance b
                 where b.account_id = dep_acc.id
                   and b.balance_type = 'BLTP0001'
               ) as account_open_date
             , (select distinct first_value(i.expir_date) over (order by i.seq_number desc)
                  from iss_card_instance i
                 where i.card_id = card.id
               ) as expir_date
             , (select distinct first_value(i.embossed_first_name) over (order by i.seq_number desc)
                  from iss_card_instance i
                 where i.card_id = card.id
               ) as embossed_first_name
             , (select distinct first_value(i.embossed_surname) over (order by i.seq_number desc)
                  from iss_card_instance i
                 where i.card_id = card.id
               ) as embossed_surname
          from crp_department     dep
          join acc_account_object dep_ao    on dep_ao.entity_type  = 'ENTTDPRT'
                                           and dep_ao.object_id    = dep.id
          join acc_account        dep_acc   on dep_acc.id          = dep_ao.account_id
          join acc_account_object card_ao   on card_ao.account_id  = dep_acc.id
                                           and card_ao.entity_type = 'ENTTCARD'
          join iss_card           card      on card.id             = card_ao.object_id
          join iss_cardholder     crdh      on crdh.id             = card.cardholder_id
         where dep.corp_company_id = i_company_id
      order by dep.id
    ) loop
        l_line := '1'                                       || DELIMITER  -- Load transaction code
               || lpad(i_company_id, 10, '0')               || DELIMITER
               || rpad(r.cardholder_number, 20, ' ')        || DELIMITER
               || rpad(r.department_id, 40, ' ')            || DELIMITER
               || rpad(r.embossed_first_name, 20, ' ')      || DELIMITER
               || rpad(r.embossed_surname, 20, ' ')         || DELIMITER
               || rpad(' ', 40, ' ')                        || DELIMITER
               || rpad(' ', 40, ' ')                        || DELIMITER
               || rpad(' ', 20, ' ')                        || DELIMITER
               || rpad(' ', 4, ' ')                         || DELIMITER
               || rpad(' ', 5, ' ')                         || DELIMITER
               || rpad(' ', 14, ' ')                        || DELIMITER
               || rpad(' ', 40, ' ')                        || DELIMITER
               || rpad(' ', 14, ' ')                        || DELIMITER
               || rpad(' ', 14, ' ')                        || DELIMITER
               || rpad(' ', 14, ' ')                        || DELIMITER
               || rpad(' ', 20, ' ')                        || DELIMITER
               || lpad('0', 8, '0')                         || DELIMITER
               || rpad(' ', 128, ' ')                       || DELIMITER
               || rpad(' ', 26, ' ')                        || DELIMITER
               || rpad(' ', 26, ' ')                        || DELIMITER
               || rpad(' ', 26, ' ')                        || DELIMITER
               || rpad(' ', 10, ' ')                        || DELIMITER
               || rpad(' ', 14, ' ')                        || DELIMITER
               || rpad(' ', 30, ' ')                        || DELIMITER
               || rpad(' ', 19, ' ')                        || DELIMITER
               || rpad(' ', 20, ' ')                        || DELIMITER
               || rpad(' ', 16, ' ')                        || DELIMITER
               || rpad(' ', 26, ' ')                        || DELIMITER
               || rpad(' ', 16, ' ')                        || DELIMITER
               || rpad(' ', 26, ' ')                        || DELIMITER
               || rpad(' ', 26, ' ')                        || DELIMITER -- Optional field #1
               || rpad(' ', 26, ' ')                        || DELIMITER -- Optional field #2
               || rpad(' ', 26, ' ')                        || DELIMITER -- Optional field #3
               || rpad(' ', 26, ' ')                                     -- Optional field #4
        ;
        prc_api_file_pkg_pl(
            i_raw_data      => l_line
          , i_sess_file_id  => i_session_file_id
        );
        o_record_count := o_record_count + 1;
    end loop;
end put_t4;

procedure put_t11(
    i_inst_id                in     com_api_type_pkg.t_inst_id
  , i_company_id             in     com_api_type_pkg.t_short_id
  , i_eff_date               in     date
  , i_session_file_id        in     com_api_type_pkg.t_long_id
  , o_record_count              out com_api_type_pkg.t_short_id
) is
    l_line                          com_api_type_pkg.t_text;
begin
    o_record_count := 0;

    for r in (
        select card.cardholder_id
             , (select min(b.open_date)
                  from acc_balance b
                 where b.account_id = dep_acc.id
                   and b.balance_type = 'BLTP0001'
               ) as account_open_date
             , (select distinct first_value(i.expir_date) over (order by i.seq_number desc)
                  from iss_card_instance i
                 where i.card_id = card.id
               ) as expir_date
          from crp_department     dep
          join acc_account_object dep_ao    on dep_ao.entity_type  = 'ENTTDPRT'
                                           and dep_ao.object_id    = dep.id
          join acc_account        dep_acc   on dep_acc.id          = dep_ao.account_id
          join acc_account_object card_ao   on card_ao.account_id  = dep_acc.id
                                           and card_ao.entity_type = 'ENTTCARD'
          join iss_card           card      on card.id             = card_ao.object_id
          join iss_cardholder     crdh      on crdh.id             = card.cardholder_id
         where dep.corp_company_id = i_company_id
      order by dep.id
    ) loop
        l_line := '1'                                       || DELIMITER  -- Load transaction code
               || lpad(i_company_id, 10, '0')               || DELIMITER
               || lpad('1', 5, '0')                         || DELIMITER  -- Period
               || '2'                                       || DELIMITER  -- Card type = 2 (purchasing)
               || to_char(i_eff_date, DATE_FORMAT)          || DELIMITER
               || to_char(add_months(i_eff_date, 1), DATE_FORMAT) || DELIMITER
               || '0'                                       || DELIMITER  -- Period is opened
               || rpad(' ', 26, ' ')                        || DELIMITER -- Optional field #1
               || rpad(' ', 26, ' ')                        || DELIMITER -- Optional field #2
               || rpad(' ', 26, ' ')                        || DELIMITER -- Optional field #3
               || rpad(' ', 26, ' ')                                     -- Optional field #4
        ;

        prc_api_file_pkg_pl(
            i_raw_data      => l_line
          , i_sess_file_id  => i_session_file_id
        );

        o_record_count := o_record_count + 1;
    end loop;
end put_t11;

procedure put_t5(
    i_inst_id                in     com_api_type_pkg.t_inst_id
  , i_company_id             in     com_api_type_pkg.t_short_id
  , i_eff_date               in     date
  , i_session_file_id        in     com_api_type_pkg.t_long_id
  , o_record_count              out com_api_type_pkg.t_short_id
  , o_total_amount              out com_api_type_pkg.t_money
) is
    l_line                          com_api_type_pkg.t_text;
begin
    o_record_count := 0;
    o_total_amount := 0;

    for r in (
        select card.cardholder_id
             , crdh.cardholder_number
--             , dep_acc.account_number
             , iss_api_token_pkg.decode_card_number(i_card_number => crdn.card_number) as card_number
             , (select min(b.open_date)
                  from acc_balance b
                 where b.account_id = dep_acc.id
                   and b.balance_type = 'BLTP0001'
               ) as account_open_date
             , (select distinct first_value(i.expir_date) over (order by i.seq_number desc)
                  from iss_card_instance i
                 where i.card_id = card.id
               ) as expir_date
             , fin.acq_inst_bin
             , oper.oper_date
             , oper.host_date
             , oper.merchant_city
             , oper.merchant_country
             , oper.originator_refnum
             , oper.oper_amount
             , oper.oper_currency
             , oper.sttl_amount
             , oper.sttl_currency
             , oper.mcc
             , oper.oper_type
          from crp_department     dep
          join acc_account_object dep_ao    on dep_ao.entity_type  = 'ENTTDPRT'
                                           and dep_ao.object_id    = dep.id
          join acc_account        dep_acc   on dep_acc.id          = dep_ao.account_id
          join acc_account_object card_ao   on card_ao.account_id  = dep_acc.id
                                           and card_ao.entity_type = 'ENTTCARD'
          join iss_card           card      on card.id             = card_ao.object_id
          join iss_cardholder     crdh      on crdh.id             = card.cardholder_id
          join opr_participant    part      on part.account_id     = dep_acc.id
                                            or part.card_id        = card.id
          join opr_operation      oper      on oper.id             = part.oper_id
          join iss_card_number    crdn      on crdn.card_id        = card.id
          left join vis_fin_message fin     on fin.id              = oper.id
         where dep.corp_company_id = i_company_id
      order by dep.id
    ) loop
        o_record_count := o_record_count + 1;

        l_line := '1'                                       || DELIMITER  -- Load transaction code
               || rpad(r.cardholder_number, 20, ' ')        || DELIMITER
               || rpad(r.card_number, 19, ' ')              || DELIMITER
               || to_char(r.oper_date, DATE_FORMAT)         || DELIMITER
               || to_char(r.originator_refnum, DATE_FORMAT) || DELIMITER
               || lpad(o_record_count, 10, '0')             || DELIMITER
               || lpad('1', 5, '0')                         || DELIMITER  -- Period
               || lpad(r.acq_inst_bin, 10, '0')             || DELIMITER
               || rpad(' ', 26, ' ')                        || DELIMITER
               || rpad(' ', 26, ' ')                        || DELIMITER
               || rpad(substr(r.merchant_city, 1, 14), 14, ' ') || DELIMITER
               || rpad(' ', 4, ' ')                         || DELIMITER
               || rpad(r.merchant_country, 4, ' ')          || DELIMITER
               || rpad(' ', 14, ' ')                        || DELIMITER
               || lpad(r.oper_amount, 16, '0')              || DELIMITER
               || lpad(nvl(r.sttl_amount, r.oper_amount), 16, '0') || DELIMITER
               || lpad(r.oper_currency, 5, '0')             || DELIMITER
               || r.mcc                                     || DELIMITER
               || case r.oper_type
                      when 'OPTP0000' then '10'
                      when 'OPTP0028' then '31'
                      when 'OPTP0001' then '22'
                  end                                       || DELIMITER
               || to_char(r.host_date, DATE_FORMAT)         || DELIMITER
               || lpad(nvl(r.sttl_currency, r.oper_currency), 5, '0') || DELIMITER
               || lpad('0', 16, '0')                        || DELIMITER
               || lpad('0', 16, '0')                        || DELIMITER
        ;
        for i in 1 .. 54 loop -- not required fields
            l_line := l_line || DELIMITER;
        end loop;

        prc_api_file_pkg_pl(
            i_raw_data      => l_line
          , i_sess_file_id  => i_session_file_id
        );
        o_total_amount := o_total_amount + nvl(r.sttl_amount, r.oper_amount);
    end loop;
end put_t5;

procedure put_t1(
    i_inst_id                in     com_api_type_pkg.t_inst_id
  , i_company_id             in     com_api_type_pkg.t_short_id
  , i_eff_date               in     date
  , i_session_file_id        in     com_api_type_pkg.t_long_id
  , o_record_count              out com_api_type_pkg.t_short_id
) is
    l_line                          com_api_type_pkg.t_text;
begin
    o_record_count := 0;

    for r in (
        select card.cardholder_id
--             , dep_acc.account_number
             , iss_api_token_pkg.decode_card_number(i_card_number => crdn.card_number) as card_number
             , dep_acc.currency as account_currency
             , (select min(b.open_date)
                  from acc_balance b
                 where b.account_id = dep_acc.id
                   and b.balance_type = 'BLTP0001'
               ) as account_open_date
             , (select distinct first_value(i.expir_date) over (order by i.seq_number desc)
                  from iss_card_instance i
                 where i.card_id = card.id
               ) as expir_date
             , (select sum(nvl(sttl_amount, oper_amount))
                  from opr_operation   o
                  join opr_participant p    on p.oper_id = o.id
                 where (p.account_id = dep_acc.id or p.card_id = card.id)
               ) as total_oper_amount
          from crp_department     dep
          join acc_account_object dep_ao    on dep_ao.entity_type  = 'ENTTDPRT'
                                           and dep_ao.object_id    = dep.id
          join acc_account        dep_acc   on dep_acc.id          = dep_ao.account_id
          join acc_account_object card_ao   on card_ao.account_id  = dep_acc.id
                                           and card_ao.entity_type = 'ENTTCARD'
          join iss_card           card      on card.id             = card_ao.object_id
          join iss_cardholder     crdh      on crdh.id             = card.cardholder_id
          join iss_card_number    crdn      on crdn.card_id        = card.id
         where dep.corp_company_id = i_company_id
      order by dep.id
    ) loop
        l_line := '1'                                       || DELIMITER  -- Load transaction code
               || rpad(r.card_number, 19, ' ')              || DELIMITER
               || to_char(add_months(i_eff_date, 1), DATE_FORMAT) || DELIMITER -- Closing date
               || lpad('1', 5, '0')                         || DELIMITER  -- Period
               || lpad('0', 16, '0')                        || DELIMITER
               || lpad(r.total_oper_amount, 16, '0')        || DELIMITER
               || lpad('0', 16, '0')                        || DELIMITER
               || lpad('0', 16, '0')                        || DELIMITER
               || lpad('0', 5, '0')                         || DELIMITER
               || lpad('0', 16, '0')                        || DELIMITER
               || lpad('0', 16, '0')                        || DELIMITER
               || lpad(r.account_currency, 5, '0')          || DELIMITER
               || lpad('0', 16, '0')                        || DELIMITER
               || lpad('0', 16, '0')                        || DELIMITER
               || lpad('0', 16, '0')                        || DELIMITER
               || lpad('0', 16, '0')                        || DELIMITER
               || lpad('0', 16, '0')                        || DELIMITER
               || lpad('0', 16, '0')                        || DELIMITER
               || lpad('0', 16, '0')                        || DELIMITER
               || lpad('0', 5, '0')                         || DELIMITER
               || lpad('0', 5, '0')                         || DELIMITER
               || lpad('0', 5, '0')                         || DELIMITER
               || lpad('0', 5, '0')                         || DELIMITER
               || lpad('0', 5, '0')                         || DELIMITER
               || lpad('0', 5, '0')                         || DELIMITER
               || lpad('0', 5, '0')                         || DELIMITER
               || lpad('0', 5, '0')                         || DELIMITER
               || lpad('0', 16, '0')                        || DELIMITER
               || lpad('0', 8, '0')                         || DELIMITER
               || lpad('0', 8, '0')                         || DELIMITER
               || lpad('0', 16, '0')                        || DELIMITER
               || rpad(' ', 26, ' ')                        || DELIMITER -- Optional field #1
               || rpad(' ', 26, ' ')                        || DELIMITER -- Optional field #2
               || rpad(' ', 26, ' ')                        || DELIMITER -- Optional field #3
               || rpad(' ', 26, ' ')                                     -- Optional field #4
        ;
        prc_api_file_pkg_pl(
            i_raw_data      => l_line
          , i_sess_file_id  => i_session_file_id
        );
        o_record_count := o_record_count + 1;
    end loop;
end put_t1;

procedure export_data(
    i_inst_id                in     com_api_type_pkg.t_inst_id
  , i_company_id             in     com_api_type_pkg.t_short_id
) is
    l_eff_date                      date;
    l_session_file_id               com_api_type_pkg.t_long_id;
    l_param_tab                     com_api_type_pkg.t_param_tab;
    l_host_id                       com_api_type_pkg.t_tiny_id;
    l_standard_id                   com_api_type_pkg.t_tiny_id;
    l_cmid                          com_api_type_pkg.t_bin;
    l_acq_business_id               com_api_type_pkg.t_bin;
    l_record_count                  com_api_type_pkg.t_short_id;
--    l_total_amount                  com_api_type_pkg.t_money;
    l_set_record_count              com_api_type_pkg.t_short_id;
    l_set_total_amount              com_api_type_pkg.t_money;
begin
    l_eff_date    := com_api_sttl_day_pkg.get_calc_date(i_inst_id => i_inst_id);
    l_host_id     := net_api_network_pkg.get_default_host(i_network_id => vis_api_const_pkg.VISA_NETWORK_ID);
    l_standard_id := net_api_network_pkg.get_offline_standard(i_host_id => l_host_id);
    
    cmn_api_standard_pkg.get_param_value(
        i_inst_id        => i_inst_id
        , i_standard_id  => l_standard_id
        , i_object_id    => l_host_id
        , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
        , i_param_name   => vis_api_const_pkg.CMID
        , o_param_value  => l_cmid
        , i_param_tab    => l_param_tab
    );
    cmn_api_standard_pkg.get_param_value(
        i_inst_id        => i_inst_id
        , i_standard_id  => l_standard_id
        , i_object_id    => l_host_id
        , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
        , i_param_name   => vis_api_const_pkg.ACQ_BUSINESS_ID
        , o_param_value  => l_acq_business_id
        , i_param_tab    => l_param_tab
    );

--    prc_api_file_pkg.open_file(
--        o_sess_file_id   => l_session_file_id
--      , i_file_type      => vis_api_const_pkg.FILE_TYPE_VCF
--      , io_params        => l_param_tab
--    );

    for r in (
        select d.corp_company_id
          from crp_department d
         where d.inst_id = i_inst_id
    connect by parent_id = prior id
    start with (corp_company_id = i_company_id or (i_company_id is null and parent_id is null))
           and inst_id = i_inst_id
    ) loop
        l_set_record_count := 0;
        l_set_total_amount := 0;

        -- Transaction set header
        put_header(
            i_inst_id          => i_inst_id
          , i_company_id       => r.corp_company_id 
          , i_eff_date         => l_eff_date
          , i_trans_code       => '6'
          , i_record_type      => '00'
          , i_cmid             => l_cmid
          , i_acq_business_id  => l_acq_business_id
          , i_session_file_id  => l_session_file_id
        );

        -- Transaction record T6 (Company Record)
        put_header(
            i_inst_id          => i_inst_id
          , i_company_id       => r.corp_company_id 
          , i_eff_date         => l_eff_date
          , i_trans_code       => '8'
          , i_record_type      => '06'
          , i_cmid             => l_cmid
          , i_acq_business_id  => l_acq_business_id
          , i_session_file_id  => l_session_file_id
        );
        put_t6(
            i_inst_id          => i_inst_id 
          , i_company_id       => r.corp_company_id 
          , i_eff_date         => l_eff_date
          , i_session_file_id  => l_session_file_id
        );
        put_header( -- trailer
            i_inst_id          => i_inst_id
          , i_company_id       => r.corp_company_id 
          , i_eff_date         => l_eff_date
          , i_trans_code       => '9'
          , i_record_type      => '06'
          , i_cmid             => l_cmid
          , i_acq_business_id  => l_acq_business_id
          , i_record_count     => 1
          , i_session_file_id  => l_session_file_id
        );
        l_set_record_count := l_set_record_count + 1 + 2;

        -- Transaction record T10 (Hierarchy)
        put_header(
            i_inst_id          => i_inst_id
          , i_company_id       => r.corp_company_id 
          , i_eff_date         => l_eff_date
          , i_trans_code       => '8'
          , i_record_type      => '10'
          , i_cmid             => l_cmid
          , i_acq_business_id  => l_acq_business_id
          , i_session_file_id  => l_session_file_id
        );
        put_t10(
            i_inst_id          => i_inst_id 
          , i_company_id       => r.corp_company_id 
          , i_eff_date         => l_eff_date
          , i_session_file_id  => l_session_file_id
          , o_record_count     => l_record_count
        );
        put_header( -- trailer
            i_inst_id          => i_inst_id
          , i_company_id       => r.corp_company_id 
          , i_eff_date         => l_eff_date
          , i_trans_code       => '9'
          , i_record_type      => '10'
          , i_cmid             => l_cmid
          , i_acq_business_id  => l_acq_business_id
          , i_record_count     => l_record_count
          , i_session_file_id  => l_session_file_id
        );
        l_set_record_count := l_set_record_count + l_record_count + 2;

        -- Transaction record T3 (Card Account Record)
        put_header(
            i_inst_id          => i_inst_id
          , i_company_id       => r.corp_company_id 
          , i_eff_date         => l_eff_date
          , i_trans_code       => '8'
          , i_record_type      => '03'
          , i_cmid             => l_cmid
          , i_acq_business_id  => l_acq_business_id
          , i_session_file_id  => l_session_file_id
        );
        put_t3(
            i_inst_id          => i_inst_id 
          , i_company_id       => r.corp_company_id 
          , i_eff_date         => l_eff_date
          , i_session_file_id  => l_session_file_id
          , o_record_count     => l_record_count
        );
        put_header( -- trailer
            i_inst_id          => i_inst_id
          , i_company_id       => r.corp_company_id 
          , i_eff_date         => l_eff_date
          , i_trans_code       => '9'
          , i_record_type      => '03'
          , i_cmid             => l_cmid
          , i_acq_business_id  => l_acq_business_id
          , i_record_count     => l_record_count
          , i_session_file_id  => l_session_file_id
        );
        l_set_record_count := l_set_record_count + l_record_count + 2;

        -- Transaction record T4 (Cardholder Record)
        put_header(
            i_inst_id          => i_inst_id
          , i_company_id       => r.corp_company_id 
          , i_eff_date         => l_eff_date
          , i_trans_code       => '8'
          , i_record_type      => '04'
          , i_cmid             => l_cmid
          , i_acq_business_id  => l_acq_business_id
          , i_session_file_id  => l_session_file_id
        );
        put_t4(
            i_inst_id          => i_inst_id 
          , i_company_id       => r.corp_company_id 
          , i_eff_date         => l_eff_date
          , i_session_file_id  => l_session_file_id
          , o_record_count     => l_record_count
        );
        put_header( -- trailer
            i_inst_id          => i_inst_id
          , i_company_id       => r.corp_company_id 
          , i_eff_date         => l_eff_date
          , i_trans_code       => '9'
          , i_record_type      => '04'
          , i_cmid             => l_cmid
          , i_acq_business_id  => l_acq_business_id
          , i_record_count     => l_record_count
          , i_session_file_id  => l_session_file_id
        );
        l_set_record_count := l_set_record_count + l_record_count + 2;

        -- Transaction record T11 (Period record)
        put_header(
            i_inst_id          => i_inst_id
          , i_company_id       => r.corp_company_id 
          , i_eff_date         => l_eff_date
          , i_trans_code       => '8'
          , i_record_type      => '11'
          , i_cmid             => l_cmid
          , i_acq_business_id  => l_acq_business_id
          , i_session_file_id  => l_session_file_id
        );
        put_t11(
            i_inst_id          => i_inst_id 
          , i_company_id       => r.corp_company_id 
          , i_eff_date         => l_eff_date
          , i_session_file_id  => l_session_file_id
          , o_record_count     => l_record_count
        );
        put_header( -- trailer
            i_inst_id          => i_inst_id
          , i_company_id       => r.corp_company_id 
          , i_eff_date         => l_eff_date
          , i_trans_code       => '9'
          , i_record_type      => '11'
          , i_cmid             => l_cmid
          , i_acq_business_id  => l_acq_business_id
          , i_record_count     => l_record_count
          , i_session_file_id  => l_session_file_id
        );
        l_set_record_count := l_set_record_count + l_record_count + 2;

        -- Transaction record T5 (Financial record)
        put_header(
            i_inst_id          => i_inst_id
          , i_company_id       => r.corp_company_id 
          , i_eff_date         => l_eff_date
          , i_trans_code       => '8'
          , i_record_type      => '05'
          , i_cmid             => l_cmid
          , i_acq_business_id  => l_acq_business_id
          , i_session_file_id  => l_session_file_id
        );
        put_t5(
            i_inst_id          => i_inst_id 
          , i_company_id       => r.corp_company_id 
          , i_eff_date         => l_eff_date
          , i_session_file_id  => l_session_file_id
          , o_record_count     => l_record_count
          , o_total_amount     => l_set_total_amount
        );
        put_header( -- trailer
            i_inst_id          => i_inst_id
          , i_company_id       => r.corp_company_id 
          , i_eff_date         => l_eff_date
          , i_trans_code       => '9'
          , i_record_type      => '05'
          , i_cmid             => l_cmid
          , i_record_count     => l_record_count
          , i_total_amount     => l_set_total_amount
          , i_acq_business_id  => l_acq_business_id
          , i_session_file_id  => l_session_file_id
        );
        l_set_record_count := l_set_record_count + l_record_count + 2;

        -- Transaction record T1 (Financial record)
        put_header(
            i_inst_id          => i_inst_id
          , i_company_id       => r.corp_company_id 
          , i_eff_date         => l_eff_date
          , i_trans_code       => '8'
          , i_record_type      => '01'
          , i_cmid             => l_cmid
          , i_acq_business_id  => l_acq_business_id
          , i_session_file_id  => l_session_file_id
        );
        put_t1(
            i_inst_id          => i_inst_id 
          , i_company_id       => r.corp_company_id 
          , i_eff_date         => l_eff_date
          , i_session_file_id  => l_session_file_id
          , o_record_count     => l_record_count
        );
        put_header( -- trailer
            i_inst_id          => i_inst_id
          , i_company_id       => r.corp_company_id 
          , i_eff_date         => l_eff_date
          , i_trans_code       => '9'
          , i_record_type      => '01'
          , i_cmid             => l_cmid
          , i_acq_business_id  => l_acq_business_id
          , i_record_count     => l_record_count
          , i_session_file_id  => l_session_file_id
        );
        l_set_record_count := l_set_record_count + l_record_count + 2;

        -- Transaction set trailer
        put_header(
            i_inst_id          => i_inst_id
          , i_company_id       => r.corp_company_id 
          , i_eff_date         => l_eff_date
          , i_trans_code       => '7'
          , i_record_type      => '00'
          , i_cmid             => l_cmid
          , i_acq_business_id  => l_acq_business_id
          , i_record_count     => l_set_record_count
          , i_total_amount     => l_set_total_amount
          , i_session_file_id  => l_session_file_id
        );
    end loop;

--    prc_api_file_pkg.close_file(
--        i_sess_file_id   => l_session_file_id
--      , i_status         => 'FLSTACPT'
--    );
end;

end;
/
