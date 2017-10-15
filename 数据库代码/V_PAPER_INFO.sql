CREATE OR REPLACE VIEW V_PAPER_INFO AS
select
  ps.question_score as ps_score, --��ֵ
  p.examination_no as p_no,  -- �Ծ���
  ps.question_num as ps_num, --��Ŀ����
  p.create_user as p_user,  -- �û�
  qd.question_no as qd_no,-- ��Ŀ���
  qd.question_type as qd_type,--��Ŀ����
  qd.question_num as qd_num,-- ��Ŀ���
  qd.question_name as qd_name,--��Ŀ����
  qd.right_key as qd_key,-- ��ȷ��
  ai.answer_num as ai_num, --�����
  ai.answer_name as ai_name, --������
  ai.istrue as ai_istrue -- �Ƿ���ȷ
from
  t_exa_question_Detailed qd,
  t_exa_answer_info ai,
  t_exa_paper_score ps,
  t_exa_paper p
where qd.questions_no in
  (select t_exa_questions.questions_no from t_exa_questions where subject_no in
  (SELECT t_subject_info.subject_no from t_subject_info START WITH subject_no in
  (select si.subject_no from t_exa_paper p,t_subject_info si where p.subject_no=si.subject_no)
     CONNECT BY father_subject = PRIOR subject_no))
  and ai.question_no=qd.question_no
  and ps.question_type=qd.question_type order by qd.question_no,ai.answer_num
;
