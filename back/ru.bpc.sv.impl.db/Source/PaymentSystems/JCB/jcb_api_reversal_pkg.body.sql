create or replace package body jcb_api_reversal_pkg is

    procedure gen_common_reversal (
        o_fin_id                  out com_api_type_pkg.t_long_id
        , i_de004                 in jcb_api_type_pkg.t_de004
        , i_de049                 in jcb_api_type_pkg.t_de049
        , i_original_fin_id       in com_api_type_pkg.t_long_id
    ) is
        l_fin_rec                 jcb_api_type_pkg.t_fin_rec;
        l_stage                   varchar2(100);
        l_standard_id             com_api_type_pkg.t_tiny_id;
        l_host_id                 com_api_type_pkg.t_tiny_id;
        l_pds_tab                 jcb_api_type_pkg.t_pds_tab;
        l_count                   com_api_type_pkg.t_boolean;
    begin
        trc_log_pkg.debug (
            i_text         => 'Generating reversal request'
        );
        
        l_stage := 'load original fin';
        jcb_api_fin_pkg.get_fin (
            i_id         => i_original_fin_id
            , o_fin_rec  => l_fin_rec
        );
        
        if l_fin_rec.is_reversal = com_api_type_pkg.FALSE
           and l_fin_rec.is_incoming = com_api_type_pkg.FALSE
        then
            if l_fin_rec.mti = jcb_api_const_pkg.MSG_TYPE_PRESENTMENT
                and l_fin_rec.de024 = jcb_api_const_pkg.FUNC_CODE_FIRST_PRES
            then
                l_stage := 'init first presentment';
                l_fin_rec.is_reversal := com_api_type_pkg.TRUE;
                l_fin_rec.p3007_1 := jcb_api_const_pkg.REVERSAL_PDS_REVERSAL;
                                
                l_stage := 'get_message_impact';
                l_fin_rec.impact := jcb_utl_pkg.get_message_impact (
                    i_mti           => l_fin_rec.mti
                    , i_de024       => l_fin_rec.de024
                    , i_de003_1     => l_fin_rec.de003_1
                    , i_is_reversal => l_fin_rec.is_reversal
                    , i_is_incoming => l_fin_rec.is_incoming
                );
                
                l_stage := 'add_curr_exp';
                jcb_utl_pkg.add_curr_exp (
                    io_p3002       => l_fin_rec.p3002
                    , i_curr_code  => null
                );

                l_stage := 'de004';
                if nvl(i_de004, 0) > nvl(l_fin_rec.de004, 0) then
                    com_api_error_pkg.raise_error (
                        i_error         => 'REVERSAL_AMOUNT_GREATER_ORIGINAL_AMOUNT'
                        , i_env_param1  => nvl(l_fin_rec.de004, 0)
                        , i_env_param2  => nvl(i_de004, 0)
                    );
                end if;

                l_fin_rec.de004 := i_de004;
                l_fin_rec.de049 := i_de049;

                l_stage := 'add_curr_exp';
                jcb_utl_pkg.add_curr_exp (
                    io_p3002       => l_fin_rec.p3002
                    , i_curr_code  => l_fin_rec.de049
                );
                
                jcb_api_dispute_pkg.sync_dispute_id (
                    io_fin_rec      => l_fin_rec
                    , o_dispute_id  => l_fin_rec.dispute_id
                    , o_dispute_rn  => l_fin_rec.dispute_rn
                );
                
                select
                    case when count(id) > 0 then 1 else 0 end
                into
                    l_count
                from
                    jcb_fin_message
                where
                    mti = l_fin_rec.mti
                    and de024 = l_fin_rec.de024
                    and is_reversal = com_api_type_pkg.TRUE
                    and dispute_id = l_fin_rec.dispute_id;

                if l_count = com_api_type_pkg.TRUE then
                    com_api_error_pkg.raise_error (
                        i_error        => 'DISPUTE_DOUBLE_REVERSAL'
                        , i_env_param1 => l_fin_rec.dispute_id
                    );
                end if;

                l_stage := 'update status';
                update
                    jcb_fin_message
                set
                    status = decode (
                        l_fin_rec.status
                        , net_api_const_pkg.CLEARING_MSG_STATUS_READY
                        , net_api_const_pkg.CLEARING_MSG_STATUS_PENDING
                        , status
                    )
                where
                    rowid = l_fin_rec.row_id
                returning
                    case when l_fin_rec.status in (
                        net_api_const_pkg.CLEARING_MSG_STATUS_READY
                        , net_api_const_pkg.CLEARING_MSG_STATUS_PENDING
                    ) then
                        net_api_const_pkg.CLEARING_MSG_STATUS_PENDING
                    else
                        net_api_const_pkg.CLEARING_MSG_STATUS_READY
                    end
                into
                    l_fin_rec.status;
                
                l_stage := 'init';
                l_fin_rec.is_rejected := com_api_type_pkg.FALSE;
                l_fin_rec.file_id := null;
                
                o_fin_id := opr_api_create_pkg.get_id;
                l_fin_rec.id := o_fin_id;
            
                l_stage := 'put message';
                jcb_api_fin_pkg.put_message (
                    i_fin_rec   => l_fin_rec
                );
                
                l_stage := 'create_operation';
                l_host_id := net_api_network_pkg.get_default_host (
                    i_network_id  => l_fin_rec.network_id
                );
                l_standard_id := net_api_network_pkg.get_offline_standard (
                    i_host_id       => l_host_id
                );
                
                jcb_api_fin_pkg.create_operation (
                     i_fin_rec          => l_fin_rec
                    , i_standard_id     => l_standard_id
                );

                l_stage := 'done';
                
            else
                l_stage := 'read_pds';
                jcb_api_pds_pkg.read_pds (
                    i_msg_id     => i_original_fin_id
                    , o_pds_tab  => l_pds_tab
                );
                 
                l_fin_rec.is_reversal := com_api_type_pkg.TRUE;
                l_fin_rec.p3007_1 := jcb_api_const_pkg.REVERSAL_PDS_REVERSAL;
                                
                l_stage := 'get_message_impact';
                l_fin_rec.impact := jcb_utl_pkg.get_message_impact (
                    i_mti           => l_fin_rec.mti
                    , i_de024       => l_fin_rec.de024
                    , i_de003_1     => l_fin_rec.de003_1
                    , i_is_reversal => l_fin_rec.is_reversal
                    , i_is_incoming => l_fin_rec.is_incoming
                );
                
                jcb_api_dispute_pkg.sync_dispute_id (
                    io_fin_rec      => l_fin_rec
                    , o_dispute_id  => l_fin_rec.dispute_id
                    , o_dispute_rn  => l_fin_rec.dispute_rn
                );
                select
                    case when count(id) > 0 then 1 else 0 end
                into
                    l_count
                from
                    jcb_fin_message
                where
                    mti = l_fin_rec.mti
                    and de024 = l_fin_rec.de024
                    and is_reversal = com_api_type_pkg.TRUE
                    and dispute_id = l_fin_rec.dispute_id;

                if l_count = com_api_type_pkg.TRUE then
                    com_api_error_pkg.raise_error (
                        i_error        => 'DISPUTE_DOUBLE_REVERSAL'
                        , i_env_param1 => l_fin_rec.dispute_id
                    );
                end if;
                
                l_stage := 'update status';
                update
                    jcb_fin_message
                set
                    status = decode (
                        l_fin_rec.status
                        , net_api_const_pkg.CLEARING_MSG_STATUS_READY
                        , net_api_const_pkg.CLEARING_MSG_STATUS_PENDING
                        , status
                    )
                where
                    rowid = l_fin_rec.row_id
                returning
                    case when l_fin_rec.status in (
                        net_api_const_pkg.CLEARING_MSG_STATUS_READY
                        , net_api_const_pkg.CLEARING_MSG_STATUS_PENDING
                    ) then
                        net_api_const_pkg.CLEARING_MSG_STATUS_PENDING
                    else
                        net_api_const_pkg.CLEARING_MSG_STATUS_READY
                    end
                into
                    l_fin_rec.status;
                
                l_stage := 'init';
                l_fin_rec.is_rejected := com_api_type_pkg.FALSE;
                l_fin_rec.file_id := null;
                
                o_fin_id := opr_api_create_pkg.get_id;
                l_fin_rec.id := o_fin_id;
            
                l_stage := 'put message';
                jcb_api_fin_pkg.put_message (
                    i_fin_rec   => l_fin_rec
                );
                
                l_stage := 'save_pds';
                jcb_api_pds_pkg.save_pds (
                    i_msg_id     => l_fin_rec.id
                    , i_pds_tab  => l_pds_tab
                );
                
                l_stage := 'create_operation';
                l_host_id := net_api_network_pkg.get_default_host (
                    i_network_id  => l_fin_rec.network_id
                );
                l_standard_id := net_api_network_pkg.get_offline_standard (
                    i_host_id       => l_host_id
                );
                
                jcb_api_fin_pkg.create_operation (
                     i_fin_rec          => l_fin_rec
                    , i_standard_id     => l_standard_id
                );

                l_stage := 'done';
            end if;
        end if;
        
        trc_log_pkg.debug (
            i_text         => 'Generating reversal request. Assigned id[#1]'
            , i_env_param1 => l_fin_rec.id
        );
    exception
        when others then
            trc_log_pkg.error(
                i_text          => 'Error generating reversal request on stage ' || l_stage || ': ' || sqlerrm
            );

            raise;
    end;

end;
/
