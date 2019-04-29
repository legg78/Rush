create or replace package body pmo_ui_purpose_formatter_pkg is

    procedure add_purpose_formatter (
        o_id                        out com_api_type_pkg.t_short_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_purpose_id              in com_api_type_pkg.t_short_id
        , i_standard_id             in com_api_type_pkg.t_tiny_id
        , i_version_id              in com_api_type_pkg.t_tiny_id
        , i_paym_aggr_msg_type      in com_api_type_pkg.t_dict_value
        , i_formatter               in clob
    ) is   
    l_count                 com_api_type_pkg.t_short_id;
    
    begin
        select count(1)
          into l_count  
          from pmo_purpose_formatter_vw
         where purpose_id = i_purpose_id
           and paym_aggr_msg_type = i_paym_aggr_msg_type
           and standard_id = i_standard_id;   
    
        if l_count > 0 then
            com_api_error_pkg.raise_error(
                i_error         => 'PAYMENT_FORMATTER_ALREADY_EXISTS'
                , i_env_param1  => i_purpose_id
                , i_env_param2  => i_paym_aggr_msg_type
                , i_env_param3  => i_standard_id
            );            
        end if;
        
        o_id := pmo_purpose_formatter_seq.nextval;
        o_seqnum := 1;
        
        insert into pmo_purpose_formatter_vw (
            id
            , seqnum
            , purpose_id
            , standard_id
            , version_id
            , paym_aggr_msg_type
            , formatter
       ) values (
            o_id
            , o_seqnum
            , i_purpose_id
            , i_standard_id
            , i_version_id
            , i_paym_aggr_msg_type
            , i_formatter
        );
        
    end;

    procedure modify_purpose_formatter (
        i_id                        in com_api_type_pkg.t_short_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_purpose_id              in com_api_type_pkg.t_short_id
        , i_standard_id             in com_api_type_pkg.t_tiny_id
        , i_version_id              in com_api_type_pkg.t_tiny_id
        , i_paym_aggr_msg_type      in com_api_type_pkg.t_dict_value
        , i_formatter               in clob
    ) is
    l_count                 com_api_type_pkg.t_short_id;

    begin
        select count(1)
          into l_count  
          from pmo_purpose_formatter_vw
         where purpose_id = i_purpose_id
           and paym_aggr_msg_type = i_paym_aggr_msg_type
           and standard_id = i_standard_id
           and id <> i_id;   

        if l_count > 0 then
            com_api_error_pkg.raise_error(
                i_error         => 'PAYMENT_FORMATTER_ALREADY_EXISTS'
                , i_env_param1  => i_purpose_id
                , i_env_param2  => i_paym_aggr_msg_type
                , i_env_param3  => i_standard_id
            );            
        end if;
    
        update
            pmo_purpose_formatter_vw
        set
            seqnum = io_seqnum
            , purpose_id = i_purpose_id
            , standard_id = i_standard_id
            , version_id = i_version_id
            , paym_aggr_msg_type = i_paym_aggr_msg_type
            , formatter = i_formatter
        where
            id = i_id;
        
        io_seqnum := io_seqnum + 1;
        
    end;

    procedure remove_purpose_formatter (
        i_id                        in com_api_type_pkg.t_short_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    ) is
    begin
        update
            pmo_purpose_formatter_vw
        set
            seqnum = i_seqnum
        where
            id = i_id;
            
        delete from
            pmo_purpose_formatter_vw
        where
            id = i_id;
    
    end;

end;
/
