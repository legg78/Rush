create or replace package body svy_api_questionary_pkg is

procedure add(
    o_id                    out com_api_type_pkg.t_long_id
  , o_seqnum                out com_api_type_pkg.t_tiny_id
  , i_inst_id            in     com_api_type_pkg.t_inst_id
  , i_split_hash         in     com_api_type_pkg.t_tiny_id
  , i_object_id          in     com_api_type_pkg.t_long_id
  , i_survey_id          in     com_api_type_pkg.t_short_id
  , i_questionary_number in     com_api_type_pkg.t_name
  , i_status             in     com_api_type_pkg.t_dict_value
  , i_creation_date      in     date
  , i_closure_date       in     date
) is
begin
    o_id := com_api_id_pkg.get_id(svy_questionary_seq.nextval, com_api_sttl_day_pkg.get_sysdate);
    o_seqnum := 1;

    insert into svy_questionary (
        id
      , seqnum
      , inst_id
      , split_hash
      , object_id
      , survey_id
      , questionary_number
      , status
      , creation_date
      , closure_date
    ) values (
        o_id
      , o_seqnum
      , i_inst_id
      , i_split_hash
      , i_object_id
      , i_survey_id
      , i_questionary_number
      , i_status
      , i_creation_date
      , i_closure_date
    );

    trc_log_pkg.debug(
        i_text        => 'svy_api_questionary_pkg.add Added o_id=' || o_id || ', o_seqnum=' || o_seqnum
    );
end add;

procedure modify(
    i_id                 in     com_api_type_pkg.t_long_id
  , io_seqnum            in out com_api_type_pkg.t_tiny_id
  , i_inst_id            in     com_api_type_pkg.t_inst_id
  , i_split_hash         in     com_api_type_pkg.t_tiny_id
  , i_object_id          in     com_api_type_pkg.t_long_id
  , i_survey_id          in     com_api_type_pkg.t_short_id
  , i_questionary_number in     com_api_type_pkg.t_name
  , i_status             in     com_api_type_pkg.t_dict_value
  , i_closure_date       in     date
) is
    l_seqnum                    com_api_type_pkg.t_tiny_id;
begin
    select seqnum
      into l_seqnum
      from svy_questionary
     where id = i_id;

    if l_seqnum > io_seqnum then
        com_api_error_pkg.raise_error(
            i_error => 'INCONSISTENT_DATA'
        );
    end if;

    io_seqnum := io_seqnum + 1;

    update svy_questionary
       set inst_id            = i_inst_id
         , split_hash         = i_split_hash
         , object_id          = i_object_id
         , survey_id          = i_survey_id
         , questionary_number = i_questionary_number
         , status             = i_status
         , closure_date       = nvl(i_closure_date, closure_date)
     where id                 = i_id;

    trc_log_pkg.debug(
        i_text        => 'svy_api_questionary_pkg.modify Modified i_id=' || i_id || ', io_seqnum=' || io_seqnum
    );
end modify;

procedure remove(
    i_id                 in     com_api_type_pkg.t_long_id
  , i_seqnum             in     com_api_type_pkg.t_tiny_id
) is
begin
    update svy_questionary
       set seqnum = i_seqnum
     where id     = i_id;

    delete svy_questionary
     where id = i_id;

    trc_log_pkg.debug(
        i_text        => 'svy_api_questionary_pkg.remove Removed i_id=' || i_id || ', i_seqnum=' || i_seqnum
    );
end remove;

function get_questionary(
    i_id                 in com_api_type_pkg.t_long_id
  , i_mask_error         in com_api_type_pkg.t_boolean   default com_api_const_pkg.FALSE
) return svy_api_type_pkg.t_questionary_rec is
    l_questionary_rec       svy_api_type_pkg.t_questionary_rec;
begin
    select q.id
         , q.seqnum
         , q.inst_id
         , q.split_hash
         , q.object_id
         , q.survey_id
         , q.questionary_number
         , q.status
         , q.creation_date
         , q.closure_date
      into l_questionary_rec
      from svy_questionary q
     where q.id = i_id;

    return l_questionary_rec;
exception
    when no_data_found then
        if nvl(i_mask_error, com_api_const_pkg.FALSE) = com_api_type_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error      => 'QUESTIONARY_BY_NUMBER_NOT_FOUND'
              , i_env_param1 => i_id
            );
        else
           trc_log_pkg.debug(
               i_text        => 'Questionary not found by ID [#1]' 
             , i_env_param1  => i_id
           );
           return l_questionary_rec;
        end if;
end get_questionary;

function get_questionary(
    i_questionary_number in com_api_type_pkg.t_name
  , i_mask_error         in com_api_type_pkg.t_boolean   default com_api_const_pkg.FALSE
) return svy_api_type_pkg.t_questionary_rec is
    l_questionary_rec       svy_api_type_pkg.t_questionary_rec;
begin
    select q.id
         , q.seqnum
         , q.inst_id
         , q.split_hash
         , q.object_id
         , q.survey_id
         , q.questionary_number
         , q.status
         , q.creation_date
         , q.closure_date
      into l_questionary_rec
      from svy_questionary q
     where q.questionary_number = i_questionary_number;

    return l_questionary_rec;
exception
    when no_data_found then
        if nvl(i_mask_error, com_api_const_pkg.FALSE) = com_api_type_pkg.FALSE then
            com_api_error_pkg.raise_error(
                i_error      => 'QUESTIONARY_BY_NUMBER_NOT_FOUND'
              , i_env_param1 => i_questionary_number
            );
        else
           trc_log_pkg.debug(
               i_text        => 'Questionary not found by number [#1]' 
             , i_env_param1  => i_questionary_number
           );
           return l_questionary_rec;
        end if;
end get_questionary;

procedure process_questionary
is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_questionary: ';
    l_survey_rec                svy_api_type_pkg.t_survey_rec;
    l_root_id                   com_api_type_pkg.t_long_id;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_app_questionary_id        com_api_type_pkg.t_long_id;
    l_command                   com_api_type_pkg.t_dict_value;
    l_survey_number             com_api_type_pkg.t_name;
    l_object_number             com_api_type_pkg.t_name;
    l_questionary_number        com_api_type_pkg.t_name;
    l_status                    com_api_type_pkg.t_dict_value;
    l_object_id                 com_api_type_pkg.t_long_id;
    l_entity_type               com_api_type_pkg.t_dict_value;
    l_closure_date              date;
    l_param_tab                 com_api_type_pkg.t_param_tab;
    l_seqnum                    com_api_type_pkg.t_tiny_id;
    l_split_hash                com_api_type_pkg.t_tiny_id;
    l_questionary_rec           svy_api_type_pkg.t_questionary_rec;
begin
    trc_log_pkg.debug(LOG_PREFIX || 'START');

    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'APPLICATION'
      , i_parent_id      => null
      , o_appl_data_id   => l_root_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name  => 'INSTITUTION_ID'
      , i_parent_id     => l_root_id
      , o_element_value => l_inst_id
    );

    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'QUESTIONARY'
      , i_parent_id     => l_root_id
      , o_appl_data_id  => l_app_questionary_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name  => 'SURVEY_NUMBER'
      , i_parent_id     => l_app_questionary_id
      , o_element_value => l_survey_number
    );

    if l_survey_number is null then
        com_api_error_pkg.raise_error(
            i_error      => 'SURVEY_BY_NUMBER_NOT_FOUND'
          , i_env_param1 => l_survey_number
          , i_env_param2 => l_inst_id
        );
    end if;

    l_survey_rec := svy_api_survey_pkg.get_survey(
                        i_survey_number          => l_survey_number
                      , i_inst_id                => l_inst_id
                      , i_mask_error             => com_api_const_pkg.TRUE
                    );

    trc_log_pkg.debug(LOG_PREFIX || 'l_survey_rec.id [' || l_survey_rec.id || ']');

    app_api_application_pkg.get_element_value(
        i_element_name  => 'OBJECT_NUMBER'
      , i_parent_id     => l_app_questionary_id
      , o_element_value => l_object_number
    );

    if l_survey_rec.entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER then
        l_object_id := prd_api_customer_pkg.get_customer_id(
                           i_customer_number => l_object_number
                         , i_inst_id         => l_inst_id
                       );
        l_entity_type := l_survey_rec.entity_type;

    else
        com_api_error_pkg.raise_error(
            i_error      => 'ENTITY_TYPE_NOT_SUPPORTED'
          , i_env_param1 => l_survey_rec.entity_type
        );

    end if;

    trc_log_pkg.debug(LOG_PREFIX || 'l_object_id [' || l_object_id || ']');

    app_api_application_pkg.get_element_value(
        i_element_name   => 'COMMAND'
      , i_parent_id      => l_app_questionary_id
      , o_element_value  => l_command
    );

    trc_log_pkg.debug(LOG_PREFIX || 'command [' || l_command || ']');

    app_api_application_pkg.get_element_value(
        i_element_name  => 'QUESTIONARY_NUMBER'
      , i_parent_id     => l_app_questionary_id
      , o_element_value => l_questionary_number
    );

    app_api_application_pkg.get_element_value(
        i_element_name  => 'STATUS'
      , i_parent_id     => l_app_questionary_id
      , o_element_value => l_status
    );

    l_split_hash := com_api_hash_pkg.get_split_hash(svy_api_const_pkg.ENTITY_TYPE_SURVEY, l_survey_rec.id);

    if l_questionary_number is not null then
        l_questionary_rec := get_questionary(
                                 i_questionary_number  => l_questionary_number
                               , i_mask_error          => com_api_const_pkg.FALSE
                             );
    end if;

    if l_command in (
              app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
          ) and l_questionary_rec.id is not null then
        remove(
            i_id     => l_questionary_rec.id
          , i_seqnum => l_seqnum
        );

    elsif l_command in (
              app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
            , app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
          ) and l_questionary_rec.id is not null then

        modify(
            i_id                 => l_questionary_rec.id
          , io_seqnum            => l_seqnum
          , i_inst_id            => l_inst_id
          , i_split_hash         => l_split_hash
          , i_object_id          => l_object_id
          , i_survey_id          => l_survey_rec.id
          , i_questionary_number => l_questionary_number
          , i_status             => l_status
          , i_closure_date       => l_closure_date
        );

    elsif l_command in (
           app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
         , app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
         , app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
       ) and l_questionary_number is null then

        add(
            o_id                 => l_questionary_rec.id
          , o_seqnum             => l_seqnum
          , i_inst_id            => l_inst_id
          , i_split_hash         => l_split_hash
          , i_object_id          => l_object_id
          , i_survey_id          => l_survey_rec.id
          , i_questionary_number => l_questionary_number
          , i_status             => l_status
          , i_creation_date      => com_api_sttl_day_pkg.get_sysdate
          , i_closure_date       => l_closure_date
        );

        l_param_tab('INST_ID')        := l_inst_id;
        l_param_tab('SURVEY_NUMBER')  := l_survey_number;
        l_param_tab('QUESTIONARY_ID') := l_questionary_rec.id;
        l_param_tab('OBJECT_NUMBER')  := l_object_number;
        l_param_tab('ENTITY_TYPE')    := l_entity_type;

        l_questionary_number := rul_api_name_pkg.get_name(
                                    i_inst_id      => l_inst_id
                                  , i_entity_type  => svy_api_const_pkg.ENTITY_TYPE_QUESTIONARY
                                  , i_param_tab    => l_param_tab
                                );

        modify(
            i_id                 => l_questionary_rec.id
          , io_seqnum            => l_seqnum
          , i_inst_id            => l_inst_id
          , i_split_hash         => l_split_hash
          , i_object_id          => l_object_id
          , i_survey_id          => l_survey_rec.id
          , i_questionary_number => l_questionary_number
          , i_status             => l_status
          , i_closure_date       => l_closure_date
        );

        app_api_application_pkg.add_element(
            i_element_name       => 'QUESTIONARY_NUMBER'
          , i_parent_id          => l_app_questionary_id
          , i_element_value      => l_questionary_number
        );

    else
        trc_log_pkg.debug(LOG_PREFIX || 'command has been ignored');

    end if;

    process_parameters;

    trc_log_pkg.debug(LOG_PREFIX || 'FINISH');

end process_questionary;

procedure process_system_parameters(
    i_inst_id                     in    com_api_type_pkg.t_inst_id
  , i_questionary_id              in    com_api_type_pkg.t_long_id
  , i_object_id                   in    com_api_type_pkg.t_long_id
  , i_entity_type                 in    com_api_type_pkg.t_dict_value
  , i_ref_object_id               in    com_api_type_pkg.t_long_id
  , i_ref_entity_type             in    com_api_type_pkg.t_dict_value
)
is
    LOG_PREFIX                 constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_system_parameters: ';
    l_params_customer                   com_api_type_pkg.t_param_tab;
    l_params_address                    com_api_type_pkg.t_param_tab;
    l_params_person                     com_api_type_pkg.t_param_tab;
    l_params_contact                    com_api_type_pkg.t_param_tab;
    l_customer_rec                      prd_api_type_pkg.t_customer;
    l_address_rec                       com_api_type_pkg.t_address_rec;
    l_person_rec                        com_api_type_pkg.t_person;
    l_contact_data_rec                  com_api_type_pkg.t_contact_data_rec;
    l_address_object_id                 com_api_type_pkg.t_long_id;
    l_contact_object_id                 com_api_type_pkg.t_long_id;
    l_index                             com_api_type_pkg.t_oracle_name;
begin
    trc_log_pkg.debug(LOG_PREFIX || 'START: [' || i_inst_id || '] [' || i_object_id || '] [' || i_entity_type || '] [' || i_ref_object_id || '] [' || i_ref_entity_type || ']');

    if i_entity_type = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER then
        l_customer_rec := prd_api_customer_pkg.get_customer_data(
                              i_customer_id  => i_object_id
                            , i_mask_error   => com_api_const_pkg.TRUE
                          );
    else
        com_api_error_pkg.raise_error(
            i_error      => 'ENTITY_TYPE_NOT_SUPPORTED'
          , i_env_param1 => i_entity_type
        );
    end if;

    for r in (
        select p.table_name
             , p.param_name
             , v.param_value
             , p.data_type
          from svy_parameter p
             , svy_qstn_parameter_value v
         where p.is_system_param = 1
           and p.id              = v.param_id
           and v.questionary_id  = i_questionary_id
    ) loop
        if    r.table_name = 'PRD_CUSTOMER' then
            rul_api_param_pkg.set_param(
                i_name     => r.param_name
              , io_params  => l_params_customer
              , i_value    => r.param_value
            );

        elsif r.table_name = 'COM_ADDRESS' then
            rul_api_param_pkg.set_param(
                i_name     => r.param_name
              , io_params  => l_params_address
              , i_value    => r.param_value
            );

        elsif r.table_name = 'COM_PERSON' then
            rul_api_param_pkg.set_param(
                i_name     => r.param_name
              , io_params  => l_params_person
              , i_value    => r.param_value
            );

        elsif r.table_name = 'COM_CONTACT' then
            rul_api_param_pkg.set_param(
                i_name     => r.param_name
              , io_params  => l_params_contact
              , i_value    => r.param_value
            );

        end if;
    end loop;

    if l_params_customer.count > 0 and l_customer_rec.id is not null then
        l_customer_rec.category           := rul_api_param_pkg.get_param_char(
                                                 i_name            => 'CATEGORY'
                                               , io_params         => l_params_customer
                                               , i_mask_error      => com_api_type_pkg.TRUE
                                               , i_error_value     => l_customer_rec.category
                                             );
        l_customer_rec.relation            := rul_api_param_pkg.get_param_char(
                                                  i_name            => 'RELATION'
                                                , io_params         => l_params_customer
                                                , i_mask_error      => com_api_type_pkg.TRUE
                                                , i_error_value     => l_customer_rec.relation
                                              );
        l_customer_rec.resident            := rul_api_param_pkg.get_param_num(
                                                  i_name            => 'RESIDENT'
                                                , io_params         => l_params_customer
                                                , i_mask_error      => com_api_type_pkg.TRUE
                                                , i_error_value     => l_customer_rec.resident
                                              );
        l_customer_rec.nationality         := rul_api_param_pkg.get_param_char(
                                                  i_name            => 'NATIONALITY'
                                                , io_params         => l_params_customer
                                                , i_mask_error      => com_api_type_pkg.TRUE
                                                , i_error_value     => l_customer_rec.nationality
                                              );
        l_customer_rec.credit_rating       := rul_api_param_pkg.get_param_char(
                                                  i_name            => 'CREDIT_RATING'
                                                , io_params         => l_params_customer
                                                , i_mask_error      => com_api_type_pkg.TRUE
                                                , i_error_value     => l_customer_rec.credit_rating
                                              );
        l_customer_rec.employment_status   := rul_api_param_pkg.get_param_char(
                                                  i_name            => 'EMPLOYMENT_STATUS'
                                                , io_params         => l_params_customer
                                                , i_mask_error      => com_api_type_pkg.TRUE
                                                , i_error_value     => l_customer_rec.employment_status
                                              );
        l_customer_rec.employment_period   := rul_api_param_pkg.get_param_char(
                                                  i_name            => 'EMPLOYMENT_PERIOD'
                                                , io_params         => l_params_customer
                                                , i_mask_error      => com_api_type_pkg.TRUE
                                                , i_error_value     => l_customer_rec.employment_period
                                              );
        l_customer_rec.residence_type      := rul_api_param_pkg.get_param_char(
                                                  i_name            => 'RESIDENCE_TYPE'
                                                , io_params         => l_params_customer
                                                , i_mask_error      => com_api_type_pkg.TRUE
                                                , i_error_value     => l_customer_rec.residence_type
                                              );
        l_customer_rec.marital_status_date := rul_api_param_pkg.get_param_date(
                                                  i_name            => 'MARITAL_STATUS_DATE'
                                                , io_params         => l_params_customer
                                                , i_mask_error      => com_api_type_pkg.TRUE
                                                , i_error_value     => l_customer_rec.marital_status_date
                                              );
        l_customer_rec.income_range        := rul_api_param_pkg.get_param_char(
                                                  i_name            => 'INCOME_RANGE'
                                                , io_params         => l_params_customer
                                                , i_mask_error      => com_api_type_pkg.TRUE
                                                , i_error_value     => l_customer_rec.income_range
                                              );
        l_customer_rec.number_of_children  := rul_api_param_pkg.get_param_char(
                                                  i_name            => 'NUMBER_OF_CHILDREN'
                                                , io_params         => l_params_customer
                                                , i_mask_error      => com_api_type_pkg.TRUE
                                                , i_error_value     => l_customer_rec.number_of_children
                                              );
        l_customer_rec.marital_status      := rul_api_param_pkg.get_param_char(
                                                  i_name            => 'MARITAL_STATUS'
                                                , io_params         => l_params_customer
                                                , i_mask_error      => com_api_type_pkg.TRUE
                                                , i_error_value     => l_customer_rec.marital_status
                                              );

        l_customer_rec.inst_id := i_inst_id;

        prd_api_customer_pkg.modify_customer(
             i_id                   => l_customer_rec.id
           , io_seqnum              => l_customer_rec.seqnum
           , i_object_id            => l_customer_rec.object_id
           , i_customer_number      => l_customer_rec.customer_number
           , i_category             => l_customer_rec.category
           , i_relation             => l_customer_rec.relation
           , i_resident             => l_customer_rec.resident
           , i_nationality          => l_customer_rec.nationality
           , i_credit_rating        => l_customer_rec.credit_rating
           , i_money_laundry_risk   => l_customer_rec.money_laundry_risk
           , i_money_laundry_reason => l_customer_rec.money_laundry_reason
           , i_employment_status    => l_customer_rec.employment_status
           , i_employment_period    => l_customer_rec.employment_period
           , i_residence_type       => l_customer_rec.residence_type
           , i_marital_status       => l_customer_rec.marital_status
           , i_marital_status_date  => l_customer_rec.marital_status_date
           , i_income_range         => l_customer_rec.income_range
           , i_number_of_children   => l_customer_rec.number_of_children
        );
    end if;

    if l_params_address.count > 0 then
        l_address_rec := com_api_address_pkg.get_address(
                             i_object_id    => i_object_id
                           , i_entity_type  => i_entity_type
                           , i_address_type => com_api_const_pkg.ADDRESS_TYPE_HOME
                           , i_mask_error   => com_api_const_pkg.TRUE
                         );

        trc_log_pkg.debug('Result of Address searching: id=' || l_address_rec.id);

        l_address_rec.country     := rul_api_param_pkg.get_param_char(
                                         i_name            => 'COUNTRY'
                                       , io_params         => l_params_address
                                       , i_mask_error      => com_api_type_pkg.TRUE
                                       , i_error_value     => l_address_rec.country
                                     );
        l_address_rec.region      := rul_api_param_pkg.get_param_char(
                                         i_name            => 'REGION'
                                       , io_params         => l_params_address
                                       , i_mask_error      => com_api_type_pkg.TRUE
                                       , i_error_value     => l_address_rec.region
                                     );
        l_address_rec.city        := rul_api_param_pkg.get_param_char(
                                         i_name            => 'CITY'
                                       , io_params         => l_params_address
                                       , i_mask_error      => com_api_type_pkg.TRUE
                                       , i_error_value     => l_address_rec.city
                                     );
        l_address_rec.street      := rul_api_param_pkg.get_param_char(
                                         i_name            => 'STREET'
                                       , io_params         => l_params_address
                                       , i_mask_error      => com_api_type_pkg.TRUE
                                       , i_error_value     => l_address_rec.street
                                     );
        l_address_rec.house       := rul_api_param_pkg.get_param_char(
                                         i_name            => 'HOUSE'
                                       , io_params         => l_params_address
                                       , i_mask_error      => com_api_type_pkg.TRUE
                                       , i_error_value     => l_address_rec.house
                                     );
        l_address_rec.postal_code := rul_api_param_pkg.get_param_char(
                                       i_name              => 'POSTAL_CODE'
                                     , io_params           => l_params_address
                                     , i_mask_error        => com_api_type_pkg.TRUE
                                     , i_error_value       => l_address_rec.postal_code
                                   );
        l_address_rec.region_code := rul_api_param_pkg.get_param_char(
                                         i_name            => 'REGION_CODE'
                                       , io_params         => l_params_address
                                       , i_mask_error      => com_api_type_pkg.TRUE
                                       , i_error_value     => l_address_rec.region_code
                                     );

        l_address_rec.inst_id := i_inst_id;

        if l_address_rec.id is null then
            com_api_address_pkg.add_address(
                io_address_id  => l_address_rec.id
              , i_lang         => l_address_rec.lang
              , i_country      => l_address_rec.country
              , i_region       => l_address_rec.region
              , i_city         => l_address_rec.city
              , i_street       => l_address_rec.street
              , i_house        => l_address_rec.house
              , i_apartment    => l_address_rec.apartment
              , i_postal_code  => l_address_rec.postal_code
              , i_region_code  => l_address_rec.region_code
              , i_inst_id      => l_address_rec.inst_id
              , i_latitude     => l_address_rec.latitude
              , i_longitude    => l_address_rec.longitude
              , i_place_code   => l_address_rec.place_code
            );
            com_api_address_pkg.add_address_object(
                i_address_id        => l_address_rec.id
              , i_address_type      => com_api_const_pkg.ADDRESS_TYPE_HOME
              , i_entity_type       => i_entity_type
              , i_object_id         => i_object_id
              , o_address_object_id => l_address_object_id
            );
        else
            com_api_address_pkg.modify_address(
                i_address_id  => l_address_rec.id
              , i_country     => l_address_rec.country
              , i_region      => l_address_rec.region
              , i_city        => l_address_rec.city
              , i_street      => l_address_rec.street
              , i_house       => l_address_rec.house
              , i_apartment   => l_address_rec.apartment
              , i_postal_code => l_address_rec.postal_code
              , i_region_code => l_address_rec.region_code
              , i_latitude    => l_address_rec.latitude
              , i_longitude   => l_address_rec.longitude
              , i_lang        => l_address_rec.lang
              , i_inst_id     => l_address_rec.inst_id
              , i_place_code  => l_address_rec.place_code
            );
        end if;
    end if;

    if i_ref_entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON and l_params_person.count > 0 then
        l_person_rec := com_api_person_pkg.get_person(
                            i_person_id  => i_ref_object_id
                          , i_mask_error => com_api_type_pkg.FALSE
                        );

        if l_person_rec.id is not null then
            trc_log_pkg.debug('Result of Person searching: id=' || l_person_rec.id);

            l_person_rec.first_name     := rul_api_param_pkg.get_param_char(
                                               i_name            => 'FIRST_NAME'
                                             , io_params         => l_params_person
                                             , i_mask_error      => com_api_type_pkg.TRUE
                                             , i_error_value     => l_person_rec.first_name
                                           );
            l_person_rec.second_name    := rul_api_param_pkg.get_param_char(
                                               i_name            => 'SECOND_NAME'
                                             , io_params         => l_params_person
                                             , i_mask_error      => com_api_type_pkg.TRUE
                                             , i_error_value     => l_person_rec.second_name
                                           );
            l_person_rec.surname        := rul_api_param_pkg.get_param_char(
                                               i_name            => 'SURNAME'
                                             , io_params         => l_params_person
                                             , i_mask_error      => com_api_type_pkg.TRUE
                                             , i_error_value     => l_person_rec.surname
                                           );
            l_person_rec.gender         := rul_api_param_pkg.get_param_char(
                                               i_name            => 'GENDER'
                                             , io_params         => l_params_person
                                             , i_mask_error      => com_api_type_pkg.TRUE
                                             , i_error_value     => l_person_rec.gender
                                           );
            l_person_rec.birthday       := rul_api_param_pkg.get_param_date(
                                               i_name            => 'BIRTHDAY'
                                             , io_params         => l_params_person
                                             , i_mask_error      => com_api_type_pkg.TRUE
                                             , i_error_value     => l_person_rec.birthday
                                           );
            l_person_rec.place_of_birth := rul_api_param_pkg.get_param_char(
                                               i_name            => 'PLACE_OF_BIRTH'
                                             , io_params         => l_params_person
                                             , i_mask_error      => com_api_type_pkg.TRUE
                                             , i_error_value     => l_person_rec.place_of_birth
                                           );

            l_person_rec.inst_id := i_inst_id;

            com_api_person_pkg.modify_person(
                i_person_id      => l_person_rec.id
              , i_person_title   => l_person_rec.person_title
              , i_first_name     => l_person_rec.first_name
              , i_second_name    => l_person_rec.second_name
              , i_surname        => l_person_rec.surname
              , i_suffix         => l_person_rec.suffix
              , i_gender         => l_person_rec.gender
              , i_birthday       => l_person_rec.birthday
              , i_place_of_birth => l_person_rec.place_of_birth
              , i_seqnum         => null
              , i_lang           => l_person_rec.lang
              , i_inst_id        => l_person_rec.inst_id
            );
        end if;
    end if;

    if i_ref_entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON and l_params_contact.count > 0 then
        l_index := l_params_contact.first;
        while l_index is not null
        loop
            if l_index = 'COMMUN_ADDRESS' then
                l_contact_data_rec := com_api_contact_pkg.get_contact_data_rec(
                                          i_object_id     => i_object_id
                                        , i_entity_type   => i_entity_type
                                        , i_contact_type  => com_api_const_pkg.CONTACT_TYPE_NOTIFICATION
                                        , i_mask_error    => com_api_const_pkg.TRUE
                                      );
                l_contact_data_rec.commun_address := rul_api_param_pkg.get_param_char(
                                                         i_name            => 'COMMUN_ADDRESS'
                                                       , io_params         => l_params_contact
                                                       , i_mask_error      => com_api_type_pkg.TRUE
                                                       , i_error_value     => l_contact_data_rec.commun_address
                                                     );
            end if;
            l_index := l_params_contact.next(l_index);
        end loop;

        trc_log_pkg.debug('Result of Contact searching: id=' || l_contact_data_rec.id);

        if l_contact_data_rec.contact_id is null then
            com_api_contact_pkg.add_contact(
                o_id             => l_contact_data_rec.contact_id
              , i_preferred_lang => com_ui_user_env_pkg.get_user_lang
              , i_job_title      => null
              , i_person_id      => i_ref_object_id
              , i_inst_id        => i_inst_id
            );
            com_api_contact_pkg.add_contact_object(
                i_contact_id        => l_contact_data_rec.contact_id
              , i_entity_type       => i_entity_type
              , i_contact_type      => com_api_const_pkg.CONTACT_TYPE_NOTIFICATION
              , i_object_id         => i_object_id
              , o_contact_object_id => l_contact_object_id
            );
            com_api_contact_pkg.add_contact_data(
                i_contact_id     => l_contact_data_rec.contact_id
              , i_commun_method  => nvl(l_contact_data_rec.commun_method, com_api_const_pkg.COMMUNICATION_METHOD_MOBILE)
              , i_commun_address => l_contact_data_rec.commun_address
              , i_start_date     => l_contact_data_rec.start_date
              , i_end_date       => l_contact_data_rec.end_date
            );
        else
            com_api_contact_pkg.modify_contact_data(
                i_contact_id     => l_contact_data_rec.contact_id
              , i_commun_method  => nvl(l_contact_data_rec.commun_method, com_api_const_pkg.COMMUNICATION_METHOD_MOBILE)
              , i_commun_address => l_contact_data_rec.commun_address
              , i_start_date     => l_contact_data_rec.start_date
              , i_end_date       => l_contact_data_rec.end_date
            );
        end if;
    end if;

    trc_log_pkg.debug(LOG_PREFIX || 'FINISH');

end process_system_parameters;

procedure process_parameters
is
    LOG_PREFIX                 constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_parameters: ';
    l_root_id                           com_api_type_pkg.t_long_id;
    l_inst_id                           com_api_type_pkg.t_inst_id;
    l_app_questionary_id                com_api_type_pkg.t_long_id;
    l_object_id                         com_api_type_pkg.t_long_id;
    l_survey_rec                        svy_api_type_pkg.t_survey_rec;
    l_entity_type                       com_api_type_pkg.t_dict_value;
    l_object_number                     com_api_type_pkg.t_name;
    l_ref_object_id                     com_api_type_pkg.t_long_id;
    l_ref_entity_type                   com_api_type_pkg.t_dict_value;
    l_questionary_number                com_api_type_pkg.t_name;
    l_questionary_rec                   svy_api_type_pkg.t_questionary_rec;

    l_id_tab                            com_api_type_pkg.t_number_tab;
    l_parameter_id                      com_api_type_pkg.t_long_id;
    l_parameter_data_type               com_api_type_pkg.t_dict_value;
    l_parameter_name                    com_api_type_pkg.t_name;
    l_parameter_value                   com_api_type_pkg.t_name;
    l_seq_number                        com_api_type_pkg.t_tiny_id;
    l_param_name_id                     com_api_type_pkg.t_long_id;
    l_param_value_id                    com_api_type_pkg.t_long_id;
    l_seq_number_id                     com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug(LOG_PREFIX || 'START');

    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'APPLICATION'
      , i_parent_id      => null
      , o_appl_data_id   => l_root_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name  => 'INSTITUTION_ID'
      , i_parent_id     => l_root_id
      , o_element_value => l_inst_id
    );

    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'QUESTIONARY'
      , i_parent_id     => l_root_id
      , o_appl_data_id  => l_app_questionary_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name  => 'OBJECT_NUMBER'
      , i_parent_id     => l_app_questionary_id
      , o_element_value => l_object_number
    );

    app_api_application_pkg.get_element_value(
        i_element_name  => 'QUESTIONARY_NUMBER'
      , i_parent_id     => l_app_questionary_id
      , o_element_value => l_questionary_number
    );

    l_questionary_rec := get_questionary(
                             i_questionary_number  => l_questionary_number
                           , i_mask_error          => com_api_const_pkg.FALSE
                         );

    trc_log_pkg.debug('Questionary found: id=' || l_questionary_rec.id);

    l_survey_rec := svy_api_survey_pkg.get_survey(
                        i_id          => l_questionary_rec.survey_id
                      , i_mask_error  => com_api_const_pkg.FALSE
                    );

    l_entity_type := l_survey_rec.entity_type;

    if l_entity_type = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER then
        l_object_id    := prd_api_customer_pkg.get_customer_id(
                              i_customer_number => l_object_number
                          );
        prd_api_customer_pkg.get_customer_object(
            i_customer_id => l_object_id
          , o_object_id   => l_ref_object_id
          , o_entity_type => l_ref_entity_type
          , i_mask_error  => com_api_type_pkg.TRUE
        );

    else
        com_api_error_pkg.raise_error(
            i_error      => 'ENTITY_TYPE_NOT_SUPPORTED'
          , i_env_param1 => l_entity_type
        );

    end if;

    trc_log_pkg.debug('Object found: id=' || l_object_id || ', entity_type=' || l_entity_type);

    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'QUESTIONARY_PARAMETER'
      , i_parent_id     => l_app_questionary_id
      , o_appl_data_id  => l_id_tab
    );

    for i in 1..nvl(l_id_tab.count, 0) loop
        app_api_application_pkg.get_appl_data_id(
            i_element_name  => 'PARAMETER_NAME'
          , i_parent_id     => l_id_tab(i)
          , o_appl_data_id  => l_param_name_id
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'PARAMETER_NAME'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_parameter_name
        );

        app_api_application_pkg.get_appl_data_id(
            i_element_name  => 'PARAMETER_VALUE'
          , i_parent_id     => l_id_tab(i)
          , o_appl_data_id  => l_param_value_id
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'PARAMETER_VALUE'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_parameter_value
        );

        app_api_application_pkg.get_appl_data_id(
            i_element_name  => 'SEQUENCE_NUMBER'
          , i_parent_id     => l_id_tab(i)
          , o_appl_data_id  => l_seq_number_id
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'SEQUENCE_NUMBER'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_seq_number
        );

        begin
            select p.id
                 , p.data_type
              into l_parameter_id
                 , l_parameter_data_type
              from svy_parameter p
                 , svy_parameter_entity e
             where upper(param_name) = upper(l_parameter_name)
               and p.id              = e.param_id
               and entity_type       = l_entity_type;
        exception
            when others then
                l_parameter_id := null;
        end;

        trc_log_pkg.debug('before processing: parameter_name[' || l_parameter_name || '] parameter_value[' || l_parameter_value || ']' || ', parameter_data_type['|| l_parameter_data_type || '], sequence_number[' || l_seq_number || ']');

        if l_parameter_id is null then
            com_api_error_pkg.raise_error(
                i_error         => 'PARAMETER_NOT_FOUND'
              , i_env_param1    => l_parameter_name
            );
        else
            case l_parameter_data_type
                when com_api_const_pkg.DATA_TYPE_NUMBER then
                    svy_api_application_pkg.add_element(
                        i_element_name      => l_parameter_name
                      , i_parent_id         => l_app_questionary_id
                      , i_element_value     => to_number(l_parameter_value)
                    );             
                    svy_api_parameter_value_pkg.set_parameter_value(
                        i_param_name        => upper(l_parameter_name)
                      , i_entity_type       => l_entity_type
                      , i_questionary_id    => l_questionary_rec.id
                      , i_seq_number        => l_seq_number
                      , i_param_value       => to_number(l_parameter_value)
                    );
                when com_api_const_pkg.DATA_TYPE_DATE then
                    svy_api_application_pkg.add_element(
                        i_element_name      => l_parameter_name
                      , i_parent_id         => l_app_questionary_id
                      , i_element_value     => to_date(l_parameter_value, com_api_const_pkg.XML_DATE_FORMAT)
                    );
                    svy_api_parameter_value_pkg.set_parameter_value(
                        i_param_name        => upper(l_parameter_name)
                      , i_entity_type       => l_entity_type
                      , i_questionary_id    => l_questionary_rec.id
                      , i_seq_number        => l_seq_number
                      , i_param_value       => to_date(l_parameter_value, com_api_const_pkg.XML_DATE_FORMAT)
                    );
                else
                    svy_api_application_pkg.add_element(
                        i_element_name      => l_parameter_name
                      , i_parent_id         => l_app_questionary_id
                      , i_element_value     => l_parameter_value
                    );
                    svy_api_parameter_value_pkg.set_parameter_value(
                        i_param_name        => upper(l_parameter_name)
                      , i_entity_type       => l_entity_type
                      , i_questionary_id    => l_questionary_rec.id
                      , i_seq_number        => l_seq_number
                      , i_param_value       => l_parameter_value
                    );
            end case;

            app_api_application_pkg.remove_element(i_appl_data_id => l_id_tab(i));
            app_api_application_pkg.remove_element(i_appl_data_id => l_param_name_id);
            app_api_application_pkg.remove_element(i_appl_data_id => l_param_value_id);
            app_api_application_pkg.remove_element(i_appl_data_id => l_seq_number_id);

        end if;

        trc_log_pkg.debug('after processing: parameter_name[' || l_parameter_name || '] parameter_value[' || l_parameter_value || '] l_seq_number[' || l_seq_number || ']');
    end loop;

    if l_entity_type = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER then
        prd_api_customer_pkg.set_last_modify(
            i_customer_id => l_object_id
        );
    end if;

    process_system_parameters(
        i_inst_id           => l_inst_id
      , i_questionary_id    => l_questionary_rec.id
      , i_object_id         => l_object_id
      , i_entity_type       => l_entity_type
      , i_ref_object_id     => l_ref_object_id
      , i_ref_entity_type   => l_ref_entity_type
    );

    trc_log_pkg.debug(LOG_PREFIX || 'FINISH');

end process_parameters;

end svy_api_questionary_pkg;
/
