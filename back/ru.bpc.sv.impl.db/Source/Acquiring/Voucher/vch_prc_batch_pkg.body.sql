create or replace package body vch_prc_batch_pkg as
/*********************************************************
*  API for voucher batches processing <br />
*  Created by Fomichev A.(fomichev@bpcbt.com)  at 21.03.2012 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::       $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: vch_prc_batch_pkg<br />
*  @headcom
**********************************************************/
procedure create_operations(
    i_inst_id  in   com_api_type_pkg.t_inst_id
) is
    l_oper_id      com_api_type_pkg.t_long_id;
    l_voucher_id   com_api_type_pkg.t_long_id;
    l_errors_count com_api_type_pkg.t_long_id;
begin
    prc_api_stat_pkg.log_start;

    for b in (
        select b.id
             , b.currency
             , m.merchant_number
             , (select min(customer_id) from prd_contract c where c.id = m.contract_id) customer_id
             , (select min(terminal_number) from acq_terminal t where t.id = b.terminal_id) terminal_number
             , b.inst_id
             , m.split_hash
             , row_number() over(order by b.id) rn
             , row_number() over(order by b.id desc) rn_desc
             , count(b.id) over() cnt
          from vch_batch b
             , acq_merchant m
         where b.status  = vch_api_const_pkg.BATCH_STATUS_WAITING
           and b.inst_id = i_inst_id
           and m.id      = b.merchant_id
         order by id
    ) loop
        if b.rn = 1 then
            prc_api_stat_pkg.log_estimation (
                i_estimated_count     => b.cnt
            );        
        end if;
        
        begin
            savepoint sp_before_batch;
            for v in (
                select id
                     , card_id
                     , expir_date
                     , oper_amount
                     , oper_id
                     , oper_type
                     , auth_code
                     , oper_request_amount
                     , oper_date
                     , (select min(card_number) from vch_card_number_vw n where voucher_id = v.id) as card_number
                  from vch_voucher v
                 where v.batch_id = b.id
                 order by id
            ) loop
                l_oper_id     := null;
                l_voucher_id  := v.id;

                opr_api_create_pkg.create_operation(
                    io_oper_id             => l_oper_id
                  , i_is_reversal          => com_api_const_pkg.FALSE
                  , i_oper_type            => v.oper_type
                  , i_msg_type             => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
                  , i_status               => opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
                  , i_sttl_type            => opr_api_const_pkg.SETTLEMENT_INTERNAL_INTRAINST
                  , i_merchant_number      => b.merchant_number
                  , i_terminal_number      => b.terminal_number
                  , i_oper_count           => 1
                  , i_oper_request_amount  => v.oper_request_amount
                  , i_oper_amount          => v.oper_amount
                  , i_oper_currency        => b.currency
                  , i_oper_date            => v.oper_date
                  , i_host_date            => v.oper_date
                );
  
                opr_api_create_pkg.add_participant(
                    i_oper_id               => l_oper_id
                  , i_msg_type              => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
                  , i_oper_type             => v.oper_type
                  , i_participant_type      => com_api_const_pkg.PARTICIPANT_ISSUER
                  , i_host_date             => get_sysdate
                  , i_inst_id               => b.inst_id
                  , i_customer_id           => b.customer_id
                  , i_card_id               => v.card_id
                  , i_card_number           => v.card_number
                  , i_split_hash            => b.split_hash
                  , i_without_checks        => com_api_const_pkg.TRUE
                );
  
                update vch_voucher
                   set oper_id = l_oper_id
                 where id      = v.id;
            end loop;
            update vch_batch
               set proc_date = get_sysdate
                 , status    = vch_api_const_pkg.BATCH_STATUS_PROCESSED
             where id        = b.id;
        exception
            when others then
                rollback to sp_before_batch;
                update vch_batch
                   set proc_date = get_sysdate
                     , status    = vch_api_const_pkg.BATCH_STATUS_ERROR
                 where id        = b.id;
                 l_errors_count := l_errors_count + 1;

                trc_log_pkg.error('batch_id='||b.id||', voucher_id='||l_voucher_id||' ['||sqlerrm||']');
        end;
        
        prc_api_stat_pkg.log_current (
            i_current_count       => b.rn
          , i_excepted_count      => l_errors_count
        );
    end loop;

    prc_api_stat_pkg.log_end(
        i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        raise;

end;

end;
/
