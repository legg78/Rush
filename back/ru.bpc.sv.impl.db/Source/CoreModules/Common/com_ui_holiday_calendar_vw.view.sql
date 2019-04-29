create or replace force view com_ui_holiday_calendar_vw
as
   select   to_char (days.ddd, 'YYYY') yy,
            to_char (days.ddd, 'MM') mm,
            max (decode (days.day_of_week, 'MON', days.dd, null)) mon,
            max (decode (days.day_of_week, 'MON', nvl2(holidays.holiday_date, 1, 0), null)) mon_holiday,
            max (decode (days.day_of_week, 'TUE', days.dd, null)) tue,
            max (decode (days.day_of_week, 'TUE', nvl2(holidays.holiday_date, 1, 0), null)) tue_holiday,
            max (decode (days.day_of_week, 'WED', days.dd, null)) wed,
            max (decode (days.day_of_week, 'WED', nvl2(holidays.holiday_date, 1, 0), null)) wed_holiday,
            max (decode (days.day_of_week, 'THU', days.dd, null)) thu,
            max (decode (days.day_of_week, 'THU', nvl2(holidays.holiday_date, 1, 0), null)) thu_holiday,
            max (decode (days.day_of_week, 'FRI', days.dd, null)) fri,
            max (decode (days.day_of_week, 'FRI', nvl2(holidays.holiday_date, 1, 0), null)) fri_holiday,
            max (decode (days.day_of_week, 'SAT', days.dd, null)) sat,
            max (decode (days.day_of_week, 'SAT', nvl2(holidays.holiday_date, 1, 0), null)) sat_holiday,
            max (decode (days.day_of_week, 'SUN', days.dd, null)) sun,
            max (decode (days.day_of_week, 'SUN', nvl2(holidays.holiday_date, 1, 0), null)) sun_holiday,
            days.week_num
            , days.inst_id
       from (select dd.n + 1 dd, (mm_days.day + dd.n) ddd,
                    to_char (mm_days.day + dd.n,
                             'DY',
                             'NLS_DATE_LANGUAGE=AMERICAN'
                            ) day_of_week,
                    decode (   to_char (mm_days.day, 'MM')
                            || to_char (mm_days.day + dd.n, 'IW'),
                            '1201', '54',
                            '0152', '00',
                            '0153', '00',
                            to_char (mm_days.day + dd.n, 'IW')
                           ) week_num
                    , i.id inst_id    
               from (select rownum - 1 n
                       from  dual connect by level <= 31) dd,
                    (select to_date ('01.' || mm || '.' || yy,
                                     'DD.MM.YY') day
                       from (select rownum mm
                               from  dual connect by level <= 12),
                            (select rownum yy
                               from dual connect by level <= 50)
                    ) mm_days
                    , (select id 
                         from ost_institution
                        union 
                       select 9999 
                         from dual  
                    ) i
              where dd.n < to_number (to_char (last_day (mm_days.day), 'DD'))
         ) days
         , (    select distinct
                    hh.holiday_date
                    , ii.id inst_id
                from 
                    com_holiday hh
                    , (select id 
                         from ost_institution
                        union 
                       select 9999 
                         from dual ) ii
                where 
                    hh.inst_id = ii.id or hh.inst_id = 9999
           ) holidays         
    where 
        days.ddd = holidays.holiday_date(+)
        and days.inst_id = holidays.inst_id(+) 
   group by
        to_char (days.ddd, 'YYYY')
        , to_char (days.ddd, 'MM')    
        , days.week_num
        , days.inst_id
/        
