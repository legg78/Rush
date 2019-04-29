create or replace package body com_cst_rate_pkg as
/*
 * return rate.
 */
function get_rate (
    i_rate            in number
    , i_eff_rate      in number
) return number is
begin
    return i_eff_rate;
end;

end com_cst_rate_pkg;
/