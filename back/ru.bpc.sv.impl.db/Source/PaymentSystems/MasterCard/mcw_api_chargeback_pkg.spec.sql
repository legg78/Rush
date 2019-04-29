create or replace package mcw_api_chargeback_pkg is

procedure gen_first_chargeback (
    o_fin_id               out com_api_type_pkg.t_long_id
  , i_original_fin_id   in     com_api_type_pkg.t_long_id
  , i_de004             in     mcw_api_type_pkg.t_de004
  , i_de049             in     mcw_api_type_pkg.t_de049
  , i_de024             in     mcw_api_type_pkg.t_de024
  , i_de025             in     mcw_api_type_pkg.t_de025
  , i_p0262             in     mcw_api_type_pkg.t_p0262
  , i_de072             in     mcw_api_type_pkg.t_de072
  , i_cashback_amount   in     mcw_api_type_pkg.t_de004
  , i_ext_claim_id      in     mcw_api_type_pkg.t_ext_claim_id   default null
  , i_ext_message_id    in     mcw_api_type_pkg.t_ext_message_id default null
);
    
procedure gen_second_chargeback (
    o_fin_id               out com_api_type_pkg.t_long_id
  , i_original_fin_id   in     com_api_type_pkg.t_long_id
  , i_de004             in     mcw_api_type_pkg.t_de004
  , i_de049             in     mcw_api_type_pkg.t_de049
  , i_de024             in     mcw_api_type_pkg.t_de024
  , i_de025             in     mcw_api_type_pkg.t_de025
  , i_p0262             in     mcw_api_type_pkg.t_p0262
  , i_de072             in     mcw_api_type_pkg.t_de072
  , i_ext_claim_id      in     mcw_api_type_pkg.t_ext_claim_id   default null
  , i_ext_message_id    in     mcw_api_type_pkg.t_ext_message_id default null
);
    
procedure gen_second_presentment (
    o_fin_id               out com_api_type_pkg.t_long_id
  , i_original_fin_id   in     com_api_type_pkg.t_long_id
  , i_de004             in     mcw_api_type_pkg.t_de004
  , i_de049             in     mcw_api_type_pkg.t_de049
  , i_de024             in     mcw_api_type_pkg.t_de024
  , i_de025             in     mcw_api_type_pkg.t_de025
  , i_p0262             in     mcw_api_type_pkg.t_p0262
  , i_de072             in     mcw_api_type_pkg.t_de072
  , i_ext_claim_id      in     mcw_api_type_pkg.t_ext_claim_id   default null
  , i_ext_message_id    in     mcw_api_type_pkg.t_ext_message_id default null
);

procedure modify_first_chargeback(
    i_fin_id            in     com_api_type_pkg.t_long_id
  , i_de004             in     mcw_api_type_pkg.t_de004
  , i_de049             in     mcw_api_type_pkg.t_de049
  , i_de024             in     mcw_api_type_pkg.t_de024
  , i_de025             in     mcw_api_type_pkg.t_de025
  , i_p0262             in     mcw_api_type_pkg.t_p0262
  , i_de072             in     mcw_api_type_pkg.t_de072
  , i_cashback_amount   in     mcw_api_type_pkg.t_de004
);

procedure modify_second_presentment (
    i_fin_id            in     com_api_type_pkg.t_long_id
  , i_de004             in     mcw_api_type_pkg.t_de004
  , i_de049             in     mcw_api_type_pkg.t_de049
  , i_de024             in     mcw_api_type_pkg.t_de024
  , i_de025             in     mcw_api_type_pkg.t_de025
  , i_p0262             in     mcw_api_type_pkg.t_p0262
  , i_de072             in     mcw_api_type_pkg.t_de072
);

procedure modify_second_chargeback(
    i_fin_id            in     com_api_type_pkg.t_long_id
  , i_de004             in     mcw_api_type_pkg.t_de004
  , i_de049             in     mcw_api_type_pkg.t_de049
  , i_de024             in     mcw_api_type_pkg.t_de024
  , i_de025             in     mcw_api_type_pkg.t_de025
  , i_p0262             in     mcw_api_type_pkg.t_p0262
  , i_de072             in     mcw_api_type_pkg.t_de072
);
    
end mcw_api_chargeback_pkg;
/
