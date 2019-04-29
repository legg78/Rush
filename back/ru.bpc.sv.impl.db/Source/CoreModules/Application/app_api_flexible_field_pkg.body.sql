create or replace package body app_api_flexible_field_pkg as
/*********************************************************
 *  Acquiring application API  <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 28.05.2011 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: app_api_flexible_field_pkg <br />
 *  @headcom
 **********************************************************/
procedure process_flexible_fields(
    i_entity_type          in            com_api_type_pkg.t_dict_value
  , i_object_type          in            com_api_type_pkg.t_dict_value
  , i_object_id            in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_appl_data_id         in            com_api_type_pkg.t_long_id
) is
    l_value_n              number;
    l_value_v              com_api_type_pkg.t_name;
    l_value_d              date;
    l_changed              com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
    l_id_tab               com_api_type_pkg.t_number_tab;
    l_filed_name           com_api_type_pkg.t_name; 
    l_filed_value          com_api_type_pkg.t_name; 
    l_data_type            com_api_type_pkg.t_dict_value; 
    l_appl_data_id         com_api_type_pkg.t_long_id;
    
    l_flexible_field_name       com_api_type_pkg.t_name;
    l_flexible_field_value      com_api_type_pkg.t_name;
    l_flexible_field_id         com_api_type_pkg.t_long_id;
    l_flexible_data_type        com_api_type_pkg.t_dict_value;
    l_flexible_data_format      com_api_type_pkg.t_text;
    l_flex_name_id              com_api_type_pkg.t_long_id;
    l_flex_value_id             com_api_type_pkg.t_long_id;
    
begin
    trc_log_pkg.debug('app_api_flexible_field_pkg.process_flexible_fields');
    
    for r in (
        select nvl(get_text ('com_flexible_field'
                           , 'label'
                           , f.id
                           , com_ui_user_env_pkg.get_user_lang)
                 , name) as label
             , f.name
             , f.data_type
          from com_flexible_field f
         where inst_id in (i_inst_id, ost_api_const_pkg.DEFAULT_INST)
           and entity_type  = i_entity_type
           and (object_type = i_object_type
                or
                object_type is null
               )
    ) loop
        trc_log_pkg.debug('app_api_flexible_field_pkg.process_flexible_fields: data_type = '
                         ||r.data_type||', label='||r.label||', name='||r.name);
                         
        if r.data_type = com_api_const_pkg.DATA_TYPE_CHAR then
            app_api_application_pkg.get_element_value(
                i_element_name  => upper(r.name)
              , i_parent_id     => i_appl_data_id
              , o_element_value => l_value_v
            );
        elsif r.data_type = com_api_const_pkg.DATA_TYPE_NUMBER then
            app_api_application_pkg.get_element_value(
                i_element_name  => upper(r.name)
              , i_parent_id     => i_appl_data_id
              , o_element_value => l_value_n
            );
        elsif r.data_type = com_api_const_pkg.DATA_TYPE_DATE then
            app_api_application_pkg.get_element_value(
                i_element_name  => upper(r.name)
              , i_parent_id     => i_appl_data_id
              , o_element_value => l_value_d
            );
        end if;

        if r.data_type = com_api_const_pkg.DATA_TYPE_CHAR and l_value_v is not null then
            com_api_flexible_data_pkg.set_flexible_value(
                i_field_name    => upper(r.name)
              , i_entity_type   => i_entity_type
              , i_object_id     => i_object_id
              , i_field_value   => l_value_v
            );
        elsif r.data_type = com_api_const_pkg.DATA_TYPE_NUMBER and l_value_n is not null then
            com_api_flexible_data_pkg.set_flexible_value(
                i_field_name    => upper(r.name)
              , i_entity_type   => i_entity_type
              , i_object_id     => i_object_id
              , i_field_value   => l_value_n
            );
        elsif r.data_type = com_api_const_pkg.DATA_TYPE_DATE and l_value_d is not null then
            com_api_flexible_data_pkg.set_flexible_value(
                i_field_name    => upper(r.name)
              , i_entity_type   => i_entity_type
              , i_object_id     => i_object_id
              , i_field_value   => l_value_d
            );
        end if;
        
        l_changed := com_api_type_pkg.TRUE;
    end loop;

    -- new support of flex 
    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'FLEXIBLE_FIELD'
      , i_parent_id     => i_appl_data_id
      , o_appl_data_id  => l_id_tab
    );

    for i in 1..nvl(l_id_tab.count, 0) loop
        app_api_application_pkg.get_appl_data_id(
            i_element_name  => 'FLEXIBLE_FIELD_NAME'
          , i_parent_id     => l_id_tab(i)
          , o_appl_data_id  => l_flex_name_id
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'FLEXIBLE_FIELD_NAME'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_flexible_field_name
        );

        app_api_application_pkg.get_appl_data_id(
            i_element_name  => 'FLEXIBLE_FIELD_VALUE'
          , i_parent_id     => l_id_tab(i)
          , o_appl_data_id  => l_flex_value_id
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'FLEXIBLE_FIELD_VALUE'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_flexible_field_value
        );

        begin
            select id
                 , data_type
                 , data_format
              into l_flexible_field_id
                 , l_flexible_data_type
                 , l_flexible_data_format
              from com_flexible_field
             where upper(name) = upper(l_flexible_field_name)
               and entity_type = i_entity_type;
        exception
            when others then
                l_flexible_field_id := null;
        end;

        trc_log_pkg.debug('flexible_field_name[' || l_flexible_field_name || '] flexible_field_value[' || l_flexible_field_value || ']'
                       || ', l_flexible_data_type['|| l_flexible_data_type || '], l_flexible_data_format['|| l_flexible_data_format || ']');

        if l_flexible_field_id is null then
            com_api_error_pkg.raise_error(
                i_error         => 'FLEXIBLE_FIELD_NOT_FOUND'
              , i_env_param1    => l_flexible_field_name
            );
        else
            case l_flexible_data_type
                when com_api_const_pkg.DATA_TYPE_NUMBER then
                    app_api_application_pkg.add_element(
                        i_element_name      => l_flexible_field_name
                      , i_parent_id         => i_appl_data_id
                      , i_element_value     => to_number(
                                                   l_flexible_field_value
                                                 , nvl(l_flexible_data_format, com_api_const_pkg.NUMBER_FORMAT)
                                               )
                    );             
                    com_api_flexible_data_pkg.set_flexible_value(
                        i_field_name    => upper(l_flexible_field_name)
                      , i_entity_type   => i_entity_type
                      , i_object_id     => i_object_id
                      , i_field_value   => to_number(
                                                   l_flexible_field_value
                                                 , nvl(l_flexible_data_format, com_api_const_pkg.NUMBER_FORMAT)
                                               )
                    );
                when com_api_const_pkg.DATA_TYPE_DATE then
                    app_api_application_pkg.add_element(
                        i_element_name      => l_flexible_field_name
                      , i_parent_id         => i_appl_data_id
                      , i_element_value     => to_date(
                                                   l_flexible_field_value
                                                 , nvl(l_flexible_data_format, com_api_const_pkg.DATE_FORMAT)
                                               )
                    );
                    com_api_flexible_data_pkg.set_flexible_value(
                        i_field_name    => upper(l_flexible_field_name)
                      , i_entity_type   => i_entity_type
                      , i_object_id     => i_object_id
                      , i_field_value   => to_date(
                                                   l_flexible_field_value
                                                 , nvl(l_flexible_data_format, com_api_const_pkg.DATE_FORMAT)
                                               )
                    );
                else
                    app_api_application_pkg.add_element(
                        i_element_name      => l_flexible_field_name
                      , i_parent_id         => i_appl_data_id
                      , i_element_value     => l_flexible_field_value
                    );
                    com_api_flexible_data_pkg.set_flexible_value(
                        i_field_name    => upper(l_flexible_field_name)
                      , i_entity_type   => i_entity_type
                      , i_object_id     => i_object_id
                      , i_field_value   => l_flexible_field_value
                    );
            end case;

            app_api_application_pkg.remove_element(i_appl_data_id => l_id_tab(i));
            app_api_application_pkg.remove_element(i_appl_data_id => l_flex_name_id);
            app_api_application_pkg.remove_element(i_appl_data_id => l_flex_value_id);
        end if;

        trc_log_pkg.debug('flexible_field_name[' || l_flexible_field_name || '] flexible_field_value[' || l_flexible_field_value || ']');
    end loop;

    if l_changed = com_api_type_pkg.TRUE and i_entity_type = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER then
        prd_api_customer_pkg.set_last_modify(
            i_customer_id => i_object_id
        );
    end if;

end;

end;
/
