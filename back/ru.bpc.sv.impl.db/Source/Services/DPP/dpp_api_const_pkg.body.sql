create or replace package body dpp_api_const_pkg is
/*********************************************************
*  Constants for DPP module <br />
*  Created by  E. Kryukov (kryukov@bpc.ru)  at 06.09.2011 <br />
*  Module: DPP_API_CONST_PKG <br />
*  @headcom
**********************************************************/

function get_dpp_service_type return com_api_type_pkg.t_short_id as
begin
    return dpp_api_const_pkg.DPP_SERVICE_TYPE_ID;
end;

end dpp_api_const_pkg;
/
