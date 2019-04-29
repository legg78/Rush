create or replace package cst_tie_prc_outgoing_pkg is

-- Purpose : Tieto Outgoing clearing file generation
  
procedure process(
    i_network_id          in com_api_type_pkg.t_tiny_id default '5001'
  , i_inst_id             in com_api_type_pkg.t_inst_id default '1001'
  , i_start_date          in date default null
  , i_end_date            in date default null
  , i_card_network_id     in com_api_type_pkg.t_tiny_id default null
);

end cst_tie_prc_outgoing_pkg;
/
