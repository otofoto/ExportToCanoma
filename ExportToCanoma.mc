//----------------------------------------------------
// ExportToCanoma.mc
//
// MicroStation -> Canoma exporter
//
// Roberto Angeletti 06-october-2003
//
//----------------------------------------------------
//#define VERSION8
#include <mdl.h>
#include <cmdclass.h>
#include <image.h>
#include <global.h>
#include <msdefs.h>
#include <mselems.h>
#include <msinputq.h>
#include <system.h>
#include <tcb.h>
#include <userfnc.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <dlogids.h>
#include <rastref.h>
#include <scanner.h>
#include <mdlerrs.h>
#include <mscexpr.fdf>
#include <mscexpr.fdf>
#include <mselemen.fdf>
#include <mselmdsc.fdf>
#include <msrmatrx.fdf>
#include <mssystem.fdf>
#include <msparse.fdf>
#include <msstate.fdf>
#include <msoutput.fdf>
#include <msvec.fdf>
#include <msrsrc.fdf>
#include <msimage.fdf>
#include <msfile.fdf>
#include <msmisc.fdf>
#include <msdialog.fdf>
#include <msview.fdf>
FILE * fp2;
Dpoint3d lower, upper, center;
int tipo, numero=0;
// TerritorioDWG------------------------
Dpoint3d TerritorioPoints[256];
int isDwg = 0, Tiii = 0;
float quantiso;
// -------------------------------------
static int StrCnt;
char *StrFunc[16];
int level;
int color, style;
DialogBox *lpComplBAR;
int nPercent;
float num;
float den;
char Tratta[10], nomeFile[50];
char table[32];
ULong maxMslink = 0;
double Lenght, Width, Hight;
int pavimento;
RotMatrix outRMatrix;
Transform outTMatrix;
Dpoint3d point0, point1, point2;
Dpoint3d point;
double Sbandamento, Imbardata, Rollio, angolo, valore, valore1;
double alpha, beta, gamma;
double XO, YO, ZO ;
double XP, YP, ZP ;
double FX, FY, FZ ;
double R, R1, SA, CA, SB, CB ;
double angolo1, angolo2, angolo3;
double xo, yo, zo, xp, yp, zp;
double fx, fy, fz, r1, r2;
double sa, ca, sb, cb;
double dx, dy, dz, u, v;
double x2, y1, y2, z2;
double pim = 3.1415926535897932384626433832795 / 2.;
double ang360 = 57.295961893431049274795086972554;
int ret;
Dvector3d rangeP;
Dvector3d direction;
int NV, iii;
Dpoint3d points[102];
Dpoint3d SPoints[102];
int numSingle;
char groupName[20];
//----------------------------------------------------------------------
// CoordinateControl
//----------------------------------------------------------------------
Public void CoordinateControl()
{
//printf("NumeroVertici %d\n", NV);
// for (iii = 0; iii < NV; iii++){
// printf ("prima XYZ [%d] %lf %lf %lf\n", iii, points[iii].x, points[iii].y, points[iii].z);
// }
// Eliminazione punti ripetuti
numSingle = 0;
SPoints[0].x = points[0].x;
SPoints[0].y = points[0].y;
SPoints[0].z = points[0].z;
for (iii = 1; iii < NV; iii++){
//printf ("durante XYZ [%d] %lf %lf %lf\n", iii, points[iii].x, points[iii].y, points[iii].z);
//printf ("--------XYZ [%d] %lf %lf %lf\n", numSingle, SPoints[numSingle].x,
SPoints[numSingle].y, SPoints[numSingle].z);
dx = points[iii].x;
dy = points[iii].y;
dz = points[iii].z;
fx = SPoints[numSingle].x;
fy = SPoints[numSingle].y;
fz = SPoints[numSingle].z;
if ((dx != fx) ||
(dy != fy) ||
(dz != fz) ) {
numSingle++;
SPoints[numSingle].x = points[iii].x;
SPoints[numSingle].y = points[iii].y;
SPoints[numSingle].z = points[iii].z;
//printf("trovato %d %d\n", numSingle, iii);
}
}
// Riappoggio il vettore ripulito
NV = numSingle+1;
if (NV == 3) NV = 4;
points[NV].x = 0.;
points[NV].y = 0.;
points[NV].z = 0.;
for (iii = 0; iii < NV; iii++){
points[iii].x = SPoints[iii].x;
points[iii].y = SPoints[iii].y;
points[iii].z = SPoints[iii].z;
}
// for (iii = 0; iii < NV; iii++){
// printf ("dopo XYZ [%d] %lf %lf %lf\n", iii, points[iii].x, points[iii].y, points[iii].z);
// }
}
//----------------------------------------------------------------------
// WriteRectangle
//----------------------------------------------------------------------
Public void WriteRectangle()
{
fprintf(fp2, "rectangle %sRectangle%d { \n", groupName, numero);
fprintf(fp2, " state { \n");
fprintf(fp2, " alpha { 0.00000 f } \n");
fprintf(fp2, " beta { 0.00000 f } \n");
fprintf(fp2, " gamma { 0.00000 f } \n");
fprintf(fp2, " X0 { %lf f } \n", center.x);
fprintf(fp2, " Y0 { %lf f } \n", center.y);
fprintf(fp2, " Z0 { %lf f } \n", center.z);
fprintf(fp2, " L { %lf f } \n", Lenght);
fprintf(fp2, " W { %lf f } \n", Width);
fprintf(fp2, " } \n");
fprintf(fp2, " } \n");
}
//----------------------------------------------------------------------
// WriteVerticalRectangle
//----------------------------------------------------------------------
Public void WriteVerticalRectangle()
{
fprintf(fp2, "verticalrectangle %sVerticalRectangle%d { \n", groupName, numero);
fprintf(fp2, " state { \n");
fprintf(fp2, " alpha { %lf f } \n", Sbandamento);
fprintf(fp2, " beta { 0.00000 f } \n");
fprintf(fp2, " gamma { 0.00000 f } \n");
fprintf(fp2, " X0 { %lf f } \n", center.x);
fprintf(fp2, " Y0 { %lf f } \n", center.y);
fprintf(fp2, " Z0 { %lf f } \n", center.z);
fprintf(fp2, " W { %lf f } \n", Lenght);
fprintf(fp2, " H { %lf f } \n", Hight);
fprintf(fp2, " } \n");
fprintf(fp2, " } \n");
}
//----------------------------------------------------------------------
// WriteHorizontalFlatPolygon
//----------------------------------------------------------------------
Public void WriteHorizontalFlatPolygon()
{
CoordinateControl();
fprintf(fp2, "flatpolygon %sHorizontalPolygon%d %d 0 { \n", groupName, numero,
NV-1);
fprintf(fp2, " state { \n");
fprintf(fp2, " alpha { 0.00000 f } \n");
fprintf(fp2, " beta { 0.00000 f } \n");
fprintf(fp2, " gamma { 0.00000 f } \n");
fprintf(fp2, " X0 { %lf f } \n", center.x);
fprintf(fp2, " Y0 { %lf f } \n", center.y);
fprintf(fp2, " Z0 { %lf f } \n", center.z);
for (iii = 0; iii < NV-1; iii++){
fprintf(fp2, " u%d { %lf f }\n", iii, (points[iii].x / 1000.0) - center.x);
fprintf(fp2, " v%d { %lf f }\n", iii, (points[iii].y / 1000.0) - center.y);
} // End For
fprintf(fp2, " } \n");
fprintf(fp2, " } \n");
}
//----------------------------------------------------------------------
// WriteTiltedPolygon
//----------------------------------------------------------------------
Public void WriteTiltedPolygon()
{
CoordinateControl();
//printf("TiltedPolygon%d\n", numero);
fprintf(fp2, "flatpolygon %sTiltedPolygon%d %d 0 { \n", groupName, numero, NV
-1);
fprintf(fp2, " state { \n");
fprintf(fp2, " alpha { %lf f } \n", Sbandamento); // Sbandamento
(around Z)
fprintf(fp2, " beta { %lf f } \n", Imbardata); // Imbardata (around X)
fprintf(fp2, " gamma { %lf f } \n", Rollio); // Rollio (around Y)
fprintf(fp2, " X0 { %lf f } \n", center.x);
fprintf(fp2, " Y0 { %lf f } \n", center.y);
fprintf(fp2, " Z0 { %lf f } \n", center.z);
for (iii = 0; iii < NV-1; iii++){
dx = points[iii].x - xo;
dy = points[iii].y - yo;
dz = points[iii].z - zo;
x2 = dx*ca + dy*sa;
y1 = -dx*sa + dy*ca;
y2 = y1*cb + dz*sb;
z2 = -y1*sb + dz*cb;
u = x2;
v = z2;
if (sb > 0. ) v = -v;
fprintf(fp2, " u%d { %lf f }\n", iii, u/1000.);
fprintf(fp2, " v%d { %lf f }\n", iii, v/1000.);
} // End For
fprintf(fp2, " } \n");
fprintf(fp2, " } \n");
}
//----------------------------------------------------------------------
// WriteCube
//----------------------------------------------------------------------
Public void WriteCube()
{
fprintf(fp2, "cube %sBox%d { \n", groupName, numero);
fprintf(fp2, " state { \n");
fprintf(fp2, " alpha { 0.00000 f } \n");
fprintf(fp2, " beta { 0.00000 f } \n");
fprintf(fp2, " gamma { 0.00000 f } \n");
fprintf(fp2, " X0 { %lf f } \n", center.x);
fprintf(fp2, " Y0 { %lf f } \n", center.y);
fprintf(fp2, " Z0 { %lf f } \n", center.z);
fprintf(fp2, " L { %lf f } \n", Lenght);
fprintf(fp2, " W { %lf f } \n", Width);
fprintf(fp2, " H { %lf f } \n", Hight); // Per sbloccare l'altezza togliere
la "f"
fprintf(fp2, " } \n");
fprintf(fp2, " } \n");
}
//----------------------------------------------------------------------
// WriteTranslationSweep
//----------------------------------------------------------------------
Public void WriteTranslationSweep()
{
fprintf(fp2, "translationsweep %sTSW%d 2 %d { \n", groupName, numero, NV-1);
fprintf(fp2, " state { \n");
fprintf(fp2, " alpha { 0.00000 f } \n");
fprintf(fp2, " beta { 0.00000 f } \n");
fprintf(fp2, " gamma { 0.00000 f } \n");
fprintf(fp2, " X0 { %lf f } \n", center.x);
fprintf(fp2, " Y0 { %lf f } \n", center.y);
fprintf(fp2, " Z0 { %lf f } \n", center.z);
fprintf(fp2, " majorAxis { %lf f }\n", Hight); // Per sbloccare l'altezza togliere la
"f"
for (iii = 0; iii < NV-1; iii++){
fprintf(fp2, " u%d { %lf f }\n", iii, center.x - (points[iii].x / 1000.0));
fprintf(fp2, " v%d { %lf f }\n", iii, (points[iii].y / 1000.0) - center.y);
} // End For
fprintf(fp2, " } \n");
fprintf(fp2, " } \n");
}
//----------------------------------------------------------------------
// WriteCurtain
//----------------------------------------------------------------------
Public void WriteCurtain()
{
fprintf(fp2, "curtain %sCurtain%d 2 %d { \n", groupName, numero, NV-1);
fprintf(fp2, " state { \n");
fprintf(fp2, " alpha { 0.00000 f } \n");
fprintf(fp2, " beta { 0.00000 f } \n");
fprintf(fp2, " gamma { 0.00000 f } \n");
fprintf(fp2, " X0 { %lf f } \n", center.x);
fprintf(fp2, " Y0 { %lf f } \n", center.y);
fprintf(fp2, " Z0 { %lf f } \n", center.z);
fprintf(fp2, " majorAxis { %lf f }\n", Hight); // Per sbloccare l'altezza togliere la
"f"
for (iii = 0; iii < NV-1; iii++){
fprintf(fp2, " u%d { %lf f }\n", iii, (points[iii].x / 1000.0) - center.x);
fprintf(fp2, " v%d { %lf f }\n", iii, (points[iii].y / 1000.0) - center.y);
} // End For
fprintf(fp2, " } \n");
fprintf(fp2, " } \n");
}
//----------------------------------------------------------------------
// surface_show
//----------------------------------------------------------------------
Public int surface_show
(
MSElementDescr *elemDescr,
char *currentIndent
)
{
char indent[128];
/* If no descriptor, return */
if (elemDescr == NULL)
return SUCCESS;
strcpy (indent, currentIndent);
strcat (indent, " ");
/* Hilite indicated element */
mdlElmdscr_display (elemDescr, 0, HILITE);
/* Display information about element descriptor */
do
{
if (!elemDescr->h.isHeader) {
if ((ret = mdlLinear_extract(points, &NV, &elemDescr->el, 0)) == SUCCESS)
{
WriteCurtain();
return SUCCESS;
} // End Linear Extract
} // End !isHeader
/* If have a header, call us recursively */
if (elemDescr->h.isHeader)
{
surface_show (elemDescr->h.firstElem, indent);
}
/* Access next descriptor in chain */
elemDescr = elemDescr->h.next;
} while (elemDescr);
return SUCCESS;
}
//----------------------------------------------------------------------
// polygon_show
//----------------------------------------------------------------------
Public int polygon_show
(
MSElementDescr *elemDescr,
char *currentIndent
)
{
char indent[128];
// int riga, colo;
/* If no descriptor, return */
if (elemDescr == NULL)
return SUCCESS;
strcpy (indent, currentIndent);
strcat (indent, " ");
/* Hilite indicated element */
mdlElmdscr_display (elemDescr, 0, HILITE);
/* Display information about element descriptor */
do
{
if (!elemDescr->h.isHeader) {
if ((ret = mdlLinear_extract(points, &NV, &elemDescr->el, 0)) == SUCCESS)
{
//printf("NumPunti %d\n", NV);
if (NV == 5 ) {
// Controllo se si tratta di un finto rettangolo (DXF da FloorPlan)
if (points[2].x == points[3].x &&
points[2].y == points[3].y &&
points[2].z == points[3].z ) {
NV = NV - 1;
points[3].x == points[4].x ;
points[3].y == points[4].y ;
points[3].z == points[4].z ;
}
}
// if (NV == 5 ) { // <----------------------------------------------------
/*---------------------
if (points[0].x == points[1].x ||
points[0].y == points[1].y ) { // RETTANGOLO
if (points[0].z == points[1].z &&
points[1].z == points[2].z ) { // ORIZZONTALE
WriteRectangle();
return SUCCESS;
} // ORIZZONTALE
if (points[0].x == points[1].x ||
points[0].x == points[3].x ) { // VERTICALE
//printf("VerticalRectangle%d\n", numero);
if (mdlElmdscr_extractNormal (&direction.end,
&direction.org,
elemDescr, NULL) != MDLERR_BADELEMENT){
//---------------------------------------------------
// Cerco l'angolo di rotazione orizzontale
XO = points[0].x ;
YO = points[0].y ;
ZO = points[0].z ;
if (points[0].z == points[1].z ) { //
XP = points[1].x ;
YP = points[1].y ;
ZP = points[1].z ;
}
if (points[0].z == points[3].z ) {
XP = points[3].x ;
YP = points[3].y ;
ZP = points[3].z ;
}
FX = XP - XO ;
FY = YP - YO ;
FZ = ZP - ZO ;
FX = - FX ;
R = sqrt (FX*FX + FY*FY) ;
if (R == 0.){
angolo1 = 0.;
}else{
SA = FX / R ;
CA = FY / R ;
angolo1 = acos( CA ) ;
}
if (angolo1 == 3.141593) angolo1 = 0.00000;
if (Lenght == 0.0) {
alpha = 1.570796;
Lenght = Width;
}
Sbandamento = angolo1;
//-----------------------------------------
WriteVerticalRectangle();
}
return SUCCESS;
} // VERTICALE
} // RETTANGOLO
-------------------------------------*/
// }else{ // <-------------------------------------------------
if (NV > 2 ){ // POLIGONO
//printf("flatPolygon%d ", numero);
if (lower.z == upper.z ) { // ORIZZONTALE
//printf(" ORIZZONTALE \n");
WriteHorizontalFlatPolygon();
return SUCCESS;
} // ORIZZONTALE
else{ // POLIGONO INCLINATO
//printf(" INCLINATO \n");
#ifdef VERSION8
if (mdlElmdscr_extractNormal (&direction.end,
&direction.org,
elemDescr, NULL) != MDLERR_BADELEMENT){
#else
if (mdlElmdscr_extractNormal (&direction.end,
&direction.org,
elemDescr, NULL) != MDLERR_BADELEMENT){
#endif
//printf("ExtractNormal---Origine--------------------Direzione---------\n");
//printf("%lf ",direction.org.x);
//printf("%lf ",direction.org.y);
//printf("%lf ",direction.org.z);
//printf("%lf ",direction.end.x);
//printf("%lf ",direction.end.y);
//printf("%lf\n",direction.end.z);
// Calcolo gli angoli di rotazione del piano del poligono
xo = direction.org.x;
yo = direction.org.y;
zo = direction.org.z;
xp = direction.end.x + xo;
yp = direction.end.y + yo;
zp = direction.end.z + zo;
fx = xp - xo;
fy = yp - yo;
fz = zp - zo;
fx = -fx;
r1 = sqrt(fx*fx + fy*fy);
if(r1 != 0.){
sa = fx/r1;
ca = fy/r1;
}else{
sa = 0.00;
ca = 1.00;
//printf("FIXED ALFA <TiltedPolygon%d>\n", numero);
}
r2 = sqrt(r1*r1 + fz*fz);
if(r2 != 0.){
sb = fz/r2;
cb = r1/r2;
}else{
sb = 0.00;
cb = 1.00;
//printf("FIXED BETA <TiltedPolygon%d>\n", numero);
}
alpha = acos(ca);
beta = acos(cb);
beta = pim - beta;
gamma = 0.00;
//printf("sa ca %lf %lf\n", sa, ca);
//printf("sb cb %lf %lf\n", sb, cb);
Sbandamento = alpha;
if (sa < 0. && ca > 0.) Sbandamento = -Sbandamento;
if (sa < 0. && ca < 0.) Sbandamento = -Sbandamento;
if (sa == -1.) Sbandamento = -1.570796;
Imbardata = beta;
if (sb > 0. ) Imbardata = -Imbardata;
if (cb == 1.) Imbardata = 1.570796;
//if ((cb-1.) < 0.000001) Imbardata = 1.570796;
Rollio = gamma;
//printf("alpha %lf\n", Sbandamento);
//printf("beta %lf\n", Imbardata);
//printf("gamma %lf\n", Rollio);
}else{
printf("ExtractNormal MDLERR_BADELEMENT\n");
}
// Estraggo le coordinate del punto centrale dell'elemento
center.x = direction.org.x;
center.y = direction.org.y;
center.z = direction.org.z;
center.x /= 1000.0 ;
center.y /= 1000.0 ;
center.z /= 1000.0 ;
WriteTiltedPolygon();
return SUCCESS;
} // End POLIGONO INCLINATO
} // End POLIGON
// } // End RECTANGLE
} // End Linear Extract
} // End !isHeader
/* If have a header, call us recursively */
if (elemDescr->h.isHeader)
{
polygon_show (elemDescr->h.firstElem, indent);
}
/* Access next descriptor in chain */
elemDescr = elemDescr->h.next;
} while (elemDescr);
return SUCCESS;
}
/*----------------------------------------------------------------------+
| |
| name DwgTerritorioSolid - function to show complete element |
| descriptor |
| |
| author BSI 8/92 |
| |
+----------------------------------------------------------------------*/
Public int DwgTerritorioSolid
(
MSElementDescr *elemDescr,
char *currentIndent
)
{
char indent[128];
int ret;
int star, ende, actu, jjj;
/* If no descriptor, return */
if (elemDescr == NULL) return SUCCESS;
strcpy (indent, currentIndent);
strcat (indent, " ");
/* Hilite indicated element */
mdlElmdscr_display (elemDescr, 0, HILITE);
/* Display information about element descriptor */
do
{
if (!elemDescr->h.isHeader) {
if ((ret = mdlLinear_extract(points, &NV, &elemDescr->el, 0)) == SUCCESS)
{
Tiii++;
TerritorioPoints[Tiii].x = points[0].x;
TerritorioPoints[Tiii].y = points[0].y;
TerritorioPoints[Tiii].z = points[0].z;
Tiii++;
TerritorioPoints[Tiii].x = points[1].x;
TerritorioPoints[Tiii].y = points[1].y;
TerritorioPoints[Tiii].z = points[1].z;
} // End Linear Extract
} // End !isHeader
/* If have a header, call us recursively */
if (elemDescr->h.isHeader)
{
Tiii = 0;
DwgTerritorioSolid (elemDescr->h.firstElem, indent);
}
/* Access next descriptor in chain */
elemDescr = elemDescr->h.next;
} while (elemDescr);
// Scrivo l'elemento di estrusione di TerritorioDWG
// if (elemDescr->h.next == NULL){
quantiso = ((float)Tiii/3.)/2.;
// printf("Tiii %d QUANTISO %f\n", Tiii, quantiso);
// Estraggo le coordinate del poligono di base
actu = 0;
for (jjj = 0; jjj < Tiii; jjj++){
if (TerritorioPoints[jjj].z == TerritorioPoints[jjj+1].z){
if (TerritorioPoints[jjj].z != center.z){
points[actu].x = TerritorioPoints[jjj].x;
points[actu].y = TerritorioPoints[jjj].y;
points[actu].z = center.z;
actu++;
}
}
}
numero++;
NV = actu+1;
CoordinateControl();
WriteTranslationSweep();
// }
return SUCCESS;
}
/*----------------------------------------------------------------------+
| |
| name elemDscr_show - function to show complete element |
| descriptor |
| |
| author BSI 8/92 |
| |
+----------------------------------------------------------------------*/
Public int elemDscr_show
(
MSElementDescr *elemDescr,
char *currentIndent
)
{
char indent[128];
int ret;
/* If no descriptor, return */
if (elemDescr == NULL)
return SUCCESS;
strcpy (indent, currentIndent);
strcat (indent, " ");
/* Hilite indicated element */
mdlElmdscr_display (elemDescr, 0, HILITE);
/* Display information about element descriptor */
do
{
if (!elemDescr->h.isHeader) {
if ((ret = mdlLinear_extract(points, &NV, &elemDescr->el, 0)) == SUCCESS)
{
if (NV == 5){ // CUBE
if ((points[0].x == points[3].x &&
points[0].y == points[1].y) ||
(points[0].y == points[3].y &&
points[0].x == points[1].x) ) { // RETTANGOLO
if (!pavimento) {
WriteCube();
}else pavimento = 0;
}else{
if (!pavimento) {
WriteTranslationSweep();
pavimento = 1;
}else pavimento = 0;
}
}else{
if ( NV > 2 ){ // SOLIDO DI ESTRUSIONE VERTICALE
if (!pavimento) {
//printf("HERE1\n");
WriteTranslationSweep();
pavimento = 1;
} else pavimento = 0;
} // End POLIGON
} // End CUBE
} // End Linear Extract
} // End !isHeader
/* If have a header, call us recursively */
if (elemDescr->h.isHeader)
{
elemDscr_show (elemDescr->h.firstElem, indent);
}
/* Access next descriptor in chain */
elemDescr = elemDescr->h.next;
} while (elemDescr);
return SUCCESS;
}
//-----------------------------------------------------------------
void ExportToCanoma(char *filePathAndNameDGN)
{
ULong curpos ;
ULong filePos ;
#ifndef VERSION8
int currfile;
#endif
ULong eofpos ;
MSElementDescr *edP = NULL;
unsigned short type ;
#ifdef VERSION8
DgnModelRefP modelRef;
unsigned long level ;
#else
unsigned short level ;
#endif
MSElementUnion *elem ;
char file3DV[512];
char devP[3], extP[4], dirP[1024];
int viewNumberSource, view;
RotMatrix rMatrixSource;
int err;
double EX, EY, EZ;
double f;
double CX, CY;
Dpoint3d position;
Dpoint3d target;
double angle;
double focalLength;
Dpoint3d origin, delta;
double activeZ;
int qui=0;
int gg;
//-----------------------------------
mdlFile_parseName (filePathAndNameDGN, devP, dirP, nomeFile, extP);
if(!strcmpi(extP, "dwg")){
printf("---------------DWG!\n");
isDwg = 1;
}else{
isDwg = 1;
}
strcpy (file3DV, devP);
if (strlen(file3DV) != 0) strcat (file3DV,":");
strcat (file3DV, dirP);
strcat (file3DV, nomeFile);
strcat (file3DV, ".3dv");
//printf("file %s\n", file3DV);
fp2 = fopen(file3DV,"wt");
// -----------------------------
// Inizio il file 3VD
// -----------------------------
fprintf(fp2, "version 1\n");
// strcpy(groupName, "group1@");
strcpy(groupName, "");
//----------------------------------------------------
// Preparazione loop di scansione del design file.
//----------------------------------------------------
filePos = 0L;
#ifdef VERSION8
eofpos = mdlElement_getFilePos(FILEPOS_EOF, &modelRef);
filePos = mdlElement_getFilePos(FILEPOS_FIRST_ELE, &modelRef);
filePos = mdlElmdscr_read(&edP, filePos, modelRef, FALSE, &curpos);
#else
eofpos = mdlElement_getFilePos(FILEPOS_EOF, &currfile);
filePos = mdlElement_getFilePos(FILEPOS_FIRST_ELE, &currfile);
filePos = mdlElmdscr_read (&edP, filePos, currfile, FALSE, &curpos);
#endif
// printf("filePos %ld\n", filePos);
lpComplBAR = mdlDialog_openCompletionBar("Exporting to Canoma 3DV");
/*-------------------------------------------------------------------------
Ciclo di elaborazione degli elementi
-------------------------------------------------------------------------*/
do{
num = filePos;
den = eofpos;
nPercent = (int) (num / den * 100.0);
mdlDialog_updateCompletionBar(lpComplBAR ,"Exporting to Canoma 3DV"
, nPercent);
elem = &edP->el;
type = elem->hdr.ehdr.type;
level = elem->hdr.ehdr.level;
mdlElement_getProperties(NULL, &gg, NULL, NULL, NULL, NULL, NULL,
NULL, elem);
if (gg != 0){
sprintf(groupName, "gg%d@", gg);
}else strcpy(groupName, "");
// Estraggo le coordinate del punto centrale dell'elemento
#ifdef VERSION8
if ((ret = mdlElement_extractRange (&rangeP, &edP->el)) == SUCCESS){
lower.x = rangeP.org.x;
lower.y = rangeP.org.y;
lower.z = rangeP.org.z;
upper.x = rangeP.end.x;
upper.y = rangeP.end.y;
upper.z = rangeP.end.z;
}else{
// printf("ERROR ExportToCanoma <%d> mdlElement_extractRange \n", ret);
}
#else
lower.x = (double) mdlCnv_fromScanFormat(elem->ehdr.xlow);
lower.y = (double) mdlCnv_fromScanFormat(elem->ehdr.ylow);
lower.z = (double) mdlCnv_fromScanFormat(elem->ehdr.zlow);
upper.x = (double) mdlCnv_fromScanFormat(elem->ehdr.xhigh);
upper.y = (double) mdlCnv_fromScanFormat(elem->ehdr.yhigh);
upper.z = (double) mdlCnv_fromScanFormat(elem->ehdr.zhigh);
#endif
center.x = (lower.x + upper.x) / 2.;
center.y = (lower.y + upper.y) / 2.;
center.z = lower.z;
center.x /= 1000.0 ;
center.y /= 1000.0 ;
center.z /= 1000.0 ;
Lenght = upper.x - lower.x;
Width = upper.y - lower.y;
Hight = upper.z - lower.z;
Lenght /= 1000.0 ;
Width /= 1000.0 ;
Hight /= 1000.0 ;
// ----------------------------------------------------------------------
// ExportToCanoma ---------------------------------------------------
// ----------------------------------------------------------------------
if (type == CELL_HEADER_ELM){ // DWG 3DSOLID FROM TERRITORIO
if (isDwg == 1) DwgTerritorioSolid (edP, "-> ");
}
if (type == SOLID_ELM){
numero++;
pavimento=1;
elemDscr_show (edP, "-> ");
}
if (type == SHAPE_ELM){
numero++;
pavimento=1;
polygon_show (edP, "-> ");
}
if (type == SURFACE_ELM){ //|| type == LINE_STRING_ELM){
//printf("found SURFACE_ELM\n");
numero++;
pavimento=1;
surface_show (edP, "-> ");
}
LabelVaiAvanti:
qui = 1;
#ifdef VERSION8
} while ((filePos=mdlElmdscr_read(&edP, filePos, modelRef, FALSE, &curpos)));
#else
} while ((filePos=mdlElmdscr_read(&edP,filePos,currfile,FALSE,&curpos)));
#endif
/*-------------------------------------------------------------------------
Chiusura del ciclo di elaborazione degli elementi
-------------------------------------------------------------------------*/
mdlDialog_closeCompletionBar(lpComplBAR);
// if (edP != NULL) mdlElmdscr_freeAll(&edP);
// ----------------------------------------------
// Calcolo i parametri della vista prospettica
// ----------------------------------------------
// Cerca la vista prospettica
//printf("STO CERCANDO LA VISTA PROSPETTICA\n");
viewNumberSource = -1;
for(view=0; view<8; view++){
if ((mdlView_getCamera(&position, &target, &angle, &focalLength, NULL,
view)) == SUCCESS){
if (focalLength != -1){
viewNumberSource = view;
//printf("HO TROVATO LA VISTA PROSPETTICA %d\n", view);
goto fine;
}
}
}
//printf("NON HO TROVATO LA VISTA PROSPETTICA ! \n");
fine:
err = mdlView_getParameters(&origin, &center, &delta, &rMatrixSource,
&activeZ, viewNumberSource);
//printf("dopo mdlView_getParameters\n");
XO = position.x ;
YO = position.y ;
ZO = position.z ;
XP = target.x ;
YP = target.y ;
ZP = target.z ;
FX = XP - XO ;
FY = YP - YO ;
FZ = ZP - ZO ;
FX = - FX ;
R = sqrt (FX*FX + FY*FY) ;
if (R == 0.){
angolo1 = 0.;
}else{
SA = FX / R ;
CA = FY / R ;
angolo1 = acos( CA ) ;
}
if (angolo1 == 3.141593) angolo1 = 0.00000;
if (Lenght == 0.0) {
alpha = 1.570796;
Lenght = Width;
}
R1 = sqrt (R*R + FZ*FZ) ;
SB = FZ/R1 ;
CB = R/R1 ;
// if (rMatrixSource.form3d[1][0] < 0.0) angolo1 = -angolo1 ;
angolo2 = acos( CB ) ;
angolo3 = acos( rMatrixSource.form3d[0][0]) ;
EX = position.x /1000.; //28565.12704 ;
EY = position.y /1000.; //503694.01105 ;
EZ = position.z /1000.; //525.42142 ;
f = focalLength; //168.38375 ;
alpha = angolo1; // 0.08332 ;
beta = angolo2; // 0.94032 ;
gamma = 0.000; //-0.01170 ;
CX = 0.000; // -0.04519 ;
CY = 0.000; //0.04519 ;
printf("--------------------------------------------\n");
printf(" Exported Elements: <%d>\n", numero);
printf("--------------------------------------------\n");
printf(" ExportToCanoma 1.01\n");
printf("\n");
printf(" ExentialTechnologies Copyright 2004\n");
printf(" (mar 15, 2004)\n");
printf(" (jun 14, 2004)\n");
printf("\n");
printf(" BobMax exporttocanoma@fastmail.fm\n");
printf("--------------------------------------------\n");
// -----------------------------
// Concludo il file 3VD
// -----------------------------
fprintf(fp2, "camera { \n");
fprintf(fp2, " state { \n");
fprintf(fp2, " EX { %lf } \n", EX);
fprintf(fp2, " EY { %lf } \n", EY);
fprintf(fp2, " EZ { %lf } \n", EZ);
fprintf(fp2, " alpha { %lf } \n", alpha);
fprintf(fp2, " beta { %lf } \n", beta);
fprintf(fp2, " gamma { %lf } \n", gamma);
fprintf(fp2, " f { %lf } \n", f);
fprintf(fp2, " CX { %lf } \n", CX);
fprintf(fp2, " CY { %lf } \n", CY);
fprintf(fp2, " } \n");
fprintf(fp2, " } \n");
fprintf(fp2, "image Image.jpg { \n");
fprintf(fp2, " camera { \n");
fprintf(fp2, " state { \n");
fprintf(fp2, " EX { %lf } \n", EX);
fprintf(fp2, " EY { %lf } \n", EY);
fprintf(fp2, " EZ { %lf } \n", EZ);
fprintf(fp2, " alpha { %lf } \n", alpha);
fprintf(fp2, " beta { %lf } \n", beta);
fprintf(fp2, " gamma { %lf } \n", gamma);
fprintf(fp2, " f { %lf } \n", f);
fprintf(fp2, " CX { %lf } \n", CX);
fprintf(fp2, " CY { %lf } \n", CY);
fprintf(fp2, " } \n");
fprintf(fp2, " } \n");
fprintf(fp2, " { 723.00000 476.00000 } \n");
fprintf(fp2, " } \n");
fprintf(fp2, "selection Image.jpg TSW n \n");
fprintf(fp2, "calibration 1.00000 \n");
fclose(fp2);
return;
}
//------------------------------------------------
//
// MAIN
//
//------------------------------------------------
void main(int argc, char *argv[])
{
char filePathAndNameDGN[256];
if(argc < 3){
strcpy(filePathAndNameDGN, tcb->dgnfilenm);
}else{
strcpy(filePathAndNameDGN, argv[2]);
}
ExportToCanoma(filePathAndNameDGN);
mdlSystem_exit(0,1);
}
