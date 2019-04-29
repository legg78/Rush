create or replace package tie_prc_outgoing_pkg is

-- Purpose : Tieto Outgoing clearing file generation
  
procedure process(
    i_network_id          in com_api_type_pkg.t_tiny_id
  , i_inst_id             in com_api_type_pkg.t_inst_id
  , i_start_date          in date default null
  , i_end_date            in date default null
  , i_card_network_id     in com_api_type_pkg.t_tiny_id default null
  , i_file_type           in com_api_type_pkg.t_name default 'D'
);

end tie_prc_outgoing_pkg;
/
