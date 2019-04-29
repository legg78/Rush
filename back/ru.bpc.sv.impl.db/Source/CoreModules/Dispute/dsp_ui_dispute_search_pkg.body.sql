create or replace package body dsp_ui_dispute_search_pkg is
/************************************************************
 * User interface for displaying disputes in Issuing and Acquiring <br />
 * Created by Truschelev O.(truschelev@bpcbt.com) at 08.09.2016 <br />
 * Last changed by $Author: Truschelev $ <br />
 * $LastChangedDate:: 2016-09-08 18:55:00 +0400#$ <br />
 * Revision: $LastChangedRevision: 1 $ <br />
 * Module: dsp_ui_dispute_search_pkg <br />
 * @headcom
 ************************************************************/

g_dispute_tab                       dsp_ui_dispute_info_tpt       := dsp_ui_dispute_info_tpt();

type t_operation_id_exists_tab is table of binary_integer index by varchar2(16);
g_operation_id_exists_tab           t_operation_id_exists_tab;


function get_mcc_name(
    i_mcc                   in      com_api_type_pkg.t_name
  , i_lang                  in      com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_name is
    l_mcc_name                      com_api_type_pkg.t_name;
begin
     select mcc.name
       into l_mcc_name
       from com_ui_mcc_vw mcc
      where mcc.mcc   = i_mcc
        and mcc.lang = i_lang;
        
    return l_mcc_name;
exception when no_data_found then
    return null;
end get_mcc_name;

function get_payment_host_name(
    i_payment_host_id       in      com_api_type_pkg.t_name
  , i_lang                  in      com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_name is
    l_payment_host_name             com_api_type_pkg.t_name;
begin
     select h.description
       into l_payment_host_name
       from net_ui_host_vw h
      where h.id   = i_payment_host_id
        and h.lang = i_lang;

    return l_payment_host_name;
exception when no_data_found then
    return null;
end get_payment_host_name;

procedure set_level(
    i_oper_id           in      com_api_type_pkg.t_long_id
  , i_op_level          in      com_api_type_pkg.t_tiny_id
) is
begin
    if g_dispute_tab(g_operation_id_exists_tab(i_oper_id)).op_level is null then
        g_dispute_tab(g_operation_id_exists_tab(i_oper_id)).op_level := i_op_level;
    end if;
end set_level;

/*
 * Only mcw and visa are supported
 */
procedure get_additional_ips_info(
    i_oper_id               in      com_api_type_pkg.t_long_id
  , o_fin_message_type         out  com_api_type_pkg.t_name
  , o_fin_in_flag              out  com_api_type_pkg.t_byte_char
  , o_fin_reason_code          out  com_api_type_pkg.t_name
  , o_fin_member_text          out  com_api_type_pkg.t_param_value
  , o_fin_doc_flag             out  com_api_type_pkg.t_byte_char
  , o_fin_fraud_type           out  com_api_type_pkg.t_byte_char
  , o_fin_rejected             out  com_api_type_pkg.t_byte_char
  , o_fin_reversal             out  com_api_type_pkg.t_byte_char
  , o_created_by               out  com_api_type_pkg.t_name
  , o_fin_status               out  com_api_type_pkg.t_name
  , o_inst_id                  out  com_api_type_pkg.t_inst_id
  , o_network_id               out  com_api_type_pkg.t_network_id
  , o_ext_claim_id             out  com_api_type_pkg.t_attr_name
  , o_ext_message_id           out  com_api_type_pkg.t_attr_name
)
is
begin
    trc_log_pkg.debug(
        i_text => 'get_additional_ips_info: start for ' || i_oper_id
    );
    case 
    when vis_api_fin_message_pkg.is_visa(i_id => i_oper_id) = com_api_const_pkg.TRUE then
        for tab in (
            select case when f.id is not null
                        then f.trans_code
                        when d.id is not null
                        then '40'
                        else null
                   end as fin_message_type
                 , f.is_incoming as fin_in_flag
                 , case when t4.id is not null and f.trans_code in (15, 16, 17) and t4.dispute_condition is not null
                        then substr(substr(t4.dispute_condition, 1, 2) || '.' || substr(t4.dispute_condition, -1) || ' - '
                                 || get_article_text('DSCD0' || t4.dispute_condition), 1, 200)
                        when f.id is not null and f.reason_code is not null
                        then substr(f.reason_code || ' - ' || get_article_text('VMRC00' || f.reason_code), 1, 200)
                        when fee.id is not null and fee.reason_code is not null
                        then substr(fee.reason_code || ' - ' || get_article_text('FCRC' || fee.reason_code), 1, 200)
                        when r.id is not null and r.reason_code is not null
                        then substr(r.reason_code || ' - ' || get_article_text('RCRC00' || r.reason_code), 1, 200)
                        else null
                   end as fin_reason_code
                 , nvl(f.member_msg_text, fee.message_text) as fin_member_text
                 , case when f.dcc_indicator = ' '
                        then get_article_text('VDCI000 ')
                        when f.dcc_indicator is not null
                        then substr(f.dcc_indicator ||
                                    ' - ' || get_article_text('VDCI000' || f.dcc_indicator), 1, 200)
                        else null
                   end as fin_doc_flag
                 , case when d.fraud_type is not null
                        then substr(substr(d.fraud_type, 7, 2) || 
                          ' - ' || get_article_text(d.fraud_type) , 1, 200)
                        else null
                   end as fin_fraud_type
                 , f.is_rejected as fin_rejected
                 , f.is_reversal as fin_reversal
                 , case f.is_incoming
                       when com_api_const_pkg.TRUE
                       then 'UNDEFINED'
                       else null -- get information from app_history for the case
                   end as created_by
                 , get_article_text(i_article => nvl(f.status, d.status) )  as fin_status
                 , f.inst_id
                 , f.network_id
              from opr_operation o
              left join csm_case c        on o.id = c.original_id
              left join vis_fin_message f on o.id = f.id
              left join vis_fraud       d on o.id = d.id
              left join vis_fee       fee on o.id = fee.id
              left join vis_retrieval   r on o.id = r.id
              left join vis_tcr4       t4 on o.id = t4.id
             where o.id = i_oper_id
        ) loop
            o_fin_message_type := tab.fin_message_type;
            o_fin_in_flag      := tab.fin_in_flag;
            o_fin_reason_code  := tab.fin_reason_code;
            o_fin_member_text  := tab.fin_member_text;
            o_fin_doc_flag     := tab.fin_doc_flag;
            o_fin_fraud_type   := tab.fin_fraud_type;
            o_fin_rejected     := tab.fin_rejected;
            o_fin_reversal     := tab.fin_reversal;
            o_created_by       := tab.created_by;
            o_fin_status       := tab.fin_status;
            o_inst_id          := tab.inst_id;
            o_network_id       := tab.network_id;
            o_ext_claim_id     := null;
            o_ext_message_id   := null;
        end loop;
    when mcw_api_fin_pkg.is_mastercard(i_id => i_oper_id) = com_api_const_pkg.TRUE then
        for tab in (
            select f.mti || '/' || f.de024 as fin_message_type
                 , f.is_incoming           as fin_in_flag
                 , (select substr(mrc.de025 || ' - ' || mrc.description, 1, 200)
                      from mcw_reason_code mrc
                     where mrc.mti   = f.mti
                       and mrc.de024 = f.de024
                       and mrc.de025 = f.de025) as fin_reason_code
                 , f.de072 as fin_member_text
                 , case when f.p0262 is not null
                        then substr(f.p0262 ||
                                     ' - ' || get_article_text('MDDI000' || f.p0262) , 1, 200)
                        else null
                   end as fin_doc_flag
                 , case when d.c28 is not null
                        then substr(substr(d.c28, 7, 2) ||
                             ' - ' || get_article_text(d.c28) , 1, 200)
                        else null
                   end as fin_fraud_type
                 , f.is_rejected as fin_rejected
                 , f.is_reversal as fin_reversal
                 , case f.is_incoming
                       when com_api_const_pkg.TRUE
                       then 'UNDEFINED'
                       else null -- get information from app_history for the case                               
                   end as created_by
                 , get_article_text(i_article => nvl(f.status, d.status)) as fin_status
                 , f.inst_id
                 , f.network_id
                 , f.ext_claim_id
                 , f.ext_message_id
              from opr_operation o
              left join mcw_fin f   on f.id = o.id
              left join mcw_fraud d on d.id = o.id
              left join csm_case c  on o.id = c.original_id
             where o.id = i_oper_id
        ) loop
            o_fin_message_type := tab.fin_message_type;
            o_fin_in_flag      := tab.fin_in_flag;
            o_fin_reason_code  := tab.fin_reason_code;
            o_fin_member_text  := tab.fin_member_text;
            o_fin_doc_flag     := tab.fin_doc_flag;
            o_fin_fraud_type   := tab.fin_fraud_type;
            o_fin_rejected     := tab.fin_rejected;
            o_fin_reversal     := tab.fin_reversal;
            o_created_by       := tab.created_by;
            o_fin_status       := tab.fin_status;
            o_inst_id          := tab.inst_id;
            o_network_id       := tab.network_id;
            o_ext_claim_id     := tab.ext_claim_id;
            o_ext_message_id   := tab.ext_message_id;
        end loop;
    else
        trc_log_pkg.debug(
            i_text => 'get_additional_ips_info: unsupported ips'
        );
    end case;
    trc_log_pkg.debug(
        i_text => 'get_additional_ips_info: end ' || o_fin_reason_code
    );
end;

procedure get_operation_by_id(
    i_oper_id           in      com_api_type_pkg.t_long_id
  , i_lang              in      com_api_type_pkg.t_dict_value
  , o_root_oper_id     out      com_api_type_pkg.t_long_id
) is
    l_dispute_rec dsp_ui_dispute_info_tpr := 
        dsp_ui_dispute_info_tpr(null, null, null, null, null, null, null, null, null, null, null, null
                              , null, null, null, null, null, null, null, null, null, null, null, null
                              , null, null, null, null, null, null, null, null, null, null, null, null
                              , null, null, null, null, null, null, null, null, null, null, null, null
                              , null, null, null, null, null, null, null, null, null, null
                              , null, null, null, null
        );
begin

    select op.id as oper_id
         , op.session_id
         , op.is_reversal
         , op.original_id
         , op.oper_type
         , op.oper_reason
         , op.msg_type
         , op.status
         , op.status_reason
         , op.sttl_type
         , op.sttl_amount
         , op.sttl_currency
         , op.acq_inst_bin
         , op.forw_inst_bin
         , op.terminal_number
         , op.merchant_number
         , op.merchant_name
         , op.merchant_street
         , op.merchant_city
         , op.merchant_region
         , op.merchant_country
         , op.merchant_postcode
         , op.mcc
         , op.originator_refnum
         , op.network_refnum
         , op.oper_count
         , op.oper_request_amount
         , op.oper_amount_algorithm
         , op.oper_amount
         , op.oper_currency
         , op.oper_cashback_amount
         , op.oper_replacement_amount
         , op.oper_surcharge_amount
         , op.oper_date
         , op.host_date
         , op.unhold_date
         , op.match_status
         , op.match_id
         , op.dispute_id
         , op.payment_order_id
         , op.payment_host_id
         , op.forced_processing
      into l_dispute_rec.oper_id
         , l_dispute_rec.session_id
         , l_dispute_rec.is_reversal
         , l_dispute_rec.original_id
         , l_dispute_rec.oper_type
         , l_dispute_rec.oper_reason
         , l_dispute_rec.msg_type
         , l_dispute_rec.status
         , l_dispute_rec.status_reason
         , l_dispute_rec.sttl_type
         , l_dispute_rec.sttl_amount
         , l_dispute_rec.sttl_currency
         , l_dispute_rec.acq_inst_bin
         , l_dispute_rec.forw_inst_bin
         , l_dispute_rec.terminal_number
         , l_dispute_rec.merchant_number
         , l_dispute_rec.merchant_name
         , l_dispute_rec.merchant_street
         , l_dispute_rec.merchant_city
         , l_dispute_rec.merchant_region
         , l_dispute_rec.merchant_country
         , l_dispute_rec.merchant_postcode
         , l_dispute_rec.mcc
         , l_dispute_rec.originator_refnum
         , l_dispute_rec.network_refnum
         , l_dispute_rec.oper_count
         , l_dispute_rec.oper_request_amount
         , l_dispute_rec.oper_amount_algorithm
         , l_dispute_rec.oper_amount
         , l_dispute_rec.oper_currency
         , l_dispute_rec.oper_cashback_amount
         , l_dispute_rec.oper_replacement_amount
         , l_dispute_rec.oper_surcharge_amount
         , l_dispute_rec.oper_date
         , l_dispute_rec.host_date
         , l_dispute_rec.unhold_date
         , l_dispute_rec.match_status
         , l_dispute_rec.match_id
         , l_dispute_rec.dispute_id
         , l_dispute_rec.payment_order_id
         , l_dispute_rec.payment_host_id
         , l_dispute_rec.forced_processing
      from opr_ui_operation_vw op
     where id = i_oper_id;


    l_dispute_rec.op_level             := null;
    l_dispute_rec.mcc_name             := get_mcc_name(
                                              i_mcc              => l_dispute_rec.mcc
                                            , i_lang             => i_lang
                                          );
    l_dispute_rec.payment_host_name    := get_payment_host_name(
                                              i_payment_host_id  => l_dispute_rec.payment_host_id
                                            , i_lang             => i_lang
                                          );
    l_dispute_rec.is_dispute_allowed   := dsp_ui_process_pkg.check_dispute_allow(l_dispute_rec.oper_id);

    -- get ips info (mcw and vis)
    get_additional_ips_info(
        i_oper_id               => i_oper_id
      , o_fin_message_type      => l_dispute_rec.fin_message_type
      , o_fin_in_flag           => l_dispute_rec.fin_in_flag
      , o_fin_reason_code       => l_dispute_rec.fin_reason_code
      , o_fin_member_text       => l_dispute_rec.fin_member_text
      , o_fin_doc_flag          => l_dispute_rec.fin_doc_flag
      , o_fin_fraud_type        => l_dispute_rec.fin_fraud_type
      , o_fin_rejected          => l_dispute_rec.fin_rejected
      , o_fin_reversal          => l_dispute_rec.fin_reversal
      , o_created_by            => l_dispute_rec.created_by
      , o_fin_status            => l_dispute_rec.fin_status
      , o_inst_id               => l_dispute_rec.inst_id
      , o_network_id            => l_dispute_rec.network_id
      , o_ext_claim_id          => l_dispute_rec.ext_claim_id
      , o_ext_message_id        => l_dispute_rec.ext_message_id
    );

    g_dispute_tab.extend;
    g_dispute_tab(g_dispute_tab.count)                        := l_dispute_rec;
    g_operation_id_exists_tab(to_char(l_dispute_rec.oper_id)) := g_dispute_tab.count;

    -- Get original operation info.
    if l_dispute_rec.original_id is not null then
        get_operation_by_id(
            i_oper_id         => l_dispute_rec.original_id
          , i_lang            => i_lang
          , o_root_oper_id    => o_root_oper_id
        );
    else
        o_root_oper_id := l_dispute_rec.oper_id;
    end if;

end get_operation_by_id;

procedure get_operation_by_original_id(
    i_oper_id                   in      com_api_type_pkg.t_long_id
  , i_lang                      in      com_api_type_pkg.t_dict_value
  , i_op_level                  in      com_api_type_pkg.t_tiny_id
  , i_parent_hierarchical_path  in      com_api_type_pkg.t_full_desc
) is
    l_dispute_rec dsp_ui_dispute_info_tpr := 
        dsp_ui_dispute_info_tpr(null, null, null, null, null, null, null, null, null, null, null, null
                              , null, null, null, null, null, null, null, null, null, null, null, null
                              , null, null, null, null, null, null, null, null, null, null, null, null
                              , null, null, null, null, null, null, null, null, null, null, null, null
                              , null, null, null, null, null, null, null, null, null, null, null, null
                              , null, null
        );
    l_hierarchical_path         com_api_type_pkg.t_full_desc;
begin

    for r in (
        select op.id as oper_id
             , op.session_id
             , op.is_reversal
             , op.original_id
             , op.oper_type
             , op.oper_reason
             , op.msg_type
             , op.status
             , op.status_reason
             , op.sttl_type
             , op.sttl_amount
             , op.sttl_currency
             , op.acq_inst_bin
             , op.forw_inst_bin
             , op.terminal_number
             , op.merchant_number
             , op.merchant_name
             , op.merchant_street
             , op.merchant_city
             , op.merchant_region
             , op.merchant_country
             , op.merchant_postcode
             , op.mcc
             , op.originator_refnum
             , op.network_refnum
             , op.oper_count
             , op.oper_request_amount
             , op.oper_amount_algorithm
             , op.oper_amount
             , op.oper_currency
             , op.oper_cashback_amount
             , op.oper_replacement_amount
             , op.oper_surcharge_amount
             , op.oper_date
             , op.host_date
             , op.unhold_date
             , op.match_status
             , op.match_id
             , op.dispute_id
             , op.payment_order_id
             , op.payment_host_id
             , op.forced_processing
          from opr_ui_operation_vw op
         where original_id = i_oper_id

    ) loop

        if g_operation_id_exists_tab.exists(r.oper_id) then
            set_level(
                i_oper_id   => r.oper_id
              , i_op_level  => i_op_level
            );

        else
            l_dispute_rec.oper_id                  := r.oper_id;
            l_dispute_rec.session_id               := r.session_id;
            l_dispute_rec.is_reversal              := r.is_reversal;
            l_dispute_rec.original_id              := r.original_id;
            l_dispute_rec.oper_type                := r.oper_type;
            l_dispute_rec.oper_reason              := r.oper_reason;
            l_dispute_rec.msg_type                 := r.msg_type;
            l_dispute_rec.status                   := r.status;
            l_dispute_rec.status_reason            := r.status_reason;
            l_dispute_rec.sttl_type                := r.sttl_type;
            l_dispute_rec.sttl_amount              := r.sttl_amount;
            l_dispute_rec.sttl_currency            := r.sttl_currency;
            l_dispute_rec.acq_inst_bin             := r.acq_inst_bin;
            l_dispute_rec.forw_inst_bin            := r.forw_inst_bin;
            l_dispute_rec.terminal_number          := r.terminal_number;
            l_dispute_rec.merchant_number          := r.merchant_number;
            l_dispute_rec.merchant_name            := r.merchant_name;
            l_dispute_rec.merchant_street          := r.merchant_street;
            l_dispute_rec.merchant_city            := r.merchant_city;
            l_dispute_rec.merchant_region          := r.merchant_region;
            l_dispute_rec.merchant_country         := r.merchant_country;
            l_dispute_rec.merchant_postcode        := r.merchant_postcode;
            l_dispute_rec.mcc                      := r.mcc;
            l_dispute_rec.originator_refnum        := r.originator_refnum;
            l_dispute_rec.network_refnum           := r.network_refnum;
            l_dispute_rec.oper_count               := r.oper_count;
            l_dispute_rec.oper_request_amount      := r.oper_request_amount;
            l_dispute_rec.oper_amount_algorithm    := r.oper_amount_algorithm;
            l_dispute_rec.oper_amount              := r.oper_amount;
            l_dispute_rec.oper_currency            := r.oper_currency;
            l_dispute_rec.oper_cashback_amount     := r.oper_cashback_amount;
            l_dispute_rec.oper_replacement_amount  := r.oper_replacement_amount;
            l_dispute_rec.oper_surcharge_amount    := r.oper_surcharge_amount;
            l_dispute_rec.oper_date                := r.oper_date;
            l_dispute_rec.host_date                := r.host_date;
            l_dispute_rec.unhold_date              := r.unhold_date;
            l_dispute_rec.match_status             := r.match_status;
            l_dispute_rec.match_id                 := r.match_id;
            l_dispute_rec.dispute_id               := r.dispute_id;
            l_dispute_rec.payment_order_id         := r.payment_order_id;
            l_dispute_rec.payment_host_id          := r.payment_host_id;
            l_dispute_rec.forced_processing        := r.forced_processing;

            l_dispute_rec.op_level                 := i_op_level;

            l_dispute_rec.mcc_name                 := get_mcc_name(
                                                          i_mcc              => l_dispute_rec.mcc
                                                        , i_lang             => i_lang
                                                      );
            l_dispute_rec.payment_host_name        := get_payment_host_name(
                                                          i_payment_host_id  => l_dispute_rec.payment_host_id
                                                        , i_lang             => i_lang
                                                      );
            l_dispute_rec.is_dispute_allowed       := dsp_ui_process_pkg.check_dispute_allow(l_dispute_rec.oper_id);

            get_additional_ips_info(
                i_oper_id               => r.oper_id
              , o_fin_message_type      => l_dispute_rec.fin_message_type
              , o_fin_in_flag           => l_dispute_rec.fin_in_flag
              , o_fin_reason_code       => l_dispute_rec.fin_reason_code
              , o_fin_member_text       => l_dispute_rec.fin_member_text
              , o_fin_doc_flag          => l_dispute_rec.fin_doc_flag
              , o_fin_fraud_type        => l_dispute_rec.fin_fraud_type
              , o_fin_rejected          => l_dispute_rec.fin_rejected
              , o_fin_reversal          => l_dispute_rec.fin_reversal
              , o_created_by            => l_dispute_rec.created_by
              , o_fin_status            => l_dispute_rec.fin_status
              , o_inst_id               => l_dispute_rec.inst_id
              , o_network_id            => l_dispute_rec.network_id
              , o_ext_claim_id          => l_dispute_rec.ext_claim_id
              , o_ext_message_id        => l_dispute_rec.ext_message_id
          );

            g_dispute_tab.extend;
            g_dispute_tab(g_dispute_tab.count)            := l_dispute_rec;
            g_operation_id_exists_tab(to_char(r.oper_id)) := g_dispute_tab.count;

        end if;

        l_hierarchical_path := i_parent_hierarchical_path || '/' || to_char(r.oper_id);

        g_dispute_tab(g_operation_id_exists_tab(r.oper_id)).hierarchical_path := l_hierarchical_path;

        get_operation_by_original_id(
            i_oper_id                  => r.oper_id
          , i_lang                     => i_lang
          , i_op_level                 => i_op_level + 1
          , i_parent_hierarchical_path => l_hierarchical_path
        );

    end loop;

end get_operation_by_original_id;

procedure get_operation_by_dispute_id(
    i_dispute_id        in      com_api_type_pkg.t_long_id
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_op_level          in      com_api_type_pkg.t_tiny_id
) is
    l_dispute_rec dsp_ui_dispute_info_tpr := 
        dsp_ui_dispute_info_tpr(null, null, null, null, null, null, null, null, null, null, null, null
                              , null, null, null, null, null, null, null, null, null, null, null, null
                              , null, null, null, null, null, null, null, null, null, null, null, null
                              , null, null, null, null, null, null, null, null, null, null, null, null
                              , null, null, null, null, null, null, null, null, null, null, null, null
                              , null, null
        );
begin

    for r in (
        select op.id as oper_id
             , op.session_id
             , op.is_reversal
             , op.original_id
             , op.oper_type
             , op.oper_reason
             , op.msg_type
             , op.status
             , op.status_reason
             , op.sttl_type
             , op.sttl_amount
             , op.sttl_currency
             , op.acq_inst_bin
             , op.forw_inst_bin
             , op.terminal_number
             , op.merchant_number
             , op.merchant_name
             , op.merchant_street
             , op.merchant_city
             , op.merchant_region
             , op.merchant_country
             , op.merchant_postcode
             , op.mcc
             , op.originator_refnum
             , op.network_refnum
             , op.oper_count
             , op.oper_request_amount
             , op.oper_amount_algorithm
             , op.oper_amount
             , op.oper_currency
             , op.oper_cashback_amount
             , op.oper_replacement_amount
             , op.oper_surcharge_amount
             , op.oper_date
             , op.host_date
             , op.unhold_date
             , op.match_status
             , op.match_id
             , op.dispute_id
             , op.payment_order_id
             , op.payment_host_id
             , op.forced_processing
          from opr_ui_operation_vw op
         where op.dispute_id = i_dispute_id
           and op.original_id is null

    ) loop

        if g_operation_id_exists_tab.exists(r.oper_id) then
            set_level(
                i_oper_id   => r.oper_id
              , i_op_level  => i_op_level
            );

        else
            l_dispute_rec.oper_id                  := r.oper_id;
            l_dispute_rec.session_id               := r.session_id;
            l_dispute_rec.is_reversal              := r.is_reversal;
            l_dispute_rec.original_id              := r.original_id;
            l_dispute_rec.oper_type                := r.oper_type;
            l_dispute_rec.oper_reason              := r.oper_reason;
            l_dispute_rec.msg_type                 := r.msg_type;
            l_dispute_rec.status                   := r.status;
            l_dispute_rec.status_reason            := r.status_reason;
            l_dispute_rec.sttl_type                := r.sttl_type;
            l_dispute_rec.sttl_amount              := r.sttl_amount;
            l_dispute_rec.sttl_currency            := r.sttl_currency;
            l_dispute_rec.acq_inst_bin             := r.acq_inst_bin;
            l_dispute_rec.forw_inst_bin            := r.forw_inst_bin;
            l_dispute_rec.terminal_number          := r.terminal_number;
            l_dispute_rec.merchant_number          := r.merchant_number;
            l_dispute_rec.merchant_name            := r.merchant_name;
            l_dispute_rec.merchant_street          := r.merchant_street;
            l_dispute_rec.merchant_city            := r.merchant_city;
            l_dispute_rec.merchant_region          := r.merchant_region;
            l_dispute_rec.merchant_country         := r.merchant_country;
            l_dispute_rec.merchant_postcode        := r.merchant_postcode;
            l_dispute_rec.mcc                      := r.mcc;
            l_dispute_rec.originator_refnum        := r.originator_refnum;
            l_dispute_rec.network_refnum           := r.network_refnum;
            l_dispute_rec.oper_count               := r.oper_count;
            l_dispute_rec.oper_request_amount      := r.oper_request_amount;
            l_dispute_rec.oper_amount_algorithm    := r.oper_amount_algorithm;
            l_dispute_rec.oper_amount              := r.oper_amount;
            l_dispute_rec.oper_currency            := r.oper_currency;
            l_dispute_rec.oper_cashback_amount     := r.oper_cashback_amount;
            l_dispute_rec.oper_replacement_amount  := r.oper_replacement_amount;
            l_dispute_rec.oper_surcharge_amount    := r.oper_surcharge_amount;
            l_dispute_rec.oper_date                := r.oper_date;
            l_dispute_rec.host_date                := r.host_date;
            l_dispute_rec.unhold_date              := r.unhold_date;
            l_dispute_rec.match_status             := r.match_status;
            l_dispute_rec.match_id                 := r.match_id;
            l_dispute_rec.dispute_id               := r.dispute_id;
            l_dispute_rec.payment_order_id         := r.payment_order_id;
            l_dispute_rec.payment_host_id          := r.payment_host_id;
            l_dispute_rec.forced_processing        := r.forced_processing;

            l_dispute_rec.op_level                 := i_op_level;

            l_dispute_rec.mcc_name                 := get_mcc_name(
                                                          i_mcc              => l_dispute_rec.mcc
                                                        , i_lang             => i_lang
                                                      );
            l_dispute_rec.payment_host_name        := get_payment_host_name(
                                                          i_payment_host_id  => l_dispute_rec.payment_host_id
                                                        , i_lang             => i_lang
                                                      );
            l_dispute_rec.is_dispute_allowed       := dsp_ui_process_pkg.check_dispute_allow(l_dispute_rec.oper_id);

            get_additional_ips_info(
                i_oper_id               => r.oper_id
              , o_fin_message_type      => l_dispute_rec.fin_message_type
              , o_fin_in_flag           => l_dispute_rec.fin_in_flag
              , o_fin_reason_code       => l_dispute_rec.fin_reason_code
              , o_fin_member_text       => l_dispute_rec.fin_member_text
              , o_fin_doc_flag          => l_dispute_rec.fin_doc_flag
              , o_fin_fraud_type        => l_dispute_rec.fin_fraud_type
              , o_fin_rejected          => l_dispute_rec.fin_rejected
              , o_fin_reversal          => l_dispute_rec.fin_reversal
              , o_created_by            => l_dispute_rec.created_by
              , o_fin_status            => l_dispute_rec.fin_status
              , o_inst_id               => l_dispute_rec.inst_id
              , o_network_id            => l_dispute_rec.network_id
              , o_ext_claim_id          => l_dispute_rec.ext_claim_id
              , o_ext_message_id        => l_dispute_rec.ext_message_id
            );

            g_dispute_tab.extend;
            g_dispute_tab(g_dispute_tab.count)            := l_dispute_rec;
            g_operation_id_exists_tab(to_char(r.oper_id)) := g_dispute_tab.count;

        end if;

        g_dispute_tab(g_operation_id_exists_tab(r.oper_id)).hierarchical_path := '/' || to_char(r.oper_id);

    end loop;

end get_operation_by_dispute_id;

procedure get_operation_by_match_id(
    i_oper_id           in      com_api_type_pkg.t_long_id
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_op_level          in      com_api_type_pkg.t_tiny_id
) is
    l_dispute_rec dsp_ui_dispute_info_tpr := 
        dsp_ui_dispute_info_tpr(null, null, null, null, null, null, null, null, null, null, null, null
                              , null, null, null, null, null, null, null, null, null, null, null, null
                              , null, null, null, null, null, null, null, null, null, null, null, null
                              , null, null, null, null, null, null, null, null, null, null, null, null
                              , null, null, null, null, null, null, null, null, null, null, null, null
                              , null, null
        );
begin

    for r in (
        select op.id as oper_id
             , op.session_id
             , op.is_reversal
             , op.original_id
             , op.oper_type
             , op.oper_reason
             , op.msg_type
             , op.status
             , op.status_reason
             , op.sttl_type
             , op.sttl_amount
             , op.sttl_currency
             , op.acq_inst_bin
             , op.forw_inst_bin
             , op.terminal_number
             , op.merchant_number
             , op.merchant_name
             , op.merchant_street
             , op.merchant_city
             , op.merchant_region
             , op.merchant_country
             , op.merchant_postcode
             , op.mcc
             , op.originator_refnum
             , op.network_refnum
             , op.oper_count
             , op.oper_request_amount
             , op.oper_amount_algorithm
             , op.oper_amount
             , op.oper_currency
             , op.oper_cashback_amount
             , op.oper_replacement_amount
             , op.oper_surcharge_amount
             , op.oper_date
             , op.host_date
             , op.unhold_date
             , op.match_status
             , op.match_id
             , op.dispute_id
             , op.payment_order_id
             , op.payment_host_id
             , op.forced_processing
          from opr_ui_operation_vw op
         where op.id = i_oper_id

    ) loop

        if g_operation_id_exists_tab.exists(r.oper_id) then
            set_level(
                i_oper_id   => r.oper_id
              , i_op_level  => i_op_level
            );

        else
            l_dispute_rec.oper_id                  := r.oper_id;
            l_dispute_rec.session_id               := r.session_id;
            l_dispute_rec.is_reversal              := r.is_reversal;
            l_dispute_rec.original_id              := r.original_id;
            l_dispute_rec.oper_type                := r.oper_type;
            l_dispute_rec.oper_reason              := r.oper_reason;
            l_dispute_rec.msg_type                 := r.msg_type;
            l_dispute_rec.status                   := r.status;
            l_dispute_rec.status_reason            := r.status_reason;
            l_dispute_rec.sttl_type                := r.sttl_type;
            l_dispute_rec.sttl_amount              := r.sttl_amount;
            l_dispute_rec.sttl_currency            := r.sttl_currency;
            l_dispute_rec.acq_inst_bin             := r.acq_inst_bin;
            l_dispute_rec.forw_inst_bin            := r.forw_inst_bin;
            l_dispute_rec.terminal_number          := r.terminal_number;
            l_dispute_rec.merchant_number          := r.merchant_number;
            l_dispute_rec.merchant_name            := r.merchant_name;
            l_dispute_rec.merchant_street          := r.merchant_street;
            l_dispute_rec.merchant_city            := r.merchant_city;
            l_dispute_rec.merchant_region          := r.merchant_region;
            l_dispute_rec.merchant_country         := r.merchant_country;
            l_dispute_rec.merchant_postcode        := r.merchant_postcode;
            l_dispute_rec.mcc                      := r.mcc;
            l_dispute_rec.originator_refnum        := r.originator_refnum;
            l_dispute_rec.network_refnum           := r.network_refnum;
            l_dispute_rec.oper_count               := r.oper_count;
            l_dispute_rec.oper_request_amount      := r.oper_request_amount;
            l_dispute_rec.oper_amount_algorithm    := r.oper_amount_algorithm;
            l_dispute_rec.oper_amount              := r.oper_amount;
            l_dispute_rec.oper_currency            := r.oper_currency;
            l_dispute_rec.oper_cashback_amount     := r.oper_cashback_amount;
            l_dispute_rec.oper_replacement_amount  := r.oper_replacement_amount;
            l_dispute_rec.oper_surcharge_amount    := r.oper_surcharge_amount;
            l_dispute_rec.oper_date                := r.oper_date;
            l_dispute_rec.host_date                := r.host_date;
            l_dispute_rec.unhold_date              := r.unhold_date;
            l_dispute_rec.match_status             := r.match_status;
            l_dispute_rec.match_id                 := r.match_id;
            l_dispute_rec.dispute_id               := r.dispute_id;
            l_dispute_rec.payment_order_id         := r.payment_order_id;
            l_dispute_rec.payment_host_id          := r.payment_host_id;
            l_dispute_rec.forced_processing        := r.forced_processing;

            l_dispute_rec.op_level                 := i_op_level;

            l_dispute_rec.mcc_name                 := get_mcc_name(
                                                          i_mcc              => l_dispute_rec.mcc
                                                        , i_lang             => i_lang
                                                      );
            l_dispute_rec.payment_host_name        := get_payment_host_name(
                                                          i_payment_host_id  => l_dispute_rec.payment_host_id
                                                        , i_lang             => i_lang
                                                      );
            l_dispute_rec.is_dispute_allowed       := dsp_ui_process_pkg.check_dispute_allow(l_dispute_rec.oper_id);

            get_additional_ips_info(
                i_oper_id               => r.oper_id
              , o_fin_message_type      => l_dispute_rec.fin_message_type
              , o_fin_in_flag           => l_dispute_rec.fin_in_flag
              , o_fin_reason_code       => l_dispute_rec.fin_reason_code
              , o_fin_member_text       => l_dispute_rec.fin_member_text
              , o_fin_doc_flag          => l_dispute_rec.fin_doc_flag
              , o_fin_fraud_type        => l_dispute_rec.fin_fraud_type
              , o_fin_rejected          => l_dispute_rec.fin_rejected
              , o_fin_reversal          => l_dispute_rec.fin_reversal
              , o_created_by            => l_dispute_rec.created_by
              , o_fin_status            => l_dispute_rec.fin_status
              , o_inst_id               => l_dispute_rec.inst_id
              , o_network_id            => l_dispute_rec.network_id
              , o_ext_claim_id          => l_dispute_rec.ext_claim_id
              , o_ext_message_id        => l_dispute_rec.ext_message_id
            );

            g_dispute_tab.extend;
            g_dispute_tab(g_dispute_tab.count)            := l_dispute_rec;
            g_operation_id_exists_tab(to_char(r.oper_id)) := g_dispute_tab.count;

        end if;

        g_dispute_tab(g_operation_id_exists_tab(r.oper_id)).hierarchical_path := '/' || to_char(r.oper_id);

    end loop;

end get_operation_by_match_id;

--
-- You can use next query for your testing of this pipelined method:
--
-- select to_char(o.oper_id) oper_id, to_char(o.original_id) original_id, to_char(dispute_id) dispute_id, to_char(match_id) match_id, o.*
--   from table(cast(dsp_ui_dispute_search_pkg.get_dispute_info(1606290000030005, null, 'LANGENG') as dsp_ui_dispute_info_tpt)) o
--   order by rn
--
function get_dispute_info(
    i_oper_id               in      com_api_type_pkg.t_long_id
  , i_match_id              in      com_api_type_pkg.t_long_id
  , i_lang                  in      com_api_type_pkg.t_dict_value
) return dsp_ui_dispute_info_tpt pipelined is

    l_root_oper_id                  com_api_type_pkg.t_long_id;
    l_root_hierarchical_path        com_api_type_pkg.t_full_desc;

begin
    trc_log_pkg.debug(
        i_text           => 'get_dispute_info start: i_oper_id [#1] i_match_id [#2] i_lang [#3]'
      , i_env_param1     => i_oper_id
      , i_env_param2     => i_match_id
      , i_env_param3     => i_lang
    );

    g_dispute_tab.delete;
    g_operation_id_exists_tab.delete;

    get_operation_by_id(
        i_oper_id        => i_oper_id
      , i_lang           => i_lang
      , o_root_oper_id   => l_root_oper_id
    );

    l_root_hierarchical_path := '/' || to_char(l_root_oper_id);

    g_dispute_tab(g_operation_id_exists_tab(l_root_oper_id)).op_level          := 1;
    g_dispute_tab(g_operation_id_exists_tab(l_root_oper_id)).hierarchical_path := l_root_hierarchical_path;

    get_operation_by_original_id(
        i_oper_id                  => l_root_oper_id
      , i_lang                     => i_lang
      , i_op_level                 => 2
      , i_parent_hierarchical_path => l_root_hierarchical_path
    );

    for r in (
        select distinct dispute_id
          from table(cast(g_dispute_tab as dsp_ui_dispute_info_tpt))
         where dispute_id is not null
    ) loop
        get_operation_by_dispute_id(
            i_dispute_id => r.dispute_id
          , i_lang       => i_lang
          , i_op_level   => 1
        );
    end loop;

    for r in (
        select oper_id
             , match_id
          from table(cast(g_dispute_tab as dsp_ui_dispute_info_tpt))
         where oper_id   = i_oper_id
           and match_id is not null
    ) loop
        get_operation_by_match_id(
            i_oper_id    => r.match_id
          , i_lang       => i_lang
          , i_op_level   => 1
        );
    end loop;

    -- Sort pipelined collection by hierarchical_path which contains "oper_id" values
    for r in (
        select oper_id
             , rownum  as rn
          from (
              select oper_id
                from table(cast(g_dispute_tab as dsp_ui_dispute_info_tpt))
               order by hierarchical_path
          )
    ) loop
        g_dispute_tab(g_operation_id_exists_tab(r.oper_id)).rn := r.rn;
    end loop;

    trc_log_pkg.debug(
        i_text           => 'get_dispute_info finish ' || g_dispute_tab.count
    );

    for i in 1 .. g_dispute_tab.count loop
        pipe row(g_dispute_tab(i));
    end loop;
    return;

end get_dispute_info;

end dsp_ui_dispute_search_pkg;
/
