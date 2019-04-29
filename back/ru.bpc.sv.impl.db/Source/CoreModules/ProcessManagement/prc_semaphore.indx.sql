create unique index prc_semaphore_uk on prc_semaphore (session_id, semaphore_name)
/
drop index prc_semaphore_uk
/
create unique index prc_semaphore_uk on prc_semaphore (semaphore_name)
/
