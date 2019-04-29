CREATE OR REPLACE package itf_prc_entry_pkg is

    procedure upload_entry_obi (
        i_inst_id                 in com_api_type_pkg.t_inst_id
        , i_agent_id              in com_api_type_pkg.t_agent_id := null
        , i_transaction_type      in com_api_type_pkg.t_dict_value := null
        , i_start_date            in date := null
        , i_end_date              in date := null
        , i_shift_from            in com_api_type_pkg.t_tiny_id := 0
        , i_shift_to              in com_api_type_pkg.t_tiny_id := 0
    );

    function get_reletad_id(i_id            in com_api_type_pkg.t_long_id
                            , i_original_id in com_api_type_pkg.t_long_id
                            , i_is_reversal in com_api_type_pkg.t_boolean) 
       return com_api_type_pkg.t_long_id;

end;
/
