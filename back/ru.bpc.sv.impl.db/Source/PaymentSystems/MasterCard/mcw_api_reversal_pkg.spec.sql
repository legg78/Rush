create or replace package mcw_api_reversal_pkg is

    procedure gen_common_reversal (
        o_fin_id              out com_api_type_pkg.t_long_id
      , i_de004            in     mcw_api_type_pkg.t_de004    default null
      , i_de049            in     mcw_api_type_pkg.t_de049    default null
      , i_original_fin_id  in     com_api_type_pkg.t_long_id
      , i_ext_claim_id     in     mcw_api_type_pkg.t_ext_claim_id   default null
      , i_ext_message_id   in     mcw_api_type_pkg.t_ext_message_id default null
    );

end;
/
