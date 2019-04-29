create or replace package body app_api_person_pkg as
/*******************************************************************
*  API for application's person <br />
*  Created by Filimonov A.(filimonov@bpc.ru)  at 22.09.2009 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: APP_API_PERSON_PKG <br />
*  @headcom
******************************************************************/

procedure get_appl_data(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_person_id            in            com_api_type_pkg.t_person_id default null
  , o_person                  out nocopy com_api_type_pkg.t_person
) is
    l_appl_data_rec        app_api_type_pkg.t_appl_data_rec;
    l_root_id              com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.get_appl_data START');
    
    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'APPLICATION'
      , i_parent_id      => null
      , o_appl_data_id   => l_root_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'INSTITUTION_ID'
      , i_parent_id      => l_root_id
      , o_element_value  => o_person.inst_id
    );

    if i_person_id is not null then
        o_person.person_title := com_api_person_pkg.get_person(i_person_id => i_person_id).person_title;
    end if;
    
    app_api_application_pkg.get_element_value(
        i_element_name   => 'PERSON_TITLE'
      , i_parent_id      => i_appl_data_id
      , i_current_value  => o_person.person_title
      , o_element_value  => o_person.person_title
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'SUFFIX'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_person.suffix
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'GENDER'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_person.gender
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'BIRTHDAY'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_person.birthday
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'PLACE_OF_BIRTH'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_person.place_of_birth
    );
    
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.get_appl_data END');

exception
    when com_api_error_pkg.e_value_error or com_api_error_pkg.e_invalid_number then
        l_appl_data_rec := app_api_application_pkg.get_last_appl_data_rec(); -- receive data of last processed element
        app_api_error_pkg.raise_error(
            i_appl_data_id => i_appl_data_id
          , i_error        => 'INCORRECT_ELEMENT_VALUE'
          , i_env_param1   => l_appl_data_rec.element_value
          , i_env_param2   => l_appl_data_rec.element_name
          , i_env_param3   => l_appl_data_rec.data_type
          , i_env_param4   => l_appl_data_rec.parent_id
          , i_env_param5   => l_appl_data_rec.element_type
          , i_env_param6   => l_appl_data_rec.serial_number
          , i_element_name => l_appl_data_rec.element_name
        );
end get_appl_data;

procedure change_objects(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_person_id            in            com_api_type_pkg.t_person_id
) is
    l_card_id              com_api_type_pkg.t_long_id;
begin
    app_api_id_object_pkg.process_id_object(
        i_appl_data_id => i_appl_data_id
      , i_entity_type  => com_api_const_pkg.ENTITY_TYPE_PERSON
      , i_object_id    => i_person_id
      , o_id           => l_card_id
    );
end change_objects;

procedure change_person(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_person_id            in            com_api_type_pkg.t_person_id
) is
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.change_person';
    l_person               com_api_type_pkg.t_person;
    l_id_tab               com_api_type_pkg.t_number_tab;
    l_lang_tab             com_api_type_pkg.t_dict_tab;
begin
    trc_log_pkg.debug(LOG_PREFIX || ' START: i_person_id [' || i_person_id || ']');

    get_appl_data(
        i_appl_data_id   => i_appl_data_id
      , i_person_id      => i_person_id
      , o_person         => l_person
    );

    -- process multi-language person name
    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'PERSON_NAME'
      , i_parent_id      => i_appl_data_id
      , o_appl_data_id   => l_id_tab
      , o_appl_data_lang => l_lang_tab
    );

    trc_log_pkg.debug(LOG_PREFIX || ': blocks <person_name> have been read: ' || l_id_tab.count());

    for i in 1..l_lang_tab.count loop
        for j in 1..l_lang_tab.count loop
            if i < j and l_lang_tab(i) = l_lang_tab(j) then
                com_api_error_pkg.raise_error(
                    i_error         =>  'DUPLICATE_PERSON_NAME'
                  , i_env_param1    =>  i_person_id
                  , i_env_param2    =>  l_lang_tab(i)
                );
            end if;
        end loop;
    end loop;

    for i in 1..l_id_tab.count loop
        l_person.lang := l_lang_tab(i);

        app_api_application_pkg.get_element_value(
            i_element_name   => 'FIRST_NAME'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_person.first_name
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'SECOND_NAME'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_person.second_name
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'SURNAME'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_person.surname
        );

        com_api_person_pkg.modify_person(
            i_person_id      =>  i_person_id
          , i_person_title   =>  l_person.person_title
          , i_first_name     =>  l_person.first_name
          , i_second_name    =>  l_person.second_name
          , i_surname        =>  l_person.surname
          , i_suffix         =>  l_person.suffix
          , i_gender         =>  l_person.gender
          , i_birthday       =>  l_person.birthday
          , i_place_of_birth =>  l_person.place_of_birth
          , i_seqnum         =>  null
          , i_lang           =>  l_person.lang
          , i_inst_id        =>  l_person.inst_id
        );
    end loop;

    change_objects(
        i_appl_data_id  => i_appl_data_id
      , i_person_id     => i_person_id
    );

    trc_log_pkg.debug(LOG_PREFIX || ' END');
end change_person;

procedure create_person(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , o_person_id               out nocopy com_api_type_pkg.t_person_id
) is
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.create_person';
    l_person               com_api_type_pkg.t_person;
    l_id_tab               com_api_type_pkg.t_number_tab;
    l_lang_tab             com_api_type_pkg.t_dict_tab;
begin
    trc_log_pkg.debug(LOG_PREFIX || ' START: i_appl_data_id [' || i_appl_data_id || ']');

    get_appl_data(
        i_appl_data_id   => i_appl_data_id
      , o_person         => l_person
    );

    -- process multi-language person name
    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'PERSON_NAME'
      , i_parent_id      => i_appl_data_id
      , o_appl_data_id   => l_id_tab
      , o_appl_data_lang => l_lang_tab
    );
    
    trc_log_pkg.debug(LOG_PREFIX || ': blocks <person_name> have been read: ' || l_id_tab.count());

    for i in 1..l_lang_tab.count loop
        for j in 1..l_lang_tab.count loop
            if i < j and l_lang_tab(i) = l_lang_tab(j) then
                com_api_error_pkg.raise_error(
                    i_error         => 'DUPLICATE_PERSON_NAME'
                  , i_env_param1    => null
                  , i_env_param2    => l_lang_tab(i)
                );
            end if;
        end loop;
    end loop;

    o_person_id := null;

    for i in 1..l_id_tab.count loop
        l_person.lang := l_lang_tab(i);

        app_api_application_pkg.get_element_value(
            i_element_name   => 'FIRST_NAME'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_person.first_name
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'SECOND_NAME'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_person.second_name
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'SURNAME'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_person.surname
        );

        com_api_person_pkg.add_person(
            io_person_id     => o_person_id
          , i_lang           => l_person.lang
          , i_person_title   => l_person.person_title
          , i_first_name     => l_person.first_name
          , i_second_name    => l_person.second_name
          , i_surname        => l_person.surname
          , i_suffix         => l_person.suffix
          , i_gender         => l_person.gender
          , i_birthday       => l_person.birthday
          , i_place_of_birth => l_person.place_of_birth
          , i_inst_id        => l_person.inst_id
        );
    end loop;

    trc_log_pkg.debug(LOG_PREFIX || ': person with id [' || o_person_id || '] has been created');

    change_objects(
        i_appl_data_id => i_appl_data_id
      , i_person_id    => o_person_id
    );

    trc_log_pkg.debug(LOG_PREFIX || ' END');
end create_person;

procedure process_person(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , io_person_id           in out nocopy com_api_type_pkg.t_person_id
) is
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_person: ';
    l_command              com_api_type_pkg.t_dict_value;
    l_id_tab               com_api_type_pkg.t_number_tab;
    l_lang_tab             com_api_type_pkg.t_dict_tab;
    l_inst_id              com_api_type_pkg.t_inst_id;
    l_root_id              com_api_type_pkg.t_long_id;
    l_id_card_is_present   com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
begin
    trc_log_pkg.debug(LOG_PREFIX || 'START with i_appl_data_id [' || i_appl_data_id || ']');

    cst_api_application_pkg.process_person_before (
        i_appl_data_id   => i_appl_data_id
      , io_person_id     => io_person_id
    );

    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'APPLICATION'
      , i_parent_id      => null
      , o_appl_data_id   => l_root_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'INSTITUTION_ID'
      , i_parent_id      => l_root_id
      , o_element_value  => l_inst_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'COMMAND'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_command
    );

    trc_log_pkg.debug(LOG_PREFIX || 'io_person_id [' || io_person_id || '], command [' || l_command || ']');

    if io_person_id is null then
        -- we try to search person with its identification documents
        app_api_application_pkg.get_appl_data_id(
            i_element_name => 'IDENTITY_CARD'
          , i_parent_id    => i_appl_data_id
          , o_appl_data_id => l_id_tab
        );
        
        if l_id_tab.count() > 0 then
            trc_log_pkg.debug(LOG_PREFIX || 'searching person by <identity_card> data...');
            
            l_id_card_is_present := com_api_type_pkg.TRUE;

            declare
                l_card    com_api_type_pkg.t_identity_card;
                i         pls_integer := l_id_tab.first();
            begin
                l_card.inst_id := l_inst_id;
                loop
                    app_api_application_pkg.get_element_value(
                        i_element_name   => 'ID_TYPE'
                      , i_parent_id      => l_id_tab(i)
                      , o_element_value  => l_card.id_type
                    );
                    app_api_application_pkg.get_element_value(
                        i_element_name   => 'ID_SERIES'
                      , i_parent_id      => l_id_tab(i)
                      , o_element_value  => l_card.id_series
                    );
                    app_api_application_pkg.get_element_value(
                        i_element_name   => 'ID_NUMBER'
                      , i_parent_id      => l_id_tab(i)
                      , o_element_value  => l_card.id_number
                    );

                    com_api_person_pkg.get_person_id(
                        i_identity_card  => l_card
                      , i_person         => null -- searching only by IDENTITY_CARD data
                      , o_person_id      => io_person_id
                    );
                    
                    exit when io_person_id is not null
                           or i = l_id_tab.last();
                           
                    i := l_id_tab.next(i);
                end loop;
            end;
            
            trc_log_pkg.debug(LOG_PREFIX || 'io_person_id [' || io_person_id || ']');
        end if;
    end if;

    -- we use searching by person name only if identity card isn't passed,
    -- otherwise we consider that there is a name of new(!) person in tag (block) <person_name>  
    if  io_person_id is null 
        and 
        l_id_card_is_present = com_api_type_pkg.FALSE 
    then
        trc_log_pkg.debug(LOG_PREFIX || 'searching person by <person_name> data...');
        
        app_api_application_pkg.get_appl_data_id(
            i_element_name   => 'PERSON_NAME'
          , i_parent_id      => i_appl_data_id
          , o_appl_data_id   => l_id_tab
          , o_appl_data_lang => l_lang_tab
        );
        
        if l_id_tab.count() > 0 then
            -- multi-language person name
            for i in 1..l_lang_tab.count loop
                for j in 1..l_lang_tab.count loop
                    if i < j and l_lang_tab(i) = l_lang_tab(j) then
                        com_api_error_pkg.raise_error(
                            i_error      => 'DUPLICATE_PERSON_NAME'
                          , i_env_param1 => null
                          , i_env_param2 => l_lang_tab(i)
                        );
                    end if;
                end loop;
            end loop;

            declare
                l_person    com_api_type_pkg.t_person;
                i           pls_integer := l_id_tab.first();
            begin
                l_person.inst_id := l_inst_id;
                app_api_application_pkg.get_element_value(
                    i_element_name   => 'BIRTHDAY'
                  , i_parent_id      => i_appl_data_id
                  , o_element_value  => l_person.birthday
                );
                app_api_application_pkg.get_element_value(
                    i_element_name   => 'PLACE_OF_BIRTH'
                  , i_parent_id      => i_appl_data_id
                  , o_element_value  => l_person.place_of_birth
                );
                loop
                    l_person.lang := coalesce(l_lang_tab(i), get_user_lang());

                    app_api_application_pkg.get_element_value(
                        i_element_name   => 'FIRST_NAME'
                      , i_parent_id      => l_id_tab(i)
                      , o_element_value  => l_person.first_name
                    );
                    app_api_application_pkg.get_element_value(
                        i_element_name   => 'SECOND_NAME'
                      , i_parent_id      => l_id_tab(i)
                      , o_element_value  => l_person.second_name
                    );
                    app_api_application_pkg.get_element_value(
                        i_element_name   => 'SURNAME'
                      , i_parent_id      => l_id_tab(i)
                      , o_element_value  => l_person.surname
                    );

                    com_api_person_pkg.get_person_id(
                        i_identity_card => null -- searching only by PERSON data
                      , i_person        => l_person
                      , o_person_id     => io_person_id
                    );

                    exit when io_person_id is not null
                           or i = l_id_tab.last();
                           
                    i := l_id_tab.next(i);
                end loop;
            end;
        end if;

        trc_log_pkg.debug(LOG_PREFIX || 'io_person_id [' || io_person_id || ']');
    end if;

    trc_log_pkg.debug(LOG_PREFIX || 'processing io_person_id [' || io_person_id || '] in according to command');

    if io_person_id is not null then
        if l_command in (
               app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
             , app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED
           )
        then
            change_objects(
                i_appl_data_id  =>  i_appl_data_id
              , i_person_id     =>  io_person_id
            );
        elsif l_command = app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT then
            com_api_error_pkg.raise_error(
                i_error         => 'PERSON_ALREADY_EXIST'
              , i_env_param1    => io_person_id
            );
        elsif l_command in (
            app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
          , app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
        ) then
            change_person(
                i_appl_data_id  => i_appl_data_id
              , i_person_id     => io_person_id
            );
        else
            trc_log_pkg.debug(LOG_PREFIX || 'command has been ignored');
        end if;

    else
        if l_command in (app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE) then
            trc_log_pkg.debug(LOG_PREFIX || 'command has been ignored');
        elsif l_command in (
            app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
          , app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
          , app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED
        ) then
            com_api_error_pkg.raise_error(
                i_error      => 'PERSON_NOT_FOUND'
              , i_env_param1 => io_person_id
            );
        --elsif l_command in (
        --    app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
        --  , app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
        --  , app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
        --) then
        else
            create_person(
                i_appl_data_id => i_appl_data_id
              , o_person_id    => io_person_id
            );
        end if;
    end if;

    app_api_flexible_field_pkg.process_flexible_fields(
        i_entity_type   => 'ENTTPERS'
      , i_object_type   => null
      , i_object_id     => io_person_id
      , i_inst_id       => l_inst_id
      , i_appl_data_id  => i_appl_data_id
    );

    app_api_note_pkg.process_note(
        i_appl_data_id => i_appl_data_id
      , i_entity_type  => com_api_const_pkg.ENTITY_TYPE_PERSON
      , i_object_id    => io_person_id
    );

    cst_api_application_pkg.process_person_after(
        i_appl_data_id  => i_appl_data_id
      , io_person_id    => io_person_id
    );
    
    trc_log_pkg.debug(LOG_PREFIX || 'END with io_person_id [' || io_person_id || ']');

exception
    when com_api_error_pkg.e_application_error then
        app_api_error_pkg.intercept_error(
            i_appl_data_id  => i_appl_data_id
          , i_element_name  => 'PERSON'
        );
end process_person;

procedure process_dummy_person(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_pool_number          in            com_api_type_pkg.t_short_id
  , io_person_id              out nocopy com_api_type_pkg.t_person_id
) is
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_dummy_person';
    l_person               com_api_type_pkg.t_person;
    l_id_tab               com_api_type_pkg.t_number_tab;
    l_lang_tab             com_api_type_pkg.t_dict_tab;
    
    function get_name_value(
        i_name_value       com_api_type_pkg.t_name
    ) return com_api_type_pkg.t_name as
        l_param_tab            com_api_type_pkg.t_param_tab;
    begin
        rul_api_param_pkg.set_param(
            io_params     => l_param_tab
          , i_name        => 'NAME_VALUE'
          , i_value       => i_name_value
        );
        rul_api_param_pkg.set_param(
            io_params     => l_param_tab
          , i_name        => 'SEQ_NUMBER'
          , i_value       => i_pool_number
        );
        rul_api_param_pkg.set_param(
            io_params     => l_param_tab
          , i_name        => 'INST_ID'
          , i_value       => l_person.inst_id
        );
        rul_api_param_pkg.set_param(
            io_params     => l_param_tab
          , i_name        => 'SYS_DATE'
          , i_value       => com_api_sttl_day_pkg.get_sysdate
        );
        rul_api_param_pkg.set_param(
            io_params     => l_param_tab
          , i_name        => 'APPLICATION_ID'
          , i_value       => app_api_application_pkg.get_appl_id
        );
        
        return rul_api_name_pkg.get_name(
                   i_inst_id             => l_person.inst_id
                 , i_entity_type         => com_api_const_pkg.ENTITY_TYPE_PERSON
                 , i_param_tab           => l_param_tab
                 , i_double_check_value  => null
               );
    end;
begin
    trc_log_pkg.debug(LOG_PREFIX || ' START: i_appl_data_id [' || i_appl_data_id || ']');

    get_appl_data(
        i_appl_data_id   => i_appl_data_id
      , o_person         => l_person
    );

    -- process multi-language person name
    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'PERSON_NAME'
      , i_parent_id      => i_appl_data_id
      , o_appl_data_id   => l_id_tab
      , o_appl_data_lang => l_lang_tab
    );
    
    trc_log_pkg.debug(LOG_PREFIX || ': blocks <person_name> have been read: ' || l_id_tab.count());

    for i in 1..l_lang_tab.count loop
        for j in 1..l_lang_tab.count loop
            if i < j and l_lang_tab(i) = l_lang_tab(j) then
                com_api_error_pkg.raise_error(
                    i_error         => 'DUPLICATE_PERSON_NAME'
                  , i_env_param1    => null
                  , i_env_param2    => l_lang_tab(i)
                );
            end if;
        end loop;
    end loop;

    io_person_id := null;

    for i in 1..l_id_tab.count loop
        l_person.lang := l_lang_tab(i);

        app_api_application_pkg.get_element_value(
            i_element_name   => 'FIRST_NAME'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_person.first_name
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'SECOND_NAME'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_person.second_name
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'SURNAME'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_person.surname
        );
        
        l_person.first_name  := get_name_value(i_name_value => l_person.first_name);
        l_person.second_name := get_name_value(i_name_value => l_person.second_name);
        l_person.surname     := get_name_value(i_name_value => l_person.surname);
        
        com_api_person_pkg.add_person(
            io_person_id     => io_person_id
          , i_lang           => l_person.lang
          , i_person_title   => l_person.person_title
          , i_first_name     => l_person.first_name
          , i_second_name    => l_person.second_name
          , i_surname        => l_person.surname
          , i_suffix         => l_person.suffix
          , i_gender         => l_person.gender
          , i_birthday       => l_person.birthday
          , i_place_of_birth => l_person.place_of_birth
          , i_inst_id        => l_person.inst_id
        );
    end loop;

    trc_log_pkg.debug(LOG_PREFIX || ': person with id [' || io_person_id || '] has been created');

    change_objects(
        i_appl_data_id => i_appl_data_id
      , i_person_id    => io_person_id
    );

    trc_log_pkg.debug(LOG_PREFIX || ' END');
end;

end;
/
