create or replace package emv_ui_script_type_pkg is
/************************************************************
 * User interface for EMV script type <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 06.06.2011 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: emv_ui_script_type_pkg <br />
 * @headcom
 ************************************************************/

/*
 * Add script type
 * @param  o_id                  - EMV type identifier
 * @param  o_seqnum              - Sequential number of record version
 * @param  i_type                - EMV type script (SRTP key)
 * @param  i_priority            - Priority
 * @param  i_mac                 - MAC calculating need flag
 * @param  i_tag_71              - EMV script is sent to the tag tag 71
 * @param  i_tag_72              - EMV script is sent to the tag tag 72
 * @param  i_condition           - Script transfer conditions
 * @param  i_retransmission      - Required retransmission script
 * @param  i_repeat_count        - Number of attempts to retransmit emv script
 * @param  i_class_byte          - Class byte of the command message
 * @param  i_instruction_byte    - Instruction byte of command message
 * @param  i_parameter1          - Parameter 1 of command message
 * @param  i_parameter2          - Parameter 2 of command message
 * @param  i_req_length_data     - Length of expected data is required
 */
    procedure add_script_type (
        o_id                    out com_api_type_pkg.t_tiny_id
        , o_seqnum              out com_api_type_pkg.t_seqnum
        , i_type                in com_api_type_pkg.t_dict_value
        , i_priority            in com_api_type_pkg.t_tiny_id
        , i_mac                 in com_api_type_pkg.t_boolean
        , i_tag_71              in com_api_type_pkg.t_boolean
        , i_tag_72              in com_api_type_pkg.t_boolean
        , i_condition           in com_api_type_pkg.t_dict_value
        , i_retransmission      in com_api_type_pkg.t_boolean
        , i_repeat_count        in com_api_type_pkg.t_tiny_id
        , i_class_byte          in com_api_type_pkg.t_byte_char
        , i_instruction_byte    in com_api_type_pkg.t_byte_char
        , i_parameter1          in com_api_type_pkg.t_byte_char
        , i_parameter2          in com_api_type_pkg.t_byte_char
        , i_req_length_data     in com_api_type_pkg.t_boolean
        , i_is_used_by_user     in com_api_type_pkg.t_boolean := null
        , i_form_url            in com_api_type_pkg.t_name := null
    );

/*
 * Modify script type
 * @param  o_id                  - EMV type identifier
 * @param  io_seqnum             - Sequential number of record version
 * @param  i_type                - EMV type script (SRTP key)
 * @param  i_priority            - Priority
 * @param  i_mac                 - MAC calculating need flag
 * @param  i_tag_71              - EMV script is sent to the tag tag 71
 * @param  i_tag_72              - EMV script is sent to the tag tag 72
 * @param  i_condition           - Script transfer conditions
 * @param  i_retransmission      - Required retransmission script
 * @param  i_repeat_count        - Number of attempts to retransmit emv script
 * @param  i_class_byte          - Class byte of the command message
 * @param  i_instruction_byte    - Instruction byte of command message
 * @param  i_parameter1          - Parameter 1 of command message
 * @param  i_parameter2          - Parameter 2 of command message
 * @param  i_req_length_data     - Length of expected data is required
 */
    procedure modify_script_type (
        i_id                    in com_api_type_pkg.t_tiny_id
        , io_seqnum             in out com_api_type_pkg.t_seqnum
        , i_type                in com_api_type_pkg.t_dict_value
        , i_priority            in com_api_type_pkg.t_tiny_id
        , i_mac                 in com_api_type_pkg.t_boolean
        , i_tag_71              in com_api_type_pkg.t_boolean
        , i_tag_72              in com_api_type_pkg.t_boolean
        , i_condition           in com_api_type_pkg.t_dict_value
        , i_retransmission      in com_api_type_pkg.t_boolean
        , i_repeat_count        in com_api_type_pkg.t_tiny_id
        , i_class_byte          in com_api_type_pkg.t_byte_char
        , i_instruction_byte    in com_api_type_pkg.t_byte_char
        , i_parameter1          in com_api_type_pkg.t_byte_char
        , i_parameter2          in com_api_type_pkg.t_byte_char
        , i_req_length_data     in com_api_type_pkg.t_boolean
        , i_is_used_by_user     in com_api_type_pkg.t_boolean := null
        , i_form_url            in com_api_type_pkg.t_name := null
    );

/*
 * Remove script type
 * @param  i_id                  - EMV type identifier
 * @param  i_seqnum              - Sequential number of record version
 */
    procedure remove_script_type (
        i_id                    in com_api_type_pkg.t_tiny_id
        , i_seqnum              in com_api_type_pkg.t_seqnum
    );
    
end;
/
