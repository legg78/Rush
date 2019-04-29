create or replace package body crd_api_mod_pkg as
----------------------------------------------------------------------------------
-- IMPORTANT:
-- This package contains functions which is called from modifiers of module "CRD".
-- Please do not use these functions for other purposes.
----------------------------------------------------------------------------------

-- Function returns com_api_type_pkg.TRUE when TAD from N-th previous invoice is paid.
function get_prev_is_tad_paid(
    i_account_id     in  com_api_type_pkg.t_medium_id
  , i_split_hash     in  com_api_type_pkg.t_tiny_id
  , i_prev_depth     in  com_api_type_pkg.t_long_id    default 1
) return com_api_type_pkg.t_boolean is

    l_is_tad_paid        com_api_type_pkg.t_boolean;
begin

    select max(is_tad_paid)
      into l_is_tad_paid
      from (
          select is_tad_paid
               , row_number() over(order by invoice_date desc) as rn
            from crd_invoice i
           where account_id = i_account_id
             and split_hash = i_split_hash
      )
      where rn = i_prev_depth;

    return nvl(l_is_tad_paid, com_api_type_pkg.TRUE);

end get_prev_is_tad_paid;

-- Function returns com_api_type_pkg.TRUE when MAD from N-th previous invoice is paid.
function get_prev_is_mad_paid(
    i_account_id     in  com_api_type_pkg.t_medium_id
  , i_split_hash     in  com_api_type_pkg.t_tiny_id
  , i_prev_depth     in  com_api_type_pkg.t_long_id    default 1
) return com_api_type_pkg.t_boolean is

    l_is_mad_paid        com_api_type_pkg.t_boolean;
begin

    select max(is_mad_paid)
      into l_is_mad_paid
      from (
          select is_mad_paid
               , row_number() over(order by invoice_date desc) as rn
            from crd_invoice i
           where account_id = i_account_id
             and split_hash = i_split_hash
      )
      where rn = i_prev_depth;

    return nvl(l_is_mad_paid, com_api_type_pkg.TRUE);

end get_prev_is_mad_paid;

end crd_api_mod_pkg;
/
