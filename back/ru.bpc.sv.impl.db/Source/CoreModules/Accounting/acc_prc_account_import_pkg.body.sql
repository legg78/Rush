create or replace package body acc_prc_account_import_pkg is

procedure import_settl_acknowledgement is
    l_estimated_count       com_api_type_pkg.t_long_id := 0;
    l_processed_count       com_api_type_pkg.t_long_id := 0;
    l_excepted_count        com_api_type_pkg.t_long_id := 0;
    l_account_rec           acc_api_type_pkg.t_account_rec;
    l_inst_id               com_api_type_pkg.t_inst_id;
begin

    savepoint sp_import_settl_acknowl;

    trc_log_pkg.info(
        i_text          => 'Running Import settlement acknowledgement (container[#1])'
      , i_env_param1    => prc_api_session_pkg.get_container_id
    );

    select count(*)
      into l_estimated_count
      from prc_session_file s
         , prc_file_attribute a
         , prc_file f
         , xmltable(
               xmlnamespaces(default 'http://bpc.ru/SVXP/entry')
             , '/entries/entry'
               passing s.file_xml_contents
               columns entry_id varchar2(200) path 'entry_id'
           ) x_entry
     where s.session_id = get_session_id
       and s.file_attr_id = a.id
       and f.id = a.file_id
       and f.file_type = prd_api_const_pkg.FILE_TYPE_SETTL_ACKNOWLEDG;

    prc_api_stat_pkg.log_start;
    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_estimated_count
    );
    trc_log_pkg.debug(
        i_text => 'l_estimated_count=' || l_estimated_count
    );

    if l_estimated_count > 0 then
        select x_entry.inst_id
          into l_inst_id
          from prc_session_file s
             , prc_file_attribute a
             , prc_file f
             , xmltable(
                   xmlnamespaces(default 'http://bpc.ru/SVXP/entry')
                 , '/entries'
                   passing s.file_xml_contents
                   columns inst_id varchar2(200) path 'inst_id'
               ) x_entry
         where s.session_id = get_session_id
           and s.file_attr_id = a.id
           and f.id = a.file_id
           and f.file_type = prd_api_const_pkg.FILE_TYPE_SETTL_ACKNOWLEDG;
        for rec_entry in (
                select x_entry.entry_id
                     , (select account_number
                          from xmltable(
                                   xmlnamespaces(default 'http://bpc.ru/SVXP/entry')
                                 , '/account'
                                   passing x_entry.account
                                   columns account_number varchar2(200) path 'account_number'
                       )) xx_account_number
                     , (select currency
                          from xmltable(
                                   xmlnamespaces(default 'http://bpc.ru/SVXP/entry')
                                 , '/account'
                                   passing x_entry.account
                                   columns currency varchar2(3) path 'currency'
                       )) xx_currency
                     , to_date(sttl_flag_date, com_api_const_pkg.XML_DATETIME_FORMAT) sttl_flag_date
                  from prc_session_file s
                     , prc_file_attribute a
                     , prc_file f
                     , xmltable(
                           xmlnamespaces(default 'http://bpc.ru/SVXP/entry')
                         , '/entries/entry'
                           passing s.file_xml_contents
                           columns entry_id varchar2(200) path 'entry_id'
                                 , account  xmltype       path 'account'
                                 , sttl_flag_date   varchar2(20)  path 'sttl_flag_date'
                       ) x_entry
                 where s.session_id = get_session_id
                   and s.file_attr_id = a.id
                   and f.id = a.file_id
                   and f.file_type = prd_api_const_pkg.FILE_TYPE_SETTL_ACKNOWLEDG
        ) loop

            l_account_rec := acc_api_account_pkg.get_account(
                                 i_account_id     => null
                               , i_account_number => rec_entry.xx_account_number
                               , i_inst_id        => l_inst_id
                             );

            if l_account_rec.account_id is not null
                and rec_entry.xx_currency = l_account_rec.currency then

                acc_api_entry_pkg.set_is_settled(
                    i_entry_id       => rec_entry.entry_id
                  , i_is_settled     => com_api_const_pkg.TRUE
                  , i_inst_id        => l_account_rec.inst_id
                  , i_sttl_flag_date => rec_entry.sttl_flag_date
                  , i_split_hash     => l_account_rec.split_hash
                );

                l_processed_count := l_processed_count + 1;

            else
                trc_log_pkg.debug(
                    i_text       => 'Account[#1] is not found in inst_id[#2] with currency[#3]'
                  , i_env_param1 => rec_entry.xx_account_number
                  , i_env_param2 => l_inst_id
                  , i_env_param3 => rec_entry.xx_currency
                );

                l_excepted_count := l_excepted_count + 1;
            end if;

            if mod(l_processed_count, 100) = 0 then
                prc_api_stat_pkg.log_current(
                    i_current_count     => l_processed_count
                  , i_excepted_count    => l_excepted_count
                );
            end if;

        end loop;
    end if;

    prc_api_stat_pkg.log_end(
        i_excepted_total     => l_excepted_count
        , i_processed_total  => l_processed_count
        , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.info(
        i_text => 'Import settlement acknowledgement finished'
    );

exception
    when others then
        rollback to sp_import_settl_acknowl;
        raise;
end import_settl_acknowledgement;

end acc_prc_account_import_pkg;
/
