create or replace package body svy_ui_survey_pkg is

procedure add(
    o_id               out com_api_type_pkg.t_short_id
  , o_seqnum           out com_api_type_pkg.t_tiny_id
  , i_inst_id       in     com_api_type_pkg.t_inst_id
  , i_entity_type   in     com_api_type_pkg.t_dict_value
  , i_survey_number in     com_api_type_pkg.t_name
  , i_status        in     com_api_type_pkg.t_dict_value
  , i_start_date    in     date
  , i_end_date      in     date
  , i_name          in     com_api_type_pkg.t_name
  , i_description   in     com_api_type_pkg.t_name
  , i_lang          in     com_api_type_pkg.t_dict_value
) is
    l_status               com_api_type_pkg.t_dict_value;
begin
    o_id     := svy_survey_seq.nextval;
    o_seqnum := 1;

    l_status := nvl(i_status, svy_api_const_pkg.SURVEY_STATUS_ACTIVE);
    insert into svy_survey_vw (
        id
      , seqnum
      , inst_id
      , entity_type
      , survey_number
      , status
      , start_date
      , end_date
    ) values (
        o_id
      , o_seqnum
      , i_inst_id
      , i_entity_type
      , nvl(i_survey_number, o_id)
      , l_status
      , nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate)
      , i_end_date
    );

    com_api_i18n_pkg.add_text(
        i_table_name   => 'svy_survey'
      , i_column_name  => 'name'
      , i_object_id    => o_id
      , i_text         => i_name
      , i_lang         => i_lang
      , i_check_unique => com_api_type_pkg.TRUE
    );

    com_api_i18n_pkg.add_text(
        i_table_name   => 'svy_survey'
      , i_column_name  => 'description'
      , i_object_id    => o_id
      , i_text         => i_description
      , i_lang         => i_lang
      , i_check_unique => com_api_type_pkg.TRUE
    );

exception
  when dup_val_on_index then
      com_api_error_pkg.raise_error(
          i_error      => 'DUPLICATE_SURVEY_NUMBER_FOR_INSTITUTION'
        , i_env_param1 => i_survey_number
        , i_env_param2 => i_inst_id
      );
end add;

procedure modify(
    i_id            in     com_api_type_pkg.t_short_id
  , io_seqnum       in out com_api_type_pkg.t_tiny_id
  , i_inst_id       in     com_api_type_pkg.t_inst_id
  , i_entity_type   in     com_api_type_pkg.t_dict_value
  , i_survey_number in     com_api_type_pkg.t_name
  , i_status        in     com_api_type_pkg.t_dict_value
  , i_start_date    in     date
  , i_end_date      in     date
  , i_name          in     com_api_type_pkg.t_name
  , i_description   in     com_api_type_pkg.t_name
  , i_lang          in     com_api_type_pkg.t_dict_value
) is
begin
    update svy_survey_vw
       set seqnum        = io_seqnum
         , inst_id       = i_inst_id
         , entity_type   = i_entity_type
         , survey_number = i_survey_number
         , status        = i_status
         , start_date    = i_start_date
         , end_date      = i_end_date
     where id            = i_id;

    com_api_i18n_pkg.add_text(
        i_table_name   => 'svy_survey'
      , i_column_name  => 'name'
      , i_object_id    => i_id
      , i_text         => i_name
      , i_lang         => i_lang
      , i_check_unique => com_api_type_pkg.TRUE
    );

    com_api_i18n_pkg.add_text(
        i_table_name   => 'svy_survey'
      , i_column_name  => 'description'
      , i_object_id    => i_id
      , i_text         => i_description
      , i_lang         => i_lang
      , i_check_unique => com_api_type_pkg.TRUE
    );

    io_seqnum := io_seqnum + 1;

exception
  when dup_val_on_index then
      com_api_error_pkg.raise_error(
          i_error      => 'DUPLICATE_SURVEY_NUMBER_FOR_INSTITUTION'
        , i_env_param1 => i_survey_number
        , i_env_param2 => i_inst_id
      );
end modify;

procedure remove(
    i_id            in     com_api_type_pkg.t_short_id
) is
begin
    delete svy_survey_vw
     where id = i_id;

    com_api_i18n_pkg.remove_text(
        i_table_name => 'svy_survey'
      , i_object_id  => i_id
    );
end remove;

end svy_ui_survey_pkg;
/
