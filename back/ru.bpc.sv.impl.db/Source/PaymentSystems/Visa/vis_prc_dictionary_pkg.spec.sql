create or replace package vis_prc_dictionary_pkg is
/************************************************************
 * Interface for loading dictionary files from Visa <br />
 * Created by Fomichev A.(fomichev@bpc.ru)  at 21.04.2010 <br />
 * Last changed by $Author: Fomichev A. $ <br />
 * $LastChangedDate:: 2010-04-29 10:32:00 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: vis_prc_dictionary_pkg <br />
 * @headcom
 ************************************************************/
 
    procedure load_ardef (
        i_network_id                in com_api_type_pkg.t_tiny_id := null
        , i_inst_id                 in com_api_type_pkg.t_inst_id := null
        , i_card_network_id         in com_api_type_pkg.t_tiny_id
        , i_card_inst_id            in com_api_type_pkg.t_inst_id := null
    );

    procedure load_country;

    procedure load_mcc;

    procedure load_currency;

end;
/
