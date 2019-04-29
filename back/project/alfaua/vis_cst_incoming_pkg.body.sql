create or replace package body vis_cst_incoming_pkg as
/*********************************************************
 *  The package with user-exits for processing of VISA incoming clearing <br />
 *
 *  Created by A. Alalykin (alalykin@bpcbt.com) at 28.07.2015 <br />
 *  Last changed by $Author: alalykin $ <br />
 *  $LastChangedDate: 2015-07-28 17:00:00 +0400#$ <br />
 *  Revision: $LastChangedRevision: 1 $ <br />
 *  Module: vis_cst_incoming_pkg <br />
 *  @headcom
 **********************************************************/ 

/*
 * Custom processing of settlement data (TC 46).
 */
procedure process_settlement_data(
    i_sttl_data          in            vis_api_type_pkg.t_settlement_data_rec
  , i_host_id            in            com_api_type_pkg.t_tiny_id
  , i_standard_id        in            com_api_type_pkg.t_tiny_id
) is
    LOG_PREFIX  constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_settlement_data: ';
begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'START with rep_id_num [' || i_sttl_data.rep_id_num
               || '], report_group [' || i_sttl_data.report_group
               || '], report_subgroup [' || i_sttl_data.report_subgroup || ']'
    );
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'END'
    );
end process_settlement_data;

/*
 * Custom processing of assign_dispute.
 */
procedure assign_dispute(
    io_visa              in out nocopy vis_api_type_pkg.t_visa_fin_mes_rec
  , o_iss_inst_id           out        com_api_type_pkg.t_inst_id
  , o_iss_network_id        out        com_api_type_pkg.t_tiny_id
  , o_acq_inst_id           out        com_api_type_pkg.t_inst_id
  , o_acq_network_id        out        com_api_type_pkg.t_tiny_id
  , o_sttl_type             out        com_api_type_pkg.t_dict_value
  , o_match_status          out        com_api_type_pkg.t_dict_value
) is
    LOG_PREFIX  constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.assign_dispute: ';
begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'START, io_visa.id [' || io_visa.id || ']'
    );
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'END'
    );
end assign_dispute;

/*
 * Custom preprocessing collections with data about operation and its participants.
 */
procedure before_creating_operation(
    io_oper              in out nocopy opr_api_type_pkg.t_oper_rec
  , io_iss_part          in out nocopy opr_api_type_pkg.t_oper_part_rec
  , io_acq_part          in out nocopy opr_api_type_pkg.t_oper_part_rec
)  is
    LOG_PREFIX  constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.before_creating_operation: ';
begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'START, io_oper.id [' || io_oper.id || ']'
    );
    -->aua 20180904
    if    io_iss_part.card_network_id is null
      and io_iss_part.network_id      =  1001
      and io_acq_part.network_id      <> 1001
    then
        io_iss_part.card_network_id := io_acq_part.network_id;
    end if;
    --<aua 20180904
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'END'
    );
end before_creating_operation;

/*
 * Custom preprocessing financial message collection.
 */
procedure process_fin_message(
    io_fin_rec           in out nocopy vis_api_type_pkg.t_visa_fin_mes_rec
) is
    LOG_PREFIX  constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_fin_message: ';
begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'START, io_fin_rec.id [' || io_fin_rec.id || ']'
    );
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'END'
    );
end process_fin_message;

end;
/
