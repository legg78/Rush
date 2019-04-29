create or replace package body svy_ui_survey_parameter_pkg is

procedure add(
    o_id               out com_api_type_pkg.t_medium_id
  , i_survey_id     in     com_api_type_pkg.t_short_id
  , i_param_id      in     com_api_type_pkg.t_medium_id
) is

begin
    o_id     := svy_survey_parameter_seq.nextval;

    insert into svy_survey_parameter_vw (
        id
      , survey_id
      , param_id
    ) values (
        o_id
      , i_survey_id
      , i_param_id
    );
end add;

procedure modify(
    i_id            in     com_api_type_pkg.t_medium_id
  , i_survey_id     in     com_api_type_pkg.t_short_id
  , i_param_id      in     com_api_type_pkg.t_medium_id
) is
begin
    update svy_survey_parameter_vw
       set survey_id     = i_survey_id
         , param_id      = i_param_id
     where id            = i_id;
end modify;

procedure remove(
    i_id            in     com_api_type_pkg.t_medium_id
) is
begin
    delete svy_survey_parameter_vw
     where id = i_id;
end remove;

end svy_ui_survey_parameter_pkg;
/
