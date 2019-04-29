create or replace package body com_prc_partition_pkg as
/************************************************************
*  Maintenance of partitioning. <br />
*  Created by Filimonov A.(filimonov@bpc.ru) at 30.03.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: COM_PRC_PARTITION_PKG <br />
*  @headcom
*************************************************************/

CRLF                  constant com_api_type_pkg.t_oracle_name := chr(13) || chr(10);
LOG_DATE_FORMAT       constant com_api_type_pkg.t_oracle_name := 'dd.mm.yyyy';

/*
 * Procedure creates a new partition for table <i_table_name>.
 * @param i_part_table_id    - PK value for com_partition_table,
 *     it would be useless if the table has UK for table_name column;
 * @param i_table_name       - name of a processing table
 * @param i_start_date       - start date for a new partition
 * @param i_end_date         - end date, it is start date for %maxvalue partition
 */
procedure create_partition(
    i_part_table_id     in     com_api_type_pkg.t_tiny_id
  , i_table_name        in     com_api_type_pkg.t_oracle_name
  , i_partition_prefix  in     com_api_type_pkg.t_oracle_name
  , i_start_date        in     date
  , i_end_date          in     date
  , i_drop_date         in     date
  , o_partition_name       out com_api_type_pkg.t_oracle_name
) is
    LOG_PREFIX constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.create_partition: ';
    l_split_id          com_api_type_pkg.t_long_id;
    l_partition_name    com_api_type_pkg.t_oracle_name;
    l_partition_max     com_api_type_pkg.t_oracle_name;
    l_script            com_api_type_pkg.t_text; -- dynamic script text
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'START for table [#1][#2], '
                     || 'i_start_date [#3], i_end_date [#4], i_drop_date [#5]'
      , i_env_param1 => i_part_table_id
      , i_env_param2 => i_table_name
      , i_env_param3 => to_char(i_start_date, LOG_DATE_FORMAT)
      , i_env_param4 => to_char(i_end_date,   LOG_DATE_FORMAT)
      , i_env_param5 => to_char(i_drop_date,  LOG_DATE_FORMAT)
    );

    l_partition_max  := i_partition_prefix || '_maxvalue';
    l_partition_name := i_partition_prefix || to_char(i_end_date, '"_"YYYYMMDD');
    -- new upper bound for splitting partition = ID (date // 0000000000),
    -- current last partition split on -> [upper_bound ; MAXVALUE(id)]
    l_split_id := to_number(to_char(i_end_date, 'YYMMDD"0000000000"'));

    trc_log_pkg.debug(
        i_text       => 'l_partition_name [' || l_partition_name
                     || '], l_split_id [' || l_split_id
                     || '], l_partition_max [' || l_partition_max || ']'
    );
    begin
        savepoint prc_partitions;

        -- create new partition record
        insert into com_partition(
            id
          , table_name
          , partition_name
          , start_date
          , end_date
          , drop_date
        ) values (
            com_partition_seq.nextval
          , i_table_name
          , l_partition_name
          , i_start_date
          , i_end_date -- new partition-creating date
          , i_drop_date
        );
        -- set next processing date (new/next date of creating a partition)
        update com_partition_table cpt
           set cpt.next_partition_date = i_end_date
         where cpt.id = i_part_table_id;
        -- core split partition action(!)
        l_script := 'alter table ' || i_table_name
                 || ' split partition ' || l_partition_max || ' at (' || l_split_id || ') '
                 || ' into (partition ' || l_partition_name || ', partition ' || l_partition_max || ') update indexes';
        execute immediate l_script;

        o_partition_name := l_partition_name;

        trc_log_pkg.debug(
            i_text       => 'Partition [#1] successfully created'
          , i_env_param1 => l_partition_name
        );
    exception
        when others then
            rollback to prc_partitions;

            trc_log_pkg.error(
                i_text       => 'Creating partition [#2] FAILED; l_script [#3]:' || CRLF || '#1'
              , i_env_param1 => dbms_utility.format_error_backtrace||dbms_utility.format_error_stack
              , i_env_param2 => l_partition_name
              , i_env_param3 => l_script
            );
    end;
    trc_log_pkg.debug(LOG_PREFIX || 'FINISH');
end create_partition;

/*
 * Procedure drops expired partitions for table <i_table_name>.
 */
procedure drop_old_partitions(
    i_table_name        in     com_api_type_pkg.t_oracle_name
  , i_drop_date         in     date
) is
    LOG_PREFIX constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.drop_old_partitions: ';
    l_script            com_api_type_pkg.t_text; -- dynamic script text
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'START with i_table_name [#1], i_drop_date [#2]'
      , i_env_param1 => i_table_name
      , i_env_param2 => to_char(i_drop_date, LOG_DATE_FORMAT)
    );
    for p in (
        select cp.id
             , cp.partition_name
          from com_partition cp
         where cp.table_name = i_table_name
           and cp.drop_date <= i_drop_date
    ) loop
        begin
            -- core split partition action(!)
            l_script := 'alter table ' || i_table_name || ' drop partition ' || p.partition_name || ' update indexes';
            execute immediate l_script;

            trc_log_pkg.debug('Dropping partition [' || p.partition_name || '] completed');

            -- if physical dropping is successful then clear the record from the table
            delete from com_partition cp where cp.id = p.id;
        exception
            when others then
                trc_log_pkg.error(
                    i_text       => 'Dropping partition [#2] FAILED; l_script [#3]:' || CRLF || '#1'
                  , i_env_param1 => dbms_utility.format_error_backtrace||dbms_utility.format_error_stack
                  , i_env_param2 => p.partition_name
                  , i_env_param3 => l_script
                );
        end;
    end loop;
    trc_log_pkg.debug(LOG_PREFIX || 'FINISH');
end drop_old_partitions;

/*
 * Procedure for rebuilding all broken indexes after creating partitions.
 */
procedure rebuild_indexes
is
    LOG_PREFIX constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.rebuild_indexes: ';
    l_script            com_api_type_pkg.t_text; -- dynamic script text
begin
    trc_log_pkg.debug(LOG_PREFIX || 'START');

    for i in (
        select ui.table_name
             , ui.index_name
          from user_indexes ui
         where ui.table_name in (select cpt.table_name from com_partition_table cpt)
           and ui.status not in ('VALID', 'N/A')
      order by ui.table_name
             , ui.index_name
    ) loop
        begin
            l_script := 'alter index ' || i.index_name || ' rebuild';
            execute immediate l_script;

            trc_log_pkg.debug (
                i_text       => 'Rebuilding index [#1] on table [#2] completed'
              , i_env_param1 => i.index_name
              , i_env_param2 => i.table_name
            );
        exception
            when others then
                trc_log_pkg.error (
                    i_text       => 'Rebuilding index [#2] on table [#3] FAILED; l_script [#4]:' || CRLF || '#1'
                  , i_env_param1 => dbms_utility.format_error_backtrace||dbms_utility.format_error_stack
                  , i_env_param2 => i.index_name
                  , i_env_param3 => i.table_name
                  , i_env_param4 => l_script
                );
        end;
    end loop;

    trc_log_pkg.debug(LOG_PREFIX || 'FINISH');
end rebuild_indexes;


/*
 * Procedure modifies table partition's statistics by setting a specific value
 * for number of rows; statistics of local indexes' partitions are modified
 * proportionally.
 * @param i_table_name       - name of a processing table
 * @param i_partition_name   - name of a partition that statistics is modified
 * @param i_rows             - specific value for number of rows in a partition
 */
procedure set_partition_stats(
    i_table_name        in     com_api_type_pkg.t_oracle_name
  , i_partition_name    in     com_api_type_pkg.t_oracle_name
  , i_rows              in     com_api_type_pkg.t_medium_id
) is
    l_prev_partition    com_api_type_pkg.t_oracle_name;
    l_coefficient       number;

    /*
     * Function returns previous partition with non-zero number of rows toward
     * specified partition, it it doesn't exist then function returns null.
     */
    function get_previous_partition(
        i_table_name        in     com_api_type_pkg.t_oracle_name
      , i_partition_name    in     com_api_type_pkg.t_oracle_name
    ) return com_api_type_pkg.t_oracle_name
    is
        l_prev_partition    com_api_type_pkg.t_oracle_name;
    begin
        begin
            select distinct
                   first_value(p.partition_name) over (order by p.partition_position desc)
              into l_prev_partition
              from user_tab_partitions p
             where p.table_name = upper(i_table_name)
               and p.partition_position < (select lp.partition_position
                                             from user_tab_partitions lp
                                            where lp.table_name = upper(i_table_name)
                                              and lp.partition_name = upper(i_partition_name))
               and p.num_rows > 0;

            trc_log_pkg.debug('Previous partition with non-zero number of rows is [' || l_prev_partition || ']');
        exception
            when no_data_found then
                trc_log_pkg.debug('There is no previous partition with non-zero number of rows');
        end;
        return l_prev_partition;
    end get_previous_partition;

    /*
     * Procedure modifies table partition's statistics by setting a specific value for number of rows.
     * @param i_table_name       - name of a processing table
     * @param i_curr_partition   - name of a partition that statistics is modified
     * @param i_prev_partition   - name of a partition that statistics is used
     *     to get some additional statistics parameter
     * @param i_rows             - specific value for number of rows in a partition
     * @param o_coefficient      - calculated as i_rows / num_rows_of_prev_partition,
     *     it is used for changing statistics of local indexes' partitions.
     */
    procedure set_table_partition_stats(
        i_table_name        in     com_api_type_pkg.t_oracle_name
      , i_curr_partition    in     com_api_type_pkg.t_oracle_name
      , i_prev_partition    in     com_api_type_pkg.t_oracle_name
      , i_rows              in     com_api_type_pkg.t_medium_id
      , o_coefficient          out number
    ) is
        LOG_PREFIX constant com_api_type_pkg.t_name :=
            lower($$PLSQL_UNIT) || '.set_table_partition_stats: ';
        l_num_rows          number;
        l_blocks            number;
        l_avg_row_length    number;
    begin
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'START for partition [' || i_curr_partition
                   || '] of table [' || i_table_name || ']'
        );
        if i_prev_partition is not null then
            dbms_stats.get_table_stats(
                ownname   => null
              , tabname   => i_table_name
              , partname  => i_prev_partition
              , stattab   => null
              , numrows   => l_num_rows
              , numblks   => l_blocks
              , avgrlen   => l_avg_row_length
            );
        end if;

        -- Set all parameters proportionally except numrows (i_rows)
        o_coefficient :=
            case
                when nvl(l_num_rows, 0) > 0 then i_rows / l_num_rows
                                            else 1
            end;

        trc_log_pkg.debug(
            i_text => 'Using stats of previous partition [' || i_prev_partition
                   || '], o_coefficient [' || round(o_coefficient, 4) || ']'
                   || '; l_num_rows [' || l_num_rows
                   || '], l_blocks [' || l_blocks
                   || '], l_avg_row_length [' || l_avg_row_length || ']'
        );
        -- If stats data for previous partition is null then let
        -- all parameters except numrows = i_rows be empty.
        dbms_stats.set_table_stats(
            ownname   => null
          , tabname   => i_table_name
          , partname  => i_curr_partition
          , stattab   => null
          , numrows   => i_rows
          , numblks   => round(o_coefficient * l_blocks)
          , avgrlen   => l_avg_row_length
        );
        trc_log_pkg.debug(LOG_PREFIX || 'FINISH');
    end set_table_partition_stats;

    /*
     * Procedure modifies statistics of local indexes' partitions,
     * it uses stats parameters of previous partition either without changes
     * or multiplied by a factor of <i_coefficient>.
     * @param i_curr_partition   - name of a partition that statistics is modified
     * @param i_prev_partition   - name of a partition that statistics is used
     *     to get some additional statistics parameter
     * @param i_coefficient      - multiple factor for some stats parameters
     */
    procedure set_index_partition_stats(
        i_curr_partition    in     com_api_type_pkg.t_oracle_name
      , i_prev_partition    in     com_api_type_pkg.t_oracle_name
      , i_coefficient       in     number
    ) is
        LOG_PREFIX        constant com_api_type_pkg.t_name :=
            lower($$PLSQL_UNIT) || '.set_index_partition_stats: ';
        l_num_rows                 number;
        l_leaf_blocks              number;
        l_num_dist_keys            number;
        l_avg_leaf_blocks_per_key  number;
        l_avg_data_blocks_per_key  number;
        l_clustering_factor        number;
        l_index_level              number;
    begin
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'START for partition [' || i_curr_partition
                   || '], i_prev_partition [' || i_prev_partition
                   || '], i_coefficient [' || round(i_coefficient, 4) || ']'
        );
        for i in (
            select *
              from user_ind_partitions ip
             where ip.partition_name = upper(i_curr_partition)
        ) loop
            begin
                trc_log_pkg.debug('Processing index [' || i.index_name || ']');

                if i_prev_partition is not null then
                    dbms_stats.get_index_stats(
                        ownname  => null
                      , indname  => i.index_name
                      , partname => i_prev_partition
                      , numrows  => l_num_rows
                      , numlblks => l_leaf_blocks
                      , numdist  => l_num_dist_keys
                      , avglblk  => l_avg_leaf_blocks_per_key
                      , avgdblk  => l_avg_data_blocks_per_key
                      , clstfct  => l_clustering_factor
                      , indlevel => l_index_level
                    );
                end if;
                -- Not all statistics parameters of index should be modified
                -- in proportion to the parameter <numrows> is modified, some
                -- of them are non-sensitive to modifying number of rows
                dbms_stats.set_index_stats(
                    ownname  => null
                  , indname  => i.index_name
                  , partname => i.partition_name
                  , numrows  => round(i_coefficient * l_num_rows)
                  , numlblks => round(i_coefficient * l_leaf_blocks)
                  , numdist  => round(i_coefficient * l_num_dist_keys)
                  , avglblk  => l_avg_leaf_blocks_per_key
                  , avgdblk  => l_avg_data_blocks_per_key
                  , clstfct  => round(i_coefficient * l_clustering_factor)
                  , indlevel => l_index_level
                );
            exception
                when others then
                    trc_log_pkg.warn(
                        i_text       => 'WARNING: ' || sqlerrm || ':' || CRLF || '#1'
                      , i_env_param1 => dbms_utility.format_error_backtrace
                                     || dbms_utility.format_error_stack
                    );
            end;
        end loop;
        trc_log_pkg.debug(LOG_PREFIX || 'FINISH');
    end set_index_partition_stats;

begin -- set_partition_stats
    if nvl(i_rows, 0) > 0 and i_partition_name is not null then
        -- We use only one value with number of rows for setting partition's statistcs
        -- manually, but we should also describe some other parameters.
        -- Is seems the most reasonable to get them from a previous partition.
        l_prev_partition := get_previous_partition(
                                i_table_name     => i_table_name
                              , i_partition_name => i_partition_name
                            );
        -- Set statistics for a new table partition manually
        set_table_partition_stats(
            i_table_name     => i_table_name
          , i_curr_partition => i_partition_name
          , i_prev_partition => l_prev_partition
          , i_rows           => i_rows
          , o_coefficient    => l_coefficient
        );
        -- And the same way we should set statistics for all local indexes' partitions
        set_index_partition_stats(
            i_curr_partition => i_partition_name
          , i_prev_partition => l_prev_partition
          , i_coefficient    => l_coefficient
        );
    end if;
end set_partition_stats;

/*
 * Process for creatng new partitions and dropping expired ones.
 * @param i_rows    - it is used for manually setting statistics
 *     for a new partition, if parameter is specified then it
 *     should be used to define a number of rows in a new partition
 */
procedure process(
    i_rows              in     com_api_type_pkg.t_medium_id    default null
) is
    l_sysdate           date;
    l_end_date          date;
    l_drop_date         date;
    l_record_count      com_api_type_pkg.t_count := 0;
    l_new_partition     com_api_type_pkg.t_oracle_name;
begin
    prc_api_stat_pkg.log_start;
    -- look one day ahead for creating/dropping partitions
    l_sysdate := com_api_sttl_day_pkg.get_sysdate() + 1;

    trc_log_pkg.debug (
        i_text       => 'com_prc_partition_pkg.process STARTED, session_id [#1], eff_date [#2]'
      , i_env_param1 => get_session_id
      , i_env_param2 => to_char(l_sysdate, LOG_DATE_FORMAT)
    );

    for rec in (
        select cpt.id
             , upt.table_name
             , substr(utp.partition_name, 1, instr(utp.partition_name, '_MAXVALUE') - 1) as partition_prefix
             , cpt.partition_cycle_id
             , cpt.storage_cycle_id
             , trunc(cpt.next_partition_date) as next_partition_date
             , count(*) over () as total_cnt
          from com_partition_table cpt
             , user_part_tables upt
             , user_tab_partitions utp
         where upt.table_name = upper(cpt.table_name)
           and upt.partitioning_key_count = 1 -- paranoiac-style checking
           and utp.table_name = upper(cpt.table_name)
           and utp.partition_name like '%_MAXVALUE'
           and cpt.next_partition_date <= l_sysdate
           --and cpt.table_name = 'TMP_TEST' -- for debugging
      order by trunc(cpt.next_partition_date)
             , upt.table_name
    ) loop
        trc_log_pkg.debug('Processing table [' || rec.id || '][' || rec.table_name || ']');

        if l_record_count = 0 then
            prc_api_stat_pkg.log_estimation (
                i_estimated_count => rec.total_cnt
            );
        end if;
        l_record_count := l_record_count + 1;

        -- calculating end date for a new partition (new partition's UPPER-bound)
        fcl_api_cycle_pkg.calc_next_date(
            i_cycle_id       => rec.partition_cycle_id
          , i_start_date     => rec.next_partition_date
          , i_forward        => com_api_const_pkg.TRUE
          , o_next_date      => l_end_date
        );
        -- calculating DROP (expired) date for a new partition
        fcl_api_cycle_pkg.calc_next_date(
            i_cycle_id       => rec.storage_cycle_id
          , i_start_date     => l_end_date
          , i_forward        => com_api_const_pkg.TRUE
          , o_next_date      => l_drop_date
        );
        trc_log_pkg.debug(
            i_text           => 'storage_cycle_id [#1], '
                             || 'partition_end_date [#2], partition_drop_date [#3]'
          , i_env_param1     => rec.storage_cycle_id
          , i_env_param2     => to_char(l_end_date, LOG_DATE_FORMAT)
          , i_env_param3     => to_char(l_drop_date, LOG_DATE_FORMAT)
        );

        create_partition(
            i_part_table_id     => rec.id
          , i_table_name        => rec.table_name
          , i_partition_prefix  => rec.partition_prefix
          , i_start_date        => rec.next_partition_date
          , i_end_date          => l_end_date
          , i_drop_date         => l_drop_date
          , o_partition_name    => l_new_partition
        );

        set_partition_stats(
            i_table_name     => rec.table_name
          , i_partition_name => l_new_partition
          , i_rows           => i_rows
        );

        drop_old_partitions(
            i_table_name     => rec.table_name
          , i_drop_date      => l_sysdate
        );

        prc_api_stat_pkg.log_current (
            i_current_count  => l_record_count
          , i_excepted_count => 0
        );
    end loop;

    rebuild_indexes();

    -- finish
    prc_api_stat_pkg.log_end (
        i_processed_total => l_record_count
      , i_excepted_total  => 0
      , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    trc_log_pkg.debug (
        i_text => 'com_prc_partition_pkg.process FINISHED'
    );
exception
    when others then
        rebuild_indexes();

        prc_api_stat_pkg.log_end (
            i_result_code => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        trc_log_pkg.error (
            i_text       => 'com_prc_partition_pkg.process FAILED:' || CRLF || '#1'
          , i_env_param1 => dbms_utility.format_error_backtrace||dbms_utility.format_error_stack
        );
end process;

end;
/
