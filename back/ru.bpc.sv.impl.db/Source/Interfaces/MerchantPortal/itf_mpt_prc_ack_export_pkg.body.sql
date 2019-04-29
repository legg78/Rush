create or replace package body itf_mpt_prc_ack_export_pkg is

procedure export_settl_acknowledg_1_6(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_mpt_version         in     com_api_type_pkg.t_name
) as
    l_processed_count       com_api_type_pkg.t_long_id := 0;
    l_file                  clob;
    l_session_file_id       com_api_type_pkg.t_long_id;
    l_container_id          com_api_type_pkg.t_long_id;
    l_file_type             com_api_type_pkg.t_dict_value;
    CRLF           constant com_api_type_pkg.t_name := chr(13) || chr(10);
    l_params                com_api_type_pkg.t_param_tab;

    l_entries_id_tab        num_tab_tpt;

    cursor cur_export_entries_list is
        select e.id    as    event_object_id
          from acc_entry        ae
             , evt_event_object e
             , acc_account      acc
         where e.object_id = ae.id
           and decode(e.status, 'EVST0001', e.procedure_name, null) = 'ITF_MPT_PRC_ACK_EXPORT_PKG.EXPORT_SETTL_ACKNOWLEDGEMENT'
           and e.split_hash in (select split_hash from com_api_split_map_vw)
           and e.entity_type = acc_api_const_pkg.ENTITY_TYPE_ENTRY
           and acc.id = ae.account_id
           and acc.inst_id = i_inst_id;

    cursor cur_export_entries_xml is
        select 
            xmlelement(
                "entries"
              , xmlattributes('http://sv.bpc.in/SVXP/entries' as "xmlns")
              , xmlelement("file_type" , l_file_type)
              , xmlelement("inst_id"   , i_inst_id)
              , xmlagg(
                    xmlelement(
                        "entry"
                      , xmlelement("entry_id", ae.id)
                      , xmlelement(
                            "account"
                          , xmlelement("account_number", acc.account_number)
                          , xmlelement("currency"      , acc.currency)
                        )
                      , xmlelement(
                            "amount"
                          , xmlelement("amount_value", ae.amount)
                          , xmlelement("currency"    , ae.currency)
                        )
                      , xmlelement("is_settled", ae.is_settled)
                      , case
                            when i_mpt_version >= '1.7'
                                then xmlelement("sttl_flag_date", to_char(ae.sttl_flag_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                            else null
                        end
                    ))).getclobval()
             , count(ae.id) count_entries
          from acc_entry        ae
             , evt_event_object e
             , acc_account      acc
         where e.object_id = ae.id
           and e.id in (select column_value from table(cast(l_entries_id_tab as num_tab_tpt)))
           and acc.id = ae.account_id
           and acc.inst_id = i_inst_id;

begin
    savepoint sp_export_settl_acknowledg;

    prc_api_stat_pkg.log_start;

    l_container_id      := prc_api_session_pkg.get_container_id;

    select min(file_type)
      into l_file_type
      from prc_file_attribute a
         , prc_file f
     where a.container_id = l_container_id
       and a.file_id      = f.id
       and file_purpose   = prc_api_const_pkg.FILE_PURPOSE_OUT;

    open cur_export_entries_list;
    fetch cur_export_entries_list bulk collect into l_entries_id_tab;
    close cur_export_entries_list;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_entries_id_tab.count
    );

    if l_entries_id_tab.count > 0 then

        rul_api_param_pkg.set_param (
            i_name          => 'INST_ID'
          , i_value         => i_inst_id
          , io_params       => l_params
        );

        open cur_export_entries_xml;
        fetch cur_export_entries_xml into l_file
                                        , l_processed_count;
        close cur_export_entries_xml;

        l_file := com_api_const_pkg.XML_HEADER || CRLF || l_file;

        prc_api_file_pkg.open_file(
            o_sess_file_id          => l_session_file_id
          , i_file_type             => l_file_type
          , i_file_purpose          => prc_api_const_pkg.FILE_PURPOSE_OUT
          , io_params               => l_params
        );

        prc_api_file_pkg.put_file(
            i_sess_file_id   => l_session_file_id
          , i_clob_content   => l_file
        );

        prc_api_file_pkg.close_file(
            i_sess_file_id   => l_session_file_id
          , i_status         => prc_api_const_pkg.FILE_STATUS_ACCEPTED
          , i_record_count   => l_processed_count 
        );

        trc_log_pkg.debug(
            i_text           => 'file saved, cnt=[#1], length=[#2]'
          , i_env_param1     => l_processed_count
          , i_env_param2     => length(l_file)
        );

        evt_api_event_pkg.process_event_object(
            i_event_object_id_tab => l_entries_id_tab
        );

    else
        trc_log_pkg.debug(i_text => 'file NOT saved, cnt=[0], length=[0]');
    end if;

    prc_api_stat_pkg.log_end(
        i_excepted_total     => 0
      , i_processed_total    => l_processed_count
      , i_result_code        => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code    => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        rollback to sp_export_settl_acknowledg;
        raise;

end export_settl_acknowledg_1_6;

procedure export_settl_acknowledgement(
    i_mpt_version         in     com_api_type_pkg.t_name
,   i_inst_id             in     com_api_type_pkg.t_inst_id
)
  as
begin

    trc_log_pkg.info(
        i_text          => 'Running Import settlement acknowledgement (container[#2]). i_mpt_version[#2], inst_id[#3]'
      , i_env_param1    => prc_api_session_pkg.get_container_id
      , i_env_param2    => i_mpt_version
      , i_env_param3    => i_inst_id
    );

    if i_mpt_version >= '1.6' then
        export_settl_acknowledg_1_6(
            i_inst_id    => i_inst_id
          , i_mpt_version => i_mpt_version
        );

    else
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'VERSION_IS_NOT_SUPPORTED'
          , i_env_param1 => i_mpt_version
        );
    end if;

    trc_log_pkg.info(
        i_text => 'Export settlement acknowledgement to Merchant Portal finished'
    );
end export_settl_acknowledgement;

end itf_mpt_prc_ack_export_pkg;
/
