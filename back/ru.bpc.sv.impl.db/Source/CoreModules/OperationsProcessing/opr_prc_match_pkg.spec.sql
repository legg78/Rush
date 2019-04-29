create or replace package opr_prc_match_pkg is

    /**
    *   Insert match data in tables for presentments and authorizations with temporary storage data.
    *   @param i_inst_id - Institution identifier
    *   @param i_depth_presentment - depth of the search for presentment (in days)
    *   @param i_depth_authorization - depth of the search for authorization (in days)
    */
    procedure insert_match_data (
        i_inst_id               in com_api_type_pkg.t_inst_id
      , i_depth_presentment     in com_api_type_pkg.t_tiny_id default null
      , i_depth_authorization   in com_api_type_pkg.t_tiny_id default null
    );

    /**
    *   Process matching
    *   @param i_inst_id - Institution identifier
    */
    procedure process_match (
        i_inst_id               in com_api_type_pkg.t_inst_id
    );

    /**
    *   Process matching (obsolete)
    *   @param i_inst_id - Institution identifier
    *   @param i_depth_presentment - depth of the search for presentment (in days)
    *   @param i_depth_authorization - depth of the search for authorization (in days)
    */
    procedure process_match_obsolete (
        i_inst_id               in com_api_type_pkg.t_inst_id
      , i_depth_presentment     in com_api_type_pkg.t_tiny_id default null
      , i_depth_authorization   in com_api_type_pkg.t_tiny_id default null
    );

    procedure process_mark_expired (
        i_inst_id               in com_api_type_pkg.t_inst_id
    );
    
end opr_prc_match_pkg;
/
