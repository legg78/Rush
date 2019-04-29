create or replace package body cst_ap_rcp_load_pkg is
/************************************************************
 * Processes for loading SATIM files <br />
 * Created by Gerbeev I.(gerbeev@bpcbt.com)  at 05.03.2019 <br />
 * Last changed by $Author: $ <br />
 * $LastChangedDate:: #$ <br />
 * Revision: $LastChangedRevision:  $ <br />
 * Module: cst_ap_rcp_load_pkg <br />
 * @headcom
 ***********************************************************/

procedure update_status(
    i_oper_id               in      com_api_type_pkg.t_long_id
  , i_oper_status           in      com_api_type_pkg.t_dict_value
) is
begin
    update opr_operation o
       set o.match_status   = i_oper_status
     where o.id             = i_oper_id;
end update_status;

procedure update_status(
    i_oper_id_tab           in      com_api_type_pkg.t_long_tab
  , i_oper_status           in      com_api_type_pkg.t_dict_value
) is
begin
    if i_oper_id_tab.count > 0 then
        forall i in 1 .. i_oper_id_tab.count
            update opr_operation o
               set o.match_status   = nvl(i_oper_status, o.match_status)
             where o.id             = i_oper_id_tab(i);
    end if;
end update_status;

function check_closed_session(
    i_auth_id           in  com_api_type_pkg.t_long_id
  , i_tag_id            in  com_api_type_pkg.t_short_id default cst_ap_api_const_pkg.TAG_ID_SESSION_DAY
) return com_api_type_pkg.t_name
is
    l_result            com_api_type_pkg.t_long_id;
begin
    select auth_id 
        into l_result
      from aup_tag_value tv
     where tv.tag_id = cst_ap_api_const_pkg.TAG_ID_SESSION_DAY
       and tv.auth_id       = i_auth_id
       and exists (select null from cst_ap_session s where s.status = 0 and s.id = to_number(tv.tag_value));

    return com_api_const_pkg.TRUE;

exception
    when no_data_found then
        return com_api_const_pkg.FALSE;
end check_closed_session;

function get_merchant_id(
    i_merchant_number       in      com_api_type_pkg.t_merchant_number
  , i_inst_id               in      com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_short_id is
    l_result                com_api_type_pkg.t_merchant_number;
begin
    select m.id
      into l_result
      from acq_merchant m
     where m.merchant_number = i_merchant_number
       and m.inst_id         = i_inst_id;

    return l_result;
exception
    when no_data_found then
        return null;
end;

function get_terminal_id(
    i_terminal_number       in      com_api_type_pkg.t_terminal_number
  , i_inst_id               in      com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_short_id is
    l_result                com_api_type_pkg.t_merchant_number;
begin
    select m.id
      into l_result
      from acq_terminal m
     where m.terminal_number = i_terminal_number
       and m.inst_id         = i_inst_id;

    return l_result;
exception
    when no_data_found then
        return null;
end;

procedure parse_header(
    i_raw_data              in      com_api_type_pkg.t_raw_data
  , o_file_header_rec           out cst_ap_api_type_pkg.t_file_header_rec
  , o_party_code                out com_api_type_pkg.t_cmid
  , io_processed_count      in  out com_api_type_pkg.t_long_id
  , io_excepted_count       in  out com_api_type_pkg.t_long_id
) is
begin
    o_file_header_rec.sign                    := substr(i_raw_data, 1, 1);

    if substr(i_raw_data, 1, 1) <> cst_ap_api_const_pkg.RCP_IMPORT_SIGN then
        io_excepted_count  := io_excepted_count + 1;

        com_api_error_pkg.raise_error(
            i_error             => 'WRONG_RCP_SIGN'
          , i_env_param1        => o_file_header_rec.sign
        );
    end if;

    o_file_header_rec.compensation_code       := substr(i_raw_data, 2, 2);
    o_file_header_rec.iss_currency_code       := substr(i_raw_data, 4, 2);
    o_file_header_rec.date_of_generation      := substr(i_raw_data, 6, 8);
    o_file_header_rec.time_of_generation      := substr(i_raw_data, 14, 6);
    o_file_header_rec.operation_code          := substr(i_raw_data, 20, 2);
    o_file_header_rec.participant_code        := substr(i_raw_data, 22, 3);
    o_file_header_rec.presentation_date       := substr(i_raw_data, 25, 8);
    o_file_header_rec.presentation_date_appl  := substr(i_raw_data, 33, 8);
    o_file_header_rec.number_of_delivery      := substr(i_raw_data, 41, 4);
    o_file_header_rec.registration_code       := substr(i_raw_data, 45, 2);
    o_file_header_rec.currency_code           := substr(i_raw_data, 47, 3);
    o_file_header_rec.total_amount            := substr(i_raw_data, 50, 15);
    o_file_header_rec.number_of_operation     := substr(i_raw_data, 65, 10);
    o_file_header_rec.source_identification   := substr(i_raw_data, 75, 3);
    o_file_header_rec.filler                  := substr(i_raw_data, 78, 573);

    o_party_code        := o_file_header_rec.participant_code;
    io_processed_count  := io_processed_count + 1;
end;


procedure parse_file_record(
    i_raw_data              in      com_api_type_pkg.t_raw_data
  , o_file_rec                  out cst_ap_api_type_pkg.t_file_rec
) is
begin
    if substr(i_raw_data, 20, 2) = cst_ap_api_const_pkg.FILE_OPERATION_TYPE_ATM then
        o_file_rec.sign                        := substr(i_raw_data, 1, 1);
        o_file_rec.compensation_code           := substr(i_raw_data, 2, 2);
        o_file_rec.iss_currency_code           := substr(i_raw_data, 4, 2);
        o_file_rec.date_of_generation          := substr(i_raw_data, 6, 8);
        o_file_rec.time_of_generation          := substr(i_raw_data, 14, 6);
        o_file_rec.operation_code              := substr(i_raw_data, 20, 2);
        o_file_rec.participant_code            := substr(i_raw_data, 22, 3); -- ACQ
        o_file_rec.presentation_date           := substr(i_raw_data, 25, 8);
        o_file_rec.presentation_date_appl      := substr(i_raw_data, 33, 8);
        o_file_rec.number_of_delivery          := substr(i_raw_data, 41, 4);
        o_file_rec.registration_code           := substr(i_raw_data, 45, 2);
        o_file_rec.currency_code               := substr(i_raw_data, 47, 3);
        o_file_rec.amount_of_operation         := substr(i_raw_data, 50, 15);
        o_file_rec.transaction_number          := substr(i_raw_data, 65, 12);
        o_file_rec.authorization_number        := substr(i_raw_data, 77, 20);
        o_file_rec.type_of_operation           := substr(i_raw_data, 97, 3);
        o_file_rec.code_of_dest_participant    := substr(i_raw_data, 100, 3); -- ISS
        o_file_rec.destination_currency        := substr(i_raw_data, 103, 2);
        o_file_rec.rib_of_the_creditor         := substr(i_raw_data, 105, 20);
        o_file_rec.card_number                 := substr(i_raw_data, 125, 16);
        o_file_rec.point_number                := substr(i_raw_data, 141, 10);
        o_file_rec.terminal_number             := substr(i_raw_data, 151, 10);
        o_file_rec.merchant_number             := substr(i_raw_data, 161, 11);
        o_file_rec.date_of_regulation          := substr(i_raw_data, 172, 8);
        o_file_rec.reson_for_reject            := substr(i_raw_data, 180, 8);
        o_file_rec.reference_of_operation      := substr(i_raw_data, 188, 18);
        o_file_rec.rio_of_operation            := substr(i_raw_data, 206, 38);
        o_file_rec.destination_agency_code     := substr(i_raw_data, 244, 5);
        o_file_rec.withdrawal_amount           := substr(i_raw_data, 249, 15);
        o_file_rec.sign_of_commission          := substr(i_raw_data, 264, 1);
        o_file_rec.amount_of_commision         := substr(i_raw_data, 265, 7);
        o_file_rec.date_of_withdrawal          := substr(i_raw_data, 272, 8);
        o_file_rec.time_of_withdrawal          := substr(i_raw_data, 280, 6);
        o_file_rec.processing_mode             := substr(i_raw_data, 286, 1);
        o_file_rec.authentication_mode         := substr(i_raw_data, 287, 1);
        o_file_rec.start_date_of_valid_card    := substr(i_raw_data, 288, 8);
        o_file_rec.end_date_of_valid_card      := substr(i_raw_data, 296, 8);
        o_file_rec.criptogram_information      := substr(i_raw_data, 304, 1);
        o_file_rec.atc                         := substr(i_raw_data, 305, 2);
        o_file_rec.tvr                         := substr(i_raw_data, 307, 5);
        o_file_rec.remitting_agency_code       := substr(i_raw_data, 312, 5);
        o_file_rec.filler                      := substr(i_raw_data, 317, 334);

    elsif substr(i_raw_data, 20, 2) in (
                                         cst_ap_api_const_pkg.FILE_OPERATION_TYPE_POS
                                       , cst_ap_api_const_pkg.FILE_OPERATION_TYPE_REFUND
                                       )
    then
        o_file_rec.sign                        := substr(i_raw_data, 1, 1);
        o_file_rec.compensation_code           := substr(i_raw_data, 2, 2);
        o_file_rec.iss_currency_code           := substr(i_raw_data, 4, 2);
        o_file_rec.date_of_generation          := substr(i_raw_data, 6, 8);
        o_file_rec.time_of_generation          := substr(i_raw_data, 14, 6);
        o_file_rec.operation_code              := substr(i_raw_data, 20, 2);
        o_file_rec.participant_code            := substr(i_raw_data, 22, 3);
        o_file_rec.presentation_date           := substr(i_raw_data, 25, 8);
        o_file_rec.presentation_date_appl      := substr(i_raw_data, 33, 8);
        o_file_rec.number_of_delivery          := substr(i_raw_data, 41, 4);
        o_file_rec.registration_code           := substr(i_raw_data, 45, 2);
        o_file_rec.currency_code               := substr(i_raw_data, 47, 3);
        o_file_rec.amount_of_operation         := substr(i_raw_data, 50, 15);
        o_file_rec.transaction_number          := substr(i_raw_data, 65, 12);
        o_file_rec.authorization_number        := substr(i_raw_data, 77, 20);
        o_file_rec.type_of_operation           := substr(i_raw_data, 97, 3);
        o_file_rec.code_of_dest_participant    := substr(i_raw_data, 100, 3);
        o_file_rec.destination_currency        := substr(i_raw_data, 103, 2);
        o_file_rec.rib_of_the_creditor         := substr(i_raw_data, 105, 20);
        o_file_rec.card_number                 := substr(i_raw_data, 125, 16);
        o_file_rec.point_number                := substr(i_raw_data, 141, 10);
        o_file_rec.terminal_number             := substr(i_raw_data, 151, 10);
        o_file_rec.merchant_number             := substr(i_raw_data, 161, 11);
        o_file_rec.date_of_regulation          := substr(i_raw_data, 172, 8);
        o_file_rec.reson_for_reject            := substr(i_raw_data, 180, 8);
        o_file_rec.reference_of_operation      := substr(i_raw_data, 188, 18);
        o_file_rec.rio_of_operation            := substr(i_raw_data, 206, 38);
        o_file_rec.payment_type                := substr(i_raw_data, 244, 2);
        o_file_rec.amount                      := substr(i_raw_data, 246, 15);
        o_file_rec.sign_of_operation           := substr(i_raw_data, 261, 1);
        o_file_rec.sign_of_commission          := substr(i_raw_data, 262, 1);
        o_file_rec.amount_of_commision         := substr(i_raw_data, 263, 7);
        o_file_rec.date_of_payment             := substr(i_raw_data, 270, 8);
        o_file_rec.time_of_payment             := substr(i_raw_data, 278, 6);
        o_file_rec.processing_mode             := substr(i_raw_data, 284, 1);
        o_file_rec.authentication_mode         := substr(i_raw_data, 285, 1);
        o_file_rec.start_date_of_valid_card    := substr(i_raw_data, 286, 8);
        o_file_rec.end_date_of_valid_card      := substr(i_raw_data, 294, 8);
        o_file_rec.criptogram_information      := substr(i_raw_data, 302, 1);
        o_file_rec.atc                         := substr(i_raw_data, 303, 2);
        o_file_rec.tvr                         := substr(i_raw_data, 305, 5);
        o_file_rec.acceptor_customer_discount  := substr(i_raw_data, 310, 8);
        o_file_rec.presence_indicator_rib_iban := substr(i_raw_data, 318, 1);
        o_file_rec.prefix_iban                 := substr(i_raw_data, 319, 4);
        o_file_rec.merchant_name               := substr(i_raw_data, 323, 50);
        o_file_rec.address_of_merchant         := substr(i_raw_data, 373, 70);
        o_file_rec.telephone_of_merchant       := substr(i_raw_data, 443, 10);
        o_file_rec.acceptor_contract_number    := substr(i_raw_data, 453, 15);
        o_file_rec.acceptor_activity_code      := substr(i_raw_data, 468, 6);
        o_file_rec.remitting_agency_code       := substr(i_raw_data, 474, 5);
        o_file_rec.filler                      := substr(i_raw_data, 479, 172);
    else
        null;
    end if;
end parse_file_record;

procedure match_record(
    i_file_rec                  in      cst_ap_api_type_pkg.t_file_rec
  , i_card_status               in      com_api_type_pkg.t_name
  , i_tag_cst_iss_part_code     in      com_api_type_pkg.t_name
  , i_tag_cst_acq_part_code     in      com_api_type_pkg.t_name
  , i_match_status              in      com_api_type_pkg.t_name
  , i_closed_session            in      com_api_type_pkg.t_boolean
  , i_tp_operation_not_found    in      com_api_type_pkg.t_boolean
  , o_create_operation              out com_api_type_pkg.t_boolean
  , o_resp_code                     out com_api_type_pkg.t_dict_value
) is
begin

    -- TP operation not in status MTST5000
    if i_match_status <> cst_ap_api_const_pkg.STATUS_TP_FILE_LOADED then

        if i_file_rec.operation_code = cst_ap_api_const_pkg.FILE_OPERATION_TYPE_POS          --'050'
        then
            o_resp_code := cst_ap_api_const_pkg.RESP_CODE_DOUBLE_OPERATION;         -- 'RESP6001';

        elsif i_file_rec.operation_code = cst_ap_api_const_pkg.FILE_OPERATION_TYPE_ATM       --'040'
        then
            o_resp_code := cst_ap_api_const_pkg.RESP_CODE_DOUBLE_OPERATION;         -- 'RESP6001';

        elsif i_file_rec.operation_code = cst_ap_api_const_pkg.FILE_OPERATION_TYPE_REFUND    --'051'
        then
            o_resp_code := cst_ap_api_const_pkg.RESP_CODE_DOUBLE_OPERATION;         -- 'RESP6001';

        end if;

        -- Create operation on base RCP Set reject code and active session(tag CST_AP_SESSION)
        o_create_operation  := com_api_const_pkg.TRUE;

    -- Issuer bank(Aup_tag_value for CST_ISS_PART_CODE) or Acquirer bank(Aup_tag_value for CST_ACQ_PART_CODE) not compare in RCP and TP operation.
    elsif   i_tag_cst_acq_part_code <> i_file_rec.participant_code
        or  i_tag_cst_iss_part_code <> i_file_rec.code_of_dest_participant
    then
        if i_file_rec.operation_code = cst_ap_api_const_pkg.FILE_OPERATION_TYPE_POS          --'050'
        then
            o_resp_code := cst_ap_api_const_pkg.RESP_CODE_INVALID_BANK_INFO;        -- 'RESP6002';

        elsif i_file_rec.operation_code = cst_ap_api_const_pkg.FILE_OPERATION_TYPE_ATM       --'040'
        then
            o_resp_code := cst_ap_api_const_pkg.RESP_CODE_INVALID_BANK_INFO;        -- 'RESP6002';

        elsif i_file_rec.operation_code = cst_ap_api_const_pkg.FILE_OPERATION_TYPE_REFUND    --'051'
        then
            o_resp_code := cst_ap_api_const_pkg.RESP_CODE_INVALID_BANK_INFO;        -- 'RESP6002';

        end if;

        o_create_operation  := com_api_const_pkg.TRUE;

    -- Card has status CSTS0020, CSTS0021, CSTS0023, CSTS0024, CSTS0025
    elsif i_card_status in (
        iss_api_const_pkg.CARD_STATUS_PERM_BLOCK_CLIENT       --'CSTS0020'
      , iss_api_const_pkg.CARD_STATUS_EXPIRY_OF_CARD          --'CSTS0021'
      , iss_api_const_pkg.CARD_STATUS_TEMP_BLOCK_BANK         --'CSTS0023'
      , iss_api_const_pkg.CARD_STATUS_TEMP_BLOCK_CLREQ        --'CSTS0024'
      , iss_api_const_pkg.CARD_STATUS_PERM_BLOCK_BANK         --'CSTS0025'
    ) then
        if i_file_rec.operation_code = cst_ap_api_const_pkg.FILE_OPERATION_TYPE_POS              --'050'
        then
            o_resp_code := cst_ap_api_const_pkg.RESP_CODE_POS_BLOCK_ON_CARD;            -- 'RESP6501';

        elsif i_file_rec.operation_code = cst_ap_api_const_pkg.FILE_OPERATION_TYPE_ATM           --'040'
        then
            o_resp_code := cst_ap_api_const_pkg.RESP_CODE_ATM_BLOCK_ON_CARD;            -- 'RESP6401';

        elsif i_file_rec.operation_code = cst_ap_api_const_pkg.FILE_OPERATION_TYPE_REFUND        --'051'
        then
            o_resp_code := cst_ap_api_const_pkg.RESP_CODE_REF_BLOCK_ON_CARD;            -- 'RESP6511';

        end if;

        o_create_operation  := com_api_const_pkg.TRUE;

    -- Card does not have status CSTS0000 or CSTS0022
    elsif i_card_status not in (
        iss_api_const_pkg.CARD_STATUS_VALID_CARD            --'CSTS0000'
      , iss_api_const_pkg.CARD_STATUS_EXPIRY_OF_CARD        --'CSTS0022'
    ) then
        if i_file_rec.operation_code = cst_ap_api_const_pkg.FILE_OPERATION_TYPE_POS          --'050'
        then
            o_resp_code := cst_ap_api_const_pkg.RESP_CODE_POS_CARD_LOCK;            --'RESP6502';

        elsif i_file_rec.operation_code = cst_ap_api_const_pkg.FILE_OPERATION_TYPE_ATM       --'040'
        then
            o_resp_code := cst_ap_api_const_pkg.RESP_CODE_ATM_CARD_LOCK;            -- 'RESP6402';

        elsif i_file_rec.operation_code = cst_ap_api_const_pkg.FILE_OPERATION_TYPE_REFUND    --'051'
        then
            o_resp_code := cst_ap_api_const_pkg.RESP_CODE_REF_CARD_LOCK;            --'RESP6512';

        end if;

        o_create_operation  := com_api_const_pkg.TRUE;

    -- TP operation not found
    elsif i_tp_operation_not_found = com_api_const_pkg.TRUE
    then
        if i_file_rec.operation_code = cst_ap_api_const_pkg.FILE_OPERATION_TYPE_POS          --'050'
        then
            o_resp_code := cst_ap_api_const_pkg.RESP_CODE_POS_UNAUTH_TRANS;         -- 'RESP6503';

        elsif i_file_rec.operation_code = cst_ap_api_const_pkg.FILE_OPERATION_TYPE_ATM       --'040'
        then
            o_resp_code := cst_ap_api_const_pkg.RESP_CODE_ATM_UNAUTH_TRANS;         -- 'RESP6403';

        elsif i_file_rec.operation_code = cst_ap_api_const_pkg.FILE_OPERATION_TYPE_REFUND    --'051'
        then
            o_resp_code := cst_ap_api_const_pkg.RESP_CODE_REF_UNAUTH_TRANS;         -- 'RESP6513';

        end if;

        o_create_operation  := com_api_const_pkg.TRUE;

    -- Card has status CSTS0022
    elsif i_card_status = iss_api_const_pkg.CARD_STATUS_EXPIRY_OF_CARD
    then
        if i_file_rec.operation_code = cst_ap_api_const_pkg.FILE_OPERATION_TYPE_POS          --'050'
        then
            o_resp_code := cst_ap_api_const_pkg.RESP_CODE_POS_EXPIRED_CARD;         -- 'RESP6504';

        elsif i_file_rec.operation_code = cst_ap_api_const_pkg.FILE_OPERATION_TYPE_ATM       --'040'
        then
            o_resp_code := cst_ap_api_const_pkg.RESP_CODE_ATM_EXPIRED_CARD;         -- 'RESP6404';

        elsif i_file_rec.operation_code = cst_ap_api_const_pkg.FILE_OPERATION_TYPE_REFUND    --'051'
        then
            o_resp_code := cst_ap_api_const_pkg.RESP_CODE_REF_EXPIRED_CARD;         -- 'RESP6514';

        end if;

        o_create_operation  := com_api_const_pkg.TRUE;

    -- TP Operation relate to closed session
    elsif i_closed_session = com_api_const_pkg.TRUE
    then

        if i_file_rec.operation_code = cst_ap_api_const_pkg.FILE_OPERATION_TYPE_POS          --'050'
        then
            o_resp_code := cst_ap_api_const_pkg.RESP_CODE_POS_LATE_PRESENT;         --'RESP6505';

        elsif i_file_rec.operation_code = cst_ap_api_const_pkg.FILE_OPERATION_TYPE_ATM       --'040'
        then
            o_resp_code := cst_ap_api_const_pkg.RESP_CODE_ATM_LATE_PRESENT;         --'RESP6405';

        elsif i_file_rec.operation_code = cst_ap_api_const_pkg.FILE_OPERATION_TYPE_REFUND    --'051'
        then
            o_resp_code := cst_ap_api_const_pkg.RESP_CODE_REF_LATE_PRESENT;         --'RESP6515';

        end if;

        o_create_operation  := com_api_const_pkg.TRUE;

    -- All ckecks are Ok
    else
        o_resp_code := cst_ap_api_const_pkg.RESP_CODE_ACCEPT;   -- 'RESP6000';
    end if;

end match_record;

procedure process_record(
    i_raw_data              in      com_api_type_pkg.t_raw_data
  , i_file_header_rec       in      cst_ap_api_type_pkg.t_file_header_rec
  , i_eff_date              in      date
  , i_incom_sess_file_id    in      com_api_type_pkg.t_long_id
  , i_matched_oper_tab      in      com_api_type_pkg.t_param_tab
  , io_matched_oper_id_tab  in  out com_api_type_pkg.t_long_tab
  , io_processed_count      in  out com_api_type_pkg.t_long_id
  , io_excepted_count       in  out com_api_type_pkg.t_long_id

  , i_card_status_tab            in com_api_type_pkg.t_param_tab
  , i_tag_cst_iss_part_code_tab  in com_api_type_pkg.t_param_tab
  , i_tag_cst_acq_part_code_tab  in com_api_type_pkg.t_param_tab
  , i_match_status_tab           in com_api_type_pkg.t_param_tab
) is
    l_operation_id                  com_api_type_pkg.t_long_id;
    l_operation_rec                 opr_api_type_pkg.t_oper_rec;
    l_acq_participant_rec           opr_api_type_pkg.t_oper_part_rec;
    l_iss_participant_rec           opr_api_type_pkg.t_oper_part_rec;
    l_file_rec                      cst_ap_api_type_pkg.t_file_rec;

    l_create_operation              com_api_type_pkg.t_boolean;
    l_auth_rec                      aut_api_type_pkg.t_auth_rec;
    l_emv_data                      com_api_type_pkg.t_full_desc;
    l_resp_code                     com_api_type_pkg.t_dict_value;
    
    l_matching_operations_tab       com_api_type_pkg.t_param_tab;
    l_card_status_tab              com_api_type_pkg.t_param_tab;
    l_tag_cst_iss_part_code_tab    com_api_type_pkg.t_param_tab;
    l_tag_cst_acq_part_code_tab    com_api_type_pkg.t_param_tab;
    l_match_status_tab             com_api_type_pkg.t_param_tab;
    l_closed_session_tab            com_api_type_pkg.t_param_tab;
begin
    if substr(i_raw_data, 1, 1) <> cst_ap_api_const_pkg.RCP_IMPORT_SIGN then
        io_excepted_count  := io_excepted_count + 1;

        com_api_error_pkg.raise_error(
            i_error             => 'WRONG_RCP_SIGN'
          , i_env_param1        => substr(i_raw_data, 1, 1)
        );
    end if;

    parse_file_record(
        i_raw_data          => i_raw_data
      , o_file_rec          => l_file_rec
    );

    io_matched_oper_id_tab(io_matched_oper_id_tab.count + 1) := to_number(l_file_rec.transaction_number);

         -- i_matched_oper_tab.exists(l_file_rec.transaction_number) 
        match_record(
            i_file_rec                  => l_file_rec
          , i_card_status               => l_card_status_tab(l_file_rec.transaction_number)
          , i_tag_cst_iss_part_code     => l_tag_cst_iss_part_code_tab(l_file_rec.transaction_number)
          , i_tag_cst_acq_part_code     => l_tag_cst_acq_part_code_tab(l_file_rec.transaction_number)
          , i_match_status              => l_match_status_tab(l_file_rec.transaction_number)
          , i_closed_session            => l_closed_session_tab(l_file_rec.transaction_number)
          , i_tp_operation_not_found    => case when i_matched_oper_tab.exists(l_file_rec.transaction_number) then com_api_const_pkg.TRUE else com_api_const_pkg.FALSE end
          , o_create_operation          => l_create_operation
          , o_resp_code                 => l_resp_code
        );

    if l_create_operation = com_api_const_pkg.TRUE then

        l_operation_id                          := opr_api_create_pkg.get_id;

        l_operation_rec.id                      := l_operation_id;
        l_operation_rec.incom_sess_file_id      := i_incom_sess_file_id;
        l_operation_rec.host_date               :=
            to_date(
                l_file_rec.date_of_withdrawal || l_file_rec.time_of_withdrawal
               , 'yyyymmddhh24miss'
            );

        case l_file_rec.payment_type

        when cst_ap_api_const_pkg.PAYM_TYPE_PAYMENT then
            l_operation_rec.oper_type       := opr_api_const_pkg.OPERATION_TYPE_PURCHASE;   --'OPTP0000';

        when cst_ap_api_const_pkg.PAYM_TYPE_CASH_ADVANCE then
            l_operation_rec.oper_type       := opr_api_const_pkg.OPERATION_TYPE_POS_CASH;   --'OPTP0012';

        when cst_ap_api_const_pkg.PAYM_TYPE_BILL_PAYM_VIA_INT then
            l_operation_rec.oper_type       := opr_api_const_pkg.OPERATION_TYPE_PAYMENT;    --'OPTP0028';
            l_operation_rec.terminal_type   := acq_api_const_pkg.TERMINAL_TYPE_EPOS;        --'TRMT0004';

        when cst_ap_api_const_pkg.PAYM_TYPE_OTHER_PAYM_VIA_INT then
            l_operation_rec.oper_type       := cst_ap_api_const_pkg.OPER_TYPE_DEBIT_NOTIF;  --'OPTP0002';
            l_operation_rec.terminal_type   := acq_api_const_pkg.TERMINAL_TYPE_EPOS;        --'TRMT0004';

        when cst_ap_api_const_pkg.PAYM_TYPE_BILL_PAYM_VIA_POS then
            l_operation_rec.oper_type       := opr_api_const_pkg.OPERATION_TYPE_PAYMENT;    --'OPTP0028';
            l_operation_rec.terminal_type   := acq_api_const_pkg.TERMINAL_TYPE_POS;         --'TRMT0003';

        end case;

        if l_file_rec.sign_of_operation = 'D' or l_file_rec.sign_of_commission = 'D' then
            l_operation_rec.oper_type       := opr_api_const_pkg.OPERATION_TYPE_POS_CASH;   --'OPTP0012';
        end if;

        if l_file_rec.authentication_mode  = '3' then
            l_operation_rec.terminal_type   := acq_api_const_pkg.TERMINAL_TYPE_EPOS;        --'TRMT0004';
        elsif l_file_rec.authentication_mode in ('1', '2') then
            l_operation_rec.terminal_type   := acq_api_const_pkg.TERMINAL_TYPE_POS;         --'TRMT0003';
        end if;

        if l_file_rec.operation_code = cst_ap_api_const_pkg.FILE_OPERATION_TYPE_POS then
            l_operation_rec.oper_type       := opr_api_const_pkg.OPERATION_TYPE_PURCHASE;   --'OPTP0000';
        elsif l_file_rec.operation_code = cst_ap_api_const_pkg.FILE_OPERATION_TYPE_REFUND then
            l_operation_rec.oper_type       := opr_api_const_pkg.OPERATION_TYPE_REFUND;     --'OPTP0020';
        end if;

        l_operation_rec.oper_amount             := to_number(l_file_rec.amount_of_operation);
        l_operation_rec.merchant_name           := l_file_rec.merchant_name;
        l_operation_rec.merchant_street         := l_file_rec.address_of_merchant;
        l_operation_rec.originator_refnum       := l_file_rec.transaction_number;
        l_operation_rec.is_reversal             := com_api_const_pkg.FALSE;
        l_operation_rec.msg_type                := opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT;
        l_operation_rec.status                  := opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY;
        l_operation_rec.oper_currency           := cst_ap_api_const_pkg.CURRENCY_TP;
        l_operation_rec.sttl_date               := i_eff_date;

        l_iss_participant_rec.oper_id           := l_operation_id;
        l_iss_participant_rec.participant_type  := com_api_const_pkg.PARTICIPANT_ISSUER;
        l_iss_participant_rec.auth_code         := to_number(l_file_rec.authorization_number);
        l_iss_participant_rec.card_number       := l_file_rec.card_number;
        l_iss_participant_rec.network_id        := cst_ap_api_const_pkg.NETWORK_ID;
        l_iss_participant_rec.client_id_type    := opr_api_const_pkg.CLIENT_ID_TYPE_CARD;
        l_iss_participant_rec.customer_id       := iss_api_card_pkg.get_customer_id(l_file_rec.card_number);

        l_acq_participant_rec.oper_id           := l_operation_id;
        l_acq_participant_rec.participant_type  := com_api_const_pkg.PARTICIPANT_ACQUIRER;
        l_acq_participant_rec.card_number       := l_file_rec.card_number;
        l_acq_participant_rec.network_id        := cst_ap_api_const_pkg.NETWORK_ID;
        l_acq_participant_rec.client_id_type    := opr_api_const_pkg.CLIENT_ID_TYPE_TERMINAL;

        l_acq_participant_rec.inst_id           := cst_ap_api_const_pkg.SAT_INST_ID;


        l_acq_participant_rec.inst_id           := cst_ap_api_const_pkg.SAT_INST_ID;
        l_iss_participant_rec.inst_id           := cst_ap_api_const_pkg.AP_INST_ID;


        if l_file_rec.operation_code = cst_ap_api_const_pkg.FILE_OPERATION_TYPE_REFUND    --'051'
        then
            l_operation_rec.sttl_type               := cst_ap_api_const_pkg.STTT_SATIM_ON_US;
            l_operation_rec.match_status            := cst_ap_api_const_pkg.STATUS_TP_FILE_LOADED;

            insert into aup_tag_value(
                auth_id
              , tag_id
              , tag_value
            )
            values (
                l_operation_id
              , cst_ap_api_const_pkg.TAG_SESSION_DAY
              , cst_ap_api_process_pkg.get_ap_session_id(
                    i_ap_session_status     => 1
                  , i_eff_date              => i_eff_date
                  , i_mask_error            => com_api_const_pkg.TRUE
                )
           );

        else
            l_operation_rec.sttl_type               := cst_ap_api_const_pkg.STTT_US_ON_SATIM;
            l_operation_rec.match_status            := cst_ap_api_const_pkg.STATUS_RCP_TRANS_ABSENT_IN_TP;
        end if;

        l_operation_rec.status      := opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY;

        l_acq_participant_rec.terminal_id :=
            get_terminal_id(
                i_terminal_number   => l_operation_rec.terminal_number
              , i_inst_id           => l_acq_participant_rec.inst_id
            );

        l_acq_participant_rec.merchant_id :=
            get_merchant_id(
                i_merchant_number   => l_operation_rec.merchant_number
              , i_inst_id           => l_acq_participant_rec.inst_id
            );

        opr_api_create_pkg.create_operation(
            io_oper_id                => l_operation_rec.id
          , i_session_id              => get_session_id
          , i_status                  => l_operation_rec.status
          , i_status_reason           => null
          , i_sttl_type               => l_operation_rec.sttl_type
          , i_msg_type                => l_operation_rec.msg_type
          , i_oper_type               => l_operation_rec.oper_type
          , i_oper_reason             => null
          , i_is_reversal             => l_operation_rec.is_reversal
          , i_oper_amount             => l_operation_rec.oper_amount
          , i_oper_currency           => l_operation_rec.oper_currency
          , i_oper_cashback_amount    => l_operation_rec.oper_cashback_amount
          , i_sttl_amount             => l_operation_rec.sttl_amount
          , i_sttl_currency           => l_operation_rec.sttl_currency
          , i_oper_date               => l_operation_rec.oper_date
          , i_host_date               => l_operation_rec.host_date
          , i_sttl_date               => l_operation_rec.sttl_date
          , i_terminal_type           => l_operation_rec.terminal_type
          , i_mcc                     => l_operation_rec.mcc
          , i_originator_refnum       => l_operation_rec.originator_refnum
          , i_network_refnum          => l_operation_rec.network_refnum
          , i_acq_inst_bin            => l_operation_rec.acq_inst_bin
          , i_forw_inst_bin           => l_operation_rec.forw_inst_bin
          , i_merchant_number         => l_operation_rec.merchant_number
          , i_terminal_number         => l_operation_rec.terminal_number
          , i_merchant_name           => l_operation_rec.merchant_name
          , i_merchant_street         => l_operation_rec.merchant_street
          , i_merchant_city           => l_operation_rec.merchant_city
          , i_merchant_region         => l_operation_rec.merchant_region
          , i_merchant_country        => l_operation_rec.merchant_country
          , i_merchant_postcode       => l_operation_rec.merchant_postcode
          , i_dispute_id              => l_operation_rec.dispute_id
          , i_match_status            => l_operation_rec.match_status
          , i_original_id             => l_operation_rec.original_id
          , i_proc_mode               => l_operation_rec.proc_mode
          , i_clearing_sequence_num   => l_operation_rec.clearing_sequence_num
          , i_clearing_sequence_count => l_operation_rec.clearing_sequence_count
          , i_incom_sess_file_id      => l_operation_rec.incom_sess_file_id
        );

        if l_iss_participant_rec.inst_id = cst_ap_api_const_pkg.AP_INST_ID then
            begin
                select card_id
                 into l_iss_participant_rec.card_id
                 from iss_card_number
                where card_number = l_iss_participant_rec.card_number;

                acc_api_account_pkg.get_account_info(
                    i_entity_type          =>  iss_api_const_pkg.ENTITY_TYPE_CARD
                  , i_object_id            =>  l_iss_participant_rec.card_id
                  , i_curr_code            =>  cst_ap_api_const_pkg.CURRENCY_ALGERIAN_DINAR
                  , o_account_number       =>  l_iss_participant_rec.account_number
                  , o_inst_id              =>  l_iss_participant_rec.inst_id
                );

                trc_log_pkg.debug(
                    i_text       => 'Found account [#1] using card id [#2] for institution [#3]'
                  , i_env_param1 => l_iss_participant_rec.account_number
                  , i_env_param2 => l_iss_participant_rec.card_id
                  , i_env_param3 => l_iss_participant_rec.inst_id
                );
            exception
                when others then
                    trc_log_pkg.error(
                        i_text       => 'Account not found [#1] for card id [#2] institution [#3]'
                      , i_env_param1 => l_iss_participant_rec.account_number
                      , i_env_param2 => l_iss_participant_rec.card_id
                      , i_env_param3 => l_iss_participant_rec.inst_id
                    );

                l_operation_rec.status := opr_api_const_pkg.OPERATION_STATUS_MANUAL;
            end;
        else
            trc_log_pkg.debug(
                i_text       => 'Foreign issuer participant [#1]'
              , i_env_param1 => l_iss_participant_rec.inst_id
            );
        end if;

        opr_api_create_pkg.add_participant(
            i_oper_id                 => l_operation_rec.id
          , i_msg_type                => l_operation_rec.msg_type
          , i_oper_type               => l_operation_rec.oper_type
          , i_participant_type        => l_iss_participant_rec.participant_type
          , i_host_date               => null
          , i_inst_id                 => l_iss_participant_rec.inst_id
          , i_network_id              => l_iss_participant_rec.network_id
          , i_customer_id             => l_iss_participant_rec.customer_id
          , i_client_id_type          => nvl(l_iss_participant_rec.client_id_type, opr_api_const_pkg.CLIENT_ID_TYPE_CARD)
          , i_client_id_value         => l_iss_participant_rec.client_id_value
          , i_card_id                 => l_iss_participant_rec.card_id
          , i_card_type_id            => l_iss_participant_rec.card_type_id
          , i_card_expir_date         => l_iss_participant_rec.card_expir_date
          , i_card_service_code       => l_iss_participant_rec.card_service_code
          , i_card_seq_number         => l_iss_participant_rec.card_seq_number
          , i_card_number             => l_iss_participant_rec.card_number
          , i_card_mask               => l_iss_participant_rec.card_mask
          , i_card_hash               => l_iss_participant_rec.card_hash
          , i_card_country            => l_iss_participant_rec.card_country
          , i_card_inst_id            => l_iss_participant_rec.card_inst_id
          , i_card_network_id         => l_iss_participant_rec.card_network_id
          , i_account_id              => null
          , i_account_number          => l_iss_participant_rec.account_number
          , i_account_amount          => null
          , i_account_currency        => null
          , i_auth_code               => l_iss_participant_rec.auth_code
          , i_split_hash              => l_iss_participant_rec.split_hash
          , i_without_checks          => com_api_const_pkg.FALSE
        );

        opr_api_create_pkg.add_participant(
            i_oper_id                 => l_operation_rec.id
          , i_msg_type                => l_operation_rec.msg_type
          , i_oper_type               => l_operation_rec.oper_type
          , i_participant_type        => l_acq_participant_rec.participant_type
          , i_host_date               => l_operation_rec.host_date
          , i_inst_id                 => l_acq_participant_rec.inst_id
          , i_network_id              => l_acq_participant_rec.network_id
          , i_merchant_number         => l_operation_rec.merchant_number
          , i_terminal_id             => l_acq_participant_rec.terminal_id
          , i_terminal_number         => l_operation_rec.terminal_number
          , i_split_hash              => l_acq_participant_rec.split_hash
          , i_without_checks          => com_api_const_pkg.FALSE
          , i_client_id_type          => l_acq_participant_rec.client_id_type
          , i_client_id_value         => l_operation_rec.terminal_number
        );

        l_auth_rec.id               := l_operation_rec.id;
        l_auth_rec.resp_code        := l_resp_code;
        l_auth_rec.external_auth_id := l_file_rec.transaction_number;
        l_auth_rec.proc_type        := aut_api_const_pkg.DEFAULT_AUTH_PROC_TYPE;
        l_auth_rec.is_advice        := com_api_const_pkg.FALSE;
        l_auth_rec.network_currency := cst_ap_api_const_pkg.CURRENCY_TP;
        l_auth_rec.auth_code        := l_iss_participant_rec.auth_code;


-- MTST5000, + заполнять тег CST_AP_SESSION - номером активной сессии,  сеттлемент тип = STTT5011 

        cst_ap_tp_load_pkg.put_auth_data(
            i_auth_data     =>  l_auth_rec
        );
    else
         update_status(
            i_oper_id           => i_matched_oper_tab(l_file_rec.transaction_number)
          , i_oper_status       => cst_ap_api_const_pkg.STATUS_RCP_FILE_LOADED
         );
    end if;

    io_processed_count := io_processed_count + 1;
end;

procedure prepare_matched_rcp_operations(
    o_matching_operations_tab       out     com_api_type_pkg.t_param_tab
  , o_card_status_tab              out     com_api_type_pkg.t_param_tab
  , o_tag_cst_iss_part_code_tab        out     com_api_type_pkg.t_param_tab
  , o_tag_cst_acq_part_code_tab        out     com_api_type_pkg.t_param_tab
  , o_match_status_tab                 out     com_api_type_pkg.t_param_tab
  , o_closed_session_tab                out     com_api_type_pkg.t_param_tab
) is
    l_oper_id_tab               com_api_type_pkg.t_long_tab;
    l_external_auth_id_tab      com_api_type_pkg.t_long_tab;
    l_card_instance_id          com_api_type_pkg.t_medium_id;
    l_card_id                   com_api_type_pkg.t_medium_id;
    l_card_instance_rec         iss_api_type_pkg.t_card_instance;

--    l_oper_status_tab           com_api_type_pkg.t_dict_tab;
    l_match_status_tab          com_api_type_pkg.t_dict_tab;

    l_card_number_tab           com_api_type_pkg.t_card_number_tab;

    l_tag_cst_iss_part_code     com_api_type_pkg.t_full_desc;
    l_tag_cst_acq_part_code     com_api_type_pkg.t_full_desc;
    

begin
    select o.id                 as oper_id
         , a.external_auth_id   as external_auth_id
--         , o.status             as oper_status
         , o.match_status       as match_status -- MSTS
         , c.card_number        as card_number
      bulk collect into
           l_oper_id_tab
         , l_external_auth_id_tab
--         , l_oper_status_tab
         , l_match_status_tab
         , l_card_number_tab
      from opr_operation        o
         , aut_auth             a
         , opr_card             c
     where o.id                 = a.id
--       and o.match_status       = cst_ap_api_const_pkg.STATUS_TP_FILE_LOADED
       and c.participant_type   = com_api_const_pkg.PARTICIPANT_ISSUER
       and a.external_auth_id   is not null;

    for i in 1 .. l_oper_id_tab.count loop
        o_matching_operations_tab(l_external_auth_id_tab(i)) := l_oper_id_tab(i);

        l_card_id :=
            iss_api_card_pkg.get_card_id(
                i_card_number               => l_card_number_tab(i)
                -- , i_inst_id              => null
            );

        l_card_instance_id :=
            iss_api_card_instance_pkg.get_card_instance_id(
                i_card_id => l_card_id
            );

        l_card_instance_rec :=
            iss_api_card_instance_pkg.get_instance(
                i_id                    => l_card_instance_id
              , i_card_id               => l_card_id
              , i_raise_error           => com_api_const_pkg.FALSE
            );

        o_card_status_tab(l_external_auth_id_tab(i)) := l_card_instance_rec.status;

        o_match_status_tab(l_external_auth_id_tab(i)) := l_match_status_tab(i);

        -- Code of destination participant
        o_tag_cst_iss_part_code_tab(l_external_auth_id_tab(i)) :=
            aup_api_tag_pkg.get_tag_value(
                i_auth_id => l_oper_id_tab(i)
              , i_tag_id  => aup_api_tag_pkg.find_tag_by_reference(i_reference => 'CST_ISS_PART_CODE') -- TAG_CST_ISS_PART_CODE
            );

        -- Source participant code
        o_tag_cst_acq_part_code_tab(l_external_auth_id_tab(i)) :=
            aup_api_tag_pkg.get_tag_value(
                i_auth_id => l_oper_id_tab(i)
              , i_tag_id  => aup_api_tag_pkg.find_tag_by_reference(i_reference => 'CST_ACQ_PART_CODE') -- TAG_CST_ACQ_PART_CODE
            );

  
        o_closed_session_tab(l_external_auth_id_tab(i)) :=
            check_closed_session(
                i_auth_id => l_external_auth_id_tab(i)
            );

    end loop;

end prepare_matched_rcp_operations;



procedure process_rcp(
    i_inst_id           in      com_api_type_pkg.t_inst_id      default cst_ap_api_const_pkg.AP_INST_ID
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name         := lower($$PLSQL_UNIT) || '.process_rcn: ';

    l_estimated_count           com_api_type_pkg.t_long_id      := 0;
    l_record_number             com_api_type_pkg.t_long_id      := 0;
    l_processed_count           com_api_type_pkg.t_long_id      := 0;
    l_excepted_count            com_api_type_pkg.t_long_id      := 0;
    l_rec                       com_api_type_pkg.t_text;

    l_eff_date                  date                            := com_api_sttl_day_pkg.get_sysdate;
    l_session_id                com_api_type_pkg.t_long_id      := prc_api_session_pkg.get_session_id;
    l_matching_operations_tab   com_api_type_pkg.t_param_tab;
    l_matched_oper_id_tab       com_api_type_pkg.t_long_tab;
    l_inst_id                   com_api_type_pkg.t_inst_id      := i_inst_id;
    l_file_header_rec           cst_ap_api_type_pkg.t_file_header_rec;
    l_part_code                 com_api_type_pkg.t_cmid;

    l_file_part_code            com_api_type_pkg.t_cmid;
    l_session_file_id           com_api_type_pkg.t_long_id;

    l_card_status_tab           com_api_type_pkg.t_param_tab;
    l_tag_cst_iss_part_code_tab com_api_type_pkg.t_param_tab;
    l_tag_cst_acq_part_code_tab com_api_type_pkg.t_param_tab;
    l_match_status_tab          com_api_type_pkg.t_param_tab;
    l_closed_session_tab        com_api_type_pkg.t_param_tab;

    cursor cu_records_count is
        select count(1)
          from prc_file_raw_data a
             , prc_session_file b
         where b.session_id      = l_session_id
           and a.session_file_id = b.id;

begin
    prc_api_stat_pkg.log_start;
  
    -- Generate array of operations, prepared to matching
    prepare_matched_rcp_operations(
        o_matching_operations_tab   => l_matching_operations_tab
      , o_card_status_tab           => l_card_status_tab           
      , o_tag_cst_iss_part_code_tab => l_tag_cst_iss_part_code_tab 
      , o_tag_cst_acq_part_code_tab => l_tag_cst_acq_part_code_tab 
      , o_match_status_tab          => l_match_status_tab          
      , o_closed_session_tab        => l_closed_session_tab
    );

    open cu_records_count;
    fetch cu_records_count into l_estimated_count;
    close cu_records_count;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count     => l_estimated_count
    );

    l_part_code :=
        com_api_flexible_data_pkg.get_flexible_value(
            i_field_name    => 'CST_PARTICIPANT_CODE'
          , i_entity_type   => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
          , i_object_id     => i_inst_id
        );

    for file in (
        select sf.id            as session_file_id
             , sf.record_count  as record_count
             , sf.file_name     as file_name
          from prc_session_file sf
         where sf.session_id    = l_session_id
         order by id
    ) loop
        l_session_file_id   := file.session_file_id;

        begin
            for rec in (
                select record_number
                     , raw_data
                     , count(1) over() cnt
                     , row_number() over(order by record_number) rn
                     , row_number() over(order by record_number desc) rn_desc
                  from prc_file_raw_data rd
                 where rd.session_file_id = l_session_file_id
                 order by rd.record_number
                )
            loop
                l_record_number := rec.record_number;
                l_rec           := rec.raw_data;

                if rec.record_number <> 1 then
                    process_record(
                        i_raw_data              => rec.raw_data
                      , i_file_header_rec       => l_file_header_rec
                      , i_eff_date              => l_eff_date
                      , i_incom_sess_file_id    => l_session_file_id
                      , i_matched_oper_tab      => l_matching_operations_tab
                      , io_matched_oper_id_tab  => l_matched_oper_id_tab
                      , io_processed_count      => l_processed_count
                      , io_excepted_count       => l_excepted_count
                      , i_card_status_tab               => l_card_status_tab
                      , i_tag_cst_iss_part_code_tab     => l_tag_cst_iss_part_code_tab
                      , i_tag_cst_acq_part_code_tab     => l_tag_cst_acq_part_code_tab
                      , i_match_status_tab              => l_match_status_tab
                    );
                else
                    parse_header(
                        i_raw_data              => rec.raw_data
                      , o_file_header_rec       => l_file_header_rec
                      , o_party_code            => l_file_part_code
                      , io_processed_count      => l_processed_count
                      , io_excepted_count       => l_excepted_count
                    );
                    if l_part_code <> l_file_part_code then
                        com_api_error_pkg.raise_error(
                            i_error         => 'TWO_DIFFERENT_INSTITUTES'
                          , i_env_param1    => l_part_code
                          , i_env_param2    => l_file_header_rec.participant_code
                        );

                    end if;
                end if;
            end loop;

/*
            if l_matched_oper_id_tab.count > 0 then
                update_status(
                    i_oper_id_tab   => l_matched_oper_id_tab
                  , i_oper_status   => cst_ap_api_const_pkg.STATUS_RCP_FILE_LOADED
                );
            else
                com_api_error_pkg.raise_error(
                    i_error         => 'CST_TP_FILE_ISNT_LOADED'
                  , i_env_param1    => file.file_name
                );
            end if;
*/

            prc_api_file_pkg.close_file(
                i_sess_file_id      => l_session_file_id
              , i_status            => prc_api_const_pkg.FILE_STATUS_ACCEPTED
            );

            l_processed_count := l_processed_count + file.record_count;

            prc_api_stat_pkg.log_end(
                i_processed_total   => l_processed_count
              , i_excepted_total    => l_excepted_count
              , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
            );

        exception
            when others then
                prc_api_stat_pkg.log_end(
                    i_result_code           => prc_api_const_pkg.PROCESS_RESULT_FAILED
                );

                if l_session_file_id is not null then
                    prc_api_file_pkg.close_file(
                        i_sess_file_id      => l_session_file_id
                      , i_status            => prc_api_const_pkg.FILE_STATUS_REJECTED
                    );
                end if;

                trc_log_pkg.fatal(
                    i_text          => LOG_PREFIX || 'UNHANDLED_EXCEPTION'
                  , i_env_param1    => sqlerrm
                );

                raise;
        end;
    end loop;

end process_rcp;

end cst_ap_rcp_load_pkg;
/
