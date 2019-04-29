create or replace package mup_api_file_pkg is
    
    function extract_file_date (
        i_p0105                 in mup_api_type_pkg.t_p0105
    ) return date;
    
    function encode_p0105 (
        i_cmid                  in com_api_type_pkg.t_cmid
        , i_file_date           in date
        , i_inst_id             in com_api_type_pkg.t_inst_id
        , i_network_id          in com_api_type_pkg.t_tiny_id
        , i_host_id             in com_api_type_pkg.t_tiny_id
        , i_standard_id         in com_api_type_pkg.t_tiny_id
        , i_collection_only     in com_api_type_pkg.t_boolean    := null
    ) return mup_api_type_pkg.t_pds_body;

end;
/
