create or replace package body tie_api_fin_pkg is

function get_msg_impact(
    i_msg_type      in tie_api_type_pkg.t_msg_type
  , i_proc_code     in tie_api_type_pkg.t_proc_code
) return com_api_type_pkg.t_sign is
    result com_api_type_pkg.t_sign;
begin
    case 
        when     substr(i_msg_type, 2, 1) in ('1', '2')
             and substr(i_proc_code, 1, 1) = '2'
        then
            result:= com_api_const_pkg.CREDIT;
        when     substr(i_msg_type, 2, 1) in ('1', '2')
             and substr(i_proc_code, 1, 1) != '2'
        then
            result:= com_api_const_pkg.DEBIT;
        when     substr(i_msg_type, 2, 1) not in ('1', '2')
             and substr(i_proc_code, 1, 1) = '2'
        then
            result:= com_api_const_pkg.DEBIT;
        when     substr(i_msg_type, 2, 1) not in ('1', '2')
             and substr(i_proc_code, 1, 1) != '2'
        then
            result:= com_api_const_pkg.CREDIT;
        else
            result:= com_api_const_pkg.NONE;
    end case;
    
    return result;
    
end;

function get_tran_type(
    i_oper_type            in com_api_type_pkg.t_dict_value
  , i_is_reversal          in com_api_type_pkg.t_boolean
) return tie_api_type_pkg.t_tran_type is
begin
    return
        case
            when i_is_reversal = com_api_type_pkg.FALSE then
                case
                    when i_oper_type in ( opr_api_const_pkg.OPERATION_TYPE_ATM_CASH
                                        , opr_api_const_pkg.OPERATION_TYPE_POS_CASH
                                        ) then
                        tie_api_const_pkg.TC_CASH
                    when i_oper_type in (opr_api_const_pkg.OPERATION_TYPE_PURCHASE
                                        , opr_api_const_pkg.OPERATION_TYPE_UNIQUE
                                        , opr_api_const_pkg.OPERATION_TYPE_P2P_DEBIT
                                        , opr_api_const_pkg.OPERATION_TYPE_SRV_PRV_PAYMENT
                                        ) then
                        tie_api_const_pkg.TC_PURCHASE
                    when i_oper_type in (opr_api_const_pkg.OPERATION_TYPE_REFUND
                                        , opr_api_const_pkg.OPERATION_TYPE_PAYMENT
                                        , opr_api_const_pkg.OPERATION_TYPE_P2P_CREDIT
                                        , opr_api_const_pkg.OPERATION_TYPE_CASHIN
                                        ) then
                        tie_api_const_pkg.TC_REFUND
                    when i_oper_type in ( opr_api_const_pkg.OPERATION_TYPE_CASHIN
                                        ) then
                        tie_api_const_pkg.TC_DEPOSIT
                    else
                        null
                end
            when i_is_reversal = com_api_type_pkg.TRUE then
                case
                    when i_oper_type in ( opr_api_const_pkg.OPERATION_TYPE_ATM_CASH
                                        , opr_api_const_pkg.OPERATION_TYPE_POS_CASH
                                        ) then
                        tie_api_const_pkg.TC_CASH_REVERSAL
                    when i_oper_type in (opr_api_const_pkg.OPERATION_TYPE_PURCHASE
                                        , opr_api_const_pkg.OPERATION_TYPE_UNIQUE
                                        , opr_api_const_pkg.OPERATION_TYPE_P2P_DEBIT
                                        , opr_api_const_pkg.OPERATION_TYPE_SRV_PRV_PAYMENT
                                        ) then
                        tie_api_const_pkg.TC_PURCHASE_REVERSAL
                    when i_oper_type in (opr_api_const_pkg.OPERATION_TYPE_REFUND
                                        , opr_api_const_pkg.OPERATION_TYPE_PAYMENT
                                        , opr_api_const_pkg.OPERATION_TYPE_P2P_CREDIT
                                        , opr_api_const_pkg.OPERATION_TYPE_CASHIN
                                        ) then
                        tie_api_const_pkg.TC_REFUND_REVERSAL
                    when i_oper_type in ( opr_api_const_pkg.OPERATION_TYPE_CASHIN
                                        ) then
                        tie_api_const_pkg.TC_DEPOSIT_REVERSAL
                    else 
                        null
                end
            end;
end;

function get_proc_code(
    i_oper_type              in com_api_type_pkg.t_dict_value
) return tie_api_type_pkg.t_proc_code is
    l_result      tie_api_type_pkg.t_proc_code;
begin
    
    l_result:= 
        case i_oper_type
            when 'OPTP0000' then '00'
            when 'OPTP0001' then '01'
            when 'OPTP0402' then '02'
            when 'OPTP0018' then '11'
            when 'OPTP0009' then '09'
            when 'OPTP0010' then '10'
            when 'OPTP0012' then '17'
            when 'OPTP0020' then '20'
            when 'OPTP0025' then '21'
            when 'OPTP0422' then '22'
            when 'OPTP0026' then '26'
            when 'OPTP0030' then '31'
            when 'OPTP0039' then '38'
            when 'OPTP0040' then '40'
            when 'OPTP0028' then '50'
            when 'OPTP0070' then '70'
            when 'OPTP0038' then '72'
                            else ''
        end;
    
    return l_result;

end;

function get_currency_name(
    i_curr_code       in com_api_type_pkg.t_curr_code
) return com_api_type_pkg.t_curr_name is
    l_result          com_api_type_pkg.t_curr_name;
begin
    select t.name
    into l_result
    from com_currency t
    where t.code = i_curr_code;
    
    return l_result;
    
exception
    when no_data_found then
        return null;
end;

function get_currency_code(
    i_curr_name       in com_api_type_pkg.t_curr_name
) return com_api_type_pkg.t_curr_code is
    l_result          com_api_type_pkg.t_curr_code;
begin
    select t.code
    into l_result
    from com_currency t
    where t.name = i_curr_name;
    
    return l_result;
    
exception
    when no_data_found then
        return null;
end;

function get_currency_exp(
    i_curr_name       in com_api_type_pkg.t_curr_name
) return com_api_type_pkg.t_curr_code is
    l_result          com_api_type_pkg.t_curr_code;
begin
    select t.exponent
    into l_result
    from com_currency t
    where t.name = i_curr_name;
    
    return l_result;
    
exception
    when no_data_found then
        return null;
end;

function get_country_name(
    i_country_code           in com_api_type_pkg.t_country_code
) return com_api_type_pkg.t_curr_name is
    l_result          com_api_type_pkg.t_curr_name;
begin
    select t.name
    into l_result
    from com_country t
    where t.code = i_country_code;
    
    return l_result;
    
exception
    when no_data_found then
        return i_country_code;
end;



function encode_pos_data_code(
    i_auth_rec              in aut_api_type_pkg.t_auth_rec
) return tie_api_type_pkg.t_point_code is
    l_result                tie_api_type_pkg.t_point_code;
begin
    l_result:= l_result ||
               case i_auth_rec.card_data_input_mode
                   when 'F2210000' then '0'
                   when 'F2210001' then '1'
                   when 'F2210002' then '2'
                   when 'F2210003' then '3'
                   when 'F2210004' then '4'
                   when 'F2210005' then '5'
                   when 'F2210006' then '6'
                   when 'F221000A' then 'A'
                   when 'F221000M' then 'M'
                                   else '0'
               end;
    l_result:= l_result ||
               case i_auth_rec.crdh_auth_cap
                   when 'F2220000' then '0'
                   when 'F2220001' then '1'
                   when 'F2220002' then '2'
                   when 'F2220003' then '5'
                   when 'F2210009' then '9'
                                   else '9'
               end;
    l_result:= l_result ||
               case i_auth_rec.card_capture_cap
                   when 'F2230000' then '0'
                   when 'F2230001' then '1'
                   when 'F2230002' then '9'
                                   else '9'
               end;
    l_result:= l_result ||
               case i_auth_rec.terminal_operating_env
                   when 'F2240000' then '0'
                   when 'F2240001' then '1'
                   when 'F2240002' then '2'
                   when 'F2240003' then '3'
                   when 'F2240004' then '4'
                   when 'F2240005' then '5'
                   when 'F2240009' then '9'
                                   else '9'
               end;
    l_result:= l_result ||
               case i_auth_rec.crdh_presence
                   when 'F2250000' then '0'
                   when 'F2250001' then '1'
                   when 'F2250002' then '2'
                   when 'F2250003' then '3'
                   when 'F2250004' then '4'
                   when 'F2250005' then '5'
                   when 'F2250009' then '9'
                                   else '9'
               end;
    l_result:= l_result ||
               case i_auth_rec.card_presence
                   when 'F2260000' then '0'
                   when 'F2260001' then '1'
                   when 'F2260009' then '9'
                                   else '9'
               end;
    -- TODO
    l_result:= l_result ||
               case i_auth_rec.card_data_input_mode
                   when 'F2270000' then '0'
                   when 'F2270001' then '1'
                   when 'F2270002' then '2'
                   when 'F2270003' then '3'
                   --when 'F2270004' then '4'
                   when 'F227000C' then '5'
                   when 'F2270006' then '6'
                   --when 'F2270008' then '8'
                   --when 'F2270009' then '9'
                   when 'F227000A' then 'A'
                   --when 'F2270009' then 'J'
                   when 'F227000M' then 'M'
                   when 'F227000N' then 'N'
                   when 'F227000R' then 'R'
                   when 'F227000S' then 'S' -- expand to U, V, T
                   when 'F227000W' then 'W' -- expand to Y if possible
                   --when 'F2270009' then 'Y'
                                   else '0'
               end;
    l_result:= l_result ||
               case i_auth_rec.crdh_auth_method
                   when 'F2280000' then '0'
                   when 'F2280001' then '1'
                   when 'F2280002' then '2'
                   when 'F2280005' then '5'
                   when 'F2280006' then '6'
                   when 'F2280009' then '9'
                                   else '9'
               end;
    l_result:= l_result ||
               case i_auth_rec.crdh_auth_entity
                   when 'F2290000' then '0'
                   when 'F2290001' then '1'
                   when 'F2290003' then '3'
                   when 'F2290004' then '4'
                   when 'F2290005' then '5'
                   when 'F2290009' then '9'
                                   else '9'
               end;
    l_result:= l_result ||
               case i_auth_rec.card_data_output_cap
                   when 'F22A0000' then '0'
                   when 'F22A0001' then '1'
                   when 'F22A0002' then '2'
                   when 'F22A0003' then '3'
                                   else '0'
               end;
    l_result:= l_result ||
               case i_auth_rec.terminal_output_cap
                   when 'F22B0000' then '0'
                   when 'F22B0001' then '1'
                   when 'F22B0002' then '2'
                   when 'F22B0003' then '3'
                   when 'F22B0004' then '4'
                                   else '0'
               end;
    l_result:= l_result ||
               case i_auth_rec.pin_capture_cap
                   when 'F22C0000' then '0'
                   when 'F22C0001' then '1'
                   when 'F22C0004' then '4'
                   when 'F22C0005' then '5'
                   when 'F22C0006' then '6'
                   when 'F22C0007' then '7'
                   when 'F22C0008' then '8'
                   when 'F22C0009' then '9'
                   when 'F22C000A' then 'A'
                   when 'F22C000B' then 'B'
                   when 'F22C000C' then 'C'
                                   else '1'
               end;
    
    return l_result;
end;


function get_original_id (
    i_fin_rec               in tie_api_type_pkg.t_fin_rec
) return com_api_type_pkg.t_long_id is
    l_original_id           com_api_type_pkg.t_long_id;
    l_split_hash            com_api_type_pkg.t_inst_id;
    l_tran_type             tie_api_type_pkg.t_tran_type;
begin
    l_split_hash := com_api_hash_pkg.get_split_hash(i_fin_rec.card);
    
    l_tran_type:= case i_fin_rec.tran_type
                      when tie_api_const_pkg.TC_PURCHASE_REVERSAL then
                          tie_api_const_pkg.TC_PURCHASE
                      when tie_api_const_pkg.TC_REFUND_REVERSAL then
                          tie_api_const_pkg.TC_REFUND
                      when tie_api_const_pkg.TC_CASH_REVERSAL then
                          tie_api_const_pkg.TC_CASH
                      when tie_api_const_pkg.TC_DEPOSIT_REVERSAL then
                          tie_api_const_pkg.TC_DEPOSIT
                      when tie_api_const_pkg.TC_CASHBACK_REVERSAL then
                          tie_api_const_pkg.TC_CASHBACK
                  end;
    if i_fin_rec.is_reversal = com_api_type_pkg.TRUE 
       and i_fin_rec.dispute_id is not null
    then
        select
            min(id)
        into
            l_original_id
        from
            tie_fin f
        where f.split_hash   = l_split_hash
            and f.mtid       = tie_api_const_pkg.MTID_PRESENTMENT
            and f.tran_type  = l_tran_type
            and is_reversal  = com_api_type_pkg.FALSE
            and dispute_id   = i_fin_rec.dispute_id;
    elsif i_fin_rec.is_reversal = com_api_type_pkg.TRUE 
    then
        select
            min(id)
        into
            l_original_id
        from
            tie_fin f
        where f.split_hash   = l_split_hash
            and f.mtid       = tie_api_const_pkg.MTID_PRESENTMENT
            and f.tran_type  = l_tran_type
            and is_reversal  = com_api_type_pkg.FALSE
            and f.ref_number = i_fin_rec.ref_number
        ;
    end if;

    return l_original_id;
end;
procedure put_message(
    i_fin                in tie_api_type_pkg.t_fin_rec
) is
    l_split_hash            com_api_type_pkg.t_tiny_id;
begin
    l_split_hash := com_api_hash_pkg.get_split_hash(i_fin.card);
    insert into tie_fin(
        id
      , split_hash
      , status
      , inst_id
      , network_id
      , file_id
      , is_incoming
      , is_reversal
      , is_invalid
      , is_rejected
      , dispute_id
      , impact
      , mtid
      , rec_centr
      , send_centr
      , iss_cmi
      , send_cmi
      , settl_cmi
      , acq_bank
      , acq_branch
      , member
      , clearing_group
      , sender_ica
      , receiver_ica
      , merchant
      , batch_nr
      , slip_nr
      , exp_date
      , tran_date_time
      , tran_type
      , appr_code
      , appr_src
      , stan
      , ref_number
      , amount
      , cash_back
      , fee
      , currency
      , ccy_exp
      , sb_amount
      , sb_cshback
      , sb_fee
      , sbnk_ccy
      , sb_ccyexp
      , sb_cnvrate
      , sb_cnvdate
      , i_amount
      , i_cshback
      , i_fee
      , ibnk_ccy
      , i_ccyexp
      , i_cnvrate
      , i_cnvdate
      , abvr_name
      , city
      , country
      , point_code
      , mcc_code
      , terminal
      , batch_id
      , settl_nr
      , settl_date
      , acqref_nr
      , clr_file_id
      , ms_number
      , file_date
      , source_algorithm
      , err_code
      , term_nr
      , ecmc_fee
      , tran_info
      , pr_amount
      , pr_cshback
      , pr_fee
      , prnk_ccy
      , pr_ccyexp
      , pr_cnvrate
      , pr_cnvdate
      , region
      , card_type
      , proc_class
      , card_seq_nr
      , msg_type
      , org_msg_type
      , proc_code
      , msg_category
      , merchant_code
      , moto_ind
      , susp_status
      , transact_row
      , authoriz_row
      , fld_043
      , fld_098
      , fld_102
      , fld_103
      , fld_104
      , fld_039
      , fld_sh6
      , batch_date
      , tr_fee
      , fld_040
      , fld_123_1
      , epi_42_48
      , fld_003
      , msc
      , account_nr
      , epi_42_48_full
      , other_code
      , fld_015
      , fld_095
      , audit_date
      , other_fee1
      , other_fee2
      , other_fee3
      , other_fee4
      , other_fee5
      , fld_030a
      , fld_055
      , fld_126
    )
    values(
        i_fin.id
      , l_split_hash
      , i_fin.status
      , i_fin.inst_id
      , i_fin.network_id
      , i_fin.file_id
      , i_fin.is_incoming
      , i_fin.is_reversal
      , i_fin.is_invalid
      , i_fin.is_rejected
      , i_fin.dispute_id
      , i_fin.impact
      , i_fin.mtid
      , i_fin.rec_centr
      , i_fin.send_centr
      , i_fin.iss_cmi
      , i_fin.send_cmi
      , i_fin.settl_cmi
      , i_fin.acq_bank
      , i_fin.acq_branch
      , i_fin.member
      , i_fin.clearing_group
      , i_fin.sender_ica
      , i_fin.receiver_ica
      , i_fin.merchant
      , i_fin.batch_nr
      , i_fin.slip_nr
      , i_fin.exp_date
      , i_fin.tran_date_time
      , i_fin.tran_type
      , i_fin.appr_code
      , i_fin.appr_src
      , i_fin.stan
      , i_fin.ref_number
      , i_fin.amount
      , i_fin.cash_back
      , i_fin.fee
      , i_fin.currency
      , i_fin.ccy_exp
      , i_fin.sb_amount
      , i_fin.sb_cshback
      , i_fin.sb_fee
      , i_fin.sbnk_ccy
      , i_fin.sb_ccyexp
      , i_fin.sb_cnvrate
      , i_fin.sb_cnvdate
      , i_fin.i_amount
      , i_fin.i_cshback
      , i_fin.i_fee
      , i_fin.ibnk_ccy
      , i_fin.i_ccyexp
      , i_fin.i_cnvrate
      , i_fin.i_cnvdate
      , i_fin.abvr_name
      , i_fin.city
      , i_fin.country
      , i_fin.point_code
      , i_fin.mcc_code
      , i_fin.terminal
      , i_fin.batch_id
      , i_fin.settl_nr
      , i_fin.settl_date
      , i_fin.acqref_nr
      , i_fin.clr_file_id
      , i_fin.ms_number
      , i_fin.file_date
      , i_fin.source_algorithm
      , i_fin.err_code
      , i_fin.term_nr
      , i_fin.ecmc_fee
      , i_fin.tran_info
      , i_fin.pr_amount
      , i_fin.pr_cshback
      , i_fin.pr_fee
      , i_fin.prnk_ccy
      , i_fin.pr_ccyexp
      , i_fin.pr_cnvrate
      , i_fin.pr_cnvdate
      , i_fin.region
      , i_fin.card_type
      , i_fin.proc_class
      , i_fin.card_seq_nr
      , i_fin.msg_type
      , i_fin.org_msg_type
      , i_fin.proc_code
      , i_fin.msg_category
      , i_fin.merchant_code
      , i_fin.moto_ind
      , i_fin.susp_status
      , i_fin.transact_row
      , i_fin.authoriz_row
      , i_fin.fld_043
      , i_fin.fld_098
      , i_fin.fld_102
      , i_fin.fld_103
      , i_fin.fld_104
      , i_fin.fld_039
      , i_fin.fld_sh6
      , i_fin.batch_date
      , i_fin.tr_fee
      , i_fin.fld_040
      , i_fin.fld_123_1
      , i_fin.epi_42_48
      , i_fin.fld_003
      , i_fin.msc
      , i_fin.account_nr
      , i_fin.epi_42_48_full
      , i_fin.other_code
      , i_fin.fld_015
      , i_fin.fld_095
      , i_fin.audit_date
      , i_fin.other_fee1
      , i_fin.other_fee2
      , i_fin.other_fee3
      , i_fin.other_fee4
      , i_fin.other_fee5
      , i_fin.fld_030a
      , i_fin.fld_055
      , i_fin.fld_126
    );
        
    insert into tie_card(
        id
        , card_number
    ) values (
        i_fin.id
        , iss_api_token_pkg.encode_card_number(i_card_number => i_fin.card)
    );
        
end put_message;

procedure create_operation (
    i_fin_rec               in tie_api_type_pkg.t_fin_rec
  , i_standard_id         in com_api_type_pkg.t_tiny_id
  , i_auth                in aut_api_type_pkg.t_auth_rec
  , i_status              in com_api_type_pkg.t_dict_value := null
  , i_incom_sess_file_id  in com_api_type_pkg.t_long_id
) is
    l_iss_inst_id                   com_api_type_pkg.t_inst_id;
    l_acq_inst_id                   com_api_type_pkg.t_inst_id;
    l_card_inst_id                  com_api_type_pkg.t_inst_id;
    l_iss_network_id                com_api_type_pkg.t_tiny_id;
    l_acq_network_id                com_api_type_pkg.t_tiny_id;
    l_card_network_id               com_api_type_pkg.t_tiny_id;
    l_card_type_id                  com_api_type_pkg.t_tiny_id;
    l_card_country                  com_api_type_pkg.t_country_code;
    l_bin_currency                  com_api_type_pkg.t_curr_code;
    l_sttl_currency                 com_api_type_pkg.t_curr_code;
    l_msg_type                      com_api_type_pkg.t_dict_value;
    l_sttl_type                     com_api_type_pkg.t_dict_value;
    l_status                        com_api_type_pkg.t_dict_value;
    l_match_status                  com_api_type_pkg.t_dict_value;
    l_terminal_type                 com_api_type_pkg.t_dict_value;
    l_oper_type                     com_api_type_pkg.t_dict_value;
    l_oper_id                       com_api_type_pkg.t_long_id;
    l_original_id                   com_api_type_pkg.t_long_id;
    l_proc_mode                     com_api_type_pkg.t_dict_value;
    l_oper_cashback_amount          com_api_type_pkg.t_money;

    l_operation                     opr_api_type_pkg.t_oper_rec;
    l_participant                   opr_api_type_pkg.t_oper_part_rec;
    l_iss_part                      opr_api_type_pkg.t_oper_part_rec;
    l_acq_part                      opr_api_type_pkg.t_oper_part_rec;
begin
    l_oper_id := i_fin_rec.id;

    l_original_id := get_original_id (i_fin_rec => i_fin_rec);

    l_status := nvl(i_status, opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY);
    
    if i_fin_rec.is_reversal = com_api_type_pkg.TRUE
       and i_fin_rec.is_incoming = com_api_type_pkg.FALSE
    then
        opr_api_operation_pkg.get_operation (
            i_oper_id      => l_original_id
            , o_operation  => l_operation
        );

        l_sttl_type := l_operation.sttl_type;
        l_oper_type := l_operation.oper_type;
        l_msg_type  := l_operation.msg_type;

        opr_api_operation_pkg.get_participant (
            i_oper_id              => l_original_id
            , i_participaint_type  => com_api_const_pkg.PARTICIPANT_ISSUER
            , o_participant        => l_participant
        );

        l_iss_inst_id := l_participant.inst_id;
        l_iss_network_id := l_participant.network_id;
        l_iss_part.split_hash := l_participant.split_hash;
        l_card_type_id := l_participant.card_type_id;
        l_card_country := l_participant.card_country;
        l_card_inst_id := l_participant.card_inst_id;
        l_card_network_id := l_participant.card_network_id;

        opr_api_operation_pkg.get_participant (
            i_oper_id              => l_original_id
            , i_participaint_type  => com_api_const_pkg.PARTICIPANT_ACQUIRER
            , o_participant        => l_participant
        );

        l_acq_inst_id := l_participant.inst_id;
        l_acq_network_id := l_participant.network_id;
        l_acq_part.merchant_id := l_participant.merchant_id;
        l_acq_part.terminal_id := l_participant.terminal_id;
        l_acq_part.split_hash := l_participant.split_hash;

    elsif i_auth.id is null then
        iss_api_bin_pkg.get_bin_info (
            i_card_number        => i_fin_rec.card
            , o_iss_inst_id      => l_iss_inst_id
            , o_iss_network_id   => l_iss_network_id
            , o_card_inst_id     => l_card_inst_id
            , o_card_network_id  => l_card_network_id
            , o_card_type        => l_card_type_id
            , o_card_country     => l_card_country
            , o_bin_currency     => l_bin_currency
            , o_sttl_currency    => l_sttl_currency
        );

        if l_card_inst_id is null then --????
            l_iss_inst_id := i_fin_rec.inst_id;
            l_iss_network_id := ost_api_institution_pkg.get_inst_network(i_fin_rec.inst_id);
        end if;

        l_acq_network_id := i_fin_rec.network_id;
        l_acq_inst_id := net_api_network_pkg.get_inst_id(i_fin_rec.network_id);

        begin
            net_api_sttl_pkg.get_sttl_type (
                i_iss_inst_id        => l_iss_inst_id
                , i_acq_inst_id      => l_acq_inst_id
                , i_card_inst_id     => l_card_inst_id
                , i_iss_network_id   => l_iss_network_id
                , i_acq_network_id   => l_acq_network_id
                , i_card_network_id  => l_card_network_id
                , i_acq_inst_bin     => nvl(i_fin_rec.acq_bank, i_fin_rec.send_cmi)
                , o_sttl_type        => l_sttl_type
                , o_match_status     => l_match_status
            );
        exception
            when others then
                trc_log_pkg.error (
                    i_text          => sqlerrm
                );

                l_status := opr_api_const_pkg.OPERATION_STATUS_MANUAL;

                update tie_fin
                   set status =  net_api_const_pkg.CLEARING_MSG_STATUS_INVALID
                 where id = i_fin_rec.id;

                trc_log_pkg.debug (
                    i_text          => 'Set message status is invalid and save operation'
                );
        end;

    else
        l_sttl_type := i_auth.sttl_type;
        l_iss_inst_id := i_auth.iss_inst_id;
        l_iss_network_id := i_auth.iss_network_id;
        l_acq_inst_id := i_auth.acq_inst_id;
        l_acq_network_id := i_auth.acq_network_id;
        l_match_status := i_auth.match_status;
    end if;

    -- Operation type and message type are not defined by a financial message in case of reversal operation,
    -- fields' values of an original operation are used instead of this
    if l_msg_type is null then
        l_msg_type := net_api_map_pkg.get_msg_type(
                          i_network_msg_type   => i_fin_rec.mtid
                        , i_standard_id        => i_standard_id
                        , i_mask_error         => com_api_type_pkg.FALSE
                      );
    end if;

    if l_oper_type is null then
        l_oper_type := net_api_map_pkg.get_oper_type(
                           i_network_oper_type => i_fin_rec.tran_type || i_fin_rec.proc_code || nvl(i_fin_rec.mcc_code, '____')
                         , i_standard_id       => i_standard_id
                         , i_mask_error        => com_api_type_pkg.FALSE
                       );
    end if;

    l_terminal_type :=
        case
            when i_fin_rec.terminal = 'N' then
                acq_api_const_pkg.TERMINAL_TYPE_IMPRINTER
            when i_fin_rec.terminal = 'A' then
                acq_api_const_pkg.TERMINAL_TYPE_ATM
            when i_fin_rec.terminal = 'P' then
                acq_api_const_pkg.TERMINAL_TYPE_POS
            when trim(i_fin_rec.terminal) is null and i_fin_rec.mcc_code = '6011' then
                acq_api_const_pkg.TERMINAL_TYPE_ATM
            else
                acq_api_const_pkg.TERMINAL_TYPE_POS
        end;

    if i_fin_rec.is_reversal = com_api_const_pkg.TRUE then
        opr_api_operation_pkg.get_operation(
            i_oper_id       => l_original_id
          , o_operation     => l_operation
        );
        l_terminal_type := l_operation.terminal_type;
    end if;
    
    opr_api_create_pkg.create_operation (
        io_oper_id                => l_oper_id
        , i_session_id            => get_session_id
        , i_status                => l_status
        , i_status_reason         => null
        , i_sttl_type             => l_sttl_type
        , i_msg_type              => l_msg_type
        , i_oper_type             => l_oper_type
        , i_oper_reason           => null
        , i_is_reversal           => i_fin_rec.is_reversal
        , i_original_id           => l_original_id
        , i_oper_amount           => i_fin_rec.amount
        , i_oper_currency         => get_currency_code(i_fin_rec.currency)
        , i_oper_cashback_amount  => l_oper_cashback_amount
        , i_sttl_amount           => i_fin_rec.sb_amount
        , i_sttl_currency         => get_currency_code(i_fin_rec.sbnk_ccy)
        , i_oper_date             => i_fin_rec.tran_date_time
        , i_host_date             => null
        , i_terminal_type         => l_terminal_type
        , i_mcc                   => i_fin_rec.mcc_code
        , i_originator_refnum     => i_fin_rec.ref_number
        , i_network_refnum        => i_fin_rec.acqref_nr
        , i_acq_inst_bin          => nvl(i_fin_rec.send_cmi, i_fin_rec.sender_ica)
        , i_merchant_number       => nvl(i_fin_rec.merchant_code, i_fin_rec.merchant)
        , i_terminal_number       => i_fin_rec.term_nr
        , i_merchant_name         => i_fin_rec.abvr_name
        , i_merchant_street       => null
        , i_merchant_city         => i_fin_rec.city
        , i_merchant_region       => null
        , i_merchant_country      => i_fin_rec.country
        , i_merchant_postcode     => null
        , i_dispute_id            => i_fin_rec.dispute_id
        , i_match_status          => l_match_status
        , i_proc_mode             => l_proc_mode
        , i_incom_sess_file_id    => i_incom_sess_file_id
        , i_fee_amount            => i_fin_rec.tr_fee
        , i_fee_currency          => get_currency_code(i_fin_rec.currency)
    );
    
    opr_api_additional_amount_pkg.save_amount(
        i_oper_id      => l_oper_id
      , i_amount_type  => 'AMPT0014'
      , i_amount_value => i_fin_rec.i_amount
      , i_currency     => get_currency_code(i_fin_rec.ibnk_ccy)
    );
    

    opr_api_create_pkg.add_participant (
        i_oper_id             => l_oper_id
        , i_msg_type          => l_msg_type
        , i_oper_type         => l_oper_type
        , i_participant_type  => com_api_const_pkg.PARTICIPANT_ISSUER
        , i_host_date         => null
        , i_inst_id           => l_iss_inst_id
        , i_network_id        => l_iss_network_id
        , i_customer_id       => iss_api_card_pkg.get_customer_id(i_fin_rec.card)
        , i_client_id_type    => opr_api_const_pkg.CLIENT_ID_TYPE_CARD
        , i_client_id_value   => i_fin_rec.card
        , i_card_id           => iss_api_card_pkg.get_card_id(i_fin_rec.card)
        , i_card_type_id      => l_card_type_id
        , i_card_expir_date   => null
        , i_card_seq_number   => i_fin_rec.card_seq_nr
        , i_card_number       => i_fin_rec.card
        , i_card_mask         => iss_api_card_pkg.get_card_mask(i_fin_rec.card)
        , i_card_hash         => com_api_hash_pkg.get_card_hash(i_fin_rec.card)
        , i_card_country      => l_card_country
        , i_card_inst_id      => l_card_inst_id
        , i_card_network_id   => l_card_network_id
        , i_account_id        => null
        , i_account_number    => null
        , i_account_amount    => null
        , i_account_currency  => null
        , i_auth_code         => i_fin_rec.appr_code
        , i_split_hash        => l_iss_part.split_hash
        , i_without_checks    => com_api_const_pkg.TRUE
    );

    opr_api_create_pkg.add_participant (
        i_oper_id             => l_oper_id
        , i_msg_type          => l_msg_type
        , i_oper_type         => l_oper_type
        , i_participant_type  => com_api_const_pkg.PARTICIPANT_ACQUIRER
        , i_host_date         => null
        , i_inst_id           => l_acq_inst_id
        , i_network_id        => l_acq_network_id
        , i_merchant_id       => l_acq_part.merchant_id
        , i_terminal_id       => l_acq_part.terminal_id
        , i_terminal_number   => i_fin_rec.term_nr
        , i_split_hash        => l_acq_part.split_hash
        , i_without_checks    => com_api_const_pkg.TRUE
    );
end;

procedure create_from_auth (
    i_auth_rec              in aut_api_type_pkg.t_auth_rec
  , i_oper_rec              in opr_api_type_pkg.t_oper_rec
  , i_iss_part_rec          in opr_api_type_pkg.t_oper_part_rec
) is
    l_fin                   tie_api_type_pkg.t_fin_rec;
    l_standard_id           com_api_type_pkg.t_tiny_id;
    l_host_id               com_api_type_pkg.t_tiny_id;
    l_send_cmi              tie_api_type_pkg.t_send_cmi;
    l_settl_cmi             tie_api_type_pkg.t_settl_cmi;
    l_use_auth_send_cmi     com_api_type_pkg.t_boolean;
    l_center_code           tie_api_type_pkg.t_send_centr;
    l_param_tab             com_api_type_pkg.t_param_tab;
begin

    l_fin.id               := i_auth_rec.id;
    l_fin.status           := net_api_const_pkg.CLEARING_MSG_STATUS_READY;
    l_fin.inst_id          := i_auth_rec.acq_inst_id;
    l_fin.network_id       := i_auth_rec.iss_network_id;
    l_fin.is_incoming      := com_api_type_pkg.FALSE;
    l_fin.is_reversal      := i_auth_rec.is_reversal;
    l_fin.is_rejected      := com_api_type_pkg.FALSE;
    l_fin.is_invalid       := com_api_type_pkg.FALSE;
    
    l_host_id := net_api_network_pkg.get_member_id (
        i_inst_id       => i_auth_rec.iss_inst_id
      , i_network_id  => i_auth_rec.iss_network_id
    );

    l_standard_id := net_api_network_pkg.get_offline_standard (
        i_host_id       => l_host_id
    );
    
    
    rul_api_param_pkg.set_param(
        i_name    => 'ISS_CARD_NETWORK_ID'
      , i_value   => i_iss_part_rec.card_network_id
      , io_params => l_param_tab
    );

    l_settl_cmi:= nvl(
        cmn_api_standard_pkg.get_varchar_value (
            i_inst_id     => l_fin.inst_id
          , i_standard_id => l_standard_id
          , i_object_id   => l_host_id
          , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_param_name  => tie_api_const_pkg.SETTL_CMI
          , i_param_tab   => l_param_tab
        )
      , i_auth_rec.acq_inst_bin
    );
    
    l_use_auth_send_cmi:= nvl(
        cmn_api_standard_pkg.get_number_value (
            i_inst_id     => l_fin.inst_id
          , i_standard_id => l_standard_id
          , i_object_id   => l_host_id
          , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_param_name  => tie_api_const_pkg.USE_AUTH_ACQ_BIN_AS_SEND_CMI
          , i_param_tab   => l_param_tab
        )
      , com_api_const_pkg.FALSE
    );
    if l_use_auth_send_cmi = com_api_const_pkg.FALSE then
        l_send_cmi:= 
            cmn_api_standard_pkg.get_varchar_value (
                i_inst_id     => l_fin.inst_id
              , i_standard_id => l_standard_id
              , i_object_id   => l_host_id
              , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
              , i_param_name  => tie_api_const_pkg.SETTL_CMI
              , i_param_tab   => l_param_tab
        );
    else
        l_send_cmi:= i_auth_rec.acq_inst_bin;
    end if;
    
    l_center_code:= nvl(
        cmn_api_standard_pkg.get_number_value (
            i_inst_id     => l_fin.inst_id
          , i_standard_id => l_standard_id
          , i_object_id   => l_host_id
          , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
          , i_param_name  => tie_api_const_pkg.CENTER_CODE
          , i_param_tab   => l_param_tab
        )
      , 0
    );

    l_fin.impact           := null; --
    l_fin.mtid             := tie_api_const_pkg.MTID_PRESENTMENT;
    l_fin.rec_centr        := 0;
    l_fin.send_centr       := l_center_code;
    l_fin.iss_cmi          := null;
    l_fin.send_cmi         := l_send_cmi;
    l_fin.settl_cmi        := l_settl_cmi;
    l_fin.acq_bank         := null;
    l_fin.acq_branch       := null;
    l_fin.member           := null;
    l_fin.clearing_group   := null;
    l_fin.sender_ica       := null;
    l_fin.receiver_ica     := null;
    l_fin.merchant         := null;--substr(i_oper_rec.merchant_number,1,7);
    l_fin.batch_nr         := null;
    l_fin.slip_nr          := null;
    l_fin.card             := i_auth_rec.card_number;
    l_fin.exp_date         := i_auth_rec.card_expir_date;
    l_fin.tran_date_time   := i_auth_rec.oper_date;
    l_fin.tran_type        := get_tran_type(
                                  i_oper_type     => i_auth_rec.oper_type
                                , i_is_reversal   => i_auth_rec.is_reversal
                              );
    l_fin.appr_code        := i_auth_rec.auth_code;
    l_fin.appr_src         := 1;
    l_fin.stan             := i_auth_rec.system_trace_audit_number;
    l_fin.ref_number       := i_auth_rec.originator_refnum;
    l_fin.amount           := i_oper_rec.oper_amount;
    l_fin.cash_back        := i_oper_rec.oper_cashback_amount;
    l_fin.fee              := null;--i_oper_rec.;
    l_fin.currency         := get_currency_name(i_oper_rec.oper_currency);
    l_fin.ccy_exp          := get_currency_exp(i_curr_name => l_fin.currency);
    l_fin.sb_amount        := null;
    l_fin.sb_cshback       := null;
    l_fin.sb_fee           := null;
    l_fin.sbnk_ccy         := null;
    l_fin.sb_ccyexp        := null;
    l_fin.sb_cnvrate       := null;
    l_fin.sb_cnvdate       := null;
    opr_api_additional_amount_pkg.get_amount(
        i_oper_id     => i_auth_rec.id
      , i_amount_type => 'AMPR0013'
      , o_amount      => l_fin.i_amount
      , o_currency    => l_fin.ibnk_ccy
      , i_mask_error  => com_api_const_pkg.TRUE
    );
    l_fin.ibnk_ccy:= 
        get_currency_name(
            i_curr_code      => l_fin.ibnk_ccy
        );
    l_fin.i_cshback        := null;
    l_fin.i_fee            := null;

    if l_fin.i_amount is null then
        l_fin.i_amount     := l_fin.amount;
        l_fin.ibnk_ccy     := l_fin.currency;
    end if;
    l_fin.i_ccyexp         := get_currency_exp(i_curr_name => l_fin.ibnk_ccy);
    l_fin.i_cnvrate        := null;
    l_fin.i_cnvdate        := null;
    l_fin.abvr_name        := i_oper_rec.merchant_name;
    l_fin.city             := i_oper_rec.merchant_city;
    l_fin.country          := get_country_name(i_oper_rec.merchant_country);
    l_fin.point_code       := encode_pos_data_code(
                                  i_auth_rec      => i_auth_rec
                              );
    l_fin.mcc_code         := i_auth_rec.mcc;
    l_fin.terminal         := case i_auth_rec.terminal_type
                                  when 'TRMT0001' then 'N'
                                  when 'TRMT0002' then 'A'
                                  when 'TRMT0003' then 'P'
                                                  else ' '
                              end;
    l_fin.batch_id         := null;
    l_fin.settl_nr         := null;
    l_fin.settl_date       := null;
    l_fin.acqref_nr        := null;
    l_fin.clr_file_id      := null;
    l_fin.ms_number        := null;
    l_fin.file_date        := null;
    l_fin.source_algorithm := null;
    l_fin.err_code         := null;
    l_fin.term_nr          := (case when length(i_auth_rec.terminal_number) >= 8 
                                  then substr(i_auth_rec.terminal_number, -8) 
                                  else i_auth_rec.terminal_number
                               end);
    l_fin.ecmc_fee         := null;
    l_fin.tran_info        := lpad(substr(l_fin.point_code, 1, 1), 2, '0')
                            ||substr(l_fin.point_code, 8, 1)
                            ||lpad(i_auth_rec.card_seq_number, 3, '0');
    opr_api_additional_amount_pkg.get_amount(
        i_oper_id     => i_auth_rec.id
      , i_amount_type => 'AMPR0014'
      , o_amount      => l_fin.pr_amount
      , o_currency    => l_fin.prnk_ccy
      , i_mask_error  => com_api_const_pkg.TRUE
    );
    l_fin.pr_cshback       := null;
    l_fin.pr_fee           := null;
    l_fin.prnk_ccy         := 
        get_currency_name(
            i_curr_code      => l_fin.prnk_ccy
        );
    if l_fin.pr_amount is null then
        l_fin.pr_amount    := l_fin.amount;
        l_fin.prnk_ccy     := l_fin.currency;
    end if;
    l_fin.pr_ccyexp        := get_currency_exp(i_curr_name => l_fin.prnk_ccy);
    l_fin.pr_cnvrate       := null;
    l_fin.pr_cnvdate       := null;
    l_fin.region           := null;
    l_fin.card_type        := null;
    l_fin.proc_class       := null;
    l_fin.card_seq_nr      := i_auth_rec.card_seq_number;
    l_fin.msg_type         := null;
    l_fin.org_msg_type     := null;
    l_fin.proc_code        := get_proc_code(
                                  i_oper_type   => i_oper_rec.oper_type
                              );
    l_fin.msg_category     := 'D';
    l_fin.merchant_code    := i_auth_rec.merchant_number;
    l_fin.moto_ind         := null;
    l_fin.susp_status      := null;
    l_fin.transact_row     := null;
    l_fin.authoriz_row     := null;
    l_fin.fld_043          := null;
    l_fin.fld_098          := null;
    l_fin.fld_102          := null;
    l_fin.fld_103          := null;
    l_fin.fld_104          := null;
    l_fin.fld_039          := null;
    l_fin.fld_sh6          := null;
    l_fin.batch_date       := null;
    l_fin.tr_fee           := null;
    l_fin.fld_040          := i_auth_rec.card_service_code;
    l_fin.fld_123_1        := null;
    l_fin.epi_42_48        := null;
    l_fin.fld_003          := null;
    l_fin.msc              := null;
    l_fin.account_nr       := null;
    l_fin.epi_42_48_full   := null;
    l_fin.other_code       := null;
    l_fin.fld_015          := get_sysdate;
    l_fin.fld_095          := null;
    l_fin.audit_date       := null;
    l_fin.other_fee1       := null;
    l_fin.other_fee2       := null;
    l_fin.other_fee3       := null;
    l_fin.other_fee4       := null;
    l_fin.other_fee5       := null;
    l_fin.fld_030a         := null;
    l_fin.fld_055          := i_auth_rec.emv_data;
    l_fin.fld_126          := null;
    
    l_fin.impact           := 
        tie_api_fin_pkg.get_msg_impact(
            i_msg_type  => l_fin.msg_type
          , i_proc_code => l_fin.proc_code
        );
    
    put_message(
        i_fin       => l_fin
    );
    
end;

procedure create_incoming_first_pres (
    i_mes_fin_rec         in tie_api_type_pkg.t_mes_fin_rec
  , i_mes_chip_rec        in tie_api_type_pkg.t_mes_fin_add_chip_rec
  , i_mes_acq_rec         in tie_api_type_pkg.t_mes_fin_acq_ref_rec
  , i_file_id             in com_api_type_pkg.t_long_id
  , i_network_id          in com_api_type_pkg.t_tiny_id
  , i_host_id             in com_api_type_pkg.t_tiny_id
  , i_standard_id         in com_api_type_pkg.t_tiny_id
) is
    l_fin                   tie_api_type_pkg.t_fin_rec;
    l_card_network_id       com_api_type_pkg.t_tiny_id;
    l_card_type             com_api_type_pkg.t_tiny_id;
    l_card_country          com_api_type_pkg.t_curr_code;
    procedure make_message is
    begin
       l_fin.id                    := opr_api_create_pkg.get_id;
       l_fin.status                := net_api_const_pkg.CLEARING_MSG_STATUS_LOADED;
       l_fin.network_id            := i_network_id;
       l_fin.file_id               := i_file_id;
       l_fin.is_incoming           := com_api_const_pkg.TRUE;
       l_fin.is_reversal           := case 
                                         when i_mes_fin_rec.tran_type in
                                                  (
                                                    tie_api_const_pkg.TC_PURCHASE_REVERSAL 
                                                  , tie_api_const_pkg.TC_REFUND_REVERSAL   
                                                  , tie_api_const_pkg.TC_CASH_REVERSAL     
                                                  , tie_api_const_pkg.TC_DEPOSIT_REVERSAL  
                                                  , tie_api_const_pkg.TC_CASHBACK_REVERSAL 
                                                  )
                                         then
                                             com_api_const_pkg.TRUE
                                         else
                                             com_api_const_pkg.FALSE
                                     end
                                     ;
       l_fin.is_rejected           := com_api_const_pkg.FALSE;
       l_fin.is_invalid            := com_api_const_pkg.FALSE;
       -- TODO Dispute
       l_fin.dispute_id            := null;
       
       l_fin.mtid                  := i_mes_fin_rec.mtid;
       l_fin.rec_centr             := i_mes_fin_rec.rec_centr;
       l_fin.send_centr            := i_mes_fin_rec.send_centr;
       l_fin.iss_cmi               := i_mes_fin_rec.iss_cmi;
       l_fin.send_cmi              := i_mes_fin_rec.send_cmi;
       l_fin.settl_cmi             := i_mes_fin_rec.settl_cmi;
       l_fin.acq_bank              := i_mes_fin_rec.acq_bank;
       l_fin.acq_branch            := i_mes_fin_rec.acq_branch;
       l_fin.member                := i_mes_fin_rec.member;
       l_fin.clearing_group        := i_mes_fin_rec.clearing_group;
       l_fin.sender_ica            := i_mes_fin_rec.sender_ica;
       l_fin.receiver_ica          := i_mes_fin_rec.receiver_ica;
       l_fin.merchant              := i_mes_fin_rec.merchant;
       l_fin.batch_nr              := i_mes_fin_rec.batch_nr;
       l_fin.slip_nr               := i_mes_fin_rec.slip_nr;
       l_fin.card                  := i_mes_fin_rec.card;
       l_fin.exp_date              := last_day(i_mes_fin_rec.exp_date);
       l_fin.tran_date_time        := i_mes_fin_rec.tran_date
                                    + ( i_mes_fin_rec.tran_time - trunc(i_mes_fin_rec.tran_time) 
                                      );
       l_fin.tran_type             := i_mes_fin_rec.tran_type;
       l_fin.appr_code             := i_mes_fin_rec.appr_code;
       l_fin.appr_src              := i_mes_fin_rec.appr_src;
       l_fin.stan                  := i_mes_fin_rec.stan;
       l_fin.ref_number            := i_mes_fin_rec.ref_number;
       l_fin.amount                := i_mes_fin_rec.amount;
       l_fin.cash_back             := i_mes_fin_rec.cash_back;
       l_fin.fee                   := i_mes_fin_rec.fee;
       l_fin.currency              := i_mes_fin_rec.currency;
       l_fin.ccy_exp               := i_mes_fin_rec.ccy_exp;
       l_fin.sb_amount             := i_mes_fin_rec.sb_amount;
       l_fin.sb_cshback            := i_mes_fin_rec.sb_cshback;
       l_fin.sb_fee                := i_mes_fin_rec.sb_fee;
       l_fin.sbnk_ccy              := i_mes_fin_rec.sbnk_ccy;
       l_fin.sb_ccyexp             := i_mes_fin_rec.sb_ccyexp;
       l_fin.sb_cnvrate            := i_mes_fin_rec.sb_cnvrate;
       l_fin.sb_cnvdate            := i_mes_fin_rec.sb_cnvdate;
       l_fin.i_amount              := i_mes_fin_rec.i_amount;
       l_fin.i_cshback             := i_mes_fin_rec.i_cshback;
       l_fin.i_fee                 := i_mes_fin_rec.i_fee;
       l_fin.ibnk_ccy              := i_mes_fin_rec.ibnk_ccy;
       l_fin.i_ccyexp              := i_mes_fin_rec.i_ccyexp;
       l_fin.i_cnvrate             := i_mes_fin_rec.i_cnvrate;
       l_fin.i_cnvdate             := i_mes_fin_rec.i_cnvdate;
       l_fin.abvr_name             := i_mes_fin_rec.abvr_name;
       l_fin.city                  := i_mes_fin_rec.city;
       l_fin.country               := i_mes_fin_rec.country;
       l_fin.point_code            := i_mes_fin_rec.point_code;
       l_fin.mcc_code              := i_mes_fin_rec.mcc_code;
       l_fin.terminal              := i_mes_fin_rec.terminal;
       l_fin.batch_id              := i_mes_fin_rec.batch_id;
       l_fin.settl_nr              := i_mes_fin_rec.settl_nr;
       l_fin.settl_date            := i_mes_fin_rec.settl_date;
       l_fin.acqref_nr             := i_mes_fin_rec.acqref_nr;
       l_fin.clr_file_id           := i_mes_fin_rec.file_id;
       l_fin.ms_number             := i_mes_fin_rec.ms_number;
       l_fin.file_date             := i_mes_fin_rec.file_date;
       l_fin.source_algorithm      := i_mes_fin_rec.source_algorithm;
       l_fin.err_code              := i_mes_fin_rec.err_code;
       l_fin.term_nr               := i_mes_fin_rec.term_nr;
       l_fin.ecmc_fee              := i_mes_fin_rec.ecmc_fee;
       l_fin.tran_info             := i_mes_fin_rec.tran_info;
       l_fin.pr_amount             := i_mes_fin_rec.pr_amount;
       l_fin.pr_cshback            := i_mes_fin_rec.pr_cshback;
       l_fin.pr_fee                := i_mes_fin_rec.pr_fee;
       l_fin.prnk_ccy              := i_mes_fin_rec.prnk_ccy;
       l_fin.pr_ccyexp             := i_mes_fin_rec.pr_ccyexp;
       l_fin.pr_cnvrate            := i_mes_fin_rec.pr_cnvrate;
       l_fin.pr_cnvdate            := i_mes_fin_rec.pr_cnvdate;
       l_fin.region                := i_mes_fin_rec.region;
       l_fin.card_type             := i_mes_fin_rec.card_type;
       l_fin.proc_class            := i_mes_fin_rec.proc_class;
       l_fin.card_seq_nr           := i_mes_fin_rec.card_seq_nr;
       l_fin.msg_type              := i_mes_fin_rec.msg_type;
       l_fin.org_msg_type          := i_mes_fin_rec.org_msg_type;
       l_fin.proc_code             := i_mes_fin_rec.proc_code;
       l_fin.msg_category          := i_mes_fin_rec.msg_category;
       l_fin.merchant_code         := i_mes_fin_rec.merchant_code;
       l_fin.moto_ind              := i_mes_fin_rec.moto_ind;
       l_fin.susp_status           := i_mes_fin_rec.susp_status;
       l_fin.transact_row          := i_mes_fin_rec.transact_row;
       l_fin.authoriz_row          := i_mes_fin_rec.authoriz_row;
       l_fin.fld_043               := i_mes_fin_rec.fld_043;
       l_fin.fld_098               := i_mes_fin_rec.fld_098;
       l_fin.fld_102               := i_mes_fin_rec.fld_102;
       l_fin.fld_103               := i_mes_fin_rec.fld_103;
       l_fin.fld_104               := i_mes_fin_rec.fld_104;
       l_fin.fld_039               := i_mes_fin_rec.fld_039;
       l_fin.fld_sh6               := i_mes_fin_rec.fld_sh6;
       l_fin.batch_date            := i_mes_fin_rec.batch_date;
       l_fin.tr_fee                := i_mes_fin_rec.tr_fee;
       l_fin.fld_040               := i_mes_fin_rec.fld_040;
       l_fin.fld_123_1             := i_mes_fin_rec.fld_123_1;
       l_fin.epi_42_48             := i_mes_fin_rec.epi_42_48;
       l_fin.fld_003               := i_mes_fin_rec.fld_003;
       l_fin.msc                   := i_mes_fin_rec.msc;
       l_fin.account_nr            := i_mes_fin_rec.account_nr;
       l_fin.epi_42_48_full        := i_mes_fin_rec.epi_42_48_full;
       l_fin.other_code            := i_mes_fin_rec.other_code;
       l_fin.fld_015               := i_mes_fin_rec.fld_015;
       l_fin.fld_095               := i_mes_fin_rec.fld_095;
       l_fin.audit_date            := i_mes_fin_rec.audit_date;
       l_fin.other_fee1            := i_mes_fin_rec.other_fee1;
       l_fin.other_fee2            := i_mes_fin_rec.other_fee2;
       l_fin.other_fee3            := i_mes_fin_rec.other_fee3;
       l_fin.other_fee4            := i_mes_fin_rec.other_fee4;
       l_fin.other_fee5            := i_mes_fin_rec.other_fee5;
       l_fin.fld_030a              := i_mes_fin_rec.fld_030a;
       l_fin.fld_055               := i_mes_chip_rec.fld_055;
       l_fin.fld_126               := i_mes_acq_rec.fld_126;

       l_fin.impact                := tie_api_fin_pkg.get_msg_impact(
                                          i_msg_type  => l_fin.msg_type
                                        , i_proc_code => l_fin.proc_code
                                      );
       
    end make_message;
begin
    make_message;

    iss_api_bin_pkg.get_bin_info (
        i_card_number        => l_fin.card
        , o_card_inst_id     => l_fin.inst_id
        , o_card_network_id  => l_card_network_id
        , o_card_type        => l_card_type
        , o_card_country     => l_card_country
        , i_raise_error      => com_api_const_pkg.FALSE
    );
    if l_fin.inst_id is null then
        l_fin.inst_id:= 
            cmn_api_standard_pkg.find_value_owner (
                i_standard_id  => i_standard_id
              , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
              , i_object_id    => i_host_id
              , i_param_name   => tie_api_const_pkg.SEND_CMI
              , i_value_char   => l_fin.iss_cmi
            );
    end if;
    
    put_message(
        i_fin       => l_fin
    );
    
    create_operation (
        i_fin_rec             => l_fin
      , i_standard_id         => i_standard_id
      , i_auth                => null
      , i_incom_sess_file_id  => i_file_id
    );

end;

function estimate_messages_for_upload(
    i_network_id            in com_api_type_pkg.t_tiny_id
  , i_inst_id               in com_api_type_pkg.t_inst_id
  , i_start_date            in date default null
  , i_end_date              in date default null
  , i_card_network_id       in com_api_type_pkg.t_tiny_id default null
) return com_api_type_pkg.t_count is
    l_result                com_api_type_pkg.t_count:= 0;
begin
    if coalesce(i_start_date, i_end_date) is not null then
        select /*+ INDEX(f, tie_fin_status_CLMS10_ndx)*/
            count(*)
        into l_result
        from tie_fin f
           , opr_operation o
           , opr_participant ip
        where decode(f.status, 'CLMS0010', f.inst_id, null) = i_inst_id -- net_api_const.CLEARING_MSG_STATUS_READY
          and f.split_hash in (select split_hash from com_api_split_map_vw)
          and f.is_incoming = 0
          and f.id = o.id
          and f.network_id = i_network_id
          and ip.oper_id = o.id
          and ip.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
          and ( ip.card_network_id = i_card_network_id
                or i_card_network_id is null
              )
          and ( ( f.tran_date_time between trunc(nvl(i_start_date, f.tran_date_time)) 
                                     and trunc(nvl(i_end_date, f.tran_date_time)) + 1 - com_api_const_pkg.ONE_SECOND
                  and f.is_reversal = com_api_const_pkg.FALSE
                )
               or 
                ( o.host_date between nvl(i_start_date, trunc(o.host_date)) 
                                  and nvl(i_end_date, trunc(o.host_date)) + 1 - com_api_const_pkg.ONE_SECOND
                  and f.is_reversal = com_api_const_pkg.TRUE
                )
              )
        ;
    else
        select /*+ INDEX(f, tie_fin_status_CLMS10_ndx)*/
            count(*)*100
        into l_result
        from tie_fin f
           , opr_participant ip
        where decode(f.status, 'CLMS0010', f.inst_id, null) = i_inst_id -- net_api_const.CLEARING_MSG_STATUS_READY
          and f.split_hash in (select split_hash from com_api_split_map_vw)
          and f.is_incoming = com_api_const_pkg.FALSE
          and f.network_id = i_network_id
          and ip.oper_id = f.id
          and ip.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
          and ( ip.card_network_id = i_card_network_id
                or i_card_network_id is null
              )
        ;
    end if;
    return l_result;

    return l_result;
end;

procedure enum_messages_for_upload (
    i_network_id            in com_api_type_pkg.t_tiny_id
  , i_inst_id               in com_api_type_pkg.t_inst_id
  , i_start_date            in date default null
  , i_end_date              in date default null
  , i_card_network_id       in com_api_type_pkg.t_tiny_id
  , o_fin_cur              out tie_api_type_pkg.t_fin_cur
) is
begin
    if coalesce(i_start_date, i_end_date) is not null then
        open o_fin_cur for
            select /*+ INDEX(f, tie_fin_status_CLMS10_ndx)*/
                f.rowid
              , ip.card_network_id
              , ip.card_type_id
              , f.id
              , f.status
              , f.inst_id
              , f.network_id
              , f.file_id
              , f.is_incoming
              , f.is_reversal
              , f.is_invalid
              , f.is_rejected
              , f.dispute_id
              , f.impact
              , f.mtid
              , f.rec_centr
              , f.send_centr
              , f.iss_cmi
              , f.send_cmi
              , f.settl_cmi
              , f.acq_bank
              , f.acq_branch
              , f.member
              , f.clearing_group
              , f.sender_ica
              , f.receiver_ica
              , f.merchant
              , f.batch_nr
              , f.slip_nr
              , f.card
              , f.exp_date
              , f.tran_date_time
              , f.tran_type
              , f.appr_code
              , f.appr_src
              , f.stan
              , f.ref_number
              , f.amount
              , f.cash_back
              , f.fee
              , f.currency
              , f.ccy_exp
              , f.sb_amount
              , f.sb_cshback
              , f.sb_fee
              , f.sbnk_ccy
              , f.sb_ccyexp
              , f.sb_cnvrate
              , f.sb_cnvdate
              , f.i_amount
              , f.i_cshback
              , f.i_fee
              , f.ibnk_ccy
              , f.i_ccyexp
              , f.i_cnvrate
              , f.i_cnvdate
              , f.abvr_name
              , f.city
              , f.country
              , f.point_code
              , f.mcc_code
              , f.terminal
              , f.batch_id
              , f.settl_nr
              , f.settl_date
              , f.acqref_nr
              , f.clr_file_id
              , f.ms_number
              , f.file_date
              , f.source_algorithm
              , f.err_code
              , f.term_nr
              , f.ecmc_fee
              , f.tran_info
              , f.pr_amount
              , f.pr_cshback
              , f.pr_fee
              , f.prnk_ccy
              , f.pr_ccyexp
              , f.pr_cnvrate
              , f.pr_cnvdate
              , f.region
              , f.card_type
              , f.proc_class
              , f.card_seq_nr
              , f.msg_type
              , f.org_msg_type
              , f.proc_code
              , f.msg_category
              , f.merchant_code
              , f.moto_ind
              , f.susp_status
              , f.transact_row
              , f.authoriz_row
              , f.fld_043
              , f.fld_098
              , f.fld_102
              , f.fld_103
              , f.fld_104
              , f.fld_039
              , f.fld_sh6
              , f.batch_date
              , f.tr_fee
              , f.fld_040
              , f.fld_123_1
              , f.epi_42_48
              , f.fld_003
              , f.msc
              , f.account_nr
              , f.epi_42_48_full
              , f.other_code
              , f.fld_015
              , f.fld_095
              , f.audit_date
              , f.other_fee1
              , f.other_fee2
              , f.other_fee3
              , f.other_fee4
              , f.other_fee5
              , f.fld_030a
              , f.fld_055
              , f.fld_126
            from tie_fin f
               , opr_operation o
               , opr_participant ip
            where decode(f.status, 'CLMS0010', f.inst_id, null) = i_inst_id -- net_api_const.CLEARING_MSG_STATUS_READY
              and f.split_hash in (select split_hash from com_api_split_map_vw)
              and f.is_incoming = 0
              and f.id = o.id
              and f.network_id = i_network_id
              and ip.oper_id = o.id
              and ip.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
              and ( ip.card_network_id = i_card_network_id
                    or i_card_network_id is null
                  )
              and ( ( f.tran_date_time between trunc(nvl(i_start_date, f.tran_date_time)) 
                                         and trunc(nvl(i_end_date, f.tran_date_time)) + 1 - com_api_const_pkg.ONE_SECOND
                      and f.is_reversal = com_api_const_pkg.FALSE
                    )
                   or 
                    ( o.host_date between nvl(i_start_date, trunc(o.host_date)) 
                                      and nvl(i_end_date, trunc(o.host_date)) + 1 - com_api_const_pkg.ONE_SECOND
                      and f.is_reversal = com_api_const_pkg.TRUE
                    )
                  )
        ;
    else
        open o_fin_cur for
            select /*+ INDEX(f, tie_fin_status_CLMS10_ndx)*/
                f.rowid
              , ip.card_network_id
              , ip.card_type_id
              , f.id
              , f.status
              , f.inst_id
              , f.network_id
              , f.file_id
              , f.is_incoming
              , f.is_reversal
              , f.is_invalid
              , f.is_rejected
              , f.dispute_id
              , f.impact
              , f.mtid
              , f.rec_centr
              , f.send_centr
              , f.iss_cmi
              , f.send_cmi
              , f.settl_cmi
              , f.acq_bank
              , f.acq_branch
              , f.member
              , f.clearing_group
              , f.sender_ica
              , f.receiver_ica
              , f.merchant
              , f.batch_nr
              , f.slip_nr
              , f.card
              , f.exp_date
              , f.tran_date_time
              , f.tran_type
              , f.appr_code
              , f.appr_src
              , f.stan
              , f.ref_number
              , f.amount
              , f.cash_back
              , f.fee
              , f.currency
              , f.ccy_exp
              , f.sb_amount
              , f.sb_cshback
              , f.sb_fee
              , f.sbnk_ccy
              , f.sb_ccyexp
              , f.sb_cnvrate
              , f.sb_cnvdate
              , f.i_amount
              , f.i_cshback
              , f.i_fee
              , f.ibnk_ccy
              , f.i_ccyexp
              , f.i_cnvrate
              , f.i_cnvdate
              , f.abvr_name
              , f.city
              , f.country
              , f.point_code
              , f.mcc_code
              , f.terminal
              , f.batch_id
              , f.settl_nr
              , f.settl_date
              , f.acqref_nr
              , f.clr_file_id
              , f.ms_number
              , f.file_date
              , f.source_algorithm
              , f.err_code
              , f.term_nr
              , f.ecmc_fee
              , f.tran_info
              , f.pr_amount
              , f.pr_cshback
              , f.pr_fee
              , f.prnk_ccy
              , f.pr_ccyexp
              , f.pr_cnvrate
              , f.pr_cnvdate
              , f.region
              , f.card_type
              , f.proc_class
              , f.card_seq_nr
              , f.msg_type
              , f.org_msg_type
              , f.proc_code
              , f.msg_category
              , f.merchant_code
              , f.moto_ind
              , f.susp_status
              , f.transact_row
              , f.authoriz_row
              , f.fld_043
              , f.fld_098
              , f.fld_102
              , f.fld_103
              , f.fld_104
              , f.fld_039
              , f.fld_sh6
              , f.batch_date
              , f.tr_fee
              , f.fld_040
              , f.fld_123_1
              , f.epi_42_48
              , f.fld_003
              , f.msc
              , f.account_nr
              , f.epi_42_48_full
              , f.other_code
              , f.fld_015
              , f.fld_095
              , f.audit_date
              , f.other_fee1
              , f.other_fee2
              , f.other_fee3
              , f.other_fee4
              , f.other_fee5
              , f.fld_030a
              , f.fld_055
              , f.fld_126
            from tie_fin f
               , opr_participant ip
            where decode(f.status, 'CLMS0010', f.inst_id, null) = i_inst_id -- net_api_const.CLEARING_MSG_STATUS_READY
              and f.split_hash in (select split_hash from com_api_split_map_vw)
              and f.is_incoming = com_api_const_pkg.FALSE
              and f.network_id = i_network_id
              and ip.oper_id = f.id
              and ip.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
              and ( ip.card_network_id = i_card_network_id
                    or i_card_network_id is null
                  )
        ;
    end if;

end;

begin
    -- Initialization
    null;
end tie_api_fin_pkg;
/
