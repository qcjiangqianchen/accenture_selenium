
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
        delete from cp01.CP_CODE_SCHOOLMASTER where CATEGORY_NAME = 'SCHOOL' and code_value = v_school;
        delete from cp01.cp_arch_school where school_code = v_school;
        delete from cp01.cp_code_school where code_value = v_school;
        delete from cp01.cp_arch_class where school_code = v_school;
        delete from cp01.cp_sal_class_parameter where school_code = v_school;
        delete from cp01.cp_arch_sch_stream_holiday where school_code = v_school;
		delete from cp01.cp_arch_school_parameter where school_code = v_school;
        delete from cp01.cp_arch_school_transaction where school_code = v_school;
        delete from cp01.cp_tt_timetable_hdr where school_code = v_school;
        delete from cp01.CP_ARCH_SCH_YRLY_PARAMETER where SCHOOL_CODE =v_school;
        delete from cp01.CP_ARCH_SCH_LVL_PARAMETER where SCHOOL_CODE =v_school;
        delete from cp01.cp_arch_sch_stream_parameter where SCHOOL_CODE =v_school;
        delete from cp01.cp_arch_sch_stream_holiday where school_code =v_school
    END LOOP;
 
END
$BLOCK$;
COMMIT;
-- This script deletes school data from various tables in the CP schema.