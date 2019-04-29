create or replace package csm_api_type_pkg as
/********************************************************* 
 *  Case Management CSM  <br /> 
 *  Created by Kondratyev A.(kondratyev@bpcbt.com)  at 21.12.2017 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: csm_api_type_pkg <br /> 
 *  @headcom 
 **********************************************************/

type t_csm_case_rec is record(
    case_id                   com_api_type_pkg.t_long_id
  , seqnum                    com_api_type_pkg.t_seqnum
  , inst_id                   com_api_type_pkg.t_inst_id
  , merchant_name             com_api_type_pkg.t_name
  , customer_number           com_api_type_pkg.t_name
  , dispute_reason            com_api_type_pkg.t_dict_value
  , oper_date                 date
  , oper_amount               com_api_type_pkg.t_money
  , oper_currency             com_api_type_pkg.t_curr_code
  , dispute_id                com_api_type_pkg.t_long_id
  , dispute_progress          com_api_type_pkg.t_dict_value
  , write_off_amount          com_api_type_pkg.t_money
  , write_off_currency        com_api_type_pkg.t_curr_code
  , due_date                  date
  , reason_code               com_api_type_pkg.t_dict_value
  , disputed_amount           com_api_type_pkg.t_money
  , disputed_currency         com_api_type_pkg.t_curr_code
  , created_date              date
  , created_by_user_id        com_api_type_pkg.t_short_id
  , arn                       com_api_type_pkg.t_card_number
  , claim_id                  com_api_type_pkg.t_long_id
  , auth_code                 com_api_type_pkg.t_auth_code
  , case_progress             com_api_type_pkg.t_dict_value
  , acquirer_inst_bin         com_api_type_pkg.t_cmid
  , transaction_code          com_api_type_pkg.t_cmid
  , case_source               com_api_type_pkg.t_dict_value
  , sttl_amount               com_api_type_pkg.t_money
  , sttl_currency             com_api_type_pkg.t_curr_code
  , base_amount               com_api_type_pkg.t_money
  , base_currency             com_api_type_pkg.t_curr_code
  , hide_date                 date
  , unhide_date               date
  , team_id                   com_api_type_pkg.t_tiny_id
  , card_id                   com_api_type_pkg.t_medium_id
  , merchant_id               com_api_type_pkg.t_short_id
  , is_visible                com_api_type_pkg.t_boolean
  , case_status               com_api_type_pkg.t_dict_value
  , case_resolution           com_api_type_pkg.t_dict_value
  , flow_id                   com_api_type_pkg.t_tiny_id
  , is_reversal               com_api_type_pkg.t_boolean
  , split_hash                com_api_type_pkg.t_tiny_id
  , original_id               com_api_type_pkg.t_long_id
  , network_id                com_api_type_pkg.t_network_id
  , ext_claim_id              com_api_type_pkg.t_attr_name
  , ext_clearing_trans_id     com_api_type_pkg.t_name
  , ext_auth_trans_id         com_api_type_pkg.t_name
);

type t_csm_case_tab is table of t_csm_case_rec index by binary_integer;

end;
/
