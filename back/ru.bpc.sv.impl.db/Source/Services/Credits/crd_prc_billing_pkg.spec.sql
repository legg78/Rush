create or replace package crd_prc_billing_pkg as

procedure process(
    i_inst_id                     in      com_api_type_pkg.t_inst_id
  , i_cycle_date_type             in      com_api_type_pkg.t_dict_value  default fcl_api_const_pkg.DATE_TYPE_SYSTEM_DATE
  , i_calculate_apr               in      com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
  , i_detailed_entities_array_id  in      com_api_type_pkg.t_short_id    default null
);

procedure process_interest_posting(
    i_inst_id                     in     com_api_type_pkg.t_dict_value
  , i_eff_date                    in     date                            default null
  , i_truncation_type             in     com_api_type_pkg.t_dict_value
  , i_in_due_macros_type          in     com_api_type_pkg.t_tiny_id
  , i_overdue_macros_type         in     com_api_type_pkg.t_tiny_id
  , i_start_date                  in     date                            default null
  , i_end_date                    in     date                            default null
);

end;
/
