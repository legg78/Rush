create table atm_bna_counts (
    id                     number(12)
  , note_encashed_type4    number(5)
  , note_encashed_type3    number(5)
  , note_encashed_type2    number(5)
  , note_retracted_type4   number(5)
  , note_retracted_type3   number(5)
  , note_retracted_type2   number(5)
  , note_counterfeit_type3 number(5)
  , note_counterfeit_type2 number(5)
)
/

comment on table atm_bna_counts is 'ATM Bunch Note Acceptor (Cash-In) counters'
/
comment on column atm_bna_counts.id is 'Denomination identifier. Primary key. References atm_cash_in.id'
/
comment on column atm_bna_counts.note_encashed_type4 is 'Total number of category 4 (valid) encashed notes for denomination'
/
comment on column atm_bna_counts.note_encashed_type3 is 'Total number of category 3 (suspect) encashed notes for denomination'
/
comment on column atm_bna_counts.note_encashed_type2 is 'Total number of category 2 (counterfeit) encashed notes for denomination'
/
comment on column atm_bna_counts.note_retracted_type4 is 'Total number of category 4 (valid) retracted notes for denomination'
/
comment on column atm_bna_counts.note_retracted_type3 is 'Total number of category 3 (suspect) retracted notes for denomination'
/
comment on column atm_bna_counts.note_retracted_type2 is 'Total number of category 2 (counterfeit) retracted notes for denomination'
/
comment on column atm_bna_counts.note_counterfeit_type3 is 'Total number of category 3 (suspect) counterfeit notes for denomination'
/
comment on column atm_bna_counts.note_counterfeit_type2 is 'Total number of category 2 (counterfeit) counterfeit notes for denomination'
/
