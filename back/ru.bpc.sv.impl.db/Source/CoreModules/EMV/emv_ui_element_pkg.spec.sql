create or replace package emv_ui_element_pkg is
/************************************************************
 * User interface for EMV element <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 06.06.2011 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: emv_ui_element_pkg <br />
 * @headcom
 ************************************************************/

/*
 * Add EMV element
 * @param  o_id                  - Element identifier
 * @param  o_seqnum              - Element sequence number
 * @param  i_parent_id           - Reference to parent element indentifier
 * @param  i_entity_type         - Entity type element
 * @param  i_object_id           - Element object identifier
 * @param  i_element_order       - Order within element
 * @param  i_code                - Element code
 * @param  i_tag                 - Tag name
 * @param  i_value               - Tag value
 * @param  i_is_optional         - Option if value is optional
 * @param  i_add_length          - Add to value of length
 * @param  i_start_position      - Returns a portion of element value, beginning at start_position, length long
 * @param  i_length              - Returns a portion of element value, beginning at start_position, length long
 * @param  i_profile             - Profile of EMV application (EPFL dictionary)
 */
    procedure add_element (
        o_id                        out com_api_type_pkg.t_short_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_parent_id               in com_api_type_pkg.t_short_id
        , i_entity_type             in com_api_type_pkg.t_dict_value
        , i_object_id               in com_api_type_pkg.t_short_id
        , i_element_order           in com_api_type_pkg.t_tiny_id
        , i_code                    in com_api_type_pkg.t_name
        , i_tag                     in com_api_type_pkg.t_tag
        , i_value                   in com_api_type_pkg.t_name
        , i_is_optional             in com_api_type_pkg.t_boolean
        , i_add_length              in com_api_type_pkg.t_boolean
        , i_start_position          in com_api_type_pkg.t_tiny_id
        , i_length                  in com_api_type_pkg.t_tiny_id
        , i_profile                 in com_api_type_pkg.t_dict_value := null
    );

/*
 * Modify EMV element
 * @param  o_id                  - Element identifier
 * @param  io_seqnum             - Element sequence number
 * @param  i_parent_id           - Reference to parent element indentifier
 * @param  i_entity_type         - Entity type element
 * @param  i_object_id           - Element object identifier
 * @param  i_element_order       - Order within element 
 * @param  i_code                - Element code
 * @param  i_tag                 - Tag name
 * @param  i_value               - Tag value
 * @param  i_is_optional         - Option if value is optional
 * @param  i_add_length          - Add to value of length
 * @param  i_start_position      - Returns a portion of element value, beginning at start_position, length long
 * @param  i_length              - Returns a portion of element value, beginning at start_position, length long
 * @param  i_profile             - Profile of EMV application (EPFL dictionary)
 */
    procedure modify_element (
        i_id                        in com_api_type_pkg.t_short_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_parent_id               in com_api_type_pkg.t_short_id
        , i_entity_type             in com_api_type_pkg.t_dict_value
        , i_object_id               in com_api_type_pkg.t_short_id
        , i_element_order           in com_api_type_pkg.t_tiny_id
        , i_code                    in com_api_type_pkg.t_name
        , i_tag                     in com_api_type_pkg.t_tag
        , i_value                   in com_api_type_pkg.t_name
        , i_is_optional             in com_api_type_pkg.t_boolean
        , i_add_length              in com_api_type_pkg.t_boolean
        , i_start_position          in com_api_type_pkg.t_tiny_id
        , i_length                  in com_api_type_pkg.t_tiny_id
        , i_profile                 in com_api_type_pkg.t_dict_value := null
    );

/*
 * Remove EMV element
 * @param  i_id                  - Element identifier
 * @param  i_seqnum              - Element sequence number
 */
    procedure remove_element (
        i_id                        in com_api_type_pkg.t_short_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    );

end;
/
