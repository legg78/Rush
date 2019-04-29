create or replace package body fcl_ui_cycle_pkg as

-- This parameter is calculated in the initialization section
g_instance_type                 com_api_type_pkg.t_sign;

procedure add_cycle_type (
    io_cycle_type           in out com_api_type_pkg.t_dict_value
  , i_short_desc            in     com_api_type_pkg.t_short_desc
  , i_full_desc             in     com_api_type_pkg.t_full_desc
  , i_cycle_calc_start_date in     com_api_type_pkg.t_dict_value
  , i_cycle_calc_date_type  in     com_api_type_pkg.t_dict_value
  , i_lang                  in     com_api_type_pkg.t_dict_value
  , i_is_repeating          in     com_api_type_pkg.t_boolean    default com_api_type_pkg.TRUE
  , i_is_standard           in     com_api_type_pkg.t_boolean    default com_api_type_pkg.TRUE
) is
    l_count                 com_api_type_pkg.t_count := 0;
begin
    if io_cycle_type is null then
        select max(to_number(substr(cycle_type, 5, 4)) ) + 1
          into io_cycle_type
          from fcl_cycle_type
         where regexp_like(cycle_type, 'CYTP' || g_instance_type || '\d{3}');

        io_cycle_type := 'CYTP' || lpad(to_char(greatest(nvl(io_cycle_type, 0)
                                                       , g_instance_type * 1000 + 1)
                                              , 'TM9')
                                      , 4, '0');
    end if;

    trc_log_pkg.debug (
        i_text        => lower($$PLSQL_UNIT) || '.add_cycle_type: io_cycle_type [#1] '
      , i_env_param1  => io_cycle_type
    );

    select count(1)
      into l_count
      from fcl_cycle_type_vw
     where cycle_type = io_cycle_type;

    if l_count > 0 then
        com_api_error_pkg.raise_error (
            i_error       => 'CYCLE_TYPE_ALREADY_EXIST'
          , i_env_param1  => io_cycle_type
        );
    end if;

    select count(*)
      into l_count
      from com_dictionary_vw
     where dict = 'CYTP'
       and code = lpad(substr(io_cycle_type, 5), 4, '0');

    if l_count = 0 then
        com_ui_dictionary_pkg.add_article (
            i_dict        => 'CYTP'
          , i_code        => lpad(substr(io_cycle_type, 5), 4, '0')
          , i_short_desc  => i_short_desc
          , i_full_desc   => i_full_desc
          , i_is_editable => com_api_type_pkg.TRUE
          , i_lang        => i_lang
        );
    end if;

    insert into fcl_cycle_type (
        id
      , cycle_type
      , is_repeating
      , is_standard
      , cycle_calc_start_date
      , cycle_calc_date_type
    ) values (
        fcl_cycle_type_seq.nextval
      , io_cycle_type
      , i_is_repeating
      , i_is_standard
      , i_cycle_calc_start_date
      , i_cycle_calc_date_type
    );
end;

procedure modify_cycle_type (
    i_cycle_type            in     com_api_type_pkg.t_dict_value
  , i_is_repeating          in     com_api_type_pkg.t_boolean
  , i_is_standard           in     com_api_type_pkg.t_boolean
  , i_cycle_calc_start_date in     com_api_type_pkg.t_dict_value
  , i_cycle_calc_date_type  in     com_api_type_pkg.t_dict_value
) is
    l_cycle_type_id         com_api_type_pkg.t_tiny_id;
begin
    if i_cycle_type is null then
        com_api_error_pkg.raise_error (
            i_error  => 'CYCLE_TYPE_NOT_DEFINED'
        );
    end if;

    begin
        select id
          into l_cycle_type_id
          from fcl_cycle_type_vw
         where cycle_type = i_cycle_type;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error (
                i_error       => 'CYCLE_TYPE_NOT_FOUND'
              , i_env_param1  => i_cycle_type
            );
    end;

    if i_cycle_calc_start_date is not null then
        com_api_dictionary_pkg.check_article('CYSD', i_cycle_calc_start_date);
    end if;

    if i_cycle_calc_date_type is not null then
        com_api_dictionary_pkg.check_article('CYDT', i_cycle_calc_date_type);
    end if;

    update fcl_cycle_type_vw
       set is_repeating = nvl(i_is_repeating, is_repeating),
           is_standard = nvl(i_is_standard, is_standard),
           cycle_calc_start_date = nvl(i_cycle_calc_start_date, cycle_calc_start_date),
           cycle_calc_date_type = nvl(i_cycle_calc_date_type, cycle_calc_date_type)
     where id = l_cycle_type_id;
end;

procedure remove_cycle_type (
    i_cycle_type   in     com_api_type_pkg.t_dict_value
) is
    l_count        pls_integer;
begin
    if i_cycle_type is null then
        com_api_error_pkg.raise_error (
            i_error  => 'CYCLE_TYPE_NOT_DEFINED'
        );
    end if;

    select count(1)
      into l_count
      from fcl_cycle_vw
     where cycle_type = i_cycle_type;

    if l_count > 0 then
        com_api_error_pkg.raise_error (
            i_error       => 'CYCLES_FOR_CYCLE_TYPE_EXIST'
          , i_env_param1  => i_cycle_type
        );
    end if;

    delete from fcl_cycle_type_vw
     where cycle_type = i_cycle_type;

    com_ui_dictionary_pkg.remove_article (
        i_dict  => 'CYTP'
      , i_code  => lpad(substr(i_cycle_type, 5), 4, '0')
      , i_is_leaf           => com_api_const_pkg.TRUE
    );
end;

procedure validate_cycle(
    i_cycle_length      in      com_api_type_pkg.t_tiny_id
  , i_length_type       in      com_api_type_pkg.t_dict_value
  , i_trunc_type        in      com_api_type_pkg.t_dict_value
) is
begin
    if i_cycle_length is null then
        com_api_error_pkg.raise_error(
            i_error    => 'CYCLE_LENGTH_NOT_DEFINED'
        );
    end if;

    if i_length_type is null then
        com_api_error_pkg.raise_error(
            i_error    => 'CYCLE_LENGTH_TYPE_NOT_DEFINED'
        );
    else
        com_api_dictionary_pkg.check_article(
            i_dict  => 'LNGT'
          , i_code  => i_length_type
        );
    end if;

    if i_trunc_type is not null then
        com_api_dictionary_pkg.check_article(
            i_dict  => 'LNGT'
          , i_code  => i_trunc_type
        );
    end if;
end;

procedure add_cycle(
    i_cycle_type        in      com_api_type_pkg.t_dict_value
  , i_length_type       in      com_api_type_pkg.t_dict_value
  , i_cycle_length      in      com_api_type_pkg.t_tiny_id
  , i_trunc_type        in      com_api_type_pkg.t_dict_value
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_workdays_only     in      com_api_type_pkg.t_boolean
  , o_cycle_id             out  com_api_type_pkg.t_short_id
) is
begin
    if i_cycle_type is null then
        com_api_error_pkg.raise_error(
            i_error             => 'CYCLE_TYPE_NOT_DEFINED'
        );
    end if;

    com_api_dictionary_pkg.check_article(
        i_dict  => 'CYTP'
      , i_code  => i_cycle_type
    );

    validate_cycle(
        i_cycle_length  => i_cycle_length
      , i_length_type   => i_length_type
      , i_trunc_type    => i_trunc_type
    );

    if i_inst_id is null then
        com_api_error_pkg.raise_error(
            i_error             => 'INSTITUTION_NOT_DEFINED'
        );
    end if;

    select fcl_cycle_seq.nextval into o_cycle_id from dual;

    insert into fcl_cycle_vw(
        id
      , seqnum
      , cycle_type
      , length_type
      , cycle_length
      , trunc_type
      , inst_id
      , workdays_only
    ) values (
        o_cycle_id
      , 1
      , i_cycle_type
      , i_length_type
      , i_cycle_length
      , i_trunc_type
      , i_inst_id
      , i_workdays_only
    );

end;

procedure modify_cycle(
    i_cycle_id          in      com_api_type_pkg.t_short_id
  , i_length_type       in      com_api_type_pkg.t_dict_value
  , i_cycle_length      in      com_api_type_pkg.t_tiny_id
  , i_trunc_type        in      com_api_type_pkg.t_dict_value
  , i_workdays_only     in      com_api_type_pkg.t_boolean
  , i_seqnum            in      com_api_type_pkg.t_seqnum
) is
    l_count             pls_integer;
begin
    if i_cycle_id is null then
        com_api_error_pkg.raise_error(
            i_error             => 'CYCLE_ID_NOT_DEFINED'
        );
    end if;

    begin
        select count(1)
          into l_count
          from fcl_cycle_vw
         where id = i_cycle_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error             => 'CYCLE_NOT_FOUND'
              , i_env_param1        => i_cycle_id
            );
    end;

    validate_cycle(
        i_cycle_length  => i_cycle_length
      , i_length_type   => i_length_type
      , i_trunc_type    => i_trunc_type
    );

    update fcl_cycle_vw
       set length_type   = i_length_type
         , cycle_length  = i_cycle_length
         , trunc_type    = i_trunc_type
         , seqnum        = i_seqnum
         , workdays_only = i_workdays_only
     where id            = i_cycle_id;
end;

procedure remove_cycle(
    i_cycle_id          in      com_api_type_pkg.t_short_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
) is
begin
    update fcl_cycle_vw
       set seqnum       = i_seqnum
     where id           = i_cycle_id;

    delete from fcl_cycle_shift_vw where cycle_id = i_cycle_id;

    delete from fcl_cycle_vw where id = i_cycle_id;
end;

procedure validate_cycle_shift(
    i_shift_type        in      com_api_type_pkg.t_dict_value
  , i_length_type       in      com_api_type_pkg.t_dict_value
  , i_shift_length      in      com_api_type_pkg.t_tiny_id
) is
begin
    case
        when i_shift_type = fcl_api_const_pkg.CYCLE_SHIFT_PERIOD then
            if i_length_type is null then
                com_api_error_pkg.raise_error(
                    i_error      => 'CYCLE_LENGTH_TYPE_NOT_DEFINED'
                );
            else
                com_api_dictionary_pkg.check_article(
                    i_dict  => 'LNGT'
                  , i_code  => i_length_type
                );
            end if;

            if i_shift_length is null then
                com_api_error_pkg.raise_error(
                    i_error      => 'CYCLE_SHIFT_LENGTH_NOT_DEFINED'
                );
            end if;

        when i_shift_type = fcl_api_const_pkg.CYCLE_SHIFT_WEEK_DAY then
            if i_shift_length is null then
                com_api_error_pkg.raise_error(
                    i_error      => 'CYCLE_SHIFT_LENGTH_NOT_DEFINED'
                );
            elsif not (i_shift_length between 1 and 7) then
                com_api_error_pkg.raise_error(
                    i_error      => 'CYCLE_SHIFT_INCORRECT_WEEK_DAY'
                );
            end if;

        when i_shift_type = fcl_api_const_pkg.CYCLE_SHIFT_CERTAIN_YEAR then
            if i_shift_length is null then
                com_api_error_pkg.raise_error(
                    i_error      => 'CYCLE_SHIFT_LENGTH_NOT_DEFINED'
                );
            elsif i_shift_length < to_char(com_api_sttl_day_pkg.get_sysdate(), 'yyyy') then
                com_api_error_pkg.raise_error(
                    i_error      => 'CYCLE_SHIFT_INCORRECT_LENGTH'
                  , i_env_param1 => i_shift_type
                  , i_env_param2 => i_shift_length
                );
            end if;

        else
            null;
    end case;
end;

procedure add_cycle_shift(
    i_cycle_id          in      com_api_type_pkg.t_short_id
  , i_shift_type        in      com_api_type_pkg.t_dict_value
  , i_priority          in      com_api_type_pkg.t_tiny_id
  , i_shift_sign        in      com_api_type_pkg.t_sign
  , i_length_type       in      com_api_type_pkg.t_dict_value
  , i_shift_length      in      com_api_type_pkg.t_tiny_id
  , o_cycle_shift_id       out  com_api_type_pkg.t_short_id
) is
    l_count             pls_integer;
begin
    if i_cycle_id is null then
        com_api_error_pkg.raise_error(
            i_error             => 'CYCLE_ID_NOT_DEFINED'
        );
    end if;

    begin
        select count(1)
          into l_count
          from fcl_cycle_vw
         where id = i_cycle_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error       => 'CYCLE_NOT_FOUND'
              , i_env_param1  => i_cycle_id
            );
    end;

    if i_shift_type is null then
        com_api_error_pkg.raise_error(
            i_error             => 'CYCLE_SHIFT_TYPE_NOT_DEFINED'
        );
    else
        com_api_dictionary_pkg.check_article(
            i_dict  => 'CSHT'
          , i_code  => i_shift_type
        );
    end if;

    validate_cycle_shift(
        i_shift_type    => i_shift_type
      , i_length_type   => i_length_type
      , i_shift_length  => i_shift_length
    );

    select fcl_cycle_shift_seq.nextval into o_cycle_shift_id from dual;

    insert into fcl_cycle_shift_vw(
        id
      , seqnum
      , cycle_id
      , shift_type
      , shift_sign
      , length_type
      , shift_length
      , priority
    ) values (
        o_cycle_shift_id
      , 1
      , i_cycle_id
      , i_shift_type
      , nvl(i_shift_sign, 1)
      , i_length_type
      , i_shift_length
      , nvl(i_priority, 1)
    );
end;

procedure modify_cycle_shift(
    i_cycle_shift_id    in      com_api_type_pkg.t_short_id
  , i_shift_type        in      com_api_type_pkg.t_dict_value
  , i_priority          in      com_api_type_pkg.t_tiny_id
  , i_shift_sign        in      com_api_type_pkg.t_sign
  , i_length_type       in      com_api_type_pkg.t_dict_value
  , i_shift_length      in      com_api_type_pkg.t_tiny_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
) is
begin
    if i_cycle_shift_id is null then
        com_api_error_pkg.raise_error(
            i_error             => 'CYCLE_SHIFT_ID_NOT_DEFINED'
        );
    end if;

    validate_cycle_shift(
        i_shift_type    => i_shift_type
      , i_length_type   => i_length_type
      , i_shift_length  => i_shift_length
    );

    update fcl_cycle_shift_vw
       set shift_type   = i_shift_type
         , shift_sign   = i_shift_sign
         , length_type  = i_length_type
         , shift_length = i_shift_length
         , priority     = i_priority
         , seqnum       = i_seqnum
     where id           = i_cycle_shift_id;
end;

procedure remove_cycle_shift(
    i_cycle_shift_id    in      com_api_type_pkg.t_short_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
) is
begin
    update fcl_cycle_shift_vw
       set seqnum       = i_seqnum
     where id           = i_cycle_shift_id;

    delete from fcl_cycle_shift_vw
     where id = i_cycle_shift_id;
end;


function get_cycle_desc(
    i_cycle_id          in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_name is
    l_result                    com_api_type_pkg.t_name;
    l_nls_numeric_characters    com_api_type_pkg.t_name;
begin
    l_nls_numeric_characters := com_ui_user_env_pkg.get_nls_numeric_characters;
    select to_char(cycle_length, com_api_const_pkg.get_number_i_format_with_sep, l_nls_numeric_characters) || ' ' ||
           com_api_dictionary_pkg.get_article_text(length_type) || ' ' ||
           com_api_label_pkg.get_label_text('FROM_BEGINING_OF') || ' ' ||
           com_api_dictionary_pkg.get_article_text(trunc_type)
      into l_result
      from fcl_cycle_vw
     where id = i_cycle_id;

    for r in (
        select decode(shift_sign, -1, 'SHIFT_BACKWARD_TO', 'SHIFT_FORWARD_TO') shift_sign
             , case shift_type
                   when fcl_api_const_pkg.CYCLE_SHIFT_WORK_DAY then
                       shift_length || ' ' || com_api_label_pkg.get_label_text('WORKDAY')
                   when fcl_api_const_pkg.CYCLE_SHIFT_WEEK_DAY then
                       case shift_length
                           when 1 then com_api_label_pkg.get_label_text('common.monday')
                           when 2 then com_api_label_pkg.get_label_text('common.tuesday')
                           when 3 then com_api_label_pkg.get_label_text('common.wednesday')
                           when 4 then com_api_label_pkg.get_label_text('common.thursday')
                           when 5 then com_api_label_pkg.get_label_text('common.friday')
                           when 6 then com_api_label_pkg.get_label_text('common.saturday')
                           when 7 then com_api_label_pkg.get_label_text('common.sunday')
                           else null
                       end
                   when fcl_api_const_pkg.CYCLE_SHIFT_PERIOD then
                       shift_length || ' ' || com_api_dictionary_pkg.get_article_text(length_type)
                   when fcl_api_const_pkg.CYCLE_SHIFT_MONTH_DAY then
                       shift_length || ' ' || com_api_label_pkg.get_label_text('DAY_OF_MONTH')
                   when fcl_api_const_pkg.CYCLE_SHIFT_CERTAIN_YEAR then
                       shift_length || ' ' ||
                       com_api_dictionary_pkg.get_article_text(i_article => fcl_api_const_pkg.CYCLE_LENGTH_YEAR)
                   else null
               end shift_type
          from fcl_cycle_shift_vw
         where cycle_id = i_cycle_id
         order by priority
    ) loop
        l_result := substr(l_result || '; ' || com_api_label_pkg.get_label_text(r.shift_sign) || ' ' || r.shift_type, 1, 200);
    end loop;

    return lower(l_result);
exception
    when no_data_found then
        return null;
end;

procedure modify_cycle_counter(
    i_counter_id        in      com_api_type_pkg.t_short_id
  , i_next_date         in      date
)is
begin
    update fcl_cycle_counter_vw
       set next_date  = i_next_date
     where id         = i_counter_id;
end;

-- Define instance's type for correct generating numeric dictionary articles
begin
    select substr(to_char(min_value), 1, 1)
      into g_instance_type
      from user_sequences
     where sequence_name = 'FCL_CYCLE_TYPE_SEQ';

    trc_log_pkg.debug(
        i_text       => lower($$PLSQL_UNIT) || '~initialization: g_instance_type [#1]'
      , i_env_param1 => g_instance_type
    );
exception
    when no_data_found then
        g_instance_type := utl_deploy_pkg.INSTANCE_TYPE_CUSTOM1;
        trc_log_pkg.debug(
            i_text       => lower($$PLSQL_UNIT)
                         || '~initialization: g_instance_type [#1] BY DEFAULT'
          , i_env_param1 => g_instance_type
        );
end;
/
