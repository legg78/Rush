create or replace package iss_ui_black_list_pkg as
/*********************************************************
*  Card number black list <br />
*  Created by Kryukov E.(krukov@bpcbt.com)  at 19.09.2013 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: ISS_UI_BLACK_LIST_PKG <br />
*  @headcom
**********************************************************/

procedure add(
    io_id                 in out com_api_type_pkg.t_medium_id
  , i_card_number         in     com_api_type_pkg.t_card_number
);

procedure remove(
    i_id                  in     com_api_type_pkg.t_medium_id
);

end iss_ui_black_list_pkg;
/
