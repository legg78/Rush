create or replace package body adt_api_trail_pkg as
/*********************************************************
 *  Audit trail API  <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 30.07.2009 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: adt_api_trail_pkg <br />
 *  @headcom
 **********************************************************/

CRLF               constant com_api_type_pkg.t_name := chr(13) || chr(10); 

function get_trail_id return com_api_type_pkg.t_long_id is
    l_result                com_api_type_pkg.t_long_id;
begin
    l_result := com_api_id_pkg.get_id(adt_trail_seq.nextval, get_sysdate);

    return l_result;
end;

function get_detail_id return com_api_type_pkg.t_long_id is
    l_result                com_api_type_pkg.t_long_id;
begin
    l_result := com_api_id_pkg.get_id(adt_detail_seq.nextval, get_sysdate);

    return l_result;
end;
    
procedure put_audit_trail(
    i_trail_id              in      com_api_type_pkg.t_long_id
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_action_type           in      com_api_type_pkg.t_dict_value
  , i_priv_id               in      com_api_type_pkg.t_short_id       default null
  , i_session_id            in      com_api_type_pkg.t_long_id        default null
  , i_status                in      com_api_type_pkg.t_dict_value     default null
) is
begin
    merge into adt_trail dest
    using (
        select
            i_trail_id                      as id
          , i_entity_type                   as entity_type
          , i_object_id                     as object_id
          , i_action_type                   as action_type
          , systimestamp                    as action_time
          , com_ui_user_env_pkg.get_user_id as user_id
          , i_priv_id                       as priv_id
          , i_session_id                    as session_id
          , i_status                        as status
        from dual
    ) src
    on (dest.id = src.id)
    when matched then update set
        dest.entity_type = nvl(src.entity_type, dest.entity_type)
      , dest.object_id   = nvl(src.object_id  , dest.object_id  )
      , dest.action_type = nvl(src.action_type, dest.action_type)
      , dest.action_time = nvl(src.action_time, dest.action_time)
      , dest.user_id     = nvl(src.user_id    , dest.user_id    )
      , dest.priv_id     = nvl(src.priv_id    , dest.priv_id    )
      , dest.session_id  = coalesce(nvl(src.session_id , dest.session_id), get_session_id)
      , dest.status      = nvl(src.status     , dest.status     )
    when not matched then insert (
        dest.id
      , dest.entity_type
      , dest.object_id
      , dest.action_type
      , dest.action_time
      , dest.user_id
      , dest.priv_id
      , dest.session_id
      , dest.status
    ) values (
        src.id
      , src.entity_type
      , src.object_id
      , src.action_type
      , src.action_time
      , src.user_id
      , src.priv_id
      , coalesce(src.session_id, get_session_id)
      , src.status
    );

    g_trail_id := i_trail_id;
end;

procedure add_audit_trail(
    i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_action_type           in      com_api_type_pkg.t_dict_value
  , i_user_id               in      com_api_type_pkg.t_short_id
  , i_priv_id               in      com_api_type_pkg.t_short_id       default null
  , i_session_id            in      com_api_type_pkg.t_long_id        default null
  , i_status                in      com_api_type_pkg.t_dict_value     default null
)
as
    l_trail_id     com_api_type_pkg.t_long_id;
begin
    l_trail_id := adt_api_trail_pkg.get_trail_id;
    insert into adt_trail(
        id
      , entity_type
      , object_id
      , action_type
      , action_time
      , user_id
      , priv_id
      , session_id
      , status
    ) values (
        l_trail_id
      , i_entity_type
      , i_object_id
      , i_action_type
      , systimestamp
      , i_user_id
      , i_priv_id
      , i_session_id
      , i_status
    );
end;

procedure check_value(
    i_trail_id              in      com_api_type_pkg.t_long_id
  , i_column_name           in      com_api_type_pkg.t_oracle_name
  , i_data_type             in      com_api_type_pkg.t_dict_value
  , i_old_value_v           in      varchar2             default null
  , i_new_value_v           in      varchar2             default null
  , i_old_value_n           in      number               default null
  , i_new_value_n           in      number               default null
  , i_old_value_d           in      date                 default null
  , i_new_value_d           in      date                 default null
  , i_data_format           in      com_api_type_pkg.t_dict_value default null
  , i_old_value_clob        in      clob                 default null
  , i_new_value_clob        in      clob                 default null
  , io_changed_count        in out  pls_integer
) is
    l_old_value         com_api_type_pkg.t_text;
    l_new_value         com_api_type_pkg.t_text;
    l_data_type         com_api_type_pkg.t_dict_value := i_data_type;
    l_old_value_clob    clob := i_old_value_clob;
    l_new_value_clob    clob := i_new_value_clob;
begin

    if l_data_type in (com_api_const_pkg.DATA_TYPE_CHAR, com_api_const_pkg.DATA_TYPE_CLOB) then
        l_old_value := i_old_value_v;
        l_new_value := i_new_value_v;
    elsif l_data_type = com_api_const_pkg.DATA_TYPE_NUMBER then
        l_old_value := to_char(i_old_value_n, com_api_const_pkg.NUMBER_FORMAT);
        l_new_value := to_char(i_new_value_n, com_api_const_pkg.NUMBER_FORMAT);
    elsif l_data_type = com_api_const_pkg.DATA_TYPE_DATE then
        l_old_value := to_char(i_old_value_d, com_api_const_pkg.DATE_FORMAT);
        l_new_value := to_char(i_new_value_d, com_api_const_pkg.DATE_FORMAT);
    end if;
    
    if l_data_type = com_api_const_pkg.DATA_TYPE_CHAR and  
       (length(l_old_value) > 200 or length(l_new_value) > 200)
    then
        l_data_type := com_api_const_pkg.DATA_TYPE_CLOB;
        l_old_value_clob := to_clob(l_old_value);
        l_new_value_clob := to_clob(l_new_value);
        l_old_value := null;
        l_new_value := 'saved as CLOB';
    end if;

    if  (l_old_value is null and l_new_value is not null) or
        (l_old_value is not null and l_new_value is null) or
        (l_old_value != l_new_value)
    then
        insert into adt_detail(
            id
          , trail_id
          , column_name
          , data_type
          , data_format
          , old_value
          , new_value
          , old_clob_value
          , new_clob_value
        ) values (
            adt_api_trail_pkg.get_detail_id
          , i_trail_id
          , i_column_name
          , l_data_type
          , decode(l_data_type
                 , com_api_const_pkg.DATA_TYPE_NUMBER, com_api_const_pkg.NUMBER_FORMAT
                 , com_api_const_pkg.DATA_TYPE_DATE, com_api_const_pkg.DATE_FORMAT
                 , i_data_format)
          , l_old_value
          , l_new_value
          , l_old_value_clob
          , l_new_value_clob
        );
        io_changed_count := nvl(io_changed_count, 0) + 1;
    end if;
end;

procedure modify_com_18n(
    i_trail_id              in      com_api_type_pkg.t_long_id
  , i_table_name            in      com_api_type_pkg.t_oracle_name
  , i_column_name           in      com_api_type_pkg.t_oracle_name
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_old_value             in      com_api_type_pkg.t_text
  , i_new_value             in      com_api_type_pkg.t_text
  , i_action_type           in      com_api_type_pkg.t_dict_value   
  , i_lang                  in      com_api_type_pkg.t_dict_value   
) is
    l_table_name            com_api_type_pkg.t_oracle_name;
    l_object_id             com_api_type_pkg.t_long_id;
    l_action_type           com_api_type_pkg.t_dict_value;   
    l_changed_count         pls_integer;
begin
    select e.table_name
         , t.object_id
         , t.action_type
      into l_table_name  
         , l_object_id 
         , l_action_type 
      from adt_trail t
         , adt_entity e
     where t.id = i_trail_id
       and t.entity_type = e.entity_type;
       
    if upper(l_table_name) != upper(i_table_name) 
        or l_object_id     != i_object_id 
        or l_action_type   != i_action_type 
        or i_old_value     =  i_new_value then
        null;
    else
        check_value(
            i_trail_id          => i_trail_id
          , i_column_name       => i_column_name
          , i_data_type         => com_api_const_pkg.DATA_TYPE_CHAR--i_lang
          , i_old_value_v       => i_old_value
          , i_new_value_v       => i_new_value
          , i_data_format       => i_lang
          , io_changed_count    => l_changed_count
        );            
    end if;    
exception when others then
    null;    
end;

procedure check_value(
    i_trail_id              in      com_api_type_pkg.t_long_id
  , i_column_name           in      com_api_type_pkg.t_oracle_name
  , i_old_value             in      com_api_type_pkg.t_name
  , i_new_value             in      com_api_type_pkg.t_name
  , io_changed_count        in out  pls_integer
) is
begin
    check_value(
        i_trail_id          => i_trail_id
      , i_column_name       => i_column_name
      , i_data_type         => com_api_const_pkg.DATA_TYPE_CHAR
      , i_old_value_v       => i_old_value
      , i_new_value_v       => i_new_value
      , io_changed_count    => io_changed_count
    );
end;

procedure check_value(
    i_trail_id              in      com_api_type_pkg.t_long_id
  , i_column_name           in      com_api_type_pkg.t_oracle_name
  , i_old_value             in      number
  , i_new_value             in      number
  , io_changed_count        in out  pls_integer
) is
begin
    check_value(
        i_trail_id          => i_trail_id
      , i_column_name       => i_column_name
      , i_data_type         => com_api_const_pkg.DATA_TYPE_NUMBER
      , i_old_value_n       => i_old_value
      , i_new_value_n       => i_new_value
      , io_changed_count    => io_changed_count
    );
end;

procedure check_value(
    i_trail_id              in      com_api_type_pkg.t_long_id
  , i_column_name           in      com_api_type_pkg.t_oracle_name
  , i_old_value             in      date
  , i_new_value             in      date
  , io_changed_count        in out  pls_integer
) is
begin
    check_value(
        i_trail_id          => i_trail_id
      , i_column_name       => i_column_name
      , i_data_type         => com_api_const_pkg.DATA_TYPE_DATE
      , i_old_value_d       => i_old_value
      , i_new_value_d       => i_new_value
      , io_changed_count    => io_changed_count
    );
end;

procedure get_diff_line(
    i_old                   in            clob
  , i_new                   in            clob
  , io_old_d                in out nocopy clob
  , io_new_d                in out nocopy clob
) is
    NEXT_LINE    constant char := chr(10); -- LF symbol

    l_curpos_o   integer := 1;
    l_curpos_n   integer := 1;
    l_str_index  integer;

    l_line_old   clob;
    l_line_new   clob;

    procedure get_subclob( 
        i_source        in             clob
      , io_dest         in out nocopy  clob
      , i_offset        in             integer
      , i_amount        in             integer
    ) is
        MAXVARCHAR2     constant number := 20000;
        l_temp_str      com_api_type_pkg.t_lob_data;
        l_offset        integer := i_offset;
        l_amount        integer := i_amount;
    begin
        if i_amount > MAXVARCHAR2 then
            
            l_amount := MAXVARCHAR2;
            loop
                l_temp_str := dbms_lob.substr(i_source, l_amount, l_offset);
                dbms_lob.writeappend(io_dest, length(l_temp_str), l_temp_str);
                exit when dbms_lob.getlength(io_dest) >= i_amount;
        
                l_offset := l_offset + l_amount;
                if l_offset + MAXVARCHAR2 > i_offset + i_amount then
                    l_amount := i_amount - (l_offset - i_offset);
                else
                    l_amount := MAXVARCHAR2;
                end if;
            end loop;
        else
            l_temp_str := dbms_lob.substr(i_source, i_amount, i_offset);
            if length(l_temp_str) > 0 then
                dbms_lob.writeappend(io_dest, length(l_temp_str), l_temp_str);
            end if;
        end if; 
    end;

    function get_line(
        i_clob          in            clob
      , io_pos          in out        integer
    ) return clob
    is
        l_clob          clob;
        l_next_pos      integer;
        l_last_line     com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
    begin
        dbms_lob.createtemporary(l_clob, TRUE);
             
        l_next_pos := dbms_lob.instr(i_clob, NEXT_LINE, io_pos);

        if l_next_pos is null or l_next_pos = 0 then
            -- Last or single line in a clob-string
            l_next_pos := dbms_lob.getlength(i_clob);
            l_last_line := com_api_type_pkg.TRUE;
        end if;

        get_subclob(
            i_source => i_clob
          , io_dest  => l_clob
          , i_offset => io_pos
          , i_amount => l_next_pos - io_pos + 1
        );
        io_pos := l_next_pos + 1;

        -- If lengths of old and new CLOBs are different then adding LF symbol to
        -- end of last line of shortest one allows to avoid situation when lines
        -- of old and new CLOBs differ only with LF symbol.
        -- For example, an old CLOB contains 1 line "foo" and a new CLOB contains
        -- the same line and "bar" in the 2nd line. It is logical that a differnce
        -- between old and new CLOBs should contain only 2nd line "bar", but it will
        -- contain both of lines because an old CLOB's "foo" is not equal to a new
        -- CLOB's "foo"+LF.
        if  l_last_line = com_api_type_pkg.TRUE and dbms_lob.getlength(l_clob) > 0 then
            dbms_lob.append(l_clob, NEXT_LINE);
        end if;

        return l_clob;
    end;
    
    procedure append_clob(
        i_source        in             clob
      , io_dest         in out nocopy  clob
      , i_str_index     in             integer
    ) is
        l_str_prefix    com_api_type_pkg.t_name;
    begin
        if dbms_lob.getlength(i_source) > 0 then
            l_str_prefix := to_char(i_str_index) || ': ';
            dbms_lob.writeappend(io_dest, length(l_str_prefix), l_str_prefix);
            dbms_lob.append(io_dest, i_source);
        end if;
    end;

begin
    l_str_index := 0;
    loop
        l_line_old := get_line(i_old, l_curpos_o);
        l_line_new := get_line(i_new, l_curpos_n);
              
        exit when dbms_lob.getlength(l_line_old) = 0
              and dbms_lob.getlength(l_line_new) = 0;

        l_str_index := l_str_index + 1;

        if dbms_lob.compare(l_line_old, l_line_new) != 0 then
            append_clob(
                i_source    => l_line_old
              , io_dest     => io_old_d
              , i_str_index => l_str_index
            );
            append_clob(
                i_source    => l_line_new
              , io_dest     => io_new_d
              , i_str_index => l_str_index
            );
        end if;
    end loop;
exception
    when others then
        trc_log_pkg.debug(
            i_text       => lower($$PLSQL_UNIT) || '.get_diff_line FAILED;' || CRLF
                         || 'i_old:' || CRLF || dbms_lob.substr(i_old, 1900) || CRLF
                         || 'i_new:' || CRLF || dbms_lob.substr(i_new, 1900)
        );
        trc_log_pkg.debug(
            i_text       => lower($$PLSQL_UNIT) || '.get_diff_line FAILED; '
                         || 'l_str_index [#1], l_curpos_o [#2], l_curpos_n [#3];' || CRLF
                         || 'l_line_old:' || CRLF
                         || dbms_lob.substr(l_line_old, 1900) || CRLF
                         || 'l_line_new:' || CRLF
                         || dbms_lob.substr(l_line_new, 1900)
          , i_env_param1 => l_str_index
          , i_env_param2 => l_curpos_o
          , i_env_param3 => l_curpos_n
        );
        raise;
end get_diff_line;
 
procedure check_value(
    i_trail_id              in      com_api_type_pkg.t_long_id
  , i_column_name           in      com_api_type_pkg.t_oracle_name
  , i_old_value             in      clob
  , i_new_value             in      clob
  , io_changed_count        in out  pls_integer
) is
    l_compare               pls_integer; 
    l_old_diff              clob;
    l_new_diff              clob;     
begin
    l_compare := dbms_lob.compare(nvl(i_old_value, 'Null'), nvl(i_new_value, 'Null'));
    
    if l_compare <> 0 and l_compare is not null then
        
        dbms_lob.createtemporary(l_old_diff, true);
        dbms_lob.createtemporary(l_new_diff, true);
        
        get_diff_line(i_old     => i_old_value
                    , i_new     => i_new_value
                    , io_old_d  => l_old_diff
                    , io_new_d  => l_new_diff);
                
        check_value(
            i_trail_id          => i_trail_id
          , i_column_name       => i_column_name
          , i_data_type         => com_api_const_pkg.DATA_TYPE_CLOB
          , i_old_value_v       => null
          , i_new_value_v       => 'CLOB changed' 
          , i_old_value_clob    => l_old_diff
          , i_new_value_clob    => l_new_diff
          , io_changed_count    => io_changed_count
        );
    end if;
end;

procedure check_value(
    i_trail_id              in      com_api_type_pkg.t_long_id
  , i_column_name           in      com_api_type_pkg.t_oracle_name
  , i_old_value             in      timestamp
  , i_new_value             in      timestamp
  , io_changed_count        in out  pls_integer
) is
begin
    check_value(
        i_trail_id          => i_trail_id
      , i_column_name       => i_column_name
      , i_data_type         => com_api_const_pkg.DATA_TYPE_DATE
      , i_old_value_d       => cast(i_old_value as date)
      , i_new_value_d       => cast(i_new_value as date)
      , io_changed_count    => io_changed_count
    );
end;

end;
/
