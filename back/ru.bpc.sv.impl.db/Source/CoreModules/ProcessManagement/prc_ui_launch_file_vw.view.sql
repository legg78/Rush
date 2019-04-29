create or replace force view prc_ui_launch_file_vw as
select
    x.container_id
	, x.container_process_id
    , x.process_id
    , get_text (
        i_table_name    => 'prc_process'
        , i_column_name => 'name'
        , i_object_id   => p.id
        , i_lang        => l.lang
    ) process_name
    , p.inst_id
    , x.exec_order
    , f.id file_id
    , get_text (
        i_table_name    => 'prc_file'
        , i_column_name => 'name'
        , i_object_id   => f.id
        , i_lang        => l.lang
    ) file_name
    , f.file_purpose
    , f.file_type
    , f.file_nature
    , l.lang
from 
    prc_process p
    , prc_file f
    , ( select
            connect_by_root(id) container_id
            , connect_by_root(container_process_id) container_process_id
            , process_id
            , connect_by_root(exec_order) exec_order
        from
            prc_container
        connect by
            container_process_id = prior process_id
    ) x
    , com_language_vw l
where
    f.process_id = p.id
    and x.process_id = p.id
/
