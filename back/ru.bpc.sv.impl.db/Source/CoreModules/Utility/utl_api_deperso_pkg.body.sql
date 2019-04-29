create or replace package body utl_api_deperso_pkg is
/**********************************************************
 * API for depersonalization of personal data <br />
 * Created by Kopachev D.(kopachev@bpcbt.com)  at 17.01.2017 <br />
 * Last changed by $Author: fomichev $ <br />
 * $LastChangedDate:: 2017-08-07 14:00:45 +0400$ <br />
 * Module: utl_api_deperso_pkg <br />
 * @headcom
 **********************************************************/

BULK_LIMIT             constant integer := 400;
BULK_COMMIT            constant integer := 25000;
SIZEOF_T_FULL_DESC     constant pls_integer := 2000; -- sizeof(com_api_type_pkg.t_full_desc)
    
e_table_not_exist exception;
PRAGMA EXCEPTION_INIT(e_table_not_exist, -942);
    
LOG_PREFIX             constant com_api_type_pkg.t_name := 'DEPERSO: ';

g_time integer := dbms_utility.get_time;
procedure log_record (
    i_text in     com_api_type_pkg.t_text
) is
    pragma autonomous_transaction;
    l_section com_api_type_pkg.t_full_desc;
    v_text    com_api_type_pkg.t_text;
begin
    v_text := LOG_PREFIX || i_text || ' ['||to_char((dbms_utility.get_time-g_time)/100,'FM999999999999990.00')||' sec.]';
    g_time := dbms_utility.get_time;
        
    l_section := substrb(trc_log_pkg. get_error_stack || chr(10) || 'Oracle:' || sqlerrm, 1, SIZEOF_T_FULL_DESC);
  
    --dbms_output.put_line(v_text);
    insert into trc_log (
        trace_timestamp
      , trace_level
      , trace_section
      , trace_text
      , user_id
      , entity_type
      , object_id
      , event_id
      , label_id
      , inst_id
      , session_id
      , thread_number
      , who_called
    ) values (
        current_timestamp
      , 'DEBUG'
      , l_section
      , v_text
      , sys_context('USERENV', 'CLIENT_IDENTIFIER')
      , null
      , null
      , null
      , null
      , null
      , get_session_id
      , get_thread_number
      , null
    );
    commit;
end;
--columns TRACE_SECTION, USER_ID and SESSION_ID. At least, the data from column TRACE_SECTION must be presented in table TRC_LOG.   
function gen_name (
    i_length                  in number
) return varchar2 is
begin
    return dbms_random.string('a', trunc(dbms_random.value(0, i_length)));
end;

function gen_date (
    i_begin_date            in date
  , i_end_date              in date
) return date is
begin
    return to_date(trunc(dbms_random.value( to_number(to_char(i_begin_date, 'J')), to_number(to_char(i_end_date, 'J')) )),'J');
end;

function gen_number (
    i_low                   in number
  , i_high                  in number
) return number is
begin
    return trunc(dbms_random.value(i_low, i_high));
end;

procedure exec_no_errors(
    i_text in com_api_type_pkg.t_text
) is
begin
    execute immediate i_text;
exception
    when others then
        log_record(i_text||': error - '||substr(sqlerrm,1,400));
end;

procedure exec(
    i_text in com_api_type_pkg.t_text
) is
begin
    execute immediate i_text;
end;

    
procedure create_indexes is
begin
    log_record(i_text => 'create indexes started');

    exec_no_errors('drop index aut_card_dst_card_number_ndx');
    exec_no_errors('create index aut_card_dst_card_number_ndx on aut_card (reverse(dst_card_number))');
    exec_no_errors('drop index aut_reject_card_mask_ndx');
    exec_no_errors('create index aut_reject_card_mask_ndx on aut_reject (reverse(card_mask))');
    exec_no_errors('drop index pmo_linked_card_mask_ndx');
    exec_no_errors('create index pmo_linked_card_mask_ndx on pmo_linked_card (reverse(card_mask))');
    exec_no_errors('drop index vch_card_number_ndx');
    exec_no_errors('create index vch_card_number_ndx on vch_card_number (reverse(card_number))');
    exec_no_errors('drop index ecm_linked_cardholder_ndx');
    exec_no_errors('create index ecm_linked_cardholder_ndx on ecm_linked_card (reverse(cardholder_name))');
    exec_no_errors('drop index pmo_linked_cardholder_ndx');
    exec_no_errors('create index pmo_linked_cardholder_ndx on pmo_linked_card (reverse(cardholder_name))');
    exec_no_errors('drop index vis_card_card_number_ndx');
    exec_no_errors('create index vis_card_card_number_ndx on vis_card (reverse(card_number))');
    exec_no_errors('drop index ecm_linked_card_mask_ndx');
    exec_no_errors('create index ecm_linked_card_mask_ndx on ecm_linked_card (reverse(card_mask))');
    exec_no_errors('drop index aci_clerk_tot_card_num_ndx');
    exec_no_errors('create index aci_clerk_tot_card_num_ndx on aci_clerk_tot(headx_crd_card_crd_num)');
    exec_no_errors('drop index aci_pos_fin_card_num_ndx');
    exec_no_errors('create index aci_pos_fin_card_num_ndx on aci_pos_fin(headx_crd_card_crd_num)');
    exec_no_errors('drop index aci_pos_setl_card_num_ndx');
    exec_no_errors('create index aci_pos_setl_card_num_ndx on aci_pos_setl(headx_crd_card_crd_num)');
    exec_no_errors('drop index aci_service_card_num_ndx');
    exec_no_errors('create index aci_service_card_num_ndx on aci_service(headx_crd_card_crd_num)');
    exec_no_errors('drop index aup_belkart_card_num_ndx');
    exec_no_errors('create index aup_belkart_card_num_ndx on aup_belkart(card_num)');
    log_record(i_text => 'create indexes has finished');
exception
    when others then
        log_record(i_text =>  'create_indexes Error: ' || sqlerrm || ' Stack: ' || dbms_utility.format_error_backtrace);
        raise;
end;
    
procedure before_deperso (
    i_start_date in     date default null
  , i_end_date   in     date default null
) is
    l_start_id          com_api_type_pkg.t_long_id;
    l_end_id            com_api_type_pkg.t_long_id;
begin
    l_start_id := com_api_id_pkg.get_from_id(trunc(coalesce(i_start_date, sysdate)));
    l_end_id   := com_api_id_pkg.get_till_id(coalesce(i_end_date, sysdate));
        
    log_record(i_text => 'before deperso has started. [' || l_start_id || ' - '|| l_end_id || ']');

    execute immediate 'delete from utl_us_card_number where split_hash in (select split_hash from com_api_split_map_vw)';

    execute immediate 'delete from utl_them_card_number where split_hash in (select split_hash from com_api_split_map_vw)';

    -- us cards
    insert /* +append */ into utl_us_card_number ( 
           id 
         , split_hash 
         , new_card_number 
         , new_card_hash
         , new_card_mask
         , old_card_number
         , old_card_hash
         , old_card_mask)
    select cn.card_id 
         , c.split_hash 
         , cn.card_number new_card_number 
         , c.card_hash new_card_hash
         , c.card_mask new_card_mask
         , cn.card_number old_card_number
         , c.card_hash old_card_hash
         , c.card_mask old_card_mask
      from iss_card c
         , iss_card_number cn 
     where c.id        = cn.card_id 
       and c.split_hash in (select split_hash from com_api_split_map_vw);

    log_record(i_text => 'utl_us_card_number filled ('||sql%rowcount || ' records)');
            
    -- them cards
    insert /* +append */ into utl_them_card_number ( 
           id
         , old_card_number
         , new_card_number
         , split_hash )
    select utl_them_card_number_seq.nextval
         , old_card_number
         , substr(old_card_number, 1, 6) || lpad(trunc(dbms_random.value(0, power(10, 15))), length(old_card_number) - 6, '0') new_card_number
         , split_hash
     from (
        select distinct 
               c.card_number old_card_number
             , split_hash
          from opr_card c 
         where c.oper_id >= l_start_id 
           and c.split_hash in (select split_hash from com_api_split_map_vw)
           and not exists (select 1 from iss_card_number n where reverse(n.card_number) = reverse(c.card_number)) 
    );
    log_record(i_text => 'utl_them_card_number filled ('||sql%rowcount || ' records)');
        
    log_record(i_text => 'before deperso has finished');
exception
    when others then
        log_record(i_text => 'before_deperso Error: ' || sqlerrm || ' Stack: ' || dbms_utility.format_error_backtrace);
        raise;
end;
    
-- RUN SENSIBLE!
procedure run_deperso_card (
    i_start_date            in date default null
  , i_end_date              in date default null
) is
    l_card_cur            sys_refcursor;
    l_instance_data_cur   sys_refcursor;
    l_attribute_value_cur sys_refcursor;

    l_id_tab              com_api_type_pkg.t_number_tab;
    l_card_id_tab         com_api_type_pkg.t_medium_tab;
    l_old_card_number_tab com_api_type_pkg.t_card_number_tab;
    l_card_number_tab     com_api_type_pkg.t_card_number_tab;
    l_old_card_mask_tab   com_api_type_pkg.t_card_number_tab;
    l_card_mask_tab       com_api_type_pkg.t_card_number_tab;
    l_old_card_hash_tab   com_api_type_pkg.t_medium_tab;
    l_card_hash_tab       com_api_type_pkg.t_medium_tab;
    l_split_hash_tab      com_api_type_pkg.t_tiny_tab;
    l_bin_tab             com_api_type_pkg.t_card_number_tab;

    l_idx                 number;
    l_start_id            com_api_type_pkg.t_long_id;
    l_end_id              com_api_type_pkg.t_long_id;
    l_processed_count     com_api_type_pkg.t_long_id;
    l_bulk_count          com_api_type_pkg.t_long_id := 0;
    l_cycle_count         com_api_type_pkg.t_long_id := 0;

    procedure change_field(
        i_table_name          in      com_api_type_pkg.t_name
      , i_field_name in      com_api_type_pkg.t_name
    ) is
    begin
        forall i in 1..l_old_card_number_tab.count
            execute immediate 
                'update '||i_table_name||
                ' set '||i_field_name|| ' = :new_value '||
                ' where '||i_field_name||' = :old_value' 
            using l_card_number_tab(i)
                , l_old_card_number_tab(i) ;
            log_record(i_table_name||'('||i_field_name||'): rowcount='||sql%rowcount);
    exception
        when utl_api_deperso_pkg.e_table_not_exist 
        then log_record(i_table_name||'('||i_field_name||'): '||substr(sqlerrm, 1, 200));
    end;
begin
    /*
    1 - card numbers
    2 - transaction by card numbers
    3 - attribute value
    4 - card crypto values
    */

    l_start_id := com_api_id_pkg.get_from_id(trunc(coalesce(i_start_date, sysdate)));
    l_end_id   := com_api_id_pkg.get_till_id(coalesce(i_end_date, sysdate));
        
    log_record(i_text => 'run deperso card has started. [' || l_start_id || ' - '|| l_end_id || ']');

    l_processed_count := 0;

    log_record(i_text => 'table iss_card');


    open l_card_cur for
    select cn.card_id
         , cn.card_number
         , cn.card_number
         , c.card_mask
         , c.card_mask
         , c.card_hash
         , c.card_hash
         , c.split_hash
         , substr(cn.card_number, 1, 6) bin
      from iss_card c
         , iss_card_number cn
     where c.id         = cn.card_id
       and c.split_hash in (select split_hash 
                              from com_api_split_map_vw)
     order by cn.card_id;

    loop
        fetch l_card_cur
         bulk collect into
              l_card_id_tab
            , l_old_card_number_tab
            , l_card_number_tab
            , l_old_card_mask_tab
            , l_card_mask_tab
            , l_old_card_hash_tab
            , l_card_hash_tab
            , l_split_hash_tab
            , l_bin_tab
        limit BULK_LIMIT;

        -- convert card numbers
        for i in 1..l_card_id_tab.count loop
            l_card_number_tab(i) := l_bin_tab(i) || com_api_type_pkg.pad_number(to_char(gen_number(0, power(10, 15))), 10, 10);
            l_card_mask_tab(i)   := iss_api_card_pkg.get_card_mask(l_card_number_tab(i));
            l_card_hash_tab(i)   := com_api_hash_pkg.get_card_hash(l_card_number_tab(i));
        end loop;

        begin
            forall i in 1..l_card_id_tab.count save exceptions
                update iss_card_number
                   set card_number = l_card_number_tab(i)
                 where card_id     = l_card_id_tab(i);
                 l_bulk_count := sql%rowcount;
        exception
            when com_api_error_pkg.e_dml_errors then
                for i in 1..sql%bulk_exceptions.count loop
                    l_idx := sql%bulk_exceptions(i).error_index;

                    l_card_number_tab(l_idx) := l_bin_tab(l_idx) || com_api_type_pkg.pad_number(to_char(gen_number(0, power(10, 15))), 10, 10);
                    l_card_mask_tab(l_idx)   := iss_api_card_pkg.get_card_mask(l_card_number_tab(l_idx));
                    l_card_hash_tab(l_idx)   := com_api_hash_pkg.get_card_hash(l_card_number_tab(l_idx));

                    update iss_card_number
                       set card_number = l_card_number_tab(l_idx)
                     where card_id     = l_card_id_tab(l_idx);
                     l_cycle_count := l_cycle_count + 1;
                end loop;
        end;
        log_record('iss_card_number: bulk count='||l_bulk_count||', cycle_count='|| l_cycle_count);

        forall i in 1..l_card_id_tab.count
            update iss_card
               set card_mask  = l_card_mask_tab(i)
                 , card_hash  = l_card_hash_tab(i)
             where id         = l_card_id_tab(i)
               and split_hash = l_split_hash_tab(i);
        log_record('iss_card: rowcount='||sql%rowcount);
            
        forall i in 1..l_card_id_tab.count
            update iss_black_list
               set card_number = l_card_number_tab(i)
             where id          = l_card_id_tab(i);
        log_record('iss_black_list: rowcount='||sql%rowcount);

        forall i in 1..l_card_id_tab.count
            update utl_us_card_number
               set split_hash      = l_split_hash_tab(i)
                 , new_card_number = l_card_number_tab(i)
                 , new_card_hash   = l_card_hash_tab(i)
                 , new_card_mask   = l_card_mask_tab(i)
             where id              = l_card_id_tab(i);
        log_record('utl_us_card_number: rowcount='||sql%rowcount);
            
        l_processed_count := l_processed_count + l_card_id_tab.count;
        if mod(l_processed_count, BULK_COMMIT) = 0 or l_card_cur%notfound then
            log_record(i_text => 'table iss_card has processed = '||l_processed_count);
        end if;

        exit when l_card_cur%notfound;
    end loop;
    close l_card_cur;
------------- US CARDS        
    l_processed_count := 0;
    log_record(i_text => 'table us card on operation');
    open l_card_cur for
    select c.id as card_id
         , c.old_card_number
         , c.new_card_number
         , c.old_card_mask
         , c.new_card_mask
         , c.old_card_hash
         , c.new_card_hash
         , c.split_hash
      from utl_us_card_number c
     where c.split_hash in (select split_hash 
                              from com_api_split_map_vw);
    loop
        fetch l_card_cur
         bulk collect into
              l_card_id_tab
            , l_old_card_number_tab
            , l_card_number_tab
            , l_old_card_mask_tab
            , l_card_mask_tab
            , l_old_card_hash_tab
            , l_card_hash_tab
            , l_split_hash_tab
        limit BULK_LIMIT;
                    
        forall i in 1..l_old_card_number_tab.count
            update aut_card
               set card_number = l_card_number_tab(i)
             where card_number = l_old_card_number_tab(i)
               and split_hash  = l_split_hash_tab(i)
               and auth_id    >= l_start_id
               and auth_id    <= l_end_id;
        log_record('aut_card: rowcount='||sql%rowcount);
            
        forall i in 1..l_old_card_number_tab.count
            update --+ INDEX ( AUT_CARD AUT_CARD_DST_CARD_NUMBER_NDX )
                   aut_card
               set dst_card_number = l_card_number_tab(i)
             where reverse(dst_card_number) = reverse(l_old_card_number_tab(i))
               and split_hash = l_split_hash_tab(i)
               and auth_id   >= l_start_id
               and auth_id   <= l_end_id;
        log_record('aut_card: rowcount='||sql%rowcount);
            
        forall i in 1..l_old_card_number_tab.count
            update aut_reject
               set card_mask = l_card_mask_tab(i)
                 , card_hash = l_card_hash_tab(i)
             where reverse(card_mask) = reverse(l_old_card_mask_tab(i))
               and id                >= l_start_id
               and id                <= l_end_id;
        log_record('aut_reject: rowcount='||sql%rowcount);

        change_field(i_table_name => 'aci_card',              i_field_name => 'card_number');            -- ACI
        change_field(i_table_name => 'aci_clerk_tot',         i_field_name => 'headx_crd_card_crd_num'); -- ACI
        change_field(i_table_name => 'aci_pos_fin',           i_field_name => 'headx_crd_card_crd_num'); -- ACI
        change_field(i_table_name => 'aci_pos_setl',          i_field_name => 'headx_crd_card_crd_num'); -- ACI
        change_field(i_table_name => 'aci_service',           i_field_name => 'headx_crd_card_crd_num'); -- ACI
        change_field(i_table_name => 'acq_card_distribution', i_field_name => 'card_number');            -- ACQ
        change_field(i_table_name => 'acq_reimb_oper',        i_field_name => 'card_number');            -- ACQ
        change_field(i_table_name => 'amx_card',              i_field_name => 'card_number');            -- AMX
        change_field(i_table_name => 'aup_belkart',           i_field_name => 'card_num');               -- AUP
        change_field(i_table_name => 'bgn_card',              i_field_name => 'card_number');            -- BGN
        change_field(i_table_name => 'cmp_card',              i_field_name => 'card_number');            -- CMP
        change_field(i_table_name => 'cup_card',              i_field_name => 'card_number');            -- CUP
        change_field(i_table_name => 'din_card',              i_field_name => 'card_number'); -- DIN
        change_field(i_table_name => 'jcb_card',              i_field_name => 'card_number');            -- JCB

--------- MCW        
        forall i in 1..l_old_card_number_tab.count
            update mcw_card
               set card_number = l_card_number_tab(i)
             where card_number = l_old_card_number_tab(i)
               and id         >= l_start_id
               and id         <= l_end_id;
        log_record('mcw_card: rowcount='||sql%rowcount);

        change_field(i_table_name => 'mup_card',              i_field_name => 'card_number'); -- MUP
        change_field(i_table_name => 'nbc_card',              i_field_name => 'card_number'); -- NBC
--------- OPR
        forall i in 1..l_old_card_number_tab.count
            update opr_participant
               set card_mask = l_card_mask_tab(i)
                 , card_hash = l_card_hash_tab(i)
             where oper_id in (
                    select oper_id
                      from opr_card
                     where reverse(card_number) = reverse(l_old_card_number_tab(i))
                       and split_hash           = l_split_hash_tab(i)
                       and oper_id             >= l_start_id
                       and oper_id             <= l_end_id)
               and split_hash = l_split_hash_tab(i)
               and card_hash = l_old_card_hash_tab(i);
        log_record('opr_participant: rowcount='||sql%rowcount);
            
        forall i in 1..l_old_card_number_tab.count
            update opr_card
               set card_number          = l_card_number_tab(i)
             where reverse(card_number) = reverse(l_old_card_number_tab(i))
               and split_hash           = l_split_hash_tab(i)
               and oper_id             >= l_start_id
               and oper_id             <= l_end_id;
        log_record('opr_card: rowcount='||sql%rowcount);

        change_field(i_table_name => 'pos_batch_detail', i_field_name => 'card_number'); -- POS
        change_field(i_table_name => 'tie_card',         i_field_name => 'card_number'); -- TIE

-------- VIS
        forall i in 1..l_old_card_number_tab.count
            update vis_card
               set card_number = l_card_number_tab(i)
             where reverse(card_number) = reverse(l_old_card_number_tab(i))
               and id                  >= l_start_id
               and id                  <= l_end_id;
        log_record('vis_card: rowcount='||sql%rowcount);

        change_field(i_table_name => 'vis_multipurpose', i_field_name => 'card_number');
        change_field(i_table_name => 'vis_reject_data', i_field_name => 'card_number');

        forall i in 1..l_old_card_number_tab.count
            update ecm_linked_card
               set card_mask          = l_card_mask_tab(i)
             where reverse(card_mask) = reverse(l_old_card_mask_tab(i));
        log_record('ecm_linked_card: rowcount='||sql%rowcount);
            
        forall i in 1..l_old_card_number_tab.count
            update pmo_linked_card
               set card_mask          = l_card_mask_tab(i)
             where reverse(card_mask) = reverse(l_old_card_mask_tab(i));
        log_record('pmo_linked_card: rowcount='||sql%rowcount);

        forall i in 1..l_old_card_number_tab.count
            update vch_card_number
               set card_number          = l_card_number_tab(i)
             where reverse(card_number) = reverse(l_old_card_number_tab(i));
        log_record('vch_card_number: rowcount='||sql%rowcount);
            
        l_processed_count := l_processed_count + l_card_id_tab.count;
        if mod(l_processed_count, BULK_COMMIT) = 0 or l_card_cur%notfound then
            log_record(i_text => 'table linked_card has processed = '||l_processed_count);
        end if;

        l_processed_count := l_processed_count + l_card_id_tab.count;
        if mod(l_processed_count, BULK_COMMIT) = 0 or l_card_cur%notfound then
            log_record(i_text => 'table us card on operation has processed = '||l_processed_count);
        end if;

        exit when l_card_cur%notfound;
    end loop;
    close l_card_cur;
------------ Them cards        
    log_record(i_text => 'them cards on operation');
    open l_card_cur for
    select c.old_card_number
         , c.new_card_number
         , c.split_hash
      from utl_them_card_number c
     where c.split_hash in (select split_hash 
                              from com_api_split_map_vw);
    loop
        fetch l_card_cur
         bulk collect into
              l_old_card_number_tab
            , l_card_number_tab
            , l_split_hash_tab
        limit BULK_LIMIT;
            
        forall i in 1..l_old_card_number_tab.count
            update opr_card
               set card_number          = l_card_number_tab(i)
             where reverse(card_number) = reverse(l_old_card_number_tab(i))
               and split_hash           = l_split_hash_tab(i)
               and oper_id             >= l_start_id
               and oper_id             <= l_end_id;
        log_record('opr_card: rowcount='||sql%rowcount);

        change_field(i_table_name => 'aci_card',    i_field_name => 'card_number'); -- ACI
        change_field(i_table_name => 'amx_card',    i_field_name => 'card_number'); -- AMX
        change_field(i_table_name => 'aup_belkart', i_field_name => 'card_num');    -- AUP
        change_field(i_table_name => 'bgn_card',    i_field_name => 'card_number'); -- BGN
        change_field(i_table_name => 'cmp_card',    i_field_name => 'card_number'); -- CMP
        change_field(i_table_name => 'cup_card',    i_field_name => 'card_number'); -- CUP
        change_field(i_table_name => 'din_card',    i_field_name => 'card_number'); -- DIN
        change_field(i_table_name => 'jcb_card',    i_field_name => 'card_number'); -- JCB
--------- MCW        
        forall i in 1..l_old_card_number_tab.count
            update vis_card
               set card_number          = l_card_number_tab(i)
             where reverse(card_number) = reverse(l_old_card_number_tab(i))
               and id                  >= l_start_id
               and id                  <= l_end_id;
        log_record('vis_card: rowcount='||sql%rowcount);
            
        forall i in 1..l_old_card_number_tab.count
            update mcw_card
               set card_number = l_card_number_tab(i)
             where card_number = l_old_card_number_tab(i)
               and id         >= l_start_id
               and id         <= l_end_id;
        log_record('mcw_card: rowcount='||sql%rowcount);
                    
        forall i in 1..l_old_card_number_tab.count
            update aut_card
               set card_number = l_card_number_tab(i)
             where card_number = l_old_card_number_tab(i)
               and split_hash  = l_split_hash_tab(i)
               and auth_id    >= l_start_id
               and auth_id    <= l_end_id;
        log_record('aut_card: rowcount='||sql%rowcount);
            
        forall i in 1..l_old_card_number_tab.count
            update aut_card
               set dst_card_number          = l_card_number_tab(i)
             where reverse(dst_card_number) = reverse(l_old_card_number_tab(i))
               and split_hash               = l_split_hash_tab(i)
               and auth_id                 >= l_start_id
               and auth_id                 <= l_end_id;
        log_record('aut_card: reverse rowcount='||sql%rowcount);
        commit;
            
        l_processed_count := l_processed_count + l_card_id_tab.count;
        if mod(l_processed_count, BULK_COMMIT) = 0 or l_card_cur%notfound then
            log_record(i_text => 'them card has processed = '||l_processed_count);
        end if;

        exit when l_card_cur%notfound;
    end loop;
    close l_card_cur;
        
    log_record(i_text => 'table prd_attribute_value');
    open l_attribute_value_cur for
    select id
      from prd_attribute_value
     where entity_type = 'ENTTCARD'
       and split_hash in (select split_hash from com_api_split_map_vw);
    loop
        fetch l_attribute_value_cur
         bulk collect into
              l_id_tab
        limit BULK_LIMIT;

        forall i in 1..l_id_tab.count
            update prd_attribute_value
               set attr_value = null
             where id         = l_id_tab(i);

        log_record('prd_attribute_value: rowcount='||sql%rowcount);
        exit when l_attribute_value_cur%notfound;
    end loop;
    close l_attribute_value_cur;
       
    log_record(i_text => 'table iss_card_instance_data');
    open l_instance_data_cur for
    select cd.card_instance_id
      from iss_card_instance_data cd
         , iss_card_instance ci
     where ci.split_hash in (select split_hash from com_api_split_map_vw)
       and ci.id = cd.card_instance_id;
    loop
        fetch l_instance_data_cur
         bulk collect into
              l_id_tab
        limit BULK_LIMIT;

        forall i in 1..l_id_tab.count
            update iss_card_instance_data
               set pvv              = null
                 , kcolb_nip        = null
                 , old_pvv          = null
             where card_instance_id = l_id_tab(i);

        log_record('iss_card_instance_data: rowcount='||sql%rowcount);
        exit when l_instance_data_cur%notfound;
    end loop;
    close l_instance_data_cur;

    log_record(i_text =>  'run deperso card has finished');
exception
    when others then
        log_record(i_text => 'run_deperso_card Error: ' || sqlerrm || ' Stack: ' || dbms_utility.format_error_backtrace);

        if l_attribute_value_cur%isopen then
            close l_attribute_value_cur;
        end if;
        if l_instance_data_cur%isopen then
            close l_instance_data_cur;
        end if;
        if l_card_cur%isopen then
            close l_card_cur;
        end if;
        raise;
end;
    
-- RUN SENSIBLE!
procedure run_deperso_data is
    l_fin_addendum_cur        sys_refcursor;
    l_company_cur             sys_refcursor;
    l_linked_card_cur         sys_refcursor;
    l_person_cur              sys_refcursor;
    l_cardholder_cur          sys_refcursor;
    l_id_object_cur           sys_refcursor;
    l_contact_data_cur        sys_refcursor;
    l_word_cur                sys_refcursor;
        
    l_id_tab                  com_api_type_pkg.t_number_tab;
    l_embossed_name_tab       com_api_type_pkg.t_name_tab;
    l_old_cardholder_name_tab com_api_type_pkg.t_name_tab;
    l_cardholder_name_tab     com_api_type_pkg.t_name_tab;
    l_company_name_tab        com_api_type_pkg.t_name_tab;
        
    l_first_name_tab          com_api_type_pkg.t_name_tab;
    l_second_name_tab         com_api_type_pkg.t_name_tab;
    l_surname_tab             com_api_type_pkg.t_name_tab;
    l_birthday_tab            com_api_type_pkg.t_date_tab;
    l_place_of_birth_tab      com_api_type_pkg.t_name_tab;

    l_id_series_tab           com_api_type_pkg.t_name_tab;
    l_id_number_tab           com_api_type_pkg.t_name_tab;
    l_id_issuer_tab           com_api_type_pkg.t_name_tab;
    l_id_issue_date_tab       com_api_type_pkg.t_date_tab;
    l_id_expire_date_tab      com_api_type_pkg.t_date_tab;
        
    l_commun_address_tab      com_api_type_pkg.t_desc_tab;
    l_word_tab                com_api_type_pkg.t_name_tab;
    l_word_hash_tab           com_api_type_pkg.t_number_tab;
        
    l_idx                     number;
begin
    /*
    1 - customers
    2 - person
    3 - company
    4 - objects identities
    5 - addresses
    6 - security words
    7 - contact data
    */
        
    log_record(i_text => 'run deperso data has started.');

    log_record(i_text => 'table com_company');
    open l_company_cur for
    select id
         , embossed_name
      from com_company;
    loop
        fetch l_company_cur
         bulk collect into
              l_id_tab
            , l_embossed_name_tab
        limit BULK_LIMIT;

        for i in 1..l_id_tab.count loop
            l_embossed_name_tab(i) := upper(gen_name(i_length => 200));
        end loop;

        forall i in 1..l_id_tab.count
            update com_company
               set embossed_name = l_embossed_name_tab(i)
             where id            = l_id_tab(i);

        log_record('com_company: rowcount='||sql%rowcount);
        exit when l_company_cur%notfound;
    end loop;
    close l_company_cur;
    commit;

    log_record(i_text => 'table ecm_linked_card');
    open l_linked_card_cur for
    select id
         , cardholder_name
      from ecm_linked_card l
     where not exists (
            select null
              from iss_cardholder c
             where l.cardholder_name = c.cardholder_name
        );
    loop
        fetch l_linked_card_cur
         bulk collect into
              l_id_tab
            , l_cardholder_name_tab
        limit BULK_LIMIT;

        for i in 1..l_id_tab.count loop
            l_cardholder_name_tab(i) := upper(gen_name(i_length => 20)) || ' ' || upper(gen_name(i_length => 200));
        end loop;

        forall i in 1..l_id_tab.count
            update ecm_linked_card
               set cardholder_name = l_cardholder_name_tab(i)
             where id              = l_id_tab(i);

        log_record('ecm_linked_card: rowcount='||sql%rowcount);
        exit when l_linked_card_cur%notfound;
    end loop;
    close l_linked_card_cur;
    commit;

    log_record(i_text => 'table pmo_linked_card');
    open l_linked_card_cur for
    select id
         , cardholder_name
      from pmo_linked_card l
     where not exists (select null from iss_cardholder c where l.cardholder_name = c.cardholder_name
        );
    loop
        fetch l_linked_card_cur
         bulk collect into
              l_id_tab
            , l_cardholder_name_tab
        limit BULK_LIMIT;

        for i in 1..l_id_tab.count loop
            l_cardholder_name_tab(i) := upper(gen_name(i_length => 20)) || ' ' || upper(gen_name(i_length => 200));
        end loop;

        forall i in 1..l_id_tab.count
            update pmo_linked_card
               set cardholder_name = l_cardholder_name_tab(i)
             where id              = l_id_tab(i);
        log_record('pmo_linked_card: rowcount='||sql%rowcount);

        exit when l_linked_card_cur%notfound;
    end loop;
    close l_linked_card_cur;
    commit;

    log_record(i_text => 'table com_person');
    open l_person_cur for
    select id
         , first_name
         , second_name
         , surname
         , birthday
         , place_of_birth
      from com_person;
    loop
        fetch l_person_cur
         bulk collect into
              l_id_tab
            , l_first_name_tab
            , l_second_name_tab
            , l_surname_tab
            , l_birthday_tab
            , l_place_of_birth_tab
        limit BULK_LIMIT;

        for i in 1..l_id_tab.count loop
            l_first_name_tab(i)     := gen_name(i_length => 20);
            l_second_name_tab(i)    := gen_name(i_length => 20);
            l_surname_tab(i)        := gen_name(i_length => 20);
            l_birthday_tab(i)       := gen_date(to_date('01.01.1880', 'dd.mm.yyyy'), trunc(sysdate));
            l_place_of_birth_tab(i) := gen_name(i_length => 200);
        end loop;

        forall i in 1..l_id_tab.count
            update com_person
               set first_name     = l_first_name_tab(i)
                 , second_name    = l_second_name_tab(i)
                 , surname        = l_surname_tab(i)
                 , birthday       = l_birthday_tab(i)
                 , place_of_birth = l_place_of_birth_tab(i)
             where id             = l_id_tab(i);

        log_record('com_person: rowcount='||sql%rowcount);
        forall i in 1..l_id_tab.count
            update iss_cardholder
               set cardholder_name = l_first_name_tab(i) || ' ' || l_second_name_tab(i)
             where person_id       = l_id_tab(i);

        log_record('iss_cardholder: rowcount='||sql%rowcount);
        exit when l_person_cur%notfound;
    end loop;
    close l_person_cur;
    commit;

    log_record(i_text => 'table iss_cardholder');
    open l_cardholder_cur for
    select id
         , cardholder_name
         , cardholder_name
      from iss_cardholder h
     where not exists ( select null from com_person p where p.id = h.person_id);

    loop
        fetch l_cardholder_cur
         bulk collect into
              l_id_tab
            , l_old_cardholder_name_tab
            , l_cardholder_name_tab
        limit BULK_LIMIT;

        for i in 1..l_id_tab.count loop
            l_cardholder_name_tab(i) := gen_name(i_length => 20) || ' ' || gen_name(i_length => 20);
            l_company_name_tab(i)    := gen_name(i_length => 200);
        end loop;

        forall i in 1..l_id_tab.count
            update ecm_linked_card
               set cardholder_name          = l_cardholder_name_tab(i)
             where reverse(cardholder_name) = reverse(l_old_cardholder_name_tab(i));

        log_record('ecm_linked_card: rowcount='||sql%rowcount);
        forall i in 1..l_id_tab.count
            update pmo_linked_card
               set cardholder_name         = l_cardholder_name_tab(i)
             where reverse(cardholder_name) = reverse(l_old_cardholder_name_tab(i));

        log_record('pmo_linked_card: rowcount='||sql%rowcount);
        forall i in 1..l_id_tab.count
            update iss_cardholder
               set cardholder_name = l_cardholder_name_tab(i)
             where id              = l_id_tab(i);

        log_record('iss_cardholder: rowcount='||sql%rowcount);
        forall i in 1..l_id_tab.count
            update iss_card_instance i
               set cardholder_name = l_cardholder_name_tab(i)
                 , company_name    = l_company_name_tab(i)
             where exists (select null 
                             from iss_card c
                            where c.cardholder_id = l_id_tab(i)
                              and c.id            = i.card_id);

        log_record('iss_card_instance: rowcount='||sql%rowcount);
        exit when l_cardholder_cur%notfound;
    end loop;
    close l_cardholder_cur;

    log_record(i_text => 'table com_id_object');
    open l_id_object_cur for
    select id
         , id_series
         , id_number
         , id_issuer
         , id_issue_date
         , id_expire_date
      from com_id_object;

    loop
        fetch l_id_object_cur
         bulk collect into
              l_id_tab
            , l_id_series_tab
            , l_id_number_tab
            , l_id_issuer_tab
            , l_id_issue_date_tab
            , l_id_expire_date_tab
        limit BULK_LIMIT;

        for i in 1..l_id_tab.count loop
            l_id_series_tab(i)      := com_api_type_pkg.pad_number(to_char(gen_number(0, 9999)), 4, 4);
            l_id_number_tab(i)      := com_api_type_pkg.pad_number(to_char(gen_number(0, 999999999999)), 6, 6);
            l_id_issuer_tab(i)      := gen_name(i_length => 60);
            l_id_issue_date_tab(i)  := gen_date(to_date('01.01.1880', 'dd.mm.yyyy'), trunc(sysdate));
            l_id_expire_date_tab(i) := gen_date(l_id_issue_date_tab(i), trunc(sysdate));
        end loop;

        begin
            forall i in 1..l_id_tab.count save exceptions
                update com_id_object
                   set id_series      = l_id_series_tab(i)
                     , id_number      = l_id_number_tab(i)
                     , id_issuer      = l_id_issuer_tab(i)
                     , id_issue_date  = l_id_issue_date_tab(i)
                     , id_expire_date = nvl2(id_expire_date, l_id_expire_date_tab(i), null)
                 where id             = l_id_tab(i);
        exception
            when com_api_error_pkg.e_dml_errors then
                for i in 1..sql%bulk_exceptions.count loop
                    l_idx := sql%bulk_exceptions(i).error_index;

                    l_id_number_tab(l_idx) := l_id_number_tab(i) || '_';

                    update com_id_object
                       set id_series      = l_id_series_tab(l_idx)
                         , id_number      = l_id_number_tab(l_idx)
                         , id_issuer      = l_id_issuer_tab(l_idx)
                         , id_issue_date  = l_id_issue_date_tab(l_idx)
                         , id_expire_date = nvl2(id_expire_date, l_id_expire_date_tab(l_idx), null)
                     where id             = l_id_tab(l_idx);
                end loop;
        end;
        log_record('com_id_object: rowcount='||sql%rowcount);

        exit when l_id_object_cur%notfound;
    end loop;
    close l_id_object_cur;
    commit;

    log_record(i_text => 'table com_address');
    begin
        execute immediate 'drop table com_address_rdf';
    exception
        when others then
            null;
    end;

    execute immediate
    'create table com_address_rdf as
    select id
         , lang
         , dbms_random.string(''a'', trunc(dbms_random.value(0, 30))) region
         , dbms_random.string(''a'', trunc(dbms_random.value(0, 50))) city
         , dbms_random.string(''a'', trunc(dbms_random.value(0, 50))) street
         , dbms_random.string(''a'', trunc(dbms_random.value(0, 10))) house
         , dbms_random.string(''a'', trunc(dbms_random.value(0, 10))) apartment
         , to_char(trunc(dbms_random.value(0, 999999))) postal_code
      from com_address';

    execute immediate 'alter table com_address drop primary key cascade';
    execute immediate 'drop table com_address cascade constraints';
    execute immediate 'alter table com_address_rdf rename to com_address';
    execute immediate 'create index com_address_postal_code_ndx on com_address (postal_code)';
    execute immediate 'create unique index com_address_pk on com_address (id, lang)';
    --execute immediate 'create index com_address_city_street_ndx on com_address (city, street, house)';
    execute immediate 'alter table com_address add (constraint com_address_pk  primary key (id, lang) using index com_address_pk)';
        
    log_record(i_text => 'table com_contact_data');
    open l_contact_data_cur for
    select id
         , commun_address
      from com_contact_data;
    loop
        fetch l_contact_data_cur
         bulk collect into
              l_id_tab
            , l_commun_address_tab
        limit BULK_LIMIT;

        for i in 1..l_id_tab.count loop
            l_commun_address_tab(i) := to_char(gen_number(0, 9999999999));
        end loop;

        forall i in 1..l_id_tab.count
            update com_contact_data
               set commun_address = l_commun_address_tab(i)
             where id             = l_id_tab(i);
        log_record('com_contact_data: rowcount='||sql%rowcount);
        commit;

        exit when l_contact_data_cur%notfound;
    end loop;
    close l_contact_data_cur;
    commit;

    log_record(i_text => 'table sec_word');
    open l_word_cur for
    select question_id
         , word
      from sec_word;

    loop
        fetch l_word_cur
         bulk collect into
              l_id_tab
            , l_word_tab
        limit BULK_LIMIT;

        for i in 1..l_id_tab.count loop
            l_word_tab(i)      := upper(gen_name(200));
            l_word_hash_tab(i) := com_api_hash_pkg.get_string_hash(l_word_tab(i));
        end loop;

        forall i in 1..l_id_tab.count
            update sec_word
               set word        = l_word_tab(i)
             where question_id = l_id_tab(i);
        log_record('sec_word: rowcount='||sql%rowcount);

        forall i in 1..l_id_tab.count
            update sec_question
               set word_hash = l_word_hash_tab(i)
             where id        = l_id_tab(i);
        log_record('sec_question: rowcount='||sql%rowcount);

        exit when l_word_cur%notfound;
    end loop;
    close l_word_cur;
    commit;
        
    log_record(i_text => 'run_deperso_data has finished');
exception
    when others then
        log_record(i_text => 'run_deperso_data Error: ' || sqlerrm || ' Stack: ' || dbms_utility.format_error_backtrace);
            
        if l_word_cur%isopen then
            close l_word_cur;
        end if;
        if l_contact_data_cur%isopen then
            close l_contact_data_cur;
        end if;
        if l_id_object_cur%isopen then
            close l_id_object_cur;
        end if;
        if l_cardholder_cur%isopen then
            close l_cardholder_cur;
        end if;
        if l_person_cur%isopen then
            close l_person_cur;
        end if;
        if l_linked_card_cur%isopen then
            close l_linked_card_cur;
        end if;
        if l_company_cur%isopen then
            close l_company_cur;
        end if;
        if l_fin_addendum_cur%isopen then
            close l_fin_addendum_cur;
        end if;
            
        raise;
end;
    
procedure truncate_table(i_table_name    in     varchar2) is
begin
   execute immediate 'truncate table '||i_table_name;
end;

procedure after_deperso is
begin
    log_record(i_text => 'after_deperso has started');

    log_record(i_text => 'erase vis_fin_message.card_mask and card_hash');
    exec('alter table vis_fin_message drop column card_mask');
    exec('alter table vis_fin_message drop column card_hash');
    exec('alter table vis_fin_message add (card_mask varchar2(24), card_hash number(12))');
                    
    log_record(i_text => 'erase mcw_fin.de002');
    exec('alter table mcw_fin drop column de002');
    exec('alter table mcw_fin add de002 varchar2(19)');
        
    log_record(i_text => 'erase aut_auth.emv_data');
    exec('alter table aut_auth drop column emv_data');
    exec('alter table aut_auth add emv_data varchar2(2000)');
        
    log_record(i_text => 'erase vis_fin_addendum.raw_data');
    exec('alter table vis_fin_addendum drop column raw_data');
    exec('alter table vis_fin_addendum add raw_data varchar2(4000)');
        
    log_record(i_text => 'clear tables');
        
    truncate_table('adt_detail');
    truncate_table('app_data');
    truncate_table('aup_aggt');
    truncate_table('aup_amount');
    truncate_table('aup_atm');
    truncate_table('aup_atm_bna');
    truncate_table('aup_atm_disp');
    truncate_table('aup_chronopay');
    truncate_table('aup_cnpy');
    truncate_table('aup_cyberplat');
    truncate_table('aup_cyberplat_in');
    truncate_table('aup_ekassir');
    truncate_table('aup_epay');
    truncate_table('aup_fimi');
    truncate_table('aup_iso8583bic');
    truncate_table('aup_iso8583bic_tech');
    truncate_table('aup_iso8583cbs');
    truncate_table('aup_iso8583pos');
    truncate_table('aup_iso8583pos_tech');
    truncate_table('aup_limit');
    truncate_table('aup_mastercard');
    truncate_table('aup_mastercard_tech');
    truncate_table('aup_scheme_object');
    truncate_table('aup_spdh');
    truncate_table('aup_sv2sv');
    truncate_table('aup_sv2sv_tech');
    truncate_table('aup_svip');
    truncate_table('aup_tag_value');
    truncate_table('aup_visa_basei');
    truncate_table('aup_visa_basei_tech');
    truncate_table('aup_visa_sms');
    truncate_table('aup_visa_sms_tech');
    truncate_table('aup_way4');
    truncate_table('aup_way4_tech');
    truncate_table('emv_script');
    truncate_table('emv_tag_value');
    truncate_table('frp_auth');
    truncate_table('frp_auth_card');
    truncate_table('mcw_250byte_message');
    truncate_table('mcw_reject_data');
    truncate_table('mup_reject_data');
    truncate_table('net_host_substitution');
    truncate_table('ntf_custom_event');
    truncate_table('ntf_message');
    truncate_table('pmo_order_data');
    truncate_table('prc_file_raw_data');
    truncate_table('sec_des_key');
    truncate_table('sec_hmac_key');
    truncate_table('sec_rsa_key');
    truncate_table('sec_rsa_certificate');
    
       
    -- the last !!
    truncate_table('utl_us_card_number');
    truncate_table('utl_them_card_number');
        
    log_record(i_text => 'after_deperso has finished');
exception
    when others then
        log_record(i_text => 'after_deperso Error: ' || sqlerrm || ' Stack: ' || dbms_utility.format_error_backtrace);
        raise;
end;

end utl_api_deperso_pkg;
/
