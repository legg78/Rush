create or replace package body app_ui_element_pkg as
/*********************************************************
*  Application - UI for elements <br />
*  Created by Filimonov A.(filimonov@bpcbt.com)  at 23.11.2009 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: APP_UI_ELEMENT_PKG <br />
*  @headcom
**********************************************************/
procedure add_element(
    o_element_id           out  com_api_type_pkg.t_short_id
  , i_element_name      in      com_api_type_pkg.t_name
  , i_element_type      in      com_api_type_pkg.t_dict_value
  , i_data_type         in      com_api_type_pkg.t_dict_value
  , i_min_length        in      com_api_type_pkg.t_tiny_id
  , i_max_length        in      com_api_type_pkg.t_tiny_id
  , i_min_value         in      com_api_type_pkg.t_name
  , i_max_value         in      com_api_type_pkg.t_name
  , i_lov_id            in      com_api_type_pkg.t_tiny_id
  , i_default_value     in      com_api_type_pkg.t_name
  , i_is_multilang      in      com_api_type_pkg.t_boolean
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_edit_form         in      com_api_type_pkg.t_name
  , i_short_desc        in      com_api_type_pkg.t_short_desc
  , i_full_desc         in      com_api_type_pkg.t_full_desc
  , i_lang              in      com_api_type_pkg.t_dict_value
) is
begin
    if i_data_type is not null 
      and i_data_type not in (
          com_api_const_pkg.DATA_TYPE_NUMBER
        , com_api_const_pkg.DATA_TYPE_CHAR
        , com_api_const_pkg.DATA_TYPE_CLOB
        , com_api_const_pkg.DATA_TYPE_DATE )
    then
        com_api_error_pkg.raise_error(
            i_error => 'UNKNOWN_DATA_TYPE'
          , i_env_param1 => i_data_type
        );
    end if;

    select com_parameter_seq.nextval into o_element_id from dual;

    insert into app_element(
        id
      , name
      , element_type
      , data_type
      , min_length
      , max_length
      , min_value
      , max_value
      , lov_id
      , default_value
      , is_multilang
      , entity_type
      , edit_form
    ) values (
        o_element_id
      , upper(i_element_name)
      , i_element_type
      , i_data_type
      , i_min_length
      , i_max_length
      , i_min_value
      , i_max_value
      , i_lov_id
      , i_default_value
      , i_is_multilang
      , i_entity_type
      , i_edit_form
    );
    
    com_api_id_pkg.check_doubles;
    
    if i_short_desc is not null then
        com_api_i18n_pkg.add_text(
            i_table_name            => 'APP_ELEMENT' 
          , i_column_name           => 'CAPTION' 
          , i_object_id             => o_element_id
          , i_lang                  => i_lang
          , i_text                  => i_short_desc
        );
    end if;
        
    if i_full_desc is not null then
        com_api_i18n_pkg.add_text(
            i_table_name            => 'APP_ELEMENT' 
          , i_column_name           => 'DESCRIPTION' 
          , i_object_id             => o_element_id
          , i_lang                  => i_lang
          , i_text                  => i_full_desc
        );
    end if;

exception 
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error       => 'APP_ELEMENT_ALREADY_EXISTS'
          , i_env_param1  => upper(i_element_name)
        );        
end;

procedure add_desc(
    i_element_name      in      com_api_type_pkg.t_name
  , i_short_desc        in      com_api_type_pkg.t_short_desc
  , i_full_desc         in      com_api_type_pkg.t_full_desc
  , i_lang              in      com_api_type_pkg.t_dict_value
) is
    l_element_id        com_api_type_pkg.t_short_id;
begin

    if i_short_desc is not null or i_full_desc is not null then
        begin
            select id
              into l_element_id
              from app_element
             where name = upper(i_element_name);
        exception
            when no_data_found then
                return;
        end;         
        
        if i_short_desc is not null then
            com_api_i18n_pkg.add_text(
                i_table_name            => 'APP_ELEMENT' 
              , i_column_name           => 'NAME' 
              , i_object_id             => l_element_id
              , i_lang                  => i_lang
              , i_text                  => i_short_desc
            );
        end if;
        
        if i_full_desc is not null then
            com_api_i18n_pkg.add_text(
                i_table_name            => 'APP_ELEMENT' 
              , i_column_name           => 'DESCRIPTION' 
              , i_object_id             => l_element_id
              , i_lang                  => i_lang
              , i_text                  => i_full_desc
            );
        end if;
    end if;
    
end;

end;
/
