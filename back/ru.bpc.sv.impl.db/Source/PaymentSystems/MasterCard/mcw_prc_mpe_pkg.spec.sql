create or replace package mcw_prc_mpe_pkg is

    procedure load (
        i_network_id                in com_api_type_pkg.t_tiny_id := null
        , i_inst_id                 in com_api_type_pkg.t_inst_id := null
        , i_card_network_id         in com_api_type_pkg.t_tiny_id
        , i_card_inst_id            in com_api_type_pkg.t_inst_id := null
        , i_table                   in com_api_type_pkg.t_oracle_name := null
        , i_expansion               in com_api_type_pkg.t_boolean := null
        , i_record_format           in com_api_type_pkg.t_dict_value
    );

    procedure load_currency(
       i_network_id                 in com_api_type_pkg.t_tiny_id
     , i_inst_id                    in com_api_type_pkg.t_tiny_id    
    ) ;

end;
/
 