create or replace package svy_api_type_pkg as

type t_survey_rec is record (
    id             com_api_type_pkg.t_short_id
  , seqnum         com_api_type_pkg.t_tiny_id
  , inst_id        com_api_type_pkg.t_tiny_id
  , entity_type    com_api_type_pkg.t_dict_value
  , survey_number  com_api_type_pkg.t_name
  , status         com_api_type_pkg.t_dict_value
  , start_date     date
  , end_date       date
);

type t_questionary_rec is record (
    id                 com_api_type_pkg.t_long_id
  , seqnum             com_api_type_pkg.t_tiny_id
  , inst_id            com_api_type_pkg.t_tiny_id
  , split_hash         com_api_type_pkg.t_tiny_id
  , object_id          com_api_type_pkg.t_long_id
  , survey_id          com_api_type_pkg.t_short_id
  , questionary_number com_api_type_pkg.t_name
  , status             com_api_type_pkg.t_dict_value
  , creation_date      date
  , closure_date       date
);

end svy_api_type_pkg;
/
