create table prc_file_saver (
    id               number(4)
    , seqnum         number(4)
    , source         varchar2(200)
    , is_parallel    number(1)
)
/

comment on table prc_file_saver is 'List of java classes for saving files of different types'
/
comment on column prc_file_saver.id is 'Primary key'
/
comment on column prc_file_saver.seqnum is 'Data version sequencial number'
/
comment on column prc_file_saver.source is 'Java class'
/
comment on column prc_file_saver.is_parallel is 'Is parallel threads'
/
comment on column prc_file_saver.source is 'The Saver Java class which is executed in any thread of process'
/
alter table prc_file_saver add (post_source varchar2(200))
/
comment on column prc_file_saver.post_source is 'The Post-Saver Java class which is executed after all threads of process'
/
