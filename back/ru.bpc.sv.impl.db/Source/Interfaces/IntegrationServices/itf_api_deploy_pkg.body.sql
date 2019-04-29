create or replace package body itf_api_deploy_pkg as
/**********************************************************
 * ITF deploy utilites<br/>
 * Created by Alalykin A. (alalykin@bpc.ru) at 22.08.2014<br/>
 * Last changed by $Author: alalykin $<br/>
 * $LastChangedDate: 25.08.2014 $<br/>
 * Revision: $LastChangedRevision: 1 $<br/>
 * Module: ITF_API_DEPLOY_PKG
 * @headcom
 **********************************************************/

DATABASE_LINK          constant com_api_type_pkg.t_oracle_name := 'back';
LOG_UNIT_RPAD          constant com_api_type_pkg.t_count       := 30;
CRLF                   constant com_api_type_pkg.t_oracle_name := chr(13) || chr(10);
LINE_DELIMITER         constant com_api_type_pkg.t_full_desc   := '*********************************';

g_log_unit_stack       com_api_type_pkg.t_oracle_name_tab; -- Stack of procedure/function names for logging output
g_debug_is_enabled     com_api_type_pkg.t_boolean;
g_db_link_user         com_api_type_pkg.t_oracle_name; -- Username of db-link

type t_index_rec is record (
    index_name         all_indexes.index_name%type
  , table_name         all_indexes.table_name%type
  , uniqueness         all_indexes.uniqueness%type
  , tablespace_name    all_indexes.tablespace_name%type
  , column_position    all_ind_columns.column_position%type
  , column_name        all_ind_columns.column_name%type
  , constraint_name    all_constraints.constraint_name%type
  , constraint_type    all_constraints.constraint_type%type
);

type t_index_tab is table of t_index_rec index by pls_integer;

/*
 * Adds unit name for logging to the top of stack <g_log_unit_stack>. 
 */
procedure set_log_unit(
    i_unit_name        in    com_api_type_pkg.t_oracle_name
) is
begin
    g_log_unit_stack(nvl(g_log_unit_stack.last, 0)+1) := i_unit_name;
    --dbms_output.put_line('set_log_unit: i_unit_name [' || i_unit_name ||
    --                     '], g_log_unit_stack.last [' || g_log_unit_stack.last || ']');
end;

function get_log_unit return com_api_type_pkg.t_oracle_name
is
begin
    return case when g_log_unit_stack.count() > 0
                then g_log_unit_stack(g_log_unit_stack.last) 
                else null 
           end;
end; 

/*
 * Removes unit name for logging from the top of stack <g_log_unit_stack>. 
 */
procedure release_log_unit
is
begin
    if g_log_unit_stack.count() > 0 then
        g_log_unit_stack.delete(g_log_unit_stack.last);
    end if;
end;

procedure set_debug(
    i_debug_is_enabled in    com_api_type_pkg.t_boolean
) is
begin
    g_debug_is_enabled := i_debug_is_enabled;
end;

procedure debug(
    i_text             in    com_api_type_pkg.t_text
) is
begin
    if g_debug_is_enabled = com_api_type_pkg.TRUE then
        dbms_output.put_line(rpad(get_log_unit(), LOG_UNIT_RPAD) || ': ' || i_text);
    end if;
end;

procedure info(
    i_text             in    com_api_type_pkg.t_text
) is
begin
    dbms_output.put_line(rpad(get_log_unit(), LOG_UNIT_RPAD) || ': ' || i_text);
end;

procedure log_error(
    i_text             in    com_api_type_pkg.t_text
  , i_sqlerrm          in    com_api_type_pkg.t_full_desc default null -- limited by 512 chars
) is
begin
    dbms_output.put_line(rpad(get_log_unit(), LOG_UNIT_RPAD) || ': FAILED' || CRLF ||
                         case when i_text is not null    then i_text || CRLF else null end || 
                         dbms_utility.format_error_backtrace || dbms_utility.format_error_stack);
end;

function bool_to_char(
    i_bool             in     com_api_type_pkg.t_boolean
) return com_api_type_pkg.t_oracle_name
is
begin
    return case i_bool
               when com_api_type_pkg.TRUE  then 'TRUE'
               when com_api_type_pkg.FALSE then 'FALSE'
                                           else 'UNKNOWN'
           end;
end;

/*
 * Checks db-link status that is defined as package's constant and raise an error if it isn't ready for work,
 * otherwise it returns db-link's user name into global variable.
 */ 
procedure check_db_link_user
is
    e_db_link_doesnt_exist   exception;
    e_db_link_is_not_valid   exception;
    l_status                 dba_objects.status%type;
begin
    set_log_unit('check_db_link');
    dbms_output.put_line(LINE_DELIMITER);
    debug('checking db-link "' || DATABASE_LINK || '"...');

    declare
        l_host                   dba_db_links.host%type;
        l_created                date;
    begin
        select distinct first_value(status) over (order by status desc) -- get status "VALID" if it exists
          into l_status
          from dba_objects
         where object_type = 'DATABASE LINK'
           and upper(object_name) = upper(DATABASE_LINK)
           and upper(owner) in (user, 'PUBLIC');
           
        select t.username
             , t.host
             , t.created
          into g_db_link_user
             , l_host
             , l_created
          from dba_db_links t
         where t.owner in (user, 'PUBLIC')
           and t.db_link = upper(DATABASE_LINK);

        info('DB link found: username [' || g_db_link_user || '], host [' || l_host ||
             '], created at ' || to_char(l_created, com_api_const_pkg.DATE_FORMAT));
    exception
        when no_data_found then
            log_error('DB link ' || DATABASE_LINK || ' doesn''t exist. Halt work.');
            raise e_db_link_doesnt_exist;
    end;
    
    if l_status != 'VALID' then
        log_error('DB link ' || DATABASE_LINK || ' isn''t valid. Halt work.');
        raise e_db_link_is_not_valid;
    end if;
    
    info('Status of DB link is OK. Continue work...');
    release_log_unit();
    
exception
    when e_db_link_doesnt_exist or e_db_link_is_not_valid then
        release_log_unit();
        raise;
    when others then
        log_error(null);
        release_log_unit();
        raise;
end check_db_link_user;

procedure execute_statement(
    i_statement        in    com_api_type_pkg.t_text
) is
begin
    set_log_unit('execute_statement');
    debug(i_statement);
    execute immediate i_statement;
    release_log_unit();
exception
    when others then
        log_error(null);
        release_log_unit();
        raise;
end execute_statement;

/*
 * Returns delimited list of table's fields via db-link, for example: "field1, field2, field3".
 */ 
function get_table_column_list(
    i_table_name       in     com_api_type_pkg.t_oracle_name
) return com_api_type_pkg.t_text
is
    DELIMITER    constant com_api_type_pkg.t_oracle_name := ', ';
    l_text                com_api_type_pkg.t_text;
    l_column_name_tab     com_api_type_pkg.t_oracle_name_tab;
begin
    set_log_unit('get_table_column_list');
    debug('START with i_table_name [' || i_table_name || ']');

    l_text :=
        'select lower(column_name) as column_name' ||
         ' from all_tab_columns@'||DATABASE_LINK ||
        ' where upper(owner) = ''' || upper(g_db_link_user) || '''' ||
          ' and upper(table_name) = upper(:i_table_name)' ||
     ' order by column_id';
    debug('query [' || l_text || ']'); 

    execute immediate l_text        
    bulk collect into l_column_name_tab
    using i_table_name;

    debug('l_column_name_tab.count() = ' || l_column_name_tab.count());

    l_text := null;
    for i in l_column_name_tab.first .. l_column_name_tab.last loop
        l_text := l_text || DELIMITER || l_column_name_tab(i);
    end loop;
    
    debug('END');
    release_log_unit();

    return substr(l_text, length(DELIMITER)+1);

exception
    when others then
        release_log_unit();
        raise;
end get_table_column_list;

/*
 * It checks tablespace by its name and returns clause for using in some DDL-query (e.g. ' tablespace USER_TABLESPACE_NAME')
 * if the tablespace is valid, otherwise NULL is returned, so clause will be ignored in a DDL-query.
 */
function get_tablespace_clause(
    i_tablespace       in     com_api_type_pkg.t_oracle_name
) return com_api_type_pkg.t_name
is
    l_tablespace_clause       com_api_type_pkg.t_name;
begin
    set_log_unit('get_tablespace_clause');
    --debug('START with i_tablespace [' || i_tablespace || ']');

    begin
        select ' tablespace ' || lower(tablespace_name)
          into l_tablespace_clause
          from user_tablespaces
         where upper(tablespace_name) = upper(i_tablespace)
           and status = 'ONLINE';
    exception
        when no_data_found then
            info('tablespace [' || i_tablespace || '] is not FOUND or is not online, so default user''s tablespace will be used');
    end;
    
    --debug('END');
    release_log_unit();

    return l_tablespace_clause;
    
exception
    when others then
        release_log_unit();
        raise; 
end;

/*
 * Returns a column expression for an index as far it is stored as LONG value.
 */ 
function get_index_column_expression(
    i_index_owner      in     com_api_type_pkg.t_oracle_name
  , i_index_name       in     com_api_type_pkg.t_oracle_name
  , i_column_position  in     number
) return com_api_type_pkg.t_full_desc
is
    l_column_expression       long;
begin
    select t.column_expression
      into l_column_expression
      from dba_ind_expressions t
     where t.index_owner     = i_index_owner
       and t.index_name      = i_index_name 
       and t.column_position = i_column_position;
        
    return substr(l_column_expression, 1, 2000); -- Consider that column expression can not exceed 2000 symbols
end get_index_column_expression;


function indexes_are_equal(
    i_index_rec1       in     t_index_rec
  , i_index_rec2       in     t_index_rec
) return com_api_type_pkg.t_boolean
is
begin
    return case when i_index_rec1.index_name       = i_index_rec2.index_name
                 and i_index_rec1.table_name       = i_index_rec2.table_name
                 and i_index_rec1.uniqueness       = i_index_rec2.uniqueness
                 --and i_index_rec1.tablespace_name  = i_index_rec2.tablespace_name -- tablespaces could be different...
                 and i_index_rec1.column_position  = i_index_rec2.column_position
                 and i_index_rec1.column_name      = i_index_rec2.column_name
                 and nvl(i_index_rec1.constraint_name, '~')  = nvl(i_index_rec2.constraint_name, '~')
                 and nvl(i_index_rec1.constraint_type, '~')  = nvl(i_index_rec2.constraint_type, '~')
                then com_api_type_pkg.TRUE 
                else com_api_type_pkg.FALSE
           end;
end indexes_are_equal;

/*
 * Function returns collection with indexes' data by incoming table or materialized view name
 */
function get_index_data(
    i_name             in     com_api_type_pkg.t_oracle_name
  , i_db_link          in     com_api_type_pkg.t_oracle_name    default null
) return t_index_tab
is
    l_index_tab               t_index_tab;
    l_link_suffix             com_api_type_pkg.t_oracle_name;
    l_user                    com_api_type_pkg.t_oracle_name;
begin
    set_log_unit('get_index_data');
    debug('START with i_name [' || i_name || '], i_db_link [' || i_db_link || ']');

    if i_db_link is null then
        l_link_suffix := null;
        l_user        := '''' || user || '''';
    else
        l_link_suffix := '@'||i_db_link;
        l_user        := '''' || upper(g_db_link_user) || '''';
    end if;
    debug('l_user [' || l_user || ']');

    execute immediate
       'select i.index_name
             , i.table_name
             , i.uniqueness
             , i.tablespace_name
             , ic.column_position
             , case when upper(ic.column_name) not like ''SYS%'' 
                    then ic.column_name
                    else itf_api_deploy_pkg.get_index_column_expression'||l_link_suffix||'( -- retrive string of LONG data type
                             i_index_owner     => ic.index_owner
                           , i_index_name      => ic.index_name
                           , i_column_position => ic.column_position
                         ) 
               end as column_name
             , c.constraint_name
             , c.constraint_type
          from all_indexes'||l_link_suffix || ' i
          join all_ind_columns'||l_link_suffix || ' ic
              on ic.index_owner = i.owner
             and ic.index_name  = i.index_name
             and ic.table_name  = i.table_name
          left join all_constraints'||l_link_suffix || ' c
              on c.owner        = i.owner
             and c.index_name   = i.index_name
             and c.table_name   = i.table_name
             and c.constraint_type in (''P'', ''U'') -- searching only for primary and unique keys
         where upper(i.owner) = ' || l_user || '
           and upper(i.table_owner) = upper(i.owner)
           and upper(i.table_name)  = upper(:i_owner_name)
      order by i.table_name
             , i.uniqueness desc nulls last
             , c.constraint_type nulls last
             , i.index_name
             , ic.column_position'
    bulk collect into l_index_tab
    using i_name;
    
    debug('l_index_tab.count() = ' || l_index_tab.count());
    debug('END');
    release_log_unit();    

    return l_index_tab;

exception
    when others then
        release_log_unit();
        raise;
end get_index_data;

/*
 * Procedure recreates table's indexes for a new materialized view.
 * @param i_index_tab    – collection of indexes that should be created (copied) for the new mat. view i_mview_name
 */
procedure create_indexes(
    i_mview_name       in     com_api_type_pkg.t_oracle_name
  , i_index_tab        in     t_index_tab
) is
    l_column_list             com_api_type_pkg.t_text;
    i                         pls_integer;
    
    procedure create_index(
        i_index_rec        in     t_index_rec
      , i_mview            in     com_api_type_pkg.t_oracle_name               
      , i_column_list      in     com_api_type_pkg.t_text
    ) is
    begin
        set_log_unit('create_index');
        debug('START for index ' || i_index_rec.index_name || ' (' || i_index_rec.uniqueness || 
              '), constraint type (' || i_index_rec.constraint_type || 
              '), column_list [' || i_column_list || ']');

        execute_statement('create ' || case when i_index_rec.uniqueness = 'UNIQUE' then lower(i_index_rec.uniqueness)||' ' else null end ||
                          'index '  || i_index_rec.index_name || ' on ' || i_mview ||
                          '(' || i_column_list || ')' || 
                          get_tablespace_clause(i_index_rec.tablespace_name));
        -- Recreation of primary or unique key  
        if i_index_rec.constraint_name is not null then
            execute_statement('alter materialized view ' || i_mview || 
                              ' add (constraint ' || i_index_rec.constraint_name || ' ' ||
                              case when i_index_rec.constraint_type = 'P' then 'primary key' else 'unique' end ||  
                              ' (' || i_column_list || ') using index ' || i_index_rec.index_name || ' enable validate)');
        end if;
        
        debug('END');
        release_log_unit();

    exception
        when others then
            release_log_unit();
            raise;
    end create_index;
    
begin
    set_log_unit('create_indexes');
    debug('START with i_mview_name [' || i_mview_name || '], i_index_tab.count() = ' || i_index_tab.count());

    if i_index_tab.count() > 0 then
        l_column_list := i_index_tab(i_index_tab.first).column_name;

        i := i_index_tab.next(i_index_tab.first);
        while i <= i_index_tab.last loop
            if i_index_tab(i).column_position = 1 then
                -- 1st column of a NEW index has been fetched, we need to replace index with a new one for mat. view
                create_index(
                    i_index_rec   => i_index_tab(i_index_tab.prior(i))
                  , i_mview       => i_mview_name
                  , i_column_list => l_column_list
                );
                l_column_list := i_index_tab(i).column_name;
            else
                l_column_list := l_column_list || ', ' || i_index_tab(i).column_name;
            end if;
            debug('i [' || i || '], column_position [' || i_index_tab(i).column_position || '], l_column_list [' || l_column_list || ']' );
            i := i_index_tab.next(i);
        end loop;
        
        if l_column_list is not null then
            create_index(
                i_index_rec   => i_index_tab(i_index_tab.last)
              , i_mview       => i_mview_name
              , i_column_list => l_column_list
            );
        end if;
    end if;
    
    debug('END');
    release_log_unit();
exception
    when others then
        log_error(
            i_sqlerrm => sqlerrm
          , i_text    => 'l_column_list [' || l_column_list || ']'
        );
        release_log_unit();
        raise;
end create_indexes;

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
) is

    l_skip_mview_creation     com_api_type_pkg.t_boolean;
    l_mview_index_tab         t_index_tab;
    l_table_index_tab         t_index_tab;

    -- Check all indexes and unique keys of the mat. view as compared with the original table at the db-link's site
    function index_tab_are_identical(
        i_mview_index_tab  in t_index_tab 
      , i_table_index_tab  in t_index_tab
    ) return com_api_type_pkg.t_boolean
    is
        l_result                  com_api_type_pkg.t_boolean;
        i                         pls_integer; 
    begin
        set_log_unit('index_tab_are_identical');

        if i_mview_index_tab.count() != i_table_index_tab.count() then
            debug('Index collections differ by count of indexes [' || i_mview_index_tab.count()
                                                        || ' and ' || i_table_index_tab.count() || ']');
            l_result := com_api_type_pkg.FALSE;
        else
            debug('Index collections contain the same count of indexes, comparison of the elements...');
            l_result := com_api_type_pkg.TRUE;
            i := i_mview_index_tab.first;
            while i <= i_mview_index_tab.last and l_result = com_api_type_pkg.TRUE loop
                l_result := indexes_are_equal(i_mview_index_tab(i), i_table_index_tab(i));
                debug('i [' || i || '], l_result [' || bool_to_char(l_result) || ']');
                i := i_mview_index_tab.next(i);
            end loop;
        end if;
        
        release_log_unit();
        return l_result;

    exception
        when others then
            release_log_unit();
            raise;
    end index_tab_are_identical;    

    -- It creates mat. view by table on db-link's site, original table should be deleted  
    procedure create_a_mat_view(
        i_name             in     com_api_type_pkg.t_oracle_name
      , i_tablespace       in     com_api_type_pkg.t_oracle_name
      , i_refresh          in     com_api_type_pkg.t_name
    ) is
        l_statement               com_api_type_pkg.t_text;
    begin
        l_statement := 'select ' || get_table_column_list(i_name) || ' from ' || i_name||'@'||DATABASE_LINK;
        -- All table's indexes are recreated for a new materialized view explicitly after its creating
        l_statement := 'create materialized view ' || i_name
                    || get_tablespace_clause(i_tablespace) 
                    || ' using no index ' || i_refresh || ' with primary key'
                    || ' as ' || l_statement;
                   
        -- Creating new materialized view as replacement for table
        execute_statement(l_statement);
    exception
        when others then
            set_log_unit('create_a_mat_view');
            info('FAILED with l_statement [' || l_statement || ']');
            release_log_unit();
            raise;
    end create_a_mat_view;
    
begin
    check_db_link_user();
    
    set_log_unit('create_mat_views');
    set_debug(i_debug_is_enabled => i_detail_logging);
    --debug('START with i_refresh_clause [' || i_refresh_clause || '], i_detail_logging [' || i_detail_logging || ']');
    info('START with i_force_recreating [' || bool_to_char(i_force_recreating) || '], i_refresh_clause [' || i_refresh_clause || ']');

    -- Look through all tables in UTL_TABLES that should be replaced with mat. views
    -- with additional information about which tables really exists and which are already replaced with mat. views 
    for r in (
        select ut.table_name as table_name
             , ut.synch_group
             , ut.tablespace_name
             , t.table_name as table_name_real
             , m.mview_name as mview_name -- ut.table_name is already replaced 
          from utl_table ut
          left join all_tables t  on upper(t.table_name) = upper(ut.table_name)
                                 and t.owner = user
                                 and t.iot_type is null -- don't process index-organized tables
          left join all_mviews m  on upper(m.mview_name) = upper(ut.table_name)
                                 and m.owner = user
         where ut.synch_group is not null
      order by ut.synch_group
             , ut.table_name
    ) loop
        dbms_output.put_line(LINE_DELIMITER);
        info('Processing table [' || r.table_name || '], tablespace [' || r.tablespace_name || '], synch_group [' || r.synch_group
                                  ||  '], existing table [' || r.table_name_real || '], existing mat. view [' || r.mview_name || ']');
        
        if r.table_name_real is null then
            info('Table DOESN''T exist');
        elsif r.mview_name is null then -- if mat. view exists then r.table_name_real = r.mview_name, but there is no the table in real 
            info('Table exists, drop it...');
            execute_statement('drop table ' || r.table_name_real);
        else
            info('Mat. view exists, check or drop it...'); 
        end if;

        l_table_index_tab     := get_index_data(r.table_name, DATABASE_LINK); -- indexes of source table on db-link site
        l_skip_mview_creation := com_api_type_pkg.FALSE;

        if r.mview_name is not null then
            if i_force_recreating = com_api_type_pkg.TRUE then
                info('Drop mat. view [forced]...');
                execute_statement('drop materialized view ' || r.mview_name);
            else
                l_mview_index_tab := get_index_data(r.mview_name);
                l_skip_mview_creation := index_tab_are_identical(
                                             i_mview_index_tab => l_mview_index_tab
                                           , i_table_index_tab => l_table_index_tab
                                         );
                if l_skip_mview_creation = com_api_type_pkg.TRUE then
                    info('Mat. view is correct, SKIP of recreating is due to flag i_force_recreating');
                else
                    info('Mat. view is NOT correct and will be recreated');
                    execute_statement('drop materialized view ' || r.mview_name);
                end if;
            end if;
        end if;
        
        if l_skip_mview_creation = com_api_type_pkg.FALSE then
            -- (Re)create mat. view if it is missed, or incorrect, or flag <i_force_recreating> is set to true 
            create_a_mat_view(
                i_name        => r.table_name
              , i_tablespace  => r.tablespace_name
              , i_refresh     => i_refresh_clause
            );
            -- Coping all table's indexes (with primary and unique keys) for a new materialized view
            create_indexes(
                i_mview_name => r.table_name
              , i_index_tab  => l_table_index_tab
            );
        end if;
    end loop;
    dbms_output.put_line(LINE_DELIMITER);
    
    --execute_statement('alter package utl_deploy_pkg compile package');  
    --utl_deploy_pkg.recompile_invalid_packages();
    
    debug('END');
    release_log_unit();
end create_mat_views;

/*
 * Procedure creates materialized view logs for all tables in UTL_TABLE with non-empty <synch_group> field with the same names.
 * Db-link isn't used.
 * All existing mat. view logs are recreated.
 * @param i_detail_logging    – if it is set to TRUE then all DDL-queries will be logged
 */
procedure create_mat_view_logs(
    i_detail_logging   in     com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
) is
begin
    set_log_unit('create_mat_view_logs');
    set_debug(i_debug_is_enabled => i_detail_logging);
    info('START');

    -- Look through all existing(!) tables that should be replaced by materialized views
    for r in (
        select ut.table_name as table_name
             , ut.tablespace_name
             , ut.synch_group
             , (select com_api_type_pkg.TRUE 
                  from all_constraints c
                 where c.owner           = t.owner
                   and c.table_name      = t.table_name
                   and c.constraint_type = 'P' -- primary key
               ) as primary_key_exists
             , m.log_table as mview_log -- mat. view log already exists
          from utl_table ut
          join all_tables t           on upper(t.table_name) = upper(ut.table_name)
          left join all_mview_logs m  on upper(m.master) = upper(ut.table_name)
                                     and m.log_owner = t.owner
         where ut.synch_group is not null
           and t.owner = user
           and t.iot_type is null -- don't process index-organized tables
      order by ut.synch_group
             , ut.table_name
    ) loop
        dbms_output.put_line(LINE_DELIMITER);
        info('Processing table [' || r.table_name || '], tablespace [' || r.tablespace_name 
                                  || '], synch_group [' || r.synch_group || '], existing mat. view log [' || r.mview_log || ']');
        
        if r.mview_log is not null then
            info('Drop mat. view log to recreate it again...');
            execute_statement('drop materialized view log on ' || r.table_name);
        end if;

        execute_statement('create materialized view log on ' || r.table_name || 
                          get_tablespace_clause(r.tablespace_name) || 
                          ' with rowid' || 
                          case when r.primary_key_exists = com_api_type_pkg.TRUE then ', primary key' else null end);
    end loop;
    
    dbms_output.put_line(LINE_DELIMITER);
    info('END');
    release_log_unit();
end create_mat_view_logs;


begin
    dbms_output.put_line('Initializing package ' || lower($$PLSQL_UNIT) || '...');
    g_debug_is_enabled := com_api_type_pkg.TRUE;
    dbms_output.enable(buffer_size => null);
    check_db_link_user();
    dbms_output.put_line('Initialization completed');
end;
/
