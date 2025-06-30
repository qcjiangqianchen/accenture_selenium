BEGIN;
DO $BLOCK$
DECLARE
    v_populate_assessment_frame BOOLEAN := TRUE;
    v_ip_dt_na_geb_school CHARACTER VARYING(2) := 'NA';
    v_mainlevel_code CHARACTER VARYING(2) := NULL;
    v_school CHARACTER VARYING(10) := NULL;

    v_start_sch DOUBLE PRECISION := 9808;
    v_end_sch DOUBLE PRECISION := 9808;


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
                WHERE school_code = v_school;
        DELETE FROM cp20.cp_cur_cay_sch_asmt_frame
            WHERE school_code = v_school;
        --COMMIT;