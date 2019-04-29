create or replace package prd_ui_attribute_pkg is
/*********************************************************
*  UI for attributes<br />
*  Created by Kopachev D.(kopachev@bpcbt.com)  at 15.11.2010 <br />
*  Last changed by $Author: fomichev $ <br />
*  $LastChangedDate:: 2011-07-13 16:20:00 +0400#$ <br />
*  Revision: $LastChangedRevision: 10500 $ <br />
*  Module: prd_ui_attribute_pkg <br />
*  @headcom
**********************************************************/

    procedure add_attribute (
        o_id                         out com_api_type_pkg.t_short_id
        , i_service_type_id       in     com_api_type_pkg.t_short_id
        , i_parent_id             in     com_api_type_pkg.t_short_id
        , i_attr_name             in     com_api_type_pkg.t_name
        , i_data_type             in     com_api_type_pkg.t_dict_value
        , i_lov_id                in     com_api_type_pkg.t_tiny_id
        , i_display_order         in     com_api_type_pkg.t_tiny_id
        , i_lang                  in     com_api_type_pkg.t_dict_value
        , i_short_description     in     com_api_type_pkg.t_name
        , i_description           in     com_api_type_pkg.t_full_desc
        , i_entity_type           in     com_api_type_pkg.t_dict_value
        , i_object_type           in     com_api_type_pkg.t_dict_value
        , i_definition_level      in     com_api_type_pkg.t_dict_value
        , i_is_cycle              in     com_api_type_pkg.t_boolean
        , i_is_use_limit          in     com_api_type_pkg.t_boolean
        , i_is_limit_cyclic       in     com_api_type_pkg.t_boolean
        , i_is_visible            in     com_api_type_pkg.t_boolean
        , i_is_service_fee        in     com_api_type_pkg.t_boolean
        , i_cycle_calc_start_date in     com_api_type_pkg.t_dict_value
        , i_cycle_calc_date_type  in     com_api_type_pkg.t_dict_value
        , i_posting_method        in     com_api_type_pkg.t_dict_value    default null
        , i_counter_algorithm     in     com_api_type_pkg.t_dict_value    default null
        , i_short_name            in     com_api_type_pkg.t_name          default null
        , i_is_repeating          in     com_api_type_pkg.t_boolean       default null
        , i_need_length_type      in     com_api_type_pkg.t_boolean       default null
        , i_module_code           in     com_api_type_pkg.t_module_code   default null
        , i_limit_usage           in     com_api_type_pkg.t_dict_value    default null
    );

    procedure modify_attribute (
        i_id                      in     com_api_type_pkg.t_short_id
        , i_service_type_id       in     com_api_type_pkg.t_short_id
        , i_parent_id             in     com_api_type_pkg.t_short_id
        , i_display_order         in     com_api_type_pkg.t_tiny_id
        , i_lang                  in     com_api_type_pkg.t_dict_value
        , i_short_description     in     com_api_type_pkg.t_name
        , i_description           in     com_api_type_pkg.t_full_desc
        , i_is_visible            in     com_api_type_pkg.t_boolean
        , i_is_service_fee        in     com_api_type_pkg.t_boolean
        , i_is_repeating          in     com_api_type_pkg.t_boolean       default null
        , i_counter_algorithm     in     com_api_type_pkg.t_dict_value    default null
    );

    procedure delete_attribute (
        i_id                      in     com_api_type_pkg.t_short_id
    );

    procedure add_attribute_scale (
        o_id                         out com_api_type_pkg.t_tiny_id
        , i_attr_id               in     com_api_type_pkg.t_short_id
        , i_inst_id               in     com_api_type_pkg.t_tiny_id
        , i_scale_id              in     com_api_type_pkg.t_tiny_id
        , o_seqnum                   out com_api_type_pkg.t_tiny_id
    );

    procedure modify_attribute_scale (
        i_id                      in     com_api_type_pkg.t_tiny_id
        , i_scale_id              in     com_api_type_pkg.t_tiny_id
        , io_seqnum               in out com_api_type_pkg.t_seqnum
    );

    procedure remove_attribute_scale (
        i_id                      in     com_api_type_pkg.t_tiny_id
        , i_seqnum                in     com_api_type_pkg.t_tiny_id
    );

    function get_cycle_type (
        i_attr_name               in     com_api_type_pkg.t_name
    ) return com_api_type_pkg.t_dict_value;

end;
/
