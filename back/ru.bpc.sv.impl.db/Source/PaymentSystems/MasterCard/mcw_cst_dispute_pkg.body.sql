create or replace package body mcw_cst_dispute_pkg as
/*********************************************************
 *  The package with user-exits for MasterCard dispute processing <br />
 *
 *  Created by Alalykin A. (alalykin@bpcbt.com) at 28.01.2015 <br />
 *  Last changed by $Author: alalykin $ <br />
 *  $LastChangedDate: 2015-01-28 13:00:00 +0400#$ <br />
 *  Remcwion: $LastChangedVersion: 1 $ <br />
 *  Module: mcw_cst_dispute_pkg <br />
 *  @headcom
 **********************************************************/

/*
 * Custom processing for generation of financial message's first chargeback.
 */
procedure gen_first_chargeback(
    io_fin_message    in out nocopy mcw_api_type_pkg.t_fin_rec
) is
begin
    trc_log_pkg.debug(
        i_text       => lower($$PLSQL_UNIT) || '.gen_first_chargeback: dummy'
    );    
end;

end;
/
