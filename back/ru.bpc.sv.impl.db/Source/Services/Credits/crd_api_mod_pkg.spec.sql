create or replace package crd_api_mod_pkg as
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
) return com_api_type_pkg.t_boolean;

-- Function returns com_api_type_pkg.TRUE when MAD from N-th previous invoice is paid.
function get_prev_is_mad_paid(
    i_account_id     in  com_api_type_pkg.t_medium_id
  , i_split_hash     in  com_api_type_pkg.t_tiny_id
  , i_prev_depth     in  com_api_type_pkg.t_long_id    default 1
) return com_api_type_pkg.t_boolean;

end crd_api_mod_pkg;
/
