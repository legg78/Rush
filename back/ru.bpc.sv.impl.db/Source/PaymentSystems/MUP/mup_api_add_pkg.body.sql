create or replace package body mup_api_add_pkg is

    procedure enum_messages_for_upload (
        i_fin_id                in            com_api_type_pkg.t_long_id
      , o_add_tab               in out nocopy mup_api_type_pkg.t_add_tab
    ) is
    begin
        select
            rowid
            , id
            , fin_id
            , file_id
            , is_incoming
            , mti
            , de024
            , de032
            , de033
            , de063
            , de071
            , de093
            , de094
            , de100
        bulk collect into
            o_add_tab
        from
            mup_add
        where
            fin_id = i_fin_id
        order by
            id
        for update;
    end;

    procedure pack_message (
        i_add_rec               in mup_api_type_pkg.t_add_rec
      , i_file_id               in com_api_type_pkg.t_short_id
      , i_de071                 in mup_api_type_pkg.t_de071
      , i_fin_de071             in mup_api_type_pkg.t_de071
      , o_raw_data              out varchar2
      , i_charset               in com_api_type_pkg.t_oracle_name := null
    ) is
        l_pds_tab                mup_api_type_pkg.t_pds_tab;
    begin
        mup_api_pds_pkg.read_pds (
            i_msg_id        => i_add_rec.id
            , o_pds_tab     => l_pds_tab
        );

        mup_api_msg_pkg.pack_message (
            i_mti            => i_add_rec.mti
            , i_de024        => i_add_rec.de024
            , i_de032        => i_add_rec.de032
            , i_de033        => i_add_rec.de033
            , i_de071        => i_de071
            , i_de094        => i_add_rec.de094
            , i_pds_tab      => l_pds_tab
            , o_raw_data     => o_raw_data
            , i_charset      => i_charset
        );
    end;

    procedure mark_uploaded (
        i_rowid                 in com_api_type_pkg.t_rowid_tab
      , i_file_id               in com_api_type_pkg.t_number_tab
      , i_de071                 in com_api_type_pkg.t_number_tab
      , i_fin_de071             in com_api_type_pkg.t_number_tab
    ) is
    begin
        forall i in 1 .. i_rowid.count
            update mup_add
            set
                de071 = i_de071(i)
                , file_id = i_file_id(i)
            where
                rowid = i_rowid(i);
    end;

    procedure put_message (
        i_add_rec               in mup_api_type_pkg.t_add_rec
    ) is
    begin
        insert into mup_add (
            id
            , fin_id
            , file_id
            , is_incoming
            , mti
            , de024
            , de071
            , de032
            , de033
            , de063
            , de093
            , de094
            , de100
        ) values (
            i_add_rec.id
            , i_add_rec.fin_id
            , i_add_rec.file_id
            , i_add_rec.is_incoming
            , i_add_rec.mti
            , i_add_rec.de024
            , i_add_rec.de071
            , i_add_rec.de032
            , i_add_rec.de033
            , i_add_rec.de063
            , i_add_rec.de093
            , i_add_rec.de094
            , i_add_rec.de100
        );
    end;

    procedure create_incoming_addendum (
        i_mes_rec                in mup_api_type_pkg.t_mes_rec
        , i_file_id              in com_api_type_pkg.t_short_id
        , i_fin_id               in com_api_type_pkg.t_long_id
        , i_network_id           in com_api_type_pkg.t_tiny_id
    ) is
        l_add_rec                mup_api_type_pkg.t_add_rec;
        l_pds_tab                mup_api_type_pkg.t_pds_tab;
        l_pds_body               mup_api_type_pkg.t_pds_body;

        l_stage                  varchar2(100);
    begin
        l_add_rec := null;

        l_stage := 'init';
        -- init
        l_add_rec.id := opr_api_create_pkg.get_id;
        l_add_rec.fin_id := i_fin_id;
        l_add_rec.file_id := i_file_id;
        l_add_rec.is_incoming := com_api_type_pkg.TRUE;

        l_stage := 'mti & de24 - de100';
        l_add_rec.mti := i_mes_rec.mti;
        l_add_rec.de024 := i_mes_rec.de024;
        l_add_rec.de032 := i_mes_rec.de032;
        l_add_rec.de033 := i_mes_rec.de033;
        l_add_rec.de063 := i_mes_rec.de063;
        l_add_rec.de071 := i_mes_rec.de071;
        l_add_rec.de093 := i_mes_rec.de093;
        l_add_rec.de094 := i_mes_rec.de094;
        l_add_rec.de100 := i_mes_rec.de100;

        l_stage := 'extract_pds';
        mup_api_pds_pkg.extract_pds (
            de048        => i_mes_rec.de048
            , de062      => i_mes_rec.de062
            , de123      => i_mes_rec.de123
            , de124      => i_mes_rec.de124
            , de125      => i_mes_rec.de125
            , pds_tab    => l_pds_tab
        );

        l_stage := 'put_message';
        put_message (
            i_add_rec    => l_add_rec
        );

        l_stage := 'save_pds';
        mup_api_pds_pkg.save_pds (
            i_msg_id     => l_add_rec.id
            , i_pds_tab  => l_pds_tab
        );

    exception
        when others then
            trc_log_pkg.debug(
                i_text => 'Error generating IPM addendum on stage ' || l_stage || ': ' || sqlerrm
            );
            raise;
    end;

    procedure create_outgoing_addendum (
        i_fin_rec                in mup_api_type_pkg.t_fin_rec
    ) is
        l_add_rec                mup_api_type_pkg.t_add_rec;
        l_pds_tab                mup_api_type_pkg.t_pds_tab;
        l_sender                 com_api_type_pkg.t_full_desc;
        l_payer                  com_api_type_pkg.t_full_desc;
        l_name                   com_api_type_pkg.t_full_desc;
        l_stage                  varchar2(100);
    begin
        l_add_rec := null;

        l_stage := 'init';
        -- init
        l_add_rec.id := opr_api_create_pkg.get_id;
        l_add_rec.fin_id := i_fin_rec.id;
        l_add_rec.file_id := null;
        l_add_rec.is_incoming := i_fin_rec.is_incoming;

        l_stage := 'mti & de24 - de100';
        l_add_rec.mti := mup_api_const_pkg.MSG_TYPE_ADMINISTRATIVE;
        l_add_rec.de024 := mup_api_const_pkg.FUNC_CODE_ADDENDUM;
        l_add_rec.de032 := i_fin_rec.de032;
        l_add_rec.de033 := i_fin_rec.de033;
        l_add_rec.de063 := i_fin_rec.de063;
        l_add_rec.de071 := null;
        l_add_rec.de093 := i_fin_rec.de093;
        l_add_rec.de094 := i_fin_rec.de094;
        l_add_rec.de100 := i_fin_rec.de100;

        l_stage := 'put_message';
        put_message (
            i_add_rec    => l_add_rec
        );

        l_stage := 'save_pds';
        mup_api_pds_pkg.save_pds (
            i_msg_id     => l_add_rec.id
            , i_pds_tab  => l_pds_tab
        );

    exception
        when others then
            trc_log_pkg.debug(
                i_text  => 'Error generating IPM addendum on stage ' || l_stage || ': ' || sqlerrm
            );
            raise;
    end;

end;
/
 