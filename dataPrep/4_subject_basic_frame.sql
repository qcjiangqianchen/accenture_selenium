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
AND SCHOOL_CODE BETWEEN '9808' and '9808'
GROUP BY SCHOOL_CODE, LEVEL_XCODE, program_ind;

\qecho 'cp_cur_cay_course_subj_link'
SELECT A.SCHOOL_CODE, a.level_xcode, a.program_ind, COUNT(*) 
from cp20.cp_cur_cay_course a inner join cp20.cp_cur_cay_course_subj_link b on a.course_sys_code = b.course_refid
WHERE a.ACADEMIC_YEAR = TO_CHAR(NOW(), 'YYYY')
AND a.SCHOOL_CODE BETWEEN '9808' and '9808'
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
        VALUES (v_school, '31', '22', '9', '4', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', to_char(now(), 'YYYY')::NUMERIC - 1, '0', 'M', 'M', NULL, '0');
		INSERT INTO cp01.cp_cur_aggregate_parameter (school_code, level_xcode, stream_xcode, ovrl_total_subject_no, l3_replacement_icode, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id, level_param_changed_ind, academic_year, ovrl_total_subject_no_schm, overall_total_criteria, ip_results_based_on, ip_moe_subject_no, ip_school_based_subject_no)
        VALUES (v_school, '31', '21', '8', '4', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', to_char(now(), 'YYYY')::NUMERIC - 1, '0', 'M', 'M', NULL, '0');
		INSERT INTO cp01.cp_cur_aggregate_parameter (school_code, level_xcode, stream_xcode, ovrl_total_subject_no, l3_replacement_icode, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id, level_param_changed_ind, academic_year, ovrl_total_subject_no_schm, overall_total_criteria, ip_results_based_on, ip_moe_subject_no, ip_school_based_subject_no)
        VALUES (v_school, '31', '20', '7', '4', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', to_char(now(), 'YYYY')::NUMERIC - 1, '0', 'M', 'M', NULL, '0');
		INSERT INTO cp01.cp_cur_aggregate_parameter (school_code, level_xcode, stream_xcode, ovrl_total_subject_no, l3_replacement_icode, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id, level_param_changed_ind, academic_year, ovrl_total_subject_no_schm, overall_total_criteria, ip_results_based_on, ip_moe_subject_no, ip_school_based_subject_no)
        VALUES (v_school, '31', '00', '0', '4', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', to_char(now(), 'YYYY'), '0', 'M', 'M', NULL, '0');
		
		INSERT INTO cp01.cp_cur_aggregate_parameter (school_code, level_xcode, stream_xcode, ovrl_total_subject_no, l3_replacement_icode, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id, level_param_changed_ind, academic_year, ovrl_total_subject_no_schm, overall_total_criteria, ip_results_based_on, ip_moe_subject_no, ip_school_based_subject_no)
        VALUES (v_school, '32', '22', '9', '4', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', to_char(now(), 'YYYY')::NUMERIC - 1, '0', 'M', 'M', NULL, '0');
		INSERT INTO cp01.cp_cur_aggregate_parameter (school_code, level_xcode, stream_xcode, ovrl_total_subject_no, l3_replacement_icode, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id, level_param_changed_ind, academic_year, ovrl_total_subject_no_schm, overall_total_criteria, ip_results_based_on, ip_moe_subject_no, ip_school_based_subject_no)
        VALUES (v_school, '32', '21', '8', '4', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', to_char(now(), 'YYYY')::NUMERIC - 1, '0', 'M', 'M', NULL, '0');
		INSERT INTO cp01.cp_cur_aggregate_parameter (school_code, level_xcode, stream_xcode, ovrl_total_subject_no, l3_replacement_icode, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id, level_param_changed_ind, academic_year, ovrl_total_subject_no_schm, overall_total_criteria, ip_results_based_on, ip_moe_subject_no, ip_school_based_subject_no)
        VALUES (v_school, '32', '20', '7', '4', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', to_char(now(), 'YYYY')::NUMERIC - 1, '0', 'M', 'M', NULL, '0');
		INSERT INTO cp01.cp_cur_aggregate_parameter (school_code, level_xcode, stream_xcode, ovrl_total_subject_no, l3_replacement_icode, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id, level_param_changed_ind, academic_year, ovrl_total_subject_no_schm, overall_total_criteria, ip_results_based_on, ip_moe_subject_no, ip_school_based_subject_no)
		VALUES (v_school, '32', '22', '9', '4', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', to_char(now(), 'YYYY'), '0', 'M', 'M', NULL, '0');
		INSERT INTO cp01.cp_cur_aggregate_parameter (school_code, level_xcode, stream_xcode, ovrl_total_subject_no, l3_replacement_icode, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id, level_param_changed_ind, academic_year, ovrl_total_subject_no_schm, overall_total_criteria, ip_results_based_on, ip_moe_subject_no, ip_school_based_subject_no)
		VALUES (v_school, '32', '21', '8', '4', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', to_char(now(), 'YYYY'), '0', 'M', 'M', NULL, '0');
		INSERT INTO cp01.cp_cur_aggregate_parameter (school_code, level_xcode, stream_xcode, ovrl_total_subject_no, l3_replacement_icode, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id, level_param_changed_ind, academic_year, ovrl_total_subject_no_schm, overall_total_criteria, ip_results_based_on, ip_moe_subject_no, ip_school_based_subject_no)
		VALUES (v_school, '32', '20', '7', '4', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', to_char(now(), 'YYYY'), '0', 'M', 'M', NULL, '0');
		
        
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
		
 		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'31','0',NULL ,v_course_sys_code,'Sec 1 G3 Subject Combi',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS1-1','31','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2ART','31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2FCE','31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3EL','31','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3HUMGEOG','31','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3HUMHIST','31','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G3HUMLIT E','31','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3MATHS','31','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3SCI','31','00','26',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2MUSIC','31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE','31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
			
		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'31','0',NULL ,v_course_sys_code,'Sec 1 G2 Subject Combi',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS1-1' ,'31','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2ART' ,'31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2D&T' ,'31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2FCE' ,'31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2EL' ,'31','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2HUMGEOG' ,'31','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2HUMHIST' ,'31','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G2HUMLIT E' ,'31','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2MATHS' ,'31','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2SCI' ,'31','00','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2MUSIC' ,'31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
			
			
		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'31','0',NULL ,v_course_sys_code,'Sec 1 G1 Subject Combi',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'0SS1-1','31','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'2ART','31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'2D&T','31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'2FCE','31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'2G1EL','31','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'2G1MATHS','31','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'2G1SCI','31','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'2G1SS&HEMS','31','00','25',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'2MUSIC','31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'2PE','31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
		
		
		
		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'32','0',NULL ,v_course_sys_code,'S2E Subject Combi',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS2-1','32','0','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3ART','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3BL','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3BURMESE','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3CL','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3D&T','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3EL','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3FCE','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3FRENCH','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3GEOG','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3GERMAN','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3HCL','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3HIST','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3HL','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3HML','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3HTL','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3LIT(EL)','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3MATHS','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3ML','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3PL','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3SCI','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3THAI','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3TL','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3UL','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2MUSIC' ,'32','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'32','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');

        v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
                    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'32','0',NULL ,v_course_sys_code,'S2E Subject Combi CL',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS2-1','32','0','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3ART','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3D&T','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3EL','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3FCE','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3GEOG','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3HIST','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3LIT(EL)','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3MATHS','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3CL','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3SCI','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2MUSIC' ,'32','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'32','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');

		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
                    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'32','0',NULL ,v_course_sys_code,'S2E Subject Combi ML',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS2-1','32','0','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3ART','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3D&T','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3EL','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3FCE','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3GEOG','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3HIST','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3LIT(EL)','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3MATHS','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3ML','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3SCI','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2MUSIC' ,'32','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'32','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');


        v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
                    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'32','0',NULL ,v_course_sys_code,'S2E Subject Combi TL',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS2-1','32','0','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3ART','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3D&T','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3EL','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3FCE','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3GEOG','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3HIST','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3LIT(EL)','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3MATHS','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3TL','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3SCI','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2MUSIC' ,'32','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'32','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');


		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'32','0',NULL ,v_course_sys_code,'S2N(A) Subject Combi',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS2-1' ,'32','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2ART' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2BL' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2CL' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2D&T' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2EL' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2FCE' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2GEOG' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2HIST' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2HL' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2LIT(EL)' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2MATHS' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2ML' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2PL' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2SCI' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2TL' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2UL' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3BURMESE' ,'32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3FRENCH' ,'32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2MUSIC' ,'32','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'32','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');

        v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
                    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'32','0',NULL ,v_course_sys_code,'S2N(A) Subject Combi CL',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS2-1' ,'32','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
                        (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2ART' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2D&T' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2EL' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2FCE' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2GEOG' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2HIST' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2LIT(EL)' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2MATHS' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2CL' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2SCI' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2MUSIC' ,'32','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'32','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');


        v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
                    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'32','0',NULL ,v_course_sys_code,'S2N(A) Subject Combi ML',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS2-1' ,'32','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
                        (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2ART' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2D&T' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2EL' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2FCE' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2GEOG' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2HIST' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2LIT(EL)' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2MATHS' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2ML' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2SCI' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2MUSIC' ,'32','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'32','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');

        v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
                    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'32','0',NULL ,v_course_sys_code,'S2N(A) Subject Combi TL',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS2-1' ,'32','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
                        (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2ART' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2D&T' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2EL' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2FCE' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2GEOG' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2HIST' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2LIT(EL)' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2MATHS' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2SCI' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2MUSIC' ,'32','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2TL' ,'32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'32','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');

		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'32','0',NULL ,v_course_sys_code,'S2N(T) Subject Combi',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS2-1','32','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1ART' ,'32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1CL' ,'32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1CPA' ,'32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1D&T' ,'32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1EL' ,'32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1FCE' ,'32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1MATHS' ,'32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1ML' ,'32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1SCI' ,'32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1SS' ,'32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1TL' ,'32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3BURMESE' ,'32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3THAI' ,'32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2MUSIC' ,'32','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'32','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');

        v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
                    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'32','0',NULL ,v_course_sys_code,'S2N(T) Subject Combi CL',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS2-1','32','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1ART' ,'32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1CPA' ,'32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1D&T' ,'32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1EL' ,'32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1FCE' ,'32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1MATHS' ,'32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1CL' ,'32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1SCI' ,'32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1SS' ,'32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2MUSIC' ,'32','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'32','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');


        v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
                    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'32','0',NULL ,v_course_sys_code,'S2N(T) Subject Combi ML',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS2-1','32','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1ART' ,'32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1CPA' ,'32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1D&T' ,'32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1EL' ,'32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1FCE' ,'32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1MATHS' ,'32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1ML' ,'32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1SCI' ,'32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1SS' ,'32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2MUSIC' ,'32','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'32','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');

        v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
                    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'32','0',NULL ,v_course_sys_code,'S2N(T) Subject Combi TL',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS2-1','32','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1ART' ,'32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1CPA' ,'32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1D&T' ,'32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1EL' ,'32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1FCE' ,'32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1MATHS' ,'32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
                        (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1TL' ,'32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1SCI' ,'32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1SS' ,'32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2MUSIC' ,'32','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'32','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
	
		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'33','0',NULL ,v_course_sys_code,'Physics and Chemistry + SS/Geo',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G3SCI(P,C)','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');

		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'33','0',NULL ,v_course_sys_code,'Biology and Chemistry + SS/Geo',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3BIO','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3CHEM','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3SS&GEOG','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
			
		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'33','0',NULL ,v_course_sys_code,'Design & Technology (O)',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3D&T','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
			
		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'33','0',NULL ,v_course_sys_code,'Additional Mathematics (NA)',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS3-1'     ,'33','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE'       ,'33','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2AMATHS','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3EL','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3MATHS','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');

		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'33','0',NULL ,v_course_sys_code,'Art (NA)',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS3-1'     ,'33','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2ART','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
			
		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'33','0',NULL ,v_course_sys_code,'Normal (Technical)',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1EL','33','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
			
		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'33','0',NULL ,v_course_sys_code,'Physics and Chemistry + SS/His',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G3SCI(P,C)','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
			
		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'33','0',NULL ,v_course_sys_code,'Biology and Chemistry + SS/His',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3BIO','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3CHEM','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3SS&HIST','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
			
		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'33','0',NULL ,v_course_sys_code,'Nutrition & Food Science (O)',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3NFS','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
			
		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'33','0',NULL ,v_course_sys_code,'Exercise & Sport Science (O)',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G3EX&SPSCI','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
			
		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'33','0',NULL ,v_course_sys_code,'History (O)',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3MATHS','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
			
		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'33','0',NULL ,v_course_sys_code,'Literature (English) (O)',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3LIT(EL)','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
			
			
		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'33','0',NULL ,v_course_sys_code,'Art (O)',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '0SS3-1'     ,'33','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3ART','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
			
			
		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'33','0',NULL ,v_course_sys_code,'Nutrition & Food Science (NA)',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES            
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2NFS','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
			
			
		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'33','0',NULL ,v_course_sys_code,'Design & Technology (NA)',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2D&T','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
			
			
		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'33','0',NULL ,v_course_sys_code,'Literature (English) (NA)',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G2LIT(EL)','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
			
			
		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'33','0',NULL ,v_course_sys_code,'Exercise & Sport Science (NA)',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, 'G3EX&SPSCI','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
		

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
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1ML','34','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G1SCI','34','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2PE' ,'34','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');


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


		
--		v_SEQ_GPA_SYSCODE := NEXTVAL('cp01.SEQ_GPA_SYSCODE');
--		INSERT INTO cp01.cp_cur_sch_gpa( gpa_sys_code , academic_year , school_code , level_xcode , stream_xcode , gpa_std_name ,      gpa_name       , use_rule_ind , gradscheme_ind , record_version_no ,    created_date     , created_by_id ,  last_updated_date  , updated_by_id  ) values
--			(v_SEQ_GPA_SYSCODE, TO_CHAR(NOW(),'YYYY'), v_school, '31', '00', 'GPA1', 'Overall Subject GPA', 'N', 'SCH', 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP');
--		INSERT INTO cp01.cp_cur_sch_gpa_cat_dtls(gpa_sys_code , priority_no , subject_group , subject_no , subject_included , record_version_no ,    created_date     , created_by_id ,  last_updated_date  , updated_by_id  ) values
--			(v_SEQ_GPA_SYSCODE, '1', 'CORE', NULL, NULL, 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP'),
--			(v_SEQ_GPA_SYSCODE, '2', 'NONCORE', NULL, NULL, 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP');
--
--		v_SEQ_GPA_SYSCODE := NEXTVAL('cp01.SEQ_GPA_SYSCODE');
--		INSERT INTO cp01.cp_cur_sch_gpa( gpa_sys_code , academic_year , school_code , level_xcode , stream_xcode , gpa_std_name ,      gpa_name       , use_rule_ind , gradscheme_ind , record_version_no ,    created_date     , created_by_id ,  last_updated_date  , updated_by_id  ) values
--			(v_SEQ_GPA_SYSCODE, TO_CHAR(NOW(),'YYYY'), v_school, '31', '00', 'GPA2', 'Overall Subject GPA', 'N', 'SCH', 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP');
--		INSERT INTO cp01.cp_cur_sch_gpa_cat_dtls(gpa_sys_code , priority_no , subject_group , subject_no , subject_included , record_version_no ,    created_date     , created_by_id ,  last_updated_date  , updated_by_id  ) values
--			(v_SEQ_GPA_SYSCODE, '1', 'CORE', NULL, NULL, 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP'),
--			(v_SEQ_GPA_SYSCODE, '2', 'NONCORE', NULL, NULL, 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP');
--
--		v_SEQ_GPA_SYSCODE := NEXTVAL('cp01.SEQ_GPA_SYSCODE');
--		INSERT INTO cp01.cp_cur_sch_gpa( gpa_sys_code , academic_year , school_code , level_xcode , stream_xcode , gpa_std_name ,      gpa_name       , use_rule_ind , gradscheme_ind , record_version_no ,    created_date     , created_by_id ,  last_updated_date  , updated_by_id  ) values
--			(v_SEQ_GPA_SYSCODE, TO_CHAR(NOW(),'YYYY'), v_school, '31', '00', 'GPA3', 'Overall Subject GPA', 'N', 'SCH', 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP');
--		INSERT INTO cp01.cp_cur_sch_gpa_cat_dtls(gpa_sys_code , priority_no , subject_group , subject_no , subject_included , record_version_no ,    created_date     , created_by_id ,  last_updated_date  , updated_by_id  ) values
--			(v_SEQ_GPA_SYSCODE, '1', 'CORE', NULL, NULL, 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP'),
--			(v_SEQ_GPA_SYSCODE, '2', 'NONCORE', NULL, NULL, 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP');
--
--		v_SEQ_GPA_SYSCODE := NEXTVAL('cp01.SEQ_GPA_SYSCODE');
--		INSERT INTO cp01.cp_cur_sch_gpa( gpa_sys_code , academic_year , school_code , level_xcode , stream_xcode , gpa_std_name ,      gpa_name       , use_rule_ind , gradscheme_ind , record_version_no ,    created_date     , created_by_id ,  last_updated_date  , updated_by_id  ) values
--			(v_SEQ_GPA_SYSCODE, TO_CHAR(NOW(),'YYYY'), v_school, '31', '00', 'GPA4', 'Overall Subject GPA', 'Y', 'SCH', 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP');
--		INSERT INTO cp01.cp_cur_sch_gpa_cat_dtls(gpa_sys_code , priority_no , subject_group , subject_no , subject_included , record_version_no ,    created_date     , created_by_id ,  last_updated_date  , updated_by_id  ) values
--			(v_SEQ_GPA_SYSCODE, '1', 'CORE', NULL, NULL, 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP');
--
--		v_SEQ_GPA_SYSCODE := NEXTVAL('cp01.SEQ_GPA_SYSCODE');
--		INSERT INTO cp01.cp_cur_sch_gpa( gpa_sys_code , academic_year , school_code , level_xcode , stream_xcode , gpa_std_name ,      gpa_name       , use_rule_ind , gradscheme_ind , record_version_no ,    created_date     , created_by_id ,  last_updated_date  , updated_by_id  ) values
--			(v_SEQ_GPA_SYSCODE, TO_CHAR(NOW(),'YYYY'), v_school, '31', '00', 'GPA5', 'Overall Subject GPA', 'N', 'SCH', 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP');
--
--		
--		
--
--		v_SEQ_GPA_SYSCODE := NEXTVAL('cp01.SEQ_GPA_SYSCODE');
--		INSERT INTO cp01.cp_cur_sch_gpa( gpa_sys_code , academic_year , school_code , level_xcode , stream_xcode , gpa_std_name ,      gpa_name       , use_rule_ind , gradscheme_ind , record_version_no ,    created_date     , created_by_id ,  last_updated_date  , updated_by_id  ) values
--			(v_SEQ_GPA_SYSCODE, TO_CHAR(NOW(),'YYYY'), v_school, '33', '22', 'GPA1', 'Overall Subject GPA', 'N', 'SCH', 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP');
--		INSERT INTO cp01.cp_cur_sch_gpa_cat_dtls(gpa_sys_code , priority_no , subject_group , subject_no , subject_included , record_version_no ,    created_date     , created_by_id ,  last_updated_date  , updated_by_id  ) values
--			(v_SEQ_GPA_SYSCODE, '1', 'CORE', NULL, NULL, 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP'),
--			(v_SEQ_GPA_SYSCODE, '2', 'NONCORE', NULL, NULL, 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP');
--
--		v_SEQ_GPA_SYSCODE := NEXTVAL('cp01.SEQ_GPA_SYSCODE');
--		INSERT INTO cp01.cp_cur_sch_gpa( gpa_sys_code , academic_year , school_code , level_xcode , stream_xcode , gpa_std_name ,      gpa_name       , use_rule_ind , gradscheme_ind , record_version_no ,    created_date     , created_by_id ,  last_updated_date  , updated_by_id  ) values
--			(v_SEQ_GPA_SYSCODE, TO_CHAR(NOW(),'YYYY'), v_school, '33', '22', 'GPA2', 'Overall Subject GPA', 'N', 'SCH', 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP');
--		INSERT INTO cp01.cp_cur_sch_gpa_cat_dtls(gpa_sys_code , priority_no , subject_group , subject_no , subject_included , record_version_no ,    created_date     , created_by_id ,  last_updated_date  , updated_by_id  ) values
--			(v_SEQ_GPA_SYSCODE, '1', 'CORE', NULL, NULL, 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP'),
--			(v_SEQ_GPA_SYSCODE, '2', 'NONCORE', NULL, NULL, 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP');
--
--		v_SEQ_GPA_SYSCODE := NEXTVAL('cp01.SEQ_GPA_SYSCODE');
--		INSERT INTO cp01.cp_cur_sch_gpa( gpa_sys_code , academic_year , school_code , level_xcode , stream_xcode , gpa_std_name ,      gpa_name       , use_rule_ind , gradscheme_ind , record_version_no ,    created_date     , created_by_id ,  last_updated_date  , updated_by_id  ) values
--			(v_SEQ_GPA_SYSCODE, TO_CHAR(NOW(),'YYYY'), v_school, '33', '22', 'GPA3', 'Overall Subject GPA', 'N', 'SCH', 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP');
--		INSERT INTO cp01.cp_cur_sch_gpa_cat_dtls(gpa_sys_code , priority_no , subject_group , subject_no , subject_included , record_version_no ,    created_date     , created_by_id ,  last_updated_date  , updated_by_id  ) values
--			(v_SEQ_GPA_SYSCODE, '1', 'CORE', NULL, NULL, 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP'),
--			(v_SEQ_GPA_SYSCODE, '2', 'NONCORE', NULL, NULL, 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP');
--
--		v_SEQ_GPA_SYSCODE := NEXTVAL('cp01.SEQ_GPA_SYSCODE');
--		INSERT INTO cp01.cp_cur_sch_gpa( gpa_sys_code , academic_year , school_code , level_xcode , stream_xcode , gpa_std_name ,      gpa_name       , use_rule_ind , gradscheme_ind , record_version_no ,    created_date     , created_by_id ,  last_updated_date  , updated_by_id  ) values
--			(v_SEQ_GPA_SYSCODE, TO_CHAR(NOW(),'YYYY'), v_school, '33', '22', 'GPA4', 'Overall Subject GPA', 'N', 'SCH', 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP');
--
--		v_SEQ_GPA_SYSCODE := NEXTVAL('cp01.SEQ_GPA_SYSCODE');
--		INSERT INTO cp01.cp_cur_sch_gpa( gpa_sys_code , academic_year , school_code , level_xcode , stream_xcode , gpa_std_name ,      gpa_name       , use_rule_ind , gradscheme_ind , record_version_no ,    created_date     , created_by_id ,  last_updated_date  , updated_by_id  ) values
--			(v_SEQ_GPA_SYSCODE, TO_CHAR(NOW(),'YYYY'), v_school, '33', '22', 'GPA5', 'Overall Subject GPA', 'Y', 'SCH', 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP');
--		INSERT INTO cp01.cp_cur_sch_gpa_cat_dtls(gpa_sys_code , priority_no , subject_group , subject_no , subject_included , record_version_no ,    created_date     , created_by_id ,  last_updated_date  , updated_by_id  ) values
--			(v_SEQ_GPA_SYSCODE, '1', 'L', '2', '33~05~2SS318|33~05~2SS313', 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP'),
--			(v_SEQ_GPA_SYSCODE, '2', 'A|H|D|O|L', '1', '33~05~2SS311|33~05~2SS312|33~05~2SS314|33~05~2SS315|33~05~2SS319|33~05~2SS320|33~03~2G3BHSINDO|33~05~2SS3-7|33~05~2SS322', 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP'),
--			(v_SEQ_GPA_SYSCODE, '3', 'S|M|E', '1', '33~05~2SS3-9|33~05~2SS310|33~05~2SS316|33~05~2SS317|33~05~2SS323', 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP'),
--			(v_SEQ_GPA_SYSCODE, '4', 'C|L|D|B|S|E|K|M|H|A|O', '3', '33~05~2SS3-7|33~03~2G3ARAB-L3|33~03~2G3BHSINDO|33~05~2SS3-9|33~05~2SS310|33~05~2SS332|33~05~2SS311|33~05~2SS331|33~05~2SS312|33~05~2SS314|33~05~2SS316|33~05~2SS315|33~05~2SS317|33~05~2SS330|33~05~2SS319|33~05~2SS320|33~05~2SS322|33~05~2SS323|33~05~2SS329', 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP');
--
--		
--		v_SEQ_GPA_SYSCODE := NEXTVAL('cp01.SEQ_GPA_SYSCODE');
--		INSERT INTO cp01.cp_cur_sch_gpa( gpa_sys_code , academic_year , school_code , level_xcode , stream_xcode , gpa_std_name ,      gpa_name       , use_rule_ind , gradscheme_ind , record_version_no ,    created_date     , created_by_id ,  last_updated_date  , updated_by_id  ) values
--			(v_SEQ_GPA_SYSCODE, TO_CHAR(NOW(),'YYYY'), v_school, '34', '22', 'GPA1', 'Overall Subject GPA', 'N', 'SCH', 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP');
--		INSERT INTO cp01.cp_cur_sch_gpa_cat_dtls(gpa_sys_code , priority_no , subject_group , subject_no , subject_included , record_version_no ,    created_date     , created_by_id ,  last_updated_date  , updated_by_id  ) values
--			(v_SEQ_GPA_SYSCODE, '1', 'CORE', NULL, NULL, 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP'),
--			(v_SEQ_GPA_SYSCODE, '2', 'NONCORE', NULL, NULL, 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP');
--
--		v_SEQ_GPA_SYSCODE := NEXTVAL('cp01.SEQ_GPA_SYSCODE');
--		INSERT INTO cp01.cp_cur_sch_gpa( gpa_sys_code , academic_year , school_code , level_xcode , stream_xcode , gpa_std_name ,      gpa_name       , use_rule_ind , gradscheme_ind , record_version_no ,    created_date     , created_by_id ,  last_updated_date  , updated_by_id  ) values
--			(v_SEQ_GPA_SYSCODE, TO_CHAR(NOW(),'YYYY'), v_school, '34', '22', 'GPA2', 'Overall Subject GPA', 'N', 'SCH', 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP');
--		INSERT INTO cp01.cp_cur_sch_gpa_cat_dtls(gpa_sys_code , priority_no , subject_group , subject_no , subject_included , record_version_no ,    created_date     , created_by_id ,  last_updated_date  , updated_by_id  ) values
--			(v_SEQ_GPA_SYSCODE, '1', 'CORE', NULL, NULL, 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP'),
--			(v_SEQ_GPA_SYSCODE, '2', 'NONCORE', NULL, NULL, 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP');
--
--		v_SEQ_GPA_SYSCODE := NEXTVAL('cp01.SEQ_GPA_SYSCODE');
--		INSERT INTO cp01.cp_cur_sch_gpa( gpa_sys_code , academic_year , school_code , level_xcode , stream_xcode , gpa_std_name ,      gpa_name       , use_rule_ind , gradscheme_ind , record_version_no ,    created_date     , created_by_id ,  last_updated_date  , updated_by_id  ) values
--			(v_SEQ_GPA_SYSCODE, TO_CHAR(NOW(),'YYYY'), v_school, '34', '22', 'GPA3', 'Overall Subject GPA', 'N', 'SCH', 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP');
--		INSERT INTO cp01.cp_cur_sch_gpa_cat_dtls(gpa_sys_code , priority_no , subject_group , subject_no , subject_included , record_version_no ,    created_date     , created_by_id ,  last_updated_date  , updated_by_id  ) values
--			(v_SEQ_GPA_SYSCODE, '1', 'CORE', NULL, NULL, 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP'),
--			(v_SEQ_GPA_SYSCODE, '2', 'NONCORE', NULL, NULL, 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP');
--
--		v_SEQ_GPA_SYSCODE := NEXTVAL('cp01.SEQ_GPA_SYSCODE');
--		INSERT INTO cp01.cp_cur_sch_gpa( gpa_sys_code , academic_year , school_code , level_xcode , stream_xcode , gpa_std_name ,      gpa_name       , use_rule_ind , gradscheme_ind , record_version_no ,    created_date     , created_by_id ,  last_updated_date  , updated_by_id  ) values
--			(v_SEQ_GPA_SYSCODE, TO_CHAR(NOW(),'YYYY'), v_school, '34', '22', 'GPA4', 'Overall Subject GPA', 'N', 'SCH', 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP');
--
--		v_SEQ_GPA_SYSCODE := NEXTVAL('cp01.SEQ_GPA_SYSCODE');
--		INSERT INTO cp01.cp_cur_sch_gpa( gpa_sys_code , academic_year , school_code , level_xcode , stream_xcode , gpa_std_name ,      gpa_name       , use_rule_ind , gradscheme_ind , record_version_no ,    created_date     , created_by_id ,  last_updated_date  , updated_by_id  ) values
--			(v_SEQ_GPA_SYSCODE, TO_CHAR(NOW(),'YYYY'), v_school, '34', '22', 'GPA5', 'Overall Subject GPA', 'Y', 'SCH', 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP');
--		INSERT INTO cp01.cp_cur_sch_gpa_cat_dtls(gpa_sys_code , priority_no , subject_group , subject_no , subject_included , record_version_no ,    created_date     , created_by_id ,  last_updated_date  , updated_by_id  ) values
--			(v_SEQ_GPA_SYSCODE, '1', 'L', '2', '34~05~2SS413|34~05~2SS418', 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP'),
--			(v_SEQ_GPA_SYSCODE, '2', 'H|D|O|L', '1', '34~05~2SS411|34~05~2SS412|34~05~2SS414|34~05~2SS415|34~05~2SS419|34~05~2SS420|34~05~2SS422|34~03~2G3BHSINDO|34~05~2SS4-7', 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP'),
--			(v_SEQ_GPA_SYSCODE, '3', 'S|M', '1', '34~05~2SS4-9|34~05~2SS410|34~05~2SS416|34~05~2SS417|34~05~2SS423', 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP'),
--			(v_SEQ_GPA_SYSCODE, '4', 'C|L|D|B|S|E|K|M|H|A|O', '3', '34~05~2SS4-7|34~03~2G3ARAB-L3|34~03~2G3BHSINDO|34~05~2SS4-9|34~05~2SS410|34~05~2SS430|34~05~2SS411|34~05~2SS431|34~05~2SS412|34~05~2SS414|34~05~2SS415|34~05~2SS416|34~05~2SS417|34~05~2SS432|34~05~2SS419|34~05~2SS420|34~05~2SS422|34~05~2SS423|34~05~2SS433', 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP');
--
--
--		/* cp_cur_sch_gpa_subj_dtls - assign from online */
--		
--		v_grdscheme_sys_code := NEXTVAL('cp01.seq_grdscheme_syscode');
--		INSERT INTO CP20.cp_cur_cay_sch_grdscheme(id,academic_year,school_code,grdscheme_sys_code,grdscheme_code,grdscheme_name,grdscheme_display,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) values
--			(replace(public.uuid_generate_v4()::text,'-',''), TO_CHAR(NOW(),'YYYY'), v_school, v_grdscheme_sys_code, 'UPPSECGRAD', 'UPPSECGRAD', 'GL', 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP', 'N');
--		INSERT INTO cp20.cp_cur_cay_sch_grdscheme_dtls(id,grdscheme_sys_code,grade_name,grade_name2,grade_desc,pass_ind,start_marks_no,grade_points_no,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
--			(replace(public.uuid_generate_v4()::text,'-',''), v_grdscheme_sys_code,  'D',  'DISTINCTION', NULL, 'Y',  4.00, 0.00, 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP', 'N'),
--			(replace(public.uuid_generate_v4()::text,'-',''), v_grdscheme_sys_code,  'M',  'MERIT'      , NULL, 'Y',  3.00, 0.00, 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP', 'N'),
--			(replace(public.uuid_generate_v4()::text,'-',''), v_grdscheme_sys_code,  'P',  'PASS'       , NULL, 'Y',  2.00, 0.00, 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP', 'N'),
--			(replace(public.uuid_generate_v4()::text,'-',''), v_grdscheme_sys_code,  'U',  'UNGRADED'   , NULL, 'N',  1.00, 0.00, 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP', 'N'),
--			(replace(public.uuid_generate_v4()::text,'-',''), v_grdscheme_sys_code, 'VR',  'VR'         , NULL, 'N',  0.00, 0.00, 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP', 'N');
--
--		v_grdscheme_sys_code := NEXTVAL('cp01.seq_grdscheme_syscode');
--		INSERT INTO cp20.cp_cur_cay_sch_grdscheme(id,academic_year,school_code,grdscheme_sys_code,grdscheme_code,grdscheme_name,grdscheme_display,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) values
--			(replace(public.uuid_generate_v4()::text,'-',''), TO_CHAR(NOW(),'YYYY'), v_school, v_grdscheme_sys_code, 'LOWSECGRAD' , 'LOWSECGRAD' , 'GL', 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP', 'N');
--		INSERT INTO cp20.cp_cur_cay_sch_grdscheme_dtls(id,grdscheme_sys_code,grade_name,grade_name2,grade_desc,pass_ind,start_marks_no,grade_points_no,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
--			(replace(public.uuid_generate_v4()::text,'-',''), v_grdscheme_sys_code, 'A',  'ACCOMPLISHED', NULL, 'Y', 4.00, 0.00, 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP', 'N'),
--			(replace(public.uuid_generate_v4()::text,'-',''), v_grdscheme_sys_code, 'C',  'COMPETENT',    NULL, 'Y', 3.00, 0.00, 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP', 'N'),
--			(replace(public.uuid_generate_v4()::text,'-',''), v_grdscheme_sys_code, 'P',  'PROGRESSING',  NULL, 'Y', 2.00, 0.00, 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP', 'N'),
--			(replace(public.uuid_generate_v4()::text,'-',''), v_grdscheme_sys_code, 'U',  'UNGRADED',     NULL, 'N', 1.00, 0.00, 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP', 'N'),
--			(replace(public.uuid_generate_v4()::text,'-',''), v_grdscheme_sys_code, 'VR', 'VR',           NULL, 'N', 0.00, 0.00, 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP', 'N');
--			
--		v_grdscheme_sys_code := NEXTVAL('cp01.seq_grdscheme_syscode');
--		INSERT INTO cp20.cp_cur_cay_sch_grdscheme(id,academic_year,school_code,grdscheme_sys_code,grdscheme_code,grdscheme_name,grdscheme_display,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) values
--			(replace(public.uuid_generate_v4()::text,'-',''), TO_CHAR(NOW(),'YYYY'), v_school, v_grdscheme_sys_code, 'IP-GPA', 'IP-GPA', 'GL', 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP', 'N');
--		INSERT INTO cp20.cp_cur_cay_sch_grdscheme_dtls(id,grdscheme_sys_code,grade_name,grade_name2,grade_desc,pass_ind,start_marks_no,grade_points_no,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
--			(replace(public.uuid_generate_v4()::text,'-',''), v_grdscheme_sys_code, 'A1', 'A1', NULL, 'Y', 75.00, 9.00, 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP', 'N'),
--			(replace(public.uuid_generate_v4()::text,'-',''), v_grdscheme_sys_code, 'A2', 'A2', NULL, 'Y', 70.00, 8.00, 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP', 'N'),
--			(replace(public.uuid_generate_v4()::text,'-',''), v_grdscheme_sys_code, 'B3', 'B3', NULL, 'Y', 65.00, 7.00, 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP', 'N'),
--			(replace(public.uuid_generate_v4()::text,'-',''), v_grdscheme_sys_code, 'B4', 'B4', NULL, 'Y', 60.00, 6.00, 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP', 'N'),
--			(replace(public.uuid_generate_v4()::text,'-',''), v_grdscheme_sys_code, 'C5', 'C5', NULL, 'Y', 55.00, 5.00, 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP', 'N'),
--			(replace(public.uuid_generate_v4()::text,'-',''), v_grdscheme_sys_code, 'C6', 'C6', NULL, 'Y', 50.00, 4.00, 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP', 'N'),
--			(replace(public.uuid_generate_v4()::text,'-',''), v_grdscheme_sys_code, 'D7', 'D7', NULL, 'N', 45.00, 3.00, 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP', 'N'),
--			(replace(public.uuid_generate_v4()::text,'-',''), v_grdscheme_sys_code, 'E8', 'E8', NULL, 'N', 40.00, 2.00, 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP', 'N'),
--			(replace(public.uuid_generate_v4()::text,'-',''), v_grdscheme_sys_code,  '9',  '9', NULL, 'N',  0.00, 1.00, 1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP', 'N');
--
--
--        v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
--        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
-- 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'31','2',NULL ,v_course_sys_code,'SECONDARY 1 IP',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
--        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS1-2','31','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS1-3','31','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS1-5','31','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS1-6','31','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS1-8','31','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS1-9','31','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS111','31','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS112','31','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS114','31','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS119','31','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS120','31','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS121','31','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
--
-- 		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
--        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
-- 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'32','2',NULL ,v_course_sys_code,'SECONDARY 2 IP',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
--        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS2-2','32','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS2-3','32','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS2-5','32','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS2-6','32','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS2-8','32','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS2-9','32','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS210','32','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS211','32','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS213','32','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS214','32','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS215','32','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS219','32','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS221','32','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS222','32','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
--
--        v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
--        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
-- 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'33','2',NULL ,v_course_sys_code,'SECONDARY 3 IP 2SC BC',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
--        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS3-1','33','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS3-2','33','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS3-3','33','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS311','33','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS312','33','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
--
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3HCL' ,'33','00','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
--
--		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
--        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
-- 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'33','2',NULL ,v_course_sys_code,'SECONDARY 3 IP 2SC CP',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
--        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS3-1','33','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS3-2','33','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS3-3','33','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS310','33','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS311','33','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
--
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3HCL' ,'33','00','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
--
--		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
--        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
-- 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'33','2',NULL ,v_course_sys_code,'SECONDARY 3 IP 3 SC',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
--        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS3-1','33','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS3-2','33','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS3-3','33','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS3-4','33','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS310','33','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS311','33','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS312','33','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
--
--        v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
--        INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
-- 		    (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code, v_school,'34','2',NULL ,v_course_sys_code,'SECONDARY 4 IP',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
--        INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind) VALUES 
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS4-1','34','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2SS412','34','00','05',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
--
--            (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school, '2G3HCL','34','00','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
				
-- 		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
--         INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
-- 		(replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code,v_school,'31','0','21',v_course_sys_code,'S1N(A) Subject Combi',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
-- 		INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind)
-- 		 VALUES (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G2ART','31','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G2CL','31','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 		(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G2ML','31','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G2D&T','31','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G2EL','31','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G2FCE','31','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G2GEOG','31','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G2HIST','31','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G2MATHS','31','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G2TL','31','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G2SCI','31','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
-- 
-- 		 v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
--         INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
-- 		(replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code,v_school,'31','0','22',v_course_sys_code,'S1E Subject Combi',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
-- 		INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind)
-- 		VALUES (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3ART','31','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3CL','31','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3HIST','31','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3MATHS','31','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3ML','31','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3TL','31','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3SCI','31','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3EL','31','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),			    (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'MUSIC','31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'PE','31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
-- 		 v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
--         INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
-- 		(replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code,v_school,'31','2','22',v_course_sys_code,'S1E Subject Combi',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
-- 		INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind)
-- 		VALUES (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3ART','31','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3MATHS','31','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3SCI','31','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3GEOG','31','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3HIST','31','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3EL','31','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3CL','31','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3ML','31','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3TL','31','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'PE','31','00','14',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
-- 				
-- 		
-- 		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
--         INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
-- 		(replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code,v_school,'32','0','20',v_course_sys_code,'S2N(T) Subject Combi',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
-- 		INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind)
-- 		VALUES (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G1ART','32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G1CPA','32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G1D&T','32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G1FCE','32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G1MATHS','32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G1SCI','32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G1SS','32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G1EL','32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G1ML','32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G1TL','32','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
-- 
-- 		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
--         INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
-- 		(replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code,v_school,'32','0','21',v_course_sys_code,'S2N(A) Subject Combi',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
-- 		INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind)
-- 		VALUES (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G2ART','32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G2D&T','32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G2EL','32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G2CL','32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G2ML','32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G2FCE','32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G2GEOG','32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G2HIST','32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G2LIT(EL)','32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G2MATHS','32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G2SCI','32','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
-- 		 
-- 		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
--         INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
-- 		(replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code,v_school,'32','0','22',v_course_sys_code,'S2E Subject Combi',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
-- 		INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind)
-- 		VALUES (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3D&T','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3EL','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3FCE','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3GEOG','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3HIGHMUS','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3HIST','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3MATHS','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3SCI','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G2ML','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G2TL','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
-- 
-- 		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
--         INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
-- 		(replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code,v_school,'32','2','22',v_course_sys_code,'S2E Subject Combi',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
-- 		INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind)
-- 		VALUES (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3D&T','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 		       (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3EL','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 		       (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3FCE','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 		       (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3GEOG','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 		       (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3HIGHMUS','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 		       (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3HIST','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 		       (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3MATHS','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 		       (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3SCI','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 		       (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G2ML','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 		       (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G2TL','32','22','15',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
-- 
-- 		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
--         INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
-- 		(replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code,v_school,'33','0','20',v_course_sys_code,'S3N(T) Subject Combi',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
-- 	    INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind)
-- 		VALUES (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G1TL','33','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G1ML','33','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G1CL','33','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G1MUSIC','33','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G1CPA','33','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G1MATHS','33','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G1EL','33','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G1D&T','33','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G1BIO','33','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G1SCI','33','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
-- 	
-- 		
-- 		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
--         INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
-- 		(replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code,v_school,'33','0','21',v_course_sys_code,'S3N(A) Subject Combi',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
-- 	    INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind)		
-- 		VALUES (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G2SCI(P,B)','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G2EL','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G2HIST','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G2MATHS','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G2ML','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 		   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G2SS&GEOG','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G2TL','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 		   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G2AMATHS','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G2GEOG','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G2CL','33','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
-- 
-- 		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
--         INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
-- 		(replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code,v_school,'33','0','22',v_course_sys_code,'S3E Subject Combi',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
-- 		INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind)		
-- 		VALUES (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3TL','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 		   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3SCI(P,C)','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 		   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3SS&GEOG','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3ML','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 		   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3HIGHMUS','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3MATHS','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3D&T','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3CHEM','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3CL','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3EL','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
-- 		
-- 		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
--         INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
-- 		(replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code,v_school,'33','2','22',v_course_sys_code,'S3E Subject Combi',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
-- 		INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind)		
-- 		VALUES (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3TL','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3SCI(P,C)','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 		(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3SS&GEOG','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 		 (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3ML','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 		 (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3HIGHMUS','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3MATHS','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3D&T','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3CHEM','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3CL','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3EL','33','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
-- 
-- 		
-- 		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
--         INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
-- 		(replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code,v_school,'34','0','20',v_course_sys_code,'S4N(T) Subject Combi',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
-- 		INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind)		
-- 		VALUES (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G1ML','34','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G1TL','34','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G1CL','34','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G1D&T','34','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G1MATHS','34','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G1EL','34','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G1BIO','34','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G1CPA','34','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G1SCI','34','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G1ART','34','20','13',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
-- 		
-- 		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0'); 
-- 		INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
-- 		(replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code,v_school,'34','0','21',v_course_sys_code,'S4N(A) Subject Combi',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
-- 		INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind)		
-- 		VALUES	   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G2ART','34','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G2MATHS','34','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G2EL','34','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),   
-- 			(replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G2SCI(P,B)','34','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G2D&T','34','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G2AMATHS','34','21','12',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
-- 		
-- 		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
--         INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
-- 		(replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code,v_school,'34','0','22',v_course_sys_code,'S4E Subject Combi',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
-- 		INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind)		
-- 		VALUES (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3AMATHS','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3D&T','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3GEOG','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3HIST','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			(replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3EL','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3ART','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3BIO','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 		   (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3HIGHART','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3CHEM','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),			   (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3LIT(EL)','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
-- 		
-- 		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
--         INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
-- 		(replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code,v_school,'34','2','22',v_course_sys_code,'S4E Subject Combi',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
-- 		INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind)		
-- 		VALUES (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3AMATHS','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3D&T','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3GEOG','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3HIST','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 		   (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3LIT(EL)','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3ART','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3BIO','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 		   (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3HIGHART','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3EL','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3CHEM','34','22','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');			   
-- 		
-- 		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
--         INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
-- 		(replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code,v_school,'35','0','21',v_course_sys_code,'S5N(A) Subject Combi',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
-- 		INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind)		
-- 		VALUES (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3CL','35','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3ECONS','35','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3EL','35','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3GEOG','35','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3HIST','35','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3MATHS','35','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3ML','35','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3MUSIC','35','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 		   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3SCI(P,C)','35','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 		   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3SS&HIST','35','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'G3TL','35','21','03',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
-- 
-- 		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
--         INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
-- 		(replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code,v_school,'41','0','00',v_course_sys_code,'Arts Subject',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
-- 		INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind)
-- 		VALUES (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'H1ART','41','00','07',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'H1GEOG','41','00','07',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'H1HIST','41','00','07',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'H1MATHS','41','00','07',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'H2ART','41','00','08',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 		   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'H2LIT(EL)','41','00','08',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'H2MUS','41','00','08',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 		   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'H2TS&DRAMA','41','00','08',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
-- 
-- 		v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
--         INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
-- 		(replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code,v_school,'41','0','00',v_course_sys_code,'Science Subj Combi',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
-- 		INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind)		
-- 		VALUES (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'H1BIO','41','00','07',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 		       (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'H1CHEM','41','00','07',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 		       (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'H1ECONS','41','00','07',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 		       (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'H1GEOG','41','00','07',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 		       (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'H1GP','41','00','07',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 		       (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'H1HIST','41','00','07',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 		       (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'H1LIT(EL)','41','00','07',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 		       (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'H1MATHS','41','00','07',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 		       (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'H2EL&L','41','00','08',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 		       (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'H2MUS','41','00','08',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
-- 
--        v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
--         INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
-- 		(replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code,v_school,'42','0','00',v_course_sys_code,'Arts Subject',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
-- 		INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind)
-- 		VALUES (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'H1GP','42','00','07',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'H1PW','42','00','07',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'H2ART','42','00','08',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'H2CL&L','42','00','08',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'H2ECONS','42','00','08',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 		   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'H2FMATHS','42','00','08',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'H2GEOG','42','00','08',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'H2HIST','42','00','08',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 		   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'H2LIT(EL)','42','00','08',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'H2MATHS','42','00','08',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'H2MUS','42','00','08',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');
-- 		
-- v_course_sys_code := LPAD(nextval('cp01.SEQ_COURSE')::TEXT,14,'0');
--         INSERT INTO cp20.cp_cur_cay_course (id,academic_year,course_sys_code,school_code,level_xcode,program_ind,stream_xcode,course_xcode,course_name,course_type_code,curriculum_ind,previous_course_refid,new_jcci_cur_ind,course_offered_ind,version_no,created_ts,created_by,updated_ts,updated_by,delete_ind) VALUES
-- 		(replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'),v_course_sys_code,v_school,'42','0','00',v_course_sys_code,'Science Subj Combi',NULL,'N',NULL,'N','Y',1,NOW(),'LT_DATAPREP',NOW(),'LT_DATAPREP','N');
-- 		INSERT INTO cp20.cp_cur_cay_course_subj_link(id, academic_year, course_refid, school_code, subject_code, level_xcode, stream_xcode, subject_level_icode, bandedgroup_ind, bandedgroup_refid, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind)		
-- 		VALUES (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'H1GEOG','42','00','07',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'H1GP','42','00','07',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'H1HIST','42','00','07',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'H1MATHS','42','00','07',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'H2BIO','42','00','08',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'H2CHEM','42','00','08',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'H2COMP','42','00','08',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'H2ECONS','42','00','08',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			  (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'H2FMATHS','42','00','08',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			  (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'H2KI','42','00','08',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			 (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'H2LIT(EL)','42','00','08',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N'),
-- 			   (replace(public.uuid_generate_v4()::text,'-',''),to_char(now(), 'YYYY'), v_course_sys_code, v_school,'H2PHY','42','00','08',NULL,NULL,1,now(), 'LT_DATAPREP',now(),'LT_DATAPREP','N');

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
AND SCHOOL_CODE BETWEEN '9808' and '9808'
GROUP BY SCHOOL_CODE, LEVEL_XCODE, program_ind;

\qecho 'cp_cur_cay_course_subj_link'
SELECT A.SCHOOL_CODE, a.level_xcode, a.program_ind, COUNT(*) 
from cp20.cp_cur_cay_course a inner join cp20.cp_cur_cay_course_subj_link b on a.course_sys_code = b.course_refid
WHERE a.ACADEMIC_YEAR = TO_CHAR(NOW(), 'YYYY')
AND a.SCHOOL_CODE BETWEEN '9808' and '9808'
GROUP BY A.SCHOOL_CODE, a.level_xcode, a.program_ind
order by A.SCHOOL_CODE, a.level_xcode, a.program_ind;