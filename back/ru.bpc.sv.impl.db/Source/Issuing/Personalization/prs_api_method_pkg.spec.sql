create or replace package prs_api_method_pkg is
/************************************************************
 * API for personalization method <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 05.08.2011 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: prs_api_method_pkg <br />
 * @headcom
 ************************************************************/

/*
 * Getting personalization method
 * @param  i_inst_id          - Institution identifier
 * @param  i_perso_method_id  - Personalization method identifier
 */
    function get_perso_method (
        i_inst_id                   in com_api_type_pkg.t_inst_id
        , i_perso_method_id         in com_api_type_pkg.t_tiny_id
    ) return prs_api_type_pkg.t_perso_method_rec;

/*
 * Bulk mark perso method is used
 * @param  i_method_tab  - Personalization method identifier
 */
    procedure mark_perso_method (
        i_method_tab              in com_api_type_pkg.t_number_tab
    );
    
end;
/
