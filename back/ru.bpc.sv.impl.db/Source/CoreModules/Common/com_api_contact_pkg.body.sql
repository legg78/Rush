create or replace package body com_api_contact_pkg as
/********************************************************* 
 *  API for contacts  <br /> 
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 11.12.2009 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: com_api_contact_pkg <br /> 
 *  @headcom 
 **********************************************************/

procedure register_event(
    i_contact_id        in      com_api_type_pkg.t_long_id
  , i_contact_data_id   in      com_api_type_pkg.t_long_id  default null
) is
    l_param_tab         com_api_type_pkg.t_param_tab;
begin
    for rec in (
        select c.id
             , c.inst_id
             , c.split_hash
          from com_contact_object o
             , prd_customer c
         where o.entity_type = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
           and o.contact_id  = i_contact_id
           and c.id          = o.object_id
         union
        select c.id
             , c.inst_id
             , c.split_hash 
          from com_contact_object o
             , iss_cardholder h
             , prd_customer c
         where o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
           and o.object_id   = h.id
           and h.person_id   = c.object_id
           and c.entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON
           and o.contact_id  = i_contact_id
    ) loop
        evt_api_event_pkg.register_event(
            i_event_type      => prd_api_const_pkg.EVENT_CUSTOMER_MODIFY
          , i_eff_date        => get_sysdate
          , i_entity_type     => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
          , i_object_id       => rec.id
          , i_inst_id         => rec.inst_id
          , i_split_hash      => rec.split_hash
          , i_param_tab       => l_param_tab
        );
        if i_contact_data_id is not null then
            for r_cdata in (
                select cntr.product_id
                     , prd.product_type
                  from prd_contract cntr
                     , prd_product prd
                 where cntr.customer_id = rec.id
                   and prd.id           = cntr.product_id
            ) loop
                rul_api_param_pkg.set_param(
                    i_name    => 'PRODUCT_ID'
                  , i_value   => r_cdata.product_id
                  , io_params => l_param_tab
                );
                rul_api_param_pkg.set_param(
                    i_name    => 'PRODUCT_TYPE'
                  , i_value   => r_cdata.product_type
                  , io_params => l_param_tab
                );
                rul_api_param_pkg.set_param(
                    i_name    => 'SRC_ENTITY_TYPE'
                  , i_value   => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
                  , io_params => l_param_tab
                );
                rul_api_param_pkg.set_param(
                    i_name    => 'SRC_OBJECT_ID'
                  , i_value   => rec.id
                  , io_params => l_param_tab
                );
                evt_api_event_pkg.register_event(
                    i_event_type      => com_api_const_pkg.EVENT_TYPE_CON_DATA_CHANGED
                  , i_eff_date        => get_sysdate
                  , i_entity_type     => com_api_const_pkg.ENTITY_TYPE_CONTACT_DATA
                  , i_object_id       => i_contact_data_id
                  , i_inst_id         => rec.inst_id
                  , i_split_hash      => rec.split_hash
                  , i_param_tab       => l_param_tab
                );
                rul_api_param_pkg.clear_params(
                    io_params => l_param_tab
                );
            end loop;
        end if;
    end loop;
end;
  
procedure add_contact(
    o_id                   out  com_api_type_pkg.t_medium_id
  , i_preferred_lang    in      com_api_type_pkg.t_dict_value
  , i_job_title         in      com_api_type_pkg.t_dict_value
  , i_person_id         in      com_api_type_pkg.t_name
  , i_inst_id           in      com_api_type_pkg.t_inst_id
) is
begin
    o_id := com_contact_seq.nextval;

    insert into com_contact_vw(
        id
      , seqnum
      , preferred_lang
      , job_title
      , person_id
      , inst_id
    ) values (
        o_id
      , 1
      , i_preferred_lang
      , i_job_title
      , i_person_id
      , ost_api_institution_pkg.get_sandbox(i_inst_id)
    );

    trc_log_pkg.debug(
        i_text        => 'Contact [#1] added'
      , i_env_param1  => o_id
    );
    
    register_event(i_contact_id => o_id);
end;

procedure modify_contact(
    i_id                in      com_api_type_pkg.t_medium_id
  , i_preferred_lang    in      com_api_type_pkg.t_dict_value
  , i_job_title         in      com_api_type_pkg.t_dict_value
  , i_person_id         in      com_api_type_pkg.t_name
) is
begin
    update com_contact_vw
    set job_title      = nvl(i_job_title, job_title)
      , person_id      = nvl(i_person_id, person_id)
      , preferred_lang = nvl(i_preferred_lang, preferred_lang)
    where id           = i_id;

    trc_log_pkg.debug(
        i_text          => 'Contact [#1] modified'
        , i_env_param1  => i_id
    );

    register_event(i_contact_id => i_id);
end;


procedure remove_contact(
    i_contact_id        in      com_api_type_pkg.t_long_id
) is
begin
    trc_log_pkg.debug(
        i_text          => 'remove_contact [#1] '
        , i_env_param1  => i_contact_id
    );
        
    for contact_data  in (select id from com_contact_data_vw where contact_id = i_contact_id)
    loop
        remove_contact_data(contact_data.id);
    end loop; 

    delete from com_contact_vw
    where id = i_contact_id;    
end;


procedure add_contact_data (
    i_contact_id        in      com_api_type_pkg.t_medium_id
  , i_commun_method     in      com_api_type_pkg.t_dict_value
  , i_commun_address    in      com_api_type_pkg.t_full_desc
  , i_start_date        in      date := null
  , i_end_date          in      date := null
) is
    l_entity            com_api_type_pkg.t_name;
    l_inst_id           com_api_type_pkg.t_inst_id;
    l_count             com_api_type_pkg.t_count := 0;
    l_sysdate           date;
    l_contact_data_id   com_api_type_pkg.t_long_id;
begin
    l_sysdate := com_api_sttl_day_pkg.get_sysdate;

    if i_end_date < l_sysdate then
        com_api_error_pkg.raise_error (
            i_error         => 'END_DATE_PASSED'
          , i_env_param1    => to_char(i_end_date, com_api_const_pkg.LOG_DATE_FORMAT)
        );
    end if;

    select count(1)
      into l_count
      from com_contact_data
     where commun_method = i_commun_method
       and commun_address = i_commun_address
       and contact_id = i_contact_id
       and (end_date is null or end_date > l_sysdate);

    if l_count > 0 then
        raise dup_val_on_index;
    end if;

    insert into com_contact_data_vw (
        id
        , contact_id
        , commun_method
        , commun_address
        , start_date
        , end_date
    ) values (
        com_contact_data_seq.nextval
        , i_contact_id
        , i_commun_method
        , i_commun_address
        , nvl(i_start_date, get_sysdate)
        , i_end_date
    )
    returning 
        id into l_contact_data_id;

    trc_log_pkg.debug(
        i_text        => 'Contact data [#1] insert to contact [#2]'
      , i_env_param1  => i_commun_method||' '||i_commun_address
      , i_env_param2  => i_contact_id
    );

    register_event (
        i_contact_id       => i_contact_id
      , i_contact_data_id  => l_contact_data_id
    );
exception
    when dup_val_on_index then
        select min(trc_log_pkg.get_desc(entity_type)||' '||object_id) entity
             , min(ost_api_institution_pkg.get_object_inst_id(
                       i_entity_type  => o.entity_type
                     , i_object_id    => o.object_id
                     , i_mask_errors  => com_api_type_pkg.TRUE
                  ))
          into l_entity
             , l_inst_id
          from com_contact_object_vw o
             , com_contact_data_vw d
         where d.contact_id     = o.contact_id
           and d.commun_method  = i_commun_method
           and d.commun_address = i_commun_address;

        com_api_error_pkg.raise_error (
            i_error         => 'CONTACT_DATA_NOT_UNIQUE'
          , i_env_param1    => i_contact_id
          , i_env_param2    => i_commun_method
          , i_env_param3    => i_commun_address
          , i_env_param4    => nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate)
          , i_env_param5    => l_entity
          , i_env_param6    => l_inst_id
        );
end;

/*
 * Procedure updates contact data for some entity object;
 * if incoming contact ID belongs to another entity object then it isn't changed,
 * but a new contact with data is created for an incoming entity object.
 */
procedure modify_contact_data(
    i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_contact_id        in      com_api_type_pkg.t_medium_id
  , i_commun_method     in      com_api_type_pkg.t_dict_value
  , i_commun_address    in      com_api_type_pkg.t_full_desc
  , i_start_date        in      date
  , i_end_date          in      date
) is
    LOG_PREFIX constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.modify_contact_data: ';
    l_id                com_api_type_pkg.t_long_id;
begin
    select id
      into l_id
      from com_contact_object
     where entity_type = i_entity_type
       and object_id   = i_object_id
       and contact_id  = i_contact_id;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'contact for specified entity [#1][#2]'
                     || ' was found, update data for existing contact...'
      , i_env_param1 => i_entity_type
      , i_env_param2 => i_object_id
    );

    modify_contact_data(
        i_contact_id      => i_contact_id
      , i_commun_method   => i_commun_method
      , i_commun_address  => i_commun_address
      , i_start_date      => i_start_date
      , i_end_date        => i_end_date
    );
exception
    when no_data_found then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'contact for specified entity [#1][#2]'
                         || ' was NOT found, create a new contact...'
          , i_env_param1 => i_entity_type
          , i_env_param2 => i_object_id
        );

        add_contact(
            o_id                => l_id
          , i_preferred_lang    => nvl(com_ui_user_env_pkg.get_user_lang()
                                     , com_api_const_pkg.DEFAULT_LANGUAGE)
          , i_job_title         => null
          , i_person_id         => null
          , i_inst_id           => i_inst_id
        );

        add_contact_data(
            i_contact_id        => l_id
          , i_commun_method     => i_commun_method
          , i_commun_address    => i_commun_address
          , i_start_date        => i_start_date
        );

        add_contact_object(
            i_contact_id        => l_id
          , i_entity_type       => i_entity_type
          , i_object_id         => i_object_id
          , i_contact_type      => com_api_const_pkg.CONTACT_TYPE_PRIMARY
          , o_contact_object_id => l_id
        );
end modify_contact_data;

/*
 * Procedure updates data of some contact. 
 *
 * Main concept: we can update the "last and current" record only.
 *
 * This method's algorithm has got concept:
 *    1) take the fixed "contact_id", "commun_method" and "commun_address" values.
 *    1.1) It raises an exception if <l_new_start_date> is greater than <l_new_end_date>.
 *    2) find the last record with condition: "start_date=max(start_date)".
 *    3) if the last record is not found then create new record.
 *    4) if the last record is intersected with more than one record then the error is encountered (CONTACT_DATA_NOT_UNIQUE).
 *    5) if the nvl(i_start_date, sysdate) is greatest than the cd.end_date of last record then create new record.
 *    6) find the current record with condition: "sysdate between cd.start_date and cd.end_date".
 *    6.1) We cannot close contact data with end_date less than sysdate.
 *    7) if the [nvl(i_start_date, sysdate), i_end_date] interval is intersected with more than one current record then the error is encountered (CONTACT_DATA_NOT_UNIQUE).
 *    8) if the i_end_date is less than the cd.start_date of last record then the error is encountered (CONTACT_DATA_NOT_UNIQUE).
 *    9) if last record is not equal to current record then the error is encountered (CONTACT_DATA_NOT_UNIQUE).
 *   10) this method can change the "end_date" value of the last&current record.
 */
procedure modify_contact_data (
    i_contact_id        in      com_api_type_pkg.t_medium_id
  , i_commun_method     in      com_api_type_pkg.t_dict_value
  , i_commun_address    in      com_api_type_pkg.t_full_desc
  , i_start_date        in      date
  , i_end_date          in      date
) is
    l_insert_record             com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
    l_too_many_rows             com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
    l_sysdate                   date;

    l_new_start_date            date;
    l_new_end_date              date;

    l_last_id                   com_api_type_pkg.t_medium_id;
    l_last_start_date           date;
    l_last_end_date             date;

    l_current_id                com_api_type_pkg.t_medium_id;
    l_current_start_date        date;
    l_current_end_date          date;
    l_contact_data_id           com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug(
        i_text        => 'com_api_contact_pkg.modify_contact_data: i_contact_id [#1] i_commun_method [#2] i_commun_address [#3] i_start_date [#4] i_end_date [#5]'
      , i_env_param1  => i_contact_id
      , i_env_param2  => i_commun_method
      , i_env_param3  => i_commun_address
      , i_env_param4  => to_char(i_start_date, com_api_const_pkg.LOG_DATE_FORMAT)
      , i_env_param5  => to_char(i_end_date,   com_api_const_pkg.LOG_DATE_FORMAT)
    );

    l_sysdate         := com_api_sttl_day_pkg.get_sysdate;
    l_new_start_date  := nvl(i_start_date, l_sysdate);
    l_new_end_date    := i_end_date;

    -- 1.1) It raises an exception if <l_new_start_date> is greater than <l_new_end_date>.
    if l_new_start_date > nvl(l_new_end_date, l_new_start_date) then
        com_api_error_pkg.raise_error(
            i_error      => 'END_DATE_IS_LESS_THAN_START_DATE'
          , i_env_param1 => com_api_type_pkg.convert_to_char(l_new_start_date)
          , i_env_param2 => com_api_type_pkg.convert_to_char(l_new_end_date)
        );
    end if;

    begin
        -- 2) find the last record with condition: "start_date=max(start_date)".
        select id, start_date, end_date
          into l_last_id, l_last_start_date, l_last_end_date
          from com_contact_data_vw cd
         where cd.contact_id     = i_contact_id
           and cd.commun_method  = i_commun_method
           and cd.commun_address = i_commun_address
           and cd.start_date in (
                                    select max(start_date)
                                      from com_contact_data_vw
                                     where contact_id     = i_contact_id
                                       and commun_method  = i_commun_method
                                       and commun_address = i_commun_address
                                );

        trc_log_pkg.debug(
            i_text        => 'com_api_contact_pkg.modify_contact_data: l_last_id [#1] l_last_start_date [#2] l_last_end_date [#3]'
          , i_env_param1  => l_last_id
          , i_env_param2  => to_char(l_last_start_date, com_api_const_pkg.LOG_DATE_FORMAT)
          , i_env_param3  => to_char(l_last_end_date,   com_api_const_pkg.LOG_DATE_FORMAT)
        );
    exception
        when no_data_found then
            -- 3) if the last record is not found then create new record.
            l_insert_record := com_api_type_pkg.TRUE;

        when too_many_rows then
            -- 4) if the last record is intersected with more than one record then the error is encountered (CONTACT_DATA_NOT_UNIQUE).
            l_too_many_rows := com_api_type_pkg.TRUE;

    end;

    -- 5) if the nvl(i_start_date, sysdate) is greatest than the cd.end_date of last record then create new record.
    if l_new_start_date > l_last_end_date then
        l_insert_record := com_api_type_pkg.TRUE;
    end if;

    if l_insert_record = com_api_type_pkg.TRUE then
        insert into com_contact_data_vw (
            id
            , contact_id
            , commun_method
            , commun_address
            , start_date
            , end_date
        ) values (
            com_contact_data_seq.nextval
            , i_contact_id
            , i_commun_method
            , i_commun_address
            , nvl(i_start_date, get_sysdate)
            , i_end_date
        )
        returning 
            id into l_contact_data_id;

        trc_log_pkg.debug(
            i_text        => 'Contact data [#1] added for contact [#2]'
          , i_env_param1  => i_commun_method || ' ' || i_commun_address
          , i_env_param2  => i_contact_id
        );

        register_event (
            i_contact_id       => i_contact_id
          , i_contact_data_id  => l_contact_data_id
        );

    else
        begin
            -- 6) find the current record with condition: "sysdate between cd.start_date and cd.end_date".
            select id, start_date, end_date
              into l_current_id, l_current_start_date, l_current_end_date
              from com_contact_data_vw cd
             where cd.contact_id     = i_contact_id
               and cd.commun_method  = i_commun_method
               and cd.commun_address = i_commun_address
               and (
                       l_sysdate between cd.start_date and cd.end_date
                       or (cd.end_date is null and cd.start_date <= l_sysdate)
               );

            trc_log_pkg.debug(
                i_text        => 'com_api_contact_pkg.modify_contact_data: l_current_id [#1] l_current_start_date [#2] l_current_end_date [#3]'
              , i_env_param1  => l_current_id
              , i_env_param2  => to_char(l_current_start_date, com_api_const_pkg.LOG_DATE_FORMAT)
              , i_env_param3  => to_char(l_current_end_date,   com_api_const_pkg.LOG_DATE_FORMAT)
            );
        exception
            when no_data_found then
                -- 6.1) We cannot close contact data with end_date less than sysdate.
                com_api_error_pkg.raise_error (
                    i_error         => 'CONTACT_DATA_ALREADY_CLOSED'
                  , i_env_param1    => i_contact_id
                  , i_env_param2    => i_commun_method
                  , i_env_param3    => i_commun_address
                );

            when too_many_rows then
                -- 7) if the [nvl(i_start_date, sysdate), i_end_date] interval is intersected with more than one current record then the error is encountered (CONTACT_DATA_NOT_UNIQUE).
                l_too_many_rows := com_api_type_pkg.TRUE;

        end;

        -- 8) if the i_end_date is less than the cd.start_date of last record then the error is encountered (CONTACT_DATA_NOT_UNIQUE).
        -- 9) if last record is not equal to current record then the error is encountered (CONTACT_DATA_NOT_UNIQUE).
        if l_new_end_date < l_last_start_date
           or (l_last_id is not null and l_current_id is not null and l_last_id != l_current_id)
        then
            l_too_many_rows := com_api_type_pkg.TRUE;

            trc_log_pkg.debug(
                i_text        => 'com_api_contact_pkg.modify_contact_data: it is not last record. l_last_id [#1] l_current_id [#2]'
              , i_env_param1  => l_last_id
              , i_env_param2  => l_current_id
            );
        end if;

        if l_too_many_rows = com_api_type_pkg.TRUE then
            com_api_error_pkg.raise_error (
                i_error         => 'CONTACT_DATA_NOT_UNIQUE'
              , i_env_param1    => i_contact_id
              , i_env_param2    => i_commun_method
              , i_env_param3    => i_commun_address
              , i_env_param4    => nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate)
            );
        end if;

        if l_last_id = l_current_id then
            -- 10) this method can change the "end_date" value of the last&current record.
            update com_contact_data_vw
               set end_date = l_new_end_date
             where id = l_last_id;

            trc_log_pkg.debug(
                i_text        => 'com_api_contact_pkg.modify_contact_data: update end_date'
            );
        end if;

    end if;

    trc_log_pkg.debug(
        i_text        => 'com_api_contact_pkg.modify_contact_data finished'
    );
end;

procedure remove_contact_data(
    i_contact_data_id   in      com_api_type_pkg.t_long_id
) is
begin
    delete from com_contact_data_vw
    where id = i_contact_data_id;
end;

procedure add_contact_object(
    i_contact_id        in      com_api_type_pkg.t_medium_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_contact_type      in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , o_contact_object_id    out  com_api_type_pkg.t_long_id
) is
    l_count             com_api_type_pkg.t_medium_id;
begin
    select count(id)
     into l_count
     from com_contact_object_vw
    where object_id   = i_object_id
      and entity_type = i_entity_type
      and contact_id  = i_contact_id;

    if l_count > 0 then
        return;
    end if;

    o_contact_object_id := com_contact_object_seq.nextval;

    insert into com_contact_object_vw(
        id
      , object_id
      , entity_type
      , contact_type
      , contact_id
    ) values (
        o_contact_object_id
      , i_object_id
      , i_entity_type
      , i_contact_type
      , i_contact_id
    );

    register_event(i_contact_id => i_contact_id);
exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error       => 'CONTACT_ALREADY_EXIST'
          , i_env_param1  => i_contact_type
          , i_env_param2  => i_entity_type
          , i_env_param3  => i_object_id
        );
end;

procedure remove_contact_object(
    i_contact_object_id in      com_api_type_pkg.t_long_id
) is
    l_contact_id        com_api_type_pkg.t_long_id;
begin
    for rec in (
        select count(1) as cnt
             , b.entity_type
             , b.object_id
          from com_contact_object_vw b
         where (b.object_id, b.entity_type) in (
            select a.object_id
                 , a.entity_type
              from com_contact_object_vw a
             where a.id = i_contact_object_id)
      group by b.entity_type
             , b.object_id
    ) loop
        if rec.cnt > 1 then
            delete com_contact_object
             where id = i_contact_object_id
         returning contact_id
              into l_contact_id;

            register_event(i_contact_id => l_contact_id);
        else
            com_api_error_pkg.raise_error(
                i_error      => 'OBJECT_LAST_CONTACT'
              , i_env_param1 => rec.entity_type
              , i_env_param2 => rec.object_id
            );
        end if;
    end loop;
end;

function get_contact_string(
    i_contact_id        in      com_api_type_pkg.t_medium_id
  , i_commun_method     in      com_api_type_pkg.t_dict_value
  , i_start_date        in      date
) return com_api_type_pkg.t_full_desc is
    l_result            com_api_type_pkg.t_full_desc;
begin
    begin
        select distinct
               first_value(commun_address) over (order by d.end_date desc nulls first)
          into l_result
          from com_contact_data d
         where d.contact_id    = i_contact_id
           and d.commun_method = i_commun_method
           and d.start_date = (
                   select max(start_date)
                     from com_contact_data b 
                    where b.contact_id = d.contact_id 
                      and b.start_date <= nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate)
                      and b.commun_method = d.commun_method
                      and nvl(b.end_date, com_api_sttl_day_pkg.get_sysdate) >= com_api_sttl_day_pkg.get_sysdate
               );
    exception
        when no_data_found then
            null;
    end;

    return l_result;
end;

function get_contact_data(
    i_object_id             in com_api_type_pkg.t_long_id
  , i_entity_type           in com_api_type_pkg.t_dict_value
  , i_contact_type          in com_api_type_pkg.t_dict_value
  , i_eff_date              in date                             default null
) return com_api_type_pkg.t_param_tab
is
    l_result    com_api_type_pkg.t_param_tab;
    l_eff_date  date := nvl(i_eff_date, com_api_sttl_day_pkg.get_sysdate());
begin
    for cu_contact in (
        select cd.commun_method
             , cd.commun_address
          from com_contact c
             , com_contact_object co
             , com_contact_data cd
         where c.id             = co.contact_id
           and c.id             = cd.contact_id
           and co.object_id     = i_object_id
           and co.entity_type   = i_entity_type
           and (
                    co.contact_type = i_contact_type
                or  i_contact_type is null
               )
           and (
                    cd.end_date is null
                or  cd.end_date > l_eff_date
               )
    ) loop
        l_result(cu_contact.commun_method) := cu_contact.commun_address;
    end loop;

    return l_result;
end get_contact_data;

function get_contact_data_rec(
    i_object_id         in  com_api_type_pkg.t_long_id
  , i_entity_type       in  com_api_type_pkg.t_dict_value
  , i_contact_type      in  com_api_type_pkg.t_dict_value
  , i_eff_date          in  date                           default null
  , i_mask_error        in  com_api_type_pkg.t_boolean     default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_contact_data_rec
is
    l_contact_data_rec      com_api_type_pkg.t_contact_data_rec;
    l_eff_date              date := nvl(i_eff_date, com_api_sttl_day_pkg.get_sysdate());
begin
    select d.id
         , d.contact_id
         , d.commun_method
         , d.commun_address
         , d.start_date
         , d.end_date
      into l_contact_data_rec.id
         , l_contact_data_rec.contact_id
         , l_contact_data_rec.commun_method
         , l_contact_data_rec.commun_address
         , l_contact_data_rec.start_date
         , l_contact_data_rec.end_date
      from com_contact c
         , com_contact_object o
         , com_contact_data d
     where c.id            = o.contact_id
       and c.id            = d.contact_id
       and o.object_id     = i_object_id
       and o.entity_type   = i_entity_type
       and o.contact_type  = i_contact_type
       and (
               d.end_date is null
            or d.end_date  > l_eff_date
           )
       and rownum          = 1;

    return l_contact_data_rec;
exception
    when no_data_found
      or com_api_error_pkg.e_application_error
    then
        if nvl(i_mask_error, com_api_const_pkg.TRUE) = com_api_const_pkg.TRUE then
            return l_contact_data_rec;
        else
            com_api_error_pkg.raise_error(
                i_error      => 'CONTACT_NOT_FOUND'
            );
        end if;
    when com_api_error_pkg.e_fatal_error then
        raise;
    when others then
        com_api_error_pkg.raise_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );

end get_contact_data_rec;

end;
/
