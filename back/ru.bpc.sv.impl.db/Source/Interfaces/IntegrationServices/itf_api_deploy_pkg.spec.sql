create or replace package itf_api_deploy_pkg as
/**********************************************************
 * ITF deploy utilites<br/>
 * Created by Alalykin A. (alalykin@bpc.ru) at 22.08.2014<br/>
 * Last changed by $Author: alalykin $<br/>
 * $LastChangedDate: 22.08.2014 $<br/>
 * Revision: $LastChangedRevision: 1 $<br/>
 * Module: ITF_API_DEPLOY_PKG
 * @headcom
 **********************************************************/

MV_REFRESH_CLAUSE      constant com_api_type_pkg.t_name := 'refresh force on demand';

/*
 * Returns a column expression for an index as far it is stored as LONG value.
 */ 
function get_index_column_expression(
    i_index_owner      in     com_api_type_pkg.t_oracle_name
  , i_index_name       in     com_api_type_pkg.t_oracle_name
  , i_column_position  in     number
) return com_api_type_pkg.t_full_desc;

/*
 * Procedure creates materialized views for all tables in UTL_TABLE with non-empty <synch_group> field with the same names.
 * Tables' column lists, indexes and unique keys are copied from tables with the same names on db-link's site(!).
 * Existing tables in user's scheme are removed.
 * @param i_refresh_clause    – refresh clause is used for creating materialized views
 * @param i_detail_logging    – if it is set to TRUE then all DDL-queries will be logged
 * @param i_force_recreating  – if it is set to TRUE then all created earlier mat. views will be recreated,
 *     otherwise they will be recreated only if their indexes differ from original tables' indexes on db-link's site 
 */
procedure create_mat_views(
    i_refresh_clause   in     com_api_type_pkg.t_name    default MV_REFRESH_CLAUSE
  , i_detail_logging   in     com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
  , i_force_recreating in     com_api_type_pkg.t_boolean default com_api_type_pkg.FALSE
);

/*
 * Procedure creates materialized view logs for all tables in UTL_TABLE with non-empty <synch_group> field with the same names.
 * Db-link isn't used.
 * All existing mat. view logs are recreated.
 * @param i_detail_logging    – if it is set to TRUE then all DDL-queries will be logged
 */
procedure create_mat_view_logs(
    i_detail_logging   in     com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
);

end;
/