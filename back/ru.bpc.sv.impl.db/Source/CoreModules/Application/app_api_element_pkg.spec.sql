create or replace package app_api_element_pkg as
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
) return com_api_type_pkg.t_short_id;

/*
 * Function returns true if entity type <i_entity_type> is linked with
 * some element in application structure.
 */
function is_linked_with_entity(
    i_entity_type          in     com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_boolean;

/*
 * Function returns true if element <i_element_id> is used in applications.
 */
function is_used(
    i_element_id           in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean;

end;
/