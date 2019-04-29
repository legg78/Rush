create or replace package lty_prc_lottery_tickets_pkg as
/*********************************************************
 *  Process for lottery tickets <br /> 
 *  Created by Kondratyev A.(kondratyev@bpc.ru)  at 11.04.2017 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: lty_prc_lottery_tickets_pkg <br />
 *  @headcom
 **********************************************************/ 

procedure export_file (
    i_inst_id     in     com_api_type_pkg.t_inst_id
);

end;
/
