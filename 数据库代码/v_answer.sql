create or replace view v_answer as
select
pi.examination_id as exa_id,
pi.examination_no as exa_no,
pi.question_no as que_no,
pi.question_type as que_type,
pi.question_num as que_num,
pi.question_name as que_name,
pi.question_nscore as que_score,
ai.answer_id as ans_id,
ai.answer_num as ans_num,
ai.answer_name as ans_name,
ai.istrue as istrue
from t_exa_paper_info pi,t_exa_answer_info ai
where pi.question_no=ai.question_no;
