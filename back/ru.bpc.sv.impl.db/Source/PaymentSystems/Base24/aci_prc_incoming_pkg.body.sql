create or replace package body aci_prc_incoming_pkg is
/************************************************************
 * Base24 incoming files API <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 06.12.2013 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: aci_prc_incoming_pkg <br />
 * @headcom
 ************************************************************/
     
    BULK_LIMIT      constant integer := 400;
    
    g_session_file_id           com_api_type_pkg.t_long_id;
    g_file_name     com_api_type_pkg.t_name;
    g_clob_line     pls_integer := 0;
    g_msg_count     aci_api_type_pkg.t_msg_count_tab;
    
    g_oper_type     aci_api_type_pkg.t_dict_count_tab;
    g_sttl_type     aci_api_type_pkg.t_dict_count_tab;
    g_msg_type      aci_api_type_pkg.t_dict_count_tab;
    g_status        aci_api_type_pkg.t_dict_count_tab;

    function get_field_char (
        i_raw_data              in varchar2
        , i_start_pos           in pls_integer
        , i_length              in pls_integer
    ) return com_api_type_pkg.t_raw_data is
    begin
        return aci_api_util_pkg.get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => i_start_pos
            , i_length     => i_length
        );
    end;
    
    function get_field_number (
        i_raw_data              in varchar2
        , i_start_pos           in pls_integer
        , i_length              in pls_integer
    ) return number is
    begin
        return aci_api_util_pkg.get_field_number (
            i_raw_data     => i_raw_data
            , i_start_pos  => i_start_pos
            , i_length     => i_length
        );
    end;
    
    function get_field_date (
        i_raw_data              in varchar2
        , i_start_pos           in pls_integer
        , i_length              in pls_integer
        , i_fmt                 in varchar2
    ) return date is
    begin
        return aci_api_util_pkg.get_field_date (
            i_raw_data     => i_raw_data
            , i_start_pos  => i_start_pos
            , i_length     => i_length
            , i_fmt        => i_fmt
        );
    end;

    function get_inst_id (
        i_inst_id               in com_api_type_pkg.t_name
    ) return com_api_type_pkg.t_inst_id is
    begin
        return com_api_array_pkg.conv_array_elem_v (
            i_array_type_id  => aci_api_const_pkg.BASE24_INST_ARRAY_TYPE
            , i_elem_value   => i_inst_id
            , i_mask_error   => com_api_type_pkg.TRUE
        );
    end;
    
    function get_service_code (
        i_raw_data              in varchar2
        , i_interface           in com_api_type_pkg.t_name
    ) return com_api_type_pkg.t_module_code is
        l_length                number := null;
        l_service_code          com_api_type_pkg.t_module_code;
    begin
        case i_interface
        when aci_api_const_pkg.INTERFACE_BNET then
            case substr(i_raw_data, 1, 1)
            when ';' then
                l_length := instr(i_raw_data, '=', 1);
                if l_length != 0 and length(substr(i_raw_data, l_length)) > 6 then
                    l_service_code := substr(i_raw_data, l_length + 5, 3);
                end if;
                
            else
                null;
            end case;
            
        when aci_api_const_pkg.INTERFACE_VISA then
            case substr(i_raw_data, 1, 1)
            when ';' then
                l_length := instr(i_raw_data, '=', 1);
                if l_length != 0 then
                    l_service_code := substr(i_raw_data, l_length + 5, 3);
                end if;
                
            else
                null;
            end case;
        
        else
            null;    
        end case;
        
        return l_service_code;
    end;
    
    procedure get_merchant_address (
        i_inst_id               in com_api_type_pkg.t_inst_id
        , i_merchant_number     in com_api_type_pkg.t_merchant_number
        , io_merchant_street    in out com_api_type_pkg.t_name
        , io_merchant_city      in out com_api_type_pkg.t_name
        , io_merchant_region    in out com_api_type_pkg.t_name
        , io_merchant_country   in out com_api_type_pkg.t_curr_code
        , io_merchant_postcode  in out com_api_type_pkg.t_name
    ) is
    begin
        for r in (
            select
                a.street
                , a.city
                , a.region
                , a.country
                , a.postal_code
            from
                acq_merchant m
                , com_address a
            where
                m.inst_id = i_inst_id
                and m.merchant_number = i_merchant_number
                and a.id = acq_api_merchant_pkg.get_merchant_address_id(m.id)
            order by
                decode(a.lang, get_user_lang, 1, 'LANGENG', 2, 3)
        ) loop
            io_merchant_street := nvl(io_merchant_street, r.street);
            io_merchant_city := nvl(io_merchant_city, r.city);
            io_merchant_region := nvl(io_merchant_region, r.region);
            io_merchant_country := nvl(io_merchant_country, r.country);
            io_merchant_postcode := nvl(io_merchant_postcode, r.postal_code);
            exit;
        end loop;
    end;
    
    procedure get_terminal (
        i_inst_id               in com_api_type_pkg.t_inst_id
        , i_terminal_number     in com_api_type_pkg.t_terminal_number
        , o_terminal_rec        out aap_api_type_pkg.t_terminal
    ) is
        l_terminal_cur          sys_refcursor;
    begin
        open l_terminal_cur for 
        select
            x.id
            , is_template
            , terminal_number
            , terminal_type
            , null standard_id
            , null version_id
            , merchant_id
            , mcc
            , plastic_number
            , card_data_input_cap
            , crdh_auth_cap
            , card_capture_cap
            , term_operating_env
            , crdh_data_present
            , card_data_present
            , card_data_input_mode
            , crdh_auth_method
            , crdh_auth_entity
            , card_data_output_cap
            , term_data_output_cap
            , pin_capture_cap
            , cat_level
            , status
            , null product_id
            , inst_id
            , device_id
            , is_mac
            , gmt_offset
            , null terminal_template
            , cash_dispenser_present
            , payment_possibility
            , use_card_possibility
            , cash_in_present
            , available_network
            , available_operation
            , available_currency
            , mcc_template_id
        from
            acq_terminal x
        where
            x.terminal_number = i_terminal_number
            and x.inst_id = i_inst_id
            and x.is_template = com_api_type_pkg.FALSE;
        fetch l_terminal_cur into o_terminal_rec;
        close l_terminal_cur;
    exception
        when others then
            if l_terminal_cur%isopen then
                close l_terminal_cur;
            end if;
            raise;
    end;
    
    procedure clear_global_data is
    begin
        g_msg_count.delete;
        g_session_file_id := null;
        g_file_name := null;
        g_clob_line := 0;
        
        g_oper_type.delete;
        g_sttl_type.delete;
        g_msg_type.delete;
        g_status.delete;
    end;
    
    procedure init_counts is
    begin
        if not g_msg_count.exists(nvl(g_file_name, '')) then
            g_msg_count(nvl(g_file_name, '')).estimated_count := 0;
            g_msg_count(nvl(g_file_name, '')).successed_total := 0;
            g_msg_count(nvl(g_file_name, '')).excepted_total := 0;
            g_msg_count(nvl(g_file_name, '')).skipped_total := 0;
        end if;
    end;
    
    procedure register_oper (
        i_oper_type             in com_api_type_pkg.t_dict_value
        , i_sttl_type           in com_api_type_pkg.t_dict_value
        , i_msg_type            in com_api_type_pkg.t_dict_value
        , i_status              in com_api_type_pkg.t_dict_value
    )  is
        l_oper_type             com_api_type_pkg.t_dict_value := nvl(i_oper_type, '');
        l_sttl_type             com_api_type_pkg.t_dict_value := nvl(i_sttl_type, '');
        l_msg_type              com_api_type_pkg.t_dict_value := nvl(i_msg_type, '');
        l_status                com_api_type_pkg.t_dict_value := nvl(i_status, '');
    begin
        if not g_oper_type.exists(l_oper_type) then
            g_oper_type(i_oper_type) := 0;
        end if;
        if not g_sttl_type.exists(l_sttl_type) then
            g_sttl_type(l_sttl_type) := 0;
        end if;
        if not g_msg_type.exists(l_msg_type) then
            g_msg_type(l_msg_type) := 0;
        end if;
        if not g_status.exists(l_status) then
            g_status(l_status) := 0;
        end if;
        
        g_oper_type(l_oper_type) := nvl(g_oper_type(l_oper_type), 0) + 1;
        g_sttl_type(l_sttl_type) := nvl(g_sttl_type(l_sttl_type), 0) + 1;
        g_msg_type(l_msg_type) := nvl(g_msg_type(l_msg_type), 0) + 1;
        g_status(l_status) := nvl(g_status(l_status), 0) + 1;
    end;
    
    procedure register_count is
    begin
        init_counts;
        g_msg_count(nvl(g_file_name, '')).estimated_count := nvl(g_msg_count(nvl(g_file_name, '')).estimated_count, 0) + 1;
    end;
    
    procedure register_ok is
    begin
        init_counts;
        g_msg_count(nvl(g_file_name, '')).successed_total := nvl(g_msg_count(nvl(g_file_name, '')).successed_total, 0) + 1;
    end;
    
    procedure register_error is
    begin
        init_counts;
        g_msg_count(nvl(g_file_name, '')).excepted_total := nvl(g_msg_count(nvl(g_file_name, '')).excepted_total, 0) + 1;
    end;
    
    procedure register_skip is
    begin
        init_counts;
        g_msg_count(nvl(g_file_name, '')).skipped_total := nvl(g_msg_count(nvl(g_file_name, '')).skipped_total, 0) + 1;
    end;
    
    procedure serialize_msg_count is
        l_result                com_api_type_pkg.t_name;
    begin
        -- Summary
        l_result := g_msg_count.first;
        loop
            exit when l_result is null;
                
            trc_log_pkg.info (
                i_text          => 'File [#1]: estimated[#2] successed[#3] excepted[#4] skipped[#5]'
                , i_env_param1  => l_result
                , i_env_param2  => g_msg_count(l_result).estimated_count
                , i_env_param3  => g_msg_count(l_result).successed_total
                , i_env_param4  => g_msg_count(l_result).excepted_total
                , i_env_param5  => g_msg_count(l_result).skipped_total
            );
                
            l_result := g_msg_count.next(l_result);
        end loop;
        
        -- Operation type
        l_result := g_oper_type.first;
        loop
            exit when l_result is null;
            
            trc_log_pkg.info (
                i_text          => 'Successed: Operation type [#1] count [#2]'
                , i_env_param1  => l_result
                , i_env_param2  => g_oper_type(l_result)
            );
                
            l_result := g_oper_type.next(l_result);
        end loop;
        
        -- Settlement type
        l_result := g_sttl_type.first;
        loop
            exit when l_result is null;
            
            trc_log_pkg.info (
                i_text          => 'Successed: Settlement type [#1] count [#2]'
                , i_env_param1  => l_result
                , i_env_param2  => g_sttl_type(l_result)
            );
                
            l_result := g_sttl_type.next(l_result);
        end loop;
        
        -- Message type
        l_result := g_msg_type.first;
        loop
            exit when l_result is null;
            
            trc_log_pkg.info (
                i_text          => 'Successed: Message type [#1] count [#2]'
                , i_env_param1  => l_result
                , i_env_param2  => g_msg_type(l_result)
            );
                
            l_result := g_msg_type.next(l_result);
        end loop;
        
        -- Operation status
        l_result := g_status.first;
        loop
            exit when l_result is null;
            
            trc_log_pkg.info (
                i_text          => 'Successed: Operation status [#1] count [#2]'
                , i_env_param1  => l_result
                , i_env_param2  => g_status(l_result)
            );
                
            l_result := g_status.next(l_result);
        end loop;
    end;

    procedure set_auth (
        o_auth                  out aut_api_type_pkg.t_auth_rec
        , i_terminal            in aap_api_type_pkg.t_terminal
    ) is
        l_stage                 com_api_type_pkg.t_name;
    begin
        l_stage := 'resp_code';
        
        o_auth.resp_code := aup_api_const_pkg.RESP_CODE_OK;
        
        o_auth.network_cnvt_date := null;
        
        o_auth.card_data_input_cap    := case when i_terminal.id is null
                                             then 'F2210000'
                                             else i_terminal.card_data_input_cap
                                         end;
        o_auth.crdh_auth_cap          := case when i_terminal.id is null
                                              then 'F2220009'
                                              else i_terminal.crdh_auth_cap
                                         end;
        o_auth.card_capture_cap       := case when i_terminal.id is null
                                             then 'F2230002'
                                             else i_terminal.card_capture_cap
                                         end;
        o_auth.terminal_operating_env := case when i_terminal.id is null
                                             then 'F2240009'
                                             else i_terminal.term_operating_env
                                         end;
        o_auth.crdh_presence          := case when i_terminal.id is null
                                             then 'F2250000'
                                             else i_terminal.crdh_data_present
                                         end;
        o_auth.card_presence          := case when i_terminal.id is null
                                             then 'F2260000'
                                             else i_terminal.card_data_present
                                         end;
        o_auth.card_data_input_mode   := case when i_terminal.id is null
                                             then 'F2270000'
                                             else i_terminal.card_data_input_mode
                                         end;
        o_auth.crdh_auth_method       := case when i_terminal.id is null
                                             then 'F228000S'
                                             else i_terminal.crdh_auth_method
                                         end;
        o_auth.crdh_auth_entity       := case when i_terminal.id is null
                                             then 'F2290009'
                                             else i_terminal.crdh_auth_entity
                                         end;
        o_auth.card_data_output_cap   := case when i_terminal.id is null
                                             then 'F22A0000'
                                             else i_terminal.card_data_output_cap
                                         end;
        o_auth.terminal_output_cap    := case when i_terminal.id is null
                                             then 'F22B0000'
                                             else i_terminal.term_data_output_cap
                                         end;
        o_auth.pin_capture_cap        := case when i_terminal.id is null
                                             then 'F22C0001'
                                             else i_terminal.pin_capture_cap
                                         end;
        o_auth.cat_level              := case when i_terminal.id is null
                                             then 'F22D0000'
                                             else i_terminal.cat_level
                                         end;

        o_auth.pos_cond_code      := null;
        o_auth.pin_presence       := 'PINP0002';
        o_auth.cvv2_presence      := 'CV2P0000';
        o_auth.ucaf_indicator     := 'UCAF0000';
        o_auth.cvv2_result        := 'CV2R0003';
        o_auth.certificate_type   := null;
        o_auth.certificate_method := 'CRTM0009';
        o_auth.service_code       := null;
        
        o_auth.is_early_emv       := 0;
        o_auth.is_advice          := com_api_type_pkg.FALSE;
    exception
        when others then
            trc_log_pkg.debug (
                i_text          => 'Error save_auth on stage [#1] :[#2]'
                , i_env_param1  => l_stage
                , i_env_param2  => sqlerrm
            );
            --dbms_output.put_line(substr(i_raw_data, 1, 575));
            raise;
    end;
    
    procedure save_visa_basei (
        i_visa_basei            in aup_api_type_pkg.t_aup_visa_basei_rec  
    ) is
        l_stage                 com_api_type_pkg.t_name;
    begin
        insert into aup_visa_basei (
            auth_id
            , tech_id
            , iso_msg_type
            , acq_inst_bin
            , forw_inst_bin
            , host_id
            , validation_code
            , srv_indicator
            , ecommerce_indicator
            , trace
            , resp_code
        ) values (
            i_visa_basei.auth_id
            , i_visa_basei.tech_id
            , i_visa_basei.iso_msg_type
            , i_visa_basei.acq_inst_bin
            , i_visa_basei.forw_inst_bin
            , i_visa_basei.host_id
            , i_visa_basei.validation_code
            , i_visa_basei.srv_indicator
            , i_visa_basei.ecommerce_indicator
            , i_visa_basei.trace
            , i_visa_basei.resp_code
        );
    exception
        when others then
            trc_log_pkg.debug (
                i_text          => 'Error visa base I on stage [#1] :[#2]'
                , i_env_param1  => l_stage
                , i_env_param2  => sqlerrm
            );
            raise;
    end;
    
    procedure save_mastercard (
        i_aup_mastercard        in aup_api_type_pkg.t_aup_mastercard_rec
    ) is
        l_stage                 com_api_type_pkg.t_name;
    begin
        insert into aup_mastercard (
            auth_id
            , tech_id
            , iso_msg_type
            , trace
            , trms_datetime
            , time_mark
            , bitmap
            , sttl_date
            , acq_inst_bin
            , forw_inst_bin
            , eci
            , auth_code
            , resp_code
        ) values (
            i_aup_mastercard.auth_id
            , i_aup_mastercard.tech_id
            , i_aup_mastercard.iso_msg_type
            , i_aup_mastercard.trace
            , i_aup_mastercard.trms_datetime
            , i_aup_mastercard.time_mark
            , i_aup_mastercard.bitmap
            , i_aup_mastercard.sttl_date
            , i_aup_mastercard.acq_inst_bin
            , i_aup_mastercard.forw_inst_bin
            , i_aup_mastercard.eci
            , i_aup_mastercard.auth_code
            , i_aup_mastercard.resp_code
        );
    exception
        when others then
            trc_log_pkg.debug (
                i_text          => 'Error mastercard on stage [#1] :[#2]'
                , i_env_param1  => l_stage
                , i_env_param2  => sqlerrm
            );
            raise;
    end;
    
    procedure save_auth (
        i_auth_rec              in aut_api_type_pkg.t_auth_rec
    ) is
        l_stage                 com_api_type_pkg.t_name;
    begin
        insert into aut_auth (
            id
            , parent_id
            , resp_code
            , proc_type
            , proc_mode
            , is_advice
            , is_repeat
            , is_completed
            , account_cnvt_rate
            , bin_amount
            , bin_currency
            , bin_cnvt_rate
            , network_amount
            , network_currency
            , network_cnvt_date
            , network_cnvt_rate
            , addr_verif_result
            , acq_device_id
            , acq_resp_code
            , acq_device_proc_result
            , cat_level
            , card_data_input_cap
            , crdh_auth_cap
            , card_capture_cap
            , terminal_operating_env
            , crdh_presence
            , card_presence
            , card_data_input_mode
            , crdh_auth_method
            , crdh_auth_entity
            , card_data_output_cap
            , terminal_output_cap
            , pin_capture_cap
            , pin_presence
            , cvv2_presence
            , cvc_indicator
            , pos_entry_mode
            , pos_cond_code
            , emv_data
            , atc
            , tvr
            , cvr
            , addl_data
            , service_code
            , device_date
            , certificate_method
            , certificate_type
            , merchant_certif
            , cardholder_certif
            , ucaf_indicator
            , is_early_emv
            , amounts
            , cavv_presence
            , aav_presence
            , cvv2_result
            , transaction_id
        ) values (
            i_auth_rec.id
            , i_auth_rec.parent_id
            , i_auth_rec.resp_code
            , null              -- proc_type
            , null              -- proc_mode
            , i_auth_rec.is_advice
            , i_auth_rec.is_repeat
            , aut_api_const_pkg.AUTH_DURING_EXECUTION    -- is_completed
            , i_auth_rec.account_cnvt_rate
            , i_auth_rec.bin_amount
            , i_auth_rec.bin_currency
            , i_auth_rec.bin_cnvt_rate
            , i_auth_rec.network_amount
            , i_auth_rec.network_currency
            , i_auth_rec.network_cnvt_date
            , i_auth_rec.network_cnvt_rate
            , i_auth_rec.addr_verif_result
            , i_auth_rec.acq_device_id
            , i_auth_rec.acq_resp_code
            , i_auth_rec.acq_device_proc_result
            , i_auth_rec.cat_level
            , i_auth_rec.card_data_input_cap
            , i_auth_rec.crdh_auth_cap
            , i_auth_rec.card_capture_cap
            , i_auth_rec.terminal_operating_env
            , i_auth_rec.crdh_presence
            , i_auth_rec.card_presence
            , i_auth_rec.card_data_input_mode
            , i_auth_rec.crdh_auth_method
            , i_auth_rec.crdh_auth_entity
            , i_auth_rec.card_data_output_cap
            , i_auth_rec.terminal_output_cap
            , i_auth_rec.pin_capture_cap
            , i_auth_rec.pin_presence
            , i_auth_rec.cvv2_presence
            , i_auth_rec.cvc_indicator
            , i_auth_rec.pos_entry_mode
            , i_auth_rec.pos_cond_code
            , i_auth_rec.emv_data
            , i_auth_rec.atc
            , i_auth_rec.tvr
            , i_auth_rec.cvr
            , i_auth_rec.addl_data
            , i_auth_rec.service_code
            , i_auth_rec.device_date
            , i_auth_rec.certificate_method
            , i_auth_rec.certificate_type
            , i_auth_rec.merchant_certif
            , i_auth_rec.cardholder_certif
            , i_auth_rec.ucaf_indicator
            , i_auth_rec.is_early_emv
            , i_auth_rec.amounts
            , i_auth_rec.cavv_presence
            , i_auth_rec.aav_presence
            , i_auth_rec.cvv2_result
            , i_auth_rec.transaction_id
        );
    exception
        when others then
            trc_log_pkg.debug (
                i_text          => 'Error save auth on stage [#1] :[#2]'
                , i_env_param1  => l_stage
                , i_env_param2  => sqlerrm
            );
            raise;
    end;

    procedure create_operation (
        i_oper                  in opr_api_type_pkg.t_oper_rec
        , i_iss_part            in opr_api_type_pkg.t_oper_part_rec
        , i_acq_part            in opr_api_type_pkg.t_oper_part_rec
        , i_auth                in aut_api_type_pkg.t_auth_rec
        , i_visa_basei          in aup_api_type_pkg.t_aup_visa_basei_rec
        , i_aup_mastercard      in aup_api_type_pkg.t_aup_mastercard_rec
        , i_interface           in com_api_type_pkg.t_name
    ) is
        l_oper                  opr_api_type_pkg.t_oper_rec := i_oper;
        l_auth                  aut_api_type_pkg.t_auth_rec := i_auth;
        l_iss_part              opr_api_type_pkg.t_oper_part_rec := i_iss_part;
        l_acq_part              opr_api_type_pkg.t_oper_part_rec := i_acq_part;
        l_visa_basei            aup_api_type_pkg.t_aup_visa_basei_rec := i_visa_basei;
        l_aup_mastercard        aup_api_type_pkg.t_aup_mastercard_rec := i_aup_mastercard;
        l_original_id           com_api_type_pkg.t_long_id;
        l_original_amount       com_api_type_pkg.t_money;
        l_original_currency     com_api_type_pkg.t_curr_code;
        l_original_status       com_api_type_pkg.t_dict_value;
        l_stage                 com_api_type_pkg.t_name;
        l_result                com_api_type_pkg.t_boolean;
        
        procedure set_original_id is
        begin
            -- check offline duplicate
            select
                case when count(o.id) > 0 then 1 else 0 end
            into
                l_result
            from
                opr_operation o
            where
                o.originator_refnum = l_oper.originator_refnum
                and o.is_reversal = l_oper.is_reversal
                and o.oper_type = l_oper.oper_type
                and o.msg_type = l_oper.msg_type
                and o.status != opr_api_const_pkg.OPERATION_STATUS_DUPLICATE;
            
            if l_result = com_api_type_pkg.TRUE then
                l_oper.status := opr_api_const_pkg.OPERATION_STATUS_DUPLICATE;
                return;
            end if;

            if l_oper.status != opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY then
                return;
            end if;
            
            if l_oper.is_reversal = com_api_type_pkg.TRUE then
                l_stage := 'get original for reversal';
                begin
                    select
                        id
                        , oper_amount
                        , oper_currency
                        , status
                        , crdh_auth_method
                        , crdh_auth_entity
                    into
                        l_original_id
                        , l_original_amount
                        , l_original_currency
                        , l_original_status
                        , l_auth.crdh_auth_method
                        , l_auth.crdh_auth_entity
                    from (
                        select
                            o.id
                            , o.oper_amount
                            , o.oper_currency
                            , o.status
                            , a.crdh_auth_method
                            , a.crdh_auth_entity
                            
                        from
                            opr_operation o
                            , opr_participant p
                            , opr_card c
                            , aut_auth a
                        where
                            p.participant_type = 'PRTYISS'
                            and p.oper_id = o.id
                            and c.participant_type = 'PRTYISS'
                            and c.oper_id = o.id
                            and reverse(c.card_number) = 
                                    reverse(iss_api_token_pkg.encode_card_number(i_card_number => l_iss_part.card_number))
                            and o.originator_refnum = l_oper.originator_refnum
                            and o.merchant_number = l_oper.merchant_number
                            and o.terminal_number = l_oper.terminal_number
                            and o.is_reversal = com_api_type_pkg.FALSE
                            and abs(trunc(o.oper_date) - trunc(l_oper.oper_date)) <= 30
                            and a.id = o.id
                            and not exists (select 1 from opr_operation o2 where o2.original_id = o.id)
                            and o.status != opr_api_const_pkg.OPERATION_STATUS_DUPLICATE
                        order by
                            p.auth_code
                            , abs(trunc(o.oper_date) - trunc(l_oper.oper_date))
                            , o.id desc
                    )
                    where
                        rownum = 1;
                exception
                    when no_data_found then
                        l_oper.status := opr_api_const_pkg.OPERATION_STATUS_MANUAL;
                        trc_log_pkg.warn (
                            i_text           => 'ORIGINAL_OPERATION_IS_NOT_FOUND'
                            , i_env_param1   => l_oper.id
                            , i_env_param2   => l_oper.originator_refnum
                            , i_env_param3   => iss_api_card_pkg.get_card_mask(l_iss_part.card_number)
                            , i_env_param4   => com_api_type_pkg.convert_to_char(l_oper.oper_date)
                            , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                            , i_object_id    => l_oper.id
                        );
                end;
                    
                if l_original_id is not null then
                    if l_original_currency != l_oper.oper_currency then
                        com_api_error_pkg.raise_error (
                            i_error         => 'ORIGINAL_AND_REVERSAL_CURRENCY_NOTEQUAL'
                            , i_env_param1  => l_original_currency
                            , i_env_param2  => l_oper.oper_currency
                            , i_env_param3  => l_oper.originator_refnum
                        );
                    end if;
                        
                    l_oper.oper_replacement_amount := l_original_amount - l_oper.oper_amount;
                    if l_oper.oper_replacement_amount = 0 and l_original_status = opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY then
                       l_oper.status := opr_api_const_pkg.OPERATION_STATUS_MERGED;
                           
                       update
                           opr_operation
                       set
                           status = opr_api_const_pkg.OPERATION_STATUS_MERGED
                       where
                           id = l_original_id;
                    end if;
                end if;
            end if;

            if l_oper.msg_type in (opr_api_const_pkg.MESSAGE_TYPE_COMPLETION) then
                l_stage := 'get original for completion';
                begin
                    select
                        o.id
                        , p.inst_id
                        , p.network_id
                    into
                        l_original_id
                        , l_iss_part.inst_id
                        , l_iss_part.network_id
                    from
                        opr_operation o
                        , opr_participant p
                        , opr_card c
                    where
                        c.oper_id = o.id
                        and c.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                        and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                        and p.oper_id = o.id
                        and p.auth_code = l_iss_part.auth_code
                        and o.is_reversal = l_oper.is_reversal
                        and o.msg_type = opr_api_const_pkg.MESSAGE_TYPE_PREAUTHORIZATION
                        and abs(trunc(o.oper_date) - trunc(l_oper.oper_date)) <= 30
                        and reverse(c.card_number) = 
                                reverse(iss_api_token_pkg.encode_card_number(i_card_number => l_iss_part.card_number))
                        and not exists (select 1 from opr_operation o2 where o2.original_id = o.id)
                        and o.status != opr_api_const_pkg.OPERATION_STATUS_DUPLICATE;
                exception
                    when no_data_found then
                        trc_log_pkg.warn (
                            i_text           => 'ORIGINAL_OPERATION_COMPLETION_NOT_FOUND'
                            , i_env_param1   => l_iss_part.auth_code
                            , i_env_param2   => l_oper.is_reversal 
                            , i_env_param3   => iss_api_card_pkg.get_card_mask(l_iss_part.card_number)
                            , i_env_param4   => com_api_type_pkg.convert_to_char(l_oper.oper_date)
                            , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                            , i_object_id    => l_oper.id
                        );
                end;
            end if;
        end;
    begin
        l_oper.status := nvl(l_oper.status, opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY);
        
        set_original_id;
        
        l_stage := 'opr_api_create_pkg.create_operation';
        opr_api_create_pkg.create_operation (
            io_oper_id                   => l_oper.id
            , i_session_id               => get_session_id
            , i_status                   => l_oper.status
            , i_status_reason            => null
            , i_sttl_type                => l_oper.sttl_type
            , i_msg_type                 => l_oper.msg_type
            , i_oper_type                => l_oper.oper_type
            , i_oper_reason              => null
            , i_is_reversal              => l_oper.is_reversal
            , i_oper_count               => l_oper.oper_count
            , i_oper_request_amount      => l_oper.oper_request_amount
            , i_oper_cashback_amount     => l_oper.oper_cashback_amount
            , i_oper_replacement_amount  => l_oper.oper_replacement_amount
            , i_oper_surcharge_amount    => l_oper.oper_surcharge_amount
            , i_oper_amount              => l_oper.oper_amount
            , i_oper_currency            => l_oper.oper_currency
            , i_sttl_amount              => l_oper.sttl_amount
            , i_sttl_currency            => l_oper.sttl_currency
            , i_oper_date                => l_oper.oper_date
            , i_host_date                => l_oper.host_date
            , i_terminal_type            => l_oper.terminal_type
            , i_mcc                      => l_oper.mcc
            , i_originator_refnum        => l_oper.originator_refnum
            , i_network_refnum           => l_oper.network_refnum
            , i_acq_inst_bin             => l_oper.acq_inst_bin
            , i_merchant_number          => l_oper.merchant_number
            , i_terminal_number          => l_oper.terminal_number
            , i_merchant_name            => l_oper.merchant_name
            , i_merchant_street          => l_oper.merchant_street
            , i_merchant_city            => l_oper.merchant_city
            , i_merchant_region          => l_oper.merchant_region
            , i_merchant_country         => l_oper.merchant_country
            , i_merchant_postcode        => l_oper.merchant_postcode
            , i_dispute_id               => l_oper.dispute_id
            , i_match_status             => l_oper.match_status
            , i_original_id              => l_original_id
            , i_proc_mode                => l_oper.proc_mode
            , i_incom_sess_file_id       => g_session_file_id
        );

        l_stage := 'opr_api_create_pkg.add_participant issuer';
        begin
            opr_api_create_pkg.add_participant (
                i_oper_id             => l_oper.id
                , i_msg_type          => l_oper.msg_type
                , i_oper_type         => l_oper.oper_type
                , i_participant_type  => com_api_const_pkg.PARTICIPANT_ISSUER
                , i_host_date         => null
                , i_inst_id           => l_iss_part.inst_id
                , i_network_id        => l_iss_part.network_id
                , i_customer_id       => l_iss_part.customer_id
                , i_client_id_type    => opr_api_const_pkg.CLIENT_ID_TYPE_CARD
                , i_client_id_value   => null
                , i_card_id           => l_iss_part.card_id
                , i_card_type_id      => l_iss_part.card_type_id
                , i_card_expir_date   => l_iss_part.card_expir_date
                , i_card_seq_number   => l_iss_part.card_seq_number
                , i_card_service_code => l_iss_part.card_service_code
                , i_card_number       => l_iss_part.card_number
                , i_card_mask         => l_iss_part.card_mask
                , i_card_hash         => l_iss_part.card_hash
                , i_card_country      => l_iss_part.card_country
                , i_card_inst_id      => l_iss_part.card_inst_id
                , i_card_network_id   => l_iss_part.card_network_id
                , i_account_id        => null
                , i_account_number    => l_iss_part.account_number
                , i_account_type      => l_iss_part.account_type
                , i_account_amount    => null
                , i_account_currency  => null
                , i_auth_code         => l_iss_part.auth_code
                , i_split_hash        => l_iss_part.split_hash
                , i_without_checks    => com_api_const_pkg.FALSE
                , i_mask_error        => com_api_type_pkg.TRUE
            );
        exception
            when com_api_error_pkg.e_application_error then
                update
                    opr_operation
                set
                    status = decode(
                        l_oper.status
                        , opr_api_const_pkg.OPERATION_STATUS_DUPLICATE
                        , l_oper.status
                        , decode(
                        status
                        , opr_api_const_pkg.OPERATION_STATUS_UNSUCCESSFUL
                        , status
                        , opr_api_const_pkg.OPERATION_STATUS_MANUAL
                    )
                    )
                where
                    id = l_oper.id;
        end;

        l_stage := 'opr_api_create_pkg.add_participant acquirer';
        begin
            opr_api_create_pkg.add_participant (
                i_oper_id             => l_oper.id
                , i_msg_type          => l_oper.msg_type
                , i_oper_type         => l_oper.oper_type
                , i_participant_type  => com_api_const_pkg.PARTICIPANT_ACQUIRER
                , i_host_date         => null
                , i_inst_id           => l_acq_part.inst_id
                , i_network_id        => l_acq_part.network_id
                , i_account_type      => l_acq_part.account_type
                , i_account_number    => l_acq_part.account_number
                , i_merchant_id       => null
                , i_merchant_number   => l_oper.merchant_number
                , i_terminal_id       => null
                , i_terminal_number   => l_oper.terminal_number
                , i_split_hash        => null
                , i_without_checks    => com_api_const_pkg.FALSE
                , i_mask_error        => com_api_type_pkg.TRUE
            );
        exception
            when com_api_error_pkg.e_application_error then
                update
                    opr_operation
                set
                    status = decode(
                        l_oper.status
                        , opr_api_const_pkg.OPERATION_STATUS_DUPLICATE
                        , l_oper.status
                        , decode(
                        status
                        , opr_api_const_pkg.OPERATION_STATUS_UNSUCCESSFUL
                        , status
                        , opr_api_const_pkg.OPERATION_STATUS_MANUAL
                    )
                    )
                where
                    id = l_oper.id;
        end;
        
        l_stage := 'save_auth';
        l_auth.id := l_oper.id;
        l_auth.resp_code := 
        case when l_oper.status = opr_api_const_pkg.OPERATION_STATUS_UNSUCCESSFUL then
            aup_api_const_pkg.RESP_CODE_ERROR
        else
            aup_api_const_pkg.RESP_CODE_OK
        end;
        
        save_auth (
            i_auth_rec  => l_auth
        );
        
        if nvl(i_interface, aci_api_const_pkg.INTERFACE_VISA) = aci_api_const_pkg.INTERFACE_VISA then
            l_visa_basei.auth_id := l_oper.id;
            l_visa_basei.tech_id := l_oper.id;
            l_visa_basei.acq_inst_bin := l_oper.acq_inst_bin;

            l_stage := 'save_visa_basei';
            save_visa_basei (
                i_visa_basei  => l_visa_basei
            );
        end if;
        if nvl(i_interface, aci_api_const_pkg.INTERFACE_BNET) = aci_api_const_pkg.INTERFACE_BNET then
            l_stage := 'save_mastercard';
            l_aup_mastercard.auth_id := l_oper.id;
            l_aup_mastercard.tech_id := l_oper.id;
            l_aup_mastercard.acq_inst_bin := l_oper.acq_inst_bin;
            l_aup_mastercard.auth_code := l_iss_part.auth_code;

            save_mastercard (
                i_aup_mastercard  => l_aup_mastercard
            );
        end if;
        
        register_oper (
            i_oper_type    => l_oper.oper_type
            , i_sttl_type  => l_oper.sttl_type
            , i_msg_type   => l_oper.msg_type
            , i_status     => l_oper.status
        );
    exception
        when others then
            trc_log_pkg.debug (
                i_text           => 'Error create_operation on stage [#1] :[#2]'
                , i_env_param1   => l_stage
                , i_env_param2   => sqlerrm
                , i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                , i_object_id    => l_oper.id
            );
            --dbms_output.put_line(substr(i_raw_data, 1, 575));
            raise;
    end;
    
    procedure process_duplicate (
        i_raw_data              in varchar2
        , i_tlf_type            in com_api_type_pkg.t_dict_value
        , i_file_type           in com_api_type_pkg.t_dict_value
        , i_file_id             in com_api_type_pkg.t_long_id
    ) is
        l_id                    com_api_type_pkg.t_long_id;
        l_headx_dat_tim         com_api_type_pkg.t_name;
        l_cde                   com_api_type_pkg.t_tiny_id;
        l_format                com_api_type_pkg.t_byte_char;
    begin
        trc_log_pkg.debug (
            i_text          => 'Check duplicate record'
        );
        
        l_headx_dat_tim := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 1
            , i_length     => 19
        );
        
        -- Financial transaction record
        if i_tlf_type in (
          aci_api_const_pkg.REC_TYPE_CUSTOMER_TRANSACTION
        ) then
            if i_file_type = aci_api_const_pkg.FILE_TYPE_TLF then
                select
                    min(id)
                into
                    l_id
                from
                    aci_atm_fin
                where
                    headx_dat_tim = l_headx_dat_tim
                    and file_id != i_file_id;
                    
            else
                select
                    min(id)
                into
                    l_id
                from
                    aci_pos_fin
                where
                    headx_dat_tim = l_headx_dat_tim
                    and file_id != i_file_id;
                    
            end if;
            
        -- Administrative transaction record
        elsif i_tlf_type in (
          aci_api_const_pkg.REC_TYPE_ADMIN_TRANSACTION
        ) then
            if i_file_type = aci_api_const_pkg.FILE_TYPE_TLF then
                l_cde := get_field_number (
                    i_raw_data     => i_raw_data
                    , i_start_pos  => 104
                    , i_length     => 2
                );
                
                -- Terminal Cash Adjustment
                if l_cde in (1, 2, 3, 4, 7, 8) then
                    select
                        min(id)
                    into
                        l_id
                    from
                        aci_atm_cash
                    where
                        headx_dat_tim = l_headx_dat_tim
                        and file_id != i_file_id;

                -- Terminal balancing
                elsif l_cde in (5, 6, 9) then
                    select
                        min(id)
                    into
                        l_id
                    from
                        aci_atm_setl
                    where
                        headx_dat_tim = l_headx_dat_tim
                        and file_id != i_file_id;

                -- Terminal Settlement
                else
                    null;

                end if;
            else
                l_format := get_field_char (
                    i_raw_data     => i_raw_data
                    , i_start_pos  => 157
                    , i_length     => 1
                );
                
                -- Settlement Totals
                if l_format in ('0', '1', '2', '3') then
                    select
                        min(id)
                    into
                        l_id
                    from
                        aci_pos_setl
                    where
                        headx_dat_tim = l_headx_dat_tim
                        and file_id != i_file_id;

                -- Clerk Totals
                elsif l_format in ('0', '1', '2', '3') then
                    select
                        min(id)
                    into
                        l_id
                    from
                        aci_clerk_tot
                    where
                        headx_dat_tim = l_headx_dat_tim
                        and file_id != i_file_id;

                -- First/Second Services
                else
                    null;

                end if;
            end if;
            
        else
            com_api_error_pkg.raise_error (
                i_error         => 'ACI_UNKNOWN_TLF_TYPE'
                , i_env_param1  => i_tlf_type
            );
            
        end if;
        
        if l_id is not null then
            com_api_error_pkg.raise_error (
                i_error         => 'ACI_MESSAGE_ALREADY_PROCESSED'
                , i_env_param1  => l_headx_dat_tim
                , i_env_param2  => g_clob_line
                , i_env_param3  => g_file_name
            );
        end if;
    end;

    procedure process_tape_header (
        i_raw_data              in varchar2
    ) is
        l_charset               com_api_type_pkg.t_byte_char;
        l_extract_date          date;
        l_name                  com_api_type_pkg.t_name;
        l_network_id            com_api_type_pkg.t_name;
    begin
        trc_log_pkg.debug (
            i_text          => 'Process tape header'
        );
        l_charset := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 1
            , i_length     => 1
        );
        l_extract_date := get_field_date (
            i_raw_data     => i_raw_data
            , i_start_pos  => 2
            , i_length     => 12
            , i_fmt        => 'yymmddhh24miss'
        );
        l_network_id := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 16
            , i_length     => 4
        );
        l_name := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 30
            , i_length     => 35
        );
        trc_log_pkg.debug (
            i_text          => 'Process tape header: charset[#1] network_id[#2] extract_date[#3] name[#4]'
            , i_env_param1  => l_charset
            , i_env_param2  => l_network_id
            , i_env_param3  => com_api_type_pkg.convert_to_char(l_extract_date)
            , i_env_param4  => l_name
        );
    end;
        
    procedure process_tape_trailer (
        i_raw_data              in varchar2
    ) is
        l_name                  com_api_type_pkg.t_name;
        l_record_count          com_api_type_pkg.t_long_id;
    begin
        trc_log_pkg.debug (
            i_text          => 'Process tape trailer'
        );
        l_name := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 30
            , i_length     => 35
        );
        l_record_count := get_field_number (
            i_raw_data     => i_raw_data
            , i_start_pos  => 69
            , i_length     => 10
        );
        trc_log_pkg.debug (
            i_text          => 'Process tape trailer: name[#1] record_count[#2]'
            , i_env_param1  => l_name
            , i_env_param2  => l_record_count
        );
    end;
        
    procedure process_file_header (
        i_raw_data              in varchar2
        , i_session_file_id     in com_api_type_pkg.t_long_id
        , o_file_rec            out aci_api_type_pkg.t_aci_file_rec
    ) is
    begin
        trc_log_pkg.debug (
            i_text          => 'Process file header'
        );
        o_file_rec.id := aci_file_seq.nextval;
        o_file_rec.is_incoming := com_api_type_pkg.TRUE;
        o_file_rec.session_file_id := i_session_file_id;
        
        o_file_rec.extract_date := get_field_date (
            i_raw_data     => i_raw_data
            , i_start_pos  => 2
            , i_length     => 12
            , i_fmt        => 'yymmddhh24miss'
        );
        o_file_rec.network_id := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 16
            , i_length     => 4
        );
        o_file_rec.release_number := get_field_number (
            i_raw_data     => i_raw_data
            , i_start_pos  => 20
            , i_length     => 2
        );
        o_file_rec.file_type := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 22
            , i_length     => 8
        );
        o_file_rec.name := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 30
            , i_length     => 35
        );
        trc_log_pkg.debug (
            i_text          => 'Process file header: network_id[#1] release_number[#2] file_id[#3] name[#4]'
            , i_env_param1  => o_file_rec.network_id
            , i_env_param2  => o_file_rec.release_number
            , i_env_param3  => o_file_rec.file_type
            , i_env_param4  => o_file_rec.name
        );
    end;
        
    procedure process_file_trailer (
        i_raw_data              in varchar2
        , io_file_rec           in out nocopy aci_api_type_pkg.t_aci_file_rec
    ) is
        l_file_id               com_api_type_pkg.t_dict_value;
        l_name                  com_api_type_pkg.t_name;
        l_status                com_api_type_pkg.t_tiny_id;
    begin
        trc_log_pkg.debug (
            i_text          => 'Process file trailer'
        );
        
        l_file_id := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 1
            , i_length     => 8
        );
        l_name := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 9
            , i_length     => 35
        );
        l_status := get_field_number (
            i_raw_data     => i_raw_data
            , i_start_pos  => 45
            , i_length     => 5
        );
        io_file_rec.total := get_field_number (
            i_raw_data     => i_raw_data
            , i_start_pos  => 69
            , i_length     => 10
        );
        io_file_rec.amount := get_field_number (
            i_raw_data     => i_raw_data
            , i_start_pos  => 50
            , i_length     => 19
        );
        io_file_rec.impact_timestamp := to_timestamp (
            get_field_char (
                i_raw_data     => i_raw_data
                , i_start_pos  => 79
                , i_length     => 20
            ), 'yyyymmddhh24missff'
        );
        trc_log_pkg.debug (
            i_text          => 'Process file trailer: file_id[#1] name[#2] record_count[#3] status[#4]'
            , i_env_param1  => l_file_id
            , i_env_param2  => l_name
            , i_env_param3  => io_file_rec.total
            , i_env_param4  => l_status
        );
        
        insert into aci_file (
            id
            , is_incoming
            , session_file_id
            , network_id
            , extract_date
            , release_number
            , name
            , file_type
            , total
            , amount
            , impact_timestamp
        ) values (
            io_file_rec.id
            , io_file_rec.is_incoming
            , io_file_rec.session_file_id
            , io_file_rec.network_id
            , io_file_rec.extract_date
            , io_file_rec.release_number
            , io_file_rec.name
            , io_file_rec.file_type
            , io_file_rec.total
            , io_file_rec.amount
            , io_file_rec.impact_timestamp
        );

    end;
    
    procedure process_atm_fin (
        i_raw_data              in com_api_type_pkg.t_raw_data
        , i_file_id             in com_api_type_pkg.t_long_id
        , i_record_number       in com_api_type_pkg.t_long_id
    ) is
        l_card                  iss_api_type_pkg.t_card_rec;
        
        l_iss_inst_id           com_api_type_pkg.t_inst_id;
        l_acq_inst_id           com_api_type_pkg.t_inst_id;
        l_card_inst_id          com_api_type_pkg.t_inst_id;
        l_iss_network_id        com_api_type_pkg.t_tiny_id;
        l_acq_network_id        com_api_type_pkg.t_tiny_id;
        l_card_network_id       com_api_type_pkg.t_tiny_id;
        l_card_type_id          com_api_type_pkg.t_tiny_id;
        l_card_country          com_api_type_pkg.t_country_code;
        l_bin_currency          com_api_type_pkg.t_curr_code;
        l_sttl_currency         com_api_type_pkg.t_curr_code;
        l_iss_inst_id2          com_api_type_pkg.t_inst_id;
        l_iss_network_id2       com_api_type_pkg.t_tiny_id;
        l_iss_host_id           com_api_type_pkg.t_tiny_id;
        l_pan_length            com_api_type_pkg.t_tiny_id;
        l_response_code         com_api_type_pkg.t_dict_value;
        l_offline               com_api_type_pkg.t_boolean;
        l_interface             com_api_type_pkg.t_name;
        l_resp_code             com_api_type_pkg.t_byte_char;
        l_network_amount        com_api_type_pkg.t_money;
        l_network_currency      com_api_type_pkg.t_curr_code;
        l_account_type          com_api_type_pkg.t_dict_value;

        l_oper                  opr_api_type_pkg.t_oper_rec;
        l_iss_part              opr_api_type_pkg.t_oper_part_rec;
        l_acq_part              opr_api_type_pkg.t_oper_part_rec;
        l_auth                  aut_api_type_pkg.t_auth_rec;
        l_visa_basei            aup_api_type_pkg.t_aup_visa_basei_rec;
        l_aup_mastercard        aup_api_type_pkg.t_aup_mastercard_rec;
        l_fin_rec               aci_api_type_pkg.t_atm_fin_rec;
        
        l_terminal              aap_api_type_pkg.t_terminal;
        l_token_tab             aci_api_type_pkg.t_token_tab;
        
        l_params                com_api_type_pkg.t_param_tab;
        
        l_stage                 com_api_type_pkg.t_name;
    begin
        l_stage := 'create incoming message';
        process_duplicate (
            i_raw_data     => i_raw_data
            , i_tlf_type   => aci_api_const_pkg.REC_TYPE_CUSTOMER_TRANSACTION
            , i_file_type  => aci_api_const_pkg.FILE_TYPE_TLF
            , i_file_id    => i_file_id
        );
        
        l_stage := 'create incoming message';
        aci_api_fin_pkg.create_incoming_atm_message (
            i_raw_data         => i_raw_data
            , i_file_id        => i_file_id
            , i_record_number  => i_record_number
            , o_mes_rec        => l_fin_rec
        );
        
        l_stage := 'create tokens';
        aci_api_token_pkg.create_tokens (
            i_id           => l_fin_rec.id
            , i_raw_data   => substrb(i_raw_data, 574)
            , o_token_tab  => l_token_tab
        );
        
        l_oper.id := l_fin_rec.id;
        
        l_stage := 'oper type';
        l_oper.msg_type := opr_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION;
        case get_field_char(i_raw_data, 230, 2)
        when '10' then -- Withdrawal
            l_oper.oper_type := opr_api_const_pkg.OPERATION_TYPE_ATM_CASH;
            l_oper.mcc       := '6011';
           
        when '20' then -- Deposit
            l_oper.oper_type := opr_api_const_pkg.OPERATION_TYPE_CASHIN;
            l_oper.mcc       := '6012';
            
        when '30' then -- Balance Inquiry
            l_oper.oper_type := opr_api_const_pkg.OPERATION_TYPE_BALANCE_INQUIRY;
            l_oper.mcc       := '6012';
        
        when '61' then -- Log Only
            l_oper.oper_type := opr_api_const_pkg.OPERATION_TYPE_CUSTOMER_CHECK;
            l_oper.mcc       := '6012';
        
        when '81' then -- PIN change
            l_oper.oper_type := opr_api_const_pkg.OPERATION_TYPE_PIN_CHANGE;
            l_oper.mcc       := '6012';
        
        else
            --03 = Check Guarantee
            --04 = Check Verify
            --11 = Cash Check
            --24 = Deposit with Cash Back
            --40 = Transfer
            --41 = Load Value
            --50 = Payment from/to
            --51 = Payment Enclosed
            --60 = Message Enclosed to Financial Institution
            --61 = Log Only
            --62 = Card Review            
            --70 = Statement print on
            --82 = EMV PIN Unblock
            --U1 = EMV PIN Unblock
            
            trc_log_pkg.debug (
                i_text          => 'ACI_OPER_TYPE_NOT_SUPPORTED'
                , i_env_param1  => get_field_char(i_raw_data, 230, 2)
            );
            -- register excepted processed
            register_skip;
            return;
        end case;
        
        l_stage := 'response_code';
        l_response_code := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 344
            , i_length     => 3
        );
        if substr(l_response_code, -2) not in ('00', '01') then
            trc_log_pkg.debug (
                i_text          => 'ACI_OPER_RESP_CODE_NOT_SUPPORTED'
                , i_env_param1  => l_response_code
            );
            l_oper.status := opr_api_const_pkg.OPERATION_STATUS_UNSUCCESSFUL;
        end if;
        l_resp_code := substr(l_response_code, -2);
        
        l_stage := 'card_number';
        l_card.card_number := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 58
            , i_length     => 19
        );
        
        l_card := iss_api_card_pkg.get_card (
            i_card_number   => l_card.card_number
            , i_mask_error  => com_api_type_pkg.TRUE
        );
        if l_card.card_number is null then
            l_card.card_number := get_field_char (
                i_raw_data     => i_raw_data
                , i_start_pos  => 58
                , i_length     => 19
            );
        end if;
        
        l_stage := 'get_bin_info';
        iss_api_bin_pkg.get_bin_info (
            i_card_number        => l_card.card_number
            , o_iss_inst_id      => l_iss_inst_id
            , o_iss_network_id   => l_iss_network_id
            , o_card_inst_id     => l_card_inst_id
            , o_card_network_id  => l_card_network_id
            , o_card_type        => l_card_type_id
            , o_card_country     => l_card_country
            , o_bin_currency     => l_bin_currency
            , o_sttl_currency    => l_sttl_currency
        );

        l_stage := 'iss_inst_id and iss_network_id';
        l_iss_inst_id := get_inst_id (
            i_inst_id  => get_field_char (
                i_raw_data     => i_raw_data
                , i_start_pos  => 54
                , i_length     => 4
            )
        );
        l_iss_network_id := ost_api_institution_pkg.get_inst_network(l_iss_inst_id);
        l_offline := case when l_iss_inst_id is null then com_api_type_pkg.TRUE else com_api_type_pkg.FALSE end;
       
        l_stage := 'acq_inst_id and acq_network_id';
        l_acq_inst_id := get_inst_id (
            i_inst_id  => get_field_char (
                i_raw_data     => i_raw_data
                , i_start_pos  => 30
                , i_length     => 4
            )
        );
        l_acq_network_id := ost_api_institution_pkg.get_inst_network(l_acq_inst_id);
        l_oper.acq_inst_bin := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 208
            , i_length     => 11
        );
        
        l_stage := 'is_reversal and oper_count';
        l_oper.is_reversal :=
        case when get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 92
            , i_length     => 4
        ) in (aci_api_const_pkg.MESSAGE_TYPE_REVERSAL)
        then
            com_api_type_pkg.TRUE
        else
            com_api_type_pkg.FALSE
        end;
        l_oper.oper_count := 1;
        
        l_stage := 'amount and currency';
        aci_api_token_pkg.get_be_params (
            i_token_tab               => l_token_tab
            , o_oper_amount           => l_oper.oper_amount
            , o_oper_currency         => l_oper.oper_currency
            , o_oper_cashback_amount  => l_oper.oper_cashback_amount
        );
        
        if l_oper.oper_amount is null then
            if l_oper.is_reversal = com_api_type_pkg.TRUE then
                l_oper.oper_amount := 
                    get_field_number (
                        i_raw_data     => i_raw_data
                        , i_start_pos  => 276
                        , i_length     => 19
                    ) - get_field_number (
                        i_raw_data     => i_raw_data
                        , i_start_pos  => 295
                        , i_length     => 19
                    );
                l_oper.oper_currency := get_field_char (
                    i_raw_data     => i_raw_data
                    , i_start_pos  => 440
                    , i_length     => 3
                );
                l_network_amount := l_oper.oper_amount;
                l_network_currency := l_oper.oper_currency;
            else
                l_oper.oper_amount := get_field_number (
                    i_raw_data     => i_raw_data
                    , i_start_pos  => 276
                    , i_length     => 19
                );
                l_oper.oper_currency := get_field_char (
                    i_raw_data     => i_raw_data
                    , i_start_pos  => 440
                    , i_length     => 3
                );
                l_network_amount := l_oper.oper_amount;
                l_network_currency := l_oper.oper_currency;
            end if;
        else
            if l_oper.is_reversal = com_api_type_pkg.TRUE then
                l_oper.oper_amount := l_oper.oper_amount - l_oper.oper_cashback_amount;
                
                l_network_amount := 
                    get_field_number (
                        i_raw_data     => i_raw_data
                        , i_start_pos  => 276
                        , i_length     => 19
                    ) - get_field_number (
                        i_raw_data     => i_raw_data
                        , i_start_pos  => 295
                        , i_length     => 19
                    );
                l_network_currency := l_oper.oper_currency;
            else
                l_network_amount := get_field_number (
                    i_raw_data     => i_raw_data
                    , i_start_pos  => 276
                    , i_length     => 19
                );
                l_network_currency := get_field_char (
                    i_raw_data     => i_raw_data
                    , i_start_pos  => 440
                    , i_length     => 3
                );
            end if;
        end if;
        
        l_oper.oper_cashback_amount := null;
        l_oper.oper_surcharge_amount := 0;
        
        l_stage := 'oper_date';
        l_oper.oper_date         := get_field_date (
            i_raw_data     => i_raw_data
            , i_start_pos  => 157
            , i_length     => 12
            , i_fmt        => 'yymmddhh24miss'
        );
        l_oper.host_date         := null;
        
        l_stage := 'terminal_type';
        l_oper.terminal_type     := acq_api_const_pkg.TERMINAL_TYPE_ATM;
        
        l_stage := 'get_bin_info';
        if l_card_inst_id is null then
            net_api_bin_pkg.get_bin_info(
                i_card_number             => l_card.card_number
                , i_oper_type             => l_oper.oper_type
                , i_terminal_type         => l_oper.terminal_type
                , i_acq_inst_id           => l_acq_inst_id
                , i_acq_network_id        => l_acq_network_id
                , i_msg_type              => l_oper.msg_type
                , i_oper_reason           => l_oper.oper_reason
                , i_oper_currency         => l_oper.oper_currency
                , i_merchant_id           => null
                , i_terminal_id           => null
                , o_iss_inst_id           => l_iss_inst_id2
                , o_iss_network_id        => l_iss_network_id2
                , o_iss_host_id           => l_iss_host_id
                , o_card_type_id          => l_card_type_id
                , o_card_country          => l_card_country
                , o_card_inst_id          => l_card_inst_id
                , o_card_network_id       => l_card_network_id
                , o_pan_length            => l_pan_length
                , i_raise_error           => com_api_type_pkg.FALSE
            );
        end if;
        
        if l_offline = com_api_type_pkg.TRUE then
            l_iss_inst_id := l_iss_inst_id2;
            l_iss_network_id := l_iss_network_id2;
        end if;
        
        l_stage := 'terminal and merchant';
        l_oper.originator_refnum := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 189
            , i_length     => 12
        );
        l_oper.terminal_number   := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 34
            , i_length     => 16
        );
        if l_acq_inst_id = 1001 then
            l_oper.merchant_number := l_oper.terminal_number;
        else
            l_oper.merchant_number   := get_field_char (
                i_raw_data     => i_raw_data
                , i_start_pos  => 552
                , i_length     => 11
            );
        end if;
        l_oper.merchant_name     := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 372
            , i_length     => 22
        );
        l_oper.merchant_street   := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 347
            , i_length     => 25
        );
        l_oper.merchant_city     := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 394
            , i_length     => 13
        );
        l_oper.merchant_region   := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 407
            , i_length     => 3
        );
        l_oper.merchant_country  := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 410
            , i_length     => 2
        );
        if l_oper.merchant_country is not null then
            l_oper.merchant_country := com_api_country_pkg.get_country_code (
                i_visa_country_code  => l_oper.merchant_country
                , i_raise_error      => com_api_type_pkg.FALSE
            );
            l_oper.merchant_country := nvl(l_oper.merchant_country, '000');
        end if;
        l_oper.merchant_postcode := null;

        l_stage := 'dispute_id';
        l_oper.dispute_id        := null;
        l_oper.original_id       := null;
        --l_oper.proc_mode := aut_api_const_pkg.AUTH_PROC_MODE_CARD_ABSENT;
        
        l_stage := 'iss participant';
        l_iss_part.inst_id         := l_iss_inst_id;
        l_iss_part.network_id      := l_iss_network_id;
        l_iss_part.client_id_type  := opr_api_const_pkg.CLIENT_ID_TYPE_CARD;
        l_iss_part.client_id_value := l_card.card_number;
        l_iss_part.customer_id     := l_card.customer_id;
        l_iss_part.card_id         := l_card.id;
        l_iss_part.card_type_id    := l_card.card_type_id;
        l_iss_part.card_expir_date := null;--?
        l_iss_part.card_seq_number := null;-- from token b4
        l_iss_part.card_number     := l_card.card_number;
        l_iss_part.card_mask       := iss_api_card_pkg.get_card_mask(l_card.card_number);
        l_iss_part.card_country :=
        case when l_card_country is not null then
            l_card_country
        else
            l_card.country
        end;
        l_iss_part.card_inst_id     := l_card_inst_id;
        l_iss_part.card_network_id  := l_card_network_id;
        l_iss_part.account_id       := null;
        l_iss_part.account_number   := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 236
            , i_length     => 19
        );
        l_account_type   := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 232
            , i_length     => 2
        );
        l_iss_part.account_type :=
        case l_account_type
        when '00' then 'ACCT'||'0000'
        when '01' then 'ACCT'||'0020'
        when '11' then 'ACCT'||'0010'
        when '31' then 'ACCT'||'0030'
        when '70' then 'ACCT'||'0040'
        else null
        end;

        l_iss_part.account_amount   := null;
        l_iss_part.account_currency := null;
        l_iss_part.auth_code        := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 504
            , i_length     => 6
        );
        l_iss_part.split_hash       := l_card.split_hash;

        l_stage := 'acq participant';
        l_acq_part.inst_id          := l_acq_inst_id;
        l_acq_part.network_id       := l_acq_network_id;
        l_acq_part.merchant_id      := null;
        l_acq_part.terminal_id      := null;
        l_acq_part.split_hash       := null;
        l_account_type   := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 234
            , i_length     => 2
        );
        l_acq_part.account_type := 
        case l_account_type
        when '00' then 'ACCT'||'0000'
        when '01' then 'ACCT'||'0020'
        when '11' then 'ACCT'||'0010'
        when '31' then 'ACCT'||'0030'
        when '70' then 'ACCT'||'0040'
        else null
        end;
        l_acq_part.account_number   := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 256
            , i_length     => 19
        );
        l_acq_part.account_number := ltrim(l_acq_part.account_number, '0');
        
        l_stage := 'get_terminal';
        get_terminal (
            i_inst_id            => l_acq_inst_id
            , i_terminal_number  => l_oper.terminal_number
            , o_terminal_rec     => l_terminal
        );
        
        l_stage := 'set_auth';
        set_auth (
            o_auth        => l_auth
            , i_terminal  => l_terminal
        );
        l_stage := 'network_amount';
        l_auth.network_amount := l_network_amount;
        l_auth.network_currency := l_network_currency;
        
        l_auth.pin_presence := 'PINP0001';
        l_auth.cvv2_presence := 'CV2P0002';
        
        l_stage := 'format_emv_data';
        l_auth.emv_data := aci_api_token_pkg.format_emv_data (
            i_token_tab  => l_token_tab
        );
        l_auth.card_data_input_mode := case
                                           when l_auth.emv_data is not null
                                           then
                                               case when l_offline = com_api_type_pkg.FALSE
                                                   then 'F227000C'
                                                   else 'F227000F'
                                               end
                                           else
                                               'F227000B'
                                       end;
        
        l_stage := 'get_b1_params';
        aci_api_token_pkg.get_b1_params (
            i_token_tab           => l_token_tab
            , o_pos_entry_mode    => l_auth.pos_entry_mode
            , o_cvr               => l_auth.cvr
            , o_ecom_sec_lvl_ind  => l_aup_mastercard.eci
            , o_trace             => l_visa_basei.trace
            , o_interface         => l_interface
            , io_resp_code        => l_resp_code
        );
        
        case l_interface
        when aci_api_const_pkg.INTERFACE_BNET then
            l_aup_mastercard.resp_code := l_resp_code;
        when aci_api_const_pkg.INTERFACE_VISA then
            l_visa_basei.resp_code := l_resp_code;
        else
            l_aup_mastercard.resp_code := l_resp_code;
            l_visa_basei.resp_code := l_resp_code;
        end case;
        
        l_stage := 'get_b4_params';
        aci_api_token_pkg.get_b4_params (
            i_token_tab           => l_token_tab
            , i_pin_present       => com_api_type_pkg.TRUE
            , i_cat_level         => l_auth.cat_level
            , i_iss_inst_id       => get_field_char (i_raw_data, 54, 4)
            , io_pos_entry_mode   => l_auth.pos_entry_mode
            , o_crdh_auth_method  => l_auth.crdh_auth_method
            , o_crdh_auth_entity  => l_auth.crdh_auth_entity
            , o_card_seq_number   => l_iss_part.card_seq_number
        );
        
        l_stage := 'get_20_params';
        aci_api_token_pkg.get_20_params (
            i_token_tab         => l_token_tab
            , o_network_refnum  => l_oper.network_refnum
        );
        
        l_auth.crdh_auth_method := 'F2280001';
        l_auth.crdh_auth_entity := 'F2290003';
        
        rul_api_param_pkg.set_param (
            i_name          => 'TERMINAL_ID'
            , i_value       => l_terminal.id
            , io_params     => l_params
        );

        l_stage := 'get_sttl_type';
        net_api_sttl_pkg.get_sttl_type (
            i_iss_inst_id        => l_iss_inst_id
            , i_acq_inst_id      => l_acq_inst_id
            , i_card_inst_id     => l_card_inst_id
            , i_iss_network_id   => l_iss_network_id
            , i_acq_network_id   => l_acq_network_id
            , i_card_network_id  => l_card_network_id
            , i_acq_inst_bin     => l_oper.acq_inst_bin
            , o_sttl_type        => l_oper.sttl_type
            , o_match_status     => l_oper.match_status
            , i_params           => l_params
            , i_mask_error       => com_api_type_pkg.TRUE
            , i_oper_type        => l_oper.oper_type
        );
        
        l_auth.is_advice := l_offline;
        
        l_stage := 'create_operation';
        create_operation (
            i_oper              => l_oper
            , i_iss_part        => l_iss_part
            , i_acq_part        => l_acq_part
            , i_auth            => l_auth
            , i_visa_basei      => l_visa_basei
            , i_aup_mastercard  => l_aup_mastercard
            , i_interface       => l_interface
        );
        
        -- register successed processed
        register_ok;
    exception
        when others then
            trc_log_pkg.error (
                i_text          => 'Error processing ATM customer transaction on stage [#1] line[#3] of file[#4]:[#2]'
                , i_env_param1  => l_stage
                , i_env_param2  => sqlerrm
                , i_env_param3  => g_clob_line
                , i_env_param4  => g_file_name
            );
            raise;
    end;
    
    procedure process_atm_adm (
        i_raw_data              in com_api_type_pkg.t_raw_data
        , i_file_id             in com_api_type_pkg.t_long_id
        , i_record_number       in com_api_type_pkg.t_long_id
    ) is
        l_cde                   com_api_type_pkg.t_tiny_id;
        
        l_card                  iss_api_type_pkg.t_card_rec;
        
        l_iss_inst_id           com_api_type_pkg.t_inst_id;
        l_acq_inst_id           com_api_type_pkg.t_inst_id;
        l_card_inst_id          com_api_type_pkg.t_inst_id;
        l_iss_network_id        com_api_type_pkg.t_tiny_id;
        l_acq_network_id        com_api_type_pkg.t_tiny_id;
        l_card_network_id       com_api_type_pkg.t_tiny_id;
        l_card_type_id          com_api_type_pkg.t_tiny_id;
        l_card_country          com_api_type_pkg.t_country_code;
        l_bin_currency          com_api_type_pkg.t_curr_code;
        l_sttl_currency         com_api_type_pkg.t_curr_code;
        l_iss_inst_id2          com_api_type_pkg.t_inst_id;
        l_iss_network_id2       com_api_type_pkg.t_tiny_id;
        l_iss_host_id           com_api_type_pkg.t_tiny_id;
        l_pan_length            com_api_type_pkg.t_tiny_id;
        l_offline               com_api_type_pkg.t_boolean;
        l_exponent              com_api_type_pkg.t_tiny_id;
        l_interface             com_api_type_pkg.t_name;
        
        l_oper                  opr_api_type_pkg.t_oper_rec;
        l_iss_part              opr_api_type_pkg.t_oper_part_rec;
        l_acq_part              opr_api_type_pkg.t_oper_part_rec;
        l_auth                  aut_api_type_pkg.t_auth_rec;
        l_visa_basei            aup_api_type_pkg.t_aup_visa_basei_rec;
        l_aup_mastercard        aup_api_type_pkg.t_aup_mastercard_rec;
        l_setl_rec              aci_api_type_pkg.t_atm_setl_rec;
        l_setl_ttl_rec          aci_api_type_pkg.t_atm_setl_ttl_rec;
        l_cash_rec              aci_api_type_pkg.t_atm_cash_rec;
        l_hopr_tab              aci_api_type_pkg.t_atm_setl_hopr_tab;
        
        l_terminal              aap_api_type_pkg.t_terminal;
        l_token_tab             aci_api_type_pkg.t_token_tab;
        l_params                com_api_type_pkg.t_param_tab;
        
        l_stage                 com_api_type_pkg.t_name;
    begin
        l_stage := 'check_fin_duplicate';
        process_duplicate (
            i_raw_data     => i_raw_data
            , i_tlf_type   => aci_api_const_pkg.REC_TYPE_ADMIN_TRANSACTION
            , i_file_type  => aci_api_const_pkg.FILE_TYPE_TLF
            , i_file_id    => i_file_id
        );
        
        -- Terminal balancing records are identified by a value of
        -- 04 in the REC-TYP field in the TLF header. These
        -- records are further identified by values of 05, 06, or 
        -- 09 in the TERM-SETL.ADMIN-CDE field
            
        -- Terminal Cash Adjustment records are identified
        -- by a value of 04 in the REC-TYP field in the TLF
        -- header. These records are further identified by values
        -- of 01, 02, 03, 04, 07, or 08 in the TERM-CASH.ADMIN-CDE field.
            
        -- Terminal Settlement records are identified by a
        -- value of 04 in the REC-TYP field in the TLF header.
        -- These records are further identified by values of 20,
        -- 21, or 22 in the SETL-TTL.ADMIN-CDE field.
        l_stage := 'get cde';
        l_cde := get_field_number (
            i_raw_data     => i_raw_data
            , i_start_pos  => 104
            , i_length     => 2
        );
        
        l_stage := 'create incoming message';
        -- Terminal Cash Adjustment
        if l_cde in (1, 2, 3, 4, 7, 8) then
            aci_api_adm_pkg.create_incoming_cash (
                i_raw_data         => i_raw_data
                , i_file_id        => i_file_id
                , i_record_number  => i_record_number
                , o_mes_rec        => l_cash_rec
            );
            
            l_oper.id := l_cash_rec.id;
        
            l_stage := 'create tokens';
            aci_api_token_pkg.create_tokens (
                i_id           => l_oper.id
                , i_raw_data   => substrb(i_raw_data, 150)
                , o_token_tab  => l_token_tab
            );

        -- Terminal balancing
        elsif l_cde in (5, 6, 9) then
            aci_api_adm_pkg.create_incoming_setl (
                i_raw_data         => i_raw_data
                , i_file_id        => i_file_id
                , i_record_number  => i_record_number
                , o_mes_rec        => l_setl_rec
                , o_hopr_tab       => l_hopr_tab
            );
            
            l_oper.id := l_setl_rec.id;
        
            l_stage := 'create tokens';
            aci_api_token_pkg.create_tokens (
                i_id           => l_oper.id
                , i_raw_data   => substrb(i_raw_data, 856)
                , o_token_tab  => l_token_tab
            );

        -- Terminal Settlement
        else
            aci_api_adm_pkg.create_incoming_setl_ttl (
                i_raw_data         => i_raw_data
                , i_file_id        => i_file_id
                , i_record_number  => i_record_number
                , o_mes_rec        => l_setl_ttl_rec
            );

            l_oper.id := l_setl_ttl_rec.id;
            
            l_stage := 'create tokens';
            aci_api_token_pkg.create_tokens (
                i_id           => l_oper.id
                , i_raw_data   => substrb(i_raw_data, 182)
                , o_token_tab  => l_token_tab
            );

        end if;
        
        l_stage := 'card_number';
        l_card.card_number := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 58
            , i_length     => 19
        );
        
        l_card := iss_api_card_pkg.get_card (
            i_card_number   => l_card.card_number
            , i_mask_error  => com_api_type_pkg.TRUE
        );
        if l_card.card_number is null then
            l_card.card_number := get_field_char (
                i_raw_data     => i_raw_data
                , i_start_pos  => 58
                , i_length     => 19
            );
        end if;
        
        l_stage := 'get_bin_info';
        iss_api_bin_pkg.get_bin_info (
            i_card_number        => l_card.card_number
            , o_iss_inst_id      => l_iss_inst_id
            , o_iss_network_id   => l_iss_network_id
            , o_card_inst_id     => l_card_inst_id
            , o_card_network_id  => l_card_network_id
            , o_card_type        => l_card_type_id
            , o_card_country     => l_card_country
            , o_bin_currency     => l_bin_currency
            , o_sttl_currency    => l_sttl_currency
        );

        l_stage := 'iss_inst_id and iss_network_id';
        l_iss_inst_id := get_inst_id (
            i_inst_id  => get_field_char (
                i_raw_data     => i_raw_data
                , i_start_pos  => 54
                , i_length     => 4
            )
        );
        l_iss_network_id := ost_api_institution_pkg.get_inst_network(l_iss_inst_id);
        l_offline := case when l_iss_inst_id is null then com_api_type_pkg.TRUE else com_api_type_pkg.FALSE end;
        
        l_stage := 'acq_inst_id and acq_network_id';
        l_acq_inst_id := get_inst_id (
            i_inst_id  => get_field_char (
                i_raw_data     => i_raw_data
                , i_start_pos  => 30
                , i_length     => 4
            )
        );
        l_acq_network_id := ost_api_institution_pkg.get_inst_network(l_acq_inst_id);
        
        l_stage := 'msg_type and oper_type';
        l_oper.msg_type := opr_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION;
        l_oper.oper_type :=
        case
        -- Terminal Cash Adjustment records
        when l_cde in (1, 2, 3, 4, 7, 8) then
            opr_api_const_pkg.OPERATION_TYPE_ATM_CASH_ADJST
            
        -- Terminal balancing records
        when l_cde in (5, 6, 9) then
            opr_api_const_pkg.OPERATION_TYPE_ATM_SETTLEMENT
            
        -- Terminal Settlement records
        when l_cde in (20, 21, 22) then
            opr_api_const_pkg.OPERATION_TYPE_ATM_RESET
            
        else
            null
        end;
        
        l_stage := 'reversal and oper_count';
        l_oper.is_reversal := com_api_type_pkg.FALSE;
        l_oper.oper_count := 1;
        
        l_stage := 'amount and currency';
        -- Terminal balancing records
        if l_cde in (5, 6, 9) then
            l_oper.oper_currency := get_field_char (
                i_raw_data     => i_raw_data
                , i_start_pos  => 828
                , i_length     => 3
            );
            -- amount that was taken from hoppers
            for i in 1..l_hopr_tab.count loop
                l_oper.oper_currency := l_hopr_tab(i).term_setl_hopr_crncy_cde;
                l_exponent := com_api_currency_pkg.get_currency_exponent (
                    i_curr_code  => l_oper.oper_currency
                );
                l_oper.oper_amount := nvl(l_oper.oper_amount, 0) + to_number(l_hopr_tab(i).term_setl_hopr_end_cash) * power(10, l_exponent);
            end loop;
            
        -- Terminal Cash Adjustment records
        elsif l_cde in (1, 2, 3, 4, 7, 8) then
            l_oper.oper_amount := get_field_number (
                i_raw_data     => i_raw_data
                , i_start_pos  => 109
                , i_length     => 12
            );

            l_oper.oper_currency := get_field_char (
                i_raw_data     => i_raw_data
                , i_start_pos  => 121
                , i_length     => 3
            );
            l_exponent := com_api_currency_pkg.get_currency_exponent (
                i_curr_code  => l_oper.oper_currency
            );
            l_oper.oper_amount := l_oper.oper_amount * power(10, l_exponent);
        
        -- Terminal Settlement records
        elsif l_cde in (20, 21, 22) then
            l_oper.oper_amount := get_field_number (
                i_raw_data     => i_raw_data
                , i_start_pos  => 118
                , i_length     => 12
            );

            l_oper.oper_currency := get_field_char (
                i_raw_data     => i_raw_data
                , i_start_pos  => 154
                , i_length     => 3
            );
        end if;
        
        l_stage := 'oper_date';
        l_oper.oper_date := get_field_date (
            i_raw_data     => i_raw_data
            , i_start_pos  => 90
            , i_length     => 12
            , i_fmt        => 'yymmddhh24miss'
        );
        l_oper.host_date         := null;
        
        l_stage := 'terminal_type';
        l_oper.terminal_type     := acq_api_const_pkg.TERMINAL_TYPE_ATM;
        
        l_stage := 'get_bin_info';
        if l_card_inst_id is null then
            net_api_bin_pkg.get_bin_info(
                i_card_number             => l_card.card_number
                , i_oper_type             => l_oper.oper_type
                , i_terminal_type         => l_oper.terminal_type
                , i_acq_inst_id           => l_acq_inst_id
                , i_acq_network_id        => l_acq_network_id
                , i_msg_type              => l_oper.msg_type
                , i_oper_reason           => l_oper.oper_reason
                , i_oper_currency         => l_oper.oper_currency
                , i_merchant_id           => null
                , i_terminal_id           => null
                , o_iss_inst_id           => l_iss_inst_id2
                , o_iss_network_id        => l_iss_network_id2
                , o_iss_host_id           => l_iss_host_id
                , o_card_type_id          => l_card_type_id
                , o_card_country          => l_card_country
                , o_card_inst_id          => l_card_inst_id
                , o_card_network_id       => l_card_network_id
                , o_pan_length            => l_pan_length
                , i_raise_error           => com_api_type_pkg.FALSE
            );
        end if;
        
        if l_offline = com_api_type_pkg.TRUE then
            l_iss_inst_id := l_iss_inst_id2;
            l_iss_network_id := l_iss_network_id2;
        end if;
        
        l_stage := 'terminal and merchant';
        l_oper.mcc               := '6011';--?
        l_oper.originator_refnum := null;
        l_oper.merchant_number   := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 34
            , i_length     => 16
        );
        l_oper.terminal_number   := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 34
            , i_length     => 16
        );
        
        l_stage := 'dispute_id';
        l_oper.dispute_id        := null;
        l_oper.original_id       := null;
        --l_oper.proc_mode := aut_api_const_pkg.AUTH_PROC_MODE_CARD_ABSENT;
        
        l_stage := 'iss participant';
        l_iss_part.inst_id         := l_iss_inst_id;
        l_iss_part.network_id      := l_iss_network_id;
        l_iss_part.client_id_type  := opr_api_const_pkg.CLIENT_ID_TYPE_CARD;
        l_iss_part.client_id_value := l_card.card_number;
        l_iss_part.customer_id     := l_card.customer_id;
        l_iss_part.card_id         := l_card.id;
        l_iss_part.card_type_id    := l_card.card_type_id;
        l_iss_part.card_expir_date := null;--?
        l_iss_part.card_seq_number := null;-- from token b4
        l_iss_part.card_number     := l_card.card_number;
        l_iss_part.card_mask       := iss_api_card_pkg.get_card_mask(l_card.card_number);
        l_iss_part.card_country :=
        case when l_card_country is not null then
            l_card_country
        else
            l_card.country
        end;
        l_iss_part.card_inst_id     := l_card_inst_id;
        l_iss_part.card_network_id  := l_card_network_id;
        l_iss_part.account_id       := null;
        l_iss_part.account_number   := null;
        l_iss_part.account_amount   := null;
        l_iss_part.account_currency := null;
        l_iss_part.auth_code        := null;--?
        l_iss_part.split_hash       := l_card.split_hash;

        l_stage := 'acq participant';
        l_acq_part.inst_id          := l_acq_inst_id;
        l_acq_part.network_id       := l_acq_network_id;
        l_acq_part.merchant_id      := null;
        l_acq_part.terminal_id      := null;
        l_acq_part.split_hash       := null;
        l_acq_part.account_number   := null;
        
        l_stage := 'get_terminal';
        get_terminal (
            i_inst_id            => l_acq_inst_id
            , i_terminal_number  => l_oper.terminal_number
            , o_terminal_rec     => l_terminal
        );
        
        l_stage := 'set_auth';
        set_auth (
            o_auth        => l_auth
            , i_terminal  => l_terminal
        );
        
        l_stage := 'format_emv_data';
        l_auth.emv_data := aci_api_token_pkg.format_emv_data (
            i_token_tab  => l_token_tab
        );
        
        l_auth.pin_presence         := 'PINP0001';
        l_auth.cvv2_presence        := 'CV2P0002';
        l_auth.card_data_input_mode := case
                                           when l_auth.emv_data is not null then
                                           case when l_offline = com_api_type_pkg.FALSE
                                               then 'F227000C'
                                               else 'F227000F'
                                           end
                                       else
                                           'F227000B'
                                       end;
        
        l_stage := 'get_b4_params';
        aci_api_token_pkg.get_b4_params (
            i_token_tab           => l_token_tab
            , i_pin_present       => com_api_type_pkg.TRUE
            , i_cat_level         => l_auth.cat_level
            , i_iss_inst_id       => get_field_char (i_raw_data, 54, 4)
            , io_pos_entry_mode   => l_auth.pos_entry_mode
            , o_crdh_auth_method  => l_auth.crdh_auth_method
            , o_crdh_auth_entity  => l_auth.crdh_auth_entity
            , o_card_seq_number   => l_iss_part.card_seq_number
        );
        
        l_stage := 'get_20_params';
        aci_api_token_pkg.get_20_params (
            i_token_tab         => l_token_tab
            , o_network_refnum  => l_oper.network_refnum
        );
        
        l_auth.crdh_auth_method := 'F2280001';
        l_auth.crdh_auth_entity := 'F2290003';
        
        rul_api_param_pkg.set_param (
            i_name          => 'TERMINAL_ID'
            , i_value       => l_terminal.id
            , io_params     => l_params
        );

        l_stage := 'get_sttl_type';
        net_api_sttl_pkg.get_sttl_type (
            i_iss_inst_id        => l_iss_inst_id
            , i_acq_inst_id      => l_acq_inst_id
            , i_card_inst_id     => l_card_inst_id
            , i_iss_network_id   => l_iss_network_id
            , i_acq_network_id   => l_acq_network_id
            , i_card_network_id  => l_card_network_id
            , i_acq_inst_bin     => l_acq_inst_id
            , o_sttl_type        => l_oper.sttl_type
            , o_match_status     => l_oper.match_status
            , i_params           => l_params
            , i_mask_error       => com_api_type_pkg.TRUE
            , i_oper_type        => l_oper.oper_type
        );
        
        l_auth.is_advice := l_offline;
        
        l_stage := 'create_operation';
        create_operation (
            i_oper              => l_oper
            , i_iss_part        => l_iss_part
            , i_acq_part        => l_acq_part
            , i_auth            => l_auth
            , i_visa_basei      => l_visa_basei
            , i_aup_mastercard  => l_aup_mastercard
            , i_interface       => l_interface
        );
        
        -- register successed processed
        register_ok;
    exception
        when others then
            trc_log_pkg.error (
                i_text          => 'Error processing ATM administrative transaction on stage [#1] line[#3] of file[#4]: [#2]'
                , i_env_param1  => l_stage
                , i_env_param2  => sqlerrm
                , i_env_param3  => g_clob_line
                , i_env_param4  => g_file_name
            );
            raise;
    end;
    
    procedure process_pos_fin (
        i_raw_data              in com_api_type_pkg.t_raw_data
        , i_file_id             in com_api_type_pkg.t_long_id
        , i_record_number       in com_api_type_pkg.t_long_id
    ) is
        l_card                  iss_api_type_pkg.t_card_rec;
        
        l_iss_inst_id           com_api_type_pkg.t_inst_id;
        l_acq_inst_id           com_api_type_pkg.t_inst_id;
        l_card_inst_id          com_api_type_pkg.t_inst_id;
        l_iss_network_id        com_api_type_pkg.t_tiny_id;
        l_acq_network_id        com_api_type_pkg.t_tiny_id;
        l_card_network_id       com_api_type_pkg.t_tiny_id;
        l_card_type_id          com_api_type_pkg.t_tiny_id;
        l_card_country          com_api_type_pkg.t_country_code;
        l_bin_currency          com_api_type_pkg.t_curr_code;
        l_sttl_currency         com_api_type_pkg.t_curr_code;
        l_auth_code_length      com_api_type_pkg.t_tiny_id;
        l_dft_capture           com_api_type_pkg.t_tiny_id;
        l_iss_inst_id2          com_api_type_pkg.t_inst_id;
        l_iss_network_id2       com_api_type_pkg.t_tiny_id;
        l_iss_host_id           com_api_type_pkg.t_tiny_id;
        l_pan_length            com_api_type_pkg.t_tiny_id;
        l_response_code         com_api_type_pkg.t_dict_value;
        l_offline               com_api_type_pkg.t_boolean;
        l_pin_present           com_api_type_pkg.t_boolean;
        l_interface             com_api_type_pkg.t_name;
        l_card_expir_date       com_api_type_pkg.t_name;
        l_resp_code             com_api_type_pkg.t_byte_char;
        l_network_amount        com_api_type_pkg.t_money;
        l_network_currency      com_api_type_pkg.t_curr_code;
        l_auth_code             com_api_type_pkg.t_auth_code;
        
        l_oper                  opr_api_type_pkg.t_oper_rec;
        l_iss_part              opr_api_type_pkg.t_oper_part_rec;
        l_acq_part              opr_api_type_pkg.t_oper_part_rec;
        l_auth                  aut_api_type_pkg.t_auth_rec;
        l_visa_basei            aup_api_type_pkg.t_aup_visa_basei_rec;
        l_aup_mastercard        aup_api_type_pkg.t_aup_mastercard_rec;
        l_fin_rec               aci_api_type_pkg.t_pos_fin_rec;
        
        l_terminal              aap_api_type_pkg.t_terminal;
        l_token_tab             aci_api_type_pkg.t_token_tab;
        l_params                com_api_type_pkg.t_param_tab;
        
        l_stage                 com_api_type_pkg.t_name;
    begin
        l_stage := 'check_fin_duplicate';
        process_duplicate (
            i_raw_data     => i_raw_data
            , i_tlf_type   => aci_api_const_pkg.REC_TYPE_CUSTOMER_TRANSACTION
            , i_file_type  => aci_api_const_pkg.FILE_TYPE_PTLF
            , i_file_id    => i_file_id
        );
        
        l_stage := 'create incoming message';
        aci_api_fin_pkg.create_incoming_pos_message (
            i_raw_data         => i_raw_data
            , i_file_id        => i_file_id
            , i_record_number  => i_record_number
            , o_mes_rec        => l_fin_rec
        );
        
        l_stage := 'create tokens';
        aci_api_token_pkg.create_tokens (
            i_id           => l_fin_rec.id
            , i_raw_data   => substrb(i_raw_data, 1070)
            , o_token_tab  => l_token_tab
        );
        
        l_oper.id := l_fin_rec.id;
        
        /*trc_log_pkg.info (
            i_text          => 'Create pos message: oper_id[#1] card_number[#2] inst_id[#3] [#4][#5]'
            , i_env_param1  => l_oper.id
            , i_env_param2  => l_fin_rec.headx_crd_card_crd_num
            , i_env_param3  => l_fin_rec.headx_crd_fiid
            , i_env_param4  => l_fin_rec.authx_amt_1
            , i_env_param5  => l_fin_rec.authx_amt_2
        );*/
        
        l_stage := 'msg_type and reversal';
        l_oper.msg_type := opr_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION;
        l_oper.is_reversal :=
            case when get_field_char (
                i_raw_data     => i_raw_data
                , i_start_pos  => 184
                , i_length     => 4
            ) in (aci_api_const_pkg.MESSAGE_TYPE_REVERSAL)
            then
                com_api_type_pkg.TRUE
            else
                com_api_type_pkg.FALSE
            end;
        
        l_stage := 'dft_capture';
        l_dft_capture := get_field_number (
            i_raw_data     => i_raw_data
            , i_start_pos  => 650
            , i_length     => 1
        );
        
        l_stage := 'oper_type';
        case get_field_char(i_raw_data, 426, 2)
        when '10' then -- Normal purchase
            l_oper.oper_type := opr_api_const_pkg.OPERATION_TYPE_PURCHASE;
            l_oper.msg_type :=
            case l_dft_capture
            when 0 then opr_api_const_pkg.MESSAGE_TYPE_PREAUTHORIZATION
            when 1 then opr_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION
            when 2 then opr_api_const_pkg.MESSAGE_TYPE_PREAUTHORIZATION
            else opr_api_const_pkg.MESSAGE_TYPE_COMPLETION
            end;
            
        when '11' then -- Preauthorization purchase
            l_oper.oper_type := opr_api_const_pkg.OPERATION_TYPE_PURCHASE;
            l_oper.msg_type  := opr_api_const_pkg.MESSAGE_TYPE_PREAUTHORIZATION;
            
        when '12' then -- Preauthorization purchase completion
            l_oper.oper_type := opr_api_const_pkg.OPERATION_TYPE_PURCHASE;
            l_oper.msg_type  := opr_api_const_pkg.MESSAGE_TYPE_COMPLETION;
        
        when '13' then -- Mail/phone order + Card data input mode ???
            l_oper.oper_type := opr_api_const_pkg.OPERATION_TYPE_PURCHASE;
            l_oper.msg_type :=
            case l_dft_capture
            when 0 then opr_api_const_pkg.MESSAGE_TYPE_PREAUTHORIZATION
            when 1 then opr_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION
            when 2 then opr_api_const_pkg.MESSAGE_TYPE_PREAUTHORIZATION
            else opr_api_const_pkg.MESSAGE_TYPE_COMPLETION
            end;
        
        when '14' then -- Merchandise return
            l_oper.oper_type := opr_api_const_pkg.OPERATION_TYPE_REFUND;
            
        when '15' then -- Cash advance
            l_oper.oper_type := opr_api_const_pkg.OPERATION_TYPE_POS_CASH;
        
        when '16' then -- Card verification
            l_oper.oper_type := opr_api_const_pkg.OPERATION_TYPE_CUSTOMER_CHECK;
            
        when '17' then -- Balance inquiry
            l_oper.oper_type := opr_api_const_pkg.OPERATION_TYPE_BALANCE_INQUIRY;
            
        when '18' then -- Purchase with cash back
            l_oper.oper_type := opr_api_const_pkg.OPERATION_TYPE_CASHBACK;
            l_oper.msg_type :=
            case l_dft_capture
            when 0 then opr_api_const_pkg.MESSAGE_TYPE_PREAUTHORIZATION
            when 1 then opr_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION
            when 2 then opr_api_const_pkg.MESSAGE_TYPE_PREAUTHORIZATION
            else opr_api_const_pkg.MESSAGE_TYPE_COMPLETION
            end;
            
        when '21' then -- Purchase adjustment
            l_oper.oper_type := opr_api_const_pkg.OPERATION_TYPE_REFUND;
            l_oper.msg_type :=
            case l_dft_capture
            when 0 then opr_api_const_pkg.MESSAGE_TYPE_PREAUTHORIZATION
            when 1 then opr_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION
            when 2 then opr_api_const_pkg.MESSAGE_TYPE_PREAUTHORIZATION
            else opr_api_const_pkg.MESSAGE_TYPE_COMPLETION
            end;
            
        /*when '22' then -- Adjustment - merchandise return
            if get_field_char (i_raw_data, 713, 1) = '0' then
                l_oper.oper_type := opr_api_const_pkg.OPERATION_TYPE_DEBIT_ADJUST;
            else
                l_oper.oper_type := opr_api_const_pkg.OPERATION_TYPE_CREDIT_ADJUST;
            end if;
            
        when '23' then -- Adjustment - cash advance
            if get_field_char (i_raw_data, 713, 1) = '0' then
                l_oper.oper_type := opr_api_const_pkg.OPERATION_TYPE_DEBIT_ADJUST;
            else
                l_oper.oper_type := opr_api_const_pkg.OPERATION_TYPE_CREDIT_ADJUST;
            end if;
            
        when '24' then -- Adjustment - purchase with cash back
            if get_field_char (i_raw_data, 713, 1) = '0' then
                l_oper.oper_type := opr_api_const_pkg.OPERATION_TYPE_DEBIT_ADJUST;
            else
                l_oper.oper_type := opr_api_const_pkg.OPERATION_TYPE_CREDIT_ADJUST;
            end if;*/

        else
            --19 = Check verification
            --20 = Check guarantee
            
            trc_log_pkg.debug (
                i_text          => 'ACI_OPER_TYPE_NOT_SUPPORTED'
                , i_env_param1  => get_field_char(i_raw_data, 426, 2)
            );
            -- register excepted processed
            register_skip;
            return;
        end case;
        
        l_stage := 'mcc';
        l_oper.mcc := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 414
            , i_length     => 4
        );
        aci_api_util_pkg.get_oper_type (
            io_oper_type    => l_oper.oper_type
            , i_mcc         => l_oper.mcc
            , i_mask_error  => com_api_type_pkg.TRUE
        );
        
        l_stage := 'response_code';
        l_response_code := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 453
            , i_length     => 3
        );
        if l_response_code not in ('000', '001', '002', '003', '004', '005', '006', '007', '008', '009') then
            trc_log_pkg.debug (
                i_text          => 'ACI_OPER_RESP_CODE_NOT_SUPPORTED'
                , i_env_param1  => l_response_code
            );
            l_oper.status := opr_api_const_pkg.OPERATION_STATUS_UNSUCCESSFUL;
        end if;
        l_resp_code := substr(l_response_code, 1, 2);
        
        l_stage := 'auth_code';
        l_auth_code_length := get_field_number (
            i_raw_data     => i_raw_data
            , i_start_pos  => 617
            , i_length     => 1
        );
        l_auth_code        := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 609
            , i_length     => l_auth_code_length
        );
        
        l_stage := 'card_number';
        l_card.card_number := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 30
            , i_length     => 19
        );
        
        l_card := iss_api_card_pkg.get_card (
            i_card_number   => l_card.card_number
            , i_mask_error  => com_api_type_pkg.TRUE
        );
        if l_card.card_number is null then
            l_card.card_number := get_field_char (
                i_raw_data     => i_raw_data
                , i_start_pos  => 30
                , i_length     => 19
            );
        end if;
        
        l_stage := 'get_bin_info';
        iss_api_bin_pkg.get_bin_info (
            i_card_number        => l_card.card_number
            , o_iss_inst_id      => l_iss_inst_id
            , o_iss_network_id   => l_iss_network_id
            , o_card_inst_id     => l_card_inst_id
            , o_card_network_id  => l_card_network_id
            , o_card_type        => l_card_type_id
            , o_card_country     => l_card_country
            , o_bin_currency     => l_bin_currency
            , o_sttl_currency    => l_sttl_currency
        );
        
        l_stage := 'iss_inst_id and iss_network_id';
        l_iss_inst_id := get_inst_id (
            i_inst_id  => get_field_char (
                i_raw_data     => i_raw_data
                , i_start_pos  => 26
                , i_length     => 4
            )
        );
        l_iss_network_id := ost_api_institution_pkg.get_inst_network(l_iss_inst_id);
        l_offline := case when l_iss_inst_id is null then com_api_type_pkg.TRUE else com_api_type_pkg.FALSE end;
        
        l_stage := 'acq_inst_id and acq_network_id';
        l_acq_inst_id := get_inst_id (
            i_inst_id  => get_field_char (
                i_raw_data     => i_raw_data
                , i_start_pos  => 113
                , i_length     => 4
            )
        );
        l_acq_network_id := ost_api_institution_pkg.get_inst_network(l_acq_inst_id);
        l_oper.acq_inst_bin := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 372
            , i_length     => 11
        );
        
        l_oper.oper_count := 1;

        l_stage := 'amount and currency';
        aci_api_token_pkg.get_be_params (
            i_token_tab               => l_token_tab
            , o_oper_amount           => l_oper.oper_amount
            , o_oper_currency         => l_oper.oper_currency
            , o_oper_cashback_amount  => l_oper.oper_cashback_amount
        );

        if l_oper.oper_amount is null then
            if l_oper.is_reversal = com_api_type_pkg.TRUE then
                l_oper.oper_amount := get_field_number (
                    i_raw_data     => i_raw_data
                    , i_start_pos  => 456
                    , i_length     => 19
                );
                l_oper.oper_currency := get_field_char (
                    i_raw_data     => i_raw_data
                    , i_start_pos  => 663
                    , i_length     => 3
                );
                l_oper.oper_replacement_amount := get_field_number (
                    i_raw_data     => i_raw_data
                    , i_start_pos  => 475
                    , i_length     => 19
                );
                l_network_amount := l_oper.oper_amount;
                l_network_currency := l_oper.oper_currency;
            else
                l_oper.oper_amount := get_field_number (
                    i_raw_data     => i_raw_data
                    , i_start_pos  => 456
                    , i_length     => 19
                );
                l_oper.oper_currency := get_field_char (
                    i_raw_data     => i_raw_data
                    , i_start_pos  => 663
                    , i_length     => 3
                );
                l_network_amount := l_oper.oper_amount;
                l_network_currency := l_oper.oper_currency;
            end if;
        else
            if l_oper.is_reversal = com_api_type_pkg.TRUE then
                l_network_amount := get_field_number (
                    i_raw_data     => i_raw_data
                    , i_start_pos  => 456
                    , i_length     => 19
                );
                l_network_currency := l_oper.oper_currency;
                l_oper.oper_replacement_amount := l_oper.oper_cashback_amount;
            else
                l_network_amount := get_field_number (
                    i_raw_data     => i_raw_data
                    , i_start_pos  => 456
                    , i_length     => 19
                );
                l_network_currency := get_field_char (
                    i_raw_data     => i_raw_data
                    , i_start_pos  => 663
                    , i_length     => 3
                );
            end if;
        end if;
        
        case l_oper.oper_type
        when opr_api_const_pkg.OPERATION_TYPE_CASHBACK then
            l_oper.oper_cashback_amount :=
                case when l_oper.oper_cashback_amount is null then
                    get_field_number (
                        i_raw_data     => i_raw_data
                        , i_start_pos  => 475
                        , i_length     => 19
                    )
                else
                    l_oper.oper_cashback_amount
                end;
            
        when opr_api_const_pkg.OPERATION_TYPE_REFUND then
            l_oper.oper_amount := 
                get_field_number (
                    i_raw_data     => i_raw_data
                    , i_start_pos  => 456
                    , i_length     => 19
                ) - get_field_number (
                    i_raw_data     => i_raw_data
                    , i_start_pos  => 475
                    , i_length     => 19
                );
            l_oper.oper_currency := get_field_char (
                i_raw_data     => i_raw_data
                , i_start_pos  => 663
                , i_length     => 3
            );
            l_oper.oper_replacement_amount := get_field_number (
                i_raw_data     => i_raw_data
                , i_start_pos  => 475
                , i_length     => 19
            );
            l_oper.oper_cashback_amount := null;
            
        else
            l_oper.oper_cashback_amount := null;
            
        end case;
        
        l_stage := 'oper_date';
        l_oper.oper_date         := get_field_date (
            i_raw_data     => i_raw_data
            , i_start_pos  => 251
            , i_length     => 12
            , i_fmt        => 'yymmddhh24miss'
        );
        l_oper.host_date         := null;
        
        l_stage := 'terminal_type';
        l_oper.terminal_type     := acq_api_const_pkg.TERMINAL_TYPE_POS;
        
        l_stage := 'get_bin_info';
        if l_card_inst_id is null then
            net_api_bin_pkg.get_bin_info(
                i_card_number             => l_card.card_number
                , i_oper_type             => l_oper.oper_type
                , i_terminal_type         => l_oper.terminal_type
                , i_acq_inst_id           => l_acq_inst_id
                , i_acq_network_id        => l_acq_network_id
                , i_msg_type              => l_oper.msg_type
                , i_oper_reason           => l_oper.oper_reason
                , i_oper_currency         => l_oper.oper_currency
                , i_merchant_id           => null
                , i_terminal_id           => null
                , o_iss_inst_id           => l_iss_inst_id2
                , o_iss_network_id        => l_iss_network_id2
                , o_iss_host_id           => l_iss_host_id
                , o_card_type_id          => l_card_type_id
                , o_card_country          => l_card_country
                , o_card_inst_id          => l_card_inst_id
                , o_card_network_id       => l_card_network_id
                , o_pan_length            => l_pan_length
                , i_raise_error           => com_api_type_pkg.FALSE
            );
        end if;
        
        if l_offline = com_api_type_pkg.TRUE then
            l_iss_inst_id := l_iss_inst_id2;
            l_iss_network_id := l_iss_network_id2;
        end if;
        
        if l_oper.msg_type in (opr_api_const_pkg.MESSAGE_TYPE_COMPLETION) then
            begin
                select
                    p.inst_id
                    , p.network_id
                    , p.card_type_id
                    , p.card_country
                    , p.card_inst_id
                    , p.card_network_id
                into
                    l_iss_inst_id
                    , l_iss_network_id
                    , l_card_type_id
                    , l_card_country
                    , l_card_inst_id
                    , l_card_network_id
                from
                    opr_operation o
                    , opr_participant p
                    , opr_card c
                where
                    c.oper_id = o.id
                    and c.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                    and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                    and p.oper_id = o.id
                    and p.auth_code = l_auth_code
                    and o.is_reversal = l_oper.is_reversal
                    and o.msg_type = opr_api_const_pkg.MESSAGE_TYPE_PREAUTHORIZATION
                    and abs(trunc(o.oper_date) - trunc(l_oper.oper_date)) <= 30
                    and reverse(c.card_number) = 
                            reverse(iss_api_token_pkg.encode_card_number(i_card_number => l_card.card_number))
                    and not exists (select 1 from opr_operation o2 where o2.original_id = o.id)
                    and o.status != opr_api_const_pkg.OPERATION_STATUS_DUPLICATE;
            exception
                when no_data_found then
                    null;
            end;
        end if;
        
        l_stage := 'terminal and merchant';
        l_oper.originator_refnum := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 283
            , i_length     => 12
        );
        l_oper.merchant_number   := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 68
            , i_length     => 19
        );
        l_oper.merchant_street   := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 295
            , i_length     => 25
        );
        l_oper.merchant_name     := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 320
            , i_length     => 22
        );
        l_oper.merchant_city     := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 342
            , i_length     => 13
        );
        l_oper.merchant_region   := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 355
            , i_length     => 3
        );
        l_oper.merchant_country  := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 358
            , i_length     => 2
        );
        if l_oper.merchant_country is not null then
            l_oper.merchant_country  := com_api_country_pkg.get_country_code (
                i_visa_country_code  => l_oper.merchant_country
                , i_raise_error      => com_api_type_pkg.FALSE
            );
            l_oper.merchant_country := nvl(l_oper.merchant_country, '000');
        end if;
        l_oper.merchant_postcode := null;
        
        get_merchant_address (
            i_inst_id               => l_acq_inst_id
            , i_merchant_number     => l_oper.merchant_number
            , io_merchant_street    => l_oper.merchant_street
            , io_merchant_city      => l_oper.merchant_city
            , io_merchant_region    => l_oper.merchant_region
            , io_merchant_country   => l_oper.merchant_country
            , io_merchant_postcode  => l_oper.merchant_postcode
        );
        
        l_oper.terminal_number   := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 87
            , i_length     => 16
        );
        
        l_stage := 'dispute_id';
        l_oper.dispute_id        := null;
        l_oper.original_id       := null;
        --l_oper.proc_mode := aut_api_const_pkg.AUTH_PROC_MODE_CARD_ABSENT;
        
        l_stage := 'iss participant';
        l_iss_part.inst_id         := l_iss_inst_id;
        l_iss_part.network_id      := l_iss_network_id;
        l_iss_part.client_id_type  := opr_api_const_pkg.CLIENT_ID_TYPE_CARD;
        l_iss_part.client_id_value := l_card.card_number;
        l_iss_part.customer_id     := l_card.customer_id;
        l_iss_part.card_id         := l_card.id;
        l_iss_part.card_type_id    := l_card.card_type_id;
        l_card_expir_date := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 494
            , i_length     => 4
        );
        if not (l_card_expir_date is null or l_card_expir_date = '0000') then
            l_iss_part.card_expir_date := get_field_date (
                i_raw_data     => i_raw_data
                , i_start_pos  => 494
                , i_length     => 4
                , i_fmt        => 'yymm'
            );
        end if;
        l_iss_part.card_seq_number := null; -- from token b4
        l_iss_part.card_number     := l_card.card_number;
        l_iss_part.card_mask       := iss_api_card_pkg.get_card_mask(l_card.card_number);
        l_iss_part.card_country :=
        case when l_card_country is not null then
            l_card_country
        else
            l_card.country
        end;
        l_iss_part.card_inst_id     := l_card_inst_id;
        l_iss_part.card_network_id  := l_card_network_id;
        l_iss_part.account_id       := null;
        l_iss_part.account_number   := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 434
            , i_length     => 19
        );
        l_iss_part.account_amount   := null;
        l_iss_part.account_currency := null;
        l_iss_part.auth_code        := l_auth_code;
        l_iss_part.split_hash       := l_card.split_hash;

        l_stage := 'acq participant';
        l_acq_part.inst_id          := l_acq_inst_id;
        l_acq_part.network_id       := l_acq_network_id;
        l_acq_part.merchant_id      := null;
        l_acq_part.terminal_id      := null;
        l_acq_part.split_hash       := null;
        
        l_stage := 'get_terminal';
        get_terminal (
            i_inst_id            => l_acq_inst_id
            , i_terminal_number  => l_oper.terminal_number
            , o_terminal_rec     => l_terminal
        );
        if l_terminal.id is not null then
            l_oper.terminal_type := l_terminal.terminal_type;
        end if;
        
        l_stage := 'set_auth';
        set_auth (
            o_auth        => l_auth
            , i_terminal  => l_terminal
        );
        
        l_stage := 'network_amount';
        l_auth.network_amount := l_network_amount;
        l_auth.network_currency := l_network_currency;
        
        l_stage := 'pos_cond_code';
        l_auth.pos_cond_code := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 657
            , i_length     => 2
        );
        l_stage := 'get_b1_params';
        aci_api_token_pkg.get_b1_params (
            i_token_tab           => l_token_tab
            , o_pos_entry_mode    => l_auth.pos_entry_mode
            , o_cvr               => l_auth.cvr
            , o_ecom_sec_lvl_ind  => l_aup_mastercard.eci
            , o_trace             => l_visa_basei.trace
            , o_interface         => l_interface
            , io_resp_code        => l_resp_code
        );
        
        case l_interface
        when aci_api_const_pkg.INTERFACE_BNET then
            l_aup_mastercard.resp_code := l_resp_code;
        when aci_api_const_pkg.INTERFACE_VISA then
            l_visa_basei.resp_code := l_resp_code;
        else
            l_aup_mastercard.resp_code := l_resp_code;
            l_visa_basei.resp_code := l_resp_code;
        end case;

        l_iss_part.card_service_code := get_service_code (
            i_raw_data     => get_field_char (
                i_raw_data     => i_raw_data
                , i_start_pos  => 498
                , i_length     => 40
            )
            , i_interface  => l_interface
        );
        
        l_stage := 'pin_present';
        l_pin_present := get_field_number (
            i_raw_data     => i_raw_data
            , i_start_pos  => 817
            , i_length     => 1
        );
        l_auth.pin_presence := 'PINP' ||
        case l_pin_present
        when 0 then '0002'
        when 1 then '0001'
        else '0000'
        end;
        
        /*l_stage := 'pin_capture_cap';
        l_auth.pin_capture_cap := 'F22C' ||
        case when substr(l_auth.pos_entry_mode, 3, 1) = '0' then
            '0001'
        when substr(l_auth.pos_entry_mode, 3, 1) = '2' then
            '0000'
        when substr(l_auth.pos_entry_mode, 3, 1) in ('3', '4', '5', '6', '7', '8', '9') then
            '0004'
        else
            '0001'
        end;*/
        
        l_stage := 'get_c_params';
        aci_api_token_pkg.get_c_params (
            i_token_tab               => l_token_tab
            , io_crdh_presence        => l_auth.crdh_presence
            , io_card_presence        => l_auth.card_presence
            , io_cvv2_presence        => l_auth.cvv2_presence
            , io_ucaf_indicator       => l_auth.ucaf_indicator
            , io_cat_level            => l_auth.cat_level
            , io_card_data_input_cap  => l_auth.card_data_input_cap
            , io_ecommerce_indicator  => l_visa_basei.ecommerce_indicator
        );
        
        l_stage := 'get_b4_params';
        aci_api_token_pkg.get_b4_params (
            i_token_tab           => l_token_tab
            , i_pin_present       => l_pin_present
            , i_cat_level         => l_auth.cat_level
            , i_iss_inst_id       => get_field_char (i_raw_data, 26, 4)
            , io_pos_entry_mode   => l_auth.pos_entry_mode
            , o_crdh_auth_method  => l_auth.crdh_auth_method
            , o_crdh_auth_entity  => l_auth.crdh_auth_entity
            , o_card_seq_number   => l_iss_part.card_seq_number
        );
        
        l_stage := 'card_data_input_mode';
        if nvl(l_visa_basei.ecommerce_indicator, '0') = '0' then
            l_auth.card_data_input_mode := case substr(l_auth.pos_entry_mode, 1, 2)
                                               when '00' then
                                                   'F2270000'
                                               when '01' then
                                                   case when l_auth.terminal_operating_env = 'F2240000' then
                                                       'F2270001'
                                                   else
                                                       'F2270006'
                                                   end
                                               when '02' then
                                                   'F2270002'
                                               when '03' then
                                                   'F2270003'
                                               when '04' then
                                                   'F2270004'
                                               when '05' then
                                                   case when l_offline = com_api_type_pkg.FALSE then
                                                       'F227000C'
                                                   else
                                                       'F227000F'
                                                   end
                                               when '06' then
                                                   'F2270006'
                                               when '07' then
                                                   'F227000M'
                                               when '08' then
                                                   'F227000A'
                                               when '09' then
                                                   'F2270000'
                                               when '90' then
                                                   'F227000B'
                                               when '91' then
                                                   'F227000A'
                                               else
                                                   'F2270000'
                                               end;
        else -- e-commerce indicator
            l_auth.card_data_input_mode :=     case l_visa_basei.ecommerce_indicator
                                                   when '5' then
                                                       'F2270005'
                                                   when '6' then
                                                       'F2270005'
                                                   when '7' then
                                                       'F2270007'
                                                   when '9' then
                                                       'F2270009'
                                                   when 'S' then
                                                       'F227000S'
                                                   else
                                                       'F2270000'
                                                   end;

            trc_log_pkg.debug (
                i_text          => 'b24 pos fin: e-commerce indicator [#1]'
                , i_env_param1  => l_visa_basei.ecommerce_indicator
            );
            
            if l_aup_mastercard.eci is null then
                l_aup_mastercard.eci := 
                case l_visa_basei.ecommerce_indicator
                when '5' then '212'
                when '6' then '211'
                when '7' then '210'
                when '8' then '910'
                else null
                end;
            end if;
        end if;
        
        l_stage := 'get_17_params';
        aci_api_token_pkg.get_17_params (
            i_token_tab          => l_token_tab
            , o_srv_indicator    => l_visa_basei.srv_indicator
            , o_transaction_id   => l_auth.transaction_id
            , o_validation_code  => l_visa_basei.validation_code
        );
        
        l_stage := 'get_20_params';
        aci_api_token_pkg.get_20_params (
            i_token_tab         => l_token_tab
            , o_network_refnum  => l_oper.network_refnum
        );
        
        l_stage := 'get_ch_params';
        aci_api_token_pkg.get_ch_params (
            i_token_tab       => l_token_tab
            , io_cvv2_result  => l_auth.cvv2_result
        );
        
        l_stage := 'certificate_method';
        if nvl(l_visa_basei.ecommerce_indicator, '0') in ('5', '7', '9', 'S') then
            l_auth.certificate_method := 'CRTM0001';
        elsif l_auth.ucaf_indicator in ('UCAF0002', 'UCAF0003') then
            l_auth.certificate_method := 'CRTM0004';
        elsif  l_visa_basei.srv_indicator in ('U') then
            l_auth.certificate_method := 'CRTM0003';
        end if;
        
        l_stage := 'format_emv_data';
        l_auth.emv_data := aci_api_token_pkg.format_emv_data (
            i_token_tab  => l_token_tab
        );
        
        rul_api_param_pkg.set_param (
            i_name          => 'TERMINAL_ID'
            , i_value       => l_terminal.id
            , io_params     => l_params
        );

        l_stage := 'get_sttl_type';
        net_api_sttl_pkg.get_sttl_type (
            i_iss_inst_id        => l_iss_inst_id
            , i_acq_inst_id      => l_acq_inst_id
            , i_card_inst_id     => l_card_inst_id
            , i_iss_network_id   => l_iss_network_id
            , i_acq_network_id   => l_acq_network_id
            , i_card_network_id  => l_card_network_id
            , i_acq_inst_bin     => l_oper.acq_inst_bin
            , o_sttl_type        => l_oper.sttl_type
            , o_match_status     => l_oper.match_status
            , i_params           => l_params
            , i_mask_error       => com_api_type_pkg.TRUE
            , i_oper_type        => l_oper.oper_type
        );
        
        l_auth.is_advice := l_offline;
        
        l_stage := 'create_operation';
        create_operation (
            i_oper              => l_oper
            , i_iss_part        => l_iss_part
            , i_acq_part        => l_acq_part
            , i_auth            => l_auth
            , i_visa_basei      => l_visa_basei
            , i_aup_mastercard  => l_aup_mastercard
            , i_interface       => l_interface
        );
        
        -- register successed processed
        register_ok;
    exception
        when others then
            trc_log_pkg.error (
                i_text          => 'Error processing POS customer transaction on stage [#1] line[#3] of file[#4]: [#2]'
                , i_env_param1  => l_stage
                , i_env_param2  => sqlerrm
                , i_env_param3  => g_clob_line
                , i_env_param4  => g_file_name
            );
            raise;
    end;
    
    procedure process_pos_adm (
        i_raw_data              in com_api_type_pkg.t_raw_data
        , i_file_id             in com_api_type_pkg.t_long_id
        , i_record_number       in com_api_type_pkg.t_long_id
    ) is
        l_format                com_api_type_pkg.t_byte_char;
        
        --l_card                  iss_api_type_pkg.t_card_rec;
        
        --l_iss_inst_id           com_api_type_pkg.t_inst_id;
        --l_acq_inst_id           com_api_type_pkg.t_inst_id;
        --l_card_inst_id          com_api_type_pkg.t_inst_id;
        --l_iss_network_id        com_api_type_pkg.t_tiny_id;
        --l_acq_network_id        com_api_type_pkg.t_tiny_id;
        --l_card_network_id       com_api_type_pkg.t_tiny_id;
        --l_card_type_id          com_api_type_pkg.t_tiny_id;
        --l_card_country          com_api_type_pkg.t_country_code;
        --l_bin_currency          com_api_type_pkg.t_curr_code;
        --l_sttl_currency         com_api_type_pkg.t_curr_code;
        --l_sttl_type             com_api_type_pkg.t_dict_value;
        --l_match_status          com_api_type_pkg.t_dict_value;
        --l_iss_inst_id2          com_api_type_pkg.t_inst_id;
        --l_iss_network_id2       com_api_type_pkg.t_tiny_id;
        --l_iss_host_id           com_api_type_pkg.t_tiny_id;
        --l_pan_length            com_api_type_pkg.t_tiny_id;
        
        l_oper                  opr_api_type_pkg.t_oper_rec;
        --l_iss_part              opr_api_type_pkg.t_oper_part_rec;
        --l_acq_part              opr_api_type_pkg.t_oper_part_rec;
        --l_auth                  aut_api_type_pkg.t_auth_rec;
        --l_visa_basei            aup_api_type_pkg.t_aup_visa_basei_rec;
        --l_aup_mastercard        aup_api_type_pkg.t_aup_mastercard_rec;
        l_setl_tot_rec          aci_api_type_pkg.t_pos_setl_rec;
        l_clerk_tot_rec         aci_api_type_pkg.t_clerk_tot_rec;
        l_service_rec           aci_api_type_pkg.t_service_rec;
        
        --l_terminal              aap_api_type_pkg.t_terminal;
        --l_token_tab             aci_api_type_pkg.t_token_tab;
        --l_params                com_api_type_pkg.t_param_tab;
        
        l_stage                 com_api_type_pkg.t_name;
    begin
        l_stage := 'check_fin_duplicate';
        process_duplicate (
            i_raw_data     => i_raw_data
            , i_tlf_type   => aci_api_const_pkg.REC_TYPE_ADMIN_TRANSACTION
            , i_file_type  => aci_api_const_pkg.FILE_TYPE_PTLF
            , i_file_id    => i_file_id
        );
        
        l_stage := 'get format';
        l_format := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 157
            , i_length     => 1
        );
        --trc_log_pkg.debug('process_pos_adm: format= '||l_format);
        
        l_stage := 'create incoming message';
        -- Settlement Totals
        if l_format in ('0', '1', '2', '3') then
            aci_api_adm_pkg.create_incoming_setl_tot (
                i_raw_data         => i_raw_data
                , i_file_id        => i_file_id
                , i_record_number  => i_record_number
                , o_mes_rec        => l_setl_tot_rec
            );
            
            l_oper.id := l_setl_tot_rec.id;
            l_oper.oper_type := opr_api_const_pkg.OPERATION_TYPE_SETTL_TOTALS;
        
        -- Clerk Totals
        elsif l_format in ('0', '1', '2', '3') then
            aci_api_adm_pkg.create_incoming_clerk (
                i_raw_data         => i_raw_data
                , i_file_id        => i_file_id
                , i_record_number  => i_record_number
                , o_mes_rec        => l_clerk_tot_rec
            );
            
            l_oper.id := l_clerk_tot_rec.id;
            l_oper.oper_type := opr_api_const_pkg.OPERATION_TYPE_CLERK_TOTALS;
        
        -- First/Second Services
        else
            trc_log_pkg.debug (
                i_text          => 'ACI_OPER_TYPE_NOT_SUPPORTED'
                , i_env_param1  => get_field_char(i_raw_data, 157, 1)
            );
            -- register excepted processed
            register_skip;
            return;
            
            aci_api_adm_pkg.create_incoming_srvcs (
                i_raw_data         => i_raw_data
                , i_file_id        => i_file_id
                , i_record_number  => i_record_number
                , o_mes_rec        => l_service_rec
            );
            
            l_oper.id := l_service_rec.id;
            
        end if;
        
        register_skip;
        return;
        /*
        l_stage := 'card_number';
        l_card.card_number := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 30
            , i_length     => 19
        );
        
        l_card := iss_api_card_pkg.get_card (
            i_card_number   => l_card.card_number
            , i_mask_error  => com_api_type_pkg.TRUE
        );
        if l_card.card_number is null then
            l_card.card_number := get_field_char (
                i_raw_data     => i_raw_data
                , i_start_pos  => 30
                , i_length     => 19
            );
        end if;
        
        l_stage := 'card_number';
        iss_api_bin_pkg.get_bin_info (
            i_card_number        => l_card.card_number
            , o_iss_inst_id      => l_iss_inst_id
            , o_iss_network_id   => l_iss_network_id
            , o_card_inst_id     => l_card_inst_id
            , o_card_network_id  => l_card_network_id
            , o_card_type        => l_card_type_id
            , o_card_country     => l_card_country
            , o_bin_currency     => l_bin_currency
            , o_sttl_currency    => l_sttl_currency
        );
        
        l_stage := 'iss_inst_id and iss_network_id';
        l_iss_inst_id := get_inst_id (
            i_inst_id  => get_field_char (
                i_raw_data     => i_raw_data
                , i_start_pos  => 26
                , i_length     => 4
            )
        );
        \*l_iss_network_id := get_network_id (
            i_network_id  => get_field_char (
                i_raw_data     => i_raw_data
                , i_start_pos  => 22
                , i_length     => 4
            )
        );*\
        l_iss_network_id := ost_api_institution_pkg.get_inst_network(l_iss_inst_id);
        
        if l_card_inst_id is null then
            net_api_bin_pkg.get_bin_info (
                i_card_number        => l_card.card_number
                , i_network_id       => l_iss_network_id
                , o_iss_inst_id      => l_iss_inst_id2
                , o_iss_host_id      => l_iss_host_id
                , o_card_type_id     => l_card_type_id
                , o_card_country     => l_card_country
                , o_card_inst_id     => l_card_inst_id
                , o_card_network_id  => l_card_network_id
                , o_pan_length       => l_pan_length
                , i_raise_error      => com_api_type_pkg.FALSE
            );
        end if;
        
        l_stage := 'acq_inst_id and acq_network_id';
        l_acq_inst_id := get_inst_id (
            i_inst_id  => get_field_char (
                i_raw_data     => i_raw_data
                , i_start_pos  => 113
                , i_length     => 4
            )
        );
        l_acq_network_id := ost_api_institution_pkg.get_inst_network(l_acq_inst_id);
        
        l_oper.msg_type := opr_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION;
        l_oper.is_reversal := com_api_type_pkg.FALSE;
        
        l_oper.oper_count := 1;
        
        l_stage := 'amount and currency';
        l_oper.oper_amount       := get_field_number (
            i_raw_data     => i_raw_data
            , i_start_pos  => 456
            , i_length     => 19
        );

        l_oper.oper_currency     := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 330
            , i_length     => 3
        );
        --l_oper.sttl_amount       := get_field_char(276, 19); --?
        --l_oper.sttl_currency     := get_field_char (
        --    i_raw_data     => i_raw_data
        --    , i_start_pos  => 454
        --    , i_length     => 3
        --);
        
        l_oper.oper_date         := get_field_date (
            i_raw_data     => i_raw_data
            , i_start_pos  => 297
            , i_length     => 12
            , i_fmt        => 'yymmddhh24miss'
        );
        l_oper.host_date         := null;
        l_oper.terminal_type     := acq_api_const_pkg.TERMINAL_TYPE_POS;
        l_oper.mcc               := null;--?
        l_oper.originator_refnum := null;
        l_oper.merchant_number   := null;
        l_oper.terminal_number   := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 87
            , i_length     => 16
        );
        l_oper.dispute_id        := null;
        l_oper.sttl_type         := l_sttl_type;
        l_oper.match_status      := l_match_status;
        l_oper.original_id       := null;
        --l_oper.proc_mode := aut_api_const_pkg.AUTH_PROC_MODE_CARD_ABSENT;
        
        l_stage := 'iss participant';
        l_iss_part.inst_id         := l_iss_inst_id;
        l_iss_part.network_id      := l_iss_network_id;
        l_iss_part.client_id_type  := opr_api_const_pkg.CLIENT_ID_TYPE_CARD;
        l_iss_part.client_id_value := l_card.card_number;
        l_iss_part.customer_id     := l_card.customer_id;
        l_iss_part.card_id         := l_card.id;
        l_iss_part.card_type_id    := l_card.card_type_id;
        l_iss_part.card_expir_date := get_field_date (
            i_raw_data     => i_raw_data
            , i_start_pos  => 494
            , i_length     => 4
            , i_fmt        => 'yymm'
        );
        l_iss_part.card_seq_number := null; -- from token b4
        l_iss_part.card_number     := l_card.card_number;
        l_iss_part.card_mask       := iss_api_card_pkg.get_card_mask(l_card.card_number);
        l_iss_part.card_country :=
        case when l_card_country is not null then
            l_card_country
        else
            l_card.country
        end;
        l_iss_part.card_inst_id     := l_card_inst_id;
        l_iss_part.card_network_id  := l_card_network_id;
        l_iss_part.account_id       := null;
        l_iss_part.account_number   := get_field_char (
            i_raw_data     => i_raw_data
            , i_start_pos  => 434
            , i_length     => 19
        );
        l_iss_part.account_amount   := null;
        l_iss_part.account_currency := null;
        l_iss_part.auth_code        := null;--?
        l_iss_part.split_hash       := l_card.split_hash;

        l_stage := 'acq participant';
        l_acq_part.inst_id          := l_acq_inst_id;
        l_acq_part.network_id       := l_acq_network_id;
        l_acq_part.merchant_id      := null;
        l_acq_part.terminal_id      := null;
        l_acq_part.split_hash       := null;
        
        l_stage := 'get_terminal';
        get_terminal (
            i_inst_id            => l_acq_inst_id
            , i_terminal_number  => l_oper.terminal_number
            , o_terminal_rec     => l_terminal
        );
        
        l_stage := 'format_emv_data';
        l_auth.emv_data := aci_api_token_pkg.format_emv_data (
            i_token_tab  => l_token_tab
        );
        
        rul_api_param_pkg.set_param (
            i_name          => 'TERMINAL_ID'
            , i_value       => l_terminal.id
            , io_params     => l_params
        );
        
        l_stage := 'get_sttl_type';
        net_api_sttl_pkg.get_sttl_type (
            i_iss_inst_id        => l_iss_inst_id
            , i_acq_inst_id      => l_acq_inst_id
            , i_card_inst_id     => l_card_inst_id
            , i_iss_network_id   => l_iss_network_id
            , i_acq_network_id   => l_acq_network_id
            , i_card_network_id  => l_card_network_id
            , i_acq_inst_bin     => l_acq_inst_id
            , o_sttl_type        => l_sttl_type
            , o_match_status     => l_match_status
            , i_params           => l_params
            , i_mask_error       => com_api_type_pkg.TRUE
        );
        
        l_auth.is_advice := l_offline;
        
        l_stage := 'create_operation';
        create_operation (
            i_oper              => l_oper
            , i_iss_part        => l_iss_part
            , i_acq_part        => l_acq_part
            , i_auth            => l_auth
            , i_visa_basei      => l_visa_basei
            , i_aup_mastercard  => l_aup_mastercard
            , i_interface       => l_interface
        );*/
        
        -- register successed processed
        register_ok;
    exception
        when others then
            trc_log_pkg.debug (
                i_text          => 'Error processing POS administrative transaction on stage [#1] line[#3] of file[#4]: [#2]'
                , i_env_param1  => l_stage
                , i_env_param2  => sqlerrm
                , i_env_param3  => g_clob_line
                , i_env_param4  => g_file_name
            );
            raise;
    end;
        
    procedure load_extract is
        
        l_estimated_count       com_api_type_pkg.t_long_id := 0;
        l_excepted_count        com_api_type_pkg.t_long_id := 0;
        l_processed_count       com_api_type_pkg.t_long_id := 0;
        
        l_record_type           com_api_type_pkg.t_dict_value;
        
        l_file_rec              aci_api_type_pkg.t_aci_file_rec;
        
        l_clob                  clob;
        l_offset                pls_integer := 1;
        l_length                pls_integer := null;
        l_buffer                com_api_type_pkg.t_lob_data;
        l_record                com_api_type_pkg.t_lob_data;
        l_clob_line_count       pls_integer;
        l_record_number         com_api_type_pkg.t_long_id;
        
        cursor l_count_cur is
        select sum(dbms_lob.getlength(file_contents) - nvl(length(replace(file_contents, chr(10))),0) + 1) line
        from prc_session_file where session_id = get_session_id;
    
        cursor l_data_cur is
        select id, file_name, file_contents from prc_session_file where session_id = get_session_id;
        
        procedure process_data_record (
            i_raw_data              in varchar2
        ) is
            l_tlf_type              com_api_type_pkg.t_dict_value;
            l_headx_dat_tim         com_api_type_pkg.t_name;
        begin
            begin
                savepoint start_new_record;

                l_record_number := l_record_number + 1;
                
                l_headx_dat_tim := get_field_char (
                    i_raw_data     => i_raw_data
                    , i_start_pos  => 1
                    , i_length     => 19
                );
                l_tlf_type := get_field_char (
                    i_raw_data     => i_raw_data
                    , i_start_pos  => 20
                    , i_length     => 2
                );

                -- Financial transaction record
                if l_tlf_type in (
                  aci_api_const_pkg.REC_TYPE_CUSTOMER_TRANSACTION
                  , aci_api_const_pkg.REC_TYPE_EXCEPTION_POSTED
                  , aci_api_const_pkg.REC_TYPE_EXCEPTION_NOTPOSTED
                  , aci_api_const_pkg.REC_TYPE_EXCEPTION_FUTURE
                  , aci_api_const_pkg.REC_TYPE_EXCEPTION_INVALIDDATA
                ) then
                    if l_file_rec.file_type = aci_api_const_pkg.FILE_TYPE_TLF then
                        process_atm_fin (
                            i_raw_data         => i_raw_data
                            , i_file_id        => l_file_rec.id
                            , i_record_number  => l_record_number
                        );
                    else
                        process_pos_fin (
                            i_raw_data         => i_raw_data
                            , i_file_id        => l_file_rec.id
                            , i_record_number  => l_record_number
                        );
                    end if;

                -- Administrative transaction record
                elsif l_tlf_type in (
                  aci_api_const_pkg.REC_TYPE_ADMIN_TRANSACTION
                ) then
                    if l_file_rec.file_type = aci_api_const_pkg.FILE_TYPE_TLF then
                        process_atm_adm (
                            i_raw_data         => i_raw_data
                            , i_file_id        => l_file_rec.id
                            , i_record_number  => l_record_number
                        );
                    else
                        process_pos_adm (
                            i_raw_data         => i_raw_data
                            , i_file_id        => l_file_rec.id
                            , i_record_number  => l_record_number
                        );
                    end if;

                    /*trc_log_pkg.warn (
                        i_text          => 'ACI_RECCORD_TYPE_SKIPPED'
                        , i_env_param1  => l_tlf_type
                        , i_env_param2  => l_headx_dat_tim
                    );*/

                else
                    com_api_error_pkg.raise_error (
                        i_error         => 'ACI_UNKNOWN_TLF_TYPE'
                        , i_env_param1  => l_tlf_type
                        , i_env_param2  => l_headx_dat_tim
                    );
                end if;
            exception
                when others then
                    trc_log_pkg.debug (
                        i_text          => 'Error processing data record line[#1] of file[#2]'
                        , i_env_param1  => g_clob_line
                        , i_env_param2  => g_file_name
                    );
                    if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_type_pkg.TRUE then
                        raise;

                    else
                        rollback to savepoint start_new_record;

                        l_excepted_count := l_excepted_count + 1;
                        -- register excepted processed
                        register_error;
                        
                    end if;
            end;
            
            l_processed_count := l_processed_count + 1;
            -- register estimated count processed
            register_count;
        end;
    begin
        savepoint loading_extract;
        
        prc_api_stat_pkg.log_start;
        
        open l_count_cur;
        fetch l_count_cur into l_estimated_count;
        close l_count_cur;
        prc_api_stat_pkg.log_estimation (
            i_estimated_count  => l_estimated_count
        );
        
        clear_global_data;
        
        open l_data_cur;
        loop
            fetch l_data_cur into g_session_file_id, g_file_name, l_clob;
            exit when l_data_cur%notfound;
            
            -- get count lines
            l_clob_line_count := dbms_lob.getlength(l_clob) - nvl(length(replace(l_clob, chr(10))),0) + 1;
            l_offset := 1;
            
            -- init record number
            l_record_number := 0;
            
            trc_log_pkg.debug (
                i_text          => 'Processing file name[#1] line_count[#2]'
                , i_env_param1  => g_file_name
                , i_env_param2  => l_clob_line_count
            );
            
            -- process lines
            for i in 1..l_clob_line_count loop
                trc_log_pkg.debug (
                    i_text          => 'Processing line[#1]'
                    , i_env_param1  => i
                );
                g_clob_line := i;
                l_length := dbms_lob.instr(l_clob, chr(10), l_offset, 1) - l_offset;
                l_buffer := dbms_lob.substr(l_clob, l_length, l_offset);
                l_offset := dbms_lob.instr(l_clob, chr(10), l_offset + 1, 1) + 1;
                  
                -- remove line length
                l_buffer := substr(l_buffer, 7);
            
                loop
                    l_buffer := rtrim(l_buffer, chr(10));
                    l_buffer := rtrim(l_buffer, chr(13));
                    l_buffer := trim(l_buffer);
                    exit when nvl(length(l_buffer), 0) = 0; 
                    
                    l_length := get_field_number(l_buffer, 1, 6);
                    l_record := substr(l_buffer, 7, l_length-6);
                    l_buffer := substr(l_buffer, l_length+1);
                    
                    l_record_type := get_field_char(l_record, 1, 2);
                    l_record := substr(l_record, 3);
                    
                    if l_record_type in (
                      aci_api_const_pkg.EXTRACT_TAPE_HEADER
                    ) then
                        process_tape_header (
                            i_raw_data      => l_record
                        );
                        
                    elsif l_record_type in (
                      aci_api_const_pkg.EXTRACT_FILE_HEADER
                    ) then
                        process_file_header (
                            i_raw_data           => l_record
                            , i_session_file_id  => g_session_file_id
                            , o_file_rec         => l_file_rec
                        );
    
                    elsif l_record_type in (
                      aci_api_const_pkg.EXTRACT_FILE_TRAILER
                    ) then
                        process_file_trailer (
                            i_raw_data      => l_record
                            , io_file_rec   => l_file_rec
                        );
                        
                    elsif l_record_type in (
                      aci_api_const_pkg.EXTRACT_TAPE_TRAILER
                    ) then
                        process_tape_trailer (
                            i_raw_data      => l_record
                        );
                        
                    elsif l_record_type in (
                      aci_api_const_pkg.EXTRACT_DATA_RECORD
                    ) then
                        process_data_record (
                            i_raw_data      => l_record
                        );
                        
                    else
                        com_api_error_pkg.raise_error(
                            i_error         => 'ACI_UNKNOWN_RECORD'
                            , i_env_param1  => l_record_type
                        );
                    end if;
                end loop;

                if mod(l_processed_count, BULK_LIMIT) = 0 then
                    prc_api_stat_pkg.log_current (
                        i_current_count    => l_processed_count
                        , i_excepted_count => l_excepted_count
                    );
                end if;
            end loop;
            
            trc_log_pkg.debug (
                i_text          => 'File processed successfully'
            );
        end loop;
        close l_data_cur;
        
        -- serialize messages count
        serialize_msg_count;

        prc_api_stat_pkg.log_estimation (
            i_estimated_count  => l_processed_count
        );
        
        prc_api_stat_pkg.log_end (
            i_excepted_total     => l_excepted_count
            , i_processed_total  => l_processed_count
            , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );
        
        clear_global_data;
    exception
        when others then
            rollback to savepoint loading_extract;
            trc_log_pkg.debug (
                i_text          => 'Error processing file[#3]: line[#1] error[#2]'
                , i_env_param1  => g_clob_line
                , i_env_param2  => sqlerrm
                , i_env_param3  => g_file_name
            );
            if l_data_cur%isopen then
                close l_data_cur;
            end if;
            if l_count_cur%isopen then
                close l_count_cur;
            end if;

            prc_api_stat_pkg.log_end (
                i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );

            clear_global_data;

            if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_fatal_error (
                    i_error         => 'UNHANDLED_EXCEPTION'
                    , i_env_param1  => sqlerrm
                );
            end if;

            raise;
    end;

end;
/
