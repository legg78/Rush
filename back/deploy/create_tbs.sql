 -- Transactional data tablespace
CREATE TABLESPACE trans_data_tbs LOGGING
     DATAFILE '/oradata/sv/trans_data01.dbf' SIZE 100M AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED
     EXTENT MANAGEMENT LOCAL
     SEGMENT SPACE MANAGEMENT AUTO;

CREATE TABLESPACE trans_indx_tbs LOGGING
     DATAFILE '/oradata/sv/trans_indx01.dbf' SIZE 100M AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED
     EXTENT MANAGEMENT LOCAL
     SEGMENT SPACE MANAGEMENT AUTO;

-- Business-objects data tablespace
CREATE TABLESPACE large_data_tbs LOGGING
     DATAFILE '/oradata/sv/large_data01.dbf' SIZE 100M AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED
     EXTENT MANAGEMENT LOCAL
     SEGMENT SPACE MANAGEMENT AUTO;

CREATE TABLESPACE large_indx_tbs LOGGING
     DATAFILE '/oradata/sv/large_indx01.dbf' SIZE 100M AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED
     EXTENT MANAGEMENT LOCAL
     SEGMENT SPACE MANAGEMENT AUTO;

-- Dictionary data tablespace
CREATE TABLESPACE small_data_tbs LOGGING
     DATAFILE '/oradata/sv/small_data01.dbf' SIZE 100M AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED
     EXTENT MANAGEMENT LOCAL
     SEGMENT SPACE MANAGEMENT AUTO;

CREATE TABLESPACE small_indx_tbs LOGGING
     DATAFILE '/oradata/sv/small_indx01.dbf' SIZE 100M AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED
     EXTENT MANAGEMENT LOCAL
     SEGMENT SPACE MANAGEMENT AUTO;

-- Encrypted data tablespace
CREATE TABLESPACE encrypt_data_tbs LOGGING
     DATAFILE '/oradata/sv/encrypt_data01.dbf' SIZE 100M AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED
     EXTENT MANAGEMENT LOCAL
     SEGMENT SPACE MANAGEMENT AUTO
     ENCRYPTION USING 'AES256'
     DEFAULT STORAGE(ENCRYPT);

CREATE TABLESPACE encrypt_indx_tbs LOGGING
     DATAFILE '/oradata/sv/encrypt_indx01.dbf' SIZE 100M AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED
     EXTENT MANAGEMENT LOCAL
     SEGMENT SPACE MANAGEMENT AUTO
     ENCRYPTION USING 'AES256'
     DEFAULT STORAGE(ENCRYPT);

-- User data tablespace
CREATE TABLESPACE user_data_tbs LOGGING
     DATAFILE '/oradata/sv/user_data01.dbf' SIZE 100M AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED
     EXTENT MANAGEMENT LOCAL
     SEGMENT SPACE MANAGEMENT AUTO;