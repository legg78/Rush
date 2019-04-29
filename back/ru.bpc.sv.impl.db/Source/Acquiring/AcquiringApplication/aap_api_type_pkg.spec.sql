create or replace package aap_api_type_pkg as
/*********************************************************
*  Acquer application - types <br />
*  Created by Filimonov A.(filimonov@bpc.ru)  at 08.04.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate: 2010-04-27 17:29:49 +0400#$ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: APP_API_TYPE_PKG <br />
*  @headcom
**********************************************************/
type t_merchant is record(
    id                      com_api_type_pkg.t_short_id
  , merchant_number         com_api_type_pkg.t_merchant_number
  , merchant_name           com_api_type_pkg.t_name
  , merchant_type           com_api_type_pkg.t_dict_value
  , parent_id               com_api_type_pkg.t_short_id
  , mcc                     com_api_type_pkg.t_mcc
  , status                  com_api_type_pkg.t_dict_value
  , status_reason           com_api_type_pkg.t_dict_value
  , inst_id                 com_api_type_pkg.t_inst_id
  , merchant_label          com_api_type_pkg.t_multilang_desc_tab
  , merchant_desc           com_api_type_pkg.t_multilang_desc_tab
  , partner_id_code         com_api_type_pkg.t_auth_code
  , risk_indicator          com_api_type_pkg.t_dict_value
  , mc_assigned_id          com_api_type_pkg.t_tag
);

type t_cud_codes is table of varchar2(1) index by binary_integer;

type t_terminal is record(
    id                      com_api_type_pkg.t_short_id
  , is_template             com_api_type_pkg.t_boolean
  , terminal_number         com_api_type_pkg.t_terminal_number
  , terminal_type           com_api_type_pkg.t_dict_value
  , standard_id             com_api_type_pkg.t_tiny_id
  , version_id              com_api_type_pkg.t_tiny_id
  , merchant_id             com_api_type_pkg.t_short_id
  , mcc                     com_api_type_pkg.t_mcc
  , plastic_number          com_api_type_pkg.t_card_number
  , card_data_input_cap     com_api_type_pkg.t_dict_value
  , crdh_auth_cap           com_api_type_pkg.t_dict_value
  , card_capture_cap        com_api_type_pkg.t_dict_value
  , term_operating_env      com_api_type_pkg.t_dict_value
  , crdh_data_present       com_api_type_pkg.t_dict_value
  , card_data_present       com_api_type_pkg.t_dict_value
  , card_data_input_mode    com_api_type_pkg.t_dict_value
  , crdh_auth_method        com_api_type_pkg.t_dict_value
  , crdh_auth_entity        com_api_type_pkg.t_dict_value
  , card_data_output_cap    com_api_type_pkg.t_dict_value
  , term_data_output_cap    com_api_type_pkg.t_dict_value
  , pin_capture_cap         com_api_type_pkg.t_dict_value
  , cat_level               com_api_type_pkg.t_dict_value
  , status                  com_api_type_pkg.t_dict_value
  , status_reason           com_api_type_pkg.t_dict_value
  , product_id              com_api_type_pkg.t_long_id
  , inst_id                 com_api_type_pkg.t_inst_id
  , device_id               com_api_type_pkg.t_short_id
  , is_mac                  com_api_type_pkg.t_boolean
  , gmt_offset              com_api_type_pkg.t_tiny_id
  , terminal_template       com_api_type_pkg.t_short_id
  , cash_dispenser_present  com_api_type_pkg.t_boolean
  , payment_possibility     com_api_type_pkg.t_boolean
  , use_card_possibility    com_api_type_pkg.t_boolean
  , cash_in_present         com_api_type_pkg.t_boolean
  , available_network       com_api_type_pkg.t_short_id
  , available_operation     com_api_type_pkg.t_short_id
  , available_currency      com_api_type_pkg.t_short_id
  , mcc_template_id         com_api_type_pkg.t_medium_id
  , terminal_profile        com_api_type_pkg.t_medium_id
  , pin_block_format        com_api_type_pkg.t_dict_value
  , pos_batch_support       com_api_type_pkg.t_boolean
);

type t_pos_terminal is record(
    pos_type                com_api_type_pkg.t_dict_value
  , pos_batch_mode          com_api_type_pkg.t_dict_value
  , pos_conn_type           com_api_type_pkg.t_dict_value
);

type t_atm_terminal is record(
    terminal_id                  com_api_type_pkg.t_short_id
  , atm_type                     com_api_type_pkg.t_dict_value
  , atm_model                    com_api_type_pkg.t_name
  , serial_number                com_api_type_pkg.t_name
  , placement_type               com_api_type_pkg.t_dict_value
  , availability_type            com_api_type_pkg.t_dict_value
  , operating_hours              com_api_type_pkg.t_name
  , local_date_gap               com_api_type_pkg.t_short_id
  , counter_sync_cond            com_api_type_pkg.t_dict_value
  , cassette_count               com_api_type_pkg.t_tiny_id
  , key_change_algo              com_api_type_pkg.t_dict_value
  , reject_disp_warn             com_api_type_pkg.t_tiny_id
  , reject_disp_min_warn         com_api_type_pkg.t_tiny_id
  , disp_rest_warn               com_api_type_pkg.t_tiny_id
  , receipt_warn                 com_api_type_pkg.t_tiny_id
  , card_capture_warn            com_api_type_pkg.t_tiny_id
  , note_max_count               com_api_type_pkg.t_tiny_id
  , scenario_id                  com_api_type_pkg.t_tiny_id
  , hopper_count                 com_api_type_pkg.t_tiny_id
  , manual_synch                 com_api_type_pkg.t_dict_value
  , establ_conn_synch            com_api_type_pkg.t_dict_value
  , counter_mismatch_synch       com_api_type_pkg.t_dict_value
  , online_in_synch              com_api_type_pkg.t_dict_value
  , online_out_synch             com_api_type_pkg.t_dict_value
  , safe_close_synch             com_api_type_pkg.t_dict_value
  , disp_error_synch             com_api_type_pkg.t_dict_value
  , periodic_synch               com_api_type_pkg.t_dict_value
  , periodic_all_oper            com_api_type_pkg.t_boolean
  , periodic_oper_count          com_api_type_pkg.t_tiny_id
  , cash_in_present              com_api_type_pkg.t_boolean
  , cash_in_min_warn             com_api_type_pkg.t_tiny_id
  , cash_in_max_warn             com_api_type_pkg.t_tiny_id
  , mcc_template_id              com_api_type_pkg.t_medium_id
  , powerup_service              com_api_type_pkg.t_dict_value
  , supervisor_service           com_api_type_pkg.t_dict_value
  , dispense_algo                com_api_type_pkg.t_dict_value
);

type t_tcp_ip_protocol is record(
    remote_address          com_api_type_pkg.t_remote_adr
  , remote_port             com_api_type_pkg.t_port
  , local_port              com_api_type_pkg.t_port
  , initiator               com_api_type_pkg.t_dict_value
  , format                  com_api_type_pkg.t_dict_value
  , header_length           com_api_type_pkg.t_mcc
  , keep_alive              com_api_type_pkg.t_boolean
  , monitor_connection      com_api_type_pkg.t_boolean
  , multiple_connection     com_api_type_pkg.t_boolean
);

type t_encryption is record(
    id                  com_api_type_pkg.t_medium_id
  , key_type            com_api_type_pkg.t_dict_value
  , key_prefix          varchar2(50)
  , key_length          com_api_type_pkg.t_tiny_id
  , check_value         varchar2(6)
  , key                 varchar2(48)
  , entity_type         com_api_type_pkg.t_dict_value
  , object_id           com_api_type_pkg.t_long_id
);

type t_dispenser is record(
    id               com_api_type_pkg.t_medium_id
  , disp_number      com_api_type_pkg.t_tiny_id
  , face_value       com_api_type_pkg.t_money
  , currency         com_api_type_pkg.t_curr_code
  , denomination_id  com_api_type_pkg.t_curr_code
  , dispenser_type   com_api_type_pkg.t_dict_value
);


end;
/
