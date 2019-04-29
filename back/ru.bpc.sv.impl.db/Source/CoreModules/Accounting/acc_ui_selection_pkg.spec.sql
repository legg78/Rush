create or replace package acc_ui_selection_pkg is
/*********************************************************
*  UI for account selection <br />
*  Created by Khougaev A.(khougaev@bpcsv.ru)  at 20.09.2011 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module:  ACC_UI_SELECTION_PKG <br />
*  @headcom
**********************************************************/
procedure add_selection (
    o_id                         out com_api_type_pkg.t_tiny_id
  , o_seqnum                     out com_api_type_pkg.t_seqnum
  , i_check_aval_balance      in     com_api_type_pkg.t_boolean         default com_api_const_pkg.FALSE
  , i_lang                    in     com_api_type_pkg.t_dict_value
  , i_description             in     com_api_type_pkg.t_full_desc
);

procedure modify_selection (
    i_id                      in     com_api_type_pkg.t_tiny_id
  , io_seqnum                 in out com_api_type_pkg.t_seqnum
  , i_check_aval_balance      in     com_api_type_pkg.t_boolean         default com_api_const_pkg.FALSE
  , i_lang                    in     com_api_type_pkg.t_dict_value
  , i_description             in     com_api_type_pkg.t_full_desc
);

procedure remove_selection (
    i_id                        in com_api_type_pkg.t_tiny_id
    , i_seqnum                  in com_api_type_pkg.t_seqnum
);

procedure add_selection_step (
    o_id                        out com_api_type_pkg.t_tiny_id
    , o_seqnum                  out com_api_type_pkg.t_seqnum
    , i_selection_id            in com_api_type_pkg.t_short_id
    , i_exec_order              in com_api_type_pkg.t_short_id
    , i_step                    in com_api_type_pkg.t_dict_value
);

procedure modify_selection_step (
    i_id                        in com_api_type_pkg.t_tiny_id
    , io_seqnum                 in out com_api_type_pkg.t_seqnum
    , i_selection_id            in com_api_type_pkg.t_short_id
    , i_exec_order              in com_api_type_pkg.t_short_id
    , i_step                    in com_api_type_pkg.t_dict_value
);
        
procedure remove_selection_step (
    i_id                        in com_api_type_pkg.t_tiny_id
    , i_seqnum                  in com_api_type_pkg.t_seqnum
);

end; 
/
