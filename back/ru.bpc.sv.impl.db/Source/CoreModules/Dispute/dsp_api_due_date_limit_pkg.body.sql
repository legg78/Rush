create or replace package body dsp_api_due_date_limit_pkg is
/**************************************************
 *  Dispute due date limits API <br />
 *  Created by Alalykin A.(alalykin@bpcbt.com) at 02.12.2016 <br />
 *  Module: DSP_API_DUE_DATE_LIMIT_PKG <br />
 *  @headcom
 ***************************************************/

/*
 * Get a due date limit for a dispute application.
 */
function get_due_date(
    i_standard_id           in     com_api_type_pkg.t_tiny_id
  , i_message_type          in     com_api_type_pkg.t_dict_value
  , i_eff_date              in     date
  , i_is_incoming           in     com_api_type_pkg.t_boolean
  , i_usage_code            in     com_api_type_pkg.t_byte_char  default null
  , i_reason_code           in     com_api_type_pkg.t_dict_value default null
) return date
is
    l_days_count                   com_api_type_pkg.t_tiny_id;
    l_is_incoming                  com_api_type_pkg.t_boolean;
    l_reason_code                  com_api_type_pkg.t_name;
begin
    l_is_incoming := nvl(i_is_incoming, com_api_const_pkg.FALSE);
    
    begin
        select min(nvl(resolve_due_date, respond_due_date))
               keep (
                   dense_rank first order by
                       case reason_code
                            when dsp_api_const_pkg.DUE_DATE_REASON_CODE_ANY
                            then '99999999'
                            else reason_code
                        end
               )
          into l_days_count
          from dsp_due_date_limit t
         where standard_id   = i_standard_id
           and message_type  = i_message_type
           and is_incoming   = l_is_incoming
           and reason_code  in (i_reason_code, dsp_api_const_pkg.DUE_DATE_REASON_CODE_ANY)
           and (respond_due_date is not null or resolve_due_date is not null)
           and ( (i_usage_code is null and usage_code is null)
              or usage_code   = i_usage_code
               );
    exception
        when no_data_found then
            null;
    end;

    return trunc(i_eff_date) + l_days_count;
end get_due_date;

/*
 * Update value of dispute application element DUE_DATE, switch a notification cycle (optional).
 * @i_dispute_id     - it is used for searching an application if @i_appld_is is not specified
 * @i_expir_notif    - if TRUE then set/switch associated notification cycle
 * @i_due_date       - a base for calculation a new (updated) due date
 */
procedure update_due_date(
    i_dispute_id            in     com_api_type_pkg.t_long_id
  , i_appl_id               in     com_api_type_pkg.t_long_id
  , i_due_date              in     date
  , i_expir_notif           in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
  , i_mask_error            in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
) is
    LOG_PREFIX            constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.update_due_date ';
    e_application_not_found        exception;
    l_dsp_expir_notif_gap          com_api_type_pkg.t_tiny_id;
    l_inst_id                      com_api_type_pkg.t_inst_id;
    l_new_due_date                 date;
    l_cycle_id                     com_api_type_pkg.t_short_id;
    l_prev_date                    date;
    l_next_date                    date;
    l_case_rec                     csm_api_type_pkg.t_csm_case_rec;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' << i_appl_id [#1], i_dispute_id [#2]'
                                   || ', i_due_date [#3], i_expir_notif [#4], i_mask_error [#5]'
      , i_env_param1 => i_appl_id
      , i_env_param2 => i_dispute_id
      , i_env_param3 => i_due_date
      , i_env_param4 => i_expir_notif
      , i_env_param5 => i_mask_error
    );
    
    if i_due_date is null then
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || ' Base due date [i_due_date] is not defined, EXIT'
        );
        return;
    end if;
    
    if i_appl_id is not null then
        csm_api_case_pkg.get_case(
            i_case_id     => i_appl_id
          , o_case_rec    => l_case_rec
          , i_mask_error  => i_mask_error
        );
    else
        csm_api_case_pkg.get_case(
            i_dispute_id  => i_dispute_id
          , o_case_rec    => l_case_rec
          , i_mask_error  => i_mask_error
        );
    end if;

    l_inst_id := com_ui_user_env_pkg.get_user_inst();

    trc_log_pkg.debug(
        i_text => 'l_inst_id [' || l_inst_id || ']'
    );
    
    csm_api_case_pkg.set_due_date(
        i_case_id   => l_case_rec.case_id
      , i_due_date  => trunc(i_due_date)
      , io_seqnum   => l_case_rec.seqnum
    );

    -- Dispute expiration notification gap in days
    l_dsp_expir_notif_gap :=
        set_ui_value_pkg.get_inst_param_n(
            i_param_name => dsp_api_const_pkg.DISPUTE_EXPIR_NOTIF_GAP
          , i_inst_id    => l_inst_id
        );
    trc_log_pkg.debug(
        i_text => 'l_dsp_expir_notif_gap [' || l_dsp_expir_notif_gap || ']'
    );

    if nvl(l_dsp_expir_notif_gap, 0) > 0 and i_expir_notif = com_api_const_pkg.TRUE then
        l_new_due_date := trunc(i_due_date) - l_dsp_expir_notif_gap;

        trc_log_pkg.debug(
            i_text => 'l_new_due_date [' || l_new_due_date || ']'
        );

        if i_expir_notif = com_api_const_pkg.TRUE then
            -- Register a new cycle if it doesn't exist
            fcl_api_cycle_pkg.get_cycle_date(
                i_cycle_type   => dsp_api_const_pkg.CYCLE_TYPE_EXPIR_NOTIF_GAP
              , i_entity_type  => app_api_const_pkg.ENTITY_TYPE_APPLICATION
              , i_object_id    => l_case_rec.case_id
              , i_split_hash   => l_case_rec.split_hash
              , i_add_counter  => com_api_type_pkg.FALSE
              , o_prev_date    => l_prev_date
              , o_next_date    => l_next_date
            );

            if l_next_date is not null then
                fcl_ui_cycle_pkg.add_cycle(
                    i_cycle_type    => dsp_api_const_pkg.CYCLE_TYPE_EXPIR_NOTIF_GAP
                  , i_length_type   => fcl_api_const_pkg.CYCLE_LENGTH_DAY
                  , i_cycle_length  => l_dsp_expir_notif_gap
                  , i_trunc_type    => null
                  , i_inst_id       => l_inst_id
                  , i_workdays_only => null
                  , o_cycle_id      => l_cycle_id
                );
            end if;

            -- Set/update new due date
            fcl_api_cycle_pkg.add_cycle_counter(
                i_cycle_type   => dsp_api_const_pkg.CYCLE_TYPE_EXPIR_NOTIF_GAP
              , i_entity_type  => app_api_const_pkg.ENTITY_TYPE_APPLICATION
              , i_object_id    => l_case_rec.case_id
              , i_split_hash   => l_case_rec.split_hash
              , i_next_date    => l_new_due_date
              , i_inst_id      => l_inst_id
            );
        end if;
    end if;

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || ' >> l_new_due_date [' || l_new_due_date || ']'
    );
exception
    when others then
        if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE then
            if nvl(i_mask_error, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE then
                raise;
            else
                trc_log_pkg.debug(
                    i_text => LOG_PREFIX || ' >> error was masked: '
                                         || com_api_error_pkg.get_last_message()
                );
            end if;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_type_pkg.TRUE then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end update_due_date;

end;
/
