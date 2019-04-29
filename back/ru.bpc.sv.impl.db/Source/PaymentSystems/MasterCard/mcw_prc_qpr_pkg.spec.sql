create or replace package mcw_prc_qpr_pkg is

function is_international_within_region(
    i_iss_country    in com_api_type_pkg.t_country_code
  , i_acq_country    in com_api_type_pkg.t_country_code
) return com_api_type_pkg.t_boolean;

procedure qpr_mastercard_data(
    i_dest_curr        in     com_api_type_pkg.t_curr_code
  , i_year             in     com_api_type_pkg.t_tiny_id
  , i_quarter          in     com_api_type_pkg.t_tiny_id
  , i_network_id       in     com_api_type_pkg.t_tiny_id
  , i_cmid_network_id  in     com_api_type_pkg.t_tiny_id    default null
  , i_report_name      in     com_api_type_pkg.t_dict_value default null
  , i_rate_type        in     com_api_type_pkg.t_dict_value default mcw_api_const_pkg.MC_RATE_TYPE
  , i_inst_id          in     com_api_type_pkg.t_inst_id    default null
);

end;
/
