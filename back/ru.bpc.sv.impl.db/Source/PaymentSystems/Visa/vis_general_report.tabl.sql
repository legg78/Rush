create table vis_general_report (
    id               number(16)
  , file_id          number(16)
  , dst_bin          varchar2(6)
  , src_bin          varchar2(6)
  , report_text      varchar2(132)
  , report_id        varchar2(10)
  , rep_day_seq_num  number(1)
  , rep_line_seq_num number(7)
  , reimb_attr       varchar2(1)
  , inst_id          number(4)
)
/

comment on table vis_general_report is 'Visa General Delivery Report records.'
/

comment on column vis_general_report.id is 'Primary key.'
/ 

comment on column vis_general_report.file_id is 'Reference to clearing file.'
/

comment on column vis_general_report.dst_bin is 'Destination BIN'
/

comment on column vis_general_report.src_bin is 'Source BIN'
/

comment on column vis_general_report.report_text is 'Report source text'
/

comment on column vis_general_report.report_id is 'Report ID'
/

comment on column vis_general_report.rep_day_seq_num is 'Report Day Sequence Number'
/

comment on column vis_general_report.rep_line_seq_num is 'Report Line Sequence Number'
/

comment on column vis_general_report.reimb_attr is 'Reimbursement Attribute.'
/

comment on column vis_general_report.inst_id is 'ID of the financial institution the record belongs to. '
/
