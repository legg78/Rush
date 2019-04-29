create or replace package svy_ui_survey_parameter_pkg is

procedure add(
    o_id               out com_api_type_pkg.t_medium_id
  , i_survey_id     in     com_api_type_pkg.t_short_id
  , i_param_id      in     com_api_type_pkg.t_medium_id
);

procedure modify(
    i_id            in     com_api_type_pkg.t_medium_id
  , i_survey_id     in     com_api_type_pkg.t_short_id
  , i_param_id      in     com_api_type_pkg.t_medium_id
);

procedure remove(
    i_id            in     com_api_type_pkg.t_medium_id
);

end svy_ui_survey_parameter_pkg;
/
