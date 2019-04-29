create or replace package body crd_ui_invoice_search_pkg as
/************************************************************
 * The API for search in invoice forms <br />
 * Created by Gogolev I. (i.gogolev@bpcbt.com)  at 11.01.2017 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: CRD_UI_INVOICE_SEARCH_PKG <br />
 * @headcom
 ************************************************************/
 
procedure get_interest_details_main(
    o_ref_cur           out     com_api_type_pkg.t_ref_cur
  , o_ref_count         out     com_api_type_pkg.t_medium_id
  , i_account_id         in     com_api_type_pkg.t_account_id
  , i_invoice_id         in     com_api_type_pkg.t_long_id
  , i_sorting_tab        in     com_param_map_tpt
  , i_is_first_call      in     com_api_type_pkg.t_boolean
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name    := lower($$PLSQL_UNIT) || '.get_interest_details_main: ';
    CRLF               constant com_api_type_pkg.t_name    := chr(13) || chr(10);
    FIRST_ELEMENT      constant com_api_type_pkg.t_boolean := 1;
    
    l_sort             com_api_type_pkg.t_name;
    
    COLUMN_LIST        constant com_api_type_pkg.t_text :=
    'select dint.id'
     ||  ', dint.debt_id'
     ||  ', dint.balance_type'
     ||  ', dint.start_date'
     ||  ', round(nvl( '
     ||  '      case '
     ||  '          crd_interest_pkg.get_interest_calc_end_date( '
     ||  '              i_account_id => i.account_id '
     ||  '          ) when ''ICEDDDUE'' then '
     ||  '                case trunc(i.invoice_date) '
     ||  '                    when trunc(dint.end_date) ' 
     ||  '                    then i.due_date '
     ||  '                    else dint.end_date ' 
     ||  '                end '
     ||  '          else dint.end_date '
     ||  '      end , i.invoice_date) - dint.start_date, 4) duration '
     ||  ', dint.amount'
     ||  ', dint.min_amount_due'
     ||  ', dint.interest_amount'
     ||  ', dint.fee_id'
     ||  ', dint.fee_desc'
     ||  ', dint.add_fee_id'
     ||  ', dint.add_fee_desc'
     ||  ', dint.is_charged'
     ||  ', dint.is_grace_enable'
     ||  ', i.id invoice_id'
     ||  ', dint.split_hash'
     ||  ', i.invoice_date'
     ||  ', dint.currency'
     ||  ', nvl( '
     ||  '      case '
     ||  '          crd_interest_pkg.get_interest_calc_end_date( '
     ||  '              i_account_id => i.account_id '
     ||  '          ) when ''ICEDDDUE'' then '
     ||  '                case trunc(i.invoice_date) '
     ||  '                    when trunc(dint.end_date) ' 
     ||  '                    then i.due_date '
     ||  '                    else dint.end_date ' 
     ||  '                end '
     ||  '         else dint.end_date '
     ||  '      end, i.invoice_date) end_date '
     ||  ', dint.oper_id'
     ||  ', dint.oper_type'
     ||  ', dint.oper_date'
     ||  ', dint.is_waived'
    ;

    l_ref_source                com_api_type_pkg.t_text :=
        'from ('
    ||        'select t.id'
    ||             ', t.debt_id'
    ||             ', t.balance_type'
    ||             ', t.start_date'
    ||             ', t.amount'
    ||             ', t.min_amount_due'
    ||             ', t.interest_amount'
    ||             ', t.fee_id'
    ||             ', t.fee_desc'
    ||             ', t.add_fee_id'
    ||             ', t.add_fee_desc'
    ||             ', t.is_charged'
    ||             ', t.is_grace_enable'
    ||             ', t.split_hash'
    ||             ', t.invoice_id'
    ||             ', t.is_waived'
    ||             ', d.currency'
    ||             ', d.oper_id'
    ||             ', d.oper_type'
    ||             ', d.oper_date'
    ||             ', lead(t.start_date) over (partition by t.debt_id, t.balance_type order by t.start_date, t.id) end_date '
    ||          'from crd_ui_debt_interest_vw t'
    ||             ', crd_debt d '
    ||         'where d.account_id      = :p_account_id '
    ||           'and t.debt_id         = d.id'
    ||       ') dint'
    ||     ', crd_ui_invoice_vw i '
    || 'where i.id = :p_invoice_id '
    ||   'and i.id = dint.invoice_id '
    ||   'and dint.split_hash = i.split_hash '
    ||   'and dint.interest_amount > 0'
    ;

begin
    trc_log_pkg.debug(LOG_PREFIX || 'START');
    
    begin
        
        if i_sorting_tab.exists(FIRST_ELEMENT) then
        
            select nvl2(list, 'order by '||list, '')
              into l_sort
              from (select rtrim(xmlagg(xmlelement(e,name||' '||char_value,',').extract('//text()')),',') list
                      from table(cast(i_sorting_tab as com_param_map_tpt))
                   );
                   
        end if;
               
    exception
        when no_data_found then
            null;
        when others then
            trc_log_pkg.debug(LOG_PREFIX || ' get_sorting_param FAILED; '||
                              'dumping i_sorting_tab for debug...'
            );
            
            utl_data_pkg.print_table(i_param_tab => i_sorting_tab); -- dumping collection, DEBUG logging level is required
            
            raise;
    end;
    
    if i_is_first_call = com_api_const_pkg.FALSE then
    
        l_ref_source := 'select * from ('
                     || COLUMN_LIST || ' ' || l_ref_source || ') ' || l_sort;

        trc_log_pkg.debug(LOG_PREFIX || ': l_ref_source [' || substr(l_ref_source, 1, 3900) || ']');

        open o_ref_cur for l_ref_source
        using i_account_id
            , i_invoice_id;
        
    else
        
        l_ref_source := 'select count(1) ' || l_ref_source;

        trc_log_pkg.debug(LOG_PREFIX || ': l_ref_source [' || substr(l_ref_source, 1, 3900) || ']');

        execute immediate l_ref_source
                     into o_ref_count
                    using in i_account_id
                        , in i_invoice_id;
    
    end if;

    trc_log_pkg.debug(LOG_PREFIX || 'END');
    
exception
    when others then
        
        trc_log_pkg.debug(substr(LOG_PREFIX || 'FAILED with l_ref_source is:' || CRLF || l_ref_source, 1, 3900));
        
        raise;
        
end get_interest_details_main;

procedure get_interest_details(
    o_ref_cur           out        com_api_type_pkg.t_ref_cur
  , i_account_id         in        com_api_type_pkg.t_account_id
  , i_invoice_id         in        com_api_type_pkg.t_long_id
  , i_sorting_tab        in        com_param_map_tpt
) is

    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_interest_details: ';
    l_row_count        com_api_type_pkg.t_medium_id;
    
begin
    
    trc_log_pkg.debug(LOG_PREFIX || 'START');
    
    get_interest_details_main(
        o_ref_cur        => o_ref_cur
      , o_ref_count      => l_row_count
      , i_account_id     => i_account_id
      , i_invoice_id     => i_invoice_id
      , i_sorting_tab    => i_sorting_tab
      , i_is_first_call  => com_api_const_pkg.FALSE
    );
    
    trc_log_pkg.debug(LOG_PREFIX || 'END');
    
exception
    when others then
       
        trc_log_pkg.debug(LOG_PREFIX || 'FAILED with i_account_id[' || i_account_id || '], i_invoice_id[' || i_invoice_id || ']');
        
        raise;
        
end get_interest_details;

procedure get_interest_details_count(
    o_row_count         out        com_api_type_pkg.t_medium_id
  , i_account_id         in        com_api_type_pkg.t_account_id
  , i_invoice_id         in        com_api_type_pkg.t_long_id
) is

    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_interest_details_count: ';
    l_ref_cur          com_api_type_pkg.t_ref_cur;
    
begin
    
    trc_log_pkg.debug(LOG_PREFIX || 'START');
    
    get_interest_details_main(
        o_ref_cur        => l_ref_cur
      , o_ref_count      => o_row_count
      , i_account_id     => i_account_id
      , i_invoice_id     => i_invoice_id
      , i_sorting_tab    => null
      , i_is_first_call  => com_api_const_pkg.TRUE
    );
    
    trc_log_pkg.debug(LOG_PREFIX || 'END');
    
exception
    when others then
        
        trc_log_pkg.debug(LOG_PREFIX || 'FAILED with i_account_id[' || i_account_id || '], i_invoice_id[' || i_invoice_id || ']');
        
        raise;
        
end get_interest_details_count;

end crd_ui_invoice_search_pkg;
/
