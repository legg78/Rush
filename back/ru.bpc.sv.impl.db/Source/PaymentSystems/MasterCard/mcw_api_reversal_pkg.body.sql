create or replace package body mcw_api_reversal_pkg is

    procedure gen_common_reversal (
        o_fin_id              out com_api_type_pkg.t_long_id
      , i_de004            in     mcw_api_type_pkg.t_de004    default null
      , i_de049            in     mcw_api_type_pkg.t_de049    default null
      , i_original_fin_id  in     com_api_type_pkg.t_long_id
      , i_ext_claim_id     in     mcw_api_type_pkg.t_ext_claim_id   default null
      , i_ext_message_id   in     mcw_api_type_pkg.t_ext_message_id default null
    ) is
        l_fin_rec                 mcw_api_type_pkg.t_fin_rec;
        l_stage                   varchar2(100);
        l_standard_id             com_api_type_pkg.t_tiny_id;
        l_host_id                 com_api_type_pkg.t_tiny_id;
        l_pds_tab                 mcw_api_type_pkg.t_pds_tab;
        l_count                   com_api_type_pkg.t_boolean;
    begin
        trc_log_pkg.debug (
            i_text         => 'Generating/updating reversal request'
        );
        
        l_stage := 'load original fin';
        mcw_api_fin_pkg.get_fin (
            i_id         => i_original_fin_id
            , o_fin_rec  => l_fin_rec
        );
        
        if l_fin_rec.is_reversal     = com_api_type_pkg.FALSE
           and l_fin_rec.is_incoming = com_api_type_pkg.FALSE
        then
            if not (l_fin_rec.mti       = mcw_api_const_pkg.MSG_TYPE_PRESENTMENT
                    and l_fin_rec.de024 = mcw_api_const_pkg.FUNC_CODE_FIRST_PRES)
            then
                mcw_api_pds_pkg.read_pds (
                    i_msg_id     => i_original_fin_id
                    , o_pds_tab  => l_pds_tab
                );
            end if;

            l_stage := 'init first presentment';
            l_fin_rec.is_reversal := com_api_type_pkg.TRUE;
            l_fin_rec.p0025_1 := mcw_api_const_pkg.REVERSAL_PDS_REVERSAL;

            l_stage := 'get_processing_date';
            mcw_api_fin_pkg.get_processing_date (
                i_id                 => l_fin_rec.id
                , i_is_fpd_matched   => l_fin_rec.is_fpd_matched
                , i_is_fsum_matched  => l_fin_rec.is_fsum_matched
                , i_file_id          => l_fin_rec.file_id
                , o_p0025_2          => l_fin_rec.p0025_2
            );
                
            l_stage := 'get_message_impact';
            l_fin_rec.impact := mcw_utl_pkg.get_message_impact (
                i_mti           => l_fin_rec.mti
                , i_de024       => l_fin_rec.de024
                , i_de003_1     => l_fin_rec.de003_1
                , i_is_reversal => l_fin_rec.is_reversal
                , i_is_incoming => l_fin_rec.is_incoming
            );
                
            if l_fin_rec.mti = mcw_api_const_pkg.MSG_TYPE_PRESENTMENT
                and l_fin_rec.de024 = mcw_api_const_pkg.FUNC_CODE_FIRST_PRES
            then
                l_stage := 'de030_1-p0149_2';
                if nvl(i_de004, 0) > nvl(l_fin_rec.de004, 0) then
                    com_api_error_pkg.raise_error (
                        i_error         => 'REVERSAL_AMOUNT_GREATER_ORIGINAL_AMOUNT'
                        , i_env_param1  => nvl(l_fin_rec.de004, 0)
                        , i_env_param2  => nvl(i_de004, 0)
                    );
                end if;
                l_fin_rec.de004   := nvl(i_de004, l_fin_rec.de004);
                l_fin_rec.de049   := nvl(i_de049, l_fin_rec.de049);
                l_fin_rec.de030_1 := l_fin_rec.de004;
                l_fin_rec.p0149_1 := l_fin_rec.de049;
                l_fin_rec.de030_2 := 0;
                l_fin_rec.p0149_2 := '000';

                l_stage := 'add_curr_exp';
                mcw_utl_pkg.add_curr_exp (
                    io_p0148       => l_fin_rec.p0148
                    , i_curr_code  => l_fin_rec.p0149_1
                );

                l_stage := 'add_curr_exp';
                mcw_utl_pkg.add_curr_exp (
                    io_p0148       => l_fin_rec.p0148
                    , i_curr_code  => l_fin_rec.de049
                );
            end if;

            mcw_api_dispute_pkg.sync_dispute_id (
                io_fin_rec      => l_fin_rec
                , o_dispute_id  => l_fin_rec.dispute_id
                , o_dispute_rn  => l_fin_rec.dispute_rn
            );

            select case when count(id) > 0 then 1 else 0 end
              into l_count
              from mcw_fin
             where mti         = l_fin_rec.mti
               and de024       = l_fin_rec.de024
               and is_reversal = com_api_type_pkg.TRUE
               and dispute_id  = l_fin_rec.dispute_id;

            if l_count = com_api_type_pkg.TRUE then
                com_api_error_pkg.raise_error (
                    i_error        => 'DISPUTE_DOUBLE_REVERSAL'
                    , i_env_param1 => l_fin_rec.dispute_id
                );
            end if;

            l_stage := 'update status';
            update mcw_fin
               set status = decode(
                                l_fin_rec.status
                              , net_api_const_pkg.CLEARING_MSG_STATUS_READY
                              , net_api_const_pkg.CLEARING_MSG_STATUS_PENDING
                              , status
                            )
             where rowid = l_fin_rec.row_id
             returning case
                           when l_fin_rec.status in (net_api_const_pkg.CLEARING_MSG_STATUS_READY
                                                   , net_api_const_pkg.CLEARING_MSG_STATUS_PENDING)
                           then net_api_const_pkg.CLEARING_MSG_STATUS_PENDING
                           else net_api_const_pkg.CLEARING_MSG_STATUS_READY
                       end
                  into l_fin_rec.status;

            l_stage := 'init';
            l_fin_rec.is_rejected     := com_api_type_pkg.FALSE;
            l_fin_rec.is_fpd_matched  := com_api_type_pkg.FALSE;
            l_fin_rec.is_fsum_matched := com_api_type_pkg.FALSE;
            l_fin_rec.file_id         := null;

            o_fin_id        := opr_api_create_pkg.get_id;
            l_fin_rec.id    := o_fin_id;
            l_fin_rec.p0375 := l_fin_rec.id;

            l_fin_rec.ext_claim_id    := i_ext_claim_id;
            l_fin_rec.ext_message_id  := i_ext_message_id;
            l_fin_rec.status := net_api_const_pkg.CLEARING_MSG_STATUS_READY;
            
            if not (l_fin_rec.mti = mcw_api_const_pkg.MSG_TYPE_PRESENTMENT
                and l_fin_rec.de024 = mcw_api_const_pkg.FUNC_CODE_FIRST_PRES
                    )
               and csm_api_utl_pkg.is_mcom_enabled(
                       i_network_id  => l_fin_rec.network_id
                     , i_inst_id     => l_fin_rec.inst_id
                     , i_host_id     => l_host_id
                     , i_standard_id => l_fin_rec.network_id
                   ) = com_api_type_pkg.TRUE
            then
                l_fin_rec.status := mup_api_const_pkg.MSG_STATUS_DO_NOT_UNLOAD;
            else
                l_fin_rec.status := net_api_const_pkg.CLEARING_MSG_STATUS_READY;
            end if;

            l_stage := 'put message';
            mcw_api_fin_pkg.put_message (
                i_fin_rec   => l_fin_rec
            );
                
            if l_fin_rec.mti = mcw_api_const_pkg.MSG_TYPE_PRESENTMENT
                and l_fin_rec.de024 = mcw_api_const_pkg.FUNC_CODE_FIRST_PRES
            then
                l_stage := 'save_pds';
                mcw_api_pds_pkg.save_pds(
                    i_msg_id   => l_fin_rec.id
                  , i_pds_tab  => l_pds_tab
                );
            end if;

            l_stage := 'create_operation';
            l_host_id     := net_api_network_pkg.get_default_host(
                                 i_network_id => l_fin_rec.network_id
                             );
            l_standard_id := net_api_network_pkg.get_offline_standard(
                                 i_host_id    => l_host_id
                             );
                
            mcw_api_fin_pkg.create_operation(
                 i_fin_rec          => l_fin_rec
                , i_standard_id     => l_standard_id
            );

            l_stage := 'done';

        else
            trc_log_pkg.warn(
                i_text       => 'MCW_DSP_NOT_GENERATED'
              , i_env_param1 => l_fin_rec.id
              , i_env_param5 => l_fin_rec.is_reversal
              , i_env_param6 => l_fin_rec.is_incoming
            );
        end if;
        
        trc_log_pkg.debug (
            i_text         => 'Generating reversal request. Assigned id [#1]'
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
