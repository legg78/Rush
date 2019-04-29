create or replace package body aup_api_tag_pkg is

g_tags                      com_api_type_pkg.t_number_by_name_tab;
g_date                      date;

procedure load_tags is
begin
    if g_date > com_api_sttl_day_pkg.get_sysdate() - 1/(24 * 6) then
        null;
    else
        g_tags.delete;

        for rec in (select * from aup_tag where reference is not null) loop
            g_tags(rec.reference) := rec.tag;
        end loop;

        g_date := com_api_sttl_day_pkg.get_sysdate();
    end if;
end load_tags;

function find_tag_by_reference(
    i_reference             in     com_api_type_pkg.t_name
  , i_mask_error            in     com_api_type_pkg.t_boolean         default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_short_id is
begin
    load_tags;

    if g_tags.exists(i_reference) then
        return g_tags(i_reference);
    elsif nvl(i_mask_error, com_api_const_pkg.TRUE) = com_api_const_pkg.TRUE then
        return null;
    else
        com_api_error_pkg.raise_error(
            i_error       => 'AUP_TAG_NOT_FOUND_BY_REFERENCE'
          , i_env_param1  => i_reference
        );
    end if;
end find_tag_by_reference;

function get_tag_value(
    i_auth_id               in     com_api_type_pkg.t_long_id
  , i_tag_reference         in     com_api_type_pkg.t_name
  , i_seq_number            in     com_api_type_pkg.t_short_id  default null
) return com_api_type_pkg.t_full_desc is
begin
    return get_tag_value(
               i_auth_id    => i_auth_id
             , i_tag_id     => find_tag_by_reference(i_tag_reference)
             , i_seq_number => i_seq_number
           );
end get_tag_value;

function get_tag_value(
    i_auth_id               in     com_api_type_pkg.t_long_id
  , i_tag_id                in     com_api_type_pkg.t_short_id  -- equal to aup_tag.tag
  , i_seq_number            in     com_api_type_pkg.t_short_id  default null
) return com_api_type_pkg.t_full_desc is
    l_result                       com_api_type_pkg.t_full_desc;
begin
    select min(v.tag_value)
      into l_result
      from aup_tag_value v
     where v.auth_id            = i_auth_id
       and v.tag_id             = i_tag_id
       and nvl(v.seq_number, 1) = nvl(i_seq_number, 1);

    return case when i_tag_id in (aup_api_const_pkg.TAG_SECOND_CARD_NUMBER)
                then iss_api_token_pkg.decode_card_number(
                         i_card_number => l_result
                       , i_mask_error  => com_api_const_pkg.TRUE
                     )
                else l_result
           end;
end get_tag_value;

procedure get_tag_value(
    i_auth_id               in      com_api_type_pkg.t_long_id
  , i_seq_number            in      com_api_type_pkg.t_tiny_id    default null
  , o_aup_tag_tab              out  aup_api_type_pkg.t_aup_tag_tab
) is
begin
    select v.tag_id
         , v.tag_value
         , v.seq_number
      bulk collect into
           o_aup_tag_tab
      from aup_tag_value v
     where auth_id              = i_auth_id
       and nvl(v.seq_number, 1) = nvl(i_seq_number, 1)
     order by
           v.tag_id;
end get_tag_value;

procedure save_tag(
    i_auth_id               in     com_api_type_pkg.t_long_id
  , i_tags                  in     aup_api_type_pkg.t_aup_tag_tab
) is
begin
    forall i in 1 .. i_tags.count()
        merge into
            aup_tag_value dst
        using (
            select
                i_auth_id                    as auth_id
              , i_tags(i).tag_id             as tag_id
              , i_tags(i).tag_value          as tag_value
              , nvl(i_tags(i).seq_number, 1) as seq_number
            from
                dual
        ) src
        on (
                src.auth_id     = dst.auth_id
            and src.tag_id      = dst.tag_id
            and src.seq_number  = nvl(dst.seq_number, 1)
        )
        when matched then
            update
            set dst.tag_value   = src.tag_value
        when not matched then
            insert (
                dst.auth_id
              , dst.tag_id
              , dst.tag_value
              , dst.seq_number
            ) values (
                src.auth_id
              , src.tag_id
              , src.tag_value
              , src.seq_number
            );
end save_tag;

procedure save_tag(
    i_auth_id               in     com_api_type_pkg.t_long_id
  , i_tags                  in     aup_tag_value_tpt
) is
    LOG_PREFIX            constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.save_tag';
    l_tag_tab                      aup_api_type_pkg.t_aup_tag_tab;
    l_index                        binary_integer;
begin
    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || ': i_tags.count() = #1'
      , i_env_param1  => i_tags.count()
    );

    l_index := i_tags.first();

    while l_index is not null loop
        l_tag_tab(l_index).tag_id :=
            coalesce(
                i_tags(l_index).tag_id
              , find_tag_by_reference(
                    i_reference   => i_tags(l_index).tag_reference
                  , i_mask_error  => com_api_const_pkg.FALSE
                )
            );
        l_tag_tab(l_index).tag_value  := i_tags(l_index).tag_value;
        l_tag_tab(l_index).seq_number := nvl(i_tags(l_index).seq_number, 1);

        l_index := i_tags.next(l_index);
    end loop;

    if i_tags.count() > 0 then
        save_tag(
            i_auth_id  => i_auth_id
          , i_tags     => l_tag_tab
        );
    end if;
end save_tag;

procedure insert_tag(
    i_auth_id               in     com_api_type_pkg.t_long_id
  , i_tags                  in     aup_api_type_pkg.t_aup_tag_tab
) is
begin
    forall i in 1 .. i_tags.count()
        insert into aup_tag_value(
            auth_id
          , tag_id
          , tag_value
          , seq_number
        )
        values (
            i_auth_id
          , i_tags(i).tag_id
          , i_tags(i).tag_value
          , nvl(i_tags(i).seq_number, 1)
        );
end insert_tag;

procedure copy_tag_value(
    i_source_auth_id        in     com_api_type_pkg.t_long_id
  , i_target_auth_id        in     com_api_type_pkg.t_long_id
) is
    LOG_PREFIX            constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.copy_tag_value';
begin
    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || ' << from i_source_auth_id [#1] to i_target_auth_id [#2]'
      , i_env_param1  => i_source_auth_id
      , i_env_param2  => i_target_auth_id
    );

    insert into aup_tag_value(
        auth_id
      , tag_id
      , tag_value
      , seq_number
    )
    select i_target_auth_id
         , tag_id
         , tag_value
         , seq_number
      from aup_tag_value
     where auth_id = i_source_auth_id;

    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || ' >> [#1] tags were copied'
      , i_env_param1  => sql%rowcount
    );
end copy_tag_value;

end;
/
