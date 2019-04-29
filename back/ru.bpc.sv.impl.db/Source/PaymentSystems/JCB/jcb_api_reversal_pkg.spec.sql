create or replace package jcb_api_reversal_pkg is

    procedure gen_common_reversal (
        o_fin_id                  out com_api_type_pkg.t_long_id
        , i_de004                 in jcb_api_type_pkg.t_de004 := null
        , i_de049                 in jcb_api_type_pkg.t_de049 := null
        , i_original_fin_id       in com_api_type_pkg.t_long_id
    );

end;
/
