create or replace package cst_mpu_prc_incoming_pkg as

procedure load_clearing(
    i_network_id            in     com_api_type_pkg.t_tiny_id
);

procedure load_statistics_data(
    i_network_id            in     com_api_type_pkg.t_tiny_id
);

end cst_mpu_prc_incoming_pkg;
/
