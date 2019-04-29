create or replace package body acc_api_mod_pkg as
----------------------------------------------------------------------------------
-- IMPORTANT:
-- This package contains functions which is called from modifiers of module "ACC".
-- Please do not use these functions for other purposes.
----------------------------------------------------------------------------------

g_macros_id          com_api_type_pkg.t_long_id;
g_sttl_type          com_api_type_pkg.t_dict_value;

function get_operation_sttl_type(
    i_macros_id      in     com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_dict_value
is
    l_sttl_type      com_api_type_pkg.t_dict_value;
begin

    l_sttl_type := opr_api_shared_data_pkg.get_operation().sttl_type;

    if l_sttl_type is null then

        if g_macros_id    is null
           or i_macros_id != g_macros_id
        then
            select o.sttl_type
              into l_sttl_type
              from acc_macros    m
                 , opr_operation o
             where m.id          = i_macros_id
               and m.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
               and o.id          = m.object_id;

            g_macros_id := i_macros_id;
            g_sttl_type := l_sttl_type;
        else
            l_sttl_type := g_sttl_type;
        end if;

    end if;

    return l_sttl_type;

end get_operation_sttl_type;

end acc_api_mod_pkg;
/
