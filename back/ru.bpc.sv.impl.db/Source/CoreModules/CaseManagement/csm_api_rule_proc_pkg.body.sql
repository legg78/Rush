create or replace package body csm_api_rule_proc_pkg is
/**********************************************************
 * Rules for disputes <br />
 *  <br />
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 08.12.2016 <br />
 * <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: CSM_API_RULE_PROC_PKG
 * @headcom
 **********************************************************/

procedure send_dispute_user_notification
is
    l_object_id                     com_api_type_pkg.t_long_id;
    l_event_date                    date;
    l_entity_type                   com_api_type_pkg.t_dict_value;
    l_event_type                    com_api_type_pkg.t_dict_value;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_mask_error                    com_api_type_pkg.t_boolean;
    
    l_user_list                     num_tab_tpt;
    l_role_list                     num_tab_tpt;

    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.send_dispute_user_notification: ';
begin

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'start'
    );

    l_object_id := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');
    l_entity_type := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_event_type := evt_api_shared_data_pkg.get_param_char('EVENT_TYPE');
    l_event_date := evt_api_shared_data_pkg.get_param_date('EVENT_DATE');
    l_inst_id := evt_api_shared_data_pkg.get_param_num('INST_ID');
    l_mask_error := evt_api_shared_data_pkg.get_param_num('MASK_ERROR', com_api_type_pkg.TRUE, com_api_type_pkg.TRUE);
    
    if l_event_type = dsp_api_const_pkg.EVENT_DISPUTE_ASSIGNED_USER
       and l_entity_type = app_api_const_pkg.ENTITY_TYPE_APPLICATION
    then
        
        select user_id
          bulk collect
          into l_user_list
          from
          (
               (select user_id
                  from
                  (
                       select ah.change_user as user_id
                         from app_history ah
                        where ah.appl_id = l_object_id
                        order by
                              ah.id desc
                  )
                 where rownum = 1
               )
               
               union
               
               (select user_id
                  from app_application ap
                 where ap.id = l_object_id
               )
           );
           
    elsif l_event_type in (dsp_api_const_pkg.EVENT_DISPUTE_ACCEPT
                         , dsp_api_const_pkg.EVENT_DISPUTE_REJECT)
       and l_entity_type = app_api_const_pkg.ENTITY_TYPE_APPLICATION
    then

        select created_by_user_id
          bulk collect
          into l_user_list
          from csm_case
         where id = l_object_id;

    else
        if l_event_type = dsp_api_const_pkg.EVENT_ADD_DISPUTE_COMMENT
           and l_entity_type = app_api_const_pkg.ENTITY_TYPE_APPLICATION
        then

            select afs.role_id
              bulk collect
              into l_role_list
              from app_application ap
                 , (select row_number() over(order by ah.id desc) as rank_app_history
                         , ah.appl_status
                         , ah.reject_code
                      from app_history ah
                     where ah.appl_id = l_object_id
                   ) aph
                 , app_flow_stage afs
                 , app_flow_transition aft
             where ap.id = l_object_id
               and afs.flow_id = ap.flow_id
               and afs.appl_status = aph.appl_status
               and afs.reject_code = aph.reject_code
               and aph.rank_app_history = 1
               and aft.event_type = l_event_type
               and aft.transition_stage_id = afs.id;
        end if;

        select com_api_array_pkg.conv_array_elem_v(
                   i_array_type_id => 1055
                 , i_array_id      => 10000077
                 , i_inst_id       => l_inst_id
                 , i_elem_value    => team_id
               )
          bulk collect
          into l_user_list
          from csm_case
         where id = l_object_id;

    end if;
    
    begin
        ntf_api_notification_pkg.make_user_notification (
              i_inst_id      => l_inst_id
            , i_event_type   => l_event_type
            , i_entity_type  => l_entity_type
            , i_object_id    => l_object_id
            , i_eff_date     => l_event_date
            , i_user_list    => l_user_list
            , i_role_list    => l_role_list
        );
    exception
        when others then
            if nvl(l_mask_error, com_api_type_pkg.TRUE) = com_api_type_pkg.TRUE then
                
                trc_log_pkg.debug(
                      i_text        => 'Make notification error intercepted: [#1]'
                    , i_env_param1  => sqlerrm
                );
                
            else
                
                raise;
                
            end if;
    end;
    
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'end'
    );

end send_dispute_user_notification;

procedure calculate_hide_date
is
    l_object_id                     com_api_type_pkg.t_long_id;
    l_entity_type                   com_api_type_pkg.t_dict_value;
    l_event_date                    date;
    l_hide_gap                      com_api_type_pkg.t_long_id;
begin
    l_object_id := evt_api_shared_data_pkg.get_param_num('OBJECT_ID');
    l_entity_type := evt_api_shared_data_pkg.get_param_char('ENTITY_TYPE');
    l_event_date := evt_api_shared_data_pkg.get_param_date('EVENT_DATE');
    l_hide_gap := set_ui_value_pkg.get_system_param_n('DISPUTE_CASE_AUTO_HIDE_GAP');
    
    l_event_date := l_event_date + nvl(l_hide_gap, 30);
    trc_log_pkg.debug(
        i_text       => 'calculate_hide_date: set hide date to [#1]'
      , i_env_param1 => l_event_date
    );

    update csm_case_vw
       set hide_date   = l_event_date
         , unhide_date = null
     where id          = l_object_id;

end calculate_hide_date;

end csm_api_rule_proc_pkg;
/
