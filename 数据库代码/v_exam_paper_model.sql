create or replace view v_exam_paper_model as
select p.examination_no,p.examination_type,p.examination_name,p.examination_content,
       p.exam_length,p.state,p.create_user ,sum(ps.total_score) as sum_score
from t_exa_paper p,t_exa_paper_score ps
where p.examination_no=ps.examination_no
group by  p.examination_no,p.examination_type,p.examination_name,p.examination_content,p.exam_length,
p.state,p.create_user;
