create or replace package body com_ui_holiday_pkg as

procedure add_state_holday(
    o_state_holiday_id     out  com_api_type_pkg.t_tiny_id
  , i_cycle_id          in      com_api_type_pkg.t_short_id
  , i_short_desc        in      com_api_type_pkg.t_short_desc
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id          default null
) is
begin
    o_state_holiday_id := com_state_holiday_seq.nextval;

    insert into com_state_holiday_vw(
        id
      , cycle_id
      , inst_id
    ) values (
        o_state_holiday_id
      , i_cycle_id
      , nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST)
    );

    com_api_i18n_pkg.add_text(
        i_table_name    => 'com_state_holiday'
      , i_column_name   => 'name'
      , i_object_id     => o_state_holiday_id
      , i_lang          => i_lang
      , i_text          => i_short_desc
    );

end;

procedure modify_state_holday(
    i_state_holiday_id  in      com_api_type_pkg.t_tiny_id
  , i_cycle_id          in      com_api_type_pkg.t_short_id         default null
  , i_short_desc        in      com_api_type_pkg.t_short_desc       default null
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
) is
begin
    if i_cycle_id is not null then
        update com_state_holiday_vw
           set cycle_id = i_cycle_id
         where id = i_state_holiday_id;
    end if;

    if i_short_desc is not null then

        com_api_i18n_pkg.add_text(
            i_table_name    => 'com_state_holiday'
          , i_column_name   => 'name'
          , i_object_id     => i_state_holiday_id
          , i_lang          => i_lang
          , i_text          => i_short_desc
        );
    end if;
end;

procedure remove_state_holday(
    i_state_holiday_id  in      com_api_type_pkg.t_tiny_id
) is
begin
    delete from com_state_holiday_vw
     where id = i_state_holiday_id;

    com_api_i18n_pkg.remove_text(
        i_table_name    => 'com_state_holiday'
      , i_object_id     => i_state_holiday_id
    );

end;

procedure add_remove_holiday(
    i_holiday_date      in      date
  , i_inst_id           in      com_api_type_pkg.t_inst_id          default null
) is
    l_holiday_id        com_api_type_pkg.t_tiny_id;
begin

    if trunc(i_holiday_date) < trunc(com_api_sttl_day_pkg.get_sysdate()) then
        com_api_error_pkg.raise_error(
            i_error => 'HOLIDAY_DATE_LESS_CURR_DATE'
          , i_env_param1 => to_char(i_holiday_date, 'dd.mm.yyyy')
          , i_env_param2 => to_char(com_api_sttl_day_pkg.get_sysdate(), 'dd.mm.yyyy')
        );
    end if;

    begin
        select id
          into l_holiday_id
          from com_holiday_vw
         where holiday_date = trunc(i_holiday_date)
           and inst_id = nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST);

        delete from com_holiday_vw where id = l_holiday_id;

    exception
        when no_data_found then
            insert into com_holiday_vw(
                id
              , holiday_date
              , inst_id
            ) values (
                com_holiday_seq.nextval
              , trunc(i_holiday_date)
              , nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST)
            );
    end;
end add_remove_holiday;

end com_ui_holiday_pkg;
/
