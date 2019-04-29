create or replace package body prs_ui_sort_pkg is
/************************************************************
 * User interface for personalization sort <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 03.08.2010 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: prs_ui_sort_pkg <br />
 * @headcom
 ************************************************************/

    procedure add_sort (
        o_id                           out com_api_type_pkg.t_tiny_id
        , o_seqnum                     out com_api_type_pkg.t_seqnum
        , i_inst_id                 in     com_api_type_pkg.t_inst_id
        , i_condition               in     com_api_type_pkg.t_full_desc
        , i_lang                    in     com_api_type_pkg.t_dict_value
        , i_label                   in     com_api_type_pkg.t_name
        , i_description             in     com_api_type_pkg.t_full_desc
    ) is
    begin
        o_id := prs_sort_seq.nextval;
        o_seqnum := 1;

        insert into prs_sort_vw (
            id
            , seqnum
            , inst_id
            , condition
        ) values (
            o_id
            , o_seqnum
            , i_inst_id
            , i_condition
        );

        com_api_i18n_pkg.add_text (
            i_table_name     => 'prs_sort'
            , i_column_name  => 'label'
            , i_object_id    => o_id
            , i_lang         => i_lang
            , i_text         => i_label
        );
        
        if i_description is not null then
            com_api_i18n_pkg.add_text (
                i_table_name     => 'prs_sort'
                , i_column_name  => 'description'
                , i_object_id    => o_id
                , i_lang         => i_lang
                , i_text         => i_description
            );
        end if;
    end;

    procedure modify_sort (
        i_id                        in     com_api_type_pkg.t_tiny_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_condition               in     com_api_type_pkg.t_full_desc
        , i_lang                    in     com_api_type_pkg.t_dict_value
        , i_label                   in     com_api_type_pkg.t_name
        , i_description             in     com_api_type_pkg.t_full_desc
    ) is
    begin
        update
            prs_sort_vw
        set
            seqnum = io_seqnum
            , condition = i_condition
        where
            id = i_id;

        io_seqnum := io_seqnum + 1;

        com_api_i18n_pkg.add_text (
            i_table_name     => 'prs_sort'
            , i_column_name  => 'label'
            , i_object_id    => i_id
            , i_lang         => i_lang
            , i_text         => i_label
        );

        if i_description is not null then
            com_api_i18n_pkg.add_text (
                i_table_name     => 'prs_sort'
                , i_column_name  => 'description'
                , i_object_id    => i_id
                , i_lang         => i_lang
                , i_text         => i_description
            );
        end if;
    end;

    procedure remove_sort (
        i_id                        in     com_api_type_pkg.t_tiny_id
        , i_seqnum                  in     com_api_type_pkg.t_seqnum
    ) is
        l_check_cnt                 number;
    begin
        select
            count(*)
        into
            l_check_cnt
        from
            prs_batch_vw
        where
            sort_id = i_id;

        if l_check_cnt > 0 then
            com_api_error_pkg.raise_error (
                i_error  => 'SORT_ALREADY_USED'
            );
        end if;

        com_api_i18n_pkg.remove_text (
            i_table_name   => 'prs_sort'
            , i_object_id  => i_id
        );

        update
            prs_sort_vw
        set
            seqnum = i_seqnum
        where
            id = i_id;

        delete from
            prs_sort_vw
        where
            id = i_id;
    end;

end;
/
