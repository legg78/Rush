create or replace package emv_api_application_pkg is
/************************************************************
 * API for EMV application <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 02.09.2011 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: emv_api_application_pkg <br />
 * @headcom
 ************************************************************/

/*
 * Getting EMV application scheme
 * @param i_object_id   - Object identifier
 * @param i_entity_type - Entity type
 */
    function get_emv_appl_scheme (
        i_object_id             in com_api_type_pkg.t_long_id
        , i_entity_type         in com_api_type_pkg.t_dict_value
    ) return emv_api_type_pkg.t_emv_appl_scheme_rec;
    
/*
 * Processing EMV application
 * @param i_appl_scheme_id - Application scheme identifier
 * @param i_perso_rec      - Personalization record
 * @param i_perso_method   - Personalization method
 * @param io_perso_data    - Personalization data
 * @param io_appl_data     - Array application data
 * @param i_params         - Parameters array
 */

    procedure process_application (
        i_appl_scheme_id        in com_api_type_pkg.t_tiny_id
        , i_perso_rec           in prs_api_type_pkg.t_perso_rec
        , i_perso_method        in prs_api_type_pkg.t_perso_method_rec
        , io_perso_data         in out prs_api_type_pkg.t_perso_data_rec
        , io_appl_data          in out emv_api_type_pkg.t_appl_data_tab
        , i_params              in com_api_type_pkg.t_param_tab
    );
    
/*
 * Processing P3 application
 * @param i_appl_scheme_id - Application scheme identifier
 * @param i_perso_rec      - Personalization record
 * @param i_perso_method   - Personalization method
 * @param io_perso_data    - Personalization data
 * @param io_appl_data     - Array application data
 */
    procedure process_p3_application (
        i_appl_scheme_id        in com_api_type_pkg.t_tiny_id
        , i_perso_rec           in prs_api_type_pkg.t_perso_rec
        , i_perso_method        in prs_api_type_pkg.t_perso_method_rec
        , io_perso_data         in out nocopy prs_api_type_pkg.t_perso_data_rec
        , io_appl_data          in out nocopy emv_api_type_pkg.t_appl_data_tab
    );
    
/*
 * Format chip data
 * @param i_card_number  - Card number
 * @param io_appl_data   - Array application data
 * @param o_chip_data    - chip data in raw
 */
    procedure format_chip_data (
        i_card_number           in com_api_type_pkg.t_card_number
        , i_appl_data           in emv_api_type_pkg.t_appl_data_tab
        , o_chip_data           out raw
    );

/*
 * Format P3 chip data
 * @param io_appl_data   - Array application data
 * @param o_raw_data     - p3 data
 */
    procedure format_p3chip_data (
        i_appl_data             in emv_api_type_pkg.t_appl_data_tab
        , o_raw_data            out raw
    );
    
    function get_appl_scheme_type(
        i_tag             in  com_api_type_pkg.t_name
      , i_value           in  com_api_type_pkg.t_param_value
      , i_mask_error      in  com_api_type_pkg.t_boolean        default com_api_const_pkg.TRUE
    )
    return com_api_type_pkg.t_dict_value
    result_cache;
    
end;
/
