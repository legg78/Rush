create or replace package body com_ui_dictionary_pkg as
/*********************************************************
*  UI for dictionary <br />
*  Created by Fomichev A.(fomichev@bpc.ru)  at 18.08.2010 <br />
*  Last changed by $Author: Fomichev $ <br />
*  $LastChangedDate:: 2010-06-07 16:20:00 +0400#$ <br />
*  Revision: $LastChangedRevision: 2432 $ <br />
*  Module: com_ui_dictionary_pkg <br />
*  @headcom
**********************************************************/

procedure add_dictionary (
    i_code              in      com_api_type_pkg.t_dict_value
  , i_short_desc        in      com_api_type_pkg.t_short_desc
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_is_numeric        in      com_api_type_pkg.t_boolean          default com_api_type_pkg.FALSE
  , i_is_editable       in      com_api_type_pkg.t_boolean          default com_api_type_pkg.FALSE
  , i_module_code       in      com_api_type_pkg.t_dict_value       default null
) is
begin
    add_article (
        i_dict          => 'DICT'
      , i_code          => i_code
      , i_short_desc    => i_short_desc
      , i_lang          => i_lang
      , i_is_numeric    => i_is_numeric
      , i_is_editable   => i_is_editable
      , i_module_code   => i_module_code
    );
end;

procedure add_article (
    i_dict         in      com_api_type_pkg.t_dict_value
  , i_code         in      com_api_type_pkg.t_dict_value
  , i_short_desc   in      com_api_type_pkg.t_short_desc
  , i_full_desc    in      com_api_type_pkg.t_full_desc   default null
  , i_lang         in      com_api_type_pkg.t_dict_value
  , i_is_numeric   in      com_api_type_pkg.t_boolean     default com_api_type_pkg.FALSE
  , i_is_editable  in      com_api_type_pkg.t_boolean     default com_api_type_pkg.FALSE
  , i_module_code  in      com_api_type_pkg.t_dict_value  default null
) is
    l_dict_id           com_api_type_pkg.t_short_id;
    l_is_numeric        com_api_type_pkg.t_boolean;
    l_count             pls_integer;
    l_module_code       com_api_type_pkg.t_dict_value := i_module_code;
begin
    if i_dict != 'DICT' then
        begin
            select is_numeric
              into l_is_numeric
              from com_dictionary
             where dict = 'DICT'
               and code = upper(i_dict);
        exception
            when no_data_found then
                com_api_error_pkg.raise_error('DICTIONARY_NOT_EXISTS', upper(i_dict));
        end;
    else
        l_is_numeric := i_is_numeric;
    end if;

    if l_is_numeric = com_api_type_pkg.TRUE and i_dict != 'DICT' then
        declare
            l_number_value    com_api_type_pkg.t_tiny_id;
        begin
            l_number_value := to_number(i_code);
        exception
            when com_api_error_pkg.e_value_error then -- character to number conversion error
                com_api_error_pkg.raise_error(
                    i_error      => 'DICT_CODE_IS_NOT_NUMERIC'
                  , i_env_param1 => upper(i_code)
                );
        end;
    end if;

    select id
      into l_dict_id
      from com_dictionary_vw
     where dict = i_dict
       and code = i_code;

    com_api_error_pkg.raise_error(
        i_error         => 'CODE_ALREADY_EXISTS_IN_DICT'
      , i_env_param1    => i_code
      , i_env_param2    => i_dict
    );
exception
    when no_data_found then
        select com_dictionary_seq.nextval into l_dict_id from dual;

        -- get module code
        if trim(l_module_code) is null then
            select count(*)
              into l_count
              from com_module
             where dict_code = substr(i_code, 1, 2);

            if l_count > 0 then
                select module_code
                  into l_module_code
                  from com_module
                 where dict_code = substr(i_code, 1, 2);
            end if;
        end if;

        insert into com_dictionary_vw (
            id
          , dict
          , code
          , is_numeric
          , is_editable
          , inst_id
          , module_code
        ) values (
            l_dict_id
          , i_dict
          , i_code
          , l_is_numeric
          , i_is_editable
          , acm_api_user_pkg.get_user_sandbox
          , l_module_code
        );

        select count(*)
          into l_count
          from com_i18n_vw a
             , com_dictionary b
         where table_name  = 'COM_DICTIONARY'
           and column_name = 'NAME'
           and text        = i_short_desc
           and object_id  != l_dict_id
           and object_id  in (select id from com_dictionary where dict = i_dict);

        if l_count > 0 then
            com_api_error_pkg.raise_error(
                i_error       => 'DESCRIPTION_IS_NOT_UNIQUE'
              , i_env_param1  => 'COM_DICTIONARY'
              , i_env_param2  => 'NAME'
              , i_env_param3  => i_short_desc
            );
        end if;

        com_api_i18n_pkg.add_text(
            i_table_name   => 'COM_DICTIONARY'
          , i_column_name  => 'NAME'
          , i_object_id    => l_dict_id
          , i_lang         => i_lang
          , i_text         => i_short_desc
        );

        com_api_i18n_pkg.add_text(
            i_table_name   => 'COM_DICTIONARY'
          , i_column_name  => 'DESCRIPTION'
          , i_object_id    => l_dict_id
          , i_lang         => i_lang
          , i_text         => i_full_desc
        );
end;

procedure modify_article (
    i_dict         in      com_api_type_pkg.t_dict_value
  , i_code         in      com_api_type_pkg.t_dict_value
  , i_short_desc   in      com_api_type_pkg.t_short_desc
  , i_full_desc    in      com_api_type_pkg.t_full_desc   default null
  , i_lang         in      com_api_type_pkg.t_dict_value
  , i_module_code  in      com_api_type_pkg.t_dict_value  default null
) is
    l_dict_id           com_api_type_pkg.t_short_id;
    l_is_numeric        com_api_type_pkg.t_boolean;
    l_count             pls_integer;
    l_module_code       com_api_type_pkg.t_dict_value := i_module_code;
begin
    if i_dict != 'DICT' then
        begin
            select is_numeric
              into l_is_numeric
              from com_dictionary_vw
             where dict = 'DICT'
               and code = upper(i_dict);
        exception
            when no_data_found then
                com_api_error_pkg.raise_error('DICTIONARY_NOT_EXISTS', upper(i_dict));
        end;
    end if;

    select id
      into l_dict_id
      from com_dictionary_vw
     where dict = i_dict
       and code = i_code;

    select count(*)
      into l_count
      from com_i18n_vw a
         , com_dictionary b
     where table_name  = 'COM_DICTIONARY'
       and column_name = 'NAME'
       and text        = i_short_desc
       and object_id  != l_dict_id
       and object_id  in (select id from com_dictionary where dict = i_dict);

    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error       => 'DESCRIPTION_IS_NOT_UNIQUE'
          , i_env_param1  => 'COM_DICTIONARY'
          , i_env_param2  => 'NAME'
          , i_env_param3  => i_short_desc
        );
    end if;

    com_api_i18n_pkg.add_text(
        i_table_name   => 'COM_DICTIONARY'
      , i_column_name  => 'NAME'
      , i_object_id    => l_dict_id
      , i_lang         => i_lang
      , i_text         => i_short_desc
    );

    com_api_i18n_pkg.add_text(
        i_table_name   => 'COM_DICTIONARY'
      , i_column_name  => 'DESCRIPTION'
      , i_object_id    => l_dict_id
      , i_lang         => i_lang
      , i_text         => i_full_desc
    );
    
    -- get module code
    if trim(l_module_code) is null then
        select count(*)
          into l_count
          from com_module
         where dict_code = substr(i_code, 1, 2);

        if l_count > 0 then
            select module_code
              into l_module_code
              from com_module
             where dict_code = substr(i_code, 1, 2);
        end if;
    end if;
    
    update com_dictionary 
       set module_code = l_module_code
     where id = l_dict_id;
        
exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error        => 'CODE_NOT_EXISTS_IN_DICT'
          , i_env_param1   => i_code
          , i_env_param2   => i_dict
        );
end;

procedure remove_article (
    i_dict        in      com_api_type_pkg.t_dict_value
  , i_code        in      com_api_type_pkg.t_dict_value
  , i_is_leaf     in      com_api_type_pkg.t_boolean      default null
) is
    l_count       com_api_type_pkg.t_short_id;
begin
    if nvl(i_is_leaf, com_api_type_pkg.FALSE) = com_api_type_pkg.FALSE then
        select count(id)
          into l_count
          from com_dictionary_vw
         where dict = i_dict
           and code = i_code
           and is_editable = com_api_type_pkg.FALSE;

        if l_count > 0 then
            com_api_error_pkg.raise_error(
                i_error      => 'CANNOT_DELETE_DICTIONARY'
              , i_env_param1 => i_dict
              , i_env_param2 => i_code
            );
        end if;
    end if;

    if i_dict = 'DICT' then
        for dict in (
            select code
              from com_dictionary_vw
             where dict = i_code
        ) loop
            remove_article(
                i_dict     => i_code
              , i_code     => dict.code
              , i_is_leaf  => com_api_type_pkg.TRUE
            );
        end loop;
    end if;

    declare
        l_article_id    com_api_type_pkg.t_short_id;
    begin
        select id
          into l_article_id
          from com_dictionary_vw
         where dict = i_dict
           and code = i_code;

        delete from com_dictionary_vw
         where id = l_article_id;

        com_api_i18n_pkg.remove_text(
            i_table_name => 'COM_DICTIONARY'
          , i_object_id  => l_article_id
        );
    exception
        when no_data_found then
            if i_dict = 'DICT' then
                com_api_error_pkg.raise_error(
                    i_error      => 'DICTIONARY_ALREADY_DELETED'
                  , i_env_param1 => i_dict||i_code
                );
            else
                com_api_error_pkg.raise_error(
                    i_error      => 'CODE_NOT_EXISTS_IN_DICT'
                  , i_env_param1 => i_dict||i_code
                  , i_env_param2 => i_dict
                );
            end if;
    end;
end;

end;
/
