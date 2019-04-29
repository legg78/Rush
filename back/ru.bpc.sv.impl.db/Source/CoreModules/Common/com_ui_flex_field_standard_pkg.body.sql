create or replace package body com_ui_flex_field_standard_pkg is

procedure add_flex_field_standard(
    i_standard_id        in     com_api_type_pkg.t_tiny_id
  , i_field_id           in     com_api_type_pkg.t_short_id
  , o_id                    out com_api_type_pkg.t_short_id
  , o_seqnum                out com_api_type_pkg.t_seqnum
) is
    l_standard_id              com_api_type_pkg.t_tiny_id;
    l_field_id                 com_api_type_pkg.t_short_id;
    l_seqnum                   com_api_type_pkg.t_seqnum;
    l_count                    com_api_type_pkg.t_tiny_id;
begin
    o_id     := com_flex_field_standard_seq.nextval;
    o_seqnum := 1;

    begin
        select field_id
             , seqnum
             , standard_id
          into l_field_id
             , l_seqnum
             , l_standard_id
          from com_flex_field_standard_vw
         where field_id    = i_field_id
           and seqnum      = o_seqnum
           and standard_id = i_standard_id;
    exception
        when no_data_found then
            null;
    end;

    if l_field_id = i_field_id and l_seqnum = o_seqnum and l_standard_id = i_standard_id then
        raise dup_val_on_index;
    else
        insert into com_flex_field_standard_vw (
            id
          , field_id
          , seqnum
          , standard_id
        ) values (
            o_id
          , i_field_id
          , o_seqnum
          , i_standard_id
        );

        trc_log_pkg.debug(
            i_text        => 'Flexible field standard added id = [#1]'
          , i_env_param1  => o_id
        );
    end if;

exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error      => 'DUPLICATE_FLEX_FIELD_STANDARD'
          , i_env_param1 => i_standard_id
          , i_env_param2 => i_field_id
        );
end add_flex_field_standard;

procedure modify_flex_field_standard(
    i_id                 in     com_api_type_pkg.t_short_id
  , i_standard_id        in     com_api_type_pkg.t_tiny_id
  , i_field_id           in     com_api_type_pkg.t_short_id
  , io_seqnum            in out com_api_type_pkg.t_seqnum
) is
begin
    update com_flex_field_standard_vw
       set standard_id = i_standard_id
         , field_id    = i_field_id
         , seqnum      = io_seqnum
     where id = i_id;

    io_seqnum := io_seqnum + 1;

    trc_log_pkg.debug(
        i_text        => 'Flexible field standard modified id = [#1]'
      , i_env_param1  => i_id
    );

end modify_flex_field_standard;

procedure remove_flex_field_standard(
    i_id                 in     com_api_type_pkg.t_short_id
) is
    l_field_id                  com_api_type_pkg.t_short_id;
    l_standard_id               com_api_type_pkg.t_tiny_id;
begin
    delete from com_flex_field_standard_vw where id = i_id returning standard_id, field_id into l_standard_id, l_field_id;

    trc_log_pkg.debug(
        i_text        => 'Flexible field standard removed id = [#1], standard_id = [#2], field_id = [#3]'
      , i_env_param1  => i_id
      , i_env_param2  => l_standard_id
      , i_env_param3  => l_field_id
    );

end remove_flex_field_standard;

end com_ui_flex_field_standard_pkg;
/
