create or replace package body svy_api_application_pkg is

procedure add_element(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , i_data_type            in            com_api_type_pkg.t_dict_value
  , i_element_value_c      in            varchar2                            default null
  , i_element_value_n      in            number                              default null
  , i_element_value_d      in            date                                default null
  , i_lang                 in            com_api_type_pkg.t_dict_value       default null
) is
    l_parent_element_id    com_api_type_pkg.t_short_id;
    l_parameter_id         com_api_type_pkg.t_short_id;
    l_element_id           com_api_type_pkg.t_short_id;
    l_serial_number        com_api_type_pkg.t_tiny_id;
    l_max_count            com_api_type_pkg.t_tiny_id;
    l_element_value        com_api_type_pkg.t_full_desc;
    l_data_type            com_api_type_pkg.t_dict_value;
    l_appl_id              com_api_type_pkg.t_long_id;
    l_element_name         com_api_type_pkg.t_name;
    l_split_hash           com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug('svy_api_application_pkg.add_element [' || i_element_name || ']');

    begin
        select p.id
             , p.data_type
          into l_parameter_id
             , l_data_type
          from svy_parameter p
         where p.param_name = upper(i_element_name);
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'ELEMENT_NOT_FOUND'
              , i_env_param1    => upper(i_element_name)
            );
    end;

    if l_data_type != i_data_type then
        com_api_error_pkg.raise_error(
            i_error         => 'INCORRECT_ELEMENT_DATA_TYPE'
          , i_env_param1    => upper(i_element_name)
          , i_env_param2    => i_data_type
          , i_env_param3    => l_data_type
        );
    end if;

    begin
        select e.id
          into l_element_id
          from app_element e
         where e.name = 'PARAMETER_NAME';
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'ELEMENT_NOT_FOUND'
              , i_env_param1    => 'PARAMETER_NAME'
            );
    end;

    begin
        select a.element_id, a.appl_id, b.name
          into l_parent_element_id, l_appl_id, l_element_name
          from app_data a
             , app_element_all_vw b
         where a.id = i_parent_id
           and a.element_id = b.id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'PARENT_ELEMENT_NOT_FOUND'
              , i_env_param1    => upper(i_element_name)
              , i_env_param2    => i_parent_id
            );
    end;

    l_split_hash := com_api_hash_pkg.get_split_hash(app_api_const_pkg.ENTITY_TYPE_APPLICATION, l_appl_id);

    begin
        select max_count
          into l_max_count
          from app_structure a
             , app_application b
         where b.id                = l_appl_id
           and a.appl_type         = b.appl_type
           and a.element_id = l_parent_element_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'IMPOSSIBLE_ATTACH_ELEMENT'
              , i_env_param1    => upper(i_element_name)
              , i_env_param2    => upper(l_element_name)
            );
    end;

    select nvl(max(serial_number), 0)
      into l_serial_number
      from app_data
     where parent_id  = i_parent_id
       and appl_id    = l_appl_id
       and element_id = l_element_id;

    if l_serial_number >= l_max_count then
        com_api_error_pkg.raise_error(
            i_error         => 'ELEMENT_MAX_COUNT_ACHIEVED'
          , i_env_param1    => l_max_count
          , i_env_param2    => upper(i_element_name)
          , i_env_param3    => upper(l_element_name)
        );
    end if;

    if l_data_type = com_api_const_pkg.DATA_TYPE_CHAR then
        l_element_value := i_element_value_c;
    elsif l_data_type = com_api_const_pkg.DATA_TYPE_NUMBER then
        l_element_value := to_char(i_element_value_n, com_api_const_pkg.NUMBER_FORMAT);
    elsif l_data_type = com_api_const_pkg.DATA_TYPE_DATE then
        l_element_value := to_char(i_element_value_d, com_api_const_pkg.DATE_FORMAT);
    end if;

    insert into app_data(
        id
      , appl_id
      , split_hash
      , parent_id
      , element_id
      , element_value
      , serial_number
      , is_auto
      , lang
    ) values (
        app_api_application_pkg.get_appl_data_id(i_appl_id => l_appl_id)
      , l_appl_id
      , l_split_hash
      , i_parent_id
      , l_parameter_id
      , l_element_value
      , l_serial_number + 1
      , com_api_type_pkg.TRUE
      , i_lang
    );

end add_element;

procedure add_element(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , i_element_value        in            com_api_type_pkg.t_full_desc
  , i_lang                 in            com_api_type_pkg.t_dict_value       default null
) is
begin
    add_element(
        i_element_name      => i_element_name
      , i_parent_id         => i_parent_id
      , i_data_type         => com_api_const_pkg.DATA_TYPE_CHAR
      , i_element_value_c   => i_element_value
      , i_lang              => i_lang
    );
end add_element;

procedure add_element(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , i_element_value        in            number
) is
begin
    add_element(
        i_element_name      => i_element_name
      , i_parent_id         => i_parent_id
      , i_data_type         => com_api_const_pkg.DATA_TYPE_NUMBER
      , i_element_value_n   => i_element_value
    );
end add_element;

procedure add_element(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , i_element_value        in            date
) is
begin
    add_element(
        i_element_name      => i_element_name
      , i_parent_id         => i_parent_id
      , i_data_type         => com_api_const_pkg.DATA_TYPE_DATE
      , i_element_value_d   => i_element_value
    );
end add_element;

procedure process_application
is
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_application: ';
    l_root_id              com_api_type_pkg.t_long_id;
    l_appl_id              com_api_type_pkg.t_long_id;
    l_inst_id              com_api_type_pkg.t_inst_id;
    l_questionary_id       com_api_type_pkg.t_long_id;
    l_survey_number        com_api_type_pkg.t_name;
    l_object_number        com_api_type_pkg.t_name;
    l_customer_id          com_api_type_pkg.t_long_id;
    l_survey_rec           svy_api_type_pkg.t_survey_rec;
begin
    trc_log_pkg.debug(LOG_PREFIX || 'START');

    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'APPLICATION'
      , i_parent_id     => null
      , o_appl_data_id  => l_root_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name  => 'APPLICATION_ID'
      , i_parent_id     => l_root_id
      , o_element_value => l_appl_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name  => 'INSTITUTION_ID'
      , i_parent_id     => l_root_id
      , o_element_value => l_inst_id
    );

    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'QUESTIONARY'
      , i_parent_id     => l_root_id
      , o_appl_data_id  => l_questionary_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name  => 'SURVEY_NUMBER'
      , i_parent_id     => l_questionary_id
      , o_element_value => l_survey_number
    );

    app_api_application_pkg.get_element_value(
        i_element_name  => 'OBJECT_NUMBER'
      , i_parent_id     => l_questionary_id
      , o_element_value => l_object_number
    );

    l_survey_rec := svy_api_survey_pkg.get_survey(
                        i_survey_number  => l_survey_number
                      , i_inst_id        => l_inst_id
                      , i_mask_error     => com_api_const_pkg.FALSE
                    );

    if l_survey_rec.status = svy_api_const_pkg.SURVEY_STATUS_CLOSE then
        com_api_error_pkg.raise_error(
            i_error      => 'SURVEY_IS_CLOSED'
          , i_env_param1 => l_survey_number
          , i_env_param2 => l_inst_id
        );
    end if;

    if l_survey_rec.entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER then
        l_customer_id := prd_api_customer_pkg.get_customer_id(
                             i_customer_number => l_object_number
                           , i_inst_id         => l_inst_id
                         );

        if l_customer_id is null then
            com_api_error_pkg.raise_error(
                i_error      => 'SURVEY_BY_NUMBER_OBJECT_NOT_FOUND'
              , i_env_param1 => l_survey_number
              , i_env_param2 => l_inst_id
              , i_env_param3 => l_survey_rec.entity_type
              , i_env_param4 => l_object_number
            );
        end if;

    else
        com_api_error_pkg.raise_error(
            i_error      => 'ENTITY_TYPE_NOT_SUPPORTED'
          , i_env_param1 => l_survey_rec.entity_type
        );

    end if;

    svy_api_questionary_pkg.process_questionary;

    trc_log_pkg.debug(LOG_PREFIX || 'FINISH');

exception
    when com_api_error_pkg.e_application_error then
        app_api_error_pkg.intercept_error(
            i_appl_data_id  => l_root_id
          , i_element_name  => 'APPLICATION'
        );
end process_application;

function get_parent_element_id(
    i_element_id           in            com_api_type_pkg.t_short_id
  , i_app_type             in            com_api_type_pkg.t_dict_value    default  app_api_const_pkg.APPL_TYPE_QUESTIONARY
) return com_api_type_pkg.t_short_id is
    l_element_id        com_api_type_pkg.t_short_id; 
begin
     select s.parent_element_id
       into l_element_id
       from app_structure s
      where s.appl_type  = i_app_type
        and s.element_id = i_element_id;

    return l_element_id;
end get_parent_element_id;

end svy_api_application_pkg;
/
