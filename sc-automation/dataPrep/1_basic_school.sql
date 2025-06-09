-- v_ip_dt_na_geb_school 
    -- 'NA' -> normal school
    -- 'DT' -> dual Track
    -- 'IP' -> FULL IP
    -- 'GE' -> GEP

-- mainlevel_code
-- type_code
-- sap_ind

-- v_school_name

-- cp_arch_sch_stream_parameter edit stream
-- cp_arch_sch_stream_holiday edit stream

-- cp01.cp_arch_class.form_teacher_id is a placeholder


\o 'S2-Non-IP-01_basic_school.log'

\qecho 'cp01.cp_arch_school'
select school_code,  count(*) from cp01.cp_arch_school where school_code between '9808' and '9808' group by school_code;

\qecho 'cp01.cp_arch_sch_stream_holiday'
select school_code, stream_xcode, count(*)  from cp01.cp_arch_sch_stream_holiday 
where academic_year = to_char(now(), 'YYYY') and school_code between '9808' and '9808' group by school_code, stream_xcode order by school_code, stream_xcode;

\qecho 'cp01.CP_ARCH_SCH_YRLY_PARAMETER'
select school_code, count(*)  from cp01.CP_ARCH_SCH_YRLY_PARAMETER 
where academic_year = to_char(now(), 'YYYY') and school_code between '9808' and '9808' group by school_code order by school_code;

\qecho 'cp01.CP_ARCH_SCH_LVL_PARAMETER'
select school_code, level_xcode, count(*) from cp01.CP_ARCH_SCH_LVL_PARAMETER 
where academic_year = to_char(now(), 'YYYY') and school_code between '9808' and '9808' group by school_code,level_xcode order by school_code,level_xcode;

\qecho 'cp01.CP_ARCH_SCH_STREAM_PARAMETER'
select school_code, level_xcode, stream_xcode, count(*)  
from cp01.CP_ARCH_SCH_STREAM_PARAMETER 
where academic_year = to_char(now(), 'YYYY') and school_code between '9808' and '9808'
group by school_code,level_xcode, stream_xcode 
order by school_code,level_xcode, stream_xcode;

select school_code, count(*), 
TERM1_DAYS_NO, TERM2_DAYS_NO, TERM3_DAYS_NO, TERM4_DAYS_NO, 
TERM1_START_DATE, TERM1_END_DATE, TERM2_START_DATE, TERM2_END_DATE, TERM3_START_DATE, TERM3_END_DATE, TERM4_START_DATE, TERM4_END_DATE
from cp01.CP_ARCH_SCH_STREAM_PARAMETER 
where academic_year = to_char(now(), 'YYYY') and school_code between '9808' and '9808'  
group by school_code,
TERM1_DAYS_NO, TERM2_DAYS_NO, TERM3_DAYS_NO, TERM4_DAYS_NO, 
TERM1_START_DATE, TERM1_END_DATE, TERM2_START_DATE, TERM2_END_DATE, TERM3_START_DATE, TERM3_END_DATE, TERM4_START_DATE, TERM4_END_DATE
order by school_code,
TERM1_DAYS_NO, TERM2_DAYS_NO, TERM3_DAYS_NO, TERM4_DAYS_NO, 
TERM1_START_DATE, TERM1_END_DATE, TERM2_START_DATE, TERM2_END_DATE, TERM3_START_DATE, TERM3_END_DATE, TERM4_START_DATE, TERM4_END_DATE;

BEGIN;
DO $BLOCK$
DECLARE
    v_ip_dt_na_geb_school CHARACTER VARYING(2) := 'NA';
    v_mainlevel_code CHARACTER VARYING(2) := NULL;

    v_start_sch DOUBLE PRECISION := 9808;
    v_end_sch DOUBLE PRECISION := 9808;
    
    v_gep_ind CHARACTER VARYING(1) := 'N';
    v_school CHARACTER VARYING(10) := NULL;
    v_school_name CHARACTER VARYING(65) := NULL;
    v_school_holiday TIMESTAMP(0) WITHOUT TIME ZONE := TO_DATE(CONCAT_WS('', '01/01/', to_char(now(), 'YYYY'))::TEXT, 'DD/MM/YYYY');
    v_student_no DOUBLE PRECISION := 0;
    v_student_id CHARACTER VARYING(20) := NULL;
    
    v_cp_arch_school INTEGER := -1;
    v_cp_code_schoolmaster INTEGER := -1;
    v_cp_code_school INTEGER := -1;
    v_previous_year CHARACTER VARYING(4) := (to_char(now(), 'YYYY')::NUMERIC - 1)::text;
    v_current_year CHARACTER VARYING(4) := to_char(now(), 'YYYY');

    v_dateType  CHARACTER VARYING(1) := 'D';
	v_dateDesc  CHARACTER VARYING(10) := 'School Day';

BEGIN
    IF v_ip_dt_na_geb_school = 'GE' THEN
        v_gep_ind := 'Y';
    END IF;

    WHILE v_start_sch <= v_end_sch LOOP
        v_school := trim(TO_CHAR(v_start_sch,'9999'));
        raise notice '%', v_school;
        v_start_sch := v_start_sch + 1;

        v_school_name := concat_ws('',v_school ,' Secondary School S1-S5');

        raise notice 'school_name: %',v_school;
        raise notice '% v_ip_dt_na_geb_school: %', v_school, v_ip_dt_na_geb_school;
        raise notice '% v_school_name: %', v_school, v_school_name;

        /* Insert Into CP_ARCH_SCHOOL*/
        SELECT COUNT(code_value) INTO v_cp_code_schoolmaster 
        FROM cp01.CP_CODE_SCHOOLMASTER WHERE CATEGORY_NAME = 'SCHOOL' and code_value = v_school;
        IF v_cp_code_schoolmaster > 0 THEN
            update cp01.CP_CODE_SCHOOLMASTER 
            set code_full_desc = v_school_name, code_status = '1', updated_date = NOW(), updated_by_id = 'LT_DATAPREP' WHERE CATEGORY_NAME = 'SCHOOL' and code_value = v_school;
        ELSE
            INSERT INTO cp01.CP_CODE_SCHOOLMASTER(category_name,code_value,code_full_desc,code_status,codekey1_name,effective_date,changed_ind,updated_by_id,updated_date)
            VALUES('SCHOOL',v_school,v_school_name,'1','SC',NOW(),0,'LT_DATAPREP',NOW());
        END IF;

        SELECT COUNT(school_code) INTO v_cp_arch_school FROM cp01.cp_arch_school where school_code = v_school;
        IF v_cp_arch_school > 0 THEN
            update cp01.cp_arch_school set school_name = v_school_name, school_ind = 'Y', nature_code='M', 
                mainlevel_code='S2', type_code='G', 
                sap_ind='N',gifted_ind=v_gep_ind where school_code = v_school;
        ELSE
            INSERT INTO cp01.cp_arch_school (school_code, school_name, school_ind, nature_code, mainlevel_code, 
            email_address, principal_name, first_vp_name, second_vp_name, zone_code, constituency_code, cluster_code, mothertongue1_code, mothertongue2_code, mothertongue3_code, aff1_school_code, aff2_school_code, aff3_school_code, aff4_school_code, dgp_code, 
            type_code, sap_ind, 
            autonomous_ind, gifted_ind, 
            ep_ind, missionstatement_desc, visionstatement_desc, orgchart_exist_ind, logo_exist_ind, cca_highlight_desc, special_offering_desc, school_url_name, session_code, 
            effective_start_date, effective_close_date, effective_change_date, 
            entry_criteria_desc, school_status_icode, updated_by_id, division_code, school_remarks, third_vp_name, bus_mrt_desc, special_facilities_desc, affilliated_school_desc, multiple_timetable_ind, 
            bus_desc, mrt_desc, special_emphasis_desc, school_achievement_desc, principal_chinese_name, first_vp_chinese_name, second_vp_chinese_name, third_vp_chinese_name, school_chinese_name, principal_id, first_vp_id, second_vp_id, third_vp_id, pft_percent_no, overweight_percent_no, sendviainterface_ind, 
            subject_highlight_desc, other_awards, display_school_logo_ind, display_org_chart_ind, fourth_vp_id, fifth_vp_id, sixth_vp_id, fourth_vp_name, fifth_vp_name, sixth_vp_name, fourth_vp_chinese_name, fifth_vp_chinese_name, sixth_vp_chinese_name, other_awards_new, imp_sgc_ind, created_date, created_by_id, last_updated_date, dxu_ind)
            VALUES (v_school, v_school_name, 'Y', 'M', 'S2', -- mainlevel_code
            'OPM_PT_01', 'OPM_PT_01', NULL, NULL, '03', 'AM', '01', 'C', 'M', 'T', NULL, NULL, NULL, NULL, 'AM', 
            'G', 'N', -- sap_ind
            'N', v_gep_ind, -- gifted_ind
            NULL, 'OPM_PT_01', 'OPM_PT_01', 'N', 'N', 'OPM_PT_01', 'Nil', 'OPM_PT_01', 'NONE', 
            TO_DATE('02-01-1980', 'DD-MM-YYYY'), NULL, NULL, 
            'OPM_PT_01', 'A', 'CONVERSION', NULL, NULL, NULL, NULL, NULL, NULL, 'N', 
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Y', 
            NULL, NULL, 'N', 'Y', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'N', NULL, 'N', now(), 'LT_DATAPREP', now(), 'Y');
        END IF;

        SELECT mainlevel_code INTO v_mainlevel_code FROM cp01.cp_arch_school where school_code = v_school;
        raise notice '% mainlevel_code: %', v_school, v_mainlevel_code;

        -- UPDATE FOR IP INDICATOR
        SELECT COUNT(code_value) INTO v_cp_code_school
        FROM cp01.cp_code_school WHERE category_name = 'IPSCHOOL' and code_value = v_school;
        IF v_cp_code_school > 0 THEN
            IF v_ip_dt_na_geb_school = 'DT' THEN
                UPDATE cp01.cp_code_school SET code_status = '1',changed_ind = '1' WHERE category_name = 'IPSCHOOL' and code_value = v_school;
            ELSIF v_ip_dt_na_geb_school = 'IP' THEN
                UPDATE cp01.cp_code_school SET code_status = '1',changed_ind = '0' WHERE category_name = 'IPSCHOOL' and code_value = v_school;
            ELSIF v_ip_dt_na_geb_school = 'NA' THEN
                DELETE FROM cp01.cp_code_school WHERE category_name = 'IPSCHOOL' and code_value = v_school;
            END IF;
        ELSE
            IF v_ip_dt_na_geb_school = 'DT' THEN
                INSERT INTO cp01.cp_code_school(category_name,code_value,code_full_desc,code_status,codekey1_name,effective_date,updated_by_id,updated_date,changed_ind)
                VALUES('IPSCHOOL',v_school,v_school_name,'1','IP',NOW(),'LT_DATAPREP',NOW(),'1');
            ELSIF v_ip_dt_na_geb_school = 'IP' THEN
                INSERT INTO cp01.cp_code_school(category_name,code_value,code_full_desc,code_status,codekey1_name,effective_date,updated_by_id,updated_date,changed_ind)
                VALUES('IPSCHOOL',v_school,v_school_name,'1','IP',NOW(),'LT_DATAPREP',NOW(),'0');
            END IF;
        END IF;

        /* Insert into cp_arch_class */
        DELETE FROM cp01.cp_arch_class
            WHERE school_code = v_school and academic_year in (v_previous_year, v_current_year);
            
        -- to assign teacher to class
        IF v_mainlevel_code IN ('T5', 'P') THEN -- PRI1 TO PRI6
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI1-01', 'PRI1-01', '1', '11', 'FD', CONCAT_WS('', 'FS', v_school, '00001'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI1-02', 'PRI1-02', '2', '11', 'FD', CONCAT_WS('', 'FS', v_school, '00002'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI1-03', 'PRI1-03', '3', '11', 'FD', CONCAT_WS('', 'FS', v_school, '00003'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI1-04', 'PRI1-04', '4', '11', 'FD', CONCAT_WS('', 'FS', v_school, '00004'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI1-05', 'PRI1-05', '5', '11', 'FD', CONCAT_WS('', 'FS', v_school, '00005'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI1-06', 'PRI1-06', '6', '11', 'FD', CONCAT_WS('', 'FS', v_school, '00006'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI1-07', 'PRI1-07', '7', '11', 'FD', CONCAT_WS('', 'FS', v_school, '00007'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI1-08', 'PRI1-08', '8', '11', 'FD', CONCAT_WS('', 'FS', v_school, '00008'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI1-09', 'PRI1-09', '9', '11', 'FD', CONCAT_WS('', 'FS', v_school, '00009'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI1-10', 'PRI1-10', '10', '11', 'FD', CONCAT_WS('', 'FS', v_school, '00010'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());

            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI2-01', 'PRI2-01', '1', '12', 'FD', CONCAT_WS('', 'FS', v_school, '00011'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI2-02', 'PRI2-02', '2', '12', 'FD', CONCAT_WS('', 'FS', v_school, '00012'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI2-03', 'PRI2-03', '3', '12', 'FD', CONCAT_WS('', 'FS', v_school, '00013'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI2-04', 'PRI2-04', '4', '12', 'FD', CONCAT_WS('', 'FS', v_school, '00014'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI2-05', 'PRI2-05', '5', '12', 'FD', CONCAT_WS('', 'FS', v_school, '00015'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI2-06', 'PRI2-06', '6', '12', 'FD', CONCAT_WS('', 'FS', v_school, '00016'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI2-07', 'PRI2-07', '7', '12', 'FD', CONCAT_WS('', 'FS', v_school, '00017'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI2-08', 'PRI2-08', '8', '12', 'FD', CONCAT_WS('', 'FS', v_school, '00018'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI2-09', 'PRI2-09', '9', '12', 'FD', CONCAT_WS('', 'FS', v_school, '00019'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI2-10', 'PRI2-10', '10', '12', 'FD', CONCAT_WS('', 'FS', v_school, '00020'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());

            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI3-01', 'PRI3-01', '1', '13', 'FD', CONCAT_WS('', 'FS', v_school, '00021'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI3-02', 'PRI3-02', '2', '13', 'FD', CONCAT_WS('', 'FS', v_school, '00022'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI3-03', 'PRI3-03', '3', '13', 'FD', CONCAT_WS('', 'FS', v_school, '00023'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI3-04', 'PRI3-04', '4', '13', 'FD', CONCAT_WS('', 'FS', v_school, '00024'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI3-05', 'PRI3-05', '5', '13', 'FD', CONCAT_WS('', 'FS', v_school, '00025'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI3-06', 'PRI3-06', '6', '13', 'FD', CONCAT_WS('', 'FS', v_school, '00026'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI3-07', 'PRI3-07', '7', '13', 'FD', CONCAT_WS('', 'FS', v_school, '00027'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI3-08', 'PRI3-08', '8', '13', 'FD', CONCAT_WS('', 'FS', v_school, '00028'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI3-09', 'PRI3-09', '9', '13', 'FD', CONCAT_WS('', 'FS', v_school, '00029'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI3-10', 'PRI3-10', '10', '13', 'FD', CONCAT_WS('', 'FS', v_school, '00030'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());

            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI4-01', 'PRI4-01', '1', '14', 'FD', CONCAT_WS('', 'FS', v_school, '00031'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI4-02', 'PRI4-02', '2', '14', 'FD', CONCAT_WS('', 'FS', v_school, '00032'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI4-03', 'PRI4-03', '3', '14', 'FD', CONCAT_WS('', 'FS', v_school, '00033'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI4-04', 'PRI4-04', '4', '14', 'FD', CONCAT_WS('', 'FS', v_school, '00034'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI4-05', 'PRI4-05', '5', '14', 'FD', CONCAT_WS('', 'FS', v_school, '00035'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI4-06', 'PRI4-06', '6', '14', 'FD', CONCAT_WS('', 'FS', v_school, '00036'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI4-07', 'PRI4-07', '7', '14', 'FD', CONCAT_WS('', 'FS', v_school, '00037'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI4-08', 'PRI4-08', '8', '14', 'FD', CONCAT_WS('', 'FS', v_school, '00038'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI4-09', 'PRI4-09', '9', '14', 'FD', CONCAT_WS('', 'FS', v_school, '00039'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI4-10', 'PRI4-10', '10', '14', 'FD', CONCAT_WS('', 'FS', v_school, '00040'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());

            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI5-01', 'PRI5-01', '1', '15', 'FD', CONCAT_WS('', 'FS', v_school, '00041'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI5-02', 'PRI5-02', '2', '15', 'FD', CONCAT_WS('', 'FS', v_school, '00042'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI5-03', 'PRI5-03', '3', '15', 'FD', CONCAT_WS('', 'FS', v_school, '00043'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI5-04', 'PRI5-04', '4', '15', 'FD', CONCAT_WS('', 'FS', v_school, '00044'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI5-05', 'PRI5-05', '5', '15', 'FD', CONCAT_WS('', 'FS', v_school, '00045'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI5-06', 'PRI5-06', '6', '15', 'FD', CONCAT_WS('', 'FS', v_school, '00046'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI5-07', 'PRI5-07', '7', '15', 'FD', CONCAT_WS('', 'FS', v_school, '00047'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI5-08', 'PRI5-08', '8', '15', 'FD', CONCAT_WS('', 'FS', v_school, '00048'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI5-09', 'PRI5-09', '9', '15', 'FD', CONCAT_WS('', 'FS', v_school, '00049'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI5-10', 'PRI5-10', '10', '15', 'FD', CONCAT_WS('', 'FS', v_school, '00050'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());

            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI6-01', 'PRI6-01', '1', '16', 'FD', CONCAT_WS('', 'FS', v_school, '00051'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI6-02', 'PRI6-02', '2', '16', 'FD', CONCAT_WS('', 'FS', v_school, '00052'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI6-03', 'PRI6-03', '3', '16', 'FD', CONCAT_WS('', 'FS', v_school, '00053'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI6-04', 'PRI6-04', '4', '16', 'FD', CONCAT_WS('', 'FS', v_school, '00054'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI6-05', 'PRI6-05', '5', '16', 'FD', CONCAT_WS('', 'FS', v_school, '00055'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI6-06', 'PRI6-06', '6', '16', 'FD', CONCAT_WS('', 'FS', v_school, '00056'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI6-07', 'PRI6-07', '7', '16', 'FD', CONCAT_WS('', 'FS', v_school, '00057'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI6-08', 'PRI6-08', '8', '16', 'FD', CONCAT_WS('', 'FS', v_school, '00058'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI6-09', 'PRI6-09', '9', '16', 'FD', CONCAT_WS('', 'FS', v_school, '00059'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRI6-10', 'PRI6-10', '10', '16', 'FD', CONCAT_WS('', 'FS', v_school, '00060'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            
            /* previous year*/
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI1-01', 'PRI1-01', '1', '11', 'FD', CONCAT_WS('', 'FS', v_school, '00001'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI1-02', 'PRI1-02', '2', '11', 'FD', CONCAT_WS('', 'FS', v_school, '00002'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI1-03', 'PRI1-03', '3', '11', 'FD', CONCAT_WS('', 'FS', v_school, '00003'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI1-04', 'PRI1-04', '4', '11', 'FD', CONCAT_WS('', 'FS', v_school, '00004'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI1-05', 'PRI1-05', '5', '11', 'FD', CONCAT_WS('', 'FS', v_school, '00005'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI1-06', 'PRI1-06', '6', '11', 'FD', CONCAT_WS('', 'FS', v_school, '00006'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI1-07', 'PRI1-07', '7', '11', 'FD', CONCAT_WS('', 'FS', v_school, '00007'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI1-08', 'PRI1-08', '8', '11', 'FD', CONCAT_WS('', 'FS', v_school, '00008'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI1-09', 'PRI1-09', '9', '11', 'FD', CONCAT_WS('', 'FS', v_school, '00009'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI1-10', 'PRI1-10', '10', '11', 'FD', CONCAT_WS('', 'FS', v_school, '00010'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());

            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI2-01', 'PRI2-01', '1', '12', 'FD', CONCAT_WS('', 'FS', v_school, '00011'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI2-02', 'PRI2-02', '2', '12', 'FD', CONCAT_WS('', 'FS', v_school, '00012'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI2-03', 'PRI2-03', '3', '12', 'FD', CONCAT_WS('', 'FS', v_school, '00013'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI2-04', 'PRI2-04', '4', '12', 'FD', CONCAT_WS('', 'FS', v_school, '00014'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI2-05', 'PRI2-05', '5', '12', 'FD', CONCAT_WS('', 'FS', v_school, '00015'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI2-06', 'PRI2-06', '6', '12', 'FD', CONCAT_WS('', 'FS', v_school, '00016'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI2-07', 'PRI2-07', '7', '12', 'FD', CONCAT_WS('', 'FS', v_school, '00017'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI2-08', 'PRI2-08', '8', '12', 'FD', CONCAT_WS('', 'FS', v_school, '00018'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI2-09', 'PRI2-09', '9', '12', 'FD', CONCAT_WS('', 'FS', v_school, '00019'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI2-10', 'PRI2-10', '10', '12', 'FD', CONCAT_WS('', 'FS', v_school, '00020'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());

            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI3-01', 'PRI3-01', '1', '13', 'FD', CONCAT_WS('', 'FS', v_school, '00021'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI3-02', 'PRI3-02', '2', '13', 'FD', CONCAT_WS('', 'FS', v_school, '00022'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI3-03', 'PRI3-03', '3', '13', 'FD', CONCAT_WS('', 'FS', v_school, '00023'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI3-04', 'PRI3-04', '4', '13', 'FD', CONCAT_WS('', 'FS', v_school, '00024'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI3-05', 'PRI3-05', '5', '13', 'FD', CONCAT_WS('', 'FS', v_school, '00025'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI3-06', 'PRI3-06', '6', '13', 'FD', CONCAT_WS('', 'FS', v_school, '00026'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI3-07', 'PRI3-07', '7', '13', 'FD', CONCAT_WS('', 'FS', v_school, '00027'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI3-08', 'PRI3-08', '8', '13', 'FD', CONCAT_WS('', 'FS', v_school, '00028'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI3-09', 'PRI3-09', '9', '13', 'FD', CONCAT_WS('', 'FS', v_school, '00029'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI3-10', 'PRI3-10', '10', '13', 'FD', CONCAT_WS('', 'FS', v_school, '00030'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());

            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI4-01', 'PRI4-01', '1', '14', 'FD', CONCAT_WS('', 'FS', v_school, '00031'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI4-02', 'PRI4-02', '2', '14', 'FD', CONCAT_WS('', 'FS', v_school, '00032'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI4-03', 'PRI4-03', '3', '14', 'FD', CONCAT_WS('', 'FS', v_school, '00033'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI4-04', 'PRI4-04', '4', '14', 'FD', CONCAT_WS('', 'FS', v_school, '00034'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI4-05', 'PRI4-05', '5', '14', 'FD', CONCAT_WS('', 'FS', v_school, '00035'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI4-06', 'PRI4-06', '6', '14', 'FD', CONCAT_WS('', 'FS', v_school, '00036'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI4-07', 'PRI4-07', '7', '14', 'FD', CONCAT_WS('', 'FS', v_school, '00037'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI4-08', 'PRI4-08', '8', '14', 'FD', CONCAT_WS('', 'FS', v_school, '00038'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI4-09', 'PRI4-09', '9', '14', 'FD', CONCAT_WS('', 'FS', v_school, '00039'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI4-10', 'PRI4-10', '10', '14', 'FD', CONCAT_WS('', 'FS', v_school, '00040'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI5-01', 'PRI5-01', '1', '15', 'FD', CONCAT_WS('', 'FS', v_school, '00041'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI5-02', 'PRI5-02', '2', '15', 'FD', CONCAT_WS('', 'FS', v_school, '00042'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI5-03', 'PRI5-03', '3', '15', 'FD', CONCAT_WS('', 'FS', v_school, '00043'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI5-04', 'PRI5-04', '4', '15', 'FD', CONCAT_WS('', 'FS', v_school, '00044'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI5-05', 'PRI5-05', '5', '15', 'FD', CONCAT_WS('', 'FS', v_school, '00045'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI5-06', 'PRI5-06', '6', '15', 'FD', CONCAT_WS('', 'FS', v_school, '00046'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI5-07', 'PRI5-07', '7', '15', 'FD', CONCAT_WS('', 'FS', v_school, '00047'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI5-08', 'PRI5-08', '8', '15', 'FD', CONCAT_WS('', 'FS', v_school, '00048'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI5-09', 'PRI5-09', '9', '15', 'FD', CONCAT_WS('', 'FS', v_school, '00049'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI5-10', 'PRI5-10', '10', '15', 'FD', CONCAT_WS('', 'FS', v_school, '00050'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());

            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI6-01', 'PRI6-01', '1', '16', 'FD', CONCAT_WS('', 'FS', v_school, '00051'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI6-02', 'PRI6-02', '2', '16', 'FD', CONCAT_WS('', 'FS', v_school, '00052'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI6-03', 'PRI6-03', '3', '16', 'FD', CONCAT_WS('', 'FS', v_school, '00053'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI6-04', 'PRI6-04', '4', '16', 'FD', CONCAT_WS('', 'FS', v_school, '00054'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI6-05', 'PRI6-05', '5', '16', 'FD', CONCAT_WS('', 'FS', v_school, '00055'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI6-06', 'PRI6-06', '6', '16', 'FD', CONCAT_WS('', 'FS', v_school, '00056'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI6-07', 'PRI6-07', '7', '16', 'FD', CONCAT_WS('', 'FS', v_school, '00057'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI6-08', 'PRI6-08', '8', '16', 'FD', CONCAT_WS('', 'FS', v_school, '00058'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI6-09', 'PRI6-09', '9', '16', 'FD', CONCAT_WS('', 'FS', v_school, '00059'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, last_updated_date, updated_by_id, created_by_id, created_date)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRI6-10', 'PRI6-10', '10', '16', 'FD', CONCAT_WS('', 'FS', v_school, '00060'), '1', now(), 'LT_DATAPREP', 'LT_DATAPREP', now());
        END IF;

        IF v_mainlevel_code IN ('S1','S2', 'T1', 'T5', 'T6') THEN -- SEC1, SEC2
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'SEC1-01', 'SEC1-01', '1', '31', 'FD', CONCAT_WS('', 'FSU', v_school, '01'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'SEC1-02', 'SEC1-02', '2', '31', 'FD', CONCAT_WS('', 'FSU', v_school, '02'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'SEC1-03', 'SEC1-03', '3', '31', 'FD', CONCAT_WS('', 'FSU', v_school, '03'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'SEC1-04', 'SEC1-04', '4', '31', 'FD', CONCAT_WS('', 'FSU', v_school, '04'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'SEC1-05', 'SEC1-05', '5', '31', 'FD', CONCAT_WS('', 'FSU', v_school, '05'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'SEC1-06', 'SEC1-06', '6', '31', 'FD', CONCAT_WS('', 'FSU', v_school, '05'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'SEC1-07', 'SEC1-06', '7', '31', 'FD', CONCAT_WS('', 'FSU', v_school, '05'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
        
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'SEC2-01', 'SEC2-01', '1', '32', 'FD', CONCAT_WS('', 'FSU', v_school, '06'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'SEC2-02', 'SEC2-02', '2', '32', 'FD', CONCAT_WS('', 'FSU', v_school, '07'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'SEC2-03', 'SEC2-03', '3', '32', 'FD', CONCAT_WS('', 'FSU', v_school, '08'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'SEC2-04', 'SEC2-04', '4', '32', 'FD', CONCAT_WS('', 'FSU', v_school, '09'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'SEC2-05', 'SEC2-05', '5', '32', 'FD', CONCAT_WS('', 'FSU', v_school, '10'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'SEC2-06', 'SEC2-06', '6', '32', 'FD', CONCAT_WS('', 'FSU', v_school, '10'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'SEC2-07', 'SEC2-07', '7', '32', 'FD', CONCAT_WS('', 'FSU', v_school, '10'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');

            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'SEC1-01', 'SEC1-01', '1', '31', 'FD', CONCAT_WS('', 'FSU', v_school, '01'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'SEC1-02', 'SEC1-02', '2', '31', 'FD', CONCAT_WS('', 'FSU', v_school, '02'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'SEC1-03', 'SEC1-03', '3', '31', 'FD', CONCAT_WS('', 'FSU', v_school, '03'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'SEC1-04', 'SEC1-04', '4', '31', 'FD', CONCAT_WS('', 'FSU', v_school, '04'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'SEC1-05', 'SEC1-05', '5', '31', 'FD', CONCAT_WS('', 'FSU', v_school, '05'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'SEC1-06', 'SEC1-06', '6', '31', 'FD', CONCAT_WS('', 'FSU', v_school, '04'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'SEC1-07', 'SEC1-07', '7', '31', 'FD', CONCAT_WS('', 'FSU', v_school, '05'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'SEC2-01', 'SEC2-01', '1', '32', 'FD', CONCAT_WS('', 'FSU', v_school, '06'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'SEC2-02', 'SEC2-02', '2', '32', 'FD', CONCAT_WS('', 'FSU', v_school, '07'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'SEC2-03', 'SEC2-03', '3', '32', 'FD', CONCAT_WS('', 'FSU', v_school, '08'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'SEC2-04', 'SEC2-04', '4', '32', 'FD', CONCAT_WS('', 'FSU', v_school, '09'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'SEC2-05', 'SEC2-05', '5', '32', 'FD', CONCAT_WS('', 'FSU', v_school, '10'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'SEC2-06', 'SEC2-06', '6', '32', 'FD', CONCAT_WS('', 'FSU', v_school, '10'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'SEC2-07', 'SEC2-07', '7', '32', 'FD', CONCAT_WS('', 'FSU', v_school, '10'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
        END IF;

        IF v_mainlevel_code IN ('S1','S2', 'T1', 'T5', 'T6', 'T2') THEN -- SEC3, SEC4
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'SEC3-01', 'SEC3-01', '1', '33', 'FD', CONCAT_WS('', 'FSU', v_school, '11'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'SEC3-02', 'SEC3-02', '2', '33', 'FD', CONCAT_WS('', 'FSU', v_school, '12'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'SEC3-03', 'SEC3-03', '3', '33', 'FD', CONCAT_WS('', 'FSU', v_school, '13'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'SEC3-04', 'SEC3-04', '4', '33', 'FD', CONCAT_WS('', 'FSU', v_school, '14'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'SEC3-05', 'SEC3-05', '5', '33', 'FD', CONCAT_WS('', 'FSU', v_school, '15'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'SEC3-06', 'SEC3-06', '6', '33', 'FD', CONCAT_WS('', 'FSU', v_school, '15'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'SEC3-07', 'SEC3-07', '7', '33', 'FD', CONCAT_WS('', 'FSU', v_school, '15'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');

            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'SEC4-01', 'SEC4-01', '1', '34', 'FD', CONCAT_WS('', 'FSU', v_school, '16'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'SEC4-02', 'SEC4-02', '2', '34', 'FD', CONCAT_WS('', 'FSU', v_school, '17'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'SEC4-03', 'SEC4-03', '3', '34', 'FD', CONCAT_WS('', 'FSU', v_school, '18'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'SEC4-04', 'SEC4-04', '4', '34', 'FD', CONCAT_WS('', 'FSU', v_school, '19'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'SEC4-05', 'SEC4-05', '5', '34', 'FD', CONCAT_WS('', 'FSU', v_school, '20'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'SEC4-06', 'SEC4-06', '6', '34', 'FD', CONCAT_WS('', 'FSU', v_school, '19'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'SEC4-07', 'SEC4-07', '7', '34', 'FD', CONCAT_WS('', 'FSU', v_school, '20'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');


            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'SEC3-01', 'SEC3-01', '1', '33', 'FD', CONCAT_WS('', 'FSU', v_school, '11'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'SEC3-02', 'SEC3-02', '2', '33', 'FD', CONCAT_WS('', 'FSU', v_school, '12'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'SEC3-03', 'SEC3-03', '3', '33', 'FD', CONCAT_WS('', 'FSU', v_school, '13'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'SEC3-04', 'SEC3-04', '4', '33', 'FD', CONCAT_WS('', 'FSU', v_school, '14'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'SEC3-05', 'SEC3-05', '5', '33', 'FD', CONCAT_WS('', 'FSU', v_school, '15'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'SEC3-06', 'SEC3-06', '6', '33', 'FD', CONCAT_WS('', 'FSU', v_school, '14'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'SEC3-07', 'SEC3-07', '7', '33', 'FD', CONCAT_WS('', 'FSU', v_school, '15'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'SEC4-01', 'SEC4-01', '1', '34', 'FD', CONCAT_WS('', 'FSU', v_school, '16'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'SEC4-02', 'SEC4-02', '2', '34', 'FD', CONCAT_WS('', 'FSU', v_school, '17'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'SEC4-03', 'SEC4-03', '3', '34', 'FD', CONCAT_WS('', 'FSU', v_school, '18'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'SEC4-04', 'SEC4-04', '4', '34', 'FD', CONCAT_WS('', 'FSU', v_school, '19'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'SEC4-05', 'SEC4-05', '5', '34', 'FD', CONCAT_WS('', 'FSU', v_school, '20'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'SEC4-06', 'SEC4-06', '6', '34', 'FD', CONCAT_WS('', 'FSU', v_school, '19'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'SEC4-07', 'SEC4-07', '7', '34', 'FD', CONCAT_WS('', 'FSU', v_school, '20'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
        END IF;
        
        IF v_mainlevel_code IN ('S2','T6') THEN -- SEC5
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'SEC5-01', 'SEC5-01', '1', '35', 'FD', CONCAT_WS('', 'FSU', v_school, '01'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'SEC5-02', 'SEC5-02', '2', '35', 'FD', CONCAT_WS('', 'FSU', v_school, '02'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');

            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::smallint -1 , 'SEC5-01', 'SEC5-01', '1', '35', 'FD', CONCAT_WS('', 'FSU', v_school, '03'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::smallint -1, 'SEC5-02', 'SEC5-02', '2', '35', 'FD', CONCAT_WS('', 'FSU', v_school, '04'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
        END IF;

        IF v_mainlevel_code IN ('T1','T2','T6','J','I') THEN -- PreU1, PreU2
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'JC1-01', 'JC1-01', '1', '41', 'FD', CONCAT_WS('', 'FSU', v_school, '01'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'JC1-02', 'JC1-02', '2', '41', 'FD', CONCAT_WS('', 'FSU', v_school, '02'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'JC1-03', 'JC1-03', '3', '41', 'FD', CONCAT_WS('', 'FSU', v_school, '03'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'JC1-04', 'JC1-04', '4', '41', 'FD', CONCAT_WS('', 'FSU', v_school, '04'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'JC1-05', 'JC1-05', '5', '41', 'FD', CONCAT_WS('', 'FSU', v_school, '05'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');

            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'JC2-01', 'JC2-01', '1', '42', 'FD', CONCAT_WS('', 'FSU', v_school, '06'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'JC2-02', 'JC2-02', '2', '42', 'FD', CONCAT_WS('', 'FSU', v_school, '07'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'JC2-03', 'JC2-03', '3', '42', 'FD', CONCAT_WS('', 'FSU', v_school, '08'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'JC2-04', 'JC2-04', '4', '42', 'FD', CONCAT_WS('', 'FSU', v_school, '09'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'JC2-05', 'JC2-05', '5', '42', 'FD', CONCAT_WS('', 'FSU', v_school, '10'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');

            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'JC1-01', 'JC1-01', '1', '41', 'FD', CONCAT_WS('', 'FSU', v_school, '01'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'JC1-02', 'JC1-02', '2', '41', 'FD', CONCAT_WS('', 'FSU', v_school, '02'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'JC1-03', 'JC1-03', '3', '41', 'FD', CONCAT_WS('', 'FSU', v_school, '03'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'JC1-04', 'JC1-04', '4', '41', 'FD', CONCAT_WS('', 'FSU', v_school, '04'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'JC1-05', 'JC1-05', '5', '41', 'FD', CONCAT_WS('', 'FSU', v_school, '05'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');

            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'JC2-01', 'JC2-01', '1', '42', 'FD', CONCAT_WS('', 'FSU', v_school, '06'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'JC2-02', 'JC2-02', '2', '42', 'FD', CONCAT_WS('', 'FSU', v_school, '07'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'JC2-03', 'JC2-03', '3', '42', 'FD', CONCAT_WS('', 'FSU', v_school, '08'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'JC2-04', 'JC2-04', '4', '42', 'FD', CONCAT_WS('', 'FSU', v_school, '09'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'JC2-05', 'JC2-05', '5', '42', 'FD', CONCAT_WS('', 'FSU', v_school, '10'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
        END IF;

        IF v_mainlevel_code IN ('I') THEN -- PreU3
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'JC3-01', 'JC3-01', '1', '43', 'FD', CONCAT_WS('', 'FSU', v_school, '11'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'JC3-02', 'JC3-02', '2', '43', 'FD', CONCAT_WS('', 'FSU', v_school, '12'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'JC3-03', 'JC3-03', '3', '43', 'FD', CONCAT_WS('', 'FSU', v_school, '13'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'JC3-04', 'JC3-04', '4', '43', 'FD', CONCAT_WS('', 'FSU', v_school, '14'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY'), 'JC3-05', 'JC3-05', '5', '43', 'FD', CONCAT_WS('', 'FSU', v_school, '15'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');

            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'JC3-01', 'JC3-01', '1', '43', 'FD', CONCAT_WS('', 'FSU', v_school, '11'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'JC3-02', 'JC3-02', '2', '43', 'FD', CONCAT_WS('', 'FSU', v_school, '12'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'JC3-03', 'JC3-03', '3', '43', 'FD', CONCAT_WS('', 'FSU', v_school, '13'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'JC3-04', 'JC3-04', '4', '43', 'FD', CONCAT_WS('', 'FSU', v_school, '14'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_arch_class (school_code, academic_year, class_xcode, class_name, class_ref_name, level_xcode, session_code, form_teacher_id, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'JC3-05', 'JC3-05', '5', '43', 'FD', CONCAT_WS('', 'FSU', v_school, '15'), '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
        END IF;


		/* Insert into cp_sal_class_parameter */
        DELETE FROM cp01.cp_sal_class_parameter
            WHERE school_code = v_school and academic_year in (v_previous_year, v_current_year);

        IF v_mainlevel_code IN ('T5', 'P') THEN -- PRI1 TO PRI6
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI1-01', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '11', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI1-02', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '11', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI1-03', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '11', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI1-04', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '11', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI1-05', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '11', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI1-06', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '11', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI1-07', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '11', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI1-08', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '11', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI1-09', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '11', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI1-10', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '11', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI2-01', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '12', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI2-02', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '12', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI2-03', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '12', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI2-04', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '12', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI2-05', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '12', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI2-06', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '12', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI2-07', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '12', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI2-08', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '12', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI2-09', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '12', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI2-10', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '12', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI3-01', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '13', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI3-02', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '13', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI3-03', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '13', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI3-04', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '13', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI3-05', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '13', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI3-06', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '13', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI3-07', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '13', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI3-08', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '13', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI3-09', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '13', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI3-10', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '13', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI4-01', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '14', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI4-02', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '14', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI4-03', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '14', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI4-04', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '14', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI4-05', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '14', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI4-06', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '14', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI4-07', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '14', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');

            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI1-01', v_school, to_char(now(), 'YYYY'), '11', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI1-02', v_school, to_char(now(), 'YYYY'), '11', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI1-03', v_school, to_char(now(), 'YYYY'), '11', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI1-04', v_school, to_char(now(), 'YYYY'), '11', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI1-05', v_school, to_char(now(), 'YYYY'), '11', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI1-06', v_school, to_char(now(), 'YYYY'), '11', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI1-07', v_school, to_char(now(), 'YYYY'), '11', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI1-08', v_school, to_char(now(), 'YYYY'), '11', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI1-09', v_school, to_char(now(), 'YYYY'), '11', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI1-10', v_school, to_char(now(), 'YYYY'), '11', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI2-01', v_school, to_char(now(), 'YYYY'), '12', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI2-02', v_school, to_char(now(), 'YYYY'), '12', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI2-03', v_school, to_char(now(), 'YYYY'), '12', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI2-04', v_school, to_char(now(), 'YYYY'), '12', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI2-05', v_school, to_char(now(), 'YYYY'), '12', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI2-06', v_school, to_char(now(), 'YYYY'), '12', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI2-07', v_school, to_char(now(), 'YYYY'), '12', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI2-08', v_school, to_char(now(), 'YYYY'), '12', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI2-09', v_school, to_char(now(), 'YYYY'), '12', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI2-10', v_school, to_char(now(), 'YYYY'), '12', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI3-01', v_school, to_char(now(), 'YYYY'), '13', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI3-02', v_school, to_char(now(), 'YYYY'), '13', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI3-03', v_school, to_char(now(), 'YYYY'), '13', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI3-04', v_school, to_char(now(), 'YYYY'), '13', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI3-05', v_school, to_char(now(), 'YYYY'), '13', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI3-06', v_school, to_char(now(), 'YYYY'), '13', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI3-07', v_school, to_char(now(), 'YYYY'), '13', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI3-08', v_school, to_char(now(), 'YYYY'), '13', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI3-09', v_school, to_char(now(), 'YYYY'), '13', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI3-10', v_school, to_char(now(), 'YYYY'), '13', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI4-01', v_school, to_char(now(), 'YYYY'), '14', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI4-02', v_school, to_char(now(), 'YYYY'), '14', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI4-03', v_school, to_char(now(), 'YYYY'), '14', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI4-04', v_school, to_char(now(), 'YYYY'), '14', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI4-05', v_school, to_char(now(), 'YYYY'), '14', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI4-06', v_school, to_char(now(), 'YYYY'), '14', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI4-07', v_school, to_char(now(), 'YYYY'), '14', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');

            --START: GEP Classes
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI4-08', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '14', '1', '1', '50', v_gep_ind, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI4-09', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '14', '1', '1', '50', v_gep_ind, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI4-10', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '14', '1', '1', '50', v_gep_ind, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI4-08', v_school, to_char(now(), 'YYYY'), '14', '1', '1', '50', v_gep_ind, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI4-09', v_school, to_char(now(), 'YYYY'), '14', '1', '1', '50', v_gep_ind, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI4-10', v_school, to_char(now(), 'YYYY'), '14', '1', '1', '50', v_gep_ind, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            --END: GEP Classes

            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI5-01', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '15', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI5-02', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '15', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI5-03', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '15', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI5-04', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '15', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI5-05', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '15', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI5-06', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '15', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI5-07', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '15', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI5-01', v_school, to_char(now(), 'YYYY'), '15', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI5-02', v_school, to_char(now(), 'YYYY'), '15', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI5-03', v_school, to_char(now(), 'YYYY'), '15', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI5-04', v_school, to_char(now(), 'YYYY'), '15', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI5-05', v_school, to_char(now(), 'YYYY'), '15', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI5-06', v_school, to_char(now(), 'YYYY'), '15', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI5-07', v_school, to_char(now(), 'YYYY'), '15', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');

            --START: GEP Classes
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI5-08', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '15', '1', '1', '50', v_gep_ind, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI5-09', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '15', '1', '1', '50', v_gep_ind, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI5-10', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '15', '1', '1', '50', v_gep_ind, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI5-08', v_school, to_char(now(), 'YYYY'), '15', '1', '1', '50', v_gep_ind, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI5-09', v_school, to_char(now(), 'YYYY'), '15', '1', '1', '50', v_gep_ind, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI5-10', v_school, to_char(now(), 'YYYY'), '15', '1', '1', '50', v_gep_ind, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            --END: GEP Classes

            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI6-01', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '16', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI6-02', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '16', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI6-03', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '16', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI6-04', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '16', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI6-05', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '16', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI6-06', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '16', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI6-07', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '16', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');

            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI6-01', v_school, to_char(now(), 'YYYY'), '16', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI6-02', v_school, to_char(now(), 'YYYY'), '16', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI6-03', v_school, to_char(now(), 'YYYY'), '16', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI6-04', v_school, to_char(now(), 'YYYY'), '16', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI6-05', v_school, to_char(now(), 'YYYY'), '16', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI6-06', v_school, to_char(now(), 'YYYY'), '16', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI6-07', v_school, to_char(now(), 'YYYY'), '16', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');

            --START: GEP Classes
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI6-08', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '16', '1', '1', '50', v_gep_ind, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI6-09', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '16', '1', '1', '50', v_gep_ind, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI6-10', v_school, to_char(now(), 'YYYY')::NUMERIC - 1, '16', '1', '1', '50', v_gep_ind, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI6-08', v_school, to_char(now(), 'YYYY'), '16', '1', '1', '50', v_gep_ind, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI6-09', v_school, to_char(now(), 'YYYY'), '16', '1', '1', '50', v_gep_ind, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('PRI6-10', v_school, to_char(now(), 'YYYY'), '16', '1', '1', '50', v_gep_ind, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            --END: GEP Classes
        END IF;

        IF v_mainlevel_code IN ('S1','S2', 'T1', 'T5', 'T6') THEN -- SEC1, SEC2
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('SEC1-01', v_school, to_char(now(), 'YYYY'), '31', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('SEC1-02', v_school, to_char(now(), 'YYYY'), '31', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('SEC1-03', v_school, to_char(now(), 'YYYY'), '31', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('SEC1-04', v_school, to_char(now(), 'YYYY'), '31', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('SEC1-05', v_school, to_char(now(), 'YYYY'), '31', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('SEC1-06', v_school, to_char(now(), 'YYYY'), '31', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('SEC1-07', v_school, to_char(now(), 'YYYY'), '31', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');

            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('SEC2-01', v_school, to_char(now(), 'YYYY'), '32', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('SEC2-02', v_school, to_char(now(), 'YYYY'), '32', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('SEC2-03', v_school, to_char(now(), 'YYYY'), '32', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('SEC2-04', v_school, to_char(now(), 'YYYY'), '32', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('SEC2-05', v_school, to_char(now(), 'YYYY'), '32', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('SEC2-06', v_school, to_char(now(), 'YYYY'), '32', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('SEC2-07', v_school, to_char(now(), 'YYYY'), '32', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
        END IF;

        IF v_mainlevel_code IN ('S1','S2', 'T1', 'T5', 'T6', 'T2') THEN -- SEC3, SEC4
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('SEC3-01', v_school, to_char(now(), 'YYYY'), '33', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('SEC3-02', v_school, to_char(now(), 'YYYY'), '33', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('SEC3-03', v_school, to_char(now(), 'YYYY'), '33', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('SEC3-04', v_school, to_char(now(), 'YYYY'), '33', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('SEC3-05', v_school, to_char(now(), 'YYYY'), '33', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('SEC3-06', v_school, to_char(now(), 'YYYY'), '33', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('SEC3-07', v_school, to_char(now(), 'YYYY'), '33', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');

            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('SEC4-01', v_school, to_char(now(), 'YYYY'), '34', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('SEC4-02', v_school, to_char(now(), 'YYYY'), '34', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('SEC4-03', v_school, to_char(now(), 'YYYY'), '34', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('SEC4-04', v_school, to_char(now(), 'YYYY'), '34', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('SEC4-05', v_school, to_char(now(), 'YYYY'), '34', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('SEC4-06', v_school, to_char(now(), 'YYYY'), '34', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('SEC4-07', v_school, to_char(now(), 'YYYY'), '34', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
        END IF;
        
        IF v_mainlevel_code IN ('S2','T6') THEN -- SEC5
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('SEC5-01', v_school, to_char(now(), 'YYYY'), '35', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('SEC5-02', v_school, to_char(now(), 'YYYY'), '35', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
        END IF;
		
        IF v_mainlevel_code IN ('T1','T2','T6','J','I') THEN -- PreU1, PreU2
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('JC1-01', v_school, to_char(now(), 'YYYY'), '41', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('JC1-02', v_school, to_char(now(), 'YYYY'), '41', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('JC1-03', v_school, to_char(now(), 'YYYY'), '41', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('JC1-04', v_school, to_char(now(), 'YYYY'), '41', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('JC1-05', v_school, to_char(now(), 'YYYY'), '41', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');

            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('JC2-01', v_school, to_char(now(), 'YYYY'), '42', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('JC2-02', v_school, to_char(now(), 'YYYY'), '42', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('JC2-03', v_school, to_char(now(), 'YYYY'), '42', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('JC2-04', v_school, to_char(now(), 'YYYY'), '42', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('JC2-05', v_school, to_char(now(), 'YYYY'), '42', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
        END IF;

        IF v_mainlevel_code IN ('I') THEN -- PreU3
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('JC3-01', v_school, to_char(now(), 'YYYY'), '43', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('JC3-02', v_school, to_char(now(), 'YYYY'), '43', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('JC3-03', v_school, to_char(now(), 'YYYY'), '43', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('JC3-04', v_school, to_char(now(), 'YYYY'), '43', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            INSERT INTO cp01.cp_sal_class_parameter (class_xcode, school_code, academic_year, level_xcode, sorting_type_icode, min_students_no, max_students_no, gep_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
            VALUES ('JC3-05', v_school, to_char(now(), 'YYYY'), '43', '1', '1', '50', 'N', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
        END IF;
        
        DELETE FROM cp01.cp_arch_sch_stream_holiday
            WHERE school_code = v_school and academic_year = to_char(now(), 'YYYY');

        /* Insert Into CP_ARCH_SCH_STREAM_HOLIDAY */
	    v_school_holiday := TO_DATE(CONCAT_WS('', '01/01/', to_char(now(), 'YYYY'))::TEXT, 'DD/MM/YYYY');
         WHILE (TO_CHAR(v_school_holiday, 'YYYY')::NUMERIC  < TO_CHAR(now(), 'YYYY')::NUMERIC + 1)
		 LOOP
            v_dateType :='D';
			v_dateDesc := 'School Day';
			if (EXTRACT(ISODOW FROM v_school_holiday) IN (6,7)) THEN
				v_dateType := 'W';
				v_dateDesc := 'Weekend';
			END IF;

            IF v_mainlevel_code IN ('T5', 'P') THEN -- PRI1 TO PRI6
                INSERT INTO cp01.cp_arch_sch_stream_holiday (school_code, academic_year, level_xcode, stream_xcode, calendar_date, date_type_icode, date_desc, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
                VALUES (v_school, to_char(now(), 'YYYY'), '11', '00', v_school_holiday, v_dateType,v_dateDesc, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
                INSERT INTO cp01.cp_arch_sch_stream_holiday (school_code, academic_year, level_xcode, stream_xcode, calendar_date, date_type_icode, date_desc, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
                VALUES (v_school, to_char(now(), 'YYYY'), '12', '00', v_school_holiday, v_dateType, v_dateDesc, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
                INSERT INTO cp01.cp_arch_sch_stream_holiday (school_code, academic_year, level_xcode, stream_xcode, calendar_date, date_type_icode, date_desc, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
                VALUES (v_school, to_char(now(), 'YYYY'), '13', '00', v_school_holiday, v_dateType, v_dateDesc, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
                INSERT INTO cp01.cp_arch_sch_stream_holiday (school_code, academic_year, level_xcode, stream_xcode, calendar_date, date_type_icode, date_desc, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
                VALUES (v_school, to_char(now(), 'YYYY'), '14', '00', v_school_holiday, v_dateType, v_dateDesc, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
                INSERT INTO cp01.cp_arch_sch_stream_holiday (school_code, academic_year, level_xcode, stream_xcode, calendar_date, date_type_icode, date_desc, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
                VALUES (v_school, to_char(now(), 'YYYY'), '15', '00', v_school_holiday, v_dateType, v_dateDesc, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
                INSERT INTO cp01.cp_arch_sch_stream_holiday (school_code, academic_year, level_xcode, stream_xcode, calendar_date, date_type_icode, date_desc, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
                VALUES (v_school, to_char(now(), 'YYYY'), '16', '00', v_school_holiday, v_dateType, v_dateDesc, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            END IF;

            IF v_mainlevel_code IN ('S1','S2', 'T1', 'T5', 'T6') THEN -- SEC1, SEC2
                INSERT INTO cp01.cp_arch_sch_stream_holiday (school_code, academic_year, level_xcode, stream_xcode, calendar_date, date_type_icode, date_desc, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
                VALUES (v_school, to_char(now(), 'YYYY'), '31', '00', v_school_holiday, v_dateType,v_dateDesc, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');

                INSERT INTO cp01.cp_arch_sch_stream_holiday (school_code, academic_year, level_xcode, stream_xcode, calendar_date, date_type_icode, date_desc, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
                VALUES (v_school, to_char(now(), 'YYYY'), '32', '22', v_school_holiday, v_dateType,v_dateDesc, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
                INSERT INTO cp01.cp_arch_sch_stream_holiday (school_code, academic_year, level_xcode, stream_xcode, calendar_date, date_type_icode, date_desc, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
                VALUES (v_school, to_char(now(), 'YYYY'), '32', '21', v_school_holiday, v_dateType,v_dateDesc, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
                INSERT INTO cp01.cp_arch_sch_stream_holiday (school_code, academic_year, level_xcode, stream_xcode, calendar_date, date_type_icode, date_desc, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
                VALUES (v_school, to_char(now(), 'YYYY'), '32', '20', v_school_holiday, v_dateType,v_dateDesc, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            END IF;

            IF v_mainlevel_code IN ('S1','S2', 'T1', 'T5', 'T6', 'T2') THEN -- SEC3, SEC4
                INSERT INTO cp01.cp_arch_sch_stream_holiday (school_code, academic_year, level_xcode, stream_xcode, calendar_date, date_type_icode, date_desc, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
                VALUES (v_school, to_char(now(), 'YYYY'), '33', '22', v_school_holiday, v_dateType,v_dateDesc, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
                INSERT INTO cp01.cp_arch_sch_stream_holiday (school_code, academic_year, level_xcode, stream_xcode, calendar_date, date_type_icode, date_desc, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
                VALUES (v_school, to_char(now(), 'YYYY'), '33', '21', v_school_holiday, v_dateType,v_dateDesc, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
                INSERT INTO cp01.cp_arch_sch_stream_holiday (school_code, academic_year, level_xcode, stream_xcode, calendar_date, date_type_icode, date_desc, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
                VALUES (v_school, to_char(now(), 'YYYY'), '33', '20', v_school_holiday, v_dateType,v_dateDesc, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');

                INSERT INTO cp01.cp_arch_sch_stream_holiday (school_code, academic_year, level_xcode, stream_xcode, calendar_date, date_type_icode, date_desc, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
                VALUES (v_school, to_char(now(), 'YYYY'), '34', '22', v_school_holiday, v_dateType,v_dateDesc, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
                INSERT INTO cp01.cp_arch_sch_stream_holiday (school_code, academic_year, level_xcode, stream_xcode, calendar_date, date_type_icode, date_desc, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
                VALUES (v_school, to_char(now(), 'YYYY'), '34', '21', v_school_holiday, v_dateType,v_dateDesc, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
                INSERT INTO cp01.cp_arch_sch_stream_holiday (school_code, academic_year, level_xcode, stream_xcode, calendar_date, date_type_icode, date_desc, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
                VALUES (v_school, to_char(now(), 'YYYY'), '34', '20', v_school_holiday, v_dateType,v_dateDesc, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            END IF;

            IF v_mainlevel_code IN ('S2','T6') THEN -- SEC5
                INSERT INTO cp01.cp_arch_sch_stream_holiday (school_code, academic_year, level_xcode, stream_xcode, calendar_date, date_type_icode, date_desc, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
                VALUES (v_school, to_char(now(), 'YYYY'), '35', '21', v_school_holiday, v_dateType,v_dateDesc, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            END IF;

            IF v_mainlevel_code IN ('T1','T2','T6','J','I') THEN -- PreU1, PreU2
                INSERT INTO cp01.cp_arch_sch_stream_holiday (school_code, academic_year, level_xcode, stream_xcode, calendar_date, date_type_icode, date_desc, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
                VALUES (v_school, to_char(now(), 'YYYY'), '41', '00', v_school_holiday, v_dateType,v_dateDesc, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
                INSERT INTO cp01.cp_arch_sch_stream_holiday (school_code, academic_year, level_xcode, stream_xcode, calendar_date, date_type_icode, date_desc, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
                VALUES (v_school, to_char(now(), 'YYYY'), '42', '00', v_school_holiday, v_dateType,v_dateDesc, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            END IF;

            IF v_mainlevel_code IN ('I') THEN -- PreU3
                INSERT INTO cp01.cp_arch_sch_stream_holiday (school_code, academic_year, level_xcode, stream_xcode, calendar_date, date_type_icode, date_desc, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
                VALUES (v_school, to_char(now(), 'YYYY'), '43', '00', v_school_holiday, v_dateType,v_dateDesc, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP');
            END IF;

            v_school_holiday := v_school_holiday + INTERVAL '1 day';
        END LOOP;
		

        DELETE FROM cp01.cp_arch_school_parameter
        WHERE school_code = v_school;
        --COMMIT;
        /* Insert into cp_arch_school_parameter */
        IF v_mainlevel_code IN ('I') THEN
            INSERT INTO cp01.cp_arch_school_parameter (school_code, framework_type_icode, break_tie_icode, pass_fail_xcode, olevel_mt_ind, promotional_exam_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id, curriculum_changed_ind, alevel_downgrade_ind, rank_pts_olevel_mt_ind, rank_pts_gsc_ind, late_ind, del_late_ind, truancy_ind, del_truancy_ind, late_days_no, late_subsequent_no, late_period, del_late_off_ind, del_truancy_off_ind, new_rank_pts_olevel_mt_ind, new_rank_pts_gsc_ind, h2_downgrade_ind, new_rank_pts_aolevel_mt_ind, new_rank_pts_h1ntil_ind, new_rank_pts_h1fl_ind, customise_pq_rating_set_ind)
            VALUES (v_school, '02', NULL, NULL, 'N', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'Y', 'Y', 'Y', 'N', 'N', 'N', 'N', 'N', '4', '1', 'Year', 'N', 'N', 'Y', NULL, 'Y', 'Y', 'N', 'N', 'Y');

        ELSIF v_mainlevel_code IN ('J') THEN
            INSERT INTO cp01.cp_arch_school_parameter (school_code, framework_type_icode, break_tie_icode, pass_fail_xcode, olevel_mt_ind, promotional_exam_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id, curriculum_changed_ind, alevel_downgrade_ind, rank_pts_olevel_mt_ind, rank_pts_gsc_ind, late_ind, del_late_ind, truancy_ind, del_truancy_ind, late_days_no, late_subsequent_no, late_period, del_late_off_ind, del_truancy_off_ind, new_rank_pts_olevel_mt_ind, new_rank_pts_gsc_ind, h2_downgrade_ind, new_rank_pts_aolevel_mt_ind, new_rank_pts_h1ntil_ind, new_rank_pts_h1fl_ind, customise_pq_rating_set_ind)
            VALUES (v_school, '02', NULL, NULL, 'Y', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'Y', 'Y', 'Y', 'Y', 'N', 'N', 'N', 'N', '4', '1', 'Year', 'N', 'N', 'N', NULL, 'Y', 'N', 'N', 'N', 'Y');

        ELSIF v_mainlevel_code IN ('K') THEN
            INSERT INTO cp01.cp_arch_school_parameter (school_code, framework_type_icode, break_tie_icode, pass_fail_xcode, olevel_mt_ind, promotional_exam_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id, curriculum_changed_ind, alevel_downgrade_ind, rank_pts_olevel_mt_ind, rank_pts_gsc_ind, late_ind, del_late_ind, truancy_ind, del_truancy_ind, late_days_no, late_subsequent_no, late_period, del_late_off_ind, del_truancy_off_ind, new_rank_pts_olevel_mt_ind, new_rank_pts_gsc_ind, h2_downgrade_ind, new_rank_pts_aolevel_mt_ind, new_rank_pts_h1ntil_ind, new_rank_pts_h1fl_ind, customise_pq_rating_set_ind)
            VALUES (v_school, '01', NULL, NULL, NULL, NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', NULL, NULL, NULL, 'N', 'N', 'N', 'N', '4', '1', 'Year', 'N', 'N', NULL, NULL, NULL, NULL, NULL, NULL, 'Y');

        ELSIF v_mainlevel_code IN ('P','S1') THEN
            INSERT INTO cp01.cp_arch_school_parameter (school_code, framework_type_icode, break_tie_icode, pass_fail_xcode, olevel_mt_ind, promotional_exam_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id, curriculum_changed_ind, alevel_downgrade_ind, rank_pts_olevel_mt_ind, rank_pts_gsc_ind, late_ind, del_late_ind, truancy_ind, del_truancy_ind, late_days_no, late_subsequent_no, late_period, del_late_off_ind, del_truancy_off_ind, new_rank_pts_olevel_mt_ind, new_rank_pts_gsc_ind, h2_downgrade_ind, new_rank_pts_aolevel_mt_ind, new_rank_pts_h1ntil_ind, new_rank_pts_h1fl_ind, customise_pq_rating_set_ind)
            VALUES (v_school, '01', NULL, NULL, NULL, NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'Y', 'Y', NULL, NULL, 'N', 'N', 'N', 'N', '4', '1', 'Year', 'N', 'N', NULL, NULL, NULL, NULL, NULL, NULL, 'Y');

        ELSIF v_mainlevel_code IN ('T1') THEN
            INSERT INTO cp01.cp_arch_school_parameter (school_code, framework_type_icode, break_tie_icode, pass_fail_xcode, olevel_mt_ind, promotional_exam_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id, curriculum_changed_ind, alevel_downgrade_ind, rank_pts_olevel_mt_ind, rank_pts_gsc_ind, late_ind, del_late_ind, truancy_ind, del_truancy_ind, late_days_no, late_subsequent_no, late_period, del_late_off_ind, del_truancy_off_ind, new_rank_pts_olevel_mt_ind, new_rank_pts_gsc_ind, h2_downgrade_ind, new_rank_pts_aolevel_mt_ind, new_rank_pts_h1ntil_ind, new_rank_pts_h1fl_ind, customise_pq_rating_set_ind)
            VALUES (v_school, '02', NULL, 'Y', 'N', 'N', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'Y', 'Y', NULL, NULL, 'N', 'N', 'N', 'N', '4', '1', 'Year', 'N', 'N', NULL, NULL, NULL, 'N', 'N', 'N', 'Y');

        ELSIF v_mainlevel_code IN ('S2','T5') THEN
            INSERT INTO cp01.cp_arch_school_parameter (school_code, framework_type_icode, break_tie_icode, pass_fail_xcode, olevel_mt_ind, promotional_exam_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id, curriculum_changed_ind, alevel_downgrade_ind, rank_pts_olevel_mt_ind, rank_pts_gsc_ind, late_ind, del_late_ind, truancy_ind, del_truancy_ind, late_days_no, late_subsequent_no, late_period, del_late_off_ind, del_truancy_off_ind, new_rank_pts_olevel_mt_ind, new_rank_pts_gsc_ind, h2_downgrade_ind, new_rank_pts_aolevel_mt_ind, new_rank_pts_h1ntil_ind, new_rank_pts_h1fl_ind, customise_pq_rating_set_ind)
            VALUES (v_school, '01', 'M', NULL, NULL, NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'Y', 'Y', NULL, NULL, 'N', 'N', 'N', 'N', '4', '1', 'Year', 'N', 'N', NULL, NULL, NULL, NULL, NULL, NULL, 'Y');

        ELSE -- T6 & DEFAULTS
            INSERT INTO cp01.cp_arch_school_parameter (school_code, framework_type_icode, break_tie_icode, pass_fail_xcode, olevel_mt_ind, promotional_exam_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id, curriculum_changed_ind, alevel_downgrade_ind, rank_pts_olevel_mt_ind, rank_pts_gsc_ind, late_ind, del_late_ind, truancy_ind, del_truancy_ind, late_days_no, late_subsequent_no, late_period, del_late_off_ind, del_truancy_off_ind, new_rank_pts_olevel_mt_ind, new_rank_pts_gsc_ind, h2_downgrade_ind, new_rank_pts_aolevel_mt_ind, new_rank_pts_h1ntil_ind, new_rank_pts_h1fl_ind, customise_pq_rating_set_ind)
            VALUES (v_school, '01', 'M', NULL, NULL, NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'Y', NULL, NULL, NULL, 'N', 'N', 'N', 'N', '4', '1', 'Year', 'N', 'N', NULL, NULL, NULL, NULL, NULL, NULL, 'Y');
        END IF;

        /* Insert into cp_arch_school_transaction */
        DELETE FROM cp01.cp_arch_school_transaction
            WHERE school_code = v_school;
        
        IF v_mainlevel_code IN ('T5', 'P') THEN -- PRI1 TO PRI6
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'CALC', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '11');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'CALC', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '12');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'CALC', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '13');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'CALC', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '14');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'CALC', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '15');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'CALC', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '16');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'CALN', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '11');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'CALN', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '12');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'CALN', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '13');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'CALN', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '14');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'CALN', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '15');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'CALN', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '16');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'CUR', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '11');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'CUR', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '12');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'CUR', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '13');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'CUR', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '14');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'CUR', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '15');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'CUR', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '16');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'NWYR', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '11');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'NWYR', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '12');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'NWYR', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '13');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'NWYR', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '14');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'NWYR', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '15');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'NWYR', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '16');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'POST', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '11');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'POST', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '16');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PRS1', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '11');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PRS1', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '12');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PRS1', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '13');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PRS1', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '14');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PRS1', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '15');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PRS1', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '16');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PRS2', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '11');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PRS2', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '12');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PRS2', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '13');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PRS2', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '14');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PRS2', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '15');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PRS2', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '16');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'RSAL', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '11');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'RSAL', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '12');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'RSAL', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '13');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'RSAL', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '14');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'RSAL', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '15');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'RSAL', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '16');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'SAL', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '11');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'SAL', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '12');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'SAL', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '13');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'SAL', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '14');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'SAL', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '15');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'SAL', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '16');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'CALC', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '11');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'CALC', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '12');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'CALC', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '13');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'CALC', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '14');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'CALC', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '15');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'CALC', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '16');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'CALN', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '11');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'CALN', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '12');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'CALN', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '13');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'CALN', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '14');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'CALN', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '15');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'CALN', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '16');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'CUR', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '11');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'CUR', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '12');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'CUR', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '13');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'CUR', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '14');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'CUR', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '15');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'CUR', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '16');


            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'NWYR', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '11');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'NWYR', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '12');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'NWYR', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '13');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'NWYR', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '14');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'NWYR', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '15');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'NWYR', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '16');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'POST', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '11');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'POST', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '16');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRS1','CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '11');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRS1','CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '12');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRS1','CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '13');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRS1','CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '14');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRS1','CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '15');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRS1','CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '16');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRS2','CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '11');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRS2','CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '12');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRS2','CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '13');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRS2','CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '14');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRS2','CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '15');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRS2','CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '16');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'RSAL','CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '11');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'RSAL','CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '12');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'RSAL','CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '13');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'RSAL','CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '14');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'RSAL','CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '15');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'RSAL','CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '16');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'SAL', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '11');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'SAL', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '12');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'SAL', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '13');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'SAL', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '14');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'SAL', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '15');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'SAL', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '16');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'CALC', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '11');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'CALC', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '12');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'CALC', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '13');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'CALC', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '14');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'CALC', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '15');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'CALC', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '16');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'CALN', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '11');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'CALN', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '12');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'CALN', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '13');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'CALN', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '14');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'CALN', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '15');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'CALN', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '16');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'CUR', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '11');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'CUR', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '12');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'CUR', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '13');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'CUR', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '14');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'CUR', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '15');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'CUR', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '16');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'NWYR', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '11');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'NWYR', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '12');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'NWYR', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '13');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'NWYR', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '14');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'NWYR', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '15');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'NWYR', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '16');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'POST', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '11');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'POST', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '16');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRS1', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '11');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRS1', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '12');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRS1', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '13');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRS1', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '14');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRS1', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '15');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRS1', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '16');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRS2', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '11');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRS2', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '12');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRS2', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '13');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRS2', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '14');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRS2', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '15');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRS2', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '16');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'RSAL', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '11');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'RSAL', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '12');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'RSAL', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '13');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'RSAL', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '14');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'RSAL', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '15');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'RSAL', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '16');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'SAL', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '11');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'SAL', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '12');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'SAL', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '13');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'SAL', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '14');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'SAL', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '15');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'SAL', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '16');
        END IF;

        IF v_mainlevel_code IN ('S1','S2', 'T1', 'T5', 'T6') THEN -- SEC1, SEC2
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'CALC', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '31');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'CALC', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '32');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'CALN', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '31');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'CALN', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '32');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'CUR', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '31');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'CUR', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '32');
            
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'NWYR', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '31');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'NWYR', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '32');
            
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRS1', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '31');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRS1', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '32');
            
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRS2', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '31');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRS2', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '32'); 
            
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'RSAL', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '31');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'RSAL', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '32');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'SAL', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '31');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'SAL', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '32');
            
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'CALC', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '31');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'CALC', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '32');
            
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'CALN', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '31');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'CALN', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '32');
            
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'CUR', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '31');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'CUR', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '32');
            
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'JAE', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '31');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'JAE', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '32');
            
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'NWYR', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '31');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'NWYR', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '32'); 
            
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PAE', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '31');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PAE', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '32');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'POST', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '31');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'POST', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '32');
            
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRS1', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '31');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRS1', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '32');
            
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRS2', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '31');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRS2', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '32');
            
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'RSAL', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '31');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'RSAL', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '32');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'SAL', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '31');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'SAL', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '32');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'CALC', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '31');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'CALC', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '32');
            
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'CALN', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '31');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'CALN', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '32');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'CUR', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '31');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'CUR', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '32'); 
            
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'JAE', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '31');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'JAE', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '32'); 
            
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'NWYR', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '31');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'NWYR', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '32');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PAE', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '31');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PAE', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '32');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'POST', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '31');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'POST', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '32');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PRS1', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '31');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PRS1', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '32'); 

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PRS2', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '31');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PRS2', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '32');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'RSAL', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '31');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'RSAL', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '32');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'SAL', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '31');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'SAL', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '32');
        END IF;

        IF v_mainlevel_code IN ('S1','S2', 'T1', 'T5', 'T6', 'T2') THEN -- SEC3, SEC4
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'CALC', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '33');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'CALC', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '34');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'CALN', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '33');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'CALN', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '34'); 

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'CUR', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '33');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'CUR', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '34'); 

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'NWYR', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '33');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'NWYR', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '34'); 

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRS1', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '33');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRS1', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '34'); 

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRS2', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '33');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRS2', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '34');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'RSAL', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '33');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'RSAL', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '34');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'SAL', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '33');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'SAL', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '34'); 

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'CALC', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '33');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'CALC', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '34'); 

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'CALN', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '33');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'CALN', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '34'); 

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'CUR', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '33');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'CUR', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '34');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'JAE', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '33');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'JAE', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '34'); 

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'NWYR', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '33');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'NWYR', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '34');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PAE', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '33');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PAE', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '34');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'POST', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '33');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'POST', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '34'); 

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRS1', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '33');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRS1', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '34'); 

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRS2', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '33');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRS2', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '34'); 

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'RSAL', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '33');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'RSAL', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '34'); 

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'SAL', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '33');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'SAL', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '34'); 

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'CALC', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '33');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'CALC', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '34'); 

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'CALN', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '33');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'CALN', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '34');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'CUR', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '33');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'CUR', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '34');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'JAE', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '33');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'JAE', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '34');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'NWYR', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '33');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'NWYR', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '34'); 

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PAE', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '33');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PAE', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '34'); 

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'POST', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '33');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'POST', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '34'); 

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PRS1', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '33');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PRS1', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '34');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PRS2', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '33');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PRS2', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '34'); 

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'RSAL', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '33');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'RSAL', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '34'); 

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'SAL', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '33');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'SAL', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '34'); 
        END IF;

        IF v_mainlevel_code IN ('S2','T6') THEN -- copy Sec4 to Sec5
            insert into cp01.cp_arch_school_transaction
            select  v_school  ,  to_char(now(),'YYYY') , process_type_icode, process_status_icode, record_version_no, NOW(), created_by_id, NOW(), updated_by_id, remarks_desc, '35', unconfirm_ind
            from cp01.cp_arch_school_transaction where academic_year  =  to_char(now(),'YYYY')
            and school_code = v_school and level_xcode ='34';
            
            insert into cp01.cp_arch_school_transaction
            select  v_school  ,   to_char(now(),'YYYY')::smallInt - 1 , process_type_icode, process_status_icode, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id, remarks_desc, '35', unconfirm_ind
            from cp01.cp_arch_school_transaction where academic_year::smallInt  =  to_char(now(),'YYYY')::smallInt - 1
            and school_code = v_school and level_xcode ='34';

            insert into cp01.cp_arch_school_transaction
            select  v_school  ,   to_char(now(),'YYYY')::smallInt - 2 , process_type_icode, process_status_icode, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id, remarks_desc, '35', unconfirm_ind
            from cp01.cp_arch_school_transaction where academic_year::smallInt  =  to_char(now(),'YYYY')::smallInt - 2
            and school_code = v_school and level_xcode ='34';
        END IF;

        IF v_mainlevel_code IN ('S1', 'T1', 'T5') THEN -- containing IP stud, PIP & PNIP to be CF
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PIP', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '31');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PNIP', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '31');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PIP', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '31');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PNIP', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '31');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PIP', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '31');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PNIP', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '31');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PIP', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '32');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PNIP', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '32');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PIP', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '32');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PNIP', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '32');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PIP', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '32');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PNIP', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '32');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PIP', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '33');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PNIP', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '33');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PIP', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '33');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PNIP', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '33');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PIP', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '33');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PNIP', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '33');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PIP', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '34');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PNIP', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '34');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PIP', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '34');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PNIP', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '34');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PIP', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '34');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PNIP', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '34');
        END IF;

        IF v_mainlevel_code IN ('S2', 'T2', 'T6') THEN -- no IP stud, PIP & PNIP to be NULL
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PIP', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '31');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PNIP', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '31');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PIP', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '31');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PNIP', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '31');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PIP', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '31');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PNIP', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '31');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PIP', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '32');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PNIP', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '32');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PIP', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '32');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PNIP', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '32');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PIP', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '32');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PNIP', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '32');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PIP', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '33');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PNIP', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '33');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PIP', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '33');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PNIP', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '33');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PIP', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '33');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PNIP', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '33');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PIP', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '34');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PNIP', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '34');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PIP', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '34');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PNIP', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '34');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PIP', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '34');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PNIP', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '34');
        END IF;
        
        IF v_mainlevel_code IN ('T1','T2','T6','J','I') THEN -- PreU1, PreU2
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PIP', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '41');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PNIP', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '41');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PIP', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '41');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PNIP', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '41');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PIP', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '41');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PNIP', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '41');
        
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PIP', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '42');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PNIP', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '42');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PIP', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '42');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PNIP', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '42');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PIP', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '42');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PNIP', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '42');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'CALC', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '41');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'CALC', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '42');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'CALN', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '41');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'CALN', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '42');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'CUR', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '41');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'CUR', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '42');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'JAE', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '41');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'JAE', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '42');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'NWYR', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '41');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'NWYR', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '42');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PAE', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '41');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PAE', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '42');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'POST', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '41');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'POST', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '42');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRS1', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '41');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRS1', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '42');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRS2', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '41');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRS2', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '42');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'RSAL', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '41');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'RSAL', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '42');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'SAL', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '41');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'SAL', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '42');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'CALC', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '41');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'CALC', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '42');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'CALN', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '41');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'CALN', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '42');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'CUR', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '41');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'CUR', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '42');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'JAE', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '41');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'JAE', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '42');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'NWYR', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '41');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'NWYR', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '42');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PAE', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '41');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PAE', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '42');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'POST', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '41');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'POST', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '42');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRS1', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '41');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRS1', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '42');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRS2', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '41');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRS2', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '42');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'RSAL', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '41');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'RSAL', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '42');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'SAL', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '41');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'SAL', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '42');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'CALC', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '41');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'CALC', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '42');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'CALN', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '41');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'CALN', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '42');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'CUR', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '41');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'CUR', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '42');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'JAE', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '41');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'JAE', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '42');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'NWYR', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '41');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'NWYR', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '42');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PAE', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '41');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PAE', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '42');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'POST', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '41');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'POST', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '42');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PRS1', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '41');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PRS1', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '42');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PRS2', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '41');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PRS2', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '42');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'RSAL', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '41');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'RSAL', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '42');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'SAL', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '41');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'SAL', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '42');
        END IF;

        IF v_mainlevel_code IN ('I') THEN -- PreU3
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PIP', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '43');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PNIP', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '43');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PIP', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '43');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PNIP', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '43');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PIP', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '43');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PNIP', 'CF', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '43');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'CALC', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '43');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'CALN', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '43');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'CUR', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '43');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'JAE', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '43');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'NWYR', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '43');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PAE', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '43');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'POST', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '43');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRS1', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '43');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'PRS2', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '43');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'RSAL', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '43');	
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY'), 'SAL', NULL, '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '43');
                    
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'CALC', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '43');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'CALN', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '43');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'CUR', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '43');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'JAE', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '43');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'NWYR', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '43');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PAE', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '43');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'POST', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '43');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRS1', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '43');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'PRS2', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '43');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'RSAL', NULL, '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '43');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 1, 'SAL', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '43');

            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'CALC', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '43');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'CALN', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '43');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'CUR', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '43');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'JAE', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '43');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'NWYR', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '43');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PAE', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '43');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'POST', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '43');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PRS1', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '43');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'PRS2', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '43');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'RSAL', 'CF', '0', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '43');
            INSERT INTO cp01.cp_arch_school_transaction (school_code, academic_year, process_type_icode, process_status_icode, record_version_no, last_updated_date, updated_by_id, created_date, created_by_id, level_xcode)
            VALUES (v_school, to_char(now(), 'YYYY')::NUMERIC - 2, 'SAL', 'CF', '2', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', '43');
        END IF;
        DELETE FROM cp01.cp_tt_timetable_hdr
        WHERE school_code = v_school;
	    INSERT INTO cp01.cp_tt_timetable_hdr(	school_code, timetable_no, start_date, version_no, cycle_days_no, created_tmt_ind, record_version_no, created_date, created_by_id, last_updated_date, updated_by_id)
		VALUES (v_school, '1', date(concat_ws('',  TO_CHAR(now(), 'YYYY'),'-01-01')), '1','5', 'Y', 1, NOW(), 'LT_DATAPREP', NOW(), 'LT_DATAPREP');
        
 END LOOP;
 
END
$BLOCK$;
COMMIT;

\qecho 'cp01.cp_arch_school'
select school_code,  count(*) from cp01.cp_arch_school where school_code between '9808' and '9808' group by school_code;

\qecho '=== INSERTING SCHOOL DAYS ==='

begin;
do $block$
DECLARE 
    v_acadYear CHARACTER VARYING(4) := to_char(now(), 'YYYY'); 
    v_start_sch DOUBLE PRECISION := 9808;
    v_end_sch DOUBLE PRECISION := 9808;

    v_mainlevel_code CHARACTER VARYING(2) := NULL;
    v_school CHARACTER VARYING(10) := NULL;

    v_public_holiday_dates text[];
    V_PUBLIC_HOLIDAY_DESC text[];
    V_SCHOOL_HOLIDAY_DATES text[];
    V_SCHOOL_HOLIDAY_DESC text[];

    v_CHILDRENS_DAY DATE:=TO_DATE('03/10/' || v_acadYear , 'DD/MM/YYYY') ;

    V_TERM_START_DATES text[];
    V_TERM_END_DATES text[];

BEGIN
	v_public_holiday_dates := array[ concat_ws('','01/01/' ,v_acadYear),
                                    concat_ws('','29/01/' ,v_acadYear),
                                    concat_ws('','30/01/' ,v_acadYear),
                                    concat_ws('','18/04/' ,v_acadYear),
                                    concat_ws('','01/05/' ,v_acadYear),
                                    concat_ws('','12/05/' ,v_acadYear),
                                    concat_ws('','31/03/' ,v_acadYear),
                                    concat_ws('','07/06/' ,v_acadYear),
                                    concat_ws('','09/08/' ,v_acadYear),
                                    concat_ws('','20/10/' ,v_acadYear),
                                    concat_ws('','25/12/' ,v_acadYear)];
	V_PUBLIC_HOLIDAY_DESC:= array [concat_ws('', 'New Year Day'  ),
                                    concat_ws('', 'Chinese New Year'              ),
                                    concat_ws('', 'Off in lieu - Chinese New Year'),
                                    concat_ws('', 'Good Friday'                   ),
                                    concat_ws('', 'Labour Day'                    ),
                                    concat_ws('', 'Vesak Day'                     ),
                                    concat_ws('', 'Hari Raya Puasa'               ),
                                    concat_ws('', 'Hari Raya Haji'                ),
                                    concat_ws('', 'National Day'                  ),
                                    concat_ws('', 'Deepavali'                     ),
                                    concat_ws('', 'Christmas Day'                 )];
								
	V_SCHOOL_HOLIDAY_DATES := array[concat_ws('','09/06/' , v_acadYear), -- school
                                    concat_ws('','01/05/' , v_acadYear), -- school
                                    concat_ws('','07/07/' , v_acadYear),
                                    concat_ws('','11/08/' , v_acadYear), -- school
                                    concat_ws('','05/09/' , v_acadYear)];
	V_SCHOOL_HOLIDAY_DESC := array['Off in lieu - Hari Raya Haji', -- school
                                    'Off in lieu - Labour Day', 
                                    'Youth Day', 
                                    'Off in lieu - National Day', 
                                    'Teachers Day'];
	
	V_TERM_START_DATES := array [concat_ws('', '02/01/', v_acadYear),
							concat_ws('', '24/03/', v_acadYear),
							concat_ws('', '30/06/', v_acadYear),
							concat_ws('', '15/09/', v_acadYear)];
	
	V_TERM_END_DATES:=array[concat_ws('', '14/03/' , v_acadYear),
							concat_ws('', '30/05/' , v_acadYear),
							concat_ws('', '05/09/' , v_acadYear),
							concat_ws('', '19/11/' , v_acadYear)];

	WHILE v_start_sch <= v_end_sch LOOP
        v_school := trim(TO_CHAR(v_start_sch,'9999'));
        v_start_sch := v_start_sch + 1;
        raise notice 'Calendar %', v_school;

        SELECT mainlevel_code INTO v_mainlevel_code FROM cp01.cp_arch_school where school_code = v_school;
        raise notice '% mainlevel_code: %', v_school, v_mainlevel_code;

        delete from cp01.CP_ARCH_SCH_YRLY_PARAMETER where SCHOOL_CODE =v_school AND ACADEMIC_YEAR=v_acadYear;
        delete from cp01.CP_ARCH_SCH_LVL_PARAMETER where SCHOOL_CODE =v_school AND ACADEMIC_YEAR=v_acadYear;
        delete from cp01.cp_arch_sch_stream_parameter where SCHOOL_CODE =v_school AND ACADEMIC_YEAR=v_acadYear;

        INSERT INTO cp01.CP_ARCH_SCH_YRLY_PARAMETER(SCHOOL_CODE, ACADEMIC_YEAR, TERM1_DAYS_NO, TERM2_DAYS_NO, TERM3_DAYS_NO, TERM4_DAYS_NO, SEM1_DAYS_NO, SEM2_DAYS_NO, TERM1_START_DATE, TERM1_END_DATE, TERM2_START_DATE, TERM2_END_DATE, TERM3_START_DATE, TERM3_END_DATE, TERM4_START_DATE, TERM4_END_DATE, RECORD_VERSION_NO, CREATED_DATE, CREATED_BY_ID, LAST_UPDATED_DATE, UPDATED_BY_ID, ATTENDANCE_SUMMARY_IND, LES_ACCESS_IND, SCH_DEF_PROMOTION_STATUS_IND, CA_CUTOFF_DATE1, CA_CUTOFF_DATE2, CA_CUTOFF_DATE3, CA_CUTOFF_DATE4)
        SELECT sch.school_code, v_acadYear, '50', '29', '60', '48', '79', '108', TO_DATE(concat_ws('', V_TERM_START_DATES[1] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[2] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[3] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS') ,  TO_DATE(concat_ws('', V_TERM_END_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS') ,'2', now(), 'CONVERSION', now(), 'CONVERSION', 'Y', 'N', 'N', TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS')
        FROM cp01.CP_ARCH_SCHOOL sch where SCHOOL_CODE = v_school;

        IF v_mainlevel_code IN ('T5', 'P') THEN -- PRI1 TO PRI6
            INSERT INTO cp01.CP_ARCH_SCH_LVL_PARAMETER(SCHOOL_CODE, ACADEMIC_YEAR,LEVEL_XCODE, TERM1_DAYS_NO, TERM2_DAYS_NO, TERM3_DAYS_NO, TERM4_DAYS_NO, SEM1_DAYS_NO, SEM2_DAYS_NO, TERM1_START_DATE, TERM1_END_DATE, TERM2_START_DATE, TERM2_END_DATE, TERM3_START_DATE, TERM3_END_DATE, TERM4_START_DATE, TERM4_END_DATE, RECORD_VERSION_NO, CREATED_DATE, CREATED_BY_ID, LAST_UPDATED_DATE, UPDATED_BY_ID, CA_CUTOFF_DATE1, CA_CUTOFF_DATE2, CA_CUTOFF_DATE3, CA_CUTOFF_DATE4)
            SELECT sch.school_code, v_acadYear, '11', '50', '29', '60', '48', '79', '108', TO_DATE(concat_ws('', V_TERM_START_DATES[1] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[2] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[3] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'),'2', now(), 'CONVERSION', now(), 'CONVERSION',TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS') FROM cp01.CP_ARCH_SCHOOL sch where SCHOOL_CODE =v_school;
            INSERT INTO cp01.cp_arch_sch_stream_parameter(SCHOOL_CODE, ACADEMIC_YEAR,LEVEL_XCODE, stream_xcode, TERM1_DAYS_NO, TERM2_DAYS_NO, TERM3_DAYS_NO, TERM4_DAYS_NO, SEM1_DAYS_NO, SEM2_DAYS_NO, TERM1_START_DATE, TERM1_END_DATE, TERM2_START_DATE, TERM2_END_DATE, TERM3_START_DATE, TERM3_END_DATE, TERM4_START_DATE, TERM4_END_DATE, RECORD_VERSION_NO, CREATED_DATE, CREATED_BY_ID, LAST_UPDATED_DATE, UPDATED_BY_ID, CA_CUTOFF_DATE1, CA_CUTOFF_DATE2, CA_CUTOFF_DATE3, CA_CUTOFF_DATE4)
            SELECT sch.school_code, v_acadYear, '11', '00', '50', '29', '60', '48', '79', '108', TO_DATE(concat_ws('', V_TERM_START_DATES[1] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[2] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[3] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'),'2', now(), 'CONVERSION', now(), 'CONVERSION',TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS') FROM cp01.CP_ARCH_SCHOOL sch where SCHOOL_CODE =v_school;

            INSERT INTO cp01.CP_ARCH_SCH_LVL_PARAMETER(SCHOOL_CODE, ACADEMIC_YEAR,LEVEL_XCODE, TERM1_DAYS_NO, TERM2_DAYS_NO, TERM3_DAYS_NO, TERM4_DAYS_NO, SEM1_DAYS_NO, SEM2_DAYS_NO, TERM1_START_DATE, TERM1_END_DATE, TERM2_START_DATE, TERM2_END_DATE, TERM3_START_DATE, TERM3_END_DATE, TERM4_START_DATE, TERM4_END_DATE, RECORD_VERSION_NO, CREATED_DATE, CREATED_BY_ID, LAST_UPDATED_DATE, UPDATED_BY_ID, CA_CUTOFF_DATE1, CA_CUTOFF_DATE2, CA_CUTOFF_DATE3, CA_CUTOFF_DATE4)
            SELECT sch.school_code, v_acadYear, '12', '50', '29', '60', '48', '79', '108', TO_DATE(concat_ws('', V_TERM_START_DATES[1] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[2] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[3] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'),TO_DATE(concat_ws('', V_TERM_END_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), '2', now(), 'CONVERSION', now(), 'CONVERSION',TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS') FROM cp01.CP_ARCH_SCHOOL sch where SCHOOL_CODE =v_school;
            INSERT INTO cp01.cp_arch_sch_stream_parameter(SCHOOL_CODE, ACADEMIC_YEAR,LEVEL_XCODE, stream_xcode, TERM1_DAYS_NO, TERM2_DAYS_NO, TERM3_DAYS_NO, TERM4_DAYS_NO, SEM1_DAYS_NO, SEM2_DAYS_NO, TERM1_START_DATE, TERM1_END_DATE, TERM2_START_DATE, TERM2_END_DATE, TERM3_START_DATE, TERM3_END_DATE, TERM4_START_DATE, TERM4_END_DATE, RECORD_VERSION_NO, CREATED_DATE, CREATED_BY_ID, LAST_UPDATED_DATE, UPDATED_BY_ID, CA_CUTOFF_DATE1, CA_CUTOFF_DATE2, CA_CUTOFF_DATE3, CA_CUTOFF_DATE4)
            SELECT sch.school_code, v_acadYear, '12', '00', '50', '29', '60', '48', '79', '108', TO_DATE(concat_ws('', V_TERM_START_DATES[1] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[2] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[3] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'),'2', now(), 'CONVERSION', now(), 'CONVERSION',TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS') FROM cp01.CP_ARCH_SCHOOL sch where SCHOOL_CODE =v_school;

            INSERT INTO cp01.CP_ARCH_SCH_LVL_PARAMETER(SCHOOL_CODE, ACADEMIC_YEAR,LEVEL_XCODE, TERM1_DAYS_NO, TERM2_DAYS_NO, TERM3_DAYS_NO, TERM4_DAYS_NO, SEM1_DAYS_NO, SEM2_DAYS_NO, TERM1_START_DATE, TERM1_END_DATE, TERM2_START_DATE, TERM2_END_DATE, TERM3_START_DATE, TERM3_END_DATE, TERM4_START_DATE, TERM4_END_DATE, RECORD_VERSION_NO, CREATED_DATE, CREATED_BY_ID, LAST_UPDATED_DATE, UPDATED_BY_ID,  CA_CUTOFF_DATE1, CA_CUTOFF_DATE2, CA_CUTOFF_DATE3, CA_CUTOFF_DATE4)
            SELECT sch.school_code, v_acadYear, '13', '50', '29', '60', '48', '79', '108', TO_DATE(concat_ws('', V_TERM_START_DATES[1] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[2] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[3] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'),TO_DATE(concat_ws('', V_TERM_END_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), '2', now(), 'CONVERSION', now(), 'CONVERSION',TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS') FROM cp01.CP_ARCH_SCHOOL sch where SCHOOL_CODE =v_school;
            INSERT INTO cp01.cp_arch_sch_stream_parameter(SCHOOL_CODE, ACADEMIC_YEAR,LEVEL_XCODE, stream_xcode, TERM1_DAYS_NO, TERM2_DAYS_NO, TERM3_DAYS_NO, TERM4_DAYS_NO, SEM1_DAYS_NO, SEM2_DAYS_NO, TERM1_START_DATE, TERM1_END_DATE, TERM2_START_DATE, TERM2_END_DATE, TERM3_START_DATE, TERM3_END_DATE, TERM4_START_DATE, TERM4_END_DATE, RECORD_VERSION_NO, CREATED_DATE, CREATED_BY_ID, LAST_UPDATED_DATE, UPDATED_BY_ID, CA_CUTOFF_DATE1, CA_CUTOFF_DATE2, CA_CUTOFF_DATE3, CA_CUTOFF_DATE4)
            SELECT sch.school_code, v_acadYear, '13', '00', '50', '29', '60', '48', '79', '108', TO_DATE(concat_ws('', V_TERM_START_DATES[1] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[2] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[3] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'),'2', now(), 'CONVERSION', now(), 'CONVERSION',TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS') FROM cp01.CP_ARCH_SCHOOL sch where SCHOOL_CODE =v_school;

            INSERT INTO cp01.CP_ARCH_SCH_LVL_PARAMETER(SCHOOL_CODE, ACADEMIC_YEAR,LEVEL_XCODE, TERM1_DAYS_NO, TERM2_DAYS_NO, TERM3_DAYS_NO, TERM4_DAYS_NO, SEM1_DAYS_NO, SEM2_DAYS_NO, TERM1_START_DATE, TERM1_END_DATE, TERM2_START_DATE, TERM2_END_DATE, TERM3_START_DATE, TERM3_END_DATE, TERM4_START_DATE, TERM4_END_DATE, RECORD_VERSION_NO, CREATED_DATE, CREATED_BY_ID, LAST_UPDATED_DATE, UPDATED_BY_ID,  CA_CUTOFF_DATE1, CA_CUTOFF_DATE2, CA_CUTOFF_DATE3, CA_CUTOFF_DATE4)
            SELECT sch.school_code, v_acadYear, '14', '50', '29', '60', '48', '79', '108', TO_DATE(concat_ws('', V_TERM_START_DATES[1] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[2] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[3] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'),TO_DATE(concat_ws('', V_TERM_END_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), '2', now(), 'CONVERSION', now(), 'CONVERSION',TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS') FROM cp01.CP_ARCH_SCHOOL sch where SCHOOL_CODE =v_school;
            INSERT INTO cp01.cp_arch_sch_stream_parameter(SCHOOL_CODE, ACADEMIC_YEAR,LEVEL_XCODE, stream_xcode, TERM1_DAYS_NO, TERM2_DAYS_NO, TERM3_DAYS_NO, TERM4_DAYS_NO, SEM1_DAYS_NO, SEM2_DAYS_NO, TERM1_START_DATE, TERM1_END_DATE, TERM2_START_DATE, TERM2_END_DATE, TERM3_START_DATE, TERM3_END_DATE, TERM4_START_DATE, TERM4_END_DATE, RECORD_VERSION_NO, CREATED_DATE, CREATED_BY_ID, LAST_UPDATED_DATE, UPDATED_BY_ID, CA_CUTOFF_DATE1, CA_CUTOFF_DATE2, CA_CUTOFF_DATE3, CA_CUTOFF_DATE4)
            SELECT sch.school_code, v_acadYear, '14', '00', '50', '29', '60', '48', '79', '108', TO_DATE(concat_ws('', V_TERM_START_DATES[1] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[2] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[3] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'),'2', now(), 'CONVERSION', now(), 'CONVERSION',TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS') FROM cp01.CP_ARCH_SCHOOL sch where SCHOOL_CODE =v_school;

            INSERT INTO cp01.CP_ARCH_SCH_LVL_PARAMETER(SCHOOL_CODE, ACADEMIC_YEAR,LEVEL_XCODE, TERM1_DAYS_NO, TERM2_DAYS_NO, TERM3_DAYS_NO, TERM4_DAYS_NO, SEM1_DAYS_NO, SEM2_DAYS_NO, TERM1_START_DATE, TERM1_END_DATE, TERM2_START_DATE, TERM2_END_DATE, TERM3_START_DATE, TERM3_END_DATE, TERM4_START_DATE, TERM4_END_DATE, RECORD_VERSION_NO, CREATED_DATE, CREATED_BY_ID, LAST_UPDATED_DATE, UPDATED_BY_ID,  CA_CUTOFF_DATE1, CA_CUTOFF_DATE2, CA_CUTOFF_DATE3, CA_CUTOFF_DATE4)
            SELECT sch.school_code, v_acadYear, '15', '50', '29', '60', '48', '79', '108', TO_DATE(concat_ws('', V_TERM_START_DATES[1] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[2] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[3] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'),'2', now(), 'CONVERSION', now(), 'CONVERSION',TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS') FROM cp01.CP_ARCH_SCHOOL sch where SCHOOL_CODE =v_school;
            INSERT INTO cp01.cp_arch_sch_stream_parameter(SCHOOL_CODE, ACADEMIC_YEAR,LEVEL_XCODE, stream_xcode, TERM1_DAYS_NO, TERM2_DAYS_NO, TERM3_DAYS_NO, TERM4_DAYS_NO, SEM1_DAYS_NO, SEM2_DAYS_NO, TERM1_START_DATE, TERM1_END_DATE, TERM2_START_DATE, TERM2_END_DATE, TERM3_START_DATE, TERM3_END_DATE, TERM4_START_DATE, TERM4_END_DATE, RECORD_VERSION_NO, CREATED_DATE, CREATED_BY_ID, LAST_UPDATED_DATE, UPDATED_BY_ID, CA_CUTOFF_DATE1, CA_CUTOFF_DATE2, CA_CUTOFF_DATE3, CA_CUTOFF_DATE4)
            SELECT sch.school_code, v_acadYear, '15', '00', '50', '29', '60', '48', '79', '108', TO_DATE(concat_ws('', V_TERM_START_DATES[1] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[2] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[3] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'),'2', now(), 'CONVERSION', now(), 'CONVERSION',TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS') FROM cp01.CP_ARCH_SCHOOL sch where SCHOOL_CODE =v_school;

            INSERT INTO cp01.CP_ARCH_SCH_LVL_PARAMETER(SCHOOL_CODE, ACADEMIC_YEAR,LEVEL_XCODE, TERM1_DAYS_NO, TERM2_DAYS_NO, TERM3_DAYS_NO, TERM4_DAYS_NO, SEM1_DAYS_NO, SEM2_DAYS_NO, TERM1_START_DATE, TERM1_END_DATE, TERM2_START_DATE, TERM2_END_DATE, TERM3_START_DATE, TERM3_END_DATE, TERM4_START_DATE, TERM4_END_DATE, RECORD_VERSION_NO, CREATED_DATE, CREATED_BY_ID, LAST_UPDATED_DATE, UPDATED_BY_ID,  CA_CUTOFF_DATE1, CA_CUTOFF_DATE2, CA_CUTOFF_DATE3, CA_CUTOFF_DATE4)
            SELECT sch.school_code, v_acadYear, '16', '50', '29', '60', '48', '79', '108', TO_DATE(concat_ws('', V_TERM_START_DATES[1] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[2] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[3] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'),TO_DATE(concat_ws('', V_TERM_END_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), '2', now(), 'CONVERSION', now(), 'CONVERSION',TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS') FROM cp01.CP_ARCH_SCHOOL sch where SCHOOL_CODE =v_school;
            INSERT INTO cp01.cp_arch_sch_stream_parameter(SCHOOL_CODE, ACADEMIC_YEAR,LEVEL_XCODE, stream_xcode, TERM1_DAYS_NO, TERM2_DAYS_NO, TERM3_DAYS_NO, TERM4_DAYS_NO, SEM1_DAYS_NO, SEM2_DAYS_NO, TERM1_START_DATE, TERM1_END_DATE, TERM2_START_DATE, TERM2_END_DATE, TERM3_START_DATE, TERM3_END_DATE, TERM4_START_DATE, TERM4_END_DATE, RECORD_VERSION_NO, CREATED_DATE, CREATED_BY_ID, LAST_UPDATED_DATE, UPDATED_BY_ID, CA_CUTOFF_DATE1, CA_CUTOFF_DATE2, CA_CUTOFF_DATE3, CA_CUTOFF_DATE4)
            SELECT sch.school_code, v_acadYear, '16', '00', '50', '29', '60', '48', '79', '108', TO_DATE(concat_ws('', V_TERM_START_DATES[1] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[2] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[3] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'),'2', now(), 'CONVERSION', now(), 'CONVERSION',TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS') FROM cp01.CP_ARCH_SCHOOL sch where SCHOOL_CODE =v_school;
        END IF;

        IF v_mainlevel_code IN ('S1','S2', 'T1', 'T5', 'T6') THEN -- SEC1, SEC2
            INSERT INTO cp01.CP_ARCH_SCH_LVL_PARAMETER(SCHOOL_CODE, ACADEMIC_YEAR,LEVEL_XCODE, TERM1_DAYS_NO, TERM2_DAYS_NO, TERM3_DAYS_NO, TERM4_DAYS_NO, SEM1_DAYS_NO, SEM2_DAYS_NO, TERM1_START_DATE, TERM1_END_DATE, TERM2_START_DATE, TERM2_END_DATE, TERM3_START_DATE, TERM3_END_DATE, TERM4_START_DATE, TERM4_END_DATE, RECORD_VERSION_NO, CREATED_DATE, CREATED_BY_ID, LAST_UPDATED_DATE, UPDATED_BY_ID, CA_CUTOFF_DATE1, CA_CUTOFF_DATE2, CA_CUTOFF_DATE3, CA_CUTOFF_DATE4)
            SELECT sch.school_code, v_acadYear, '31', '50', '29', '60', '48', '79', '108', TO_DATE(concat_ws('', V_TERM_START_DATES[1] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[2] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[3] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'),'2', now(), 'CONVERSION', now(), 'CONVERSION',TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS') FROM cp01.CP_ARCH_SCHOOL sch where SCHOOL_CODE =v_school;
            INSERT INTO cp01.cp_arch_sch_stream_parameter(SCHOOL_CODE, ACADEMIC_YEAR,LEVEL_XCODE, stream_xcode, TERM1_DAYS_NO, TERM2_DAYS_NO, TERM3_DAYS_NO, TERM4_DAYS_NO, SEM1_DAYS_NO, SEM2_DAYS_NO, TERM1_START_DATE, TERM1_END_DATE, TERM2_START_DATE, TERM2_END_DATE, TERM3_START_DATE, TERM3_END_DATE, TERM4_START_DATE, TERM4_END_DATE, RECORD_VERSION_NO, CREATED_DATE, CREATED_BY_ID, LAST_UPDATED_DATE, UPDATED_BY_ID, CA_CUTOFF_DATE1, CA_CUTOFF_DATE2, CA_CUTOFF_DATE3, CA_CUTOFF_DATE4)
            SELECT sch.school_code, v_acadYear, '31', '00', '50', '29', '60', '48', '79', '108', TO_DATE(concat_ws('', V_TERM_START_DATES[1] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[2] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[3] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'),'2', now(), 'CONVERSION', now(), 'CONVERSION',TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS') FROM cp01.CP_ARCH_SCHOOL sch where SCHOOL_CODE =v_school;

            INSERT INTO cp01.CP_ARCH_SCH_LVL_PARAMETER(SCHOOL_CODE, ACADEMIC_YEAR,LEVEL_XCODE, TERM1_DAYS_NO, TERM2_DAYS_NO, TERM3_DAYS_NO, TERM4_DAYS_NO, SEM1_DAYS_NO, SEM2_DAYS_NO, TERM1_START_DATE, TERM1_END_DATE, TERM2_START_DATE, TERM2_END_DATE, TERM3_START_DATE, TERM3_END_DATE, TERM4_START_DATE, TERM4_END_DATE, RECORD_VERSION_NO, CREATED_DATE, CREATED_BY_ID, LAST_UPDATED_DATE, UPDATED_BY_ID, CA_CUTOFF_DATE1, CA_CUTOFF_DATE2, CA_CUTOFF_DATE3, CA_CUTOFF_DATE4)
            SELECT sch.school_code, v_acadYear, '32', '50', '29', '60', '48', '79', '108', TO_DATE(concat_ws('', V_TERM_START_DATES[1] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[2] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[3] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'),'2', now(), 'CONVERSION', now(), 'CONVERSION',TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS') FROM cp01.CP_ARCH_SCHOOL sch where SCHOOL_CODE =v_school;

            INSERT INTO cp01.cp_arch_sch_stream_parameter(SCHOOL_CODE, ACADEMIC_YEAR,LEVEL_XCODE, stream_xcode, TERM1_DAYS_NO, TERM2_DAYS_NO, TERM3_DAYS_NO, TERM4_DAYS_NO, SEM1_DAYS_NO, SEM2_DAYS_NO, TERM1_START_DATE, TERM1_END_DATE, TERM2_START_DATE, TERM2_END_DATE, TERM3_START_DATE, TERM3_END_DATE, TERM4_START_DATE, TERM4_END_DATE, RECORD_VERSION_NO, CREATED_DATE, CREATED_BY_ID, LAST_UPDATED_DATE, UPDATED_BY_ID, CA_CUTOFF_DATE1, CA_CUTOFF_DATE2, CA_CUTOFF_DATE3, CA_CUTOFF_DATE4)
            SELECT sch.school_code, v_acadYear, '32', '22', '50', '29', '60', '48', '79', '108', TO_DATE(concat_ws('', V_TERM_START_DATES[1] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[2] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[3] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'),'2', now(), 'CONVERSION', now(), 'CONVERSION',TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS') FROM cp01.CP_ARCH_SCHOOL sch where SCHOOL_CODE =v_school;
            INSERT INTO cp01.cp_arch_sch_stream_parameter(SCHOOL_CODE, ACADEMIC_YEAR,LEVEL_XCODE, stream_xcode, TERM1_DAYS_NO, TERM2_DAYS_NO, TERM3_DAYS_NO, TERM4_DAYS_NO, SEM1_DAYS_NO, SEM2_DAYS_NO, TERM1_START_DATE, TERM1_END_DATE, TERM2_START_DATE, TERM2_END_DATE, TERM3_START_DATE, TERM3_END_DATE, TERM4_START_DATE, TERM4_END_DATE, RECORD_VERSION_NO, CREATED_DATE, CREATED_BY_ID, LAST_UPDATED_DATE, UPDATED_BY_ID, CA_CUTOFF_DATE1, CA_CUTOFF_DATE2, CA_CUTOFF_DATE3, CA_CUTOFF_DATE4)
            SELECT sch.school_code, v_acadYear, '32', '21', '50', '29', '60', '48', '79', '108', TO_DATE(concat_ws('', V_TERM_START_DATES[1] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[2] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[3] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'),'2', now(), 'CONVERSION', now(), 'CONVERSION',TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS') FROM cp01.CP_ARCH_SCHOOL sch where SCHOOL_CODE =v_school;
            INSERT INTO cp01.cp_arch_sch_stream_parameter(SCHOOL_CODE, ACADEMIC_YEAR,LEVEL_XCODE, stream_xcode, TERM1_DAYS_NO, TERM2_DAYS_NO, TERM3_DAYS_NO, TERM4_DAYS_NO, SEM1_DAYS_NO, SEM2_DAYS_NO, TERM1_START_DATE, TERM1_END_DATE, TERM2_START_DATE, TERM2_END_DATE, TERM3_START_DATE, TERM3_END_DATE, TERM4_START_DATE, TERM4_END_DATE, RECORD_VERSION_NO, CREATED_DATE, CREATED_BY_ID, LAST_UPDATED_DATE, UPDATED_BY_ID, CA_CUTOFF_DATE1, CA_CUTOFF_DATE2, CA_CUTOFF_DATE3, CA_CUTOFF_DATE4)
            SELECT sch.school_code, v_acadYear, '32', '20', '50', '29', '60', '48', '79', '108', TO_DATE(concat_ws('', V_TERM_START_DATES[1] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[2] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[3] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'),'2', now(), 'CONVERSION', now(), 'CONVERSION',TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS') FROM cp01.CP_ARCH_SCHOOL sch where SCHOOL_CODE =v_school;
        END IF;

        IF v_mainlevel_code IN ('S1','S2', 'T1', 'T5', 'T6', 'T2') THEN -- SEC3, SEC4
            INSERT INTO cp01.CP_ARCH_SCH_LVL_PARAMETER(SCHOOL_CODE, ACADEMIC_YEAR,LEVEL_XCODE, TERM1_DAYS_NO, TERM2_DAYS_NO, TERM3_DAYS_NO, TERM4_DAYS_NO, SEM1_DAYS_NO, SEM2_DAYS_NO, TERM1_START_DATE, TERM1_END_DATE, TERM2_START_DATE, TERM2_END_DATE, TERM3_START_DATE, TERM3_END_DATE, TERM4_START_DATE, TERM4_END_DATE, RECORD_VERSION_NO, CREATED_DATE, CREATED_BY_ID, LAST_UPDATED_DATE, UPDATED_BY_ID, CA_CUTOFF_DATE1, CA_CUTOFF_DATE2, CA_CUTOFF_DATE3, CA_CUTOFF_DATE4)
            SELECT sch.school_code, v_acadYear, '33', '50', '29', '60', '48', '79', '108', TO_DATE(concat_ws('', V_TERM_START_DATES[1] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[2] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[3] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'),'2', now(), 'CONVERSION', now(), 'CONVERSION',TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS') FROM cp01.CP_ARCH_SCHOOL sch where SCHOOL_CODE =v_school;

            INSERT INTO cp01.cp_arch_sch_stream_parameter(SCHOOL_CODE, ACADEMIC_YEAR,LEVEL_XCODE, stream_xcode, TERM1_DAYS_NO, TERM2_DAYS_NO, TERM3_DAYS_NO, TERM4_DAYS_NO, SEM1_DAYS_NO, SEM2_DAYS_NO, TERM1_START_DATE, TERM1_END_DATE, TERM2_START_DATE, TERM2_END_DATE, TERM3_START_DATE, TERM3_END_DATE, TERM4_START_DATE, TERM4_END_DATE, RECORD_VERSION_NO, CREATED_DATE, CREATED_BY_ID, LAST_UPDATED_DATE, UPDATED_BY_ID, CA_CUTOFF_DATE1, CA_CUTOFF_DATE2, CA_CUTOFF_DATE3, CA_CUTOFF_DATE4)
            SELECT sch.school_code, v_acadYear, '33', '22', '50', '29', '60', '48', '79', '108', TO_DATE(concat_ws('', V_TERM_START_DATES[1] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[2] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[3] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'),'2', now(), 'CONVERSION', now(), 'CONVERSION',TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS') FROM cp01.CP_ARCH_SCHOOL sch where SCHOOL_CODE =v_school;
            INSERT INTO cp01.cp_arch_sch_stream_parameter(SCHOOL_CODE, ACADEMIC_YEAR,LEVEL_XCODE, stream_xcode, TERM1_DAYS_NO, TERM2_DAYS_NO, TERM3_DAYS_NO, TERM4_DAYS_NO, SEM1_DAYS_NO, SEM2_DAYS_NO, TERM1_START_DATE, TERM1_END_DATE, TERM2_START_DATE, TERM2_END_DATE, TERM3_START_DATE, TERM3_END_DATE, TERM4_START_DATE, TERM4_END_DATE, RECORD_VERSION_NO, CREATED_DATE, CREATED_BY_ID, LAST_UPDATED_DATE, UPDATED_BY_ID, CA_CUTOFF_DATE1, CA_CUTOFF_DATE2, CA_CUTOFF_DATE3, CA_CUTOFF_DATE4)
            SELECT sch.school_code, v_acadYear, '33', '21', '50', '29', '60', '48', '79', '108', TO_DATE(concat_ws('', V_TERM_START_DATES[1] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[2] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[3] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'),'2', now(), 'CONVERSION', now(), 'CONVERSION',TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS') FROM cp01.CP_ARCH_SCHOOL sch where SCHOOL_CODE =v_school;
            INSERT INTO cp01.cp_arch_sch_stream_parameter(SCHOOL_CODE, ACADEMIC_YEAR,LEVEL_XCODE, stream_xcode, TERM1_DAYS_NO, TERM2_DAYS_NO, TERM3_DAYS_NO, TERM4_DAYS_NO, SEM1_DAYS_NO, SEM2_DAYS_NO, TERM1_START_DATE, TERM1_END_DATE, TERM2_START_DATE, TERM2_END_DATE, TERM3_START_DATE, TERM3_END_DATE, TERM4_START_DATE, TERM4_END_DATE, RECORD_VERSION_NO, CREATED_DATE, CREATED_BY_ID, LAST_UPDATED_DATE, UPDATED_BY_ID, CA_CUTOFF_DATE1, CA_CUTOFF_DATE2, CA_CUTOFF_DATE3, CA_CUTOFF_DATE4)
            SELECT sch.school_code, v_acadYear, '33', '20', '50', '29', '60', '48', '79', '108', TO_DATE(concat_ws('', V_TERM_START_DATES[1] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[2] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[3] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'),'2', now(), 'CONVERSION', now(), 'CONVERSION',TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS') FROM cp01.CP_ARCH_SCHOOL sch where SCHOOL_CODE =v_school;

            INSERT INTO cp01.CP_ARCH_SCH_LVL_PARAMETER(SCHOOL_CODE, ACADEMIC_YEAR,LEVEL_XCODE, TERM1_DAYS_NO, TERM2_DAYS_NO, TERM3_DAYS_NO, TERM4_DAYS_NO, SEM1_DAYS_NO, SEM2_DAYS_NO, TERM1_START_DATE, TERM1_END_DATE, TERM2_START_DATE, TERM2_END_DATE, TERM3_START_DATE, TERM3_END_DATE, TERM4_START_DATE, TERM4_END_DATE, RECORD_VERSION_NO, CREATED_DATE, CREATED_BY_ID, LAST_UPDATED_DATE, UPDATED_BY_ID, CA_CUTOFF_DATE1, CA_CUTOFF_DATE2, CA_CUTOFF_DATE3, CA_CUTOFF_DATE4)
            SELECT sch.school_code, v_acadYear, '34', '50', '29', '60', '48', '79', '108', TO_DATE(concat_ws('', V_TERM_START_DATES[1] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[2] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[3] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'),'2', now(), 'CONVERSION', now(), 'CONVERSION',TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS') FROM cp01.CP_ARCH_SCHOOL sch where SCHOOL_CODE =v_school;

            INSERT INTO cp01.cp_arch_sch_stream_parameter(SCHOOL_CODE, ACADEMIC_YEAR,LEVEL_XCODE, stream_xcode, TERM1_DAYS_NO, TERM2_DAYS_NO, TERM3_DAYS_NO, TERM4_DAYS_NO, SEM1_DAYS_NO, SEM2_DAYS_NO, TERM1_START_DATE, TERM1_END_DATE, TERM2_START_DATE, TERM2_END_DATE, TERM3_START_DATE, TERM3_END_DATE, TERM4_START_DATE, TERM4_END_DATE, RECORD_VERSION_NO, CREATED_DATE, CREATED_BY_ID, LAST_UPDATED_DATE, UPDATED_BY_ID, CA_CUTOFF_DATE1, CA_CUTOFF_DATE2, CA_CUTOFF_DATE3, CA_CUTOFF_DATE4)
            SELECT sch.school_code, v_acadYear, '34', '22', '50', '29', '60', '48', '79', '108', TO_DATE(concat_ws('', V_TERM_START_DATES[1] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[2] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[3] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'),'2', now(), 'CONVERSION', now(), 'CONVERSION',TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS') FROM cp01.CP_ARCH_SCHOOL sch where SCHOOL_CODE =v_school;
            INSERT INTO cp01.cp_arch_sch_stream_parameter(SCHOOL_CODE, ACADEMIC_YEAR,LEVEL_XCODE, stream_xcode, TERM1_DAYS_NO, TERM2_DAYS_NO, TERM3_DAYS_NO, TERM4_DAYS_NO, SEM1_DAYS_NO, SEM2_DAYS_NO, TERM1_START_DATE, TERM1_END_DATE, TERM2_START_DATE, TERM2_END_DATE, TERM3_START_DATE, TERM3_END_DATE, TERM4_START_DATE, TERM4_END_DATE, RECORD_VERSION_NO, CREATED_DATE, CREATED_BY_ID, LAST_UPDATED_DATE, UPDATED_BY_ID, CA_CUTOFF_DATE1, CA_CUTOFF_DATE2, CA_CUTOFF_DATE3, CA_CUTOFF_DATE4)
            SELECT sch.school_code, v_acadYear, '34', '21', '50', '29', '60', '48', '79', '108', TO_DATE(concat_ws('', V_TERM_START_DATES[1] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[2] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[3] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'),'2', now(), 'CONVERSION', now(), 'CONVERSION',TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS') FROM cp01.CP_ARCH_SCHOOL sch where SCHOOL_CODE =v_school;
            INSERT INTO cp01.cp_arch_sch_stream_parameter(SCHOOL_CODE, ACADEMIC_YEAR,LEVEL_XCODE, stream_xcode, TERM1_DAYS_NO, TERM2_DAYS_NO, TERM3_DAYS_NO, TERM4_DAYS_NO, SEM1_DAYS_NO, SEM2_DAYS_NO, TERM1_START_DATE, TERM1_END_DATE, TERM2_START_DATE, TERM2_END_DATE, TERM3_START_DATE, TERM3_END_DATE, TERM4_START_DATE, TERM4_END_DATE, RECORD_VERSION_NO, CREATED_DATE, CREATED_BY_ID, LAST_UPDATED_DATE, UPDATED_BY_ID, CA_CUTOFF_DATE1, CA_CUTOFF_DATE2, CA_CUTOFF_DATE3, CA_CUTOFF_DATE4)
            SELECT sch.school_code, v_acadYear, '34', '20', '50', '29', '60', '48', '79', '108', TO_DATE(concat_ws('', V_TERM_START_DATES[1] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[2] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[3] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'),'2', now(), 'CONVERSION', now(), 'CONVERSION',TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS') FROM cp01.CP_ARCH_SCHOOL sch where SCHOOL_CODE =v_school;
        END IF;

        IF v_mainlevel_code IN ('S2','T6') THEN -- SEC5
            INSERT INTO cp01.CP_ARCH_SCH_LVL_PARAMETER(SCHOOL_CODE, ACADEMIC_YEAR,LEVEL_XCODE, TERM1_DAYS_NO, TERM2_DAYS_NO, TERM3_DAYS_NO, TERM4_DAYS_NO, SEM1_DAYS_NO, SEM2_DAYS_NO, TERM1_START_DATE, TERM1_END_DATE, TERM2_START_DATE, TERM2_END_DATE, TERM3_START_DATE, TERM3_END_DATE, TERM4_START_DATE, TERM4_END_DATE, RECORD_VERSION_NO, CREATED_DATE, CREATED_BY_ID, LAST_UPDATED_DATE, UPDATED_BY_ID, CA_CUTOFF_DATE1, CA_CUTOFF_DATE2, CA_CUTOFF_DATE3, CA_CUTOFF_DATE4)
            SELECT sch.school_code, v_acadYear, '35', '50', '29', '60', '48', '79', '108', TO_DATE(concat_ws('', V_TERM_START_DATES[1] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[2] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[3] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'),'2', now(), 'CONVERSION', now(), 'CONVERSION',TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS') FROM cp01.CP_ARCH_SCHOOL sch where SCHOOL_CODE =v_school;
            INSERT INTO cp01.cp_arch_sch_stream_parameter(SCHOOL_CODE, ACADEMIC_YEAR,LEVEL_XCODE, stream_xcode, TERM1_DAYS_NO, TERM2_DAYS_NO, TERM3_DAYS_NO, TERM4_DAYS_NO, SEM1_DAYS_NO, SEM2_DAYS_NO, TERM1_START_DATE, TERM1_END_DATE, TERM2_START_DATE, TERM2_END_DATE, TERM3_START_DATE, TERM3_END_DATE, TERM4_START_DATE, TERM4_END_DATE, RECORD_VERSION_NO, CREATED_DATE, CREATED_BY_ID, LAST_UPDATED_DATE, UPDATED_BY_ID, CA_CUTOFF_DATE1, CA_CUTOFF_DATE2, CA_CUTOFF_DATE3, CA_CUTOFF_DATE4)
            SELECT sch.school_code, v_acadYear, '35', '21', '50', '29', '60', '48', '79', '108', TO_DATE(concat_ws('', V_TERM_START_DATES[1] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[2] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[3] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'),'2', now(), 'CONVERSION', now(), 'CONVERSION',TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS') FROM cp01.CP_ARCH_SCHOOL sch where SCHOOL_CODE =v_school;
        END IF;

        IF v_mainlevel_code IN ('T1','T2','T6','J','I') THEN -- PreU1, PreU2
            INSERT INTO cp01.CP_ARCH_SCH_LVL_PARAMETER(SCHOOL_CODE, ACADEMIC_YEAR,LEVEL_XCODE, TERM1_DAYS_NO, TERM2_DAYS_NO, TERM3_DAYS_NO, TERM4_DAYS_NO, SEM1_DAYS_NO, SEM2_DAYS_NO, TERM1_START_DATE, TERM1_END_DATE, TERM2_START_DATE, TERM2_END_DATE, TERM3_START_DATE, TERM3_END_DATE, TERM4_START_DATE, TERM4_END_DATE, RECORD_VERSION_NO, CREATED_DATE, CREATED_BY_ID, LAST_UPDATED_DATE, UPDATED_BY_ID, CA_CUTOFF_DATE1, CA_CUTOFF_DATE2, CA_CUTOFF_DATE3, CA_CUTOFF_DATE4)
            SELECT sch.school_code, v_acadYear, '41', '50', '29', '60', '48', '79', '108', TO_DATE(concat_ws('', V_TERM_START_DATES[1] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[2] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[3] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'),'2', now(), 'CONVERSION', now(), 'CONVERSION',TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS') FROM cp01.CP_ARCH_SCHOOL sch where SCHOOL_CODE =v_school;
            INSERT INTO cp01.cp_arch_sch_stream_parameter(SCHOOL_CODE, ACADEMIC_YEAR,LEVEL_XCODE, stream_xcode, TERM1_DAYS_NO, TERM2_DAYS_NO, TERM3_DAYS_NO, TERM4_DAYS_NO, SEM1_DAYS_NO, SEM2_DAYS_NO, TERM1_START_DATE, TERM1_END_DATE, TERM2_START_DATE, TERM2_END_DATE, TERM3_START_DATE, TERM3_END_DATE, TERM4_START_DATE, TERM4_END_DATE, RECORD_VERSION_NO, CREATED_DATE, CREATED_BY_ID, LAST_UPDATED_DATE, UPDATED_BY_ID, CA_CUTOFF_DATE1, CA_CUTOFF_DATE2, CA_CUTOFF_DATE3, CA_CUTOFF_DATE4)
            SELECT sch.school_code, v_acadYear, '41', '00', '50', '29', '60', '48', '79', '108', TO_DATE(concat_ws('', V_TERM_START_DATES[1] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[2] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[3] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'),'2', now(), 'CONVERSION', now(), 'CONVERSION',TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS') FROM cp01.CP_ARCH_SCHOOL sch where SCHOOL_CODE =v_school;

            INSERT INTO cp01.CP_ARCH_SCH_LVL_PARAMETER(SCHOOL_CODE, ACADEMIC_YEAR,LEVEL_XCODE, TERM1_DAYS_NO, TERM2_DAYS_NO, TERM3_DAYS_NO, TERM4_DAYS_NO, SEM1_DAYS_NO, SEM2_DAYS_NO, TERM1_START_DATE, TERM1_END_DATE, TERM2_START_DATE, TERM2_END_DATE, TERM3_START_DATE, TERM3_END_DATE, TERM4_START_DATE, TERM4_END_DATE, RECORD_VERSION_NO, CREATED_DATE, CREATED_BY_ID, LAST_UPDATED_DATE, UPDATED_BY_ID, CA_CUTOFF_DATE1, CA_CUTOFF_DATE2, CA_CUTOFF_DATE3, CA_CUTOFF_DATE4)
            SELECT sch.school_code, v_acadYear, '42', '50', '29', '60', '48', '79', '108', TO_DATE(concat_ws('', V_TERM_START_DATES[1] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[2] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[3] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'),'2', now(), 'CONVERSION', now(), 'CONVERSION',TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS') FROM cp01.CP_ARCH_SCHOOL sch where SCHOOL_CODE =v_school;
            INSERT INTO cp01.cp_arch_sch_stream_parameter(SCHOOL_CODE, ACADEMIC_YEAR,LEVEL_XCODE, stream_xcode, TERM1_DAYS_NO, TERM2_DAYS_NO, TERM3_DAYS_NO, TERM4_DAYS_NO, SEM1_DAYS_NO, SEM2_DAYS_NO, TERM1_START_DATE, TERM1_END_DATE, TERM2_START_DATE, TERM2_END_DATE, TERM3_START_DATE, TERM3_END_DATE, TERM4_START_DATE, TERM4_END_DATE, RECORD_VERSION_NO, CREATED_DATE, CREATED_BY_ID, LAST_UPDATED_DATE, UPDATED_BY_ID, CA_CUTOFF_DATE1, CA_CUTOFF_DATE2, CA_CUTOFF_DATE3, CA_CUTOFF_DATE4)
            SELECT sch.school_code, v_acadYear, '42', '00', '50', '29', '60', '48', '79', '108', TO_DATE(concat_ws('', V_TERM_START_DATES[1] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[2] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[3] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'),'2', now(), 'CONVERSION', now(), 'CONVERSION',TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS') FROM cp01.CP_ARCH_SCHOOL sch where SCHOOL_CODE =v_school;
        END IF;

        IF v_mainlevel_code IN ('I') THEN -- PreU3
            INSERT INTO cp01.CP_ARCH_SCH_LVL_PARAMETER(SCHOOL_CODE, ACADEMIC_YEAR,LEVEL_XCODE, TERM1_DAYS_NO, TERM2_DAYS_NO, TERM3_DAYS_NO, TERM4_DAYS_NO, SEM1_DAYS_NO, SEM2_DAYS_NO, TERM1_START_DATE, TERM1_END_DATE, TERM2_START_DATE, TERM2_END_DATE, TERM3_START_DATE, TERM3_END_DATE, TERM4_START_DATE, TERM4_END_DATE, RECORD_VERSION_NO, CREATED_DATE, CREATED_BY_ID, LAST_UPDATED_DATE, UPDATED_BY_ID, CA_CUTOFF_DATE1, CA_CUTOFF_DATE2, CA_CUTOFF_DATE3, CA_CUTOFF_DATE4)
            SELECT sch.school_code, v_acadYear, '43', '50', '29', '60', '48', '79', '108', TO_DATE(concat_ws('', V_TERM_START_DATES[1] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[2] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[3] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'),'2', now(), 'CONVERSION', now(), 'CONVERSION',TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS') FROM cp01.CP_ARCH_SCHOOL sch where SCHOOL_CODE =v_school;
            INSERT INTO cp01.cp_arch_sch_stream_parameter(SCHOOL_CODE, ACADEMIC_YEAR,LEVEL_XCODE, stream_xcode, TERM1_DAYS_NO, TERM2_DAYS_NO, TERM3_DAYS_NO, TERM4_DAYS_NO, SEM1_DAYS_NO, SEM2_DAYS_NO, TERM1_START_DATE, TERM1_END_DATE, TERM2_START_DATE, TERM2_END_DATE, TERM3_START_DATE, TERM3_END_DATE, TERM4_START_DATE, TERM4_END_DATE, RECORD_VERSION_NO, CREATED_DATE, CREATED_BY_ID, LAST_UPDATED_DATE, UPDATED_BY_ID, CA_CUTOFF_DATE1, CA_CUTOFF_DATE2, CA_CUTOFF_DATE3, CA_CUTOFF_DATE4)
            SELECT sch.school_code, v_acadYear, '43', '00', '50', '29', '60', '48', '79', '108', TO_DATE(concat_ws('', V_TERM_START_DATES[1] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[2] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[3] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_START_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4] , ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'),'2', now(), 'CONVERSION', now(), 'CONVERSION',TO_DATE(concat_ws('', V_TERM_END_DATES[1], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[2], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[3], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS'), TO_DATE(concat_ws('', V_TERM_END_DATES[4], ' 00:00:00'), 'DD/MM/YY HH24:MI:SS') FROM cp01.CP_ARCH_SCHOOL sch where SCHOOL_CODE =v_school;
        END IF;

        FOR school_holiday IN 0..5 LOOP
            UPDATE cp01.cp_arch_sch_stream_holiday SET DATE_TYPE_ICODE='S', DATE_DESC= V_SCHOOL_HOLIDAY_DESC[school_holiday] WHERE SCHOOL_CODE =v_school AND ACADEMIC_YEAR=v_acadYear AND CALENDAR_DATE = TO_DATE(V_SCHOOL_HOLIDAY_DATES[school_holiday], 'DD/MM/YYYY');
        END LOOP;
        
        FOR public_holiday IN 0..11 LOOP
            UPDATE cp01.cp_arch_sch_stream_holiday SET DATE_TYPE_ICODE='P', DATE_DESC= V_PUBLIC_HOLIDAY_DESC[public_holiday] WHERE SCHOOL_CODE =v_school AND ACADEMIC_YEAR=v_acadYear AND CALENDAR_DATE = TO_DATE(V_PUBLIC_HOLIDAY_DATES[public_holiday], 'DD/MM/YYYY');
        END LOOP;

        IF v_mainlevel_code IN ('T5', 'P') THEN -- PRI1 TO PRI6
            UPDATE cp01.cp_arch_sch_stream_holiday SET DATE_TYPE_ICODE='S', DATE_DESC= 'Childrens Day' WHERE SCHOOL_CODE =v_school AND ACADEMIC_YEAR=v_acadYear AND CALENDAR_DATE = v_CHILDRENS_DAY;
        END IF;

        --commit;

        delete from cp01.cp_arch_sch_stream_holiday
        where school_code =v_school and ACADEMIC_YEAR=v_acadYear and DATE_TYPE_ICODE='D'
        and  not exists (
        select 1 from cp01.CP_ARCH_SCH_YRLY_PARAMETER
        where cp01.CP_ARCH_SCH_YRLY_PARAMETER.SCHOOL_CODE = cp01.cp_arch_sch_stream_holiday.SCHOOL_CODE
        AND cp01.CP_ARCH_SCH_YRLY_PARAMETER.ACADEMIC_YEAR = cp01.cp_arch_sch_stream_holiday.ACADEMIC_YEAR
        AND (
            calendar_date between term1_start_date and term1_end_date or
            calendar_date between term2_start_date and term2_end_date or
            calendar_date between term3_start_date and term3_end_date or
            calendar_date between term4_start_date and term4_end_date
        )); 
    end loop;


END 
$block$;

commit;

\qecho 'cp01.cp_arch_sch_stream_holiday'
select school_code, stream_xcode, count(*)  from cp01.cp_arch_sch_stream_holiday 
where academic_year = to_char(now(), 'YYYY') and school_code between '9808' and '9808' group by school_code, stream_xcode order by school_code, stream_xcode;

\qecho 'cp01.CP_ARCH_SCH_YRLY_PARAMETER'
select school_code, count(*)  from cp01.CP_ARCH_SCH_YRLY_PARAMETER 
where academic_year = to_char(now(), 'YYYY') and school_code between '9808' and '9808' group by school_code order by school_code;

\qecho 'cp01.CP_ARCH_SCH_LVL_PARAMETER'
select school_code, level_xcode, count(*) from cp01.CP_ARCH_SCH_LVL_PARAMETER 
where academic_year = to_char(now(), 'YYYY') and school_code between '9808' and '9808' group by school_code,level_xcode order by school_code,level_xcode;

\qecho 'cp01.CP_ARCH_SCH_STREAM_PARAMETER'
select school_code, level_xcode, stream_xcode, count(*)  
from cp01.CP_ARCH_SCH_STREAM_PARAMETER 
where academic_year = to_char(now(), 'YYYY') and school_code between '9808' and '9808'
group by school_code,level_xcode, stream_xcode 
order by school_code,level_xcode, stream_xcode;

select school_code, count(*), 
TERM1_DAYS_NO, TERM2_DAYS_NO, TERM3_DAYS_NO, TERM4_DAYS_NO, 
TERM1_START_DATE, TERM1_END_DATE, TERM2_START_DATE, TERM2_END_DATE, TERM3_START_DATE, TERM3_END_DATE, TERM4_START_DATE, TERM4_END_DATE
from cp01.CP_ARCH_SCH_STREAM_PARAMETER 
where academic_year = to_char(now(), 'YYYY') and school_code between '9808' and '9808'  
group by school_code,
TERM1_DAYS_NO, TERM2_DAYS_NO, TERM3_DAYS_NO, TERM4_DAYS_NO, 
TERM1_START_DATE, TERM1_END_DATE, TERM2_START_DATE, TERM2_END_DATE, TERM3_START_DATE, TERM3_END_DATE, TERM4_START_DATE, TERM4_END_DATE
order by school_code,
TERM1_DAYS_NO, TERM2_DAYS_NO, TERM3_DAYS_NO, TERM4_DAYS_NO, 
TERM1_START_DATE, TERM1_END_DATE, TERM2_START_DATE, TERM2_END_DATE, TERM3_START_DATE, TERM3_END_DATE, TERM4_START_DATE, TERM4_END_DATE;