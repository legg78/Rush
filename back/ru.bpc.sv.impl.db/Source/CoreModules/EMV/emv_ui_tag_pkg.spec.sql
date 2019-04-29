create or replace package emv_ui_tag_pkg is
/************************************************************
 * User interface for EMV tag <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 06.06.2011 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: emv_ui_tag_pkg <br />
 * @headcom
 ************************************************************/

/*
 * Add EMV tag
 * @param  o_id                  - Tag identifier
 * @param  i_tag                 - Tag name
 * @param  i_min_length          - Minimal length
 * @param  i_max_length          - Maximal length
 * @param  i_data_type           - Data type (EMVT dictionary)
 * @param  i_data_format         - Data format mask
 * @param  i_default_value       - Tag default value
 * @param  i_tag_type            - Tag type (EMVP dictionary)
 * @param  i_lang                - Language description
 * @param  i_description         - Tag description
 */
    procedure add_tag (
        o_id                        out com_api_type_pkg.t_tiny_id
        , i_tag                     in com_api_type_pkg.t_tag
        , i_min_length              in com_api_type_pkg.t_tiny_id
        , i_max_length              in com_api_type_pkg.t_tiny_id
        , i_data_type               in com_api_type_pkg.t_dict_value
        , i_data_format             in com_api_type_pkg.t_name
        , i_default_value           in com_api_type_pkg.t_name
        , i_tag_type                in com_api_type_pkg.t_dict_value
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_description             in com_api_type_pkg.t_full_desc
    );

/*
 * Modify EMV tag
 * @param  i_id                  - Tag identifier
 * @param  i_min_length          - Minimal length
 * @param  i_max_length          - Maximal length
 * @param  i_data_type           - Data type (EMVT dictionary)
 * @param  i_data_format         - Data format mask
 * @param  i_default_value       - Tag default value
 * @param  i_tag_type            - Tag type (EMVP dictionary)
 * @param  i_lang                - Language description
 * @param  i_description         - Tag description
 */
    procedure modify_tag (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_min_length              in com_api_type_pkg.t_tiny_id
        , i_max_length              in com_api_type_pkg.t_tiny_id
        , i_data_type               in com_api_type_pkg.t_dict_value
        , i_data_format             in com_api_type_pkg.t_name
        , i_default_value           in com_api_type_pkg.t_name
        , i_tag_type                in com_api_type_pkg.t_dict_value
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_description             in com_api_type_pkg.t_full_desc
    );

/*
 * Remove EMV tag
 * @param  i_id                  - Tag identifier
 */
    procedure remove_tag (
        i_id                        in com_api_type_pkg.t_tiny_id
    );

/*
 * Setup EMV tag value
 * @param  i_tag_id              - Tag identifier
 * @param  i_object_id           - Object identifier
 * @param  i_entity_type         - Entity type
 * @param  i_value               - Tag value
 * @param  i_profile             - Profile of emv application (EPFL dictionary)
 */
    procedure set_tag_value (
        i_tag_id                    in com_api_type_pkg.t_tiny_id
        , i_object_id               in com_api_type_pkg.t_long_id
        , i_entity_type             in com_api_type_pkg.t_dict_value
        , i_value                   in com_api_type_pkg.t_name
        , i_profile                 in com_api_type_pkg.t_dict_value
    );
    
/*
 * Remove EMV tag value
 * @param  i_id                  - Tag value identifier
 */
    procedure remove_tag_value (
        i_id                        in com_api_type_pkg.t_short_id
    );

end; 
/
