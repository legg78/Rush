create or replace package svy_api_questionary_pkg is

procedure add(
    o_id                    out com_api_type_pkg.t_long_id
  , o_seqnum                out com_api_type_pkg.t_tiny_id
  , i_inst_id            in     com_api_type_pkg.t_inst_id
  , i_split_hash         in     com_api_type_pkg.t_tiny_id
  , i_object_id          in     com_api_type_pkg.t_long_id
  , i_survey_id          in     com_api_type_pkg.t_short_id
  , i_questionary_number in     com_api_type_pkg.t_name
  , i_status             in     com_api_type_pkg.t_dict_value
  , i_creation_date      in     date
  , i_closure_date       in     date
);

procedure modify(
    i_id                 in     com_api_type_pkg.t_long_id
  , io_seqnum            in out com_api_type_pkg.t_tiny_id
  , i_inst_id            in     com_api_type_pkg.t_inst_id
  , i_split_hash         in     com_api_type_pkg.t_tiny_id
  , i_object_id          in     com_api_type_pkg.t_long_id
  , i_survey_id          in     com_api_type_pkg.t_short_id
  , i_questionary_number in     com_api_type_pkg.t_name
  , i_status             in     com_api_type_pkg.t_dict_value
  , i_closure_date       in     date
);

procedure remove(
    i_id                 in     com_api_type_pkg.t_long_id
  , i_seqnum             in     com_api_type_pkg.t_tiny_id
);

function get_questionary(
    i_id                 in com_api_type_pkg.t_long_id
  , i_mask_error         in com_api_type_pkg.t_boolean   default com_api_const_pkg.FALSE
) return svy_api_type_pkg.t_questionary_rec;

function get_questionary(
    i_questionary_number in com_api_type_pkg.t_name
  , i_mask_error         in com_api_type_pkg.t_boolean   default com_api_const_pkg.FALSE
) return svy_api_type_pkg.t_questionary_rec;

procedure process_questionary;

procedure process_parameters;

end svy_api_questionary_pkg;
/
