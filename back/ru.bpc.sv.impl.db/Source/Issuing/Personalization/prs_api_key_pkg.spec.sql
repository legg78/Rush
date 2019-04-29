create or replace package prs_api_key_pkg is
/************************************************************
 * The API for keys <br />
 * Created by Kopachev D.(kopachev@bpcbt.ru) at 20.05.2010 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2010-06-30 15:04:48 +0400#$ <br />
 * Revision: $LastChangedRevision: 0000 $ <br />
 * Module: PRS_API_KEY_PKG <br />
 * @headcom
 ************************************************************/

/*
 * Clear global data
 */
    procedure clear_global_data;

/*
 * Getting personalization keys
 * @param  i_perso_rec      - Personalization record
 * @param  i_perso_method   - Personalization method
 * @param  i_hsm_device_id  - HSM device identifier
 */
    function get_perso_keys (
        i_perso_rec                 in prs_api_type_pkg.t_perso_rec
        , i_perso_method            in prs_api_type_pkg.t_perso_method_rec
        , i_hsm_device_id           in com_api_type_pkg.t_tiny_id
    ) return prs_api_type_pkg.t_perso_key_rec;

end; 
/
