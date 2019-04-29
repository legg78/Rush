create or replace package body mup_prc_dictionary_pkg is

procedure load_currency_rate is
    l_current_count    com_api_type_pkg.t_long_id := 0;
    l_excepted_count   com_api_type_pkg.t_long_id := 0;
    l_rejected_count   com_api_type_pkg.t_long_id := 0;
    l_file             xmltype;
    l_file_id          com_api_type_pkg.t_long_id;
begin
    savepoint mup_curr_load_start;

    trc_log_pkg.debug (
        i_text          => 'Loading of MUP currency rates is started'
    );

    prc_api_stat_pkg.log_start;

    for files in (
        select s.id as file_id
             , s.file_xml_contents
             , count(1) over() cnt
             , row_number() over(order by s.id) rn
          from prc_session_file s
             , prc_file_attribute a
             , prc_file f
         where a.id = s.file_attr_id
           and f.id = a.file_id
           and f.file_purpose = prc_api_file_pkg.get_file_purpose_in
           and s.session_id   = get_session_id
    ) loop
        savepoint mup_process_file_start;
        begin
            l_file    := files.file_xml_contents;
            l_file_id := files.file_id;

            if files.rn = 1 then
                prc_api_stat_pkg.log_estimation (
                    i_estimated_count => files.cnt
                );
            end if;

            for rec in (
                select extract(a.s, 'MIRRates/@name').getStringVal()  name
                     , extract(a.s, 'MIRRates/@currType').getStringVal() currType
                     , extract(a.s, 'MIRRates/@id').getStringVal() id
                     , extract(a.s, 'MIRRates/@appTime').getStringVal()appTime
                     , extract(a.s, 'MIRRates/@date').getStringVal() date_
                     , extract(b.column_value, 'BenchmarkCurrency/@id').getStringVal() base_curr_id
                     , extract(c.column_value, 'Currency/@id').getStringVal() curr_id
                     , extract(c.column_value, 'Currency/AlphaCode//text()').getStringVal() AlphaCode
                     , extract(c.column_value, 'Currency/Nominal//text()').getStringVal() Nominal 
                     , extract(c.column_value, 'Currency/Name//text()').getStringVal() cName
                     , extract(c.column_value, 'Currency/ValueBase//text()').getStringVal() ValueBase
                     , extract(c.column_value, 'Currency/ValueBuy//text()').getStringVal() ValueBuy
                     , extract(c.column_value, 'Currency/ValueSell//text()').getStringVal() ValueSell
                  from (select l_file s from dual) a
                     , table(XMLSequence(a.s.extract('MIRRates/BenchmarkCurrency'))) b
                     , table(XMLSequence(b.column_value.extract('BenchmarkCurrency/Currency'))) c
            ) loop
                insert into mup_currency_rate(
                    id
                  , rate_type
                  , rates_id
                  , rates_date
                  , base_curr_code
                  , curr_code
                  , curr_name
                  , nominal
                  , base_rate
                  , buy_rate
                  , sell_rate
                ) values (
                    mup_currency_rate_seq.nextval
                  , rec.currType
                  , rec.id
                  , to_date(rec.date_ || ' ' || rec.appTime, com_api_const_pkg.LOG_DATE_FORMAT)
                  , rec.base_curr_id
                  , rec.curr_id
                  , rec.AlphaCode
                  , to_number(rec.nominal,   com_api_const_pkg.XML_FLOAT_FORMAT)
                  , to_number(rec.ValueBase, com_api_const_pkg.XML_FLOAT_FORMAT)
                  , to_number(rec.ValueBuy,  com_api_const_pkg.XML_FLOAT_FORMAT)
                  , to_number(rec.ValueSell, com_api_const_pkg.XML_FLOAT_FORMAT)
                );
            end loop;
            l_current_count := l_current_count + 1;
        exception
            when com_api_error_pkg.e_application_error or dup_val_on_index then
                rollback to mup_process_file_start;

                l_rejected_count := l_rejected_count + 1;

                trc_log_pkg.warn(
                    i_text        =>  'Processing session file with id=[#1]: [#2]'
                  , i_env_param1  =>  l_file_id
                  , i_env_param2  =>  substr(sqlerrm,1,1000)
                );
        end;
        prc_api_stat_pkg.log_current (
            i_current_count       => l_current_count
          , i_excepted_count      => l_excepted_count
        );

    end loop;

    trc_log_pkg.debug (
        i_text          => 'Loading of MUP currency rates is finished, '||l_current_count||' files processed'
    );

    prc_api_stat_pkg.log_end(
        i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
      , i_processed_total  => l_current_count
      , i_excepted_total   => l_excepted_count
      , i_rejected_total   => l_rejected_count
    );

exception
    when others then
        rollback to mup_curr_load_start;
        
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
end;

end mup_prc_dictionary_pkg;
/
