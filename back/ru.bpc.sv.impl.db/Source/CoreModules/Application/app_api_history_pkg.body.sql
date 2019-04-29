create or replace package body app_api_history_pkg is

procedure add_history (
    i_appl_id               in com_api_type_pkg.t_long_id
  , i_action                in com_api_type_pkg.t_name
  , i_comments              in com_api_type_pkg.t_full_desc
  , i_new_appl_status       in com_api_type_pkg.t_dict_value
  , i_old_appl_status       in com_api_type_pkg.t_dict_value
  , i_new_reject_code       in com_api_type_pkg.t_dict_value
  , i_old_reject_code       in com_api_type_pkg.t_dict_value
) is
    l_comments              com_api_type_pkg.t_full_desc;
    l_event_type            com_api_type_pkg.t_dict_value;
    l_change_date           date;
    l_params                com_api_type_pkg.t_param_tab;
    l_id                    com_api_type_pkg.t_long_id;
    l_user_id               com_api_type_pkg.t_short_id;
    l_change_action         com_api_type_pkg.t_name;
begin
        
    trc_log_pkg.debug(
        i_text       => 'app_api_history_pkg.add_history Start with params: i_appl_id[#1], i_action[#2], i_new_appl_status[#3], i_old_appl_status[#4], i_new_reject_code[#5], i_old_reject_code[#6]'
      , i_env_param1 => i_appl_id
      , i_env_param2 => i_action
      , i_env_param3 => i_new_appl_status
      , i_env_param4 => i_old_appl_status
      , i_env_param5 => i_new_reject_code
      , i_env_param6 => i_old_reject_code
    );

    l_change_date := com_api_sttl_day_pkg.get_sysdate;

    if i_new_appl_status = app_api_const_pkg.APPL_STATUS_PROC_FAILED
       and i_comments is null
    then
        for rec in (
            select a.element_value
              from app_ui_data_vw a
             where a.name    = 'ERROR_DESC'
               and a.appl_id = i_appl_id
        ) loop
            l_comments := rec.element_value;
            exit;
        end loop;
    end if;

    if i_new_appl_status     != i_old_appl_status
       or i_new_reject_code  != i_old_reject_code
       or (i_new_reject_code is not null and i_old_reject_code is null)
       or (i_new_reject_code is null     and i_old_reject_code is not null)
    then
        begin
            select aft.event_type
              into l_event_type
              from app_application     ap
                 , app_flow_stage      afs
                 , app_flow_transition aft
             where ap.id                     = i_appl_id
               and afs.flow_id               = ap.flow_id
               and afs.appl_status           = i_new_appl_status
               and nvl(afs.reject_code, 'DUMMY') = nvl (i_new_reject_code, 'DUMMY')
               and aft.transition_stage_id   = afs.id
               and aft.event_type           is not null
               and rownum                    = 1;

        exception
            when no_data_found then
                trc_log_pkg.debug(
                    i_text => 'app_api_history_pkg.add_history: no transition is found'
                ); 
        end;
    end if;

    l_id      := com_api_id_pkg.get_id(app_history_seq.nextval, i_appl_id);
    l_user_id := acm_api_user_pkg.get_user_id;

    if evt_api_event_pkg.check_event_type(i_action => i_action) = com_api_const_pkg.TRUE then
        l_change_action := i_action;
    else
        l_change_action := l_event_type;
    end if;

    insert into app_history_vw (
        id
      , seqnum
      , appl_id
      , change_date
      , change_user
      , change_action
      , appl_status
      , comments
      , reject_code
    ) values (
        l_id
      , 1
      , i_appl_id
      , l_change_date
      , l_user_id
      , l_change_action
      , i_new_appl_status
      , nvl(i_comments,   l_comments)
      , i_new_reject_code
    );
        
    l_params := evt_api_shared_data_pkg.g_params;
        
    if l_event_type is not null then
            
        evt_api_event_pkg.register_event(
            i_event_type        => l_event_type
          , i_eff_date          => l_change_date
          , i_entity_type       => app_api_const_pkg.ENTITY_TYPE_APPLICATION
          , i_object_id         => i_appl_id
          , i_inst_id           => null
          , i_split_hash        => null
          , i_param_tab         => l_params
        );
            
    end if;
        
    if i_action is not null
       and (l_event_type is null or i_action != l_event_type)
    then
            
        evt_api_event_pkg.register_event(
            i_event_type        => i_action
          , i_eff_date          => l_change_date
          , i_entity_type       => app_api_const_pkg.ENTITY_TYPE_APPLICATION
          , i_object_id         => i_appl_id
          , i_inst_id           => null
          , i_split_hash        => null
          , i_param_tab         => l_params
        );
            
    end if;
        
end add_history;

procedure remove_history(
    i_id                  in     com_api_type_pkg.t_long_id
) is
begin

    delete from app_history_vw
     where id = i_id;

end remove_history;

function get_previous_status (
    i_appl_id               in com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_dict_value
is
    PREVIOUS constant   com_api_type_pkg.t_byte_id := 2;
    l_result            com_api_type_pkg.t_dict_value;
begin
    select appl_status
      into l_result
      from (select row_number() over(order by a.id desc) rnk
                 , a.appl_status
              from app_history a
             where a.appl_id = i_appl_id
           )
     where rnk = PREVIOUS;
    return l_result;
exception
    when no_data_found then
        return null;
    when others then
        raise;
end get_previous_status;
    
end app_api_history_pkg;
/
