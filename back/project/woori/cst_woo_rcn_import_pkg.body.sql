create or replace package body cst_woo_rcn_import_pkg is

procedure import_file_50 is  

    C_COLLECTION_SIZE com_api_type_pkg.t_short_id default 1000;

    cursor cu_records_count(ci_session_id in com_api_type_pkg.t_long_id) is
        select count(1) - 1
          from prc_file_raw_data a
             , prc_session_file b
         where b.id = ci_session_id
           and a.session_file_id = b.id;

    l_rec_balance       cst_woo_api_type_pkg.t_rec_balance;
    l_tab_balance       cst_woo_api_type_pkg.t_tab_balance;

    l_session_id        prc_session_file.id%type;

    l_total_per_session com_api_type_pkg.t_long_id default 0;
    l_total_per_file    com_api_type_pkg.t_long_id default 0;
    l_excepted_count    com_api_type_pkg.t_long_id default 0;


    procedure process_row(
        i_row in     com_api_type_pkg.t_raw_data
      , o_rec    out cst_woo_api_type_pkg.t_rec_balance
    ) is

        l_field_end com_api_type_pkg.t_tiny_id   default 1;
        l_field_num com_api_type_pkg.t_tiny_id   default 1;
        l_field_val com_api_type_pkg.t_text      default null;
        l_separator com_api_type_pkg.t_byte_char default '|';
        l_row       com_api_type_pkg.t_raw_data  default i_row;

    begin
        if substr(l_row, 1, 1) = l_separator then
            l_row := substr(l_row, 2);
        end if;

        while length(l_row) > 0 loop
            l_field_end := instr(l_row, l_separator, 1);
            l_field_val := substr(l_row, 1, l_field_end - 1);
            l_row := substr(l_row, l_field_end + 1);

            case l_field_num
            when 3 then
                o_rec.aggregation_date := to_date(l_field_val, 'yyyymmdd');
            when 6 then
                o_rec.agent_number := l_field_val;
            when 8 then
                o_rec.account_number := l_field_val;
            when 10 then
                o_rec.currency := l_field_val;
            when 12 then
                o_rec.amount := l_field_val;
            else
              null;
            end case;

            o_rec.status := cst_woo_const_pkg.GL_RCN_STATUS_IMPORTED; --'RCST0001'

            l_field_val := null;
            l_field_num := l_field_num + 1;
        end loop;

    exception
    when others then
        raise;
    end process_row;


    procedure collect_row(i_rec in cst_woo_api_type_pkg.t_rec_balance)
    is
    begin
        l_tab_balance(l_tab_balance.count + 1) := i_rec;
        l_rec_balance := null;
    end collect_row;

    procedure insert_collection is
    begin
        trc_log_pkg.debug (
            i_text       => 'Going to import [#1] rec(s)'
          , i_env_param1 => l_tab_balance.count
        );

        forall i in 1..l_tab_balance.count
        insert into cst_woo_rcn_gl_balance_temp values l_tab_balance(i);

        l_tab_balance.delete;
    exception
    when others then
        raise;
    end insert_collection;

begin --main
    prc_api_stat_pkg.log_start;

    select max(id) keep (dense_rank first order by file_name desc)
      into l_session_id
      from prc_session_file
     where session_id = prc_api_session_pkg.get_session_id;

    open cu_records_count(l_session_id);
    fetch cu_records_count into l_total_per_session;
    close cu_records_count;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_total_per_session
    );

    if l_total_per_session > 0 then

        l_total_per_session := 0;

        for cur_file in (
            select f.id session_file_id
              from prc_session_file f
             where f.id = l_session_id
        ) loop begin
            savepoint import_file;

            l_total_per_file := 0;
            l_excepted_count := 0;

            for cur_row in (
                select record_number
                     , raw_data
                  from prc_file_raw_data
                 where session_file_id = cur_file.session_file_id
                 order by record_number
            ) loop begin

                if substr(cur_row.raw_data, 1, 6) = 'HEADER' then
                    continue;
                end if;

                process_row(cur_row.raw_data, l_rec_balance);
                collect_row(l_rec_balance);            

                l_total_per_session := l_total_per_session + 1;
                l_total_per_file := l_total_per_file + 1;

                if mod(l_tab_balance.count, C_COLLECTION_SIZE) = 0 then
                    insert_collection;

                    prc_api_stat_pkg.log_current(
                        i_current_count  => l_total_per_session
                      , i_excepted_count => l_excepted_count
                    );
                end if;

            exception
            when others then            
                l_excepted_count := l_excepted_count + 1;

                if mod(l_excepted_count, 10) = 0 then
                    prc_api_stat_pkg.log_current(
                        i_current_count  => l_total_per_session
                      , i_excepted_count => l_excepted_count
                    );
                end if;

    --            raise;
            end;
            end loop; --row

            insert_collection;

            prc_api_file_pkg.close_file(
                i_sess_file_id => cur_file.session_file_id
              , i_status       => prc_api_const_pkg.FILE_STATUS_ACCEPTED
            );

        exception
        when others then
            prc_api_file_pkg.close_file(
                i_sess_file_id => cur_file.session_file_id
              , i_status       => prc_api_const_pkg.FILE_STATUS_REJECTED
            );

            rollback to import_file;
            raise;
        end;
        end loop; --file

    end if; --estimation > 0

exception
when others then
    raise;
end import_file_50;

end cst_woo_rcn_import_pkg;
/
