create or replace package body mcw_cst_fin_pkg as
/*********************************************************
 *  The package with user-exits for MasterCard finance message <br />
 *  Created by Truschelev O. (truschelev@bpcbt.com) at 09.12.2015 <br />
 *  Last changed by $Author: truschelev $ <br />
 *  $LastChangedDate: 2015-12-09 18:59:00 +0400#$ <br />
 *  Remcwion: $LastChangedVersion: 1 $ <br />
 *  Module: mcw_cst_fin_pkg <br />
 *  @headcom
 **********************************************************/

/*
 * Get custom de063 value.
 */
function get_de063(
    i_auth_id in com_api_type_pkg.t_long_id
) return mcw_api_type_pkg.t_de063 is
begin
    trc_log_pkg.debug(
        i_text       => lower($$PLSQL_UNIT) || '.get_de063: dummy'
    );    
    return null;
end;

/*
 * Custom preprocessing collections with data about operation and its participants.
 */
procedure before_creating_operation(
    io_oper              in out nocopy opr_api_type_pkg.t_oper_rec
  , io_iss_part          in out nocopy opr_api_type_pkg.t_oper_part_rec
  , io_acq_part          in out nocopy opr_api_type_pkg.t_oper_part_rec
) is
begin
    trc_log_pkg.debug(
        i_text       => lower($$PLSQL_UNIT) || '.before_creating_operation: dummy'
    );    
end;

end;
/
