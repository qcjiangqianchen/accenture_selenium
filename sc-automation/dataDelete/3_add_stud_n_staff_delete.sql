\qecho '****************** PROCESS cp_stud_profile ******************'

BEGIN;
DO $BLOCK%
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

BEGIN 
    WHILE v_start_sch <= v_end_sch LOOP
        v_school := trim(TO_CHAR(v_start_sch,'9999'));
        raise notice 'LOOP 1: %', v_school;
        v_start_sch := v_start_sch + 1;

        -- delete from cp_holding_stud_subj_link if school code matches the current school
        DELETE FROM cp01.cp_holding_stud_subj_link
		    WHERE subject_schooL_code  = v_school;
		
        -- delete from cp_holding_list if school code matches current school
		DELETE FROM cp01.cp_holding_list
            WHERE school_code = v_school;
    
        -- delete student promotion history (between levels) if the matches current school
        DELETE FROM cp01.cp_stud_hist_promotion
            WHERE school_code = v_school;

        -- delete the individual students if the current school is populated
        DELETE FROM cp01.cp_stud_profile
            WHERE school_code = v_school;

        DELETE FROM cp01.cp_tt_staff_subjclass_link
            WHERE school_code = v_school;
        DELETE FROM cp01.cp_access_matrix_role_link
            WHERE uid_code IN (SELECT UIN_FIN_NO FROM CP01.CP_STAFF_PROFILE  WHERE SCHOOL_CODE =v_school );
        DELETE FROM cp01.cp_access_matrix
            WHERE MOE_SCHOOl_CODE =v_school ;
        DELETE FROM cp01.cp_staff_profile
            WHERE  SCHOOL_CODE= v_school;


\qecho '****************** PROCESS cp_staff_profile ******************'

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

BEGIN
    FOR sch IN sch_cur LOOP
        v_school := sch.school_code;
        raise notice 'LOOP 2: %', v_school;

        -- remove staff profile from tables if the school is currently populated w it
        
		v_count := 1;