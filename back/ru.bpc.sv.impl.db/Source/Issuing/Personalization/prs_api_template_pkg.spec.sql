create or replace package prs_api_template_pkg is
/************************************************************
 * API for personalization template <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 22.10.2010 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: prs_api_template_pkg <br />
 * @headcom
 ************************************************************/

/*
 * Get template values
 * @param  i_format_id         - Personalization format identifier
 * @param  i_perso_rec         - Personalization record
 * @param  i_perso_method      - Personalization method
 * @param  i_perso_data        - Personalization data
 * @param  i_entity_type       - Personalization template entity type
 * @param  i_record_number     - Record number
 * @param  o_param_tab         - Naming format params
 */
    procedure set_template_param (
        i_format_id             in com_api_type_pkg.t_tiny_id
        , i_perso_rec           in prs_api_type_pkg.t_perso_rec
        , i_perso_method        in prs_api_type_pkg.t_perso_method_rec
        , i_perso_data          in prs_api_type_pkg.t_perso_data_rec
        , i_entity_type         in com_api_type_pkg.t_dict_value
        , i_record_number       in pls_integer
        , o_param_tab           out nocopy com_api_type_pkg.t_param_tab
    );
    
/*
 * Parse track2 discretionary data by naming format
 * @param  i_format_id        - Personalization format identifier
 * @param  i_discr_data       - track discretionary data
 * @param  o_pvv              - Pin offeset or PVV
 * @param  o_pvk_index        - PVK Index used for PVV generation
 * @param  o_cvv              - CVV value
 * @param  o_atc              - ATC value
 */
    procedure parse_discr_data (
        i_format_id             in com_api_type_pkg.t_tiny_id
        , i_discr_data          in com_api_type_pkg.t_name
        , o_pvv                 out com_api_type_pkg.t_name
        , o_pvk_index           out com_api_type_pkg.t_name
        , o_cvv                 out com_api_type_pkg.t_name
        , o_atc                 out com_api_type_pkg.t_name
    );

/*
 * Parse track2 discretionary contact data by personalization method
 * @param  i_perso_method_id  - Personalization method identifier
 * @param  i_discr_data       - track discretionary data
 * @param  o_pvv              - Pin offeset or PVV
 * @param  o_pvk_index        - PVK Index used for PVV generation
 * @param  o_cvv              - CVV value
 */    
    procedure parse_discr_data (
        i_perso_method_id       in com_api_type_pkg.t_short_id
        , i_discr_data          in com_api_type_pkg.t_name
        , o_pvv                 out com_api_type_pkg.t_name
        , o_pvk_index           out com_api_type_pkg.t_name
        , o_cvv                 out com_api_type_pkg.t_name
        , o_atc                 out com_api_type_pkg.t_name
        , i_discr_type          in     com_api_type_pkg.t_short_id := null
    );
    
/*
 * Parse track discretionary contactless data by personalization method
 * @param  i_perso_method_id  - Personalization method identifier
 * @param  i_discr_data       - Track discretionary data
 * @param  i_track_type       - Track type - track1, track2
 * @param  o_bitmask_pcvc3    - Bitmask pcvc3 track
 * @param  o_bitmask_punatc   - Bitmask punatc track
 * @param  o_natc             - natc track
 */

    procedure parse_discr_contactless_data (
        i_perso_method_id       in com_api_type_pkg.t_short_id
        , i_discr_data          in com_api_type_pkg.t_name
        , i_track_type          in com_api_type_pkg.t_dict_value
        , o_bitmask_pcvc3       out com_api_type_pkg.t_name
        , o_bitmask_punatc      out com_api_type_pkg.t_name
        , o_natc                out com_api_type_pkg.t_tiny_id
    );

/*
 * Parse track discretionary contactless data by personalization method
 * @param  i_perso_method_id  - Personalization method identifier
 * @param  i_discr_data       - Track discretionary data
 * @param  o_atc              - ATC track
 * @param  o_un_placeholder   - UN track
 * @param  o_cvc3             - CVC3 track
 * @param  o_pvv              - Pin offeset or PVV
 * @param  o_pvk_index        - PVK Index used for PVV generation
 */

    procedure parse_discr_contactless_data (
        i_perso_method_id       in com_api_type_pkg.t_short_id
        , i_discr_data          in com_api_type_pkg.t_name
        , o_atc                 out com_api_type_pkg.t_name
        , o_un_placeholder      out com_api_type_pkg.t_name
        , o_cvc3                out com_api_type_pkg.t_name
        , o_pvv                 out com_api_type_pkg.t_name
        , o_pvk_index           out com_api_type_pkg.t_name
    );
    
/*
 * Apply templates for card
 * @param  i_inst_id             - Institution identifier
 * @param  i_perso_rec           - Personalization record
 * @param  i_embossing_request   - Requesting action about plastic embossing
 * @param  i_pin_mailer_request  - Requesting action about PIN mailer printing
 * @param  i_perso_method        - Personalization method
 * @param  io_perso_data         - Personalization data
 */    
    procedure setup_templates (
        i_inst_id               in com_api_type_pkg.t_inst_id
        , i_perso_rec           in prs_api_type_pkg.t_perso_rec
        , i_embossing_request   in com_api_type_pkg.t_dict_value
        , i_pin_mailer_request  in com_api_type_pkg.t_dict_value
        , i_perso_method        in prs_api_type_pkg.t_perso_method_rec
        , io_perso_data         in out nocopy prs_api_type_pkg.t_perso_data_rec
    );

end; 
/
