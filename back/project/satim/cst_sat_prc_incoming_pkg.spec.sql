create or replace package cst_sat_prc_incoming_pkg as
/*********************************************************
*  SAT custom incoming proceses <br />
*  Created by Gogolev I. (i.gogolev@bpcbt.com) at 08.06.2018 <br />
*  Module: CST_SAT_PRC_INCOMING_PKG <br />
*  @headcom
**********************************************************/

procedure process_reissue_card_list(
    i_separate_char     in  com_api_type_pkg.t_byte_char
);

end;
/
