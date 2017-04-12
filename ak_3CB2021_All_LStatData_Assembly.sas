
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

/*
LIBNAME calvert aster user=ak186133 pwd=ak186133 server='10.25.98.20' database=calvert schema=calvert 
                dimension=yes port=2406;

LIBNAME calv13 aster user=ak186133 pwd=ak186133 server='10.25.98.13' database=calvert schema=calvert 
                dimension=yes port=2406;
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

 VALUE coil_wt     /* Coil Weight */
   LOW  -< 12    = '<12mt'
    12  -< 13    = '12-13mt' 
    13  -< 14    = '13-14mt'    
    14  -< 15    = '14-15mt' 
    15  -< 16    = '15-16mt' 
    16  -< 17    = '16-17mt' 
    17  -< 18    = '17-18mt' 
    18  -< 19    = '18-19mt' 
    19  -< 20    = '19-20mt' 
    20  -< 21    = '20-21mt' 
    21  -< 22    = '21-22mt' 
    22  -< 23    = '22-23mt' 
    23  -< 24    = '23-24mt' 
    24  -< 25    = '24-25mt' 
    25  -< 26    = '25-26mt' 
    26  -< 27    = '26-27mt' 
    27  -< 28    = '28-29mt' 
    29  -< 30    = '29-30mt' 
    30  - HIGH   = '>30mt'
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
	lpiece.code_plant_successive as pc_code_plant_successive,
	lpiece.furn_len_slab_cold	as pc_furn_len_slab_cold,
	lpiece.furn_pred_temp_disch	as pc_furn_pred_temp_disch,
	lpiece.furn_thick_slab_cold	as pc_furn_thick_slab_cold,
	lpiece.furn_width_slab_cold	as pc_furn_width_slab_cold,
	lpiece.val_wght_coil		as pc_val_wght_coil,
	lpiece.group_product		as pc_group_product,
	lpiece.id_caster                as pc_id_caster,
	lpiece.id_foreign               as pc_id_foreign,  

	lpiece.id_furn                  as pc_id_furn,
	lpiece.id_piece_pre             as pc_id_piece_pre,
	lpiece.id_row_furn              as pc_id_row_furn,
	lpiece.id_setup_rm_used         as pc_id_setup_rm_used,
	lpiece.id_setup_used_fm         as pc_id_setup_used_fm,
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
	lpiece.id_shift_fin	        as pc_id_shift_fin,
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
	
	lpiece.mode_rolling                 as pc_mode_rolling,
	lpiece.mode_transport		    as pc_mode_transport,
	lpiece.no_work_instr		    as pc_no_work_instr,
	lpiece.pdi_temp_coil		    as pc_pdi_temp_coil,
	
/* *** Added SetUP PDI Slab & Coil Parameters 20170223 *** */	
	lpiece.pdi_temp_furn_disch	    as pc_pdi_temp_furn_disch,
	lpiece.pdi_thick_slab_cold	    as pc_pdi_thick_slab_cold,
	lpiece.pdi_width_slab_cold	    as pc_pdi_width_slab_cold,
	lpiece.pdi_wght_slab		    as pc_pdi_wght_slab,
	
	lpiece.pdi_temp_strip		    as pc_pdi_temp_strip,
	lpiece.pdi_thick_strip_cold	    as pc_pdi_thick_strip_cold,
	lpiece.pdi_width_strip_cold	    as pc_pdi_width_strip_cold,
	lpiece.pdi_wght_coil		    as pc_pdi_wght_coil,
	
	lpiece.pred_wght_coil		    as pc_pred_wght_coil,
	lpiece.status_heatcover		    as pc_status_heatcover,
	lpiece.steel_grade		    as pc_steel_grade,
	lpiece.steel_grp                    as pc_steel_grp,
	lpiece.temp_entry_f1		    as pc_temp_entry_f1,
	lpiece.time_stamp                   as pc_time_stamp,
	lpiece.time_stamp_adp_psc_fm        as pc_time_stamp_adp_psc_fm,
	lpiece.time_stamp_chrg		    as pc_time_stamp_chrg,
	lpiece.time_stamp_disch		    as pc_time_stamp_disch,
	lpiece.time_stamp_drop_out_fm       as pc_time_stamp_drop_out_fm,
	lpiece.time_stamp_drop_out_r1_last  as pc_time_stamp_drop_out_r1_last,
	lpiece.time_stamp_drop_out_r2_last  as pc_time_stamp_drop_out_r2_last,
	lpiece.time_stamp_fin		    as pc_time_stamp_fin,
	lpiece.time_stamp_log_rep	    as pc_time_stamp_log_rep,
	lpiece.time_stamp_pick_fm	    as pc_time_stamp_pick_fm,
	lpiece.time_stamp_pick_r1_first     as pc_time_stamp_pick_r1_first,
	lpiece.time_stamp_pick_r2_first     as pc_time_stamp_pick_r2_first,
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

	lpiece.pos_furn         as lpiece_pos_furn,
	lpiece.pred_wght_coil	as lpiece_pred_wght_coil,
	lpiece.prod_order_no	as lpiece_prod_order_no,
	lpiece.product_class	as lpiece_product_class,
	lpiece.round            as lpiece_round,
	lpiece.sequence_no      as lpiece_sequence_no,

/* *** Furnace mes_measurementdata Added 20170220 *** */ 
	mes_meas.fcenum           as mes_meas_fcenum,
	mes_meas.coil_id          as mes_meas_coil_id,
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
	mes_meas.totaltimefce     as mes_meas_totaltimefce,
	mes_meas.chgtemp          as mes_meas_chtemp, 
	mes_meas.tgtdchtemp       as mes_meas_tgtdchtemp,
	mes_meas.actdchtemp	  as mes_meas_actdchtemp,
	mes_meas.slabgapmillside  as mes_meas_slabgapmillside, 

/* *** Roughing Mill Intermediate Rolled Piece Profile "O"-Overall calvert.lstat_pfg *** */
	lstat_pfgO.id_piece       as lst_pfgO_id_piece,
	lstat_pfgO.id_segment	  as lst_pfgO_id_segment,

	lstat_pfgO.trg_thick_hot  as lst_pfgO_trg_thick_hot,
	lstat_pfgO.trg_width_hot  as lst_pfgO_trg_width_hot,
	lstat_pfgO.trg_temp       as lst_pfgO_trg_temp,

	lstat_pfgO.thick_cold	  as lst_pfgO_thick_cold,
	lstat_pfgO.thick_hot      as lst_pfgO_thick_hot,
	lstat_pfgO.thick_hot_min  as lst_pfgO_thick_hot_min,
	lstat_pfgO.thick_hot_max  as lst_pfgO_thick_hot_max,
	lstat_pfgO.thick_hot_std  as lst_pfgO_thick_hot_std,
	lstat_pfgO.limit_thick_hot_up  as lst_pfgO_lm_thick_hot_up,
	lstat_pfgO.limit_thick_hot_low as lst_pfgO_lm_thick_hot_low,

	lstat_pfgO.width_hot      as lst_pfgO_width_hot,
	lstat_pfgO.width_hot_min  as lst_pfgO_width_hot_min,
	lstat_pfgO.width_hot_max  as lst_pfgO_width_hot_max,
	lstat_pfgO.width_hot_std  as lst_pfgO_width_hot_std,
	lstat_pfgO.limit_width_hot_up  as lst_pfgO_lmt_width_hot_up,
	lstat_pfgO.limit_width_hot_low as lst_pfgO_lmt_width_hot_low,

	lstat_pfgO.dev_cl        as lst_pfgO_dev_cl,
	lstat_pfgO.dev_cl_min	 as lst_pfgO_dev_cl_min,
	lstat_pfgO.dev_cl_max	 as lst_pfgO_dev_cl_max,
	lstat_pfgO.dev_cl_std	 as lst_pfgO_dev_cl_std,

	lstat_pfgO.temp		 as lst_pfgO_temp,
	lstat_pfgO.temp_min	 as lst_pfgO_temp_min,
	lstat_pfgO.temp_max	 as lst_pfgO_temp_max,
	lstat_pfgO.temp_std	 as lst_pfgO_temp_std,
	lstat_pfgO.limit_temp_up  as lst_pfgO_lmt_temp_up,
	lstat_pfgO.limit_temp_low as lst_pfgO_lmt_temp_low,
	lstat_pfgO.time_stamp     as lst_pfgO_time_stamp,

/* *** Roughing Mill Intermediate Rolled Piece Profile 'H'-Coils Head calvert.lst_pfg *** */
	lstat_pfgH.id_piece       as lst_pfgH_id_piece,
	lstat_pfgH.id_segment	  as lst_pfgH_id_segment,

	lstat_pfgH.trg_thick_hot  as lst_pfgH_trg_thick_hot,
	lstat_pfgH.trg_width_hot  as lst_pfgH_trg_width_hot,
	lstat_pfgH.trg_temp       as lst_pfgH_trg_temp,

	lstat_pfgH.thick_cold	  as lst_pfgH_thick_cold,
	lstat_pfgH.thick_hot      as lst_pfgH_thick_hot,
	lstat_pfgH.thick_hot_min  as lst_pfgH_thick_hot_min,
	lstat_pfgH.thick_hot_max  as lst_pfgH_thick_hot_max,
	lstat_pfgH.thick_hot_std  as lst_pfgH_thick_hot_std,
	lstat_pfgH.limit_thick_hot_up  as lst_pfgH_lm_thick_hot_up,
	lstat_pfgH.limit_thick_hot_low as lst_pfgH_lm_thick_hot_low,

	lstat_pfgH.width_hot      as lst_pfgH_width_hot,
	lstat_pfgH.width_hot_min  as lst_pfgH_width_hot_min,
	lstat_pfgH.width_hot_max  as lst_pfgH_width_hot_max,
	lstat_pfgH.width_hot_std  as lst_pfgH_width_hot_std,
	lstat_pfgH.limit_width_hot_up  as lst_pfgH_lmt_width_hot_up,
	lstat_pfgH.limit_width_hot_low as lst_pfgH_lmt_width_hot_low,

	lstat_pfgH.dev_cl        as lst_pfgH_dev_cl,
	lstat_pfgH.dev_cl_min	 as lst_pfgH_dev_cl_min,
	lstat_pfgH.dev_cl_max	 as lst_pfgH_dev_cl_max,
	lstat_pfgH.dev_cl_std	 as lst_pfgH_dev_cl_std,

	lstat_pfgH.temp		 as lst_pfgH_temp,
	lstat_pfgH.temp_min	 as lst_pfgH_temp_min,
	lstat_pfgH.temp_max	 as lst_pfgH_temp_max,
	lstat_pfgH.temp_std	 as lst_pfgH_temp_std,
	lstat_pfgH.limit_temp_up  as lst_pfgH_lmt_temp_up,
	lstat_pfgH.limit_temp_low as lst_pfgH_lmt_temp_low,
	lstat_pfgH.time_stamp     as lst_pfgH_time_stamp,

/* *** Roughing Mill Intermediate Rolled Piece Profile "B"-Coils Body calvert.lst_pfg *** */
	lstat_pfgB.id_piece       as lst_pfgB_id_piece,
	lstat_pfgB.id_segment	  as lst_pfgB_id_segment,

	lstat_pfgB.trg_thick_hot  as lst_pfgB_trg_thick_hot,
	lstat_pfgB.trg_width_hot  as lst_pfgB_trg_width_hot,
	lstat_pfgB.trg_temp       as lst_pfgB_trg_temp,

	lstat_pfgB.thick_cold	  as lst_pfgB_thick_cold,
	lstat_pfgB.thick_hot      as lst_pfgB_thick_hot,
	lstat_pfgB.thick_hot_min  as lst_pfgB_thick_hot_min,
	lstat_pfgB.thick_hot_max  as lst_pfgB_thick_hot_max,
	lstat_pfgB.thick_hot_std  as lst_pfgB_thick_hot_std,
	lstat_pfgB.limit_thick_hot_up  as lst_pfgB_lm_thick_hot_up,
	lstat_pfgB.limit_thick_hot_low as lst_pfgB_lm_thick_hot_low,

	lstat_pfgB.width_hot      as lst_pfgB_width_hot,
	lstat_pfgB.width_hot_min  as lst_pfgB_width_hot_min,
	lstat_pfgB.width_hot_max  as lst_pfgB_width_hot_max,
	lstat_pfgB.width_hot_std  as lst_pfgB_width_hot_std,
	lstat_pfgB.limit_width_hot_up  as lst_pfgB_lmt_width_hot_up,
	lstat_pfgB.limit_width_hot_low as lst_pfgB_lmt_width_hot_low,

	lstat_pfgB.dev_cl        as lst_pfgB_dev_cl,
	lstat_pfgB.dev_cl_min	 as lst_pfgB_dev_cl_min,
	lstat_pfgB.dev_cl_max	 as lst_pfgB_dev_cl_max,
	lstat_pfgB.dev_cl_std	 as lst_pfgB_dev_cl_std,

	lstat_pfgB.temp		 as lst_pfgB_temp,
	lstat_pfgB.temp_min	 as lst_pfgB_temp_min,
	lstat_pfgB.temp_max	 as lst_pfgB_temp_max,
	lstat_pfgB.temp_std	 as lst_pfgB_temp_std,
	lstat_pfgB.limit_temp_up  as lst_pfgB_lmt_temp_up,
	lstat_pfgB.limit_temp_low as lst_pfgB_lmt_temp_low,
	lstat_pfgB.time_stamp     as lst_pfgB_time_stamp,


/* *** Adding Information from the calvert.lstat_exit_fm Table 
	   (Temperature, Center Line Deviation, Thickness "O"-Overall
*** */
	lst_exit_fmO.id_piece   as lst_exit_fmO_id_piece,      
	lst_exit_fmO.id_segment	as lst_exit_fmO_id_segment,

	lst_exit_fmO.thick_hot	as lst_exit_fmO_thick_hot,
	lst_exit_fmO.dev_cl	as lst_exit_fmO_dev_cl,
	lst_exit_fmO.dev_cl_min	as lst_exit_fmO_dev_cl_min,
	lst_exit_fmO.dev_cl_max	as lst_exit_fmO_dev_cl_max,
	lst_exit_fmO.dev_cl_std	as lst_exit_fmO_dev_cl_std,
	lst_exit_fmO.width_hot	as lst_exit_fmO_width_hot,

	lst_exit_fmO.trg_temp	as lst_exit_fmO_trg_temp,
	lst_exit_fmO.temp	as lst_exit_fmO_temp,
	lst_exit_fmO.temp_min	as lst_exit_fmO_temp_min,
	lst_exit_fmO.temp_max	as lst_exit_fmO_temp_max,
	lst_exit_fmO.temp_std	as lst_exit_fmO_temp_std,
	lst_exit_fmO.limit_temp_up  as lst_exit_fmO_lmt_temp_up,
	lst_exit_fmO.limit_temp_low as lst_exit_fmO_lmt_temp_low,

/* *** Adding Information from the calvert.lstat_exit_fm Table 
	   (Temperature, Center Line Deviation, Thickness "H"-Coill Head
*** */
	lst_exit_fmH.id_piece   as lst_exit_fmH_id_piece,      
	lst_exit_fmH.id_segment	as lst_exit_fmH_id_segment,

	lst_exit_fmH.thick_hot	as lst_exit_fmH_thick_hot,
	lst_exit_fmH.dev_cl	as lst_exit_fmH_dev_cl,
	lst_exit_fmH.dev_cl_min	as lst_exit_fmH_dev_cl_min,
	lst_exit_fmH.dev_cl_max	as lst_exit_fmH_dev_cl_max,
	lst_exit_fmH.dev_cl_std	as lst_exit_fmH_dev_cl_std,
	lst_exit_fmH.width_hot	as lst_exit_fmH_width_hot,

	lst_exit_fmH.trg_temp	as lst_exit_fmH_trg_temp,
	lst_exit_fmH.temp	as lst_exit_fmH_temp,
	lst_exit_fmH.temp_min	as lst_exit_fmH_temp_min,
	lst_exit_fmH.temp_max	as lst_exit_fmH_temp_max,
	lst_exit_fmH.temp_std	as lst_exit_fmH_temp_std,
	lst_exit_fmH.limit_temp_up  as lst_exit_fmH_lmt_temp_up,
	lst_exit_fmH.limit_temp_low as lst_exit_fmH_lmt_temp_low,

/* *** Adding Information from the calvert.lstat_exit_fm Table 
	   (Temperature, Center Line Deviation, Thickness "B"-Coill Body
*** */
	lst_exit_fmB.id_piece   as lst_exit_fmB_id_piece,      
	lst_exit_fmB.id_segment	as lst_exit_fmB_id_segment,

	lst_exit_fmB.thick_hot	as lst_exit_fmB_thick_hot,
	lst_exit_fmB.dev_cl	as lst_exit_fmB_dev_cl,
	lst_exit_fmB.dev_cl_min	as lst_exit_fmB_dev_cl_min,
	lst_exit_fmB.dev_cl_max	as lst_exit_fmB_dev_cl_max,
	lst_exit_fmB.dev_cl_std	as lst_exit_fmB_dev_cl_std,
	lst_exit_fmB.width_hot	as lst_exit_fmB_width_hot,

	lst_exit_fmB.trg_temp	as lst_exit_fmB_trg_temp,
	lst_exit_fmB.temp	as lst_exit_fmB_temp,
	lst_exit_fmB.temp_min	as lst_exit_fmB_temp_min,
	lst_exit_fmB.temp_max	as lst_exit_fmB_temp_max,
	lst_exit_fmB.temp_std	as lst_exit_fmB_temp_std,
	lst_exit_fmB.limit_temp_up  as lst_exit_fmB_lmt_temp_up,
	lst_exit_fmB.limit_temp_low as lst_exit_fmB_lmt_temp_low,

/* *** Adding calvert.lsetup_piece_rm (FM Set-Up Table) 20170410 *** */
/* *** Adding calvert.lsetup_piece_rm (FM Set-Up Table) 20170410 *** */
	lstp_rm.id_piece            as lstp_rm_id_piece,          
	lstp_rm.id_setup_rm         as lstp_rm_id_setup_rm,
	lstp_rm.thick_slab_hot	    as lstp_rm_thick_slab_hot,
	lstp_rm.width_slab_hot	    as lstp_rm_width_slab_hot,
	lstp_rm.len_slab_hot	    as lstp_rm_len_slab_hot,
	lstp_rm.width_tbar_cold	    as lstp_rm_width_tbar_cold,
	lstp_rm.width_tbar_hot	    as lstp_rm_width_tbar_hot,
	lstp_rm.thick_tbar_cold	    as lstp_rm_thick_tbar_cold,
	lstp_rm.thick_tbar_hot	    as lstp_rm_thick_tbar_hot,
	lstp_rm.sel_mode_ssp	    as lstp_rm_sel_mode_ssp,
	lstp_rm.thick_ssp_exit	    as lstp_rm_thick_ssp_exit,
	lstp_rm.max_thick_ssp_exit  as lstp_rm_max_thick_ssp_exit,
	lstp_rm.width_ssp_exit	    as lstp_rm_width_ssp_exit,
	lstp_rm.len_ssp_exit	    as lstp_rm_len_ssp_exit,

/* *** Adding calvert.lsetup_piece_fm (FM Set-Up Table) 20170324 *** */
	lstp_fm.id_piece           as lstp_fm_id_piece,
	lstp_fm.id_setup_fm	   as lstp_fm_id_setup_fm,

	lstp_fm.thick_strip_cold   as lstp_fm_thick_strip_cold,
	lstp_fm.thick_strip_hot	   as lstp_fm_thick_strip_hot,
	lstp_fm.width_strip_cold   as lstp_fm_width_strip_cold,
	lstp_fm.width_strip_hot	   as lstp_fm_width_strip_hot,
	lstp_fm.len_strip_cold	   as lstp_fm_len_strip_cold,
	lstp_fm.len_strip_hot	   as lstp_fm_len_strip_hot,
	lstp_fm.trg_temp_strip	   as lstp_fm_trg_temp_strip,

	lstp_fm.trg_temp_coil	   as lstp_fm_trg_temp_coil,
	lstp_fm.temp_strip	   as lstp_fm_temp_strip,

	lstp_fm.trg_thick_strip_cold   as lstp_fm_trg_thick_strip_cold,
	lstp_fm.min_dev_thick_allowed  as lstp_fm_min_dev_thick_allowed,
	lstp_fm.max_dev_thick_allowed  as lstp_fm_max_dev_thick_allowed,
	lstp_fm.min_dev_width_allowed  as lstp_fm_min_dev_width_allowed,
	lstp_fm.max_dev_width_allowed  as lstp_fm_max_dev_width_allowed,
	lstp_fm.trg_width_strip_cold   as lstp_fm_trg_width_strip_cold,
	lstp_fm.max_dev_prof_allowed   as lstp_fm_max_prof_allowed,
	lstp_fm.min_dev_prof_allowed   as lstp_fm_min_prof_allowed,
	lstp_fm.min_dev_flat_allowed   as lstp_fm_min_flat_allowed,
	lstp_fm.max_dev_temp_strip_allowed as lstp_fm_maxdev_temp_strip_allowed,
	lstp_fm.min_dev_temp_coil_allowed  as lstp_fm_mindev_temp_coil_allowed,
	lstp_fm.max_dev_temp_coil_allowed  as lstp_fm_maxdev_temp_coil_allowed,

	lstp_fm.prof_strip	   as lstp_fm_prof_strip,
	lstp_fm.flat_strip	   as lstp_fm_flat_strip,

	lstp_fm.max_wedge_allowed      as lstp_fm_max_wedge_allowed,
	lstp_fm.max_dev_flat_allowed   as lstp_fm_max_dev_flat_allowed,
	lstp_fm.min_dev_temp_strip_allowed as lstp_fm_mindev_temp_strip_allowed,
	lstp_fm.max_camber_allowed	   as lstp_fm_maxdev_camber_allowed,
	lstp_fm.temp_dsch_slab		   as lstp_fm_temp_dsch_slab,

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
	lsetup_dc.strgy_cool           as lstp_dc_strgy_cool,  
	lsetup_dc.len_strip            as lstp_dc_len_strip,
	lsetup_dc.dia_coil             as lstp_dc_dia_coil,
	lsetup_dc.width_coil	       as lstp_dc_width_coil,
	lsetup_dc.wght_coil            as lstp_dc_wght_coil,
	lsetup_dc.len_head_strip          as lstp_dc_len_head_strip,
	lsetup_dc.len_head_strip_un_cool  as lstp_dc_len_head_strip_un_cool,
	lsetup_dc.len_tail_strip          as lstp_dc_len_tail_strip,
	lsetup_dc.len_tail_strip_un_cool  as lstp_dc_len_tail_strip_un_cool,
	lsetup_dc.nom_strength_yield   as lstp_dc_nom_strength_yield,
	lsetup_dc.trg_temp_coil	       as lstp_dc_trg_temp_coil,
	lsetup_dc.trg_temp_head_coil   as lstp_dc_trg_temp_head_coil,
	lsetup_dc.trg_temp_tail_coil   as lstp_dc_trg_temp_tail_coil,
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

/* *** Adding Information from the calvert.lst_widthO_dc Table "O"-Overall *** */
	lst_widthO.id_piece       as lst_widthO_id_piece,
	lst_widthO.id_segment     as lst_widthO_id_segment,
	lst_widthO.time_stamp     as lst_widthO_time_stamp,
	lst_widthO.temp           as lst_widthO_temp,
	lst_widthO.dev_cl         as lst_widthO_dev_cl, 
	lst_widthO.width_hot      as lst_widthO_width_hot,
	
	lst_widthO.width_cold     as lst_widthO_width_cold,
	lst_widthO.width_cold_min as lst_widthO_width_cold_min,
	lst_widthO.width_cold_max as lst_widthO_width_cold_max,
	lst_widthO.width_cold_std as lst_widthO_width_cold_std,

/* *** Adding Information from the calvert.lst_widthO_dc Table "H"-Coil Head *** */
	lst_widthH.id_piece       as lst_widthH_id_piece,
	lst_widthH.id_segment     as lst_widthH_id_segment,
	lst_widthH.time_stamp     as lst_widthH_time_stamp,
	lst_widthH.temp           as lst_widthH_temp,
	lst_widthH.dev_cl         as lst_widthH_dev_cl, 
	lst_widthH.width_hot      as lst_widthH_width_hot,
	
	lst_widthH.width_cold     as lst_widthH_width_cold,
	lst_widthH.width_cold_min as lst_widthH_width_cold_min,
	lst_widthH.width_cold_max as lst_widthH_width_cold_max,
	lst_widthH.width_cold_std as lst_widthH_width_cold_std,	

/* *** Adding Information from the calvert.lst_widthO_dc Table "B"-Coil Body *** */
	lst_widthB.id_piece       as lst_widthB_id_piece,
	lst_widthB.id_segment     as lst_widthB_id_segment,
	lst_widthB.time_stamp     as lst_widthB_time_stamp,
	lst_widthB.temp           as lst_widthB_temp,
	lst_widthB.dev_cl         as lst_widthB_dev_cl, 
	lst_widthB.width_hot      as lst_widthB_width_hot,
	
	lst_widthB.width_cold     as lst_widthB_width_cold,
	lst_widthB.width_cold_min as lst_widthB_width_cold_min,
	lst_widthB.width_cold_max as lst_widthB_width_cold_max,
	lst_widthB.width_cold_std as lst_widthB_width_cold_std,


	/* *** Adding Information from the calvert.lstat_temp_coiler Table "O"-Overall *** */
	lst_temp_dcO.id_piece      as lst_temp_dcO_id_piece,
	lst_temp_dcO.id_segment    as lst_temp_dcO_id_segment,      /* (Values: T;O;B;H;); */
	lst_temp_dcO.temp          as lst_temp_dcO_temp,
	lst_temp_dcO.temp_min	   as lst_temp_dcO_temp_min,
	lst_temp_dcO.temp_max	   as lst_temp_dcO_temp_max,
	lst_temp_dcO.temp_std	   as lst_temp_dcO_temp_std,
	lst_temp_dcO.limit_temp_up as lst_temp_dcO_limit_temp_up,
	lst_temp_dcO.limit_temp_low           as lst_temp_dcO_limit_temp_low,
	lst_temp_dcO.count_temp_exc_limit_up  as lst_temp_dcO_exc_limit_up,
	lst_temp_dcO.count_temp_exc_limit_low as lst_temp_dcO_exc_limit_low,
	lst_temp_dcO.count_temp_in_limit      as lst_temp_dcO_count_temp_in_limit,
	lst_temp_dcO.time_stamp     as lst_temp_dcO_time_stamp,
	lst_temp_dcO.min_no_segment as lst_temp_dcO_min_no_segment,
	lst_temp_dcO.max_no_segment as lst_temp_dcO_max_no_segment,
	lst_temp_dcO.count_meas     as lst_temp_dcO_count_meas,
	lst_temp_dcO.trg_temp       as lst_temp_dcO_trg_temp,
	lst_temp_dcO.temp_scanner   as lst_temp_dcO_temp_scanner,
	lst_temp_dcO.temp_scanner_std  as lst_temp_dcO_temp_scanner_std,
	lst_temp_dcO.temp_bot_low      as lst_temp_dcO_temp_bot_low,
	lst_temp_dcO.temp_bot_low_std  as lst_temp_dcO_temp_bot_low_std,
	lst_temp_dcO.temp_bot_high     as lst_temp_dcO_temp_bot_high,
	lst_temp_dcO.temp_bot_high_std as lst_temp_dcO_temp_bot_high_std,
	
/* *** Adding Information from the calvert.lstat_temp_coiler Table "H"-Coil Head *** */
	lst_temp_dcH.id_piece      as lst_temp_dcH_id_piece,
	lst_temp_dcH.id_segment    as lst_temp_dcH_id_segment,      /* (Values: T;O;B;H;); */
	lst_temp_dcH.temp          as lst_temp_dcH_temp,
	lst_temp_dcH.temp_min	   as lst_temp_dcH_temp_min,
	lst_temp_dcH.temp_max	   as lst_temp_dcH_temp_max,
	lst_temp_dcH.temp_std	   as lst_temp_dcH_temp_std,
	lst_temp_dcH.limit_temp_up as lst_temp_dcH_limit_temp_up,
	lst_temp_dcH.limit_temp_low            as lst_temp_dcH_limit_temp_low,
	lst_temp_dcH.count_temp_exc_limit_up   as lst_temp_dcH_exc_limit_up,
	lst_temp_dcH.count_temp_exc_limit_low  as lst_temp_dcH_exc_limit_low,
	lst_temp_dcH.count_temp_in_limit       as lst_temp_dcH_count_temp_in_limit,
	lst_temp_dcH.time_stamp     as lst_temp_dcH_time_stamp,
	lst_temp_dcH.min_no_segment as lst_temp_dcH_min_no_segment,
	lst_temp_dcH.max_no_segment as lst_temp_dcH_max_no_segment,
	lst_temp_dcH.count_meas     as lst_temp_dcH_count_meas,
	lst_temp_dcH.trg_temp       as lst_temp_dcH_trg_temp,
	lst_temp_dcH.temp_scanner   as lst_temp_dcH_temp_scanner,
	lst_temp_dcH.temp_scanner_std as lst_temp_dcH_temp_scanner_std,
	lst_temp_dcH.temp_bot_low     as lst_temp_dcH_temp_bot_low,
	lst_temp_dcH.temp_bot_low_std as lst_temp_dcH_temp_bot_low_std,
	lst_temp_dcH.temp_bot_high    as lst_temp_dcH_temp_bot_high,
	lst_temp_dcH.temp_bot_high_std as lst_temp_dcH_temp_bot_high_std,

/* *** Adding Information from the calvert.lstat_temp_coiler Table "B"-Coil Body *** */
	lst_temp_dcB.id_piece      as lst_temp_dcB_id_piece,
	lst_temp_dcB.id_segment    as lst_temp_dcB_id_segment,      /* (Values: T;O;B;H;); */
	lst_temp_dcB.temp          as lst_temp_dcB_temp,
	lst_temp_dcB.temp_min	   as lst_temp_dcB_temp_min,
	lst_temp_dcB.temp_max	   as lst_temp_dcB_temp_max,
	lst_temp_dcB.temp_std	   as lst_temp_dcB_temp_std,
	lst_temp_dcB.limit_temp_up as lst_temp_dcB_limit_temp_up,
	lst_temp_dcB.limit_temp_low            as lst_temp_dcB_limit_temp_low,
	lst_temp_dcB.count_temp_exc_limit_up   as lst_temp_dcB_exc_limit_up,
	lst_temp_dcB.count_temp_exc_limit_low  as lst_temp_dcB_exc_limit_low,
	lst_temp_dcB.count_temp_in_limit       as lst_temp_dc_count_temp_in_limit,
	lst_temp_dcB.time_stamp     as lst_temp_dcB_time_stamp,
	lst_temp_dcB.min_no_segment as lst_temp_dcB_min_no_segment,
	lst_temp_dcB.max_no_segment as lst_temp_dcB_max_no_segment,
	lst_temp_dcB.count_meas     as lst_temp_dcB_count_meas,
	lst_temp_dcB.trg_temp       as lst_temp_dcB_trg_temp,
	lst_temp_dcB.temp_scanner   as lst_temp_dcB_temp_scanner,
	lst_temp_dcB.temp_scanner_std as lst_temp_dcB_temp_scanner_std,
	lst_temp_dcB.temp_bot_low     as lst_temp_dcB_temp_bot_low,
	lst_temp_dcB.temp_bot_low_std as lst_temp_dcB_temp_bot_low_std,
	lst_temp_dcB.temp_bot_high    as lst_temp_dcB_temp_bot_high,
	lst_temp_dcB.temp_bot_high_std as lst_temp_dcB_temp_bot_high_std,
	%str(%'&coil_loc%'||'-'||%'&loc_name%')   as coil_location,
	shift.time_stamp_shift,
	shift.chrg_shift,
	shift.disch_shift,
	shift.fin_shift,
	shift.shift_part,
	suppl.supply_code,
	suppl.supplier,
    	suppl.comment

  FROM calvert.lpiece lpiece 
   LEFT OUTER JOIN calvert.mes_material materials
    on materials.coil_id = lpiece.id_coil
    
     LEFT OUTER JOIN calvert.mes_measurementdata  mes_meas
       on mes_meas.coil_id = lpiece.id_coil

       LEFT OUTER JOIN calvert.lstat_pfg lstat_pfgO
         on lstat_pfgO.id_piece = lpiece.id_coil
        and lstat_pfgO.id_segment = 'O' 

       LEFT OUTER JOIN calvert.lstat_pfg lstat_pfgH
         on lstat_pfgH.id_piece = lpiece.id_coil
        and lstat_pfgH.id_segment = 'H' 

       LEFT OUTER JOIN calvert.lstat_pfg lstat_pfgB
         on lstat_pfgB.id_piece = lpiece.id_coil
        and lstat_pfgB.id_segment = 'B' 

        LEFT OUTER JOIN calvert.lstat_exit_fm lst_exit_fmO
          on lst_exit_fmO.id_piece = lpiece.id_coil
         and lst_exit_fmO.id_segment = 'O' 

        LEFT OUTER JOIN calvert.lstat_exit_fm lst_exit_fmH
          on lst_exit_fmH.id_piece = lpiece.id_coil
         and lst_exit_fmH.id_segment = 'H' 

        LEFT OUTER JOIN calvert.lstat_exit_fm lst_exit_fmB
          on lst_exit_fmB.id_piece = lpiece.id_coil
         and lst_exit_fmB.id_segment = 'B' 

          LEFT OUTER JOIN calvert.lsetup_piece_rm lstp_rm
            on lstp_rm.id_piece = lpiece.id_coil
           and lstp_rm.id_setup_rm = lpiece.id_setup_rm_used 

          LEFT OUTER JOIN calvert.lsetup_piece_fm lstp_fm
            on lstp_fm.id_piece = lpiece.id_coil
           and lstp_fm.id_setup_fm = lpiece.id_setup_used_fm 

          LEFT OUTER JOIN calvert.lsetup_csc lsetup_csc
            on lsetup_csc.id_piece = lpiece.id_coil
           and lsetup_csc.id_setup = lpiece.id_setup_used_fm 

            LEFT OUTER JOIN calvert.lsetup_dc lsetup_dc
              on lsetup_dc.id_piece = lpiece.id_coil
             and lsetup_dc.id_setup = lpiece.id_setup_used_fm 

              LEFT OUTER JOIN calvert.lstat_width_dc lst_widthO
                 on lst_widthO.id_piece = lpiece.id_coil
	            and lst_widthO.id_segment = 'O'

              LEFT OUTER JOIN calvert.lstat_width_dc lst_widthH
                 on lst_widthH.id_piece = lpiece.id_coil
	            and lst_widthH.id_segment = 'H'

              LEFT OUTER JOIN calvert.lstat_width_dc lst_widthB
                 on lst_widthB.id_piece = lpiece.id_coil
	            and lst_widthB.id_segment = 'B'

                LEFT OUTER JOIN calvert.lstat_temp_coiler lst_temp_dcO
                  on lst_temp_dcO.id_piece = lpiece.id_coil
	             and lst_temp_dcO.id_segment = 'O'

                LEFT OUTER JOIN calvert.lstat_temp_coiler lst_temp_dcH
                  on lst_temp_dcH.id_piece = lpiece.id_coil
	             and lst_temp_dcH.id_segment = 'H'

                LEFT OUTER JOIN calvert.lstat_temp_coiler lst_temp_dcB
                  on lst_temp_dcB.id_piece = lpiece.id_coil
	             and lst_temp_dcB.id_segment = 'B'
	          
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
   BY mt_coil_id;
    IF last.mt_coil_id; 

slab_supplier = PUT(SUBSTR(pc_id_foreign,1,1),$slb_suppl.); 
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
  FROM /* calvert.ak_3cb2021_steel my_file, */
       calvert.lmeas_csc mcsc
 /* WHERE mcsc.id_piece = my_file.coil_id */
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

	lstat_fm.tension		 as lstat_fm6_tension,
	lstat_fm.angle_looper_calib	 as lstat_fm6_angle_looper_calib
  FROM calvert.lstat_fm  lstat_fm
  WHERE /* lstat_fm.id_piece = '1157346070' and */ 
        lstat_fm.stand_id IN(6)
  ORDER BY lstat_fm.id_piece /*, lstat_fm.id_segment */
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




/* *** Adding calvert.lmeas_dc (Down Coiler Tension Table) Started 2/01/2017 *** */
/* *** Pull Pinch_Roll Average Speed *** */
PROC SQL;
CONNECT TO ASTER (USER=ak186133 PASSWORD=ak186133
                  SERVER='10.25.98.20' DATABASE=calvert PORT=2406);
CREATE TABLE lmeas_dc as 
SELECT * FROM CONNECTION TO ASTER 
 (SELECT DISTINCT
		lmeas_dc.id_piece, 
		lmeas_dc.time_stamp, 
		lmeas_dc.dc_used, 
		lmeas_dc.force_sg, 
		lmeas_dc.force_sg_os, 
		lmeas_dc.force_sg_ds, 
		lmeas_dc.gap_sg, 
		lmeas_dc.force_pr, 
		lmeas_dc.force_pr_os, 
		lmeas_dc.force_pr_ds, 
		lmeas_dc.diff_force_pr, 
		lmeas_dc.level_pr, 
		lmeas_dc.speed_top_pr, 
		lmeas_dc.speed_bot_pr, 
		lmeas_dc.tens_mandrel, 
		lmeas_dc.torque_mandrel, 
		lmeas_dc.expan_mandrel, 
		lmeas_dc.speed_mandrel, 
		lmeas_dc.force_wr1, 
		lmeas_dc.force_wr2, 
		lmeas_dc.force_wr3, 
		lmeas_dc.pos_wr1, 
		lmeas_dc.pos_wr2, 
		lmeas_dc.pos_wr3
FROM calvert.lmeas_dc lmeas_dc
/* 
WHERE mcsc.id_piece = my_file.coil_id
  GROUP BY mcsc.id_piece
*/
ORDER BY lmeas_dc.id_piece,lmeas_dc.time_stamp
);

DISCONNECT FROM ASTER;
QUIT;


PROC FREQ DATA=lmeas_dc NOPRINT;
 TABLE id_piece / NOROW NOCOL NOCUM NOPERCENT OUT=dcmesr_count;
run;


DATA dc_mpoints;
 MERGE lmeas_dc (IN=lmesdc)
       dcmesr_count (IN=cnt);
  BY id_piece;
   IF lmesdc & cnt;
IF first.id_piece THEN m_count=1; 
  ELSE m_count + 1;
IF m_count <= 0.05*count THEN coil_location = 'H';
 ELSE IF m_count > 0.95*count THEN coil_location = 'T';
  ELSE coil_location = 'B'; 
;
run;


PROC MEANS DATA=dc_mpoints MAXDEC=1 NOPRINT NWAY MEAN;  *MEAN MIN MAX STD;
  BY id_piece;
  ID dc_used;
    VAR force_sg force_sg_os force_sg_ds gap_sg force_pr force_pr_os 
		force_pr_ds diff_force_pr level_pr speed_top_pr speed_bot_pr tens_mandrel torque_mandrel 
		expan_mandrel speed_mandrel force_wr1 force_wr2 force_wr3 pos_wr1 pos_wr2 pos_wr3;
   OUTPUT OUT=dc_coillocO (DROP=_TYPE_ _FREQ_)
          MEAN=dcmeanO_force_sg dcmeanO_force_sg_os dcmeanO_force_sg_ds dcmeanO_gap_sg dcmeanO_force_pr dcmeanO_force_pr_os 
		dcmeanO_force_pr_ds dcmeanO_diff_force_pr dcmeanO_level_pr dcmeanO_speed_top_pr dcmeanO_speed_bot_pr 
		dcmeanO_tens_mandrel dcmeanO_torque_mandrel dcmeanO_expan_mandrel dcmeanO_speed_mandrel dcmeanO_force_wr1 
   		dcmeanO_force_wr2 dcmeanO_force_wr3 dcmeanO_pos_wr1 dcmeanO_pos_wr2 dcmeanO_pos_wr3
;
run;

PROC MEANS DATA=dc_mpoints MAXDEC=1 NOPRINT NWAY MEAN;  *MEAN MIN MAX STD;
 WHERE coil_location = 'B';
  BY id_piece;
    VAR force_sg force_sg_os force_sg_ds gap_sg force_pr force_pr_os 
	force_pr_ds diff_force_pr level_pr speed_top_pr speed_bot_pr tens_mandrel torque_mandrel 
	expan_mandrel speed_mandrel force_wr1 force_wr2 force_wr3 pos_wr1 pos_wr2 pos_wr3;
   OUTPUT OUT=dc_coillocB (DROP=_TYPE_ _FREQ_)
          MEAN=dcmeanB_force_sg dcmeanB_force_sg_os dcmeanB_force_sg_ds dcmeanB_gap_sg dcmeanB_force_pr dcmeanB_force_pr_os 
		dcmeanB_force_pr_ds dcmeanB_diff_force_pr dcmeanB_level_pr dcmeanB_speed_top_pr dcmeanB_speed_bot_pr 
		dcmeanB_tens_mandrel dcmeanB_torque_mandrel dcmeanB_expan_mandrel dcmeanB_speed_mandrel dcmeanB_force_wr1 
  		dcmeanB_force_wr2 dcmeanB_force_wr3 dcmeanB_pos_wr1 dcmeanB_pos_wr2 dcmeanB_pos_wr3
;
run;

PROC MEANS DATA=dc_mpoints MAXDEC=1 NOPRINT NWAY MEAN;  *MEAN MIN MAX STD;
 WHERE coil_location = 'H';
  BY id_piece;
    VAR force_sg force_sg_os force_sg_ds gap_sg force_pr force_pr_os 
		force_pr_ds diff_force_pr level_pr speed_top_pr speed_bot_pr tens_mandrel torque_mandrel 
		expan_mandrel speed_mandrel force_wr1 force_wr2 force_wr3 pos_wr1 pos_wr2 pos_wr3;
   OUTPUT OUT=dc_coillocH (DROP=_TYPE_ _FREQ_)
          MEAN=dcmeanH_force_sg dcmeanH_force_sg_os dcmeanH_force_sg_ds dcmeanH_gap_sg dcmeanH_force_pr dcmeanH_force_pr_os 
		dcmeanH_force_pr_ds dcmeanH_diff_force_pr dcmeanH_level_pr dcmeanH_speed_top_pr dcmeanH_speed_bot_pr 
		dcmeanH_tens_mandrel dcmeanH_torque_mandrel dcmeanH_expan_mandrel dcmeanH_speed_mandrel dcmeanH_force_wr1 
		dcmeanH_force_wr2 dcmeanH_force_wr3 dcmeanH_pos_wr1 dcmeanH_pos_wr2 dcmeanH_pos_wr3
;
run;

DATA dc_coil_tension;
 MERGE dc_coillocO (IN=dco)
       dc_coillocB (IN=dcb)
       dc_coillocH (IN=dch); 
  BY id_piece;
   IF dco;
run;



/* *** Old: Pull Data FROM calvert.jrs_coil_reprocess_reject Table *** */
/* *** New: Pull Data FROM my_sas.ak_rejreprocess_20170317 rjrp Table *** */

PROC SQL;
CONNECT TO ASTER (USER=ak186133 PASSWORD=ak186133
                  SERVER='10.25.98.20' DATABASE=calvert PORT=2406);
CREATE TABLE rejects_508 as
SELECT * FROM CONNECTION TO ASTER 
(SELECT DISTINCT
	rjrp.hsm_piece_no  			as rjrp_hsm_piece_no, 	
	rjrp.slab_number  			as rjrp_slab_number, 	
	rjrp.melt_source  			as rjrp_melt_source, 	
	rjrp.heat_number  			as rjrp_heat_number, 	
	rjrp.steel_grade 			as rjrp_steel_grade,
	rjrp.decision_type  		as rjrp_decision_type, 	
/*rjrp.timestamp_rework  		as rjrp_timestamp_rework,*/
	rjrp.timestamp_rework       as rjrp_timestamp_decision, 
    CASE WHEN rjrp.timestamp_rework IS NULL THEN rjrp.timestamp_rework  		
           ELSE rjrp.timestamp_rework 
    END                         as rjrp_timestamp_rework,
	rjrp.piece_no 				as rjrp_piece_no,	
	rjrp.weight_in_mt  			as rjrp_weight_in_mt, 	
	rjrp.defect_code  			as rjrp_defect_code, 	
	rjrp.defect_code_text 		as rjrp_defect_code_text,	
	rjrp.defect_group  			as rjrp_defect_group, 	
	rjrp.defect_group_text 		as rjrp_defect_group_text,	
	rjrp.originating_unit  		as rjrp_originating_unit, 	
	rjrp.reporting_unit 		as rjrp_reporting_unit,	
	rjrp.material_type  		as rjrp_material_type, 	
	rjrp.charged_coil  			as rjrp_charged_coil, 	
	rjrp.production_date 		as rjrp_production_date,	
	rjrp.order_grade  			as rjrp_order_grade, 	
	rjrp.product_group  		as rjrp_product_group, 	
	rjrp.order_product 			as rjrp_order_product,	
	rjrp.sort_grade  			as rjrp_sort_grade, 	
	rjrp.manufacturing_order 	as rjrp_manufacturing_order,	
	rjrp.sales_order_number  	as rjrp_sales_order_number, 	
	rjrp.sales_order_item 		as rjrp_sales_order_item,	
	rjrp.customer_number  		as rjrp_customer_number, 	
/*	rjrp.customer_application  	as rjrp_customer_application, 	*/
	rjrp.thickness  			as rjrp_thickness, 	
	rjrp.width 					as rjrp_width,	
	rjrp.decision_user  		as rjrp_decision_user, 	
	rjrp.decision_user_name 	as rjrp_decision_user_name,	
	rjrp.defect_details 		as rjrp_defect_details,	
	rjrp.flag_bad_coil			as rjrp_flag_bad_coil,	
	 CASE WHEN rjrp.defect_code = '508' THEN 'Squatty Coils'
	       ELSE 'Non-Squatty Coils'
	 END                 		as Squatty_Coil_Flag,
	 CASE WHEN rjrp.defect_code = '508' THEN 1
	       ELSE 0
	 END                 		as Squatty_Coil_Code
  FROM calvert.defects rjrp
  WHERE rjrp.defect_code = '508' 
);

DISCONNECT FROM ASTER;
QUIT;

/*
LIBNAME my_sas "C:\Users\ak186133\Remote Calvert ASTER Project\SAS_Outputs\";

PROC SQL;
CREATE TABLE rejects_508 as
  SELECT DISTINCT
	rjrp.hsm_piece_no  			as rjrp_hsm_piece_no, 	
	rjrp.slab_number  			as rjrp_slab_number, 	
	rjrp.melt_source  			as rjrp_melt_source, 	
	rjrp.heat_number  			as rjrp_heat_number, 	
	rjrp.steel_grade 			as rjrp_steel_grade,
	rjrp.decision_type  		as rjrp_decision_type, 	
--rjrp.timestamp_rework  		as rjrp_timestamp_rework,
	rjrp.timestamp_decision     as rjrp_timestamp_decision,
    CASE WHEN MISSING(rjrp.timestamp_rework) THEN rjrp.timestamp_rework  		
           ELSE rjrp.timestamp_rework 
    END                         as rjrp_timestamp_rework,
	rjrp.piece_no 				as rjrp_piece_no,	
	rjrp.weight_in_mt  			as rjrp_weight_in_mt, 	
	rjrp.defect_code  			as rjrp_defect_code, 	
	rjrp.defect_code_text 		as rjrp_defect_code_text,	
	rjrp.defect_group  			as rjrp_defect_group, 	
	rjrp.defect_group_text 		as rjrp_defect_group_text,	
	rjrp.originating_unit  		as rjrp_originating_unit, 	
	rjrp.reporting_unit 		as rjrp_reporting_unit,	
	rjrp.material_type  		as rjrp_material_type, 	
	rjrp.charged_coil  			as rjrp_charged_coil, 	
	rjrp.production_date 		as rjrp_production_date,	
	rjrp.order_grade  			as rjrp_order_grade, 	
	rjrp.product_group  		as rjrp_product_group, 	
	rjrp.order_product 			as rjrp_order_product,	
	rjrp.sort_grade  			as rjrp_sort_grade, 	
	rjrp.manufacturing_order 	as rjrp_manufacturing_order,	
	rjrp.sales_order_number  	as rjrp_sales_order_number, 	
	rjrp.sales_order_item 		as rjrp_sales_order_item,	
	rjrp.customer_number  		as rjrp_customer_number, 	
	rjrp.customer_application  	as rjrp_customer_application, 	
	rjrp.thickness  			as rjrp_thickness, 	
	rjrp.width 					as rjrp_width,	
	rjrp.decision_user  		as rjrp_decision_user, 	
	rjrp.decision_user_name 	as rjrp_decision_user_name,	
	rjrp.defect_details 		as rjrp_defect_details,	
	rjrp.flag_bad_coil			as rjrp_flag_bad_coil,	
	 CASE WHEN rjrp.defect_code = '508' THEN 'Squatty Coils'
	       ELSE 'Non-Squatty Coils'
	 END                 		as Squatty_Coil_Flag,
	 CASE WHEN rjrp.defect_code = '508' THEN 1
	       ELSE 0
	 END                 		as Squatty_Coil_Code,

	 DATEPART(timestamp_rework) as rjrp_reprocess_date FORMAT=DATE9.,
	 DATEPART(production_date)  as rjrp_production_date FORMAT=DATE9.,
	(DATEPART(timestamp_rework) - DATEPART(production_date))  as rjrp_days_to_reprocess,

	1.*INPUT(rjrp.hsm_piece_no,10.) as coil_number

  FROM my_sas.ak_rejreprocess_20170317 rjrp
  WHERE rjrp.defect_code = '508' 
  ORDER BY CALCULATED coil_number  
;
QUIT;
*/

PROC SORT DATA=rejects_508 OUT=dedup_rejects_508 NODUPKEY; 
 BY rjrp_hsm_piece_no;
run;


/* *** Adding calvert.lsetup_piece_fm (FM Set-Up Table) 20170324 *** */
/*
PROC SQL;
CONNECT TO ASTER (USER=ak186133 PASSWORD=ak186133
                  SERVER='10.25.98.20' DATABASE=calvert PORT=2406);
CREATE TABLE lsetup_fm_dc as 
SELECT * FROM CONNECTION TO ASTER 
 (SELECT DISTINCT
		lstp_fm.id_piece           as lstp_fm_id_piece,
		lstp_fm.id_setup_fm	   	   as lstp_fm_id_setup_fm,

		lstp_fm.thick_strip_cold   as lstp_fm_thick_strip_cold,
		lstp_fm.thick_strip_hot	   as lstp_fm_thick_strip_hot,
		lstp_fm.width_strip_cold   as lstp_fm_width_strip_cold,
		lstp_fm.width_strip_hot	   as lstp_fm_width_strip_hot,
		lstp_fm.len_strip_cold	   as lstp_fm_len_strip_cold,
		lstp_fm.len_strip_hot	   as lstp_fm_len_strip_hot,
		lstp_fm.trg_temp_strip	   as lstp_fm_trg_temp_strip,

		lstp_fm.trg_temp_coil	   as lstp_fm_trg_temp_coil,
		lstp_fm.temp_strip	   	   as lstp_fm_temp_strip,

		lstp_fm.trg_thick_strip_cold   as lstp_fm_trg_thick_strip_cold,
		lstp_fm.min_dev_thick_allowed  as lstp_fm_min_dev_thick_allowed,
		lstp_fm.max_dev_thick_allowed  as lstp_fm_max_dev_thick_allowed,
		lstp_fm.min_dev_width_allowed  as lstp_fm_min_dev_width_allowed,
		lstp_fm.max_dev_width_allowed  as lstp_fm_max_dev_width_allowed,
		lstp_fm.trg_width_strip_cold   as lstp_fm_trg_width_strip_cold,
		lstp_fm.max_dev_prof_allowed   as lstp_fm_max_prof_allowed,
		lstp_fm.min_dev_prof_allowed   as lstp_fm_min_prof_allowed,
		lstp_fm.min_dev_flat_allowed   as lstp_fm_min_flat_allowed,
		lstp_fm.max_dev_temp_strip_allowed	as lstp_fm_maxdev_temp_strip_allowed,
		lstp_fm.min_dev_temp_coil_allowed	as lstp_fm_mindev_temp_coil_allowed,
		lstp_fm.max_dev_temp_coil_allowed	as lstp_fm_maxdev_temp_coil_allowed,

		lstp_fm.prof_strip	   as lstp_fm_prof_strip,
		lstp_fm.flat_strip	   as lstp_fm_flat_strip,

		lstp_fm.max_wedge_allowed      as lstp_fm_max_wedge_allowed,
		lstp_fm.max_dev_flat_allowed   as lstp_fm_max_dev_flat_allowed,
		lstp_fm.min_dev_temp_strip_allowed as lstp_fm_mindev_temp_strip_allowed,
		lstp_fm.max_camber_allowed	   as lstp_fm_maxdev_camber_allowed,
		lstp_fm.temp_dsch_slab		   as lstp_fm_temp_dsch_slab

FROM calvert.lsetup_piece_fm lstp_fm
);

DISCONNECT FROM ASTER;
QUIT;
*/




/* *** Combine Squatty Coils (Defect Code 508 with all operational Data Sources *** */
/* *** Add op_corr_mandrell_tension,op_corr_mandrel_exp_press and  speed_pinch_roll1,
       speed_pinch_roll2, speed_pinch_roll3 *** */
PROC SQL;
CREATE TABLE steel_3cb2021 as
  SELECT base.*,
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
	pinch_roll.speed_pinch_roll3,

	dc_tens.*,
	rej.* 

  FROM de_dup_slabs base
/* *** Finishing Mill Tension & Loopers Calibration *** */
     LEFT OUTER JOIN fm6_tension lstat_fm
      on lstat_fm.lstat_fm_id_piece = base.pc_id_piece
/* *** Pinch Rolls Speed *** */
       LEFT OUTER JOIN pinch_rollspd pinch_roll
        on pinch_roll.id_piece = base.pc_id_piece
/* *** DC Coil Tension *** */
         LEFT OUTER JOIN dc_coil_tension dc_tens
		  on dc_tens.id_piece = base.pc_id_piece
/* *** 508 (Squatty Coils Rejects *** */
           LEFT OUTER JOIN dedup_rejects_508 rej
		    on rej.rjrp_hsm_piece_no = base.pc_id_piece /* INPUT(base.pc_id_piece,10.)*/
  ORDER BY base.pc_id_piece  
;
QUIT;




/* *** Save intermediant file 'coils_3cb2021' for analysis my_3cb21.coils_3cb2021 *** */
LIBNAME my_sas "C:\Users\ak186133\Remote Calvert ASTER Project\SAS_Outputs\";

DATA my_sas.coils_3cb2021_20170410;
 SET steel_3cb2021;
run;


/*
ODS LISTING;
ODS EXCEL FILE="C:\Users\ak186133\Remote Calvert ASTER Project\SAS_Outputs\AK_3CB2021_Steel_TableContent_&SYSDATE9..xlsx"
          OPTIONS(SHEET_INTERVAL='none');
;
PROC CONTENTS DATA=steel_3cb2021 VARNUM;
run;
ODS EXCEL CLOSE;


PROC PRINT DATA=coils_3cb2021_20170321 (OBS=100);
 * WHERE pc_id_piece IN('1164841090','1164775590','1164749060');
 * VAR pc_id_piece supplier comment slab_supplier rjrp_charged_coil rjrp_hsm_piece_no rjrp_piece_no
      rjrp_slab_number rjrp_production_date rjrp_timestamp_rework rjrp_melt_source rjrp_product_group
;
run;

PROC FREQ DATA=steel_3cb2021 NOHEADER ORDER=FREQ;
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

ODS EXCEL CLOSE;
* ODS LISTING CLOSE;
*/

/* *** Load Data into ASTER Table dblib.ak_3CB2021_Steel *** */
/* *** Load Data into ASTER Table dblib.ak_3CB2021_Steel *** */
LIBNAME dblib ASTER DSN=Calvert UID=ak186133 PWD=ak186133 DIMENSION=yes;

DATA dblib.ak_3CB2021_Steel (BULKLOAD=YES 
	                         BL_DATAFILE_PATH='C:\Temp\' 
	                         BL_HOST='10.25.98.20' 
	                         BL_PATH='C:\Remote_ASTER_Client\'
	                         BL_DBNAME='calvert'
                           /* BL_DELETE_DATAFILE=NO */
	                         DBCREATE_TABLE_OPTS='DISTRIBUTE BY HASH(pc_id_piece)'
                            );
 SET steel_3cb2021;
run;


/* *** EXPORT steel_3cb2021 into .csv for Paul (to Run PYTON Analytics) *** */
FILENAME csv_out "C:\Users\ak186133\Remote Calvert ASTER Project\SAS_Outputs\ak_3CB2021_Steel_&SYSDATE9..csv";
PROC EXPORT DATA=steel_3cb2021
            OUTFILE=csv_out
  DBMS=csv REPLACE;
run;


/* *** End Section creating ASTER , SAS and .csv Data Source for Analysis *** */ 
ODS  _ALL_  CLOSE; 
FILENAME _ALL_ CLEAR;
LIBNAME _ALL_ CLEAR;

*ODS PHTML CLOSE;
ODS TRACE OFF;
* ENDSAS;
**** END *** END *** END *** END *** END *** END *** END ***;
**** END *** END *** END *** END *** END *** END *** END ***;