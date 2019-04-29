create or replace package body acq_ui_mcc_selection_tpl_pkg is
/************************************************************
 * User interface for MCC selection template <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 29.01.2013 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: emv_ui_appl_scheme_pkg <br />
 * @headcom
 ************************************************************/

    procedure add_selection_tpl (
        o_id                        out com_api_type_pkg.t_medium_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_name
        , i_description             in com_api_type_pkg.t_full_desc
    ) is
    begin
        o_id := acq_mcc_selection_tpl_seq.nextval;
        o_seqnum := 1;

        insert into acq_mcc_selection_tpl_vw (
            id
            , seqnum
        ) values (
            o_id
            , o_seqnum
        );

        com_api_i18n_pkg.add_text (
            i_table_name     => 'acq_mcc_selection_tpl'
            , i_column_name  => 'name'
            , i_object_id    => o_id
            , i_lang         => i_lang
            , i_text         => i_name
            , i_check_unique => com_api_type_pkg.TRUE
        );

        com_api_i18n_pkg.add_text (
            i_table_name     => 'acq_mcc_selection_tpl'
            , i_column_name  => 'description'
            , i_object_id    => o_id
            , i_lang         => i_lang
            , i_text         => i_description
        );

    end;

    procedure modify_selection_tpl(
        i_id                        in com_api_type_pkg.t_medium_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_name
        , i_description             in com_api_type_pkg.t_full_desc
    ) is
    begin
        update
            acq_mcc_selection_tpl_vw
        set
            seqnum = io_seqnum
        where
            id = i_id;

        io_seqnum := io_seqnum + 1;

        com_api_i18n_pkg.add_text (
            i_table_name     => 'acq_mcc_selection_tpl'
            , i_column_name  => 'name'
            , i_object_id    => i_id
            , i_lang         => i_lang
            , i_text         => i_name
            , i_check_unique => com_api_type_pkg.TRUE
        );

        com_api_i18n_pkg.add_text (
            i_table_name     => 'acq_mcc_selection_tpl'
            , i_column_name  => 'description'
            , i_object_id    => i_id
            , i_lang         => i_lang
            , i_text         => i_description
        );

    end;

    procedure remove_selection_tpl (
        i_id                        in com_api_type_pkg.t_medium_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    ) is
    begin
        -- remove text
        com_api_i18n_pkg.remove_text (
            i_table_name   => 'acq_mcc_selection_tpl'
            , i_object_id  => i_id
        );

        update
            acq_mcc_selection_tpl_vw
        set
            seqnum = i_seqnum
        where
            id = i_id;

        for r in
        (
            select id 
                from acq_mcc_selection_vw
            where mcc_template_id = i_id    
        )
        loop
            acq_ui_mcc_selection_pkg.remove (
                i_id => r.id
            );
        end loop;

        -- delete scheme
        delete from
            acq_mcc_selection_tpl_vw
        where
            id = i_id;

    end;

end;
/
