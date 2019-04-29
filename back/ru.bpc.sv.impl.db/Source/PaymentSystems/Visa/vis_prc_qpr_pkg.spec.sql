create or replace package vis_prc_qpr_pkg is

    procedure qpr_visa_data (
        i_dest_curr               in com_api_type_pkg.t_curr_code
        , i_year                  in com_api_type_pkg.t_tiny_id
        , i_quarter               in com_api_type_pkg.t_tiny_id
        , i_network_id            in com_api_type_pkg.t_tiny_id
        , i_report_code           in com_api_type_pkg.t_dict_value default null
        , i_rate_type             in com_api_type_pkg.t_dict_value default vis_api_const_pkg.VISA_RATE_TYPE
        , i_inst_id               in com_api_type_pkg.t_inst_id    default null
        , i_host_inst_id          in com_api_type_pkg.t_inst_id    default null
    );
end;
/
