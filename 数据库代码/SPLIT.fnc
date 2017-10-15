CREATE OR REPLACE FUNCTION SPLIT(P_SOURCE VARCHAR2, P_F VARCHAR2) RETURN DBMS_SQL.VARCHAR2_TABLE IS
     V_POS     PLS_INTEGER; -- ��ǰ�ָ��λ��
      V_PRE_POS PLS_INTEGER; -- ǰһ���ָ���λ��
      V_NUM     PLS_INTEGER; -- Ԫ������
      V_RESULT  DBMS_SQL.VARCHAR2_TABLE; -- �����
      V_F_LEN   PLS_INTEGER; -- �ָ�������
    BEGIN
      V_NUM     := 1;
      V_F_LEN   := LENGTH(P_F);
      V_PRE_POS := 1 - V_F_LEN;
      LOOP
        V_POS := INSTR(P_SOURCE, P_F, V_PRE_POS + V_F_LEN);
        IF V_POS > 0 THEN
          V_RESULT(V_NUM) := SUBSTR(P_SOURCE,
                                    V_PRE_POS + V_F_LEN,
                                    V_POS - V_PRE_POS - V_F_LEN);
        ELSE
          V_RESULT(V_NUM) := SUBSTR(P_SOURCE, V_PRE_POS + V_F_LEN);
          EXIT;
        END IF;
        V_NUM     := V_NUM + 1;
        V_PRE_POS := V_POS;
      END LOOP;
      RETURN V_RESULT;
    END SPLIT;
/
