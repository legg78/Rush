create or replace package atm_api_cash_in_pkg as
/*********************************************************
 *  Api for cash in <br>
 *  Created by Kryukov E.(krukov@bpcbt.com)  at 17.11.2011  <br>
 *  Last changed by $Author$ <br>
 *  $LastChangedDate::                           $  <br>
 *  Revision: $LastChangedRevision$ <br>
 *  Module: atm_api_cash_in_pkg <br>
 *  @headcom
 **********************************************************/

procedure sync(
    i_params      in     atm_cash_in_tpt
);

end;
/
