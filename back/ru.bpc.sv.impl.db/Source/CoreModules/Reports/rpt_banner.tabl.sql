create table rpt_banner (
    id          number(8)
  , seqnum      number(4)
  , status      varchar2(8)
  , filename    varchar2(200)
  , inst_id     number(4)
)
/

comment on table rpt_banner is 'List of marketing banners to publish in reports.'
/

comment on column rpt_banner.id is 'Primary key.'
/

comment on column rpt_banner.seqnum is 'Data version sequential number.'
/

comment on column rpt_banner.status is 'Banner status (Active, Inactive). Only active banners could be published in report.'
/

comment on column rpt_banner.filename is 'Path and filename of phisical file containing banner image.'
/

comment on column rpt_banner.inst_id is 'Institution identifier.'
/