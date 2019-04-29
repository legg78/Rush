CREATE OR REPLACE package vis_api_reject_pkg is
/*********************************************************
*  API for VISA rejected operations <br />
*  Created by Mashonkin V.(mashonkin@bpcbt.com)  at 17.06.2015 <br />
*  Last changed by $Author: mashonkin $ <br />
*  $LastChangedDate:: 2015-06-17 19:28:48 +0300#$ <br />
*  Revision: $LastChangedRevision: 52735 $ <br />
*  Module: vis_api_reject_pkg <br />
*  @headcom
**********************************************************/

g_process_run_date  date   := sysdate;

procedure put_reject (
    i_msg in out vis_reject%ROWTYPE
);

procedure put_reject_data (
    i_reject_rec        in vis_reject%rowtype
    , o_reject_data_id  out com_api_type_pkg.t_long_id
);

  -- put 'Operation reject data' for further validation of auth messages
procedure put_reject_data_dummy (
    i_oper_id           in com_api_type_pkg.t_long_id
    , o_reject_data_id  out com_api_type_pkg.t_long_id
);

-- creates reversal operation, register reject event, set oper_status = REJECTED (OPST700), register oper stage = REJECTED
procedure finalize_rejected_oper (
    i_oper_id in com_api_type_pkg.t_long_id
);

procedure validate_visa_record_auth(
    i_oper_id     in com_api_type_pkg.t_long_id
    , i_visa_data in com_api_type_pkg.t_text
);

function validate_visa_record (
    i_reject_data_id   in com_api_type_pkg.t_long_id
    , i_visa_record    in com_api_type_pkg.t_text
) return com_api_type_pkg.t_boolean;

    procedure create_duplicate_vis_fin (
        i_oper_id         in com_api_type_pkg.t_long_id
      , i_new_oper_id     in com_api_type_pkg.t_long_id
      , i_create_reversal in com_api_type_pkg.t_boolean default com_api_type_pkg.false
    );
    
    function check_dict_field(
        i_field_value       in com_api_type_pkg.t_text
        , i_dict            in com_api_type_pkg.t_dict_value
        , i_reject_data_id  in com_api_type_pkg.t_long_id
        , i_start_position  in com_api_type_pkg.t_long_id
        , i_end_position    in com_api_type_pkg.t_long_id
    ) return com_api_type_pkg.t_boolean;
    
    procedure put_reject_code(
        i_reject_data_id  in com_api_type_pkg.t_long_id
        , i_reject_code   in com_api_type_pkg.t_text
        , i_description   in com_api_type_pkg.t_text
        , i_field         in com_api_type_pkg.t_text
    );        

    procedure create_reversal_operation (
        i_oper_id in com_api_type_pkg.t_long_id
    );
    
    function create_duplicate_operation (
        i_oper_id         in com_api_type_pkg.t_long_id
      , i_create_reversal in com_api_type_pkg.t_boolean default com_api_type_pkg.false
    ) return com_api_type_pkg.t_long_id;    

end vis_api_reject_pkg;
/
 