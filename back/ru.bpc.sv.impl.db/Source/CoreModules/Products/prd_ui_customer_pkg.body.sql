create or replace package body prd_ui_customer_pkg is
/*********************************************************
*  UI for customers <br />
*  Created by Fomichev A.(fomichev@bpcbt.com)  at 16.08.2012 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: prd_ui_customer_pkg <br />
*  @headcom
**********************************************************/

procedure modify_customer(
    i_customer_id     in      com_api_type_pkg.t_medium_id
  , i_ext_entity_type in      com_api_type_pkg.t_dict_value
  , i_ext_object_id   in      com_api_type_pkg.t_long_id
) is
    l_inst_id                 com_api_type_pkg.t_inst_id;
begin
    select p.inst_id
      into l_inst_id
      from prd_customer p
     where p.id = i_customer_id;

    ost_api_institution_pkg.check_status(
        i_inst_id     => l_inst_id
      , i_data_action => com_api_const_pkg.DATA_ACTION_MODIFY
    );

    -- Agent <i_ext_object_id> should be associated with only one customer and vice versa,
    -- otherwise an error will be rised
    prd_api_customer_pkg.check_association(
        i_customer_id     => i_customer_id
      , i_ext_entity_type => i_ext_entity_type
      , i_ext_object_id   => i_ext_object_id
    );

    update prd_customer_vw
       set ext_entity_type = i_ext_entity_type
         , ext_object_id   = i_ext_object_id
     where id              = i_customer_id;
end;

procedure clear_ext_fields(
    i_customer_id     in      com_api_type_pkg.t_medium_id
) is
begin
    update prd_customer_vw
       set ext_entity_type = null
         , ext_object_id   = null
     where id              = i_customer_id;
end;

function get_customer_name(
    i_customer_id     in       com_api_type_pkg.t_medium_id
  , i_lang            in       com_api_type_pkg.t_dict_value default null
) return com_api_type_pkg.t_name
is
    l_res       com_api_type_pkg.t_name;
begin
    for tab in (select entity_type
                     , object_id 
                  from prd_customer
                 where id = i_customer_id)
    loop
        trc_log_pkg.debug(
            i_text       => 'get_customer_name: found object [#1] for [#2] of type [#3]'
          , i_env_param1 => tab.object_id
          , i_env_param2 => i_customer_id
          , i_env_param3 => tab.entity_type
        );

        case tab.entity_type 
            when com_api_const_pkg.ENTITY_TYPE_PERSON
                then
                    l_res := com_ui_person_pkg.get_person_name(
                                 i_person_id => tab.object_id
                               , i_lang        => i_lang
                             );
            when com_api_const_pkg.ENTITY_TYPE_COMPANY
                then
                    l_res := get_text(
                                 i_table_name  => 'COM_COMPANY'
                               , i_column_name => 'LABEL'
                               , i_object_id   => tab.object_id
                               , i_lang        => i_lang
                             );
            else null;
        end case;
    end loop;

    trc_log_pkg.debug(
        i_text       => 'get_customer_name: [#1]'
      , i_env_param1 => l_res
    );
    return l_res;
end get_customer_name;

end;
/
