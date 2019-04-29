create or replace package body app_api_address_pkg as
/*********************************************************
 *  API for Address in application <br />
 *  Created by Khougaev A.(khougaev@bpc.ru)  at 23.03.2010 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: APP_API_ADDRESS_PKG  <br />
 *  @headcom
 **********************************************************/

procedure get_appl_data (
    i_appl_data_id      in            com_api_type_pkg.t_long_id
  , o_address              out nocopy app_api_type_pkg.t_address
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
      , o_element_value  => o_address.inst_id
    );

    app_api_application_pkg.get_element_value (
        i_element_name    => 'ADDRESS_TYPE'
      , i_parent_id       => i_appl_data_id
      , o_element_value   => o_address.address_type
    );

    app_api_application_pkg.get_element_value (
        i_element_name    => 'COUNTRY'
      , i_parent_id       => i_appl_data_id
      , o_element_value   => o_address.country
    );

    app_api_application_pkg.get_element_value (
        i_element_name    => 'HOUSE'
      , i_parent_id       => i_appl_data_id
      , o_element_value   => o_address.house
    );

    app_api_application_pkg.get_element_value (
        i_element_name    => 'APARTMENT'
      , i_parent_id       => i_appl_data_id
      , o_element_value   => o_address.apartment
    );

    app_api_application_pkg.get_element_value (
        i_element_name    => 'POSTAL_CODE'
      , i_parent_id       => i_appl_data_id
      , o_element_value   => o_address.postal_code
    );

    app_api_application_pkg.get_element_value (
        i_element_name    => 'REGION_CODE'
      , i_parent_id       => i_appl_data_id
      , o_element_value   => o_address.region_code
    );

    app_api_application_pkg.get_element_value (
        i_element_name    => 'LATITUDE'
      , i_parent_id       => i_appl_data_id
      , o_element_value   => o_address.latitude
    );

    app_api_application_pkg.get_element_value (
        i_element_name    => 'LONGITUDE'
      , i_parent_id       => i_appl_data_id
      , o_element_value   => o_address.longitude
    );

    app_api_application_pkg.get_element_value (
        i_element_name    => 'PLACE_CODE'
      , i_parent_id       => i_appl_data_id
      , o_element_value   => o_address.place_code
    );

--    trc_log_pkg.debug('get_address_data: i_appl_data_id='||i_appl_data_id
--      ||', o_address.id='||o_address.id
--      ||', address_type='||o_address.address_type
--      ||', country='||o_address.country
--      ||', house='||o_address.house
--      ||', apartment='|| o_address.apartment
--      ||', postal_code='|| o_address.postal_code
--      ||', region_code='|| o_address.region_code);
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

procedure change_address (
    i_appl_data_id          in            com_api_type_pkg.t_long_id
  , i_object_id             in            com_api_type_pkg.t_long_id
  , i_address_id            in            com_api_type_pkg.t_long_id
  , i_address_object_id     in            com_api_type_pkg.t_long_id
  , i_entity_type           in            com_api_type_pkg.t_dict_value
) is
    l_id_tab                com_api_type_pkg.t_number_tab;
    l_lang_tab              com_api_type_pkg.t_dict_tab;
    l_address               app_api_type_pkg.t_address;
begin
    get_appl_data (
        i_appl_data_id  => i_appl_data_id
      , o_address       => l_address
    );

    trc_log_pkg.debug (
        i_text        => 'Change_address: [#1] [#2] [#3] [#4]'
      , i_env_param1  => l_address.lang
      , i_env_param2  => l_address.id
      , i_env_param3  => i_address_object_id
      , i_env_param4  => i_entity_type
    );

    l_address.id := null;

    app_api_application_pkg.get_appl_data_id (
        i_element_name    => 'ADDRESS_NAME'
      , i_parent_id       => i_appl_data_id
      , o_appl_data_id    => l_id_tab
      , o_appl_data_lang  => l_lang_tab
    );

    for i in 1..l_lang_tab.count loop
        for j in 1..l_lang_tab.count loop
            if i < j and l_lang_tab(i) = l_lang_tab(j) then
                com_api_error_pkg.raise_error (
                    i_error       => 'DUPLICATE_ADDRESS'
                  , i_env_param1  => l_address.id
                  , i_env_param2  => l_lang_tab(i)
                );
            end if;
        end loop;
    end loop;

    for i in 1..l_id_tab.count loop
        app_api_application_pkg.get_element_value (
            i_element_name   => 'REGION'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_address.region
        );
        app_api_application_pkg.get_element_value (
            i_element_name   => 'CITY'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_address.city
        );
        app_api_application_pkg.get_element_value (
            i_element_name   => 'STREET'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_address.street
        );
        app_api_application_pkg.get_element_value (
            i_element_name   => 'COMMENT'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_address.comments
        );

        l_address.region := replace(l_address.region, chr(9), chr(32));
        l_address.city   := replace(l_address.city,   chr(9), chr(32));
        l_address.street := replace(l_address.street, chr(9), chr(32));

        if l_lang_tab(i) = com_api_const_pkg.LANGUAGE_ENGLISH then
            com_api_i18n_pkg.check_text_for_latin(i_text => l_address.region);
            com_api_i18n_pkg.check_text_for_latin(i_text => l_address.city);
            com_api_i18n_pkg.check_text_for_latin(i_text => l_address.street);
        end if;

        com_api_address_pkg.modify_address(
            i_address_id  => i_address_id
          , i_country     => l_address.country
          , i_region      => l_address.region
          , i_city        => l_address.city
          , i_street      => l_address.street
          , i_house       => l_address.house
          , i_apartment   => l_address.apartment
          , i_postal_code => l_address.postal_code
          , i_region_code => l_address.region_code
          , i_latitude    => l_address.latitude
          , i_longitude   => l_address.longitude
          , i_lang        => l_lang_tab(i)
          , i_inst_id     => l_address.inst_id
          , i_place_code  => l_address.place_code
          , i_comments    => l_address.comments
        );
        
        app_api_flexible_field_pkg.process_flexible_fields(
            i_entity_type   => com_api_const_pkg.ENTITY_TYPE_ADDRESS
          , i_object_type   => null
          , i_object_id     => i_address_id
          , i_inst_id       => l_address.inst_id
          , i_appl_data_id  => i_appl_data_id
        );
        
    end loop;
end;

procedure create_address (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_parent_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_object_id            in            com_api_type_pkg.t_long_id
  , i_entity_type          in            com_api_type_pkg.t_dict_value
  , o_address_id              out nocopy com_api_type_pkg.t_medium_id
) is
    l_serial_number         com_api_type_pkg.t_tiny_id := 1;
    l_id_tab                com_api_type_pkg.t_number_tab;
    l_lang_tab              com_api_type_pkg.t_dict_tab;
    l_address               app_api_type_pkg.t_address;
    l_address_obj_id        com_api_type_pkg.t_long_id;
begin
    get_appl_data (
        i_appl_data_id  => i_appl_data_id
      , o_address       => l_address
    );

    -- Element merchant->address->post_code is mandatory for field De43 SE04 of Presentment clearing message
    if l_address.postal_code is null
       and
       i_entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
    then
        com_api_error_pkg.raise_error(
            i_error      => 'MANDATORY_ELEMENT_IS_MISSING'
          , i_env_param1 => 'POSTAL_CODE'
          , i_env_param2 => 'MERCHANT->ADDRESS'
        );
    end if;

    app_api_application_pkg.get_appl_data_id (
        i_element_name    => 'ADDRESS_NAME'
      , i_parent_id       => i_appl_data_id
      , o_appl_data_id    => l_id_tab
      , o_appl_data_lang  => l_lang_tab
    );

    trc_log_pkg.debug (
        i_text        => 'create_address: i_appl_data_id[#1], i_parent_appl_data_id[#2], l_address_name_tab.count[#3]'
      , i_env_param1  => i_appl_data_id
      , i_env_param2  => i_parent_appl_data_id
      , i_env_param3  => l_id_tab.count
    );

    for i in 1..l_lang_tab.count loop
        for j in 1..l_lang_tab.count loop
            if i < j and l_lang_tab(i) = l_lang_tab(j) then
                com_api_error_pkg.raise_error (
                    i_error       => 'DUPLICATE_ADDRESS'
                  , i_env_param1  => l_address.id
                  , i_env_param2  => l_lang_tab(i)
                );
            end if;
        end loop;
    end loop;

    -- Adding one record with same ID for each language
    for i in 1..l_id_tab.count loop
        -- trc_log_pkg.debug('l_id_tab(i)='||l_id_tab(i));

        l_address.lang := l_lang_tab(i);

        app_api_application_pkg.get_element_value (
            i_element_name   => 'REGION'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_address.region
        );
        app_api_application_pkg.get_element_value (
            i_element_name   => 'CITY'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_address.city
        );
        app_api_application_pkg.get_element_value (
            i_element_name   => 'STREET'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_address.street
        );
        app_api_application_pkg.get_element_value (
            i_element_name   => 'COMMENT'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_address.comments
        );

        l_serial_number := l_serial_number + 1;
--        trc_log_pkg.debug('create_address: id='||l_address.id||', lang ='  ||l_lang_tab(i)
--                     ||', region=' ||l_address.region ||', city='   ||l_address.city
--                     ||', street=' ||l_address.street ||', country='||l_address.country  );

        l_address.region := replace(l_address.region, chr(9), chr(32));
        l_address.city   := replace(l_address.city,   chr(9), chr(32));
        l_address.street := replace(l_address.street, chr(9), chr(32));

        if l_address.lang = com_api_const_pkg.LANGUAGE_ENGLISH then
            com_api_i18n_pkg.check_text_for_latin(i_text => l_address.region);
            com_api_i18n_pkg.check_text_for_latin(i_text => l_address.city);
            com_api_i18n_pkg.check_text_for_latin(i_text => l_address.street);
        end if;

        com_api_address_pkg.add_address (
            io_address_id  => o_address_id
          , i_lang         => l_lang_tab(i)
          , i_country      => l_address.country
          , i_region       => l_address.region
          , i_city         => l_address.city
          , i_street       => l_address.street
          , i_house        => l_address.house
          , i_apartment    => l_address.apartment
          , i_postal_code  => l_address.postal_code
          , i_region_code  => l_address.region_code
          , i_inst_id      => l_address.inst_id
          , i_latitude     => l_address.latitude
          , i_longitude    => l_address.longitude
          , i_place_code   => l_address.place_code
          , i_comments     => l_address.comments
        );

        if i = 1 and l_address_obj_id is null then
            com_api_address_pkg.add_address_object (
                i_address_id         => o_address_id
              , i_address_type       => l_address.address_type
              , i_entity_type        => i_entity_type
              , i_object_id          => i_object_id
              , o_address_object_id  => l_address_obj_id
            );
        end if;
        
        app_api_flexible_field_pkg.process_flexible_fields(
            i_entity_type   => com_api_const_pkg.ENTITY_TYPE_ADDRESS
          , i_object_type   => null
          , i_object_id     => o_address_id
          , i_inst_id       => l_address.inst_id
          , i_appl_data_id  => i_appl_data_id
        );
        
    end loop;
end;

procedure process_address (
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_parent_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_entity_type          in            com_api_type_pkg.t_dict_value
  , i_object_id            in            com_api_type_pkg.t_long_id
  , o_address_id              out nocopy com_api_type_pkg.t_medium_id
) is
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_address: ';
    l_address_type         com_api_type_pkg.t_dict_value;
    l_address_object_id    com_api_type_pkg.t_long_id;
    l_command              com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug(LOG_PREFIX || 'START with i_appl_data_id [' || i_appl_data_id || ']');

    cst_api_application_pkg.process_address_before (
        i_appl_data_id         => i_appl_data_id
      , i_parent_appl_data_id  => i_parent_appl_data_id
      , i_entity_type          => i_entity_type
      , i_object_id            => i_object_id
      , o_address_id           => o_address_id
    );

    app_api_application_pkg.get_element_value (
        i_element_name   => 'ADDRESS_TYPE'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_address_type
    );
    app_api_application_pkg.get_element_value (
        i_element_name   => 'COMMAND'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_command
    );

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'i_entity_type [#3], i_object_id [#4], l_command [#1], l_address_type [#2]'
      , i_env_param1 => l_command
      , i_env_param2 => l_address_type
      , i_env_param3 => i_entity_type
      , i_env_param4 => i_object_id
    );

    begin
        select distinct
               o.id
             , o.address_id
          into l_address_object_id
             , o_address_id
          from com_address_object_vw o
             , com_address_vw a
         where a.id = o.address_id
           and entity_type  = i_entity_type
           and object_id    = i_object_id
           and address_type = l_address_type;

        trc_log_pkg.debug(LOG_PREFIX || 'address [' || o_address_id || '] has been found');

        if l_command = app_api_const_pkg.COMMAND_CREATE_OR_PROCEED then
            null;

        elsif l_command = app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT then
            com_api_error_pkg.raise_error (
                i_error       => 'ADDRESS_ALREADY_EXIST'
              , i_env_param1  => i_object_id ||' '|| l_address_type||' '|| i_entity_type
            );

        elsif l_command in (
            app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
          , app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
        ) then
            change_address (
                i_appl_data_id       => i_appl_data_id
              , i_object_id          => i_object_id
              , i_address_id         => o_address_id
              , i_address_object_id  => l_address_object_id
              , i_entity_type        => i_entity_type
            );

        elsif l_command = app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE then
            com_api_address_pkg.remove_address_object (
                i_address_object_id  => l_address_object_id
            );

            com_api_address_pkg.remove_address(
                i_address_id  => o_address_id
              , i_seqnum      => 1
            );
        else
            null; -- unknown command
        end if;

    exception
        when no_data_found then
            trc_log_pkg.debug(LOG_PREFIX || 'address has NOT been found');

            if l_command = app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE then
                null;

            elsif l_command in (
                app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
              , app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
              , app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED
            ) then
                com_api_error_pkg.raise_error (
                    i_error       => 'ADDRESS_NOT_FOUND'
                  , i_env_param1  => i_object_id ||' '|| l_address_type||' '|| i_entity_type
                );

            elsif l_command in (
                app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
              , app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
              , app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
            ) then
                create_address (
                    i_appl_data_id         => i_appl_data_id
                  , i_parent_appl_data_id  => i_parent_appl_data_id
                  , i_object_id            => i_object_id
                  , i_entity_type          => i_entity_type
                  , o_address_id           => o_address_id
                );

            else
                create_address (
                    i_appl_data_id         => i_appl_data_id
                  , i_parent_appl_data_id  => i_parent_appl_data_id
                  , i_object_id            => i_object_id
                  , i_entity_type          => i_entity_type
                  , o_address_id           => o_address_id
                );
            end if;
    end;

    app_api_note_pkg.process_note(
        i_appl_data_id => i_appl_data_id
      , i_entity_type  => com_api_const_pkg.ENTITY_TYPE_ADDRESS
      , i_object_id    => o_address_id
    );

    cst_api_application_pkg.process_address_after (
        i_appl_data_id           => i_appl_data_id
        , i_parent_appl_data_id  => i_parent_appl_data_id
        , i_entity_type          => i_entity_type
        , i_object_id            => i_object_id
        , io_address_id          => o_address_id
    );

exception
    when com_api_error_pkg.e_application_error then
        app_api_error_pkg.intercept_error (
            i_appl_data_id  => i_appl_data_id
          , i_element_name  => 'ADDRESS'
        );
end;

end;
/
