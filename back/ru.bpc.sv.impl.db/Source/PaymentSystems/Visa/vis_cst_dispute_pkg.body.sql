create or replace package body vis_cst_dispute_pkg as
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
 * Custom processing for generation of financial message's draft.
 */
procedure process_fin_message_draft(
    io_fin_message    in out nocopy vis_api_type_pkg.t_visa_fin_mes_rec
) is
begin
    trc_log_pkg.debug(
        i_text       => lower($$PLSQL_UNIT) || '.process_fin_message_draft: dummy'
    );    
end;

end;
/
