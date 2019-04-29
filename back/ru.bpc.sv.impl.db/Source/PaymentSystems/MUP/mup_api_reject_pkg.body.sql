CREATE OR REPLACE package body mup_api_reject_pkg is

    g_process_run_date date := sysdate;

    type t_de_tab is table of com_api_type_pkg.t_text index by com_api_type_pkg.t_text;
    
    procedure put_message (
        i_reject_rec in mup_api_type_pkg.t_reject_rec
    ) is
    begin
        insert into mup_reject (
            id
            , network_id
            , inst_id
            , file_id
            , rejected_fin_id
            , rejected_file_id
            , mti
            , de024
            , de071
            , de072
            , de093
            , de094
            , de100
            , p0005
            , p0025
            , p0026
            , p0138
            , p0165
            , p0280
        ) values (
            i_reject_rec.id
            , i_reject_rec.network_id
            , i_reject_rec.inst_id
            , i_reject_rec.file_id
            , i_reject_rec.rejected_fin_id
            , i_reject_rec.rejected_file_id
            , i_reject_rec.mti
            , i_reject_rec.de024
            , i_reject_rec.de071
            , i_reject_rec.de072
            , i_reject_rec.de093
            , i_reject_rec.de094
            , i_reject_rec.de100
            , i_reject_rec.p0005
            , i_reject_rec.p0025
            , i_reject_rec.p0026
            , i_reject_rec.p0138
            , i_reject_rec.p0165
            , i_reject_rec.p0280
        );

    end;

    procedure put_reject_code (
        i_reject_data_id         in com_api_type_pkg.t_long_id
        , i_reject_code_tab      in mup_api_type_pkg.t_reject_code_tab
    ) is
    begin
        forall i in 1 .. i_reject_code_tab.count
            insert into mup_reject_code (
                id
                , reject_data_id
                , de_number
                , severity_code
                , message_code
                , subfield_id
                , is_from_orig_msg
            ) values (
                mup_reject_code_seq.nextval
                , i_reject_data_id
                , i_reject_code_tab(i).de_number
                , i_reject_code_tab(i).severity_code
                , i_reject_code_tab(i).message_code
                , i_reject_code_tab(i).subfield_id
                , 1
            );
    end;
    
    procedure put_reject_code (
        i_reject_data_id in com_api_type_pkg.t_long_id
        , i_de_number    in com_api_type_pkg.t_text
        , i_pds_number   in com_api_type_pkg.t_text
        , i_message_code in com_api_type_pkg.t_text
    ) is
    begin
        insert into mup_reject_code (
            id
            , reject_data_id
            , de_number
            , severity_code
            , message_code
            , subfield_id
            , is_from_orig_msg
        )
        values (
            mup_reject_code_seq.nextval
            , i_reject_data_id
            , i_de_number
            , mup_api_const_pkg.C_REJECT_CODE_INVALID_FORMAT
            , i_message_code
            , i_pds_number
            , 0
        );
    end put_reject_code;

    -- save operation rejected data in format 'Operation reject data'
    procedure put_reject_data (
        i_reject_rec        in mup_api_type_pkg.t_reject_rec
        , o_reject_data_id  out com_api_type_pkg.t_long_id
    ) is
        l_msg mup_reject_data%ROWTYPE;
    begin
        begin
          select a.oper_type
               , b.card_number
               , m.de031
            into l_msg.operation_type
               , l_msg.card_number
               , l_msg.arn
            from opr_operation a
                 , opr_card b
                 , mup_fin m
           where a.id = b.oper_id
             and a.id = m.id
             and a.id = i_reject_rec.rejected_fin_id; --mup_fin.id = opr_operation.id
        exception
            when no_data_found then
                null;
        end;
        --
        l_msg.reject_id           := i_reject_rec.id;
        l_msg.original_id         := i_reject_rec.rejected_fin_id;
        --“3”(REJECT RECORDS INFORMED BY NATIONAL/INTERNATIONAL SCHEMES
        --l_msg.reject_type         := mup_api_const_pkg.REJECT_TYPE_REGULATORS_SCHEMES; -- RJTP0003
        l_msg.process_date        := g_process_run_date;
        l_msg.originator_network  := i_reject_rec.de094; -- Transaction Originator Institution ID Code
        l_msg.destination_network := i_reject_rec.de093; -- Transaction Destination Institution ID Code
        l_msg.scheme              := mup_api_const_pkg.C_DEF_SCHEME;
        --l_msg.reject_code         := mup_api_const_pkg.REJECT_CODE_INVALID_FORMAT; -- RJCD0001
        l_msg.assigned            := null; --assigned user
        --l_msg.resolution_mode     := mup_api_const_pkg.REJECT_RESOLUT_MODE_FORWARD; --'RJMD001';  -- FORWARD
        l_msg.resolution_date     := null; -- just created, not resolved
        --l_msg.status              := mup_api_const_pkg.REJECT_STATUS_OPENED; --'RJST0001'; -- Opened
        --
        insert into mup_reject_data (
            id
            , reject_id
            , original_id
            , reject_type
            , process_date
            , originator_network
            , destination_network
            , scheme
            , reject_code
            , operation_type
            , assigned
            , card_number
            , arn
            , resolution_mode
            , resolution_date
            , status
        )
        values (
            mup_reject_data_seq.nextval
            , l_msg.reject_id
            , l_msg.original_id
            , l_msg.reject_type
            , l_msg.process_date
            , l_msg.originator_network
            , l_msg.destination_network
            , l_msg.scheme
            , l_msg.reject_code
            , l_msg.operation_type
            , l_msg.assigned
            , l_msg.card_number
            , l_msg.arn
            , l_msg.resolution_mode
            , l_msg.resolution_date
            , l_msg.status
        )
        returning
            id
        into
            o_reject_data_id;
    end put_reject_data;

    procedure find_original_file (
        i_p0105                  in mup_api_type_pkg.t_p0105
        , i_network_id           in com_api_type_pkg.t_tiny_id
        , o_file_id              out com_api_type_pkg.t_short_id
        , i_lock                 in com_api_type_pkg.t_boolean := com_api_type_pkg.TRUE
    ) is
    begin
        if i_lock = com_api_type_pkg.TRUE then
            select
                id
            into
                o_file_id
            from
                mup_file
            where
                p0105 = i_p0105
                and network_id = i_network_id
            for update;
        else
            select
                id
            into
                o_file_id
            from
                mup_file
            where
                p0105 = i_p0105
                and network_id = i_network_id;
        end if;
    exception
        when no_data_found then
            o_file_id := null;
    end;

    procedure find_original_message (
        i_file_id                in com_api_type_pkg.t_short_id
        , i_de071                in mup_api_type_pkg.t_de071
        , i_network_id           in com_api_type_pkg.t_tiny_id
        , o_fin_id               out com_api_type_pkg.t_long_id
    ) is
    begin
        select
            id
        into
            o_fin_id
        from
            mup_fin
        where
            file_id = i_file_id
            and network_id = i_network_id
            and de071 = i_de071
        for update;
    exception
        when no_data_found then
            o_fin_id := null;
    end;

    procedure mark_file_rejected (
        i_file_id                in com_api_type_pkg.t_short_id
        , i_reject_id            in com_api_type_pkg.t_long_id
    ) is
    begin
        update
            mup_fin
        set
            is_rejected = com_api_type_pkg.TRUE
            , reject_id = i_reject_id
        where
            file_id = i_file_id;

        update
            mup_file
        set
            is_rejected = com_api_type_pkg.TRUE
            , reject_id = i_reject_id
        where
            id = i_file_id;
    end;

    procedure mark_msg_rejected (
        i_id                     in com_api_type_pkg.t_long_id
        , i_reject_id            in com_api_type_pkg.t_long_id
    ) is
    begin
        update
            mup_fin
        set
            is_rejected = com_api_type_pkg.TRUE
            , reject_id = i_reject_id
        where
            id = i_id;
    end;

    procedure set_message (
        i_mes_rec                in mup_api_type_pkg.t_mes_rec
        , i_file_id              in com_api_type_pkg.t_short_id
        , i_network_id           in com_api_type_pkg.t_tiny_id
        , i_host_id              in com_api_type_pkg.t_tiny_id
        , i_standard_id          in com_api_type_pkg.t_tiny_id
        , io_reject_rec          in out nocopy mup_api_type_pkg.t_reject_rec
        , io_pds_tab             in out nocopy mup_api_type_pkg.t_pds_tab
    ) is
        l_stage                 varchar2(100);
    begin
        io_reject_rec := null;

        l_stage := 'init';
        -- init
        io_reject_rec.id := opr_api_create_pkg.get_id;
        io_reject_rec.file_id := i_file_id;
        io_reject_rec.network_id := i_network_id;

        l_stage := 'mti & de24 - de100';
        io_reject_rec.mti := i_mes_rec.mti;
        io_reject_rec.de024 := i_mes_rec.de024;
        io_reject_rec.de071 := i_mes_rec.de071;
        io_reject_rec.de072 := i_mes_rec.de072;
        io_reject_rec.de093 := i_mes_rec.de093;
        io_reject_rec.de094 := i_mes_rec.de094;
        io_reject_rec.de100 := i_mes_rec.de100;

        l_stage := 'get_inst_id';
        -- determine internal institution number
        io_reject_rec.inst_id := cmn_api_standard_pkg.find_value_owner (
            i_standard_id    => i_standard_id
            , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
            , i_object_id    => i_host_id
            , i_param_name   => mup_api_const_pkg.CMID
            , i_value_char   => io_reject_rec.de093
        );

        if io_reject_rec.inst_id is null then
            com_api_error_pkg.raise_error(
                i_error         => 'MUP_CMID_NOT_REGISTRED'
                , i_env_param1  => io_reject_rec.de093
                , i_env_param2  => i_network_id
            );
        end if;

        l_stage := 'extract_pds';
        mup_api_pds_pkg.extract_pds (
            de048       => i_mes_rec.de048
            , de062     => i_mes_rec.de062
            , de123     => i_mes_rec.de123
            , de124     => i_mes_rec.de124
            , de125     => i_mes_rec.de125
            , pds_tab   => io_pds_tab
        );
        l_stage := 'p0005';
        io_reject_rec.p0005 := mup_api_pds_pkg.get_pds_body (
            i_pds_tab         => io_pds_tab
            , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0005
        );
        l_stage := 'p0025';
        io_reject_rec.p0025 := mup_api_pds_pkg.get_pds_body (
            i_pds_tab         => io_pds_tab
            , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0025
        );
        l_stage := 'p0026';
        io_reject_rec.p0026 := mup_api_pds_pkg.get_pds_body (
            i_pds_tab         => io_pds_tab
            , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0026
        );
        l_stage := 'p0138';
        io_reject_rec.p0138 := mup_api_pds_pkg.get_pds_body (
            i_pds_tab         => io_pds_tab
            , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0138
        );
        l_stage := 'p0280';
        io_reject_rec.p0280 := mup_api_pds_pkg.get_pds_body (
            i_pds_tab         => io_pds_tab
            , i_pds_tag       => mup_api_const_pkg.PDS_TAG_0280
        );

    exception
        when others then
            trc_log_pkg.error(
                i_text          => 'Error generating IPM reject on stage ' || l_stage || ': ' || sqlerrm
            );

            raise;
    end;

    procedure create_incoming_file_reject (
        i_mes_rec                in mup_api_type_pkg.t_mes_rec
        , i_file_id              in com_api_type_pkg.t_short_id
        , i_network_id           in com_api_type_pkg.t_tiny_id
        , i_host_id              in com_api_type_pkg.t_tiny_id
        , i_standard_id          in com_api_type_pkg.t_tiny_id
    ) is
        l_reject_rec            mup_api_type_pkg.t_reject_rec;
        l_reject_code_tab       mup_api_type_pkg.t_reject_code_tab;
        l_rejected_msg          mup_reject_data%rowtype := NULL;
        l_reject_data_id        com_api_type_pkg.t_long_id;
        
        l_rejected_file_id      com_api_type_pkg.t_short_id;
        l_pds_tab               mup_api_type_pkg.t_pds_tab;

        l_stage                 varchar2(100);
    begin
        trc_log_pkg.debug (
            i_text      => 'Processing incoming file reject'
        );
        -- set message
        set_message (
            i_mes_rec        => i_mes_rec
            , i_file_id      => i_file_id
            , i_network_id   => i_network_id
            , i_host_id      => i_host_id
            , i_standard_id  => i_standard_id
            , io_reject_rec  => l_reject_rec
            , io_pds_tab     => l_pds_tab
        );

        if l_reject_rec.p0280 is null then
            trc_log_pkg.debug (
                i_text         => 'File reject received without original file specified. id[#1]'
                , i_env_param1 => l_reject_rec.id
            );
        else
            find_original_file (
                i_p0105         => l_reject_rec.p0280
                , i_network_id  => i_network_id
                , o_file_id     => l_rejected_file_id
            );
            if l_rejected_file_id is null then
                trc_log_pkg.debug (
                    i_text         => 'File reject received, but original file not found. id[#1] p0280[#2]'
                    , i_env_param1 => l_reject_rec.id
                    , i_env_param2 => l_reject_rec.p0280
                );
            else
                trc_log_pkg.debug (
                    i_text         => 'Original file found file_id[#1]'
                    , i_env_param1 => l_rejected_file_id
                );

                mark_file_rejected (
                    i_file_id      => l_rejected_file_id
                    , i_reject_id  => l_reject_rec.id
                );
                l_reject_rec.rejected_file_id := l_rejected_file_id;

                trc_log_pkg.debug (
                    i_text      => 'Message marked as rejected. reject.id[#1]'
                    , i_env_param1 => l_reject_rec.id
                );
            end if;
        end if;

        l_stage := 'parse_p0005';
        mup_api_pds_pkg.parse_p0005 (
            i_p0005              => l_reject_rec.p0005
            , o_reject_code_tab  => l_reject_code_tab
        );

        l_stage := 'put_message';
        put_message (
            i_reject_rec   => l_reject_rec
        );

        l_stage := 'put_reject_data';
        put_reject_data(
            i_reject_rec       => l_reject_rec
            , o_reject_data_id => l_reject_data_id
        );

        l_stage := 'put_reject_code';
        put_reject_code (
            i_reject_data_id     => l_reject_data_id
            , i_reject_code_tab  => l_reject_code_tab
        );
            
        l_stage := 'save_pds';
        mup_api_pds_pkg.save_pds (
            i_msg_id     => l_reject_rec.id
            , i_pds_tab  => l_pds_tab
        );

        trc_log_pkg.debug (
            i_text         => 'Incoming file reject processed. Assigned id[#1]'
            , i_env_param1 => l_reject_rec.id
        );
    exception
        when others then
            trc_log_pkg.error(
                i_text          => 'Error processing incoming file reject on stage ' || l_stage || ': ' || sqlerrm
            );

            raise;
    end;

    procedure create_incoming_msg_reject (
        i_mes_rec                in mup_api_type_pkg.t_mes_rec
        , i_next_mes_rec         in mup_api_type_pkg.t_mes_rec
        , i_file_id              in com_api_type_pkg.t_short_id
        , i_network_id           in com_api_type_pkg.t_tiny_id
        , i_host_id              in com_api_type_pkg.t_tiny_id
        , i_standard_id          in com_api_type_pkg.t_tiny_id
        , o_rejected_msg_found   out com_api_type_pkg.t_boolean
    ) is
        l_reject_rec            mup_api_type_pkg.t_reject_rec;
        l_reject_code_tab       mup_api_type_pkg.t_reject_code_tab;
        l_reject_data_id        com_api_type_pkg.t_long_id;
        
        l_rejected_file_id      com_api_type_pkg.t_short_id;
        l_rejected_fin_id       com_api_type_pkg.t_long_id;
        l_pds_tab               mup_api_type_pkg.t_pds_tab;
        l_stage                 varchar2(100);
        l_validation_result     com_api_type_pkg.t_boolean default com_api_const_pkg.true;
    begin
        l_validation_result := com_api_const_pkg.true;
        trc_log_pkg.debug (
            i_text      => 'Processing incoming message reject'
        );

        o_rejected_msg_found := com_api_type_pkg.FALSE;

        -- set message
        set_message (
            i_mes_rec        => i_mes_rec
            , i_file_id      => i_file_id
            , i_network_id   => i_network_id
            , i_host_id      => i_host_id
            , i_standard_id  => i_standard_id
            , io_reject_rec  => l_reject_rec
            , io_pds_tab     => l_pds_tab
        );

        if l_reject_rec.p0280 is null then
            trc_log_pkg.debug (
                i_text      => 'Message reject received without original file specified. id[#1]'
                , i_env_param1 => l_reject_rec.id
            );
        else
            find_original_file (
                i_p0105         => l_reject_rec.p0280
                , i_network_id  => i_network_id
                , o_file_id     => l_rejected_file_id
                , i_lock        => com_api_type_pkg.FALSE
            );
            if l_rejected_file_id is null then
                trc_log_pkg.debug (
                    i_text      => 'Message reject received, but original file not found. id[#1] p0280[#2]'
                    , i_env_param1 => l_reject_rec.id
                    , i_env_param2 => l_reject_rec.p0280
                );
            else
                trc_log_pkg.debug (
                    i_text      => 'Original file found file_id[#1]'
                    , i_env_param1 => l_rejected_file_id
                );
            end if;
        end if;

        if l_reject_rec.p0138 is null then
            trc_log_pkg.debug (
                i_text         => 'Message reject received without original message number specified. id[#1]'
                , i_env_param1 => l_reject_rec.id
            );
        end if;

        if l_rejected_file_id is not null and l_reject_rec.p0138 is not null then
            find_original_message (
                i_file_id       => l_rejected_file_id
                , i_de071       => l_reject_rec.p0138
                , i_network_id  => i_network_id
                , o_fin_id      => l_rejected_fin_id
            );
            if l_rejected_fin_id is null then
                trc_log_pkg.debug (
                    i_text         => 'Message reject received, but original message not found. file_id[#1] p0138[#2]'
                    , i_env_param1 => l_rejected_file_id
                    , i_env_param2 => l_reject_rec.p0138
                );
            else
                trc_log_pkg.debug (
                    i_text         => 'Original message found. id[#1]'
                    , i_env_param1 => l_rejected_fin_id
                );

                mark_msg_rejected (
                    i_id           => l_rejected_fin_id
                    , i_reject_id  => l_reject_rec.id
                );
                l_reject_rec.rejected_fin_id := l_rejected_fin_id;

                trc_log_pkg.debug (
                    i_text         => 'Message marked as rejected. id[#1]'
                    , i_env_param1 => l_reject_rec.id
                );
            end if;
        end if;

        if l_reject_rec.de093 = i_next_mes_rec.de094 then
            trc_log_pkg.debug (
                i_text         => 'Following message identified as returned rejected. mti[#1] de024[#2] de031[#3] de094[#4] de071[#5]'
                , i_env_param1 => i_next_mes_rec.mti
                , i_env_param2 => i_next_mes_rec.de024
                , i_env_param3 => i_next_mes_rec.de031
                , i_env_param4 => i_next_mes_rec.de094
                , i_env_param5 => i_next_mes_rec.de071

            );
            o_rejected_msg_found := com_api_type_pkg.TRUE;
        else
            trc_log_pkg.debug (
                i_text         => 'Following message not identified as returned rejected. mti[#1] de024[#2] de031[#3] de094[#4] de071[#5]'
                , i_env_param1 => i_next_mes_rec.mti
                , i_env_param2 => i_next_mes_rec.de024
                , i_env_param3 => i_next_mes_rec.de031
                , i_env_param4 => i_next_mes_rec.de094
                , i_env_param5 => i_next_mes_rec.de071
            );
        end if;

        l_stage := 'parse_p0005';
        mup_api_pds_pkg.parse_p0005 (
            i_p0005              => l_reject_rec.p0005
            , o_reject_code_tab  => l_reject_code_tab
        );

        l_stage := 'put_message';
        put_message (
            i_reject_rec   => l_reject_rec
        );

        l_stage := 'save_pds';
        mup_api_pds_pkg.save_pds (
            i_msg_id     => l_reject_rec.id
            , i_pds_tab  => l_pds_tab
        );

        l_stage := 'put_reject_data';
        put_reject_data(
            i_reject_rec       => l_reject_rec
            , o_reject_data_id => l_reject_data_id
        );

        l_stage := 'put_reject_code';
        put_reject_code (
            i_reject_data_id     => l_reject_data_id
            , i_reject_code_tab  => l_reject_code_tab
        );

        trc_log_pkg.debug (
            i_text         => 'Incoming message reject processed. Assigned id[#1]'
            , i_env_param1 => l_reject_rec.id
        );
    exception
        when others then
            trc_log_pkg.error(
                i_text          => 'Error processing incoming message reject on stage ' || l_stage || ': ' || sqlerrm
            );
            raise;
    end;

end;
/
