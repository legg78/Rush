create or replace package body emv_api_script_pkg is
/************************************************************
 * API for EMV script <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 06.07.2011 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: emv_api_script_pkg <br />
 * @headcom
 ************************************************************/

    procedure get_arqc_tags (
        i_object_id             in com_api_type_pkg.t_long_id
        , i_entity_type         in com_api_type_pkg.t_dict_value
        , o_tag_tab             out com_api_type_pkg.t_dict_tab
    ) is
    begin
        select
            tag
        bulk collect into
            o_tag_tab
        from
            emv_arqc_vw
        where
            object_id = i_object_id
            and entity_type = i_entity_type
        order by
            tag_order;
    end;
    
    function is_script_sent (
        i_object_id             in com_api_type_pkg.t_long_id
        , i_entity_type         in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_boolean is
        l_result                com_api_type_pkg.t_boolean;
    begin
        select
            case when count(id) > 0 then 1 else 0 end
        into
            l_result
        from
            emv_script_vw
        where
            object_id = i_object_id
            and entity_type = i_entity_type
            and status = emv_api_const_pkg.SCRIPT_STATUS_PROCESSING;
        
        return l_result;
    end;
    
    procedure change_script_status (
        i_object_id             in com_api_type_pkg.t_long_id
        , i_entity_type         in com_api_type_pkg.t_dict_value
        , i_script_id           in com_api_type_pkg.t_long_id := null
        , i_type                in com_api_type_pkg.t_dict_value := null
        , i_status              in com_api_type_pkg.t_dict_value 
    ) is
        l_script_id             com_api_type_pkg.t_long_id;
    begin
        trc_log_pkg.debug (
            i_text          => 'Change status emv scripts [#1][#2]'
            , i_env_param1  => i_entity_type || ':' || i_object_id
            , i_env_param2  => i_status
        );

        if i_status in (emv_api_const_pkg.SCRIPT_STATUS_WAITING
           , emv_api_const_pkg.SCRIPT_STATUS_PROCESSING
           , emv_api_const_pkg.SCRIPT_STATUS_PROCESSED
           , emv_api_const_pkg.SCRIPT_STATUS_FAILED
           , emv_api_const_pkg.SCRIPT_STATUS_OVERLOADED
        ) then
            -- clone script
            case i_status
                when emv_api_const_pkg.SCRIPT_STATUS_FAILED then
                    l_script_id := emv_script_seq.nextval;
                    
                    insert into emv_script_vw (
                        id
                        , object_id
                        , entity_type
                        , type_id
                        , class_byte
                        , instruction_byte
                        , parameter1
                        , parameter2
                        , length
                        , data
                        , status
                        , change_date
                    ) select
                        l_script_id
                        , s.object_id
                        , s.entity_type
                        , s.type_id
                        , s.class_byte
                        , s.instruction_byte
                        , s.parameter1
                        , s.parameter2
                        , s.length
                        , s.data
                        , emv_api_const_pkg.SCRIPT_STATUS_WAITING
                        , get_sysdate
                    from
                        emv_script_vw s
                        , emv_script_type_vw t
                    where
                        s.object_id = i_object_id
                        and s.entity_type = i_entity_type
                        and t.id = s.type_id
                        and (t.type = i_type or i_type is null)
                        and s.status = emv_api_const_pkg.SCRIPT_STATUS_PROCESSING
                        and t.retransmission = com_api_type_pkg.TRUE
                        and s.id = nvl(i_script_id, s.id)
                        ;
                else
                    null;
            end case;
        
            -- change status
            update
                emv_script_vw s
            set
                s.status = i_status
                , s.change_date = get_sysdate
            where
                s.object_id = i_object_id
                and s.entity_type = i_entity_type
                and s.status in (emv_api_const_pkg.SCRIPT_STATUS_OVERLOADED, emv_api_const_pkg.SCRIPT_STATUS_WAITING, emv_api_const_pkg.SCRIPT_STATUS_PROCESSING)
                and s.id = nvl(i_script_id, s.id)
                and s.type_id in (
                    select
                        t.id
                    from
                        emv_script_type_vw t
                    where
                        t.type = i_type
                        or i_type is null
                )
                and (s.id != l_script_id or l_script_id is null);

            trc_log_pkg.debug (
                i_text          => 'Updated [#1]'
                , i_env_param1  => sql%rowcount
            );
        end if;
    end;
    
    procedure change_card_script_status (
        i_card_instance_id      in com_api_type_pkg.t_medium_id
        , i_script_id           in com_api_type_pkg.t_long_id := null
        , i_type                in com_api_type_pkg.t_dict_value := null
        , i_status              in com_api_type_pkg.t_dict_value 
    ) is
    begin
        change_script_status (
            i_object_id      => i_card_instance_id
            , i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
            , i_script_id    => i_script_id
            , i_type         => i_type
            , i_status       => i_status
        );
    end;

    procedure select_scripts (
        i_object_id             in com_api_type_pkg.t_long_id
        , i_entity_type         in com_api_type_pkg.t_dict_value
        , i_status              in com_api_type_pkg.t_dict_value
        , o_script_tab          out nocopy emv_api_type_pkg.t_emv_script_tab
    ) is
    begin
        trc_log_pkg.debug (
            i_text          => 'Select emv scripts [#1][#2][#3]'
            , i_env_param1  => i_entity_type
            , i_env_param2  => i_object_id
            , i_env_param3  => i_status
        );
        
        select
            x.id
            , x.object_id
            , x.entity_type
            , x.type
            , x.mac
            , x.tag_71
            , x.tag_72
            , x.status
            , x.req_length_data
            , x.class_byte
            , x.instruction_byte
            , x.parameter1
            , x.parameter2
            , x.length
            , x.data
        bulk collect into
            o_script_tab
        from (
            select
                o.id
                , o.object_id
                , o.entity_type
                , o.type
                , o.mac
                , o.tag_71
                , o.tag_72
                , o.status
                , o.max_script
                , nvl(length(replace(sys_connect_by_path(o.body, '_;_'), '_;_', '')), 0) length_body
                , o.req_length_data
                , o.class_byte
                , o.instruction_byte
                , o.parameter1
                , o.parameter2
                , o.length
                , o.data
            from (
                select
                    s.id
                    , s.object_id
                    , s.entity_type
                    , t.type
                    , t.mac
                    , t.tag_71
                    , t.tag_72
                    , s.class_byte || s.instruction_byte || s.parameter1 || s.parameter2 || case when s.length > 0 then s.data else null end body
                    , s.status
                    , ( select
                            m.max_script
                        from
                            iss_card_instance_vw i
                            , prs_method_vw m
                        where
                            i.id = i_object_id
                            and i_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                            and m.id = i.perso_method_id
                    ) max_script
                    , lag(s.class_byte || s.instruction_byte || s.parameter1 || s.parameter2 || case when s.length > 0 then s.data else null end) over (order by t.priority) prev_body
                    , t.priority
                    , t.req_length_data
                    , s.class_byte
                    , s.instruction_byte
                    , s.parameter1
                    , s.parameter2
                    , s.length
                    , s.data
                from
                    emv_script_vw s
                    , emv_script_type_vw t
                where
                    t.id = s.type_id
                    and s.status = nvl(i_status, emv_api_const_pkg.SCRIPT_STATUS_WAITING)
                    and s.object_id = i_object_id
                    and s.entity_type = i_entity_type
                order by
                    t.priority
                ) o
            start with
                o.prev_body is null
            connect by
                o.prev_body = prior o.body
            order by
                o.priority
            ) x
        where
            x.length_body <= 240
            and (rownum <= x.max_script or x.max_script is null);

        trc_log_pkg.debug (
            i_text          => 'Selected [#1]'
            , i_env_param1  => o_script_tab.count
        );
    end;

    procedure select_card_scripts (
        i_card_instance_id      in com_api_type_pkg.t_medium_id
        , i_status              in com_api_type_pkg.t_dict_value
        , o_script_tab          out nocopy emv_api_type_pkg.t_emv_script_tab
    ) is
    begin
        select_scripts (
            i_object_id      => i_card_instance_id
            , i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
            , i_status       => i_status
            , o_script_tab   => o_script_tab
        );
    end;
    
    procedure register_script (
        i_object_id             in com_api_type_pkg.t_long_id
        , i_entity_type         in com_api_type_pkg.t_dict_value
        , i_type_id             in com_api_type_pkg.t_tiny_id
        , i_type                in com_api_type_pkg.t_dict_value
        , i_class_byte          in com_api_type_pkg.t_byte_char
        , i_instruction_byte    in com_api_type_pkg.t_byte_char
        , i_parameter1          in com_api_type_pkg.t_byte_char
        , i_parameter2          in com_api_type_pkg.t_byte_char
        , i_length              in com_api_type_pkg.t_tiny_id
        , i_data                in com_api_type_pkg.t_name
        , i_status              in com_api_type_pkg.t_dict_value
    ) is
    begin
        trc_log_pkg.debug (
            i_text          => 'Incoming emv script [#1][#2][#3][#4][#5]'
            , i_env_param1  => i_type_id
            , i_env_param2  => i_type
            , i_env_param3  => i_entity_type || ':' || i_object_id
            , i_env_param4  => i_length || ':' || i_data
            , i_env_param5  => nvl(i_status, emv_api_const_pkg.SCRIPT_STATUS_WAITING)
        );
    
        -- modify old scripts
        update emv_script_vw b
        set
            b.status = emv_api_const_pkg.SCRIPT_STATUS_OVERLOADED
            , b.change_date = get_sysdate
        where
            b.object_id = i_object_id
            and b.entity_type = i_entity_type
            and b.type_id in (
                select
                    i_type_id
                from
                    dual
                union all
                select
                    t.id
                from
                    emv_script_type t
                where
                    t.type = case i_type
                                 when emv_api_const_pkg.SCRIPT_TYPE_BLOCK_APPL then emv_api_const_pkg.SCRIPT_TYPE_UNBLOCK_APPL
                                 when emv_api_const_pkg.SCRIPT_TYPE_UNBLOCK_APPL then emv_api_const_pkg.SCRIPT_TYPE_BLOCK_APPL
                                 else i_type
                             end 
            )
            and b.status = emv_api_const_pkg.SCRIPT_STATUS_WAITING;
            
        -- add new script
        insert into emv_script_vw (
            id
            , object_id
            , entity_type
            , type_id
            , class_byte
            , instruction_byte
            , parameter1
            , parameter2
            , length
            , data
            , status
            , change_date
        ) values (
            emv_script_seq.nextval
            , i_object_id
            , i_entity_type
            , i_type_id
            , i_class_byte
            , i_instruction_byte
            , i_parameter1
            , i_parameter2
            , nvl(i_length, 0)
            , i_data
            , nvl(i_status, emv_api_const_pkg.SCRIPT_STATUS_WAITING)
            , get_sysdate
        );
        
        trc_log_pkg.debug (
            i_text          => 'Emv script saved'
        );
    end;

    procedure register_script (
        i_object_id             in com_api_type_pkg.t_long_id
        , i_entity_type         in com_api_type_pkg.t_dict_value
        , i_type                in com_api_type_pkg.t_dict_value
        , i_data                in com_api_type_pkg.t_name
        , i_status              in com_api_type_pkg.t_dict_value
    ) is
        l_script_type           emv_api_type_pkg.t_emv_script_type_rec;
    begin
        l_script_type := emv_api_script_type_pkg.get_script_type (
            i_type  => i_type
        );
        
        register_script (
            i_object_id           => i_object_id
            , i_entity_type       => i_entity_type
            , i_type_id           => l_script_type.id
            , i_type              => l_script_type.type
            , i_class_byte        => l_script_type.class_byte
            , i_instruction_byte  => l_script_type.instruction_byte
            , i_parameter1        => l_script_type.parameter1
            , i_parameter2        => l_script_type.parameter2
            , i_length            => prs_api_util_pkg.dec2hex(nvl(length(i_data), 0)/2)
            , i_data              => i_data
            , i_status            => i_status
        );
    end;

    procedure register_script_block_card (
        i_card_instance_id      in com_api_type_pkg.t_medium_id
    ) is
    begin
        register_script (
            i_object_id      => i_card_instance_id
            , i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
            , i_type         => emv_api_const_pkg.SCRIPT_TYPE_BLOCK_CARD
            , i_data         => null
        );
    end;

    procedure register_script_pin_change (
        i_card_instance_id      in com_api_type_pkg.t_medium_id
        , i_pvv                 in com_api_type_pkg.t_tiny_id
        , i_pin_block           in com_api_type_pkg.t_pin_block
    ) is
        l_script_type           emv_api_type_pkg.t_emv_script_type_rec;
    begin
        register_script (
            i_object_id      => i_card_instance_id
            , i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
            , i_type         => emv_api_const_pkg.SCRIPT_TYPE_PIN_CHANGE
            , i_data         => i_pin_block
        );
    end;
    
    procedure  register_script_pin_unblock (
        i_card_instance_id      in com_api_type_pkg.t_medium_id
    ) is
    begin
        register_script (
            i_object_id      => i_card_instance_id
            , i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
            , i_type         => emv_api_const_pkg.SCRIPT_TYPE_PIN_UNBLOCK
            , i_data         => null
        );
    end;

    procedure register_script_block_appl (
        i_card_instance_id      in com_api_type_pkg.t_medium_id
    ) is
        l_appl_scheme           emv_api_type_pkg.t_emv_appl_scheme_rec;
    begin
        l_appl_scheme := emv_api_application_pkg.get_emv_appl_scheme (
            i_object_id      => i_card_instance_id
            , i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
        );

        register_script (
            i_object_id      => l_appl_scheme.id
            , i_entity_type  => emv_api_const_pkg.ENTITY_TYPE_EMV_SCHEME
            , i_type         => emv_api_const_pkg.SCRIPT_TYPE_BLOCK_APPL
            , i_data         => null
        );
    end;

    procedure register_script_unblock_appl (
        i_card_instance_id      in com_api_type_pkg.t_medium_id
    ) is
        l_appl_scheme           emv_api_type_pkg.t_emv_appl_scheme_rec;
    begin
        l_appl_scheme := emv_api_application_pkg.get_emv_appl_scheme (
            i_object_id      => i_card_instance_id
            , i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
        );

        register_script (
            i_object_id      => l_appl_scheme.id
            , i_entity_type  => emv_api_const_pkg.ENTITY_TYPE_EMV_SCHEME
            , i_type         => emv_api_const_pkg.SCRIPT_TYPE_UNBLOCK_APPL
            , i_data         => null
        );
    end;
    
    procedure link_script (
        i_auth_id               in com_api_type_pkg.t_long_id
        , i_script_id           in com_api_type_pkg.t_long_id
    ) is
        l_auth_id               com_api_type_pkg.t_number_tab;
        l_script_id             com_api_type_pkg.t_number_tab;
        i                       binary_integer;
    begin
        i := l_auth_id.count + 1;
        
        l_auth_id(i) := i_auth_id;
        l_script_id(i) := i_script_id;
        
        link_scripts (
            i_auth_id      => l_auth_id
            , i_script_id  => l_script_id
        );
        
        l_auth_id.delete;
        l_script_id.delete;
    end;
    
    procedure link_scripts (
        i_auth_id               in com_api_type_pkg.t_number_tab
        , i_script_id           in com_api_type_pkg.t_number_tab
    ) is
    begin
        forall i in 1 .. i_auth_id.count
            merge into
                emv_linked_script dst
            using (
                select
                    i_auth_id(i) auth_id
                    , i_script_id(i) script_id
                from dual
            ) src
            on (
                src.auth_id = dst.auth_id
                and src.script_id = dst.script_id
            )
            when not matched then
                insert (
                    dst.auth_id
                    , dst.script_id
                ) values (
                    src.auth_id
                    , src.script_id
                );
    end;
    
    procedure get_link_scripts (
        i_auth_id               in com_api_type_pkg.t_long_id
        , o_script_tab          out nocopy com_api_type_pkg.t_number_tab
    ) is
    begin
        select
            s.id
        bulk collect into
            o_script_tab
        from
            emv_linked_script_vw l
            , emv_script_vw s
        where
            l.auth_id = i_auth_id
            and s.id = l.script_id;
        
        trc_log_pkg.debug (
            i_text          => 'Selected linked scripts [#1]'
            , i_env_param1  => o_script_tab.count
        );
    end;


end;
/
