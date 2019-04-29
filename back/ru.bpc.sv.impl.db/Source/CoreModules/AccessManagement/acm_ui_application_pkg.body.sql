create or replace package body acm_ui_application_pkg as
/********************************************************* 
 *  User management applications User Interface  <br /> 
 *  Created by Truschelev O. (truschelev@bpcbt.com) at 06.04.2018 <br /> 
 *  Last changed by $Author: truschelev $ <br /> 
 *  $LastChangedDate:: 2018-04-06 18:00:00 +0300#$ <br /> 
 *  Revision: $LastChangedRevision: 1 $ <br /> 
 *  Module: ACM_UI_APPLICATION_PKG <br /> 
 *  @headcom 
 **********************************************************/ 

function check_change_user_via_appl
    return com_api_type_pkg.t_boolean
is
    l_result    com_api_type_pkg.t_boolean;
begin
    l_result := nvl(set_ui_value_pkg.get_system_param_n(i_param_name => 'CHANGE_USER_VIA_APPLICATION'), com_api_const_pkg.FALSE);

    return l_result;
end check_change_user_via_appl;  

procedure create_application(
    io_appl_id          in out com_api_type_pkg.t_long_id
  , i_user_id           in     com_api_type_pkg.t_short_id
  , i_inst_command      in     com_api_type_pkg.t_dict_value  default null
  , i_user_inst_id      in     com_api_type_pkg.t_inst_id     default null
  , i_is_entirely       in     com_api_type_pkg.t_boolean     default null
  , i_is_inst_default   in     com_api_type_pkg.t_boolean     default null
  , i_agent_command     in     com_api_type_pkg.t_dict_value  default null
  , i_user_agent_id     in     com_api_type_pkg.t_agent_id    default null
  , i_is_agent_default  in     com_api_type_pkg.t_boolean     default null
  , i_role_command      in     com_api_type_pkg.t_dict_value  default null
  , i_user_role_id      in     com_api_type_pkg.t_tiny_id     default null
)
is
    LOG_PREFIX     constant com_api_type_pkg.t_name            := lower($$PLSQL_UNIT) || '.create_application ';
    l_flow_id               com_api_type_pkg.t_tiny_id         := 1302;
    l_seqnum                com_api_type_pkg.t_tiny_id;

    l_application_block_id  com_api_type_pkg.t_long_id;
    l_user_block_id         com_api_type_pkg.t_long_id;
    l_user_inst_block_id    com_api_type_pkg.t_long_id;
    l_user_agent_block_id   com_api_type_pkg.t_long_id;
    l_role_block_id         com_api_type_pkg.t_long_id;

    l_inst_command          com_api_type_pkg.t_dict_value      := i_inst_command;
    l_user_inst_id          com_api_type_pkg.t_inst_id         := i_user_inst_id;
    l_user_name             com_api_type_pkg.t_name;
    l_is_new_application    com_api_type_pkg.t_boolean         := com_api_type_pkg.FALSE;

    l_appl_inst_id          com_api_type_pkg.t_inst_id;
    l_appl_agent_id         com_api_type_pkg.t_agent_id;
    l_appl_data             app_data_tpt;
begin  
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'Start'
    );

    if l_inst_command      is null
       and i_agent_command is not null
    then
        l_inst_command := app_api_const_pkg.COMMAND_CREATE_OR_PROCEED;
    end if;

    if l_user_inst_id is null then
        l_user_inst_id := ost_api_agent_pkg.get_inst_id(
                              i_agent_id => i_user_agent_id
                          );
    end if;

    l_user_name := acm_api_user_pkg.get_user_name(
                       i_user_id => i_user_id
                   );

    if io_appl_id is null then

        for r in (
            select inst_id
              from acm_cu_inst_vw a
             order by a.is_default desc, inst_id
        ) loop
            l_appl_inst_id := r.inst_id;
            exit;
        end loop;

        l_appl_agent_id   := ost_api_institution_pkg.get_default_agent(
                                 i_inst_id => l_appl_inst_id
                             );

        app_ui_application_pkg.add_application(
            i_context_mode     => null
          , io_appl_id         => io_appl_id
          , o_seqnum           => l_seqnum
          , i_appl_type        => app_api_const_pkg.APPL_TYPE_USER_MANAGEMENT
          , i_appl_number      => null
          , i_flow_id          => l_flow_id
          , i_inst_id          => l_appl_inst_id
          , i_agent_id         => l_appl_agent_id
          , i_appl_status      => app_api_const_pkg.APPL_STATUS_PROC_READY
          , i_session_file_id  => null
          , i_file_rec_num     => null
          , i_customer_type    => null
          , i_customer_number  => null
          , i_appl_data        => l_appl_data
        );

        l_is_new_application := com_api_type_pkg.TRUE;

        trc_log_pkg.debug(
            i_text       => 'New l_appl_id [#1]'
          , i_env_param1 => io_appl_id
        );
    else
        trc_log_pkg.debug(
            i_text       => 'Exist l_appl_id [#1]'
          , i_env_param1 => io_appl_id
        );
    end if;

    acm_api_application_pkg.attach_user_to_application(
        i_appl_id        => io_appl_id
      , i_user_id        => i_user_id
    );

    app_api_application_pkg.get_appl_data(
        i_appl_id        => io_appl_id
    );

    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'APPLICATION'
      , i_parent_id     => null
      , o_appl_data_id  => l_application_block_id
    );

    -- Add "USER" block
    if l_is_new_application = com_api_type_pkg.TRUE then
        app_api_application_pkg.add_element(
            i_element_name      => 'USER'
          , i_parent_id         => l_application_block_id
          , i_element_value     => ''
        );
    end if;

    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'USER'
      , i_parent_id     => l_application_block_id
      , o_appl_data_id  => l_user_block_id
    );

    if l_is_new_application = com_api_type_pkg.TRUE then
        app_api_application_pkg.add_element(
            i_element_name      => 'COMMAND'
          , i_parent_id         => l_user_block_id
          , i_element_value     => 'CMMDEXUP'
        );

        app_api_application_pkg.add_element(
            i_element_name      => 'USER_ID'
          , i_parent_id         => l_user_block_id
          , i_element_value     => i_user_id
        );

        app_api_application_pkg.add_element(
            i_element_name      => 'USER_NAME'
          , i_parent_id         => l_user_block_id
          , i_element_value     => l_user_name
        );
    end if;

    -- Add "USER_INST" block
    if l_inst_command     is not null
       and l_user_inst_id is not null
    then
        if l_is_new_application = com_api_type_pkg.TRUE then
            app_api_application_pkg.add_element(
                i_element_name      => 'USER_INST'
              , i_parent_id         => l_user_block_id
              , i_element_value     => ''
            );
        end if;

        app_api_application_pkg.get_appl_data_id(
            i_element_name  => 'USER_INST'
          , i_parent_id     => l_user_block_id
          , o_appl_data_id  => l_user_inst_block_id
        );

        if l_is_new_application = com_api_type_pkg.TRUE then
            app_api_application_pkg.add_element(
                i_element_name      => 'COMMAND'
              , i_parent_id         => l_user_inst_block_id
              , i_element_value     => l_inst_command
            );

            app_api_application_pkg.add_element(
                i_element_name      => 'INSTITUTION_ID'
              , i_parent_id         => l_user_inst_block_id
              , i_element_value     => l_user_inst_id
            );

            if i_is_entirely is not null then
                app_api_application_pkg.add_element(
                    i_element_name      => 'IS_ENTIRELY'
                  , i_parent_id         => l_user_inst_block_id
                  , i_element_value     => i_is_entirely
                );
            end if;

            if i_is_inst_default is not null then
                app_api_application_pkg.add_element(
                    i_element_name      => 'IS_DEFAULT'
                  , i_parent_id         => l_user_inst_block_id
                  , i_element_value     => i_is_inst_default
                );
            end if;
        end if;

        -- Add "USER_AGENT" block
        if i_agent_command     is not null
           and i_user_agent_id is not null
        then

            app_api_application_pkg.add_element(
                i_element_name      => 'USER_AGENT'
              , i_parent_id         => l_user_inst_block_id
              , i_element_value     => ''
              , o_appl_data_id      => l_user_agent_block_id
            );

            app_api_application_pkg.add_element(
                i_element_name      => 'COMMAND'
              , i_parent_id         => l_user_agent_block_id
              , i_element_value     => i_agent_command
            );

            app_api_application_pkg.add_element(
                i_element_name      => 'AGENT_ID'
              , i_parent_id         => l_user_agent_block_id
              , i_element_value     => i_user_agent_id
            );

            if i_is_agent_default is not null then
                app_api_application_pkg.add_element(
                    i_element_name      => 'IS_DEFAULT'
                  , i_parent_id         => l_user_agent_block_id
                  , i_element_value     => i_is_agent_default
                );
            end if;

        end if;
    end if;

    -- Add "USER_ROLE" block
    if i_role_command is not null
       and i_user_role_id  is not null
    then

        app_api_application_pkg.add_element(
            i_element_name      => 'USER_ROLE'
          , i_parent_id         => l_user_block_id
          , i_element_value     => ''
        );

        app_api_application_pkg.get_appl_data_id(
            i_element_name  => 'USER_ROLE'
          , i_parent_id     => l_user_block_id
          , o_appl_data_id  => l_role_block_id
        );

        app_api_application_pkg.add_element(
            i_element_name      => 'COMMAND'
          , i_parent_id         => l_role_block_id
          , i_element_value     => i_role_command
        );

        app_api_application_pkg.add_element(
            i_element_name      => 'ROLE_ID'
          , i_parent_id         => l_role_block_id
          , i_element_value     => i_user_role_id
        );

    end if;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'Finish'
    );

end create_application;

end acm_ui_application_pkg;
/
