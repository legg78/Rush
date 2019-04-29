create or replace package body app_api_id_object_pkg as
/*********************************************************
*  Application - process ID <br />
*  Created by Kryukov E.(krukov@bpc.ru)  at 21.03.2011 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: APP_API_ID_OBJECT_PKG <br />
*  @headcom
**********************************************************/
procedure change_objects(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_object_id            in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
) is
begin
    app_api_flexible_field_pkg.process_flexible_fields(
        i_entity_type  => com_api_const_pkg.ENTITY_TYPE_CARD_IDENTITY
      , i_object_type  => null
      , i_object_id    => i_object_id
      , i_inst_id      => i_inst_id
      , i_appl_data_id => i_appl_data_id
    );
end;

procedure process_id_object(
    i_appl_data_id  in      com_api_type_pkg.t_long_id
  , i_entity_type   in      com_api_type_pkg.t_dict_value
  , i_object_id     in      com_api_type_pkg.t_long_id
  , o_id               out  com_api_type_pkg.t_long_id
) is
    l_command        com_api_type_pkg.t_dict_value;
    l_card           com_api_type_pkg.t_identity_card;
    l_id_tab         com_api_type_pkg.t_number_tab;
    l_seqnum         com_api_type_pkg.t_seqnum;
    l_customer_type  com_api_type_pkg.t_dict_value;
    l_root_id        com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug('app_api_id_object_pkg.process_id_object ' || i_object_id || ' and entity type ' || i_entity_type);
    l_id_tab.delete;

    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'APPLICATION'
      , i_parent_id      => null
      , o_appl_data_id   => l_root_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'INSTITUTION_ID'
      , i_parent_id      => l_root_id
      , o_element_value  => l_card.inst_id
    );

    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'IDENTITY_CARD'
      , i_parent_id      => i_appl_data_id
      , o_appl_data_id   => l_id_tab
    );

    for i in 1..nvl(l_id_tab.count, 0) loop
        app_api_application_pkg.get_element_value(
            i_element_name   => 'COMMAND'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_command
        );
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
        app_api_application_pkg.get_element_value(
            i_element_name   => 'COUNTRY'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_card.country
        );
        app_api_application_pkg.get_element_value(
            i_element_name   => 'ID_ISSUER'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_card.id_issuer
        );
        app_api_application_pkg.get_element_value(
            i_element_name   => 'ID_ISSUE_DATE'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_card.id_issue_date
        );
        app_api_application_pkg.get_element_value(
            i_element_name   => 'ID_EXPIRE_DATE'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_card.id_expire_date
        );
        app_api_application_pkg.get_element_value(
            i_element_name   => 'ID_DESC'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_card.id_desc
        );
        com_ui_id_object_pkg.get_ident_card_id(
            i_id_type    =>  l_card.id_type
          , i_id_series  =>  l_card.id_series
          , i_id_number  =>  l_card.id_number
          , o_id         =>  o_id
          , o_seqnum     =>  l_seqnum
          , i_inst_id    =>  l_card.inst_id
        );
        
        if o_id is not null then
            -- Checking document owner
            select entity_type
              into l_customer_type
              from com_id_object
             where id = o_id;   
             
            trc_log_pkg.debug('app_api_id_object_pkg.process_id_object l_customer_type=' || l_customer_type || ' and i_entity_type=' || i_entity_type);         
            
            if i_entity_type != l_customer_type then
                com_api_error_pkg.raise_error(
                    i_error         => 'IDENTITY_NOT_CORRESPOND_TO_ENTT_TYPE'
                  , i_env_param1    => o_id 
                  , i_env_param2    => i_entity_type 
                );
            end if;  

            if l_command = app_api_const_pkg.COMMAND_CREATE_OR_PROCEED then
                null;
            elsif l_command = app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT then
                com_api_error_pkg.raise_error(
                    i_error         => 'IDENTITY_CARD_ALREADY_EXIST'
                  , i_env_param1    => o_id ||' '||l_card.id_type||' '||l_card.id_series||' '||l_card.id_number
                );
            elsif l_command in (
                app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
              , app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
            ) then
                com_api_id_object_pkg.modify_id_object(
                    i_id             => o_id
                  , io_seqnum        => l_seqnum
                  , i_id_type        => l_card.id_type
                  , i_id_series      => l_card.id_series
                  , i_id_number      => l_card.id_number
                  , i_id_issuer      => l_card.id_issuer
                  , i_id_issue_date  => l_card.id_issue_date
                  , i_id_expire_date => l_card.id_expire_date
                  , i_id_desc        => l_card.id_desc
                  , i_lang           => null
                  , i_country        => l_card.country
                );
                /*com_api_error_pkg.raise_error(
                    i_error => 'UNABLE_TO_CHANGE_DOCUMENT'
                );*/
            else
                null; -- unknown command
            end if;
        else
            if l_command = app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE then
                null; 
            elsif l_command in (
                app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
              , app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
            ) then
                com_api_error_pkg.raise_error(
                    i_error         => 'IDENTITY_CARD_NOT_FOUND'
                  , i_env_param1    => o_id ||' '||l_card.id_type||' '||l_card.id_series||' '||l_card.id_number
                );
            elsif l_command in (
                app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
              , app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
              , app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
            ) then
                com_api_id_object_pkg.add_id_object(
                    o_id             => o_id
                  , o_seqnum         => l_seqnum
                  , i_entity_type    => i_entity_type
                  , i_object_id      => i_object_id
                  , i_id_type        => l_card.id_type
                  , i_id_series      => l_card.id_series
                  , i_id_number      => l_card.id_number
                  , i_id_issuer      => l_card.id_issuer
                  , i_id_issue_date  => l_card.id_issue_date
                  , i_id_expire_date => l_card.id_expire_date
                  , i_id_desc        => l_card.id_desc
                  , i_lang           => null
                  , i_inst_id        => l_card.inst_id
                  , i_country        => l_card.country
                );
            else
                null; -- unknown command
                trc_log_pkg.debug('app_api_id_object_pkg.process_id_object: l_command=' || l_command || ' is unknown');  
            end if;
        end if;

        change_objects(
            i_appl_data_id   => l_id_tab(i)
          , i_object_id      => o_id
          , i_inst_id        => l_card.inst_id
        );         

    end loop;
exception
    when com_api_error_pkg.e_application_error then
        app_api_error_pkg.intercept_error(
            i_appl_data_id  => i_appl_data_id
          , i_element_name  => 'IDENTITY_CARD'
        );
end process_id_object;

end app_api_id_object_pkg;
/
