create or replace package body emv_ui_block_pkg is

    procedure add_block (
        o_id                        out com_api_type_pkg.t_short_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_application_id          in com_api_type_pkg.t_short_id
        , i_code                    in com_api_type_pkg.t_tag
        , i_include_in_sda          in com_api_type_pkg.t_boolean
        , i_include_in_afl          in com_api_type_pkg.t_boolean
        , i_transport_key_id        in com_api_type_pkg.t_short_id
        , i_encryption_id           in com_api_type_pkg.t_short_id
        , i_block_order             in com_api_type_pkg.t_tiny_id
        , i_profile                 in com_api_type_pkg.t_dict_value
    ) is
    begin
        o_id := emv_block_seq.nextval;
        o_seqnum := 1;
        
        insert into emv_block_vw (
            id
            , seqnum
            , application_id
            , code
            , include_in_sda
            , include_in_afl
            , transport_key_id
            , encryption_id
            , block_order
            , profile
        ) values (
            o_id
            , o_seqnum
            , i_application_id
            , i_code
            , i_include_in_sda
            , i_include_in_afl
            , i_transport_key_id
            , i_encryption_id
            , i_block_order
            , i_profile
        );
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error (
                i_error         => 'EMV_BLOCK_ALREADY_EXIST'
                , i_env_param1  => i_code
            );
    end;

    procedure modify_block (
        i_id                        in com_api_type_pkg.t_short_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_application_id          in com_api_type_pkg.t_short_id
        , i_code                    in com_api_type_pkg.t_tag
        , i_include_in_sda          in com_api_type_pkg.t_boolean
        , i_include_in_afl          in com_api_type_pkg.t_boolean
        , i_transport_key_id        in com_api_type_pkg.t_short_id
        , i_encryption_id           in com_api_type_pkg.t_short_id
        , i_block_order             in com_api_type_pkg.t_tiny_id
        , i_profile                 in com_api_type_pkg.t_dict_value
    ) is
    begin
        update
            emv_block_vw
        set
            seqnum = io_seqnum
            , code = i_code
            , include_in_sda = i_include_in_sda
            , include_in_afl = i_include_in_afl
            , transport_key_id = i_transport_key_id
            , encryption_id = i_encryption_id
            , block_order = i_block_order
            , profile = i_profile
        where
            id = i_id;
        
        io_seqnum := io_seqnum + 1;
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error (
                i_error         => 'EMV_BLOCK_ALREADY_EXIST'
                , i_env_param1  => i_code
            );
    end;

    procedure remove_block (
        i_id                        in com_api_type_pkg.t_short_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    ) is
    begin
        -- delete depend elements
        delete from
            emv_element_vw
        where
            entity_type = emv_api_const_pkg.ENTITY_TYPE_EMV_BLOCK
            and object_id = i_id;
        
        update
            emv_block_vw
        set
            seqnum = i_seqnum
        where
            id = i_id;
            
        -- delete block
        delete from
            emv_block_vw
        where
            id = i_id;
    
    end;

end;
/
