create or replace package body com_ui_flexible_data_pkg as
/*******************************************************************
*  UI for flexible data <br />
*  Created by Khougaev A.(khougaev@bpc.ru)  at 19.03.2010 <br />
*  Module: COM_UI_FLEXIBLE_DATA_PKG <br />
*  @headcom
******************************************************************/

procedure add_field_to_app_structure(
    i_entity_type  in      com_api_type_pkg.t_dict_value
  , i_name         in      com_api_type_pkg.t_name
  , i_label        in      com_api_type_pkg.t_name
  , i_description  in      com_api_type_pkg.t_full_desc        default null
  , i_lang         in      com_api_type_pkg.t_dict_value
) is
    l_element_id           com_api_type_pkg.t_long_id;
    l_appl_strucure_id     com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug(
        i_text       => 'com_ui_flexible_data_pkg.add_field_to_app_structure: '
                     || 'i_entity_type [#1], i_name [#2], i_label [#3]'
      , i_env_param1 => i_entity_type
      , i_env_param2 => i_name
      , i_env_param3 => i_label
    );

    l_element_id := app_api_element_pkg.get_element_id(i_name);

    trc_log_pkg.debug('l_element_id = ' || l_element_id);

    for rec in (
        select distinct
               s.element_id
             , s.appl_type
             , nvl(s.edit_form, e.edit_form) edit_form
         from  app_element_all_vw e
             , app_structure s
             , app_type t
         where e.entity_type  = i_entity_type
           and s.element_id   = e.id
           and s.appl_type    = t.appl_type
           and e.element_type = app_api_const_pkg.APPL_ELEMENT_TYPE_COMPLEX
    ) loop
        app_ui_structure_pkg.add(
            o_id                => l_appl_strucure_id
          , i_appl_type         => rec.appl_type
          , i_element_id        => l_element_id
          , i_parent_element_id => rec.element_id
          , i_min_count         => 0
          , i_max_count         => 1
          , i_default_value     => null
          , i_is_visible        => com_api_type_pkg.TRUE
          , i_is_updatable      => com_api_type_pkg.TRUE
          , i_display_order     => 900
          , i_is_info           => 0
          , i_lov_id            => null
          , i_is_wizard         => null
          , i_edit_form         => null --rec.edit_form
          , i_is_parent_desc    => null
        );
        trc_log_pkg.debug(
            i_text => 'flexible field added, l_appl_strucure_id [' || l_appl_strucure_id || ']'
        );
    end loop;

    if i_label is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'app_element'
          , i_column_name   => 'caption'
          , i_object_id     => l_element_id
          , i_lang          => i_lang
          , i_text          => i_label
          , i_check_unique  => com_api_type_pkg.TRUE
        );
    end if;

    if i_description is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'app_element'
          , i_column_name   => 'description'
          , i_object_id     => l_element_id
          , i_lang          => i_lang
          , i_text          => i_description
          , i_check_unique  => com_api_type_pkg.TRUE
        );
    end if;

    com_api_id_pkg.check_doubles;

exception
    when others then
        trc_log_pkg.debug(
            i_text => 'add_field_to_app_structure FAILED, '
                   || 'l_appl_strucure_id [' || l_appl_strucure_id || ']'
        );
        raise;
end add_field_to_app_structure;

procedure add_flexible_field(
    o_field_id               out com_api_type_pkg.t_short_id
  , i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_object_type         in     com_api_type_pkg.t_dict_value    default null
  , i_name                in     com_api_type_pkg.t_name
  , i_label               in     com_api_type_pkg.t_name
  , i_description         in     com_api_type_pkg.t_full_desc     default null
  , i_lang                in     com_api_type_pkg.t_dict_value    default null
  , i_data_type           in     com_api_type_pkg.t_dict_value
  , i_data_format         in     com_api_type_pkg.t_name          default null
  , i_lov_id              in     com_api_type_pkg.t_tiny_id       default null
  , i_inst_id             in     com_api_type_pkg.t_inst_id       default null
  , i_default_value_char  in     com_api_type_pkg.t_name          default null
  , i_default_value_num   in     com_api_type_pkg.t_rate          default null
  , i_default_value_date  in     date                             default null
) is
    l_default_value       com_api_type_pkg.t_name;
begin
    l_default_value := com_api_type_pkg.convert_to_char(
                           i_data_type  => i_data_type
                         , i_value_char => i_default_value_char
                         , i_value_num  => i_default_value_num
                         , i_value_date => i_default_value_date
                       );
    o_field_id := com_parameter_seq.nextval;

    begin
        insert into com_flexible_field_vw(
            id
          , entity_type
          , object_type
          , name
          , data_type
          , data_format
          , lov_id
          , is_user_defined
          , inst_id
          , default_value
        ) values (
            o_field_id
          , i_entity_type
          , i_object_type
          , upper(i_name)
          , nvl(i_data_type, com_api_const_pkg.DATA_TYPE_CHAR)
          , nvl(
                i_data_format
              , decode(i_data_type
                  , com_api_const_pkg.DATA_TYPE_NUMBER, com_api_const_pkg.NUMBER_FORMAT
                  , com_api_const_pkg.DATA_TYPE_DATE,   com_api_const_pkg.DATE_FORMAT
                  , null
                )
            )
          , i_lov_id
          , com_api_type_pkg.TRUE
          , nvl(i_inst_id, com_ui_user_env_pkg.get_user_inst)
          , l_default_value
        );
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error(
                i_error             => 'FLEXIBLE_FIELD_ALREADY_EXISTS'
              , i_env_param1        => i_name
            );
    end;

    if i_label is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'com_flexible_field'
          , i_column_name   => 'label'
          , i_object_id     => o_field_id
          , i_lang          => i_lang
          , i_text          => i_label
          , i_check_unique  => com_api_type_pkg.TRUE
        );
    end if;

    if i_description is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'com_flexible_field'
          , i_column_name   => 'description'
          , i_object_id     => o_field_id
          , i_lang          => i_lang
          , i_text          => i_description
        );
    end if;

    add_field_to_app_structure(
        i_entity_type  => i_entity_type
      , i_name         => i_name
      , i_label        => i_label
      , i_description  => i_description
      , i_lang         => i_lang
    );
end add_flexible_field;

procedure modify_flexible_field(
    i_field_id            in     com_api_type_pkg.t_short_id
  , i_entity_type         in     com_api_type_pkg.t_dict_value    default null
  , i_object_type         in     com_api_type_pkg.t_dict_value    default null
  , i_name                in     com_api_type_pkg.t_name          default null
  , i_label               in     com_api_type_pkg.t_name          default null
  , i_description         in     com_api_type_pkg.t_full_desc     default null
  , i_lang                in     com_api_type_pkg.t_dict_value    default null
  , i_data_type           in     com_api_type_pkg.t_dict_value    default null
  , i_data_format         in     com_api_type_pkg.t_name          default null
  , i_lov_id              in     com_api_type_pkg.t_tiny_id       default null
  , i_default_value_char  in     com_api_type_pkg.t_name          default null
  , i_default_value_num   in     com_api_type_pkg.t_rate          default null
  , i_default_value_date  in     date                             default null
) is
    LOG_PREFIX          constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.modify_flexible_field: ';
    l_name                       com_api_type_pkg.t_name;
    l_entity_type                com_api_type_pkg.t_dict_value;
    l_default_value              com_api_type_pkg.t_name;
    l_element_id                 com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'START with field [' || i_field_id || '][' || i_name
                    || '], i_entity_type [#1], i_object_type [#2]'
      , i_env_param1 => i_entity_type
      , i_env_param2 => i_object_type
    );

    begin
        l_element_id := app_api_element_pkg.get_element_id(i_name);
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error             => 'ELEMENT_NOT_FOUND'
              , i_env_param1        => i_name
            );
    end;

    trc_log_pkg.debug('l_element_id = ' || l_element_id);

    -- If new entity type <i_entity_type> or current entity type of the flexible
    -- field <i_field_id> is linked with some application element then
    -- updating l_entity_type => i_entity_type should be disabled to prevent
    -- some inconsistencies between the flexible field and application structure.
    select f.name
         , f.entity_type
      into l_name
         , l_entity_type
      from com_flexible_field f
     where f.id = i_field_id;
     
    if nvl(l_entity_type, '~') != nvl(i_entity_type, '~')
       and (
           app_api_element_pkg.is_linked_with_entity(
               i_entity_type => i_entity_type
           ) = com_api_type_pkg.TRUE
           or
           app_api_element_pkg.is_linked_with_entity(
               i_entity_type => l_entity_type
           ) = com_api_type_pkg.TRUE
       )
    then
        com_api_error_pkg.raise_error(
            i_error      => 'CANNOT_REBIND_FLEXIBLE_FIELD_TO_ENTITY'
          , i_env_param1 => i_field_id
          , i_env_param2 => l_name
          , i_env_param3 => l_entity_type
          , i_env_param4 => i_entity_type
        );
    end if;

    l_default_value := com_api_type_pkg.convert_to_char(
                           i_data_type  => i_data_type
                         , i_value_char => i_default_value_char
                         , i_value_num  => i_default_value_num
                         , i_value_date => i_default_value_date
                       );
    begin
        update com_flexible_field_vw
           set entity_type     = i_entity_type
             , object_type     = i_object_type
             , name            = upper(i_name)
             , data_type       = nvl(i_data_type, data_type)
             , data_format     = nvl(i_data_format, data_format)
             , lov_id          = i_lov_id
             , default_value   = l_default_value
         where id              = i_field_id
           and is_user_defined = com_api_type_pkg.TRUE;
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error(
                i_error             => 'FLEXIBLE_FIELD_ALREADY_EXISTS'
              , i_env_param1        => i_name
            );
    end;

    if i_label is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'com_flexible_field'
          , i_column_name   => 'label'
          , i_object_id     => i_field_id
          , i_lang          => i_lang
          , i_text          => i_label
          , i_check_unique  => com_api_type_pkg.TRUE
        );
        com_api_i18n_pkg.add_text(
            i_table_name    => 'app_element'
          , i_column_name   => 'caption'
          , i_object_id     => i_field_id
          , i_lang          => i_lang
          , i_text          => i_label
          , i_check_unique  => com_api_type_pkg.TRUE
        );
    end if;

    if i_description is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'com_flexible_field'
          , i_column_name   => 'description'
          , i_object_id     => i_field_id
          , i_lang          => i_lang
          , i_text          => i_description
        );
        com_api_i18n_pkg.add_text(
            i_table_name    => 'app_element'
          , i_column_name   => 'description'
          , i_object_id     => i_field_id
          , i_lang          => i_lang
          , i_text          => i_description
          , i_check_unique  => com_api_type_pkg.TRUE
        );
    end if;

    com_api_id_pkg.check_doubles;
exception
    when no_data_found then
        trc_log_pkg.debug(LOG_PREFIX || 'END, the field didn''t found');
end modify_flexible_field;

procedure remove_flexible_field(
    i_field_id            in     com_api_type_pkg.t_short_id
) is
    l_name                com_api_type_pkg.t_name;
    l_entity_type         com_api_type_pkg.t_dict_value;
begin
    -- If the flexible field <i_field_id> is already used in applications 
    -- then we can't remove it.
    if app_api_element_pkg.is_used(i_element_id => i_field_id) = com_api_type_pkg.TRUE then
        select f.name
             , f.entity_type
          into l_name
             , l_entity_type
          from com_flexible_field f
         where f.id = i_field_id;

        com_api_error_pkg.raise_error(
            i_error      => 'FLEXIBLE_FIELD_IS_USED_IN_APP'
          , i_env_param1 => i_field_id
          , i_env_param2 => l_name
          , i_env_param3 => l_entity_type
        );
    end if;

    delete from com_flexible_field_vw
     where id = i_field_id
       and is_user_defined = com_api_type_pkg.TRUE;

    if sql%rowcount > 0 then
        delete from com_flexible_data_vw where field_id = i_field_id;
    end if;

    for rec in (
        select id
          from app_ui_structure_vw
         where element_id = i_field_id
    ) loop
        app_ui_structure_pkg.remove(i_id => rec.id);
    end loop;

    com_api_i18n_pkg.remove_text(
        i_table_name => 'com_flexible_field'
      , i_object_id => i_field_id
    );

    com_api_i18n_pkg.remove_text(
        i_table_name => 'app_element'
      , i_object_id => i_field_id
    );
end remove_flexible_field;

procedure set_flexible_value_v(
    i_field_name          in     com_api_type_pkg.t_name
  , i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_object_id           in     com_api_type_pkg.t_long_id
  , i_seq_number          in     com_api_type_pkg.t_tiny_id       default 1
  , i_field_value         in     varchar2
) is
    l_field_value       com_api_type_pkg.t_name := i_field_value;
begin
    com_api_flexible_data_pkg.set_flexible_value(
        i_field_name        => i_field_name
      , i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
      , i_seq_number        => i_seq_number
      , i_field_value       => l_field_value
    );
end set_flexible_value_v;

procedure set_flexible_value_d(
    i_field_name          in     com_api_type_pkg.t_name
  , i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_object_id           in     com_api_type_pkg.t_long_id
  , i_seq_number          in     com_api_type_pkg.t_tiny_id       default 1
  , i_field_value         in     date
) is
begin
    com_api_flexible_data_pkg.set_flexible_value(
        i_field_name        => i_field_name
      , i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
      , i_seq_number        => i_seq_number
      , i_field_value       => i_field_value
    );
end set_flexible_value_d;

procedure set_flexible_value_n(
    i_field_name          in     com_api_type_pkg.t_name
  , i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_object_id           in     com_api_type_pkg.t_long_id
  , i_seq_number          in     com_api_type_pkg.t_tiny_id       default 1
  , i_field_value         in     number
) is
begin
    com_api_flexible_data_pkg.set_flexible_value(
        i_field_name        => i_field_name
      , i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
      , i_seq_number        => i_seq_number
      , i_field_value       => i_field_value
    );
end set_flexible_value_n;

procedure sync_fields_with_app_structure
is
begin
    for rec in (
        select id
             , entity_type
             , name
             , label
             , description
             , lang
          from com_ui_flexible_field_vw f
         where lang = com_ui_user_env_pkg.get_user_lang
           and not exists (select 1 from app_ui_structure_vw s
                            where s.element_id = f.id)
    ) loop
        add_field_to_app_structure(
            i_entity_type => rec.entity_type
          , i_name        => rec.name
          , i_label       => rec.label
          , i_description => rec.description
          , i_lang        => rec.lang
        );
    end loop;
end sync_fields_with_app_structure;

procedure add_flexible_field_usage(
    o_id                     out com_api_type_pkg.t_short_id
  , i_field_id            in     com_api_type_pkg.t_short_id
  , i_usage               in     com_api_type_pkg.t_dict_value
) is
    LOG_PREFIX          constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.add_flexible_field_usage';
    l_entity_type                com_api_type_pkg.t_dict_value;
    l_name                       com_api_type_pkg.t_name;
begin
    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || ': i_field_id [#1], i_usage [#2]'
      , i_env_param1  => i_field_id
      , i_env_param2  => i_usage
    );

    select f.entity_type
         , f.name
      into l_entity_type
         , l_name
      from com_flexible_field f
     where f.id = i_field_id;

    o_id := com_flexible_field_usage_seq.nextval;

    begin
        insert into com_flexible_field_usage(
            id
          , field_id
          , seqnum
          , usage
        ) values (
            o_id
          , i_field_id
          , 1
          , i_usage
        );
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error(
                i_error       => 'FLEXIBLE_FIELD_USAGE_ALREADY_EXISTS'
              , i_env_param1  => i_usage
              , i_env_param2  => l_name
            );
    end;

    com_api_flexible_data_pkg.set_usage(
        i_usage       => i_usage
      , i_entity_type => l_entity_type
    );
end add_flexible_field_usage;

procedure modify_flexible_field_usage(
    i_id                  in     com_api_type_pkg.t_short_id
  , i_field_id            in     com_api_type_pkg.t_short_id
  , i_usage               in     com_api_type_pkg.t_dict_value
) is
    LOG_PREFIX          constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.modify_flexible_field_usage';
    l_entity_type                com_api_type_pkg.t_dict_value;
    l_name                       com_api_type_pkg.t_name;
begin
    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || ': i_id [#1], i_field_id [#2], i_usage [#3]'
      , i_env_param1  => i_id
      , i_env_param2  => i_field_id
      , i_env_param3  => i_usage
    );

    select f.entity_type
         , f.name
      into l_entity_type
         , l_name
      from com_flexible_field f
     where f.id = i_field_id;

    begin
        update com_flexible_field_usage
           set usage     = i_usage
             , seqnum    = seqnum + 1
         where id  = i_id;
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error(
                i_error       => 'FLEXIBLE_FIELD_USAGE_ALREADY_EXISTS'
              , i_env_param1  => i_usage
              , i_env_param2  => l_name
            );
    end;

    if sql%rowcount = 0 then
        com_api_error_pkg.raise_error(
            i_error       => 'FLEXIBLE_FIELD_USAGE_NOT_FOUND'
          , i_env_param1  => i_usage
          , i_env_param2  => l_name
        );
    end if;

    com_api_flexible_data_pkg.set_usage(
        i_usage       => i_usage
      , i_entity_type => l_entity_type
    );
end modify_flexible_field_usage;

procedure remove_flexible_field_usage(
    i_id                  in     com_api_type_pkg.t_short_id
) is
    LOG_PREFIX          constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.remove_flexible_field_usage';
begin
    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || ': i_id [#1]'
      , i_env_param1  => i_id
    );

    delete
      from com_flexible_field_usage
     where id  = i_id;

end remove_flexible_field_usage;

end;
/
