CREATE OR REPLACE package itf_prc_outgoing_pkg is
/************************************************************
 * Interface for loading dictionary files from Visa <br />
 * Created by Kondratyev A.(kondratyev@bpc.ru)  at 05.06.2013 <br />
 * Last changed by $Author: Kondratyev A. $ <br />
 * $LastChangedDate:: 2010-06-05 16:00:00 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: itf_prc_outgoing_pkg <br />
 * @headcom
 ************************************************************/

    procedure process (i_inst_id in com_api_type_pkg.t_inst_id);

    procedure export_cards_status (
        i_inst_id                 in com_api_type_pkg.t_inst_id
        , i_start_date            in date default null
        , i_end_date              in date default null
        , i_card_status           in com_api_type_pkg.t_dict_value default null
        , i_export_state          in com_api_type_pkg.t_boolean default com_api_const_pkg.TRUE
    );
    
    procedure process_ocp_file (i_inst_id in com_api_type_pkg.t_inst_id);
end;
/
