create or replace package body opr_ui_match_pkg is

    procedure check_text(
        i_object_id             in com_api_type_pkg.t_inst_id
        , i_inst_id             in com_api_type_pkg.t_inst_id
        , i_text                in com_api_type_pkg.t_name
    )is
    l_count                 com_api_type_pkg.t_tiny_id;
    
    begin       
        if i_object_id is null then
            select count(1)    
              into l_count
              from com_i18n i 
                 , opr_match_condition c  
             where i.table_name = 'OPR_MATCH_CONDITION'
               and i.column_name = 'NAME'  
               and i.text = i_text
               and c.id = i.object_id
               and c.inst_id = i_inst_id;
        else
            select count(1)
              into l_count
              from com_i18n i
                 , opr_match_condition c  
             where i.table_name = 'OPR_MATCH_CONDITION'
               and i.column_name = 'NAME'  
               and i.text        = i_text
               and c.id = i.object_id
               and i.object_id   != i_object_id
               and c.inst_id = i_inst_id;      
        end if;
        
        trc_log_pkg.debug (
            i_text          => 'l_count ' || l_count
        );
        
        if l_count > 0 then
            com_api_error_pkg.raise_error(
                  i_error           => 'CONDITION_ALREADY_EXISTS_IN_INST'
                , i_env_param1      => i_text 
                , i_env_param2      => i_inst_id 
            );            
        end if;         
    end;
    
    procedure add_match_condition (
        o_id                    out com_api_type_pkg.t_tiny_id
        , o_seqnum              out com_api_type_pkg.t_seqnum
        , i_inst_id             in com_api_type_pkg.t_inst_id
        , i_lang                in com_api_type_pkg.t_dict_value
        , i_name                in com_api_type_pkg.t_name
        , i_condition           in com_api_type_pkg.t_full_desc
    ) is
    begin
    
        check_text(
            i_object_id         => o_id
            , i_inst_id         => i_inst_id
            , i_text            => i_name
        );
            
        o_id := opr_match_condition_seq.nextval;
        o_seqnum := 1;
            
        insert into opr_match_condition_vw (
            id
            , inst_id
            , condition
            , seqnum
        ) values (
            o_id
            , i_inst_id
            , i_condition
            , o_seqnum
        );
            
        com_api_i18n_pkg.add_text(
            i_table_name            => 'opr_match_condition' 
          , i_column_name           => 'name' 
          , i_object_id             => o_id
          , i_lang                  => i_lang
          , i_text                  => i_name
          , i_check_unique          => com_api_type_pkg.FALSE
        );
    end;
    
    procedure modify_match_condition (
        i_id                    in com_api_type_pkg.t_tiny_id
        , io_seqnum             in out com_api_type_pkg.t_seqnum
        , i_lang                in com_api_type_pkg.t_dict_value
        , i_name                in com_api_type_pkg.t_name
        , i_condition           in com_api_type_pkg.t_full_desc
    ) is
    l_inst_id                   com_api_type_pkg.t_inst_id;
    
    begin
        select inst_id
          into l_inst_id 
          from opr_match_condition 
         where id = i_id; 
             
        check_text(
            i_object_id         => i_id
            , i_inst_id         => l_inst_id
            , i_text            => i_name
        );
    
        update
            opr_match_condition_vw
        set 
            seqnum = io_seqnum
            , condition = i_condition
        where
            id = i_id;

        io_seqnum := io_seqnum + 1;
    
        com_api_i18n_pkg.add_text(
            i_table_name            => 'opr_match_condition' 
          , i_column_name           => 'name' 
          , i_object_id             => i_id
          , i_lang                  => i_lang
          , i_text                  => i_name
          , i_check_unique          => com_api_type_pkg.FALSE
        );
    end;
    
    procedure remove_match_condition (
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
            opr_match_level_condition_vw
        where 
            condition_id = i_id 
            and rownum = 1;
            
        if l_check_cnt > 0 then
            com_api_error_pkg.raise_error(
                  i_error           => 'MATCH_CONDITION_INCLUDED_IN_LEVEL'
                , i_env_param1      => i_id 
            );
        else
            com_api_i18n_pkg.remove_text(
                i_table_name            => 'opr_match_condition' 
              , i_object_id             => i_id
            );

            update
                opr_match_condition_vw
            set
                seqnum = i_seqnum
            where
                id = i_id;

            delete from
                opr_match_condition_vw
            where
                id = i_id;
        end if;
    end;

    procedure add_match_level (
        o_id                    out com_api_type_pkg.t_tiny_id
        , o_seqnum              out com_api_type_pkg.t_seqnum
        , i_inst_id             in com_api_type_pkg.t_inst_id
        , i_lang                in com_api_type_pkg.t_dict_value
        , i_name                in com_api_type_pkg.t_name
        , i_priority            in com_api_type_pkg.t_tiny_id
    ) is
    begin
        o_id := opr_match_level_seq.nextval;
        o_seqnum := 1;
            
        insert into opr_match_level_vw (
            id
            , inst_id
            , priority
            , seqnum
        ) values (
            o_id
            , i_inst_id
            , i_priority
            , o_seqnum
        );
            
        com_api_i18n_pkg.add_text(
            i_table_name            => 'opr_match_level' 
          , i_column_name           => 'name' 
          , i_object_id             => o_id
          , i_lang                  => i_lang
          , i_text                  => i_name
        );
    end;

    procedure modify_match_level (
        i_id                    in com_api_type_pkg.t_tiny_id
        , io_seqnum             in out com_api_type_pkg.t_seqnum
        , i_lang                in com_api_type_pkg.t_dict_value
        , i_name                in com_api_type_pkg.t_name
        , i_priority            in com_api_type_pkg.t_tiny_id
    ) is
    begin
        update
            opr_match_level_vw
        set 
            seqnum = io_seqnum
            , priority = i_priority
        where
            id = i_id;

        io_seqnum := io_seqnum + 1;
    
        com_api_i18n_pkg.add_text(
            i_table_name            => 'opr_match_level' 
          , i_column_name           => 'name' 
          , i_object_id             => i_id
          , i_lang                  => i_lang
          , i_text                  => i_name
        );
    end;

    procedure remove_match_level (
        i_id                    in com_api_type_pkg.t_tiny_id
        , i_seqnum              in com_api_type_pkg.t_seqnum
    ) is
    begin
        com_api_i18n_pkg.remove_text(
            i_table_name            => 'opr_match_level' 
          , i_object_id             => i_id
        );

        delete from
            opr_match_level_condition_vw
        where
            level_id = i_id;

        update
            opr_match_level_vw
        set
            seqnum = i_seqnum
        where
            id = i_id;

        delete from
            opr_match_level_vw
        where
            id = i_id;
    end;

    procedure include_condition_in_level (
        o_id                    out com_api_type_pkg.t_tiny_id
        , o_seqnum              out com_api_type_pkg.t_seqnum
        , i_level_id            in com_api_type_pkg.t_tiny_id
        , i_condition_id        in com_api_type_pkg.t_tiny_id
    ) is
    begin
        o_id := opr_match_level_condition_seq.nextval;
        o_seqnum := 1;
            
        insert into opr_match_level_condition_vw (
            id
            , level_id
            , condition_id
            , seqnum
        ) values (
            o_id
            , i_level_id
            , i_condition_id
            , o_seqnum
        );
    end;

    procedure remove_condition_from_level (
        i_id                    in com_api_type_pkg.t_tiny_id
        , i_seqnum              in com_api_type_pkg.t_seqnum
    ) is
    begin
        update
            opr_match_level_condition_vw
        set
            seqnum = i_seqnum
        where
            id = i_id;
            
        delete from
            opr_match_level_condition_vw
        where
            id = i_id;
    end;

end;
/
