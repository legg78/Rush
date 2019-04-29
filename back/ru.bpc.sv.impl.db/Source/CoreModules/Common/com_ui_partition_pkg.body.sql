CREATE OR REPLACE package body com_ui_partition_pkg as
/************************************************************
 * UI for operations with table COM_PARTITION_TABLE <br />
 * Module: com_ui_partition_pkg <br />
 * @headcom
 ************************************************************/

    /**************************************************
    *
    * Register or Modify information about transactional table.
    *
    * @param i_table_name Name of transactional table.
    * @param i_partition_cycle_id Cycle identifier using for calculating partitioning interval.
    * @param i_storage_cycle_id Cycle identifier using for calculating data storage interval.
    * @param i_seqnum Sequential number or record version.
    * @param i_next_partition_date Date when next partition will be created
    *
    ***************************************************/
    procedure register_transactional_table(
        i_table_name          in com_api_type_pkg.t_oracle_name
      , i_partition_cycle_id  in com_api_type_pkg.t_short_id
      , i_storage_cycle_id    in com_api_type_pkg.t_short_id
      , i_seqnum              in com_api_type_pkg.t_tiny_id   default null
      , i_next_partition_date in date default null
    ) is
        l_table_name            com_api_type_pkg.t_short_desc; -- name of table
        l_next_partition_date   date;
        inconsistent_data       exception;
        pragma exception_init(inconsistent_data, -1476); -- division by zero      
              
    begin
        trc_log_pkg.debug(
            i_text => 'register_transactional_table [#1] with partition_cycle_id = [#2] and storage_cycle_id = [#3] seqnum = [#4]'
            , i_env_param1 => i_table_name
            , i_env_param2 => i_partition_cycle_id
            , i_env_param3 => i_storage_cycle_id
            , i_env_param4 => i_seqnum
        );
        
        -- if table not exists in user tables - will rise NDF exception
        begin
            select t.table_name 
              into l_table_name 
              from user_tables t
             where t.table_name = upper(trim(i_table_name));
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error        => 'TABLE_NOT_FOUND'
                    , i_env_param1 => i_table_name
                );
        end;        
        
        if i_next_partition_date is not null then
            -- next partition date must be in future
            if i_next_partition_date < com_api_sttl_day_pkg.get_sysdate then
                com_api_error_pkg.raise_error(
                    i_error => 'INCONSISTENT_DATE'
                );
            end if;
            l_next_partition_date := i_next_partition_date;
        else
            fcl_api_cycle_pkg.calc_next_date(
                i_cycle_id    => i_partition_cycle_id
              , i_start_date  => com_api_sttl_day_pkg.get_sysdate
              , i_forward     => com_api_type_pkg.TRUE
              , o_next_date   => l_next_partition_date
            );
        end if;
        
        begin        
            select cpt.table_name 
              into l_table_name 
              from com_partition_table_vw cpt
             where upper(trim(cpt.table_name)) = upper(trim(i_table_name));

            update com_partition_table_vw 
               set seqnum              = case when seqnum > i_seqnum then 1/0 else nvl(i_seqnum, seqnum + 1) end
                 , partition_cycle_id  = i_partition_cycle_id
                 , storage_cycle_id    = i_storage_cycle_id
                 , next_partition_date = l_next_partition_date
             where upper(trim(table_name)) = upper(trim(i_table_name));  

        exception
            when no_data_found then
            
                insert into com_partition_table_vw (
                    id
                  , seqnum
                  , table_name
                  , partition_cycle_id
                  , storage_cycle_id
                  , next_partition_date
                ) values (
                    com_partition_table_seq.nextval
                  , nvl(i_seqnum, 1)
                  , upper(trim(i_table_name))
                  , i_partition_cycle_id
                  , i_storage_cycle_id
                  , l_next_partition_date
                );
            
            -- if (new seqnum < old seqnum)
            when inconsistent_data then  
                com_api_error_pkg.raise_error(
                    i_error => 'INCONSISTENT_DATA'
                );
            
        end;
        
    end register_transactional_table;

    /**************************************************
    *
    * Delete information about transactional table.
    *
    * @param i_table_name Name of transactional table.
    *
    ***************************************************/
    procedure unregister_transactional_table(
        i_table_name in com_api_type_pkg.t_oracle_name
    ) is
        l_table_name    com_api_type_pkg.t_short_desc; -- name of table
        l_child_exists  com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
        l_count         pls_integer := 0;
    begin
        trc_log_pkg.debug(
            i_text         => 'unregistering transactional table [#1]'
            , i_env_param1 => i_table_name
        );
        
        -- if table not exists - will rise NDF exception
        begin
            select cpt.table_name 
              into l_table_name 
              from com_partition_table_vw cpt
             where upper(trim(cpt.table_name)) = upper(trim(i_table_name));
             
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error        => 'TABLE_NOT_FOUND'
                    , i_env_param1 => i_table_name
                );
        end;
           
        -- looking for child rec
        select count(1)
          into l_count 
          from com_partition c 
         where upper(trim(c.table_name)) = upper(trim(i_table_name));
        
        if l_count > 0 then
            com_api_error_pkg.raise_error(
                i_error       => 'UNABLE_TO_DELETE_COM_TABLE'
                , i_env_param1  => i_table_name
            );
        
        else
            delete 
              from com_partition_table_vw cpt 
             where upper(trim(cpt.table_name)) = upper(trim(i_table_name));
             
        end if;              

    end unregister_transactional_table;

end com_ui_partition_pkg;
/
