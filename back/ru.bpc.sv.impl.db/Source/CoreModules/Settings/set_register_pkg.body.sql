CREATE OR REPLACE package body set_register_pkg as

procedure register_parameter(
    i_parameter         in      t_param_rec
  , i_group_name        in      com_api_type_pkg.t_name             default null
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
  , i_short_desc        in      com_api_type_pkg.t_short_desc       default null
  , i_full_desc         in      com_api_type_pkg.t_full_desc        default null
) is
    l_parent_id         com_api_type_pkg.t_short_id;
    l_module_name       com_api_type_pkg.t_name;
begin
    if i_parameter.name is null then
        com_api_error_pkg.raise_error('PARAM_NAME_NOT_DEFINED');
    end if;

    begin
        select name
          into l_module_name
          from com_module
         where module_code = upper(i_parameter.module_code);
    exception
        when no_data_found then
            com_api_error_pkg.raise_error('MODULE_NOT_INSTALLED', upper(i_parameter.module_code));
    end;

    if i_group_name is not null then
        begin
            select id
              into l_parent_id
              from set_parameter
             where name = upper(i_group_name)
               and module_code = upper(i_parameter.module_code);
        exception
            when no_data_found then
                com_api_error_pkg.raise_error('PARAM_GROUP_NOT_EXISTS', upper(i_group_name), l_module_name);
        end;
    end if;
        
    begin    
        insert into set_parameter(
            id
          , name
          , module_code
          , lowest_level
          , default_value
          , data_type 
          , lov_id
          , parent_id
          , display_order
        ) values (
            com_parameter_seq.nextval
          , upper(i_parameter.name)
          , upper(i_parameter.module_code)
          , i_parameter.lowest_level
          , i_parameter.default_value
          , i_parameter.data_type 
          , i_parameter.lov_id
          , l_parent_id
          , i_parameter.display_order
        );
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error('PARAM_NAME_EXISTS', upper(i_parameter.name), l_module_name);
    end;
        
    if i_lang is not null and i_short_desc is not null then
        register_param_desc(
            i_param_name    => upper(i_parameter.name)
          , i_lang          => i_lang
          , i_short_desc    => i_short_desc
          , i_full_desc     => i_full_desc
        );
    end if;
end;
        
procedure register_parameter(
    i_name              in      com_api_type_pkg.t_name
  , i_module_code       in      com_api_type_pkg.t_module_code
  , i_lowest_level      in      com_api_type_pkg.t_dict_value       default null
  , i_default_value     in      com_api_type_pkg.t_name             default null
  , i_data_type         in      com_api_type_pkg.t_dict_value       default null
  , i_lov_id            in      com_api_type_pkg.t_tiny_id          default null
  , i_group_name        in      com_api_type_pkg.t_name             default null
  , i_display_order     in      com_api_type_pkg.t_tiny_id          default null
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
  , i_short_desc        in      com_api_type_pkg.t_short_desc       default null
  , i_full_desc         in      com_api_type_pkg.t_full_desc        default null
) is 
    l_parameter         t_param_rec;
begin
    
    l_parameter.name            := i_name;
    l_parameter.module_code     := i_module_code;
    l_parameter.lowest_level    := i_lowest_level;
    l_parameter.default_value   := i_default_value;
    l_parameter.data_type       := i_data_type;
    l_parameter.lov_id          := i_lov_id;
    l_parameter.display_order   := i_display_order;

    register_parameter(
        i_parameter         => l_parameter
      , i_group_name        => i_group_name
      , i_lang              => i_lang
      , i_short_desc        => i_short_desc
      , i_full_desc         => i_full_desc
    );
end;
    
procedure unregister_parameter(
    i_param_name        in      com_api_type_pkg.t_name
) is
    l_param_id          com_api_type_pkg.t_short_id;
    l_child_count       pls_integer;
begin
    begin        
        select id
          into l_param_id
          from set_parameter
         where name = upper(i_param_name);
    exception
        when no_data_found then
            com_api_error_pkg.raise_error('PARAM_NOT_EXISTS', upper(i_param_name));
    end;
        
    select count(*)
      into l_child_count
      from set_parameter
     where parent_id = l_param_id;
         
    if l_child_count > 0 then
        com_api_error_pkg.raise_error('PARAM_GROUP_HAS_CHILD', upper(i_param_name));
    end if;
        
    delete from set_parameter_value where param_id = l_param_id;
        
    delete from set_parameter where id = l_param_id;
        
end;
    
procedure register_param_desc(
    i_param_name        in      com_api_type_pkg.t_name
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_short_desc        in      com_api_type_pkg.t_short_desc
  , i_full_desc         in      com_api_type_pkg.t_full_desc        default null
) is
    l_param_id          com_api_type_pkg.t_short_id;
begin
    begin        
        select id
          into l_param_id
          from set_parameter
         where name = upper(i_param_name);
    exception
        when no_data_found then
            com_api_error_pkg.raise_error('PARAM_NOT_EXISTS', upper(i_param_name));
    end;
        
    if i_short_desc is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'set_parameter'
          , i_column_name   => 'caption'
          , i_object_id     => l_param_id
          , i_lang          => i_lang
          , i_text          => i_short_desc
        );
    end if;
        
    if i_full_desc is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'set_parameter'
          , i_column_name   => 'description'
          , i_object_id     => l_param_id
          , i_lang          => i_lang
          , i_text          => i_full_desc
        );
    end if;
        
end;
    
end;
/
