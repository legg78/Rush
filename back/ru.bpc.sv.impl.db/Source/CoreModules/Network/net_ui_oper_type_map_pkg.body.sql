create or replace package body net_ui_oper_type_map_pkg is

    procedure duplication_check(
        i_id                    in     com_api_type_pkg.t_tiny_id
      , i_standard_id           in     com_api_type_pkg.t_tiny_id
      , i_network_oper_type     in     com_api_type_pkg.t_dict_value
      , i_priority              in     com_api_type_pkg.t_tiny_id
      , i_oper_type             in     com_api_type_pkg.t_dict_value
    ) is
        l_count                 com_api_type_pkg.t_count := 0;
    begin
        select count(1)
        --select sum(case
        --               when oper_type = i_oper_type
        --                 or network_oper_type = i_network_oper_type
        --               then 1
        --               else 0
        --           end) 
          into l_count  
          from net_oper_type_map
         where standard_id = i_standard_id  
           and priority = i_priority
           and id != nvl(i_id, id + 1);
           
        if l_count > 0 then
            com_api_error_pkg.raise_error(
                i_error      => 'DUPLICATE_PRIORITY_OPERATION_MAPPING'
              , i_env_param1 => i_priority
              , i_env_param2 => i_standard_id
            );            
        end if;

        select count(1)
          into l_count  
          from net_oper_type_map
         where standard_id = i_standard_id  
           and network_oper_type = i_network_oper_type
           and oper_type = i_oper_type
           and id != nvl(i_id, id + 1);

        if l_count > 0 then
            com_api_error_pkg.raise_error(
                i_error      => 'DUPLICATE_MAPPING_OPERATION'
              , i_env_param1 => i_network_oper_type
              , i_env_param2 => i_oper_type
              , i_env_param3 => i_standard_id
            );            
        end if;
    end duplication_check;

    procedure add (
        o_id                       out com_api_type_pkg.t_tiny_id
        , o_seqnum                 out com_api_type_pkg.t_seqnum
        , i_standard_id         in     com_api_type_pkg.t_tiny_id
        , i_network_oper_type   in     com_api_type_pkg.t_dict_value
        , i_priority            in     com_api_type_pkg.t_tiny_id
        , i_oper_type           in     com_api_type_pkg.t_dict_value
    ) is
    begin
        duplication_check(
            i_id                => null
          , i_standard_id       => i_standard_id
          , i_network_oper_type => i_network_oper_type
          , i_priority          => i_priority
          , i_oper_type         => i_oper_type
        );

        o_id := net_oper_type_map_seq.nextval;
        o_seqnum := 1;
        
        insert into net_oper_type_map_vw (
            id
            , seqnum
            , standard_id
            , network_oper_type
            , priority
            , oper_type
        ) values (
            o_id
            , o_seqnum
            , i_standard_id
            , i_network_oper_type
            , i_priority
            , i_oper_type
        );
    end;

    procedure modify (
        i_id                    in     com_api_type_pkg.t_tiny_id
        , io_seqnum             in out com_api_type_pkg.t_seqnum
        , i_standard_id         in     com_api_type_pkg.t_tiny_id
        , i_network_oper_type   in     com_api_type_pkg.t_dict_value
        , i_priority            in     com_api_type_pkg.t_tiny_id
        , i_oper_type           in     com_api_type_pkg.t_dict_value
    ) is
    begin
        duplication_check(
            i_id                => i_id
          , i_standard_id       => i_standard_id
          , i_network_oper_type => i_network_oper_type
          , i_priority          => i_priority
          , i_oper_type         => i_oper_type
        );

        update
            net_oper_type_map_vw
        set
            seqnum = io_seqnum
            , standard_id = i_standard_id
            , network_oper_type = i_network_oper_type
            , priority = i_priority
            , oper_type = i_oper_type
        where
            id = i_id;
            
        io_seqnum := io_seqnum + 1;
    end;

    procedure remove (
        i_id                    in     com_api_type_pkg.t_tiny_id
        , i_seqnum              in     com_api_type_pkg.t_seqnum
    ) is
    begin
        update
            net_oper_type_map_vw
        set
            seqnum = i_seqnum
        where
            id = i_id;
            
        delete from
            net_oper_type_map_vw
        where
            id = i_id;
    end;

end; 
/
