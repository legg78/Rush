create or replace package acc_api_mod_pkg as
----------------------------------------------------------------------------------
-- IMPORTANT:
-- This package contains functions which is called from modifiers of module "ACC".
-- Please do not use these functions for other purposes.
----------------------------------------------------------------------------------

function get_operation_sttl_type(
    i_macros_id      in     com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_dict_value;

end acc_api_mod_pkg;
/
