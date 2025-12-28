/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_damaged
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Event script that runs when a creature takes damage (after resistances).
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "nwnx_damage"
#include "0i_master"
void main()
{
    object oMaster = GetMaster();
    if(!GetIsCharacter(oMaster)) return;
    struct NWNX_Damage_DamageEventData stDmg;
    stDmg = NWNX_Damage_GetDamageEventData ();
    int nTotalDmg;
    if (stDmg.iBludgeoning > -1) nTotalDmg += stDmg.iBludgeoning;
    if (stDmg.iPierce > -1) nTotalDmg += stDmg.iPierce;
    if (stDmg.iSlash > -1) nTotalDmg += stDmg.iSlash;
    if (stDmg.iMagical > -1) nTotalDmg += stDmg.iMagical;
    if (stDmg.iAcid > -1) nTotalDmg += stDmg.iAcid;
    if (stDmg.iCold > -1) nTotalDmg += stDmg.iCold;
    if (stDmg.iDivine > -1) nTotalDmg += stDmg.iDivine;
    if (stDmg.iElectrical > -1) nTotalDmg += stDmg.iElectrical;
    if (stDmg.iFire > -1) nTotalDmg += stDmg.iFire;
    if (stDmg.iNegative > -1) nTotalDmg += stDmg.iNegative;
    if (stDmg.iPositive > -1) nTotalDmg += stDmg.iPositive;
    if (stDmg.iSonic > -1) nTotalDmg += stDmg.iSonic;
    if (stDmg.iBase > -1) nTotalDmg += stDmg.iBase;
    //Debug ("0e_damaged", "15", GetName (OBJECT_SELF) + " iBludgeoning: " + IntToString (stDmg.iBludgeoning));
    //Debug ("0e_damaged", "16", " iPierce: " + IntToString (stDmg.iPierce));
    //Debug ("0e_damaged", "16", " iSlash: " + IntToString (stDmg.iSlash));
    //Debug ("0e_damaged", "16", " iMagical: " + IntToString (stDmg.iMagical));
    //Debug ("0e_damaged", "16", " iAcid: " + IntToString (stDmg.iAcid));
    //Debug ("0e_damaged", "16", " iCold: " + IntToString (stDmg.iCold));
    //Debug ("0e_damaged", "16", " iDivine: " + IntToString (stDmg.iDivine));
    //Debug ("0e_damaged", "16", " iElectrical: " + IntToString (stDmg.iElectrical));
    //Debug ("0e_damaged", "16", " iFire: " + IntToString (stDmg.iFire));
    //Debug ("0e_damaged", "16", " iNegative: " + IntToString (stDmg.iNegative));
    //Debug ("0e_damaged", "16", " iPositive: " + IntToString (stDmg.iPositive));
    //Debug ("0e_damaged", "16", " iSonic: " + IntToString (stDmg.iSonic));
    //Debug ("0e_damaged", "16", " iBase: " + IntToString (stDmg.iBase));
    int nHp = GetCurrentHitPoints ();
    //Debug("0e_damaged", "43", GetName (OBJECT_SELF) + " nHp: " + IntToString (nHp) + " nTotalDmg: " + IntToString (nTotalDmg));
    if(nTotalDmg >= nHp)
    {
        SetLocalObject(OBJECT_SELF, "0_Master", oMaster);
        SetLocalInt(OBJECT_SELF, "0_Hitpoints", nHp - nTotalDmg);
    }
}


