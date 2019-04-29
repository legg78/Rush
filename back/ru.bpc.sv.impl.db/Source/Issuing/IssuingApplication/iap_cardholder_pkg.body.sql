create or replace package body iap_cardholder_pkg as
/*********************************************************
*  API for cardholders <br />
*  Created by Kryukov E.(krukov@bpc.ru)  at 30.06.2010 <br />
*  Module: IAP_CARDHOLDER_PKG <br />
*  @headcom
**********************************************************/

function generate_cardholder_name(
    i_first_name           in            com_api_type_pkg.t_name
  , i_second_name          in            com_api_type_pkg.t_name
  , i_surname              in            com_api_type_pkg.t_name
  , i_max_len              in            com_api_type_pkg.t_tiny_id default iss_api_const_pkg.MAX_CARDHOLDER_NAME_LENGTH
) return com_api_type_pkg.t_name is
    l_result               com_api_type_pkg.t_name;
    l_name1                com_api_type_pkg.t_name := upper(i_first_name);
    l_name2                com_api_type_pkg.t_name := upper(i_second_name);
    l_name3                com_api_type_pkg.t_name := upper(i_surname);
begin
    loop
        if l_name2 is not null and l_name1 is not null then
            l_result := l_name1 || ' ' || l_name2 || ' ' || l_name3;
        elsif l_name1 is not null then
            l_result := l_name1 || ' ' || l_name3;
        else
            l_result := l_name3;
        end if;

        exit when length(nvl(l_result, 0)) <= i_max_len;

        if l_name2 is not null then
            if length(l_name2) > 2 then
                l_name2 := substr(l_name2, 1, 1) || '.';
            else
                l_name2 := null;
            end if;
        elsif l_name1 is not null then
            if length(l_name1) > 2 then
                l_name1 := substr(l_name1, 1, 1) || '.';
            else
                l_name1 := null;
            end if;
        else
            l_name3 := substr(l_name3, 1, least(length(l_name3)-1, i_max_len));
        end if;
    end loop;

    return l_result;
end generate_cardholder_name;

procedure attach_cardholder_to_appl (
    i_cardholder_id              in            com_api_type_pkg.t_long_id
) is
    l_count                com_api_type_pkg.t_count := 0;
begin
    if i_cardholder_id is null then
        return;
    end if;

    select count(appl_id)
      into l_count
      from app_object
     where object_id = i_cardholder_id
       and appl_id = app_api_application_pkg.get_appl_id
       and entity_type = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER;

    trc_log_pkg.debug (
        i_text        => 'Attach cardholder to application: object entry count [#1], cardholder_id [#2], application_id [#3]'
      , i_env_param1  => l_count
      , i_env_param2  => i_cardholder_id
      , i_env_param3  => app_api_application_pkg.get_appl_id
    );

    if l_count = 0 then
        app_api_appl_object_pkg.add_object(
            i_appl_id     => app_api_application_pkg.get_appl_id
          , i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
          , i_object_id   => i_cardholder_id
          , i_seqnum      => 1
        );
    end if;
end attach_cardholder_to_appl;

procedure get_appl_data(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , o_cardholder              out nocopy iss_api_type_pkg.t_cardholder
) is
begin
    app_api_application_pkg.get_element_value(
        i_element_name   => 'CARDHOLDER_NUMBER'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_cardholder.cardholder_number
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'CARDHOLDER_NAME'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_cardholder.cardholder_name
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'CUSTOMER_RELATION'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_cardholder.relation
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'RESIDENT'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_cardholder.resident
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'NATIONALITY'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_cardholder.nationality
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'MARITAL_STATUS'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_cardholder.marital_status
    );

end get_appl_data;

procedure change_objects(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_cardholder_id        in            com_api_type_pkg.t_long_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
  , i_person_id            in            com_api_type_pkg.t_person_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_card_id              in            com_api_type_pkg.t_medium_id
  , i_is_event_allowed     in            com_api_type_pkg.t_boolean
) is
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.change_objects: ';
    l_id_tab               com_api_type_pkg.t_number_tab;
    l_address_id           com_api_type_pkg.t_long_id;
    l_custom_event_id      com_api_type_pkg.t_medium_id;
    l_is_active            com_api_type_pkg.t_boolean;
    l_data_is_modified     com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
begin
    trc_log_pkg.debug(LOG_PREFIX || 'i_appl_data_id [' || i_appl_data_id || '], person_id [' || i_person_id || ']');

    -- Processing secure word
    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'SEC_WORD'
      , i_parent_id      => i_appl_data_id
      , o_appl_data_id   => l_id_tab
    );

    for i in 1..nvl(l_id_tab.count, 0) loop
        app_api_sec_question_pkg.process_sec_question(
            i_appl_data_id    => l_id_tab(i)
          , i_object_id       => i_cardholder_id
          , i_entity_type     => iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
        );
        l_data_is_modified := com_api_const_pkg.TRUE;
    end loop;

    -- Processing cardholder contacts
    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'CONTACT'
      , i_parent_id      => i_appl_data_id
      , o_appl_data_id   => l_id_tab
    );

    for i in 1..nvl(l_id_tab.count, 0) loop
        app_api_contact_pkg.process_contact(
            i_appl_data_id         => l_id_tab(i)
          , i_parent_appl_data_id  => i_appl_data_id
          , i_object_id            => i_cardholder_id
          , i_entity_type          => iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
          , i_person_id            => i_person_id
        );
        l_data_is_modified := com_api_const_pkg.TRUE;
    end loop;

    -- Processing cardholder address
    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'ADDRESS'
      , i_parent_id     => i_appl_data_id
      , o_appl_data_id  => l_id_tab
    );

    for i in 1..nvl(l_id_tab.count, 0) loop
        app_api_address_pkg.process_address(
            i_appl_data_id         => l_id_tab(i)
          , i_parent_appl_data_id  => i_appl_data_id
          , i_object_id            => i_cardholder_id
          , i_entity_type          => iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
          , o_address_id           => l_address_id
        );
        l_data_is_modified := com_api_const_pkg.TRUE;
    end loop;

    -- Processing notification
    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'NOTIFICATION'
      , i_parent_id     => i_appl_data_id
      , o_appl_data_id  => l_id_tab
    );

    g_custom_event_tab.delete;
    for i in 1..l_id_tab.count loop
        app_api_notification_pkg.process_notification(
            i_appl_data_id         => l_id_tab(i)
          , i_parent_appl_data_id  => i_appl_data_id
          , i_entity_type          => iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
          , i_object_id            => i_cardholder_id
          , i_inst_id              => i_inst_id
          , i_customer_id          => i_customer_id
          , i_linked_object_id     => i_card_id
          , o_custom_event_id      => l_custom_event_id
          , o_is_active            => l_is_active
        );

        g_custom_event_tab(nvl(g_custom_event_tab.last, 0) + 1).custom_event_id := l_custom_event_id;
        g_custom_event_tab(nvl(g_custom_event_tab.last, 0)).is_active           := l_is_active;

        l_data_is_modified := com_api_const_pkg.TRUE;

        trc_log_pkg.debug(LOG_PREFIX || 'l_custom_event_id='||l_custom_event_id || ', l_is_active=' || l_is_active);
    end loop;

    app_api_flexible_field_pkg.process_flexible_fields(
        i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
      , i_object_type   => null
      , i_object_id     => i_cardholder_id
      , i_inst_id       => i_inst_id
      , i_appl_data_id  => i_appl_data_id
    );

    -- If some objects of the cardholder were modified, it is necessary to register
    -- a new event EVENT_TYPE_CARDHOLDER_MODIFY without changing cardholder name itself
    if  i_is_event_allowed = com_api_const_pkg.TRUE
        and
        l_data_is_modified = com_api_const_pkg.TRUE
    then
        iss_api_cardholder_pkg.modify_cardholder(
            i_id               => i_cardholder_id
          , i_cardholder_name  => null
          , i_relation         => null
          , i_resident         => null
          , i_nationality      => null 
          , i_marital_status   => null
          , i_inst_id          => i_inst_id
          , i_is_event_forced  => com_api_const_pkg.TRUE
        );
    end if;
end change_objects;

procedure create_cardholder(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_parent_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_person_id            in            com_api_type_pkg.t_medium_id
  , i_card_id              in            com_api_type_pkg.t_medium_id
  , o_cardholder_id           out nocopy com_api_type_pkg.t_long_id
) is
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.create_cardholder: ';
    l_cardholder           iss_api_type_pkg.t_cardholder;
    l_appl_data_id         com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug(LOG_PREFIX || 'i_appl_data_id='||i_appl_data_id||', i_person_id='||i_person_id);

    get_appl_data(
        i_appl_data_id      => i_appl_data_id
      , o_cardholder        => l_cardholder
    );
    trc_log_pkg.debug(LOG_PREFIX || 'cardholder_name [' || l_cardholder.cardholder_name || ']');

    if l_cardholder.cardholder_name is null then
        for rec in (
            select a.first_name
                 , a.second_name
                 , a.surname
              from com_person a
             where a.id = i_person_id
        ) loop
            l_cardholder.cardholder_name := get_translit(
                generate_cardholder_name(
                    i_first_name  => rec.first_name
                  , i_second_name => rec.second_name
                  , i_surname     => rec.surname
                )
            );
        end loop;

        -- Update cardholder number
        app_api_application_pkg.get_appl_data_id(
            i_element_name      => 'CARDHOLDER_NAME'
          , i_parent_id         => i_appl_data_id
          , o_appl_data_id      => l_appl_data_id
        );

        if l_appl_data_id is null then
            app_api_application_pkg.add_element(
                i_element_name      => 'CARDHOLDER_NAME'
              , i_parent_id         => i_appl_data_id
              , i_element_value     => l_cardholder.cardholder_name
            );
        else
            app_api_application_pkg.modify_element(
                i_appl_data_id      => l_appl_data_id
              , i_element_value     => l_cardholder.cardholder_name
            );
        end if;

    end if;

    trc_log_pkg.debug(LOG_PREFIX || 'i_person_id [' || i_person_id || ']');

    iss_api_cardholder_pkg.create_cardholder(
        o_id                 => l_cardholder.id
      , i_customer_id        => i_customer_id
      , i_person_id          => i_person_id
      , i_cardholder_name    => l_cardholder.cardholder_name
      , i_relation           => l_cardholder.relation
      , i_resident           => l_cardholder.resident
      , i_nationality        => l_cardholder.nationality 
      , i_marital_status     => l_cardholder.marital_status
      , io_cardholder_number => l_cardholder.cardholder_number
      , i_inst_id            => i_inst_id
    );

    -- Update cardholder number
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'CARDHOLDER_NUMBER'
      , i_parent_id         => i_appl_data_id
      , o_appl_data_id      => l_appl_data_id
    );

    if l_appl_data_id is null then
        app_api_application_pkg.add_element(
            i_element_name      => 'CARDHOLDER_NUMBER'
          , i_parent_id         => i_appl_data_id
          , i_element_value     => l_cardholder.cardholder_number
        );
    else
        app_api_application_pkg.modify_element(
            i_appl_data_id      => l_appl_data_id
          , i_element_value     => l_cardholder.cardholder_number
        );
    end if;

    o_cardholder_id := l_cardholder.id;

    -- It is necessary to restrict registering event EVENT_TYPE_CARDHOLDER_MODIFY
    -- since event EVENT_TYPE_CARDHOLDER_CREATION is registered in this case
    change_objects(
        i_appl_data_id     => i_appl_data_id
      , i_cardholder_id    => l_cardholder.id
      , i_customer_id      => i_customer_id
      , i_person_id        => i_person_id
      , i_inst_id          => i_inst_id
      , i_card_id          => i_card_id
      , i_is_event_allowed => com_api_const_pkg.FALSE
    );

    for rec in (
        select a.person_id
             , a.inst_id
             , count(id) cnt
          from iss_cardholder_vw a
         where a.id = o_cardholder_id
      group by a.person_id
             , a.inst_id
        having count(id) > 1
    ) loop
        com_api_error_pkg.raise_error(
            i_error        => 'PERSON_LINKED_TO_MULTIPLE_CARDHOLDERS'
          , i_env_param1   => rec.person_id
          , i_env_param2   => rec.inst_id
          , i_env_param3   => rec.cnt
        );
    end loop;

    trc_log_pkg.info('New cardholder was created with ID [' || o_cardholder_id || ']');
end create_cardholder;

procedure change_cardholder(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_person_id            in            com_api_type_pkg.t_medium_id
  , i_cardholder_id        in            com_api_type_pkg.t_medium_id
  , i_card_id              in            com_api_type_pkg.t_medium_id
) is
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.change_cardholder: ';
    l_new                  iss_api_type_pkg.t_cardholder;
    l_old                  iss_api_type_pkg.t_cardholder;
    l_appl_data_id         com_api_type_pkg.t_long_id;
    l_is_new_crdhldr_name  com_api_type_pkg.t_boolean;
begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'i_appl_data_id [' || i_appl_data_id
                             || '], i_cardholder_id [' || i_cardholder_id || ']'
    );

    get_appl_data(
        i_appl_data_id   => i_appl_data_id
      , o_cardholder     => l_new
    );

    trc_log_pkg.debug(
        i_text => 'New cardholder data: l_new = {id [' || l_new.id
               || '], person_id [' || l_new.person_id
               || '], cardholder_number [' || l_new.cardholder_number
               || '], cardholder_name [' || l_new.cardholder_name
               || '], relation [' || l_new.relation || ']'
               || '], resident [' || l_new.resident || ']'
               || '], nationality [' || l_new.nationality || ']'
               || '], marital_status [' || l_new.marital_status || ']'
               || '], inst_id [' || l_new.inst_id || ']}'
    );

    -- getting old values for compare
    select a.id
         , a.person_id
         , a.inst_id
         , a.cardholder_number
         , a.cardholder_name
         , a.relation
         , a.resident
         , a.nationality 
         , a.marital_status
      into l_old.id
         , l_old.person_id
         , l_old.inst_id
         , l_old.cardholder_number
         , l_old.cardholder_name
         , l_old.relation
         , l_old.resident
         , l_old.nationality 
         , l_old.marital_status
      from iss_cardholder_vw a
     where a.id  = i_cardholder_id;

    trc_log_pkg.debug(
        i_text => 'Old cardholder found: l_old = {id [' || l_old.id
               || '], person_id [' || l_old.person_id
               || '], cardholder_number [' || l_old.cardholder_number
               || '], cardholder_name [' || l_old.cardholder_name
               || '], relation [' || l_old.relation || ']'
               || '], resident [' || l_old.resident || ']'
               || '], nationality [' || l_old.nationality || ']'
               || '], marital_status [' || l_old.marital_status || ']'
               || '], inst_id [' || l_old.inst_id || ']}'
    );

    l_is_new_crdhldr_name :=
        case
            when l_old.cardholder_name != l_new.cardholder_name
            then com_api_const_pkg.TRUE
            when l_old.relation != l_new.relation
            then com_api_const_pkg.TRUE
            when l_old.resident != l_new.resident
            then com_api_const_pkg.TRUE
            when l_old.nationality != l_new.nationality
            then com_api_const_pkg.TRUE
            when l_old.marital_status != l_new.marital_status
            then com_api_const_pkg.TRUE
            else com_api_const_pkg.FALSE
        end;

    trc_log_pkg.debug('l_is_new_crdhldr_name [' || l_is_new_crdhldr_name || ']');

    if l_old.person_id != i_person_id then
        com_api_error_pkg.raise_error(
            i_error      => 'CANNOT_CHANGE_PERSON'
          , i_env_param1 => l_old.person_id
        );
    end if;

    if l_old.inst_id != i_inst_id then
        com_api_error_pkg.raise_error(
            i_error      => 'CANNOT_CHANGE_INST'
          , i_env_param1 => l_old.inst_id
          , i_env_param2 => i_inst_id
        );
    end if;

    if l_new.cardholder_name is null then
        l_new.cardholder_name := l_old.cardholder_name;

        app_api_application_pkg.get_appl_data_id(
            i_element_name      => 'CARDHOLDER_NAME'
          , i_parent_id         => i_appl_data_id
          , o_appl_data_id      => l_appl_data_id
        );

        if l_appl_data_id is null then
            app_api_application_pkg.add_element(
                i_element_name      => 'CARDHOLDER_NAME'
              , i_parent_id         => i_appl_data_id
              , i_element_value     => l_new.cardholder_name
            );
        else
            app_api_application_pkg.modify_element(
                i_appl_data_id      => l_appl_data_id
              , i_element_value     => l_new.cardholder_name
            );
        end if;
    end if;

    if l_new.cardholder_number is null then
        l_new.cardholder_number := l_old.cardholder_number;

        app_api_application_pkg.get_appl_data_id(
            i_element_name      => 'CARDHOLDER_NUMBER'
          , i_parent_id         => i_appl_data_id
          , o_appl_data_id      => l_appl_data_id
        );

        if l_appl_data_id is null then
            app_api_application_pkg.add_element(
                i_element_name      => 'CARDHOLDER_NUMBER'
              , i_parent_id         => i_appl_data_id
              , i_element_value     => l_new.cardholder_number
            );
        else
            app_api_application_pkg.modify_element(
                i_appl_data_id      => l_appl_data_id
              , i_element_value     => l_new.cardholder_number
            );
        end if;
    end if;

    -- Event EVENT_TYPE_CARDHOLDER_MODIFY should be register when either cardholder name
    -- is changed or some cardholder's object is changed (contact, address, secure word or notification)
    if l_is_new_crdhldr_name = com_api_const_pkg.TRUE then
        iss_api_cardholder_pkg.modify_cardholder(
            i_id               => l_old.id
          , i_cardholder_name  => l_new.cardholder_name
          , i_relation         => l_new.relation
          , i_resident         => l_new.resident
          , i_nationality      => l_new.nationality 
          , i_marital_status   => l_new.marital_status
          , i_inst_id          => i_inst_id
          , i_is_event_forced  => com_api_const_pkg.FALSE
        );
    end if;

    -- The event should be registered only once to avoid situation when it is registered twice:
    -- 1st time during modification of cardholder name, and 2nd time after changing some
    -- cardholder object (see i_is_event_allowed)
    change_objects(
        i_appl_data_id     => i_appl_data_id
      , i_cardholder_id    => l_old.id
      , i_customer_id      => i_customer_id
      , i_person_id        => i_person_id
      , i_inst_id          => i_inst_id
      , i_card_id          => i_card_id
      , i_is_event_allowed => com_api_type_pkg.boolean_not(l_is_new_crdhldr_name)
    );
end change_cardholder;

procedure process_cardholder(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_parent_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_card_id              in            com_api_type_pkg.t_medium_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_is_pool_card         in            com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
  , o_cardholder_id           out nocopy com_api_type_pkg.t_long_id
) is
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_cardholder: ';
    l_command              com_api_type_pkg.t_dict_value;
    l_cardholder_number    com_api_type_pkg.t_name;
    l_appl_data_id         com_api_type_pkg.t_long_id;
    l_person_id            com_api_type_pkg.t_person_id;
    l_search_condition     com_api_type_pkg.t_name; -- for using in raise_error()
    l_linked_cardholder_id com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug(LOG_PREFIX || 'i_appl_data_id [' || i_appl_data_id || ']');

    app_api_application_pkg.get_element_value(
        i_element_name   => 'COMMAND'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_command
    );
    trc_log_pkg.debug(LOG_PREFIX || 'l_command [' || l_command || ']');

    app_api_application_pkg.get_element_value(
        i_element_name   => 'CARDHOLDER_NUMBER'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_cardholder_number
    );

    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'PERSON'
      , i_parent_id      => i_appl_data_id
      , o_appl_data_id   => l_appl_data_id
    );

    -- search for cardholder by l_cardholder_number(1) or i_card_id(2)
    if l_cardholder_number is not null
       or
       i_card_id is not null
    then
        trc_log_pkg.debug(
            i_text       => 'Search cardholder by inst_id [#1], cardholder_number [#2] or card_id [#3]'
          , i_env_param1 => i_inst_id
          , i_env_param2 => l_cardholder_number
          , i_env_param3 => i_card_id
        );
        l_search_condition :=
            case
                when l_cardholder_number is not null then
                    'cardholder_number = ' || l_cardholder_number
                when i_card_id is not null then
                    'card_id = ' || i_card_id
            end;

        declare
            l_cardholder    iss_api_type_pkg.t_cardholder;
        begin
            l_cardholder := iss_api_cardholder_pkg.get_cardholder(
                                i_inst_id           => i_inst_id
                              , i_cardholder_number => l_cardholder_number
                              , i_card_id           => i_card_id
                              , i_mask_error        => com_api_const_pkg.TRUE
                            );
            o_cardholder_id := l_cardholder.id;
            l_person_id     := l_cardholder.person_id;
        end;

        if l_appl_data_id is not null then
            app_api_person_pkg.process_person(
                i_appl_data_id  => l_appl_data_id
              , io_person_id    => l_person_id
            );
        elsif l_person_id is null then
            l_person_id := app_api_customer_pkg.get_customer_person_id;
        end if;

    else
        if l_appl_data_id is not null then
            app_api_person_pkg.process_person (
                i_appl_data_id  => l_appl_data_id
              , io_person_id    => l_person_id
            );
        else
            l_person_id := app_api_customer_pkg.get_customer_person_id;
        end if;

        trc_log_pkg.debug(
            i_text       => 'Search cardholder by inst_id [#1], person_id [#2]'
          , i_env_param1 => i_inst_id
          , i_env_param2 => l_person_id
        );
        l_search_condition := 'person_id = ' || l_person_id;

        o_cardholder_id := iss_api_cardholder_pkg.get_cardholder(
                               i_inst_id           => i_inst_id
                             , i_cardholder_number => null
                             , i_person_id         => l_person_id
                             , i_mask_error        => com_api_const_pkg.TRUE
                           ).id;
    end if;

    trc_log_pkg.debug (
        i_text => LOG_PREFIX || 'o_cardholder_id [' || o_cardholder_id || '], l_person_id [' || l_person_id || ']'
    );

    if o_cardholder_id is not null then

        if i_card_id is not null and i_is_pool_card = com_api_const_pkg.FALSE then
            select cardholder_id
              into l_linked_cardholder_id
              from iss_card
             where id = i_card_id;

            if l_linked_cardholder_id != o_cardholder_id then
                com_api_error_pkg.raise_error(
                    i_error      => 'CARDHOLDER_NOT_FOUND'
                  , i_env_param1 => l_search_condition
                );
            end if;
        end if;

        if l_command in (
            app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
          , app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED
        ) then
            change_objects(
                i_appl_data_id     => i_appl_data_id
              , i_customer_id      => i_customer_id
              , i_inst_id          => i_inst_id
              , i_person_id        => l_person_id
              , i_cardholder_id    => o_cardholder_id
              , i_card_id          => i_card_id
              , i_is_event_allowed => com_api_const_pkg.TRUE

            );
        elsif l_command = app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT then
            com_api_error_pkg.raise_error(
                i_error   => 'CARDHOLDER_ALREADY_EXISTS'
              , i_env_param1  => l_search_condition
            );
        --elsif l_command in (
        --    app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
        --  , app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
        --) then
        else
            change_cardholder(
                i_appl_data_id     => i_appl_data_id
              , i_customer_id      => i_customer_id
              , i_inst_id          => i_inst_id
              , i_person_id        => l_person_id
              , i_cardholder_id    => o_cardholder_id
              , i_card_id          => i_card_id
            );
        end if;

    else -- cardholder is NOT found
        if l_command = app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE then
            null;
        elsif l_command in (
            app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
          , app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
          , app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED
        ) then
            com_api_error_pkg.raise_error(
                i_error      => 'CARDHOLDER_NOT_FOUND'
              , i_env_param1 => l_search_condition
            );
        --elsif l_command in (
        --    app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
        --  , app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
        --  , app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
        --) then
        else
            create_cardholder(
                i_appl_data_id        => i_appl_data_id
              , i_parent_appl_data_id => i_parent_appl_data_id
              , i_customer_id         => i_customer_id
              , i_inst_id             => i_inst_id
              , i_person_id           => l_person_id
              , i_card_id             => i_card_id
              , o_cardholder_id       => o_cardholder_id
            );
        end if;
    end if;

    app_api_note_pkg.process_note(
        i_appl_data_id => i_appl_data_id
      , i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
      , i_object_id    => o_cardholder_id
    );

    attach_cardholder_to_appl (
      i_cardholder_id  => o_cardholder_id
    );

exception
    when com_api_error_pkg.e_application_error then
        app_api_error_pkg.intercept_error(
            i_appl_data_id  => i_appl_data_id
          , i_element_name  => 'CARDHOLDER'
        );
end;

end;
/
