create or replace package body app_api_contact_pkg as
/*******************************************************************
*  API for application contacts <br />
*  Created by Filimonov A.(filimonov@bpc.ru)  at 22.09.2009 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: app_api_contact_pkg <br />
*  @headcom
******************************************************************/

procedure get_appl_data (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , o_contact                 out nocopy app_api_type_pkg.t_contact
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

    app_api_application_pkg.get_element_value (
        i_element_name   => 'INSTITUTION_ID'
      , i_parent_id      => l_root_id
      , o_element_value  => o_contact.inst_id
    );

    app_api_application_pkg.get_element_value (
        i_element_name   => 'JOB_TITLE'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_contact.job_title
    );

    app_api_application_pkg.get_element_value (
        i_element_name   => 'CONTACT_TYPE'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_contact.contact_type
    );
    begin
        com_api_dictionary_pkg.check_article(substr(o_contact.contact_type, 1, 4), o_contact.contact_type);
    exception
        when com_api_error_pkg.e_application_error then
            com_api_error_pkg.raise_error(
                i_error      => 'INVALID_CONTACT_TYPE'
              , i_env_param1 => o_contact.contact_type
            );
    end;

    app_api_application_pkg.get_element_value (
        i_element_name   => 'PREFERRED_LANG'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_contact.preferred_lang
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

procedure create_contact_data (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_contact_id           in            com_api_type_pkg.t_medium_id
) is
    l_contact_data_tab     com_api_type_pkg.t_number_tab;
    l_commun_method        com_api_type_pkg.t_dict_value;
    l_commun_address       com_api_type_pkg.t_full_desc;
    l_start_date           date;
    l_end_date             date;
    l_start_date_time      date;
begin
    -- processing contact data
    app_api_application_pkg.get_appl_data_id (
        i_element_name  => 'CONTACT_DATA'
      , i_parent_id     => i_appl_data_id
      , o_appl_data_id  => l_contact_data_tab
    );

    trc_log_pkg.debug (
        i_text        => 'create_contact_data: i_appl_data_id[#1], l_contact_data_tab.count[#2]'
      , i_env_param1  => i_appl_data_id
      , i_env_param2  => l_contact_data_tab.count
    );

    for i in 1..nvl(l_contact_data_tab.count, 0) loop
        app_api_application_pkg.get_element_value (
            i_element_name   => 'COMMUN_METHOD'
          , i_parent_id      => l_contact_data_tab(i)
          , o_element_value  => l_commun_method
        );

        app_api_application_pkg.get_element_value (
            i_element_name   => 'COMMUN_ADDRESS'
          , i_parent_id      => l_contact_data_tab(i)
          , o_element_value  => l_commun_address
        );

        app_api_application_pkg.get_element_value (
            i_element_name   => 'START_DATE'
          , i_parent_id      => l_contact_data_tab(i)
          , o_element_value  => l_start_date
        );

        app_api_application_pkg.get_element_value (
            i_element_name   => 'END_DATE'
          , i_parent_id      => l_contact_data_tab(i)
          , o_element_value  => l_end_date
        );
        
        app_api_application_pkg.get_element_value (
            i_element_name   => 'START_DATE_TIME'
          , i_parent_id      => l_contact_data_tab(i)
          , o_element_value  => l_start_date_time
        );
        
        com_api_contact_pkg.add_contact_data (
            i_contact_id     => i_contact_id
          , i_commun_method  => l_commun_method
          , i_commun_address => l_commun_address
          , i_start_date     => nvl(l_start_date_time, l_start_date)
          , i_end_date       => l_end_date
        );
    end loop;
end;

procedure change_contact_data (
    i_appl_data_id         in      com_api_type_pkg.t_long_id
  , i_contact_id           in      com_api_type_pkg.t_medium_id
  , i_inst_id              in      com_api_type_pkg.t_inst_id
  , i_entity_type          in      com_api_type_pkg.t_dict_value
  , i_object_id            in      com_api_type_pkg.t_long_id
) is
    l_contact_data_tab      com_api_type_pkg.t_number_tab;
    l_commun_method         com_api_type_pkg.t_dict_value;
    l_commun_address        com_api_type_pkg.t_full_desc;
    l_start_date            date;
    l_end_date              date;
    l_start_date_time       date;
begin
    -- processing contact data
    app_api_application_pkg.get_appl_data_id (
        i_element_name  => 'CONTACT_DATA'
      , i_parent_id     => i_appl_data_id
      , o_appl_data_id  => l_contact_data_tab
    );

    trc_log_pkg.debug (
        i_text        => 'change_contact_data: i_appl_data_id[#1], l_contact_data_tab.count[#2]'
      , i_env_param1  => i_appl_data_id
      , i_env_param2  => l_contact_data_tab.count
    );

    for i in 1..nvl(l_contact_data_tab.count, 0) loop
        app_api_application_pkg.get_element_value (
            i_element_name   => 'COMMUN_METHOD'
          , i_parent_id      => l_contact_data_tab(i)
          , o_element_value  => l_commun_method
        );

        app_api_application_pkg.get_element_value (
            i_element_name   => 'COMMUN_ADDRESS'
          , i_parent_id      => l_contact_data_tab(i)
          , o_element_value  => l_commun_address
        );

        app_api_application_pkg.get_element_value (
            i_element_name   => 'START_DATE'
          , i_parent_id      => l_contact_data_tab(i)
          , o_element_value  => l_start_date
        );

        app_api_application_pkg.get_element_value (
            i_element_name   => 'END_DATE'
          , i_parent_id      => l_contact_data_tab(i)
          , o_element_value  => l_end_date
        );
            
        app_api_application_pkg.get_element_value (
            i_element_name   => 'START_DATE_TIME'
          , i_parent_id      => l_contact_data_tab(i)
          , o_element_value  => l_start_date_time
        );

        com_api_contact_pkg.modify_contact_data (
            i_entity_type    => i_entity_type
          , i_object_id      => i_object_id
          , i_inst_id        => i_inst_id
          , i_contact_id     => i_contact_id
          , i_commun_method  => l_commun_method
          , i_commun_address => l_commun_address
          , i_start_date     => nvl(l_start_date_time, l_start_date)
          , i_end_date       => l_end_date
        );
    end loop;
end;

procedure change_contact (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_object_id            in            com_api_type_pkg.t_long_id
  , i_entity_type          in            com_api_type_pkg.t_dict_value
  , i_contact_id           in            com_api_type_pkg.t_long_id
  , i_contact_object_id    in            com_api_type_pkg.t_long_id
  , i_person_id            in            com_api_type_pkg.t_long_id
) is
    l_contact              app_api_type_pkg.t_contact;
    l_appl_data_id         com_api_type_pkg.t_long_id;
    l_count                com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug (
        i_text          => 'app_api_contact_pkg.change_contact: i_entity_type[#1] i_contact_id[#2] i_contact_object_id[#3] i_object_id[#4]'
        , i_env_param1  => i_entity_type
        , i_env_param2  => i_contact_id
        , i_env_param3  => i_contact_object_id
        , i_env_param4  => i_object_id
    );

    get_appl_data(
        i_appl_data_id  => i_appl_data_id
      , o_contact       => l_contact
    );

    -- processing contact person
    if i_person_id is null then
        app_api_application_pkg.get_appl_data_id (
            i_element_name   => 'PERSON'
          , i_parent_id      => i_appl_data_id
          , o_appl_data_id   => l_appl_data_id
        );

        if l_appl_data_id is not null then
            app_api_person_pkg.process_person (
                i_appl_data_id  => l_appl_data_id
              , io_person_id    => l_contact.person_id
            );
        end if;

    else
        -- check existing person
        begin
            select min(a.id)
              into l_contact.person_id
              from com_person a
             where a.id = i_person_id;
        exception
            when no_data_found then
                app_api_error_pkg.raise_error (
                    i_error         => 'ABSENT_MANDATORY_ELEMENT'
                  , i_env_param1    => 'PERSON'
                  , i_appl_data_id  => i_appl_data_id
                  , i_element_name  => 'CONTACT'
                  , i_appl_id       => app_api_application_pkg.get_appl_id()
                );
         end;
    end if;

    begin
        select id
             , inst_id
          into l_contact.id
             , l_contact.inst_id
          from com_contact_vw
         where id      = i_contact_id
           and inst_id = ost_api_institution_pkg.get_sandbox(l_contact.inst_id);

        com_api_contact_pkg.modify_contact (
            i_id              => l_contact.id
          , i_preferred_lang  => l_contact.preferred_lang
          , i_job_title       => l_contact.job_title
          , i_person_id       => l_contact.person_id
        );
    exception
        when no_data_found then
            com_api_contact_pkg.add_contact (
                o_id              => l_contact.id
              , i_preferred_lang  => l_contact.preferred_lang
              , i_job_title       => l_contact.job_title
              , i_person_id       => l_contact.person_id
              , i_inst_id         => l_contact.inst_id
            );

            com_api_contact_pkg.add_contact_object (
                i_contact_id         => l_contact.id
              , i_entity_type        => i_entity_type
              , i_contact_type       => l_contact.contact_type
              , i_object_id          => i_object_id
              , o_contact_object_id  => l_count
            );
    end;

    -- Change contact data if contact is linked with entity i_object_id.
    -- Otherwise, it is neeeded to create a new contact with data
    -- and associated entity object i_entity_type & i_object_id
    change_contact_data (
        i_appl_data_id => i_appl_data_id
      , i_contact_id   => l_contact.id
      , i_inst_id      => l_contact.inst_id
      , i_entity_type  => i_entity_type
      , i_object_id    => i_object_id
    );
end;

procedure remove_contact (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_contact_id           in            com_api_type_pkg.t_long_id
) is
    l_contact_data_tab    com_api_type_pkg.t_number_tab;
    l_commun_method       com_api_type_pkg.t_dict_value;
    l_commun_address      com_api_type_pkg.t_full_desc;
    l_contact_data_id     com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug (
        i_text        => 'app_api_contact_pkg.remove_contact: i_contact_id[#1]'
      , i_env_param1  => i_contact_id
    );

    -- processing contact data
    app_api_application_pkg.get_appl_data_id (
        i_element_name  => 'CONTACT_DATA'
      , i_parent_id     => i_appl_data_id
      , o_appl_data_id  => l_contact_data_tab
    );

    for i in 1..nvl(l_contact_data_tab.count, 0) loop
        app_api_application_pkg.get_element_value (
            i_element_name   => 'COMMUN_METHOD'
          , i_parent_id      => l_contact_data_tab(i)
          , o_element_value  => l_commun_method
        );

        app_api_application_pkg.get_element_value (
            i_element_name   => 'COMMUN_ADDRESS'
          , i_parent_id      => l_contact_data_tab(i)
          , o_element_value  => l_commun_address
        );

        update com_contact_data d
           set end_date         = get_sysdate
         where contact_id       = i_contact_id
           and d.commun_address = l_commun_address
           and d.commun_method  = l_commun_method
     returning d.id
          into l_contact_data_id;

        trc_log_pkg.debug('removed contact data: id='||l_contact_data_id||', commun_method='||l_commun_method
                     ||', commun_address='||l_commun_address||', contact_id='||i_contact_id);
    end loop;
end;

procedure create_contact (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_parent_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_object_id            in            com_api_type_pkg.t_long_id
  , i_entity_type          in            com_api_type_pkg.t_dict_value
  , i_person_id            in            com_api_type_pkg.t_long_id
) is
    l_contact              app_api_type_pkg.t_contact;
    l_appl_data_id         com_api_type_pkg.t_long_id;
    l_id                   com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug (
        i_text        => 'app_api_contact_pkg.create_contact: i_apl_data_id[#1], i_parent_apl_data_id[#2]'
      , i_env_param1  => i_appl_data_id
      , i_env_param2  => i_parent_appl_data_id
    );

    get_appl_data (
        i_appl_data_id  => i_appl_data_id
      , o_contact       => l_contact
    );

    if i_person_id is null then
        --  processing contact person
        app_api_application_pkg.get_appl_data_id (
            i_element_name  => 'PERSON'
          , i_parent_id     => i_appl_data_id
          , o_appl_data_id  => l_appl_data_id
        );

        if l_appl_data_id is not null then
            app_api_person_pkg.process_person (
                i_appl_data_id  => l_appl_data_id
              , io_person_id    => l_contact.person_id
          );
        end if;
    else
        -- check  existing person
        begin
            select distinct a.id
            into l_contact.person_id
            from com_person a
            where a.id = i_person_id;
        exception
            when no_data_found then
                app_api_error_pkg.raise_error (
                    i_error         => 'ABSENT_MANDATORY_ELEMENT'
                  , i_env_param1    => 'PERSON'
                  , i_appl_data_id  => i_appl_data_id
                  , i_element_name  => 'CONTACT'
                  , i_appl_id       => app_api_application_pkg.get_appl_id()
               );
        end;
    end if;

    com_api_contact_pkg.add_contact(
        o_id              => l_contact.id
      , i_preferred_lang  => l_contact.preferred_lang
      , i_job_title       => l_contact.job_title
      , i_person_id       => l_contact.person_id
      , i_inst_id         => l_contact.inst_id
    );

    trc_log_pkg.debug (
        i_text        => 'l_contact.id[#1], entity_type[#2], i_object_id[#3]'
      , i_env_param1  => l_contact.id
      , i_env_param2  => i_entity_type
      , i_env_param3  => i_object_id
    );

    com_api_contact_pkg.add_contact_object (
        i_contact_id         => l_contact.id
      , i_entity_type        => i_entity_type
      , i_contact_type       => l_contact.contact_type
      , i_object_id          => i_object_id
      , o_contact_object_id  => l_id
    );

    -- add contact data
    create_contact_data (
        i_appl_data_id => i_appl_data_id
      , i_contact_id   => l_contact.id
    );
end;

procedure process_contact (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_parent_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_object_id            in            com_api_type_pkg.t_long_id
  , i_entity_type          in            com_api_type_pkg.t_dict_value
  , i_person_id            in            com_api_type_pkg.t_long_id        default null
) is
    l_contact_id           com_api_type_pkg.t_long_id;
    l_contact_type         com_api_type_pkg.t_dict_value;
    l_contact_object_id    com_api_type_pkg.t_long_id;
    l_command              com_api_type_pkg.t_dict_value;
    l_contact_data_tab     com_api_type_pkg.t_number_tab;
    l_commun_method        com_api_type_pkg.t_dict_value;
    l_commun_address       com_api_type_pkg.t_full_desc;
    l_customer_id          com_api_type_pkg.t_medium_id;
    l_count                com_api_type_pkg.t_medium_id;
    l_error_param          com_api_type_pkg.t_name;
    l_sysdate              date;
begin
    l_sysdate := com_api_sttl_day_pkg.get_sysdate;

    cst_api_application_pkg.process_contact_before (
        i_appl_data_id         => i_appl_data_id
      , i_parent_appl_data_id  => i_parent_appl_data_id
      , i_object_id            => i_object_id
      , i_entity_type          => i_entity_type
      , i_person_id            => i_person_id
      , i_appl_id              => app_api_application_pkg.get_appl_id()
    );

    l_customer_id  := app_api_customer_pkg.get_customer_id;

    app_api_application_pkg.get_element_value(
        i_element_name   => 'COMMAND'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_command
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'CONTACT_TYPE'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_contact_type
    );

    trc_log_pkg.debug(
        i_text        => 'app_api_contact_pkg.process_contact: contact_type [#1], object_id [#2], entity_type [#3]'
      , i_env_param1  => l_contact_type
      , i_env_param2  => i_object_id
      , i_env_param3  => i_entity_type
    );

    if l_contact_type is null then
          -- trying to find contact_id in communication data owned by current customer
        app_api_application_pkg.get_appl_data_id (
            i_element_name  => 'CONTACT_DATA'
          , i_parent_id     => i_appl_data_id
          , o_appl_data_id  => l_contact_data_tab
        );

        for i in 1..nvl(l_contact_data_tab.count, 0) loop
            app_api_application_pkg.get_element_value (
                i_element_name   => 'COMMUN_METHOD'
              , i_parent_id      => l_contact_data_tab(i)
              , o_element_value  => l_commun_method
            );

            app_api_application_pkg.get_element_value (
                i_element_name   => 'COMMUN_ADDRESS'
              , i_parent_id      => l_contact_data_tab(i)
              , o_element_value  => l_commun_address
            );

            trc_log_pkg.debug('l_commun_address='||l_commun_address||', l_commun_method='||l_commun_method
             ||', l_customer_id='||l_customer_id);

            select min(o.id)
                 , min(d.contact_id)
                 , count(1)
              into l_contact_object_id
                 , l_contact_id
                 , l_count
              from com_contact_data d
                 , com_contact_object o
             where d.commun_address = l_commun_address
               and d.commun_method  = l_commun_method
               and d.contact_id     = o.contact_id
               and (d.end_date is null or d.end_date > l_sysdate)
               and o.object_id      = l_customer_id
               and o.entity_type    = com_api_const_pkg.ENTITY_TYPE_CUSTOMER;

            if l_count != 0 then
                trc_log_pkg.debug('contact_object_id '||l_contact_object_id||' was found.');
                exit;
            end if;

        end loop;
    else
        select min(id)
             , min(contact_id)
             , count(id)
          into l_contact_object_id
             , l_contact_id
             , l_count
          from com_contact_object_vw
         where object_id    = i_object_id
           and contact_type = l_contact_type
           and entity_type  = i_entity_type;
    end if;

    trc_log_pkg.debug('l_count='||l_count||', l_contact_object_id='||l_contact_object_id||', l_contact_id='||l_contact_id);

    if i_entity_type = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER then
        select nvl(min(customer_number), to_char(i_object_id, 'TM9'))
          into l_error_param
          from prd_customer
          where id = i_object_id;
    else
        l_error_param := to_char(i_object_id, 'TM9');
    end if;

    if l_count != 0 then
        -- contact found
        if l_command = app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT then
            com_api_error_pkg.raise_error (
                i_error       => 'CONTACT_ALREADY_EXIST'
              , i_env_param1  => nvl(l_contact_type, case when nvl(l_contact_data_tab.count, 0) =1 then l_commun_address end)
              , i_env_param2  => i_entity_type
              , i_env_param3  => l_error_param
            );

        elsif l_command = app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
           or l_command = app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE then
            change_contact(
                i_appl_data_id          => i_appl_data_id
              , i_object_id             => i_object_id
              , i_entity_type           => i_entity_type
              , i_contact_id            => l_contact_id
              , i_contact_object_id     => l_contact_object_id
              , i_person_id             => i_person_id
            );
        elsif l_command = app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE then
            remove_contact(
                i_appl_data_id  => i_appl_data_id
              , i_contact_id    => l_contact_id
            );
        else
            null; -- unknown command
        end if;
    else
        if l_command = app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
        or l_command = app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
        then
            com_api_error_pkg.raise_error (
                i_error       => 'CONTACT_NOT_FOUND'
              , i_env_param1  => nvl(l_contact_type, case when nvl(l_contact_data_tab.count, 0) = 1 then l_commun_address end)
              , i_env_param2  => i_entity_type
              , i_env_param3  => l_error_param
            );

        elsif l_command = app_api_const_pkg.COMMAND_CREATE_OR_UPDATE then
            create_contact (
                i_appl_data_id         => i_appl_data_id
              , i_parent_appl_data_id  => i_parent_appl_data_id
              , i_object_id            => i_object_id
              , i_entity_type          => i_entity_type
              , i_person_id            => i_person_id
            );

        else
            -- unknown command
            create_contact (
                i_appl_data_id         => i_appl_data_id
              , i_parent_appl_data_id  => i_parent_appl_data_id
              , i_object_id            => i_object_id
              , i_entity_type          => i_entity_type
              , i_person_id            => i_person_id
            );

        end if;
    end if;

    cst_api_application_pkg.process_contact_after (
        i_appl_data_id         => i_appl_data_id
      , i_parent_appl_data_id  => i_parent_appl_data_id
      , i_object_id            => i_object_id
      , i_entity_type          => i_entity_type
      , i_person_id            => i_person_id
      , i_appl_id              => app_api_application_pkg.get_appl_id()
    );

exception
    when com_api_error_pkg.e_application_error then
        app_api_error_pkg.intercept_error (
            i_appl_data_id  => i_appl_data_id
          , i_element_name  => 'CONTACT'
        );
end;

end;
/
