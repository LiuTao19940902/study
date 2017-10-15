create or replace view v_exam_paper_question as
select p.examination_no,p.examination_type,p.examination_name,p.exam_length,
pi.examination_id,pi.question_type,pi.question_num as question_xh,pi.question_name,pi.question_nscore,
ps.question_num,ps.question_score,ps.total_score,
pl.answer_content,pl.answer_num,pl.istrue
from t_exa_paper_info pi,t_exa_paper_score ps,t_exa_paper p,t_exa_paper_list pl
where p.examination_no=ps.examination_no and p.examination_no=pi.examination_no and pi.question_type=ps.question_type and pi.examination_id=pl.examination_id
order by pi.examination_no,pi.question_type,question_xh,pl.answer_num;
