create or replace package jcb_api_chargeback_pkg is

    procedure gen_first_chargeback (
        o_fin_id                  out com_api_type_pkg.t_long_id
        , i_original_fin_id       in com_api_type_pkg.t_long_id
        , i_de004                 in jcb_api_type_pkg.t_de004
        , i_de049                 in jcb_api_type_pkg.t_de049
        , i_de024                 in jcb_api_type_pkg.t_de024
        , i_de025                 in jcb_api_type_pkg.t_de025
        , i_p3250                 in jcb_api_type_pkg.t_p3250
        , i_de072                 in jcb_api_type_pkg.t_de072
        , i_cashback_amount       in jcb_api_type_pkg.t_de004 := null
    );
    
    procedure gen_second_chargeback (
        o_fin_id                  out com_api_type_pkg.t_long_id
        , i_original_fin_id       in com_api_type_pkg.t_long_id
        , i_de004                 in jcb_api_type_pkg.t_de004
        , i_de049                 in jcb_api_type_pkg.t_de049
        , i_de024                 in jcb_api_type_pkg.t_de024
        , i_de025                 in jcb_api_type_pkg.t_de025
        , i_p3250                 in jcb_api_type_pkg.t_p3250
        , i_de072                 in jcb_api_type_pkg.t_de072
    );
    
    procedure gen_second_presentment (
        o_fin_id                  out com_api_type_pkg.t_long_id
        , i_original_fin_id       in com_api_type_pkg.t_long_id
        , i_de004                 in jcb_api_type_pkg.t_de004
        , i_de049                 in jcb_api_type_pkg.t_de049
        , i_de024                 in jcb_api_type_pkg.t_de024
        , i_de025                 in jcb_api_type_pkg.t_de025
        , i_p3250                 in jcb_api_type_pkg.t_p3250
        , i_de072                 in jcb_api_type_pkg.t_de072
    );
    
end;
/
