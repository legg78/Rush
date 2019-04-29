create or replace package com_api_mcc_pkg is

procedure apply_mcc_update (
    i_mcc_tab           in      com_api_type_pkg.t_mcc_tab
  , i_cab_type_tab      in      com_api_type_pkg.t_mcc_tab
);

procedure apply_mcc_update (
    i_mcc_tab           in      com_api_type_pkg.t_mcc_tab
  , i_cab_type_tab      in      com_api_type_pkg.t_mcc_tab
  , i_active_records    in      com_api_type_pkg.t_integer_tab
);

procedure get_mcc_info(
    i_mcc               in      com_api_type_pkg.t_mcc
  , o_tcc                  out  varchar2
  , o_diners_code          out  varchar2
  , o_mc_cab_type          out  varchar2
);

end;
/