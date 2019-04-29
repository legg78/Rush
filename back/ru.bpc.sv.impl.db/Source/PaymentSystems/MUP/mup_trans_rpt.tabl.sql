create table mup_trans_rpt(
    id                     number(16)
  , inst_id                number(4)
  , file_id                number(8)
  , record_number          number(8)
  , status                 varchar2(8)
  , report_type            varchar2(8)
  , activity_type          varchar2(2)
  , de094                  number(11)
  , mti                    number(4)
  , de002                  varchar2(19)
  , de003                  number(6)
  , de004                  number(12)
  , de005                  number(12)
  , de009                  varchar2(11)
  , de012                  date
  , de022                  varchar2(12)
  , de024                  varchar2(3)
  , de025                  varchar2(4)
  , de026                  varchar2(4)
  , de031                  varchar2(23)
  , de037                  varchar2(12)
  , de038                  varchar2(6)
  , de040                  varchar2(3)
  , de041                  varchar2(8)
  , de042                  varchar2(15)
  , de043_123              varchar2(300)
  , de043_4                varchar2(99)
  , de043_5                varchar2(3)
  , de043_6                varchar2(3)
  , p0025_1                varchar2(1)
  , p0105                  date       
  , p0146                  varchar2(36)
  , p0148                  varchar2(4)
  , p0165                  varchar2(30)
  , p2158                  varchar2(18)
  , orig_transfer_agent_id varchar2(11)
  , p2159                  varchar2(25)
  , de049                  varchar2(3) 
  , de050                  varchar2(3) 
  , de054                  varchar2(120)
  , de063                  varchar2(16) 
  , de072                  varchar2(100)
)
/
comment on column mup_trans_rpt.id            is 'Primary key'
/
comment on column mup_trans_rpt.inst_id       is 'Institution id for report loading'
/
comment on column mup_trans_rpt.file_id       is 'File id'
/
comment on column mup_trans_rpt.record_number is 'Record number'
/
comment on column mup_trans_rpt.status        is 'Message status'
/
comment on column mup_trans_rpt.report_type   is 'ID of report header (HSIR / HAIR/ HOIR). Equals to mup_file.report_type'
/
comment on column mup_trans_rpt.activity_type is 'Member activity type ID ( A / I / F)'
/
comment on column mup_trans_rpt.de094         is 'Transaction Originator Institution ID Code'
/
comment on column mup_trans_rpt.mti           is 'MTI'
/
comment on column mup_trans_rpt.de002         is 'Primary Account Number [PAN]'
/
comment on column mup_trans_rpt.de003         is 'Processing Code'
/
comment on column mup_trans_rpt.de004         is 'Amount, Transaction'
/
comment on column mup_trans_rpt.de005         is 'Amount, Reconciliation'
/
comment on column mup_trans_rpt.de009         is 'Conversion Rate, Reconciliation'
/
comment on column mup_trans_rpt.de012         is 'Date and Time, Local Transaction'
/
comment on column mup_trans_rpt.de022         is 'Point of Service (POS) Entry Mode'
/
comment on column mup_trans_rpt.de024         is 'Function Code'
/
comment on column mup_trans_rpt.de025         is 'Message Reason Code'
/
comment on column mup_trans_rpt.de026         is 'Card Acceptor Business Code (MCC)'
/
comment on column mup_trans_rpt.de031         is 'Acquirer Reference Data'
/
comment on column mup_trans_rpt.de037         is 'Retrieval Reference Number (RRN)'
/
comment on column mup_trans_rpt.de038         is 'Approval Code'
/
comment on column mup_trans_rpt.de040         is 'Service Code'
/
comment on column mup_trans_rpt.de041         is 'Card Acceptor Terminal ID'
/
comment on column mup_trans_rpt.de042         is 'Card Acceptor ID Code'
/
comment on column mup_trans_rpt.de043_123     is 'Card Acceptor Name/Location'
/
comment on column mup_trans_rpt.de043_4       is 'Card Acceptor Postal (ZIP) Code'
/
comment on column mup_trans_rpt.de043_5       is 'Card Acceptor State, Province, or Region Code'
/
comment on column mup_trans_rpt.de043_6       is 'Card Acceptor Country Code'
/
comment on column mup_trans_rpt.p0025_1       is 'Message Reversal Indicator'
/
comment on column mup_trans_rpt.p0105         is 'File Reference Date'
/
comment on column mup_trans_rpt.p0146         is 'Amounts, Transaction Fee'
/
comment on column mup_trans_rpt.p0148         is 'Currency Exponents'
/
comment on column mup_trans_rpt.p0165         is 'Settlement Indicator'
/
comment on column mup_trans_rpt.p2158         is 'Financial Data'
/
comment on column mup_trans_rpt.orig_transfer_agent_id is 'Originator Transfer Agent ID'
/
comment on column mup_trans_rpt.p2159         is 'Settlement Data'
/
comment on column mup_trans_rpt.de049         is 'Currency Code, Transaction'
/
comment on column mup_trans_rpt.de050         is 'Currency Code, Reconciliation'
/
comment on column mup_trans_rpt.de054         is 'Amounts, Additional'
/
comment on column mup_trans_rpt.de063         is 'Transaction Life Cycle ID'
/
comment on column mup_trans_rpt.de072         is 'Data record (only for AIR report)'
/
