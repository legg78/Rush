create or replace package body acm_ui_action_group_pkg is
/************************************************************
 * User interface for Grouping context actions <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 14.12.2011 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: acm_ui_action_group_pkg <br />
 * @headcom
 ************************************************************/

    procedure add_acm_action_group (
        o_id                        out com_api_type_pkg.t_tiny_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_entity_type             in com_api_type_pkg.t_dict_value
        , i_parent_id               in com_api_type_pkg.t_tiny_id
        , i_inst_id                 in com_api_type_pkg.t_inst_id
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_label                   in com_api_type_pkg.t_name
    ) is
    begin
        o_id := acm_action_seq.nextval;
        o_seqnum := 1;

        insert into acm_action_group_vw (
            id
            , seqnum
            , entity_type
            , parent_id
            , inst_id
        ) values (
            o_id
            , o_seqnum
            , i_entity_type
            , i_parent_id
            , i_inst_id
        );

        com_api_i18n_pkg.add_text (
            i_table_name     => 'acm_action_group'
            , i_column_name  => 'label'
            , i_object_id    => o_id
            , i_lang         => i_lang
            , i_text         => i_label
        );

    end;

    procedure modify_acm_action_group (
        i_id                        in com_api_type_pkg.t_tiny_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_parent_id               in com_api_type_pkg.t_tiny_id
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_label                   in com_api_type_pkg.t_name
    ) is
    begin
        update
            acm_action_group_vw
        set
            seqnum = io_seqnum
            , parent_id = i_parent_id
        where
            id = i_id;

        io_seqnum := io_seqnum + 1;

        com_api_i18n_pkg.add_text (
            i_table_name     => 'acm_action_group'
            , i_column_name  => 'label'
            , i_object_id    => i_id
            , i_lang         => i_lang
            , i_text         => i_label
        );

    end;

    procedure remove_acm_action_group (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    ) is
        l_check_cnt                 number;
    begin
        select
            count(*)
        into
            l_check_cnt
        from
            acm_action_vw t
        where
            t.group_id = i_id;

        if l_check_cnt > 0 then
            com_api_error_pkg.raise_error (
                i_error  => 'ACTION_GROUP_ALREADY_USED'
            );
        end if;
        
        -- remove text
        com_api_i18n_pkg.remove_text (
            i_table_name   => 'acm_action_group'
            , i_object_id  => i_id
        );

        update
            acm_action_group_vw
        set
            seqnum = i_seqnum
        where
            id = i_id;

        -- delete
        delete from
            acm_action_group_vw
        where
            id = i_id;

    end;

end;
/
