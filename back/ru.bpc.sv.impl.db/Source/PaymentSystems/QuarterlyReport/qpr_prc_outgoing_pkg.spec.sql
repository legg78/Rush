create or replace package qpr_prc_outgoing_pkg as

procedure aggregate_mc_iss (
    i_start_date               in date
    , i_end_date               in date
    , i_inst_id                in com_api_type_pkg.t_inst_id
);

procedure aggregate_mc_acq (
    i_start_date               in date
    , i_end_date               in date
    , i_inst_id                in com_api_type_pkg.t_inst_id
);

procedure aggregate_visa_iss (
    i_start_date               in date
    , i_end_date               in date
    , i_inst_id                in com_api_type_pkg.t_inst_id
);

procedure aggregate_visa_acq (
    i_start_date               in date
    , i_end_date               in date
    , i_inst_id                in com_api_type_pkg.t_inst_id
);

procedure process_mc_iss (
    i_param_group_id_mc        in com_api_type_pkg.t_long_id
    , i_qpr_card_type_id_mc    in com_api_type_pkg.t_tiny_id
    , i_start_date             in date
    , i_end_date               in date
    , i_inst_id                in com_api_type_pkg.t_inst_id
);

procedure process_mc_acq (
    i_param_group_id_mc        in com_api_type_pkg.t_long_id
    , i_start_date             in date
    , i_end_date               in date
    , i_inst_id                in com_api_type_pkg.t_inst_id
);

procedure process_visa_iss (
    i_param_group_id_visa      in com_api_type_pkg.t_long_id
    , i_qpr_card_type_id_visa  in com_api_type_pkg.t_tiny_id
    , i_start_date             in date
    , i_end_date               in date
    , i_inst_id                in com_api_type_pkg.t_inst_id
);

procedure process_visa_acq (
    i_param_group_id_visa      in com_api_type_pkg.t_long_id
    , i_start_date             in date
    , i_end_date               in date
    , i_inst_id                in com_api_type_pkg.t_inst_id
);

end;
/
