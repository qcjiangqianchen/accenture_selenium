-- CP_STUD_HIST_SCHOOLING.MOVEMENT_TYPE_ICODE in ('NA','RA','TI','RA5','RA6') 
-- -> CP_STUD_HIST_SCHOOLING.MOVEMENT_DATE must be a School Day
-- 'N', -- gep_ind
-- 'Y'); -- ip_ind
-- ramdom_secondlanguage_l2_code_cursor
-- ramdom_secondlanguage_l2_Exp_NA_code_cursor
-- ramdom_secondlanguage_l2_NT_code_cursor
-- v_stream_xcode = '00';

\o 'S2-Non-IP-03_add_stud_n_staff.log'

\qecho '****************** PROCESS cp_stud_profile ******************'


select school_code,count(*) from cp01.cp_stud_profile where school_code between '9808' and '9808'
group by school_code;

BEGIN; 
DO $BLOCK$
DECLARE
    v_stud_per_class DOUBLE PRECISION := 30;
    v_current_year_stud_offset DOUBLE PRECISION := 80; -- e.g. 2098 to 2086

    v_person_id CHARACTER VARYING(20) := NULL;
    v_nric CHARACTER VARYING(9) := NULL;
    v_new_adm CHARACTER VARYING(10);
    v_current_year_yy CHARACTER VARYING(2) = substr(to_char(now(), 'YYYY')::text, 3, 2);
    v_count DOUBLE PRECISION := 1;
    v_31_year_yy CHARACTER VARYING(2) := substr((to_char(now(), 'YYYY')::NUMERIC + v_current_year_stud_offset - 13)::text, 3, 2);
    v_32_year_yy CHARACTER VARYING(2) := substr((to_char(now(), 'YYYY')::NUMERIC + v_current_year_stud_offset - 14)::text, 3, 2);
    v_33_year_yy CHARACTER VARYING(2) := substr((to_char(now(), 'YYYY')::NUMERIC + v_current_year_stud_offset - 15)::text, 3, 2);
    v_34_year_yy CHARACTER VARYING(2) := substr((to_char(now(), 'YYYY')::NUMERIC + v_current_year_stud_offset - 16)::text, 3, 2);
    v_35_year_yy CHARACTER VARYING(2) := substr((to_char(now(), 'YYYY')::NUMERIC + v_current_year_stud_offset - 17)::text, 3, 2);
    v_31_year_yyyy INT := (to_char(now(), 'YYYY')::NUMERIC - 13)::INT;
    v_32_year_yyyy INT := (to_char(now(), 'YYYY')::NUMERIC - 14)::INT;
    v_33_year_yyyy INT := (to_char(now(), 'YYYY')::NUMERIC - 15)::INT;
    v_34_year_yyyy INT := (to_char(now(), 'YYYY')::NUMERIC - 16)::INT;
    v_35_year_yyyy INT := (to_char(now(), 'YYYY')::NUMERIC - 17)::INT;
    v_stream_xcode CHARACTER VARYING(2);
    v_secondlanguage_l2_code CHARACTER VARYING(2);
    v_race CHARACTER VARYING(1);
    v_dob DATE;
    v_gender CHARACTER VARYING(1);
    v_primary_race CHARACTER VARYING(2);

    v_school CHARACTER VARYING(10) := NULL;
    v_start_sch DOUBLE PRECISION := 9808;
    v_end_sch DOUBLE PRECISION := 9808;
    
	context text;

    class_cursor CURSOR (v_sch TEXT) FOR
    SELECT * 
    FROM cp01.cp_arch_class 
    WHERE SCHOOL_CODE = v_sch AND ACADEMIC_YEAR = to_char(now(),'YYYY')
    ORDER BY LEVEL_XCODE, CLASS_XCODE;

    random_dob_cursor CURSOR (input_year INT) FOR
    SELECT
        DATE (input_year||'-01-01') + ( RANDOM() * (DATE (input_year||'-12-31') - DATE (input_year||'-01-01')) )::int;

    ramdom_secondlanguage_l2_code_cursor CURSOR FOR 
        SELECT ARRAY_ELE FROM (SELECT unnest(ARRAY['03','04','05','14','13','15']) ARRAY_ELE) ELEMENTS OFFSET MOD(FLOOR(RANDOM() * 400)::integer, 6) LIMIT 1;
        -- 02         | ENGLISH LANGUAGE
        -- 03         | CHINESE
        -- 04         | MALAY
        -- 05         | TAMIL
        -- 13         | BASIC CHINESE
        -- 14         | BASIC MALAY
        -- 15         | BASIC TAMIL

    ramdom_secondlanguage_l2_Exp_NA_code_cursor CURSOR FOR 
        SELECT ARRAY_ELE FROM (SELECT unnest(ARRAY['03','04','05']) ARRAY_ELE) ELEMENTS OFFSET MOD(FLOOR(RANDOM() * 400)::integer, 3) LIMIT 1;
    
    ramdom_secondlanguage_l2_NT_code_cursor CURSOR FOR 
        SELECT ARRAY_ELE FROM (SELECT unnest(ARRAY['14','13','15']) ARRAY_ELE) ELEMENTS OFFSET MOD(FLOOR(RANDOM() * 400)::integer, 3) LIMIT 1;

    get_race_cursor CURSOR (language TEXT) FOR 
        SELECT 
            case
                when language = '03' OR language = '13' OR language = '33' OR language = '51' then '2'
                when language = '04' OR language = '14' OR language = '34' OR language = '52' then '1'
                when language = '05' OR language = '15' OR language = '35' OR language = '53' then '3'
            end as race;

    get_primary_race_cursor CURSOR (race TEXT) FOR 
        SELECT 
            case
                when race = '2' then 'CN'
                when race = '1' then 'MY'
                when race = '3' then 'TM'
            end as primary_race;

    ramdom_gender_cursor CURSOR FOR 
        SELECT ARRAY_ELE FROM (SELECT unnest(ARRAY['F','M']) ARRAY_ELE) ELEMENTS OFFSET MOD(FLOOR(RANDOM() * 400)::integer, 2) LIMIT 1;

BEGIN
    WHILE v_start_sch <= v_end_sch LOOP
        v_school := trim(TO_CHAR(v_start_sch,'9999'));
        raise notice 'LOOP 1: %', v_school;
        v_start_sch := v_start_sch + 1;
		
        DELETE FROM cp01.cp_holding_stud_subj_link
		 WHERE subject_schooL_code  = v_school;
		
		DELETE FROM cp01.cp_holding_list
            WHERE school_code = v_school;
    
        DELETE FROM cp01.cp_stud_hist_promotion
            WHERE school_code = v_school;

        DELETE FROM cp01.cp_stud_profile
            WHERE school_code = v_school;

        FOR c IN class_cursor (v_school) LOOP
            /* Insert into cp_stud_profile */
            IF C.level_xcode = '31' THEN
                v_stream_xcode = '00';
                v_count := 1;
                WHILE v_count <= v_stud_per_class LOOP
                    SELECT lpad(NEXTVAL('cp01.seq_person')::varchar, 14, '0') INTO v_person_id;
                    SELECT * FROM cp_common_util.cp_generate_n_validate_nric('T', v_31_year_yy) INTO v_nric;
                    select * from cp_intf_pkg_i_pu.get_admission_no(v_school, v_current_year_yy, 'S') INTO v_new_adm; -- 'P'->PRI; 'S'->SEC
                    
                    open ramdom_secondlanguage_l2_code_cursor;
                    fetch ramdom_secondlanguage_l2_code_cursor into v_secondlanguage_l2_code;
                    close ramdom_secondlanguage_l2_code_cursor;

                    OPEN get_race_cursor(v_secondlanguage_l2_code);
                    FETCH get_race_cursor into v_race;
                    CLOSE get_race_cursor;

                    open get_primary_race_cursor(v_race);
                    fetch get_primary_race_cursor into v_primary_race;
                    close get_primary_race_cursor;

                    open random_dob_cursor(v_31_year_yyyy);
                    fetch random_dob_cursor into v_dob;
                    close random_dob_cursor;

                    open ramdom_gender_cursor;
                    fetch ramdom_gender_cursor into v_gender;
                    close ramdom_gender_cursor;

                    RAISE NOTICE 'STUD v_person_id: %; v_nric: %', v_person_id, v_nric;

                    INSERT INTO cp01.cp_arch_person (person_sys_code, uin_fin_no, creation_date, updated_by_id, person_type_icode)
                    VALUES (v_person_id, v_nric, now(), 'LT_DATAPREP', '1');

                    INSERT INTO cp01.cp_stud_profile (student_id, uin_fin_no, uinfin_type_icode, student_status_icode, student_name, 
                    school_code, admission_no, academic_year, 
                    level_xcode, stream_xcode, class_xcode, class_serial_no, course_type_code, hanyu_pinyin_name, 
                    birth_date, birthplace_code, citizenship_code, 
                    race_code, religion_code, sex_code, 
                    firstlanguage_l1_code, secondlanguage_l2_code, thirdlanguage_l3_code, 
                    guardian_type_icode, health_status_code, medical_condition_desc, repeat_stud_ind, 
                    gep_ind, 
                    intf_promotion_ind, class_wtd_ranking_mark_no, class_wtd_ranking_percent_no, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id, 
                    recommended_level_xcode, recommended_stream_xcode, acad_status_icode, 
                    email_address, rolledup_ind, primary_race_code, 
                    ip_ind) 
                    VALUES (v_person_id, v_nric, '2', 'A', CONCAT_WS('', 'STUDENT ', v_school, ' ', v_person_id), 
                    v_school, v_new_adm, to_char(now(), 'YYYY'), 
                    C.level_xcode, v_stream_xcode, C.class_xcode,  v_count, NULL, CONCAT_WS('', 'STUDENT ', v_school, ' ', v_person_id), 
                    v_dob, '01', '10', 
                    v_race, '0', v_gender, 
                    '02', v_secondlanguage_l2_code, '00', 
                    'M', 'M', 'NIL', 'N', 
                    'N', -- gep_ind
                    'N', '0', '0', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 
                    NULL, NULL, NULL, 
                    NULL, 'N', v_primary_race, 
                    'N'); -- ip_ind

                    v_count := v_count + 1;
                END LOOP;

            elsif C.level_xcode = '32' then
                if C.class_ref_name IN ('6','7') THEN 
                    v_stream_xcode = '20';
                elsif C.class_ref_name IN ('4','5') THEN
                    v_stream_xcode = '21';
                else 
                    v_stream_xcode = '22';
                end if;
                v_count := 1;
                WHILE v_count <= v_stud_per_class LOOP
                    SELECT lpad(NEXTVAL('cp01.seq_person')::varchar, 14, '0') INTO v_person_id;
                    SELECT * FROM cp_common_util.cp_generate_n_validate_nric('T', v_32_year_yy) INTO v_nric;
                    select * from cp_intf_pkg_i_pu.get_admission_no(v_school, v_current_year_yy, 'S') INTO v_new_adm; -- 'P'->PRI; 'S'->SEC
                    
                    if C.class_ref_name IN ('6','7') then 
                        open ramdom_secondlanguage_l2_NT_code_cursor;
                        fetch ramdom_secondlanguage_l2_NT_code_cursor into v_secondlanguage_l2_code;
                        close ramdom_secondlanguage_l2_NT_code_cursor;
                    else
                        open ramdom_secondlanguage_l2_Exp_NA_code_cursor;
                        fetch ramdom_secondlanguage_l2_Exp_NA_code_cursor into v_secondlanguage_l2_code;
                        close ramdom_secondlanguage_l2_Exp_NA_code_cursor;
                    end if;

                    OPEN get_race_cursor(v_secondlanguage_l2_code);
                    FETCH get_race_cursor into v_race;
                    CLOSE get_race_cursor;

                    open get_primary_race_cursor(v_race);
                    fetch get_primary_race_cursor into v_primary_race;
                    close get_primary_race_cursor;

                    open random_dob_cursor(v_32_year_yyyy);
                    fetch random_dob_cursor into v_dob;
                    close random_dob_cursor;

                    open ramdom_gender_cursor;
                    fetch ramdom_gender_cursor into v_gender;
                    close ramdom_gender_cursor;

                    RAISE NOTICE 'STUD v_person_id: %; v_nric: %', v_person_id, v_nric;

                    INSERT INTO cp01.cp_arch_person (person_sys_code, uin_fin_no, creation_date, updated_by_id, person_type_icode)
                    VALUES (v_person_id, v_nric, now(), 'LT_DATAPREP', '1');

                    INSERT INTO cp01.cp_stud_profile (student_id, uin_fin_no, uinfin_type_icode, student_status_icode, student_name, 
                    school_code, admission_no, academic_year, 
                    level_xcode, stream_xcode, class_xcode, class_serial_no, course_type_code, hanyu_pinyin_name, 
                    birth_date, birthplace_code, citizenship_code, 
                    race_code, religion_code, sex_code, 
                    firstlanguage_l1_code, secondlanguage_l2_code, thirdlanguage_l3_code, 
                    guardian_type_icode, health_status_code, medical_condition_desc, repeat_stud_ind, 
                    gep_ind, 
                    intf_promotion_ind, class_wtd_ranking_mark_no, class_wtd_ranking_percent_no, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id, 
                    recommended_level_xcode, recommended_stream_xcode, acad_status_icode, 
                    email_address, rolledup_ind, primary_race_code, 
                    ip_ind) 
                    VALUES (v_person_id, v_nric, '2', 'A', CONCAT_WS('', 'STUDENT ', v_school, ' ', v_person_id), 
                    v_school, v_new_adm, to_char(now(), 'YYYY'), 
                    C.level_xcode, v_stream_xcode, C.class_xcode,  v_count, NULL, CONCAT_WS('', 'STUDENT ', v_school, ' ', v_person_id), 
                    v_dob, '01', '10', 
                    v_race, '0', v_gender, 
                    '02', v_secondlanguage_l2_code, '00', 
                    'M', 'M', 'NIL', 'N', 
                    'N', -- gep_ind
                    'N', '0', '0', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 
                    NULL, NULL, NULL, 
                    NULL, 'N', v_primary_race, 
                    'N'); -- ip_ind

                    v_count := v_count + 1;
                END LOOP;

            elsif C.level_xcode = '33' then
                if C.class_ref_name IN ('6','7') THEN 
                    v_stream_xcode = '20';
                elsif C.class_ref_name IN ('4','5') THEN
                    v_stream_xcode = '21';
                else 
                    v_stream_xcode = '22';
                end if;
                v_count := 1;
                WHILE v_count <= v_stud_per_class LOOP
                    SELECT lpad(NEXTVAL('cp01.seq_person')::varchar, 14, '0') INTO v_person_id;
                    SELECT * FROM cp_common_util.cp_generate_n_validate_nric('T', v_33_year_yy) INTO v_nric;
                    select * from cp_intf_pkg_i_pu.get_admission_no(v_school, v_current_year_yy, 'S') INTO v_new_adm; -- 'P'->PRI; 'S'->SEC
                    
                    if C.class_ref_name IN ('6','7') then 
                        open ramdom_secondlanguage_l2_NT_code_cursor;
                        fetch ramdom_secondlanguage_l2_NT_code_cursor into v_secondlanguage_l2_code;
                        close ramdom_secondlanguage_l2_NT_code_cursor;
                    else
                        open ramdom_secondlanguage_l2_Exp_NA_code_cursor;
                        fetch ramdom_secondlanguage_l2_Exp_NA_code_cursor into v_secondlanguage_l2_code;
                        close ramdom_secondlanguage_l2_Exp_NA_code_cursor;
                    end if;

                    OPEN get_race_cursor(v_secondlanguage_l2_code);
                    FETCH get_race_cursor into v_race;
                    CLOSE get_race_cursor;

                    open get_primary_race_cursor(v_race);
                    fetch get_primary_race_cursor into v_primary_race;
                    close get_primary_race_cursor;

                    open random_dob_cursor(v_33_year_yyyy);
                    fetch random_dob_cursor into v_dob;
                    close random_dob_cursor;

                    open ramdom_gender_cursor;
                    fetch ramdom_gender_cursor into v_gender;
                    close ramdom_gender_cursor;

                    RAISE NOTICE 'STUD v_person_id: %; v_nric: %', v_person_id, v_nric;

                    INSERT INTO cp01.cp_arch_person (person_sys_code, uin_fin_no, creation_date, updated_by_id, person_type_icode)
                    VALUES (v_person_id, v_nric, now(), 'LT_DATAPREP', '1');

                    INSERT INTO cp01.cp_stud_profile (student_id, uin_fin_no, uinfin_type_icode, student_status_icode, student_name, 
                    school_code, admission_no, academic_year, 
                    level_xcode, stream_xcode, class_xcode, class_serial_no, course_type_code, hanyu_pinyin_name, 
                    birth_date, birthplace_code, citizenship_code, 
                    race_code, religion_code, sex_code, 
                    firstlanguage_l1_code, secondlanguage_l2_code, thirdlanguage_l3_code, 
                    guardian_type_icode, health_status_code, medical_condition_desc, repeat_stud_ind, 
                    gep_ind, 
                    intf_promotion_ind, class_wtd_ranking_mark_no, class_wtd_ranking_percent_no, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id, 
                    recommended_level_xcode, recommended_stream_xcode, acad_status_icode, 
                    email_address, rolledup_ind, primary_race_code, 
                    ip_ind) 
                    VALUES (v_person_id, v_nric, '2', 'A', CONCAT_WS('', 'STUDENT ', v_school, ' ', v_person_id), 
                    v_school, v_new_adm, to_char(now(), 'YYYY'), 
                    C.level_xcode, v_stream_xcode, C.class_xcode,  v_count, NULL, CONCAT_WS('', 'STUDENT ', v_school, ' ', v_person_id), 
                    v_dob, '01', '10', 
                    v_race, '0', v_gender, 
                    '02', v_secondlanguage_l2_code, '00', 
                    'M', 'M', 'NIL', 'N', 
                    'N', -- gep_ind
                    'N', '0', '0', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 
                    NULL, NULL, NULL, 
                    NULL, 'N', v_primary_race, 
                    'N'); -- ip_ind

                    v_count := v_count + 1;
                END LOOP;

            elsif C.level_xcode = '34' then
                if C.class_ref_name IN ('6','7') THEN 
                    v_stream_xcode = '20';
                elsif C.class_ref_name IN ('4','5') THEN
                    v_stream_xcode = '21';
                else 
                    v_stream_xcode = '22';
                end if;
                v_count := 1;
                WHILE v_count <= v_stud_per_class LOOP
                    SELECT lpad(NEXTVAL('cp01.seq_person')::varchar, 14, '0') INTO v_person_id;
                    SELECT * FROM cp_common_util.cp_generate_n_validate_nric('T', v_34_year_yy) INTO v_nric;
                    select * from cp_intf_pkg_i_pu.get_admission_no(v_school, v_current_year_yy, 'S') INTO v_new_adm; -- 'P'->PRI; 'S'->SEC
                    
                    if C.class_ref_name IN ('6','7') then 
                        open ramdom_secondlanguage_l2_NT_code_cursor;
                        fetch ramdom_secondlanguage_l2_NT_code_cursor into v_secondlanguage_l2_code;
                        close ramdom_secondlanguage_l2_NT_code_cursor;
                    else
                        open ramdom_secondlanguage_l2_Exp_NA_code_cursor;
                        fetch ramdom_secondlanguage_l2_Exp_NA_code_cursor into v_secondlanguage_l2_code;
                        close ramdom_secondlanguage_l2_Exp_NA_code_cursor;
                    end if;

                    OPEN get_race_cursor(v_secondlanguage_l2_code);
                    FETCH get_race_cursor into v_race;
                    CLOSE get_race_cursor;

                    open get_primary_race_cursor(v_race);
                    fetch get_primary_race_cursor into v_primary_race;
                    close get_primary_race_cursor;

                    open random_dob_cursor(v_34_year_yyyy);
                    fetch random_dob_cursor into v_dob;
                    close random_dob_cursor;

                    open ramdom_gender_cursor;
                    fetch ramdom_gender_cursor into v_gender;
                    close ramdom_gender_cursor;

                    RAISE NOTICE 'STUD v_person_id: %; v_nric: %', v_person_id, v_nric;

                    INSERT INTO cp01.cp_arch_person (person_sys_code, uin_fin_no, creation_date, updated_by_id, person_type_icode)
                    VALUES (v_person_id, v_nric, now(), 'LT_DATAPREP', '1');

                    INSERT INTO cp01.cp_stud_profile (student_id, uin_fin_no, uinfin_type_icode, student_status_icode, student_name, 
                    school_code, admission_no, academic_year, 
                    level_xcode, stream_xcode, class_xcode, class_serial_no, course_type_code, hanyu_pinyin_name, 
                    birth_date, birthplace_code, citizenship_code, 
                    race_code, religion_code, sex_code, 
                    firstlanguage_l1_code, secondlanguage_l2_code, thirdlanguage_l3_code, 
                    guardian_type_icode, health_status_code, medical_condition_desc, repeat_stud_ind, 
                    gep_ind, 
                    intf_promotion_ind, class_wtd_ranking_mark_no, class_wtd_ranking_percent_no, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id, 
                    recommended_level_xcode, recommended_stream_xcode, acad_status_icode, 
                    email_address, rolledup_ind, primary_race_code, 
                    ip_ind) 
                    VALUES (v_person_id, v_nric, '2', 'A', CONCAT_WS('', 'STUDENT ', v_school, ' ', v_person_id), 
                    v_school, v_new_adm, to_char(now(), 'YYYY'), 
                    C.level_xcode, v_stream_xcode, C.class_xcode,  v_count, NULL, CONCAT_WS('', 'STUDENT ', v_school, ' ', v_person_id), 
                    v_dob, '01', '10', 
                    v_race, '0', v_gender, 
                    '02', v_secondlanguage_l2_code, '00', 
                    'M', 'M', 'NIL', 'N', 
                    'N', -- gep_ind
                    'N', '0', '0', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 
                    NULL, NULL, NULL, 
                    NULL, 'N', v_primary_race, 
                    'N'); -- ip_ind

                    v_count := v_count + 1;
                END LOOP;

            elsif C.level_xcode = '35' then
                v_stream_xcode = '21';
                v_count := 1;
                WHILE v_count <= v_stud_per_class LOOP
                    SELECT lpad(NEXTVAL('cp01.seq_person')::varchar, 14, '0') INTO v_person_id;
                    SELECT * FROM cp_common_util.cp_generate_n_validate_nric('T', v_35_year_yy) INTO v_nric;
                    select * from cp_intf_pkg_i_pu.get_admission_no(v_school, v_current_year_yy, 'S') INTO v_new_adm; -- 'P'->PRI; 'S'->SEC
                    
                    open ramdom_secondlanguage_l2_Exp_NA_code_cursor;
                    fetch ramdom_secondlanguage_l2_Exp_NA_code_cursor into v_secondlanguage_l2_code;
                    close ramdom_secondlanguage_l2_Exp_NA_code_cursor;

                    OPEN get_race_cursor(v_secondlanguage_l2_code);
                    FETCH get_race_cursor into v_race;
                    CLOSE get_race_cursor;

                    open get_primary_race_cursor(v_race);
                    fetch get_primary_race_cursor into v_primary_race;
                    close get_primary_race_cursor;

                    open random_dob_cursor(v_35_year_yyyy);
                    fetch random_dob_cursor into v_dob;
                    close random_dob_cursor;

                    open ramdom_gender_cursor;
                    fetch ramdom_gender_cursor into v_gender;
                    close ramdom_gender_cursor;

                    RAISE NOTICE 'STUD v_person_id: %; v_nric: %', v_person_id, v_nric;

                    INSERT INTO cp01.cp_arch_person (person_sys_code, uin_fin_no, creation_date, updated_by_id, person_type_icode)
                    VALUES (v_person_id, v_nric, now(), 'LT_DATAPREP', '1');

                    INSERT INTO cp01.cp_stud_profile (student_id, uin_fin_no, uinfin_type_icode, student_status_icode, student_name, 
                    school_code, admission_no, academic_year, 
                    level_xcode, stream_xcode, class_xcode, class_serial_no, course_type_code, hanyu_pinyin_name, 
                    birth_date, birthplace_code, citizenship_code, 
                    race_code, religion_code, sex_code, 
                    firstlanguage_l1_code, secondlanguage_l2_code, thirdlanguage_l3_code, 
                    guardian_type_icode, health_status_code, medical_condition_desc, repeat_stud_ind, 
                    gep_ind, 
                    intf_promotion_ind, class_wtd_ranking_mark_no, class_wtd_ranking_percent_no, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id, 
                    recommended_level_xcode, recommended_stream_xcode, acad_status_icode, 
                    email_address, rolledup_ind, primary_race_code, 
                    ip_ind) 
                    VALUES (v_person_id, v_nric, '2', 'A', CONCAT_WS('', 'STUDENT ', v_school, ' ', v_person_id), 
                    v_school, v_new_adm, to_char(now(), 'YYYY'), 
                    C.level_xcode, v_stream_xcode, C.class_xcode,  v_count, NULL, CONCAT_WS('', 'STUDENT ', v_school, ' ', v_person_id), 
                    v_dob, '01', '10', 
                    v_race, '0', v_gender, 
                    '02', v_secondlanguage_l2_code, '00', 
                    'M', 'M', 'NIL', 'N', 
                    'N', -- gep_ind
                    'N', '0', '0', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 
                    NULL, NULL, NULL, 
                    NULL, 'N', v_primary_race, 
                    'N'); -- ip_ind

                    v_count := v_count + 1;
                END LOOP;
            END IF; /* C.level_xcode */
        END LOOP; /* class_cursor */
	END LOOP; /* v_start_sch */
	exception when others then 
		   get stacked diagnostics  context     = message_text;
	-- COMMIT;
	raise notice 'LOOP 1 END: %', context;
END
$BLOCK$;

COMMIT;

\qecho '****************** select count from cp_stud_profile ******************'
select  academic_year, school_code, level_xcode, stream_xcode, count(*) 
from cp01.cp_stud_profile where school_code between '9808' and '9808'
group by academic_year, school_code, level_xcode, stream_xcode
order by academic_year, school_code, level_xcode, stream_xcode;

\qecho '****************** PROCESS cp_staff_profile ******************'
SELECT
    school_code, COUNT(*)
    FROM cp01.cp_staff_profile
    WHERE school_code between '9808' and '9808'
	group by school_code; 

	
DO $BLOCK$
DECLARE
    v_current_year_staff_offset DOUBLE PRECISION := 20 + 1; -- e.g. staff age at least 50 yrs old with range of 20 years: 2050 to 2070
    v_gender CHARACTER VARYING(1);
    v_person_id CHARACTER VARYING(20) := NULL;
    v_nric CHARACTER VARYING(9) := NULL;
    v_no_of_staff INTEGER := 0;
    v_count DOUBLE PRECISION := 1;
    v_portal_group CHARACTER VARYING(20) := '4';
    v_school CHARACTER VARYING(10) := NULL;
    
    ramdom_gender_cursor CURSOR FOR 
        SELECT ARRAY_ELE FROM (SELECT unnest(ARRAY['F','M']) ARRAY_ELE) ELEMENTS OFFSET MOD(FLOOR(RANDOM() * 400)::integer, 2) LIMIT 1;

    sch_cur CURSOR FOR
    SELECT
        school_code
        FROM cp01.cp_arch_school
        WHERE school_code between '9808' and '9808';
    
    "avlRoles" CURSOR FOR
    SELECT
        a.role_code
        FROM cp01.cp_access_roles AS a, cp01.cp_conv_special_access_code AS b
        WHERE moe_role_type = 'S' AND
        /* -- moe_role_type. S - School Roles, H - HQ roles */
        a.role_code = b.role_xcode AND b.person_type = v_portal_group;
	
BEGIN
    FOR sch IN sch_cur LOOP
        v_school := sch.school_code;
        raise notice 'LOOP 2: %', v_school;

        DELETE FROM cp01.cp_tt_staff_subjclass_link
            WHERE school_code = v_school;
        DELETE FROM cp01.cp_access_matrix_role_link
            WHERE uid_code IN (SELECT UIN_FIN_NO FROM CP01.CP_STAFF_PROFILE  WHERE SCHOOL_CODE =v_school );
        DELETE FROM cp01.cp_access_matrix
            WHERE MOE_SCHOOl_CODE =v_school ;
        DELETE FROM cp01.cp_staff_profile
         WHERE  SCHOOL_CODE= v_school;
		v_count := 1;

        SELECT COUNT(CLASS_XCODE) INTO v_no_of_staff FROM CP01.CP_ARCH_CLASS WHERE ACADEMIC_YEAR = to_char(now(), 'YYYY') AND SCHOOL_CODE = v_school;
        WHILE v_count <= v_no_of_staff LOOP
            SELECT lpad(NEXTVAL('cp01.seq_person')::varchar, 14, '0') INTO v_person_id;
            SELECT * FROM cp_common_util.cp_generate_n_validate_nric('T', (SELECT (floor(random() * v_current_year_staff_offset) + 50)::text)) INTO v_nric;

            open ramdom_gender_cursor;
            fetch ramdom_gender_cursor into v_gender;
            close ramdom_gender_cursor;

            RAISE NOTICE 'staff v_person_id: %; v_nric: %', v_person_id, v_nric;

            INSERT INTO cp01.cp_arch_person (person_sys_code, uin_fin_no, creation_date, updated_by_id, person_type_icode)
            VALUES (v_person_id, v_nric, now(), 'LT_DATAPREP', '2');

            INSERT INTO cp01.cp_staff_profile (sex_type, staff_id, school_code, actual_school, uin_fin_no, nric_name, active_inactive_ind, created_online_ind, updated_by_id, new_school_code, new_school_effective_date, staff_abbrev_name, sc_acct_type, STAFF_TYPE, record_version_no, created_date, created_by_id, last_updated_date)
            VALUES (v_gender, v_person_id, v_school, v_school, v_nric, CONCAT_WS('', 'STAFF ', v_school, ' ', v_person_id), 'A', 'S', 'LT_DATAPREP', NULL, NULL, CONCAT_WS('', 'FSU', LPAD(v_count::TEXT, 3, 0::TEXT)), 'M', 'MOE HIRED', '1', now(), 'LT_DATAPREP', now());

            INSERT INTO cp01.cp_access_matrix (uid_code, moe_person_id, moe_person_status, user_password, moe_last_password_change_date, moe_login_attempt_no, moe_login_status, moe_school_code, moe_portal_view_icode, mobile, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_nric, v_person_id, 'Active', '{SHA}44rSFJQ9qtHWTBAvrsKd5K/p2j0=',TO_CHAR(now(), 'DDMMYYYY'), 0, 'Allowed', v_school, v_portal_group::NUMERIC, NULL, 1, now(), 'INTERFACE', now(), 'INTERFACE');

            FOR r1 IN "avlRoles" LOOP
                INSERT INTO cp01.cp_access_matrix_role_link (uid_code, moe_role_code, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
                VALUES (v_nric, r1.role_code, 1, now(), 'INTERFACE', now(), 'INTERFACE');
            END LOOP;
             
            v_count := v_count + 1;
        END LOOP;
		--COMMIT;
    END LOOP;
END
$BLOCK$;

COMMIT;

\qecho '****************** select count from cp_staff_profile ******************'
SELECT
    school_code, COUNT(1)
    FROM cp01.cp_staff_profile
    WHERE school_code between '9808' and '9808'
    GROUP BY school_code;
SELECT
    moe_school_code, COUNT(1)
    FROM cp01.cp_access_matrix
    WHERE moe_school_code between '9808' and '9808'
    GROUP BY moe_school_code;
SELECT
    COUNT(DISTINCT uid_code) unique_uid, COUNT(1)
    FROM cp01.cp_access_matrix_role_link
    WHERE uid_code IN (SELECT UIN_FIN_NO FROM cp01.cp_staff_profile WHERE school_code between '9808' and '9808');


DO $BLOCK$
DECLARE
    v_no_of_staff INTEGER := 0;
    v_school CHARACTER VARYING(10) := NULL;
    v_start_sch DOUBLE PRECISION := 9808;
    v_end_sch DOUBLE PRECISION := 9808;
    v_STAFF_ID CP01.CP_STAFF_PROFILE.STAFF_ID%TYPE;
    v_CLASS_XCODE CP01.CP_ARCH_CLASS.CLASS_XCODE%TYPE;

    staff_cursor CURSOR (v_sch TEXT, limit_no INTEGER) FOR
        SELECT STAFF_ID 
        FROM CP01.CP_STAFF_PROFILE WHERE SCHOOL_CODE = v_sch 
        ORDER BY CREATED_DATE DESC LIMIT limit_no;
    class_cursor CURSOR (v_sch TEXT, limit_no INTEGER) FOR
        SELECT CLASS_XCODE 
        FROM CP01.CP_ARCH_CLASS WHERE SCHOOL_CODE = v_sch AND ACADEMIC_YEAR = to_char(now(), 'YYYY') 
        ORDER BY CREATED_DATE DESC LIMIT limit_no;

BEGIN
    WHILE v_start_sch <= v_end_sch LOOP
        v_school := trim(TO_CHAR(v_start_sch,'9999'));
        raise notice 'LOOP 3 %', v_school;
        v_start_sch := v_start_sch + 1;

        SELECT COUNT(CLASS_XCODE) INTO v_no_of_staff FROM CP01.CP_ARCH_CLASS WHERE ACADEMIC_YEAR = to_char(now(), 'YYYY') AND SCHOOL_CODE = v_school;

        OPEN staff_cursor(v_school, v_no_of_staff);
        OPEN class_cursor(v_school, v_no_of_staff);
        
        LOOP
            FETCH staff_cursor INTO v_STAFF_ID;
            FETCH class_cursor INTO v_CLASS_XCODE;
            EXIT WHEN NOT FOUND;

            UPDATE cp01.cp_arch_class 
            set form_teacher_id = v_STAFF_ID WHERE SCHOOL_CODE = v_school AND ACADEMIC_YEAR = to_char(now(), 'YYYY') and class_xcode = v_CLASS_XCODE;
        END LOOP;

        CLOSE staff_cursor;
        CLOSE class_cursor;
    END LOOP;

END
$BLOCK$;

COMMIT;

\qecho 'BF cp_stud_hist_schooling'
select school_code, movement_year, count(*)  from cp01.cp_stud_hist_schooling
where school_code between '9808' and '9808' 
group by school_code, movement_year 
order by school_code, movement_year desc;

\qecho 'BF cp_stud_attendance'
select school_code, count(student_id) from cp01.cp_stud_attendance
where school_code between '9808' and '9808'
group by school_code
order by school_code;

BEGIN; 
DO $BLOCK$
DECLARE
    v_start_sch DOUBLE PRECISION := 9808;
    v_end_sch DOUBLE PRECISION := 9808;
    v_school CHARACTER VARYING(10) := NULL;

    get_stud_hist_promotion CURSOR (v_school_code TEXT) FOR
        SELECT distinct student_id, 
            school_code, school_name, 
            hist_admission_no, 
            level_xcode, level_name, stream_xcode,stream_name
        from cp01.cp_stud_hist_promotion
        where school_code = v_school_code and academic_year = TO_CHAR(NOW(), 'YYYY');
BEGIN
    WHILE v_start_sch <= v_end_sch LOOP
        v_school := trim(TO_CHAR(v_start_sch,'9999'));
        raise notice 'LOOP 4: %', v_school;
        v_start_sch := v_start_sch + 1;
        delete from cp01.cp_stud_attendance where schooL_code  = v_school;
        FOR v_stud IN get_stud_hist_promotion (v_school) LOOP
            raise notice 'populating cp_stud_hist_schooling for: %; from: %', v_stud.student_id, v_school;

            INSERT INTO cp01.cp_stud_hist_schooling (movement_sys_code, 
                student_id, 
                school_code, school_name, 
                admission_no, 
                movement_date, movement_year, movement_type_icode, 
                level_xcode, level_name, stream_xcode, stream_name, 
                record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (nextval('cp01.seq_movement'), 
            v_stud.student_id, 
            v_stud.school_code, v_stud.school_name,
            v_stud.hist_admission_no, 
            TO_DATE(to_char(now(), 'YYYY')||'-01-02', 'YYYY-MM-DD'), TO_CHAR(NOW(), 'YYYY'), 'NA', 
            v_stud.level_xcode, v_stud.level_name, v_stud.stream_xcode, v_stud.stream_name, 
            '1', TO_DATE(to_char(now(), 'YYYY')||'-01-02', 'YYYY-MM-DD'), 'INTERFACE', TO_DATE(to_char(now(), 'YYYY')||'-01-02', 'YYYY-MM-DD'), 'INTERFACE');
            INSERT INTO cp01.cp_stud_attendance (student_id, academic_year, school_code, actual_att_ca1, actual_att_ca2, actual_att_ca3, actual_att_ca4, total_days_ca1, total_days_ca2, total_days_ca3, total_days_ca4, manual_ind_ca1, manual_ind_ca2, manual_ind_ca3, manual_ind_ca4, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_stud.student_id, to_char(now(), 'YYYY'), v_stud.school_code, '50', '29', '60', '48', '50', '29', '60', '48', 'N', 'N', 'N', 'N', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
        END LOOP;
    END LOOP;

END
$BLOCK$;

COMMIT;

\qecho 'AF cp_stud_hist_schooling'
select school_code, movement_year, count(*)  from cp01.cp_stud_hist_schooling
where school_code between '9808' and '9808' 
group by school_code, movement_year 
order by school_code, movement_year desc;

\qecho 'AF cp_stud_attendance'
select school_code, count(student_id) from cp01.cp_stud_attendance
where school_code between '9808' and '9808'
group by school_code
order by school_code;