create or replace package emv_api_script_pkg is
/************************************************************
 * API for EMV script <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 06.07.2011 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: emv_api_script_pkg <br />
 * @headcom
 ************************************************************/
    
/*
 * Get ARQC tags
 * @param  i_object_id   - Object identifier
 * @param  i_entity_type - Entity type
 * @param  o_tag_tab     - Tags array
 */
    procedure get_arqc_tags (
        i_object_id             in com_api_type_pkg.t_long_id
        , i_entity_type         in com_api_type_pkg.t_dict_value
        , o_tag_tab             out com_api_type_pkg.t_dict_tab
    );
    
/*
 * Script status is processing
 * @param  i_object_id   - Object identifier
 * @param  i_entity_type - Entity type
 */
    function is_script_sent (
        i_object_id             in com_api_type_pkg.t_long_id
        , i_entity_type         in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean;
    
/*
 * Change script status
 * @param  i_object_id   - Object identifier
 * @param  i_entity_type - Entity type
 * @param  i_script_id   - Script identifier
 * @param  i_type        - Script type dictionary
 * @param  i_status      - Script status
 */    
    procedure change_script_status (
        i_object_id             in com_api_type_pkg.t_long_id
        , i_entity_type         in com_api_type_pkg.t_dict_value
        , i_script_id           in com_api_type_pkg.t_long_id := null
        , i_type                in com_api_type_pkg.t_dict_value := null
        , i_status              in com_api_type_pkg.t_dict_value 
    );
    
/*
 * Change script status
 * @param  i_card_instance_id - Card instance identifier
 * @param  i_script_id        - Script identifier
 * @param  i_type             - Script type dictionary
 * @param  i_status           - Script status
 */
    procedure change_card_script_status (
        i_card_instance_id      in com_api_type_pkg.t_medium_id
        , i_script_id           in com_api_type_pkg.t_long_id := null
        , i_type                in com_api_type_pkg.t_dict_value := null
        , i_status              in com_api_type_pkg.t_dict_value 
    );
    
/*
 * Select scripts record
 * @param  i_object_id   - Object identifier
 * @param  i_entity_type - Entity type
 * @param  i_status      - Script status
 * @param  o_script_tab  - Script record
 */
    procedure select_scripts (
        i_object_id             in com_api_type_pkg.t_long_id
        , i_entity_type         in com_api_type_pkg.t_dict_value
        , i_status              in com_api_type_pkg.t_dict_value := null
        , o_script_tab          out nocopy emv_api_type_pkg.t_emv_script_tab
    );
    
/*
 * Select card scripts record
 * @param  i_card_instance_id - Card instance identifier
 * @param  i_status           - Script status
 * @param  o_script_tab       - Script record
 */
    procedure select_card_scripts (
        i_card_instance_id      in com_api_type_pkg.t_medium_id
        , i_status              in com_api_type_pkg.t_dict_value := null
        , o_script_tab          out nocopy emv_api_type_pkg.t_emv_script_tab
    );
    
/*
 * Register script
 * @param  i_object_id   - Object identifier
 * @param  i_entity_type - Entity type
 * @param  i_type        - Script type
 * @param  i_data        - String of bytes sent in the data field of the command
 * @param  i_status      - Script status
 */
    procedure register_script (
        i_object_id             in com_api_type_pkg.t_long_id
        , i_entity_type         in com_api_type_pkg.t_dict_value
        , i_type                in com_api_type_pkg.t_dict_value
        , i_data                in com_api_type_pkg.t_name := null
        , i_status              in com_api_type_pkg.t_dict_value := null
    );

/*
 * Register block card script
 * @param  i_card_instance_id   - Card instance identifier
 */
    procedure register_script_block_card (
        i_card_instance_id      in com_api_type_pkg.t_medium_id
    );

/*
 * Register pin change script
 * @param  i_card_instance_id - Card instance identifier
 * @param  i_pvv              - PVV
 * @param  i_pin_block        - Pin block
 */
    procedure register_script_pin_change (
        i_card_instance_id      in com_api_type_pkg.t_medium_id
        , i_pvv                 in com_api_type_pkg.t_tiny_id
        , i_pin_block           in com_api_type_pkg.t_pin_block
    );

/*
 * Register pin unblock
 * @param  i_card_instance_id - Card instance identifier
 */
    procedure  register_script_pin_unblock (
        i_card_instance_id      in com_api_type_pkg.t_medium_id
    );
    
/*
 * Register block application script
 * @param  i_card_instance_id   - Card instance identifier
 */
    procedure register_script_block_appl (
        i_card_instance_id      in com_api_type_pkg.t_medium_id
    );
    
/*
 * Register unblock application script
 * @param  i_card_instance_id   - Card instance identifier
 */
    procedure register_script_unblock_appl (
        i_card_instance_id      in com_api_type_pkg.t_medium_id
    );

/*
 * Link script with authorization
 * @param  i_auth_id            - Authorizations identifier
 * @param  i_script_id          - Scripts identifier
 */
    procedure link_script (
        i_auth_id               in com_api_type_pkg.t_long_id
        , i_script_id           in com_api_type_pkg.t_long_id
    );
    
/*
 * Link script with authorization
 * @param  i_auth_id            - Authorizations identifier array
 * @param  i_script_id          - Scripts identifier array
 */
    procedure link_scripts (
        i_auth_id               in com_api_type_pkg.t_number_tab
        , i_script_id           in com_api_type_pkg.t_number_tab
    );

/*
 * Select linked script for authorization
 * @param  i_auth_id            - Authorizations identifier array
 * @param  o_script_tab         - Scripts identifier array
 */
    procedure get_link_scripts (
        i_auth_id               in com_api_type_pkg.t_long_id
        , o_script_tab          out nocopy com_api_type_pkg.t_number_tab
    );    

end;
/
