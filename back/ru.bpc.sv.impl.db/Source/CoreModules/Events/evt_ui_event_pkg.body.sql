create or replace package body evt_ui_event_pkg as
/********************************************************* 
 *  User Interface procedures for events <br /> 
 *  Created by Filiminov A.(filimonov@bpcbt.com)  at 10.05.2011
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: evt_ui_event_pkg <br /> 
 *  @headcom 
 **********************************************************/ 
function check_process_priority(
  i_procedure_name      in      com_api_type_pkg.t_name 
  , i_event_type        in      com_api_type_pkg.t_dict_value
  , i_priority          in      com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_boolean is
    l_count             com_api_type_pkg.t_tiny_id;
begin
     select count(1)
       into l_count
       from evt_subscriber_vw e
     where e.event_type <> i_event_type
       and e.priority   = i_priority 
       and e.procedure_name = i_procedure_name;
    if l_count = 0 then
        return com_api_type_pkg.TRUE;
    else
        return com_api_type_pkg.FALSE;
    end if;          
end;

procedure add_event_type(
    o_event_type_id        out  com_api_type_pkg.t_tiny_id
  , o_seqnum               out  com_api_type_pkg.t_seqnum
  , i_event_type        in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_reason_lov_id     in      com_api_type_pkg.t_tiny_id
) is
begin
    o_event_type_id := evt_event_type_seq.nextval;
    o_seqnum := 1;
    
    insert into evt_event_type_vw(
        id
      , event_type
      , entity_type
      , seqnum
      , reason_lov_id
    ) values (
        o_event_type_id
      , i_event_type
      , i_entity_type
      , o_seqnum
      , i_reason_lov_id
    );
exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error      => 'EVENT_TYPE_ALREADY_USED'
          , i_env_param1 => i_event_type
        );
end;

procedure modify_event_type(
    i_event_type_id     in      com_api_type_pkg.t_tiny_id
  , io_seqnum           in out  com_api_type_pkg.t_seqnum
  , i_reason_lov_id     in      com_api_type_pkg.t_tiny_id
) is
begin

    update evt_event_type_vw
       set seqnum        = io_seqnum
         , reason_lov_id = i_reason_lov_id
     where id            = i_event_type_id;
     
    io_seqnum := io_seqnum + 1;    
end;

procedure remove_event_type(
    i_event_type_id     in      com_api_type_pkg.t_tiny_id  
  , i_seqnum            in      com_api_type_pkg.t_seqnum
) is
    l_count             pls_integer;
    l_event_type        com_api_type_pkg.t_dict_value;
    
begin

    select sum(cnt)
      into l_count
      from (
            select count(1) cnt
              from evt_event_type_vw a
                 , evt_event_vw b
             where a.id         = i_event_type_id
               and a.event_type = b.event_type 
            union all               
            select count(1) cnt
              from evt_subscriber_vw a
                 , evt_event_type_vw b
             where b.id         = i_event_type_id
               and a.event_type = b.event_type 
           );
        
    if l_count > 0 then
        select event_type
          into l_event_type
          from evt_event_type_vw
         where id = i_event_type_id;
         
        com_api_error_pkg.raise_error(
            i_error      => 'EVENT_TYPE_IN_USE'
          , i_env_param1 => i_event_type_id
          , i_env_param2 => l_event_type
        );
    end if;
    
    update evt_event_type_vw
       set seqnum      = i_seqnum
     where id          = i_event_type_id;
     
    delete evt_event_type_vw
     where id          = i_event_type_id;
     
    com_api_i18n_pkg.remove_text(
        i_table_name   => 'evt_event_type'
      , i_object_id    => i_event_type_id
    );
end;

procedure add_subscriber(
    o_subscr_id            out  com_api_type_pkg.t_tiny_id
  , o_seqnum               out  com_api_type_pkg.t_seqnum
  , i_procedure_name    in      com_api_type_pkg.t_name 
  , i_event_type        in      com_api_type_pkg.t_dict_value
  , i_priority          in      com_api_type_pkg.t_tiny_id
) is
begin

    select evt_subscriber_seq.nextval into o_subscr_id from dual;
    
    o_seqnum := 1;
    
    insert into evt_subscriber_vw (
        id
      , seqnum
      , procedure_name
      , event_type
      , priority
    ) values (
        o_subscr_id
      , o_seqnum
      , upper(i_procedure_name)
      , i_event_type
      , i_priority
    );
end;

procedure modify_subscriber(
    i_subscr_id         in      com_api_type_pkg.t_tiny_id 
  , io_seqnum           in out  com_api_type_pkg.t_seqnum
  , i_priority          in      com_api_type_pkg.t_tiny_id
) is
begin
    update evt_subscriber_vw
       set seqnum   = io_seqnum
         , priority = i_priority
     where id       = i_subscr_id;
     
    io_seqnum := io_seqnum + 1;
end;

procedure remove_subscriber(
    i_subscr_id         in      com_api_type_pkg.t_tiny_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
) is
    l_count             pls_integer;
    l_proc_name         com_api_type_pkg.t_name;
begin

    select count(1)
      into l_count
      from evt_subscription_vw a
     where subscr_id = i_subscr_id;

    if l_count > 0 then
        select com_api_i18n_pkg.get_text('prc_process','name', p.id, get_user_lang)
          into l_proc_name 
          from evt_subscriber_vw s
             , prc_process_vw p
         where s.id = i_subscr_id
           and s.procedure_name = p.procedure_name;
          
        com_api_error_pkg.raise_error(
            i_error      => 'EVENT_SUBSCRIBER_IN_USE'
          , i_env_param1 => i_subscr_id
          , i_env_param2 => l_proc_name
        );
    end if;
    
    update evt_subscriber_vw
       set seqnum   = i_seqnum
     where id       = i_subscr_id;
     
    delete from evt_subscriber_vw
     where id       = i_subscr_id;
end;

procedure add_event(
    o_event_id             out  com_api_type_pkg.t_tiny_id
  , o_seqnum               out  com_api_type_pkg.t_seqnum
  , i_event_type        in      com_api_type_pkg.t_dict_value
  , i_scale_id          in      com_api_type_pkg.t_tiny_id
  , i_inst_id           in      com_api_type_pkg.t_tiny_id
) is
begin

    select evt_event_seq.nextval into o_event_id from dual;
    
    o_seqnum := 1;
    
    insert into evt_event_vw (
        id
      , seqnum
      , event_type
      , scale_id
      , inst_id
      , is_cached
    ) values (
        o_event_id
      , o_seqnum
      , i_event_type
      , i_scale_id
      , i_inst_id
      , com_api_const_pkg.FALSE
    );
exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error             => 'EVENT_TYPE_ALREADY_EXIST_FOR_INST'
          , i_env_param1        => i_event_type
          , i_env_param2        => i_inst_id
        );
end;

procedure modify_event(
    i_event_id          in      com_api_type_pkg.t_tiny_id
  , io_seqnum           in out  com_api_type_pkg.t_seqnum
  , i_scale_id          in      com_api_type_pkg.t_tiny_id
) is
begin
    update evt_event_vw
       set seqnum   = io_seqnum
         , scale_id = i_scale_id
     where id       = i_event_id;
     
    io_seqnum := io_seqnum + 1;
end;

procedure remove_event(
    i_event_id          in      com_api_type_pkg.t_tiny_id  
  , i_seqnum            in      com_api_type_pkg.t_seqnum
) is
begin

    update evt_event_vw
       set seqnum = i_seqnum
     where id     = i_event_id;
     
    delete evt_event_vw
     where id     = i_event_id;

    -- atomaticaly removing substitute objects
    delete evt_subscription_vw
     where event_id = i_event_id;

    delete evt_rule_set_vw
     where event_id = i_event_id;
end;

procedure check_subscription(
  i_event_id            in      com_api_type_pkg.t_tiny_id
  , i_subscr_id         in      com_api_type_pkg.t_tiny_id
  , i_container_id      in      com_api_type_pkg.t_short_id    default null  
  , i_subscript_id      in      com_api_type_pkg.t_tiny_id     default null 
) is
begin
    for r in (    
        select a.container_id
             , a.id
          from evt_subscription_vw a
         where a.event_id       = i_event_id
           and a.subscr_id      = i_subscr_id
           and (i_subscript_id is null or i_subscript_id != a.id)
           and (
                    (i_container_id is null and a.container_id is not null)
                    or
                    (i_container_id is not null and a.container_id is null)
                )                
    ) loop
        if i_container_id is null then
            com_api_error_pkg.raise_error(
                i_error      => 'SUBSCRIPTION_WITH_CONTAINER'
              , i_env_param1 => r.container_id              
              , i_env_param2 => i_event_id
              , i_env_param3 => i_subscr_id
            );        
        else
            com_api_error_pkg.raise_error(
                i_error      => 'SUBSCRIPTION_WITHOUT_CONTAINER'
              , i_env_param1 => r.id
              , i_env_param2 => i_event_id
              , i_env_param3 => i_subscr_id
            );        
        end if;
        
        exit;
    end loop;
end;

procedure add_subscription(
    o_subscript_id         out  com_api_type_pkg.t_tiny_id
  , o_seqnum               out  com_api_type_pkg.t_seqnum
  , i_event_id          in      com_api_type_pkg.t_tiny_id
  , i_subscr_id         in      com_api_type_pkg.t_tiny_id
  , i_mod_id            in      com_api_type_pkg.t_tiny_id
  , i_container_id      in      com_api_type_pkg.t_short_id    default null  
) is
begin

    for rec in (
        select com_api_dictionary_pkg.get_article_desc(b.event_type, get_user_lang) event_name
             , com_api_i18n_pkg.get_text('PRC_PROCESS','NAME', p.id, get_user_lang) proc_name
          from evt_subscription_vw a
             , evt_subscriber_vw b
             , prc_process_vw p 
         where a.subscr_id      = b.id
           and p.procedure_name = b.procedure_name   
           and a.event_id       = i_event_id
           and a.subscr_id      = i_subscr_id
           and (
                   (i_container_id is null and not exists (select 1 
                                                             from evt_subscription_vw 
                                                            where event_id  = i_event_id 
                                                              and subscr_id = i_subscr_id 
                                                              and container_id is not null)) 
                 or (a.container_id = i_container_id)
           ) 
    )
    loop
        com_api_error_pkg.raise_error(
            i_error      => 'SUBSCRIPTION_ALREADY_EXISTS'
          , i_env_param1 => i_event_id
          , i_env_param2 => rec.event_name
          , i_env_param3 => i_subscr_id
          , i_env_param4 => rec.proc_name
        );

    end loop;

    check_subscription(
        i_event_id          => i_event_id
        , i_subscr_id       => i_subscr_id
        , i_container_id    => i_container_id  
    );

    select evt_subscription_seq.nextval into o_subscript_id from dual;

    o_seqnum := 1;

    insert into evt_subscription_vw(
        id
      , seqnum
      , event_id
      , subscr_id
      , mod_id
      , container_id
    ) values (
        o_subscript_id
      , o_seqnum
      , i_event_id
      , i_subscr_id
      , i_mod_id
      , i_container_id
    );
end;

procedure modify_subscription(
    i_subscript_id      in      com_api_type_pkg.t_tiny_id
  , io_seqnum           in out  com_api_type_pkg.t_seqnum
  , i_mod_id            in      com_api_type_pkg.t_tiny_id
  , i_container_id      in      com_api_type_pkg.t_short_id    default null  
) is
  l_event_id          com_api_type_pkg.t_tiny_id;
  l_subscr_id         com_api_type_pkg.t_tiny_id;

begin
    select event_id
         , subscr_id
      into l_event_id
         , l_subscr_id
      from evt_subscription_vw
     where id = i_subscript_id;   
      
    check_subscription(
        i_event_id          => l_event_id
        , i_subscr_id       => l_subscr_id
        , i_container_id    => i_container_id  
        , i_subscript_id    => i_subscript_id
    );

    update evt_subscription_vw
       set seqnum       = io_seqnum
         , mod_id       = i_mod_id
         , container_id = i_container_id
     where id = i_subscript_id;
     
    io_seqnum := io_seqnum + 1;
end;

procedure remove_subscription(
    i_subscript_id      in      com_api_type_pkg.t_tiny_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
) is
begin
    update evt_subscription_vw
       set seqnum = i_seqnum
     where id     = i_subscript_id;
     
    delete evt_subscription_vw
     where id     = i_subscript_id;
end;

procedure add_event_rule_set(
    o_event_rule_set_id    out  com_api_type_pkg.t_tiny_id
  , o_seqnum               out  com_api_type_pkg.t_seqnum
  , i_event_id          in      com_api_type_pkg.t_tiny_id
  , i_rule_set_id       in      com_api_type_pkg.t_tiny_id
  , i_mod_id            in      com_api_type_pkg.t_tiny_id
) is
    l_count             com_api_type_pkg.t_short_id;
begin

    select evt_rule_set_seq.nextval into o_event_rule_set_id from dual;

    o_seqnum := 1;

    insert into evt_rule_set_vw(
        id
      , seqnum
      , event_id
      , rule_set_id
      , mod_id
    ) values (
        o_event_rule_set_id
      , o_seqnum
      , i_event_id
      , i_rule_set_id
      , i_mod_id
    );
    
    select count(id)
      into l_count
      from evt_rule_set_vw
     where event_id    = i_event_id
       and rule_set_id = i_rule_set_id
       and (mod_id     = i_mod_id or (i_mod_id is null and mod_id is null))
       ;
    if l_count > 1 then
        com_api_error_pkg.raise_error(
            i_error      => 'DUPLICATE_EVENT_RULE_SET'
          , i_env_param1 => i_event_id
          , i_env_param2 => i_rule_set_id
          , i_env_param3 => i_mod_id 
          , i_env_param4 => l_count
        );
    end if;
end;

procedure modify_event_rule_set(
    i_event_rule_set_id in      com_api_type_pkg.t_tiny_id
  , io_seqnum           in out  com_api_type_pkg.t_seqnum
  , i_mod_id            in      com_api_type_pkg.t_tiny_id
) is
    l_rule_set_id       com_api_type_pkg.t_tiny_id;
    l_event_id          com_api_type_pkg.t_tiny_id;
    l_count             com_api_type_pkg.t_tiny_id;
begin
    update evt_rule_set_vw
       set seqnum        = io_seqnum
         , mod_id        = i_mod_id
     where id            = i_event_rule_set_id
 returning event_id
         , rule_set_id
      into l_event_id
         , l_rule_set_id;
 
    select count(id)
      into l_count
      from evt_rule_set_vw
     where event_id    = l_event_id
       and rule_set_id = l_rule_set_id
       and (mod_id      = i_mod_id or (i_mod_id is null and mod_id is null))
       ;
--       and (mod_id     = i_mod_id or mod_id is null);
    if l_count > 1 then
        com_api_error_pkg.raise_error(
            i_error      => 'DUPLICATE_EVENT_RULE_SET'
          , i_env_param1 => l_event_id
          , i_env_param2 => l_rule_set_id
          , i_env_param3 => i_mod_id
          , i_env_param4 => l_count 
        );
    end if;
    io_seqnum := io_seqnum + 1;
end;

procedure remove_event_rule_set(
    i_event_rule_set_id in      com_api_type_pkg.t_tiny_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
) is
begin
    update evt_rule_set_vw
       set seqnum = i_seqnum
     where id     = i_event_rule_set_id;
     
    delete evt_rule_set_vw
     where id     = i_event_rule_set_id;
end;

procedure register_event(
    i_event_type                   in      com_api_type_pkg.t_dict_value
  , i_eff_date                     in      date                           default null
  , i_entity_type                  in      com_api_type_pkg.t_dict_value
  , i_object_id                    in      com_api_type_pkg.t_long_id
  , i_inst_id                      in      com_api_type_pkg.t_inst_id     default null
  , i_split_hash                   in      com_api_type_pkg.t_tiny_id     default null
  , i_event_object_status          in      com_api_type_pkg.t_dict_value  default null
) is
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.register_event: ';
    
    l_eff_date             date;
    l_inst_id              com_api_type_pkg.t_inst_id;
    l_split_hash           com_api_type_pkg.t_tiny_id    := i_split_hash;
    l_param_tab            com_api_type_pkg.t_param_tab;
begin
    trc_log_pkg.debug (
        i_text        => LOG_PREFIX || 'Incoming event params: event_type [#1] eff_date [#2] entity_type [#3] object_id [#4] inst_id [#5] split_hash [#6'
                      || '] event_object_status [' || i_event_object_status
                      || ']'
      , i_env_param1  => i_event_type
      , i_env_param2  => to_char(i_eff_date, com_api_const_pkg.LOG_DATE_FORMAT)
      , i_env_param3  => i_entity_type
      , i_env_param4  => i_object_id
      , i_env_param5  => i_inst_id
      , i_env_param6  => i_split_hash
    );
    
    l_eff_date := nvl(l_eff_date, com_api_sttl_day_pkg.get_sysdate);
    
    l_inst_id  := nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST);
    
    if l_split_hash is null then
        begin
            l_split_hash :=com_api_hash_pkg.get_split_hash(
                               i_entity_type => i_entity_type
                             , i_object_id   => i_object_id
                             , i_mask_error  => com_api_const_pkg.TRUE
                           );
        exception
            when com_api_error_pkg.e_application_error then
                l_split_hash :=
                    com_api_hash_pkg.get_split_hash(
                        i_entity_type => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                      , i_object_id   => l_inst_id
                    );
        end;
    end if;
    
    trc_log_pkg.debug (
        i_text        => LOG_PREFIX || 'Start register event with actual params: event_type [#1] eff_date [#2] entity_type [#3] object_id [#4] inst_id [#5] split_hash [#6'
                      || '] event_object_status [' || i_event_object_status
                      || ']'
      , i_env_param1  => i_event_type
      , i_env_param2  => to_char(l_eff_date, com_api_const_pkg.LOG_DATE_FORMAT)
      , i_env_param3  => i_entity_type
      , i_env_param4  => i_object_id
      , i_env_param5  => l_inst_id
      , i_env_param6  => l_split_hash
    );
    
    evt_api_event_pkg.register_event(
        i_event_type   => i_event_type
      , i_eff_date     => l_eff_date
      , i_entity_type  => i_entity_type
      , i_object_id    => i_object_id
      , i_inst_id      => l_inst_id
      , i_split_hash   => l_split_hash
      , i_param_tab    => l_param_tab
      , i_status       => i_event_object_status
    );
    
    trc_log_pkg.debug (
        i_text        => LOG_PREFIX || 'Finish success'
    );
end register_event;

end;
/
