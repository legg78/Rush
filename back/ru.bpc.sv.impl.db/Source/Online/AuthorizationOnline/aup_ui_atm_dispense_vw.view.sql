create or replace force view aup_ui_atm_dispense_vw as
select
    auth_id
    , ltrim(sys_connect_by_path(condition , ' / '), ' / ') as condition
from (
    select
        auth_id
        , condition
        , row_number() over (partition by auth_id order by priority) rn
        , count(*) over(partition by auth_id) cnt
    from (
        select
            l.auth_id
            , d.disp_number || ':'|| d.face || ' ' || nvl(c.name, d.currency) || ' (' || d.note_dispensed || ')' condition
            , d.disp_number priority
        from
            aup_atm l
            , aup_atm_disp d
            , com_currency c
        where
            l.message_type = 40
            and d.auth_id = l.auth_id
            and d.tech_id = l.tech_id
            and c.code(+) = d.currency
        )
    )
where
    rn = cnt
start with
    rn = 1
connect by
    prior auth_id = auth_id
    and prior rn + 1 = rn
/
