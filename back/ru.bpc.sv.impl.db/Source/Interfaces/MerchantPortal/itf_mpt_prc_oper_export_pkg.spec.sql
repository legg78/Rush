create or replace package itf_mpt_prc_oper_export_pkg is

function check_inst_id(i_inst_id  in com_api_type_pkg.t_inst_id)
return com_api_type_pkg.t_boolean;

procedure process(
    i_mpt_version         in     com_api_type_pkg.t_name
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_start_date          in     date                             default null
  , i_end_date            in     date                             default null
  , i_masking_card        in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
  , i_date_type           in     com_api_type_pkg.t_dict_value    default com_api_const_pkg.DATE_PURPOSE_PROCESSING
);

end;
/
