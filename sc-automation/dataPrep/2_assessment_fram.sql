-- v_populate_assessment_frame
-- v_ip_dt_na_geb_school 
    -- 'NA' -> normal school
    -- 'DT' -> dual Track
    -- 'IP' -> FULL IP
    -- 'GE' -> GEP

\o 'S2-Non-IP-02_assessment_fram.log'

\qecho 'cp01.cp_arch_school'
select school_code,  count(*) from cp01.cp_arch_school where school_code between '9808' and '9808' group by school_code;
\qecho 'cp01.cp_cur_cay_sch_asmt_frame'
select school_code,  count(*) from cp20.cp_cur_cay_sch_asmt_frame where school_code between '9808' and '9808' and academic_year = to_char(now(),'YYYY') group by school_code;

\qecho 'cp_cur_cay_sch_asmt_frame_dtls all'
select * from cp20.cp_cur_cay_sch_asmt_frame fram, cp20.cp_cur_cay_sch_asmt_frame_dtls dtls WHERE fram.school_code between '9808' and '9808' 
AND fram.framework_sys_code = dtls.framework_sys_code
and fram.academic_year = to_char(now(),'YYYY');


BEGIN;
DO $BLOCK$
DECLARE
    v_populate_assessment_frame BOOLEAN := TRUE;
    v_ip_dt_na_geb_school CHARACTER VARYING(2) := 'NA';
    v_mainlevel_code CHARACTER VARYING(2) := NULL;
    v_school CHARACTER VARYING(10) := NULL;

    v_start_sch DOUBLE PRECISION := START_SCH;
    v_end_sch DOUBLE PRECISION := END_SCH;

    asmt_cursor CURSOR (v_sch TEXT) FOR
    SELECT
        framework_sys_code, level_xcode, program_ind
        FROM cp20.cp_cur_cay_sch_asmt_frame
        WHERE cp20.cp_cur_cay_sch_asmt_frame.school_code = v_sch;

    asmt_cursor3 CURSOR (v_sch TEXT) FOR
    SELECT
        cp20.cp_cur_cay_sch_asmt_frame.framework_sys_code, cp20.cp_cur_cay_sch_asmt_frame.level_xcode, cp20.cp_cur_cay_sch_asmt_frame.program_ind, item_id,
        cp20.cp_cur_cay_sch_asmt_frame_dtls.Tier_Id TierId, cp20.cp_cur_cay_sch_asmt_frame_dtls.Assessment_Type AssessmentType,
        cp20.cp_cur_cay_sch_asmt_frame_dtls.version_no, 
        cp20.cp_cur_cay_sch_asmt_frame_dtls.created_ts, cp20.cp_cur_cay_sch_asmt_frame_dtls.created_by, 
        cp20.cp_cur_cay_sch_asmt_frame_dtls.updated_ts, cp20.cp_cur_cay_sch_asmt_frame_dtls.updated_by
        FROM cp20.cp_cur_cay_sch_asmt_frame, cp20.cp_cur_cay_sch_asmt_frame_dtls
        WHERE cp20.cp_cur_cay_sch_asmt_frame.school_code = v_sch AND cp20.cp_cur_cay_sch_asmt_frame.framework_sys_code = cp20.cp_cur_cay_sch_asmt_frame_dtls.framework_sys_code
		and cp20.cp_cur_cay_sch_asmt_frame.academic_year = to_char(now(),'YYYY');

BEGIN
    WHILE v_start_sch <= v_end_sch LOOP
        v_school := trim(TO_CHAR(v_start_sch,'9999'));
        raise notice '%', v_school;
        v_start_sch := v_start_sch + 1;

        SELECT mainlevel_code INTO v_mainlevel_code FROM cp01.cp_arch_school where school_code = v_school;
        raise notice '% mainlevel_code: %', v_school, v_mainlevel_code;
        
        raise notice '% v_ip_dt_na_geb_school: %', v_school, v_ip_dt_na_geb_school;
        

        /* HAY */
        -- DELETE FROM cp01.cp_cur_sch_asmt_frame_dtls
        --     WHERE framework_sys_code IN (SELECT
        --         framework_sys_code
        --         FROM cp01.cp_cur_sch_asmt_frame
        --         WHERE school_code = v_school and academic_year = (to_char(now(), 'YYYY')::NUMERIC - 1)::text);
        -- DELETE FROM cp01.cp_cur_sch_asmt_frame
        --     WHERE school_code = v_school and academic_year = (to_char(now(), 'YYYY')::NUMERIC - 1)::text;
        --COMMIT;

        /* CAY */
        DELETE FROM cp20.cp_cur_cay_sch_asmt_frame_dtls
            WHERE framework_sys_code IN (SELECT
                framework_sys_code
                FROM cp20.cp_cur_cay_sch_asmt_frame
                WHERE school_code = v_school);
        DELETE FROM cp20.cp_cur_cay_sch_asmt_frame
            WHERE school_code = v_school;
        --COMMIT;
        
        IF v_populate_assessment_frame then
            IF v_mainlevel_code IN ('T5', 'P') THEN -- PRI1 TO PRI6
                INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY')::NUMERIC - 1, v_school, '11', 'P1 FRAMEWORK', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '0', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY')::NUMERIC - 1, v_school, '12', 'P2 FRAMEWORK', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '0', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY')::NUMERIC - 1, v_school, '13', 'P3 FRAMEWORK', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '0', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY')::NUMERIC - 1, v_school, '14', 'P4 FRAMEWORK', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '0', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY')::NUMERIC - 1, v_school, '15', 'P5 FRAMEWORK', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '0', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY')::NUMERIC - 1, v_school, '16', 'P6 FRAMEWORK', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '0', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                
                INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY'), v_school, '11', 'P1 FRAMEWORK', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '0', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY'), v_school, '12', 'P2 FRAMEWORK', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '0', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY'), v_school, '13', 'P3 FRAMEWORK', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '0', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY'), v_school, '14', 'P4 FRAMEWORK', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '0', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY'), v_school, '15', 'P5 FRAMEWORK', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '0', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY'), v_school, '16', 'P6 FRAMEWORK', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '0', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
            
                IF v_ip_dt_na_geb_school = 'GE' THEN
                    --FOR GEP
                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                    VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY')::NUMERIC - 1, v_school, '14', 'P4 GEP', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '1', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                    VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY')::NUMERIC - 1, v_school, '15', 'P5 GEP', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '1', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                    VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY')::NUMERIC - 1, v_school, '16', 'P6 GEP', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '1', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                
                    --FOR GEP
                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                    VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY'), v_school, '14', 'P4 GEP', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '1', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                    VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY'), v_school, '15', 'P5 GEP', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '1', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                    VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY'), v_school, '16', 'P6 GEP', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '1', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                END IF;
            END IF;

            -- Secondary
            IF v_mainlevel_code IN ('S1','S2', 'T1', 'T5', 'T6') THEN -- SEC1, SEC2
                IF v_ip_dt_na_geb_school = 'DT' THEN
                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                    VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY')::NUMERIC - 1, v_school, '31', 'S1 FRAMEWORK', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '0', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                    VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY')::NUMERIC - 1, v_school, '32', 'S2 FRAMEWORK', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '0', 'Y', replace(public.uuid_generate_v4()::text,'-',''));

                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                    VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY'), v_school, '31', 'S1 FRAMEWORK', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '0', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                    VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY'), v_school, '32', 'S2 FRAMEWORK', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '0', 'Y', replace(public.uuid_generate_v4()::text,'-',''));

                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                    VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY')::NUMERIC - 1, v_school, '31', 'S1 FRAMEWORK IP', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '2', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                    VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY')::NUMERIC - 1, v_school, '32', 'S2 FRAMEWORK IP', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '2', 'Y', replace(public.uuid_generate_v4()::text,'-',''));

                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                    VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY'), v_school, '31', 'S1 FRAMEWORK IP', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '2', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                    VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY'), v_school, '32', 'S2 FRAMEWORK IP', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '2', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                    
                ELSIF v_ip_dt_na_geb_school = 'IP' THEN
                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                    VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY')::NUMERIC - 1, v_school, '31', 'S1 FRAMEWORK IP', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '2', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                    VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY')::NUMERIC - 1, v_school, '32', 'S2 FRAMEWORK IP', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '2', 'Y', replace(public.uuid_generate_v4()::text,'-',''));

                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                    VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY'), v_school, '31', 'S1 FRAMEWORK IP', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '2', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                    VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY'), v_school, '32', 'S2 FRAMEWORK IP', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '2', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                
                ELSIF v_ip_dt_na_geb_school = 'NA' THEN
                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                    VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY')::NUMERIC - 1, v_school, '31', 'S1 FRAMEWORK', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '0', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                    VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY')::NUMERIC - 1, v_school, '32', 'S2 FRAMEWORK', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '0', 'Y', replace(public.uuid_generate_v4()::text,'-',''));

                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                    VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY'), v_school, '31', 'S1 FRAMEWORK', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '0', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                    VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY'), v_school, '32', 'S2 FRAMEWORK', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '0', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                END IF;
            END IF;

            IF v_mainlevel_code IN ('S1','S2', 'T1', 'T5', 'T6', 'T2') THEN -- SEC3, SEC4
                IF v_ip_dt_na_geb_school = 'DT' THEN
                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                    VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY')::NUMERIC - 1, v_school, '33', 'S3 FRAMEWORK', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '0', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                    VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY')::NUMERIC - 1, v_school, '34', 'S4 FRAMEWORK', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '0', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                    
                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                    VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY'), v_school, '33', 'S3 FRAMEWORK', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '0', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                    VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY'), v_school, '34', 'S4 FRAMEWORK', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '0', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                    
                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                    VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY')::NUMERIC - 1, v_school, '33', 'S3 FRAMEWORK IP', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '2', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                    VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY')::NUMERIC - 1, v_school, '34', 'S4 FRAMEWORK IP', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '2', 'Y', replace(public.uuid_generate_v4()::text,'-',''));

                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                    VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY'), v_school, '33', 'S3 FRAMEWORK IP', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '2', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                    VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY'), v_school, '34', 'S4 FRAMEWORK IP', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '2', 'Y', replace(public.uuid_generate_v4()::text,'-',''));

                ELSIF v_ip_dt_na_geb_school = 'IP' THEN
                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                    VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY')::NUMERIC - 1, v_school, '33', 'S3 FRAMEWORK IP', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '2', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                    VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY')::NUMERIC - 1, v_school, '34', 'S4 FRAMEWORK IP', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '2', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                    
                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                    VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY'), v_school, '33', 'S3 FRAMEWORK IP', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '2', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                    VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY'), v_school, '34', 'S4 FRAMEWORK IP', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '2', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                    
                ELSIF v_ip_dt_na_geb_school = 'NA' THEN
                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                    VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY')::NUMERIC - 1, v_school, '33', 'S3 FRAMEWORK', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '0', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                    VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY')::NUMERIC - 1, v_school, '34', 'S4 FRAMEWORK', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '0', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                    
                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                    VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY'), v_school, '33', 'S3 FRAMEWORK', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '0', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                    VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY'), v_school, '34', 'S4 FRAMEWORK', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '0', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                END IF;
            END IF;

            IF v_mainlevel_code IN ('S2','T6') THEN -- SEC5
                INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY')::NUMERIC - 1, v_school, '35', 'S5 FRAMEWORK', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '0', 'Y', replace(public.uuid_generate_v4()::text,'-',''));

                INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY'), v_school, '35', 'S5 FRAMEWORK', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '0', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
            END IF;

            -- JC
            IF v_mainlevel_code IN ('T1','T2','T6','J','I') THEN -- PreU1, PreU2
                INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY')::NUMERIC - 1, v_school, '41', 'JC1 FRAMEWORK', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '0', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY')::NUMERIC - 1, v_school, '42', 'JC2 FRAMEWORK', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '0', 'Y', replace(public.uuid_generate_v4()::text,'-',''));

                INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY'), v_school, '41', 'JC1 FRAMEWORK', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '0', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY'), v_school, '42', 'JC2 FRAMEWORK', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '0', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
            END IF;

            IF v_mainlevel_code IN ('I') THEN -- PreU3
                INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY')::NUMERIC - 1, v_school, '43', 'JC3 FRAMEWORK', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '0', 'Y', replace(public.uuid_generate_v4()::text,'-',''));

                INSERT INTO cp20.cp_cur_cay_sch_asmt_frame (framework_sys_code, academic_year, school_code, level_xcode, framework_name, total_tier, asmt_frame_id, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind, program_ind, display_tier2_ind, id)
                VALUES (nextval('cp01.seq_framework_syscode'), to_char(now(), 'YYYY'), v_school, '43', 'JC3 FRAMEWORK', '4', '7', '1', now(), 'LT_DATAPREP', now(), 'LT_DATAPREP', 'N', '0', 'Y', replace(public.uuid_generate_v4()::text,'-',''));
            END IF;


            FOR c IN asmt_cursor (v_school) LOOP
                INSERT INTO cp20.cp_cur_cay_sch_asmt_frame_dtls (framework_sys_code, tier_id, item_id, item_name, term_id, version_no, created_ts, created_by, updated_ts, updated_by, parent_item_id, delete_ind, order_no, assessment_type, percent_no, tier2_mg_display_ind, id)
                VALUES (c.framework_sys_code, 1, '01', 'OVERALL', '4', '1', now(), 'CONVERSION', now(), 'CONVERSION', NULL, 'N', 1, NULL, NULL, 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                INSERT INTO cp20.cp_cur_cay_sch_asmt_frame_dtls (framework_sys_code, tier_id, item_id, item_name, term_id, version_no, created_ts, created_by, updated_ts, updated_by, parent_item_id, delete_ind, order_no, assessment_type, percent_no, tier2_mg_display_ind, id)
                VALUES (c.framework_sys_code, 2, '0102', 'SEMESTER 1', '2', '1', now(), 'CONVERSION', now(), 'CONVERSION', NULL, 'N', 1, NULL, NULL, 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                INSERT INTO cp20.cp_cur_cay_sch_asmt_frame_dtls (framework_sys_code, tier_id, item_id, item_name, term_id, version_no, created_ts, created_by, updated_ts, updated_by, parent_item_id, delete_ind, order_no, assessment_type, percent_no, tier2_mg_display_ind, id)
                VALUES (c.framework_sys_code, 2, '0104', 'SEMESTER 2', '4', '1', now(), 'CONVERSION', now(), 'CONVERSION', NULL, 'N', 1, NULL, NULL, 'Y', replace(public.uuid_generate_v4()::text,'-',''));

                -- tier 3
                IF c.level_xcode IN ('41') THEN
                    raise notice 'SKIP TERM 1 WA: SCHOOL_CODE: %; v_ip_dt_na_geb_school: %; c.level_xcode: %; c.program_ind: %', v_school, v_ip_dt_na_geb_school, c.level_xcode, c.program_ind;
                ELSE
                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame_dtls (framework_sys_code, tier_id, item_id, item_name, term_id, version_no, created_ts, created_by, updated_ts, updated_by, parent_item_id, delete_ind, order_no, assessment_type, percent_no, tier2_mg_display_ind, id)
                    VALUES (c.framework_sys_code, 3, '010101', 'TERM 1 WA', '1', '1', now(), 'CONVERSION', now(), 'CONVERSION', '0102', 'N', 1, NULL, NULL, 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                END IF;

                IF c.level_xcode IN ('43') THEN
                    raise notice 'SKIP TERM 2 WA: SCHOOL_CODE: %; v_ip_dt_na_geb_school: %; c.level_xcode: %; c.program_ind: %', v_school, v_ip_dt_na_geb_school, c.level_xcode, c.program_ind;
                ELSE
                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame_dtls (framework_sys_code, tier_id, item_id, item_name, term_id, version_no, created_ts, created_by, updated_ts, updated_by, parent_item_id, delete_ind, order_no, assessment_type, percent_no, tier2_mg_display_ind, id)
                    VALUES (c.framework_sys_code, 3, '010201', 'TERM 2 WA', '2', '1', now(), 'CONVERSION', now(), 'CONVERSION', '0102', 'N', 1, NULL, NULL, 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                END IF;

                IF c.level_xcode IN ('34', '35') AND c.program_ind IN ('0') THEN
                    raise notice 'SKIP TERM 3 WA: SCHOOL_CODE: %; v_ip_dt_na_geb_school: %; c.level_xcode: %; c.program_ind: %', v_school, v_ip_dt_na_geb_school, c.level_xcode, c.program_ind;
                ELSE
                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame_dtls (framework_sys_code, tier_id, item_id, item_name, term_id, version_no, created_ts, created_by, updated_ts, updated_by, parent_item_id, delete_ind, order_no, assessment_type, percent_no, tier2_mg_display_ind, id)
                    VALUES (c.framework_sys_code, 3, '010301', 'TERM 3 WA', '3', '1', now(), 'CONVERSION', now(), 'CONVERSION', '0104', 'N', 1, NULL, NULL, 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                END IF;

                IF c.level_xcode IN ('16') THEN
                    raise notice 'SKIP TERM 4 WA: SCHOOL_CODE: %; v_ip_dt_na_geb_school: %; c.level_xcode: %; c.program_ind: %', v_school, v_ip_dt_na_geb_school, c.level_xcode, c.program_ind;
                ELSE
                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame_dtls (framework_sys_code, tier_id, item_id, item_name, term_id, version_no, created_ts, created_by, updated_ts, updated_by, parent_item_id, delete_ind, order_no, assessment_type, percent_no, tier2_mg_display_ind, id)
                    VALUES (c.framework_sys_code, 3, '010401', 'End-of-year Exam', '4', '1', now(), 'CONVERSION', now(), 'CONVERSION', '0104', 'N', 1, NULL, NULL, 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                END IF;



                -- tier 4
                IF c.level_xcode IN ('41') THEN
                    raise notice 'SKIP TERM 1 WA - 1: SCHOOL_CODE: %; v_ip_dt_na_geb_school: %; c.level_xcode: %; c.program_ind: %', v_school, v_ip_dt_na_geb_school, c.level_xcode, c.program_ind;
                ELSE
                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame_dtls (framework_sys_code, tier_id, item_id, item_name, term_id, version_no, created_ts, created_by, updated_ts, updated_by, parent_item_id, delete_ind, order_no, assessment_type, percent_no, tier2_mg_display_ind, id)
                    VALUES (c.framework_sys_code, 4, '01010101', 'TERM 1 WA - 1', '1', '1', now(), 'CONVERSION', now(), 'CONVERSION', '010101', 'N', 1, NULL, NULL, 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                END IF;

                IF c.level_xcode IN ('43') THEN
                    raise notice 'SKIP TERM 2 WA - 1: SCHOOL_CODE: %; v_ip_dt_na_geb_school: %; c.level_xcode: %; c.program_ind: %', v_school, v_ip_dt_na_geb_school, c.level_xcode, c.program_ind;
                ELSE
                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame_dtls (framework_sys_code, tier_id, item_id, item_name, term_id, version_no, created_ts, created_by, updated_ts, updated_by, parent_item_id, delete_ind, order_no, assessment_type, percent_no, tier2_mg_display_ind, id)
                    VALUES (c.framework_sys_code, 4, '01020101', 'TERM 2 WA - 1', '2', '1', now(), 'CONVERSION', now(), 'CONVERSION', '010201', 'N', 1, NULL, NULL, 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                END IF;

                -- CODE S2 FOR S4 AND S5
                -- e.g. 3003 AY24 have Term 3 WA, so prelim in 10401 (term 4)
                IF c.level_xcode IN ('34', '35') AND c.program_ind IN ('0') THEN
                    raise notice 'SKIP TERM 3 WA - 1: SCHOOL_CODE: %; v_ip_dt_na_geb_school: %; c.level_xcode: %; c.program_ind: %', v_school, v_ip_dt_na_geb_school, c.level_xcode, c.program_ind;
                ELSE
                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame_dtls (framework_sys_code, tier_id, item_id, item_name, term_id, version_no, created_ts, created_by, updated_ts, updated_by, parent_item_id, delete_ind, order_no, assessment_type, percent_no, tier2_mg_display_ind, id)
                    VALUES (c.framework_sys_code, 4, '01030101', 'TERM 3 WA - 1', '3', '1', now(), 'CONVERSION', now(), 'CONVERSION', '010301', 'N', 1, NULL, NULL, 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                END IF;

                IF c.level_xcode IN ('16') THEN
                    raise notice 'SKIP TERM 4 WA: SCHOOL_CODE: %; v_ip_dt_na_geb_school: %; c.level_xcode: %; c.program_ind: %', v_school, v_ip_dt_na_geb_school, c.level_xcode, c.program_ind;
                ELSE
                    INSERT INTO cp20.cp_cur_cay_sch_asmt_frame_dtls (framework_sys_code, tier_id, item_id, item_name, term_id, version_no, created_ts, created_by, updated_ts, updated_by, parent_item_id, delete_ind, order_no, assessment_type, percent_no, tier2_mg_display_ind, id)
                    VALUES (c.framework_sys_code, 4, '01040101', 'End-of-year Exam - 1', '4', '1', now(), 'CONVERSION', now(), 'CONVERSION', '010401', 'N', 1, NULL, NULL, 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                END IF;


                -- ADDITIONAL ASSESSMENTS
                IF v_mainlevel_code IN ('I') THEN
                    IF c.level_xcode IN ('41') THEN
                        INSERT INTO cp20.cp_cur_cay_sch_asmt_frame_dtls (framework_sys_code, tier_id, item_id, item_name, term_id, version_no, created_ts, created_by, updated_ts, updated_by, parent_item_id, delete_ind, order_no, assessment_type, percent_no, tier2_mg_display_ind, id)
                        VALUES (c.framework_sys_code, 3, '010402', 'End-of-year Exam', '4', '1', now(), 'CONVERSION', now(), 'CONVERSION', '0104', 'N', 1, 'EYE', 55, 'Y', replace(public.uuid_generate_v4()::text,'-',''));

                        INSERT INTO cp20.cp_cur_cay_sch_asmt_frame_dtls (framework_sys_code, tier_id, item_id, item_name, term_id, version_no, created_ts, created_by, updated_ts, updated_by, parent_item_id, delete_ind, order_no, assessment_type, percent_no, tier2_mg_display_ind, id)
                        VALUES (c.framework_sys_code, 4, '01040201', 'End-of-year Exam - 1', '4', '1', now(), 'CONVERSION', now(), 'CONVERSION', '010402', 'N', 1, NULL, NULL, 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                    ELSIF c.level_xcode IN ('42') THEN
                        INSERT INTO cp20.cp_cur_cay_sch_asmt_frame_dtls (framework_sys_code, tier_id, item_id, item_name, term_id, version_no, created_ts, created_by, updated_ts, updated_by, parent_item_id, delete_ind, order_no, assessment_type, percent_no, tier2_mg_display_ind, id)
                        VALUES (c.framework_sys_code, 3, '010102', 'Term 1 Class Test', '1', '1', now(), 'CONVERSION', now(), 'CONVERSION', '0102', 'N', 1, 'NWA', NULL, 'Y', replace(public.uuid_generate_v4()::text,'-',''));

                        INSERT INTO cp20.cp_cur_cay_sch_asmt_frame_dtls (framework_sys_code, tier_id, item_id, item_name, term_id, version_no, created_ts, created_by, updated_ts, updated_by, parent_item_id, delete_ind, order_no, assessment_type, percent_no, tier2_mg_display_ind, id)
                        VALUES (c.framework_sys_code, 4, '01010201', 'Term 1 Class Test - 1', '1', '1', now(), 'CONVERSION', now(), 'CONVERSION', '010102', 'N', 1, NULL, NULL, 'Y', replace(public.uuid_generate_v4()::text,'-',''));

                        INSERT INTO cp20.cp_cur_cay_sch_asmt_frame_dtls (framework_sys_code, tier_id, item_id, item_name, term_id, version_no, created_ts, created_by, updated_ts, updated_by, parent_item_id, delete_ind, order_no, assessment_type, percent_no, tier2_mg_display_ind, id)
                        VALUES (c.framework_sys_code, 3, '010302', 'Term 2 Class Test', '3', '1', now(), 'CONVERSION', now(), 'CONVERSION', '0104', 'N', 1, 'NWA', NULL, 'Y', replace(public.uuid_generate_v4()::text,'-',''));

                        INSERT INTO cp20.cp_cur_cay_sch_asmt_frame_dtls (framework_sys_code, tier_id, item_id, item_name, term_id, version_no, created_ts, created_by, updated_ts, updated_by, parent_item_id, delete_ind, order_no, assessment_type, percent_no, tier2_mg_display_ind, id)
                        VALUES (c.framework_sys_code, 4, '01030201', 'Term 2 Class Test - 1', '3', '1', now(), 'CONVERSION', now(), 'CONVERSION', '010302', 'N', 1, NULL, NULL, 'Y', replace(public.uuid_generate_v4()::text,'-',''));
                    END IF;
                END IF;

            END LOOP;
            --COMMIT;

            DELETE FROM cp20.cp_cur_cay_sch_des WHERE school_code = v_school and academic_year = to_char(now(), 'YYYY');

            -- foreach cp_cur_cay_sch_asmt_frame_dtls
            FOR c IN asmt_cursor3 (v_school) LOOP
                INSERT INTO cp20.cp_cur_cay_sch_des (id, academic_year, school_code, level_xcode, program_ind, result_type_icode, display_ind, des_type_code, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind)
                VALUES (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'), v_school, c.level_xcode, c.program_ind, c.item_id, 'Y', '01', c.version_no, c.created_ts, c.created_by, c.updated_ts, c.updated_by, 'N');
                INSERT INTO cp20.cp_cur_cay_sch_des (id, academic_year, school_code, level_xcode, program_ind, result_type_icode, display_ind, des_type_code, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind)
                VALUES (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'), v_school, c.level_xcode, c.program_ind, c.item_id, 'Y', '02', c.version_no, c.created_ts, c.created_by, c.updated_ts, c.updated_by, 'N');
                INSERT INTO cp20.cp_cur_cay_sch_des (id, academic_year, school_code, level_xcode, program_ind, result_type_icode, display_ind, des_type_code, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind)
                VALUES (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'), v_school, c.level_xcode, c.program_ind, c.item_id, 'Y', '03', c.version_no, c.created_ts, c.created_by, c.updated_ts, c.updated_by, 'N');
                INSERT INTO cp20.cp_cur_cay_sch_des (id, academic_year, school_code, level_xcode, program_ind, result_type_icode, display_ind, des_type_code, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind)
                VALUES (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'), v_school, c.level_xcode, c.program_ind, c.item_id, 'Y', '04', c.version_no, c.created_ts, c.created_by, c.updated_ts, c.updated_by, 'N');
                INSERT INTO cp20.cp_cur_cay_sch_des (id, academic_year, school_code, level_xcode, program_ind, result_type_icode, display_ind, des_type_code, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind)
                VALUES (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'), v_school, c.level_xcode, c.program_ind, c.item_id, 'Y', '05', c.version_no, c.created_ts, c.created_by, c.updated_ts, c.updated_by, 'N');
                INSERT INTO cp20.cp_cur_cay_sch_des (id, academic_year, school_code, level_xcode, program_ind, result_type_icode, display_ind, des_type_code, version_no, created_ts, created_by, updated_ts, updated_by, delete_ind)
                VALUES (replace(public.uuid_generate_v4()::text,'-',''), to_char(now(), 'YYYY'), v_school, c.level_xcode, c.program_ind, c.item_id, 'Y', '06', c.version_no, c.created_ts, c.created_by, c.updated_ts, c.updated_by, 'N');
            END LOOP;

            FOR c IN asmt_cursor3 (v_school) LOOP
                IF c.tierid = '3' AND c.assessmenttype IN ('MYE','PRELIM','EYE') THEN
                    BEGIN
                    INSERT INTO cp20.cp_cur_cay_school_exam_type(id, subject_school_code , academic_year , level_xcode , program_ind , result_type_icode , exam_type , version_no ,created_ts,   created_by   ,       updated_ts,   updated_by   , delete_ind)
                        SELECT replace(public.uuid_generate_v4()::text,'-',''), v_school, to_char(now(), 'YYYY'), C.level_xcode, C.program_ind, C.item_id, 
                        CASE 
                            WHEN c.assessmenttype = 'MYE' THEN 'M'
                            WHEN c.assessmenttype = 'PRELIM' THEN 'P'
                            WHEN c.assessmenttype = 'EYE' THEN 'E'
                        END AS exam_type,
                        '1', now(), 'CONVERSION', now(), 'CONVERSION', 'N';
                    exception when others then
                        raise notice 'cp_cur_cay_school_exam_type RECORD EXISTS FOR SCHOOL: %, assessmenttype: %', v_school, c.assessmenttype;
                    END;
                END IF;
            END LOOP;

            --COMMIT;
            -- TIER 1
            UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
            SET percent_no = 100
                WHERE framework_sys_code IN (SELECT
                    framework_sys_code
                    FROM cp20.cp_cur_cay_sch_asmt_frame
                    WHERE school_code = v_school AND level_xcode NOT IN ('11', '12')) AND item_id IN ('01');

            UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
            SET percent_no = 0
                WHERE framework_sys_code IN (SELECT
                    framework_sys_code
                    FROM cp20.cp_cur_cay_sch_asmt_frame
                    WHERE school_code = v_school AND level_xcode IN ('11', '12')) AND item_id IN ('01');

            -- TIER 2, TIER 4
            UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
            SET percent_no = NULL, assessment_type = NULL
                WHERE framework_sys_code IN (SELECT
                    framework_sys_code
                    FROM cp20.cp_cur_cay_sch_asmt_frame
                    WHERE school_code = v_school) AND item_id IN ('0102', '0104', '01010101', '01020101', '01030101', '01040101');

            -- TIER 3
            -- P1, P2
            UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
            SET percent_no = 0, assessment_type = 'AS', item_name = SUBSTR(item_name, 1, 7) || 'NWA'
                WHERE framework_sys_code IN (SELECT
                    framework_sys_code
                    FROM cp20.cp_cur_cay_sch_asmt_frame
                    WHERE school_code = v_school AND level_xcode IN ('11', '12')) AND item_id IN ('010101', '010201', '010301');
            
            UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
            SET item_name = SUBSTR(item_name, 1, 7) || 'Assessment - 1'
                WHERE framework_sys_code IN (SELECT
                    framework_sys_code
                    FROM cp20.cp_cur_cay_sch_asmt_frame
                    WHERE school_code = v_school AND level_xcode IN ('11', '12')) AND item_id IN ('01010101', '01020101', '01030101');

            UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
            SET percent_no = 0, assessment_type = 'AS', item_name = 'Term 4 NWA'
                WHERE framework_sys_code IN (SELECT
                    framework_sys_code
                    FROM cp20.cp_cur_cay_sch_asmt_frame
                    WHERE school_code = v_school AND level_xcode IN ('11', '12')) AND item_id IN ('010401');
            
            UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
            SET item_name = 'Term 4 Assessment - 1'
                WHERE framework_sys_code IN (SELECT
                    framework_sys_code
                    FROM cp20.cp_cur_cay_sch_asmt_frame
                    WHERE school_code = v_school AND level_xcode IN ('11', '12')) AND item_id IN ('01040101');
                    
            -- P3 - P5, S1 - S3
            UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
            SET percent_no = 15, assessment_type = 'WA'
                WHERE framework_sys_code IN (SELECT
                    framework_sys_code
                    FROM cp20.cp_cur_cay_sch_asmt_frame
                    WHERE school_code = v_school AND level_xcode IN ('13', '14', '15', '31', '32', '33')) AND item_id IN ('010101', '010201', '010301');

            UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
            SET percent_no = 55, assessment_type = 'EYE', item_name = 'End-of-year Exam'
                WHERE framework_sys_code IN (SELECT
                    framework_sys_code
                    FROM cp20.cp_cur_cay_sch_asmt_frame
                    WHERE school_code = v_school AND level_xcode IN ('13', '14', '15', '31', '32', '33')) AND item_id IN ('010401');

            UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
            SET item_name = 'End-of-year Exam - 1'
                WHERE framework_sys_code IN (SELECT
                    framework_sys_code
                    FROM cp20.cp_cur_cay_sch_asmt_frame
                    WHERE school_code = v_school AND level_xcode IN ('13', '14', '15', '31', '32', '33')) AND item_id IN ('01040101');

            -- P6
            UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
            SET percent_no = 15, assessment_type = 'WA'
                WHERE framework_sys_code IN (SELECT
                    framework_sys_code
                    FROM cp20.cp_cur_cay_sch_asmt_frame
                    WHERE school_code = v_school AND level_xcode IN ('16')) AND item_id IN ('010101', '010201');

            UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
            SET percent_no = 70, assessment_type = 'PRELIM', item_name = 'Preliminary Exam'
                WHERE framework_sys_code IN (SELECT
                    framework_sys_code
                    FROM cp20.cp_cur_cay_sch_asmt_frame
                    WHERE school_code = v_school AND level_xcode IN ('16')) AND item_id IN ('010301');

            UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
            SET item_name = 'Preliminary Exam - 1'
                WHERE framework_sys_code IN (SELECT
                    framework_sys_code
                    FROM cp20.cp_cur_cay_sch_asmt_frame
                    WHERE school_code = v_school AND level_xcode IN ('16')) AND item_id IN ('01030101');
            
            -- S4, S5
            -- program_ind IN ('0')
            UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
            SET percent_no = 15, assessment_type = 'WA'
                WHERE framework_sys_code IN (SELECT
                    framework_sys_code
                    FROM cp20.cp_cur_cay_sch_asmt_frame
                    WHERE school_code = v_school AND level_xcode IN ('34', '35')) AND item_id IN ('010101', '010201');

            UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
            SET percent_no = 70, assessment_type = 'PRELIM', item_name = 'Preliminary Exam'
                WHERE framework_sys_code IN (SELECT
                    framework_sys_code
                    FROM cp20.cp_cur_cay_sch_asmt_frame
                    WHERE school_code = v_school AND level_xcode IN ('34', '35') AND program_ind IN ('0')) AND item_id IN ('010401');

            UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
            SET item_name = 'Preliminary Exam - 1'
                WHERE framework_sys_code IN (SELECT
                    framework_sys_code
                    FROM cp20.cp_cur_cay_sch_asmt_frame
                    WHERE school_code = v_school AND level_xcode IN ('34', '35') AND program_ind IN ('0')) AND item_id IN ('01040101');

            -- program_ind IN ('2') -> only IP have term 3
            UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
            SET percent_no = 15, assessment_type = 'WA'
                WHERE framework_sys_code IN (SELECT
                    framework_sys_code
                    FROM cp20.cp_cur_cay_sch_asmt_frame
                    WHERE school_code = v_school AND level_xcode IN ('34')) AND item_id IN ('010301');

            UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
            SET percent_no = 55, assessment_type = 'EYE', item_name = 'End-of-year Exam'
                WHERE framework_sys_code IN (SELECT
                    framework_sys_code
                    FROM cp20.cp_cur_cay_sch_asmt_frame
                    WHERE school_code = v_school AND level_xcode IN ('34') AND program_ind IN ('2')) AND item_id IN ('010401');

            UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
            SET item_name = 'End-of-year Exam - 1'
                WHERE framework_sys_code IN (SELECT
                    framework_sys_code
                    FROM cp20.cp_cur_cay_sch_asmt_frame
                    WHERE school_code = v_school AND level_xcode IN ('34') AND program_ind IN ('2')) AND item_id IN ('01040101');

            
            IF v_mainlevel_code IN ('T1','T2','T6','J') THEN -- 41, 42
                -- 41
                UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
                SET percent_no = 15, assessment_type = 'WA', item_name = 'Weighted Assessment 1'
                    WHERE framework_sys_code IN (SELECT
                        framework_sys_code
                        FROM cp20.cp_cur_cay_sch_asmt_frame
                        WHERE school_code = v_school AND level_xcode IN ('41')) AND item_id IN ('010201');
                UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
                SET item_name = 'Weighted Assessment 1 - 1'
                    WHERE framework_sys_code IN (SELECT
                        framework_sys_code
                        FROM cp20.cp_cur_cay_sch_asmt_frame
                        WHERE school_code = v_school AND level_xcode IN ('41')) AND item_id IN ('01020101');

                UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
                SET percent_no = 15, assessment_type = 'WA', item_name = 'Weighted Assessment 2'
                    WHERE framework_sys_code IN (SELECT
                        framework_sys_code
                        FROM cp20.cp_cur_cay_sch_asmt_frame
                        WHERE school_code = v_school AND level_xcode IN ('41')) AND item_id IN ('010301');
                UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
                SET item_name = 'Weighted Assessment 2 - 1'
                    WHERE framework_sys_code IN (SELECT
                        framework_sys_code
                        FROM cp20.cp_cur_cay_sch_asmt_frame
                        WHERE school_code = v_school AND level_xcode IN ('41')) AND item_id IN ('01030101');

                UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
                SET percent_no = 70, assessment_type = 'EYE', item_name = 'Promotional Examination'
                    WHERE framework_sys_code IN (SELECT
                        framework_sys_code
                        FROM cp20.cp_cur_cay_sch_asmt_frame
                        WHERE school_code = v_school AND level_xcode IN ('41')) AND item_id IN ('010401');
                UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
                SET item_name = 'Promotional Examination - 1'
                    WHERE framework_sys_code IN (SELECT
                        framework_sys_code
                        FROM cp20.cp_cur_cay_sch_asmt_frame
                        WHERE school_code = v_school AND level_xcode IN ('41')) AND item_id IN ('01040101');

                -- 42
                UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
                SET percent_no = NULL, assessment_type = 'NWA', item_name = 'Term 1 NWA'
                    WHERE framework_sys_code IN (SELECT
                        framework_sys_code
                        FROM cp20.cp_cur_cay_sch_asmt_frame
                        WHERE school_code = v_school AND level_xcode IN ('42')) AND item_id IN ('010101');
                UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
                SET item_name = 'Term 1 NWA - 1'
                    WHERE framework_sys_code IN (SELECT
                        framework_sys_code
                        FROM cp20.cp_cur_cay_sch_asmt_frame
                        WHERE school_code = v_school AND level_xcode IN ('42')) AND item_id IN ('01010101');

                UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
                SET percent_no = 0, assessment_type = 'MYE', item_name = 'Mid Year Assessment'
                    WHERE framework_sys_code IN (SELECT
                        framework_sys_code
                        FROM cp20.cp_cur_cay_sch_asmt_frame
                        WHERE school_code = v_school AND level_xcode IN ('42')) AND item_id IN ('010201');
                UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
                SET item_name = 'Mid Year Assessment - 1'
                    WHERE framework_sys_code IN (SELECT
                        framework_sys_code
                        FROM cp20.cp_cur_cay_sch_asmt_frame
                        WHERE school_code = v_school AND level_xcode IN ('42')) AND item_id IN ('01020101');
                        
                UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
                SET percent_no = NULL, assessment_type = 'NWA', item_name = 'Term 3 NWA'
                    WHERE framework_sys_code IN (SELECT
                        framework_sys_code
                        FROM cp20.cp_cur_cay_sch_asmt_frame
                        WHERE school_code = v_school AND level_xcode IN ('42')) AND item_id IN ('010301');
                UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
                SET item_name = 'Term 3 NWA - 1'
                    WHERE framework_sys_code IN (SELECT
                        framework_sys_code
                        FROM cp20.cp_cur_cay_sch_asmt_frame
                        WHERE school_code = v_school AND level_xcode IN ('42')) AND item_id IN ('01030101');

                UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
                SET percent_no = 100, assessment_type = 'PRELIM', item_name = 'Preliminary Exam'
                    WHERE framework_sys_code IN (SELECT
                        framework_sys_code
                        FROM cp20.cp_cur_cay_sch_asmt_frame
                        WHERE school_code = v_school AND level_xcode IN ('42')) AND item_id IN ('010401');
                UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
                SET item_name = 'Preliminary Exam - 1'
                    WHERE framework_sys_code IN (SELECT
                        framework_sys_code
                        FROM cp20.cp_cur_cay_sch_asmt_frame
                        WHERE school_code = v_school AND level_xcode IN ('42')) AND item_id IN ('01040101');

            ELSIF v_mainlevel_code IN ('I') THEN -- 41, 42, 43
                -- 41
                UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
                SET percent_no = 15, assessment_type = 'WA', item_name = 'Weighted Assessment 1'
                    WHERE framework_sys_code IN (SELECT
                        framework_sys_code
                        FROM cp20.cp_cur_cay_sch_asmt_frame
                        WHERE school_code = v_school AND level_xcode IN ('41')) AND item_id IN ('010201');
                UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
                SET item_name = 'Weighted Assessment 1 - 1'
                    WHERE framework_sys_code IN (SELECT
                        framework_sys_code
                        FROM cp20.cp_cur_cay_sch_asmt_frame
                        WHERE school_code = v_school AND level_xcode IN ('41')) AND item_id IN ('01020101');

                UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
                SET percent_no = 15, assessment_type = 'WA', item_name = 'Weighted Assessment 2'
                    WHERE framework_sys_code IN (SELECT
                        framework_sys_code
                        FROM cp20.cp_cur_cay_sch_asmt_frame
                        WHERE school_code = v_school AND level_xcode IN ('41')) AND item_id IN ('010301');
                UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
                SET item_name = 'Weighted Assessment 2 - 1'
                    WHERE framework_sys_code IN (SELECT
                        framework_sys_code
                        FROM cp20.cp_cur_cay_sch_asmt_frame
                        WHERE school_code = v_school AND level_xcode IN ('41')) AND item_id IN ('01030101');

                UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
                SET percent_no = 15, assessment_type = 'WA', item_name = 'Weighted Assessment 3'
                    WHERE framework_sys_code IN (SELECT
                        framework_sys_code
                        FROM cp20.cp_cur_cay_sch_asmt_frame
                        WHERE school_code = v_school AND level_xcode IN ('41')) AND item_id IN ('010401');
                UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
                SET item_name = 'Weighted Assessment 3 - 1'
                    WHERE framework_sys_code IN (SELECT
                        framework_sys_code
                        FROM cp20.cp_cur_cay_sch_asmt_frame
                        WHERE school_code = v_school AND level_xcode IN ('41')) AND item_id IN ('01040101');

                -- 42
                UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
                SET percent_no = 15, assessment_type = 'WA', item_name = 'Weighted Assessment 1'
                    WHERE framework_sys_code IN (SELECT
                        framework_sys_code
                        FROM cp20.cp_cur_cay_sch_asmt_frame
                        WHERE school_code = v_school AND level_xcode IN ('42')) AND item_id IN ('010101');
                UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
                SET item_name = 'Weighted Assessment 1 - 1'
                    WHERE framework_sys_code IN (SELECT
                        framework_sys_code
                        FROM cp20.cp_cur_cay_sch_asmt_frame
                        WHERE school_code = v_school AND level_xcode IN ('42')) AND item_id IN ('01010101');

                UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
                SET percent_no = 15, assessment_type = 'WA', item_name = 'Weighted Assessment 2'
                    WHERE framework_sys_code IN (SELECT
                        framework_sys_code
                        FROM cp20.cp_cur_cay_sch_asmt_frame
                        WHERE school_code = v_school AND level_xcode IN ('42')) AND item_id IN ('010201');
                UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
                SET item_name = 'Weighted Assessment 2 - 1'
                    WHERE framework_sys_code IN (SELECT
                        framework_sys_code
                        FROM cp20.cp_cur_cay_sch_asmt_frame
                        WHERE school_code = v_school AND level_xcode IN ('42')) AND item_id IN ('01020101');

                UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
                SET percent_no = 15, assessment_type = 'WA', item_name = 'Weighted Assessment 3'
                    WHERE framework_sys_code IN (SELECT
                        framework_sys_code
                        FROM cp20.cp_cur_cay_sch_asmt_frame
                        WHERE school_code = v_school AND level_xcode IN ('42')) AND item_id IN ('010301');
                UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
                SET item_name = 'Weighted Assessment 3 - 1'
                    WHERE framework_sys_code IN (SELECT
                        framework_sys_code
                        FROM cp20.cp_cur_cay_sch_asmt_frame
                        WHERE school_code = v_school AND level_xcode IN ('42')) AND item_id IN ('01030101');

                UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
                SET percent_no = 55, assessment_type = 'EYE', item_name = 'End-of-year Exam'
                    WHERE framework_sys_code IN (SELECT
                        framework_sys_code
                        FROM cp20.cp_cur_cay_sch_asmt_frame
                        WHERE school_code = v_school AND level_xcode IN ('42')) AND item_id IN ('010401');
                UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
                SET item_name = 'End-of-year Exam - 1'
                    WHERE framework_sys_code IN (SELECT
                        framework_sys_code
                        FROM cp20.cp_cur_cay_sch_asmt_frame
                        WHERE school_code = v_school AND level_xcode IN ('42')) AND item_id IN ('01040101');        

                -- NO 010201
                -- 43
                UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
                SET percent_no = NULL, assessment_type = 'NWA', item_name = 'Term 1 Class Test'
                    WHERE framework_sys_code IN (SELECT
                        framework_sys_code
                        FROM cp20.cp_cur_cay_sch_asmt_frame
                        WHERE school_code = v_school AND level_xcode IN ('43')) AND item_id IN ('010101');
                UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
                SET item_name = 'Term 1 NWA - 1'
                    WHERE framework_sys_code IN (SELECT
                        framework_sys_code
                        FROM cp20.cp_cur_cay_sch_asmt_frame
                        WHERE school_code = v_school AND level_xcode IN ('43')) AND item_id IN ('01010101');

                UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
                SET percent_no = 0, assessment_type = 'MYE', item_name = 'Mid-year Exam'
                    WHERE framework_sys_code IN (SELECT
                        framework_sys_code
                        FROM cp20.cp_cur_cay_sch_asmt_frame
                        WHERE school_code = v_school AND level_xcode IN ('43')) AND item_id IN ('010301');
                UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
                SET item_name = 'Mid-year Exam - 1'
                    WHERE framework_sys_code IN (SELECT
                        framework_sys_code
                        FROM cp20.cp_cur_cay_sch_asmt_frame
                        WHERE school_code = v_school AND level_xcode IN ('43')) AND item_id IN ('01030101');

                UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
                SET percent_no = 100, assessment_type = 'PRELIM', item_name = 'Preliminary Exam'
                    WHERE framework_sys_code IN (SELECT
                        framework_sys_code
                        FROM cp20.cp_cur_cay_sch_asmt_frame
                        WHERE school_code = v_school AND level_xcode IN ('43')) AND item_id IN ('010401');
                UPDATE cp20.cp_cur_cay_sch_asmt_frame_dtls
                SET item_name = 'Preliminary Exam - 1'
                    WHERE framework_sys_code IN (SELECT
                        framework_sys_code
                        FROM cp20.cp_cur_cay_sch_asmt_frame
                        WHERE school_code = v_school AND level_xcode IN ('43')) AND item_id IN ('01040101');
            END IF;

        END IF;
    END LOOP;

END
$BLOCK$;
COMMIT;

UPDATE CP01.CP_ARCH_SCHOOL_TRANSACTION
SET process_status_icode ='CF'
WHERE ACADEMIC_YEAR < TO_CHAR(NOW(), 'YYYY')
AND SCHOOL_CODE  between '9808' and '9808';

\qecho 'cp01.cp_arch_school'
select school_code,  count(*) from cp01.cp_arch_school where school_code between '9808' and '9808' group by school_code;
\qecho 'cp01.cp_cur_cay_sch_asmt_frame'
select school_code,  count(*) from cp20.cp_cur_cay_sch_asmt_frame where school_code between '9808' and '9808' and academic_year = to_char(now(),'YYYY') group by school_code;

\qecho 'cp_cur_cay_sch_asmt_frame_dtls all'
select * from cp20.cp_cur_cay_sch_asmt_frame fram, cp20.cp_cur_cay_sch_asmt_frame_dtls dtls WHERE fram.school_code between '9808' and '9808' 
AND fram.framework_sys_code = dtls.framework_sys_code
and fram.academic_year = to_char(now(),'YYYY');