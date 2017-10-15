create or replace view v_paper as
select
ps.examination_no as exam_no,
ps.question_type as que_type,
ps.question_num  as que_num,
ps.question_score as que_score,
qd.question_num as que_xh,
qd.question_no as que_no,
qd.question_name as que_name,
qd.right_key as que_key,
qd.state
from   t_exa_paper_score ps,t_exa_question_detailed qd
where ps.question_type=qd.question_type;
