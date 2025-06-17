DO $BLOCK$
DECLARE
    v_school CHARACTER VARYING(10) := NULL;
    v_start_sch DOUBLE PRECISION := 9960;
    v_end_sch DOUBLE PRECISION := 9961;
	v_course_sys_code  CHARACTER VARYING(15) := NULL; 
	v_SEQ_GPA_SYSCODE  CHARACTER VARYING(14) := NULL; 
	v_grdscheme_sys_code CHARACTER VARYING(14) := NULL;

	v_previous_year CHARACTER VARYING(4) := (to_char(now(), 'YYYY')::NUMERIC - 1)::text;
    v_current_year CHARACTER VARYING(4) := to_char(now(), 'YYYY');

BEGIN   
    WHILE
        v_school := TRIM(to_char(v_start_sch,'9999'));
        v_start_sch := v_start_sch + 1;
		raise notice 'LOOP1 %', v_school;

        -- delete from cp_cur_aggregate_parameter (the current loaded subjects and frames) if the school exists and curriculum is in current and previous year
        DELETE FROM cp01.cp_cur_aggregate_parameter
            WHERE school_code = v_school and academic_year in (v_previous_year, v_current_year);

        -- delete from cp_cur_passing_ind if school exists and academic year is current
        DELETE FROM CP01.cp_cur_passing_ind 
            WHERE school_code = v_school AND academic_year = TO_CHAR(NOW(),'YYYY');
            
        
        