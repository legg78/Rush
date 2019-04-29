create or replace package body jcb_api_add_pkg is

    procedure enum_messages_for_upload (
        i_fin_id                in            com_api_type_pkg.t_long_id
      , o_add_tab               in out nocopy jcb_api_type_pkg.t_add_tab
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
            , de071
            , de093
            , de094
            , de100
            , p3600
            , p3600_1
            , p3600_2
            , p3600_3
            , p3601
            , p3602
            , p3604
        bulk collect into
            o_add_tab
        from
            jcb_add
        where
            fin_id = i_fin_id
        order by
              id
        for update;
    end;

    function format_p3600(
        i_p3600_1      in jcb_api_type_pkg.t_p3600_1
        , i_p3600_2    in jcb_api_type_pkg.t_p3600_2
        , i_p3600_3    in jcb_api_type_pkg.t_p3600_3
    ) return jcb_api_type_pkg.t_pds_body is
    begin
        if i_p3600_1 is null or i_p3600_2 is null or i_p3600_3 is null then
            return null;
        else
            return jcb_utl_pkg.pad_number (to_char(i_p3600_1), 8, 8) 
                || jcb_utl_pkg.pad_number (i_p3600_2, 2, 2)
                || jcb_utl_pkg.pad_number (i_p3600_3, 3, 3);
        end if;                
    end;
    
    function pack_message (
        i_add_rec               in jcb_api_type_pkg.t_add_rec
      , i_file_id               in com_api_type_pkg.t_short_id
      , i_de071                 in jcb_api_type_pkg.t_de071
      , i_fin_de071             in jcb_api_type_pkg.t_de071
      , i_add_seqnum            in jcb_api_type_pkg.t_de071
      , i_with_rdw              in com_api_type_pkg.t_boolean     := null
    ) return blob is
        l_pds_tab               jcb_api_type_pkg.t_pds_tab;
        l_p3600                 jcb_api_type_pkg.t_p3600;
    begin
        trc_log_pkg.debug(
            i_text  => 'pack_message addendum start ' || i_fin_de071 || ', i_de071= ' || i_de071
        );
    
        jcb_api_pds_pkg.read_pds (
            i_msg_id        => i_add_rec.id
            , o_pds_tab     => l_pds_tab
        );
        
        l_p3600 := format_p3600(
            i_p3600_1 => i_fin_de071
          , i_p3600_2 => '01' --Travel General
          , i_p3600_3 => i_add_seqnum
        );
        
        jcb_api_pds_pkg.set_pds_body (
            io_pds_tab       => l_pds_tab
            , i_pds_tag      => 3600
            , i_pds_body     => l_p3600
        );

        return 
            jcb_api_msg_pkg.pack_message (
                i_mti            => i_add_rec.mti
                , i_de024        => i_add_rec.de024
                , i_de032        => i_add_rec.de032
                , i_de033        => i_add_rec.de033
                , i_de071        => i_de071
                , i_de094        => i_add_rec.de094
                , i_pds_tab      => l_pds_tab
                , i_with_rdw     => i_with_rdw
            );
            
    end;

    procedure mark_uploaded (
        i_rowid                 in com_api_type_pkg.t_rowid_tab
      , i_file_id               in com_api_type_pkg.t_number_tab
      , i_de071                 in com_api_type_pkg.t_number_tab
      , i_fin_de071             in com_api_type_pkg.t_number_tab
      , i_add_seqnum            in com_api_type_pkg.t_number_tab
    ) is
    begin
        forall i in 1 .. i_rowid.count
            update jcb_add
            set
                de071     = i_de071(i)
                , p3600_1 = i_fin_de071(i)
                , p3600_3 = i_add_seqnum(i)
                , file_id = i_file_id(i)
            where
                rowid = i_rowid(i);
    end;

    procedure put_message (
        i_add_rec               in jcb_api_type_pkg.t_add_rec
    ) is
    begin
        insert into jcb_add (
              id      
            , fin_id
            , file_id
            , is_incoming
            , mti        
            , de024      
            , de032      
            , de033      
            , de071      
            , de093      
            , de094      
            , de100      
            , p3600     
            , p3600_1     
            , p3600_2     
            , p3600_3     
            , p3601     
            , p3602     
            , p3604     
        ) values (
              i_add_rec.id      
            , i_add_rec.fin_id
            , i_add_rec.file_id
            , i_add_rec.is_incoming
            , i_add_rec.mti        
            , i_add_rec.de024      
            , i_add_rec.de032      
            , i_add_rec.de033      
            , i_add_rec.de071      
            , i_add_rec.de093      
            , i_add_rec.de094      
            , i_add_rec.de100      
            , i_add_rec.p3600     
            , i_add_rec.p3600_1     
            , i_add_rec.p3600_2     
            , i_add_rec.p3600_3     
            , i_add_rec.p3601     
            , i_add_rec.p3602     
            , i_add_rec.p3604     
        );
    end;

    procedure create_incoming_addendum (
        i_mes_rec                in jcb_api_type_pkg.t_mes_rec
        , i_file_id              in com_api_type_pkg.t_short_id
        , i_fin_id               in com_api_type_pkg.t_long_id
        , i_network_id           in com_api_type_pkg.t_tiny_id
    ) is
        l_add_rec                jcb_api_type_pkg.t_add_rec;
        l_pds_tab                jcb_api_type_pkg.t_pds_tab;
        
        l_stage                  varchar2(100);
    begin
        trc_log_pkg.debug (
            i_text          => 'create addendum start'
        );
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
        l_add_rec.de071 := i_mes_rec.de071;
        l_add_rec.de093 := i_mes_rec.de093;
        l_add_rec.de094 := i_mes_rec.de094;
        l_add_rec.de100 := i_mes_rec.de100;

        l_stage := 'extract_pds';
        jcb_api_pds_pkg.extract_pds (
            de048        => i_mes_rec.de048
            , de062      => i_mes_rec.de062
            , de123      => i_mes_rec.de123
            , de124      => i_mes_rec.de124
            , de125      => i_mes_rec.de125
            , de126      => i_mes_rec.de126
            , pds_tab    => l_pds_tab
        );

        l_stage := 'p3600';
        l_add_rec.p3600 := jcb_api_pds_pkg.get_pds_body (
            i_pds_tab          => l_pds_tab
            , i_pds_tag        => jcb_api_const_pkg.PDS_TAG_3600
        );
        trc_log_pkg.debug (
            i_text          => 'i_mes_rec.de048 ='|| i_mes_rec.de048 || ', l_pds_tab.count = ' || l_pds_tab.count || ', l_add_rec.p3600 = ' || l_add_rec.p3600
        );

        jcb_api_pds_pkg.parse_p3600 (
            i_p3600            => l_add_rec.p3600
            , o_p3600_1        => l_add_rec.p3600_1
            , o_p3600_2        => l_add_rec.p3600_2
            , o_p3600_3        => l_add_rec.p3600_3 
        );
        
        l_stage := 'p3601';
        l_add_rec.p3601 := jcb_api_pds_pkg.get_pds_body (
            i_pds_tab          => l_pds_tab
            , i_pds_tag        => jcb_api_const_pkg.PDS_TAG_3601
        );

        l_stage := 'p3602';
        l_add_rec.p3602 := jcb_api_pds_pkg.get_pds_body (
            i_pds_tab          => l_pds_tab
            , i_pds_tag        => jcb_api_const_pkg.PDS_TAG_3602
        );

        l_stage := 'p3604';
        l_add_rec.p3604 := jcb_api_pds_pkg.get_pds_body (
            i_pds_tab          => l_pds_tab
            , i_pds_tag        => jcb_api_const_pkg.PDS_TAG_3604
        );

        l_stage := 'put_message';
        put_message (
            i_add_rec    => l_add_rec
        );

        l_stage := 'save_pds';
        jcb_api_pds_pkg.save_pds (
            i_msg_id     => l_add_rec.id
            , i_pds_tab  => l_pds_tab
        );

        trc_log_pkg.debug (
            i_text          => 'create addendum end'
        );

    exception
        when others then
            trc_log_pkg.debug(
                i_text => 'Error generating JCB addendum on stage ' || l_stage || ': ' || sqlerrm
            );
            raise;
    end;

    procedure create_outgoing_addendum (
        i_fin_rec                in jcb_api_type_pkg.t_fin_rec
    ) is
        l_add_rec                jcb_api_type_pkg.t_add_rec;
        l_pds_tab                jcb_api_type_pkg.t_pds_tab;
        l_stage                  varchar2(100);
    begin
        l_add_rec := null;
        trc_log_pkg.debug(
            i_text  => 'create_outgoing_addendum start '
        );

        l_stage := 'init';
        -- init
        l_add_rec.id := opr_api_create_pkg.get_id;
        l_add_rec.fin_id := i_fin_rec.id;
        l_add_rec.file_id := null;
        l_add_rec.is_incoming := i_fin_rec.is_incoming;

        l_stage := 'mti & de24 - de100';
        l_add_rec.mti := jcb_api_const_pkg.MSG_TYPE_ADMINISTRATIVE;
        l_add_rec.de024 := jcb_api_const_pkg.FUNC_CODE_ADDENDUM;
        l_add_rec.de032 := i_fin_rec.de032;
        l_add_rec.de033 := i_fin_rec.de033;
        l_add_rec.de071 := null;
        l_add_rec.de093 := i_fin_rec.de093;
        l_add_rec.de094 := i_fin_rec.de094;
        l_add_rec.de100 := i_fin_rec.de100;
        l_add_rec.p3600_1 := null;
        l_add_rec.p3600_2 := '01';
        l_add_rec.p3600_3 := null;
        
        l_stage := 'put_message';
        put_message (
            i_add_rec    => l_add_rec
        );

        l_stage := 'set_pds';
        l_add_rec.p3600 := l_add_rec.p3600_1 || l_add_rec.p3600_2 || l_add_rec.p3600_3;
        
        jcb_api_pds_pkg.set_pds_body (
            io_pds_tab   => l_pds_tab
            , i_pds_tag  => jcb_api_const_pkg.PDS_TAG_3600
            , i_pds_body => l_add_rec.p3600
        );
        
        l_stage := 'save_pds';
        jcb_api_pds_pkg.save_pds (
            i_msg_id     => l_add_rec.id
            , i_pds_tab  => l_pds_tab
        );
        
        trc_log_pkg.debug(
            i_text  => 'create_outgoing_addendum end '
        );

    exception
        when others then
            trc_log_pkg.debug(
                i_text  => 'Error generating JCB addendum on stage ' || l_stage || ': ' || sqlerrm
            );
            raise;
    end;

end;
/
