create or replace package body app_api_department_pkg as
/************************************************************
 * API for departments<br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 13.10.2011  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: APP_API_DEPARTMENT_PKG <br />
 * @headcom
 ************************************************************/

procedure create_department(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_parent_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_contract_id          in            com_api_type_pkg.t_medium_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
) is
    l_department           iss_api_type_pkg.t_department;
begin

    trc_log_pkg.debug(
        'Create department. Contract:'||
        i_contract_id || ' Customer:'||
        i_customer_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'DEPARTMENT_NAME'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_department.label
    );

    trc_log_pkg.info('DEPARTMENT:'|| l_department.label);

    crp_api_department_pkg.add_department(
        o_id               => l_department.id
      , i_parent_id        => l_department.parent_id
      , i_corp_contract_id => i_contract_id
      , i_corp_customer_id => i_customer_id
      , i_inst_id          => i_inst_id
      , i_lang             => get_def_lang
      , i_label            => l_department.label
    );

/*    crp_api_employee_pkg.add_employee(
        o_id               =>
      , i_corp_customer_id =>
      , i_corp_contract_id =>
      , i_dep_id           =>
      , i_entity_type      =>
      ,
      */

end create_department;

procedure change_department(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_parent_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_contract_id          in            com_api_type_pkg.t_medium_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_object_id            in            com_api_type_pkg.t_short_id
) is
    l_new_department       iss_api_type_pkg.t_department;
    l_old_department       iss_api_type_pkg.t_department;
begin
    for rec in (
        select parent_id
             , get_text (i_table_name    => 'crp_department'
                       , i_column_name   => 'label'
                       , i_object_id     => a.id
                       , i_lang          => get_user_lang
               ) label
             , corp_customer_id
             , corp_contract_id
             , inst_id
          from crp_department a
         where a.id = i_object_id
    ) loop
        l_old_department.id          := i_object_id;
        l_old_department.parent_id   := rec.parent_id;
        l_old_department.label       := rec.label;
        l_old_department.customer_id := rec.corp_customer_id;
        l_old_department.contract_id := rec.corp_contract_id;
        l_old_department.inst_id     := rec.inst_id;
    end loop;

    app_api_application_pkg.get_element_value(
        i_element_name   => 'DEPARTMENT_NAME'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_new_department.label
    );

    crp_api_department_pkg.modify_department(
        i_id               => l_new_department.id
      , i_parent_id        => l_new_department.parent_id
      , i_corp_customer_id => i_customer_id
      , i_corp_contract_id => i_contract_id
      , i_inst_id          => i_inst_id
      , i_lang             => get_def_lang
      , i_label            => l_new_department.label
    );

end change_department;

procedure remove_department(
   i_appl_data_id          in            com_api_type_pkg.t_long_id
 , i_object_id             in            com_api_type_pkg.t_short_id
) is
    l_id                   com_api_type_pkg.t_short_id;
begin

    -- check new department
    app_api_application_pkg.get_element_value(
        i_element_name   => 'NEW_DEPT'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_id
    );

    if l_id is not null then
        crp_api_department_pkg.remove_department(
            i_id          => i_object_id
          , i_transfer_id => l_id
        );
    else
        com_api_error_pkg.raise_error(
            i_error         => 'TRANSFER_DEPARTMENT'
          , i_env_param1    => i_object_id
            );
    end if;

end;

procedure process_department(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_parent_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
  , i_contract_id          in            com_api_type_pkg.t_medium_id
) is
    l_command              com_api_type_pkg.t_dict_value;
    l_inst_id              com_api_type_pkg.t_inst_id;
    l_root_id              com_api_type_pkg.t_long_id;
    l_count                com_api_type_pkg.t_count := 0;
    l_dep_id               com_api_type_pkg.t_short_id;
begin
    app_api_application_pkg.get_element_value(
        i_element_name   => 'COMMAND'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_command
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'DEPARTMENT'
      , i_parent_id      => i_parent_appl_data_id
      , o_element_value  => l_dep_id
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

    select
        count(id) as cnt
    into
        l_count
    from
        crp_department_vw a
    where
        a.corp_customer_id = i_customer_id
    and
        a.corp_contract_id = i_contract_id
    and
        a.id = l_dep_id;

    if l_count = 0 then -- not found
        if l_command = app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE then
            null;
        elsif l_command in (
            app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
          , app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
        ) then

          com_api_error_pkg.raise_error(
              i_error         => 'DEPARTMENT_NOT_FOUND'
            , i_env_param1    => nvl(l_dep_id, -1)
            );

        elsif l_command in (
            app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
          , app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
          , app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
        ) then

            create_department(
                i_appl_data_id        => i_appl_data_id
              , i_parent_appl_data_id => i_parent_appl_data_id
              , i_contract_id         => i_contract_id
              , i_customer_id         => i_customer_id
              , i_inst_id             => l_inst_id
            );
        else

            create_department(
                i_appl_data_id        => i_appl_data_id
              , i_parent_appl_data_id => i_parent_appl_data_id
              , i_contract_id         => i_contract_id
              , i_customer_id         => i_customer_id
              , i_inst_id             => l_inst_id
            );

        end if;
    else
        if l_command  = app_api_const_pkg.COMMAND_CREATE_OR_PROCEED then
            null;
        elsif l_command = app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT then
            com_api_error_pkg.raise_error(
                i_error => 'DEPARTMENT_ALREADY_EXIST'
              , i_env_param1 => l_dep_id
            );
        elsif l_command in (
            app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
          , app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
        ) then

            change_department(
                i_appl_data_id          => i_appl_data_id
              , i_parent_appl_data_id   => i_parent_appl_data_id
              , i_contract_id           => i_contract_id
              , i_customer_id           => i_customer_id
              , i_inst_id               => l_inst_id
              , i_object_id             => l_dep_id
            );

        elsif l_command in (
            app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
          , app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE
        ) then

            remove_department(
                i_appl_data_id => i_appl_data_id
              , i_object_id    => l_dep_id
            );

        else
            null;
        end if;

    end if;

exception
    when com_api_error_pkg.e_application_error then
        app_api_error_pkg.intercept_error(
            i_appl_data_id => i_appl_data_id
          , i_element_name => 'DEPARTMENT'
        );

end process_department;

end app_api_department_pkg;
/
