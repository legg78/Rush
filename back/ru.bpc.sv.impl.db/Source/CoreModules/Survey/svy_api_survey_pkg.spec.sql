create or replace package svy_api_survey_pkg is

function get_survey(
    i_id          in com_api_type_pkg.t_short_id
  , i_mask_error  in com_api_type_pkg.t_boolean   default com_api_const_pkg.FALSE
) return svy_api_type_pkg.t_survey_rec;

function get_survey(
    i_survey_number    in com_api_type_pkg.t_name
  , i_inst_id          in com_api_type_pkg.t_inst_id
  , i_mask_error       in com_api_type_pkg.t_boolean   default com_api_const_pkg.FALSE
) return svy_api_type_pkg.t_survey_rec;

end svy_api_survey_pkg;
/
