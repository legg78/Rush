create or replace package aup_ui_amount_pkg is
/************************************************************
 * User interface for authorization amount<br />
 * Created by Kopachev D.(kopachev@bpc.ru)  at 18.07.2013  <br />
 * Last changed by $Author: kolodkina $  <br />
 * $LastChangedDate:: 2013-07-05 17:48:06 +0400#$ <br />
 * Revision: $LastChangedRevision: 32854 $ <br />
 * Module: AUP_UI_AMOUNT_PKG <br />
 * @headcom
 ************************************************************/

    procedure get_amounts (
        i_auth_id                   in com_api_type_pkg.t_long_id
        , o_amounts_cur             out com_api_type_pkg.t_ref_cur
    );

end;
/
