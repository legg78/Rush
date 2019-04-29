create or replace package body com_api_id_pkg is

/********************************************************* 
 *  Common api for IDs and doubles checking  <br /> 
 *  Created by Khougaev A. (khougaev@bpcbt.com)  at 31.05.2010 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: com_api_id_pkg <br /> 
 *  @headcom 
 **********************************************************/ 

g_date      date;
g_from_id   com_api_type_pkg.t_long_id;
 
function get_from_id(
    i_date   in      date                               default null
) return com_api_type_pkg.t_long_id is
    l_date          date;
begin

    l_date := trunc(nvl(i_date, com_api_sttl_day_pkg.get_sysdate));
    
    if l_date != g_date or g_date is null then
        g_from_id := (to_number(to_char(l_date, 'yymmdd')) * 10000000000);
        g_date := l_date;
    end if;

    return  g_from_id;
end;

function get_id (
    i_seq           in      com_api_type_pkg.t_long_id
  , i_object_id     in      com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_long_id is
begin
    return  get_from_id(i_object_id) + i_seq;
end;

function get_till_id(
    i_date   in      date                               default null
) return com_api_type_pkg.t_long_id is
begin
    return  get_from_id(i_date) + 9999999999;
end;

function get_from_id(
    i_object_id     in      com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_long_id is
begin
    return floor(i_object_id/10000000000)*10000000000;
end;

function get_till_id(
    i_object_id     in      com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_long_id is
begin
    return get_from_id(i_object_id) + 9999999999;
end;

function get_from_id_num(
    i_object_id     in      com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_long_id is
begin
    return floor(i_object_id/10000000000)*10000000000;
end;

function get_till_id_num(
    i_object_id     in      com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_long_id is
begin
    return get_from_id_num(i_object_id) + 9999999999;
end;

function get_id (
    i_seq    in      com_api_type_pkg.t_long_id
  , i_date   in      date                               default null
) return com_api_type_pkg.t_long_id is
begin
    return  get_from_id(i_date) + i_seq;
end;

procedure check_doubles is
    l_count     number := 0;
    l_message   varchar2(4000) := null;
begin
    for rec in (
      select * from (
        select id, stragg(table_name) tables, count(*) cnt, count(*) over() total_cnt
        from com_parameter_id_vw
        group by id
        having count(*)>1
      ) where rownum <= 10
    ) loop
        l_message := l_message||chr(13)||chr(10)|| ' id='||rec.id||', tables='||rec.tables;
        l_count := rec.total_cnt;
    end loop;
    if l_message is not null then
        com_api_error_pkg.raise_error(
            i_error       => 'DUPLICATE_PARAMETER_IDS'
          , i_env_param1  => l_message
          , i_env_param2  => l_count
        );
    end if;
    for rec in (
      select * from (
        select name, count(*), stragg(table_name) tables, count(*) over() total_cnt
        from com_parameter_id_vw
        where name is not null
        group by name
        having count(*)>1
      ) where rownum <= 10
    ) loop
        l_message := l_message||chr(13)||chr(10)|| ' name='||rec.name||', tables='||rec.tables;
        l_count := rec.total_cnt;
    end loop;
    if l_message is not null then
        com_api_error_pkg.raise_error(
            i_error       => 'DUPLICATE_PARAMETER_NAMES'
          , i_env_param1  => l_message
          , i_env_param2  => l_count
        );
    end if;
end;

function get_sequence_nextval (
    i_sequence_name   in      com_api_type_pkg.t_name
) return com_api_type_pkg.t_long_id is
begin
    for seq in (
        select last_number
        from user_sequences
        where sequence_name = upper(i_sequence_name)
    ) loop
        return seq.last_number;
    end loop;

    return 0;
end;

function get_part_key_from_id(
    i_id              in      com_api_type_pkg.t_long_id
) return date is
begin
    return to_date(substr(lpad(to_char(i_id), 16, '0'), 1, 6), 'yymmdd');
end;

end com_api_id_pkg;
/
