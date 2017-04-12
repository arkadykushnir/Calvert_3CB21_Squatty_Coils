
/* START COMMENTS 

Create CALVERT.ak3CB2021_prod Table

Work Request:
1. Create CALVERT.ak3CB2021_prod Table
2. FROM calvert.mes_material materials
   INNER JOIN calvert.lpiece lpiece 
    on lpiece.id_coil = materials.coil_id
3. Add De-Dupped: calvert.jrs_coil_reprocess_reject rjrp Table
LEFT OUTER JOIN calvert.jrs_coil_reprocess_reject rjrp
       on rjrp.hsm_piece_no = materials.coil_id 
      and rjrp.defect_code = '508' 

4. Add Down Coiler Tables based on "Section_ID" = 'O' (Overall) Bease on Paul EMAIL 1/31/2017 9:27 am
   Subject:  "Calvert Technical Touchpoint"
 
Requestor:  Paul Huibers (603)395-6567
Request Date:  2/1/2017
Programmer: Arkady Kushnir
Business Reason: Identify Volumes of 3CB20/21 Steel Production by Coil Dimenntions, Slab Suppliers,etc.

Requirements:

Last Modified:

MODIFICATION LOG
Date      Description

END OF COMMENTS */

/* *** Start *** Start *** Start *** Start *** Start *** Start *** Start *** Start *** Start *** */
/* *** Start *** Start *** Start *** Start *** Start *** Start *** Start *** Start *** Start *** */
/* *** Start *** Start *** Start *** Start *** Start *** Start *** Start *** Start *** Start *** */

OPTIONS ERRORS=2 PAGENO=1 MISSING=' ' NOCENTER PAPERSIZE=LEGAL ORIENTATION=PORTRAIT PAGESIZE=80 LINESIZE=132 
        MSGLEVEL=I SPOOL SOURCE SOURCE2 MAUTOSOURCE SYMBOLGEN MPRINT MLOGIC NOBYLINE;
OPTIONS ERRORS=2 PAGENO=1 NOCENTER PAGESIZE=59 LINESIZE=132 PAGESIZE=MAX SPOOL
        MSGLEVEL=I SOURCE SOURCE2 MAUTOSOURCE SYMBOLGEN MPRINT MLOGIC NOBYLINE OBS=MAX; * OBS=100;
OPTIONS FMTERR FULLSTIMER NOTES; 

ODS TRACE ON;


LIBNAME calvert aster user=ak186133 pwd=ak186133 server='10.25.98.20' database=calvert schema=calvert 
                dimension=yes port=2406;

/*
LIBNAME calv13 aster user=ak186133 pwd=ak186133 server='10.25.98.13' database=calvert schema=calvert 
                dimension=yes port=2406;
*/

/*
LIBNAME dcalvert aster user=db_superuser pwd=superuser server='10.25.98.20' database=calvert schema=calvert 
                 dimension=yes port=2406;
*/

PROC FORMAT;
 VALUE sl_width
   LOW  -< 1000  = '< 1000'
   1000 -< 1100  = '1000-1100'
   1100 -< 1200  = '1100-1200'
   1200 -< 1300  = '1200-1300'
   1300 -< 1400  = '1300-1400'
   1400 -< 1500  = '1400-1500'
   1500 -< 1600  = '1500-1600'
   1600 -< 1700  = '1600-1700'
   1700 -< 1800  = '1700-1800' 
   1800 -< 1900  = '1800-1900'
   1900 -  HIGH  = '> 1900'
 ;

 VALUE sl_thick
   LOW -< 200   = '< 200'
   200 -< 210   = '200 - 210' 
   210 -< 220   = '210 - 220'
   220 -< 230   = '220 - 230'  
   230 -< 240   = '230 - 240' 
   240 -< 250   = '240 - 250'  
   250 -< 260   = '250 - 260'
   260 - HIGH   = '> 260'  
 ;

  VALUE coil_wt
    LOW -< 10   = '< 10 ton'  
     10 -< 15   = '10-15 ton'
     15 -< 20   = '15-20 ton'
     20 -< 25   = '20-25 ton'
     25 -< 30   = '25-30 ton'
     30 - HIGH  = '> 30 ton'
  
  ;
  
  VALUE cl_width
   LOW  -< 1000  = '< 1000'
   1000 -< 1100  = '1000-1100'
   1100 -< 1200  = '1100-1200'
   1200 -< 1300  = '1200-1300'
   1300 -< 1400  = '1300-1400'
   1400 -< 1500  = '1400-1500'
   1500 -< 1600  = '1500-1600'
   1600 -< 1700  = '1600-1700'
   1700 -< 1800  = '1700-1800' 
   1800 -< 1900  = '1800-1900'
   1900 -  HIGH  = '> 1900'
 ;
 
 VALUE cl_thick
   LOW -< 2.0   = '< 2 mm'
   2.0 -< 2.25  = '2-2.25 mm' 
   2.25 -< 2.5  = '2.25-2.5 mm'
   2.5 -< 2.73  = '2.5-2.75 mm' 
   2.75 -< 3.0  = '2.75-3 mm'  
   3.0 -< 3.5   = '3-3.5 mm' 
   3.5 -< 4.0   = '3.5-4 mm'
   4.0 -< 5.0   = '4-5 mm' 
   5.0 -< 6.0   = '5-6 mm'   
   6.0 - HIGH   = '> 6 mm'  
 ; 

/*
 VALUE cl_thick (MULTILABEL)
   LOW -< 1.0   = '< 1 mm'
   1.0 -< 1.5   = '1-1.5 mm' 
   1.5 -< 1.9   = '1.5-1.9 mm'
   1.9 -< 2.1   = '1.9-2.1 mm'  
   2.1 -< 2.3   = '2.1-2.3 mm' 
   2.3 -< 2.5   = '2.3-2.5 mm'  
   2.5 -< 2.7   = '2.5-2.7 mm' 
   2.7 -< 2.9   = '2.7-2.9 mm' 
   2.9 -< 3.1   = '2.9-3.1 mm' 
   3.1 -< 3.3   = '3.1-3.3 mm' 
   3.3 -< 3.5   = '3.3-3.5 mm' 
   3.5 -< 3.7   = '3.5-3.7 mm' 
   3.7 -< 3.9   = '3.7-3.9 mm' 
   3.9 -< 4.1   = '3.9-4.1 mm' 
   4.1 -< 4.3   = '4.1-4.3 mm' 
   4.3 -< 4.5   = '4.3-4.5 mm' 
   4.5 -< 4.7   = '4.5-4.7 mm' 
   4.7 -< 4.9   = '4.7-4.9 mm' 
   4.9 -< 5.1   = '4.9-5.1 mm' 
   5.1 - HIGH   = '> 5.1 mm'  
   
   LOW  -< 2.4   = '<= 2.4 mm'
   2.4  -< 3.0   = '2.4-3.0 mm'
   3.0  -< 3.7   = '3.0-3.7 mm'
   3.7  - HIGH   = '>= 3.7 mm'
 ; 
*/

 VALUE $slb_suppl
   'N'        = 'N-Brazil-CSA'         /* ThyssenKrupp CSA */
   'T'        = 'T-Brazil-AMT'         /* ArcelorMittal Tubarao */
   'L'        = 'L-Mexico-AMM'         /* ArcelorMittal Lazaro Cardenas */  
   '2'        = '2-USA-IH_Meltshop_2'  /* ArcelorMittal Indiana Harbor */
   '3'        = '3-USA-IH_Meltshop_3'  /* ArcelorMittal Indiana Harbor */
   '4'        = '4-USA-IH_Meltshop_4'  /* ArcelorMittal Indiana Harbor */
   'C'        = 'C-USA-Cleveland'      /* ArcelorMittal Cleveland */ 
   'B'        = 'C-USA-Burns_Harbor'   /* ArcelorMittal Burns Harbor */
   'R'        = 'R-Russia-NLMK'        /* NLMK Russia */ 
   'Y'        = 'Y-Others'             /* Remainder of old Y/N meaning of FOREIGN_MATERIAL_INDEX */
   'X'        = 'X-Mexico-AMM_Conversion'  /* ArcelorMittal Lazaro Cardenas (Toll Processing) */
   'M'        = 'M-Claims_Yoll_Processing' /* There are no Slabs Showing 'M' – Claims Toll Processing) */
   '1'        = 'Outokumpu_Stainless' /* (null: all Slab IDs start with 108) */
   ' '        = 'Outokumpu_Stainless' /* (null: all Slab IDs start with 108) */
    OTHER      = 'Other' 
; 

 VALUE carbon
   0.20 -< 0.21   = '0.20-0.21'
   0.21 -< 0.22   = '0.21-0.22' 
   0.22 -< 0.23   = '0.22-0.23' 
   0.23 -< 0.24   = '0.23-0.24' 
   0.24 -< 0.25   = '0.24-0.25' 
   0.25 -< 0.26   = '0.25-0.26' 
   0.26 -< 0.27   = '0.26-0.27' 
   0.27 - HIGH    = 'Over 0.27'
;

 VALUE mang
   1.05 -< 1.10   = '1.05-1.10'
   1.10 -< 1.15   = '1.10-1.15'
   1.15 -< 1.20   = '1.15-1.20' 
   1.20 -< 1.25   = '1.20-1.25' 
   1.25 -< 1.30   = '1.25-1.30' 
   1.30 -< 1.35   = '1.30-1.35' 
   1.35 -< 1.40   = '1.35-1.40' 
   1.40 -< 1.45   = '1.40-1.45' 
   1.45 - HIGH    = 'Over 1.45'
;

 VALUE silicon
   0.15 -< 0.17   = '0.15-0.17'
   0.17 -< 0.19   = '0.17-0.19' 
   0.19 -< 0.21   = '0.19-0.21' 
   0.21 -< 0.23   = '0.21-0.23' 
   0.23 -< 0.25   = '0.23-0.25' 
   0.25 -< 0.27   = '0.25-0.27' 
   0.27 -< 0.29   = '0.27-0.29' 
   0.29 -< 0.31   = '0.29-0.31' 
   0.31 - HIGH    = 'Over 0.31'
;

 VALUE nicel
   0    -< 0.01   = '0-0.01'
   0.01 -< 0.02   = '0.01-0.02' 
   0.02 -< 0.03   = '0.02-0.03' 
   0.03 -< 0.04   = '0.03-0.04' 
   0.04 -< 0.05   = '0.04-0.05' 
   0.05 -< 0.06   = '0.05-0.06' 
   0.06 - HIGH    = 'Over 0.06'
;

 VALUE chromium
   0.10 -< 0.15   = '0.10-0.15'
   0.15 -< 0.20   = '0.15-0.20' 
   0.20 -< 0.25   = '0.20-0.25' 
   0.25 -< 0.30   = '0.25-0.30' 
   0.30 - HIGH    = 'Over 0.30'
;

 VALUE zinc
   0     -< 0.001  = '0-0.001'
   0.001 -< 0.002  = '0.001-0.002' 
   0.002 -< 0.003  = '0.002-0.003' 
   0.003 - HIGH    = 'Over 0.003'
;

 VALUE titanum
   0.01 -< 0.02  = '0.01-0.02'
   0.02 -< 0.03  = '0.02-0.03'
   0.03 -< 0.04  = '0.03-0.04' 
   0.04 -< 0.05  = '0.04-0.05' 
   0.05 - HIGH   = 'Over 0.05'
;

 VALUE sulfur
   0     -< 0.001  = '0-0.001'
   0.001 -< 0.002  = '0.001-0.002' 
   0.002 -< 0.003  = '0.002-0.003' 
   0.003 -< 0.004  = '0.003-0.004' 
   0.004 -< 0.005  = '0.004-0.005' 
   0.005 -< 0.006  = '0.005-0.006' 
   0.006 - HIGH    = 'Over 0.006'
;

 VALUE nitrogen
   0     -< 0.001  = '0-0.001'
   0.001 -< 0.002  = '0.001-0.002' 
   0.002 -< 0.003  = '0.002-0.003' 
   0.003 -< 0.004  = '0.003-0.004' 
   0.004 -< 0.005  = '0.004-0.005' 
   0.005 -< 0.006  = '0.005-0.006' 
   0.006 -< 0.007  = '0.006-0.007' 
   0.007 -< 0.008  = '0.007-0.008' 
   0.008 - HIGH    = 'Over 0.008'
;

 VALUE coil_od
   1000  -< 1100   = '1000-1100'
   1100  -< 1200   = '1100-1200' 
   1200  -< 1300   = '1200-1300'    
   1300  -< 1400   = '1300-1400' 
   1400  -< 1500   = '1400-1500' 
   1500  -< 1600   = '1500-1600' 
   1600  -< 1700   = '1600-1700' 
   1700  -< 1800   = '1700-1800' 
   1800  -< 1900   = '1800-1900' 
   1900  -< 2000   = '1900-2000' 
   2000 - HIGH     = 'Over 2000'
;

 VALUE tension
   0  -< 5   = '0-5'
   5  -< 10  = '5-10' 
   10 -< 15  = '10-15'    
   15 -< 20  = '15-20' 
   20 -< 25  = '20-25' 
   25 -< 30  = '25-30' 
   30 -< 35  = '30-35' 
   35 -< 40  = '35-40' 
   45 -< 50  = '45-50' 
   55 -< 60  = '55-60' 
   65 -< 70  = '65-70' 
   70 -< 75  = '70-75' 
   75 -< 80  = '75-80' 
   80 - HIGH = 'Over 80'
;
run;


/* *** JOIN Tables FROM calvert.mes_material materials
                     INNER JOIN calvert.lpiece lpiece 
                      on lpiece.id_coil = materials.coil_id 
*** */

/* *** Start Macro: %MACRO coil_loc *** */
/* *** Start Macro: %MACRO coil_loc *** */
/* *** Start Macro: %MACRO coil_loc *** */
/*********************************************************/
/* This macro Pulls Data from the Calvert HSM Tables and */
/* Creates AK_3CB2021_CoilLocation Tables                */
/*********************************************************/

%MACRO coil_loc(coil_loc,loc_name);

/* CONNECT TO ASTER (USER=ak186133 PASSWORD=ak186133 DATABASE='10.25.98.20'
                  SERVER='10.25.98.13' DATABASE=calvert PORT=2406);  */
OPTIONS OBS=MAX;
PROC SQL;
CONNECT TO ASTER (USER=ak186133 PASSWORD=ak186133 /* DATABASE='10.25.98.13'*/
                  SERVER='10.25.98.20' DATABASE=calvert PORT=2406);
CREATE TABLE mat_piece as 
SELECT * FROM CONNECTION TO ASTER 
 (SELECT 
 /* *** Adding Information from the calvert.mes_material Table *** */
 /* *** !!! Table contains Multiple Records per SLAB !!! Check with Calvert Why?? *** */
	 materials.internal_steelgrade_head as mt_internal_steelgrade_head, 
	 materials.id                 as mt_id, 
	 materials.coil_id            as mt_coil_id,
	 materials.material_class     as mt_material_class, 
	 materials.rio_code           as mt_rio_code, 
	 materials.product_class      as mt_product_class, 
	 materials.product_group      as mt_product_group,
	 materials.flag_stainless     as mt_flag_stainless, 

	 materials.foreign_id          as mt_foreign_id,
	 materials.time_stamp          as mt_time_stamp,
	 materials.slab_weight/1000    as mt_slab_weight_mt, 
	 materials.slab_thickness_head as mt_slab_thickness_head,
	 materials.slab_width_head     as mt_slab_width_head, 
	 materials.slab_length         as mt_slab_slab_length,
	 materials.carbon              as mt_carbon,
	 materials.manganese           as mt_manganese, 
	 materials.silicon             as mt_silicon, 
	 materials.chromium            as mt_chromium, 
	 materials.nickel              as mt_nickel, 
	 materials.zinc                as mt_zinc, 
	 materials.titanium            as mt_titanium, 
	 materials.vanadium            as mt_vanadium, 
	 materials.sulphur             as mt_sulphur, 
	 materials.phosphorous         as mt_phosphorous, 
	 materials.nitrogen            as mt_nitrogen,

/* *** Adding Information from the calvert.lpiece Table *** */
	 lpiece.time_stamp_rm_start    as pc_time_rm_start,
	 lpiece.no_id_alloy            as pc_no_id_alloy, 
	 lpiece.id_piece               as pc_id_piece,
	 lpiece.id_coil                as pc_id_coil,
	 lpiece.flag_slab_rejected     as pc_flag_slab_rejected,
	 lpiece.meltcode               as pc_meltcode,
	 lpiece.product_class          as pc_product_class,
	 lpiece.pdi_wght_coil/1000     as pc_pdi_wght_coil_mt,
	 lpiece.val_wght_coil/1000     as pc_val_wght_coil_mt,
	 lpiece.pdi_thick_strip_cold   as pc_strip_thickness,
	 lpiece.pdi_width_strip_cold   as pc_strip_width,
	 lpiece.id_furn                as pc_id_furnace,
	 lpiece.id_dc                  as pc_id_dc,
	 lpiece.csc_strategy_used      as pc_csc_strategy, 
        
	lpiece.cont_al          as pc_cont_al,
	lpiece.cont_al_s        as pc_cont_al_s, 
	lpiece.cont_al_total    as pc_cont_al_total,
	lpiece.cont_as		    as pc_cont_as,
	lpiece.cont_b		    as pc_cont_b,
	lpiece.cont_bi		    as pc_cont_bi,
	lpiece.cont_c		    as pc_cont_c,
	lpiece.cont_ca		    as pc_cont_ca,
	lpiece.cont_ce		    as pc_cont_ce,
	lpiece.cont_co		    as pc_cont_co,
	lpiece.cont_cr		    as pc_cont_cr,
	lpiece.cont_cr_ni_cu    as pc_cont_cr_ni_cu,
	lpiece.cont_cu		    as pc_cont_cu,
	lpiece.cont_fe		    as pc_cont_fe,
	lpiece.cont_h		    as pc_cont_h,
	lpiece.cont_mg		    as pc_cont_mg,
	lpiece.cont_si		    as pc_cont_si,
	lpiece.cont_mn		    as pc_cont_mn,
	lpiece.cont_mn_s	    as pc_cont_mn_s,
	lpiece.cont_mn_si       as pc_cont_mn_si,
	lpiece.cont_mo		    as pc_cont_mo,
	lpiece.cont_n		    as pc_cont_n,
	lpiece.cont_nb		    as pc_cont_nb,
	lpiece.cont_ni		    as pc_cont_ni,
	lpiece.cont_o		    as pc_cont_o,
	lpiece.cont_p		    as pc_cont_p,
	lpiece.cont_pb		    as pc_cont_pb,
	lpiece.cont_s		    as pc_cont_s,
	lpiece.cont_sb		    as pc_cont_sb,
	lpiece.cont_se		    as pc_cont_se,
	lpiece.cont_sn		    as pc_cont_sn,
	lpiece.cont_te		    as pc_cont_te,
	lpiece.cont_ti		    as pc_cont_ti,
	lpiece.cont_v		    as pc_cont_v,
	lpiece.cont_w		    as pc_cont_w,
	lpiece.cont_zn		    as pc_cont_zn,
	lpiece.cont_zr		    as pc_cont_zr,

/* *** lpiece Columns, added 2/7/2017 *** */
	lpiece.class_material		as pc_class_material,
	lpiece.code_plant_successive    as pc_code_plant_successive,
	lpiece.furn_len_slab_cold	as pc_furn_len_slab_cold,
	lpiece.furn_pred_temp_disch	as pc_furn_pred_temp_disch,
	lpiece.furn_thick_slab_cold	as pc_furn_thick_slab_cold,
	lpiece.furn_width_slab_cold	as pc_furn_width_slab_cold,
	lpiece.val_wght_coil		as pc_val_wght_coil,
	lpiece.group_product		as pc_group_product,
	lpiece.id_caster            as pc_id_caster,
	lpiece.id_foreign           as pc_id_foreign,  

	lpiece.id_furn              as pc_id_furn,
	lpiece.id_piece_pre         as pc_id_piece_pre,
	lpiece.id_row_furn          as pc_id_row_furn,
	lpiece.id_setup_rm_used		as pc_id_setup_rm_used,
	lpiece.id_setup_used_fm		as pc_id_setup_used_fm,
	lpiece.id_setup_used_pass1_r1	as pc_id_setup_used_pass1_r1,
	lpiece.id_setup_used_pass1_r2	as pc_id_setup_used_pass1_r2,
	lpiece.id_setup_used_pass2_r1	as pc_id_setup_used_pass2_r1,
	lpiece.id_setup_used_pass2_r2	as pc_id_setup_used_pass2_r2,
	lpiece.id_setup_used_pass3_r1	as pc_id_setup_used_pass3_r1,
	lpiece.id_setup_used_pass3_r2	as pc_id_setup_used_pass3_r2,
	lpiece.id_setup_used_pass4_r1	as pc_id_setup_used_pass4_r1,
	lpiece.id_setup_used_pass4_r2	as pc_id_setup_used_pass4_r2,
	lpiece.id_setup_used_pass5_r1	as pc_id_setup_used_pass5_r1,
	lpiece.id_setup_used_pass5_r2	as pc_id_setup_used_pass5_r2,
	lpiece.id_setup_used_pass6_r1	as pc_id_setup_used_pass6_r1,
	lpiece.id_setup_used_pass6_r2	as pc_id_setup_used_pass6_r2,
	lpiece.id_setup_used_pass7_r1	as pc_id_setup_used_pass7_r1,
	lpiece.id_setup_used_pass7_r2	as pc_id_setup_used_pass7_r2,
	lpiece.id_setup_used_pass8_r1	as pc_id_setup_used_pass8_r1,
	lpiece.id_setup_used_pass8_r2	as pc_id_setup_used_pass8_r2,
	lpiece.id_setup_used_pass9_r1	as pc_id_setup_used_pass9_r1,
	lpiece.id_setup_used_pass9_r2	as pc_id_setup_used_pass9_r2,
	lpiece.id_setup_used_ssp	as pc_id_setup_used_ssp,
	lpiece.id_shift_chrg		as pc_id_shift_chrg,
	lpiece.id_shift_disch		as pc_id_shift_disch,
	lpiece.id_shift_fin         as pc_id_shift_fin,
	lpiece.id_sys_fm_used		as pc_id_sys_fm_used,
	lpiece.id_sys_rm_used		as pc_id_sys_rm_used,
	lpiece.internal_order_grade	as pc_internal_order_grade,
	
	lpiece.pdi_dia_meter_in_side_coil   as pc_pdi_dia_meter_in_side_coil,
	lpiece.pdi_dia_meter_out_side_coil  as pc_pdi_dia_meter_out_side_coil,
	lpiece.pred_dia_meter_in_side_coil  as pc_pred_dia_meter_in_side_coil,
	lpiece.pred_dia_meter_out_side_coil as pc_pred_dia_meter_out_side_coil,
	lpiece.meas_dia_meter_in_side_coil  as pc_meas_dia_meter_in_side_coil,
	lpiece.meas_dia_meter_out_side_coil as pc_meas_dia_meter_out_side_coil,
	lpiece.meas_wght_coil		    as pc_meas_wght_coil,
	lpiece.meas_wght_crop		    as pc_meas_wght_crop,
	lpiece.meas_width_coil		    as pc_meas_width_coil,
	
	lpiece.mode_rolling             as pc_mode_rolling,
	lpiece.mode_transport		    as pc_mode_transport,
	lpiece.no_work_instr		    as pc_no_work_instr,
	lpiece.pdi_temp_coil		    as pc_pdi_temp_coil,
	
/* *** Added SetUP PDI Slab & Coil Parameters 20170223 *** */	
	lpiece.pdi_temp_furn_disch	    as pc_pdi_temp_furn_disch,
	lpiece.pdi_thick_slab_cold	    as pc_pdi_thick_slab_cold,
	lpiece.pdi_width_slab_cold      as pc_pdi_width_slab_cold,
	lpiece.pdi_wght_slab		    as pc_pdi_wght_slab,
	
	lpiece.pdi_temp_strip		    as pc_pdi_temp_strip,
	lpiece.pdi_thick_strip_cold	    as pc_pdi_thick_strip_cold,
	lpiece.pdi_width_strip_cold	    as pc_pdi_width_strip_cold,
	lpiece.pdi_wght_coil		    as pc_pdi_wght_coil,
	
	lpiece.pred_wght_coil		    as pc_pred_wght_coil,
	lpiece.status_heatcover		    as pc_status_heatcover,
	lpiece.steel_grade              as pc_steel_grade,
	lpiece.steel_grp                as pc_steel_grp,
	lpiece.temp_entry_f1		    as pc_temp_entry_f1,
	lpiece.time_stamp               as pc_time_stamp,
	lpiece.time_stamp_adp_psc_fm    as pc_time_stamp_adp_psc_fm,
	lpiece.time_stamp_chrg		    as pc_time_stamp_chrg,
	lpiece.time_stamp_disch		    as pc_time_stamp_disch,
	lpiece.time_stamp_drop_out_fm       as pc_time_stamp_drop_out_fm,
	lpiece.time_stamp_drop_out_r1_last  as pc_time_stamp_drop_out_r1_last,
	lpiece.time_stamp_drop_out_r2_last  as pc_time_stamp_drop_out_r2_last,
	lpiece.time_stamp_fin		    as pc_time_stamp_fin,
	lpiece.time_stamp_log_rep	    as pc_time_stamp_log_rep,
	lpiece.time_stamp_pick_fm	    as pc_time_stamp_pick_fm,
	lpiece.time_stamp_pick_r1_first as pc_time_stamp_pick_r1_first,
	lpiece.time_stamp_pick_r2_first as pc_time_stamp_pick_r2_first,
	lpiece.time_stamp_rep_coil	    as pc_time_stamp_rep_coil,
	lpiece.time_stamp_rm_fin	    as pc_time_stamp_rm_fin,
	lpiece.time_stamp_rm_start	    as pc_time_stamp_rm_start,

/* *** LPIECE Data Added 20170220 After Trip to Calvert *** */
	lpiece.casting_process   as lpiece_casting_process,     
	lpiece.csc_strategy_used as lpiece_csc_strategy_used,
	lpiece.deoxidization	 as lpiece_deoxidization,
	lpiece.furn_len_slab_hot as lpiece_furn_len_slab_hot,
	lpiece.id_row_furn       as lpiece_id_row_furn,
	lpiece.id_caster         as lpiece_id_caster,
	lpiece.no_sched          as lpiece_no_sched,
	lpiece.no_seq            as lpiece_no_seq,

	lpiece.pos_furn          as lpiece_pos_furn,
	lpiece.pred_dia_meter_in_side_coil  as pc_pred_dia_meter_in_side_coil,
	lpiece.pred_dia_meter_out_side_coil as pc_pred_dia_meter_out_side_coil,
	lpiece.pred_wght_coil	as lpiece_pred_wght_coil,
	lpiece.prod_order_no	as lpiece_prod_order_no,
	lpiece.product_class	as lpiece_product_class,
	lpiece.round            as lpiece_round,
	lpiece.sequence_no      as lpiece_sequence_no,

/* *** Furnace mes_measurementdata Added 20170220 *** */ 
	mes_meas.fcenum       as mes_meas_fcenum,
	mes_meas.coil_id      as mes_meas_coil_id,
	mes_meas.dchgtime	  as mes_meas_dchgtime,
	mes_meas.chgtime	  as mes_meas_chgtime,
	mes_meas.length		  as mes_meas_length,
	mes_meas.thickness	  as mes_meas_thickness,
	mes_meas.width		  as mes_meas_width,
	mes_meas.weight		  as mes_meas_weight,

	mes_meas.rowpos		  as mes_meas_rowpos,
	mes_meas.heatprac	  as mes_meas_heatprac,
	mes_meas.grade		  as mes_meas_grade,
	mes_meas.steelcode	  as mes_meas_steelcode,
	mes_meas.totaltimefce as mes_meas_totaltimefce,
	mes_meas.chgtemp      as mes_meas_chtemp, 
	mes_meas.tgtdchtemp   as mes_meas_tgtdchtemp,
	mes_meas.actdchtemp	  as mes_meas_actdchtemp,
	mes_meas.slabgapmillside  as mes_meas_slabgapmillside, 


/* *** Roughing Mill Intermediate Rolled Piece Profile calvert.lstat_pfg *** */
	lstat_pfg.id_piece       as lstat_pfg_id_piece,
	lstat_pfg.id_segment	 as lstat_pfg_id_segment,

	lstat_pfg.trg_thick_hot	 as lstat_pfg_trg_thick_hot,
	lstat_pfg.trg_width_hot  as lstat_pfg_trg_width_hot,
	lstat_pfg.trg_temp       as lstat_pfg_trg_temp,

	lstat_pfg.thick_cold	 as lstat_pfg_thick_cold,
	lstat_pfg.thick_hot      as lstat_pfg_thick_hot,
	lstat_pfg.thick_hot_min  as lstat_pfg_thick_hot_min,
	lstat_pfg.thick_hot_max	 as lstat_pfg_thick_hot_max,
	lstat_pfg.thick_hot_std	 as lstat_pfg_thick_hot_std,
	lstat_pfg.limit_thick_hot_up  as lstat_pfg_limit_thick_hot_up,
	lstat_pfg.limit_thick_hot_low as lstat_pfg_limit_thick_hot_low,

	lstat_pfg.width_hot      as lstat_pfg_width_hot,
	lstat_pfg.width_hot_min	 as lstat_pfg_width_hot_min,
	lstat_pfg.width_hot_max	 as lstat_pfg_width_hot_max,
	lstat_pfg.width_hot_std	 as lstat_pfg_width_hot_std,
	lstat_pfg.limit_width_hot_up  as lstat_pfg_limit_width_hot_up,
	lstat_pfg.limit_width_hot_low as lstat_pfg_limit_width_hot_low,

	lstat_pfg.dev_cl         as lstat_pfg_dev_cl,
	lstat_pfg.dev_cl_min	 as lstat_pfg_dev_cl_min,
	lstat_pfg.dev_cl_max	 as lstat_pfg_dev_cl_max,
	lstat_pfg.dev_cl_std	 as lstat_pfg_dev_cl_std,

	lstat_pfg.temp		 as lstat_pfg_temp,
	lstat_pfg.temp_min	 as lstat_pfg_temp_min,
	lstat_pfg.temp_max	 as lstat_pfg_temp_max,
	lstat_pfg.temp_std	 as lstat_pfg_temp_std,
	lstat_pfg.limit_temp_up	 as lstat_pfg_limit_temp_up,
	lstat_pfg.limit_temp_low as lstat_pfg_limit_temp_low,
	lstat_pfg.time_stamp     as lstat_pfg_time_stamp,

/* *** Adding Information from the calvert.lstat_exit_fm Table 
	   (Temperature, Center Line Deviation, Thickness 
*** */
	lst_exit_fm.id_piece    as lst_exit_fm_id_piece,      
	lst_exit_fm.id_segment	as lst_exit_fm_id_segment,

	lst_exit_fm.thick_hot	as lst_exit_fm_thick_hot,
	lst_exit_fm.dev_cl	    as lst_exit_fm_dev_cl,
	lst_exit_fm.dev_cl_min	as lst_exit_fm_dev_cl_min,
	lst_exit_fm.dev_cl_max	as lst_exit_fm_dev_cl_max,
	lst_exit_fm.dev_cl_std	as lst_exit_fm_dev_cl_std,
	lst_exit_fm.width_hot	as lst_exit_fm_width_hot,

	lst_exit_fm.trg_temp	as lst_exit_fm_trg_temp,
	lst_exit_fm.temp	    as lst_exit_fm_temp,
	lst_exit_fm.temp_min	as lst_exit_fm_temp_min,
	lst_exit_fm.temp_max	as lst_exit_fm_temp_max,
	lst_exit_fm.temp_std	as lst_exit_fm_temp_std,
	lst_exit_fm.limit_temp_up  as lst_exit_fm_limit_temp_up,
	lst_exit_fm.limit_temp_low as lst_exit_fm_limit_temp_low,

/* *** Laminar Cooling lsetup_csc !!! JOIN lsetup_csc.id_setup on lpiece.id_setup_used_fm !!! *** */
	lsetup_csc.id_piece     as lsetup_csc_id_piece,
	lsetup_csc.id_setup     as lsetup_csc_id_setup,
	lsetup_csc.width        as lsetup_csc_width,
	lsetup_csc.thickness    as lsetup_csc_thickness,
	lsetup_csc.fm_exit_temp	as lsetup_csc_fm_exit_temp,
	lsetup_csc.time_stamp   as lsetup_csc_time_stamp, 
    lsetup_csc.des_rotc_cool_strategy as lsetup_csc_cool_strategy,

/* *** Down Coiler  lsetup_dc !!! JOIN lsetup_csc.id_setup on lpiece.id_setup_used_fm !!! *** */
	lsetup_dc.id_piece             as lstp_dc_id_piece,
	lsetup_dc.id_setup             as lstp_dc_id_setup,      
	lsetup_dc.temp_coil            as lstp_dc_temp_coil,
	lsetup_dc.width_strip          as lstp_dc_width_strip,
	lsetup_dc.thick_strip	       as lstp_dc_thick_strip,
	lsetup_dc.point_yield_hot      as lstp_dc_point_yield_hot,
	lsetup_dc.tension_spec	       as lstp_dc_tension_spec,

	lsetup_dc.temp_strip_exit      as lstp_dc_temp_strip_exit,
	lsetup_dc.len_strip            as lstp_dc_len_strip,

	lsetup_dc.dia_coil             as lstp_dc_dia_coil,
	lsetup_dc.width_coil	       as lstp_dc_width_coil,
	lsetup_dc.wght_coil            as lstp_dc_wght_coil,

	lsetup_dc.nom_strength_yield   as lstp_dc_nom_strength_yield,
	lsetup_dc.trg_temp_coil	       as lstp_dc_trg_temp_coil,

	lsetup_dc.op_corr_gap_sg       as lstp_dc_op_corr_gap_sg,
	lsetup_dc.op_corr_gap_prds     as lstp_dc_op_corr_gap_prds,
	lsetup_dc.op_corr_gap_pros     as lstp_dc_op_corr_gap_pros,
	lsetup_dc.op_corr_gap_wr1      as lstp_dc_op_corr_gap_wr1,
	lsetup_dc.op_corr_gap_wr2      as lstp_dc_op_corr_gap_wr2,
	lsetup_dc.op_corr_gap_wr3      as lstp_dc_op_corr_gap_wr3,
	lsetup_dc.op_corr_force_sg     as lstp_dc_op_corr_force_sg,
	lsetup_dc.op_corr_force_prds   as lstp_dc_op_corr_force_prds,
	lsetup_dc.op_corr_force_pros   as lstp_dc_op_corr_force_pros,
	lsetup_dc.op_corr_force_wr1    as lstp_dc_op_corr_force_wr1,
	lsetup_dc.op_corr_force_wr2    as lstp_dc_op_corr_force_wr2,
	lsetup_dc.op_corr_force_wr3    as lstp_dc_op_corr_force_wr3,
	lsetup_dc.op_corr_mandrel_tension   as lstp_dc_op_corr_mandrel_tension,
	lsetup_dc.op_corr_mandrel_exp_press as lstdc_op_corr_mandrel_exp_press,
	lsetup_dc.op_corr_strip_car_press   as lstp_dc_op_corr_strip_car_press,

/* *** Adding Information from the calvert.lstat_width_dc Table *** */
	lstat_width.id_piece       as lstat_width_id_piece,
	lstat_width.id_segment     as lstat_width_id_segment,
	lstat_width.time_stamp     as lstat_width_time_stamp,
	lstat_width.temp           as lstat_width_temp,
	lstat_width.dev_cl         as lstat_width_dev_cl, 
	lstat_width.width_hot      as lstat_width_width_hot,
	
	lstat_width.width_cold     as lstat_width_width_cold,
	lstat_width.width_cold_min as lstat_width_width_cold_min,
	lstat_width.width_cold_max as lstat_width_width_cold_max,
	lstat_width.width_cold_std as lstat_width_width_cold_std,

/* *** Adding Information from the calvert.lstat_temp_coiler Table *** */
	lstat_temp_dc.id_piece      as lstat_temp_dc_id_piece,
	lstat_temp_dc.id_segment    as lstat_temp_dc_id_segment,      /* (Values: T;O;B;H;); */
	lstat_temp_dc.temp          as lstat_temp_dc_temp,
	lstat_temp_dc.temp_min	    as lstat_temp_dc_temp_min,
	lstat_temp_dc.temp_max	    as lstat_temp_dc_temp_max,
	lstat_temp_dc.temp_std	    as lstat_temp_dc_temp_std,
	lstat_temp_dc.limit_temp_up as lstat_temp_dc_limit_temp_up,
	lstat_temp_dc.limit_temp_low            as lstat_temp_dc_limit_temp_low,
	lstat_temp_dc.count_temp_exc_limit_up	as lstat_temp_dc_exc_limit_up,
	lstat_temp_dc.count_temp_exc_limit_low	as lstat_temp_dc_exc_limit_low,
	lstat_temp_dc.count_temp_in_limit       as lst_temp_dc_count_temp_in_limit,
	lstat_temp_dc.time_stamp        as lstat_temp_dc_time_stamp,
	lstat_temp_dc.min_no_segment	as lstat_temp_dc_min_no_segment,
	lstat_temp_dc.max_no_segment	as lstat_temp_dc_max_no_segment,
	lstat_temp_dc.count_meas        as lstat_temp_dc_count_meas,
	lstat_temp_dc.trg_temp          as lstat_temp_dc_trg_temp,
	lstat_temp_dc.temp_scanner      as lstat_temp_dc_temp_scanner,
	lstat_temp_dc.temp_scanner_std	as lstat_temp_dc_temp_scanner_std,
	lstat_temp_dc.temp_bot_low      as lstat_temp_dc_temp_bot_low,
	lstat_temp_dc.temp_bot_low_std	as lstat_temp_dc_temp_bot_low_std,
	lstat_temp_dc.temp_bot_high     as lstat_temp_dc_temp_bot_high,
	lstat_temp_dc.temp_bot_high_std	as lstat_temp_dc_temp_bot_high_std,
	%str(%'&coil_loc%'||'-'||%'&loc_name%')   as coil_location,
	shift.time_stamp_shift,
	shift.chrg_shift,
	shift.disch_shift,
	shift.fin_shift,
	shift.shift_part
        suppl.supply_code,
        suppl.supplier,
        suppl.comment
	
  FROM calvert.mes_material materials
   INNER JOIN calvert.lpiece lpiece 
    on lpiece.id_coil = materials.coil_id
     LEFT OUTER JOIN calvert.mes_measurementdata  mes_meas
       on mes_meas.coil_id = lpiece.id_coil

       LEFT OUTER JOIN calvert.lstat_pfg lstat_pfg
         on lstat_pfg.id_piece = lpiece.id_coil
        and lstat_pfg.id_segment = %str(%'&coil_loc%') 

        LEFT OUTER JOIN calvert.lstat_exit_fm lst_exit_fm
          on lst_exit_fm.id_piece = lpiece.id_coil
         and lst_exit_fm.id_segment = %str(%'&coil_loc%')

          LEFT OUTER JOIN calvert.lsetup_csc lsetup_csc
            on lsetup_csc.id_piece = lpiece.id_coil
           and lsetup_csc.id_setup = lpiece.id_setup_used_fm 

            LEFT OUTER JOIN calvert.lsetup_dc lsetup_dc
              on lsetup_dc.id_piece = lpiece.id_coil
             and lsetup_dc.id_setup = lpiece.id_setup_used_fm 

              LEFT OUTER JOIN calvert.lstat_width_dc lstat_width
                  on lstat_width.id_piece = lpiece.id_coil
	         and lstat_width.id_segment = %str(%'&coil_loc%')
                LEFT OUTER JOIN calvert.lstat_temp_coiler lstat_temp_dc
                   on lstat_temp_dc.id_piece = lpiece.id_coil
	          and lstat_temp_dc.id_segment = %str(%'&coil_loc%')
	          
	           LEFT OUTER JOIN calvert.shifts shift  
	            on shift.id_piece = lpiece.id_coil 
	           
                     LEFT OUTER JOIN calvert.slab_supplier suppl  
                      on suppl.supply_code = SUBSTR(lpiece.id_foreign,1,1) 

  WHERE materials.internal_steelgrade_head LIKE '%3CB2%'
 /*   and materials.coil_id = '1157346070'  */
  ORDER BY lpiece.id_coil, lpiece.time_stamp_pick_fm
);

DISCONNECT FROM ASTER;
QUIT;


/* *** As suggected 2/3/2017 Calvert Meeting we need to use Last chronological record from the mes_material Table *** */
DATA de_dup_slabs;
 SET mat_piece;
LENGTH slab_supplier $30.;
   BY pc_id_coil;
    IF last.pc_id_coil; 

slab_supplier = PUT(SUBSTR(pc_id_foreign,1,1),$slb_suppl.); 
run;



/* *** Pull Data FROM calvert.jrs_coil_reprocess_reject Table *** */
PROC SQL;
CONNECT TO ASTER (USER=ak186133 PASSWORD=ak186133
                  SERVER='10.25.98.20' DATABASE=calvert PORT=2406);      /* SERVER='10.25.98.13' */
CREATE TABLE squaty_coils as 
SELECT * FROM CONNECTION TO ASTER 
 (SELECT DISTINCT
	rjrp.charged_coil        as rjrp_charged_coil,  
	rjrp.hsm_piece_no        as rjrp_hsm_piece_no,   
	rjrp.piece_no            as rjrp_piece_no,
	rjrp.slab_number         as rjrp_slab_number, 
	rjrp.production_date     as rjrp_production_date, 
	rjrp.timestamp_rework    as rjrp_timestamp_rework,
	rjrp.melt_source         as rjrp_melt_source,
	rjrp.product_group       as rjrp_product_group,
	rjrp.heat_number         as rjrp_heat_number,  
	rjrp.steel_grade         as rjrp_steel_grade,  
	rjrp.thickness           as rjrp_thickness, 
	rjrp.width               as rjrp_width, 
	rjrp.weight_in_mt::numeric as rjrp_weight_mt,
	rjrp.originating_unit    as rjrp_originating_unit,
	rjrp.reporting_unit      as rjrp_reporting_unit,
	rjrp.decision_type       as rjrp_decision_type,
	rjrp.defect_code         as rjrp_defect_code, 
	rjrp.defect_code_text    as rjrp_defect_code_text,

	rjrp.defect_group        as rjrp_defect_group,
	rjrp.defect_group_text   as rjrp_defect_group_text, 
	rjrp.defect_details      as rjrp_defect_details,
	rjrp.decision_user       as rjrp_decision_user,
	rjrp.decision_user_name  as rjrp_decision_user_name,

/* *** ADD Defects (Rejects / Reprocessing) flag from the EXCEL Spreadsheets & calvert.jrs_coil_reprocess_reject *** */
	 CASE WHEN rjrp.defect_code = '508' THEN 'Squatty Coils'
	       ELSE 'Non-Squatty Coils'
	 END                 as Squatty_Coil_Flag,
	 CASE WHEN rjrp.defect_code = '508' THEN 1
	       ELSE 0
	 END                 as Squatty_Coil_Code

  FROM calvert.jrs_coil_reprocess_reject rjrp
  WHERE rjrp.defect_code = '508'
 /*   and rjrp.steel_grade LIKE '%3CB21%'  */
    and rjrp.steel_grade LIKE '%3CB2%'
 	and rjrp.hsm_piece_no = rjrp.piece_no
 /*   and (rjrp.charged_coil = '1157346070'
     or rjrp.hsm_piece_no = '1157346070')  */
  ORDER BY rjrp.hsm_piece_no, rjrp.production_date
);

DISCONNECT FROM ASTER;
QUIT;


PROC SORT DATA=squaty_coils OUT=dedub_squatty_coils NODUPKEY; 
 BY rjrp_hsm_piece_no;
run;



/* *** Pull Pinch_Roll Average Speed *** */
PROC SQL;
CONNECT TO ASTER (USER=ak186133 PASSWORD=ak186133
                  SERVER='10.25.98.20' DATABASE=calvert PORT=2406);
CREATE TABLE pinch_rollspd as 
SELECT * FROM CONNECTION TO ASTER 
 (SELECT DISTINCT
	mcsc.id_piece,
	AVG(mcsc.speed_pinch_roll_1) as speed_pinch_roll1,
	AVG(mcsc.speed_pinch_roll_2) as speed_pinch_roll2,
	AVG(mcsc.speed_pinch_roll_3) as speed_pinch_roll3
  FROM calvert.lmeas_csc mcsc
  GROUP BY mcsc.id_piece
  ORDER BY mcsc.id_piece
);

DISCONNECT FROM ASTER;
QUIT;



/* *** calvert.lmeas_fm  lmeas_fm *** */ 
OPTIONS OBS=MAX;
PROC SQL;
CONNECT TO ASTER (USER=ak186133 PASSWORD=ak186133
                  SERVER='10.25.98.20' DATABASE=calvert PORT=2406);
CREATE TABLE lstat_fm as 
SELECT * FROM CONNECTION TO ASTER 
 (SELECT DISTINCT
	lstat_fm.id_piece         as lstat_fm_id_piece,
	lstat_fm.stand_id         as lstat_fm_stand_id,
	lstat_fm.id_segment       as lstat_fm_id_segment,
	lstat_fm.angle_looper	  as lstat_fm_angle_looper,

	lstat_fm.tension		  as lstat_fm6_tension,
	lstat_fm.angle_looper_calib	 as lstat_fm6_angle_looper_calib
  FROM calvert.lstat_fm  lstat_fm
  WHERE /* lstat_fm.id_piece = '1157346070' and */ 
        lstat_fm.stand_id IN(6)
  ORDER BY lstat_fm.id_piece
);

DISCONNECT FROM ASTER;
QUIT;


PROC TRANSPOSE DATA=lstat_fm (KEEP=lstat_fm_id_piece lstat_fm_id_segment
                                   lstat_fm6_tension)
               OUT=tlstat_fm6_tension
               PREFIX = fm6_tension;
  BY lstat_fm_id_piece; 
  ID lstat_fm_id_segment;
    VAR lstat_fm6_tension;   * lstat_fm6_angle_looper_calib;
  IDLABEL lstat_fm_id_segment;
run;


PROC TRANSPOSE DATA=lstat_fm (KEEP=lstat_fm_id_piece lstat_fm_id_segment
                                   lstat_fm6_angle_looper_calib)
               OUT=tlstat_fm6_looper
               PREFIX = fm6_looper;
  BY lstat_fm_id_piece; 
  ID lstat_fm_id_segment;
    VAR lstat_fm6_angle_looper_calib;
  IDLABEL lstat_fm_id_segment;
run;


DATA fm6_tension;
 MERGE tlstat_fm6_tension (IN=tens)
       tlstat_fm6_looper (IN=looper); 
  BY lstat_fm_id_piece;
   IF tens;
run;



/* *** Add op_corr_mandrell_tension,op_corr_mandrel_exp_press and  speed_pinch_roll1,
       speed_pinch_roll2, speed_pinch_roll3 *** */
PROC SQL;
CREATE TABLE ak_3cb2021_&loc_name as
  SELECT base.*,
	 sq_coils.*,

	lstat_fm.lstat_fm_id_piece,	
	lstat_fm.fm6_tensionH,	
	lstat_fm.fm6_tensionT,	
	lstat_fm.fm6_tensionO,	
	lstat_fm.fm6_tensionB,	
	lstat_fm.fm6_looperH,	
	lstat_fm.fm6_looperT,	
	lstat_fm.fm6_looperO,	
	lstat_fm.fm6_looperB,

	pinch_roll.speed_pinch_roll1,
	pinch_roll.speed_pinch_roll2,
	pinch_roll.speed_pinch_roll3 

  FROM de_dup_slabs base
/* *** Squatty Coils Regection Data *** */
   LEFT OUTER JOIN dedub_squatty_coils sq_coils
    on sq_coils.rjrp_hsm_piece_no = base.pc_id_coil
/* *** Finishing Mill Tension & Loopers Calibration *** */
     LEFT OUTER JOIN fm6_tension lstat_fm
      on lstat_fm.lstat_fm_id_piece = base.pc_id_coil
/* *** Pinch Rolls Speed *** */
       LEFT OUTER JOIN pinch_rollspd pinch_roll
        on pinch_roll.id_piece = base.pc_id_coil
  ORDER BY base.pc_id_coil  
;
QUIT;


/* *** Test  ak_3cb2021_&loc_name for Duplicate Records: *** */
/*
PROC SORT DATA=ak_3cb2021_&loc_name OUT=test_dedup NODUPKEY;
 BY pc_id_piece;
run;
*/

/* *** Save intermediant file 'coils_3cb2021' for analysis my_3cb21.coils_3cb2021 *** */
LIBNAME my_3cb21 "C:\Users\ak186133\Remote Calvert ASTER Project\SAS_Outputs\";

DATA my_3cb21.ak_3cb2021_&loc_name;
 SET ak_3cb2021_&loc_name;
run;


/* *** Rename 4 Variables, which Length Exceed 32 Bt. *** */
/*
DATA ak_3cb2021_&loc_name; 
 SET my_3cb21.ak_3cb2021_&loc_name (RENAME=(lpiece_pred_dia_meter_in_side_co=pc_pred_dia_meter_in_side_coil 
                                   lpiece_pred_dia_meter_out_side_c=pc_pred_dia_meter_out_side_coil
                                   lstp_dc_op_corr_mandrel_exp_pres=lstdc_op_corr_mandrel_exp_press 
                                   lstat_temp_dc_count_temp_in_limi=lst_temp_dc_count_temp_in_limit));
run;
*/

ODS LISTING;
ODS HTMLCSS BODY="C:\Users\ak186133\Remote Calvert ASTER Project\SAS_Outputs\ak_3cb2021_&loc_name._Content_&SYSDATE9..xls";

PROC CONTENTS DATA=ak_3cb2021_&loc_name VARNUM;
run;

/*
PROC FREQ DATA=ak_3cb2021_&loc_name NOHEADER ORDER=FREQ;
 TABLES slab_supplier*rjrp_decision_type*rjrp_defect_code_text
           / LIST MISSING NOCUM; * CUMCOL NOROW NOCOL NOPERCENT OUT=DataSetName;
                               * NOPRINT MISSPRINT CHISQ CROSSLIST;
FORMAT slab_width_head width. slab_thickness_head thick.;
LABEL
	internal_steelgrade_head  = 'Steel Grade'
	rjrp_melt_source          = 'Slab Supplier'
	slab_supplier             = 'Slab Supplier'
	slab_thickness_head       = 'Slab Thickness, mm'
	slab_width_head           = 'Slab Width, mm'
	rjrp_decision_type        = 'Decision Type' 
;
TITLE1 "Arcelor Mittal Calvert Steel HSM / Teradata GDC";
TITLE2 "HSM 3CB20/3CB21 Steel Grade:  508 Squatty Coils Defects Summary";
TITLE3 "Reporting Period: 2014 through 2016";
run;
*/
ODS HTMLCSS CLOSE;
ODS LISTING CLOSE;

/* *** Load Data into ASTER Table dblib.ak_3CB2021_Steel *** */
/* *** Load Data into ASTER Table dblib.ak_3CB2021_Steel *** */
LIBNAME dblib ASTER DSN=Calvert UID=ak186133 PWD=ak186133 DIMENSION=yes;

DATA dblib.ak_3CB2021_&loc_name (BULKLOAD=YES 
	                             BL_DATAFILE_PATH='C:\Temp\' 
	                             BL_HOST='10.25.98.20' 
	                             BL_PATH='C:\Remote_ASTER_Client\'
	                             BL_DBNAME='calvert'
				              /* BL_DELETE_DATAFILE=NO */
	                             DBCREATE_TABLE_OPTS='DISTRIBUTE BY HASH(pc_id_piece)'
                                );
 SET ak_3cb2021_&loc_name;
run;


/* *** EXPORT steel_3cb2021 into .csv for Paul (to Run PYTON Analytics) *** */
FILENAME csv_out "C:\Users\ak186133\Remote Calvert ASTER Project\SAS_Outputs\ak_3cb2021_&loc_name..csv";
PROC EXPORT DATA=ak_3cb2021_&loc_name
            OUTFILE=csv_out
  DBMS=csv REPLACE;
run;


%MEND coil_loc;

/* %MACRO coil_loc(coil_loc,loc_name); */
%coil_loc(O,Overall);
%coil_loc(H,Head);
%coil_loc(B,Body);
%coil_loc(T,Tail);

/* *** ENE Macro: %MACRO coil_loc *** */
/* *** ENE Macro: %MACRO coil_loc *** */
/* *** ENE Macro: %MACRO coil_loc *** */


/* *** End Section creating ASTER , SAS and .csv Data Source for Analysis *** */ 


FILENAME _ALL_ CLEAR;
ODS PHTML CLOSE;
ODS TRACE OFF;
* ENDSAS;
**** END *** END *** END *** END *** END *** END *** END ***;
**** END *** END *** END *** END *** END *** END *** END ***;



/* *** PROC MEANS (To See Variations of Parameters on Defective Squatty Coils *** */
PROC MEANS DATA=ak_3cb21_steel MISSING MEAN STD MIN MAX VAR MAXDEC=2 NOLABEL; * NOPRINT;   * N NOPRINT;
  CLASS rjrp_decision_type;
  VAR 
carbon 
manganese
silicon
chromium
nickel
zinc
titanium
vanadium
sulphur
phosphorous
nitrogen

mt_slab_weight_mt
slab_thickness_head
slab_width_head
slab_length
pc_pdi_wght_slab

pc_id_furnace
pc_furn_len_slab_cold
pc_furn_pred_temp_disch
pc_furn_thick_slab_cold
pc_furn_width_slab_cold
pc_pdi_temp_furn_disch

pc_temp_entry_f1

speed_pinch_roll1
speed_pinch_roll2
speed_pinch_roll3  

op_corr_mandrel_tension
op_corr_mandrel_exp_press

lstat_temp_dc_temp
lstat_temp_dc_min_no_segment
lstat_temp_dc_max_no_segment
lstat_temp_dc_temp_bot_high
lstat_temp_dc_temp_bot_high_std

pc_pdi_temp_coil
pc_pdi_temp_strip
lstat_temp_dc_temp

pc_meas_dia_meter_in_side_coil
pc_meas_dia_meter_out_side_coil
pc_meas_wght_coil
pc_meas_width_coil

lstat_width_width_hot
lstat_width_width_cold

pc_strip_thickness
pc_strip_width

pc_pdi_wght_coil
pc_pred_wght_coil
pc_val_wght_coil
pc_pdi_wght_coil_mt
pc_val_wght_coil_mt
pc_id_dc;
OUTPUT OUT=Steel_3CB21_sum (DROP=_TYPE_ _FREQ_)
;

run;


/* *** Correlation Analysis: *** */
PROC CORR DATA=ak_3cb21_steel;
 VAR Squatty_Coil_Code      *;  * WITH;
   WITH pc_pdi_temp_coil
		pc_pdi_temp_strip
		lstat_temp_dc_temp

		pc_meas_dia_meter_in_side_coil
		pc_meas_dia_meter_out_side_coil
		pc_meas_wght_coil
		pc_meas_width_coil

		lstat_width_width_hot
		lstat_width_width_cold

		pc_strip_thickness
		pc_strip_width

		pc_pdi_wght_coil
		pc_pred_wght_coil
		pc_val_wght_coil
		pc_pdi_wght_coil_mt
		pc_val_wght_coil_mt
		pc_id_dc;
run;

ODS GRAPHICS;
PROC CORR DATA=ak_3cb21_steel (OBS=300) PLOTS=MATRIX(histogram) PLOTS(MAXPOINTS=10000) ; 
 VAR  pc_pdi_temp_coil
	  pc_pdi_temp_strip
		pc_strip_thickness
		pc_strip_width;
run;
ODS GRAPHICS OFF;





/* The following program is found on p. 33 of        */
/* "A Step-by-Step Approach to Using the SAS System  */
/* for Factor Analysis and Structural Equation       */
/* Modeling."                                        */
PROC FACTOR   DATA=ak_3cb21_steel
              SIMPLE
              METHOD=PRIN
              PRIORS=SMC
              NFACT=2
              ROTATE=VARIMAX
              ROUND
              FLAG=.40
              OUT=D2   ;
 VAR pc_pdi_temp_coil
		pc_pdi_temp_strip
		lstat_temp_dc_temp

		pc_strip_thickness
		pc_strip_width
		pc_pred_wght_coil
		pc_val_wght_coil
		pc_id_dc;
run;











ODS LISTING;
ODS HTMLCSS BODY="C:\Users\ak186133\Remote Calvert ASTER Project\SAS_Outputs\ASTER_CALVERT_508Defect_FREQ_&SYSDATE9..xls";

PROC CONTENTS DATA=ak_3cb2021_steel VARNUM;
run;

/*
PROC FREQ DATA=ak_3cb2021_steel NOHEADER ORDER=FREQ;
 TABLES slab_supplier*rjrp_decision_type*rjrp_defect_code_text
           / LIST MISSING NOCUM; * CUMCOL NOROW NOCOL NOPERCENT OUT=DataSetName;
                               * NOPRINT MISSPRINT CHISQ CROSSLIST;
FORMAT slab_width_head width. slab_thickness_head thick.;
LABEL
	internal_steelgrade_head  = 'Steel Grade'
	rjrp_melt_source          = 'Slab Supplier'
	slab_supplier             = 'Slab Supplier'
	slab_thickness_head       = 'Slab Thickness, mm'
	slab_width_head           = 'Slab Width, mm'
	rjrp_decision_type        = 'Decision Type' 
;
TITLE1 "Arcelor Mittal Calvert Steel HSM / Teradata GDC";
TITLE2 "HSM 3CB20/3CB21 Steel Grade:  508 Squatty Coils Defects Summary";
TITLE3 "Reporting Period: 2014 through 2016";
run;
*/
ODS HTMLCSS CLOSE;
ODS LISTING CLOSE;




/* *** Start Here 2/2/2017 *** Start Here 2/2/2017 *** Start Here 2/2/2017 *** Start Here 2/2/2017 *** */
/* *** Start Here 2/2/2017 *** Start Here 2/2/2017 *** Start Here 2/2/2017 *** Start Here 2/2/2017 *** */
/* *** Start Here 2/2/2017 *** Start Here 2/2/2017 *** Start Here 2/2/2017 *** Start Here 2/2/2017 *** */



ODS CSVALL CLOSE;

FILENAME _ALL_ CLEAR;
ODS PHTML CLOSE;
ODS TRACE OFF;
* ENDSAS;
**** END *** END *** END *** END *** END *** END *** END ***;
**** END *** END *** END *** END *** END *** END *** END ***;


/*
OPTIONS OBS=2000;
PROC SQL;
CONNECT TO ASTER (USER=ak186133 PASSWORD=ak186133
                  SERVER='10.25.98.20' DATABASE=calvert PORT=2406);
CREATE TABLE lmeas_fm as 
SELECT * FROM CONNECTION TO ASTER 
 (SELECT DISTINCT
		lmeas_fm.id_piece     as lmeas_fm_id_piece,
		lmeas_fm.time_stamp   as lmeas_fm_time_stamp,
		lmeas_fm.stand_id	  as lmeas_fm_stand_id,
		lmeas_fm.angle_looper as lmeas_fm_angle_looper,
		lmeas_fm.tension	  as lmeas_fm_tension

  FROM calvert.lmeas_fm  lmeas_fm
  WHERE lmeas_fm.id_piece = '1157346070'
    and lmeas_fm.stand_id IN(6,7)

  ORDER BY lmeas_fm.id_piece, lmeas_fm.time_stamp
);

DISCONNECT FROM ASTER;
QUIT;
*/

/* *** Tension from the lstat_fm Table *** */
/*
PROC SQL;
CONNECT TO ASTER (USER=ak186133 PASSWORD=ak186133
                  SERVER='10.25.98.20' DATABASE=calvert PORT=2406);
CREATE TABLE pinchroll_speed as 
SELECT * FROM CONNECTION TO ASTER 
 (SELECT DISTINCT
           lstat_fm.id_piece,
		   lstat_fm.stand_id,
           lstat_fm.tension
  FROM calvert.ak_3cb2021_steel my_file,
       calvert.lstat_fm lstat_fm
  WHERE lstat_fm.id_piece = my_file.coil_id
  ORDER BY lstat_fm.id_piece, lstat_fm.stand_id
);

DISCONNECT FROM ASTER;
QUIT;
*/

/*  lstat_exit_fm  */
/*
OPTIONS OBS=1000;
PROC SQL;
CONNECT TO ASTER (USER=ak186133 PASSWORD=ak186133
                  SERVER='10.25.98.20' DATABASE=calvert PORT=2406);
CREATE TABLE exit_fm as 
SELECT * FROM CONNECTION TO ASTER 
 (SELECT DISTINCT
		lst_exit_fm.id_piece    as lst_exit_fm_id_piece,      
		lst_exit_fm.id_segment	as lst_exit_fm_id_segment,

		lst_exit_fm.thick_hot	as lst_exit_fm_thick_hot,
		lst_exit_fm.dev_cl	    as lst_exit_fm_dev_cl,
		lst_exit_fm.dev_cl_min	as lst_exit_fm_dev_cl_min,
		lst_exit_fm.dev_cl_max	as lst_exit_fm_dev_cl_max,
		lst_exit_fm.dev_cl_std	as lst_exit_fm_dev_cl_std,
		lst_exit_fm.width_hot	as lst_exit_fm_width_hot,

		lst_exit_fm.trg_temp	as lst_exit_fm_trg_temp,
		lst_exit_fm.temp	    as lst_exit_fm_temp,
		lst_exit_fm.temp_min	as lst_exit_fm_temp_min,
		lst_exit_fm.temp_max	as lst_exit_fm_temp_max,
		lst_exit_fm.temp_std	as lst_exit_fm_temp_std,
		lst_exit_fm.limit_temp_up  as lst_exit_fm_limit_temp_up,
		lst_exit_fm.limit_temp_low as lst_exit_fm_limit_temp_low

  FROM calvert.lstat_exit_fm lst_exit_fm
  WHERE lst_exit_fm.id_piece = '1157346070'
    and lst_exit_fm.id_segment = 'O'
  ORDER BY lst_exit_fm.id_piece, lst_exit_fm.id_segment
);

DISCONNECT FROM ASTER;
QUIT;
*/

/* Roughing Mill Intermediate Rolled Piece Profile calvert.lstat_pfg */
/*
OPTIONS OBS=1000;
PROC SQL;
CONNECT TO ASTER (USER=ak186133 PASSWORD=ak186133
                  SERVER='10.25.98.20' DATABASE=calvert PORT=2406);
CREATE TABLE lstat_pfg as 
SELECT * FROM CONNECTION TO ASTER 
 (SELECT DISTINCT
		lstat_pfg.id_piece       as lstat_pfg_id_piece,
		lstat_pfg.id_segment	 as lstat_pfg_id_segment,

		lstat_pfg.trg_thick_hot	 as lstat_pfg_trg_thick_hot,
		lstat_pfg.trg_width_hot  as lstat_pfg_trg_width_hot,
		lstat_pfg.trg_temp       as lstat_pfg_trg_temp,

		lstat_pfg.thick_cold	 as lstat_pfg_thick_cold,
		lstat_pfg.thick_hot      as lstat_pfg_thick_hot,
		lstat_pfg.thick_hot_min  as lstat_pfg_thick_hot_min,
		lstat_pfg.thick_hot_max	 as lstat_pfg_thick_hot_max,
		lstat_pfg.thick_hot_std	 as lstat_pfg_thick_hot_std,
		lstat_pfg.limit_thick_hot_up  as lstat_pfg_limit_thick_hot_up,
		lstat_pfg.limit_thick_hot_low as lstat_pfg_limit_thick_hot_low,

		lstat_pfg.width_hot      as lstat_pfg_width_hot,
		lstat_pfg.width_hot_min	 as lstat_pfg_width_hot_min,
		lstat_pfg.width_hot_max	 as lstat_pfg_width_hot_max,
		lstat_pfg.width_hot_std	 as lstat_pfg_width_hot_std,
		lstat_pfg.limit_width_hot_up  as lstat_pfg_limit_width_hot_up,
		lstat_pfg.limit_width_hot_low as lstat_pfg_limit_width_hot_low,

		lstat_pfg.dev_cl         as lstat_pfg_dev_cl,
		lstat_pfg.dev_cl_min	 as lstat_pfg_dev_cl_min,
		lstat_pfg.dev_cl_max	 as lstat_pfg_dev_cl_max,
		lstat_pfg.dev_cl_std	 as lstat_pfg_dev_cl_std,

		lstat_pfg.temp		 as lstat_pfg_temp,
		lstat_pfg.temp_min	 as lstat_pfg_temp_min,
		lstat_pfg.temp_max	 as lstat_pfg_temp_max,
		lstat_pfg.temp_std	 as lstat_pfg_temp_std,
		lstat_pfg.limit_temp_up	 as lstat_pfg_limit_temp_up,
		lstat_pfg.limit_temp_low as lstat_pfg_limit_temp_low,
		lstat_pfg.time_stamp     as lstat_pfg_time_stamp


  FROM calvert.lstat_pfg lstat_pfg
  WHERE lstat_pfg.id_piece = '1157346070'
    and lstat_pfg.id_segment = 'O'
  ORDER BY lstat_pfg.id_piece, lstat_pfg.id_segment
);

DISCONNECT FROM ASTER;
QUIT;
*/

/* *** Laminar Cooling lsetup_csc !!! JOIN lsetup_csc.id_setup on lpiece.id_setup_used_fm !!! *** */
/* *** JOIN lsetup_csc.id_setup on lpiece.id_setup_used_fm *** */
/*
* OPTIONS OBS=1000;
PROC SQL;
CONNECT TO ASTER (USER=ak186133 PASSWORD=ak186133
                  SERVER='10.25.98.20' DATABASE=calvert PORT=2406);
CREATE TABLE lsetup_csc as 
SELECT * FROM CONNECTION TO ASTER 
 (SELECT DISTINCT
		lsetup_csc.id_piece   as lsetup_csc_id_piece,
		lsetup_csc.id_setup   as lsetup_csc_id_setup,
		lsetup_csc.width      as lsetup_csc_width,
		lsetup_csc.thickness  as lsetup_csc_thickness,
		lsetup_csc.fm_exit_temp	as lsetup_csc_fm_exit_temp,
		lsetup_csc.time_stamp as lsetup_csc_time_stamp 
  FROM calvert.lsetup_csc lsetup_csc
  WHERE lsetup_csc.id_piece = '1157346070'  
  ORDER BY lsetup_csc.id_piece, lsetup_csc.id_setup
);

DISCONNECT FROM ASTER;
QUIT;
*/

/* *** Down Coiler lsetup_dc !!! JOIN lsetup_csc.id_setup on lpiece.id_setup_used_fm !!! *** */
/* *** JOIN lsetup_csc.id_setup on lpiece.id_setup_used_fm *** */
/*
* OPTIONS OBS=1000;
PROC SQL;
CONNECT TO ASTER (USER=ak186133 PASSWORD=ak186133
                  SERVER='10.25.98.20' DATABASE=calvert PORT=2406);
CREATE TABLE lsetup_dc as 
SELECT * FROM CONNECTION TO ASTER 
 (SELECT DISTINCT
		lsetup_dc.id_piece             as lstp_dc_id_piece,
		lsetup_dc.id_setup             as lstp_dc_id_setup,      
		lsetup_dc.temp_coil		       as lstp_dc_temp_coil,
		lsetup_dc.width_strip		   as lstp_dc_width_strip,
		lsetup_dc.thick_strip		   as lstp_dc_thick_strip,
		lsetup_dc.point_yield_hot	   as lstp_dc_point_yield_hot,
		lsetup_dc.tension_spec		   as lstp_dc_tension_spec,

		lsetup_dc.temp_strip_exit      as lstp_dc_temp_strip_exit,
		lsetup_dc.len_strip		       as lstp_dc_len_strip,

		lsetup_dc.dia_coil		       as lstp_dc_dia_coil,
		lsetup_dc.width_coil		   as lstp_dc_width_coil,
		lsetup_dc.wght_coil		       as lstp_dc_wght_coil,

		lsetup_dc.nom_strength_yield   as lstp_dc_nom_strength_yield,
		lsetup_dc.trg_temp_coil		   as lstp_dc_trg_temp_coil,

		lsetup_dc.op_corr_gap_sg       as lstp_dc_op_corr_gap_sg,
		lsetup_dc.op_corr_gap_prds	   as lstp_dc_op_corr_gap_prds,
		lsetup_dc.op_corr_gap_pros	   as lstp_dc_op_corr_gap_pros,
		lsetup_dc.op_corr_gap_wr1	   as lstp_dc_op_corr_gap_wr1,
		lsetup_dc.op_corr_gap_wr2	   as lstp_dc_op_corr_gap_wr2,
		lsetup_dc.op_corr_gap_wr3	   as lstp_dc_op_corr_gap_wr3,
		lsetup_dc.op_corr_force_sg	   as lstp_dc_op_corr_force_sg,
		lsetup_dc.op_corr_force_prds   as lstp_dc_op_corr_force_prds,
		lsetup_dc.op_corr_force_pros   as lstp_dc_op_corr_force_pros,
		lsetup_dc.op_corr_force_wr1	   as lstp_dc_op_corr_force_wr1,
		lsetup_dc.op_corr_force_wr2	   as lstp_dc_op_corr_force_wr2,
		lsetup_dc.op_corr_force_wr3	   as lstp_dc_op_corr_force_wr3,
		lsetup_dc.op_corr_mandrel_tension  as lstp_dc_op_corr_mandrel_tension,
		lsetup_dc.op_corr_mandrel_exp_press as lstp_dc_op_corr_mandrel_exp_press,
		lsetup_dc.op_corr_strip_car_press  as lstp_dc_op_corr_strip_car_press

  FROM calvert.lsetup_dc  lsetup_dc 
  WHERE lsetup_dc.id_piece = '1157346070'  
  ORDER BY lsetup_dc.id_piece, lsetup_dc.id_setup
);

DISCONNECT FROM ASTER;
QUIT;
*/

/*
PROC SQL;
CONNECT TO ASTER (USER=ak186133 PASSWORD=ak186133
                  SERVER='10.25.98.20' DATABASE=calvert PORT=2406);
CREATE TABLE setup_dc as 
SELECT * FROM CONNECTION TO ASTER 
 (SELECT DISTINCT
	setup_dc.id_piece,
	setup_dc.id_setup,
	setup_dc.op_corr_mandrel_tension,
	setup_dc.op_corr_mandrel_exp_press
  FROM calvert.ak_3cb2021_steel my_file,
       calvert.lsetup_dc setup_dc
  WHERE setup_dc.id_piece = my_file.coil_id
    and setup_dc.op_corr_mandrel_tension IS NOT NULL
  ORDER BY setup_dc.id_piece, setup_dc.id_setup
);

DISCONNECT FROM ASTER;
QUIT;
*/



/* *** Test dblib.ak_3CB2021_Steel table for Duplicate Coils Records & Generate Table Content *** */
/*
LIBNAME calvert aster user=ak186133 pwd=ak186133 server='10.25.98.20' database=calvert schema=calvert 
                dimension=yes port=2406;

DATA ak_3cb2021_steel;
 SET calvert.ak_3cb2021_steel (OBS=MAX);
* slab_supplier = SUBSTR(id_foreign,1,2);
run;


PROC SORT DATA=ak_3cb2021_steel OUT=test_dedups DUPOUT=dup_coils NODUP;  * NODUPKEY;
 BY coil_id;
run;
LIBNAME calvert CLEAR;
*/




/*
	IF SUBSTR(pc_id_foreign,1,2) = 'TB' THEN slab_supplier = 'Tubarao';		    
 ELSE IF SUBSTR(pc_id_foreign,1,2) = 'LC' THEN slab_supplier = 'Lazaro_Cardenas';
  ELSE slab_supplier = 'Other';
*/
/*
c_diff  = carbon - pc_cont_c;
mn_diff = manganese - pc_cont_mn;
si_diff = silicon - pc_cont_si;
cr_diff = chromium - pc_cont_cr;
ni_deff = nickel - pc_cont_ni;
cu_diff = copper - pc_cont_cu; 
zn_diff = zinc - pc_cont_zn;
ti_diff = titanium - pc_cont_ti;
v_diff = vanadium - pc_cont_v;
s_diff = sulphur - pc_cont_s;
p_diff = phosphorous - pc_cont_p;
n_diff = nitrogen - pc_cont_n;
mo_diff = molybdenum - pc_cont_mo;
nb_diff = niobium - pc_cont_nb;
w_diff = tungsten - pc_cont_w;
al_met_diff = aluminum_metal - pc_cont_al;
al_tot_diff = aluminum_total - pc_cont_al_total;
 
run;
*/



/* *** De-DUP Coils as Multiple Records per Coil comming from the calvert.mes_material Table *** */
PROC SORT DATA=mat_piece OUT=dedup_coils DUPOUT=dup_coils NODUPKEY;
 BY coil_id mat_time_stamp;
run;

/* *** To list Duplicate Slabs in the mes_material Table... *** */
DATA duplicate_slabs (KEEP=internal_steelgrade_head id coil_id material_class rio_code product_class product_group flag_stainless
     mat_time_stump product_group mt_slab_weight_mt slab_thickness_head slab_width_head slab_length dup_coils_count dup_coils_number);
 MERGE mat_piece (IN=all_coils)
       dup_coils (IN=dupcoils KEEP=coil_id);
  BY coil_id;
   IF all_coils & dupcoils;
IF first.coil_id THEN dup_coils_count = 0;
dup_coils_count + 1; 
IF last.coil_id THEN dup_coils_number = dup_coils_count;
run;


DATA temp;
 SET duplicate_slabs (KEEP=coil_id dup_coils_number);
  BY coil_id;
   IF last.coil_id;
run;


DATA dup_slabs_inspected;
 MERGE duplicate_slabs (IN=all_coils DROP=dup_coils_number)
       temp (IN=dups_count);
  BY coil_id;
   IF all_coils & dups_count;
run;





/* *** De-DUP Coils as Multiple Records per Coil comming from the calvert.mes_material Table *** */
/*
PROC SORT DATA=coils_3cb2021;
 BY coil_id DESCENDING rjrp_weight_mt;
run;

DATA coils_3cb2021_dd;
 SET coils_3cb2021;
  BY coil_id;
IF FIRST.coil_id; 

run;
*/



/* *** De-DUP Coils as Multiple Records per Coil comming from the calvert.mes_material Table *** */
PROC SORT DATA=coils_3cb2021 OUT=dedup_3cb2021 DUPOUT=dup_coils NODUPKEY;
 BY coil_id ;   /*pc_id_piece; pc_id_coil; */
run;



/* *** Check Table "mat_piece" for Duplicate Coil_IDs  *** */
/*
DATA dup_coils;
 SET mat_piece;
  BY coil_id mat_time_stump;
   IF first.time_stamp; 

IF pc_id_coil = LAG(pc_id_coil) THEN dup_coil_flag = 1;

run;
*/


PROC SORT DATA=mat_piece OUT=dup_check NODUPKEY;
 BY coil_id ;   /*pc_id_piece; pc_id_coil; */
run;







/* *** Load Data into ASTER Table with (BULKLOAD=YES) *** */
/* *** Getting ERROR Message: 
NOTE: SAS variable labels, formats, and lengths are not written to DBMS tables.
ERROR: Insufficient authorization to access C:\Windows\system32\BL_steel_3cb2021_pr_1800973315.dat.
NOTE: The DATA step has been abnormally terminated.
NOTE: The SAS System stopped processing this step because of errors.
NOTE: There were 1 observations read from the data set WORK.MAT_PIECE_DEFECTS.
WARNING: The data set CALVERT.steel_3cb2021_pr may be incomplete.  When this step was stopped there were 0 observations and 38 
         variables.
ERROR: ROLLBACK issued due to errors for data set CALVERT.steel_3cb2021_pr.DATA.
*** */

LIBNAME dblib aster dsn=Calvert UID=ak186133 PWD=ak186133 DIMENSION=yes;

DATA dblib.steel_3cb2021_blk2 (BULKLOAD=YES 
                              BL_DATAFILE_PATH='C:\Temp\' 
                              BL_HOST='10.25.98.20' 
                              BL_PATH='C:\Remote_ASTER_Client\'
                              BL_DBNAME='calvert'
			    /* BL_DELETE_DATAFILE=NO */
                              DBCREATE_TABLE_OPTS='DISTRIBUTE BY HASH(id_piece)'
                             );
 SET mat_piece_defects(OBS=100);
run;

/* *** Load Data into ASTER Table without (BULKLOAD=YES). This Works Fine, But Very Slow..  *** */
DATA calvert.steel_3cb2021_ts; * (BULKLOAD=YES);
 SET mat_piece_defects (OBS=100);
run;



PROC SORT DATA=mat_piece_defects  OUT=squatty_coils;
 BY Squatty_Coil_Flag rjrp_decision_type rjrp_defect_code_text rjrp_decision_type;
run;


DATA squatty_coils;
 SET squatty_coils;
  strip_thickness = 1*pc_strip_thickness ;
  defstrip_weight = 1*rjrp_weight_mt;
run;

/* ***Test Scatter PLOT *** */
proc sgplot data=squatty_coils;
WHERE Squatty_Coil_Flag = 'Squatty Coils'
    & pc_strip_thickness < 20;
 BY Squatty_Coil_Flag rjrp_decision_type rjrp_defect_code_text rjrp_decision_type;
scatter x=pc_strip_thickness
        y=defstrip_weight 
;

LABEL
     pc_strip_thickness = 'Strip Thickness, mm'
     defstrip_weight = 'Coil Weight, mt'
;
TITLE1 H=16pt J=center 'Squatty CoilsWeight (mt) by Strip Thickness (mm)';
TITLE2 H=14pt J=center 'DecisionType: #BYVAL(rjrp_decision_type)';
run;





ODS LISTING CLOSE;
ODS HTMLCSS FILE = "C:\Users\ak186133\Calvert ASTER Project\SAS_Outputs\Squatty_Coil_Summary.xls" STYLE=MINIMAL
    HEADTEXT="<STYLE>.zero {mso-number-format:\@}</style>";
 ****************************************************;
 ** REPORT ** REPORT ** REPORT ** REPORT ** REPORT **;
 ** REPORT ** REPORT ** REPORT ** REPORT ** REPORT **;
 ****************************************************;
/* *** Summary Table 1  Based on Slab Thickness & Width *** */
PROC TABULATE DATA=mat_piece_defects MISSING ORDER=UNFORMATTED
              STYLE={font_size=3 font_weight=bold just=center
                     FONT_FACE="Helvetica"};
 CLASS internal_steelgrade_head slab_thickness_head slab_width_head rjrp_melt_source
       Squatty_Coil_Flag rjrp_decision_type rjrp_defect_code_text
              / ASCENDING
                style={BACKGROUND=white font_size=3 font_weight=bold just=center};
 CLASSLEV internal_steelgrade_head slab_thickness_head slab_width_head rjrp_melt_source
          Squatty_Coil_Flag rjrp_decision_type rjrp_defect_code_text
              / style={BACKGROUND=white just=center
                       FONT_FACE="Arial" font_size=3 font_weight=bold};
 VAR mt_slab_weight_mt pc_val_wght_coil_mt
              / style={font_size=3 font_weight=bold just=center
                       BACKGROUND=white FONT_FACE="Arial"};
   TABLE (rjrp_melt_source='Melt Source'*(internal_steelgrade_head='Steel Grade'*
          slab_thickness_head='Slab Thickness, mm'*slab_width_head='Slab Width, mm' ALL='Total by Melt Source') ALL='Total'),
         (rjrp_decision_type=' '* 
          (mt_slab_weight_mt=' '*
              (SUM='Slab Weight, mt' 
               N='Count'*F=COMMA12. 
               PCTN<rjrp_melt_source*internal_steelgrade_head*slab_thickness_head*slab_width_head*rjrp_decision_type ALL>='%'*F=5.1))
           ALL='Total'*N='Count'*F=COMMA12. )
                / RTS=10 BOX='Steel Grade|Slab Width' NOCONTINUED
                  style={font_size=3 font_weight=bold just=center
                         BACKGROUND=white FONT_FACE="Courier New"};
FORMAT slab_width_head width. slab_thickness_head thick.;
 KEYLABEL MIN = 'Min'
          MAX = 'Max'
         MEAN = 'Avg'
       MEDIAN = 'Median'
           Q1 = '25% Q'
           Q3 = '75% Q'
            N = 'Stand Alone Count.'
          ALL = 'TOTAL';
KEYWORD ALL
            / style=[background=white FOREGROUND=red
              font_size=7 pt font_weight=bold just=center];
KEYWORD MAX MEAN MIN MEDIAN Q1 Q3 N SUM PCTSUM COLPCTSUM ROWPCTSUM COLPCTN ROWPCTN
            / style=[background=white FOREGROUND=black
              font_size=7 pt font_weight=bold just=center];

KEYWORD ALL / style=[background=white FOREGROUND=blue
              font_size=10 pt font_weight=bold just=center];
TITLE1 "Arcelor Mittal Calvert Steel Corp. / Teradata GDC";
TITLE2 "HSM 3CB20/3CB21 Steel Grade:  508 Squatty Coils Defects Summary";
TITLE3 "Reporting Period: 2014 through 2016";
TITLE4 "Production / Sqatty Coils Summary by Steel Grade & Coil Dimentions";
run;


/* *** Summary Table 2 Based on Coil Thickness & Width *** */
PROC TABULATE DATA=mat_piece_defects MISSING ORDER=UNFORMATTED
              STYLE={font_size=3 font_weight=bold just=center
                     FONT_FACE="Helvetica"};
 WHERE NOT MISSING(rjrp_decision_type);
 CLASS internal_steelgrade_head pc_strip_thickness pc_strip_width rjrp_melt_source
       Squatty_Coil_Flag rjrp_decision_type rjrp_defect_code_text
              / ASCENDING
                style={BACKGROUND=white font_size=3 font_weight=bold just=center};
 CLASSLEV internal_steelgrade_head pc_strip_thickness pc_strip_width rjrp_melt_source
          Squatty_Coil_Flag rjrp_decision_type rjrp_defect_code_text
              / style={BACKGROUND=white just=center
                       FONT_FACE="Arial" font_size=3 font_weight=bold};
 VAR mt_slab_weight_mt pc_val_wght_coil_mt
              / style={font_size=3 font_weight=bold just=center
                       BACKGROUND=white FONT_FACE="Arial"};
   TABLE (pc_strip_thickness='Strip Thickness, mm'*pc_strip_width='Strip Width, mm' ALL='Total'),
         (rjrp_melt_source='Melt Source'*rjrp_decision_type=' '* 
          (pc_val_wght_coil_mt=' '*
              (SUM='Slab Weight, mt' 
               N='Count'*F=COMMA12. 
               PCTN<pc_strip_thickness*pc_strip_width*rjrp_melt_source*rjrp_decision_type ALL>='%'*F=5.1))
           ALL='Total'*N='Count'*F=COMMA12. )
                / RTS=10 BOX='Steel Grade|Slab Width' NOCONTINUED
                  style={font_size=3 font_weight=bold just=center
                         BACKGROUND=white FONT_FACE="Courier New"};
/*
   TABLE (rjrp_melt_source='Melt Source'*
          (pc_strip_thickness='Strip Thickness, mm'*pc_strip_width='Strip Width, mm' ALL='Total by Melt Source') ALL='Total'),
         (rjrp_decision_type=' '* 
          (pc_val_wght_coil_mt=' '*
              (SUM='Slab Weight, mt' 
               N='Count'*F=COMMA12. 
               PCTN<rjrp_melt_source*pc_strip_thickness*pc_strip_width*rjrp_decision_type ALL>='%'*F=5.1))
           ALL='Total'*N='Count'*F=COMMA12. )
                / RTS=10 BOX='Steel Grade|Slab Width' NOCONTINUED
                  style={font_size=3 font_weight=bold just=center
                         BACKGROUND=white FONT_FACE="Courier New"};
*/

FORMAT pc_strip_width width. pc_strip_thickness cl_thick.;
 KEYLABEL MIN = 'Min'
          MAX = 'Max'
         MEAN = 'Avg'
       MEDIAN = 'Median'
           Q1 = '25% Q'
           Q3 = '75% Q'
            N = 'Stand Alone Count.'
          ALL = 'TOTAL';
KEYWORD ALL
            / style=[background=white FOREGROUND=red
              font_size=7 pt font_weight=bold just=center];
KEYWORD MAX MEAN MIN MEDIAN Q1 Q3 N SUM PCTSUM COLPCTSUM ROWPCTSUM COLPCTN ROWPCTN
            / style=[background=white FOREGROUND=black
              font_size=7 pt font_weight=bold just=center];

KEYWORD ALL / style=[background=white FOREGROUND=blue
              font_size=10 pt font_weight=bold just=center];
TITLE1 "Arcelor Mittal Calvert Steel Corp. / Teradata GDC";
TITLE2 "HSM 3CB20/3CB21 Steel Grade:  508 Squatty Coils Defects Summary";
TITLE3 "Reporting Period: 2014 through 2016";
TITLE4 "Production / Sqatty Coils Summary by Steel Grade & Coil Dimentions";
run;


/*
PROC FREQ DATA=mat_piece_defects NOHEADER ORDER=FREQ;
 WHERE NOT MISSING(rjrp_melt_source );
 TABLES rjrp_melt_source*rjrp_decision_type
        slab_thickness_head*slab_width_head
        
           / LIST MISSING NOCUM; * CUMCOL NOROW NOCOL NOPERCENT OUT=DataSetName;
                               * NOPRINT MISSPRINT CHISQ CROSSLIST;
FORMAT slab_width_head width. slab_thickness_head thick.;
LABEL
	internal_steelgrade_head  = 'Steel Grade'
	rjrp_melt_source          = 'Melt Source'
	slab_thickness_head       = 'Slab Thickness, mm'
	slab_width_head           = 'Slab Width, mm'
	rjrp_decision_type        = 'Decision Type' 
;
TITLE1 "Arcelor Mittal Calvert Steel Corp. / Teradata GDC";
TITLE2 "HSM 3CB20/3CB21 Steel Grade:  508 Squatty Coils Defects Summary";
TITLE3 "Reporting Period: 2014 through 2016";
run;
*/


/* *** Analyze Difference in Chemical Composition between mes_material and lpiece Tables *** */
ODS LISTING;

PROC FREQ DATA=de_dup_slabs NOHEADER ORDER=INTERNAL;
 TABLES c_diff
	mn_diff
	si_diff
	cr_diff
	ni_deff
	cu_diff
	zn_diff
	ti_diff
	v_diff 
	s_diff 
	p_diff 
	n_diff 
	mo_diff
	nb_diff
	w_diff
	al_met_diff
	al_tot_diff
           / LIST MISSING NOCUM; * CUMCOL NOROW NOCOL NOPERCENT OUT=DataSetName;
                               * NOPRINT MISSPRINT CHISQ CROSSLIST;
FORMAT slab_width_head width. slab_thickness_head thick.;
LABEL
	c_diff  = 'Carbon'
	mn_diff = 'Manganese'
	si_diff = 'Silicon'
	cr_diff = 'Chromium'
	ni_deff = 'Nickel'
	cu_diff = 'Copper'
	zn_diff = 'Zinc'
	ti_diff = 'Titanium'
	v_diff = 'Vanadium'
	s_diff = 'Sulphur'
	p_diff = 'Phosphorous'
	n_diff = 'Nitrogen'
	mo_diff = 'Molybdenum'
	nb_diff = 'Niobium'
	w_diff = 'Tungsten'
	al_met_diff = 'Aluminum_Metal'
	al_tot_diff = 'Aluminum_Total'
;
TITLE1 "Arcelor Mittal Calvert Steel Corp. / Teradata GDC";
TITLE2 "HSM 3CB20/3CB21 Steel Grade:  508 Squatty Coils Defects Summary";
TITLE3 "Reporting Period: 2014 through 2016";
run;

PROC PRINT DATA=mat_piece (OBS=20);
run;


ODS LISTING CLOSE;


PROC FREQ DATA=mat_piece_defects NOHEADER ORDER=FREQ;
 TABLES rjrp_melt_source*rjrp_decision_type
  /*    slab_thickness_head*slab_width_head  */
           / MISSING NOCUMNOROW NOCOL NOROW; * LIST CUMCOL NOROW NOCOL NOPERCENT OUT=DataSetName;
                               * NOPRINT MISSPRINT CHISQ CROSSLIST;
FORMAT slab_width_head width. slab_thickness_head thick.;
LABEL
	internal_steelgrade_head  = 'Steel Grade'
	rjrp_melt_source          = 'Melt Source'   
	slab_thickness_head       = 'Slab Thickness, mm'
	slab_width_head           = 'Slab Width, mm'
	rjrp_decision_type        = 'Decision Type' 
;
TITLE1 "Arcelor Mittal Calvert Steel Corp. / Teradata GDC";
TITLE2 "HSM 3CB20/3CB21 Steel Grade:  508 Squatty Coils Defects Summary";
TITLE3 "Reporting Period: 2014 through 2016";
run;

ODS HTMLCSS CLOSE;


ODS LISTING CLOSE;
ODS CSVALL FILE = "C:\Users\ak186133\Calvert ASTER Project\SAS_Outputs\Squatty_Coil_Details.csv" STYLE=MINIMAL;
 ****************************************************;
 ** REPORT ** REPORT ** REPORT ** REPORT ** REPORT **;
 ** REPORT ** REPORT ** REPORT ** REPORT ** REPORT **;
 ****************************************************;
/* *** Print Details Table 2 *** */
PROC PRINT DATA=mat_piece_defects (OBS=MAX) U NOOBS SPLIT='*' LABEL 
   STYLE(table) = [background=white font_size=2 font_face=Courier
                     foreground=black]
   STYLE(header) = [background=white just=center
                      font_size=2 font_face=Courier font_weight=bold
                      font_STYLE=italic foreground=black];
/*  BY mytl_name; */
/*   VAR mytl_name analyst_name
                    / style(data)={background=white just=center
                      foreground=black font_size=2 font_face=courier}; */
   VAR internal_steelgrade_head coil_id mt_slab_weight_mt slab_thickness_head slab_width_head slab_length
       pc_time_rm_start pc_pdi_wght_coil_mt pc_val_wght_coil_mt
       pc_strip_thickness pc_strip_width rjrp_decision_type rjrp_defect_code_text
       rjrp_weight_mt rjrp_defect_details
                    / style(data)={background=white just=center
                      foreground=black font_size=2 font_face=courier};
/*   SUM BY mytl_name;
     SUM chg_amt / style={background=white just=center foreground=black
                   font_size=2 font_weight=bold font_face=courier};  
*/
/* FORMAT decn_cd $DECFMT. chg_amt DOLLAR9.2; */
LABEL
	internal_steelgrade_head  = 'Steel Grade'
	rjrp_melt_source          = 'Melt Source'
	coil_id                   = 'Coli ID'
	mt_slab_weight_mt         = 'Slab Weight, mt'
	slab_thickness_head       = 'Slab Thickness, mm'
	slab_width_head           = 'Slab Width, mm'
	slab_length               = 'Slab Length, mm'

	pc_time_rm_start          = 'RM Start Time'
	pc_flag_slab_rejected     = 'Slab Rejection Flag'
	pc_meltcode               = 'Melt Code'
	pc_pdi_wght_coil_mt       = 'PDI Coil Weight, mt'
	pc_val_wght_coil_mt       = 'VAL Coil Weight, mt' 
	pc_strip_thickness        = 'Strip Thickness, mm'
	pc_strip_width            = 'Strip Width, mm'
	 
	Squatty_Coil_Flag         = 'Squatty Coil Flag'
	rjrp_decision_type        = 'Decision Type' 
	rjrp_defect_code_text     = 'Defect Code/Text'
	rjrp_weight_mt            = 'Rejected/Reproc. Weight, mt'
	rjrp_defect_details       = 'Defect Details'
;
TITLE1 "Arcelor Mittal Calvert Steel Corp. / Teradata GDC";
TITLE2 "HSM 3CB20/3CB21 Steel Grade:  508 Squatty Coils Defects Details";
TITLE3 "Reporting Period: 2014 through 2016";
run;

ODS CSVALL CLOSE;

FILENAME _ALL_ CLEAR;
ODS PHTML CLOSE;
ODS TRACE OFF;
* ENDSAS;
**** END *** END *** END *** END *** END *** END *** END ***;
**** END *** END *** END *** END *** END *** END *** END ***;



LIBNAME my_aster aster user=ak186133 pwd=ak186133 server='10.25.98.20' database=calvert schema=calvert 
                 dimension=yes port=2406;

LIBNAME myaster1 aster user=ak186133 pwd=ak186133 server='10.25.98.20' database=calvert schema=calvert;


OPTIONS ERRORS=2 PAGENO=1 MISSING=0 NOCENTER PAPERSIZE=LEGAL ORIENTATION=PORTRAIT PAGESIZE=80 LINESIZE=132 
        MSGLEVEL=I SPOOL SOURCE SOURCE2 MAUTOSOURCE SYMBOLGEN MPRINT MLOGIC NOBYLINE; * STARTPAGE=NO;
OPTIONS ERRORS=2 PAGENO=1 MISSING=0 NOCENTER PAGESIZE=59 LINESIZE=132 PAGESIZE=MAX SPOOL
        MSGLEVEL=I SOURCE SOURCE2 MAUTOSOURCE SYMBOLGEN MPRINT MLOGIC NOBYLINE; * OBS=100;
OPTIONS FMTERR FULLSTIMER NOTES; 


DATA test;
 SET my_aster.lsetup_dc (OBS=100);
run;

PROC PRINT DATA=test;
run;

/* Test Connection to ASTER from GOOGLE Review: */
PROC SQL; 
   CONNECT TO ASTER (USER=ak186133 PASSWORD=ak186133 DATABASE='10.25.98.20'
                     SERVER='10.25.98.20' DATABASE=calvert /* schema=calvert */ PORT=2406);
   CREATE TABLE work.test_aster as
          SELECT * FROM CONNECTION TO ASTER 
          (ASTER::SQLTables);
   DISCONNECT FROM ASTER;
QUIT;

ODS LISTING;

PROC PRINT DATA=work.test_aster;
run;

ODS LISTING CLOSE;


/* *** Read Table calvert.mes_material *** */
PROC SQL;
CONNECT TO ASTER (USER=ak186133 PASSWORD=ak186133 DATABASE='10.25.98.20'
                  SERVER='10.25.98.20' DATABASE=calvert /* schema=calvert */ PORT=2406);
CREATE TABLE mes_materials as 
SELECT * FROM CONNECTION TO ASTER 
 (SELECT materials.*
  FROM calvert.mes_material materials
  WHERE materials.internal_steelgrade_head LIKE '%3CB2%'
  ORDER BY materials.internal_steelgrade_head, time_stamp
);
   DISCONNECT FROM ASTER;
QUIT;



/* *** Read Table calvert.mes_material *** */
PROC SQL;
CONNECT TO ASTER (USER=ak186133 PASSWORD=ak186133 DATABASE='10.25.98.20'
                     SERVER='10.25.98.20' DATABASE=calvert PORT=2406);
CREATE TABLE mes_materials as 
SELECT * FROM CONNECTION TO ASTER 
 (SELECT 
		 materials.internal_steelgrade_head, 
		 materials.id, 
		 materials.coil_id,
		 materials.time_stamp,
		 materials.product_group, 
		 materials.slab_weight, 
		 materials.slab_thickness_head, 
		 materials.slab_width_head, 
		 materials.slab_length,
		 materials.carbon,
		 materials.manganese, 
		 materials.silicon, 
		 materials.chromium, 
		 materials.nickel, 
		 materials.zinc, 
		 materials.titanium, 
		 materials.vanadium, 
		 materials.sulphur, 
		 materials.phosphorous, 
		 materials.nitrogen
  FROM calvert.mes_material materials
  WHERE materials.internal_steelgrade_head LIKE '%3CB2%'
  ORDER BY materials.internal_steelgrade_head, time_stamp
);
DISCONNECT FROM ASTER;
QUIT;


ODS LISTING;

PROC PRINT DATA=mes_materials (OBS=20);
 VAR internal_steelgrade_head id coil_id time_stamp
     product_group slab_weight slab_thickness_head slab_width_head slab_length
     carbon manganese silicon chromium nickel zinc titanium vanadium sulphur phosphorous nitrogen;
 WHERE coil_id = '1157346070';
run;

ODS LISTING CLOSE;




PROC SQL;
CONNECT TO ASTER (USER=ak186133 PASSWORD=ak186133 DATABASE='10.25.98.20'
                     SERVER='10.25.98.20' DATABASE=calvert PORT=2406);
/* CREATE TABLE lpiece as  */
SELECT * FROM CONNECTION TO ASTER 
 (SELECT lpiece.steel_grade,
         COUNT(lpiece.steel_grade)
  FROM calvert.lpiece lpiece
GROUP BY lpiece.steel_grade
ORDER BY lpiece.steel_grade
);

DISCONNECT FROM ASTER;
QUIT;


/* *** Read Table calvert.lpiece *** 
       Join lpiece.id_coil = lpiece.id_piece ?? = mes_materials.coil_id 
*** */

OPTIONS OBS=100;  * OBS=MAX;
PROC SQL;
CONNECT TO ASTER (USER=ak186133 PASSWORD=ak186133 DATABASE='10.25.98.20'
                     SERVER='10.25.98.20' DATABASE=calvert PORT=2406);
CREATE TABLE lpiece as 
SELECT * FROM CONNECTION TO ASTER 
 (SELECT lpiece.*
  FROM calvert.lpiece lpiece
  WHERE lpiece.id_coil = '1157346070'
/*  WHERE materials.internal_steelgrade_head LIKE '%3CB2%'
  ORDER BY materials.internal_steelgrade_head, time_stamp */
);

DISCONNECT FROM ASTER;
QUIT;


/* *** Pull Analyze Data from the calvert.jrs_coil_reprocess_reject Tables *** */

PROC SQL;
CONNECT TO ASTER (USER=ak186133 PASSWORD=ak186133 DATABASE='10.25.98.20'
                     SERVER='10.25.98.20' DATABASE=calvert PORT=2406);
CREATE TABLE rej_rep as 
SELECT * FROM CONNECTION TO ASTER 
 (SELECT rjrp.decision_type,	
	 rjrp.timestamp_rework,
	 rjrp.piece_no,
	 rjrp.weight_in_mt,
	 rjrp.defect_code,
	 rjrp.defect_code_text,
	 rjrp.defect_group,
	 rjrp.defect_group_text,
	 rjrp.originating_unit,
	 rjrp.reporting_unit,
	 rjrp.material_type,
	 rjrp.charged_coil,
	 rjrp.production_date,
	 rjrp.order_grade,
	 rjrp.product_group,
	 rjrp.order_product,
	 rjrp.sort_grade,
	 rjrp.manufacturing_order,
	 rjrp.sales_order_number,
	 rjrp.sales_order_item,
	 rjrp.customer_number,
	 rjrp.thickness,
	 rjrp.width,
	 rjrp.decision_user,
	 rjrp.decision_user_name,	
	 rjrp.melt_source,	
	 rjrp.heat_number,	
	 rjrp.steel_grade,
	 rjrp.slab_number,	
	 rjrp.hsm_piece_no,	
	 rjrp.defect_details
  FROM calvert.jrs_coil_reprocess_reject rjrp
  /* WHERE rjrp.defect_code = '508'  */
  );

DISCONNECT FROM ASTER;
QUIT;		

PROC FREQ DATA=rej_rep NOHEADER ORDER=FREQ;
 TABLES defect_code_text*decision_type

 
           / LIST MISSING NOCUM; * CUMCOL NOROW NOCOL NOPERCENT OUT=DataSetName;
                               * NOPRINT MISSPRINT CHISQ CROSSLIST;
FORMAT slab_width_head width. slab_thickness_head thick.;
LABEL
	internal_steelgrade_head  = 'Steel Grade'
	rjrp_melt_source          = 'Melt Source'
	slab_thickness_head       = 'Slab Thickness, mm'
	slab_width_head           = 'Slab Width, mm'
	rjrp_decision_type        = 'Decision Type' 
;
TITLE1 "Arcelor Mittal Calvert Steel Corp. / Teradata GDC";
TITLE2 "HSM 3CB20/3CB21 Steel Grade:  508 Squatty Coils Defects Summary";
TITLE3 "Reporting Period: 2014 through 2016";
run;











ODS LISTING;

PROC PRINT DATA=mes_materials (OBS=100);
 VAR internal_steelgrade_head id coil_id time_stamp
     product_group slab_weight slab_thickness_head slab_width_head slab_length
     carbon manganese silicon chromium nickel zinc titanium vanadium sulphur phosphorous nitrogen;
run;

ODS LISTING CLOSE;










/*
SAS Connection to ASTER Literature Review (Google):

proc sql;
   connect to aster as dbcon
   (server=mysrv1 database=test user=myusr1 password=mypwd1);
select * from connection to dbcon
   (select * from customers WHERE customer like '1%');
quit;


Aster::SQLAPI'parameter–1', 'parameter-n'
Aster::
is required to distinguish special queries from regular queries. Aster:: is not case sensitive.
SQLAPI
is the specific API that is being called. SQLAPI is not case sensitive.
'parameter n'
is a quoted string that is delimited by commas.
Within the quoted string, two characters are universally recognized: the percent sign (%) and the underscore (_). 
The percent sign matches any sequence of zero or more characters, and the underscore represents any single character. 
To use either character as a literal value, you can use the backslash character (\) to escape the match characters.
For example, this call to SQL Tables usually matches table names such as myatest and my_test:

select * from connection to aster (ASTER::SQLTables
"test","","my_test");
Use the escape character to search only for the my_test table.
select * from connection to aster (ASTER::SQLTables "test","","my\_test");



Examples
This example shows how you can use a SAS data set, SASFLT.FLT98, to create and load a large Aster table, FLIGHTS98.
LIBNAME sasflt 'SAS-library';
LIBNAME net_air ASTER user=myusr1 pwd=mypwd1
        server=air2 database=flights dimension=yes;

PROC sql;
create table net_air.flights98
       (bulkload=YES bl_host='queen' bl_path='/home/aster_loader/'
          bl_dbname='beehive')
      as select * from sasflt.flt98;
quit;
You can use BL_OPTIONS= to pass specific Aster options to the bulk-loading process.
You can create the same table using a DATA step.
data net_air.flights98(bulkload=YES bl_host='queen' 
     bl_path='/home/aster_loader/'
     bl_dbname='beehive');
     set sasflt.flt98;
run;
You can then append the SAS data set, SASFLT.FLT98, to the existing Aster table, ALLFLIGHTS. SAS/ACCESS Interface to Aster to write data to a flat file, as specified in the BL_DATAFILE= option. Rather than deleting the data file, BL_DELETE_DATAFILE=NO causes the engine to retain it after the load completes.
PROC append base=net_air.allflights
    (BULKLOAD=YES
     BL_DATAFILE='/tmp/fltdata.dat'
     BL_HOST='queen'
     BL_PATH='/home/aster_loader/'
     BL_DBNAME='beehive'
     BL_DELETE_DATAFILE=NO )
data=sasflt.flt98;
run;



libname mylib aster user=user-id password=password database=database-name
                    server=server-name port=port-number;
NOTE: Libref MYLIB was successfully assigned as follows:
Engine:        ASTER

proc sql; 
   connect to aster (user=user-id password=password database=database-name
                     server=server-name port=port-number);
   create table work.asterschema as
          select * from connection to aster 
          (ASTER::SQLTables);
   disconnect from aster;
quit;
*/
