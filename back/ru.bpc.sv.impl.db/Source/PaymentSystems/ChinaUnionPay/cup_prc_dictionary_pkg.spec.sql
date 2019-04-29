create or replace package cup_prc_dictionary_pkg is
/************************************************************
 * Interface for loading dictionary files from China UnionPay <br />
 * Created by Truschelev O.(truschelev@bpcbt.com)  at 14.05.2016 <br />
 * Last changed by $Author: Truschelev O. $ <br />
 * $LastChangedDate:: 2016-05-14 17:59:00 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: cup_prc_dictionary_pkg <br />
 * @headcom
 ************************************************************/
 
    procedure load_bin (
        i_network_id                in com_api_type_pkg.t_tiny_id := null
        , i_inst_id                 in com_api_type_pkg.t_inst_id := null
        , i_card_network_id         in com_api_type_pkg.t_tiny_id
        , i_card_inst_id            in com_api_type_pkg.t_inst_id := null
    );

end;
/
