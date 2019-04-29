create or replace package aci_api_fin_pkg is
/************************************************************
 * API for Base24 finans message <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 22.01.2014 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: aci_api_fin_pkg <br />
 * @headcom
 ************************************************************/
 
    procedure create_incoming_atm_message (
        i_raw_data              in com_api_type_pkg.t_raw_data
        , i_file_id             in com_api_type_pkg.t_long_id
        , i_record_number       in com_api_type_pkg.t_long_id
        , o_mes_rec             out aci_api_type_pkg.t_atm_fin_rec
    );
    
    procedure create_incoming_pos_message (
        i_raw_data              in com_api_type_pkg.t_raw_data
        , i_file_id             in com_api_type_pkg.t_long_id
        , i_record_number       in com_api_type_pkg.t_long_id
        , o_mes_rec             out aci_api_type_pkg.t_pos_fin_rec
    );

end;
/
