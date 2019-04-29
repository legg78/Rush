create or replace package body h2h_api_tag_pkg as
/*********************************************************
 *  Host-to-host tag API <br />
 *  Created by Alalykin A.(alalykin@bpcbt.com) at 20.02.2019 <br />
 *  Module: H2H_API_TAG_PKG <br />
 *  @headcom
 **********************************************************/

/*
 * Return H2H tags as a map in according to reference H2H_TAG:
 * a) H2H tag name as a key; 2) {H2H ID, FE tag ID} is a value.
 */
function get_tag_map return h2h_api_type_pkg.t_h2h_tag_tab
result_cache relies_on (h2h_tag, aup_tag)
is
    LOG_PREFIX                   constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_tag_map';
    l_tag_id_tab                          com_api_type_pkg.t_short_tab;
    l_fe_tag_id_tab                       com_api_type_pkg.t_short_tab;
    l_tag_name_tab                        com_api_type_pkg.t_name_tab;
    l_tag_tab                             h2h_api_type_pkg.t_h2h_tag_tab;
begin
    -- Check for incorrect associations (foreign key) to authorization tags reference
    for r in (
        select ht.id
             , upper(ht.tag) as tag -- consider H2H tags as case insensitive
             , ht.fe_tag_id
          from      h2h_tag ht
          left join aup_tag at    on at.tag = ht.fe_tag_id
         where ht.fe_tag_id is not null
           and at.tag       is null
           and rownum = 1
    ) loop
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'H2H_FE_TAG_IS_NOT_REGISTERED'
          , i_env_param1  => r.id
          , i_env_param2  => r.tag
          , i_env_param3  => r.fe_tag_id
        );
    end loop;

    select ht.id
         , ht.tag
         , ht.fe_tag_id
      bulk collect into
           l_tag_id_tab
         , l_tag_name_tab
         , l_fe_tag_id_tab
      from h2h_tag ht
     where ht.fe_tag_id is not null;

    for i in 1 .. l_tag_id_tab.count() loop
        -- Tag name is the key
        l_tag_tab(l_tag_name_tab(i)).tag_id    := l_tag_id_tab(i);
        l_tag_tab(l_tag_name_tab(i)).fe_tag_id := l_fe_tag_id_tab(i);

        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || ': caching a tag [No. #4] with ID [#1], name [#2], FE ID [#3]'
          , i_env_param1 => l_tag_id_tab(i)
          , i_env_param2 => l_tag_name_tab(i)
          , i_env_param3 => l_fe_tag_id_tab(i)
          , i_env_param4 => l_tag_tab.count()
        );
    end loop;

    return l_tag_tab;
end get_tag_map;

/*
 * Return tags as a map by incoming IPS in according to reference H2H_TAG:
 * a) H2H-tag name is a key; 2) IPS fin. message field name with tag details is a value.
 */
function get_ips_tag_map(
    i_ips_code              in            com_api_type_pkg.t_module_code
) return h2h_api_type_pkg.t_h2h_tag_tab
result_cache relies_on (h2h_tag)
is
    LOG_PREFIX                   constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_ips_tag_map';
    SELECT_STATEMENT             constant com_api_type_pkg.t_sql_statement :=
        'select id, tag, @FIELD_NAME@ from h2h_tag where @FIELD_NAME@ is not null';
    l_query                               com_api_type_pkg.t_sql_statement;
    l_tag_cursor                          sys_refcursor;
    l_tag_id_tab                          com_api_type_pkg.t_short_tab;
    l_tag_name_tab                        com_api_type_pkg.t_name_tab;
    l_ips_tag_tab                         com_api_type_pkg.t_name_tab;
    l_field_name                          com_api_type_pkg.t_oracle_name;
    l_tag_tab                             h2h_api_type_pkg.t_h2h_tag_tab;
    l_key                                 com_api_type_pkg.t_oracle_name;
    l_position                            com_api_type_pkg.t_tiny_id;
begin
    l_field_name := case i_ips_code
                        when h2h_api_const_pkg.MODULE_CODE_MASTERCARD then 'mcw_field'
                        when h2h_api_const_pkg.MODULE_CODE_VISA       then 'vis_field'
                        when h2h_api_const_pkg.MODULE_CODE_DINERS     then 'din_field'
                        when h2h_api_const_pkg.MODULE_CODE_JCB        then 'jcb_field'
                        when h2h_api_const_pkg.MODULE_CODE_AMEX       then 'amx_field'
                        when h2h_api_const_pkg.MODULE_CODE_MUP        then 'mup_field'
                    end;

    if l_field_name is null then
        com_api_error_pkg.raise_error(
            i_error      => 'H2H_IPS_MODULE_CODE_IS_NOT_SUPPORTED'
          , i_env_param1 => i_ips_code
        );
    end if;

    begin
        l_query := replace(SELECT_STATEMENT, '@FIELD_NAME@', l_field_name);

        open l_tag_cursor for l_query;
        fetch l_tag_cursor bulk collect into l_tag_id_tab, l_tag_name_tab, l_ips_tag_tab;
        close l_tag_cursor;
    exception
        when others then
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || ': failed to open/fetch cursor [#1] with exception [#2]'
              , i_env_param1 => l_query
              , i_env_param2 => sqlerrm
            );

            if l_tag_cursor%isopen then
                close l_tag_cursor;
            end if;

            raise;
    end;

    -- Field l_ips_tag_tab(i) may content either entire IPS field name or its extended version.
    -- In the 2nd case, after delimiter "|" there is a substring position or date format.
    -- For example tag SENDER_ADDRESS in the case of Mastercard should be taken from PDS with number 0670,
    -- position 25-55. Required configuration: h2h_tag.mcw_field = 'PDS_0670|25-55'.
    -- Another example is tag DEPART_DATE in the case of Visa. It should be saved in format MMDDYY and
    -- be taken from Visa field DEPARTURE_DATE which is stored as a date.
    -- Required configuration: h2h_tag.vis_field = 'DEPARTURE_DATE|dateMMDDYY'.
    for i in 1 .. l_tag_id_tab.count() loop
        begin
            l_key := l_tag_name_tab(i);

            l_tag_tab(l_key).tag_id := l_tag_id_tab(i);

            l_position := instr(l_ips_tag_tab(i), h2h_api_const_pkg.IPS_FIELD_DELIMITER);
            if nvl(l_position, 0) = 0 then
                l_tag_tab(l_key).ips_field := l_ips_tag_tab(i);
            else
                l_tag_tab(l_key).ips_field := substr(l_ips_tag_tab(i), 1, l_position - 1);
                -- IPS fin. message field substring position (when IPS tag is used partially)
                l_tag_tab(l_key).position := substr(l_ips_tag_tab(i), l_position + 1);
                -- Date format for the case when IPS field is present as a date
                l_position := instr(l_tag_tab(l_key).position, h2h_api_const_pkg.IPS_FIELD_DATE_DELIMITER);
                if nvl(l_position, 0) > 0 then
                    l_position := l_position + length(h2h_api_const_pkg.IPS_FIELD_DATE_DELIMITER);
                    l_tag_tab(l_key).date_format := substr(l_tag_tab(l_key).position, l_position);
                    l_tag_tab(l_key).position    := null;
                end if;
            end if;

            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || ': l_tag_tab(#1) = {tag_id [#2], ips_field [#3], position [#4], date_format [#5]}'
              , i_env_param1 => l_key
              , i_env_param2 => l_tag_tab(l_key).tag_id
              , i_env_param3 => l_tag_tab(l_key).ips_field
              , i_env_param4 => l_tag_tab(l_key).position
              , i_env_param5 => l_tag_tab(l_key).date_format
            );
        exception
            when others then
                trc_log_pkg.debug(
                    i_text       => LOG_PREFIX || ': failure on iteration [#1]: l_position [#2], l_key [#3]'
                                 || ', l_ips_tag_tab(i) [#4], l_tag_id_tab(i) [#5], l_tag_name_tab(i) [#6]'
                  , i_env_param1 => i
                  , i_env_param2 => l_position
                  , i_env_param3 => l_key
                  , i_env_param4 => l_ips_tag_tab(i)
                  , i_env_param5 => l_tag_id_tab(i)
                  , i_env_param6 => l_tag_name_tab(i)
                );
                raise;
        end;
    end loop;

    return l_tag_tab;
end get_ips_tag_map;

/*
 * Copy values of fin. message fields to tag collection in according to reference H2H_TAG and incoming IPS code.
 */
procedure collect_tags(
    i_fin_id                in            com_api_type_pkg.t_long_id
  , i_ips_fin_fields        in            com_api_type_pkg.t_param_tab
  , i_ips_code              in            com_api_type_pkg.t_module_code
  , o_tag_value_tab            out        h2h_api_type_pkg.t_h2h_tag_value_tab
) is
    LOG_PREFIX                   constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.collect_tags';
    l_tags                                h2h_api_type_pkg.t_h2h_tag_tab;
    l_tag                                 com_api_type_pkg.t_name;
    l_index                               com_api_type_pkg.t_count := 0;
    l_delimiter                           com_api_type_pkg.t_count := 0;
    l_start_position                      com_api_type_pkg.t_count := 0;
    l_field_value                         com_api_type_pkg.t_param_value;
begin
    -- Key is tag name, value is tag ID
    l_tags := get_ips_tag_map(i_ips_code => i_ips_code);

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ': #1 fin. message fields can be used to generate H2H-tags'
      , i_env_param1 => l_tags.count()
    );

    -- Look through the tag map H2H tag<->IPS field, generate H2H tag values by present fin. messsage fields
    l_tag := l_tags.first();
    while l_tag is not null loop
        l_field_value := case
                             when i_ips_fin_fields.exists(l_tags(l_tag).ips_field)
                             then trim(i_ips_fin_fields(l_tags(l_tag).ips_field))
                         end;
        if l_field_value is not null then
            l_index := l_index + 1;
            o_tag_value_tab(l_index).tag_id := l_tags(l_tag).tag_id;
            if l_tags(l_tag).date_format is not null then
                o_tag_value_tab(l_index).tag_value :=
                    to_char(
                        to_date(l_field_value), l_tags(l_tag).date_format
                      , h2h_api_const_pkg.TAG_DATE_FORMAT
                    );
            elsif l_tags(l_tag).position is not null then
                l_delimiter      := instr(l_tags(l_tag).position, '-');
                l_start_position := substr(l_tags(l_tag).position, 1, l_delimiter - 1);
                o_tag_value_tab(l_index).tag_value :=
                    substr(
                        l_field_value
                      , l_start_position
                      , substr(l_tags(l_tag).position, l_delimiter + 1) - l_start_position + 1
                    );
            else
                o_tag_value_tab(l_index).tag_value := l_field_value;
            end if;
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || ': [#1] message field [#2] produced tag {ID [#3], name [#4], value [#5]}'
              , i_env_param1 => i_ips_code
              , i_env_param2 => l_tags(l_tag).ips_field
              , i_env_param3 => l_tags(l_tag).tag_id
              , i_env_param4 => l_tag
              , i_env_param5 => o_tag_value_tab(l_index).tag_value
            );
        else
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || ': tag [#3] cannot be generated due to missing of [#1] message field [#2]'
              , i_env_param1 => i_ips_code
              , i_env_param2 => l_tags(l_tag).ips_field
              , i_env_param3 => l_tag
            );
        end if;

        l_tag := l_tags.next(l_tag);
    end loop;
end collect_tags;

procedure add_tag_value(
    io_tag_value_tab        in out nocopy h2h_api_type_pkg.t_h2h_tag_value_tab
  , i_tag_id                in            com_api_type_pkg.t_short_id
  , i_tag_value             in            com_api_type_pkg.t_full_desc
) is
    l_index                               com_api_type_pkg.t_count := 0;
begin
    if i_tag_value is not null then
        l_index                             := io_tag_value_tab.count() + 1;
        io_tag_value_tab(l_index).tag_id    := i_tag_id;
        io_tag_value_tab(l_index).tag_value := i_tag_value;
    end if;
end add_tag_value;

procedure save_tag_value(
    i_fin_id                in            com_api_type_pkg.t_long_id
  , io_tag_value_tab        in out nocopy h2h_api_type_pkg.t_h2h_tag_value_tab
) is
    LOG_PREFIX                   constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.save_tag_value: ';
    l_tag_map                             h2h_api_type_pkg.t_h2h_tag_tab;
begin
    l_tag_map := get_tag_map();

    if io_tag_value_tab.count() > 0 then
        for i in 1 .. io_tag_value_tab.count() loop
            if io_tag_value_tab(i).id is null then
                io_tag_value_tab(i).id := com_api_id_pkg.get_id(i_seq => h2h_tag_value_seq.nextval);
            end if;
            -- If incoming tag collection contains tags names only, define their IDs
            if io_tag_value_tab(i).tag_id is null then
                -- Consider H2H tags as case insensitive
                io_tag_value_tab(i).tag_name := upper(io_tag_value_tab(i).tag_name);

                if l_tag_map.exists(io_tag_value_tab(i).tag_name) then
                    io_tag_value_tab(i).tag_id := l_tag_map(io_tag_value_tab(i).tag_name).tag_id;
                else
                    com_api_error_pkg.raise_fatal_error(
                        i_error       => 'H2H_TAG_IS_NOT_REGISTERED'
                      , i_env_param1  => io_tag_value_tab(i).tag_name
                    );
                end if;
            end if;
        end loop;

        forall i in 1 .. io_tag_value_tab.count()
            insert into h2h_tag_value(
                id
              , fin_id
              , tag_id
              , tag_value
            ) values (
                io_tag_value_tab(i).id
              , i_fin_id
              , io_tag_value_tab(i).tag_id
              , io_tag_value_tab(i).tag_value
            );
    end if;

    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || '[#1] tags saved'
      , i_env_param1  => io_tag_value_tab.count()
    );
end save_tag_value;

/*
 * Save values of fin. message fields to tag values table in according to reference H2H_TAG and incoming IPS code.
 */
procedure save_tag_value(
    i_fin_id                in            com_api_type_pkg.t_long_id
  , i_ips_fin_fields        in            com_api_type_pkg.t_param_tab
  , i_ips_code              in            com_api_type_pkg.t_module_code
) is
    l_tag_value_tab                       h2h_api_type_pkg.t_h2h_tag_value_tab;
begin
    collect_tags(
        i_fin_id          => i_fin_id
      , i_ips_fin_fields  => i_ips_fin_fields
      , i_ips_code        => i_ips_code
      , o_tag_value_tab   => l_tag_value_tab
    );
    save_tag_value(
        i_fin_id          => i_fin_id
      , io_tag_value_tab  => l_tag_value_tab
    );
end save_tag_value;

/*
 * Return collection of auth (FE) tag values by incoming collection of H2H tag values.
 */
procedure get_auth_tag_value(
    io_tag_value_tab        in out nocopy h2h_api_type_pkg.t_h2h_tag_value_tab
  , o_auth_tag_value_tab       out        aup_api_type_pkg.t_aup_tag_tab
) is
    l_tag_map                             h2h_api_type_pkg.t_h2h_tag_tab;
    l_index                               com_api_type_pkg.t_count := 0;
begin
    l_tag_map := get_tag_map();

    for i in 1 .. io_tag_value_tab.count() loop
        if      l_tag_map.exists(io_tag_value_tab(i).tag_name)
            and l_tag_map(io_tag_value_tab(i).tag_name).fe_tag_id is not null
        then
            l_index := l_index + 1;
            o_auth_tag_value_tab(l_index).tag_id    := l_tag_map(io_tag_value_tab(i).tag_name).fe_tag_id;
            o_auth_tag_value_tab(l_index).tag_value := io_tag_value_tab(i).tag_value;
        end if;
    end loop;
end get_auth_tag_value;

end;
/
