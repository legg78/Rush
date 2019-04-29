create or replace package body aup_ui_amount_pkg is
/************************************************************
 * User interface for authorization amount<br />
 * Created by Kopachev D.(kopachev@bpc.ru)  at 18.07.2013  <br />
 * Last changed by $Author: kolodkina $  <br />
 * $LastChangedDate:: 2013-07-05 17:48:06 +0400#$ <br />
 * Revision: $LastChangedRevision: 32854 $ <br />
 * Module: AUP_UI_AMOUNT_PKG <br />
 * @headcom
 ************************************************************/

procedure get_amounts(
    i_auth_id                  in com_api_type_pkg.t_long_id
  , o_amounts_cur             out com_api_type_pkg.t_ref_cur
) is
begin
    open o_amounts_cur for
        select substr(amounts, 1, 8) amount_type
             , substr(amounts, 9, 3) currency
             , decode(substr(amounts, 12, 1), 'N', -1, 1) * to_number(substr(amounts, 13), com_api_const_pkg.NUMBER_FORMAT) amount 
          from (
                select substr(amounts, (level - 1) * 35 + 1, 35) amounts
                  from ( 
                        select amounts
                          from aut_auth
                         where id = i_auth_id
                           and amounts is not null
                       )
               connect by level < length(nvl(amounts, 0)) / 35 + 1
               ) x;
end;

end;
/
