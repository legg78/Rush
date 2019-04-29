create or replace package aci_prc_outgoing_pkg is
/************************************************************
 * Base24 outgoing files API <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 17.12.2013 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: aci_prc_outgoing_pkg <br />
 * @headcom
 ************************************************************/
 
    procedure upload_crdacc (
        i_inst_id                 in com_api_type_pkg.t_inst_id
        --, i_date_type           in com_api_type_pkg.t_dict_value
        --, i_start_date            in date := null
        --, i_end_date              in date := null
        --, i_shift_from            in com_api_type_pkg.t_tiny_id := 0
        --, i_shift_to              in com_api_type_pkg.t_tiny_id := 0
        , i_exclude_bin           in com_api_type_pkg.t_name := null
        , i_full_export           in com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE
    );
    
    procedure upload_mmf (
        i_inst_id                 in com_api_type_pkg.t_inst_id
        --, i_date_type           in com_api_type_pkg.t_dict_value
        --, i_start_date            in date := null
        --, i_end_date              in date := null
        --, i_shift_from            in com_api_type_pkg.t_tiny_id := 0
        --, i_shift_to              in com_api_type_pkg.t_tiny_id := 0
        , i_full_export           in com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE
    );
    
    procedure upload_semf (
        i_inst_id                 in com_api_type_pkg.t_inst_id
        --, i_date_type           in com_api_type_pkg.t_dict_value
        --, i_start_date            in date := null
        --, i_end_date              in date := null
        --, i_shift_from            in com_api_type_pkg.t_tiny_id := 0
        --, i_shift_to              in com_api_type_pkg.t_tiny_id := 0
        , i_exclude_bin           in com_api_type_pkg.t_name := null
        , i_full_export           in com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE
    );

end;
/
