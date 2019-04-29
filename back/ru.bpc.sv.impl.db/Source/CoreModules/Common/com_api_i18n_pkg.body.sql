create or replace package body com_api_i18n_pkg as

function get_text(
    i_table_name        in      com_api_type_pkg.t_oracle_name
  , i_column_name       in      com_api_type_pkg.t_oracle_name
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
) return com_api_type_pkg.t_text is
    l_result            com_api_type_pkg.t_text;
    l_user_lang         com_api_type_pkg.t_dict_value;
begin
    if i_table_name is null or i_column_name is null or i_object_id is null then
        return null;
    end if;

    l_user_lang := com_ui_user_env_pkg.get_user_lang;

    select text
      into l_result
      from com_i18n_vw
     where table_name  = upper(i_table_name)
       and column_name = upper(i_column_name)
       and object_id   = i_object_id
       and lang        = nvl(i_lang, l_user_lang);

    return l_result;

exception
    when no_data_found then
        begin
            select text
              into l_result
              from com_i18n_vw
             where table_name  = upper(i_table_name)
               and column_name = upper(i_column_name)
               and object_id   = i_object_id
               and lang        = 'LANGENG';

            return l_result;
        exception
            when no_data_found then
                begin
                    select text
                      into l_result
                      from com_i18n_vw
                     where table_name  = upper(i_table_name)
                       and column_name = upper(i_column_name)
                       and object_id   = i_object_id
                       and rownum      = 1;

                    return l_result;
                exception
                    when no_data_found then
                        return null;
                end;
        end;
end get_text;

procedure add_text(
    i_table_name    in      com_api_type_pkg.t_oracle_name
  , i_column_name   in      com_api_type_pkg.t_oracle_name
  , i_object_id     in      com_api_type_pkg.t_long_id
  , i_text          in      com_api_type_pkg.t_text
  , i_lang          in      com_api_type_pkg.t_dict_value   default null
  , i_check_unique  in      com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
) is
    l_result        com_api_type_pkg.t_desc_id;
    l_count         com_api_type_pkg.t_tiny_id;
    l_entity_type   com_api_type_pkg.t_dict_value;
    l_text          com_api_type_pkg.t_text;
    l_lang          com_api_type_pkg.t_dict_value;
begin
    if i_text is null then
        return;
    end if;

    l_lang := coalesce(i_lang, com_ui_user_env_pkg.get_user_lang());
--    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.add_text: i_table_name [' || i_table_name
--                                          || '], i_column_name [' || i_column_name
--                                          || '], i_object_id [' || i_object_id
--                                          || '], i_text [' || i_text
--                                          || '], i_check_unique [' || i_check_unique
--                                          || '], l_lang [' || l_lang || ']');

    if nvl(i_check_unique, com_api_type_pkg.FALSE) = com_api_type_pkg.TRUE then
        select count(*)
          into l_count
          from com_i18n_vw
         where table_name  = upper(i_table_name)
           and column_name = upper(i_column_name)
           and text        = i_text
           and object_id   != i_object_id
--           and lang        = l_lang
           ;
        if l_count > 0 then
            select min(entity_type)
              into l_entity_type
              from adt_entity
             where table_name = i_table_name;

            if l_entity_type is not null then
                com_api_error_pkg.raise_error(
                    i_error       => 'DUPLICATE_DESCRIPTION'
                  , i_env_param1  => upper(l_entity_type)
                  , i_env_param2  => upper(i_column_name)
                  , i_env_param3  => i_text
                );
            else
                com_api_error_pkg.raise_error(
                    i_error       => 'DESCRIPTION_IS_NOT_UNIQUE'
                  , i_env_param1  => upper(i_table_name)
                  , i_env_param2  => upper(i_column_name)
                  , i_env_param3  => i_text
                );
            end if;
        end if;
    end if;

    select id
         , text
      into l_result
         , l_text
      from com_i18n_vw
     where table_name  = upper(i_table_name)
       and column_name = upper(i_column_name)
       and object_id   = i_object_id
       and lang        = l_lang;

    update com_i18n_vw
       set text      = nvl(i_text, text)
     where id        = l_result
       and not (text = i_text or i_text is null);

    if sql%rowcount > 0 then
        adt_api_trail_pkg.modify_com_18n(
            i_trail_id              => adt_api_trail_pkg.g_trail_id
          , i_table_name            => i_table_name
          , i_column_name           => i_column_name
          , i_object_id             => i_object_id
          , i_old_value             => l_text
          , i_new_value             => nvl(i_text, l_text)
          , i_action_type           => 'UPDATE'
          , i_lang                  => l_lang
        );
    end if;

exception
    when no_data_found then
        insert into com_i18n_vw (
            id
          , table_name
          , column_name
          , object_id
          , entity_type
          , lang
          , text
        ) values (
            com_i18n_seq.nextval
          , upper(i_table_name)
          , upper(i_column_name)
          , i_object_id
          , null
          , l_lang
          , i_text
        );
        adt_api_trail_pkg.modify_com_18n(
            i_trail_id              => adt_api_trail_pkg.g_trail_id
          , i_table_name            => i_table_name
          , i_column_name           => i_column_name
          , i_object_id             => i_object_id
          , i_old_value             => null
          , i_new_value             => nvl(i_text, l_text)
          , i_action_type           => 'INSERT'
          , i_lang                  => l_lang
        );
end add_text;

procedure remove_text(
    i_table_name        in      com_api_type_pkg.t_oracle_name
  , i_object_id         in      com_api_type_pkg.t_long_id
) is
begin
    delete from com_i18n_vw
     where table_name  = upper(i_table_name)
       and object_id   = i_object_id;
end remove_text;

procedure remove_text(
    i_table_name        in      com_api_type_pkg.t_oracle_name
  , i_column_name       in      com_api_type_pkg.t_oracle_name
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_lang              in      com_api_type_pkg.t_dict_value   default null
) is
    l_lang              com_api_type_pkg.t_dict_value;
begin
    l_lang := coalesce(i_lang, com_ui_user_env_pkg.get_user_lang());
    delete from com_i18n_vw
     where table_name  = upper(i_table_name)
       and column_name = upper(i_column_name)
       and object_id   = i_object_id
       and lang        = l_lang;
end remove_text;

/*
 * Function returns TRUE if text <i_text> already exists for (i_table_name, i_column_name, i_inst_id) in COM_I18N.
 * Despite of procedure <add_text> in the package with flag i_check_unique => TRUE,
 * this function provides checking only within the institute <i_inst_id> if it is defined.
 * Otherwise it executes the same check as used in <add_text> one.
 */
function text_is_present(
    i_table_name    in      com_api_type_pkg.t_oracle_name
  , i_column_name   in      com_api_type_pkg.t_oracle_name
  , i_inst_id       in      com_api_type_pkg.t_inst_id
  , i_text          in      com_api_type_pkg.t_text
  , i_lang          in      com_api_type_pkg.t_dict_value   default null
) return com_api_type_pkg.t_boolean
is
    LOG_PREFIX              constant com_api_type_pkg.t_text := lower($$PLSQL_UNIT) || '.text_is_present: ';
    COLUMN_INST_ID          constant com_api_type_pkg.t_name := 'INST_ID';
    COLUMN_INST_ID_DATATYPE constant com_api_type_pkg.t_name := 'NUMBER';
    CR_LF                   constant com_api_type_pkg.t_name := chr(13) || chr(10);
    SELECT_TEMPLATE         constant com_api_type_pkg.t_text := '
        select t.id
          from @TABLE@ t
          join com_i18n i on i.object_id = t.id
         where i.table_name = upper(:i_table_name)
           and i.column_name = upper(:i_column_name)
           and i.text = :i_text
           and i.lang = :i_lang';
    CONDITION_FOR_INSTITUTE constant com_api_type_pkg.t_text := '
           and t.inst_id = :i_inst_id';

    l_column_name           com_api_type_pkg.t_oracle_name;
    l_id                    com_api_type_pkg.t_long_id;
    l_result                com_api_type_pkg.t_boolean;
    l_lang                  com_api_type_pkg.t_dict_value;
begin
    l_lang := coalesce(i_lang, com_ui_user_env_pkg.get_user_lang());

    -- If institute isn't defined as input parameter or doesn't present in the table then it should be ignored
    if i_inst_id is not null then
        begin
            select c.column_name
              into l_column_name
              from user_tab_cols c
             where c.table_name = upper(i_table_name)
               and c.column_name = COLUMN_INST_ID
               and c.data_type = COLUMN_INST_ID_DATATYPE;
        exception
            when no_data_found then
                trc_log_pkg.debug(
                    i_text       => LOG_PREFIX || 'table [#1] has no field [#2] so that i_inst_id value [#3] will be ignored'
                  , i_env_param1 => i_table_name
                  , i_env_param2 => COLUMN_INST_ID
                  , i_env_param3 => i_inst_id
                );
        end;
    end if;

    declare
        l_sql_statement         com_api_type_pkg.t_text;
    begin
        l_sql_statement := replace(SELECT_TEMPLATE, '@TABLE@', lower(i_table_name));

        if l_column_name is null then -- field INST_ID is NOT present
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'l_sql_statement [#1' || CR_LF
                             || '] with column [#2], inst_id [#3], text [#4], lang [#5]'
              , i_env_param1 => substr(l_sql_statement, 1, 2000)
              , i_env_param2 => i_column_name
              , i_env_param3 => i_inst_id
              , i_env_param4 => i_text
              , i_env_param5 => l_lang
            );
            execute immediate l_sql_statement into l_id
            using i_table_name, i_column_name, i_text, l_lang;
        else
            l_sql_statement := l_sql_statement || CONDITION_FOR_INSTITUTE;
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'l_sql_statement [#1' || CR_LF
                             || '] with column [#2], inst_id [#3], text [#4], lang [#5]'
              , i_env_param1 => substr(l_sql_statement, 1, 2000)
              , i_env_param2 => i_column_name
              , i_env_param3 => i_inst_id
              , i_env_param4 => i_text
              , i_env_param5 => l_lang
            );
            execute immediate l_sql_statement into l_id
            using i_table_name, i_column_name, i_text, l_lang, i_inst_id;
        end if;

        l_result := com_api_type_pkg.TRUE;

    exception
        when no_data_found then
            l_result := com_api_type_pkg.FALSE;
        when too_many_rows then
            l_result := com_api_type_pkg.TRUE;
    end;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'l_id [#1], l_result [#2]'
      , i_env_param1 => l_id
      , i_env_param2 => case when l_result = com_api_type_pkg.TRUE then 'TRUE' else 'FALSE' end
    );

    return l_result;

exception
    when others then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'FAILED with table [#1], column [#2], inst_id [#3], text [#4], lang [#5]'
          , i_env_param1 => i_table_name
          , i_env_param2 => i_column_name
          , i_env_param3 => i_inst_id
          , i_env_param4 => i_text
          , i_env_param5 => l_lang
        );
        raise;
end text_is_present;

procedure check_text_for_latin(
    i_text                  in com_api_type_pkg.t_text
) is
    l_forbidden_symbol com_api_type_pkg.t_text;
begin
    if com_cst_i18n_pkg.check_text_for_latin = com_api_const_pkg.FALSE then
        return;
    end if;

    select regexp_substr(i_text, '[^]a-zA-Z0-9 !"#$%&''()*+,-./:;<=>?@\[_^`{|}~]')
      into l_forbidden_symbol
      from dual;

    if l_forbidden_symbol is not null then
        com_api_error_pkg.raise_error(
            i_error             => 'NO_LATIN_SYMBOL_IN_TEXT'
          , i_env_param1        => l_forbidden_symbol
          , i_env_param2        => i_text
        );
    end if;
end check_text_for_latin;

procedure load_translation(
    i_src_lang      in     com_api_type_pkg.t_dict_value -- Source language
  , i_dst_lang      in     com_api_type_pkg.t_dict_value -- Destination language
  , i_text_trans    in     com_text_trans_tpt            -- Translation text (table of t)
) is
    LOG_PREFIX             constant com_api_type_pkg.t_text := lower($$PLSQL_UNIT) || '.load_translation: ';
    l_ins_cnt              number := 0;
    l_upd_cnt              number := 0;
    l_nth_cnt              number := 0;
begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'translation start with i_src_lang [#1], i_dst_lang [#2]'
      , i_env_param1 => i_src_lang
      , i_env_param2 => i_dst_lang
    );
    for j in (select s.id
                   , d.id dst_id
                   , s.lang
                   , s.entity_type
                   , s.table_name
                   , s.column_name
                   , s.object_id
                   , s.text srt_text_tbl
                   , d.text dst_text_tbl
                   , t.src_text
                   , t.dst_text
                from table(cast(i_text_trans as com_text_trans_tpt)) t
           left join com_i18n s on s.text = t.src_text
                               and s.lang = i_src_lang
           left join com_i18n d on s.table_name  = d.table_name
                               and s.column_name = d.column_name
                               and s.object_id   = d.object_id
                               and d.lang = i_dst_lang)
    loop
        case
            when j.id is null
                then
                    trc_log_pkg.warn(
                        i_text       => LOG_PREFIX || 'src_text [#1], dst_text [#2], i_src_lang [#3], i_dst_lang [#4]'
                      , i_env_param1 => substr(j.src_text,1,2000)
                      , i_env_param2 => substr(j.dst_text,1,200)
                      , i_env_param3 => i_src_lang
                      , i_env_param4 => i_dst_lang
                    );
                    com_api_error_pkg.raise_error(
                        i_error      => 'NO_SRC_TEXT'
                      , i_env_param1 => substr(j.src_text,1,2000)
                    );
            when j.dst_id is null -- insert new translation
                then com_api_i18n_pkg.add_text(
                         i_table_name   => j.table_name
                       , i_column_name  => j.column_name
                       , i_object_id    => j.object_id
                       , i_text         => j.dst_text
                       , i_lang         => i_dst_lang
                       , i_check_unique => com_api_type_pkg.TRUE
                     );
                     l_ins_cnt := l_ins_cnt + 1;
            when j.dst_text_tbl != j.dst_text -- update destination text
                then com_api_i18n_pkg.add_text(
                         i_table_name   => j.table_name
                       , i_column_name  => j.column_name
                       , i_object_id    => j.object_id
                       , i_text         => j.dst_text
                       , i_lang         => i_dst_lang
                       , i_check_unique => com_api_type_pkg.FALSE
                     );
                     l_upd_cnt := l_upd_cnt + 1;
            else l_nth_cnt := l_nth_cnt + 1; -- nothing to change
        end case;

    end loop;
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'translation complete: inserts - [#1], updates - [#2], nothing changes [#3]'
      , i_env_param1 => l_ins_cnt
      , i_env_param2 => l_upd_cnt
      , i_env_param3 => l_nth_cnt
    );
end load_translation;

end com_api_i18n_pkg;
/
