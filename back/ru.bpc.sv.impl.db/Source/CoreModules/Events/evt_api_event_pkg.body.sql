create or replace package body evt_api_event_pkg as
/************************************************************
 * Events API. <br />
 * Created by Filimonov A.(filimonov@bpc.ru)  at 10.05.2011 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: EVT_API_EVENT_PKG <br />
 * @headcom
 *************************************************************/

g_object_event_tab      evt_api_type_pkg.t_event_object_tab;
g_rule_event_tab        evt_api_type_pkg.t_event_object_tab;


function get_subscriber_tab(
    i_event_type        in      com_api_type_pkg.t_dict_value
  , i_inst_id           in      com_api_type_pkg.t_inst_id
) return t_subscriber_tab
result_cache
relies_on (evt_event, evt_subscriber, evt_subscription)
is
    l_subscriber_tab    t_subscriber_tab;
begin
    select a.id
         , c.mod_id
         , b.procedure_name
         , c.container_id
      bulk collect into l_subscriber_tab
      from evt_event a
         , evt_subscriber b
         , evt_subscription c
     where a.event_type = i_event_type
       and a.inst_id   in (i_inst_id, ost_api_const_pkg.DEFAULT_INST)
       and a.id         = c.event_id
       and c.subscr_id  = b.id;

    return l_subscriber_tab;
end;

function get_rule_set_tab(
    i_event_type        in      com_api_type_pkg.t_dict_value
  , i_inst_id           in      com_api_type_pkg.t_inst_id
) return t_rule_set_tab
result_cache
relies_on (evt_event, evt_rule_set)
is
    l_rule_set_tab      t_rule_set_tab;
begin
    select b.mod_id
         , b.rule_set_id
         , a.is_cached
      bulk collect into l_rule_set_tab
      from evt_event a
         , evt_rule_set b
     where a.event_type = i_event_type
       and a.inst_id   in (i_inst_id, ost_api_const_pkg.DEFAULT_INST)
       and b.event_id   = a.id;

    return l_rule_set_tab;
end;

procedure register_event(
    i_event_type        in     com_api_type_pkg.t_dict_value
  , i_eff_date          in     date
  , i_entity_type       in     com_api_type_pkg.t_dict_value
  , i_object_id         in     com_api_type_pkg.t_long_id
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_split_hash        in     com_api_type_pkg.t_tiny_id
  , i_param_tab         in     com_api_type_pkg.t_param_tab
  , i_status            in     com_api_type_pkg.t_dict_value  default null
  , i_is_used_cache     in     com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
) is
    l_count             pls_integer;
    l_eff_date          date;
    l_split_hash        com_api_type_pkg.t_tiny_id;
    l_param_tab         com_api_type_pkg.t_param_tab;
    l_param_safe        com_api_type_pkg.t_param_tab;    
    l_subscriber_tab    t_subscriber_tab;
    l_rule_set_tab      t_rule_set_tab;
begin
    trc_log_pkg.debug (
        i_text        => 'Incoming event [#1][#2][#3][#4][#5][#6]'
      , i_env_param1  => i_event_type
      , i_env_param2  => to_char(i_eff_date, com_api_const_pkg.LOG_DATE_FORMAT)
      , i_env_param3  => i_entity_type || ':' || i_object_id
      , i_env_param4  => i_inst_id
      , i_env_param5  => i_split_hash
      , i_env_param6  => i_status
    );

    l_param_safe     := evt_api_shared_data_pkg.g_params;

    l_eff_date       := nvl(i_eff_date, com_api_sttl_day_pkg.get_sysdate);

    l_split_hash     := case
                            when i_split_hash is null
                            then com_api_hash_pkg.get_split_hash(
                                     i_entity_type => i_entity_type
                                   , i_object_id   => i_object_id
                                 )
                            else i_split_hash
                        end;

    l_subscriber_tab := get_subscriber_tab(
                            i_event_type  =>  i_event_type
                          , i_inst_id     =>  i_inst_id
                        );

    l_rule_set_tab   := get_rule_set_tab(
                            i_event_type  =>  i_event_type
                          , i_inst_id     =>  i_inst_id
                        );

    if l_subscriber_tab.count  > 0
       or l_rule_set_tab.count > 0
    then
        l_param_tab := i_param_tab;
        
        rul_api_param_pkg.set_param (
            i_name              => 'EVENT_TYPE'
            , io_params         => l_param_tab
            , i_value           => i_event_type
        );
        
        rul_api_param_pkg.set_param (
            i_name              => 'EVENT_DATE'
          , io_params           => l_param_tab
          , i_value             => l_eff_date
        );
        rul_api_param_pkg.set_param (
            i_name              => 'ENTITY_TYPE'
          , io_params           => l_param_tab  
          , i_value             => i_entity_type
        );
        rul_api_param_pkg.set_param (
            i_name              => 'OBJECT_ID'
          , io_params           => l_param_tab  
          , i_value             => i_object_id
        );
        rul_api_param_pkg.set_param (
            i_name              => 'INST_ID'
          , io_params           => l_param_tab  
          , i_value             => i_inst_id
        );
        rul_api_param_pkg.set_param (
            i_name              => 'SPLIT_HASH'
          , io_params           => l_param_tab  
          , i_value             => l_split_hash
        );

        if nvl(i_is_used_cache, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
            rul_api_shared_data_pkg.load_params(
                i_entity_type  => i_entity_type
              , i_object_id    => i_object_id
              , io_params      => l_param_tab
              , i_full_set     => com_api_const_pkg.TRUE
              , i_usage        => com_api_const_pkg.FLEXIBLE_FIELD_PROC_EVNT
            );
        end if;
    end if;

    if l_subscriber_tab.count > 0 then
        for i in 1 .. l_subscriber_tab.count loop
            trc_log_pkg.debug (
                i_text          => 'Asserting modifier [#1]'
              , i_env_param1  => l_subscriber_tab(i).mod_id
            );

            if rul_api_mod_pkg.check_condition (
                  i_mod_id         => l_subscriber_tab(i).mod_id
                , i_params         => l_param_tab
               ) = com_api_const_pkg.TRUE
            then
                l_count := g_object_event_tab.count + 1;

                trc_log_pkg.debug (
                    i_text          => 'Modifier asserted OK. Buffering subscriber [#1][#2]'
                  , i_env_param1    => l_count
                  , i_env_param2    => l_subscriber_tab(i).procedure_name
                );

                g_object_event_tab(l_count).event_object_id := com_api_id_pkg.get_id(evt_event_object_seq.nextval, l_eff_date);
                g_object_event_tab(l_count).event_id        := l_subscriber_tab(i).event_id;
                g_object_event_tab(l_count).procedure_name  := l_subscriber_tab(i).procedure_name;
                g_object_event_tab(l_count).entity_type     := i_entity_type;
                g_object_event_tab(l_count).object_id       := i_object_id;
                g_object_event_tab(l_count).eff_date        := l_eff_date;
                g_object_event_tab(l_count).inst_id         := i_inst_id;
                g_object_event_tab(l_count).split_hash      := l_split_hash;
                g_object_event_tab(l_count).status          := nvl(i_status, evt_api_const_pkg.EVENT_STATUS_READY);
                g_object_event_tab(l_count).session_id      := prc_api_session_pkg.get_session_id;
                g_object_event_tab(l_count).container_id    := l_subscriber_tab(i).container_id;
                g_object_event_tab(l_count).event_type      := i_event_type;

                if l_count >= 1000 then
                    flush_events;
                end if;
            end if;
        end loop;

        flush_events;

    end if;

    if l_rule_set_tab.count > 0 then
        trc_log_pkg.debug (
            i_text          => 'Going to execute rule sets for event'
        );
     
        for i in 1 .. l_rule_set_tab.count loop
            evt_api_shared_data_pkg.clear_shared_data;
            evt_api_shared_data_pkg.g_params := l_param_tab;

            if rul_api_mod_pkg.check_condition (
                  i_mod_id         => l_rule_set_tab(i).mod_id
                , i_params         => evt_api_shared_data_pkg.g_params
               ) = com_api_const_pkg.TRUE
            then
                rul_api_process_pkg.execute_rule_set(
                    i_rule_set_id           => l_rule_set_tab(i).rule_set_id
                  , o_rules_count           => l_count
                  , io_params               => evt_api_shared_data_pkg.g_params
                );
            end if;
        end loop;
        flush_events;
    end if;
    
    evt_api_shared_data_pkg.g_params := l_param_safe;
    
end register_event;

procedure flush_events is
    l_count         pls_integer;
    l_param_safe    com_api_type_pkg.t_param_tab;
begin
    trc_log_pkg.debug (
        i_text          => 'Going to flush [#1] subscriptions'
      , i_env_param1    => g_object_event_tab.count
    );
    
    l_param_safe        := evt_api_shared_data_pkg.g_params;

    forall i in 1..g_object_event_tab.count
        insert into evt_event_object(
            id
          , event_id
          , procedure_name
          , entity_type
          , object_id
          , eff_date
          , event_timestamp
          , inst_id
          , split_hash
          , status
          , session_id
          , container_id
          , event_type
        ) values (
            g_object_event_tab(i).event_object_id
          , g_object_event_tab(i).event_id
          , g_object_event_tab(i).procedure_name
          , g_object_event_tab(i).entity_type
          , g_object_event_tab(i).object_id
          , g_object_event_tab(i).eff_date
          , systimestamp
          , g_object_event_tab(i).inst_id
          , g_object_event_tab(i).split_hash
          , nvl(g_object_event_tab(i).status, evt_api_const_pkg.EVENT_STATUS_READY)
          , g_object_event_tab(i).session_id
          , g_object_event_tab(i).container_id
          , g_object_event_tab(i).event_type
        );

    trc_log_pkg.debug (
        i_text          => '[#1] Subscriptions saved'
      , i_env_param1    => sql%rowcount
    );

    g_object_event_tab.delete;

    for i in 1..g_rule_event_tab.count loop
        evt_api_shared_data_pkg.clear_shared_data;

        evt_api_shared_data_pkg.set_param (
            i_name              => 'EVENT_TYPE'
          , i_value             => g_rule_event_tab(i).event_type
        );
        evt_api_shared_data_pkg.set_param (
            i_name              => 'EVENT_DATE'
          , i_value             => g_rule_event_tab(i).eff_date
        );
        evt_api_shared_data_pkg.set_param (
            i_name              => 'ENTITY_TYPE'
          , i_value             => g_rule_event_tab(i).entity_type
        );
        evt_api_shared_data_pkg.set_param (
            i_name              => 'OBJECT_ID'
          , i_value             => g_rule_event_tab(i).object_id
        );
        evt_api_shared_data_pkg.set_param (
            i_name              => 'INST_ID'
          , i_value             => g_rule_event_tab(i).inst_id
        );
        evt_api_shared_data_pkg.set_param (
            i_name              => 'SPLIT_HASH'
          , i_value             => g_rule_event_tab(i).split_hash
        );

        rul_api_shared_data_pkg.load_params(
            i_entity_type  => g_rule_event_tab(i).entity_type
          , i_object_id    => g_rule_event_tab(i).object_id
          , io_params      => evt_api_shared_data_pkg.g_params
          , i_full_set     => com_api_const_pkg.TRUE
        );

        rul_api_process_pkg.execute_rule_set(
            i_rule_set_id           => g_rule_event_tab(i).rule_set_id
          , o_rules_count           => l_count
          , io_params               => evt_api_shared_data_pkg.g_params
        );
    end loop;

    g_rule_event_tab.delete;
    
    evt_api_shared_data_pkg.g_params    := l_param_safe;

end flush_events;

procedure remove_event_object(
    i_event_type   in      com_api_type_pkg.t_dict_value
  , i_entity_type  in      com_api_type_pkg.t_dict_value
  , i_object_id    in      com_api_type_pkg.t_long_id
  , i_inst_id      in      com_api_type_pkg.t_inst_id)
is
    l_event_id    com_api_type_pkg.t_tiny_id;
begin
    select max(e.id)
      into l_event_id
      from evt_event e
     where e.event_type     = i_event_type
       and (
               e.inst_id    = i_inst_id
               or e.inst_id = ost_api_const_pkg.DEFAULT_INST
       );

    for i in 1..g_object_event_tab.count loop
        if   g_object_event_tab(i).event_id    = l_event_id
         and g_object_event_tab(i).entity_type = i_entity_type
         and g_object_event_tab(i).object_id   = i_object_id
         and g_object_event_tab(i).inst_id     = i_inst_id
       then
           g_object_event_tab.delete(i);
       end if;
    end loop;

    delete evt_event_object
     where event_id    = l_event_id
       and entity_type = i_entity_type
       and object_id   = i_object_id
       and inst_id     = i_inst_id;

end remove_event_object;

procedure cancel_events is
begin
    g_object_event_tab.delete;
    g_rule_event_tab.delete;
end cancel_events;

procedure register_event(
    i_event_type        in      com_api_type_pkg.t_dict_value
  , i_eff_date          in      date
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_status            in      com_api_type_pkg.t_dict_value  default null
) is
    l_param_tab         com_api_type_pkg.t_param_tab;
begin
    register_event(
        i_event_type        => i_event_type
      , i_eff_date          => i_eff_date
      , i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
      , i_inst_id           => i_inst_id
      , i_split_hash        => i_split_hash
      , i_param_tab         => l_param_tab
      , i_status            => i_status
    );
end register_event;

procedure register_event(
    i_event_type        in      com_api_type_pkg.t_dict_value
  , i_eff_date          in      date
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_param_map         in      com_param_map_tpt
  , i_status            in      com_api_type_pkg.t_dict_value  default null
) is
    l_param_tab         com_api_type_pkg.t_param_tab;
begin
    if i_param_map is not null then
        for i in 1..i_param_map.count loop
            if i_param_map(i).char_value is not null then
                rul_api_param_pkg.set_param(upper(i_param_map(i).name), i_param_map(i).char_value, l_param_tab);

            elsif i_param_map(i).number_value is not null then
                rul_api_param_pkg.set_param(upper(i_param_map(i).name), i_param_map(i).number_value, l_param_tab);

            elsif i_param_map(i).date_value is not null then
                rul_api_param_pkg.set_param(upper(i_param_map(i).name), i_param_map(i).date_value, l_param_tab);

            else
                null;
            end if;
        end loop;
    end if;

    register_event(
        i_event_type        => i_event_type
      , i_eff_date          => i_eff_date
      , i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
      , i_inst_id           => i_inst_id
      , i_split_hash        => i_split_hash
      , i_param_tab         => l_param_tab
      , i_status            => i_status
    );
end register_event;

-- Change status of event to i_event_object_status
procedure change_event_object_status(
    i_event_object_id_tab    in    com_api_type_pkg.t_number_tab
  , i_event_object_status    in    com_api_type_pkg.t_dict_value
) is
    l_session_id                   com_api_type_pkg.t_long_id;
    l_session_file_id              com_api_type_pkg.t_long_id;
begin
    if i_event_object_id_tab.count > 0 then
        l_session_id      := prc_api_session_pkg.get_session_id;
        l_session_file_id := prc_api_file_pkg.get_session_file_id;

        forall i in i_event_object_id_tab.first .. i_event_object_id_tab.last
            update evt_event_object
               set status               = i_event_object_status
                 , proc_session_id      = l_session_id
                 , proc_session_file_id = l_session_file_id
             where id = i_event_object_id_tab(i);
    end if;
end change_event_object_status;

-- Change status of event to i_event_object_status
procedure change_event_object_status(
    i_event_object_id_tab    in    num_tab_tpt
  , i_event_object_status    in    com_api_type_pkg.t_dict_value
) is
    l_session_id                   com_api_type_pkg.t_long_id;
    l_session_file_id              com_api_type_pkg.t_long_id;
begin
    if i_event_object_id_tab.count > 0 then
        l_session_id      := prc_api_session_pkg.get_session_id;
        l_session_file_id := prc_api_file_pkg.get_session_file_id;

        forall i in i_event_object_id_tab.first .. i_event_object_id_tab.last
            update evt_event_object
               set status               = i_event_object_status
                 , proc_session_id      = l_session_id
                 , proc_session_file_id = l_session_file_id
             where id = i_event_object_id_tab(i);
    end if;
end change_event_object_status;

-- Change status of event to 'Processed'
procedure process_event_object(
    i_event_object_id    in    com_api_type_pkg.t_long_id
) is
    l_session_id                   com_api_type_pkg.t_long_id;
    l_session_file_id              com_api_type_pkg.t_long_id;
begin
    l_session_id      := prc_api_session_pkg.get_session_id;
    l_session_file_id := prc_api_file_pkg.get_session_file_id;

    update evt_event_object
       set status              = evt_api_const_pkg.EVENT_STATUS_PROCESSED
         , proc_session_id      = l_session_id
         , proc_session_file_id = l_session_file_id
     where id = i_event_object_id;
end process_event_object;

-- Change status of event to 'Processed'
procedure process_event_object(
    i_event_object_id_tab    in    com_api_type_pkg.t_number_tab
) is
    l_session_id                   com_api_type_pkg.t_long_id;
    l_session_file_id              com_api_type_pkg.t_long_id;
begin
    if i_event_object_id_tab.count > 0 then
        l_session_id      := prc_api_session_pkg.get_session_id;
        l_session_file_id := prc_api_file_pkg.get_session_file_id;

        forall i in i_event_object_id_tab.first .. i_event_object_id_tab.last
            update evt_event_object
               set status               = evt_api_const_pkg.EVENT_STATUS_PROCESSED
                 , proc_session_id      = l_session_id
                 , proc_session_file_id = l_session_file_id
             where id = i_event_object_id_tab(i);
    end if;
end process_event_object;

procedure process_event_object(
    i_event_object_id_tab    in    num_tab_tpt
) is
    l_session_id                   com_api_type_pkg.t_long_id;
    l_session_file_id              com_api_type_pkg.t_long_id;
begin
    if i_event_object_id_tab.count > 0 then
        l_session_id      := prc_api_session_pkg.get_session_id;
        l_session_file_id := prc_api_file_pkg.get_session_file_id;

        forall i in i_event_object_id_tab.first .. i_event_object_id_tab.last
            update evt_event_object
               set status               = evt_api_const_pkg.EVENT_STATUS_PROCESSED
                 , proc_session_id      = l_session_id
                 , proc_session_file_id = l_session_file_id
             where id = i_event_object_id_tab(i);
    end if;
end;

procedure register_event_autonomous(
    i_event_type        in      com_api_type_pkg.t_dict_value
  , i_eff_date          in      date
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_status            in      com_api_type_pkg.t_dict_value  default null
) is
pragma autonomous_transaction;
begin
    register_event(
        i_event_type        => i_event_type
      , i_eff_date          => i_eff_date
      , i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
      , i_inst_id           => i_inst_id
      , i_split_hash        => i_split_hash
      , i_status            => i_status
    );
    
    commit;
end register_event_autonomous;

procedure register_event_autonomous(
    i_event_type        in      com_api_type_pkg.t_dict_value
  , i_eff_date          in      date
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_param_tab         in      com_api_type_pkg.t_param_tab
  , i_status            in      com_api_type_pkg.t_dict_value  default null
) is
pragma autonomous_transaction;
begin
    register_event(
        i_event_type        => i_event_type
      , i_eff_date          => i_eff_date
      , i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
      , i_inst_id           => i_inst_id
      , i_split_hash        => i_split_hash
      , i_param_tab         => i_param_tab
      , i_status            => i_status
    );
     
    commit;
end register_event_autonomous;

procedure rollback_event_object(
    i_session_id        in      com_api_type_pkg.t_long_id
)is
begin
    update evt_event_object
       set status               = evt_api_const_pkg.EVENT_STATUS_READY
         , proc_session_id      = null
         , proc_session_file_id = null
     where proc_session_id = i_session_id;

end rollback_event_object;

procedure change_split_hash(
    i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
) is
begin
    update evt_event_object
       set split_hash  = i_split_hash
     where entity_type = i_entity_type
       and object_id   = i_object_id
       and split_hash != i_split_hash;

end change_split_hash;

procedure register_event(
    i_event_type            in     com_api_type_pkg.t_dict_value
  , i_eff_date              in     date
  , i_entity_type           in     com_api_type_pkg.t_dict_value
  , i_object_id             in     com_api_type_pkg.t_long_id
  , i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_split_hash            in     com_api_type_pkg.t_tiny_id
  , i_param_tab             in     com_api_type_pkg.t_param_tab
  , i_status                in     com_api_type_pkg.t_dict_value  default null
  , i_is_used_cache         in     com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
  , i_need_postponed_event  in     com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
  , io_postponed_event_tab  in out nocopy evt_api_type_pkg.t_postponed_event_tab
) is
    l_postponed_event              evt_api_type_pkg.t_postponed_event;
begin
    if i_need_postponed_event = com_api_const_pkg.TRUE then
        add_postponed_event (
            i_event_type      => i_event_type
          , i_eff_date        => i_eff_date
          , i_object_id       => i_object_id
          , i_entity_type     => i_entity_type
          , i_inst_id         => i_inst_id
          , i_split_hash      => i_split_hash
          , i_param_tab       => i_param_tab
          , o_postponed_event => l_postponed_event
        );

        io_postponed_event_tab(io_postponed_event_tab.count + 1) := l_postponed_event;
    else
        register_event(
            i_event_type      => i_event_type
          , i_eff_date        => i_eff_date
          , i_entity_type     => i_entity_type
          , i_object_id       => i_object_id
          , i_inst_id         => i_inst_id
          , i_split_hash      => i_split_hash
          , i_param_tab       => i_param_tab
          , i_status          => i_status
          , i_is_used_cache   => i_is_used_cache
        );
    end if;
end register_event;

procedure add_postponed_event(
    i_event_type        in      com_api_type_pkg.t_dict_value
  , i_eff_date          in      date
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_param_tab         in      com_api_type_pkg.t_param_tab
  , i_status            in      com_api_type_pkg.t_dict_value  default null
  , o_postponed_event      out  evt_api_type_pkg.t_postponed_event
) is
begin
    trc_log_pkg.debug (
        i_text        => 'Add postponed event [#1][#2][#3][#4][#5][#6]'
      , i_env_param1  => i_event_type
      , i_env_param2  => to_char(i_eff_date, com_api_const_pkg.LOG_DATE_FORMAT)
      , i_env_param3  => i_entity_type || ':' || i_object_id
      , i_env_param4  => i_inst_id
      , i_env_param5  => i_split_hash
      , i_env_param6  => i_status
    );

    o_postponed_event.event_type  := i_event_type;
    o_postponed_event.eff_date    := i_eff_date;
    o_postponed_event.entity_type := i_entity_type;
    o_postponed_event.object_id   := i_object_id;
    o_postponed_event.inst_id     := i_inst_id;
    o_postponed_event.split_hash  := i_split_hash;
    o_postponed_event.param_tab   := i_param_tab;
    o_postponed_event.status      := i_status;
end add_postponed_event;

procedure register_postponed_event(
    i_postponed_event   in      evt_api_type_pkg.t_postponed_event
) is
begin
    if i_postponed_event.event_type is not null then
        register_event(
            i_event_type   => i_postponed_event.event_type
          , i_eff_date     => i_postponed_event.eff_date
          , i_entity_type  => i_postponed_event.entity_type
          , i_object_id    => i_postponed_event.object_id
          , i_inst_id      => i_postponed_event.inst_id
          , i_split_hash   => i_postponed_event.split_hash
          , i_param_tab    => i_postponed_event.param_tab
          , i_status       => i_postponed_event.status
        );
    else
        trc_log_pkg.debug (
            i_text        => 'Postponed event is not used'
        );
    end if;
end register_postponed_event;

procedure register_postponed_event(
    io_postponed_event_tab   in out nocopy evt_api_type_pkg.t_postponed_event_tab
) is
begin
    if io_postponed_event_tab is not null then
        for i in 1 .. io_postponed_event_tab.count loop
            register_postponed_event(
                i_postponed_event => io_postponed_event_tab(i)
            );
        end loop;
    end if;
end register_postponed_event;

function check_event_type(
    i_action            in      com_api_type_pkg.t_name
) return com_api_type_pkg.t_boolean
is
    l_result    com_api_type_pkg.t_boolean;
begin
    if i_action is null or length(i_action) > 8 then
        l_result := com_api_const_pkg.FALSE;
    else
        l_result :=
            com_ui_lov_pkg.check_lov_value(
                i_lov_id => evt_api_const_pkg.LOV_ID_EVENT_TYPES
              , i_value  => i_action
            );
    end if;
    
    return l_result;
    
end check_event_type;

end evt_api_event_pkg;
/
