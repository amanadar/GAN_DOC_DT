/*---------------------------------------------------*/
/* Objet    : TRAITEMENT_INPUT_PPHJ_HORSFOA          */ 
/*---------------------------------------------------*/

%let ROOT = /data/sasgridi3/gass23/QA/DT/PROD_new/;
%let SIMU = /data/sasgridi3/gass23/QA/PROD/;
%let CTRL_OUT = &ROOT./Outputs/03_CONTROLE/;

libname QA_SIMU "&SIMU.";
libname MOD "&ROOT./Datas/01_MOD";

%include "&ROOT.Macros/*.sas";

/***********************************************/
/* Paramètres de lancement des traitements PPHJ*/
/***********************************************/

%let annee_ech = 2023; /* Année de l'échéance */
%let mois_ech = 06; /* Mois de l'échéance */

%let date_trait_zp69 = 20230307; /* Date de production du fichier ZP69 en entrée de la simu 1 (voir nom du fichier) A VOIR POUR SUPPRIMER */

%let date_trait_simu = 20230307; /* Date de production des sorties de simulation (voir nom des fichiers) */
%let env = LP0;/*LQ0 Référence de l'environnement (voir nom des fichiers) */
%let simu = S01; /* Référence de simulation (voir nom des fichiers) */
%let lot = L00;/*L00*/ /* Référence de lot (voir nom des fichiers) */

%let perimetre = 
("COART2" "CONDU2" "AUGRS1" "EMBR1" "MISCO1" "BDM4" "COENT2" "RCMOE1" "G2004A" "G2403A"
"G7009A" "BEQUI1" "RCMSO2" "APPEL2" "AMP2" "ARDEN2" "EQUIP1" "PAGAS1" "BISER1" "ARPE1"
"FRETP1" "G9004A" "PAEDO2" "PAERC2" "SANTE1" "BETIN1" "AUFLO3" "G6007A" "BGAVP1"
"PAESS2" "CYBER1" "G6004A" "G7003A"); /* Périmètre produits */   


/*************************/
/* Chargement de la simu */
/*************************/

%CHG_SIMU(annee_ech=&annee_ech, mois_ech=&mois_ech, 
		  date_trait_zp69=&date_trait_zp69, date_trait_simu=&date_trait_simu,
		  env=&env, simu=&simu, lot=&lot, perimetre=&perimetre, f_out=FOA_SOURCE);

/***************************/
/* Traitements par produit */
/***************************/

%TRAITEMENT_PPHJ_ENTREPRISE(f_in=FOA_SOURCE, f_out=PPHJ_ENT);

%TRAITEMENT_PPHJ_CONDU2(f_in=FOA_SOURCE, f_out=PPHJ_Condu2);

%TRAITEMENT_PPHJ_AUTRES(f_in=FOA_SOURCE, f_out=PPHJ_AUTRES);

%TRAITEMENT_PPHJ_CHEVAUX(f_in=FOA_SOURCE, f_out=PPHJ_Chevaux);

%TRAITEMENT_PPHJ_GAV(f_in=FOA_SOURCE, f_out=PPHJ_GAV);

/****************************************/
/* Concaténation des produits pour PPHJ */
/****************************************/

data MOD.pphj_horsfoa_&annee_ech.&mois_ech.;
	set PPHJ_ENT PPHJ_Condu2 PPHJ_AUTRES PPHJ_Chevaux PPHJ_GAV;
run;

/*******************************/
/* RECAP CONTROLE EXPORT EXCEL */
/*******************************/

proc freq data=MOD.pphj_horsfoa_&annee_ech.&mois_ech.;
	table PRODUIT*MAJO_CIBLEE/list out=CTRL_pphj_horsfoa_&annee_ech.&mois_ech.;
run;

PROC EXPORT DATA =CTRL_pphj_horsfoa_&annee_ech.&mois_ech.
			OUTFILE = "&CTRL_OUT.pphj_horsfoa_&annee_ech.&mois_ech."
	        DBMS=XLSX REPLACE LABEL;
			SHEET='CTRL_pphj_horsfoa'; 
RUN;

/****************************************/
/* Mise à jour des droits sur les bases */
/****************************************/
 
%MAJ_OUV_DROITS;
