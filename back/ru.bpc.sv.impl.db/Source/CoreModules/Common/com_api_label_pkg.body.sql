create or replace package body com_api_label_pkg as
/*
 * API for labels <br />
 * Created by Filimonov A.(filimonov@bpc.ru)  at 27.11.2009
 * Module: COM_API_LABEL_PKG
 * @headcom
 */

procedure register_label(
    i_name              in      com_api_type_pkg.t_short_desc
  , i_label_type        in      com_api_type_pkg.t_dict_value
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_module_code       in      com_api_type_pkg.t_module_code  
  , i_short_desc        in      com_api_type_pkg.t_short_desc
  , i_full_desc         in      com_api_type_pkg.t_full_desc        default null
  , i_env_var1          in      com_api_type_pkg.t_name             default null
  , i_env_var2          in      com_api_type_pkg.t_name             default null
  , i_env_var3          in      com_api_type_pkg.t_name             default null
  , i_env_var4          in      com_api_type_pkg.t_name             default null
  , i_env_var5          in      com_api_type_pkg.t_name             default null
  , i_env_var6          in      com_api_type_pkg.t_name             default null
) is
    l_label_id          com_api_type_pkg.t_short_id;
    l_env_text          com_api_type_pkg.t_name;
begin

    if i_env_var1 is not null then
        l_env_text := i_env_var1;
        if i_env_var2 is not null then
            l_env_text := l_env_text || ', ' || i_env_var2;
            if i_env_var3 is not null then
                l_env_text := l_env_text || ', ' || i_env_var3;
                if i_env_var4 is not null then
                    l_env_text := l_env_text || ', ' || i_env_var4;
                    if i_env_var5 is not null then
                        l_env_text := l_env_text || ', ' || i_env_var5;
                        if i_env_var6 is not null then
                            l_env_text := l_env_text || ', ' || i_env_var6;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end if;
    
    begin
        insert into com_label (
            id
          , name
          , label_type
          , module_code
          , env_variable
        ) values (
            com_label_seq.nextval
          , i_name
          , upper(i_label_type)
          , upper(i_module_code)
          , l_env_text
        ) returning id into l_label_id;
    exception
        when dup_val_on_index then
            select id 
              into l_label_id
              from com_label
             where upper(name) = upper(i_name);
    end;
            
    com_api_i18n_pkg.add_text(
        i_table_name    => 'com_label'
      , i_column_name   => 'name'
      , i_object_id     => l_label_id
      , i_lang          => i_lang
      , i_text          => i_short_desc
    );
    
    if i_full_desc is not null then     
      com_api_i18n_pkg.add_text(
          i_table_name    => 'com_label'
        , i_column_name   => 'description'
        , i_object_id     => l_label_id
        , i_lang          => i_lang
        , i_text          => i_full_desc
      );
    end if;    
end;

function get_label_text(
    i_name              in      com_api_type_pkg.t_short_desc
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
  , i_text_field_name   in      com_api_type_pkg.t_name             default null
) return com_api_type_pkg.t_short_desc is 
    l_result             com_api_type_pkg.t_short_desc;
    l_text_field_name    com_api_type_pkg.t_name := nvl(i_text_field_name, com_api_const_pkg.TEXT_IN_NAME);
begin
    select com_api_i18n_pkg.get_text('com_label', l_text_field_name, id, i_lang)
      into l_result
      from com_label a
     where upper(a.name) = upper(i_name);
     
    return l_result;
     
exception
    when no_data_found then
        return i_name;     
end;

end;
/
