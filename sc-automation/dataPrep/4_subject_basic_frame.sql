/* cp_cur_sch_gpa_subj_dtls - assign from online */
/* cp_cur_school_cay_subj_comp - assign from online */
/* cp_cur_school_cay_subj_grade - assign from online */
/* cp_cur_school_cay_subj_des - assign from online */
/* cp_cur_cay_course_stud_link - assign from online */
\o 'S2-Non-IP-04_subject_basic_frame.log'

\qecho 'cp_cur_aggregate_parameter'
SELECT SCHOOL_CODE, COUNT(*)
FROM cp01.cp_cur_aggregate_parameter
WHERE academic_year = TO_CHAR(NOW(),'YYYY') and school_code BETWEEN '9808' AND '9808'
GROUP BY SCHOOL_CODE;

\qecho 'cp_cur_passing_criteria_new'
SELECT SCHOOL_CODE, COUNT(*)
FROM cp01.cp_cur_passing_criteria_new 
where academic_year = TO_CHAR(NOW(),'YYYY') and school_code BETWEEN '9808' AND '9808'
GROUP BY SCHOOL_CODE;

\qecho 'cp_cur_passing_ind'
SELECT SCHOOL_CODE, COUNT(*)
FROM CP01.cp_cur_passing_ind
where academic_year = TO_CHAR(NOW(),'YYYY') and school_code BETWEEN '9808' AND '9808'
GROUP BY SCHOOL_CODE;

\qecho 'cp_cur_ranking_parameter'
select school_code, level_xcode, count(*)
from cp01.cp_cur_ranking_parameter
where academic_year = TO_CHAR(NOW(),'YYYY') and school_code BETWEEN '9808' AND '9808'
group by school_code, level_xcode
order by school_code, level_xcode;

\qecho 'cp_cur_sch_gpa'
SELECT A.SCHOOL_CODE, COUNT(*) 
FROM cp01.cp_cur_sch_gpa A
WHERE a.academic_year = TO_CHAR(NOW(),'YYYY') and a.school_code BETWEEN '9808' AND '9808'
GROUP BY A.SCHOOL_CODE;

\qecho 'cp_cur_sch_gpa_cat_dtls'
select a.school_code, count(*) 
from cp01.cp_cur_sch_gpa a inner join cp01.cp_cur_sch_gpa_cat_dtls b on a.gpa_sys_code = b.gpa_sys_code 
where a.academic_year = TO_CHAR(NOW(),'YYYY') and a.school_code BETWEEN '9808' AND '9808' 
GROUP BY A.SCHOOL_CODE;

\qecho 'cp_cur_cay_sch_grdscheme'
SELECT A.SCHOOL_CODE, COUNT(*) 
FROM CP20.cp_cur_cay_sch_grdscheme A
WHERE a.academic_year = TO_CHAR(NOW(),'YYYY') and a.school_code BETWEEN '9808' AND '9808'
GROUP BY A.SCHOOL_CODE;

\qecho 'cp_cur_cay_sch_grdscheme_dtls'
SELECT A.SCHOOL_CODE, COUNT(*) 
FROM CP20.cp_cur_cay_sch_grdscheme A INNER JOIN cp20.cp_cur_cay_sch_grdscheme_dtls B ON A.grdscheme_sys_code = B.grdscheme_sys_code
WHERE a.academic_year = TO_CHAR(NOW(),'YYYY') and a.school_code BETWEEN '9808' AND '9808'
GROUP BY A.SCHOOL_CODE;

\qecho 'cp_cur_school_cay_subj'
SELECT subject_school_code, level_xcode , stream_xcode, subject_level_icode, program_ind, gep_ind, COUNT(*)
FROM CP20.cp_cur_school_cay_subj
WHERE academic_year = TO_CHAR(NOW(),'YYYY') and subject_school_code BETWEEN '9808' AND '9808'
GROUP BY subject_school_code, level_xcode , stream_xcode, subject_level_icode, program_ind, gep_ind
ORDER BY subject_school_code, level_xcode , stream_xcode, subject_level_icode, program_ind, gep_ind;

\qecho 'cp_cur_cay_course'
SELECT SCHOOL_CODE, LEVEL_XCODE, program_ind, Count(*) 
FROM cp20.cp_cur_cay_course 
WHERE ACADEMIC_YEAR = TO_CHAR(NOW(), 'YYYY')
AND SCHOOL_CODE BETWEEN '9808' AND '9808'
GROUP BY SCHOOL_CODE, LEVEL_XCODE, program_ind;

\qecho 'cp_cur_cay_course_subj_link'
SELECT A.SCHOOL_CODE, a.level_xcode, a.program_ind, COUNT(*) 
from cp20.cp_cur_cay_course a inner join cp20.cp_cur_cay_course_subj_link b on a.course_sys_code = b.course_refid
WHERE a.ACADEMIC_YEAR = TO_CHAR(NOW(), 'YYYY')
AND a.SCHOOL_CODE BETWEEN '9808' AND '9808'
GROUP BY A.SCHOOL_CODE, a.level_xcode, a.program_ind
order by A.SCHOOL_CODE, a.level_xcode, a.program_ind;

DO $BLOCK$
DECLARE
    v_school CHARACTER VARYING(10) := NULL;
    v_start_sch DOUBLE PRECISION := 9808;
    v_end_sch DOUBLE PRECISION := 9808;
	v_course_sys_code  CHARACTER VARYING(15) := NULL; 
	v_SEQ_GPA_SYSCODE  CHARACTER VARYING(14) := NULL; 
	v_grdscheme_sys_code CHARACTER VARYING(14) := NULL;

	v_previous_year CHARACTER VARYING(4) := (to_char(now(), 'YYYY')::NUMERIC - 1)::text;
    v_current_year CHARACTER VARYING(4) := to_char(now(), 'YYYY');
BEGIN
    WHILE v_start_sch <= v_end_sch LOOP
        v_school := TRIM(to_char(v_start_sch,'9999'));
        v_start_sch := v_start_sch + 1;
		raise notice 'LOOP1 %', v_school;

        DELETE FROM cp01.cp_cur_aggregate_parameter
            WHERE school_code = v_school and academic_year in (v_previous_year, v_current_year);

		

        /* Insert into cp_cur_aggregate parameter */ 
		INSERT INTO cp01.cp_cur_aggregate_parameter (school_code, level_xcode, stream_xcode, ovrl_total_subject_no, l3_replacement_icode, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id, level_param_changed_ind, academic_year, ovrl_total_subject_no_schm, overall_total_criteria, ip_results_based_on, ip_moe_subject_no, ip_school_based_subject_no)
        VALUES (v_school, '31', '00', '0', '4', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', to_char(now(), 'YYYY')::NUMERIC - 1, '0', 'M', 'M', NULL, '0');
		INSERT INTO cp01.cp_cur_aggregate_parameter (school_code, level_xcode, stream_xcode, ovrl_total_subject_no, l3_replacement_icode, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id, level_param_changed_ind, academic_year, ovrl_total_subject_no_schm, overall_total_criteria, ip_results_based_on, ip_moe_subject_no, ip_school_based_subject_no)
        VALUES (v_school, '31', '00', '0', '4', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', to_char(now(), 'YYYY'), '0', 'M', 'M', NULL, '0');
		
		INSERT INTO cp01.cp_cur_aggregate_parameter (school_code, level_xcode, stream_xcode, ovrl_total_subject_no, l3_replacement_icode, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id, level_param_changed_ind, academic_year, ovrl_total_subject_no_schm, overall_total_criteria, ip_results_based_on, ip_moe_subject_no, ip_school_based_subject_no)
        VALUES (v_school, '32', '22', '9', '4', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', to_char(now(), 'YYYY')::NUMERIC - 1, '0', 'M', 'M', NULL, '0');
		INSERT INTO cp01.cp_cur_aggregate_parameter (school_code, level_xcode, stream_xcode, ovrl_total_subject_no, l3_replacement_icode, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id, level_param_changed_ind, academic_year, ovrl_total_subject_no_schm, overall_total_criteria, ip_results_based_on, ip_moe_subject_no, ip_school_based_subject_no)
        VALUES (v_school, '32', '21', '8', '4', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', to_char(now(), 'YYYY')::NUMERIC - 1, '0', 'M', 'M', NULL, '0');
		INSERT INTO cp01.cp_cur_aggregate_parameter (school_code, level_xcode, stream_xcode, ovrl_total_subject_no, l3_replacement_icode, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id, level_param_changed_ind, academic_year, ovrl_total_subject_no_schm, overall_total_criteria, ip_results_based_on, ip_moe_subject_no, ip_school_based_subject_no)
        VALUES (v_school, '32', '20', '7', '4', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', to_char(now(), 'YYYY')::NUMERIC - 1, '0', 'M', 'M', NULL, '0');
		INSERT INTO cp01.cp_cur_aggregate_parameter (school_code, level_xcode, stream_xcode, ovrl_total_subject_no, l3_replacement_icode, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id, level_param_changed_ind, academic_year, ovrl_total_subject_no_schm, overall_total_criteria, ip_results_based_on, ip_moe_subject_no, ip_school_based_subject_no)
        VALUES (v_school, '32', '00', '0', '4', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', to_char(now(), 'YYYY'), '0', 'M', 'M', NULL, '0');
		
        
		INSERT INTO cp01.cp_cur_aggregate_parameter (school_code, level_xcode, stream_xcode, ovrl_total_subject_no, l3_replacement_icode, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id, level_param_changed_ind, academic_year, ovrl_total_subject_no_schm, overall_total_criteria, ip_results_based_on, ip_moe_subject_no, ip_school_based_subject_no)
        VALUES (v_school, '33', '22', '9', '4', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', to_char(now(), 'YYYY')::NUMERIC - 1, '0', 'M', 'M', NULL, '0');
		INSERT INTO cp01.cp_cur_aggregate_parameter (school_code, level_xcode, stream_xcode, ovrl_total_subject_no, l3_replacement_icode, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id, level_param_changed_ind, academic_year, ovrl_total_subject_no_schm, overall_total_criteria, ip_results_based_on, ip_moe_subject_no, ip_school_based_subject_no)
        VALUES (v_school, '33', '21', '8', '4', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', to_char(now(), 'YYYY')::NUMERIC - 1, '0', 'M', 'M', NULL, '0');
		INSERT INTO cp01.cp_cur_aggregate_parameter (school_code, level_xcode, stream_xcode, ovrl_total_subject_no, l3_replacement_icode, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id, level_param_changed_ind, academic_year, ovrl_total_subject_no_schm, overall_total_criteria, ip_results_based_on, ip_moe_subject_no, ip_school_based_subject_no)
        VALUES (v_school, '33', '20', '7', '4', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', to_char(now(), 'YYYY')::NUMERIC - 1, '0', 'M', 'M', NULL, '0');
		INSERT INTO cp01.cp_cur_aggregate_parameter (school_code, level_xcode, stream_xcode, ovrl_total_subject_no, l3_replacement_icode, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id, level_param_changed_ind, academic_year, ovrl_total_subject_no_schm, overall_total_criteria, ip_results_based_on, ip_moe_subject_no, ip_school_based_subject_no)
		VALUES (v_school, '33', '22', '9', '4', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', to_char(now(), 'YYYY'), '0', 'M', 'M', NULL, '0');
		INSERT INTO cp01.cp_cur_aggregate_parameter (school_code, level_xcode, stream_xcode, ovrl_total_subject_no, l3_replacement_icode, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id, level_param_changed_ind, academic_year, ovrl_total_subject_no_schm, overall_total_criteria, ip_results_based_on, ip_moe_subject_no, ip_school_based_subject_no)
		VALUES (v_school, '33', '21', '8', '4', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', to_char(now(), 'YYYY'), '0', 'M', 'M', NULL, '0');
		INSERT INTO cp01.cp_cur_aggregate_parameter (school_code, level_xcode, stream_xcode, ovrl_total_subject_no, l3_replacement_icode, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id, level_param_changed_ind, academic_year, ovrl_total_subject_no_schm, overall_total_criteria, ip_results_based_on, ip_moe_subject_no, ip_school_based_subject_no)
		VALUES (v_school, '33', '20', '7', '4', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', to_char(now(), 'YYYY'), '0', 'M', 'M', NULL, '0');

		INSERT INTO cp01.cp_cur_aggregate_parameter (school_code, level_xcode, stream_xcode, ovrl_total_subject_no, l3_replacement_icode, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id, level_param_changed_ind, academic_year, ovrl_total_subject_no_schm, overall_total_criteria, ip_results_based_on, ip_moe_subject_no, ip_school_based_subject_no)
        VALUES (v_school, '34', '22', '9', '4', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', to_char(now(), 'YYYY')::NUMERIC - 1, '0', 'M', 'M', NULL, '0');
		INSERT INTO cp01.cp_cur_aggregate_parameter (school_code, level_xcode, stream_xcode, ovrl_total_subject_no, l3_replacement_icode, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id, level_param_changed_ind, academic_year, ovrl_total_subject_no_schm, overall_total_criteria, ip_results_based_on, ip_moe_subject_no, ip_school_based_subject_no)
        VALUES (v_school, '34', '21', '8', '4', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', to_char(now(), 'YYYY')::NUMERIC - 1, '0', 'M', 'M', NULL, '0');
		INSERT INTO cp01.cp_cur_aggregate_parameter (school_code, level_xcode, stream_xcode, ovrl_total_subject_no, l3_replacement_icode, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id, level_param_changed_ind, academic_year, ovrl_total_subject_no_schm, overall_total_criteria, ip_results_based_on, ip_moe_subject_no, ip_school_based_subject_no)
        VALUES (v_school, '34', '20', '7', '4', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', to_char(now(), 'YYYY')::NUMERIC - 1, '0', 'M', 'M', NULL, '0');
		INSERT INTO cp01.cp_cur_aggregate_parameter (school_code, level_xcode, stream_xcode, ovrl_total_subject_no, l3_replacement_icode, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id, level_param_changed_ind, academic_year, ovrl_total_subject_no_schm, overall_total_criteria, ip_results_based_on, ip_moe_subject_no, ip_school_based_subject_no)
		VALUES (v_school, '34', '22', '9', '4', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', to_char(now(), 'YYYY'), '0', 'M', 'M', NULL, '0');
		INSERT INTO cp01.cp_cur_aggregate_parameter (school_code, level_xcode, stream_xcode, ovrl_total_subject_no, l3_replacement_icode, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id, level_param_changed_ind, academic_year, ovrl_total_subject_no_schm, overall_total_criteria, ip_results_based_on, ip_moe_subject_no, ip_school_based_subject_no)
		VALUES (v_school, '34', '21', '8', '4', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', to_char(now(), 'YYYY'), '0', 'M', 'M', NULL, '0');
		INSERT INTO cp01.cp_cur_aggregate_parameter (school_code, level_xcode, stream_xcode, ovrl_total_subject_no, l3_replacement_icode, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id, level_param_changed_ind, academic_year, ovrl_total_subject_no_schm, overall_total_criteria, ip_results_based_on, ip_moe_subject_no, ip_school_based_subject_no)
		VALUES (v_school, '34', '20', '7', '4', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', to_char(now(), 'YYYY'), '0', 'M', 'M', NULL, '0');
		
		
		INSERT INTO cp01.cp_cur_aggregate_parameter (school_code, level_xcode, stream_xcode, ovrl_total_subject_no, l3_replacement_icode, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id, level_param_changed_ind, academic_year, ovrl_total_subject_no_schm, overall_total_criteria, ip_results_based_on, ip_moe_subject_no, ip_school_based_subject_no)
        VALUES (v_school, '35', '21', '8', '4', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', to_char(now(), 'YYYY')::NUMERIC - 1, '0', 'M', 'M', NULL, '0');
		INSERT INTO cp01.cp_cur_aggregate_parameter (school_code, level_xcode, stream_xcode, ovrl_total_subject_no, l3_replacement_icode, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id, level_param_changed_ind, academic_year, ovrl_total_subject_no_schm, overall_total_criteria, ip_results_based_on, ip_moe_subject_no, ip_school_based_subject_no)
		VALUES (v_school, '35', '21', '8', '4', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', to_char(now(), 'YYYY'), '0', 'M', 'M', NULL, '0');

		/* cp_cur_passing_criteria_new - NO DATA */
		/* HARDCODED */
        DELETE FROM CP01.cp_cur_passing_ind WHERE school_code = v_school AND academic_year = TO_CHAR(NOW(),'YYYY');
		INSERT INTO CP01.cp_cur_passing_ind(academic_year , school_code , level_xcode , break_tie_icode , pass_gpa_score , new_rank_pts_olevel_mt_ind , new_rank_pts_gsc_ind , h2_downgrade_ind , new_rank_pts_aolevel_mt_ind , new_rank_pts_h1ntil_ind , new_rank_pts_h1fl_ind , record_version_no ,    created_date     , created_by_id ,  last_updated_date  , updated_by_id , subject1_code , subject1_gpa , subject2_code , subject2_gpa) VALUES
			(TO_CHAR(NOW(),'YYYY'), v_school, '31', 'NA', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP', NULL, NULL, NULL, NULL),
			(TO_CHAR(NOW(),'YYYY'), v_school, '32', 'NA', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP', NULL, NULL, NULL, NULL),
			(TO_CHAR(NOW(),'YYYY'), v_school, '33', 'NA', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP', NULL, NULL, NULL, NULL),
			(TO_CHAR(NOW(),'YYYY'), v_school, '34', 'NA', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP', NULL, NULL, NULL, NULL),
			(TO_CHAR(NOW(),'YYYY'), v_school, '35', 'NA', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP', NULL, NULL, NULL, NULL);

		/* cp_cur_ranking_parameter - NO DATA */

		/* SCHB subjects only */
		INSERT INTO CP20.cp_cur_school_cay_subj (id                , subject_school_code , academic_year , level_xcode , stream_xcode , subject_code , gep_ind , subject_level_icode , examinable_ind ,                      subject_desc                       , show_in_resultslip_ind , subject_category , for_total_ind , include_tmt_ind , order_no , grade_ind , national_exam_subj_code , h1h2_gradeonly_ind , school_offering_status_icode , level_name , stream_name , threshold , weight , version_no ,         created_ts         ,   created_by   ,         updated_ts         ,   updated_by   , delete_ind , program_ind ,     abbreviation     , subject_language_medium_code , subject_type_code , offered_as_l1 , offered_as_l2 , offered_as_l3) VALUES (replace(public.uuid_generate_v4()::text,'-',''), v_school, TO_CHAR(NOW(),'YYYY'),'31','00','0SS1-1','N','05','N','FT','Y','SCHB','Y','Y',1535,'Y',NULL,NULL,'A','S1','NIL',0,1,1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP', 'N','0','FT',NULL,NULL,NULL,NULL,NULL);
		INSERT INTO CP20.cp_cur_school_cay_subj (id                , subject_school_code , academic_year , level_xcode , stream_xcode , subject_code , gep_ind , subject_level_icode , examinable_ind ,                      subject_desc                       , show_in_resultslip_ind , subject_category , for_total_ind , include_tmt_ind , order_no , grade_ind , national_exam_subj_code , h1h2_gradeonly_ind , school_offering_status_icode , level_name , stream_name , threshold , weight , version_no ,         created_ts         ,   created_by   ,         updated_ts         ,   updated_by   , delete_ind , program_ind ,     abbreviation     , subject_language_medium_code , subject_type_code , offered_as_l1 , offered_as_l2 , offered_as_l3) VALUES (replace(public.uuid_generate_v4()::text,'-',''), v_school, TO_CHAR(NOW(),'YYYY'),'32','00','0SS2-1','N','05','N','FT','Y','SCHB','Y','Y',1535,'Y',NULL,NULL,'A','S2','NIL',0,1,1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP', 'N','0','FT',NULL,NULL,NULL,NULL,NULL);
		INSERT INTO CP20.cp_cur_school_cay_subj (id                , subject_school_code , academic_year , level_xcode , stream_xcode , subject_code , gep_ind , subject_level_icode , examinable_ind ,                      subject_desc                       , show_in_resultslip_ind , subject_category , for_total_ind , include_tmt_ind , order_no , grade_ind , national_exam_subj_code , h1h2_gradeonly_ind , school_offering_status_icode , level_name , stream_name , threshold , weight , version_no ,         created_ts         ,   created_by   ,         updated_ts         ,   updated_by   , delete_ind , program_ind ,     abbreviation     , subject_language_medium_code , subject_type_code , offered_as_l1 , offered_as_l2 , offered_as_l3) VALUES (replace(public.uuid_generate_v4()::text,'-',''), v_school, TO_CHAR(NOW(),'YYYY'),'33','00','0SS3-1','N','05','N','FT','Y','SCHB','Y','Y',1535,'Y',NULL,NULL,'A','S3','NIL',0,1,1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP', 'N','0','FT',NULL,NULL,NULL,NULL,NULL);
		INSERT INTO CP20.cp_cur_school_cay_subj (id                , subject_school_code , academic_year , level_xcode , stream_xcode , subject_code , gep_ind , subject_level_icode , examinable_ind ,                      subject_desc                       , show_in_resultslip_ind , subject_category , for_total_ind , include_tmt_ind , order_no , grade_ind , national_exam_subj_code , h1h2_gradeonly_ind , school_offering_status_icode , level_name , stream_name , threshold , weight , version_no ,         created_ts         ,   created_by   ,         updated_ts         ,   updated_by   , delete_ind , program_ind ,     abbreviation     , subject_language_medium_code , subject_type_code , offered_as_l1 , offered_as_l2 , offered_as_l3) VALUES (replace(public.uuid_generate_v4()::text,'-',''), v_school, TO_CHAR(NOW(),'YYYY'),'34','00','0SS4-1','N','05','N','FT','Y','SCHB','Y','Y',1535,'Y',NULL,NULL,'A','S4','NIL',0,1,1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP', 'N','0','FT',NULL,NULL,NULL,NULL,NULL);
		INSERT INTO CP20.cp_cur_school_cay_subj (id                , subject_school_code , academic_year , level_xcode , stream_xcode , subject_code , gep_ind , subject_level_icode , examinable_ind ,                      subject_desc                       , show_in_resultslip_ind , subject_category , for_total_ind , include_tmt_ind , order_no , grade_ind , national_exam_subj_code , h1h2_gradeonly_ind , school_offering_status_icode , level_name , stream_name , threshold , weight , version_no ,         created_ts         ,   created_by   ,         updated_ts         ,   updated_by   , delete_ind , program_ind ,     abbreviation     , subject_language_medium_code , subject_type_code , offered_as_l1 , offered_as_l2 , offered_as_l3) VALUES (replace(public.uuid_generate_v4()::text,'-',''), v_school, TO_CHAR(NOW(),'YYYY'),'35','00','0SS5-1','N','05','N','FT','Y','SCHB','Y','Y',1535,'Y',NULL,NULL,'A','S5','NIL',0,1,1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP', 'N','0','FT',NULL,NULL,NULL,NULL,NULL);
		
		/* cp_cur_school_cay_subj_comp - assign from online */
		/* cp_cur_school_cay_subj_grade - assign from online */
		/* cp_cur_school_cay_subj_des - assign from online */

        /* Insert into CP20.CP_CUR_CAY_COURSE  - SCHB ONLY */
		/* cp_cur_cay_course_stud_link - assign from online */
		
		delete from cp20.cp_cur_cay_course where school_code = v_school;
		delete from cp20.cp_cur_cay_course_subj_link where school_code = v_school;				
		
		-- SEC 1 SUBJECT COMBINATIONS
 		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'31','0',NULL ,v_course_sys_code,'Sec 1 G3 Subject Combi CL',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS1-1','31','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2ART','31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2FCE','31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3EL','31','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3CL','31','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3HUMGEOG','31','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3HUMHIST','31','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G3HUMLIT E','31','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3MATHS','31','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3SCI','31','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2MUSIC','31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE','31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
			
		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');	
		INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'31','0',NULL ,v_course_sys_code,'Sec 1 G3 Subject Combi ML',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS1-1','31','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2ART','31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2FCE','31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3EL','31','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3ML','31','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3HUMGEOG','31','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3HUMHIST','31','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G3HUMLIT E','31','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3MATHS','31','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3SCI','31','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2MUSIC','31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE','31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');		
			
		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');			
		INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'31','0',NULL ,v_course_sys_code,'Sec 1 G3 Subject Combi TL',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS1-1','31','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2ART','31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2FCE','31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3EL','31','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3TL','31','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3HUMGEOG','31','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3HUMHIST','31','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G3HUMLIT E','31','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3MATHS','31','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3SCI','31','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2MUSIC','31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE','31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
			
		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'31','0',NULL ,v_course_sys_code,'Sec 1 G2 Subject Combi CL',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS1-1' ,'31','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2ART' ,'31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2D&T' ,'31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2FCE' ,'31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2EL' ,'31','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2CL' ,'31','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2HUMGEOG' ,'31','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2HUMHIST' ,'31','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G2HUMLIT E' ,'31','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2MATHS' ,'31','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2SCI' ,'31','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2MUSIC' ,'31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
			
		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'31','0',NULL ,v_course_sys_code,'Sec 1 G2 Subject Combi ML',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS1-1' ,'31','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2ART' ,'31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2D&T' ,'31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2FCE' ,'31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2EL' ,'31','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2ML' ,'31','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2HUMGEOG' ,'31','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2HUMHIST' ,'31','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G2HUMLIT E' ,'31','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2MATHS' ,'31','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2SCI' ,'31','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2MUSIC' ,'31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
			
			v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'31','0',NULL ,v_course_sys_code,'Sec 1 G2 Subject Combi TL',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS1-1' ,'31','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2ART' ,'31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2D&T' ,'31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2FCE' ,'31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2EL' ,'31','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2TL' ,'31','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2HUMGEOG' ,'31','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2HUMHIST' ,'31','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G2HUMLIT E' ,'31','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2MATHS' ,'31','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2SCI' ,'31','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2MUSIC' ,'31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
								
		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'31','0',NULL ,v_course_sys_code,'Sec 1 G1 Subject Combi CL',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'0SS1-1','31','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'2ART','31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'2D&T','31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'2FCE','31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'2G1EL','31','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'2G1CL','31','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'2G1MATHS','31','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'2G1SCI','31','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'2G1SS&HEMS','31','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'2MUSIC','31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'2PE','31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
			
		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'31','0',NULL ,v_course_sys_code,'Sec 1 G1 Subject Combi ML',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'0SS1-1','31','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'2ART','31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'2D&T','31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'2FCE','31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'2G1EL','31','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'2G1ML','31','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'2G1MATHS','31','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'2G1SCI','31','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'2G1SS&HEMS','31','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'2MUSIC','31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'2PE','31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
			
		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'31','0',NULL ,v_course_sys_code,'Sec 1 G1 Subject Combi TL',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'0SS1-1','31','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'2ART','31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'2D&T','31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'2FCE','31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'2G1EL','31','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'2G1TL','31','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'2G1MATHS','31','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'2G1SCI','31','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'2G1SS&HEMS','31','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'2MUSIC','31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'2PE','31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
		
		
		-- SEC 2 SUBJECT COMBINATIONS
		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'32','0',NULL ,v_course_sys_code,'Sec 2 G3 Subject Combi CL',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS2-1','32','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3ART','32','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),       
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3CL','32','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3D&T','32','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3EL','32','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3FCE','32','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),            
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3GEOG','32','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),            
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3HIST','32','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),       
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3MATHS','32','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),            
			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3SCI','32','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),            
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2MUSIC' ,'32','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'32','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
			
		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'32','0',NULL ,v_course_sys_code,'Sec 2 G3 Subject Combi ML',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS2-1','32','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3ART','32','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),       
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3ML','32','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3D&T','32','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3EL','32','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3FCE','32','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),            
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3GEOG','32','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),            
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3HIST','32','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),       
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3MATHS','32','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),            
			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3SCI','32','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),            
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2MUSIC' ,'32','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'32','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
			
		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'32','0',NULL ,v_course_sys_code,'Sec 2 G3 Subject Combi TL',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS2-1','32','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3ART','32','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),       
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3TL','32','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3D&T','32','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3EL','32','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3FCE','32','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),            
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3GEOG','32','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),            
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3HIST','32','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),       
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3MATHS','32','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),            
			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3SCI','32','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),            
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2MUSIC' ,'32','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'32','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');

        v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'32','0',NULL ,v_course_sys_code,'Sec 2 G2 Subject Combi CL',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS2-1','32','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2ART','32','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),       
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2CL','32','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2D&T','32','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2EL','32','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2FCE','32','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),            
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2GEOG','32','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),            
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2HIST','32','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),       
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2MATHS','32','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),            
			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2SCI','32','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),            
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2MUSIC' ,'32','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'32','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
			
		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'32','0',NULL ,v_course_sys_code,'Sec 2 G2 Subject Combi ML',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS2-1','32','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2ART','32','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),       
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2ML','32','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2D&T','32','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2EL','32','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2FCE','32','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),            
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2GEOG','32','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),            
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2HIST','32','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),       
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2MATHS','32','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),            
			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2SCI','32','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),            
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2MUSIC' ,'32','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'32','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
			
		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'32','0',NULL ,v_course_sys_code,'Sec 2 G2 Subject Combi TL',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS2-1','32','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2ART','32','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),       
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2TL','32','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2D&T','32','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2EL','32','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2FCE','32','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),            
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2GEOG','32','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),            
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2HIST','32','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),       
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2MATHS','32','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),            
			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2SCI','32','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),            
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2MUSIC' ,'32','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'32','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
			
		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'32','0',NULL ,v_course_sys_code,'Sec 2 G1 Subject Combi CL',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS2-1','32','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),         
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1CL','32','00','24',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1D&T','32','00','24',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1EL','32','00','24',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1FCE','32','00','24',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),                                    
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1MATHS','32','00','24',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),            
			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1SCI','32','00','24',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),    
			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1SS','32','00','24',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),    			
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2MUSIC' ,'32','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'32','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
			
		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'32','0',NULL ,v_course_sys_code,'Sec 2 G1 Subject Combi ML',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS2-1','32','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),         
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1ML','32','00','24',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1D&T','32','00','24',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1EL','32','00','24',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1FCE','32','00','24',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),                                    
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1MATHS','32','00','24',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),            
			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1SCI','32','00','24',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),    
			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1SS','32','00','24',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),    			
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2MUSIC' ,'32','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'32','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
			
		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'32','0',NULL ,v_course_sys_code,'Sec 2 G1 Subject Combi TL',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS2-1','32','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),         
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1TL','32','00','24',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1D&T','32','00','24',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1EL','32','00','24',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1FCE','32','00','24',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),                                    
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1MATHS','32','00','24',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),            
			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1SCI','32','00','24',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),    
			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1SS','32','00','24',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),    			
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2MUSIC' ,'32','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'32','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
	
	
		-- SEC 3 SUBJECT COMBINATIONS		
        v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
                    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'33','0',NULL ,v_course_sys_code,'S3E SubjectCombi SS&HIST CL',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS3-1','33','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G3EX&SPSCI','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3EL','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3SS&HIST','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3MATHS','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3CL','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G3SCI(C,B)','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'33','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');

                v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
                    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'33','0',NULL ,v_course_sys_code,'S3E SubjectCombi SS&GEOG CL',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS3-1','33','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G3EX&SPSCI','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3EL','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3SS&GEOG','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3MATHS','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3CL','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G3SCI(C,B)','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'33','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');


               v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
                    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'33','0',NULL ,v_course_sys_code,'S3E SubjectCombi SS&HIST ML',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS3-1','33','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G3EX&SPSCI','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3EL','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3SS&HIST','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3MATHS','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3ML','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G3SCI(C,B)','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'33','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');

                v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
                    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'33','0',NULL ,v_course_sys_code,'S3E SubjectCombi SS&GEOG ML',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS3-1','33','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G3EX&SPSCI','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3EL','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3SS&GEOG','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3MATHS','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3ML','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G3SCI(C,B)','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'33','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');


                                v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
                    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'33','0',NULL ,v_course_sys_code,'S3E SubjectCombi SS&HIST TL',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS3-1','33','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G3EX&SPSCI','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3EL','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3SS&HIST','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3MATHS','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3TL','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G3SCI(C,B)','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'33','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');

                v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
                    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'33','0',NULL ,v_course_sys_code,'S3E SubjectCombi SS&GEOG TL',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS3-1','33','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G3EX&SPSCI','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3EL','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3SS&GEOG','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3MATHS','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3TL','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G3SCI(C,B)','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'33','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');

                v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
                    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'33','0',NULL ,v_course_sys_code,'S3N(A) SubjectCombi SS&HIST CL',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS3-1','33','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G3EX&SPSCI','33','22','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2EL','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2SS&HIST','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2MATHS','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2CL','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G2SCI(P,C)','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'33','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');

                                v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
                    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'33','0',NULL ,v_course_sys_code,'S3N(A) SubjectCombi SS&GEOG CL',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS3-1','33','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G3EX&SPSCI','33','22','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2EL','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2SS&GEOG','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2MATHS','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2CL','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G2SCI(C,B)','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'33','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');

                                v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
                    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'33','0',NULL ,v_course_sys_code,'S3N(A) SubjectCombi SS&HIST ML',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS3-1','33','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G3EX&SPSCI','33','22','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2EL','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2SS&HIST','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2MATHS','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2ML','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G2SCI(P,C)','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'33','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');

                                v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
                    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'33','0',NULL ,v_course_sys_code,'S3N(A) SubjectCombi SS&GEOG ML',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS3-1','33','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G3EX&SPSCI','33','22','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2EL','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2SS&GEOG','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2MATHS','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2ML','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G2SCI(C,B)','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'33','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');


                v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
                    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'33','0',NULL ,v_course_sys_code,'S3N(A) SubjectCombi SS&HIST TL',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS3-1','33','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G3EX&SPSCI','33','22','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2EL','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2SS&HIST','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2MATHS','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2TL','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G2SCI(P,C)','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'33','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');

                                v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
                    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'33','0',NULL ,v_course_sys_code,'S3N(A) SubjectCombi SS&GEOG TL',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS3-1','33','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G3EX&SPSCI','33','22','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2EL','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2SS&GEOG','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2MATHS','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2TL','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G2SCI(C,B)','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'33','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');



                v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
                    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'33','0',NULL ,v_course_sys_code,'S3N(T) Subject Combi CL',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS3-1','33','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
                        (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1CPA','33','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1EL','33','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1SS','33','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1MATHS','33','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1CL','33','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1SCI','33','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'33','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');

                v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
                    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'33','0',NULL ,v_course_sys_code,'S3N(T) Subject Combi ML',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS3-1','33','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
                        (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1CPA','33','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1EL','33','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1SS','33','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1MATHS','33','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1ML','33','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1SCI','33','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'33','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');


                v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
                    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'33','0',NULL ,v_course_sys_code,'S3N(T) Subject Combi TL',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS3-1','33','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
                        (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1CPA','33','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1EL','33','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1SS','33','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1MATHS','33','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1TL','33','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1SCI','33','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'33','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');


		-- SEC 4 SUBJECT COMBINATIONS	
                v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
                    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'34','0',NULL ,v_course_sys_code,'S4E SubjectCombi SS&HIST CL',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS4-1','34','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3D&T','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3EL','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3SS&HIST','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3MATHS','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3CL','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G3SCI(C,B)','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'34','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');

                v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
                    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'34','0',NULL ,v_course_sys_code,'S4E SubjectCombi SS&GEOG CL',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS4-1','34','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3D&T','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3EL','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3SS&GEOG','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3MATHS','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3CL','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G3SCI(P,C)','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'34','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');


                                v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
                    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'34','0',NULL ,v_course_sys_code,'S4E SubjectCombi SS&HIST ML',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS4-1','34','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3D&T','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3EL','34','34','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3SS&HIST','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3MATHS','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3ML','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G3SCI(C,B)','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'34','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');

                v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
                    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'34','0',NULL ,v_course_sys_code,'S4E SubjectCombi SS&GEOG ML',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS4-1','34','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3D&T','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3EL','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3SS&GEOG','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3MATHS','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3ML','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G3SCI(P,C)','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'34','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');



                v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
                    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'34','0',NULL ,v_course_sys_code,'S4E SubjectCombi SS&HIST TL',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS4-1','34','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3D&T','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3EL','34','34','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3SS&HIST','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3MATHS','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3TL','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G3SCI(C,B)','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'34','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');

                v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
                    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'34','0',NULL ,v_course_sys_code,'S4E SubjectCombi SS&GEOG TL',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS4-1','34','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3D&T','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3EL','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3SS&GEOG','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3MATHS','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3TL','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G3SCI(P,C)','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'34','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');


                v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
                    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'34','0',NULL ,v_course_sys_code,'S4N(A) SubjectCombi SS&HIST CL',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS4-1','34','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2ART','34','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2EL','34','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2SS&HIST','34','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2MATHS','34','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2CL','34','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G3SCI(C,B)','34','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'34','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');

                v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
                    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'34','0',NULL ,v_course_sys_code,'S4N(A) SubjectCombi SS&GEOG CL',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS4-1','34','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2D&T','34','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2EL','34','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2SS&GEOG','34','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2MATHS','34','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2CL','34','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G2SCI(P,C)','34','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'34','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');


                                v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
                    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'34','0',NULL ,v_course_sys_code,'S4N(A) SubjectCombi SS&HIST ML',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS4-1','34','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2ART','34','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2EL','34','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2SS&HIST','34','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2MATHS','34','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2ML','34','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G3SCI(C,B)','34','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'34','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');

                v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
                    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'34','0',NULL ,v_course_sys_code,'S4N(A) SubjectCombi SS&GEOG ML',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS4-1','34','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2D&T','34','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2EL','34','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2SS&GEOG','34','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2MATHS','34','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2ML','34','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G2SCI(P,C)','34','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'34','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');



                v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
                    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'34','0',NULL ,v_course_sys_code,'S4N(A) SubjectCombi SS&HIST TL',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS4-1','34','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2ART','34','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2EL','34','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2SS&HIST','34','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2MATHS','34','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2TL','34','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G3SCI(C,B)','34','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'34','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');

                v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
                    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'34','0',NULL ,v_course_sys_code,'S4N(A) SubjectCombi SS&GEOG TL',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS4-1','34','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2D&T','34','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2EL','34','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2SS&GEOG','34','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2MATHS','34','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2TL','34','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G2SCI(P,C)','34','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'34','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');


                v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
                    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'34','0',NULL ,v_course_sys_code,'S4N(T) Subject Combi CL',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS3-1','34','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
                        (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1CPA','34','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1EL','34','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1SS','34','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1MATHS','34','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1CL','34','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1SCI','34','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'34','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');


                v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
                    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'34','0',NULL ,v_course_sys_code,'S4N(T) Subject Combi ML',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS3-1','34','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
                        (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1CPA','34','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1EL','34','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1SS','34','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1MATHS','34','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1ML','34','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1SCI','34','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'34','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');


                v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
                    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'34','0',NULL ,v_course_sys_code,'S4N(T) Subject Combi TL',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS4-1','34','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
                        (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1CPA','34','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1EL','34','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1SS','34','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1MATHS','34','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1TL','34','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1SCI','34','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'34','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');


		-- SEC 5 SUBJECT COMBINATIONS	
                v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
                    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'35','0',NULL ,v_course_sys_code,'S5N(A) Subject Combi CL',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS5-1','35','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
                        (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G3EX&SPSCI','35','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3EL','35','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3SS&GEOG','35','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3MATHS','35','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3CL','35','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G3SCI(P,C)','35','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'35','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');


                v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
                    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'35','0',NULL ,v_course_sys_code,'S5N(A) Subject Combi ML',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS5-1','35','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
                        (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G3EX&SPSCI','35','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3EL','35','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3SS&GEOG','35','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3MATHS','35','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3ML','35','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G3SCI(P,C)','35','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'35','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');


                v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
                    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'35','0',NULL ,v_course_sys_code,'S5N(A) Subject Combi TL',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS5-1','35','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
                        (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G3EX&SPSCI','35','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3EL','35','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3SS&GEOG','35','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3MATHS','35','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3TL','35','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G3SCI(P,C)','35','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'35','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');

    END LOOP;
END
$BLOCK$; 

\qecho 'cp_cur_aggregate_parameter'
SELECT SCHOOL_CODE, COUNT(*)
FROM cp01.cp_cur_aggregate_parameter
WHERE academic_year = TO_CHAR(NOW(),'YYYY') and school_code BETWEEN '9808' AND '9808'
GROUP BY SCHOOL_CODE;

\qecho 'cp_cur_passing_criteria_new'
SELECT SCHOOL_CODE, COUNT(*)
FROM cp01.cp_cur_passing_criteria_new 
where academic_year = TO_CHAR(NOW(),'YYYY') and school_code BETWEEN '9808' AND '9808'
GROUP BY SCHOOL_CODE;

\qecho 'cp_cur_passing_ind'
SELECT SCHOOL_CODE, COUNT(*)
FROM CP01.cp_cur_passing_ind
where academic_year = TO_CHAR(NOW(),'YYYY') and school_code BETWEEN '9808' AND '9808'
GROUP BY SCHOOL_CODE;

\qecho 'cp_cur_ranking_parameter'
select school_code, level_xcode, count(*)
from cp01.cp_cur_ranking_parameter
where academic_year = TO_CHAR(NOW(),'YYYY') and school_code BETWEEN '9808' AND '9808'
group by school_code, level_xcode
order by school_code, level_xcode;

\qecho 'cp_cur_sch_gpa'
SELECT A.SCHOOL_CODE, COUNT(*) 
FROM cp01.cp_cur_sch_gpa A
WHERE a.academic_year = TO_CHAR(NOW(),'YYYY') and a.school_code BETWEEN '9808' AND '9808'
GROUP BY A.SCHOOL_CODE;

\qecho 'cp_cur_sch_gpa_cat_dtls'
select a.school_code, count(*) 
from cp01.cp_cur_sch_gpa a inner join cp01.cp_cur_sch_gpa_cat_dtls b on a.gpa_sys_code = b.gpa_sys_code 
where a.academic_year = TO_CHAR(NOW(),'YYYY') and a.school_code BETWEEN '9808' AND '9808' 
GROUP BY A.SCHOOL_CODE;

\qecho 'cp_cur_cay_sch_grdscheme'
SELECT A.SCHOOL_CODE, COUNT(*) 
FROM CP20.cp_cur_cay_sch_grdscheme A
WHERE a.academic_year = TO_CHAR(NOW(),'YYYY') and a.school_code BETWEEN '9808' AND '9808'
GROUP BY A.SCHOOL_CODE;

\qecho 'cp_cur_cay_sch_grdscheme_dtls'
SELECT A.SCHOOL_CODE, COUNT(*) 
FROM CP20.cp_cur_cay_sch_grdscheme A INNER JOIN cp20.cp_cur_cay_sch_grdscheme_dtls B ON A.grdscheme_sys_code = B.grdscheme_sys_code
WHERE a.academic_year = TO_CHAR(NOW(),'YYYY') and a.school_code BETWEEN '9808' AND '9808'
GROUP BY A.SCHOOL_CODE;

\qecho 'cp_cur_school_cay_subj'
SELECT subject_school_code, level_xcode , stream_xcode, subject_level_icode, program_ind, gep_ind, COUNT(*)
FROM CP20.cp_cur_school_cay_subj
WHERE academic_year = TO_CHAR(NOW(),'YYYY') and subject_school_code BETWEEN '9808' AND '9808'
GROUP BY subject_school_code, level_xcode , stream_xcode, subject_level_icode, program_ind, gep_ind
ORDER BY subject_school_code, level_xcode , stream_xcode, subject_level_icode, program_ind, gep_ind;

\qecho 'cp_cur_cay_course'
SELECT SCHOOL_CODE, LEVEL_XCODE, program_ind, Count(*) 
FROM cp20.cp_cur_cay_course 
WHERE ACADEMIC_YEAR = TO_CHAR(NOW(), 'YYYY')
AND SCHOOL_CODE BETWEEN '9808' AND '9808'
GROUP BY SCHOOL_CODE, LEVEL_XCODE, program_ind;

\qecho 'cp_cur_cay_course_subj_link'
SELECT A.SCHOOL_CODE, a.level_xcode, a.program_ind, COUNT(*) 
from cp20.cp_cur_cay_course a inner join cp20.cp_cur_cay_course_subj_link b on a.course_sys_code = b.course_refid
WHERE a.ACADEMIC_YEAR = TO_CHAR(NOW(), 'YYYY')
AND a.SCHOOL_CODE BETWEEN '9808' AND '9808'
GROUP BY A.SCHOOL_CODE, a.level_xcode, a.program_ind
order by A.SCHOOL_CODE, a.level_xcode, a.program_ind;