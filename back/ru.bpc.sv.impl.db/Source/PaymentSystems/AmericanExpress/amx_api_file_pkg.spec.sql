create or replace package amx_api_file_pkg is
    
procedure format_trailer_counts_amounts(
    io_credit_count        in out com_api_type_pkg.t_long_id
  , io_debit_count         in out com_api_type_pkg.t_long_id
  , io_credit_amount       in out com_api_type_pkg.t_money
  , io_debit_amount        in out com_api_type_pkg.t_money
  , io_total_amount        in out com_api_type_pkg.t_money
);

procedure generate_file_number(
    i_cmid                 in     com_api_type_pkg.t_cmid
  , i_transmittal_date     in     date
  , i_inst_id              in     com_api_type_pkg.t_inst_id
  , i_network_id           in     com_api_type_pkg.t_tiny_id
  , i_action_code          in     com_api_type_pkg.t_curr_code
  , i_func_code            in     com_api_type_pkg.t_curr_code   default null
  , o_file_number            out com_api_type_pkg.t_auth_code
);

procedure check_file_processed(
    i_amx_file             in     amx_api_type_pkg.t_amx_file_rec
);

end;
/
