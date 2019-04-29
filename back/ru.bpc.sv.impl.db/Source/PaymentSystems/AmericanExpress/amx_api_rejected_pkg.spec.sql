create or replace package amx_api_rejected_pkg as

procedure process_acknowledgment(
    i_ack_message           in     com_api_type_pkg.t_text
  , i_amx_file              in     amx_api_type_pkg.t_amx_file_rec
  , o_original_file_id         out com_api_type_pkg.t_long_id
);

procedure process_rejected_message(
    i_ack_message           in     com_api_type_pkg.t_text
  , i_amx_file              in     amx_api_type_pkg.t_amx_file_rec
  , i_original_file_id      in     com_api_type_pkg.t_long_id
);

end;
/
