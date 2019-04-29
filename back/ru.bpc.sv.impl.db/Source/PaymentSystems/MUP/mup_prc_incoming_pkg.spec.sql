create or replace package mup_prc_incoming_pkg is

    procedure load (
        i_network_id            in com_api_type_pkg.t_tiny_id
      , i_charset               in com_api_type_pkg.t_oracle_name := null
      , i_use_inst              in com_api_type_pkg.t_dict_value  := null
      , i_create_operation      in com_api_type_pkg.t_boolean     := null
    );

procedure load_participant_trans_report(
    i_inst_id    in     com_api_type_pkg.t_inst_id
  , i_network_id in     com_api_type_pkg.t_network_id
);

end;
/
