create or replace package body acm_api_application_pkg as
/*********************************************************
 *  User management applications API  <br />
 *  Created by Alalykin A.(alalykin@bpcbt.com) at 12.11.2015 <br />
 *  Last changed by $Author: alalykin $ <br />
 *  $LastChangedDate:: 2015-11-12 10:00:00 +0300#$ <br />
 *  Revision: $LastChangedRevision: 1 $ <br />
 *  Module: ACM_API_APPLICATION_PKG <br />
 *  @headcom
 **********************************************************/

g_appl_id                    com_api_type_pkg.t_long_id;

procedure process_user_agent(
    i_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_user_id       in            com_api_type_pkg.t_short_id
  , i_inst_id       in            com_api_type_pkg.t_inst_id
) is
    LOG_PREFIX      constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_user_agent: ';
    l_command                com_api_type_pkg.t_dict_value;
    l_agent_id               com_api_type_pkg.t_agent_id;
    l_agent_number           com_api_type_pkg.t_name;
    l_is_default             com_api_type_pkg.t_boolean;
    l_id                     com_api_type_pkg.t_short_id;
begin
    trc_log_pkg.debug(LOG_PREFIX || 'START, i_appl_data_id [' || i_appl_data_id || ']');

    app_api_application_pkg.get_element_value(
        i_element_name   => 'COMMAND'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_command
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'AGENT_ID'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_agent_id
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'AGENT_NUMBER'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_agent_number
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'IS_DEFAULT'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_is_default
    );

    -- Agent ID is used firstly, if it is empty then agent name is used.
    -- Command relates to table ACM_USER_AGENT, so if agent is not found
    -- then the error is raised
    l_agent_id := ost_api_agent_pkg.get_agent_id(
                      i_agent_id     => l_agent_id
                    , i_agent_number => l_agent_number
                    , i_inst_id      => i_inst_id
                    , i_mask_error   => com_api_type_pkg.FALSE
                  );
    case
        when l_command in (app_api_const_pkg.COMMAND_CREATE_OR_PROCEED) then
            acm_api_user_pkg.add_agent_to_user(
                i_user_id     => i_user_id
              , i_agent_id    => l_agent_id
              , i_is_default =>  l_is_default
              , o_id          => l_id
            );
        when l_command in (app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE) then
            acm_api_user_pkg.remove_agent_from_user(
                i_user_id     => i_user_id
              , i_agent_id    => l_agent_id
            );
        else
            com_api_error_pkg.raise_error(
                i_error      => 'INVALID_COMMAND'
              , i_env_param1 => l_command
              , i_env_param2 => 'USER_AGENT' -- parent block's name
              , i_env_param3 => i_appl_data_id -- application ID of the parent block
              , i_env_param4 => app_api_const_pkg.COMMAND_CREATE_OR_PROCEED || ', '
                             || app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE -- list of valid commands
            );
    end case;

    trc_log_pkg.debug(LOG_PREFIX || 'FINISH');
end process_user_agent;

procedure process_user_inst(
    i_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_user_id       in            com_api_type_pkg.t_short_id
  , o_inst_id          out        com_api_type_pkg.t_inst_id -- returning user_inst->institution_id
) is
    LOG_PREFIX      constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_user_inst: ';
    l_command                com_api_type_pkg.t_dict_value;
    l_is_entirely            com_api_type_pkg.t_boolean;
    l_is_default             com_api_type_pkg.t_boolean;
    l_id                     com_api_type_pkg.t_short_id;
    l_id_tab                 com_api_type_pkg.t_number_tab;
begin
    trc_log_pkg.debug(LOG_PREFIX || 'START, i_appl_data_id [' || i_appl_data_id || ']');

    app_api_application_pkg.get_element_value(
        i_element_name   => 'COMMAND'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_command
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'INSTITUTION_ID'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_inst_id
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'IS_ENTIRELY'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_is_entirely
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'IS_DEFAULT'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_is_default
    );

    case
        when l_command in (app_api_const_pkg.COMMAND_CREATE_OR_PROCEED) then
            acm_api_user_pkg.add_inst_to_user(
                i_user_id     => i_user_id
              , i_inst_id     => o_inst_id
              , i_is_entirely => l_is_entirely
              , i_is_default  => l_is_default
              , o_id          => l_id
            );
        when l_command in (app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE) then
            acm_api_user_pkg.remove_inst_from_user(
                i_user_id     => i_user_id
              , i_inst_id     => o_inst_id
            );
        else
            com_api_error_pkg.raise_error(
                i_error      => 'INVALID_COMMAND'
              , i_env_param1 => l_command
              , i_env_param2 => 'USER_INST' -- parent block's name
              , i_env_param3 => i_appl_data_id -- application ID of the parent block
              , i_env_param4 => app_api_const_pkg.COMMAND_CREATE_OR_PROCEED || ', '
                             || app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE -- list of valid commands
            );
    end case;

    app_api_application_pkg.get_appl_data_id(
        i_element_name => 'USER_AGENT'
      , i_parent_id    => i_appl_data_id
      , o_appl_data_id => l_id_tab
    );
    for i in 1..l_id_tab.count loop
        process_user_agent(
            i_appl_data_id => l_id_tab(i)
          , i_user_id      => i_user_id
          , i_inst_id      => o_inst_id
        );
    end loop;

    acm_api_user_pkg.clean_agents();

    trc_log_pkg.debug(LOG_PREFIX || 'FINISH');
end process_user_inst;

procedure process_user_role(
    i_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_user_id       in            com_api_type_pkg.t_short_id
) is
    LOG_PREFIX      constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_user_role: ';
    l_command                com_api_type_pkg.t_dict_value;
    l_role_id                com_api_type_pkg.t_tiny_id;
    l_role_name              com_api_type_pkg.t_name;
    l_id                     com_api_type_pkg.t_short_id;
begin
    trc_log_pkg.debug(LOG_PREFIX || 'START, i_appl_data_id [' || i_appl_data_id || ']');

    app_api_application_pkg.get_element_value(
        i_element_name   => 'COMMAND'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_command
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'ROLE_ID'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_role_id
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'ROLE_NAME'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_role_name
    );

    -- Role ID is used firstly, if it is empty then role name is used.
    -- Command relates to table ACM_USER_ROLE, so if role is not found
    -- then the error is raised
    l_role_id := acm_api_role_pkg.get_role(
                     i_role_id    => l_role_id
                   , i_role_name  => l_role_name
                   , i_mask_error => com_api_type_pkg.FALSE
                 ).id;

    case l_command
        when app_api_const_pkg.COMMAND_CREATE_OR_PROCEED then
            acm_api_user_pkg.add_role_to_user(
                i_role_id    => l_role_id
              , i_user_id    => i_user_id
              , o_id         => l_id
              , i_mask_error => com_api_type_pkg.TRUE -- ignore an error if role is already granted
            );
        when app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE then
            acm_api_user_pkg.remove_role_from_user(
                i_role_id    => l_role_id
              , i_user_id    => i_user_id
              , i_mask_error => com_api_type_pkg.TRUE -- ignore an error if role is already removed
            );
        else
            com_api_error_pkg.raise_error(
                i_error      => 'INVALID_COMMAND'
              , i_env_param1 => l_command
              , i_env_param2 => 'USER_ROLE' -- parent block's name
              , i_env_param3 => i_appl_data_id -- application ID of the parent block
              , i_env_param4 => app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
                             || app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE
            );
    end case;

    trc_log_pkg.debug(LOG_PREFIX || 'FINISH');
end process_user_role;

procedure process_user_group(
    i_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_user_id       in            com_api_type_pkg.t_short_id
) is
    LOG_PREFIX      constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_user_group: ';
    l_group_id               com_api_type_pkg.t_short_id;
    l_link_flag              com_api_type_pkg.t_boolean;
    l_entity_type            com_api_type_pkg.t_dict_value;
    l_id                     com_api_type_pkg.t_short_id;
begin
    trc_log_pkg.debug(LOG_PREFIX || 'START, i_appl_data_id [' || i_appl_data_id || ']');

    app_api_application_pkg.get_element_value(
        i_element_name   => 'GROUP_ID'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_group_id
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'USER_LINK_FLAG'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_link_flag
    );

    select e.entity_type
      into l_entity_type
      from app_data d
         , app_element e
     where d.element_id = e.id
       and e.name       = 'GROUP_ID'
       and d.parent_id  = i_appl_data_id;

    case 
        when l_entity_type = acm_api_const_pkg.ENTITY_TYPE_USER_GROUP 
         and l_link_flag = com_api_const_pkg.TRUE then
            acm_ui_group_pkg.attach_user(
                o_id       => l_id
              , i_user_id  => i_user_id
              , i_group_id => l_group_id
            );
        when l_entity_type = acm_api_const_pkg.ENTITY_TYPE_USER_GROUP 
         and l_link_flag = com_api_const_pkg.FALSE then
            acm_ui_group_pkg.detach_user(
                i_id       => null
              , i_user_id  => i_user_id
              , i_group_id => l_group_id
            );
    end case;
    
    trc_log_pkg.debug(LOG_PREFIX || 'FINISH');
exception
    when others then
        com_api_error_pkg.raise_error(
            i_error         => 'INCORRECT_ATTACHING_USER_GROUP'
          , i_env_param1    => i_user_id
          , i_env_param2    => l_group_id
          , i_env_param3    => l_entity_type
        );
end process_user_group;

/*
 * Change/process child objects.
 * @o_inst_id  -
       it contains any value user_inst->institution_id because this value is used to
       define a root institution (sandbox) and it must be a mutual for all child instituions
 */
procedure change_objects(
    i_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_user_id       in            com_api_type_pkg.t_short_id
  , o_inst_id          out        com_api_type_pkg.t_inst_id
  , o_person_id        out        com_api_type_pkg.t_person_id
) is
    LOG_PREFIX      constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.change_objects: ';
    l_app_data_id            com_api_type_pkg.t_long_id;
    l_id_tab                 com_api_type_pkg.t_number_tab;
begin
    trc_log_pkg.debug(LOG_PREFIX || 'START, i_appl_data_id [' || i_appl_data_id || '], i_user_id [' || i_user_id || ']');

    app_api_application_pkg.get_appl_data_id(
        i_element_name => 'PERSON'
      , i_parent_id    => i_appl_data_id
      , o_appl_data_id => l_app_data_id
    );
    if l_app_data_id is not null then
        app_api_person_pkg.process_person(
            i_appl_data_id => l_app_data_id
          , io_person_id   => o_person_id
        );
    end if;
    trc_log_pkg.debug('o_person_id [' || o_person_id || ']');

    app_api_application_pkg.get_appl_data_id(
        i_element_name => 'CONTACT'
      , i_parent_id    => i_appl_data_id
      , o_appl_data_id => l_id_tab
    );
    for i in 1..l_id_tab.count loop
        app_api_contact_pkg.process_contact(
            i_appl_data_id        => l_id_tab(i)
          , i_parent_appl_data_id => i_appl_data_id
          , i_object_id           => i_user_id
          , i_entity_type         => acm_api_const_pkg.ENTITY_TYPE_USER
          , i_person_id           => null -- don't use <o_person_id> because it's a nonsense
        );
    end loop;

    app_api_application_pkg.get_appl_data_id(
        i_element_name => 'USER_INST'
      , i_parent_id    => i_appl_data_id
      , o_appl_data_id => l_id_tab
    );
    for i in 1..l_id_tab.count loop
        process_user_inst(
            i_appl_data_id => l_id_tab(i)
          , i_user_id      => i_user_id
          , o_inst_id      => o_inst_id
        );
    end loop;

    app_api_application_pkg.get_appl_data_id(
        i_element_name => 'USER_ROLE'
      , i_parent_id    => i_appl_data_id
      , o_appl_data_id => l_id_tab
    );
    for i in 1..l_id_tab.count loop
        process_user_role(
            i_appl_data_id => l_id_tab(i)
          , i_user_id      => i_user_id
        );
    end loop;
    
    app_api_application_pkg.get_appl_data_id(
        i_element_name => 'USER_GROUP'
      , i_parent_id    => i_appl_data_id
      , o_appl_data_id => l_id_tab
    );
    for i in 1..l_id_tab.count loop
        process_user_group(
            i_appl_data_id => l_id_tab(i)
          , i_user_id      => i_user_id
        );
    end loop;

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'FINISH: o_inst_id [' || o_inst_id
                             || '], o_person_id [' || o_person_id || ']'
    );
end change_objects;

procedure create_user(
    i_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_user_rec      in            acm_api_type_pkg.t_user_rec
) is
    LOG_PREFIX      constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.create_user: ';
    l_user_rec               acm_api_type_pkg.t_user_rec;
begin
    trc_log_pkg.debug(LOG_PREFIX || 'START, i_appl_data_id [' || i_appl_data_id || ']');

    l_user_rec := i_user_rec;

    acm_api_user_pkg.create_user(
        io_user_rec => l_user_rec
    );

    trc_log_pkg.debug('Add link to user into app_object. user_id(i_object_id)[' || l_user_rec.id || ']; '
                      || 'i_appl_id[' || g_appl_id || ']; '
    );
    app_api_appl_object_pkg.add_object(
        i_appl_id           => g_appl_id --app_api_application_pkg.get_appl_id
      , i_entity_type       => ACM_API_CONST_PKG.ENTITY_TYPE_USER
      , i_object_id         => l_user_rec.id
      , i_seqnum            => 1
    );

    change_objects(
        i_appl_data_id => i_appl_data_id
      , i_user_id      => l_user_rec.id
      , o_inst_id      => l_user_rec.inst_id -- <inst_id> from some block <user_inst>
      , o_person_id    => l_user_rec.person_id
    );

    -- Define user's institution (acm_user.inst_id) as a root institution for all
    -- user_inst->institution_id, i.e. all these user institutions must have a mutual root
    l_user_rec.inst_id :=
        nvl(
            ost_api_institution_pkg.get_sandbox(i_inst_id => l_user_rec.inst_id)
          , ost_api_const_pkg.DEFAULT_INST
        );
    trc_log_pkg.debug('user''s user_id [' || l_user_rec.id || ']');

    -- Change person ID and institution ID if they have been updated on previous step

    l_user_rec.password_hash := null;

    acm_api_user_pkg.update_user(
        i_user_rec       => l_user_rec
      , i_check_password => com_api_type_pkg.FALSE
    );

    trc_log_pkg.debug(LOG_PREFIX || 'FINISH');
end create_user;

procedure process_user(
    i_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_parent_id     in            com_api_type_pkg.t_long_id
) is
    e_invalid_application_command exception;
    LOG_PREFIX      constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_user: ';
    l_command                com_api_type_pkg.t_dict_value;
    l_user_rec               acm_api_type_pkg.t_user_rec;
    l_app_user_id            com_api_type_pkg.t_short_id;
begin
    trc_log_pkg.debug(LOG_PREFIX || 'START, i_appl_data_id [' || i_appl_data_id
                                 || '], i_parent_id [' || i_parent_id || ']');

    app_api_application_pkg.get_element_value(
        i_element_name   => 'COMMAND'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_command
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'USER_ID'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_user_rec.id
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'USER_NAME'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_user_rec.name
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'PASSWORD_HASH'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_user_rec.password_hash
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'USER_STATUS'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_user_rec.status
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'AUTH_SCHEME'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_user_rec.auth_scheme
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'PASSWORD_CHANGE_NEEDED'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_user_rec.password_change_needed
    );

    trc_log_pkg.debug(
        i_text       => 'Searching for user by ID [#1](primarily) OR name [#2](secondary)...'
      , i_env_param1 => l_user_rec.id
      , i_env_param2 => l_user_rec.name
    );
    -- Saving user_id from an application to use it for error's raising if it will be needed below
    l_app_user_id := l_user_rec.id;
    -- User ID is used for searching firstly, if it isn't empty then user name is ignored;
    -- overwise, user name is used for searching
    l_user_rec.id := acm_api_user_pkg.get_user(
                         i_user_id    => l_user_rec.id
                       , i_user_name  => l_user_rec.name
                       , i_mask_error => com_api_type_pkg.TRUE
                     ).id;

    if l_user_rec.id is null then
        trc_log_pkg.debug('User is NOT found');
        case
            when l_command in (app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
                             , app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
                             , app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT)
            then
                create_user(
                    i_appl_data_id => i_appl_data_id
                  , i_user_rec     => l_user_rec
                );

            when l_command in (app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
                             , app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED)
            then
                com_api_error_pkg.raise_error(
                    i_error      => 'USER_DOES_NOT_EXIST'
                  , i_env_param1 => l_app_user_id
                  , i_env_param2 => case when l_app_user_id is null then l_user_rec.name end
                );

            else
                raise e_invalid_application_command;
        end case;
    else
        trc_log_pkg.debug('User with ID [' || l_user_rec.id || '] is FOUND');
        case
            when l_command = app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT then
                -- if <l_app_user_id> is null then user has been found but its name, not ID
                com_api_error_pkg.raise_error(
                    i_error      => 'USER_ALREADY_EXISTS'
                  , i_env_param1 => l_user_rec.id
                  , i_env_param2 => case when l_app_user_id is null then l_user_rec.name end
                );

            when l_command in (app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
                             , app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE)
            then
                change_objects(
                    i_appl_data_id => i_appl_data_id
                  , i_user_id      => l_user_rec.id
                  , o_inst_id      => l_user_rec.inst_id -- ignored
                  , o_person_id    => l_user_rec.person_id
                );
                -- Change person ID and password's hash if it is needed,
                -- user's name and institution ID are not updatable
                l_user_rec.name    := null;
                l_user_rec.inst_id := null;
                -- Search a user by ID and update all other fields if they aren't empty
                acm_api_user_pkg.update_user(
                    i_user_rec                  => l_user_rec
                  , i_check_password            => com_api_type_pkg.TRUE
                );

            when l_command in (app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
                             , app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED)
            then
                change_objects(
                    i_appl_data_id => i_appl_data_id
                  , i_user_id      => l_user_rec.id
                  , o_inst_id      => l_user_rec.inst_id -- ignored
                  , o_person_id    => l_user_rec.person_id
                );

            else
                raise e_invalid_application_command;
        end case;
    end if;

    trc_log_pkg.debug(LOG_PREFIX || 'FINISH');
exception
    when e_invalid_application_command then
        com_api_error_pkg.raise_error(
            i_error      => 'INVALID_COMMAND'
          , i_env_param1 => l_command
          , i_env_param2 => 'USER' -- parent block's name
          , i_env_param3 => i_appl_data_id -- application ID of the parent block
          , i_env_param4 => app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
                         || app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
                         || app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
                         || app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
                         || app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED -- list of valid commands
        );
    when com_api_error_pkg.e_application_error then
        app_api_error_pkg.intercept_error(
            i_appl_data_id => i_appl_data_id
          , i_parent_id    => i_parent_id
          , i_element_name => 'USER'
        );
end process_user;

procedure process_application(
    i_appl_id       in            com_api_type_pkg.t_long_id
) is
    LOG_PREFIX      constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_application: ';
    l_root_id                com_api_type_pkg.t_long_id;
    l_inst_id                com_api_type_pkg.t_inst_id;
    l_user_data_id           com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug(LOG_PREFIX || 'START, i_appl_id [' || i_appl_id || ']');

    g_appl_id := i_appl_id;

    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'APPLICATION'
      , i_parent_id     => null
      , o_appl_data_id  => l_root_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name  => 'INSTITUTION_ID'
      , i_parent_id     => l_root_id
      , o_element_value => l_inst_id
    );

    rul_api_param_pkg.set_param(
        i_value         => l_inst_id
      , i_name          => 'INST_ID'
      , io_params       => app_api_application_pkg.g_params
    );

    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'USER'
      , i_parent_id     => l_root_id
      , o_appl_data_id  => l_user_data_id
    );

    if l_user_data_id is not null then
        process_user(
            i_appl_data_id => l_user_data_id
          , i_parent_id    => l_root_id
        );
    end if;

    trc_log_pkg.debug(LOG_PREFIX || 'FINISH');
exception
    when com_api_error_pkg.e_application_error then
        app_api_error_pkg.intercept_error(
            i_appl_data_id => l_root_id
          , i_element_name => 'APPLICATION'
        );
end process_application;

procedure attach_user_to_application(
    i_appl_id           in     com_api_type_pkg.t_long_id
  , i_user_id           in     com_api_type_pkg.t_short_id
) is
    l_count                    com_api_type_pkg.t_count    := 0;
begin
    if i_user_id is null then
        return;
    end if;

    select count(appl_id)
      into l_count
      from app_object
     where appl_id         = i_appl_id
       and object_id+0     = i_user_id
       and entity_type||'' = ACM_API_CONST_PKG.ENTITY_TYPE_USER;

    trc_log_pkg.debug(
        i_text        => 'Attach card to application: number of accounts [#1], account_id [#2], application_id [#3]'
      , i_env_param1  => l_count
      , i_env_param2  => i_user_id
      , i_env_param3  => i_appl_id
    );

    if l_count = 0 then
        app_api_appl_object_pkg.add_object(
            i_appl_id           => i_appl_id
          , i_entity_type       => ACM_API_CONST_PKG.ENTITY_TYPE_USER
          , i_object_id         => i_user_id
          , i_seqnum            => 1
        );
    end if;
end attach_user_to_application;

end acm_api_application_pkg;
/
