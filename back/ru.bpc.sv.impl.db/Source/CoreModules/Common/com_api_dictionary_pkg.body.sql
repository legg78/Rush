create or replace package body com_api_dictionary_pkg as

MIN_LENGTH_DICT_VALUE  constant pls_integer := 5;
MAX_LENGTH_DICT_VALUE  constant pls_integer := 8;

procedure check_article(
    i_dict              in      com_api_type_pkg.t_dict_value
  , i_code              in      com_api_type_pkg.t_dict_value
) is
    l_code              com_api_type_pkg.t_dict_value;
begin
    if i_dict != 'DICT' then
        begin
            select code
              into l_code
              from com_dictionary
             where dict = 'DICT'
               and code = upper(i_dict);
        exception
            when no_data_found then
                com_api_error_pkg.raise_error('DICTIONARY_NOT_EXISTS', upper(i_dict));
        end;
    end if;

    if i_code not like i_dict||'____' then
        com_api_error_pkg.raise_error(
            i_error         => 'CODE_NOT_CORRESPOND_TO_DICT'
          , i_env_param1    => i_code
          , i_env_param2    => i_dict
        );
    end if;

    begin
        select code
          into l_code
          from com_dictionary
         where dict = i_dict
           and code = substr(i_code, 5);
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'CODE_NOT_EXISTS_IN_DICT'
              , i_env_param1    => i_code
              , i_env_param2    => i_dict
            );
    end;
end;

function check_article(
    i_dict              in      com_api_type_pkg.t_dict_value
  , i_code              in      com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_boolean
is
    l_code              com_api_type_pkg.t_dict_value;
begin
    if i_dict != 'DICT' then
        begin
            select code
              into l_code
              from com_dictionary
             where dict = 'DICT'
               and code = upper(i_dict);
        exception
            when no_data_found then
                trc_log_pkg.error(
                    i_text => 'DICTIONARY_NOT_EXISTS'
                    , i_env_param1 => upper(i_dict)
                );
                return com_api_type_pkg.false;
        end;
    end if;

    if i_code not like i_dict||'____' then
        trc_log_pkg.error(
            i_text => 'CODE_NOT_CORRESPOND_TO_DICT'
            , i_env_param1    => i_code
            , i_env_param2    => i_dict
        );
        return com_api_type_pkg.false;
    end if;

    begin
        select code
          into l_code
          from com_dictionary
         where dict = i_dict
           and code = substr(i_code, 5);
    exception
        when no_data_found then
            trc_log_pkg.error(
                i_text => 'CODE_NOT_EXISTS_IN_DICT'
                , i_env_param1    => i_code
                , i_env_param2    => i_dict
            );
            return com_api_type_pkg.false;
    end;
    --
    return com_api_type_pkg.true;
end;

procedure get_dictionary_dml (
    i_dict              in      com_api_type_pkg.t_dict_value,
    io_dml              in out  sys_refcursor
) is
begin
    open io_dml for
        select
            'insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values ('
                || ds.id || ', '''
                || ds.lang || ''', '''
                || ds.entity_type || ''', '''
                || ds.table_name || ''', '''
                || ds.column_name || ''', '
                || ds.object_id || ', '''
                || ds.text || ''')' || chr(10) || '/'
        from
            com_i18n ds,
            com_dictionary di
        where
            di.dict = 'DICT' and
            di.code = i_dict and
            di.id = ds.object_id and
            ds.table_name = 'COM_DICTIONARY' and
            ds.lang = get_def_lang
        union all
        select
            'insert into com_dictionary (id, dict, code, is_numeric, is_editable) values ('
                || id || ', '''
                || dict || ''', '''
                || code || ''', '
                || is_numeric || ', '
                || is_editable || ')' || chr(10) || '/'
        from
            com_dictionary di
        where
            di.dict = 'DICT' and
            di.code = i_dict
        union all
        select
            'insert into com_i18n (id, lang, entity_type, table_name, column_name, object_id, text) values ('
                || ds.id || ', '''
                || ds.lang || ''', '''
                || ds.entity_type || ''', '''
                || ds.table_name || ''', '''
                || ds.column_name || ''', '
                || ds.object_id || ', '''
                || ds.text || ''')'  || chr(10) || '/'
        from
            com_i18n ds,
            com_dictionary di
        where
            di.dict = i_dict and
            di.id = ds.object_id and
            ds.table_name = 'COM_DICTIONARY' and
            ds.lang = get_def_lang
        union all
        select
            'insert into com_dictionary (id, dict, code, is_numeric, is_editable) values ('
                || id || ', '''
                || dict || ''', '''
                || code || ''', '
                || is_numeric || ', '
                || is_editable || ')'  || chr(10) || '/'
        from
            com_dictionary di
        where
            di.dict = i_dict;
end;

function get_article_text(
    i_article           in      com_api_type_pkg.t_dict_value
  , i_lang              in      com_api_type_pkg.t_dict_value   default null
) return com_api_type_pkg.t_short_desc is
    l_article_id        com_api_type_pkg.t_short_id;
begin
    if i_article is null then
        return null;
    end if;

    if length(i_article) between MIN_LENGTH_DICT_VALUE and MAX_LENGTH_DICT_VALUE then
        l_article_id := get_article_id_by_code(
                            i_code => i_article
                        );
    end if;

    if l_article_id is null then
        return i_article;
    end if;

    return nvl(com_api_i18n_pkg.get_text('com_dictionary', 'name', l_article_id, nvl(i_lang, com_ui_user_env_pkg.get_user_lang)), i_article);

exception
    when no_data_found then
        return i_article;
end;

function get_article_desc(
    i_article           in      com_api_type_pkg.t_dict_value
  , i_lang              in      com_api_type_pkg.t_dict_value   default null
) return com_api_type_pkg.t_text is
    l_article_id        com_api_type_pkg.t_short_id;
    l_result            com_api_type_pkg.t_text;
begin
    if i_article is null then
        return null;
    end if;

    if length(i_article) between MIN_LENGTH_DICT_VALUE and MAX_LENGTH_DICT_VALUE then
        l_article_id := get_article_id_by_code(
                            i_code => i_article
                        );
    end if;

    if l_article_id is null then
        return i_article;
    end if;

    l_result := com_api_i18n_pkg.get_text('com_dictionary', 'description', l_article_id, nvl(i_lang, com_ui_user_env_pkg.get_user_lang));

    if l_result is null then
        l_result := com_api_i18n_pkg.get_text('com_dictionary', 'name', l_article_id, nvl(i_lang, com_ui_user_env_pkg.get_user_lang));
    end if;

    if l_result is null then
        l_result := i_article;
    end if;

    return l_result;
exception
    when no_data_found then
        return i_article;
end;


function get_article_id(
    i_article           in      com_api_type_pkg.t_dict_value
  , i_lang              in      com_api_type_pkg.t_dict_value   default null
) return com_api_type_pkg.t_short_id is
    l_article_id        com_api_type_pkg.t_short_id;
begin
    select id
      into l_article_id
      from com_ui_dictionary_vw
     where dict   = upper(substr(i_article, 1, 4))
       and code   = upper(substr(i_article, 5))
       and lang   = nvl(i_lang, com_ui_user_env_pkg.get_user_lang)
       and rownum = 1;

    return l_article_id;
exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error         => 'CODE_NOT_EXISTS_IN_DICT'
          , i_env_param1    => upper(substr(i_article, 5))
          , i_env_param2    => upper(substr(i_article, 1, 4))
        );
end;

function get_article_id_by_code(
    i_code              in      com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_short_id
result_cache
relies_on (com_dictionary)
is
    l_article_id           com_api_type_pkg.t_short_id;
    l_dict                 com_api_type_pkg.t_dict_value;
    l_code                 com_api_type_pkg.t_dict_value;
begin
    if length(i_code) between MIN_LENGTH_DICT_VALUE and MAX_LENGTH_DICT_VALUE then

        l_dict := upper(substr(i_code, 1, 4));
        l_code := upper(substr(i_code, 5, 4));

        select id
          into l_article_id
          from com_dictionary
         where dict = l_dict
           and code = l_code;

    end if;

    return l_article_id;
exception
    when no_data_found then
        return null;
end;

function get_articles_list_desc(
    i_article_list      in      com_api_type_pkg.t_short_desc
  , i_len_article_part  in      com_api_type_pkg.t_byte_id      default null
  , i_text_in_begin     in      com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , i_lang              in      com_api_type_pkg.t_dict_value   default null
) return com_api_type_pkg.t_text
is
    l_result            com_api_type_pkg.t_text;
    l_value             com_api_type_pkg.t_text;
    l_separator         com_api_type_pkg.t_short_desc       := ', ';
    l_position          com_api_type_pkg.t_short_id;
    l_length            com_api_type_pkg.t_short_id         := abs(i_len_article_part);
    l_array             com_api_type_pkg.t_desc_tab;
begin
    case i_text_in_begin
        when com_api_const_pkg.TRUE then
            l_position := 1; 
        else 
            l_position := -1 * l_length; 
    end case;

    com_api_type_pkg.get_array_from_string(
        i_string    =>  i_article_list
      , o_array     =>  l_array
    );

    for idx in 1 .. l_array.count loop
        l_value := 
            case when i_len_article_part is not null then substr(l_array(idx), l_position, l_length) || ' - ' end ||
                com_api_dictionary_pkg.get_article_text(
                    i_article => l_array(idx)
                  , i_lang    => nvl(i_lang, com_ui_user_env_pkg.get_user_lang)
                );
        l_result := l_result || l_value || case when idx < l_array.count then l_separator end;
    end loop;

    return l_result;
end;

end;
/

