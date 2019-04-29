create or replace package cpn_api_type_pkg is

type t_campaign_rec is record(
    id               com_api_type_pkg.t_short_id
  , inst_id          com_api_type_pkg.t_inst_id
  , seqnum           com_api_type_pkg.t_seqnum
  , campaign_number  com_api_type_pkg.t_name
  , lang             com_api_type_pkg.t_dict_value
  , name             com_api_type_pkg.t_name
  , description      com_api_type_pkg.t_name
  , campaign_type    com_api_type_pkg.t_dict_value
  , start_date       date
  , end_date         date
  , cycle_id         com_api_type_pkg.t_short_id
);

end;
/
