create or replace package jcb_api_retrieval_pkg is

procedure gen_retrieval_request (
    o_fin_id                  out com_api_type_pkg.t_long_id
    , i_original_fin_id       in com_api_type_pkg.t_long_id
    , i_de025                 in jcb_api_type_pkg.t_de025
    , i_p3203                 in jcb_api_type_pkg.t_p3203
);
    
end;
/
