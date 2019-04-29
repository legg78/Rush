create or replace package body acm_ui_widget_param_pkg is
/************************************************************
 * User interface for widget parameters type <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 10.05.2012 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: acm_ui_widget_param_pkg <br />
 * @headcom
 ************************************************************/

    procedure add_widget_param (
        o_id                    out com_api_type_pkg.t_short_id
        , o_seqnum              out com_api_type_pkg.t_seqnum
        , i_param_name          in com_api_type_pkg.t_name
        , i_label               in com_api_type_pkg.t_name
        , i_data_type           in com_api_type_pkg.t_dict_value
        , i_lov_id              in com_api_type_pkg.t_tiny_id
        , i_widget_id           in com_api_type_pkg.t_tiny_id
        , i_lang                in com_api_type_pkg.t_dict_value
    ) is
    begin
        o_id := acm_widget_param_seq.nextval;
        o_seqnum := 1;

        insert into acm_widget_param_vw (
            id
            , seqnum
            , param_name
            , data_type
            , lov_id
            , widget_id
        ) values (
            o_id
            , o_seqnum
            , i_param_name
            , i_data_type
            , i_lov_id
            , i_widget_id
        );
        
        com_api_i18n_pkg.add_text (
            i_table_name     => 'acm_widget_param'
            , i_column_name  => 'label'
            , i_object_id    => o_id
            , i_lang         => i_lang
            , i_text         => i_label
        );
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error (
                i_error  => 'DUPLICATE_WIDGET_PARAM'
            );
    end;

    procedure modify_widget_param (
        i_id                    in com_api_type_pkg.t_short_id
        , io_seqnum             in out com_api_type_pkg.t_seqnum
        , i_param_name          in com_api_type_pkg.t_name
        , i_label               in com_api_type_pkg.t_name
        , i_data_type           in com_api_type_pkg.t_dict_value
        , i_lov_id              in com_api_type_pkg.t_tiny_id
        , i_widget_id           in com_api_type_pkg.t_tiny_id
        , i_lang                in com_api_type_pkg.t_dict_value
    ) is
    begin
        update
            acm_widget_param_vw
        set
            seqnum = io_seqnum
            , param_name = i_param_name
            , data_type = i_data_type
            , lov_id = i_lov_id
            , widget_id = i_widget_id
        where
            id = i_id;

        io_seqnum := io_seqnum + 1;
        
        com_api_i18n_pkg.add_text (
            i_table_name     => 'acm_widget_param'
            , i_column_name  => 'label'
            , i_object_id    => i_id
            , i_lang         => i_lang
            , i_text         => i_label
        );
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error (
                i_error  => 'DUPLICATE_WIDGET_PARAM'
            );
    end;

    procedure remove_widget_param (
        i_id                    in com_api_type_pkg.t_short_id
        , i_seqnum              in com_api_type_pkg.t_seqnum
    ) is
        l_check_cnt             number;
    begin
        select
            count(*)
        into
            l_check_cnt
        from
            acm_widget_param_value_vw
        where
            widget_param_id = i_id;

        if l_check_cnt > 0 then
            com_api_error_pkg.raise_error (
                i_error  => 'WIDGET_PARAM_USED'
            );
        end if;

        update
            acm_widget_param_vw
        set
            seqnum = i_seqnum
        where
            id = i_id;

        delete from
            acm_widget_param_vw
        where
            id = i_id;
            
        -- remove text
        com_api_i18n_pkg.remove_text (
            i_table_name   => 'acm_widget_param'
            , i_object_id  => i_id
        );
    end;

    procedure set_value (
        io_id                   in out com_api_type_pkg.t_short_id
        , io_seqnum             in out com_api_type_pkg.t_seqnum
        , i_widget_param_id     in com_api_type_pkg.t_short_id
        , i_dashboard_widget_id in com_api_type_pkg.t_short_id
        , i_value_char          in varchar2 default null
        , i_value_date          in date default null
        , i_value_number        in number default null
    ) is
        l_value                 com_api_type_pkg.t_name;
    begin
        l_value :=
        case
             when i_value_char is not null then i_value_char
             when i_value_date is not null then to_char(i_value_date, com_api_const_pkg.DATE_FORMAT)
             when i_value_number is not null then to_char(i_value_number, com_api_const_pkg.NUMBER_FORMAT)
        end;
        
        if io_id is null then
            io_id := acm_widget_param_value_seq.nextval;
            io_seqnum := 1;
                
            insert into acm_widget_param_value_vw (
                id
                , seqnum
                , param_value
                , widget_param_id
                , dashboard_widget_id
            ) values (
                io_id
                , io_seqnum
                , l_value
                , i_widget_param_id
                , i_dashboard_widget_id
            );        
        else
            update
                acm_widget_param_value_vw
            set
                widget_param_id = i_widget_param_id
                , dashboard_widget_id = i_dashboard_widget_id
                , param_value = l_value
                , seqnum = io_seqnum
            where
                id = io_id;
                    
            io_seqnum := io_seqnum + 1;
        end if;
    end;

    procedure set_widget_param_value_char (
        io_id                   in out com_api_type_pkg.t_short_id
        , io_seqnum             in out com_api_type_pkg.t_seqnum
        , i_widget_param_id     in com_api_type_pkg.t_short_id
        , i_dashboard_widget_id in com_api_type_pkg.t_short_id
        , i_param_value         in com_api_type_pkg.t_name
    ) is
    begin
        set_value (
            io_id                    => io_id
            , io_seqnum              => io_seqnum
            , i_widget_param_id      => i_widget_param_id
            , i_dashboard_widget_id  => i_dashboard_widget_id
            , i_value_char           => i_param_value
        );
    end;

    procedure set_widget_param_value_num (
        io_id                   in out com_api_type_pkg.t_short_id
        , io_seqnum             in out com_api_type_pkg.t_seqnum
        , i_widget_param_id     in com_api_type_pkg.t_short_id
        , i_dashboard_widget_id in com_api_type_pkg.t_short_id
        , i_param_value         in number
    ) is
    begin
        set_value (
            io_id                    => io_id
            , io_seqnum              => io_seqnum
            , i_widget_param_id      => i_widget_param_id
            , i_dashboard_widget_id  => i_dashboard_widget_id
            , i_value_number         => i_param_value
        );
    end;

    procedure set_widget_param_value_date (
        io_id                   in out com_api_type_pkg.t_short_id
        , io_seqnum             in out com_api_type_pkg.t_seqnum
        , i_widget_param_id     in com_api_type_pkg.t_short_id
        , i_dashboard_widget_id in com_api_type_pkg.t_short_id
        , i_param_value         in date
    )is
    begin
        set_value (
            io_id                    => io_id
            , io_seqnum              => io_seqnum
            , i_widget_param_id      => i_widget_param_id
            , i_dashboard_widget_id  => i_dashboard_widget_id
            , i_value_date           => i_param_value
        );
    end;

    procedure remove_widget_param_value (
        i_id                    in com_api_type_pkg.t_short_id
        , i_seqnum              in com_api_type_pkg.t_seqnum
    ) is
    begin
        update
            acm_widget_param_value_vw
        set
            seqnum = i_seqnum
        where
            id = i_id;
            
        delete from
            acm_widget_param_value_vw
        where
            id = i_id;
    end;

end;
/
