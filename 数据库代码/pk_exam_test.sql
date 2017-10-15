create or replace package body pk_exam_test is
  /*****************************************************
  *添加题库明细
  *****************************************************/
  procedure pro_add_exa_questions_detail
  (
    questions_no in t_exa_questions.questions_no%type,
    subject_no in t_exa_questions.subject_no%type,
    questions_name in t_exa_questions.questions_name%type,
    questions_desc in t_exa_questions.questions_desc%type,
    question_list  in clob
  ) as
  
    --存放题目数组                            
    arr_str_que    dbms_sql.Varchar2_Table;
    arr_substr_que dbms_sql.Varchar2_Table;
  
    que_no   t_exa_question_Detailed.Question_No%type;
    que_num  t_exa_question_Detailed.Question_Num%type;
    que_type t_exa_question_detailed.question_type%type;
    que_name t_exa_question_detailed.question_name%type;
    que_key  t_exa_question_detailed.right_key%type;
  
    ans_num    t_exa_answer_info.answer_num%type;
    ans_name   t_exa_answer_info.answer_name%type;
    ans_istrue t_exa_answer_info.istrue%type;
    ans_str    varchar2(20);
    ans_xh     varchar2(20);
    ans_option integer;
  begin
  
    --插入题库
    insert into t_exa_questions
    values
      (questions_no, --题库编号
       subject_no, --科目编号
       questions_name, --题库名称
       questions_desc, --题库描述
       sysdate,
       sysdate);
  
    --从字符串中拆分获取题目
    arr_str_que := split(question_list, '@||@');
    for i in 1 .. arr_str_que.count - 1 loop
      --题目编号
      que_no := t_exa_question_detail_seq.nextval;
      --题目序号
      select max(d.question_num)
        into que_num
        from t_exa_question_detailed d;
      if que_num is null then
        que_num := 0;
      end if;
      que_num := que_num + 1;
    
      arr_substr_que := split(arr_str_que(i), '@|@');
      --题目名称
      que_name := (arr_substr_que(1));
      --题目类型
      que_type := (arr_substr_que(2));
      --题目答案
      que_key := (arr_substr_que(3));
    
      ----------------题目答案转换成数字---------------
      if que_type = 1 then
        case upper(que_key)
          when 'A' then
            ans_option := 1;
          when 'B' then
            ans_option := 2;
          when 'C' then
            ans_option := 3;
          when 'D' then
            ans_option := 4;
        end case;
      end if;
      if que_type = 2 then
        ans_str := transformation(que_key);
      end if;
    
      if que_type = 3 then
        case que_key
          when '对' then
            ans_option := 1;
          when '错' then
            ans_option := 2;
        end case;
      end if;
    
      --插入题目
      insert into t_exa_question_detailed
      values
        (que_no,
         que_num,
         que_type,
         que_name,
         que_key,
         questions_no,
         1,
         sysdate,
         sysdate);
    
      --单选题，多选题插入答案
      if que_type <> 3 then
        for n in 4 .. 7 loop
          --答案名称
          ans_name := arr_substr_que(n);
          --答案序号
          ans_xh := substr(ans_name, 0, 1);
          case upper(ans_xh)
            when 'A' then
              ans_num := 1;
            when 'B' then
              ans_num := 2;
            when 'C' then
              ans_num := 3;
            when 'D' then
              ans_num := 4;
          end case;
          --判断是否是正确答案
          if que_type = 2 then
            if instr(ans_str, ans_num || '') > 0 then
              ans_istrue := 1;
            else
              ans_istrue := 2;
            end if;
          else
            if ans_num = ans_option then
              ans_istrue := 1;
            else
              ans_istrue := 2;
            end if;
          end if;
          --插入答案
          insert into t_exa_answer_info
          values
            (t_exa_answer_info_seq.nextval,
             que_no,
             ans_num,
             ans_name,
             ans_istrue,
             sysdate,
             sysdate);
        end loop;
      
        --判断插入答案
      else
        for n in 4 .. 5 loop
        
          --答案名称
          ans_name := arr_substr_que(n);
          --答案序号
          ans_xh := substr(ans_name, 0, 1);
          case upper(ans_xh)
            when '对' then
              ans_num := 1;
            when '错' then
              ans_num := 2;
          end case;
          --判断是否是正确答案
          if ans_num = ans_option then
            ans_istrue := 1;
          else
            ans_istrue := 2;
          end if;
          --插入答案
          insert into t_exa_answer_info
          values
            (t_exa_answer_info_seq.nextval,
             que_no,
             ans_num,
             ans_name,
             ans_istrue,
             sysdate,
             sysdate);
        end loop;
      end if;
    end loop;
    commit;
  end;

  /*****************************************************
  *生成试卷模板
  *****************************************************/
  procedure pro_add_exa_paper(v_subject_no   t_subject_info.subject_no%type,
                              v_exam_name    in t_exa_paper.examination_name%type,
                              v_exam_content in t_exa_paper.examination_content%type,
                              v_exam_length  in t_exa_paper.exam_length%type,
                              v_create_user  t_exa_paper.create_user%type,
                              score_list     varchar2) as
    v_exam_no        t_exa_paper.examination_no%type;
    v_exam_type      t_exa_paper.examination_type%type;
    v_que_type       t_exa_paper_score.question_type%type;
    v_que_num        t_exa_paper_score.question_num%type;
    v_que_score      t_exa_paper_score.question_score%type;
    arr_str_score    dbms_sql.Varchar2_Table;
    arr_substr_score dbms_sql.Varchar2_Table;
    s_count          integer;
  begin
  
    select count(*)
      into s_count
      from t_subject_info
     where v_subject_no in (select father_subject from t_subject_info);
    if s_count = 0 then
      v_exam_type := 1;
    else
      v_exam_type := 2;
    end if;
    --生成试卷模板
    select decode(to_char(sysdate, 'yyyymmdd'),
                  substr(max(examination_no), 0, 8),
                  max(examination_no) + 1,
                  to_char(sysdate, 'yyyymmdd') || lpad(1, 6, 0))
      into v_exam_no
      from t_exa_paper;
    insert into t_exa_paper
    values
      (v_exam_no,
       v_exam_type,
       v_exam_name,
       v_exam_content,
       v_subject_no,
       v_exam_length,
       2,
       v_create_user,
       sysdate,
       sysdate);
  
    --插入分值表
    arr_str_score := split(score_list, '#');
    for j in 1 .. arr_str_score.count - 1 loop
      arr_substr_score := split(arr_str_score(j), '|');
      v_que_type       := arr_substr_score(1);
      v_que_num        := arr_substr_score(2);
      v_que_score      := arr_substr_score(3);
      insert into t_exa_paper_score
      values
        (v_exam_no,
         v_que_type,
         v_que_num,
         v_que_score,
         v_que_num * v_que_score,
         sysdate,
         sysdate);
    end loop;
    commit;
  end;

  /*****************************************************
  *生成试卷
  *****************************************************/
  procedure pro_add_exa_paper_info(v_examination_no in t_exa_paper.examination_no%type) as
    --随机取出三种题目类型结果集，并存入游标中
    --声明游标
    cursor paper_cursor1 is
      select *
        from (select * from v_paper order by dbms_random.value) t1
       where rownum <= t1.que_num
         and t1.exam_no = v_examination_no
         and t1.que_type = 1;
    cursor paper_cursor2 is
      select *
        from (select * from v_paper order by dbms_random.value) t1
       where rownum <= t1.que_num
         and t1.exam_no = v_examination_no
         and t1.que_type = 2;
    cursor paper_cursor3 is
      select *
        from (select * from v_paper order by dbms_random.value) t1
       where rownum <= t1.que_num
         and t1.exam_no = v_examination_no
         and t1.que_type = 3;
  
    cursor answer_cursor is
      select * from v_answer v where v.exa_no = v_examination_no;
  
    --定义游标变量（题目）
    cur_paper1 paper_cursor1%rowtype;
    cur_paper2 paper_cursor2%rowtype;
    cur_paper3 paper_cursor3%rowtype;
  
    --定义游标变量（答案）
    cur_answer answer_cursor%rowtype;
  
    --定义试卷内容主键
    paper_id t_exa_paper_info.examination_id%type;
  
    --定义答案表主键
    exa_list_id t_exa_paper_list.examinati_list_id%type;
  
    p_count integer;
  
  begin
    select count(*)
      into p_count
      from t_exa_paper_info p
     where p.examination_no = v_examination_no;
    if p_count = 0 then
      --插入单选题
      open paper_cursor1;
      loop
        fetch paper_cursor1
          into cur_paper1;
        exit when paper_cursor1%notfound;
        select decode(to_char(sysdate, 'yyyymmdd'),
                      substr(max(examination_id), 0, 8),
                      max(examination_id) + 1,
                      to_char(sysdate, 'yyyymmdd') || lpad(1, 6, 0))
          into paper_id
          from t_exa_paper_info;
      
        insert into t_exa_paper_info
        values
          (paper_id,
           v_examination_no,
           cur_paper1.que_no,
           cur_paper1.que_type,
           cur_paper1.que_xh,
           cur_paper1.que_name,
           cur_paper1.que_score,
           cur_paper1.que_key,
           sysdate,
           sysdate);
      end loop;
      close paper_cursor1;
    
      --插入多选题
      open paper_cursor2;
      loop
        fetch paper_cursor2
          into cur_paper2;
        exit when paper_cursor2%notfound;
        select decode(to_char(sysdate, 'yyyymmdd'),
                      substr(max(examination_id), 0, 8),
                      max(examination_id) + 1,
                      to_char(sysdate, 'yyyymmdd') || lpad(1, 6, 0))
          into paper_id
          from t_exa_paper_info;
      
        insert into t_exa_paper_info
        values
          (paper_id,
           v_examination_no,
           cur_paper2.que_no,
           cur_paper2.que_type,
           cur_paper2.que_xh,
           cur_paper2.que_name,
           cur_paper2.que_score,
           cur_paper2.que_key,
           sysdate,
           sysdate);
      end loop;
      close paper_cursor2;
    
      --插入判断题
      open paper_cursor3;
      loop
        fetch paper_cursor3
          into cur_paper3;
        exit when paper_cursor3%notfound;
        select decode(to_char(sysdate, 'yyyymmdd'),
                      substr(max(examination_id), 0, 8),
                      max(examination_id) + 1,
                      to_char(sysdate, 'yyyymmdd') || lpad(1, 6, 0))
          into paper_id
          from t_exa_paper_info;
      
        insert into t_exa_paper_info
        values
          (paper_id,
           v_examination_no,
           cur_paper3.que_no,
           cur_paper3.que_type,
           cur_paper3.que_xh,
           cur_paper3.que_name,
           cur_paper3.que_score,
           cur_paper3.que_key,
           sysdate,
           sysdate);
      end loop;
      close paper_cursor3;
    
      --插入试卷答案
      open answer_cursor;
      loop
        fetch answer_cursor
          into cur_answer;
        exit when answer_cursor%notfound;
        select decode(to_char(sysdate, 'yyyymmdd'),
                      substr(max(examinati_list_id), 0, 8),
                      max(examinati_list_id) + 1,
                      to_char(sysdate, 'yyyymmdd') || lpad(1, 6, 0))
          into exa_list_id
          from t_exa_paper_list;
      
        insert into t_exa_paper_list
        values
          (exa_list_id,
           cur_answer.exa_id,
           cur_answer.que_num,
           cur_answer.ans_num,
           cur_answer.ans_name,
           cur_answer.istrue,
           'teacher',
           sysdate,
           sysdate);
      end loop;
      close answer_cursor;
      
    --更新试卷状态（将状态改为有效）
    update t_exa_paper set state=1 where examination_no=v_examination_no;
      commit;
    end if;
  end;

  /*****************************************************
  *生成考试编号，答题卡
  *****************************************************/
  procedure pro_add_exam_info_no(exam_no in varchar2, num in integer) as
    exam_info_no t_examination_info.examination_info_no%type;
    cursor v_exam_cursor is
      select examination_id,
             examination_no,
             question_no,
             question_type,
             question_num,
             question_name,
             question_nscore,
             right_key
        from t_exa_paper_info
       where examination_no = exam_no;
  begin
  
    for i in 1 .. num loop
      select decode(to_char(sysdate, 'yyyymmdd'),
                    substr(max(examination_info_no), 0, 8),
                    max(examination_info_no) + 1,
                    to_char(sysdate, 'yyyymmdd') || lpad(1, 6, 0))
        into exam_info_no
        from t_examination_info;
        --初始化考试信息
      insert into t_examination_info
        (examination_info_no, examination_no)
      values
        (exam_info_no, exam_no);
         
      for mycur in v_exam_cursor loop
        insert into t_examination_list
          (id,
           examination_info_no,
           examination_id,
           question_no,
           question_type,
           question_num,
           right_key)
        values
          (seq_exam_list_id.nextval,
           exam_info_no,
           mycur.examination_id,
           mycur.question_no,
           mycur.question_type,
           mycur.question_num,
           mycur.right_key);
      end loop;
    end loop;
    commit;
  
  end;

  /*****************************************************
  *更新考试信息
  *****************************************************/
  procedure pro_add_exam_info(v_exam_user    in t_examination_info.examination_user%type,
                              v_exam_info_no in t_examination_info.examination_info_no%type,
                              answer_list    in varchar2,
                              right_num      out integer,
                              error_num      out integer,
                              total_score    out integer) as
    arr_str dbms_sql.Varchar2_Table;
  
    arr_substr1 dbms_sql.Varchar2_Table;
  
    arr_substr2 dbms_sql.Varchar2_Table;
  
    v_que_right_key t_exa_paper_info.right_key%type;
    v_que_score     t_exa_paper_info.question_nscore%type;
  
    v_right_sum integer := 0;
    v_error_sum integer := 0;
  
    exam_score integer := 0;
  
    v_right_key varchar2(20);
    v_que_type  number(2);
  begin
  
    arr_str := split(answer_list, '|');
  
    /*字符串截取，将题目id和选择的答案序号插入表中*/
    for i in 1 .. arr_str.count loop
      -------------------单选、判断题----------------------------
      if i <> 2 then
        arr_substr1 := split(arr_str(i), '$,');
        for n in 1 .. arr_substr1.count - 1 loop
          arr_substr2 := split(arr_substr1(n), ',');
          select t.right_key, t.question_nscore, t.question_type
            into v_que_right_key, v_que_score, v_que_type
            from t_exa_paper_info t
           where examination_id = arr_substr2(1);
          if v_que_type = 1 then
            v_right_key := transformation(arr_substr2(2));
          else
            if arr_substr2(2) = '1' then
              v_right_key := '对';
            else
              v_right_key := '错';
            end if;
          
          end if;
          if v_right_key = v_que_right_key then
            v_right_sum := v_right_sum + 1;
            exam_score  := exam_score + v_que_score;
          end if;
        
          --更新考试明细
          update t_examination_list
             set examination_info_no = v_exam_info_no,
                 choose_key          = v_right_key,
                 create_time         = sysdate
           where examination_id = arr_substr2(1)
             and examination_info_no = v_exam_info_no;
        end loop;
      
        ---------------------多选题----------------------------
      else
        arr_substr1 := split(arr_str(i), ',,@');
        for n in 2 .. arr_substr1.count loop
          arr_substr2 := split(arr_substr1(n), '@,');
          select t.right_key, t.question_nscore
            into v_que_right_key, v_que_score
            from t_exa_paper_info t
           where examination_id = arr_substr2(1);
        
          if transformation(arr_substr2(2)) = v_que_right_key then
            v_right_sum := v_right_sum + 1;
            exam_score  := exam_score + v_que_score;
          end if;
          --更新考试明细
          update t_examination_list
             set examination_info_no = v_exam_info_no,
                 choose_key          = transformation(arr_substr2(2)),
                 create_time         = sysdate
           where examination_id = arr_substr2(1)
             and examination_info_no = v_exam_info_no;
        end loop;
      end if;
    end loop;
    --获取错误数量
    select count(*) - v_right_sum
      into v_error_sum
      from t_examination_list
     where examination_info_no = v_exam_info_no;
    --插入考试信息表
    update t_examination_info
       set examination_user   = v_exam_user,
           right_num          = v_right_sum,
           error_num          = v_error_sum,
           score              = exam_score,
           examination_length = ceil((sysdate - start_time) * 24 * 60),
           end_time           = sysdate
     where examination_info_no = v_exam_info_no;
    commit;
    --返回参数
    right_num   := v_right_sum;
    error_num   := v_error_sum;
    total_score := exam_score;
  
  end;
end;
/
