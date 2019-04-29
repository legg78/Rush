create or replace package sec_prc_rsa_certificate_pkg is
/************************************************************
 * RSA certificate process <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 12.05.2011 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: prs_ui_sort_pkg <br />
 * @headcom
 ************************************************************/

/*
 * Make certification authority request
 */

    procedure make_certificate_request;

/*
 * Read certification authority response
 */
    procedure read_certificate_response;

/*
 * Loading ips root certificate
 * @param  i_inst_id                  - Institution identifier
 * @param  i_network_id               - Network identifier
 */
    procedure load_ips_root_cert (
        i_inst_id                     in com_api_type_pkg.t_inst_id
        , i_network_id                in com_api_type_pkg.t_tiny_id
    );
    
/*
 * Loading intermediate certificate
 * @param  i_inst_id                  - Institution identifier
 * @param  i_network_id               - Network identifier
 */
    procedure load_intermediate_cert (
        i_inst_id                     in com_api_type_pkg.t_inst_id
        , i_network_id                in com_api_type_pkg.t_tiny_id
    );    

/*
 * Loading acs certificate
 * @param  i_bin                      - Issuing bin
 * @param  i_authority_id             - Authority identifier
 */    
    procedure load_acs_cert (
        i_bin                         in com_api_type_pkg.t_bin
        , i_authority_id              in com_api_type_pkg.t_tiny_id
    );

end;
/
