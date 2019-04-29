create or replace package body app_api_element_pkg as
/*********************************************************
 *  Application element API  <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 14.09.2009 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: app_api_element_pkg  <br />
 *  @headcom
 **********************************************************/

function get_element_id(
    i_element_name         in     com_api_type_pkg.t_name
) return com_api_type_pkg.t_short_id is
    l_result               com_api_type_pkg.t_short_id;
begin
    select id
      into l_result
      from app_element_all_vw
     where name = upper(i_element_name);

    return l_result;

end get_element_id;

/*
 * Function returns true if entity type <i_entity_type> is linked with
 * some element in application structure.
 */
function is_linked_with_entity(
    i_entity_type          in     com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_boolean
is
    l_result               com_api_type_pkg.t_boolean;
begin
    com_api_dictionary_pkg.check_article(
        i_dict => com_api_const_pkg.ENTITY_TYPE_DICTIONARY
      , i_code => i_entity_type
    );

    begin
        select com_api_type_pkg.TRUE
          into l_result
          from app_element e
         where e.entity_type  = i_entity_type
           and e.element_type = app_api_const_pkg.APPL_ELEMENT_TYPE_COMPLEX
           and rownum = 1;
    exception
        when no_data_found then
            l_result := com_api_type_pkg.FALSE;
    end;
    return l_result;
end is_linked_with_entity;

/*
 * Function returns true if element <i_element_id> is used in applications.
 */
function is_used(
    i_element_id           in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean
is
    l_result               com_api_type_pkg.t_boolean;
begin
    begin
        select com_api_type_pkg.TRUE
          into l_result
          from app_data d
          join app_element_all_vw e  on e.id = d.element_id
         where e.id = i_element_id
           and rownum = 1;
    exception
        when no_data_found then
            l_result := com_api_type_pkg.FALSE;
    end;
    return l_result;
end is_used;

end app_api_element_pkg;
/
