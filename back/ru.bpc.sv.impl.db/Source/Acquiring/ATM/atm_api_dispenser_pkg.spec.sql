create or replace package atm_api_dispenser_pkg as
/*********************************************************
 *  Api for dispensers of ATM terminals <br>
 *  Created by Filimonov A.(filimonov@bpc.ru)  at 27.10.2010  <br>
 *  Last changed by $Author$ <br>
 *  $LastChangedDate::                           $  <br>
 *  Revision: $LastChangedRevision$ <br>
 *  Module: atm_api_dispenser_pkg <br>
 *  @headcom
 **********************************************************/
procedure add_dispenser(
    o_id                   out  com_api_type_pkg.t_medium_id
  , i_terminal_id      in       com_api_type_pkg.t_short_id
  , i_disp_number      in       com_api_type_pkg.t_tiny_id
  , i_face_value       in       com_api_type_pkg.t_money
  , i_currency         in       com_api_type_pkg.t_curr_code
  , i_denomination_id  in       com_api_type_pkg.t_curr_code  
  , i_dispenser_type   in       com_api_type_pkg.t_dict_value
);

procedure modify_dispenser(
    i_id               in       com_api_type_pkg.t_medium_id
  , i_terminal_id      in       com_api_type_pkg.t_short_id
  , i_disp_number      in       com_api_type_pkg.t_tiny_id
  , i_face_value       in       com_api_type_pkg.t_money
  , i_currency         in       com_api_type_pkg.t_curr_code
  , i_denomination_id  in       com_api_type_pkg.t_curr_code  
  , i_dispenser_type   in       com_api_type_pkg.t_dict_value
);

procedure remove_dispenser(
    i_id  in      com_api_type_pkg.t_medium_id
);

procedure modify_disp_stat(
    i_dispenser_id          in      com_api_type_pkg.t_medium_id
  , i_note_dispensed        in      com_api_type_pkg.t_tiny_id
  , i_note_remained         in      com_api_type_pkg.t_tiny_id
  , i_note_rejected         in      com_api_type_pkg.t_tiny_id
  , i_note_loaded           in      com_api_type_pkg.t_tiny_id      default null
  , i_cassette_status       in      com_api_type_pkg.t_dict_value
);

procedure modify_disp_stat(
    i_dispenser_id_tab      in      com_api_type_pkg.t_number_tab
  , i_note_dispensed_tab    in      com_api_type_pkg.t_number_tab
  , i_note_remained_tab     in      com_api_type_pkg.t_number_tab
  , i_note_rejected_tab     in      com_api_type_pkg.t_number_tab
  , i_note_loaded_tab       in      com_api_type_pkg.t_number_tab
  , i_cassette_status_tab   in      com_api_type_pkg.t_dict_tab
);

end;
/
