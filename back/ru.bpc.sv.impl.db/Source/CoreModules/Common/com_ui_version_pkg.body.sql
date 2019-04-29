create or replace package body com_ui_version_pkg as

function get_last_version(
    i_part          in      com_api_type_pkg.t_dict_value := 'PARTBACK')
return  com_api_type_pkg.t_name
        result_cache
        relies_on (com_version)
is
    l_version    com_api_type_pkg.t_name := '';
begin

    for rec in (
              select version_number
                from (
                    select version_number
                      from com_version
                     where part_name = i_part order by build_date desc)
               where rownum = 1
        )
    loop
        l_version := l_version || rec.version_number;
    end loop;

    return l_version;

end get_last_version;

function get_release(
    i_part          in      com_api_type_pkg.t_dict_value := 'PARTPDSS'
) return com_api_type_pkg.t_name
        result_cache
        relies_on (com_version)
is
    l_version    com_api_type_pkg.t_name := '';
begin
    for rec in (
        select release
          from (
              select release
                from com_version
               where part_name = i_part order by build_date desc)
         where rownum = 1
    )
    loop
        l_version := l_version || rec.release;
    end loop;

  return l_version;

end get_release;

function get_description(
    i_major          in      com_api_type_pkg.t_tiny_id
  , i_minor          in      com_api_type_pkg.t_tiny_id
  , i_maintenance    in      com_api_type_pkg.t_tiny_id
  , i_build          in      com_api_type_pkg.t_tiny_id
  , i_extension      in      com_api_type_pkg.t_dict_value
  , i_revision       in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_name is
begin
    return to_char(i_major)||'.'||to_char(i_minor)||'.'||to_char(i_maintenance)||'.'||to_char(i_build)||to_char(i_extension)||'['||to_char(i_revision)||']';
end get_description;

procedure register_version(
      i_version      in      com_api_type_pkg.t_name
    , i_build_date   in      date
    , i_part_name    in      com_api_type_pkg.t_dict_value
    , i_git_revision in      com_api_type_pkg.t_name
) is
    l_release                com_api_type_pkg.t_name := '2.2.10';
begin
    insert into com_version (
        version_number
      , build_date
      , install_date
      , part_name
      , git_revision
      , release
  ) values (
      i_version
    , i_build_date
    , sysdate
    , i_part_name
    , i_git_revision
    , l_release
  );
end register_version;

end;
/
