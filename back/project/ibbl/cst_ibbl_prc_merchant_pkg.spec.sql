create or replace package cst_ibbl_prc_merchant_pkg as

procedure process(
    i_fee_type                in     com_api_type_pkg.t_dict_value
  , i_positive_array          in     com_api_type_pkg.t_short_id
  , i_negative_array          in     com_api_type_pkg.t_short_id     default null
  , i_rate_type               in     com_api_type_pkg.t_dict_value   default acq_api_const_pkg.ACQUIRING_RATE_TYPE
  , i_conversion_type         in     com_api_type_pkg.t_dict_value   default com_api_const_pkg.CONVERSION_TYPE_BUYING
  , i_start_date              in     date                            default null
  , i_end_date                in     date                            default null
);

end cst_ibbl_prc_merchant_pkg;
/

