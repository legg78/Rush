create or replace package body cst_tym_api_collection_pkg is
/*********************************************************
 *  Custom accounts in collection export API <br />
 *  Created by Gerbeev I.(gerbeevbpcbt.com)  at 15.06.2018 <br />
 *  Last changed by $Author: gerbeev $ <br />
 *  $LastChangedDate:: 2018-06-15 12:00:00 +0400#$ <br />
 *  Revision: $LastChangedRevision: 00000 $ <br />
 *  Module: cst_tym_api_collection_pkg <br />
 *  @headcom
 **********************************************************/

CRLF                     constant com_api_type_pkg.t_name       := chr(13)||chr(10);
BULK_LIMIT               constant integer := 1000;

procedure export_accounts(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_ids_type          in      com_api_type_pkg.t_dict_value
  , i_account_type      in      com_api_type_pkg.t_dict_value   default acc_api_const_pkg.ACCOUNT_TYPE_CREDIT
  , i_account_status    in      com_api_type_pkg.t_dict_value   default null
  , i_min_aging_period  in      com_api_type_pkg.t_short_id     default null
)
is
    l_ref_cursor                com_api_type_pkg.t_ref_cur;
    l_eff_date                  date;
    l_acc_in_collection_tab     crd_api_type_pkg.t_acc_in_collection_tab;
    l_sess_file_id              com_api_type_pkg.t_long_id;
    l_clob                      clob;
    l_file                      clob;
    l_estimated_count           com_api_type_pkg.t_long_id    := 0;
    l_processed_count           com_api_type_pkg.t_long_id    := 0;
    l_excepted_count            com_api_type_pkg.t_long_id    := 0;
begin
    savepoint sp_export_accounts;

    l_eff_date :=
        com_api_sttl_day_pkg.get_calc_date(
            i_inst_id => i_inst_id
        );

    trc_log_pkg.debug(
        i_text              => 'Accounts in collection export started. i_inst_id [#1], i_id_type [#2], i_account_type [#3], i_account_status [#4], i_min_aging_period [#5], l_eff_date [#6]'
      , i_env_param1        => i_inst_id
      , i_env_param2        => i_ids_type
      , i_env_param3        => i_account_type
      , i_env_param4        => i_account_status
      , i_env_param5        => i_min_aging_period
      , i_env_param6        => to_char(l_eff_date, com_api_const_pkg.LOG_DATE_FORMAT)
    );

    prc_api_stat_pkg.log_start;

    crd_api_external_pkg.accounts_in_collection(
        i_inst_id           => i_inst_id
      , i_ids_type          => i_ids_type
      , i_account_type      => i_account_type
      , i_account_status    => i_account_status
      , i_min_aging_period  => i_min_aging_period
      , i_eff_date          => l_eff_date
      , o_ref_cursor        => l_ref_cursor
    );

    loop
        fetch l_ref_cursor bulk collect
         into l_acc_in_collection_tab
        limit BULK_LIMIT;

        l_estimated_count   := l_estimated_count + l_acc_in_collection_tab.count;

        prc_api_stat_pkg.log_estimation(
            i_estimated_count   => l_estimated_count
        );

        for i in 1..l_acc_in_collection_tab.count loop

            l_clob := 
                l_clob ||
                CRLF || '<account_id>' || to_char(l_acc_in_collection_tab(i).account_id, com_api_const_pkg.XML_NUMBER_FORMAT) || '</account_id>'
             || CRLF || '<account_number>' || l_acc_in_collection_tab(i).account_number || '</account_number>'
             || CRLF || '<account_type>' || l_acc_in_collection_tab(i).account_type || '</account_type>'
             || CRLF || '<account_currency>' || l_acc_in_collection_tab(i).account_currency || '</account_currency>'
             || CRLF || '<account_status>' || l_acc_in_collection_tab(i).account_status || '</account_status>'
             || CRLF || '<card_mask>' || l_acc_in_collection_tab(i).card_mask || '</card_mask>'
             || CRLF || '<agent_id>' || to_char(l_acc_in_collection_tab(i).agent_id, com_api_const_pkg.XML_NUMBER_FORMAT) || '</agent_id>'
             || CRLF || '<agent_name>' || l_acc_in_collection_tab(i).agent_name || '</agent_name>'
             || CRLF || '<card_expire_date>' || to_char(l_acc_in_collection_tab(i).card_expire_date, com_api_const_pkg.XML_DATETIME_FORMAT) || '</card_expire_date>'
             || CRLF || '<aging_period>' || to_char(l_acc_in_collection_tab(i).aging_period, com_api_const_pkg.XML_NUMBER_FORMAT) || '</aging_period>'
             || CRLF || '<total_outstanding_value>' || to_char(l_acc_in_collection_tab(i).total_outstanding_value, com_api_const_pkg.XML_NUMBER_FORMAT) || '</total_outstanding_value>'
             || CRLF || '<min_amount_due>' || to_char(l_acc_in_collection_tab(i).min_amount_due, com_api_const_pkg.XML_NUMBER_FORMAT) || '</min_amount_due>'
             || CRLF || '<customer_category>' || l_acc_in_collection_tab(i).customer_category || '</customer_category>'
             || CRLF || '<customer_relation>' || l_acc_in_collection_tab(i).customer_relation || '</customer_relation>'
             || CRLF || '<contract_type>' || l_acc_in_collection_tab(i).contract_type || '</contract_type>'
             || CRLF || '<contract_number>' || l_acc_in_collection_tab(i).contract_number || '</contract_number>'
             || CRLF || '<surname>' || l_acc_in_collection_tab(i).surname || '</surname>'
             || CRLF || '<first_name>' || l_acc_in_collection_tab(i).first_name || '</first_name>'
             || CRLF || '<second_name>' || l_acc_in_collection_tab(i).second_name || '</second_name>'
             || CRLF || '<id_type>' || l_acc_in_collection_tab(i).id_type || '</id_type>'
             || CRLF || '<id_series>' || l_acc_in_collection_tab(i).id_series || '</id_series>'
             || CRLF || '<id_number>' || l_acc_in_collection_tab(i).id_number || '</id_number>'
             || CRLF || '<contact_type>' || l_acc_in_collection_tab(i).contact_type || '</contact_type>'
             || CRLF || '<preferred_lang>' || l_acc_in_collection_tab(i).preferred_lang || '</preferred_lang>'
             || CRLF || '<commun_method>' || l_acc_in_collection_tab(i).commun_method || '</commun_method>'
             || CRLF || '<commun_address>' || l_acc_in_collection_tab(i).commun_address || '</commun_address>'
             || CRLF || '<address_type>' || l_acc_in_collection_tab(i).address_type || '</address_type>'
             || CRLF || '<address_country>' || l_acc_in_collection_tab(i).address_country || '</address_country>'
             || CRLF || '<address_region>' || l_acc_in_collection_tab(i).address_region || '</address_region>'
             || CRLF || '<address_city>' || l_acc_in_collection_tab(i).address_city || '</address_city>'
             || CRLF || '<address_street>' || l_acc_in_collection_tab(i).address_street || '</address_street>'
             || CRLF || '<address_house>' || l_acc_in_collection_tab(i).address_house || '</address_house>'
             || CRLF || '<address_apartment>' || l_acc_in_collection_tab(i).address_apartment || '</address_apartment>';

            l_processed_count := l_processed_count + 1;
        end loop;

        prc_api_stat_pkg.log_current(
            i_current_count   => l_processed_count
          , i_excepted_count  => 0
        );

        exit when l_ref_cursor%notfound;
    end loop;

    close l_ref_cursor;

    if l_estimated_count != 0 then
        prc_api_file_pkg.open_file(
            o_sess_file_id  => l_sess_file_id
          , i_file_purpose  => prc_api_const_pkg.FILE_PURPOSE_OUT
        );

        l_file := com_api_const_pkg.XML_HEADER || CRLF || '<accounts>' || l_clob || CRLF || '</accounts>';

        prc_api_file_pkg.put_file(
            i_sess_file_id  => l_sess_file_id
          , i_clob_content  => l_file
        );

        trc_log_pkg.debug(
            i_text          => 'l_sess_file_id [#1], file length [#2], records exported [#3]'
          , i_env_param1    => l_sess_file_id
          , i_env_param2    => length(l_file)
          , i_env_param3    => l_estimated_count
        );

        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_sess_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
          , i_record_count  => l_estimated_count
        );
    end if;

    prc_api_stat_pkg.log_end(
        i_excepted_total     => l_excepted_count
        , i_processed_total  => l_processed_count
        , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(
        i_text      => 'Accounts in collection export has been finished.'
    );

exception
    when others then
        rollback to sp_export_accounts;

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

end export_accounts;

end cst_tym_api_collection_pkg;
/
