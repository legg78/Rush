create or replace package body aap_api_application_pkg as
/*********************************************************
*  Acquiring application API  <br />
*  Created by Khougaev A.(khougaev@bpcsv.com)  at 19.03.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: AAP_API_APPLICATION_PKG <br />
*  @headcom
**********************************************************/
procedure process_application(
    i_appl_id              in            com_api_type_pkg.t_long_id          default null
) is
    l_appl_data_id         com_api_type_pkg.t_long_id;
    l_customer_data_id     com_api_type_pkg.t_long_id;
    l_root_id              com_api_type_pkg.t_long_id;
--    l_branch_id        com_api_type_pkg.t_long_id;
    l_inst_id              com_api_type_pkg.t_inst_id;
    l_contract_id          com_api_type_pkg.t_long_id;
    l_customer_id          com_api_type_pkg.t_medium_id;
    l_agent_id             com_api_type_pkg.t_short_id;
--    l_appl_data_id_tab     com_api_type_pkg.t_number_tab;
--    l_count                pls_integer;
--    l_merchant_id          com_api_type_pkg.t_short_id;
    l_customer_number      com_api_type_pkg.t_name;
    l_agent_number         com_api_type_pkg.t_name;
begin
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
        i_element_name  => 'AGENT_NUMBER'
      , i_parent_id     => l_root_id
      , o_element_value => l_agent_number
    );

    if l_agent_number is not null then
        begin
            select id
              into l_agent_id 
              from ost_agent_vw
             where agent_number = l_agent_number
               and inst_id      = l_inst_id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error         => 'AGENT_NOT_FOUND'
                    , i_env_param1  => l_agent_number
                );            
        end;   
    else
        app_api_application_pkg.get_element_value(
            i_element_name  => 'AGENT_ID'
          , i_parent_id     => l_root_id
          , o_element_value => l_agent_id
        );                
        begin

            select id
              into l_agent_id
              from ost_agent_vw
             where id = l_agent_id;

        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error         => 'AGENT_NOT_FOUND'
                    , i_env_param1  => l_agent_id
                );
        end;
    end if;
    
    rul_api_param_pkg.set_param(
        i_value         => l_agent_id
      , i_name          => 'AGENT_ID'
      , io_params       => app_api_application_pkg.g_params
    );

    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'CUSTOMER'
      , i_parent_id      => l_root_id
      , o_appl_data_id   => l_customer_data_id
    );

    if l_customer_data_id is null then
--        com_api_error_pkg.raise_error(
--            i_error      => 'ABSENT_MANDATORY_ELEMENT'
--          , i_env_param1 => 'CUSTOMER'
--        );
        null;
    else 
        app_api_customer_pkg.process_customer(
            i_appl_data_id => l_customer_data_id
          , i_inst_id      => l_inst_id
          , o_customer_id  => l_customer_id
        );
    end if;

    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'CONTRACT'
      , i_parent_id      => l_root_id
      , o_appl_data_id   => l_appl_data_id
    );

    if l_appl_data_id is not null then
        app_api_contract_pkg.process_contract(
            i_appl_data_id  => l_appl_data_id
          , i_inst_id       => l_inst_id
          , i_agent_id      => l_agent_id
          , i_customer_id   => l_customer_id
          , o_contract_id   => l_contract_id
        );
    end if;

    app_api_flexible_field_pkg.process_flexible_fields(
        i_entity_type   => app_api_const_pkg.ENTITY_TYPE_APPLICATION
      , i_object_type   => null
      , i_object_id     => nvl(i_appl_id, app_api_application_pkg.get_appl_id)
      , i_inst_id       => l_inst_id
      , i_appl_data_id  => l_root_id
    );

    app_api_note_pkg.process_note(
        i_appl_data_id => l_root_id
      , i_entity_type  => app_api_const_pkg.ENTITY_TYPE_APPLICATION
      , i_object_id    => nvl(i_appl_id, app_api_application_pkg.get_appl_id)
    );

exception
    when com_api_error_pkg.e_application_error then
        app_api_error_pkg.intercept_error(
            i_appl_data_id  => l_root_id
          , i_element_name  => 'APPLICATION'
        );
end;

end;
/
