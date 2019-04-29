create or replace package body cst_api_files_pkg is

procedure load_sms_services_file(
    i_inst_id           in com_api_type_pkg.t_inst_id
) is
    l_sms_service_tab         cst_api_files_type_pkg.t_sms_service_tab;
    i                         com_api_type_pkg.t_count := 1;
    l_card_id                 com_api_type_pkg.t_medium_id;
    l_contract_id             com_api_type_pkg.t_medium_id;
    l_params                  com_api_type_pkg.t_param_tab;
    l_contact                 app_api_type_pkg.t_contact;
    l_cardholder_id           com_api_type_pkg.t_medium_id;
    l_contact_object_id       com_api_type_pkg.t_long_id;
    l_attribute_value_id      com_api_type_pkg.t_medium_id;
    l_count                   com_api_type_pkg.t_count := 0;
    l_excepted_count          com_api_type_pkg.t_count := 0;
    l_processed_count         com_api_type_pkg.t_count := 0;
    l_current_count           com_api_type_pkg.t_count := 0;
    l_raw                     com_api_type_pkg.t_raw_data;

    function get_sms_service_by_card(
        i_card_id           in com_api_type_pkg.t_medium_id
      , i_cardholder_id     in com_api_type_pkg.t_medium_id
      , i_is_attach         in com_api_type_pkg.t_boolean
    ) return com_api_type_pkg.t_short_id
    is
        l_service_id        com_api_type_pkg.t_short_id := 0;
        l_product_id        com_api_type_pkg.t_short_id;
        l_customer_id       com_api_type_pkg.t_medium_id;
    begin
        if i_is_attach = 0 then
            -- need to find active sms service
            select o.service_id
              into l_service_id
              from prd_service_object o
                 , prd_service s
             where o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
               and o.object_id = i_card_id
               and o.service_id = s.id
               and s.service_type_id = ntf_api_const_pkg.NOTIFICATION_CARD_SERVICE
               and o.status = prd_api_const_pkg.SERVICE_OBJECT_STATUS_ACTIVE
               and rownum = 1;
        else
            -- need to find appropriate sms service by card product
            select t.product_id
                 , t.customer_id
              into l_product_id
                 , l_customer_id
              from iss_card c
                 , prd_contract t
             where c.id = i_card_id
               and t.id = c.contract_id;

            select count(1)
              into l_count
              from iss_cardholder i
                 , prd_customer c
             where (c.entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON and c.object_id = i.person_id
                    or c.entity_type != com_api_const_pkg.ENTITY_TYPE_PERSON)
               and c.id = l_customer_id
               and i.id = i_cardholder_id;

            if l_count != 0 then
                select min(p.service_id)
                  into l_service_id
                  from prd_product_service p
                     , prd_service s
                 where p.product_id = l_product_id
                   and nvl(p.max_count, 0) > 0
                   and s.id = p.service_id
                   and s.service_type_id = ntf_api_const_pkg.NOTIFICATION_CARD_SERVICE;
            end if;
        end if;

        trc_log_pkg.debug(
            i_text          => 'Sms service for card_id [#1] is [#2]'
          , i_env_param1    => i_card_id
          , i_env_param2    => l_service_id
        );

        return l_service_id;
    exception
        when no_data_found then
            trc_log_pkg.debug(
                i_text          => 'Service not found [#1] [#2]'
              , i_env_param1    => i_card_id
              , i_env_param2    => i_is_attach
            );
            l_excepted_count := l_excepted_count + 1;
            return 0;
    end get_sms_service_by_card;

    procedure add_sms_service is
        l_service_id              com_api_type_pkg.t_short_id;
    begin
        trc_log_pkg.debug(
            i_text       => 'Start activate sms service [#1] [#2]'
          , i_env_param1 => l_sms_service_tab(i).card_number
          , i_env_param2 => l_sms_service_tab(i).mobile_phone
        );
        l_attribute_value_id := null;

        select c.id
             , contract_id
             , cardholder_id
          into l_card_id
             , l_contract_id
             , l_cardholder_id
          from iss_card_vw c
         where c.card_number = l_sms_service_tab(i).card_number;

        l_service_id := get_sms_service_by_card(
            i_card_id           => l_card_id
          , i_cardholder_id     => l_cardholder_id
          , i_is_attach         => com_api_type_pkg.TRUE
        );

        if l_service_id != 0 then
            prd_ui_service_pkg.set_service_object (
                i_service_id   => l_service_id
              , i_contract_id  => l_contract_id
              , i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CARD
              , i_object_id    => l_card_id
              , i_start_date   => get_sysdate
              , i_end_date     => null
              , i_inst_id      => i_inst_id
              , i_params       => l_params
            );

            select c.person_id
              into l_contact.person_id
              from iss_cardholder_vw c
             where c.id = l_cardholder_id;

            begin
                select c.id
                  into l_contact.id
                  from com_contact c
                     , com_contact_object o
                     , com_contact_data d
                 where c.id           = o.contact_id
                   and o.entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                   and o.object_id    = l_cardholder_id
                   and o.contact_type = l_contact.contact_type
                   and d.contact_id   = c.id
                   and d.end_date     is null;
            exception
                when no_data_found then
                    com_api_contact_pkg.add_contact(
                        o_id              => l_contact.id
                      , i_preferred_lang  => l_contact.preferred_lang
                      , i_job_title       => l_contact.job_title
                      , i_person_id       => l_contact.person_id
                      , i_inst_id         => l_contact.inst_id
                    );
                    com_api_contact_pkg.add_contact_object (
                        i_contact_id         => l_contact.id
                      , i_entity_type        => iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                      , i_contact_type       => l_contact.contact_type
                      , i_object_id          => l_cardholder_id
                      , o_contact_object_id  => l_contact_object_id
                    );
                    com_api_contact_pkg.add_contact_data (
                        i_contact_id     => l_contact.id
                      , i_commun_method  => com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                      , i_commun_address => l_sms_service_tab(i).mobile_phone
                      , i_start_date     => get_sysdate
                    );
            end;
        else
            trc_log_pkg.debug(
                i_text          => 'Service is not found!'
            );
        end if;
        trc_log_pkg.debug(
            i_text       => 'Activate sms service finished'
          , i_env_param1 => l_sms_service_tab(i).card_number
          , i_env_param2 => l_sms_service_tab(i).mobile_phone
        );
    exception
        when no_data_found then
            trc_log_pkg.debug(
                i_text          => 'Card not found [#1] [#2]'
              , i_env_param1    => l_sms_service_tab(i).card_number
              , i_env_param2    => l_sms_service_tab(i).service_type_name
            );
            l_excepted_count := l_excepted_count + 1;
    end add_sms_service;

    procedure deactivate_sms_service is
        l_service_id              com_api_type_pkg.t_short_id;
    begin
        trc_log_pkg.debug(
            i_text       => 'Start deactivate sms service [#1] [#2]'
          , i_env_param1 => l_sms_service_tab(i).card_number
          , i_env_param2 => l_sms_service_tab(i).mobile_phone
        );
        select c.id, contract_id, cardholder_id
          into l_card_id, l_contract_id, l_cardholder_id
          from iss_card_vw c
         where c.card_number = l_sms_service_tab(i).card_number;

        l_service_id := get_sms_service_by_card(
            i_card_id           => l_card_id
          , i_cardholder_id     => l_cardholder_id
          , i_is_attach         => com_api_type_pkg.FALSE
        );

        if l_service_id != 0 then
            update
                prd_service_object
            set
                end_date = nvl(sysdate, com_api_sttl_day_pkg.get_calc_date(i_inst_id => i_inst_id))
                , start_date = nvl(start_date, end_date)
                , status = prd_api_const_pkg.SERVICE_OBJECT_STATUS_CLOSED
            where object_id = l_card_id
              and service_id = l_service_id;
        else
            trc_log_pkg.debug(
                i_text          => 'Service is not found!'
            );
        end if;
        trc_log_pkg.debug(
            i_text       => 'Deactivate sms service finished'
          , i_env_param1 => l_sms_service_tab(i).card_number
          , i_env_param2 => l_sms_service_tab(i).mobile_phone
        );
    exception
        when no_data_found then
            trc_log_pkg.debug(
                i_text       => 'Card not found [#1] [#2]'
              , i_env_param1 => l_sms_service_tab(i).card_number
              , i_env_param2 => l_sms_service_tab(i).service_type_name
            );
            l_excepted_count := l_excepted_count + 1;
    end deactivate_sms_service;

    procedure proc_regular_format is
    begin
        /*
        card_number;phone;action;
        1234561234567890;+79261946425;1;
        */
        l_sms_service_tab(i).card_number  := trim(substr(l_raw, 1, 16));
        l_sms_service_tab(i).mobile_phone := trim(substr(l_raw, 18, 12));
        l_sms_service_tab(i).action_type  := trim(substr(l_raw, 31, 1));

        trc_log_pkg.debug(
            i_text       => 'Load record card_number [#1], mobile_phone [#2], action_type [#3]'
          , i_env_param1 => l_sms_service_tab(i).card_number
          , i_env_param2 => l_sms_service_tab(i).mobile_phone
          , i_env_param3 => l_sms_service_tab(i).action_type
        );

        if l_sms_service_tab(i).action_type = 1 then
            -- sms service add to card
            add_sms_service;
        elsif l_sms_service_tab(i).action_type = 0 then
            -- deactivate sms service in card
            deactivate_sms_service;
        end if;

    end proc_regular_format;
begin
    savepoint load_sms_services_file_start;
    trc_log_pkg.debug(
        i_text          => 'Load SMS services file started...'
    );

    prc_api_stat_pkg.log_start;

    select count(1)
      into l_count
      from prc_session_file s
         , prc_file_attribute_vw a
         , prc_file_vw f
     where s.session_id = get_session_id
       and s.file_attr_id = a.id
       and f.id = a.file_id
       and f.file_type = 'FLTPSMS';

    if l_count = 0 then
        trc_log_pkg.debug(
            i_text          => 'no SMS services files'
        );
    end if;

    l_contact.preferred_lang := com_api_const_pkg.LANGUAGE_RUSSIAN;
    l_contact.inst_id := i_inst_id;
    l_contact.contact_type := com_api_const_pkg.CONTACT_TYPE_NOTIFICATION;

    for files in (
        select s.file_contents
             , s.file_name
             , s.id
          from prc_session_file s
             , prc_file_attribute_vw a
             , prc_file_vw f
         where s.session_id = get_session_id
           and s.file_attr_id = a.id
           and f.id = a.file_id
           and f.file_type = 'FLTPSMS'
    ) loop
        trc_log_pkg.debug(
            i_text          => 'processing SMS services file [#1] [#2]'
          , i_env_param1    => files.id
          , i_env_param2    => files.file_name
        );
        for raws in (
            select f.record_number
                 , f.raw_data
              from prc_file_raw_data f
             where f.session_file_id = files.id
             order by f.record_number
        ) loop
            l_current_count := l_current_count + 1;
            l_raw := raws.raw_data;

            proc_regular_format;

            l_processed_count := l_processed_count + 1;
            i := i + 1;
        end loop;
    end loop;

    prc_api_stat_pkg.log_end (
        i_excepted_total   => l_excepted_count
      , i_processed_total  => l_processed_count
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(
        i_text  => 'Load SMS services files finished...'
    );

exception
    when others then
        rollback to load_sms_services_file_start;
        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
        raise;
end load_sms_services_file;

end;
/
