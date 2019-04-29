create or replace package body cst_woo_rcn_processing_pkg is

procedure aggregate_gl_balance(
    i_inst_id  in com_api_type_pkg.t_inst_id
  , i_eff_date in date
) is
    l_date date default trunc(i_eff_date);
begin --main

    if l_date is null then 
        l_date := trunc(sysdate); 
    end if;

    merge into cst_woo_rcn_gl_balance glb
    using ( select ag.agent_number
                 , gl.account_number
                 , trunc(opr.oper_date) as aggr_date
                 , sum(ent.amount * ent.balance_impact) as amount
                 , com_api_currency_pkg.get_currency_name(gl.currency) as currency
              from acc_entry_vw ent
              join acc_macros_vw mac on mac.id = ent.macros_id
              join opr_operation_vw opr on opr.id = mac.object_id
               and mac.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION --'ENTTOPER'
              join acc_gl_account_mvw gl on gl.id = ent.account_id
              join ost_agent ag on ag.id = gl.agent_id
               and ag.agent_number in ('001', '100', '200', '300') -- for testing purpose
             where 1 = 1
               and (gl.inst_id = i_inst_id or i_inst_id is null)
               and (trunc(opr.oper_date) = l_date or l_date is null)
             group by ag.agent_number, gl.account_number, gl.currency, trunc(opr.oper_date)
          ) sel
       on (glb.account_number = sel.account_number and
           glb.aggregation_date = sel.aggr_date and
           glb.currency = sel.currency
          )
     when matched then
          update set status = cst_woo_const_pkg.GL_RCN_STATUS_MATCHED
           where glb.status = cst_woo_const_pkg.GL_RCN_STATUS_IMPORTED
     when not matched then insert
          values (sel.aggr_date, sel.account_number, cst_woo_const_pkg.GL_RCN_STATUS_AGGREGATED, sel.amount, sel.currency, sel.agent_number)
    ;

    trc_log_pkg.debug (
        i_text       => 'Were merged [#1] rec(s)'
      , i_env_param1 => sql%rowcount
    );

exception
when others then
    raise;
end aggregate_gl_balance;


procedure reconcile_gl_balance(
    i_start_date   in date
  , i_end_date     in date
) is

    l_start_date date default trunc(i_start_date);
    l_end_date   date default trunc(i_end_date) + 1;

begin
    if l_start_date is null and l_end_date is null then
        l_start_date := trunc(sysdate);
        l_end_date   := l_start_date + 1;

    elsif l_start_date is null then
        l_start_date := l_end_date - 1;

    elsif l_end_date is null then
        l_end_date   := l_start_date + 1;

    end if;

    merge into cst_woo_rcn_gl_balance glb
    using ( select gl.agent_number
                 , gl.account_number
                 , gl.aggregation_date
                 , gl.amount
                 , gl.currency
              from cst_woo_rcn_gl_balance_temp gl
          ) sel
       on (    glb.agent_number = sel.agent_number
           and glb.account_number = sel.account_number
           and glb.aggregation_date = sel.aggregation_date
           and glb.amount = sel.amount
           and glb.currency = sel.currency
           and glb.aggregation_date >= l_start_date
           and glb.aggregation_date <  l_end_date
          )
     when matched then
          update set glb.status = cst_woo_const_pkg.GL_RCN_STATUS_MATCHED
           where glb.status = cst_woo_const_pkg.GL_RCN_STATUS_AGGREGATED
     when not matched then insert
          values (sel.aggregation_date, sel.account_number, cst_woo_const_pkg.GL_RCN_STATUS_IMPORTED, sel.amount, sel.currency, sel.agent_number)
    ;

    execute immediate 'truncate table cst_woo_rcn_gl_balance_temp';

exception
when others then
    raise;
end reconcile_gl_balance;

    
end cst_woo_rcn_processing_pkg;
/
