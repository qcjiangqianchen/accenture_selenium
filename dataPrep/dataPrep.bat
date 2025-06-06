@echo off
SET PGPASSWORD=password_predevscpgadmin
"%USERPROFILE%\AppData\Local\Programs\pgAdmin 4\runtime\psql" -h dbs-aurora-predevezapp-predevsccluster03.cluster-cgw632hbyo27.ap-southeast-1.rds.amazonaws.com -d predevscpg_new -U predevscpgadmin -f "%~dp001_basic_school.sql"
"%USERPROFILE%\AppData\Local\Programs\pgAdmin 4\runtime\psql" -h dbs-aurora-predevezapp-predevsccluster03.cluster-cgw632hbyo27.ap-southeast-1.rds.amazonaws.com -d predevscpg_new -U predevscpgadmin -f "%~dp002_assessment_fram.sql"
"%USERPROFILE%\AppData\Local\Programs\pgAdmin 4\runtime\psql" -h dbs-aurora-predevezapp-predevsccluster03.cluster-cgw632hbyo27.ap-southeast-1.rds.amazonaws.com -d predevscpg_new -U predevscpgadmin -f "%~dp003_add_stud_n_staff.sql"
"%USERPROFILE%\AppData\Local\Programs\pgAdmin 4\runtime\psql" -h dbs-aurora-predevezapp-predevsccluster03.cluster-cgw632hbyo27.ap-southeast-1.rds.amazonaws.com -d predevscpg_new -U predevscpgadmin -f "%~dp004_subject_basic_frame.sql"

pause