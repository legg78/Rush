create or replace force view prc_ui_progress_prc_vw as
select
    a.session_id
    , b.container_process_id
    , b.process_id
	, decode (sum (a.estimated_count), 0, 100,
               (  decode (sum (a.current_count), 0, 0, sum (a.current_count))
                / decode (sum (a.estimated_count), 0, 1, sum (a.estimated_count))
                * 100)) AS progress_bar
    , decode (sum (a.excepted_count), 0, 1, sum (a.excepted_count))
        / decode (sum (a.estimated_count), 0, 1, sum (a.estimated_count))
        * 100 as exception_bar
    , sum (a.estimated_count) AS estimated_count
    , sum (a.current_count) AS current_count
from
    prc_stat_vw a
    , (
    select
        s1.*
        , s2.process_id container_process_id
    from
        prc_session_vw s1
        , prc_session_vw s2
    where
        s1.id = s2.parent_id(+)
    ) b
where
    a.session_id = b.id
group by
    a.session_id
    , b.container_process_id
    , b.process_id
/
