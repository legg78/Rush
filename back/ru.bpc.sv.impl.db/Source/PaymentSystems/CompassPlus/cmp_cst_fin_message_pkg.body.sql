create or replace package body cmp_cst_fin_message_pkg as
/*********************************************************
 *  The package with user-exits for VISA dispute processing <br />
 *
 *  Created by Alalykin A. (alalykin@bpcbt.com) at 28.01.2015 <br />
 *  Last changed by $Author: alalykin $ <br />
 *  $LastChangedDate: 2015-01-28 13:00:00 +0400#$ <br />
 *  Revision: $LastChangedRevision: 1 $ <br />
 *  Module: vis_cst_dispute_pkg <br />
 *  @headcom
 **********************************************************/

/*
 * Custom processing for generation of financial message's.
 */
function get_orig_fi_name(
    i_auth_rec              in aut_api_type_pkg.t_auth_rec
    , i_collect_only        in com_api_type_pkg.t_boolean
    , i_fin_message         in cmp_api_type_pkg.t_cmp_fin_mes_rec
)return com_api_type_pkg.t_name is
begin
    trc_log_pkg.debug(
        i_text       => lower($$PLSQL_UNIT) || '.get_orig_fi_name: dummy'
    );    

    return i_fin_message.orig_fi_name;
end;

/*
 * Custom processing for generation of financial message's.
 */
function get_dest_fi_name(
    i_auth_rec              in aut_api_type_pkg.t_auth_rec
    , i_collect_only        in com_api_type_pkg.t_boolean
    , i_fin_message         in cmp_api_type_pkg.t_cmp_fin_mes_rec
)return com_api_type_pkg.t_name is
begin
    trc_log_pkg.debug(
        i_text       => lower($$PLSQL_UNIT) || '.get_dest_fi_name: dummy'
    );    
    return i_fin_message.dest_fi_name;
end;

end;
/
