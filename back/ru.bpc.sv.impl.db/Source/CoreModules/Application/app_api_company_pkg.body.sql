create or replace package body app_api_company_pkg as
/*********************************************************
*  Application - customer-company <br />
*  Created by Kryukov E.(krukov@bpc.ru)  at 17.09.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: app_api_company_pkg <br />
*  @headcom
**********************************************************/

procedure get_appl_data (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , o_company                 out nocopy com_api_type_pkg.t_company
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
      , o_element_value  => o_company.inst_id
    );

    app_api_application_pkg.get_element_value (
        i_element_name   => 'EMBOSSED_NAME'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_company.embossed_name
    );
    app_api_application_pkg.get_element_value (
        i_element_name   => 'INCORP_FORM'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_company.incorp_form
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

procedure change_company (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_id                   in            com_api_type_pkg.t_medium_id
) is
    l_company              com_api_type_pkg.t_company;
    l_id_tab               com_api_type_pkg.t_number_tab;
    l_lang_tab             com_api_type_pkg.t_dict_tab;
    l_card_id              com_api_type_pkg.t_long_id;
    l_seqnum               com_api_type_pkg.t_seqnum;
begin
    trc_log_pkg.debug (
        i_text        => 'app_api_company_pkg.change_company [#1]'
      , i_env_param1  => i_id
    );

    get_appl_data (
        i_appl_data_id  => i_appl_data_id
      , o_company       => l_company
    );

    -- process company document
    app_api_id_object_pkg.process_id_object (
        i_appl_data_id  => i_appl_data_id
      , i_entity_type   => com_api_const_pkg.ENTITY_TYPE_COMPANY
      , i_object_id     => i_id
      , o_id            => l_card_id
    );

    -- process multi-language company name
    app_api_application_pkg.get_appl_data_id (
        i_element_name    => 'COMPANY_NAME'
      , i_parent_id       => i_appl_data_id
      , o_appl_data_id    => l_id_tab
      , o_appl_data_lang  => l_lang_tab
    );

    for i in 1..l_lang_tab.count loop
        for j in 1..l_lang_tab.count loop
            if i < j and l_lang_tab(i) = l_lang_tab(j) then
                com_api_error_pkg.raise_error(
                    i_error         => 'DUPLICATE_COMPANY_NAME'
                  , i_env_param1    => i_id
                  , i_env_param2    => l_lang_tab(i)
                );
            end if;
        end loop;
    end loop;

    for i in 1..nvl(l_id_tab.count, 0) loop

        l_company.company_short_name(i).lang := l_lang_tab(i);
        l_company.company_full_name(i).lang  := l_lang_tab(i);

        app_api_application_pkg.get_element_value (
            i_element_name   => 'COMPANY_SHORT_NAME'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_company.company_short_name(i).value
        );

        app_api_application_pkg.get_element_value (
            i_element_name   => 'COMPANY_FULL_NAME'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_company.company_full_name(i).value
        );

    end loop;

    select seqnum
      into l_seqnum
      from com_company
     where id = i_id;

    com_api_company_pkg.modify_company (
        i_id                  => i_id
      , io_seqnum             => l_seqnum
      , i_embossed_name       => l_company.embossed_name
      , i_company_short_name  => l_company.company_short_name
      , i_company_full_name   => l_company.company_full_name
      , i_incorp_form         => l_company.incorp_form
    );
end change_company;

procedure create_company (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , o_company_id              out nocopy com_api_type_pkg.t_medium_id
) is
    l_company              com_api_type_pkg.t_company;
    l_id_tab               com_api_type_pkg.t_number_tab;
    l_lang_tab             com_api_type_pkg.t_dict_tab;
    l_card_id              com_api_type_pkg.t_long_id;
    l_seqnum               com_api_type_pkg.t_seqnum;
begin
    trc_log_pkg.debug (
        i_text  => 'app_api_company_pkg.create_company'
    );

    get_appl_data (
        i_appl_data_id  => i_appl_data_id
      , o_company       => l_company
    );

    -- process multi-language company name
    app_api_application_pkg.get_appl_data_id (
        i_element_name    => 'COMPANY_NAME'
      , i_parent_id       => i_appl_data_id
      , o_appl_data_id    => l_id_tab
      , o_appl_data_lang  => l_lang_tab
    );

    for i in 1..l_lang_tab.count loop
        for j in 1..l_lang_tab.count loop
            if i < j and l_lang_tab(i) = l_lang_tab(j) then
                com_api_error_pkg.raise_error (
                    i_error       => 'DUPLICATE_COMPANY_NAME'
                  , i_env_param1  => l_lang_tab(i)
                );
            end if;
        end loop;
    end loop;

    o_company_id := null;

    for i in 1..l_id_tab.count loop
        l_company.company_short_name(i).lang := l_lang_tab(i);
        l_company.company_full_name(i).lang  := l_lang_tab(i);

        app_api_application_pkg.get_element_value (
            i_element_name   => 'COMPANY_SHORT_NAME'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_company.company_short_name(i).value
        );

        app_api_application_pkg.get_element_value (
            i_element_name   => 'COMPANY_FULL_NAME'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_company.company_full_name(i).value
        );

    end loop;

    com_api_company_pkg.add_company (
        o_id                  => o_company_id
      , o_seqnum              => l_seqnum
      , i_company_short_name  => l_company.company_short_name
      , i_company_full_name   => l_company.company_full_name
      , i_embossed_name       => l_company.embossed_name
      , i_incorp_form         => l_company.incorp_form
      , i_inst_id             => l_company.inst_id
    );

    -- process company document
    app_api_id_object_pkg.process_id_object (
        i_appl_data_id  => i_appl_data_id
      , i_entity_type   => com_api_const_pkg.ENTITY_TYPE_COMPANY
      , i_object_id     => o_company_id
      , o_id            => l_card_id
    );
end create_company;

procedure process_company (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , io_company_id          in out nocopy com_api_type_pkg.t_long_id
) is
    l_command              com_api_type_pkg.t_dict_value;
    l_company              com_api_type_pkg.t_company;
begin
    cst_api_application_pkg.process_company_before (
        i_appl_data_id  => i_appl_data_id
      , i_inst_id       => i_inst_id
      , io_company_id   => io_company_id
    );

    app_api_application_pkg.get_element_value (
        i_element_name   => 'COMMAND'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_command
    );

    get_appl_data (
        i_appl_data_id  => i_appl_data_id
      , o_company       => l_company
    );

    if io_company_id is not null then
        if l_command = app_api_const_pkg.COMMAND_CREATE_OR_PROCEED then
            null;

        elsif l_command = app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT then
            com_api_error_pkg.raise_error (
                i_error       => 'COMPANY_ALREADY_EXIST'
              , i_env_param1  => l_company.id
              , i_env_param2  => i_inst_id
            );

        elsif l_command in (
            app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
          , app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
        ) then
            change_company (
                i_appl_data_id  => i_appl_data_id
              , i_id            => io_company_id
            );

        else
            null; -- unknown if present
        end if;
    else
        if l_command in (
            app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE
        ) then
            null;
        elsif l_command in (
            app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
          , app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
          , app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED
        ) then
            com_api_error_pkg.raise_error (
                i_error       => 'COMPANY_NOT_FOUND'
              , i_env_param1  => l_company.id
            );

        elsif l_command in (
            app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
          , app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
          , app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
        ) then
            create_company (
                i_appl_data_id  => i_appl_data_id
              , o_company_id    => io_company_id
            );
        else
            create_company (
                i_appl_data_id  => i_appl_data_id
              , o_company_id    => io_company_id
            );
        end if;
    end if;

    cst_api_application_pkg.process_company_after (
        i_appl_data_id  => i_appl_data_id
      , i_inst_id       => i_inst_id
      , io_company_id   => io_company_id
    );
exception
    when com_api_error_pkg.e_application_error then
        app_api_error_pkg.intercept_error (
            i_appl_data_id  => i_appl_data_id
          , i_element_name  => 'COMPANY'
        );
end process_company;

end app_api_company_pkg;
/
