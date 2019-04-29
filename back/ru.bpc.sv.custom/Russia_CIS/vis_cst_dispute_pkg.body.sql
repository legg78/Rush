create or replace package body vis_cst_dispute_pkg as
/*********************************************************
 *  The package with user-exits for VISA dispute processing <br />
 *
 *  Created by Alalykin A. (alalykin@bpcbt.com) at 28.01.2015 <br />
 *  Last changed by $Author: alalykin $ <br />
 *  $LastChangedDate: 2015-01-28 13:00:00 +0400#$ <br />
 *  Revision: $LastChangedRevision: 1 $ <br />
 *  Module: vis_cst_dispute_pkg <br />
 *  @headcom
 **********************************************************/

/*
 * Custom processing for generation of financial message's draft.
 */
procedure process_fin_message_draft(
    io_fin_message    in out nocopy vis_api_type_pkg.t_visa_fin_mes_rec
) is
begin
    trc_log_pkg.debug(
        i_text       => lower($$PLSQL_UNIT) || '.process_fin_message_draft: io_fin_message = {'
                     || 'network_id [' || io_fin_message.network_id || '], oper_currency [#1'
                     || '], oper_amount [' || io_fin_message.oper_amount
                     || '], sttl_amount [' || io_fin_message.sttl_amount || ']}'
      , i_env_param1 => io_fin_message.oper_currency
    );

    if  net_api_network_pkg.get_inst_id(i_network_id => io_fin_message.network_id)
            = vis_api_const_pkg.NATIONAL_PROC_CENTER_INST
        and io_fin_message.oper_currency != com_api_currency_pkg.RUBLE
        and io_fin_message.trans_code in (
                vis_api_const_pkg.TC_SALES_CHARGEBACK
              , vis_api_const_pkg.TC_VOUCHER_CHARGEBACK
              , vis_api_const_pkg.TC_CASH_CHARGEBACK
            )
    then
        -- Operation amount should be converted to Russian rubles
        -- but converted amount shouldn't be greater than settlement amount
        io_fin_message.oper_amount :=
            least(
                com_api_rate_pkg.convert_amount(
                    i_src_amount          => io_fin_message.oper_amount
                  , i_src_currency        => io_fin_message.oper_currency
                  , i_dst_currency        => com_api_currency_pkg.RUBLE
                  , i_rate_type           => 'RTTPCBRF'
                  , i_inst_id             => io_fin_message.inst_id
                  , i_eff_date            => io_fin_message.oper_date
                  , i_mask_exception      => com_api_type_pkg.FALSE
                  , i_conversion_type     => com_api_const_pkg.CONVERSION_TYPE_BUYING
                )
              , io_fin_message.sttl_amount
            );
        io_fin_message.oper_currency := com_api_currency_pkg.RUBLE;
    end if;
end;

end;
/
