create or replace package cst_ap_prc_incoming_pkg is
/************************************************************
 * Processes for loading files <br />
 * Created by Gogolev I.(i.gogolev@bpcbt.com)  at 10.03.2019 <br />
 * Last changed by $Author: Gogolev I. $ <br />
 * $LastChangedDate:: #$ <br />
 * Revision: $LastChangedRevision:  $ <br />
 * Module: cst_ap_prc_incoming_pkg <br />
 * @headcom
 ***********************************************************/
procedure process_loading_synt(
    i_file_type     in  com_api_type_pkg.t_dict_value
);

procedure process_loading_dategen;

end;
/
