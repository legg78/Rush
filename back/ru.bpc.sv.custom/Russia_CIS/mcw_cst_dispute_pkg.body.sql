create or replace package body mcw_cst_dispute_pkg as
/*********************************************************
 *  The package with user-exits for MasterCard dispute processing <br />
 *
 *  Created by Alalykin A. (alalykin@bpcbt.com) at 28.01.2015 <br />
 *  Last changed by $Author: alalykin $ <br />
 *  $LastChangedDate: 2015-01-28 13:00:00 +0400#$ <br />
 *  Remcwion: $LastChangedVersion: 1 $ <br />
 *  Module: mcw_cst_dispute_pkg <br />
 *  @headcom
 **********************************************************/

/*
 * Custom processing for generation of financial message's first chargeback.
 */
procedure gen_first_chargeback(
    io_fin_message    in out nocopy mcw_api_type_pkg.t_fin_rec
) is
    l_oper_amount      com_api_type_pkg.t_money;
    l_oper_currency    com_api_type_pkg.t_curr_code;
begin
    trc_log_pkg.debug(
        i_text => lower($$PLSQL_UNIT) || '.gen_first_chargeback: io_fin_message = {'
               || 'network_id [' || io_fin_message.network_id
               || '], de049 ['   || io_fin_message.de049
               || '], p0149_1 [' || io_fin_message.p0149_1
               || '], de004 ['   || io_fin_message.de004
               || '], de030_1 [' || io_fin_message.de030_1
               || '], de005 ['   || io_fin_message.de005 || ']}'
    );

    l_oper_currency := nvl(io_fin_message.de049, io_fin_message.p0149_1);
    l_oper_amount   := nvl(io_fin_message.de004, io_fin_message.de030_1);

    if  net_api_network_pkg.get_inst_id(i_network_id => io_fin_message.network_id)
            = mcw_api_const_pkg.NATIONAL_PROC_CENTER_INST
        and l_oper_currency != com_api_currency_pkg.RUBLE
        and io_fin_message.mti = mcw_api_const_pkg.MSG_TYPE_CHARGEBACK
    then
        -- Operation amount should be converted to Russian rubles
        -- but converted amount shouldn't be greater than settlement amount
        l_oper_amount :=
            least(
                com_api_rate_pkg.convert_amount(
                    i_src_amount          => l_oper_amount
                  , i_src_currency        => l_oper_currency
                  , i_dst_currency        => com_api_currency_pkg.RUBLE
                  , i_rate_type           => 'RTTPCBRF'
                  , i_inst_id             => io_fin_message.inst_id
                  , i_eff_date            => io_fin_message.de012 -- operation date
                  , i_mask_exception      => com_api_type_pkg.FALSE
                  , i_conversion_type     => com_api_const_pkg.CONVERSION_TYPE_BUYING
                )
              , io_fin_message.de005 -- settlement amount
            );

        if io_fin_message.de004 is not null then
            io_fin_message.de004   := l_oper_amount;
        else
            io_fin_message.de030_1 := l_oper_amount;
        end if;

        if io_fin_message.de049 is not null then
            io_fin_message.de049   := com_api_currency_pkg.RUBLE;
        else
            io_fin_message.p0149_1 := com_api_currency_pkg.RUBLE;
        end if;
    end if;
end;

end;
/
