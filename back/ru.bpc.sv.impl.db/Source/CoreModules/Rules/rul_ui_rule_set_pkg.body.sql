create or replace package body rul_ui_rule_set_pkg is
/*********************************************************
*  UI for rules set <br />
*  Created by Khougaev A.(khougaev@bpc.ru)  at 21.01.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: RUL_UI_RULE_SET_PKG <br />
*  @headcom
**********************************************************/ 
procedure add (
    o_id                    out com_api_type_pkg.t_tiny_id
    , o_seqnum              out com_api_type_pkg.t_seqnum
    , i_name                in com_api_type_pkg.t_name
    , i_category            in com_api_type_pkg.t_dict_value
    , i_lang                in com_api_type_pkg.t_dict_value := null
) is
begin
    o_id := rul_rule_set_seq.nextval;
    o_seqnum := 1;

    insert into rul_rule_set_vw (
        id
        , seqnum
        , category
    ) values (
        o_id
        , o_seqnum
        , i_category
    );

    com_api_i18n_pkg.add_text (
        i_table_name    => 'rul_rule_set'
        , i_column_name => 'name'
        , i_object_id   => o_id
        , i_text        => i_name
        , i_lang        => i_lang
        , i_check_unique  => com_api_type_pkg.TRUE
    );
end;

procedure modify (
    i_id                    in com_api_type_pkg.t_tiny_id
    , io_seqnum             in out com_api_type_pkg.t_seqnum
    , i_name                in com_api_type_pkg.t_name
    , i_category            in com_api_type_pkg.t_dict_value
    , i_lang                in com_api_type_pkg.t_dict_value := null
) is
    l_check_cnt         number;
begin
    select
        count(1)
    into
        l_check_cnt
    from 
        rul_rule_vw
    where
        rule_set_id = i_id;

    if l_check_cnt > 0 then
        for rec in (
            select
                category
            from
                rul_rule_set_vw
            where
                id = i_id
        ) loop
            if i_category <> rec.category then
                com_api_error_pkg.raise_error (
                    i_error         => 'CATEGORY_RULE_SET_NOT_CHANGE'
                );
            end if;
        end loop;
    end if;
                    
    update
        rul_rule_set_vw
    set
        seqnum = io_seqnum
        , category = i_category
    where
        id = i_id;
        
    io_seqnum := io_seqnum + 1;

    com_api_i18n_pkg.add_text (
        i_table_name    => 'rul_rule_set'
        , i_column_name => 'name'
        , i_object_id   => i_id
        , i_text        => i_name
        , i_lang        => i_lang
        , i_check_unique  => com_api_type_pkg.TRUE
    );
end;

procedure remove (
    i_id                    in com_api_type_pkg.t_tiny_id
    , i_seqnum              in com_api_type_pkg.t_seqnum
) is
    l_check_cnt             com_api_type_pkg.t_count := 0;
begin
    select
        count(*)
    into
        l_check_cnt
    from (
        select
            1 
        from
            opr_rule_selection_vw
        where
            rule_set_id = i_id
            and rownum  = 1
    );
        
    if l_check_cnt > 0 then
        com_api_error_pkg.raise_error (
            i_error         => 'RULE_SET_ALREADY_USED'
            , i_env_param1  => i_id
        );
    end if;
    
    -- delete rule param value
    delete from 
        rul_rule_param_value_vw
    where
        rule_id in (
            select 
                id
            from
                rul_rule
            where
                rule_set_id = i_id
    );
                
    -- delete rule
    delete from
        rul_rule_vw
    where
        rule_set_id = i_id;
        
    -- delete rule set
    update
        rul_rule_set_vw
    set
        seqnum = i_seqnum
    where
        id = i_id;

    delete from
        rul_rule_set_vw
    where
        id = i_id;
            
    com_api_i18n_pkg.remove_text (
        i_table_name   => 'rul_rule_set'
        , i_object_id  => i_id
    );
end;

procedure clone_rule_set ( 
    i_id                    in com_api_type_pkg.t_tiny_id
    , i_name                in com_api_type_pkg.t_name
    , i_lang                in com_api_type_pkg.t_dict_value := null
    , o_cloned_id           out com_api_type_pkg.t_tiny_id
) is
    l_rule_set_id             com_api_type_pkg.t_tiny_id;
    l_rule_set_seqnum         com_api_type_pkg.t_seqnum;
    l_rule_id                 com_api_type_pkg.t_short_id;
    l_rule_seqnum             com_api_type_pkg.t_seqnum;
    l_rule_param_value_id     com_api_type_pkg.t_short_id;
    l_rule_param_value_seqnum com_api_type_pkg.t_seqnum;
begin
    for rule_set in (
        select
            s.id
            , s.category
        from
            rul_rule_set_vw s
        where
            s.id = i_id
    ) loop
        rul_ui_rule_set_pkg.add (
            o_id          => l_rule_set_id
            , o_seqnum    => l_rule_set_seqnum
            , i_name      => i_name
            , i_category  => rule_set.category
            , i_lang      => i_lang
        );
        o_cloned_id := l_rule_set_id;

        for rule in (
            select
                r.id
                , r.rule_set_id
                , r.proc_id
                , r.exec_order
            from
                rul_rule_vw r
            where
                r.rule_set_id = rule_set.id
        ) loop
            l_rule_id := null;
            l_rule_seqnum := null;
            
            rul_ui_rule_pkg.add (
                o_id             => l_rule_id
                , o_seqnum       => l_rule_seqnum
                , i_rule_set_id  => l_rule_set_id
                , i_proc_id      => rule.proc_id
                , i_exec_order   => rule.exec_order
            );
            
            for rule_param_value in (
                select
                    v.id
                    , v.rule_id
                    , v.proc_param_id
                    , v.param_value
                from
                    rul_rule_param_value v
                where
                    v.rule_id = rule.id
            ) loop
                l_rule_param_value_id := null;
                l_rule_param_value_seqnum := null;
                
                rul_ui_rule_param_value_pkg.set_value (
                    io_id              => l_rule_param_value_id
                    , io_seqnum        => l_rule_param_value_seqnum
                    , i_rule_id        => l_rule_id
                    , i_proc_param_id  => rule_param_value.proc_param_id
                    , i_value_v        => rule_param_value.param_value
                );
            end loop;
        end loop;
    end loop;
end;

end;
/
