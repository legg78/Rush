create or replace package body iss_ui_black_list_pkg as
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
) is
begin
    io_id := iss_black_list_seq.nextval;

    insert into iss_black_list(
        id
      , card_number
    ) values (
        io_id
      , iss_api_token_pkg.encode_card_number(i_card_number => i_card_number)
    );
end add;

procedure remove(
    i_id                  in     com_api_type_pkg.t_medium_id
) is
begin
    delete from
        iss_black_list
    where
        id = i_id;
end remove;

end iss_ui_black_list_pkg;
/
