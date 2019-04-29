create or replace package body prd_ui_service_pkg is
/*********************************************************
*  UI for services  <br />
*  Created by Kopachev D.(kopachev@bpcbt.com)  at 15.11.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: PRD_UI_SERVICE_PKG <br />
*  @headcom
**********************************************************/

procedure check_already_used (
    i_id                       in com_api_type_pkg.t_short_id
) is
    l_count                    com_api_type_pkg.t_count := 0;
begin
    select count(1)
      into l_count
      from (
          select service_id from prd_attribute_value_vw where service_id = i_id union all
          select service_id from prd_product_service_vw where service_id = i_id union all
          select service_id from prd_service_object_vw where service_id = i_id
      );

    if l_count > 0 then
        com_api_error_pkg.raise_error (
            i_error       => 'SERVICE_IS_ALREADY_USED'
          , i_env_param1  => i_id
        );
    end if;
end check_already_used;

procedure check_duplicate (
    i_id        in      com_api_type_pkg.t_short_id
  , i_inst_id   in      com_api_type_pkg.t_inst_id
  , i_lang      in      com_api_type_pkg.t_dict_value
  , i_label     in      com_api_type_pkg.t_name
) is
    l_check_cnt         com_api_type_pkg.t_count := 0;
begin
    select count(id)
      into l_check_cnt
      from (
        select id
             , inst_id
             , get_text (
                  i_table_name    => 'prd_service'
                , i_column_name => 'label'
                , i_object_id   => id
                , i_lang        => i_lang
               ) label
          from prd_service_vw
        ) t
    where t.inst_id = i_inst_id
      and t.label   = i_label
      and (t.id    != i_id or i_id is null);

    if l_check_cnt > 0 then
        com_api_error_pkg.raise_error (
            i_error       => 'DUPLICATE_SERVICE_NAME'
          , i_env_param1  => i_label
          , i_env_param2  => i_inst_id
        );
    end if;
end check_duplicate;

procedure check_min_count(
    i_service_id    in     com_api_type_pkg.t_short_id
  , i_contract_id   in     com_api_type_pkg.t_medium_id
) is
    l_count                com_api_type_pkg.t_count := 0;
    l_min_count            com_api_type_pkg.t_count := 0;
    l_product_id           com_api_type_pkg.t_short_id;
begin
    select product_id
      into l_product_id
      from prd_contract_vw
     where id = i_contract_id;

    select min_count
      into l_min_count
      from prd_product_service_vw ps
     where ps.service_id  = i_service_id
       and ps.product_id  = l_product_id;

    select count(1)
      into l_count
      from prd_service_object_vw so
     where so.contract_id = i_contract_id
       and so.service_id  = i_service_id;

    if l_count < l_min_count then
        com_api_error_pkg.raise_error(
            i_error      => 'NOT_ENOUGH_SERVICES'
          , i_env_param1 => l_count
          , i_env_param2 => l_min_count
        );
    end if;
end check_min_count;

procedure check_max_count(
    i_service_id    in     com_api_type_pkg.t_short_id
  , i_contract_id   in     com_api_type_pkg.t_medium_id
) is
    l_count        com_api_type_pkg.t_count := 0;
    l_max_count    com_api_type_pkg.t_count := 0;
    l_product_id   com_api_type_pkg.t_short_id;
begin
    select product_id
      into l_product_id
      from prd_contract_vw
     where id = i_contract_id;

    select nvl(sum(max_count), 0)
      into l_max_count
      from prd_product_service_vw ps
         , prd_service_vw s
         , prd_service_type_vw t
     where ps.product_id     = l_product_id
       and ps.service_id     = i_service_id
       and ps.service_id     = s.id
       and s.service_type_id = t.id
       and t.is_initial      = com_api_const_pkg.TRUE;

    if l_max_count <> prd_api_const_pkg.UNLIMITED_SERVICE_COUNT then
        select nvl(count(s.id), 0)
          into l_count
          from prd_service_object_vw so
             , prd_service_vw s
             , prd_service_type_vw t
         where so.contract_id    = i_contract_id
           and s.id              = i_service_id
           and so.service_id     = s.id
           and s.service_type_id = t.id
           and t.is_initial      = com_api_const_pkg.TRUE
           and so.status        != prd_api_const_pkg.SERVICE_OBJECT_STATUS_CLOSED
           and so.end_date is null;

        if l_count > l_max_count then
            com_api_error_pkg.raise_error(
                i_error      => 'TOO_MANY_INITIAL_SERVICES'
              , i_env_param1 => l_count
              , i_env_param2 => l_max_count
            );
        end if;
    end if;
end check_max_count;

procedure check_count_for_object(
    i_contract_id      in       com_api_type_pkg.t_medium_id
  , i_entity_type      in       com_api_type_pkg.t_dict_value
  , i_object_id        in       com_api_type_pkg.t_long_id
  , i_split_hash       in       com_api_type_pkg.t_tiny_id
) is
    INITIAL_MAX_COUNT  constant com_api_type_pkg.t_count := 1;
    l_count                     com_api_type_pkg.t_count := 0;
begin
    select count(1)
      into l_count
      from prd_service_object_vw so
         , prd_service_vw s
         , prd_service_type_vw t
     where so.contract_id    = i_contract_id
       and so.entity_type    = i_entity_type
       and so.object_id      = i_object_id
       and so.split_hash     = i_split_hash
       and so.status        != prd_api_const_pkg.SERVICE_OBJECT_STATUS_CLOSED
       and so.end_date is null
       and s.id              = so.service_id
       and t.id              = s.service_type_id
       and t.is_initial      = com_api_const_pkg.TRUE;

    if l_count > INITIAL_MAX_COUNT then
        com_api_error_pkg.raise_error(
            i_error      => 'TOO_MANY_INITIAL_SERVICES_FOR_OBJECT'
          , i_env_param1    => i_contract_id
          , i_env_param2    => i_entity_type
          , i_env_param3    => i_object_id
        );
    end if;
end check_count_for_object;

procedure check_services_intersect(
    i_service_id            in      com_api_type_pkg.t_tiny_id
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
) is
    l_max_end_date    date := to_date('01-01-9999 00:00:00', 'dd-mm-yyyy hh24:mi:ss');
begin
    for rec in (
        select a.service_id  as id1
             , a.start_date  as start_dt1
             , a.end_date    as end_dt1
             , d.service_id  as id2
             , d.start_date  as start_dt2
             , d.end_date    as end_dt2
          from prd_service_object a
             , prd_service b
             , prd_service c
             , prd_service_object d
         where a.service_id      = i_service_id
           and a.entity_type     = i_entity_type
           and a.object_id       = i_object_id
           and b.id              = a.service_id
           and c.service_type_id = b.service_type_id
           and d.service_id      = c.id
           and d.entity_type     = a.entity_type
           and d.object_id       = a.object_id
           and d.split_hash      = a.split_hash
           and d.id             != a.id
           and greatest(a.start_date, d.start_date) <= least(nvl(a.end_date, l_max_end_date), nvl(d.end_date, l_max_end_date))
    ) loop
        com_api_error_pkg.raise_error(
            i_error      => 'SERVICES_OF_SAME_TYPE_INTERSECTED'
          , i_env_param1 => rec.id1
          , i_env_param2 => rec.start_dt1
          , i_env_param3 => rec.end_dt1
          , i_env_param4 => rec.id2
          , i_env_param5 => rec.start_dt2
          , i_env_param6 => rec.end_dt2
        );
    end loop;
end check_services_intersect;

function check_conditional_service(
    i_service_id            in      com_api_type_pkg.t_short_id
  , i_product_id            in      com_api_type_pkg.t_short_id
  , i_service_count         in      com_api_type_pkg.t_count
) return com_api_type_pkg.t_boolean is
begin
    return prd_api_service_pkg.check_conditional_service(
               i_service_id         => i_service_id
             , i_product_id         => i_product_id
             , i_service_count      => i_service_count
           );
end check_conditional_service;

procedure add_service (
    o_id                       out  com_api_type_pkg.t_short_id
  , o_seqnum                   out  com_api_type_pkg.t_seqnum
  , i_service_type_id       in      com_api_type_pkg.t_tiny_id
  , i_template_appl_id      in      com_api_type_pkg.t_long_id
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_status                in      com_api_type_pkg.t_dict_value
  , i_lang                  in      com_api_type_pkg.t_dict_value
  , i_label                 in      com_api_type_pkg.t_name
  , i_description           in      com_api_type_pkg.t_full_desc
  , i_service_number        in      com_api_type_pkg.t_name          default null
  , i_split_hash            in      com_api_type_pkg.t_tiny_id       default null
) is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.add_service: ';
    l_service_number                com_api_type_pkg.t_name;
    l_split_hash                    com_api_type_pkg.t_tiny_id;
begin
    check_duplicate (
        i_id       => o_id
      , i_inst_id  => i_inst_id
      , i_lang     => i_lang
      , i_label    => i_label
    );
    
    ost_api_institution_pkg.check_status(
        i_inst_id     => i_inst_id
      , i_data_action => com_api_const_pkg.DATA_ACTION_CREATE
    );
    
    o_id     := com_parameter_seq.nextval;
    o_seqnum := 1;

    -- if <i_service_number> is not passed then it is generated with using appropriate name format
    if i_service_number is not null then
        l_service_number := i_service_number;
    else
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'generating service_number, i_service_id [#1], i_inst_id [#2]'
          , i_env_param1 => o_id
          , i_env_param2 => i_inst_id
        );

        l_service_number:= prd_api_service_pkg.generate_service_number(
                               i_service_id        => o_id
                             , i_inst_id           => i_inst_id
                             , i_eff_date          => com_api_sttl_day_pkg.get_sysdate()
                           );
    end if;

    l_split_hash := coalesce(i_split_hash, com_api_hash_pkg.get_split_hash(i_value => o_id));

    insert into prd_service_vw (
        id
      , seqnum
      , service_type_id
      , template_appl_id
      , inst_id
      , status
      , service_number
      , split_hash
    ) values (
        o_id
      , o_seqnum
      , i_service_type_id
      , i_template_appl_id
      , i_inst_id
      , i_status
      , l_service_number
      , l_split_hash
    );

    com_api_id_pkg.check_doubles;

    com_api_i18n_pkg.add_text (
        i_table_name   => 'prd_service'
      , i_column_name  => 'label'
      , i_object_id    => o_id
      , i_lang         => i_lang
      , i_text         => i_label
    );

    com_api_i18n_pkg.add_text (
        i_table_name   => 'prd_service'
      , i_column_name  => 'description'
      , i_object_id    => o_id
      , i_lang         => i_lang
      , i_text         => i_description
    );

exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error      => 'DUPLICATE_SERVICE_NUMBER'
          , i_env_param1 => i_service_number
          , i_env_param2 => i_inst_id
        );
    when others then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'FAILED with id [#1], i_label [#2], i_status [#3], i_service_number [#4], i_inst_id [#5]'
          , i_env_param1 => o_id
          , i_env_param2 => i_label
          , i_env_param3 => i_status
          , i_env_param4 => i_service_number
          , i_env_param5 => i_inst_id
        );
        raise;
end add_service;

procedure modify_service (
    i_id                    in      com_api_type_pkg.t_short_id
  , io_seqnum               in out  com_api_type_pkg.t_seqnum
  , i_service_type_id       in      com_api_type_pkg.t_tiny_id
  , i_template_appl_id      in      com_api_type_pkg.t_long_id
  , i_status                in      com_api_type_pkg.t_dict_value
  , i_lang                  in      com_api_type_pkg.t_dict_value
  , i_label                 in      com_api_type_pkg.t_name
  , i_description           in      com_api_type_pkg.t_full_desc
  , i_service_number        in      com_api_type_pkg.t_name          default null
) is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.modify_service: ';
    l_inst_id                       com_api_type_pkg.t_inst_id;
begin
    for r in (
        select id
             , inst_id
          from prd_service_vw
         where id = i_id
    ) loop
        l_inst_id:= r.inst_id;

        check_duplicate (
            i_id       => r.id
          , i_inst_id  => r.inst_id
          , i_lang     => i_lang
          , i_label    => i_label
        );

        ost_api_institution_pkg.check_status(
            i_inst_id     => r.inst_id
          , i_data_action => com_api_const_pkg.DATA_ACTION_MODIFY
        );
    end loop;

    update prd_service_vw v
       set v.seqnum           = io_seqnum
         , v.template_appl_id = i_template_appl_id
         , v.status           = i_status
         , v.service_number   = coalesce(i_service_number, v.service_number)
     where v.id               = i_id;

    io_seqnum := io_seqnum + 1;

    com_api_i18n_pkg.add_text (
        i_table_name   => 'prd_service'
      , i_column_name  => 'label'
      , i_object_id    => i_id
      , i_lang         => i_lang
      , i_text         => i_label
    );

    com_api_i18n_pkg.add_text (
        i_table_name   => 'prd_service'
      , i_column_name  => 'description'
      , i_object_id    => i_id
      , i_lang         => i_lang
      , i_text         => i_description
    );

exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error      => 'DUPLICATE_SERVICE_NUMBER'
          , i_env_param1 => i_service_number
          , i_env_param2 => l_inst_id
        );
    when others then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'FAILED with id [#1], i_label [#2], i_status [#3], i_service_number [#4], l_inst_id [#5]'
          , i_env_param1 => i_id
          , i_env_param2 => i_label
          , i_env_param3 => i_status
          , i_env_param4 => i_service_number
          , i_env_param5 => l_inst_id
        );
        raise;
end modify_service;

procedure remove_service (
    i_id       in      com_api_type_pkg.t_short_id
  , i_seqnum   in      com_api_type_pkg.t_seqnum
) is
begin
    check_already_used (
        i_id  => i_id
    );

    com_api_i18n_pkg.remove_text (
        i_table_name => 'prd_service'
      , i_object_id  => i_id
    );

    update prd_service_vw
       set seqnum = i_seqnum
     where id     = i_id;

    delete from prd_service_vw
     where id     = i_id;
end remove_service;

procedure set_service_object (
    i_service_id   in     com_api_type_pkg.t_short_id
  , i_contract_id  in     com_api_type_pkg.t_medium_id
  , i_entity_type  in     com_api_type_pkg.t_dict_value
  , i_object_id    in     com_api_type_pkg.t_long_id
  , i_start_date   in     date
  , i_end_date     in     date
  , i_inst_id      in     com_api_type_pkg.t_inst_id
  , i_params       in     com_api_type_pkg.t_param_tab
) is
    l_postponed_event     evt_api_type_pkg.t_postponed_event;
begin
    set_service_object (
        i_service_id            => i_service_id
      , i_contract_id           => i_contract_id
      , i_entity_type           => i_entity_type
      , i_object_id             => i_object_id
      , i_start_date            => i_start_date
      , i_end_date              => i_end_date
      , i_inst_id               => i_inst_id
      , i_params                => i_params
      , i_need_postponed_event  => com_api_type_pkg.FALSE
      , o_postponed_event       => l_postponed_event
    );
end set_service_object;

procedure set_service_object (
    i_service_id            in      com_api_type_pkg.t_short_id
  , i_contract_id           in      com_api_type_pkg.t_medium_id
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_start_date            in      date
  , i_end_date              in      date
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_params                in      com_api_type_pkg.t_param_tab
  , i_need_postponed_event  in      com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , o_postponed_event          out  evt_api_type_pkg.t_postponed_event
) is
    LOG_PREFIX     constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.set_service_object: ';
    l_sysdate               date;
    l_id                    com_api_type_pkg.t_medium_id;
    l_status                com_api_type_pkg.t_dict_value;
    l_start_date            date;
    l_end_date              date;
    l_split_hash            com_api_type_pkg.t_tiny_id;
    l_count                 com_api_type_pkg.t_tiny_id     := 0;
    l_old_contract_id       com_api_type_pkg.t_medium_id;
    l_old_status            com_api_type_pkg.t_dict_value;
    l_need_postponed_event  com_api_type_pkg.t_boolean     := nvl(i_need_postponed_event, com_api_type_pkg.FALSE);
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'START with i_service_id [' || i_service_id || '], i_contract_id [' || i_contract_id
                                   || '], i_entity_type [' || i_entity_type || '], i_object_id [' || i_object_id
                                   || '], i_inst_id [' || i_inst_id || '], i_start_date [#1], i_end_date [#2]'
      , i_env_param1 => i_start_date
      , i_env_param2 => i_end_date
    );

    -- check entity_type for service
    select count(1)  
      into l_count            
      from prd_service_vw s
         , prd_service_type_vw t
     where s.id          = i_service_id          
       and t.id          = s.service_type_id
       and t.entity_type = i_entity_type;
    
    if l_count = 0 then
        com_api_error_pkg.raise_error (
            i_error       => 'INCONSISTENT_ENTITY_TYPE_FOR_SERVICE'
          , i_env_param1  => i_service_id
          , i_env_param2  => i_entity_type
        );
    end if;           
           
    l_sysdate := com_api_sttl_day_pkg.get_calc_date(i_inst_id => i_inst_id);
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'l_sysdate [#1]'
      , i_env_param1 => l_sysdate
    );
    
    for r in (
        select s.status
             , s.service_type_id
             , t.enable_event_type
             , t.disable_event_type
             , s.inst_id
          from prd_service_vw s
             , prd_service_type_vw t
         where s.id = i_service_id
           and t.id = s.service_type_id
    ) loop
        if r.status != prd_api_const_pkg.SERVICE_STATUS_ACTIVE then
            com_api_error_pkg.raise_error (
                i_error       => 'SERVICE_IS_NOT_ACTIVE'
              , i_env_param1  => i_service_id
            );
        end if;

        ost_api_institution_pkg.check_status(
            i_inst_id     => r.inst_id
          , i_data_action => com_api_const_pkg.DATA_ACTION_MODIFY
        );

        begin
            select split_hash
              into l_split_hash
              from prd_contract_vw
             where id = i_contract_id;

            trc_log_pkg.debug(LOG_PREFIX || 'l_split_hash [' || l_split_hash || ']');
        exception
            when no_data_found then
                com_api_error_pkg.raise_error (
                    i_error       => 'CONTRACT_NOT_FOUND'
                  , i_env_param1  => i_contract_id
                );
        end;

        begin
            select id
                 , o.status
                 , o.start_date
                 , o.end_date
                 , o.contract_id
              into l_id
                 , l_status
                 , l_start_date
                 , l_end_date
                 , l_old_contract_id
              from prd_service_object_vw o
             where o.service_id  = i_service_id
               and o.entity_type = i_entity_type
               and o.object_id   = i_object_id;

            l_old_status := l_status;

            if l_status = prd_api_const_pkg.SERVICE_OBJECT_STATUS_CLOSED and i_start_date is not null  then
                if i_start_date < trunc(l_end_date) then
                    com_api_error_pkg.raise_error (
                        i_error  => 'SERVICE_ACTIVATION_START_DATE_INVALID'
                    );
                end if;

                -- insert service log
                prd_api_service_pkg.add_service_log (
                    i_service_object_id => l_id
                  , i_start_date        => l_start_date
                  , i_end_date          => nvl(l_end_date, l_sysdate)
                  , i_split_hash        => l_split_hash
                );
                
                l_status := prd_api_const_pkg.SERVICE_OBJECT_STATUS_INACTIVE;
            elsif nvl(i_start_date, l_sysdate) > l_sysdate then
                l_status := prd_api_const_pkg.SERVICE_OBJECT_STATUS_INACTIVE;
            else
                l_status := null;
            end if;
            
            if l_old_contract_id != i_contract_id then
                delete from prd_service_object_vw
                 where id = l_id;

                insert into prd_service_object_vw (
                    id
                  , contract_id
                  , service_id
                  , entity_type
                  , object_id
                  , status
                  , start_date
                  , end_date
                  , split_hash
                ) values (
                    l_id
                  , i_contract_id
                  , i_service_id
                  , i_entity_type
                  , i_object_id
                  , nvl(l_status, l_old_status)
                  , l_start_date
                  , l_end_date
                  , l_split_hash
                );
                
                prd_ui_service_pkg.check_services_intersect(
                    i_service_id    => i_service_id
                  , i_entity_type   => i_entity_type
                  , i_object_id     => i_object_id
                );
            else
                --If the status of the service is "Closed", the service must be activated. 
                --Therefore, the start date is updated on i_start_date. 
                --And the end date is reset to null. 
                --If the status of the service is "Active", the service must be closed. 
                --Therefore, the start date is not changed. 
                --And the end date is updated on i_end_date.            
                update prd_service_object_vw
                   set start_date = decode(status, prd_api_const_pkg.SERVICE_OBJECT_STATUS_CLOSED, nvl(i_start_date, start_date), start_date)
                     , end_date   = decode(status, prd_api_const_pkg.SERVICE_OBJECT_STATUS_CLOSED, null, nvl(i_end_date, end_date))
                     , status     = nvl(l_status, status)
                 where id = l_id;
            end if;
             
             trc_log_pkg.debug(LOG_PREFIX || 'set status [' || l_status || ']');

        exception
            when no_data_found then
                -- insert
                l_id := prd_service_object_seq.nextval;
                trc_log_pkg.debug(LOG_PREFIX || 'inserting record into prd_service_object_vw with id [' || l_id || ']');
                
                insert into prd_service_object_vw (
                    id
                  , contract_id
                  , service_id
                  , entity_type
                  , object_id
                  , status
                  , start_date
                  , end_date
                  , split_hash
                ) values (
                    l_id
                  , i_contract_id
                  , i_service_id
                  , i_entity_type
                  , i_object_id
                  , prd_api_const_pkg.SERVICE_OBJECT_STATUS_INACTIVE
                  , least(nvl(i_start_date, l_sysdate), l_sysdate)
                  , i_end_date
                  , l_split_hash
                );

                prd_ui_service_pkg.check_services_intersect(
                    i_service_id    => i_service_id
                  , i_entity_type   => i_entity_type
                  , i_object_id     => i_object_id
                );
        end;

        prd_api_service_pkg.change_service_status (
            i_id                      => l_id
            , i_sysdate               => least(nvl(i_start_date, l_sysdate), l_sysdate)
            , i_entity_type           => i_entity_type
            , i_object_id             => i_object_id
            , i_inst_id               => i_inst_id
            , i_enable_event_type     => r.enable_event_type
            , i_disable_event_type    => r.disable_event_type
            , i_forced                => com_api_type_pkg.FALSE
            , i_params                => i_params
            , i_split_hash            => l_split_hash
            , i_need_postponed_event  => l_need_postponed_event
            , o_postponed_event       => o_postponed_event
        );

        check_max_count (
            i_service_id     => i_service_id
            , i_contract_id  => i_contract_id
        );

        check_count_for_object(
            i_contract_id    => i_contract_id
          , i_entity_type    => i_entity_type
          , i_object_id      => i_object_id
          , i_split_hash     => l_split_hash
        );

        trc_log_pkg.debug(LOG_PREFIX || 'END'); 
        return;
    end loop;

    com_api_error_pkg.raise_error (
        i_error         => 'SERVICE_NOT_FOUND'
        , i_env_param1  => i_service_id
    );
end set_service_object;

/*
 * Procedure adds new visible flag (or modifies existing one) for an attribute
 * if it differs from default value in PRD_ATTRIBUTE(_VW)
 */
procedure set_service_attribute(
    i_service_id   in     com_api_type_pkg.t_short_id
  , i_attribute_id in     com_api_type_pkg.t_short_id
  , i_is_visible   in     com_api_type_pkg.t_boolean
) is
    LOG_PREFIX            constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.set_service_attribute: ';
    l_service_attribute_visible    com_api_type_pkg.t_boolean;
    l_attribute_visible            com_api_type_pkg.t_boolean;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'i_service_id [#1], i_attribute_id [#2], i_is_visible [#3]'
      , i_env_param1 => i_service_id
      , i_env_param2 => i_attribute_id
      , i_env_param3 => i_is_visible
    );

    select sa.is_visible
         , a.is_visible
      into l_service_attribute_visible
         , l_attribute_visible    -- default attribute for service_type
      from prd_service_vw s
      left join prd_service_attribute_vw sa
          on sa.service_id     = s.id
         and sa.attribute_id   = i_attribute_id
      left join prd_attribute_vw a
          on a.service_type_id = s.service_type_id
         and a.id              = i_attribute_id
         and a.is_visible      = i_is_visible
     where s.id = i_service_id;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'l_service_attribute_visible [#4], l_attribute_visible [#5]'
      , i_env_param1 => l_service_attribute_visible
      , i_env_param2 => l_attribute_visible
    );

    if l_service_attribute_visible is null then
        -- Add new attribute's visible flag only if it differs from default one in PRD_ATTRIBUTE_VW (for service_type)
        if l_attribute_visible is null or l_attribute_visible != i_is_visible  then
            insert into prd_service_attribute_vw(
                service_id
              , attribute_id
              , is_visible
            ) values (
                i_service_id
              , i_attribute_id
              , i_is_visible
            );
        end if;
    else -- Attribute is already defined for a service
        if l_service_attribute_visible = l_attribute_visible then
            -- Delete attribute's visible flag if it DOESN'T differ from default one in PRD_ATTRIBUTE_VW (for service_type)
            delete from prd_service_attribute_vw v
            where v.attribute_id = i_attribute_id;

        elsif l_service_attribute_visible != nvl(l_attribute_visible, i_is_visible) then
            update prd_service_attribute_vw v
               set v.is_visible = i_is_visible
             where v.service_id = i_service_id
               and v.attribute_id = i_attribute_id;
        end if;
    end if;

exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error      => 'SERVICE_NOT_FOUND'
          , i_env_param1 => i_service_id
        );
end set_service_attribute;

end prd_ui_service_pkg;
/
