create or replace package body app_process_pkg as
/*********************************************************
 *  Application processing API  <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 01.10.2009 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: app_process_pkg  <br />
 *  @headcom
 **********************************************************/

g_seqnum    com_api_type_pkg.t_seqnum;

procedure prepare(
    i_appl_id           in      com_api_type_pkg.t_long_id
) is
begin
    com_api_sttl_day_pkg.set_sysdate;

    app_api_error_pkg.remove_error_elements(
        i_appl_id            => i_appl_id
      , i_skip_saver_errors  => com_api_const_pkg.TRUE
    );

end prepare;

procedure finalize(
    i_appl_id           in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_is_used_savepoint in      com_api_type_pkg.t_boolean     default com_api_type_pkg.FALSE
  , i_reject_code       in      com_api_type_pkg.t_dict_value  default null
  , o_appl_status          out  com_api_type_pkg.t_dict_value
) is
    l_param_tab                 com_api_type_pkg.t_param_tab;
    l_is_used_savepoint         com_api_type_pkg.t_boolean    := nvl(i_is_used_savepoint, com_api_type_pkg.FALSE);
begin
    trc_log_pkg.debug(
        i_text => 'app_process_pkg.finalize, appl_id = ' || i_appl_id || ' i_reject_code=' || i_reject_code
    );
    l_param_tab.delete();

    if app_api_error_pkg.g_app_errors.count > 0
    then
        o_appl_status := app_api_const_pkg.APPL_STATUS_PROC_FAILED;

        -- we rollback changes, maded by app process package such as new contracts etc
        -- but do not rollback changes when the "Error" blocks is removed in current application
        if l_is_used_savepoint = com_api_type_pkg.TRUE then
            rollback to sp_before_app_process;
        end if;

        app_api_error_pkg.add_errors_to_app_data;

    else
        o_appl_status := app_api_const_pkg.APPL_STATUS_PROC_SUCCESS;
    end if;

    evt_api_event_pkg.register_event (
        i_event_type    => case
                               when o_appl_status = app_api_const_pkg.APPL_STATUS_PROC_SUCCESS and i_reject_code is null
                                   then app_api_const_pkg.EVENT_APPL_PROCESS_SUCCESS
                               when o_appl_status = app_api_const_pkg.APPL_STATUS_PROC_SUCCESS and i_reject_code is not null
                                   then app_api_const_pkg.EVENT_APPL_CUST_REJECTED
                               when o_appl_status = app_api_const_pkg.APPL_STATUS_PROC_FAILED
                                   then app_api_const_pkg.EVENT_APPL_PROCESS_FAILED
                           end
      , i_eff_date      => com_api_sttl_day_pkg.get_sysdate
      , i_param_tab     => l_param_tab
      , i_entity_type   => app_api_const_pkg.ENTITY_TYPE_APPLICATION
      , i_object_id     => i_appl_id
      , i_inst_id       => i_inst_id
      , i_split_hash    => com_api_hash_pkg.get_split_hash(i_appl_id)
    );

    -- this prc changed app status in both APP_DATA and APP_APPLICATION tables, as needed for web interface
    app_ui_application_pkg.modify_application(
        i_appl_id           => i_appl_id
      , io_seqnum           => g_seqnum
      , i_appl_status       => o_appl_status
      , i_reject_code       => i_reject_code
      , i_resp_sess_file_id => null
    );

    com_api_sttl_day_pkg.unset_sysdate;
    trc_log_pkg.debug(
        i_text => 'app_process_pkg.finalize done'
    );
end finalize;

procedure processing(
    i_appl_id           in      com_api_type_pkg.t_long_id
  , i_forced_processing in      com_api_type_pkg.t_boolean     default null
  , o_appl_status          out  com_api_type_pkg.t_dict_value
  , i_run_mode          in      com_api_type_pkg.t_tiny_id     default null
) is
    l_appl_data_id              com_api_type_pkg.t_long_id;
    l_appl_type                 com_api_type_pkg.t_dict_value;
    l_appl_status               com_api_type_pkg.t_dict_value;
    l_reject_code               com_api_type_pkg.t_dict_value;
    l_param_tab                 com_api_type_pkg.t_param_tab;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_is_used_savepoint         com_api_type_pkg.t_boolean    := com_api_type_pkg.FALSE;
begin
    trc_log_pkg.debug(
        i_text => 'app_process_pkg.processing start ' || i_appl_id
    );
    l_param_tab.delete();
    
    -- check priviledge 
    if nvl(i_forced_processing, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE then    
    
        if acm_api_privilege_pkg.check_privs_user (
            i_user_id => com_ui_user_env_pkg.get_user_id
          , i_priv_id => app_api_const_pkg.PROCESS_APPLICATION_FORCE
        ) = com_api_type_pkg.FALSE then

            com_api_error_pkg.raise_error(
                i_error         => 'USER_HAVE_NO_SUCH_PRIVILEGE'
              , i_env_param1    => com_ui_user_env_pkg.get_user_name
              , i_env_param2    => get_text('ACM_PRIVILEGE', 'LABEL', app_api_const_pkg.PROCESS_APPLICATION_FORCE, get_user_lang)
            );           
        end if;    
    end if;
    
    begin
        select appl_type
             , appl_status
             , reject_code
             , inst_id
             , seqnum
          into l_appl_type
             , l_appl_status
             , l_reject_code
             , l_inst_id
             , g_seqnum
          from app_application_vw
         where id = i_appl_id
           for update nowait;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'APPLICATION_NOT_FOUND'
              , i_env_param1    => i_appl_id
            );
        when com_api_error_pkg.e_resource_busy then
            com_api_error_pkg.raise_error(
                i_error         => 'APPLICATION_IN_PROCESS'
              , i_env_param1    => i_appl_id
            );
    end;
    
    ost_api_institution_pkg.check_status(
        i_inst_id     => l_inst_id
      , i_data_action => com_api_const_pkg.DATA_ACTION_NON_FIN_PROC
    );

    if l_appl_status = app_api_const_pkg.APPL_STATUS_READY_FOR_REVIEW
        and l_appl_type = app_api_const_pkg.APPL_TYPE_FIN_REQUEST
    then
        null;
    else
        if l_appl_status != app_api_const_pkg.APPL_STATUS_PROC_READY then
            com_api_error_pkg.raise_error(
                i_error      => 'APPLICATION_COULD_NOT_BE_PROCESSED'
              , i_env_param1 => l_appl_status
            );
        end if;
    end if;

    app_api_application_pkg.get_appl_data(
        i_appl_id        => i_appl_id
    );

    prepare(
        i_appl_id        => i_appl_id
    );

    -- we fix deleting old error messages using savepoint;
    l_is_used_savepoint := com_api_type_pkg.TRUE;
    savepoint sp_before_app_process;

    trc_log_pkg.set_object(
        i_entity_type  => app_api_const_pkg.ENTITY_TYPE_APPLICATION
      , i_object_id    => i_appl_id
    );

    begin
        if l_appl_type = app_api_const_pkg.APPL_TYPE_ACQUIRING then
            aap_api_application_pkg.process_application(
                i_appl_id    => i_appl_id
            );

        elsif l_appl_type = app_api_const_pkg.APPL_TYPE_ISSUING then
            begin
                trc_log_pkg.debug(
                    i_text       => 'l_reject_code [#1]'
                  , i_env_param1 => l_reject_code
                );
                if l_reject_code is null then
                    iap_api_application_pkg.process_application(
                        i_appl_id    => i_appl_id
                    );
                else
                    iap_api_application_pkg.process_rejected_application(
                        i_appl_id    => i_appl_id
                    );
                end if;
            end;
        elsif l_appl_type = app_api_const_pkg.APPL_TYPE_PAYMENT_ORDERS then
            pmo_api_application_pkg.process_application(
                i_appl_id    => i_appl_id
            );

        elsif l_appl_type = app_api_const_pkg.APPL_TYPE_USER_MANAGEMENT then
            acm_api_application_pkg.process_application(
                i_appl_id    => i_appl_id
            );

            if i_run_mode is null then  -- Run from Web-service
                acm_api_user_pkg.refresh_mview;
                -- New savepoint after commit becouse "refresh_mview" contains commit
                savepoint sp_before_app_process;
            end if;

        elsif l_appl_type = app_api_const_pkg.APPL_TYPE_FIN_REQUEST then
            orq_api_application_pkg.process_request(
                i_appl_id    => i_appl_id
            );

        elsif l_appl_type in (app_api_const_pkg.APPL_TYPE_ISS_PRODUCT, app_api_const_pkg.APPL_TYPE_ACQ_PRODUCT) then
            pap_api_application_pkg.process_application(
                i_appl_id    => i_appl_id
            );

        elsif l_appl_type = app_api_const_pkg.APPL_TYPE_INSTITUTION then
            ost_api_application_pkg.process_application(
                i_appl_id    => i_appl_id
            );

            if i_run_mode is null then  -- Run from Web-service
                acm_api_user_pkg.refresh_mview;
                -- New savepoint after commit becouse "refresh_mview" contains commit
                savepoint sp_before_app_process;
            end if;

        elsif l_appl_type = app_api_const_pkg.APPL_TYPE_QUESTIONARY then
            svy_api_application_pkg.process_application;

        elsif l_appl_type = app_api_const_pkg.APPL_TYPE_CAMPAIGN then
            cpn_api_application_pkg.process_application(
                i_appl_id    => i_appl_id
            );

        else
            app_api_application_pkg.get_appl_data_id(
                i_element_name  => 'APPLICATION'
              , i_parent_id     => null
              , o_appl_data_id  => l_appl_data_id
            );

            app_api_error_pkg.raise_error(
                i_error         => 'UNKNOWN_APPLICATION_TYPE'
              , i_env_param1    => l_appl_type
              , i_element_name  => 'APPLICATION'
              , i_appl_data_id  => l_appl_data_id
            );
        end if;
    exception
        when com_api_error_pkg.e_stop_appl_processing then
            trc_log_pkg.debug('e_stop_appl_processing exception was handled');
    end;

    finalize(
        i_appl_id           => i_appl_id
      , i_inst_id           => l_inst_id
      , i_is_used_savepoint => l_is_used_savepoint
      , i_reject_code       => l_reject_code
      , o_appl_status       => o_appl_status
    );

    trc_log_pkg.debug(
        i_text => 'app processing done'
    );
    
    trc_log_pkg.clear_object;
exception
    when others then
        app_api_error_pkg.add_errors_to_app_data;
        trc_log_pkg.debug(sqlerrm);

        if l_is_used_savepoint = com_api_type_pkg.TRUE then
            rollback to sp_before_app_process;
        end if;

        evt_api_event_pkg.register_event_autonomous(
            i_event_type    => app_api_const_pkg.EVENT_APPL_PROCESS_FAILED
          , i_eff_date      => com_api_sttl_day_pkg.get_sysdate
          , i_param_tab     => l_param_tab
          , i_entity_type   => app_api_const_pkg.ENTITY_TYPE_APPLICATION
          , i_object_id     => i_appl_id
          , i_inst_id       => l_inst_id
          , i_split_hash    => com_api_hash_pkg.get_split_hash(app_api_const_pkg.ENTITY_TYPE_APPLICATION, i_appl_id)
        );

        trc_log_pkg.clear_object;

        com_api_error_pkg.raise_fatal_error(
            i_error       => 'UNHANDLED_EXCEPTION'
          , i_env_param1  => sqlerrm
          , i_env_param2  => i_appl_id
          , i_env_param3  => l_inst_id
        );
end processing;

end app_process_pkg;
/
