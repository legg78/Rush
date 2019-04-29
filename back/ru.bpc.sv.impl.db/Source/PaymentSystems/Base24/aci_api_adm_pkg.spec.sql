create or replace package aci_api_adm_pkg is
/************************************************************
 * API for Base24 administrative message <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 22.01.2014 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: aci_api_adm_pkg <br />
 * @headcom
 ************************************************************/
 
    procedure create_incoming_setl (
        i_raw_data              in com_api_type_pkg.t_raw_data
        , i_file_id             in com_api_type_pkg.t_long_id
        , i_record_number       in com_api_type_pkg.t_long_id
        , o_mes_rec             out aci_api_type_pkg.t_atm_setl_rec
        , o_hopr_tab            out aci_api_type_pkg.t_atm_setl_hopr_tab
    );
    
    procedure create_incoming_setl_ttl (
        i_raw_data              in com_api_type_pkg.t_raw_data
        , i_file_id             in com_api_type_pkg.t_long_id
        , i_record_number       in com_api_type_pkg.t_long_id
        , o_mes_rec             out aci_api_type_pkg.t_atm_setl_ttl_rec
    );
    
    procedure create_incoming_cash (
        i_raw_data              in com_api_type_pkg.t_raw_data
        , i_file_id             in com_api_type_pkg.t_long_id
        , i_record_number       in com_api_type_pkg.t_long_id
        , o_mes_rec             out aci_api_type_pkg.t_atm_cash_rec
    );
    
    procedure create_incoming_setl_tot (
        i_raw_data              in com_api_type_pkg.t_raw_data
        , i_file_id             in com_api_type_pkg.t_long_id
        , i_record_number       in com_api_type_pkg.t_long_id
        , o_mes_rec             out aci_api_type_pkg.t_pos_setl_rec
    );
    
    procedure create_incoming_clerk (
        i_raw_data              in com_api_type_pkg.t_raw_data
        , i_file_id             in com_api_type_pkg.t_long_id
        , i_record_number       in com_api_type_pkg.t_long_id
        , o_mes_rec             out aci_api_type_pkg.t_clerk_tot_rec
    );
    
    procedure create_incoming_srvcs (
        i_raw_data              in com_api_type_pkg.t_raw_data
        , i_file_id             in com_api_type_pkg.t_long_id
        , i_record_number       in com_api_type_pkg.t_long_id
        , o_mes_rec             out aci_api_type_pkg.t_service_rec
    );

end;
/
 