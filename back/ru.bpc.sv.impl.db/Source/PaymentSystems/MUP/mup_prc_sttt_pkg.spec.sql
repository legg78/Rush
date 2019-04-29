create or replace package mup_prc_sttt_pkg is

    procedure process_summary (
        i_network_id             in com_api_type_pkg.t_tiny_id
    );
    
    procedure process_settlement (
        i_network_id             in com_api_type_pkg.t_tiny_id
        , i_inst_id              in com_api_type_pkg.t_inst_id
    );

end; 
/
