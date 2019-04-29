create or replace package body prs_prc_perso_pkg is
/************************************************************
 * API for personalization process <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 20.05.2010 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2010-05-20 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: prs_prc_perso_pkg <br />
 * @headcom
 ************************************************************/

    BULK_LIMIT      constant pls_integer := 400;

    procedure process (
        i_perso_cur             in sys_refcursor
        , i_batch_id            in com_api_type_pkg.t_short_id
        , i_embossing_request   in com_api_type_pkg.t_dict_value
        , i_pin_mailer_request  in com_api_type_pkg.t_dict_value
        , i_lang                in com_api_type_pkg.t_dict_value
        , i_charset             in com_api_type_pkg.t_oracle_name
        , i_icc_instance_id     in com_api_type_pkg.t_long_id
        , i_estimated_count     in com_api_type_pkg.t_long_id
        , o_excepted_count      out com_api_type_pkg.t_long_id
        , o_processed_count     out com_api_type_pkg.t_long_id
        , o_appl_data           out nocopy emv_api_type_pkg.t_appl_data_tab
    ) is
        l_child_cur               sys_refcursor;
        l_perso_tab               prs_api_type_pkg.t_perso_tab;

        l_perso_method            prs_api_type_pkg.t_perso_method_rec;

        l_perso_data              prs_api_type_pkg.t_perso_data_rec;

        l_embossing_request       com_api_type_pkg.t_dict_value;
        l_pin_mailer_request      com_api_type_pkg.t_dict_value;
        
        l_ok_rowid                com_api_type_pkg.t_rowid_tab;
        l_error_rowid             com_api_type_pkg.t_rowid_tab;
        l_ok_id                   com_api_type_pkg.t_number_tab;
        l_pvv                     com_api_type_pkg.t_number_tab;
        l_pin_offset              com_api_type_pkg.t_cmid_tab;
        l_pvk_index               com_api_type_pkg.t_number_tab;
        l_pin_block               com_api_type_pkg.t_varchar2_tab;
        l_pin_block_format        com_api_type_pkg.t_dict_tab;
        l_iss_date                com_api_type_pkg.t_date_tab;
        l_state                   com_api_type_pkg.t_dict_tab;
        l_event_type              com_api_type_pkg.t_dict_tab;
        l_initiator               com_api_type_pkg.t_dict_tab;
        l_entity_type             com_api_type_pkg.t_dict_tab;
        l_object_id               com_api_type_pkg.t_number_tab;
        l_reason                  com_api_type_pkg.t_dict_tab;

        l_ok_batch_card_id        com_api_type_pkg.t_number_tab;
        l_error_batch_card_id     com_api_type_pkg.t_number_tab;
        l_pin_generated           com_api_type_pkg.t_number_tab;
        l_pin_mailer_printed      com_api_type_pkg.t_number_tab;
        l_embossing_done          com_api_type_pkg.t_number_tab;
        
        l_perso_method_tab        com_api_type_pkg.t_number_tab;
        l_blank_type_tab          com_api_type_pkg.t_number_tab;

        l_card_count              com_api_type_pkg.t_short_id;

        l_excepted_count          com_api_type_pkg.t_long_id;
        l_processed_count         com_api_type_pkg.t_long_id;

        l_param_tab               com_api_type_pkg.t_param_tab;
        l_event_date              com_api_type_pkg.t_date_tab;

        procedure register_event_pin_offset (
            i_perso_rec             in prs_api_type_pkg.t_perso_rec
        ) is
        
            l_param_tab             com_api_type_pkg.t_param_tab;
        begin
            -- clear parameters
            l_param_tab.delete;

            -- register event card issuance
            evt_api_event_pkg.register_event (
                i_event_type     => iss_api_const_pkg.EVENT_PIN_OFFSET_REGISTERED
                , i_eff_date     => i_perso_rec.iss_date
                , i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                , i_object_id    => i_perso_rec.card_instance_id
                , i_inst_id      => i_perso_rec.inst_id
                , i_split_hash   => i_perso_rec.split_hash
                , i_param_tab    => l_param_tab
            );
        end;

        procedure register_ok_perso (
            i_rowid                 in rowid
            , i_id                  in com_api_type_pkg.t_medium_id
            , i_pvv                 in com_api_type_pkg.t_tiny_id
            , i_pin_offset          in com_api_type_pkg.t_cmid
            , i_pvk_index           in com_api_type_pkg.t_tiny_id
            , i_pin_block           in com_api_type_pkg.t_pin_block
            , i_pin_block_format    in com_api_type_pkg.t_curr_code
            , i_iss_date            in date
            , i_batch_card_id       in com_api_type_pkg.t_medium_id
            , i_pin_request         in com_api_type_pkg.t_dict_value
            , i_perso_method_id     in com_api_type_pkg.t_tiny_id
            , i_blank_type_id       in com_api_type_pkg.t_tiny_id
            , i_state               in com_api_type_pkg.t_dict_value
            , i_embossing_request   in com_api_type_pkg.t_dict_value
            , i_pin_mailer_request  in com_api_type_pkg.t_dict_value
        ) is
            i                       binary_integer;
        begin
            i := l_ok_rowid.count + 1;
            
            -- card
            l_ok_rowid(i) := i_rowid;
            l_ok_id(i) := i_id;
            l_iss_date(i) := i_iss_date;
            l_state(i) := i_state;

            l_event_type(i) := iss_api_const_pkg.EVENT_TYPE_CARD_ISSUANCE;
            l_initiator(i) := evt_api_const_pkg.INITIATOR_SYSTEM;
            l_entity_type(i) := iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE;
            l_reason(i) := iss_api_const_pkg.CARD_STATUS_REASON_CARD_ISSUE;
            l_event_date(i) := null;
            
            if ( l_embossing_request = iss_api_const_pkg.EMBOSSING_REQUEST_EMBOSS or i_embossing_request = iss_api_const_pkg.EMBOSSING_REQUEST_DONT_EMBOSS ) and
               ( l_pin_mailer_request = iss_api_const_pkg.PIN_MAILER_REQUEST_PRINT or i_pin_mailer_request = iss_api_const_pkg.PIN_MAILER_REQUEST_DONT_PRINT ) then
                l_object_id(l_object_id.count + 1) := i_id;
            end if;

            if l_perso_method.pin_verify_method = prs_api_const_pkg.PIN_VERIFIC_METHOD_PVV then
                if l_perso_method.pvv_store_method in (prs_api_const_pkg.PVV_STORING_METHOD_DB, prs_api_const_pkg.PVV_STORING_METHOD_COMBINED) then
                    l_pvv(i)        := i_pvv;
                    l_pin_offset(i) := null;
                    l_pvk_index(i)  := i_pvk_index;
                else
                    l_pvv(i)        := null;
                    l_pin_offset(i) := null;
                    l_pvk_index(i)  := i_pvk_index;
                end if;
            elsif l_perso_method.pin_verify_method in (prs_api_const_pkg.PIN_VERIFIC_METHOD_IBM_3624, prs_api_const_pkg.PIN_VERIFIC_METHOD_COMBINED) then
                l_pvv(i)        := null;
                l_pin_offset(i) := i_pin_offset;
                l_pvk_index(i)  := i_pvk_index;
            else
                l_pvv(i)        := null;
                l_pin_offset(i) := null;
                l_pvk_index(i)  := i_pvk_index;
            end if;
            if l_perso_method.pin_store_method = prs_api_const_pkg.PIN_STORING_METHOD_YES then
                l_pin_block(i) := i_pin_block;
                l_pin_block_format(i) := i_pin_block_format;
            else
                l_pin_block(i) := null;
                l_pin_block_format(i) := i_pin_block_format;
            end if;

            -- batch card
            if i_batch_card_id is not null then
                l_ok_batch_card_id(i) := i_batch_card_id;
                if i_pin_request = iss_api_const_pkg.PIN_REQUEST_GENERATE then
                    l_pin_generated(i) := com_api_type_pkg.TRUE;
                else
                    l_pin_generated(i) := com_api_type_pkg.FALSE;
                end if;
                if l_pin_mailer_request = iss_api_const_pkg.PIN_MAILER_REQUEST_PRINT then
                    l_pin_mailer_printed(i) := com_api_type_pkg.TRUE;
                else
                    l_pin_mailer_printed(i) := com_api_type_pkg.FALSE;
                end if;
                if l_embossing_request = iss_api_const_pkg.EMBOSSING_REQUEST_EMBOSS then
                    l_embossing_done(i) := com_api_type_pkg.TRUE;
                else
                    l_embossing_done(i) := com_api_type_pkg.FALSE;
                end if;
            end if;

            -- method & blank type
            l_perso_method_tab(i_perso_method_id) := i_perso_method_id;
            if i_blank_type_id is not null then
                l_blank_type_tab(i_blank_type_id) := i_blank_type_id;
            end if;
        end;

        procedure register_error_perso (
            i_rowid               in rowid
            , i_batch_card_id     in com_api_type_pkg.t_medium_id
        ) is
            i                     binary_integer;
        begin
            i := l_error_rowid.count + 1;

            -- card
            l_error_rowid(i) := i_rowid;

            -- batch card
            if i_batch_card_id is not null then
                l_error_batch_card_id(i) := i_batch_card_id;
                l_pin_generated(i) := com_api_type_pkg.FALSE;
                l_pin_mailer_printed(i) := com_api_type_pkg.FALSE;
                l_embossing_done(i) := com_api_type_pkg.FALSE;
            end if;
        end;
        
        procedure mark_ok_perso is
        begin
            -- card
            prs_api_card_pkg.mark_ok_perso (
                i_rowid                 => l_ok_rowid
                , i_embossing_request   => l_embossing_request
                , i_pin_mailer_request  => l_pin_mailer_request
                , i_id                  => l_ok_id
                , i_pvv                 => l_pvv
                , i_pin_offset          => l_pin_offset
                , i_pvk_index           => l_pvk_index
                , i_pin_block           => l_pin_block
                , i_pin_block_format    => l_pin_block_format
                , i_iss_date            => l_iss_date
                , i_state               => l_state
            );
        
            -- save change state
            evt_api_status_pkg.add_status_log (
                i_event_type     => l_event_type
                , i_initiator    => l_initiator
                , i_entity_type  => l_entity_type
                , i_object_id    => l_object_id
                , i_reason       => l_reason
                , i_status       => l_state
                , i_eff_date     => l_iss_date
                , i_event_date   => l_event_date
            );

            l_ok_rowid.delete;
            l_ok_id.delete;
            l_pvv.delete;
            l_pin_offset.delete;
            l_pvk_index.delete;
            l_pin_block.delete;
            l_pin_block_format.delete;
            l_iss_date.delete;
            l_state.delete;
            l_event_type.delete;
            l_initiator.delete;
            l_entity_type.delete;
            l_object_id.delete;
            l_reason.delete;
            l_event_date.delete;
            
            -- batch card
            prs_api_batch_pkg.mark_ok_batch_card (
                i_id                    => l_ok_batch_card_id
                , i_pin_generated       => l_pin_generated
                , i_pin_mailer_printed  => l_pin_mailer_printed
                , i_embossing_done      => l_embossing_done
            );
            
            l_ok_batch_card_id.delete;
            l_pin_generated.delete;
            l_pin_mailer_printed.delete;
            l_embossing_done.delete;
            
            -- method & blank type
            prs_api_method_pkg.mark_perso_method (
                i_method_tab  => l_perso_method_tab
            );
            prs_api_blank_type_pkg.mark_blank_type (
                i_blank_type_tab  => l_blank_type_tab
            );
            l_perso_method_tab.delete;
            l_blank_type_tab.delete;
            
        end;
        
        procedure mark_error_perso is
        begin
            -- card
            l_error_rowid.delete;
            
            -- batch card
            prs_api_batch_pkg.mark_error_batch_card (
                i_id => l_error_batch_card_id
            );
            l_error_batch_card_id.delete;
        end;
        
        procedure check_ok_perso is
        begin
            if l_ok_rowid.count >= BULK_LIMIT then
                mark_ok_perso;
            end if;
        end;
         
        procedure check_error_perso is
        begin
            if l_error_rowid.count >= BULK_LIMIT then
                mark_error_perso;
            end if;
        end;
        
    begin
        o_excepted_count := 0;
        o_processed_count := 0;

        l_embossing_request := nvl(i_embossing_request, iss_api_const_pkg.EMBOSSING_REQUEST_DONT_EMBOSS);
        l_pin_mailer_request := nvl(i_pin_mailer_request, iss_api_const_pkg.PIN_MAILER_REQUEST_DONT_PRINT);

        l_card_count := i_estimated_count;
        
        loop
            fetch i_perso_cur bulk collect into l_perso_tab limit BULK_LIMIT;
            for i in 1 .. l_perso_tab.count loop
                begin
                    if l_perso_tab(i).icc_instance_id is not null then
                        null;--savepoint processing_next_card_slave;
                    else
                        savepoint processing_next_card;
                    end if;

                    l_card_count := nvl(l_perso_tab(i).card_count, i_estimated_count);
                    if o_processed_count >= l_card_count then
                        exit;
                    end if;
                    
                    l_perso_data := null;
                    l_perso_tab(i).iss_date := com_api_sttl_day_pkg.get_sysdate;
                    
                    trc_log_pkg.set_object (
                        i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                        , i_object_id  => l_perso_tab(i).card_instance_id
                    );

                    trc_log_pkg.debug (
                        i_text          => 'Card instance [#1], card number [#2]'
                        , i_env_param1  => l_perso_tab(i).card_instance_id
                        , i_env_param2  => l_perso_tab(i).card_mask
                    );

                    if l_perso_tab(i).slave_count > 0 and l_perso_tab(i).emv_appl_scheme_id is not null then
                        prs_api_card_pkg.enum_child_card_for_perso (
                            o_perso_cur             => l_child_cur
                            , i_batch_id            => i_batch_id
                            , i_embossing_request   => l_embossing_request
                            , i_pin_mailer_request  => l_pin_mailer_request
                            , i_lang                => i_lang
                            , i_card_instance_id    => l_perso_tab(i).card_instance_id
                        );

                        process (
                            i_perso_cur             => l_child_cur
                            , i_batch_id            => i_batch_id
                            , i_embossing_request   => i_embossing_request
                            , i_pin_mailer_request  => i_pin_mailer_request
                            , i_lang                => i_lang
                            , i_charset             => i_charset
                            , i_icc_instance_id     => l_perso_tab(i).card_instance_id
                            , i_estimated_count     => l_perso_tab(i).slave_count
                            , o_excepted_count      => l_excepted_count
                            , o_processed_count     => l_processed_count
                            , o_appl_data           => o_appl_data
                        );
                        
                        close l_child_cur;
                        l_perso_data.appl_data := o_appl_data; 
                    
                        trc_log_pkg.set_object (
                            i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                            , i_object_id  => l_perso_tab(i).card_instance_id
                        );

                    elsif l_perso_tab(i).icc_instance_id is not null then
                        l_perso_data.appl_data := o_appl_data;
                      
                    else
                        o_appl_data.delete;
                          
                    end if;
                    
                    -- get perso params
                    l_perso_method := prs_api_method_pkg.get_perso_method (
                        i_inst_id            => l_perso_tab(i).inst_id
                        , i_perso_method_id  => l_perso_tab(i).perso_method_id
                    );

                    -- get hsm device
                    l_perso_data.hsm_device_id := l_perso_tab(i).hsm_device_id;
                    -- set charset
                    l_perso_data.charset := i_charset;

                    trc_log_pkg.debug (
                        i_text          => 'Going to get keys...'
                    );

                    -- get keys
                    l_perso_data.perso_key := prs_api_key_pkg.get_perso_keys (
                        i_perso_rec        => l_perso_tab(i)
                        , i_perso_method   => l_perso_method
                        , i_hsm_device_id  => l_perso_data.hsm_device_id
                    );

                    trc_log_pkg.debug (
                        i_text          => 'Going to get pin block'
                    );

                    -- generate pin block
                    prs_api_command_pkg.gen_pin_block (
                        i_perso_rec        => l_perso_tab(i)
                        , i_perso_method   => l_perso_method
                        , i_perso_key      => l_perso_data.perso_key
                        , i_hsm_device_id  => l_perso_data.hsm_device_id
                        , o_pin_block      => l_perso_tab(i).pin_block
                    );

                    case l_perso_method.pin_verify_method
                        when prs_api_const_pkg.PIN_VERIFIC_METHOD_PVV then
                            trc_log_pkg.debug (
                                i_text      => 'PVV method'
                            );
                            -- generate pvv
                            prs_api_command_pkg.gen_pvv_value (
                                i_perso_rec        => l_perso_tab(i)
                                , i_pin_block      => l_perso_tab(i).pin_block
                                , i_perso_key      => l_perso_data.perso_key
                                , i_hsm_device_id  => l_perso_data.hsm_device_id
                                , o_pvv            => l_perso_tab(i).pvv
                            );

                        when prs_api_const_pkg.PIN_VERIFIC_METHOD_IBM_3624 then
                            trc_log_pkg.debug (
                                i_text      => 'IBM 3624 method'
                            );
                            if l_perso_tab(i).pin_offset is null
                               or l_perso_tab(i).pin_request = iss_api_const_pkg.PIN_REQUEST_GENERATE
                            then
                                -- generate pin offset
                                prs_api_command_pkg.derive_ibm_3624_offset (
                                    i_perso_rec               => l_perso_tab(i)
                                    , i_pin_block             => l_perso_tab(i).pin_block
                                    , i_pin_verify_method     => l_perso_method.pin_verify_method
                                    , i_perso_key             => l_perso_data.perso_key
                                    , i_decimalisation_table  => l_perso_method.decimalisation_table
                                    , i_pin_length            => l_perso_method.pin_length
                                    , i_hsm_device_id         => l_perso_data.hsm_device_id
                                    , o_pin_offset            => l_perso_tab(i).pin_offset
                                );
                                -- register event
                                register_event_pin_offset (
                                    i_perso_rec  => l_perso_tab(i)
                                );
                            end if;

                        when prs_api_const_pkg.PIN_VERIFIC_METHOD_COMBINED then
                            trc_log_pkg.debug (
                                i_text      => 'PVV track, IBM 3624 method db'
                            );
                            -- generate pvv
                            prs_api_command_pkg.gen_pvv_value (
                                i_perso_rec        => l_perso_tab(i)
                                , i_pin_block      => l_perso_tab(i).pin_block
                                , i_perso_key      => l_perso_data.perso_key
                                , i_hsm_device_id  => l_perso_data.hsm_device_id
                                , o_pvv            => l_perso_tab(i).pvv
                            );
                            if l_perso_tab(i).pvv2 is null
                               or l_perso_tab(i).pin_request = iss_api_const_pkg.PIN_REQUEST_GENERATE
                            then
                                -- generate pin offset
                                prs_api_command_pkg.derive_ibm_3624_offset (
                                    i_perso_rec               => l_perso_tab(i)
                                    , i_pin_block             => l_perso_tab(i).pin_block
                                    , i_pin_verify_method     => l_perso_method.pin_verify_method
                                    , i_perso_key             => l_perso_data.perso_key
                                    , i_decimalisation_table  => l_perso_method.decimalisation_table
                                    , i_pin_length            => l_perso_method.pin_length
                                    , i_hsm_device_id         => l_perso_data.hsm_device_id
                                    , o_pin_offset            => l_perso_tab(i).pvv2
                                );
                                -- register event
                                register_event_pin_offset (
                                    i_perso_rec  => l_perso_tab(i)
                                );
                            end if;

                        when prs_api_const_pkg.PIN_VERIFIC_METHOD_UNREQUIRED then
                            trc_log_pkg.debug (
                                i_text      => 'Pin verification method - Not Required'
                            );

                        else
                            com_api_error_pkg.raise_error(
                                i_error        => 'UNKNOWN_PIN_VERIFIC_METHOD'
                                , i_env_param1 => l_perso_method.pin_verify_method
                            );
                    end case;

                    -- generate cvv
                    if l_perso_method.cvv_required = com_api_type_pkg.TRUE then
                        trc_log_pkg.debug (
                            i_text          => 'Going to gen cvv'
                        );

                        prs_api_command_pkg.gen_cvv_value (
                            i_perso_rec        => l_perso_tab(i)
                            , i_perso_key      => l_perso_data.perso_key
                            , i_hsm_device_id  => l_perso_data.hsm_device_id
                            , i_service_code   => nvl(l_perso_method.service_code, prs_api_const_pkg.DEFAULT_SERVICE_CODE)
                            , o_cvv            => l_perso_data.cvv
                        );

                    else
                        trc_log_pkg.debug (
                            i_text      => 'CVV not requested'
                        );
                    end if;
                    
                    -- generate cvv2
                    if l_perso_method.cvv2_required = com_api_type_pkg.TRUE then
                        trc_log_pkg.debug (
                            i_text          => 'Going to gen cvv2'
                        );

                        prs_api_command_pkg.gen_cvv2_value (
                            i_perso_rec        => l_perso_tab(i)
                            , i_perso_key      => l_perso_data.perso_key
                            , i_exp_date_format  => substr(l_perso_method.exp_date_format, 5)
                            , i_hsm_device_id  => l_perso_data.hsm_device_id
                            , o_cvv            => l_perso_data.cvv2
                        );
                    else
                        trc_log_pkg.debug (
                            i_text      => 'CVV2 not requested'
                        );
                    end if;
                    
                    -- generate icvv
                    if l_perso_method.icvv_required = com_api_type_pkg.TRUE then
                        prs_api_command_pkg.gen_icvv_value (
                            i_perso_rec        => l_perso_tab(i)
                            , i_perso_key      => l_perso_data.perso_key
                            , i_hsm_device_id  => l_perso_data.hsm_device_id
                            , o_cvv            => l_perso_data.icvv
                        );
                    else
                        trc_log_pkg.debug (
                            i_text      => 'iCVV not requested'
                        );
                    end if;

                    -- setup template
                    prs_api_template_pkg.setup_templates (
                        i_inst_id               => l_perso_tab(i).inst_id
                        , i_perso_rec           => l_perso_tab(i)
                        , i_embossing_request   => l_embossing_request
                        , i_pin_mailer_request  => l_pin_mailer_request
                        , i_perso_method        => l_perso_method
                        , io_perso_data         => l_perso_data
                    );
                    
                    -- register perso data
                    register_ok_perso (
                        i_rowid                 => l_perso_tab(i).row_id
                        , i_id                  => l_perso_tab(i).card_instance_id
                        , i_pvv                 => case when l_perso_method.pin_verify_method = prs_api_const_pkg.PIN_VERIFIC_METHOD_COMBINED then l_perso_tab(i).pvv2 else l_perso_tab(i).pvv end
                        , i_pin_offset          => l_perso_tab(i).pin_offset
                        , i_pvk_index           => l_perso_method.pvk_index
                        , i_pin_block           => l_perso_tab(i).pin_block
                        , i_iss_date            => l_perso_tab(i).iss_date
                        , i_pin_block_format    => prs_api_const_pkg.PIN_BLOCK_FORMAT_ANSI
                        , i_batch_card_id       => l_perso_tab(i).batch_card_id
                        , i_pin_request         => l_perso_tab(i).pin_request
                        , i_perso_method_id     => l_perso_tab(i).perso_method_id
                        , i_blank_type_id       => l_perso_tab(i).blank_type_id
                        , i_state               => l_perso_tab(i).perso_state
                        , i_embossing_request   => l_perso_tab(i).embossing_request
                        , i_pin_mailer_request  => l_perso_tab(i).pin_mailer_request
                    );
                    
                    -- clear parameters
                    l_param_tab.delete;

                    rul_api_param_pkg.set_param (
                        io_params  => l_param_tab
                        , i_name   => 'CARD_TYPE_ID'
                        , i_value  => l_perso_tab(i).card_type_id
                    );
                    rul_api_param_pkg.set_param (
                        io_params  => l_param_tab
                        , i_name   => 'CARD_INSTANCE_STATUS'
                        , i_value  => l_perso_tab(i).status
                    );

                    -- register event card issuance
                    evt_api_event_pkg.register_event (
                        i_event_type     => iss_api_const_pkg.EVENT_TYPE_CARD_ISSUANCE
                        , i_eff_date     => l_perso_tab(i).iss_date
                        , i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CARD
                        , i_object_id    => l_perso_tab(i).card_id
                        , i_inst_id      => l_perso_tab(i).inst_id
                        , i_split_hash   => l_perso_tab(i).split_hash
                        , i_param_tab    => l_param_tab
                    );
                    
                    o_appl_data.delete;
                    o_appl_data := l_perso_data.appl_data;

                exception
                    when others then
                        if l_perso_tab(i).icc_instance_id is not null then
                            null;--rollback to savepoint processing_next_card_slave;
                        else
                            rollback to savepoint processing_next_card;
                        end if;
                            
                        if l_child_cur%isopen then
                            close l_child_cur;
                        end if;

                        if l_perso_tab(i).icc_instance_id is not null then
                            raise;
                        else
                            if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE then
                                register_error_perso (
                                    i_rowid            => l_perso_tab(i).row_id
                                    , i_batch_card_id  => l_perso_tab(i).batch_card_id
                                );
                                
                                o_excepted_count := o_excepted_count + 1;
                            else
                                raise;
                            end if;
                        end if;
                end;
                
                check_ok_perso;
                check_error_perso;
                
                o_processed_count := o_processed_count + 1;
            end loop;

            if i_icc_instance_id is null then
                prc_api_stat_pkg.log_current (
                    i_current_count     => o_processed_count
                    , i_excepted_count  => o_excepted_count
                );
            end if;

            exit when i_perso_cur%notfound or o_processed_count >= l_card_count;
        end loop;
        
        mark_ok_perso;
        mark_error_perso;
        
        trc_log_pkg.clear_object;

    exception
        when others then
            if l_child_cur%isopen then
                close l_child_cur;
            end if;

            trc_log_pkg.clear_object;

            raise;
    end;
    
    procedure generate_with_batch (
        i_batch_id              in com_api_type_pkg.t_short_id
        , i_embossing_request   in com_api_type_pkg.t_dict_value
        , i_pin_mailer_request  in com_api_type_pkg.t_dict_value
        , i_lang                in com_api_type_pkg.t_dict_value
        , i_charset             in com_api_type_pkg.t_oracle_name
    ) is
        l_perso_cur               sys_refcursor;

        l_batch                   prs_api_type_pkg.t_batch_rec;
        
        l_appl_data               emv_api_type_pkg.t_appl_data_tab;
        
        l_embossing_request       com_api_type_pkg.t_dict_value;
        l_pin_mailer_request      com_api_type_pkg.t_dict_value;
        
        l_estimated_count         com_api_type_pkg.t_long_id := 0;
        l_excepted_count          com_api_type_pkg.t_long_id := 0;
        l_processed_count         com_api_type_pkg.t_long_id := 0;

    begin
        savepoint perso_process_start;

        prc_api_stat_pkg.log_start;

        trc_log_pkg.debug (
            i_text          => 'Starting personalization'
        );

        prs_api_const_pkg.init_printer_encoding;

        l_embossing_request := nvl(i_embossing_request, iss_api_const_pkg.EMBOSSING_REQUEST_DONT_EMBOSS);
        l_pin_mailer_request := nvl(i_pin_mailer_request, iss_api_const_pkg.PIN_MAILER_REQUEST_DONT_PRINT);

        -- get estimated_count
        l_estimated_count := prs_api_card_pkg.estimate_card_for_perso (
            i_batch_id              => i_batch_id
            , i_embossing_request   => l_embossing_request
            , i_pin_mailer_request  => l_pin_mailer_request
            , i_lang                => i_lang
        );
        prc_api_stat_pkg.log_estimation (
            i_estimated_count  => l_estimated_count
        );

        if l_estimated_count > 0 then
            prs_api_key_pkg.clear_global_data;
            prs_api_file_pkg.clear_global_data;
            
            l_batch := prs_api_batch_pkg.get_batch (
                i_id  => i_batch_id
            );

            prs_api_card_pkg.enum_card_for_perso (
                o_perso_cur             => l_perso_cur
                , i_batch_id            => i_batch_id
                , i_embossing_request   => l_embossing_request
                , i_pin_mailer_request  => l_pin_mailer_request
                , i_lang                => i_lang
                , i_order_clause        => prs_api_card_pkg.enum_sort_condition ( i_sort_id  => l_batch.sort_id )
            );

            process (
                i_perso_cur             => l_perso_cur
                , i_batch_id            => i_batch_id
                , i_embossing_request   => i_embossing_request
                , i_pin_mailer_request  => i_pin_mailer_request
                , i_lang                => i_lang
                , i_charset             => i_charset
                , i_icc_instance_id     => null
                , i_estimated_count     => l_estimated_count
                , o_excepted_count      => l_excepted_count
                , o_processed_count     => l_processed_count
                , o_appl_data           => l_appl_data
            );
            
            close l_perso_cur;

            prs_api_batch_pkg.mark_ok_batch (
                i_id        => i_batch_id
                , i_status  => case when l_excepted_count = 0 then prs_api_const_pkg.BATCH_STATUS_PROCESSED else prs_api_const_pkg.BATCH_STATUS_IN_PROGRESS end
            );

        end if;
        
        prs_api_key_pkg.clear_global_data;
        prs_api_file_pkg.close_session_file;
        l_appl_data.delete;

        prc_api_stat_pkg.log_end (
            i_excepted_total    => l_excepted_count
          , i_processed_total   => l_processed_count
          , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );

        trc_log_pkg.debug (
            i_text  => 'Finishing personalization'
        );
    exception
        when others then
            rollback to savepoint perso_process_start;
            
            if l_perso_cur%isopen then
                close l_perso_cur;
            end if;
            
            prs_api_key_pkg.clear_global_data;
            prs_api_file_pkg.clear_global_data;

            prc_api_stat_pkg.log_end (
                i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );

            if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
                raise;
            elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_fatal_error(
                    i_error         => 'UNHANDLED_EXCEPTION'
                  , i_env_param1    => sqlerrm
                );
            end if;
            raise;
    end;
    
    procedure generate_without_batch (
        i_embossing_request     in com_api_type_pkg.t_dict_value
        , i_pin_mailer_request  in com_api_type_pkg.t_dict_value
        , i_inst_id             in com_api_type_pkg.t_inst_id
        , i_agent_id            in com_api_type_pkg.t_agent_id
        , i_product_id          in com_api_type_pkg.t_short_id
        , i_card_type_id        in com_api_type_pkg.t_tiny_id
        , i_perso_priority      in com_api_type_pkg.t_dict_value
        , i_sort_id             in com_api_type_pkg.t_tiny_id
        , i_hsm_device_id       in com_api_type_pkg.t_tiny_id
        , i_lang                in com_api_type_pkg.t_dict_value
        , i_charset             in com_api_type_pkg.t_oracle_name
    ) is
        l_perso_cur               sys_refcursor;
        
        l_hsm_device_id           com_api_type_pkg.t_tiny_id;
        
        l_batch_id                com_api_type_pkg.t_short_id;
        l_seqnum                  com_api_type_pkg.t_seqnum;

        l_batch                   prs_api_type_pkg.t_batch_rec;
        l_warning_msg             com_api_type_pkg.t_text;

        l_appl_data               emv_api_type_pkg.t_appl_data_tab;
        
        l_embossing_request       com_api_type_pkg.t_dict_value;
        l_pin_mailer_request      com_api_type_pkg.t_dict_value;

        l_estimated_count         com_api_type_pkg.t_long_id := 0;
        l_excepted_count          com_api_type_pkg.t_long_id := 0;
        l_processed_count         com_api_type_pkg.t_long_id := 0;

    begin
        savepoint perso_process_start;

        prc_api_stat_pkg.log_start;

        trc_log_pkg.debug (
            i_text          => 'Starting personalization'
        );

        prs_api_const_pkg.init_printer_encoding;
        
        l_hsm_device_id := hsm_api_selection_pkg.select_hsm (
            i_inst_id     => i_inst_id
            , i_agent_id  => i_agent_id
            , i_hsm_id    => i_hsm_device_id
            , i_action    => hsm_api_const_pkg.ACTION_HSM_PERSONALIZATION
        );

        l_embossing_request := nvl(i_embossing_request, iss_api_const_pkg.EMBOSSING_REQUEST_DONT_EMBOSS);
        l_pin_mailer_request := nvl(i_pin_mailer_request, iss_api_const_pkg.PIN_MAILER_REQUEST_DONT_PRINT);
        
        -- create batch
        prs_ui_batch_pkg.add_batch (
            o_id                => l_batch_id
            , o_seqnum          => l_seqnum
            , i_inst_id         => i_inst_id
            , i_agent_id        => i_agent_id
            , i_product_id      => i_product_id
            , i_card_type_id    => i_card_type_id
            , i_blank_type_id   => null
            , i_card_count      => null
            , i_hsm_device_id   => l_hsm_device_id
            , i_status          => prs_api_const_pkg.BATCH_STATUS_INITIAL
            , i_sort_id         => i_sort_id
            , i_perso_priority  => i_perso_priority
            , i_lang            => i_lang
            , i_batch_name      => com_api_type_pkg.convert_to_char(get_sysdate)
        );
        
        trc_log_pkg.info (
            i_text          => 'Personalization batch [#1]'
            , i_env_param1  => l_batch_id
        );

        -- add cards into batch
        prs_ui_batch_card_pkg.mark_batch_card (
            i_batch_id              => l_batch_id
            , i_agent_id            => i_agent_id
            , i_product_id          => i_product_id
            , i_card_type_id        => i_card_type_id
            , i_blank_type_id       => null
            , i_perso_priority      => i_perso_priority
            , i_pin_request         => null
            , i_embossing_request   => i_embossing_request
            , i_pin_mailer_request  => i_pin_mailer_request
            , o_warning_msg         => l_warning_msg
        );
        
        -- get estimated_count
        l_estimated_count := prs_api_card_pkg.estimate_card_for_perso (
            i_batch_id              => l_batch_id
            , i_embossing_request   => l_embossing_request
            , i_pin_mailer_request  => l_pin_mailer_request
            , i_lang                => i_lang
        );
        prc_api_stat_pkg.log_estimation (
            i_estimated_count  => l_estimated_count
        );

        if l_estimated_count > 0 then
            prs_api_key_pkg.clear_global_data;
            prs_api_file_pkg.clear_global_data;

            l_batch := prs_api_batch_pkg.get_batch (
                i_id  => l_batch_id
            );

            prs_api_card_pkg.enum_card_for_perso (
                o_perso_cur             => l_perso_cur
                , i_batch_id            => l_batch_id
                , i_embossing_request   => l_embossing_request
                , i_pin_mailer_request  => l_pin_mailer_request
                , i_lang                => i_lang
                , i_order_clause        => prs_api_card_pkg.enum_sort_condition ( i_sort_id  => l_batch.sort_id )
            );

            process (
                i_perso_cur             => l_perso_cur
                , i_batch_id            => l_batch_id
                , i_embossing_request   => l_embossing_request
                , i_pin_mailer_request  => l_pin_mailer_request
                , i_lang                => i_lang
                , i_charset             => i_charset
                , i_icc_instance_id     => null
                , i_estimated_count     => l_estimated_count
                , o_excepted_count      => l_excepted_count
                , o_processed_count     => l_processed_count
                , o_appl_data           => l_appl_data
            );

            close l_perso_cur;

        end if;
        
        prs_api_batch_pkg.mark_ok_batch (
            i_id        => l_batch_id
            , i_status  => prs_api_const_pkg.BATCH_STATUS_PROCESSED
        );

        prs_api_key_pkg.clear_global_data;
        prs_api_file_pkg.close_session_file;
        l_appl_data.delete;

        prc_api_stat_pkg.log_end (
            i_excepted_total    => l_excepted_count
          , i_processed_total   => l_processed_count
          , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );

        trc_log_pkg.debug (
            i_text  => 'Finishing personalization'
        );
    exception
        when others then
            rollback to savepoint perso_process_start;

            if l_perso_cur%isopen then
                close l_perso_cur;
            end if;

            prs_api_key_pkg.clear_global_data;
            prs_api_file_pkg.clear_global_data;

            prc_api_stat_pkg.log_end (
                i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );

            if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
                raise;
            elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_fatal_error(
                    i_error         => 'UNHANDLED_EXCEPTION'
                  , i_env_param1    => sqlerrm
                );
            end if;
            raise;
    end;

end; 
/
