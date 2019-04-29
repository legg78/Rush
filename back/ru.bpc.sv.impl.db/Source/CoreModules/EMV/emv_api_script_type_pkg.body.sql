create or replace package body emv_api_script_type_pkg is

    function get_script_type (
        i_type                  in com_api_type_pkg.t_dict_value
    ) return emv_api_type_pkg.t_emv_script_type_rec is
        l_result                emv_api_type_pkg.t_emv_script_type_rec;
    begin
        select
            a.id
            , a.seqnum
            , a.type
            , a.priority
            , a.mac
            , a.tag_71
            , a.tag_72
            , a.condition
            , a.retransmission
            , a.repeat_count
            , a.class_byte
            , a.instruction_byte
            , a.parameter1
            , a.parameter2
            , a.req_length_data
        into
            l_result
        from
            emv_script_type_vw a
        where
            a.type = i_type;
        
        return l_result;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error (
                i_error             => 'UNDEFINED_EMV_SCRIPT_TYPE'
                , i_env_param1      => i_type
            );
    end;

end;
/
