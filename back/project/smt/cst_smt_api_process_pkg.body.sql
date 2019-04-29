create or replace package body cst_smt_api_process_pkg is
/************************************************************
 * API for various processing SMT <br />
 * Created by Gogolev I.(i.gogolev@bpcbt.com)  at 25.12.2018 <br />
 * Last changed by $Author: Gogolev I. $ <br />
 * $LastChangedDate:: #$ <br />
 * Revision: $LastChangedRevision:  $ <br />
 * Module: cst_smt_api_process_pkg <br />
 * @headcom
 ***********************************************************/
procedure insert_into_msstrxn_map(
    i_input_file_name     in  com_api_type_pkg.t_name
  , i_original_file_name  in  com_api_type_pkg.t_name
  , i_load_date           in  date
  , i_msstrxn_map_tab     in  cst_smt_api_type_pkg.t_msstrxn_map_field_tab
) is
    LOG_PREFIX            constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.insert_into_msstrxn_map: ';
    l_total               com_api_type_pkg.t_long_id := 0;
begin
    if i_msstrxn_map_tab.count > 0 then
        forall i in i_msstrxn_map_tab.first .. i_msstrxn_map_tab.last
            insert into cst_smt_msstrxn_map_tmp(
                id
              , input_file_name
              , original_file_name
              , load_date
              , card_number
              , oper_amount
              , iss_auth_code
              , host_date
              , external_auth_id
            )
            values(
                cst_smt_msstrxn_map_tmp_seq.nextval
              , i_input_file_name
              , i_original_file_name
              , i_load_date
              , i_msstrxn_map_tab(i).card_number
              , i_msstrxn_map_tab(i).oper_amount
              , i_msstrxn_map_tab(i).iss_auth_code
              , to_date(i_msstrxn_map_tab(i).trans_date||substr(i_msstrxn_map_tab(i).trans_time, 1, 6), cst_smt_api_const_pkg.MSSTRXN_DATE||cst_smt_api_const_pkg.MSSTRXN_TIME_TRANSFORM)
              , i_msstrxn_map_tab(i).external_auth_id
            );
        l_total := sql%rowcount;
    end if;
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || ' results for input file [#1] original file [#2] load date [#3] - total count [#4]' 
      , i_env_param1 => i_input_file_name
      , i_env_param2 => i_original_file_name
      , i_env_param3 => i_load_date
      , i_env_param4 => l_total
    );
end insert_into_msstrxn_map;

procedure delete_msstrxn_map(
    i_input_file_name     in  com_api_type_pkg.t_name
  , i_load_date           in  date
  , i_id_tab              in  com_api_type_pkg.t_number_tab
) is
    LOG_PREFIX            constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.delete_msstrxn_map: ';
    
    l_count               com_api_type_pkg.t_long_id;
    l_total               com_api_type_pkg.t_long_id;
    l_ind                 com_api_type_pkg.t_long_id := 1;
    l_id_tab              num_tab_tpt := num_tab_tpt();
begin
    select count(*)
      into l_count
      from cst_smt_msstrxn_map_tmp t
     where t.input_file_name = i_input_file_name
       and t.load_date       = i_load_date;
    
    l_total := i_id_tab.count;
    while l_total > 0 and l_ind is not null
    loop
        if i_id_tab(l_ind) is not null then
           l_id_tab.extend;
           l_id_tab(l_id_tab.last) := i_id_tab(l_ind);
        end if;
        l_ind := i_id_tab.next(l_ind);
        l_total := l_total - 1;
    end loop;
     
    if l_id_tab.count > 0 then
        forall i in l_id_tab.first .. l_id_tab.last
            delete from cst_smt_msstrxn_map_tmp
             where id = l_id_tab(i);
        l_total := sql%rowcount;
    end if;
    
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || ' results for input file [#1] load date [#2] - total count [#3], deleted count [#4]' 
      , i_env_param1 => i_input_file_name
      , i_env_param2 => i_load_date
      , i_env_param3 => l_count
      , i_env_param4 => l_total
    );
    
end delete_msstrxn_map;

end cst_smt_api_process_pkg;
/
