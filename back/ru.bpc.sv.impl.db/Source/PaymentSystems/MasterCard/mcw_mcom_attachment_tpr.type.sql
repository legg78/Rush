create or replace type mcw_mcom_attachment_tpr as object (
    claim_id      varchar2(20)
  , message_id    varchar2(12)
  , file_name     varchar2(16)
  , file_content  clob
  , save_path     varchar2(2000)
)
/

alter type mcw_mcom_attachment_tpr modify attribute file_name varchar2(32) cascade
/
