create or replace package com_ui_reject_pkg is
/*********************************************************
*  UI for Reject Management module <br />
*  Created by Mashonkin V.(mashonkin@bpcbt.com)  at 02.07.2015 <br />
*  Last changed by $Author: mashonkin $ <br />
*  $LastChangedDate:: 2015-07-02 12:28:48 +0300#$ <br />
*  Revision: $LastChangedRevision: 52735 $ <br />
*  Module: com_ui_reject_pkg <br />
*  @headcom
**********************************************************/

    C_TABL_OPR_OPERATION              constant com_api_type_pkg.t_text := 'OPR_OPERATION_VW';
    C_TABL_OPR_PARTICIPANT            constant com_api_type_pkg.t_text := 'OPR_PARTICIPANT_VW';
    C_TABL_VIS_FIN_MESSAGE            constant com_api_type_pkg.t_text := 'VIS_FIN_MESSAGE_VW';
    C_TABL_MCW_FIN                    constant com_api_type_pkg.t_text := 'MCW_FIN_VW';
    
    -- use case "Edit operation field"
    procedure update_field_value (
        i_table_name        in com_api_type_pkg.t_name
        , i_pk_field_name   in com_api_type_pkg.t_name
        , i_pk_value        in com_api_type_pkg.t_text
        , i_upd_field_name  in com_api_type_pkg.t_name
        , i_upd_value       in com_api_type_pkg.t_text
        , i_pk2_field_name  in com_api_type_pkg.t_name default null
        , i_pk2_value       in com_api_type_pkg.t_text default null
    );

    -- use case "Assign reject to user"
    procedure assign_reject (
        i_reject_id        in com_api_type_pkg.t_long_id
        , i_user_id        in com_api_type_pkg.t_long_id
    );

    -- use case "Action on reject"
    procedure change_oper_status (
        i_action    in com_api_type_pkg.t_dict_value
      , i_oper_id   in com_api_type_pkg.t_long_id
    );

    procedure get_list_of_group (
       i_id                      in com_api_type_pkg.t_long_id
       , i_lang                  in com_api_type_pkg.t_dict_value
       , o_group_list          out com_api_type_pkg.t_ref_cur
    );

    procedure get_list_of_user (
       i_group                      in com_api_type_pkg.t_long_id
       , i_lang                  in com_api_type_pkg.t_dict_value
       , o_user_list          out com_api_type_pkg.t_ref_cur
    );

end com_ui_reject_pkg;
/