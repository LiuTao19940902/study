create or replace package pk_exam_test
is     --添加试卷明细
       procedure pro_add_exa_questions_detail
       (
        questions_no in t_exa_questions.questions_no%type,
        subject_no in t_exa_questions.subject_no%type,
        questions_name in t_exa_questions.questions_name%type,
        questions_desc in t_exa_questions.questions_desc%type,
        question_list  in clob
       );
       --添加试卷
      procedure pro_add_exa_paper
      (
        v_subject_no in t_subject_info.subject_no%type,
        v_exam_name in t_exa_paper.examination_name%type,
        v_exam_content in t_exa_paper.examination_content%type,
        v_exam_length in t_exa_paper.exam_length%type,
        v_create_user t_exa_paper.create_user%type,
        
        score_list varchar2
      );
       --生成题目明细
       procedure pro_add_exa_paper_info
       (
                 v_examination_no in t_exa_paper.examination_no%type
       );
       
         --添加考试编号，答题卡
         procedure pro_add_exam_info_no(exam_no in varchar2, num in integer);
         
         --更新考试信息
         procedure pro_add_exam_info
         (
                   v_exam_user    in t_examination_info.examination_user%type,
                   v_exam_info_no in t_examination_info.examination_info_no%type,
                   answer_list    in varchar2,
                   right_num      out integer,
                   error_num      out integer,
                   total_score    out integer
         );
end;
/
