create or replace package body pmo_api_application_pkg as
/************************************************************
 * API for payment applications <br />
 * Created by Fomichev A.(fomichev@bpcbt.com)  at 04.03.2013  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: pmo_api_application_pkg <br />
 * @headcom
 ************************************************************/

g_purpose_id        com_api_type_pkg.t_long_id;
g_root_id           com_api_type_pkg.t_long_id;

procedure process_service(
    i_appl_data_id  in     com_api_type_pkg.t_long_id
  , o_object_id     out    com_api_type_pkg.t_long_id
) is
    l_command       com_api_type_pkg.t_dict_value;
    l_object_id     com_api_type_pkg.t_long_id;
    l_id            com_api_type_pkg.t_long_id;
    l_seqnum        com_api_type_pkg.t_seqnum;
    l_count         com_api_type_pkg.t_count := 0;
    l_direction     com_api_type_pkg.t_boolean;
    l_label         com_api_type_pkg.t_multilang_desc_tab;
    l_description   com_api_type_pkg.t_multilang_desc_tab;
    l_short_name    com_api_type_pkg.t_name;                -- always english
    l_appl_data_id          com_api_type_pkg.t_long_id;
begin

    trc_log_pkg.debug(
        i_text  => 'process_service start'
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'COMMAND'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_command
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'OBJECT_ID'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_object_id
    );

    -- process multi-language label
    app_api_application_pkg.get_element_value(
        i_element_name  => 'LABEL'
      , i_parent_id     => i_appl_data_id
      , o_element_value => l_label
    );
    
    app_api_application_pkg.get_element_value(
        i_element_name   => 'SHORT_NAME'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_short_name
    );

    -- process multi-language description
    app_api_application_pkg.get_element_value(
        i_element_name  => 'DESCRIPTION'
      , i_parent_id     => i_appl_data_id
      , o_element_value => l_description
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'DIRECTION'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_direction
    );

    trc_log_pkg.debug(
        i_text          => ' l_command [#1], l_short_name [#2], l_direction [#3]'
      , i_env_param1    => l_command
      , i_env_param2    => l_short_name
      , i_env_param3    => l_direction
    );

    -- search for object
    if l_object_id is not null then
        select count(1) cnt
             , min(id) id
             , min(l_seqnum) keep (dense_rank first order by id) seqnum
          into l_count
             , l_id
             , l_seqnum
          from pmo_service_vw
         where id = l_object_id;

         trc_log_pkg.debug(' service search: l_count='||l_count||', id='||l_id);
    else
        l_count := 0;
    end if;
    trc_log_pkg.debug(' l_object_id='||l_object_id||', l_count='||l_count||', l_id='||l_id);

    if l_count = 0 then
        -- service not found
        if l_command = app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE then
            null;
        elsif l_command in (
            app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
          , app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
          , app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED
        ) then
            com_api_error_pkg.raise_error(
                i_error   => 'SERVICE_NOT_FOUND'
            );
        elsif l_command in (
            app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
          , app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
          , app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
        ) then
            pmo_ui_service_pkg.add(
                o_id          => l_id
              , o_seqnum      => l_seqnum
              , i_direction   => l_direction
              , i_label       => null
              , i_description => null
              , i_lang        => null
              , i_short_name  => l_short_name
            );

            for i in 1..nvl(l_label.count, 0) loop
            
                trc_log_pkg.debug(
                    i_text          => ' adding label for service id [#1] [#2] [#3]'
                  , i_env_param1    => l_id
                  , i_env_param2    => l_label(i).lang
                  , i_env_param3    => l_label(i).value   
                );
            
                com_api_i18n_pkg.add_text(
                    i_table_name   => 'pmo_service'
                  , i_column_name  => 'label'
                  , i_object_id    => l_id
                  , i_text         => l_label(i).value
                  , i_lang         => l_label(i).lang
                );
            end loop;
            
            for i in 1..nvl(l_description.count, 0) loop
            
                trc_log_pkg.debug(
                    i_text          => ' adding description for service id [#1] [#2] [#3]'
                  , i_env_param1    => l_id
                  , i_env_param2    => l_description(i).lang
                  , i_env_param3    => l_description(i).value   
                );
            
                com_api_i18n_pkg.add_text(
                    i_table_name   => 'pmo_service'
                  , i_column_name  => 'description'
                  , i_object_id    => l_id
                  , i_text         => l_description(i).value
                  , i_lang         => l_description(i).lang
                );
            end loop;
            
            app_api_application_pkg.get_appl_data_id(
                i_element_name      => 'OBJECT_ID'
              , i_parent_id         => i_appl_data_id
              , o_appl_data_id      => l_appl_data_id
            );

            if l_appl_data_id is null then
                app_api_application_pkg.add_element(
                    i_element_name      => 'OBJECT_ID'
                  , i_parent_id         => i_appl_data_id
                  , i_element_value     => l_id
                );

            else
                app_api_application_pkg.modify_element(
                    i_appl_data_id      => l_appl_data_id
                  , i_element_value     => l_id
                );
            end if;
            
        else
            null;

        end if;
    else
        if l_command = app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT then
            com_api_error_pkg.raise_error(
                i_error      => 'SERVICE_ALREADY_EXIST'
              , i_env_param1 => to_char(l_id, 'TM9')
            );
        elsif l_command = app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
           or l_command = app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED then
            null;
        elsif l_command in (
            app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
          , app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
        ) then
        
            select nvl(l_direction, direction)
              into l_direction
              from pmo_service
             where id = l_id; 
        
            pmo_ui_service_pkg.modify(
                i_id            => l_id
              , io_seqnum       => l_seqnum
              , i_direction     => l_direction
              , i_label         => null
              , i_description   => null
              , i_lang          => null
              , i_short_name    => l_short_name
            );
            
            for i in 1..nvl(l_label.count, 0) loop
                com_api_i18n_pkg.add_text(
                    i_table_name   => 'pmo_service'
                  , i_column_name  => 'label'
                  , i_object_id    => l_id
                  , i_text         => l_label(i).value
                  , i_lang         => l_label(i).lang
                );
            end loop;
            
            for i in 1..nvl(l_description.count, 0) loop
                com_api_i18n_pkg.add_text(
                    i_table_name   => 'pmo_service'
                  , i_column_name  => 'description'
                  , i_object_id    => l_id
                  , i_text         => l_description(i).value
                  , i_lang         => l_description(i).lang
                );
            end loop;
            
            app_api_application_pkg.get_appl_data_id(
                i_element_name      => 'OBJECT_ID'
              , i_parent_id         => i_appl_data_id
              , o_appl_data_id      => l_appl_data_id
            );

            if l_appl_data_id is null then
                app_api_application_pkg.add_element(
                    i_element_name      => 'OBJECT_ID'
                  , i_parent_id         => i_appl_data_id
                  , i_element_value     => l_id
                );

            else
                app_api_application_pkg.modify_element(
                    i_appl_data_id      => l_appl_data_id
                  , i_element_value     => l_id
                );
            end if;
            
        else
            null;
        end if;
    end if;

    o_object_id := l_id;

exception
    when com_api_error_pkg.e_application_error then
        app_api_error_pkg.intercept_error(
            i_appl_data_id  => i_appl_data_id
          , i_element_name  => 'PAYMENT_SERVICE'
        );    
end;

procedure process_provider_customer(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_provider_id       in      com_api_type_pkg.t_short_id
  , i_provider_number   in      com_api_type_pkg.t_name
) is
    l_customer_id           com_api_type_pkg.t_medium_id;
    l_ext_type_data_id      com_api_type_pkg.t_long_id;
    l_ext_object_data_id    com_api_type_pkg.t_long_id;
    l_cust_type_data_id     com_api_type_pkg.t_long_id;
    l_agent_data_id         com_api_type_pkg.t_long_id;
    l_agent_id              com_api_type_pkg.t_agent_id;
    l_customer_appl_data    com_api_type_pkg.t_long_id;
begin
    l_customer_appl_data := app_api_application_pkg.get_customer_appl_data_id;
    if l_customer_appl_data is null then
        return;
    end if;
    
    trc_log_pkg.debug(
        i_text          => 'process_provider_customer start [#1]'
      , i_env_param1    => l_customer_appl_data
    );
    
    trc_log_pkg.debug(
        i_text          => 'l_customer_appl_data [#1]'
      , i_env_param1    => l_customer_appl_data  
    );

    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'CUSTOMER_EXT_TYPE'
      , i_parent_id         => l_customer_appl_data
      , o_appl_data_id      => l_ext_type_data_id
    );
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'CUSTOMER_EXT_ID'
      , i_parent_id         => l_customer_appl_data
      , o_appl_data_id      => l_ext_object_data_id
    );
    if l_ext_type_data_id is null then
        app_api_application_pkg.add_element(
            i_element_name      => 'CUSTOMER_EXT_TYPE'
          , i_parent_id         => l_customer_appl_data
          , i_element_value     => pmo_api_const_pkg.ENTITY_TYPE_SERVICE_PROVIDER
        );
    else
        app_api_application_pkg.modify_element(
            i_appl_data_id      => l_ext_type_data_id
          , i_element_value     => pmo_api_const_pkg.ENTITY_TYPE_SERVICE_PROVIDER
        );
    end if;    
    if l_ext_object_data_id is null then
        app_api_application_pkg.add_element(
            i_element_name      => 'CUSTOMER_EXT_ID'
          , i_parent_id         => l_customer_appl_data
          , i_element_value     => i_provider_id
        );
    else
        app_api_application_pkg.modify_element(
            i_appl_data_id      => l_ext_object_data_id
          , i_element_value     => i_provider_id
        );
    end if; 
    
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'CUSTOMER_TYPE'
      , i_parent_id         => g_root_id
      , o_appl_data_id      => l_cust_type_data_id
    );
    if l_cust_type_data_id is null then
        app_api_application_pkg.add_element(
            i_element_name      => 'CUSTOMER_TYPE'
          , i_parent_id         => g_root_id
          , i_element_value     => com_api_const_pkg.ENTITY_TYPE_COMPANY
        );
    else
        app_api_application_pkg.modify_element(
            i_appl_data_id      => l_cust_type_data_id
          , i_element_value     => com_api_const_pkg.ENTITY_TYPE_COMPANY
        );
    end if;
    
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'AGENT_ID'
      , i_parent_id         => g_root_id
      , o_appl_data_id      => l_agent_data_id
    );
    
    if l_agent_data_id is null then
        l_agent_id := ost_api_institution_pkg.get_default_agent(i_inst_id);
        app_api_application_pkg.add_element(
            i_element_name      => 'AGENT_ID'
          , i_parent_id         => g_root_id
          , i_element_value     => l_agent_id
        );
        rul_api_param_pkg.set_param(
            i_name      => 'AGENT_ID'
          , i_value     => l_agent_id
          , io_params   => app_api_application_pkg.g_params
        );
        
    else
        app_api_application_pkg.get_element_value(
            i_element_name  => 'AGENT_ID'
          , i_parent_id     => g_root_id
          , o_element_value => l_agent_id
        );

        rul_api_param_pkg.set_param(
            i_value         => l_agent_id
          , i_name          => 'AGENT_ID'
          , io_params       => app_api_application_pkg.g_params
        );
            
    end if;

    app_api_customer_pkg.process_customer(
        i_appl_data_id  => l_customer_appl_data
      , i_inst_id       => i_inst_id
      , o_customer_id   => l_customer_id
    );
    
exception
    when com_api_error_pkg.e_application_error then
        app_api_error_pkg.intercept_error(
            i_appl_data_id  => l_customer_appl_data
          , i_element_name  => 'CUSTOMER'
        );  
    
end process_provider_customer;

procedure process_provider(
    i_appl_data_id  in      com_api_type_pkg.t_long_id
  , i_inst_id       in      com_api_type_pkg.t_inst_id  
  , o_object_id     out     com_api_type_pkg.t_long_id
) is
    l_command               com_api_type_pkg.t_dict_value;
    l_object_id             com_api_type_pkg.t_long_id;
    l_id                    com_api_type_pkg.t_long_id;
    l_seqnum                com_api_type_pkg.t_seqnum;
    l_count                 com_api_type_pkg.t_count := 0;
    l_region_code           com_api_type_pkg.t_region_code;
    l_label                 com_api_type_pkg.t_multilang_desc_tab;
    l_description           com_api_type_pkg.t_multilang_desc_tab;
    l_short_name            com_api_type_pkg.t_name;                -- always english
    l_appl_data_id          com_api_type_pkg.t_long_id;
    l_provider_number       com_api_type_pkg.t_name;
begin

    trc_log_pkg.debug(
        i_text  => 'process_provider start'
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'COMMAND'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_command
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'OBJECT_ID'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_object_id
    );

    -- process multi-language label
    app_api_application_pkg.get_element_value(
        i_element_name  => 'LABEL'
      , i_parent_id     => i_appl_data_id
      , o_element_value => l_label
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'SHORT_NAME'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_short_name
    );

    -- process multi-language description
    app_api_application_pkg.get_element_value(
        i_element_name  => 'DESCRIPTION'
      , i_parent_id     => i_appl_data_id
      , o_element_value => l_description
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'REGION_CODE'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_region_code
    );
    
    app_api_application_pkg.get_element_value(
        i_element_name   => 'PROVIDER_NUMBER'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_provider_number
    );

    trc_log_pkg.debug(
        i_text          => ' l_command [#1], l_short_name [#2], l_region_code [#3], l_provider_number [#4]'
      , i_env_param1    => l_command
      , i_env_param2    => l_short_name
      , i_env_param3    => l_region_code
      , i_env_param4    => l_provider_number
    );

    -- search for object
    if l_object_id is not null then
        select count(1) cnt
             , min(id) id
             , min(l_seqnum) keep (dense_rank first order by id) seqnum
          into l_count
             , l_id
             , l_seqnum
          from pmo_provider_vw
         where id = l_object_id;
         trc_log_pkg.debug(' provider search: l_count='||l_count||', id='||l_id);
         
    elsif l_provider_number is not null then
        select count(1) cnt
             , min(id) id
             , min(l_seqnum) keep (dense_rank first order by id) seqnum
          into l_count
             , l_id
             , l_seqnum
          from pmo_provider_vw
         where provider_number = l_provider_number;
         trc_log_pkg.debug(' provider search: l_count='||l_count||', id='||l_id);    
    
    else
        l_count := 0;
    end if;
    
    trc_log_pkg.debug(' l_object_id='||l_object_id||', l_count='||l_count||', l_id='||l_id);

    if l_count = 0 then
        -- service not found
        if l_command = app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE then
            null;
        elsif l_command in (
            app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
          , app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
          , app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED
        ) then
            com_api_error_pkg.raise_error(
                i_error   => 'PROVIDER_NOT_FOUND'
            );
        elsif l_command in (
            app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
          , app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
          , app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
        ) then
            pmo_ui_provider_pkg.add(
                o_id                => l_id
              , o_seqnum            => l_seqnum
              , i_region_code       => l_region_code
              , i_label             => null
              , i_description       => null
              , i_lang              => null
              , i_short_name        => l_short_name
              , i_provider_number   => l_provider_number
            );

            for i in 1..nvl(l_label.count, 0) loop
            
                trc_log_pkg.debug(
                    i_text          => ' adding label for provider id [#1] [#2] [#3]'
                  , i_env_param1    => l_id
                  , i_env_param2    => l_label(i).lang
                  , i_env_param3    => l_label(i).value   
                );
            
                com_api_i18n_pkg.add_text(
                    i_table_name   => 'pmo_provider'
                  , i_column_name  => 'label'
                  , i_object_id    => l_id
                  , i_text         => l_label(i).value
                  , i_lang         => l_label(i).lang
                );
            end loop;
            
            for i in 1..nvl(l_description.count, 0) loop
            
                trc_log_pkg.debug(
                    i_text          => ' adding description for provider id [#1] [#2] [#3]'
                  , i_env_param1    => l_id
                  , i_env_param2    => l_description(i).lang
                  , i_env_param3    => l_description(i).value   
                );
            
                com_api_i18n_pkg.add_text(
                    i_table_name   => 'pmo_provider'
                  , i_column_name  => 'description'
                  , i_object_id    => l_id
                  , i_text         => l_description(i).value
                  , i_lang         => l_description(i).lang
                );
            end loop;
            
            app_api_application_pkg.get_appl_data_id(
                i_element_name      => 'OBJECT_ID'
              , i_parent_id         => i_appl_data_id
              , o_appl_data_id      => l_appl_data_id
            );

            if l_appl_data_id is null then
                app_api_application_pkg.add_element(
                    i_element_name      => 'OBJECT_ID'
                  , i_parent_id         => i_appl_data_id
                  , i_element_value     => l_id
                );

            else
                app_api_application_pkg.modify_element(
                    i_appl_data_id      => l_appl_data_id
                  , i_element_value     => l_id
                );
            end if;
            
        else
           null;

        end if;
    else
        if l_command = app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT then
            com_api_error_pkg.raise_error(
                i_error      => 'PROVIDER_ALREADY_EXIST'
              , i_env_param1 => to_char(l_id, 'TM9')
            );
        elsif l_command = app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
           or l_command = app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED then
            null;
        elsif l_command in (
            app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
          , app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
        ) then
        
            select nvl(l_region_code, region_code)
              into l_region_code
              from pmo_provider
             where id = l_id; 
        
            pmo_ui_provider_pkg.modify(
                i_id                => l_id
              , io_seqnum           => l_seqnum
              , i_region_code       => l_region_code
              , i_label             => null
              , i_description       => null
              , i_lang              => null
              , i_short_name        => l_short_name
              , i_provider_number   => l_provider_number
            );
            
            for i in 1..nvl(l_label.count, 0) loop
                com_api_i18n_pkg.add_text(
                    i_table_name   => 'pmo_provider'
                  , i_column_name  => 'label'
                  , i_object_id    => l_id
                  , i_text         => l_label(i).value
                  , i_lang         => l_label(i).lang
                );
            end loop;
            
            for i in 1..nvl(l_description.count, 0) loop
                com_api_i18n_pkg.add_text(
                    i_table_name   => 'pmo_provider'
                  , i_column_name  => 'description'
                  , i_object_id    => l_id
                  , i_text         => l_description(i).value
                  , i_lang         => l_description(i).lang
                );
            end loop;
            
            app_api_application_pkg.get_appl_data_id(
                i_element_name      => 'OBJECT_ID'
              , i_parent_id         => i_appl_data_id
              , o_appl_data_id      => l_appl_data_id
            );

            if l_appl_data_id is null then
                app_api_application_pkg.add_element(
                    i_element_name      => 'OBJECT_ID'
                  , i_parent_id         => i_appl_data_id
                  , i_element_value     => l_id
                );

            else
                app_api_application_pkg.modify_element(
                    i_appl_data_id      => l_appl_data_id
                  , i_element_value     => l_id
                );
            end if;
        else
            null;
        end if;
    end if;
    
    process_provider_customer(
        i_inst_id           => i_inst_id
      , i_provider_id       => l_id
      , i_provider_number   => l_provider_number
    );

    o_object_id := l_id;
   
exception
    when com_api_error_pkg.e_application_error then
        app_api_error_pkg.intercept_error(
            i_appl_data_id  => i_appl_data_id
          , i_element_name  => 'PAYMENT_PROVIDER'
        );    
end;

procedure process_parameter(
    i_appl_data_id in     com_api_type_pkg.t_long_id
  , i_object_id    in     com_api_type_pkg.t_long_id
) is
    l_command               com_api_type_pkg.t_dict_value;
    l_object_id             com_api_type_pkg.t_long_id;
    l_id                    com_api_type_pkg.t_long_id;
    l_seqnum                com_api_type_pkg.t_seqnum;
    l_param_name            com_api_type_pkg.t_name;
    l_data_type             com_api_type_pkg.t_dict_value;
    l_same_dtype            com_api_type_pkg.t_dict_value;
    l_lov_id                com_api_type_pkg.t_tiny_id;
    l_pattern               com_api_type_pkg.t_name;
    l_label                 com_api_type_pkg.t_multilang_desc_tab;
    l_description           com_api_type_pkg.t_multilang_desc_tab;
    l_purpose_parameter_id  com_api_type_pkg.t_short_id;
begin

    trc_log_pkg.debug(
        i_text  => 'process_parameter start'
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'COMMAND'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_command
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'OBJECT_ID'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_object_id
    );
    
    app_api_application_pkg.get_element_value(
        i_element_name   => 'PAYMENT_PARAMETER_NAME'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_param_name
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'DATA_TYPE'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_data_type
    );
    
    app_api_application_pkg.get_element_value(
        i_element_name   => 'LOV_ID'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_lov_id
    );
    
    app_api_application_pkg.get_element_value(
        i_element_name   => 'PATTERN'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_pattern
    );
    
    -- process multi-language label
    app_api_application_pkg.get_element_value(
        i_element_name  => 'LABEL'
      , i_parent_id     => i_appl_data_id
      , o_element_value => l_label
    );
    
     -- process multi-language description
    app_api_application_pkg.get_element_value(
        i_element_name  => 'DESCRIPTION'
      , i_parent_id     => i_appl_data_id
      , o_element_value => l_description
    );
    
    trc_log_pkg.debug(
        i_text          => 'process_parameter l_command [#1], l_object_id [#2], l_param_name [#3], l_data_type [#4], l_lov_id [#5], l_pattern [#6]'
      , i_env_param1    => l_command
      , i_env_param2    => l_object_id
      , i_env_param3    => l_param_name
      , i_env_param4    => l_data_type
      , i_env_param5    => l_lov_id
      , i_env_param6    => l_pattern
    );
    
    -- search for object
    if l_object_id is not null then
        begin
            select seqnum
                 , id
              into l_seqnum
                 , l_id     
              from pmo_parameter_vw
             where id = l_object_id;
            trc_log_pkg.debug('paramter search: id='||l_id||', seqnum='||l_seqnum);
             
        exception
            when no_data_found then
                trc_log_pkg.debug(' parameter not found by object_id: object_id='||l_object_id);
        end; 
    else
        -- search for same object
        begin
            select id
                 , data_type
              into l_id
                 , l_same_dtype
              from pmo_parameter_vw
             where param_name = l_param_name;
        exception
            when too_many_rows then
                trc_log_pkg.debug(' There are more than one parameter '||l_param_name||' in pmo_parameter');
                select id
                     , data_type
                  into l_id
                     , l_same_dtype     
                 from (
                    select id
                         , data_type
                         , rownum rn
                      from pmo_parameter_vw
                     where param_name = l_param_name     
                 )     
                 where rn = 1;
        end; 
        
        if l_same_dtype is not null and l_same_dtype != l_data_type then
            com_api_error_pkg.raise_error(
                i_error         =>  'PARAMETER_ALREADY_EXIST'
              , i_env_param1    =>  to_char(l_object_id, 'TM9')
            );
        end if;
            
    end if;
    
    trc_log_pkg.debug('l_command='||l_command||', l_object_id='||l_object_id||', l_id='||l_id||', l_param_name='||l_param_name);
    
    if l_id is null then
        --parameter not found
        if l_command = app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE then
            null;
        elsif l_command in (
            app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
          , app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
          , app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED
        ) then
            com_api_error_pkg.raise_error(
                i_error         =>  'PARAMETER_NOT_FOUND'
              , i_env_param1    =>  to_char(l_object_id, 'TM9')
            );
        elsif l_command in (
            app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
          , app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
          , app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
        ) then
            pmo_ui_parameter_pkg.add(
                o_id                =>  l_id
              , o_seqnum            =>  l_seqnum
              , i_param_name        =>  l_param_name
              , i_data_type         =>  l_data_type
              , i_lov_id            =>  l_lov_id
              , i_pattern           =>  l_pattern
              , i_tag_id            =>  null
              , i_param_function    =>  null
              , i_label             =>  null
              , i_description       =>  null
              , i_lang              =>  null
            );
            
           for i in 1..nvl(l_label.count, 0) loop
            
                trc_log_pkg.debug(
                    i_text          => ' adding label for parameter id [#1] [#2] [#3]'
                  , i_env_param1    => l_id
                  , i_env_param2    => l_label(i).lang
                  , i_env_param3    => l_label(i).value   
                );
            
                com_api_i18n_pkg.add_text(
                    i_table_name   => 'pmo_parameter'
                  , i_column_name  => 'label'
                  , i_object_id    => l_id
                  , i_text         => l_label(i).value
                  , i_lang         => l_label(i).lang
                );
            end loop;
            
            for i in 1..nvl(l_description.count, 0) loop
            
                trc_log_pkg.debug(
                    i_text          => ' adding description for parameter id [#1] [#2] [#3]'
                  , i_env_param1    => l_id
                  , i_env_param2    => l_description(i).lang
                  , i_env_param3    => l_description(i).value   
                );
            
                com_api_i18n_pkg.add_text(
                    i_table_name   => 'pmo_parameter'
                  , i_column_name  => 'description'
                  , i_object_id    => l_id
                  , i_text         => l_description(i).value
                  , i_lang         => l_description(i).lang
                );
            end loop;

            pmo_ui_purpose_parameter_pkg.add(
                o_id                    => l_purpose_parameter_id
              , o_seqnum                => l_seqnum
              , i_param_id              => l_id
              , i_purpose_id            => g_purpose_id
              , i_order_stage           => pmo_api_const_pkg.PURPOSE_STAGE_1
              , i_display_order         => 10
              , i_is_mandatory          => com_api_const_pkg.FALSE
              , i_is_template_fixed     => com_api_const_pkg.FALSE
              , i_is_editable           => com_api_const_pkg.TRUE
              , i_data_type             => null
              , i_default_value_char    => null
              , i_default_value_num     => null
              , i_default_value_date    => null
            );
            
        end if;    
    else
        --parameter found
        if l_command in (
            app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
          , app_api_const_pkg.COMMAND_CREATE_OR_UPDATE  
        ) then
            pmo_ui_parameter_pkg.modify(
                i_id                =>  l_id
              , io_seqnum           =>  l_seqnum
              , i_param_name        =>  l_param_name
              , i_data_type         =>  l_data_type
              , i_lov_id            =>  l_lov_id
              , i_pattern           =>  l_pattern
              , i_tag_id            =>  null
              , i_param_function    =>  null
              , i_label             =>  null
              , i_description       =>  null
              , i_lang              =>  null
            );
            
            for i in 1..nvl(l_label.count, 0) loop
            
                trc_log_pkg.debug(
                    i_text          => ' adding label for parameter id [#1] [#2] [#3]'
                  , i_env_param1    => l_id
                  , i_env_param2    => l_label(i).lang
                  , i_env_param3    => l_label(i).value   
                );
            
                com_api_i18n_pkg.add_text(
                    i_table_name   => 'pmo_parameter'
                  , i_column_name  => 'label'
                  , i_object_id    => l_id
                  , i_text         => l_label(i).value
                  , i_lang         => l_label(i).lang
                );
            end loop;
            
            for i in 1..nvl(l_description.count, 0) loop
            
                trc_log_pkg.debug(
                    i_text          => ' adding description for parameter id [#1] [#2] [#3]'
                  , i_env_param1    => l_id
                  , i_env_param2    => l_description(i).lang
                  , i_env_param3    => l_description(i).value   
                );
            
                com_api_i18n_pkg.add_text(
                    i_table_name   => 'pmo_parameter'
                  , i_column_name  => 'description'
                  , i_object_id    => l_id
                  , i_text         => l_description(i).value
                  , i_lang         => l_description(i).lang
                );
            end loop;
            
        elsif l_command in (
            app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
          , app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED
        ) then
            pmo_ui_purpose_parameter_pkg.add(
                o_id                    => l_purpose_parameter_id
              , o_seqnum                => l_seqnum
              , i_param_id              => l_id
              , i_purpose_id            => g_purpose_id
              , i_order_stage           => pmo_api_const_pkg.PURPOSE_STAGE_1
              , i_display_order         => 10
              , i_is_mandatory          => com_api_const_pkg.FALSE
              , i_is_template_fixed     => com_api_const_pkg.FALSE
              , i_is_editable           => com_api_const_pkg.TRUE
              , i_data_type             => null
              , i_default_value_char    => null
              , i_default_value_num     => null
              , i_default_value_date    => null

            );            
            
        elsif l_command = app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT then
            com_api_error_pkg.raise_error(
                i_error         =>  'PARAMETER_ALREADY_EXIST'
              , i_env_param1    =>  to_char(l_object_id, 'TM9')
            );
        end if;    
    end if;
    
exception
    when com_api_error_pkg.e_application_error then
        app_api_error_pkg.intercept_error(
            i_appl_data_id  => i_appl_data_id
          , i_element_name  => 'PAYMENT_PARAMETER'
        );
end;

procedure process_host(
    i_appl_data_id  in      com_api_type_pkg.t_long_id
  , i_object_id     in      com_api_type_pkg.t_long_id
) is
    l_command               com_api_type_pkg.t_dict_value;
    l_host_id               com_api_type_pkg.t_long_id  default null;
    l_provider_id           com_api_type_pkg.t_long_id  default null;
    l_count                 com_api_type_pkg.t_count := 0;
    l_exec_type             com_api_type_pkg.t_dict_value;
    l_priority              com_api_type_pkg.t_tiny_id;
    l_object_host_id        com_api_type_pkg.t_long_id;
    l_object_prov_id        com_api_type_pkg.t_long_id;
    l_prov_appl_id          com_api_type_pkg.t_long_id;
    l_status                com_api_type_pkg.t_dict_value;
begin

    trc_log_pkg.debug(
        i_text  => 'process_host start'
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'COMMAND'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_command
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'HOST_ID'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_object_host_id
    );
    
    app_api_application_pkg.get_element_value(
        i_element_name   => 'EXECUTION_TYPE'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_exec_type
    );
    
    app_api_application_pkg.get_element_value(
        i_element_name   => 'PRIORITY'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_priority
    );
    
    app_api_application_pkg.get_element_value(
        i_element_name   => 'PROVIDER_HOST_STATUS'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_status
    );
    
    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'PAYMENT_PROVIDER'
      , i_parent_id      => i_appl_data_id
      , o_appl_data_id   => l_prov_appl_id
    );
    
    app_api_application_pkg.get_element_value(
        i_element_name  => 'OBJECT_ID'
      , i_parent_id     => l_prov_appl_id
      , o_element_value => l_object_prov_id
    );
    
    trc_log_pkg.debug(
        i_text          => ' process_host l_command [#1], l_object_host_id [#2], l_exec_type [#3], l_priority [#4], l_status [#5], l_object_prov_id [#6]'
      , i_env_param1    => l_command
      , i_env_param2    => l_object_host_id
      , i_env_param3    => l_exec_type
      , i_env_param4    => l_priority
      , i_env_param5    => l_status
      , i_env_param6    => l_object_prov_id
    );
    
    select count(1)
      into l_count
      from net_member m
         , prd_customer c
     where m.id = l_object_host_id
       and c.ext_object_id = m.inst_id
       and c.ext_entity_type = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION;

    if l_count = 0 then
        com_api_error_pkg.raise_error(
                i_error         =>  'HOST_MEMBER_NOT_FOUND'
              , i_env_param1    =>  to_char(l_object_host_id, 'TM9')
            );
    end if;                
    
    select count(1)
      into l_count
      from pmo_provider
     where id = l_object_prov_id;

    if l_count = 0 then
        com_api_error_pkg.raise_error(
                i_error         =>  'PROVIDER_NOT_FOUND'
              , i_env_param1    =>  to_char(l_object_prov_id, 'TM9')
            );
    end if;
 
    begin
        select host_member_id
             , provider_id             
          into l_host_id
             , l_provider_id
          from pmo_provider_host_vw
         where host_member_id = l_object_host_id
           and provider_id = l_object_prov_id; 
        trc_log_pkg.debug(' provider and host search: host_member_id='||l_host_id||', provider_id='||l_provider_id);
             
        exception
            when no_data_found then
                trc_log_pkg.debug(' provider and host and not found: host id='||l_object_host_id||', provider_id='||l_object_prov_id);
    end;
         
    if l_host_id is null then
        if l_command in (
            app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
          , app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
          , app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED
        ) then
            com_api_error_pkg.raise_error(
                i_error         =>  'PROVIDER_AND_HOST_RELATION_NOT_FOUND'
              , i_env_param1    =>  to_char(l_object_host_id, 'TM9')
              , i_env_param2    =>  to_char(l_object_prov_id, 'TM9')
            );    
        elsif l_command in (
            app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
          , app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
          , app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
        ) then
            pmo_ui_provider_host_pkg.add_host (
                  i_host_member_id       =>    l_object_host_id
                , i_provider_id          =>    l_object_prov_id   
                , i_execution_type       =>    l_exec_type
                , i_priority             =>    l_priority      
                , i_mod_id               =>    null        
                , i_inactive_till        =>    null 
                , i_status               =>    l_status
            );   
            l_host_id       := l_object_host_id;
            l_provider_id   := l_object_prov_id; 
        end if;    
    else
        if l_command = app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT then
            com_api_error_pkg.raise_error(
                i_error         =>  'PROVIDER_AND_HOST_RELATION_ALREADY_EXIST'
              , i_env_param1    =>  to_char(l_host_id, 'TM9')
              , i_env_param2    =>  to_char(l_provider_id, 'TM9')
            );
        elsif l_command in (
              app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
            , app_api_const_pkg.COMMAND_CREATE_OR_UPDATE              
        ) then
            pmo_ui_provider_host_pkg.modify_host(
                i_host_member_id       =>   l_host_id
              , i_provider_id          =>   l_provider_id
              , i_execution_type       =>   l_exec_type
              , i_priority             =>   l_priority
              , i_mod_id               =>   null
              , i_inactive_till        =>   null
              , i_status               =>   l_status 
            );
        end if;
    end if;        
    
    cst_api_application_pkg.process_provider_host_after(
        i_appl_data_id      => i_appl_data_id
      , i_host_member_id    => l_host_id         
      , i_provider_id       => l_provider_id
      , i_object_id         => i_object_id    
    );
    
exception
    when com_api_error_pkg.e_application_error then
        app_api_error_pkg.intercept_error(
            i_appl_data_id  => i_appl_data_id
          , i_element_name  => 'PAYMENT_HOST'
        );
end;

procedure process_purpose(
    i_appl_data_id  in      com_api_type_pkg.t_long_id
  , i_inst_id       in      com_api_type_pkg.t_inst_id  
  , i_object_id     in      com_api_type_pkg.t_long_id
) is
    l_command               com_api_type_pkg.t_dict_value;
    l_object_id             com_api_type_pkg.t_long_id;
    l_host_algorithm        com_api_type_pkg.t_dict_value;
    l_oper_type             com_api_type_pkg.t_dict_value;
    l_terminal_id           com_api_type_pkg.t_short_id;
    l_mcc                   com_api_type_pkg.t_mcc;
    l_appl_data_id          com_api_type_pkg.t_long_id;
    l_service_id            com_api_type_pkg.t_short_id;
    l_provider_id           com_api_type_pkg.t_short_id;
    l_service_data_id       com_api_type_pkg.t_long_id;
    l_provider_data_id      com_api_type_pkg.t_long_id;
    l_purpose_number        com_api_type_pkg.t_name;
    l_label                 com_api_type_pkg.t_multilang_desc_tab;
    
    procedure process_child_object_id(
        i_child_data_id     in      com_api_type_pkg.t_long_id
      , io_element_value    in out  com_api_type_pkg.t_long_id
    ) is
        l_object_data_id        com_api_type_pkg.t_long_id;
    begin
        if i_child_data_id is not null then
            app_api_application_pkg.get_appl_data_id(
                i_element_name      => 'OBJECT_ID'
              , i_parent_id         => i_child_data_id
              , o_appl_data_id      => l_object_data_id
            );
                
            if l_object_data_id is null and io_element_value is not null then
                app_api_application_pkg.add_element(
                    i_element_name      => 'OBJECT_ID'
                  , i_parent_id         => i_child_data_id
                  , i_element_value     => io_element_value
                );
            elsif l_object_data_id is not null and io_element_value is null then 
                app_api_application_pkg.get_element_value(
                    i_element_name   => 'OBJECT_ID'
                  , i_parent_id      => i_child_data_id
                  , o_element_value  => io_element_value
                );    
            end if;    
        end if;   
    end;
    
begin

    trc_log_pkg.debug(
        i_text  => 'process_purpose start'
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'COMMAND'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_command
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'OBJECT_ID'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_object_id
    );
    
    app_api_application_pkg.get_element_value(
        i_element_name   => 'OPERATION_TYPE'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_oper_type
    );
    
    app_api_application_pkg.get_element_value(
        i_element_name   => 'TERMINAL_ID'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_terminal_id
    );
    
    app_api_application_pkg.get_element_value(
        i_element_name   => 'MCC'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_mcc
    );
    
    app_api_application_pkg.get_element_value(
        i_element_name   => 'PAYMENT_PURPOSE_NUMBER'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_purpose_number
    );
    
     -- process multi-language label
    app_api_application_pkg.get_element_value(
        i_element_name  => 'LABEL'
      , i_parent_id     => i_appl_data_id
      , o_element_value => l_label
    );
    
    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'PAYMENT_SERVICE'
      , i_parent_id      => i_appl_data_id
      , o_appl_data_id   => l_service_data_id
    );
    
    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'SERVICE_PROVIDER'
      , i_parent_id      => i_appl_data_id
      , o_appl_data_id   => l_provider_data_id
    );
    
    l_host_algorithm    :=  pmo_api_const_pkg.PAYMENT_HOST_ALG_PRIORITY;
    
    trc_log_pkg.debug(
        i_text          => 'process_purpose l_command [#1], l_object_id [#2], l_oper_type [#3], l_terminal_id [#4], l_mcc [#5], l_purpose_number [#6]'
      , i_env_param1    => l_command
      , i_env_param2    => l_object_id
      , i_env_param3    => l_oper_type
      , i_env_param4    => l_terminal_id
      , i_env_param5    => l_mcc
      , i_env_param6    => l_purpose_number
    );
    
    if l_object_id is not null then
        begin
            select id
              into l_object_id
              from pmo_purpose_vw
             where id = l_object_id;
            
            trc_log_pkg.debug('purpose found by object_id: object_id='||l_object_id); 
        exception
            when no_data_found then
                trc_log_pkg.debug('purpose not found by object_id: object_id='||l_object_id);
        end;   
        
    elsif l_purpose_number is not null then
        begin
            select id
              into l_object_id
              from pmo_purpose_vw
             where purpose_number = l_purpose_number;
             
            trc_log_pkg.debug(
                i_text          => 'purpose [#1] found by purpose number [#2]'
              , i_env_param1    => l_object_id
              , i_env_param2    => l_purpose_number  
            ); 
            
        exception
            when no_data_found then
                trc_log_pkg.debug(
                    i_text          => 'purpose not found by purpose number [#1]'
                  , i_env_param1    => l_purpose_number  
                );         
            
        end;    
         
    end if;

    if l_object_id is null then
        if l_command in (
              app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
            , app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
            , app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED
        ) then
            com_api_error_pkg.raise_error(
                i_error         =>  'PAYMENT_PURPOSE_NOT_EXISTS'
              , i_env_param1    =>  to_char(l_object_id, 'TM9')
            );
        elsif l_command in (
              app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
            , app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
            , app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT 
        ) then
        
            process_service(
                i_appl_data_id => l_service_data_id
              , o_object_id    => l_service_id
            );
                       
            process_provider(
                i_appl_data_id => l_provider_data_id
              , i_inst_id      => i_inst_id   
              , o_object_id    => l_provider_id
            );
        
            pmo_ui_purpose_pkg.add(
                o_id             =>    l_object_id            
              , i_provider_id    =>    l_provider_id   
              , i_service_id     =>    l_service_id    
              , i_host_algorithm =>    l_host_algorithm
              , i_oper_type      =>    l_oper_type     
              , i_terminal_id    =>    l_terminal_id   
              , i_mcc            =>    l_mcc
              , i_purpose_number =>    l_purpose_number
            );
            
            for i in 1..nvl(l_label.count, 0) loop
                com_api_i18n_pkg.add_text(
                    i_table_name   => 'pmo_purpose'
                  , i_column_name  => 'label'
                  , i_object_id    => l_object_id
                  , i_text         => l_label(i).value
                  , i_lang         => l_label(i).lang
                );
                
            end loop;
            
            app_api_application_pkg.get_appl_data_id(
                i_element_name      => 'OBJECT_ID'
              , i_parent_id         => i_appl_data_id
              , o_appl_data_id      => l_appl_data_id
            );

            if l_appl_data_id is null then
                app_api_application_pkg.add_element(
                    i_element_name      => 'OBJECT_ID'
                  , i_parent_id         => i_appl_data_id
                  , i_element_value     => l_object_id
                );

            else
                app_api_application_pkg.modify_element(
                    i_appl_data_id      => l_appl_data_id
                  , i_element_value     => l_object_id
                );
            end if;
            
        end if;
    else
        if l_command in (
              app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
            , app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
        ) then
        
            select provider_id
                 , service_id
                 , nvl(l_host_algorithm, host_algorithm)
                 , nvl(l_oper_type, oper_type)
                 , nvl(l_terminal_id, terminal_id)
                 , nvl(l_mcc, mcc)
                 , nvl(l_purpose_number, purpose_number)
              into l_provider_id
                 , l_service_id  
                 , l_host_algorithm
                 , l_oper_type
                 , l_terminal_id
                 , l_mcc 
                 , l_purpose_number
              from pmo_purpose
             where id = l_object_id;          
        
            process_child_object_id(
                i_child_data_id     => l_service_data_id
              , io_element_value    => l_service_id
            );
            process_service(
                i_appl_data_id      => l_service_data_id
              , o_object_id         => l_service_id
            );
                        
            process_child_object_id(
                i_child_data_id     => l_provider_data_id
              , io_element_value    => l_provider_id  
            );
            process_provider(
                i_appl_data_id      => l_provider_data_id
              , i_inst_id      => i_inst_id  
              , o_object_id         => l_provider_id
            );
                    
            pmo_ui_purpose_pkg.modify(
                i_id             =>    l_object_id            
              , i_provider_id    =>    l_provider_id   
              , i_service_id     =>    l_service_id    
              , i_host_algorithm =>    l_host_algorithm
              , i_oper_type      =>    l_oper_type     
              , i_terminal_id    =>    l_terminal_id   
              , i_mcc            =>    l_mcc
              , i_purpose_number =>    l_purpose_number 
            );
            
            for i in 1..nvl(l_label.count, 0) loop
                com_api_i18n_pkg.add_text(
                    i_table_name   => 'pmo_purpose'
                  , i_column_name  => 'label'
                  , i_object_id    => l_object_id
                  , i_text         => l_label(i).value
                  , i_lang         => l_label(i).lang
                );
                
            end loop;
            
        elsif l_command = app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT then
            com_api_error_pkg.raise_error(
                i_error         =>  'PAYMENT_PURPOSE_ALREADY_EXISTS'
              , i_env_param1    =>  to_char(l_object_id, 'TM9')
            );    
        elsif l_command in(
            app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
          , app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED
        ) then
        
            select provider_id
                 , service_id
              into l_provider_id
                 , l_service_id   
              from pmo_purpose
             where id = l_object_id;          
        
            process_child_object_id(
                i_child_data_id     => l_service_data_id
              , io_element_value    => l_service_id
            );
            process_service(
                i_appl_data_id      => l_service_data_id
              , o_object_id         => l_service_id
            );
                        
            process_child_object_id(
                i_child_data_id     => l_provider_data_id
              , io_element_value    => l_provider_id  
            );
            process_provider(
                i_appl_data_id      => l_provider_data_id
              , i_inst_id           => i_inst_id  
              , o_object_id         => l_provider_id
            );
                   
            app_api_application_pkg.get_appl_data_id(
                i_element_name      => 'OBJECT_ID'
              , i_parent_id         => i_appl_data_id
              , o_appl_data_id      => l_appl_data_id
            );

            if l_appl_data_id is null then
                app_api_application_pkg.add_element(
                    i_element_name      => 'OBJECT_ID'
                  , i_parent_id         => i_appl_data_id
                  , i_element_value     => l_object_id
                );

            else
                app_api_application_pkg.modify_element(
                    i_appl_data_id      => l_appl_data_id
                  , i_element_value     => l_object_id
                );
            end if;                 
        end if;    
    end if;
    
    g_purpose_id := l_object_id;
    
exception
    when com_api_error_pkg.e_application_error then
        app_api_error_pkg.intercept_error(
            i_appl_data_id  => i_appl_data_id
          , i_element_name  => 'PAYMENT_PURPOSE'
        );
end;

procedure process_application(
    i_appl_id      in      com_api_type_pkg.t_long_id          default null
) is
    l_purpose_data_id   com_api_type_pkg.t_long_id;
    l_purpose_object_id com_api_type_pkg.t_long_id;
    l_id_tab            com_api_type_pkg.t_number_tab;
    l_inst_id           com_api_type_pkg.t_inst_id;
begin

    trc_log_pkg.debug(
        i_text  => 'process_application start'
    );

    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'APPLICATION'
      , i_parent_id      => null
      , o_appl_data_id   => g_root_id
    );
    
    app_api_application_pkg.get_element_value(
        i_element_name  => 'INSTITUTION_ID'
      , i_parent_id     => g_root_id
      , o_element_value => l_inst_id
    );

    rul_api_param_pkg.set_param(
        i_value         => l_inst_id
      , i_name          => 'INST_ID'
      , io_params       => app_api_application_pkg.g_params
    );

    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'PAYMENT_PURPOSE'
      , i_parent_id      => g_root_id
      , o_appl_data_id   => l_purpose_data_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'OBJECT_ID'
      , i_parent_id      => l_purpose_data_id
      , o_element_value  => l_purpose_object_id
    );

    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'PAYMENT_HOST'
      , i_parent_id     => g_root_id
      , o_appl_data_id  => l_id_tab
    );

    for i in 1..nvl(l_id_tab.count, 0) loop
        process_host(
            i_appl_data_id => l_id_tab(i)
          , i_object_id    => l_purpose_object_id
        );
    end loop;

    process_purpose(
        i_appl_data_id => l_purpose_data_id
      , i_inst_id      => l_inst_id   
      , i_object_id    => l_purpose_object_id
    );
    
    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'PAYMENT_PARAMETER'
      , i_parent_id     => l_purpose_data_id
      , o_appl_data_id  => l_id_tab
    );

    for i in 1..nvl(l_id_tab.count, 0) loop
        process_parameter(
            i_appl_data_id => l_id_tab(i)
          , i_object_id    => l_purpose_object_id
        );
    end loop;
    
    trc_log_pkg.debug(
        i_text  => 'process_application finished'
    );

exception
    when com_api_error_pkg.e_application_error then
        app_api_error_pkg.intercept_error(
            i_appl_data_id  => g_root_id
          , i_element_name  => 'APPLICATION'
        );
end;

end;
/
