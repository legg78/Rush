create or replace package body opr_api_reversal_pkg is
/********************************************************* 
 *  Operation reversal API <br />
 *  Created by Kopachev D.(kopachev@bpcbt.com) at 01.01.2013 <br />
 *  Last changed by $Author: kopachev $ <br />
 *  $LastChangedDate:: 2013-09-27 16:53:04 +0400#$ <br />
 *  Revision: $LastChangedRevision: 35108 $ <br />
 *  Module:  opr_api_reversal_pkg  <br />
 *  @headcom
 **********************************************************/
 
    function reversal_exists (
        i_id                        in com_api_type_pkg.t_long_id
        , o_oper_amount             out com_api_type_pkg.t_money
        , o_oper_currency           out com_api_type_pkg.t_curr_code
        , i_mask_error              in com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE
    ) return com_api_type_pkg.t_boolean is
        l_result                    com_api_type_pkg.t_boolean;
        l_currency_count            com_api_type_pkg.t_count := 0;
    begin
        trc_log_pkg.debug (
            i_text                  => 'Check if reversal exists for original operation [#1]'
            , i_env_param1          => i_id
        );
        
        select
            case when count(r.id) > 0 then 1 else 0 end
            , sum(r.oper_amount)
            , min(r.oper_currency)
            , nvl(count(distinct r.oper_currency), 0)
        into
            l_result
            , o_oper_amount
            , o_oper_currency
            , l_currency_count
        from
            opr_operation r
            , aut_auth t
        where
            r.original_id = i_id
            and r.is_reversal = com_api_type_pkg.TRUE
            and t.id(+) = r.id
            and case r.status_reason
                    when aut_api_const_pkg.AUTH_REASON_DUE_TO_RESP_CODE 
                    then t.resp_code
                    else nvl(r.status_reason, aup_api_const_pkg.RESP_CODE_OK)
                end
                = aup_api_const_pkg.RESP_CODE_OK;

        if l_currency_count > 1 and i_mask_error = com_api_type_pkg.FALSE then
            com_api_error_pkg.raise_error (
                i_error         => 'BAD_REVERSAL_CURRENCY'
                , i_env_param1  => i_id
            );
        end if;
        
        return l_result;
    end;
    
    function reversal_exists (
        i_id                        in com_api_type_pkg.t_long_id
    ) return com_api_type_pkg.t_boolean is
        l_oper_amount               com_api_type_pkg.t_money;
        l_oper_currency             com_api_type_pkg.t_curr_code;
    begin
        return reversal_exists (
            i_id               => i_id
            , o_oper_amount    => l_oper_amount
            , o_oper_currency  => l_oper_currency
            , i_mask_error     => com_api_type_pkg.TRUE
        );
    end;

    function get_reversals_amount(
        i_original_id               in com_api_type_pkg.t_long_id
    ) return com_api_type_pkg.t_money is

        l_result_amount                com_api_type_pkg.t_money;

    begin

        trc_log_pkg.debug(
            i_text          => 'Getting reversal amount for original operation [#1]'
          , i_env_param1    => i_original_id
        );

        select nvl(sum(amount), 0)
          into l_result_amount
          from opr_operation  op
             , acc_macros     ma
         where op.original_id = i_original_id
           and op.is_reversal = com_api_type_pkg.TRUE
           and op.status = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
           and ma.object_id = op.id
           and ma.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION;

        return l_result_amount;

    end get_reversals_amount;

end;
/
