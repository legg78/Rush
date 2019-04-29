create or replace package cln_api_case_pkg is

function get_case(
    i_id                in      com_api_type_pkg.t_long_id
) return cln_api_type_pkg.t_case_rec;

function check_case_exists(
    i_customer_id    in      com_api_type_pkg.t_medium_id
  , i_split_hash     in      com_api_type_pkg.t_tiny_id     default null
) return com_api_type_pkg.t_boolean;

function check_case_not_closed(
    i_id             in         com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean;

function check_duplicate_case(
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_case_number       in      com_api_type_pkg.t_name
) return com_api_type_pkg.t_boolean;

procedure add_case(
    o_id                   out  com_api_type_pkg.t_long_id
  , o_seqnum               out  com_api_type_pkg.t_tiny_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_split_hash        in      com_api_type_pkg.t_short_id
  , i_case_number       in      com_api_type_pkg.t_name
  , i_creation_date     in      date
  , i_customer_id       in      com_api_type_pkg.t_medium_id
  , i_user_id           in      com_api_type_pkg.t_short_id
  , i_status            in      com_api_type_pkg.t_dict_value default cln_api_const_pkg.COLLECTION_CASE_STATUS_NEW
  , i_resolution        in      com_api_type_pkg.t_dict_value default null
);

procedure modify_case(
    i_id                 in     com_api_type_pkg.t_long_id
  , io_seqnum            in out com_api_type_pkg.t_seqnum
  , i_user_id            in     com_api_type_pkg.t_short_id
  , i_status             in     com_api_type_pkg.t_dict_value
  , i_resolution         in     com_api_type_pkg.t_dict_value
);

function get_case(
    i_customer_id  in     com_api_type_pkg.t_medium_id
  , i_split_hash   in     com_api_type_pkg.t_tiny_id   default null
  , i_mask_error   in     com_api_type_pkg.t_boolean   default com_api_const_pkg.FALSE
) return cln_api_type_pkg.t_case_rec;

procedure change_case_status(
    i_case_id           in    com_api_type_pkg.t_long_id
  , i_status            in    com_api_type_pkg.t_dict_value
  , i_resolution        in    com_api_type_pkg.t_dict_value
  , i_activity_category in    com_api_type_pkg.t_dict_value
  , i_activity_type     in    com_api_type_pkg.t_dict_value
  , i_split_hash        in    com_api_type_pkg.t_tiny_id default null
);

procedure change_case_status(
    i_case_id           in    com_api_type_pkg.t_long_id
  , i_reason_code       in    com_api_type_pkg.t_dict_value
  , i_activity_category in    com_api_type_pkg.t_dict_value
  , i_activity_type     in    com_api_type_pkg.t_dict_value
  , i_split_hash        in    com_api_type_pkg.t_tiny_id default null  
);

end cln_api_case_pkg;
/
