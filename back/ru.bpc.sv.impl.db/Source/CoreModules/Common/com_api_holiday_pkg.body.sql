create or replace package body com_api_holiday_pkg as

function is_holiday(
    i_day               in      date
  , i_inst_id           in      com_api_type_pkg.t_inst_id
) return com_api_type_pkg.t_boolean is
    l_result            com_api_type_pkg.t_boolean;
begin
    select count(1)
      into l_result
      from com_holiday
     where holiday_date = trunc(i_day)
       and (inst_id = i_inst_id or inst_id = ost_api_const_pkg.DEFAULT_INST)
       and rownum = 1;

    return l_result;
end;

function get_prev_working_day (
    i_day               in      date
  , i_inst_id           in      com_api_type_pkg.t_inst_id
) return date is
    l_result            date;
begin
    select
        max(c.next_day)
    into
        l_result
    from (
        select
            trunc(i_day - rownum) next_day
        from
            all_objects
        ) c
    where
        not exists (
            select
                1
            from
                com_holiday_vw h
            where
                h.holiday_date = c.next_day
                and h.inst_id = i_inst_id
        );

    return l_result;
end;

function get_next_working_day (
    i_day               in      date
  , i_inst_id           in      com_api_type_pkg.t_inst_id
) return date is
    l_result            date;
begin
    select
        min(c.next_day)
    into
        l_result
    from (
        select
            trunc(i_day + rownum) next_day
        from
            all_objects
        ) c
    where
        not exists (
            select
                1
            from
                com_holiday_vw h
            where
                h.holiday_date = c.next_day
                and h.inst_id = i_inst_id
        );

    return l_result;
end;

function get_shifted_working_day(
    i_day               in     date
  , i_forward           in     com_api_type_pkg.t_boolean
  , i_day_shift         in     com_api_type_pkg.t_tiny_id
  , i_inst_id           in     com_api_type_pkg.t_inst_id
) return date is
    l_result            date;
    l_shift             com_api_type_pkg.t_tiny_id;
begin
    l_shift := case when i_forward = com_api_type_pkg.TRUE then 1 else -1 end;

    select
        case
            when i_forward = com_api_type_pkg.TRUE
            then min(c.next_day)
            else max(c.next_day)
        end
    into
        l_result
    from (
        select trunc(i_day) + (i_day_shift - 1 + rownum) * l_shift as next_day
          from all_objects
        ) c
    where
        not exists (
            select 1
              from com_holiday_vw h
             where h.holiday_date = c.next_day
               and h.inst_id = i_inst_id
        );

    return l_result;
end;

end;
/
