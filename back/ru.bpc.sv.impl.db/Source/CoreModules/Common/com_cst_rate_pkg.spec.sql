create or replace package com_cst_rate_pkg as
/*
 * return rate.
 */
function get_rate (
    i_rate            in number
    , i_eff_rate      in number
)
return number;

end com_cst_rate_pkg;
/