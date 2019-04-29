-- Transactional data tablespace
CREATE TABLESPACE trans_data_tbs LOGGING
     DATAFILE 'c:\oracle\oradata\sv\trans_data01.dbf' SIZE 4G REUSE
     EXTENT MANAGEMENT LOCAL
     SEGMENT SPACE MANAGEMENT AUTO;

CREATE TABLESPACE trans_indx_tbs LOGGING
     DATAFILE 'c:\oracle\oradata\sv\trans_indx01.dbf' SIZE 1G REUSE
     EXTENT MANAGEMENT LOCAL
     SEGMENT SPACE MANAGEMENT AUTO;

-- Business-objects data tablespace
CREATE TABLESPACE large_data_tbs LOGGING
     DATAFILE 'c:\oracle\oradata\sv\large_data01.dbf' SIZE 2G REUSE
     EXTENT MANAGEMENT LOCAL
     SEGMENT SPACE MANAGEMENT AUTO;

CREATE TABLESPACE large_indx_tbs LOGGING
     DATAFILE 'c:\oracle\oradata\sv\large_indx01.dbf' SIZE 512M REUSE
     EXTENT MANAGEMENT LOCAL
     SEGMENT SPACE MANAGEMENT AUTO;

-- Dictionary data tablespace
CREATE TABLESPACE small_data_tbs LOGGING
     DATAFILE 'c:\oracle\oradata\sv\small_data01.dbf' SIZE 256M REUSE
     EXTENT MANAGEMENT LOCAL
     SEGMENT SPACE MANAGEMENT AUTO;

CREATE TABLESPACE small_indx_tbs LOGGING
     DATAFILE 'c:\oracle\oradata\sv\small_indx01.dbf' SIZE 64M REUSE
     EXTENT MANAGEMENT LOCAL
     SEGMENT SPACE MANAGEMENT AUTO;

-- Encrypted data tablespace
CREATE TABLESPACE encrypt_data_tbs LOGGING
     DATAFILE 'c:\oracle\oradata\sv\encrypt_data01.dbf' SIZE 2G REUSE
     EXTENT MANAGEMENT LOCAL
     SEGMENT SPACE MANAGEMENT AUTO;

CREATE TABLESPACE encrypt_indx_tbs LOGGING
     DATAFILE 'c:\oracle\oradata\sv\encrypt_indx01.dbf' SIZE 512M REUSE
     EXTENT MANAGEMENT LOCAL
     SEGMENT SPACE MANAGEMENT AUTO;

-- User data tablespace
CREATE TABLESPACE user_data_tbs LOGGING
     DATAFILE 'c:\oracle\oradata\sv\user_data01.dbf' SIZE 64M REUSE
     EXTENT MANAGEMENT LOCAL
     SEGMENT SPACE MANAGEMENT AUTO;
