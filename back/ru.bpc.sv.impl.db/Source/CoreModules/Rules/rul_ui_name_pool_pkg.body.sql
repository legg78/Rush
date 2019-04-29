create or replace package body rul_ui_name_pool_pkg as
/*********************************************************
*  UI for pool <br />
*  Created by Kryukov E.(krukov@bpc.ru)  at 13.02.2012 <br />
*  Last changed by $Author: $ <br />
*  $LastChangedDate:: #$ <br />
*  Revision: $LastChangedRevision: 62774 $ <br />
*  Module: RUL_UI_NAME_POOL_PKG <br />
*  @headcom
**********************************************************/

BULK_SIZE           constant integer := 100000;
INDEX_RANGE_OFFSET  constant integer := -6;

function get_partition_key(
    i_index_range_id     in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_short_id is
begin
    return to_number(coalesce(substr(to_char(i_index_range_id), INDEX_RANGE_OFFSET), to_char(i_index_range_id)));
end get_partition_key;

procedure add_pool_value(
    o_id                    out com_api_type_pkg.t_long_id
  , i_index_range_id     in     com_api_type_pkg.t_short_id
  , i_value              in     com_api_type_pkg.t_large_id
) is
    l_partition_key      com_api_type_pkg.t_short_id;
begin
    o_id            := rul_name_index_pool_seq.nextval;
    l_partition_key := get_partition_key(i_index_range_id => i_index_range_id);

    insert into rul_name_index_pool_vw(
        id
      , index_range_id
      , value
      , is_used
      , partition_key
    ) values (
        o_id
      , i_index_range_id
      , i_value
      , com_api_type_pkg.FALSE
      , l_partition_key
    );
exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error      => 'DUPLICATE_NAME_INDEX_POOL'
          , i_env_param1 => i_index_range_id
          , i_env_param2 => i_value
        );
end add_pool_value;

procedure modify_pool_value(
    i_index_range_id     in     com_api_type_pkg.t_short_id
  , i_value              in     com_api_type_pkg.t_large_id
  , i_is_used            in     com_api_type_pkg.t_boolean
  , i_rowid              in     rowid                        default null
) is
    l_partition_key      com_api_type_pkg.t_short_id;
begin
    l_partition_key      := get_partition_key(i_index_range_id => i_index_range_id);

    if i_rowid is not null then
        update rul_name_index_pool_vw a
           set a.is_used        = i_is_used
         where a.rowid          = i_rowid
           and a.partition_key  = l_partition_key;
    else
        update rul_name_index_pool_vw a
           set a.is_used        = i_is_used
         where a.index_range_id = i_index_range_id
           and a.value          = i_value
           and a.partition_key  = l_partition_key;
    end if;

    if sql%rowcount = 0 then
        com_api_error_pkg.raise_error (
            i_error        => 'RUL_NAME_IND_RANGE_NOT_FOUND'
          , i_env_param1   => i_index_range_id
        );
    end if;
end modify_pool_value;

procedure remove_pool_value(
    i_id                 in     com_api_type_pkg.t_long_id
  , i_rowid              in     rowid                        default null
) is
begin
    trc_log_pkg.debug (
        i_text         => 'Delete name pool with id [#1]'
      , i_env_param1   => i_id
    );

    if i_rowid is not null then
        delete from rul_name_index_pool_vw
         where rowid = i_rowid
           and id+0  = i_id;    -- only check, disable index
    else
        delete from rul_name_index_pool_vw
         where id    = i_id;
    end if;

end remove_pool_value;

procedure remove_pool_value(
    i_index_range_id     in     com_api_type_pkg.t_short_id
  , i_value              in     com_api_type_pkg.t_large_id
) is
    l_partition_key      com_api_type_pkg.t_short_id;
begin
    l_partition_key      := get_partition_key(i_index_range_id => i_index_range_id);

    trc_log_pkg.debug (
        i_text         => 'Delete name pool with i_index_range_id [#1] i_value [#2]'
      , i_env_param1   => i_index_range_id
      , i_env_param2   => i_value
    );

    delete from rul_name_index_pool_vw a
     where a.index_range_id = i_index_range_id
       and a.value          = i_value
       and a.partition_key  = l_partition_key;
end;

procedure create_random_pool(
    i_index_range_id     in     com_api_type_pkg.t_short_id
  , i_low_value          in     com_api_type_pkg.t_large_id
  , i_high_value         in     com_api_type_pkg.t_large_id
) is
    type t_pool_array is table of com_api_type_pkg.t_large_id index by pls_integer;
    l_pool               t_pool_array;
    l_index              pls_integer:= 0;
    l_swap_index         com_api_type_pkg.t_large_id;
    l_dummy              com_api_type_pkg.t_large_id;
    l_begin_index        com_api_type_pkg.t_large_id;
    l_end_index          com_api_type_pkg.t_large_id;
begin
    -- populate sequential pool values
    for x in i_low_value .. i_high_value loop
        l_index         := l_index + 1;
        l_pool(l_index) := x;
    end loop;

    -- shake pool
    dbms_random.seed( i_high_value - i_low_value + 1 );

    for x in 1..(i_high_value - i_low_value + 1) loop
        l_swap_index:= dbms_random.value(1, i_high_value - i_low_value+1);
        l_dummy:= l_pool(x);
        l_pool(x):= l_pool(l_swap_index);
        l_pool(l_swap_index):= l_dummy;
    end loop;

    -- save result pool
    for l_iter in 1 .. floor((i_high_value - i_low_value) / BULK_SIZE) + 1 loop
        l_begin_index := (l_iter - 1)*BULK_SIZE + 1;
        l_end_index   := least(l_iter*BULK_SIZE, i_high_value - i_low_value + 1);

        forall i in l_begin_index..l_end_index
            insert into rul_name_index_pool_vw(
                id
              , index_range_id
              , value
              , is_used
              , partition_key
            )
            values(
                rul_name_index_pool_seq.nextval
              , i_index_range_id
              , l_pool(i)
              , com_api_type_pkg.FALSE
              , to_number(coalesce(substr(to_char(i_index_range_id), INDEX_RANGE_OFFSET), to_char(i_index_range_id)))
            );

    end loop;
    
    l_pool.delete;
    
exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error      => 'DUPLICATE_NAME_INDEX_POOL'
          , i_env_param1 => i_index_range_id
          , i_env_param2 => null
        );
end create_random_pool;

procedure create_sequential_pool(
    i_index_range_id     in     com_api_type_pkg.t_short_id
  , i_low_value          in     com_api_type_pkg.t_large_id
  , i_high_value         in     com_api_type_pkg.t_large_id
) is
    type t_pool_array is table of com_api_type_pkg.t_large_id index by pls_integer;
    l_pool               t_pool_array;
    l_index              pls_integer:= 0;
begin
    -- populate sequential pool values
    for l_index_outer in 1 .. floor((i_high_value - i_low_value) / BULK_SIZE) + 1
    loop
        l_index := 0;
        for l_index_inner in i_low_value + (l_index_outer - 1) * BULK_SIZE .. least(i_low_value + l_index_outer * BULK_SIZE - 1, i_high_value)
        loop
            l_index         := l_index + 1;
            l_pool(l_index) := l_index_inner;
        end loop;

        -- save result pool
        forall l_index in 1 .. l_pool.count
            insert into rul_name_index_pool_vw (
                id
              , index_range_id
              , value
              , is_used
              , partition_key
            ) values (
                rul_name_index_pool_seq.nextval
              , i_index_range_id
              , l_pool(l_index)
              , com_api_type_pkg.FALSE
              , to_number(coalesce(substr(to_char(i_index_range_id), INDEX_RANGE_OFFSET), to_char(i_index_range_id)))
            );

        l_pool.delete;
    end loop;

exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error      => 'DUPLICATE_NAME_INDEX_POOL'
          , i_env_param1 => i_index_range_id
          , i_env_param2 => null
        );
end create_sequential_pool;

procedure create_pool(
    i_index_range_id     in     com_api_type_pkg.t_short_id
  , i_low_value          in     com_api_type_pkg.t_large_id
  , i_high_value         in     com_api_type_pkg.t_large_id
  , i_force              in     com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
) is
    l_algorithm          com_api_type_pkg.t_dict_value;
begin
    select t.algorithm
      into l_algorithm
      from rul_name_index_range_vw t
     where t.id = i_index_range_id;
    
    -- create pool only on regular instance - not on configuration
    if not (
               nvl(set_ui_value_pkg.get_system_param_n(i_param_name => 'CONFIGURATION_INSTANCE')
                 , com_api_type_pkg.FALSE
               ) = com_api_type_pkg.TRUE 
           )
        or i_force = com_api_type_pkg.TRUE
    then
        if l_algorithm = rul_api_const_pkg.ALGORITHM_TYPE_RNGS then
            create_sequential_pool(
                i_index_range_id     => i_index_range_id
              , i_low_value          => i_low_value
              , i_high_value         => i_high_value
            );
        elsif l_algorithm = rul_api_const_pkg.ALGORITHM_TYPE_RNGR then
            create_random_pool(
                i_index_range_id     => i_index_range_id
              , i_low_value          => i_low_value
              , i_high_value         => i_high_value
            );
        end if; 
    end if;
end create_pool;

procedure create_pools_if_missing is
begin
    trc_log_pkg.debug(
        i_text => 'Create missing index pools start'
    );
    
    for x in (
        select t.id
             , t.low_value
             , t.high_value
             , t.algorithm
             , rownum as rn
             , count(1) over () as total_cnt
          from rul_name_index_range_vw t
         where t.algorithm in (
                   rul_api_const_pkg.ALGORITHM_TYPE_RNGS
                 , rul_api_const_pkg.ALGORITHM_TYPE_RNGR
               )
           and not exists(
                       select 1
                         from rul_name_index_pool ip
                        where ip.index_range_id = t.id
                          and ip.partition_key  = to_number(coalesce(substr(to_char(t.id), INDEX_RANGE_OFFSET), to_char(t.id)))
                   )
    ) loop
        trc_log_pkg.debug(
            i_text       => 'Create pool [#1]/[#2] for range [#3] - [#4] by algorithm [#5]'
          , i_env_param1 => x.rn
          , i_env_param2 => x.total_cnt
          , i_env_param3 => x.low_value
          , i_env_param4 => x.high_value
          , i_env_param5 => x.algorithm
        );

        create_pool(
            i_index_range_id     => x.id
          , i_low_value          => x.low_value
          , i_high_value         => x.high_value
          , i_force              => com_api_type_pkg.TRUE
        );
    end loop;
    
    trc_log_pkg.debug(
        i_text => 'Create missing index pools finished'
    );
end;

procedure check_bin_index_range_cross(
    i_index_range_id     in     com_api_type_pkg.t_short_id
  , i_low_value          in     com_api_type_pkg.t_large_id
  , i_high_value         in     com_api_type_pkg.t_large_id
) is
    l_err_flag           boolean;
begin
    for x in (
        select r.*
          from (
                   select d.id
                        , d.low_value
                        , d.high_value
                        , lag(d.low_value)   over(order by d.low_value, d.high_value) as prior_low_value
                        , lag(d.high_value)  over(order by d.low_value, d.high_value) as prior_high_value
                        , lead(d.low_value)  over(order by d.low_value, d.high_value) as next_low_value
                        , lead(d.high_value) over(order by d.low_value, d.high_value) as next_high_value
                     from (
                              select ir.id
                                   , decode(ir.id, i_index_range_id, i_low_value, ir.low_value)   as low_value
                                   , decode(ir.id, i_index_range_id, i_high_value, ir.high_value) as high_value
                                from rul_name_index_range_vw ir_src
                                join iss_bin_index_range_vw  br_src on br_src.index_range_id = ir_src.id
                                join iss_bin_index_range_vw      br on br.bin_id = br_src.bin_id
                                join rul_name_index_range_vw     ir on ir.id = br.index_range_id
                               where ir_src.id = i_index_range_id
                          ) d
               ) r
         where r.low_value  <= r.prior_high_value
            or r.high_value >= r.next_low_value
    ) loop
        trc_log_pkg.debug(
            i_text       => 'Error ranges [#1] - [#2]'
          , i_env_param1 => x.low_value
          , i_env_param2 => x.high_value
        );

        l_err_flag:= true;
    end loop;
    
    if l_err_flag then
        com_api_error_pkg.raise_error(
            i_error      => 'CROSS_RANGE'
          , i_env_param1 => i_low_value
          , i_env_param2 => i_high_value
        );
    end if;
end check_bin_index_range_cross;

procedure check_common_range_cross(
    i_index_range_id     in com_api_type_pkg.t_short_id
  , i_low_value          in com_api_type_pkg.t_large_id
  , i_high_value         in com_api_type_pkg.t_large_id
  , i_inst_id            in com_api_type_pkg.t_inst_id
  , i_entity_type        in com_api_type_pkg.t_dict_value
) is
    l_err_flag           boolean;
begin
    for x in (
        select r.*
          from (
                   select d.id
                        , d.low_value
                        , d.high_value
                        , lag(d.low_value)   over(order by d.low_value, d.high_value) as prior_low_value
                        , lag(d.high_value)  over(order by d.low_value, d.high_value) as prior_high_value
                        , lead(d.low_value)  over(order by d.low_value, d.high_value) as next_low_value
                        , lead(d.high_value) over(order by d.low_value, d.high_value) as next_high_value
                     from (
                              select ir.id
                                   , decode(ir.id, i_index_range_id, i_low_value, ir.low_value)   as low_value
                                   , decode(ir.id, i_index_range_id, i_high_value, ir.high_value) as high_value
                                from rul_name_index_range_vw     ir
                               where ir.entity_type = i_entity_type
                                 and ir.inst_id = i_inst_id
                          ) d
               ) r
         where r.low_value  <= r.prior_high_value
            or r.high_value >= r.next_low_value
    ) loop
        trc_log_pkg.debug(
            i_text       => 'Error ranges [#1] - [#2]'
          , i_env_param1 => x.low_value
          , i_env_param2 => x.high_value
        );

        l_err_flag:= true;
    end loop;
    
    if l_err_flag then
        com_api_error_pkg.raise_error(
            i_error      => 'CROSS_RANGE'
          , i_env_param1 => i_low_value
          , i_env_param2 => i_high_value
        );
    end if;
end check_common_range_cross;

procedure check_cross(
    i_index_range_id     in     com_api_type_pkg.t_short_id
  , i_low_value          in     com_api_type_pkg.t_large_id
  , i_high_value         in     com_api_type_pkg.t_large_id
) is
    l_entity_type               com_api_type_pkg.t_dict_value;
    l_inst_id                   com_api_type_pkg.t_inst_id;
begin
    select t.inst_id
         , t.entity_type
      into l_inst_id
         , l_entity_type
      from rul_name_index_range_vw t
     where t.id = i_index_range_id;
    
    if l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
        check_bin_index_range_cross(
            i_index_range_id     => i_index_range_id
          , i_low_value          => i_low_value
          , i_high_value         => i_high_value
        );
    else
        check_common_range_cross(
            i_index_range_id     => i_index_range_id
          , i_low_value          => i_low_value
          , i_high_value         => i_high_value
          , i_inst_id            => l_inst_id
          , i_entity_type        => l_entity_type
        );
    end if;
end check_cross;

procedure check_range_change(
    i_index_range_id          in com_api_type_pkg.t_short_id
  , i_low_value               in com_api_type_pkg.t_large_id
  , i_high_value              in com_api_type_pkg.t_large_id
  , o_current_low_value      out com_api_type_pkg.t_large_id
  , o_current_high_value     out com_api_type_pkg.t_large_id
) is
    l_partition_key              com_api_type_pkg.t_short_id;

    cursor boundary_cur is
        select sum(case when p.value < i_low_value  and p.is_used = com_api_type_pkg.TRUE then 1 else 0 end) as out_of_low_boundary
             , sum(case when p.value > i_high_value and p.is_used = com_api_type_pkg.TRUE then 1 else 0 end) as out_of_high_boundary
             , min(value) as low_boundary
             , max(value) as high_boundary
          from rul_name_index_pool_vw p
         where p.index_range_id = i_index_range_id
           and p.partition_key  = l_partition_key;

    l_boundary_row       boundary_cur%rowtype;      
begin
    l_partition_key      := get_partition_key(i_index_range_id => i_index_range_id);

    open boundary_cur;
    loop
        fetch boundary_cur into l_boundary_row;
        exit when boundary_cur%notfound;
    end loop;
    close boundary_cur;
    
    if l_boundary_row.out_of_low_boundary > 0 then
        trc_log_pkg.debug(
            i_text       => 'Used values found below low boundary [#1]. Found [#2] used elenments'
          , i_env_param1 => i_low_value
          , i_env_param2 => l_boundary_row.out_of_low_boundary
        );

        com_api_error_pkg.raise_error(
            i_error      => 'RANGE_CHANGE_BELOW_LOW_BOUND'
          , i_env_param1 => i_low_value
          , i_env_param2 => l_boundary_row.out_of_low_boundary
        );
    end if;
    
    if l_boundary_row.out_of_high_boundary > 0 then
        trc_log_pkg.debug(
            i_text       => 'Used values found over high boundary [#1]. Found [#2] used elenments'
          , i_env_param1 => i_high_value
          , i_env_param2 => l_boundary_row.out_of_high_boundary
        );

        com_api_error_pkg.raise_error(
            i_error      => 'RANGE_CHANGE_OVER_HIGH_BOUND'
          , i_env_param1 => i_high_value
          , i_env_param2 => l_boundary_row.out_of_high_boundary
        );
    end if;
    
    o_current_low_value  := l_boundary_row.low_boundary;
    o_current_high_value := l_boundary_row.high_boundary;

exception when others then
    if boundary_cur%isopen then
        close boundary_cur;
    end if;
    raise;
end check_range_change;

procedure check_range_change(
    i_index_range_id          in com_api_type_pkg.t_short_id
  , i_low_value               in com_api_type_pkg.t_large_id
  , i_high_value              in com_api_type_pkg.t_large_id
) is
    l_current_low_value          com_api_type_pkg.t_large_id;
    l_current_high_value         com_api_type_pkg.t_large_id;
begin
    check_range_change(
        i_index_range_id         => i_index_range_id
      , i_low_value              => i_low_value
      , i_high_value             => i_high_value
      , o_current_low_value      => l_current_low_value
      , o_current_high_value     => l_current_high_value
    );
end check_range_change;


procedure check_used(
    i_index_range_id          in com_api_type_pkg.t_short_id
) is
    l_count                      com_api_type_pkg.t_long_id;
    l_partition_key              com_api_type_pkg.t_short_id;
begin
    l_partition_key        := get_partition_key(i_index_range_id => i_index_range_id);

    select count(1)
      into l_count
      from rul_name_index_pool_vw p
     where p.index_range_id = i_index_range_id
       and p.is_used        = com_api_type_pkg.TRUE
       and p.partition_key  = l_partition_key
       and rownum           = 1;

    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error      => 'RANGE_USED_VALUES_FOUND'
          , i_env_param1 => l_count
        );
    end if;

end check_used;

procedure add_pool(
    i_index_range_id     in     com_api_type_pkg.t_short_id
  , i_low_value          in     com_api_type_pkg.t_large_id
  , i_high_value         in     com_api_type_pkg.t_large_id
) is
begin
    trc_log_pkg.debug(
        i_text           => 'i_index_range_id [#1] i_low_value [#2] i_high_value [#3]' 
      , i_env_param1     => i_index_range_id
      , i_env_param2     => i_low_value
      , i_env_param3     => i_high_value
    );
    
    -- check cross
    check_cross(
        i_index_range_id     => i_index_range_id
      , i_low_value          => i_low_value
      , i_high_value         => i_high_value
    );
    
    create_pool(
        i_index_range_id     => i_index_range_id
      , i_low_value          => i_low_value
      , i_high_value         => i_high_value
    );

exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error      => 'DUPLICATE_NAME_INDEX_POOL'
          , i_env_param1 => i_index_range_id
          , i_env_param2 => null
        );
end add_pool;

procedure modify_pool(
    i_index_range_id     in     com_api_type_pkg.t_short_id
  , i_low_value          in     com_api_type_pkg.t_large_id
  , i_high_value         in     com_api_type_pkg.t_large_id
) is
    l_current_low_value         com_api_type_pkg.t_large_id;
    l_current_high_value        com_api_type_pkg.t_large_id;
begin
    trc_log_pkg.debug(
        i_text           => 'i_index_range_id [#1] i_low_value [#2] i_high_value [#3]' 
      , i_env_param1     => i_index_range_id
      , i_env_param2     => i_low_value
      , i_env_param3     => i_high_value
    );

    -- check cross
    check_cross(
        i_index_range_id      => i_index_range_id
      , i_low_value           => i_low_value
      , i_high_value          => i_high_value
    );
    
    check_range_change(
        i_index_range_id      => i_index_range_id
      , i_low_value           => i_low_value
      , i_high_value          => i_high_value
      , o_current_low_value   => l_current_low_value
      , o_current_high_value  => l_current_high_value
    );
    
    -- remove extra pool up to the bottom of pool
    if l_current_low_value < i_low_value then
        remove_pool_range(
            i_index_range_id  => i_index_range_id
          , i_low_value       => l_current_low_value
          , i_high_value      => i_low_value
        );
    end if;
    
    -- remove extra pool from the top of pool
    if l_current_high_value > i_high_value then
        remove_pool_range(
            i_index_range_id  => i_index_range_id
          , i_low_value       => i_high_value + 1
          , i_high_value      => l_current_high_value
        );
    end if;

    -- low value is below current low value
    if i_low_value > l_current_low_value then
        create_pool(
            i_index_range_id  => i_index_range_id
          , i_low_value       => i_low_value
          , i_high_value      => l_current_low_value - 1
        );
    end if;
    
    -- high value is over current high value
    if i_high_value > l_current_high_value then
        create_pool(
            i_index_range_id  => i_index_range_id
          , i_low_value       => l_current_high_value + 1
          , i_high_value      => i_high_value
        );
    end if;
    
    -- case when pool is empty by some reason
    if     l_current_low_value is null 
       and l_current_high_value is null 
    then
        create_pool(
            i_index_range_id  => i_index_range_id
          , i_low_value       => i_low_value
          , i_high_value      => i_high_value
        );
    end if;

exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error      => 'DUPLICATE_NAME_INDEX_POOL'
          , i_env_param1 => i_index_range_id
          , i_env_param2 => null
        );
end modify_pool;

procedure clear_pool(
    i_index_range_id     in     com_api_type_pkg.t_short_id
) is
    l_partition_key      com_api_type_pkg.t_short_id;
begin
    l_partition_key      := get_partition_key(i_index_range_id => i_index_range_id);

    update rul_name_index_pool_vw a
       set a.is_used        = com_api_type_pkg.FALSE
     where a.index_range_id = i_index_range_id
       and a.partition_key  = l_partition_key;

end clear_pool;

procedure remove_pool(
    i_index_range_id     in     com_api_type_pkg.t_short_id
) is
    l_partition_key      com_api_type_pkg.t_short_id;
begin
    l_partition_key      := get_partition_key(i_index_range_id => i_index_range_id);

    check_used(
        i_index_range_id    => i_index_range_id
    );

    delete rul_name_index_pool_vw a
     where a.index_range_id = i_index_range_id
       and a.partition_key  = l_partition_key;

end remove_pool;

procedure remove_pool_range(
    i_index_range_id     in     com_api_type_pkg.t_short_id
  , i_low_value          in     com_api_type_pkg.t_large_id
  , i_high_value         in     com_api_type_pkg.t_large_id
) is
    l_partition_key      com_api_type_pkg.t_short_id;
begin
    l_partition_key      := get_partition_key(i_index_range_id => i_index_range_id);

    delete rul_name_index_pool_vw a
     where a.index_range_id = i_index_range_id
       and a.partition_key  = l_partition_key
       and a.value between least(i_low_value, i_high_value) and greatest(i_high_value, i_low_value);

end remove_pool_range;

function get_next_value(
    i_index_range_id     in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_large_id is

    l_value                     com_api_type_pkg.t_large_id     default null;
    l_partition_key             com_api_type_pkg.t_short_id;
begin
    l_partition_key := get_partition_key(i_index_range_id => i_index_range_id);
    
    for x in (
        select /*+ first_rows index_asc(a rul_name_index_pool_sequen_ndx) */
               a.value
             , a.rowid as rid
         from rul_name_index_pool_vw a
        where decode(a.is_used, 0, a.index_range_id, null) = i_index_range_id
          and a.partition_key = l_partition_key
          and rownum          = 1
        for update of a.is_used wait 10
    ) loop
        l_value:= x.value;
        modify_pool_value(
            i_index_range_id => i_index_range_id
          , i_value          => x.value
          , i_is_used        => com_api_type_pkg.TRUE
          , i_rowid          => x.rid
        );
        exit;
    end loop;

    if l_value is null then
        com_api_error_pkg.raise_error (
            i_error      => 'RANGE_FULL_USED'
          , i_env_param1 => i_index_range_id
        );
    end if;
    
    return l_value;

end get_next_value;

function get_random_value(
    i_index_range_id     in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_large_id is

    l_value                     com_api_type_pkg.t_large_id     default null;
    l_partition_key             com_api_type_pkg.t_short_id;
begin
    l_partition_key := get_partition_key(i_index_range_id => i_index_range_id);
    
    for x in (
        select /*+ first_rows index_asc(a rul_name_index_pool_random_ndx) */
               a.value
             , a.rowid as rid
         from rul_name_index_pool_vw a
        where decode(a.is_used, 0, a.index_range_id, null) = i_index_range_id
          and a.partition_key = l_partition_key
          and rownum          = 1
        for update of a.is_used skip locked
    ) loop
        l_value:= x.value;
        modify_pool_value(
            i_index_range_id => i_index_range_id
          , i_value          => x.value
          , i_is_used        => com_api_type_pkg.TRUE
          , i_rowid          => x.rid
        );
        exit;
    end loop;

    if l_value is null then
        com_api_error_pkg.raise_error (
            i_error      => 'RANGE_FULL_USED'
          , i_env_param1 => i_index_range_id
        );
    end if;
    
    return l_value;

end get_random_value;

end rul_ui_name_pool_pkg;
/
