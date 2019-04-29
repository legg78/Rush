create or replace package body adr_ui_kladr_import_pkg as

g_delim    com_api_type_pkg.t_name := null;

function get_delim return com_api_type_pkg.t_name is
begin
    return g_delim;
end;

procedure import_kladr_data(
    i_altnames_file_id  in      com_api_type_pkg.t_long_id
  , i_doma_file_id      in      com_api_type_pkg.t_long_id
  , i_flat_file_id      in      com_api_type_pkg.t_long_id
  , i_kladr_file_id     in      com_api_type_pkg.t_long_id
  , i_socrbase_file_id  in      com_api_type_pkg.t_long_id
  , i_street_file_id    in      com_api_type_pkg.t_long_id
  , i_delim             in      com_api_type_pkg.t_name default ';'
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_country_id        in      com_api_type_pkg.t_tiny_id
) is
ts  number; 
begin
    ts := dbms_utility.get_time();

    g_delim := i_delim;
    
    truncate_table(i_table_name   => 'adr_alter_place');

    insert into adr_alter_place( place_code_old, place_code_new, comp_level)
    select  
        ltrim(rtrim(substr(raw_data, 1,           c1 - 1), q), q) oldcode
      , ltrim(rtrim(substr(raw_data, c1 + 1, c2 - c1 - 1), q), q) newcode
      , ltrim(rtrim(substr(raw_data, c2 + 1, c9 - c2 - 1), q), q) lvl
    from (select '"' q
                , raw_data
                , instr(raw_data, i_delim, 1, 1) c1
                , instr(raw_data, i_delim, 1, 2) c2
                , length(raw_data) c9
          from prc_file_raw_data where session_file_id = i_altnames_file_id
    );
    trc_log_pkg.debug(sql%rowcount ||' rows imported into adr_alter_place from altnames'); 
    commit;
  
    truncate_table(i_table_name => 'adr_component');

    insert into adr_component(id, lang, abbreviation, comp_name, comp_level, country_id)
    select 
        ltrim(rtrim(substr(raw_data, c3 + 1, c4 - c3 - 1), q), q) kod_t_st
      , i_lang
      , ltrim(rtrim(substr(raw_data, c1 + 1, c2 - c1 - 1), q), q) scname
      , ltrim(rtrim(substr(raw_data, c2 + 1, c3 - c2 - 1), q), q) socrname
      , ltrim(rtrim(substr(raw_data, 1,           c1 - 1), q), q) lvl
      , i_country_id
    from (select '"' q
               , raw_data
               , instr(raw_data, i_delim, 1, 1) c1
               , instr(raw_data, i_delim, 1, 2) c2
               , instr(raw_data, i_delim, 1, 3) c3
               , length(raw_data) c4
          from prc_file_raw_data where session_file_id = i_socrbase_file_id
    );
    trc_log_pkg.debug(sql%rowcount ||' rows imported into adr_component from socrbase');
    commit;
  
    truncate_table(i_table_name => 'adr_place');  
  
    insert into adr_place(id, parent_id, place_code, place_name, comp_id, comp_level, postal_code, region_code, lang)
    select 
        adr_place_seq.nextval
      , null -- parent_id
      , code
      , name
      , (select c.id from adr_component c 
         where c.abbreviation = k.socr and c.comp_level = k.lvl)as comp_id
      , lvl as comp_level
      , indx
      , okatd
      , i_lang
    from (
      select 
          ltrim(rtrim(substr(raw_data, 1,           c1 - 1), q), q) name
        , ltrim(rtrim(substr(raw_data, c1 + 1, c2 - c1 - 1), q), q) socr
        , ltrim(rtrim(substr(raw_data, c2 + 1, c3 - c2 - 1), q), q) code
        , ltrim(rtrim(substr(raw_data, c3 + 1, c4 - c3 - 1), q), q) indx
        , ltrim(rtrim(substr(raw_data, c4 + 1, c5 - c4 - 1), q), q) gninmb
        , ltrim(rtrim(substr(raw_data, c5 + 1, c6 - c5 - 1), q), q) uno
        , ltrim(rtrim(substr(raw_data, c6 + 1, c7 - c6 - 1), q), q) okatd
        , ltrim(rtrim(substr(raw_data, c7 + 1, c9 - c2 - 1), q), q) status
        , adr_ui_kladr_import_pkg.get_level_by_code(ltrim(rtrim(substr(raw_data, c2 + 1, c3 - c2 - 1), q), q)) lvl
        , session_file_id
      from (
        select '"' q, raw_data
         , instr(raw_data, i_delim, 1, 1) c1
         , instr(raw_data, i_delim, 1, 2) c2
         , instr(raw_data, i_delim, 1, 3) c3
         , instr(raw_data, i_delim, 1, 4) c4
         , instr(raw_data, i_delim, 1, 5) c5
         , instr(raw_data, i_delim, 1, 6) c6
         , instr(raw_data, i_delim, 1, 7) c7
         , length(raw_data) c9
         , session_file_id
        from prc_file_raw_data where session_file_id = i_kladr_file_id
      )
    ) k ;
    trc_log_pkg.debug(sql%rowcount ||' rows imported into adr_place from kladr');
    commit;
    
    insert into adr_place(id, parent_id, place_code, place_name, comp_id, comp_level, postal_code, region_code, lang)
    select 
        adr_place_seq.nextval
      , null -- parent_id
      , code
      , name
      , (select c.id from adr_component c 
         where c.abbreviation = k.socr and c.comp_level = k.lvl)as comp_id
      , lvl as comp_level
      , indx
      , okatd
      , i_lang
     from(
       select 
           ltrim(rtrim(substr(raw_data, 1,           c1 - 1), q), q) name
         , ltrim(rtrim(substr(raw_data, c1 + 1, c2 - c1 - 1), q), q) socr
         , ltrim(rtrim(substr(raw_data, c2 + 1, c3 - c2 - 1), q), q) code
         , ltrim(rtrim(substr(raw_data, c3 + 1, c4 - c3 - 1), q), q) indx
         , ltrim(rtrim(substr(raw_data, c4 + 1, c5 - c4 - 1), q), q) gnimnb
         , ltrim(rtrim(substr(raw_data, c5 + 1, c6 - c5 - 1), q), q) uno
         , ltrim(rtrim(substr(raw_data, c6 + 1, c9 - c6 - 1), q), q) okatd
         , 5 lvl
       from (
         select '"' q, raw_data
          , instr(raw_data, delim, 1, 1) c1
          , instr(raw_data, delim, 1, 2) c2
          , instr(raw_data, delim, 1, 3) c3
          , instr(raw_data, delim, 1, 4) c4
          , instr(raw_data, delim, 1, 5) c5
          , instr(raw_data, delim, 1, 6) c6
          , length(raw_data) c9
          , session_file_id 
         from prc_file_raw_data, (select ',' delim from dual) x 
         where session_file_id = i_street_file_id
       )
     ) k where nvl(indx, ' ') != 'INDEX' ; 
    trc_log_pkg.debug(sql%rowcount ||' rows imported into adr_place from street');
    commit;
    
    insert into adr_place(id, parent_id, place_code, place_name, comp_id, comp_level, postal_code, region_code, lang)
    select 
         adr_place_seq.nextval
       , null -- parent_id
       , code
       , name
       , (select c.id from adr_component c where c.abbreviation = k.socr and c.comp_level = k.lvl)as comp_id
       , lvl as comp_level
       , indx
       , okatd
       , i_lang
    from(
      select 
          ltrim(rtrim(substr(raw_data, 1,           c1 - 1), q), q) name
        , ltrim(rtrim(substr(raw_data, c1 + 1, c2 - c1 - 1), q), q) korp
        , ltrim(rtrim(substr(raw_data, c2 + 1, c3 - c2 - 1), q), q) socr
        , ltrim(rtrim(substr(raw_data, c3 + 1, c4 - c3 - 1), q), q) code
        , ltrim(rtrim(substr(raw_data, c4 + 1, c5 - c4 - 1), q), q) indx
        , ltrim(rtrim(substr(raw_data, c5 + 1, c6 - c5 - 1), q), q) gnimnb
        , ltrim(rtrim(substr(raw_data, c6 + 1, c7 - c6 - 1), q), q) uno
        , ltrim(rtrim(substr(raw_data, c7 + 1, c9 - c2 - 1), q), q) okatd
        , 6 lvl
       from (
         select '"' q, raw_data
          , instr(raw_data, i_delim, 1, 1) c1
          , instr(raw_data, i_delim, 1, 2) c2
          , instr(raw_data, i_delim, 1, 3) c3
          , instr(raw_data, i_delim, 1, 4) c4
          , instr(raw_data, i_delim, 1, 5) c5
          , instr(raw_data, i_delim, 1, 6) c6
          , instr(raw_data, i_delim, 1, 7) c7
          , length(raw_data) c9
          , session_file_id 
        from prc_file_raw_data 
        where session_file_id = i_doma_file_id
       )
      ) k where nvl(indx, ' ') != 'INDEX';
    trc_log_pkg.debug(sql%rowcount ||' rows imported into adr_place from doma');
    commit;
   
    set_parent;
    commit;
    
    --clear_inactive;
    
    commit;
    trc_log_pkg.debug('Execution time = '||
        to_char(trunc((dbms_utility.get_time - ts)/6000))||' min. '||
        to_char(trunc(mod((dbms_utility.get_time - ts)/100,60)),'00')||' sec. ');
end;


function get_level_by_code(i_code   in com_api_type_pkg.t_name) 
return com_api_type_pkg.t_tiny_id is
    l_result      com_api_type_pkg.t_tiny_id;
    l_district    com_api_type_pkg.t_name;
    l_city        com_api_type_pkg.t_name;
    l_settlement  com_api_type_pkg.t_name;
begin

    l_district   := substr(i_code, 3,3);
    l_city       := substr(i_code, 6,3);
    l_settlement := substr(i_code, 9,3);
  
    l_result := case 
             when l_settlement = '000' and l_city = '000' and l_district = '000' then 1
             when l_settlement = '000' and l_city = '000'                        then 2
             when l_settlement = '000'                                           then 3
             else 4
             end;

    return l_result;
end;

procedure truncate_table (i_table_name in     com_api_type_pkg.t_name) as
begin
    for i in (
        select c2.table_name, c2.constraint_name
        from user_constraints c
        join user_constraints c2
          on c.constraint_name = c2.r_constraint_name
        where c.table_name = upper(i_table_name)
    ) loop
        trc_log_pkg.debug('alter table '||i.table_name||' disable constraint '||i.constraint_name);
        execute immediate 'alter table '||i.table_name||' disable constraint '||i.constraint_name;
    end loop;
  
    trc_log_pkg.debug('truncate table '||i_table_name);
    execute immediate 'truncate table '||i_table_name ; --|| ' reuse storage';
   
    for i in (  
        select c2.table_name, c2.constraint_name
        from user_constraints c
        join user_constraints c2
          on c.constraint_name = c2.r_constraint_name
        where c.table_name = upper(i_table_name) and c2.table_name != c.table_name
    ) loop
        truncate_table (i_table_name => i.table_name); 
    end loop;
    
    for i in (
        select c2.table_name, c2.constraint_name
        from user_constraints c
        join user_constraints c2
          on c.constraint_name = c2.r_constraint_name
        where c.table_name =upper(i_table_name)
    ) loop
        trc_log_pkg.debug('alter table '||i.table_name||' enable constraint '||i.constraint_name);
        execute immediate 'alter table '||i.table_name||' enable constraint '||i.constraint_name;
    end loop;
end;

procedure set_parent is
begin
    trc_log_pkg.debug('set parent started');
    
    execute immediate 'analyze table adr_place compute statistics';

    update adr_place a
    set a.parent_id = 
      nvl( 
          (select min(b.id) keep (dense_rank last order by b.comp_level) 
             from adr_place b
            where a.comp_level > b.comp_level
              and b.place_code like substr(a.place_code, 1, decode(a.comp_level, 2, 2, 3, 5, 4, 8, 5, 11, 6, 15, 2))||'%'
              and (substr(b.place_code, -2) = '00' or b.comp_level = 6))
        ,nvl( (select min(b.id) keep (dense_rank last order by b.comp_level) 
                 from adr_place b
                where a.comp_level > b.comp_level
                  and b.place_code like substr(a.place_code, 1, decode(a.comp_level, 2, 2, 3, 2, 4, 5, 5, 8, 6, 11, 2))||'%'
                  and (substr(b.place_code, -2) = '00' or b.comp_level = 6))
             ,(select min(b.id) keep (dense_rank last order by b.comp_level) 
                 from adr_place b
                where a.comp_level > b.comp_level
                  and b.place_code like substr(a.place_code, 1, decode(a.comp_level, 2, 2, 3, 2, 4, 2, 5, 5, 6, 8, 2))||'%'
                  and (substr(b.place_code, -2) = '00' or b.comp_level = 6))
           )
       )
     where a.comp_level > 1 and parent_id is null;

    trc_log_pkg.debug('set parent: '||sql%rowcount||' rows linked to previous levels');
    commit;   
end;
  
procedure clear_inactive is
begin
    delete from adr_place_vw
    where comp_level = 1 and status != '00' and parent_id is null;

    trc_log_pkg.debug(sql%rowcount||' inactive records with comp_level=1 deleted.');
    commit;
    
    delete from adr_place_vw
    where comp_level = 2 and status != '00' and parent_id is null;

    trc_log_pkg.debug(sql%rowcount||' inactive records with comp_level=2 deleted.');
    commit;
    
    delete from adr_place_vw
    where comp_level = 3 and status != '00' and parent_id is null;

    trc_log_pkg.debug(sql%rowcount||' inactive records with comp_level=3 deleted.');
    commit;
    
    delete from adr_place a
    where a.comp_level = 4 and substr (a.place_code, 12, 2)!= '00' and a.parent_id is null;

    trc_log_pkg.debug(sql%rowcount||' inactive records with comp_level=4 deleted.');
    commit;
    
    delete from adr_place a
    where a.comp_level = 5 and substr (a.place_code, 16, 2)!= '00' and a.parent_id is null;

    trc_log_pkg.debug(sql%rowcount||' inactive records with comp_level=5 deleted.');
    commit;  
    
    delete from adr_place a
    where a.comp_level = 6 and a.parent_id is null;

    trc_log_pkg.debug(sql%rowcount||' records with comp_level=6 and parent_id = null deleted.');
    commit;  


end;

end;
/
