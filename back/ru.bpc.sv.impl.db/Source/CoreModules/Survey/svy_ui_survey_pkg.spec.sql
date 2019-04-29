create or replace package svy_ui_survey_pkg is

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
);

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
);

procedure remove(
    i_id            in     com_api_type_pkg.t_short_id
);

end svy_ui_survey_pkg;
/
