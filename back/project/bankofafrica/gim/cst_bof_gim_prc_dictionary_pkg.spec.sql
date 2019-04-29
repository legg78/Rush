create or replace package cst_bof_gim_prc_dictionary_pkg is
/*********************************************************
 *  Interface for loading dictionary files from GIM  <br />
 *  Created by Truschelev O.(truschelev@bpcbt.com)  at 01.09.2017 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: cst_bof_gim_prc_dictionary_pkg <br />
 *  @headcom
 **********************************************************/

    procedure load_bin (
        i_network_id             in com_api_type_pkg.t_tiny_id  := null
      , i_inst_id                in com_api_type_pkg.t_inst_id  := null
      , i_card_network_id        in com_api_type_pkg.t_tiny_id
      , i_card_inst_id           in com_api_type_pkg.t_inst_id  := null
    );

end;
/
