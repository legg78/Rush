create or replace package com_ui_partition_pkg as
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
    );

    /**************************************************
    *
    * Delete information about transactional table.
    *
    * @param i_table_name Name of transactional table.
    *
    ***************************************************/
    procedure unregister_transactional_table(
        i_table_name         in com_api_type_pkg.t_oracle_name
    );

end com_ui_partition_pkg;
/
