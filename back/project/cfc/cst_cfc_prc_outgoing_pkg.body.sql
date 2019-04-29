create or replace package body cst_cfc_prc_outgoing_pkg is
/*********************************************************
 *  Processes for data export <br />
 *  Created by Fomichev A.(fomichev@bpcbt.com)  at 22.11.2017 <br />
 *  Module: CST_CFC_PRC_OUTGOING_PKG  <br />
 *  @headcom
 **********************************************************/
CRLF                             constant com_api_type_pkg.t_name     := chr(13)||chr(10);
BULK_LIMIT                       constant com_api_type_pkg.t_count    := 1000;
DELIMETER                        constant com_api_type_pkg.t_name     := '|';
COMMA_DELIMETER                  constant com_api_type_pkg.t_name     := ',';

procedure add_objects_in_tab(
    i_inst_id                      in     com_api_type_pkg.t_inst_id
  , i_entity_type                  in     com_api_type_pkg.t_dict_value
  , i_proc_name                    in     com_api_type_pkg.t_name
  , i_sysdate                      in     date
  , io_event_object_tab            in out cst_cfc_api_type_pkg.t_entity_tab
  , io_entity_tab                  in out com_api_type_pkg.t_dict_tab
) is
begin
    for rec in (select o.id as event_id
                     , o.entity_type
                     , o.object_id
                  from evt_event_object o
                     , evt_event e
                     , evt_subscriber s
                 where decode(o.status, 'EVST0001', o.procedure_name, null) = i_proc_name
                   and o.eff_date      <= i_sysdate
                   and o.inst_id        = i_inst_id
                   and o.entity_type    = i_entity_type
                   and e.id             = o.event_id
                   and e.event_type     = s.event_type
                   and o.procedure_name = s.procedure_name
                 order by
                       o.id
    ) loop
        if io_event_object_tab.count = 0 then
            io_event_object_tab(rec.entity_type).object_id(1) := rec.object_id;
            io_event_object_tab(rec.entity_type).event_id(rec.object_id)(1) := rec.event_id;
            if io_entity_tab.exists(1) then
                io_entity_tab.delete;
            end if;
            io_entity_tab(1) := rec.entity_type;
        else
            if io_event_object_tab.exists(rec.entity_type) then
                if io_event_object_tab(rec.entity_type).event_id.exists(rec.object_id) then
                    io_event_object_tab(rec.entity_type).event_id(rec.object_id)(io_event_object_tab(rec.entity_type).event_id(rec.object_id).last + 1) := rec.event_id;
                else
                    io_event_object_tab(rec.entity_type).object_id(io_event_object_tab(rec.entity_type).object_id.last + 1) := rec.object_id;
                    io_event_object_tab(rec.entity_type).event_id(rec.object_id)(1) := rec.event_id;
                end if;
            else
                io_event_object_tab(rec.entity_type).object_id(1)   := rec.object_id;
                io_event_object_tab(rec.entity_type).event_id(rec.object_id)(1) := rec.event_id;
                io_entity_tab(io_entity_tab.last + 1) := rec.entity_type;
            end if;
        end if;
    end loop;
end add_objects_in_tab;

function check_add_acc_data_result_line(
    i_entity_type                  in     com_api_type_pkg.t_dict_value
  , i_accounts_data_rec            in     acc_api_type_pkg.t_active_account_ext_rec
  , i_event_object_tab             in     cst_cfc_api_type_pkg.t_entity_tab
) return com_api_type_pkg.t_boolean
is
begin

    return case
               when (i_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                     and i_event_object_tab(i_entity_type).event_id.exists(i_accounts_data_rec.account_id)
                    )
                   then com_api_const_pkg.TRUE
               else
                   com_api_const_pkg.FALSE
           end;
end check_add_acc_data_result_line;

procedure clear_check_data(
    i_entity_type                  in     com_api_type_pkg.t_dict_value
  , i_index_element                in     com_api_type_pkg.t_long_id
  , io_event_object_tab            in out cst_cfc_api_type_pkg.t_entity_tab
)
is
begin
    if io_event_object_tab(i_entity_type).event_id.exists(i_index_element) then
        io_event_object_tab(i_entity_type).event_id.delete(i_index_element);
    end if;
end clear_check_data;

procedure add_acc_data_event_collection(
    i_index                        in     com_api_type_pkg.t_long_id
  , i_entity_tab                   in     com_api_type_pkg.t_dict_tab
  , i_accounts_data_rec            in     acc_api_type_pkg.t_active_account_ext_rec
  , io_event_object_tab            in out cst_cfc_api_type_pkg.t_entity_tab
  , io_event_tab                   in out com_api_type_pkg.t_number_tab
)
is
begin
    for i in i_index .. i_entity_tab.last
    loop
        if i_entity_tab(i) = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
            and io_event_object_tab(i_entity_tab(i)).event_id.exists(i_accounts_data_rec.account_id)
        then
            for n in 1 .. io_event_object_tab(i_entity_tab(i)).event_id(i_accounts_data_rec.account_id).last
            loop
                if io_event_tab.exists(1) then
                    io_event_tab(io_event_tab.last + 1) := io_event_object_tab(i_entity_tab(i)).event_id(i_accounts_data_rec.account_id)(n);
                else
                    io_event_tab(1) := io_event_object_tab(i_entity_tab(i)).event_id(i_accounts_data_rec.account_id)(n);
                end if;
            end loop;
            clear_check_data(
                i_entity_type        => i_entity_tab(i)
              , i_index_element      => i_accounts_data_rec.account_id
              , io_event_object_tab  => io_event_object_tab
            );
        end if;
    end loop;
end add_acc_data_event_collection;

procedure add_not_used_event_collection(
    i_entity_tab                   in     com_api_type_pkg.t_dict_tab
  , io_event_object_tab            in out cst_cfc_api_type_pkg.t_entity_tab
  , io_event_tab                   in out com_api_type_pkg.t_number_tab
)
is
begin
    if i_entity_tab.exists(1) then
        for i in i_entity_tab.first .. i_entity_tab.last
        loop
            if io_event_object_tab.exists(i_entity_tab(i)) then
                if io_event_object_tab(i_entity_tab(i)).object_id.exists(1) then
                    for j in io_event_object_tab(i_entity_tab(i)).object_id.first .. io_event_object_tab(i_entity_tab(i)).object_id.last
                    loop
                        if io_event_object_tab(i_entity_tab(i)).event_id.exists(io_event_object_tab(i_entity_tab(i)).object_id(j))
                        then
                            for k in 1 .. io_event_object_tab(i_entity_tab(i)).event_id(io_event_object_tab(i_entity_tab(i)).object_id(j)).last
                            loop
                                if io_event_tab.exists(1) then
                                    io_event_tab(io_event_tab.last + 1) := io_event_object_tab(i_entity_tab(i)).event_id(io_event_object_tab(i_entity_tab(i)).object_id(j))(k);
                                else
                                    io_event_tab(1) := io_event_object_tab(i_entity_tab(i)).event_id(io_event_object_tab(i_entity_tab(i)).object_id(j))(k);
                                end if;
                            end loop;
                        end if;
                    end loop;
                end if;
            end if;
        end loop;
    end if;
end add_not_used_event_collection;

procedure process_unload_gl_acc_numbers(
    i_inst_id                      in     com_api_type_pkg.t_inst_id
  , i_lang                         in     com_api_type_pkg.t_dict_value
) is
    l_sysdate           date;
    l_estimated_count   com_api_type_pkg.t_long_id := 0;
    l_gl_acc_tab        acc_api_type_pkg.t_gl_account_numbers_ext_tab;
    l_sess_file_id      com_api_type_pkg.t_long_id;
    l_line              com_api_type_pkg.t_raw_data;
    l_lang              com_api_type_pkg.t_dict_value;
    l_bucket            com_api_type_pkg.t_tiny_id;
    l_due               com_api_type_pkg.t_name;
    l_params            com_api_type_pkg.t_param_tab;
    l_start_date        date;
    l_end_date          date;
begin
    savepoint sp_gl_acc_export;

    l_sysdate    := com_api_sttl_day_pkg.get_sysdate();
    l_lang       := nvl(i_lang, com_api_const_pkg.DEFAULT_LANGUAGE);
    l_start_date := trunc(com_api_sttl_day_pkg.get_sysdate);
    l_end_date   := l_start_date + 1 - com_api_const_pkg.ONE_SECOND;

    trc_log_pkg.debug('Start unloading of GL account numbers: sysdate=[' || l_sysdate ||
                      '] thread_number=[' || get_thread_number || ']');

    prc_api_stat_pkg.log_start;

    acc_api_external_pkg.get_gl_account_numbers_data(
        i_inst_id    => i_inst_id
      , i_start_date => l_start_date
      , i_end_date   => l_end_date
      , o_row_count  => l_estimated_count
      , o_gl_acc_tab => l_gl_acc_tab
    );

    trc_log_pkg.debug(
        i_text       => 'Estimate count = [#1]'
      , i_env_param1 => l_estimated_count
    );

    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_estimated_count
    );

    rul_api_param_pkg.set_param(
        i_name          => 'INST_ID'
      , i_value         => i_inst_id
      , io_params       => l_params
    );

    rul_api_param_pkg.set_param(
        i_name          => 'START_DATE'
      , i_value         => l_start_date
      , io_params       => l_params
    );

    rul_api_param_pkg.set_param(
        i_name          => 'END_DATE'
      , i_value         => l_end_date
      , io_params       => l_params
    );

    prc_api_file_pkg.open_file(
        o_sess_file_id => l_sess_file_id
      , i_file_purpose => prc_api_const_pkg.FILE_PURPOSE_OUT
      , io_params      => l_params
    );

    prc_api_file_pkg.put_line(
        i_sess_file_id => l_sess_file_id
      , i_raw_data     => cst_cfc_api_const_pkg.GL_ACC_NUM_DETAIL_FILE_HEADER
    );

    for i in 1..l_gl_acc_tab.count loop

        l_bucket :=
            case when l_end_date - l_gl_acc_tab(i).overdue_date <= 9
                  and nvl(l_gl_acc_tab(i).aging, 0) > 0 then 1
                 when l_end_date - l_gl_acc_tab(i).overdue_date <= 90
                  and nvl(l_gl_acc_tab(i).aging, 0) > 0 then 2
                 when l_end_date - l_gl_acc_tab(i).overdue_date <= 180
                  and nvl(l_gl_acc_tab(i).aging, 0) > 0 then 3
                 when l_end_date - l_gl_acc_tab(i).overdue_date <= 360
                  and nvl(l_gl_acc_tab(i).aging, 0) > 0 then 4
                 when l_end_date - l_gl_acc_tab(i).overdue_date > 360
                  and nvl(l_gl_acc_tab(i).aging, 0) > 0 then 5
                 else 1
                 end;
        l_due := case when nvl(l_gl_acc_tab(i).aging, 0) > 0 then 'Overdue' else 'Indue' end;

        l_gl_acc_tab(i).oper_date :=
            case
                when l_gl_acc_tab(i).gl_account_type in ('ACTPG307', 'ACTPG306', 'ACTPG305',
                    'ACTPG304', 'ACTPG303', 'ACTPG302', 'ACTPG207') then
                    cst_cfc_com_pkg.get_cycle_prev_date(
                        i_start_date        => l_gl_acc_tab(i).posting_date
                      , i_inst_id           => i_inst_id
                      , i_cycle_type        => crd_api_const_pkg.PERIODIC_INTEREST_CHARGE
                    )
                else
                    l_gl_acc_tab(i).oper_date
            end;

        l_line := l_gl_acc_tab(i).account_number                                      || DELIMETER -- Acount Number
               || l_gl_acc_tab(i).card_mask                                           || DELIMETER -- Card Number (masked)
               || l_gl_acc_tab(i).national_id                                         || DELIMETER -- National ID
               || substr(l_gl_acc_tab(i).gl_account_number, 1, 4)                     || DELIMETER -- GL Account
               || get_article_text(l_gl_acc_tab(i).gl_account_type, l_lang)           || DELIMETER -- Name of Accounting moves
               || to_char(l_gl_acc_tab(i).oper_date, 'dd.mm.yyyy')                    || DELIMETER -- Transaction Date
               || to_char(l_gl_acc_tab(i).posting_date, 'dd.mm.yyyy')                 || DELIMETER -- Posting Date
               || to_char(l_gl_acc_tab(i).amount, com_api_const_pkg.XML_FLOAT_FORMAT) || DELIMETER -- Amount
               || to_char(l_bucket, com_api_const_pkg.XML_NUMBER_FORMAT)              || DELIMETER -- Bucket
               || l_due -- Indue/Overdue
        ;

        prc_api_file_pkg.put_line(
            i_sess_file_id => l_sess_file_id
          , i_raw_data     => l_line
        );

    end loop;

    prc_api_file_pkg.close_file (
        i_sess_file_id  => l_sess_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_estimated_count
      , i_excepted_total    => 0
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug('Finish unloading of GL account numbers');
exception
    when others then
        rollback to sp_gl_acc_export;
        prc_api_stat_pkg.log_end(
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

end process_unload_gl_acc_numbers;

procedure process_unload_acc_gl_data(
    i_inst_id                      in     com_api_type_pkg.t_inst_id
  , i_full_export                  in     com_api_type_pkg.t_boolean          default com_api_type_pkg.FALSE
  , i_date_type                    in     com_api_type_pkg.t_dict_value
  , i_start_date                   in     date                                default null
  , i_end_date                     in     date                                default null
  , i_account_number               in     com_api_type_pkg.t_account_number   default null
  , i_array_link_account_numbers   in     com_api_type_pkg.t_medium_id        default null
  , i_separate_char                in     com_api_type_pkg.t_byte_char
) is
    PROC_NAME                constant     com_api_type_pkg.t_name := $$PLSQL_UNIT || '.PROCESS_UNLOAD_ACC_GL_DATA';
    LOG_PREFIX               constant     com_api_type_pkg.t_name := lower(PROC_NAME) || ': ';

    l_event_object_tab                    cst_cfc_api_type_pkg.t_entity_tab;

    l_event_tab                           com_api_type_pkg.t_number_tab;
    l_entity_tab                          com_api_type_pkg.t_dict_tab;
    l_accounts_data_unloading             com_api_type_pkg.t_number_tab;

    l_param_tab                           com_api_type_pkg.t_param_tab;
    l_account_id_tab                      num_tab_tpt := num_tab_tpt();

    l_accounts_data_tab                   acc_api_type_pkg.t_active_account_ext_tab;
    l_gl_balance_data_tab                 acc_api_type_pkg.t_link_account_balance_ext_tab;

    l_session_file_id                     com_api_type_pkg.t_long_id;

    l_estimated_count                     com_api_type_pkg.t_long_id    := 0;
    l_processed_count                     com_api_type_pkg.t_long_id    := 0;
    l_excepted_count                      com_api_type_pkg.t_long_id    := 0;
    l_rejected_count                      com_api_type_pkg.t_long_id    := 0;

    l_ref_cursor                          com_api_type_pkg.t_ref_cur;
    l_ref_cursor_2                        com_api_type_pkg.t_ref_cur;

    l_object_tab                          com_api_type_pkg.t_object_tab;
    l_sysdate                             date;
    l_start_date                          date;
    l_end_date                            date;
    l_type_of_date_range                  com_api_type_pkg.t_dict_value;

    l_request_count                       com_api_type_pkg.t_short_id;
    l_full_export                         com_api_type_pkg.t_boolean;
    l_account_id                          com_api_type_pkg.t_account_id;

    function get_number_tab_by_name_val(
        i_num_tab_by_name  in  com_api_type_pkg.t_number_by_name_tab
      , i_name             in  com_api_type_pkg.t_oracle_name
      , i_val_for_def      in  com_api_type_pkg.t_money
    ) return com_api_type_pkg.t_money
    is
        l_result   com_api_type_pkg.t_money;
    begin
        if i_num_tab_by_name.count > 0 and i_name is not null then
            if i_num_tab_by_name.exists(i_name) then
                l_result := i_num_tab_by_name(i_name);
            end if;
        end if;
        return nvl(l_result, i_val_for_def);
    end get_number_tab_by_name_val;

    procedure put_record_to_file(
        i_raw_data             in  com_api_type_pkg.t_raw_data                      default null
      , i_accounts_data_rec    in  acc_api_type_pkg.t_active_account_ext_rec
      , i_gl_balance_data_tab  in  acc_api_type_pkg.t_link_account_balance_ext_tab
      , i_session_file_id      in  com_api_type_pkg.t_long_id
    ) is
        l_gl_balance_tab       com_api_type_pkg.t_number_by_name_tab;
        l_separate_char        com_api_type_pkg.t_byte_char := nvl(i_separate_char, DELIMETER);
        l_record               com_api_type_pkg.t_text;
        l_var_money            com_api_type_pkg.t_money;
        l_day_past_due         com_api_type_pkg.t_long_id;
        l_revised_bucket       com_api_type_pkg.t_byte_char;
        l_revised_bucket_n     com_api_type_pkg.t_tiny_id;
    begin
        if i_raw_data is null then
            if l_gl_balance_tab.count > 0 then
                l_gl_balance_tab.delete;
            end if;

            if i_gl_balance_data_tab.count > 0 then
                for i in i_gl_balance_data_tab.first .. i_gl_balance_data_tab.last
                loop
                    l_gl_balance_tab(i_gl_balance_data_tab(i).link_account_number) := i_gl_balance_data_tab(i).balance_amount;
                end loop;
            end if;

            -- Calculate columns
            l_day_past_due := greatest(0, nvl(trunc(l_end_date - cst_cfc_com_pkg.get_first_overdue_date(
                                                                     i_account_id  => i_accounts_data_rec.account_id
                                                                   , i_split_hash  => i_accounts_data_rec.split_hash
                                                                 )
                                                   ), 0));
            -- Generate file line
            l_record := i_accounts_data_rec.account_number
                     || l_separate_char
            ;
            l_record := l_record
                     || i_accounts_data_rec.card_mask
                     || l_separate_char
            ;
            l_record := l_record
                     || i_accounts_data_rec.national_id
                     || l_separate_char
            ;
            l_record := l_record
                     || i_accounts_data_rec.product_number
                     || l_separate_char
            ;
            l_record := l_record
                     || 'Medium term'
                     || l_separate_char
            ;
            l_record := l_record
                     || case
                            when nvl(i_accounts_data_rec.aging, 0) = 0
                                then 'Indue'
                            else 'Overdue'
                        end
                     || l_separate_char
            ;
            l_record := l_record
                     || case
                            when nvl(i_accounts_data_rec.aging, 0) between 0 and 1
                                then '1 '
                            when nvl(i_accounts_data_rec.aging, 0) between 2 and 4
                                then '2 '
                            when nvl(i_accounts_data_rec.aging, 0) between 5 and 7
                                then '3 '
                            when nvl(i_accounts_data_rec.aging, 0) = 8
                                then '4 '
                            else '5 '
                        end
                     || l_separate_char
            ;
            l_record := l_record
                     || to_char(l_day_past_due)
                     || l_separate_char
            ;
            l_record := l_record
                     || to_char(
                            itf_ui_integration_pkg.get_percent_rate(
                                i_account_id => i_accounts_data_rec.account_id
                              , i_product_id => i_accounts_data_rec.product_id
                              , i_split_hash => i_accounts_data_rec.split_hash
                              , i_fee_type   => crd_api_const_pkg.INTEREST_RATE_FEE_TYPE
                            )
                          , crd_api_const_pkg.NUMBER_FORMAT
                        )
                     || l_separate_char
            ;
            l_var_money :=  get_number_tab_by_name_val(
                                i_num_tab_by_name  => l_gl_balance_tab
                              , i_name             => '201'
                              , i_val_for_def      => 0
                            )
                            -
                            get_number_tab_by_name_val(
                                i_num_tab_by_name  => l_gl_balance_tab
                              , i_name             => '401'
                              , i_val_for_def      => 0
                            )
            ;
            l_record := l_record
                     || to_char(
                            l_var_money
                          , crd_api_const_pkg.NUMBER_FORMAT
                        )
                     || l_separate_char
            ;
            l_record := l_record
                     || to_char(
                            case
                                when nvl(i_accounts_data_rec.aging, 0) <= 8
                                    then l_var_money * 0.75 * com_api_const_pkg.ONE_PERCENT
                                else 0
                            end
                          , crd_api_const_pkg.NUMBER_FORMAT
                        )
                     || l_separate_char
            ;
            l_record := l_record
                     || to_char(
                            case
                                when nvl(i_accounts_data_rec.aging, 0) between 0 and 1
                                    then 0
                                when nvl(i_accounts_data_rec.aging, 0) between 2 and 4
                                    then l_var_money * 5 * com_api_const_pkg.ONE_PERCENT
                                when nvl(i_accounts_data_rec.aging, 0) between 5 and 7
                                    then l_var_money * 20 * com_api_const_pkg.ONE_PERCENT
                                when nvl(i_accounts_data_rec.aging, 0) = 8
                                    then l_var_money * 50 * com_api_const_pkg.ONE_PERCENT
                                else l_var_money * 100 * com_api_const_pkg.ONE_PERCENT
                            end
                          , crd_api_const_pkg.NUMBER_FORMAT
                        )
                     || l_separate_char
            ;
            l_record := l_record
                     || to_char(
                            get_number_tab_by_name_val(
                                i_num_tab_by_name  => l_gl_balance_tab
                              , i_name             => '302'
                              , i_val_for_def      => 0
                            )
                            +
                            get_number_tab_by_name_val(
                                i_num_tab_by_name  => l_gl_balance_tab
                              , i_name             => '303'
                              , i_val_for_def      => 0
                            )
                            -
                            get_number_tab_by_name_val(
                                i_num_tab_by_name  => l_gl_balance_tab
                              , i_name             => '402'
                              , i_val_for_def      => 0
                            )
                            -
                            get_number_tab_by_name_val(
                                i_num_tab_by_name  => l_gl_balance_tab
                              , i_name             => '403'
                              , i_val_for_def      => 0
                            )
                          , crd_api_const_pkg.NUMBER_FORMAT
                        )
                     || l_separate_char
            ;
            l_record := l_record
                     || to_char(
                            get_number_tab_by_name_val(
                                i_num_tab_by_name  => l_gl_balance_tab
                              , i_name             => '101'
                              , i_val_for_def      => 0
                            )
                          , crd_api_const_pkg.NUMBER_FORMAT
                        )
                     || l_separate_char
            ;
            l_record := l_record
                     || to_char(
                            get_number_tab_by_name_val(
                                i_num_tab_by_name  => l_gl_balance_tab
                              , i_name             => '103'
                              , i_val_for_def      => 0
                            )
                          , crd_api_const_pkg.NUMBER_FORMAT
                        )
                     || l_separate_char
            ;
            l_record := l_record
                     || to_char(
                            get_number_tab_by_name_val(
                                i_num_tab_by_name  => l_gl_balance_tab
                              , i_name             => '204'
                              , i_val_for_def      => 0
                            )
                          , crd_api_const_pkg.NUMBER_FORMAT
                        )
                     || l_separate_char
            ;
            l_record := l_record
                     || to_char(
                            get_number_tab_by_name_val(
                                i_num_tab_by_name  => l_gl_balance_tab
                              , i_name             => '203'
                              , i_val_for_def      => 0
                            )
                          , crd_api_const_pkg.NUMBER_FORMAT
                        )
                     || l_separate_char
            ;
            l_record := l_record
                     || to_char(
                            get_number_tab_by_name_val(
                                i_num_tab_by_name  => l_gl_balance_tab
                              , i_name             => '501'
                              , i_val_for_def      => 0
                            )
                          , crd_api_const_pkg.NUMBER_FORMAT
                        )
                     || l_separate_char
            ;
            l_record := l_record
                     || to_char(
                            get_number_tab_by_name_val(
                                i_num_tab_by_name  => l_gl_balance_tab
                              , i_name             => '502'
                              , i_val_for_def      => 0
                            )
                          , crd_api_const_pkg.NUMBER_FORMAT
                        )
                     || l_separate_char
            ;
            l_record := l_record
                     || to_char(
                            get_number_tab_by_name_val(
                                i_num_tab_by_name  => l_gl_balance_tab
                              , i_name             => '503'
                              , i_val_for_def      => 0
                            )
                          , crd_api_const_pkg.NUMBER_FORMAT
                        )
                     || l_separate_char
            ;
            l_record := l_record
                     || to_char(
                            get_number_tab_by_name_val(
                                i_num_tab_by_name  => l_gl_balance_tab
                              , i_name             => '501'
                              , i_val_for_def      => 0
                            )
                            -
                            get_number_tab_by_name_val(
                                i_num_tab_by_name  => l_gl_balance_tab
                              , i_name             => '601'
                              , i_val_for_def      => 0
                            )
                          , crd_api_const_pkg.NUMBER_FORMAT
                        )
                     || l_separate_char
            ;
            l_record := l_record
                     || to_char(
                            get_number_tab_by_name_val(
                                i_num_tab_by_name  => l_gl_balance_tab
                              , i_name             => '502'
                              , i_val_for_def      => 0
                            )
                            -
                            get_number_tab_by_name_val(
                                i_num_tab_by_name  => l_gl_balance_tab
                              , i_name             => '602'
                              , i_val_for_def      => 0
                            )
                          , crd_api_const_pkg.NUMBER_FORMAT
                        )
                     || l_separate_char
            ;
            l_record := l_record
                     || to_char(
                            get_number_tab_by_name_val(
                                i_num_tab_by_name  => l_gl_balance_tab
                              , i_name             => '503'
                              , i_val_for_def      => 0
                            )
                            -
                            get_number_tab_by_name_val(
                                i_num_tab_by_name  => l_gl_balance_tab
                              , i_name             => '603'
                              , i_val_for_def      => 0
                            )
                          , crd_api_const_pkg.NUMBER_FORMAT
                        )
                     || l_separate_char
            ;
            l_record := l_record
                     || to_char(
                            get_number_tab_by_name_val(
                                i_num_tab_by_name  => l_gl_balance_tab
                              , i_name             => '704'
                              , i_val_for_def      => 0
                            )
                          , crd_api_const_pkg.NUMBER_FORMAT
                        )
                     || l_separate_char
            ;
            l_record := l_record
                     || to_char(
                            get_number_tab_by_name_val(
                                i_num_tab_by_name  => l_gl_balance_tab
                              , i_name             => '703'
                              , i_val_for_def      => 0
                            )
                          , crd_api_const_pkg.NUMBER_FORMAT
                        )
                     || l_separate_char
            ;
            l_record := l_record
                     || to_char(
                            get_number_tab_by_name_val(
                                i_num_tab_by_name  => l_gl_balance_tab
                              , i_name             => '901'
                              , i_val_for_def      => 0
                            )
                          , crd_api_const_pkg.NUMBER_FORMAT
                        )
                     || l_separate_char
            ;
            l_record := l_record
                     || to_char(
                            get_number_tab_by_name_val(
                                i_num_tab_by_name  => l_gl_balance_tab
                              , i_name             => '902'
                              , i_val_for_def      => 0
                            )
                          , crd_api_const_pkg.NUMBER_FORMAT
                        )
                     || l_separate_char
            ;
            l_record := l_record
                     || to_char(
                            get_number_tab_by_name_val(
                                i_num_tab_by_name  => l_gl_balance_tab
                              , i_name             => '903'
                              , i_val_for_def      => 0
                            )
                          , crd_api_const_pkg.NUMBER_FORMAT
                        )
                     || l_separate_char
            ;
            l_revised_bucket :=
                cst_cfc_com_pkg.get_revised_bucket_attr(
                    i_customer_id     => null
                  , i_account_id      => i_accounts_data_rec.account_id
                  , i_attr            => 'revised_bucket'
                );
            l_record := l_record
                     || l_revised_bucket
                     || l_separate_char
            ;
            begin
                l_revised_bucket_n := to_number(l_revised_bucket);
            exception
                when com_api_error_pkg.e_value_error then
                    l_revised_bucket_n := null;
            end;
            l_record := l_record
                     || to_char(
                            case
                                when l_revised_bucket_n between 1 and 4 then
                                    l_var_money * 0.75 * com_api_const_pkg.ONE_PERCENT
                                when l_revised_bucket_n = 5 then
                                    0
                                else null
                            end
                            , crd_api_const_pkg.NUMBER_FORMAT
                        )
                     || l_separate_char
            ;
            l_record := l_record
                     || to_char(
                            case l_revised_bucket_n
                                when 1 then
                                    0
                                when 2 then
                                    l_var_money * 5 * com_api_const_pkg.ONE_PERCENT
                                when 3 then
                                    l_var_money * 20 * com_api_const_pkg.ONE_PERCENT
                                when 4 then
                                    l_var_money * 50 * com_api_const_pkg.ONE_PERCENT
                                when 5 then
                                    l_var_money * 100 * com_api_const_pkg.ONE_PERCENT
                                else null
                            end
                            , crd_api_const_pkg.NUMBER_FORMAT
                        )
                     || l_separate_char
            ;
        end if;
        prc_api_file_pkg.put_line(
            i_raw_data      => nvl(i_raw_data, l_record)
          , i_sess_file_id  => i_session_file_id
        );
        prc_api_file_pkg.put_file(
            i_sess_file_id   => i_session_file_id
          , i_clob_content   => nvl(i_raw_data, l_record) || CRLF
          , i_add_to         => com_api_const_pkg.TRUE
        );
    end put_record_to_file;

begin
    prc_api_stat_pkg.log_start;

    l_type_of_date_range := com_api_sttl_day_pkg.map_date_type_dict_to_dict(
                                i_date_type    => i_date_type
                              , i_dict_map     => fcl_api_const_pkg.DATE_TYPE_DICTIONARY_TYPE
                            );
    l_sysdate    := com_api_sttl_day_pkg.get_calc_date(
                        i_inst_id   => i_inst_id
                      , i_date_type => l_type_of_date_range
                    );

    l_start_date := trunc(coalesce(i_start_date, l_sysdate));
    l_end_date   := trunc(coalesce(i_end_date,   l_sysdate)) + 1 - com_api_const_pkg.ONE_SECOND;

    trc_log_pkg.debug(
        i_text => LOG_PREFIX
                  || 'Started with params - inst_id [#1] date_type [#2] separate_char [#3] array_link_account_numbers [#4] full_export [#5] account_number [#6]'
      , i_env_param1 => i_inst_id
      , i_env_param2 => i_date_type
      , i_env_param3 => i_separate_char
      , i_env_param4 => i_array_link_account_numbers
      , i_env_param5 => i_full_export
      , i_env_param6 => i_account_number
    );

    l_full_export        := coalesce(i_full_export, com_api_type_pkg.FALSE);

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Calculate date period - type_of_date_range [#1] sysdate [#2] start_date [#3] end_date [#4]'
      , i_env_param1 => l_type_of_date_range
      , i_env_param2 => to_char(l_sysdate,    com_api_const_pkg.LOG_DATE_FORMAT)
      , i_env_param3 => to_char(l_start_date, com_api_const_pkg.LOG_DATE_FORMAT)
      , i_env_param4 => to_char(l_end_date,   com_api_const_pkg.LOG_DATE_FORMAT)
    );

    if i_account_number is not null then
        l_account_id := acc_api_account_pkg.get_account(
                            i_account_id       => null
                          , i_account_number   => i_account_number
                          , i_inst_id          => i_inst_id
                          , i_mask_error       => com_api_const_pkg.FALSE
                        ).account_id;
    end if;

    if l_full_export = com_api_const_pkg.TRUE then

         select distinct(a.id)
           bulk collect into l_account_id_tab
           from acc_account a
              , acc_account_object ao
          where a.account_type  = acc_api_const_pkg.ACCOUNT_TYPE_CREDIT
            and a.status       in (acc_api_const_pkg.ACCOUNT_STATUS_CREDITS
                                 , acc_api_const_pkg.ACCOUNT_STATUS_ACTIVE)
            and ao.account_id   = a.id
            and ao.entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD;

         acc_api_external_pkg.get_active_accounts_for_period(
            i_inst_id                   => i_inst_id
          , i_date_type                 => i_date_type
          , i_start_date                => l_start_date
          , i_end_date                  => l_end_date
          , i_account_id                => l_account_id
          , io_account_id_tab           => l_account_id_tab
          , i_mask_error                => com_api_const_pkg.TRUE
          , o_ref_cursor                => l_ref_cursor
        );

        prc_api_file_pkg.open_file(
            o_sess_file_id  => l_session_file_id
          , i_file_purpose  => prc_api_const_pkg.FILE_PURPOSE_OUT
          , io_params       => l_param_tab
        );

        put_record_to_file(
            i_raw_data             => replace(cst_cfc_api_const_pkg.GL_ACC_BAL_DATA_FILE_HEADER, DELIMETER, nvl(i_separate_char, DELIMETER))
          , i_accounts_data_rec    => null
          , i_gl_balance_data_tab  => l_gl_balance_data_tab
          , i_session_file_id      => l_session_file_id
        );

        loop
            fetch l_ref_cursor bulk collect into l_accounts_data_tab limit BULK_LIMIT;

            l_estimated_count := nvl(l_estimated_count, 0) + l_accounts_data_tab.count;

            prc_api_stat_pkg.log_estimation(
                i_estimated_count   => l_estimated_count
            );

            for i in 1..l_accounts_data_tab.count loop
                acc_api_external_pkg.get_link_account_balances(
                    i_date_type                    => i_date_type
                  , i_start_date                   => l_start_date
                  , i_end_date                     => l_end_date
                  , i_account_id                   => l_accounts_data_tab(i).account_id
                  , i_gl_accounts                  => com_api_const_pkg.TRUE
                  , i_array_link_account_numbers   => i_array_link_account_numbers
                  , i_mask_error                   => com_api_const_pkg.TRUE
                  , o_ref_cursor                   => l_ref_cursor_2
                );

                fetch l_ref_cursor_2 bulk collect into l_gl_balance_data_tab;
                close l_ref_cursor_2;

                put_record_to_file(
                    i_accounts_data_rec    => l_accounts_data_tab(i)
                  , i_gl_balance_data_tab  => l_gl_balance_data_tab
                  , i_session_file_id      => l_session_file_id
                );

                l_processed_count := l_processed_count + 1;
            end loop;

            exit when l_ref_cursor%notfound;
        end loop;
        close l_ref_cursor;

    elsif l_full_export = com_api_const_pkg.FALSE then
        add_objects_in_tab(
            i_inst_id              => i_inst_id
          , i_entity_type          => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_proc_name            => PROC_NAME
          , i_sysdate              => l_sysdate
          , io_event_object_tab    => l_event_object_tab
          , io_entity_tab          => l_entity_tab
        );

        if l_event_object_tab.count = 0 then
            trc_log_pkg.debug(
                i_text        => LOG_PREFIX || 'The requested data [#1] was not found'
              , i_env_param1  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
            );
            prc_api_stat_pkg.log_estimation(
                i_estimated_count   => l_estimated_count
            );
        else
            for i in l_entity_tab.first .. l_entity_tab.last loop
                trc_log_pkg.debug(
                    i_text        => LOG_PREFIX || 'Incremental unload: count [#1] events  for entity [#2]'
                  , i_env_param1  => l_event_object_tab(l_entity_tab(i)).object_id.count
                  , i_env_param2  => l_entity_tab(i)
                );
            end loop;
            for i in l_entity_tab.first .. l_entity_tab.last loop
                l_request_count := ceil(l_event_object_tab(l_entity_tab(i)).object_id.count / BULK_LIMIT);
                for j in 1 .. l_request_count loop
                    if l_object_tab.exists(1) then
                        l_object_tab.delete;
                    end if;
                    l_object_tab(1).level_type  := l_entity_tab(i);
                    l_object_tab(1).entity_type := l_entity_tab(i);
                    for l in ((j - 1) * BULK_LIMIT + 1) .. least(l_event_object_tab(l_entity_tab(i)).object_id.last, j * BULK_LIMIT)
                    loop
                        if not l_object_tab(1).object_id.exists(1) then
                            l_object_tab(1).object_id := num_tab_tpt(l_event_object_tab(l_entity_tab(i)).object_id(l));
                        else
                            l_object_tab(1).object_id.extend;
                            l_object_tab(1).object_id(l_object_tab(1).object_id.last) := l_event_object_tab(l_entity_tab(i)).object_id(l);
                        end if;
                    end loop;

                    l_account_id_tab.delete;
                    for i in 1 .. l_object_tab(1).object_id.count loop
                        l_account_id_tab.extend;
                        l_account_id_tab(l_account_id_tab.count) := l_object_tab(1).object_id(i);
                    end loop;

                    acc_api_external_pkg.get_active_accounts_for_period(
                        i_inst_id                   => i_inst_id
                      , i_date_type                 => i_date_type
                      , i_start_date                => l_start_date
                      , i_end_date                  => l_end_date
                      , i_account_id                => l_account_id
                      , io_account_id_tab           => l_account_id_tab
                      , i_mask_error                => com_api_const_pkg.TRUE
                      , o_ref_cursor                => l_ref_cursor
                    );

                    if l_session_file_id is null then
                        prc_api_file_pkg.open_file(
                            o_sess_file_id  => l_session_file_id
                          , i_file_purpose  => prc_api_const_pkg.FILE_PURPOSE_OUT
                          , io_params       => l_param_tab
                        );

                        put_record_to_file(
                            i_raw_data             => replace(cst_cfc_api_const_pkg.GL_ACC_BAL_DATA_FILE_HEADER, DELIMETER, nvl(i_separate_char, DELIMETER))
                          , i_accounts_data_rec    => null
                          , i_gl_balance_data_tab  => l_gl_balance_data_tab
                          , i_session_file_id      => l_session_file_id
                        );
                    end if;

                    loop
                        fetch l_ref_cursor bulk collect into l_accounts_data_tab limit BULK_LIMIT;

                        for m in 1 .. l_accounts_data_tab.count loop
                            if check_add_acc_data_result_line(
                                   i_entity_type              => l_entity_tab(i)
                                 , i_accounts_data_rec        => l_accounts_data_tab(m)
                                 , i_event_object_tab         => l_event_object_tab
                               ) = com_api_const_pkg.TRUE
                            then
                                if l_accounts_data_unloading.exists(1) then
                                    l_accounts_data_unloading(l_accounts_data_unloading.last + 1) := l_accounts_data_tab(m).account_id;
                                else
                                    l_accounts_data_unloading(1) := l_accounts_data_tab(m).account_id;
                                end if;

                                l_estimated_count := l_estimated_count + 1;

                                add_acc_data_event_collection(
                                    i_index                  => i
                                  , i_entity_tab             => l_entity_tab
                                  , i_accounts_data_rec      => l_accounts_data_tab(m)
                                  , io_event_object_tab      => l_event_object_tab
                                  , io_event_tab             => l_event_tab
                                );
                            end if;
                        end loop;
                        exit when l_ref_cursor%notfound;
                    end loop;

                    close l_ref_cursor;

                end loop;
            end loop;

            prc_api_stat_pkg.log_estimation(
                i_estimated_count   => l_estimated_count
            );

            if l_estimated_count > 0 then
                l_request_count := ceil(l_estimated_count / BULK_LIMIT);
                for j in 1 .. l_request_count loop
                    if l_object_tab.exists(1) then
                        l_object_tab.delete;
                    end if;
                    l_object_tab(1).level_type  := acc_api_const_pkg.ENTITY_TYPE_ACCOUNT;
                    l_object_tab(1).entity_type := acc_api_const_pkg.ENTITY_TYPE_ACCOUNT;
                    for l in ((j - 1) * BULK_LIMIT + 1) .. least(l_accounts_data_unloading.last, j * BULK_LIMIT)
                    loop
                        if not l_object_tab(1).object_id.exists(1) then
                            l_object_tab(1).object_id := num_tab_tpt(l_accounts_data_unloading(l));
                        else
                            l_object_tab(1).object_id.extend;
                            l_object_tab(1).object_id(l_object_tab(1).object_id.last) := l_accounts_data_unloading(l);
                        end if;
                    end loop;

                    l_account_id_tab.delete;
                    for i in 1 .. l_object_tab(1).object_id.count loop
                        l_account_id_tab.extend;
                        l_account_id_tab(l_account_id_tab.count) := l_object_tab(1).object_id(i);
                    end loop;

                    acc_api_external_pkg.get_active_accounts_for_period(
                        i_inst_id                   => i_inst_id
                      , i_date_type                 => i_date_type
                      , i_start_date                => l_start_date
                      , i_end_date                  => l_end_date
                      , i_account_id                => l_account_id
                      , io_account_id_tab           => l_account_id_tab
                      , i_mask_error                => com_api_const_pkg.TRUE
                      , o_ref_cursor                => l_ref_cursor
                    );

                    loop
                        fetch l_ref_cursor bulk collect into l_accounts_data_tab limit BULK_LIMIT;

                        for m in 1..l_accounts_data_tab.count loop
                            acc_api_external_pkg.get_link_account_balances(
                                i_date_type                    => i_date_type
                              , i_start_date                   => l_start_date
                              , i_end_date                     => l_end_date
                              , i_account_id                   => l_accounts_data_tab(m).account_id
                              , i_gl_accounts                  => com_api_const_pkg.TRUE
                              , i_array_link_account_numbers   => i_array_link_account_numbers
                              , i_mask_error                   => com_api_const_pkg.TRUE
                              , o_ref_cursor                   => l_ref_cursor_2
                            );

                            fetch l_ref_cursor_2 bulk collect into l_gl_balance_data_tab;
                            close l_ref_cursor_2;

                            put_record_to_file(
                                i_accounts_data_rec    => l_accounts_data_tab(m)
                              , i_gl_balance_data_tab  => l_gl_balance_data_tab
                              , i_session_file_id      => l_session_file_id
                            );
                            l_processed_count := l_processed_count + 1;
                        end loop;
                        exit when l_ref_cursor%notfound;
                    end loop;
                    close l_ref_cursor;

                end loop;
            end if;
        end if;
    end if;

    if l_session_file_id is not null then
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );
    end if;
    add_not_used_event_collection(
        i_entity_tab               => l_entity_tab
      , io_event_object_tab        => l_event_object_tab
      , io_event_tab               => l_event_tab
    );
    if l_event_tab.exists(1) then
        evt_api_event_pkg.process_event_object(
            i_event_object_id_tab => l_event_tab
        );
    end if;

    prc_api_stat_pkg.log_end(
        i_excepted_total   => l_excepted_count
      , i_processed_total  => l_processed_count
      , i_rejected_total   => l_rejected_count
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Finished success'
    );

exception
    when others then
       trc_log_pkg.debug(
            i_text        => LOG_PREFIX || 'Finished with errors: [#1]'
          , i_env_param1  => sqlcode
        );

        if l_session_file_id is not null then
            prc_api_file_pkg.close_file(
                i_sess_file_id  => l_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;

        l_estimated_count := nvl(l_estimated_count, 0);
        l_excepted_count  := l_estimated_count - l_processed_count;

        prc_api_stat_pkg.log_end(
            i_excepted_total   => l_excepted_count
          , i_processed_total  => l_processed_count
          , i_rejected_total   => l_rejected_count
          , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(code => sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error       => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
            );
        end if;

end process_unload_acc_gl_data;

procedure process_unload_scoring_data(
    i_inst_id                      in     com_api_type_pkg.t_inst_id
  , i_agent_id                     in     com_api_type_pkg.t_agent_id
  , i_customer_number              in     com_api_type_pkg.t_name
  , i_account_number               in     com_api_type_pkg.t_account_number
  , i_start_date                   in     date                                default null
  , i_end_date                     in     date                                default null
)is
    PROC_NAME                constant     com_api_type_pkg.t_name := $$PLSQL_UNIT || '.PROCESS_UNLOAD_SCORING_DATA';
    LOG_PREFIX               constant     com_api_type_pkg.t_name := lower(PROC_NAME) || ': ';
    l_ref_cursor                          com_api_type_pkg.t_ref_cur;

    l_scr_outgoing_tab                    cst_cfc_api_type_pkg.t_scr_outgoing_tab;
    l_scr_info_rec                        cst_cfc_api_type_pkg.t_scr_info_rec;

    l_session_file_id                     com_api_type_pkg.t_long_id;
    l_record                              com_api_type_pkg.t_raw_data;

    l_account_id                          com_api_type_pkg.t_account_id;
    l_customer_id                         com_api_type_pkg.t_medium_id;
    l_start_date                          date;
    l_end_date                            date;
begin
    savepoint sp_unload_scoring_data;

    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Started with params - inst_id [#1] customer number [#2]
                    account number [#3] start_date [#4] end_date [#5]'
      , i_env_param1 => i_inst_id
      , i_env_param2 => i_customer_number
      , i_env_param3 => i_account_number
      , i_env_param4 => i_start_date
      , i_env_param5 => i_end_date
    );

    l_start_date := trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate));
    l_end_date   := nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;

    prc_api_file_pkg.open_file(
        o_sess_file_id  => l_session_file_id
    );

    prc_api_file_pkg.put_line(
        i_sess_file_id => l_session_file_id
      , i_raw_data     => cst_cfc_api_const_pkg.SCORING_DATA_FILE_HEADER
    );
    if i_account_number is not null then
        l_account_id := acc_api_account_pkg.get_account(
                            i_account_id       => null
                          , i_account_number   => i_account_number
                          , i_inst_id          => i_inst_id
                          , i_mask_error       => com_api_const_pkg.FALSE
                        ).account_id;
    end if;

    if i_customer_number is not null then
        l_customer_id := prd_api_customer_pkg.get_customer_id(
                            i_customer_number  => i_customer_number
                          , i_inst_id          => i_inst_id
                          , i_mask_error       => com_api_const_pkg.FALSE
                        );
    end if;

    scr_api_external_pkg.get_scoring_data(
        i_inst_id           => i_inst_id
      , i_agent_id          => i_agent_id
      , i_customer_id       => l_customer_id
      , i_account_id        => l_account_id
      , o_ref_cursor        => l_ref_cursor
    );

    loop
        fetch l_ref_cursor
            bulk collect into l_scr_outgoing_tab
            limit BULK_LIMIT;

        for i in 1..l_scr_outgoing_tab.count loop

            scr_api_external_pkg.get_scoring_info_rec(
                io_scr_outgoing_rec => l_scr_outgoing_tab(i)
              , o_scr_info_rec      => l_scr_info_rec
              , i_start_date        => l_start_date
              , i_end_date          => l_end_date
            );

            l_record := to_char(l_scr_info_rec.gen_date, cst_cfc_api_const_pkg.CST_SCR_DATE_FORMAT)         || DELIMETER
                     || rpad(l_scr_outgoing_tab(i).customer_number, 32)              || DELIMETER
                     || rpad(l_scr_outgoing_tab(i).account_number, 32)               || DELIMETER
                     || rpad(l_scr_outgoing_tab(i).card_mask, 24)                    || DELIMETER
                     || rpad(l_scr_outgoing_tab(i).category, 1)                      || DELIMETER
                     || rpad(l_scr_outgoing_tab(i).status, 8)                        || DELIMETER
                     || rpad(to_char(l_scr_info_rec.card_limit, com_api_const_pkg.XML_NUMBER_FORMAT), 16)   || DELIMETER
                     || to_char(l_scr_info_rec.invoice_date,    cst_cfc_api_const_pkg.CST_SCR_DATE_FORMAT)  || DELIMETER
                     || to_char(l_scr_info_rec.due_date,        cst_cfc_api_const_pkg.CST_SCR_DATE_FORMAT)  || DELIMETER
                     || rpad(l_scr_info_rec.min_amount_due, 16)                      || DELIMETER
                     || rpad(l_scr_info_rec.exceed_limit, 16)                        || DELIMETER
                     || rpad(l_scr_outgoing_tab(i).sub_acct, 32)                     || DELIMETER
                     || rpad(l_scr_info_rec.sub_acct_bal, 16)                        || DELIMETER
                     || rpad(l_scr_info_rec.atm_wdr_cnt, 12)                         || DELIMETER
                     || rpad(l_scr_info_rec.pos_cnt, 12)                             || DELIMETER
                     || rpad(l_scr_info_rec.all_trx_cnt, 12)                         || DELIMETER
                     || rpad(l_scr_info_rec.atm_wdr_amt, 16)                         || DELIMETER
                     || rpad(l_scr_info_rec.pos_amt, 16)                             || DELIMETER
                     || rpad(l_scr_info_rec.total_trx_amt, 16)                       || DELIMETER
                     || rpad(l_scr_info_rec.daily_repayment, 16)                     || DELIMETER
                     || rpad(l_scr_info_rec.cycle_repayment, 16)                     || DELIMETER
                     || rpad(l_scr_info_rec.current_dpd, 4)                          || DELIMETER
                     || rpad(l_scr_info_rec.bucket, 2)                               || DELIMETER
                     || rpad(l_scr_info_rec.revised_bucket, 2)                       || DELIMETER
                     || rpad(l_scr_info_rec.eff_date, 8)                             || DELIMETER
                     || rpad(l_scr_info_rec.expir_date, 8)                           || DELIMETER
                     || rpad(l_scr_info_rec.valid_period, 3)                         || DELIMETER
                     || rpad(l_scr_info_rec.reason, 128)                             || DELIMETER
                     || rpad(l_scr_info_rec.highest_bucket_01, 2)                    || DELIMETER
                     || rpad(l_scr_info_rec.highest_bucket_03, 2)                    || DELIMETER
                     || rpad(l_scr_info_rec.highest_bucket_06, 2)                    || DELIMETER
                     || rpad(l_scr_info_rec.highest_dpd, 4)                          || DELIMETER
                     || rpad(l_scr_info_rec.cycle_wdr_amt, 16)                       || DELIMETER
                     || rpad(l_scr_info_rec.total_debit_amt, 16)                     || DELIMETER
                     || rpad(l_scr_info_rec.cycle_avg_wdr_amt, 16)                   || DELIMETER
                     || rpad(l_scr_info_rec.cycle_daily_avg_usage, 16)               || DELIMETER
                     || rpad(l_scr_info_rec.life_wdr_amt, 16)                        || DELIMETER
                     || rpad(l_scr_info_rec.life_wdr_cnt, 12)                        || DELIMETER
                     || rpad(l_scr_info_rec.avg_wdr, 16)                             || DELIMETER
                     || rpad(l_scr_info_rec.daily_usage, 16)                         || DELIMETER
                     || rpad(l_scr_info_rec.monthly_usage, 16)                       || DELIMETER
                     || rpad(l_scr_info_rec.tmp_crd_limit, 16)                       || DELIMETER
                     || to_char(l_scr_info_rec.limit_start_date, cst_cfc_api_const_pkg.CST_SCR_DATE_FORMAT) || DELIMETER
                     || to_char(l_scr_info_rec.limit_end_date,   cst_cfc_api_const_pkg.CST_SCR_DATE_FORMAT) || DELIMETER
                     || rpad(l_scr_info_rec.card_usage_limit, 16)                    || DELIMETER
                     || rpad(l_scr_info_rec.total_debt, 16)                          || DELIMETER
                     || rpad(l_scr_info_rec.overdue_amt, 16)
            ;

            prc_api_file_pkg.put_line(
                i_raw_data      => l_record
              , i_sess_file_id  => l_session_file_id
            );

        end loop;
        exit when l_ref_cursor%notfound;
    end loop;
    close l_ref_cursor;

    prc_api_file_pkg.close_file(
        i_sess_file_id        => l_session_file_id
      , i_status              => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    prc_api_stat_pkg.log_end(
        i_result_code    => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug('Finish unloading the scoring data');
exception
    when others then
        rollback to sp_unload_scoring_data;
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if l_session_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_session_file_id
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
end process_unload_scoring_data;

procedure process_unload_coa_data(
    i_inst_id                      in     com_api_type_pkg.t_inst_id
)is
    SUMMARY_CHANNEL   constant  com_api_type_pkg.t_name       := 'Total summary';

    l_session_file_id           com_api_type_pkg.t_long_id;
    l_record_count              com_api_type_pkg.t_count      := 0;
    l_channel_count             com_api_type_pkg.t_count      := 0;
    l_summary_count             com_api_type_pkg.t_count      := 0;
    l_estimated_count           com_api_type_pkg.t_long_id;
    l_sysdate                   date;

    l_event_id_tab              com_api_type_pkg.t_number_tab;
    l_oper_id_tab               com_api_type_pkg.t_number_tab;
    l_payment_id_tab            com_api_type_pkg.t_number_tab;
    l_account_id_tab            com_api_type_pkg.t_number_tab;
    l_pay_amount_tab            com_api_type_pkg.t_money_tab;
    l_oper_date_tab             com_api_type_pkg.t_date_tab;
    l_total_payment_tab         com_api_type_pkg.t_number_tab;
    l_terminal_number_tab       com_api_type_pkg.t_terminal_number_tab;
    l_status_tab                com_api_type_pkg.t_dict_tab;
    l_prev_oper_id              com_api_type_pkg.t_long_id;
    l_channel                   com_api_type_pkg.t_name;

    cursor cur_events is
        select eo.id           as event_object_id
             , eo.object_id    as oper_id
             , p.id
             , p.account_id
             , p.pay_amount
             , op.oper_date
             , op.oper_amount  as total_payment
             , op.terminal_number
             , decode(e.event_type, opr_api_const_pkg.EVENT_PROCESSED_SUCCESSFULLY, 'Y', 'N') as status
          from evt_event_object eo
             , evt_event e
             , opr_operation op
             , crd_payment p
         where decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'CST_CFC_PRC_OUTGOING_PKG.PROCESS_UNLOAD_COA_DATA'
           and eo.split_hash  in (select split_hash from com_api_split_map_vw)
           and eo.entity_type  = opr_api_const_pkg.ENTITY_TYPE_OPERATION
           and eo.eff_date    <= l_sysdate
           and eo.inst_id      = i_inst_id
           and e.id            = eo.event_id
           and e.event_type   in (opr_api_const_pkg.EVENT_PROCESSED_SUCCESSFULLY
                                , opr_api_const_pkg.EVENT_PROCESSED_WITH_ERRORS
                                , opr_api_const_pkg.EVENT_LOADED_WITH_ERRORS)
           and op.id           = eo.object_id
           and p.oper_id(+)    = op.id
         order by eo.object_id
                , decode(e.event_type, opr_api_const_pkg.EVENT_PROCESSED_SUCCESSFULLY, 'Y', 'N') desc;

        type t_coa_rec is record (
            channel              com_api_type_pkg.t_name
          , oper_date            date
          , account_number       com_api_type_pkg.t_account_number
          , status               com_api_type_pkg.t_one_char
          , total_payment        com_api_type_pkg.t_money
          , lending_payment      com_api_type_pkg.t_money
          , overdraft_payment    com_api_type_pkg.t_money
          , overdue_payment      com_api_type_pkg.t_money
          , interest_payment     com_api_type_pkg.t_money
          , o_interest_payment   com_api_type_pkg.t_money
          , fee_payment          com_api_type_pkg.t_money
          , over_payment         com_api_type_pkg.t_money
          , w_principal_payment  com_api_type_pkg.t_money
          , w_interest_payment   com_api_type_pkg.t_money
          , w_fee_payment        com_api_type_pkg.t_money
          , s_debt_amount        com_api_type_pkg.t_money
        );
        l_coa_rec          t_coa_rec;

        type t_coa_summary_tab is table of t_coa_rec index by com_api_type_pkg.t_name;
        l_channel_tab  t_coa_summary_tab;

        procedure put_record_line(
            io_coa_rec       in out t_coa_rec
          , io_record_count  in out com_api_type_pkg.t_count
          , i_channel        in     com_api_type_pkg.t_name
        ) is
            l_record             com_api_type_pkg.t_raw_data;
        begin
            l_record := rpad(io_coa_rec.channel, 32)                                      || DELIMETER
                     || nvl(to_char(io_coa_rec.oper_date
                              , cst_cfc_api_const_pkg.CST_SCR_DATE_FORMAT), rpad(' ', 8)) || DELIMETER
                     || rpad(io_coa_rec.account_number, 32)                               || DELIMETER
                     || rpad(io_coa_rec.status, 1)                                        || DELIMETER
                     || rpad(nvl(to_char(io_coa_rec.total_payment),       ' '), 16)       || DELIMETER
                     || rpad(nvl(to_char(io_coa_rec.lending_payment),     ' '), 16)       || DELIMETER
                     || rpad(nvl(to_char(io_coa_rec.overdraft_payment),   ' '), 16)       || DELIMETER
                     || rpad(nvl(to_char(io_coa_rec.overdue_payment),     ' '), 16)       || DELIMETER
                     || rpad(nvl(to_char(io_coa_rec.interest_payment),    ' '), 16)       || DELIMETER
                     || rpad(nvl(to_char(io_coa_rec.o_interest_payment),  ' '), 16)       || DELIMETER
                     || rpad(nvl(to_char(io_coa_rec.fee_payment),         ' '), 16)       || DELIMETER
                     || rpad(nvl(to_char(io_coa_rec.over_payment),        ' '), 16)       || DELIMETER
                     || rpad(nvl(to_char(io_coa_rec.w_principal_payment), ' '), 16)       || DELIMETER
                     || rpad(nvl(to_char(io_coa_rec.w_interest_payment),  ' '), 16)       || DELIMETER
                     || rpad(nvl(to_char(io_coa_rec.w_fee_payment),       ' '), 16)       || DELIMETER
                     || rpad(nvl(to_char(io_coa_rec.s_debt_amount),       ' '), 16);

            prc_api_file_pkg.put_line(
                i_raw_data      => l_record
              , i_sess_file_id  => l_session_file_id
            );

            if i_channel is not null then
                l_channel_tab(i_channel).channel             := i_channel;
                l_channel_tab(i_channel).oper_date           := null;
                l_channel_tab(i_channel).account_number      := ' ';
                l_channel_tab(i_channel).status              := ' ';
                l_channel_tab(i_channel).total_payment       := nvl(l_channel_tab(i_channel).total_payment,       0) + nvl(io_coa_rec.total_payment       ,0);
                l_channel_tab(i_channel).lending_payment     := nvl(l_channel_tab(i_channel).lending_payment,     0) + nvl(io_coa_rec.lending_payment     ,0);
                l_channel_tab(i_channel).overdraft_payment   := nvl(l_channel_tab(i_channel).overdraft_payment,   0) + nvl(io_coa_rec.overdraft_payment   ,0);
                l_channel_tab(i_channel).overdue_payment     := nvl(l_channel_tab(i_channel).overdue_payment,     0) + nvl(io_coa_rec.overdue_payment     ,0);
                l_channel_tab(i_channel).interest_payment    := nvl(l_channel_tab(i_channel).interest_payment,    0) + nvl(io_coa_rec.interest_payment    ,0);
                l_channel_tab(i_channel).o_interest_payment  := nvl(l_channel_tab(i_channel).o_interest_payment,  0) + nvl(io_coa_rec.o_interest_payment  ,0);
                l_channel_tab(i_channel).fee_payment         := nvl(l_channel_tab(i_channel).fee_payment,         0) + nvl(io_coa_rec.fee_payment         ,0);
                l_channel_tab(i_channel).over_payment        := nvl(l_channel_tab(i_channel).over_payment,        0) + nvl(io_coa_rec.over_payment        ,0);
                l_channel_tab(i_channel).w_principal_payment := nvl(l_channel_tab(i_channel).w_principal_payment, 0) + nvl(io_coa_rec.w_principal_payment ,0);
                l_channel_tab(i_channel).w_interest_payment  := nvl(l_channel_tab(i_channel).w_interest_payment,  0) + nvl(io_coa_rec.w_interest_payment  ,0);
                l_channel_tab(i_channel).w_fee_payment       := nvl(l_channel_tab(i_channel).w_fee_payment,       0) + nvl(io_coa_rec.w_fee_payment       ,0);
                l_channel_tab(i_channel).s_debt_amount       := nvl(l_channel_tab(i_channel).s_debt_amount,       0) + nvl(io_coa_rec.s_debt_amount       ,0);
            end if;

            io_coa_rec      := null;
            io_record_count := io_record_count + 1;

    end put_record_line;

begin
    savepoint sp_unload_coa_data;

    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(
        i_text       => 'Started with params - inst_id [#1]'
      , i_env_param1 => i_inst_id
    );

    l_sysdate := com_api_sttl_day_pkg.get_sysdate;

    select count(*)
      into l_estimated_count
      from evt_event_object eo
         , evt_event e
         , opr_operation op
         , crd_payment p
     where decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'CST_CFC_PRC_OUTGOING_PKG.PROCESS_UNLOAD_COA_DATA'
       and eo.split_hash  in (select split_hash from com_api_split_map_vw)
       and eo.entity_type  = opr_api_const_pkg.ENTITY_TYPE_OPERATION
       and eo.eff_date    <= l_sysdate
       and eo.inst_id      = i_inst_id
       and e.id            = eo.event_id
       and e.event_type   in (opr_api_const_pkg.EVENT_PROCESSED_SUCCESSFULLY
                            , opr_api_const_pkg.EVENT_PROCESSED_WITH_ERRORS
                            , opr_api_const_pkg.EVENT_LOADED_WITH_ERRORS)
       and op.id           = eo.object_id
       and p.oper_id(+)    = op.id;

    trc_log_pkg.debug(
        i_text       => 'l_estimated_count [#1]'
      , i_env_param1 => l_estimated_count
    );

    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_estimated_count
    );

    if l_estimated_count > 0 then

        prc_api_file_pkg.open_file(
            o_sess_file_id  => l_session_file_id
        );

        prc_api_file_pkg.put_line(
            i_sess_file_id  => l_session_file_id
          , i_raw_data      => cst_cfc_api_const_pkg.COA_DATA_FILE_HEADER
        );

        open cur_events;

        trc_log_pkg.debug(
            i_text       => 'Start loop'
        );

        loop
            fetch cur_events
                bulk collect into l_event_id_tab
                                , l_oper_id_tab
                                , l_payment_id_tab
                                , l_account_id_tab
                                , l_pay_amount_tab
                                , l_oper_date_tab
                                , l_total_payment_tab
                                , l_terminal_number_tab
                                , l_status_tab
                limit BULK_LIMIT;

            trc_log_pkg.debug(
                i_text       => 'Read count [#1]'
              , i_env_param1 => l_event_id_tab.count
            );

            for i in 1 .. l_event_id_tab.count loop

                if l_prev_oper_id   is null              -- First oper_id
                   or
                   l_oper_id_tab(i) != l_prev_oper_id    -- oper_id is changed
                then

                    select nvl(max(channel_name), 'BANKS')
                      into l_coa_rec.channel
                      from cst_cfc_channel
                     where terminal_number = l_terminal_number_tab(i);

                    if l_account_id_tab(i) is not null then
                        select max(a.account_number)
                          into l_coa_rec.account_number
                          from acc_account a
                         where a.id = l_account_id_tab(i);
                     end if;

                    if l_coa_rec.account_number is null then
                        select max(p.account_number)
                          into l_coa_rec.account_number
                          from opr_participant p
                         where p.oper_id          = l_oper_id_tab(i)
                           and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER;
                    end if;

                    if l_coa_rec.account_number is null then
                        l_coa_rec.account_number := ' ';
                    end if;

                    l_coa_rec.over_payment  := l_pay_amount_tab(i);
                    l_coa_rec.oper_date     := l_oper_date_tab(i);
                    l_coa_rec.total_payment := l_total_payment_tab(i);
                    l_coa_rec.status        := l_status_tab(i);

                    if l_status_tab(i) = 'Y' then

                        select sum(decode(p.balance_type, crd_api_const_pkg.BALANCE_TYPE_LENDING,           p.pay_amount, 0))
                             , sum(decode(p.balance_type, acc_api_const_pkg.BALANCE_TYPE_OVERDRAFT,         p.pay_amount, 0))
                             , sum(decode(p.balance_type, acc_api_const_pkg.BALANCE_TYPE_OVERDUE,           p.pay_amount, 0))
                             , sum(decode(p.balance_type, crd_api_const_pkg.BALANCE_TYPE_INTEREST,          p.pay_amount, 0))
                             , sum(decode(p.balance_type, crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST,  p.pay_amount, 0))
                             , sum(decode(p.balance_type, acc_api_const_pkg.BALANCE_TYPE_FEES,              p.pay_amount, 0))
                             , sum(decode(p.balance_type, crd_api_const_pkg.BALANCE_TYPE_WRT_OFF_PRINCIPAL, p.pay_amount, 0))
                             , sum(decode(p.balance_type, crd_api_const_pkg.BALANCE_TYPE_WRT_OFF_INTEREST,  p.pay_amount, 0))
                             , sum(decode(p.balance_type, crd_api_const_pkg.BALANCE_TYPE_WRT_OFF_FEE,       p.pay_amount, 0))
                          into l_coa_rec.lending_payment
                             , l_coa_rec.overdraft_payment
                             , l_coa_rec.overdue_payment
                             , l_coa_rec.interest_payment
                             , l_coa_rec.o_interest_payment
                             , l_coa_rec.fee_payment
                             , l_coa_rec.w_principal_payment
                             , l_coa_rec.w_interest_payment
                             , l_coa_rec.w_fee_payment
                          from crd_debt_payment p
                         where p.pay_id = l_payment_id_tab(i);

                        l_coa_rec.s_debt_amount := 0;

                    end if;

                    put_record_line(
                        io_coa_rec      => l_coa_rec
                      , io_record_count => l_record_count
                      , i_channel       => 'Summary ' || l_coa_rec.channel
                    );

                    l_prev_oper_id := l_oper_id_tab(i);

                end if;
            end loop;

            evt_api_event_pkg.process_event_object(
                i_event_object_id_tab => l_event_id_tab
            );

            exit when cur_events%notfound;
        end loop;

        close cur_events;

        trc_log_pkg.debug(
            i_text       => 'Channel count [#1]'
          , i_env_param1 => l_channel_tab.count
        );

        -- Summary for any channel name
        if l_channel_tab.count > 0 then
            l_channel := l_channel_tab.first;

            loop
                exit when l_channel is null;

                if l_channel_tab(l_channel).channel != SUMMARY_CHANNEL then
                    put_record_line(
                        io_coa_rec      => l_channel_tab(l_channel)
                      , io_record_count => l_channel_count
                      , i_channel       => SUMMARY_CHANNEL
                    );
                end if;

                l_channel := l_channel_tab.next(l_channel);
            end loop;
        end if;

        trc_log_pkg.debug(
            i_text       => 'Save summary'
        );

        -- Result summary
        put_record_line(
            io_coa_rec      => l_channel_tab(SUMMARY_CHANNEL)
          , io_record_count => l_summary_count
          , i_channel       => null
        );

        prc_api_file_pkg.close_file(
            i_sess_file_id      => l_session_file_id
          , i_status            => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );

    end if;  -- if l_estimated_count > 0

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_record_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug('Finish unloading the CoA data');
exception
    when others then
        rollback to sp_unload_coa_data;

        if cur_events%isopen then
            close cur_events;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if l_session_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_session_file_id
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
end process_unload_coa_data;

procedure process_unload_appl_respond(
    i_inst_id                      in     com_api_type_pkg.t_inst_id
  , i_start_date                   in     date                                default null
  , i_end_date                     in     date                                default null
)is
    PROC_NAME                constant     com_api_type_pkg.t_name := $$PLSQL_UNIT || '.PROCESS_UNLOAD_APPL_RESPOND';
    LOG_PREFIX               constant     com_api_type_pkg.t_name := lower(PROC_NAME) || ': ';

    l_session_file_id                     com_api_type_pkg.t_long_id;
    l_record                              com_api_type_pkg.t_raw_data;
    l_record_count                        com_api_type_pkg.t_long_id;
    l_start_date                          date;
    l_end_date                            date;

    cursor cur_appl_resp(
        i_inst_id           in  com_api_type_pkg.t_inst_id
      , i_start_date        in  date
      , i_end_date          in  date
    )is
    select p.appl_number
         , (decode(appl_status, app_api_const_pkg.APPL_STATUS_PROC_SUCCESS, 1, 0)) result_code
         , d.customer_id
         , d.card_number
         , d.account_number
         , d.expire_date
         , cst_cfc_com_pkg.get_app_element_v(
               i_appl_id        => p.id
             , i_element_name   => 'ERROR_DESC'
           ) process_err
      from app_application p
         , (select o.appl_id
                 , a.customer_id
                 , a.account_number
                 , substr(c.card_number, -4) card_number
                 , cst_cfc_com_pkg.get_card_expire_date(i_card_id => c.card_id) expire_date
              from app_object       o
                 , acc_account      a
                 , acc_account_object   ao
                 , iss_card_number  c
             where o.entity_type    = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
               and o.object_id      = a.customer_id
               and a.id             = ao.account_id
               and ao.entity_type   = iss_api_const_pkg.ENTITY_TYPE_CARD
               and ao.object_id     = c.card_id
           ) d
         , (select appl_id
                 , max(change_date) change_date
              from app_history
             where id between com_api_id_pkg.get_from_id(appl_id)
                   and com_api_id_pkg.get_till_id(appl_id)
             group by appl_id
            ) h
     where p.id             = d.appl_id(+)
       and p.flow_id        in (1001, 1002, 1003)
       and p.inst_id        = nvl(i_inst_id, p.inst_id)
       and h.appl_id        = p.id
       and h.change_date    between i_start_date and i_end_date
     order by p.id;

    type t_appl_resp_tab is table of cur_appl_resp%rowtype index by binary_integer;
    l_appl_resp_tab     t_appl_resp_tab;
begin
    savepoint sp_unload_appl_respond;

    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Started with params - inst_id [#1] start_date [#2] end_date [#3]'
      , i_env_param1 => i_inst_id
      , i_env_param2 => i_start_date
      , i_env_param3 => i_end_date
    );
    prc_api_file_pkg.open_file(
        o_sess_file_id  => l_session_file_id
    );

    prc_api_file_pkg.put_line(
        i_sess_file_id => l_session_file_id
      , i_raw_data     => cst_cfc_api_const_pkg.APPL_RESPOND_FILE_HEADER
    );

    -- determine missed parameters
    l_start_date := coalesce(i_start_date, trunc(com_api_sttl_day_pkg.get_sysdate)) ;
    l_end_date   := coalesce(i_end_date, l_start_date + 1 - com_api_const_pkg.ONE_SECOND);

    open cur_appl_resp(
        i_inst_id       => i_inst_id
      , i_start_date    => l_start_date
      , i_end_date      => l_end_date
    );

    loop
        fetch cur_appl_resp bulk collect into l_appl_resp_tab
        limit BULK_LIMIT;
        for i in 1..l_appl_resp_tab.count loop
            l_record := l_appl_resp_tab(i).appl_number                  || COMMA_DELIMETER
                     || l_appl_resp_tab(i).customer_id                  || COMMA_DELIMETER
                     || l_appl_resp_tab(i).result_code                  || COMMA_DELIMETER
                     || l_appl_resp_tab(i).card_number                  || COMMA_DELIMETER
                     || l_appl_resp_tab(i).account_number               || COMMA_DELIMETER
                     || to_char(l_appl_resp_tab(i).expire_date, 'YYMM') || COMMA_DELIMETER
                     || l_appl_resp_tab(i).process_err
            ;

            prc_api_file_pkg.put_line(
                i_raw_data      => l_record
              , i_sess_file_id  => l_session_file_id
            );
        end loop;
        l_record_count := l_record_count + l_appl_resp_tab.count;
    exit when cur_appl_resp%notfound;
    end loop;
    close cur_appl_resp;

    prc_api_file_pkg.close_file(
        i_sess_file_id      => l_session_file_id
      , i_status            => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_record_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug('Finish unloading application respond date');
exception
    when others then
        rollback to sp_unload_appl_respond;
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if l_session_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_session_file_id
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
end process_unload_appl_respond;

procedure process_payment_inquiry_batch(
    i_inst_id                      in     com_api_type_pkg.t_inst_id
  , i_array_account_status_id      in     com_api_type_pkg.t_short_id
) is
    PROC_NAME                constant     com_api_type_pkg.t_name := $$PLSQL_UNIT || '.process_payment_inquiry_batch';
    LOG_PREFIX               constant     com_api_type_pkg.t_name := lower(PROC_NAME) || ': ';
    l_session_file_id                     com_api_type_pkg.t_long_id;
    l_cursor                              sys_refcursor;
    l_record                              com_api_type_pkg.t_raw_data;
    l_record_count                        com_api_type_pkg.t_long_id := 0;
    l_last_payment_flag                   com_api_type_pkg.t_curr_code;
    l_date                                date;

    type t_payment_rec is record(
        customer_id             com_api_type_pkg.t_medium_id
      , customer_number         com_api_type_pkg.t_name
      , account_number          com_api_type_pkg.t_account_number
      , account_currency        com_api_type_pkg.t_curr_code
      , account_status          com_api_type_pkg.t_dict_value
      , card_mask               com_api_type_pkg.t_name
      , cardholder_name         com_api_type_pkg.t_name
      , card_expiration_date    date
      , id_series               com_api_type_pkg.t_name
      , id_number               com_api_type_pkg.t_name
      , invoice_id              com_api_type_pkg.t_medium_id
      , due_date                date
      , mad                     com_api_type_pkg.t_money
      , extra_due_date          date
      , extra_mad               com_api_type_pkg.t_money
      , tad                     com_api_type_pkg.t_money
      , estimated_count         com_api_type_pkg.t_medium_id
    );
    type t_payment_tab          is table of t_payment_rec index by binary_integer;
    l_payment_tab                           t_payment_tab;

begin
    savepoint sp_unload_payment_batch;
    l_date :=  com_api_sttl_day_pkg.get_calc_date();
    prc_api_stat_pkg.log_start;

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Started with params - inst_id [#1] i_array_account_status_id [#2]'
      , i_env_param1 => i_inst_id
      , i_env_param2 => i_array_account_status_id
    );

    crd_api_external_pkg.account_statement(
        i_inst_id                 => i_inst_id
      , i_array_account_status_id => i_array_account_status_id
      , i_id_type                 => com_api_const_pkg.ID_TYPE_NATIONAL_ID -- 'IDTP0045'
      , i_invoice_date            => l_date
      , o_ref_cursor              => l_cursor
    );

    prc_api_file_pkg.open_file(
        o_sess_file_id  => l_session_file_id
    );

    prc_api_file_pkg.put_line(
        i_sess_file_id => l_session_file_id
      , i_raw_data     => cst_cfc_api_const_pkg.PAYMENT_BATCH_FILE_HEADER
    );

    loop
        fetch l_cursor
         bulk collect into l_payment_tab
        limit BULK_LIMIT;

        for i in 1..l_payment_tab.count loop
            if i = 1 then
                prc_api_stat_pkg.log_estimation(
                    i_estimated_count => l_payment_tab(i).estimated_count
                );
            end if;
            --If the card is going to expire in next 1 month then return value 0, otherwise return 1
            l_last_payment_flag :=
                case when l_payment_tab(i).card_expiration_date between trunc(add_months(l_date, 1),'MM')
                                                                    and trunc(last_day(add_months(sysdate, 1))) + 1
                     then '0'
                     else '1'
                 end;

            l_record :=
                l_payment_tab(i).id_number                                                          || COMMA_DELIMETER --National ID
             || l_payment_tab(i).customer_id                                                        || COMMA_DELIMETER --Customer ID
             || substr(l_payment_tab(i).card_mask, -4)                                              || COMMA_DELIMETER --Card mask
             || l_payment_tab(i).cardholder_name                                                    || COMMA_DELIMETER --Cardholder name
             || l_payment_tab(i).account_number                                                     || COMMA_DELIMETER --Account number
             || to_char(
                    cst_apc_crd_algo_proc_pkg.get_extra_mad(
                        i_invoice_id => l_payment_tab(i).invoice_id
                    )
                  , crd_api_const_pkg.NUMBER_FORMAT
                )                                                                                   || COMMA_DELIMETER --MAD1
             || to_char(
                    com_api_flexible_data_pkg.get_flexible_value_date(
                        i_field_name   => cst_apc_const_pkg.FLEX_FIELD_EXTRA_DUE_DATE
                      , i_entity_type  => crd_api_const_pkg.ENTITY_TYPE_INVOICE
                      , i_object_id    => l_payment_tab(i).invoice_id
                    )
                  , cst_cfc_api_const_pkg.CST_SCR_DATE_FORMAT
                )                                                                                   || COMMA_DELIMETER --Due date 1
             || to_char(l_payment_tab(i).mad, crd_api_const_pkg.NUMBER_FORMAT)                      || COMMA_DELIMETER --MAD2
             || to_char(l_payment_tab(i).due_date, cst_cfc_api_const_pkg.CST_SCR_DATE_FORMAT)       || COMMA_DELIMETER --Due date 2
             || to_char(l_payment_tab(i).tad, crd_api_const_pkg.NUMBER_FORMAT)                      || COMMA_DELIMETER
             || l_last_payment_flag
            ;
            prc_api_file_pkg.put_line(
                i_raw_data      => l_record
              , i_sess_file_id  => l_session_file_id
            );
        end loop;

        l_record_count := l_record_count + l_payment_tab.count;

        prc_api_stat_pkg.log_current(
            i_current_count  => l_record_count
          , i_excepted_count => 0
        );
        exit when l_cursor%notfound;
    end loop;
    close l_cursor;

    prc_api_file_pkg.close_file(
        i_sess_file_id      => l_session_file_id
      , i_status            => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );

    if l_record_count = 0 then
        prc_api_stat_pkg.log_estimation(
            i_estimated_count => 0
        );
    end if;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_record_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(LOG_PREFIX || ' - finished');
exception
    when others then
        rollback to sp_unload_payment_batch;

        if l_cursor%isopen then
              close l_cursor;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if l_session_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_session_file_id
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
end process_payment_inquiry_batch;

procedure process_direct_debit_data(
    i_inst_id                      in     com_api_type_pkg.t_inst_id
  , i_purpose_id                   in     com_api_type_pkg.t_short_id
) is
    PARAM_BANK_NAME          constant com_api_type_pkg.t_name := 'CBS_TRANSFER_BANK_NAME';
    PARAM_BANK_BRANCH_NAME   constant com_api_type_pkg.t_name := 'CBS_TRANSFER_BANK_BRANCH_NAME';
    PARAM_RECIPIENT_ACCOUNT  constant com_api_type_pkg.t_name := 'CBS_TRANSFER_RECIPIENT_ACCOUNT';
    PARAM_CARDHOLDER_NAME    constant com_api_type_pkg.t_name := 'CARDHOLDER_NAME';
    OPER_TYPE_CASH_BY_PHONE  constant com_api_type_pkg.t_name := 'OPTP5005';

    l_estimated_count        com_api_type_pkg.t_count     := 0;
    l_processed_count        com_api_type_pkg.t_count     := 0;
    l_sysdate                date;

    l_event_id_tab           com_api_type_pkg.t_number_tab;
    l_oper_id_tab            com_api_type_pkg.t_number_tab;
    l_customer_id_tab        com_api_type_pkg.t_number_tab;

    cursor cur_events is
        select eo.id           as event_object_id
             , eo.object_id    as oper_id
             , p.customer_id
          from evt_event_object eo
             , evt_event e
             , opr_operation o
             , opr_participant p
         where decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'CST_CFC_PRC_OUTGOING_PKG.PROCESS_DIRECT_DEBIT_DATA'
           and eo.split_hash  in (select split_hash from com_api_split_map_vw)
           and eo.entity_type  = opr_api_const_pkg.ENTITY_TYPE_OPERATION
           and eo.eff_date    <= l_sysdate
           and i_inst_id      in (eo.inst_id, ost_api_const_pkg.DEFAULT_INST)
           and e.id            = eo.event_id
           and e.event_type    = opr_api_const_pkg.EVENT_PROCESSED_SUCCESSFULLY
           and o.id            = eo.object_id
           and o.oper_type     = OPER_TYPE_CASH_BY_PHONE
           and p.oper_id       = o.id
           and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER;

begin
    savepoint sp_direct_debit_data;

    prc_api_stat_pkg.log_start;

    l_sysdate := com_api_sttl_day_pkg.get_sysdate;

    trc_log_pkg.debug(
        i_text        => 'l_sysdate [#1]'
      , i_env_param1  => to_char(l_sysdate, com_api_const_pkg.LOG_DATE_FORMAT)
    );

    select count(*)
      into l_estimated_count
      from evt_event_object eo
         , evt_event e
         , opr_operation o
         , opr_participant p
     where decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'CST_CFC_PRC_OUTGOING_PKG.PROCESS_DIRECT_DEBIT_DATA'
       and eo.split_hash  in (select split_hash from com_api_split_map_vw)
       and eo.entity_type  = opr_api_const_pkg.ENTITY_TYPE_OPERATION
       and eo.eff_date    <= l_sysdate
       and i_inst_id      in (eo.inst_id, ost_api_const_pkg.DEFAULT_INST)
       and e.id            = eo.event_id
       and e.event_type    = opr_api_const_pkg.EVENT_PROCESSED_SUCCESSFULLY
       and o.id            = eo.object_id
       and o.oper_type     = OPER_TYPE_CASH_BY_PHONE
       and p.oper_id       = o.id
       and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_estimated_count
    );

    trc_log_pkg.debug(
        i_text        => 'l_estimated_count [#1]'
      , i_env_param1  => l_estimated_count
    );

    open cur_events;

    loop
        fetch cur_events
            bulk collect into l_event_id_tab
                            , l_oper_id_tab
                            , l_customer_id_tab
            limit BULK_LIMIT;

        for i in 1 .. l_event_id_tab.count loop

            insert into aup_tag_value (
                    auth_id
                  , tag_id
                  , tag_value
                )
                select l_oper_id_tab(i)                           as auth_id
                     , aup_api_const_pkg.TAG_TRANSACTION_COMMENT  as tag_id
                     , listagg(get_text('pmo_parameter', 'label', d.param_id, 'LANGENG') || ':' || d.param_value, '/ ')
                           within group (order by d.id)           as tag_value
                  from pmo_order      o
                     , pmo_order_data d
                     , pmo_parameter  p
                 where o.customer_id  = l_customer_id_tab(i)
                   and o.purpose_id   = i_purpose_id
                   and o.is_template  = com_api_type_pkg.TRUE
                   and o.templ_status = pmo_api_const_pkg.PAYMENT_TMPL_STATUS_VALD
                   and d.order_id     = o.id
                   and p.id           = d.param_id
                   and p.param_name  in (PARAM_BANK_NAME
                                       , PARAM_BANK_BRANCH_NAME
                                       , PARAM_RECIPIENT_ACCOUNT
                                       , PARAM_CARDHOLDER_NAME);

        end loop;

        l_processed_count := l_processed_count + l_event_id_tab.count;

        prc_api_stat_pkg.log_current(
            i_current_count  => l_processed_count
          , i_excepted_count => 0
        );

        evt_api_event_pkg.process_event_object(
            i_event_object_id_tab => l_event_id_tab
        );

        exit when cur_events%notfound;
    end loop;

    close cur_events;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_processed_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
    when others then
        rollback to sp_direct_debit_data;

        if cur_events%isopen then
              close cur_events;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
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
end process_direct_debit_data;

end cst_cfc_prc_outgoing_pkg;
/
