create or replace package body emv_ui_script_type_pkg is
/************************************************************
 * User interface for EMV script type <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 06.06.2011 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: emv_ui_script_type_pkg <br />
 * @headcom
 ************************************************************/

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
        , i_is_used_by_user     in com_api_type_pkg.t_boolean
        , i_form_url            in com_api_type_pkg.t_name
    ) is
    begin
        o_id := emv_script_type_seq.nextval;
        o_seqnum := 1;

        insert into emv_script_type_vw (
            id
            , seqnum
            , type
            , priority
            , mac
            , tag_71
            , tag_72
            , condition
            , retransmission
            , repeat_count
            , class_byte
            , instruction_byte
            , parameter1
            , parameter2
            , req_length_data
            , is_used_by_user
            , form_url
        ) values (
            o_id
            , o_seqnum
            , i_type
            , i_priority
            , i_mac
            , i_tag_71
            , i_tag_72
            , i_condition
            , i_retransmission
            , i_repeat_count
            , i_class_byte
            , i_instruction_byte
            , i_parameter1
            , i_parameter2
            , i_req_length_data
            , nvl(i_is_used_by_user, com_api_type_pkg.FALSE)
            , i_form_url
        );
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error (
                i_error  => 'DUPLICATE_EMV_SCRIPT_TYPE'
            );
    end;

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
        , i_is_used_by_user     in com_api_type_pkg.t_boolean
        , i_form_url            in com_api_type_pkg.t_name
    ) is
    begin
        update
            emv_script_type_vw
        set
            seqnum = io_seqnum
            , type = i_type
            , priority = i_priority
            , mac = i_mac
            , tag_71 = i_tag_71
            , tag_72 = i_tag_72
            , condition = i_condition
            , retransmission = i_retransmission
            , repeat_count = i_repeat_count
            , class_byte = i_class_byte
            , instruction_byte = i_instruction_byte
            , parameter1 = i_parameter1
            , parameter2 = i_parameter2
            , req_length_data = i_req_length_data
            , is_used_by_user = nvl(i_is_used_by_user, com_api_type_pkg.FALSE)
            , form_url = i_form_url
        where
            id = i_id;

        io_seqnum := io_seqnum + 1;
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error (
                i_error  => 'DUPLICATE_EMV_SCRIPT_TYPE'
            );
    end;

    procedure remove_script_type (
        i_id                    in com_api_type_pkg.t_tiny_id
        , i_seqnum              in com_api_type_pkg.t_seqnum
    ) is
        l_check_cnt             number;
    begin
        select
            count(*)
        into
            l_check_cnt
        from
            emv_script_vw
        where
            type_id = i_id;

        if l_check_cnt > 0 then
            com_api_error_pkg.raise_error (
                i_error  => 'EMV_SCRIPT_TYPE_USED'
            );
        end if;

        update
            emv_script_type_vw
        set
            seqnum = i_seqnum
        where
            id = i_id;

        delete from
            emv_script_type_vw
        where
            id = i_id;
    end;

end;
/
