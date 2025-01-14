/*//////////////////////////////////////////////////////////////////////////////
 Script: nw_O0_levelup
 Copyright (c) 2001 Bioware Corp.
 Created By:     Brent
 Created On:     2002
////////////////////////////////////////////////////////////////////////////////
 This script fires whenever a player levels up.
 If the henchmen is capable of going up a level, they do.
 Philos: Fixed to allow up to maximum henchman and retention of old gear.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_menus"
int ai_CanLevelUp(object oPC, object oOldHenchman)
{
    int nMasterLevel = GetHitDice(oPC);
    int nHenchmanLevel = GetHitDice(oOldHenchman);
    if (nMasterLevel >= nHenchmanLevel + 2) return TRUE;
    return FALSE;
}
// Assumes that a succesful ai_CanLevelUp has already been tested.
// Will level up character to one level less than player.
void ai_DoLevelUp(object oPC, object oOldHenchman = OBJECT_SELF)
{
   int nMasterLevel = GetHitDice(oPC);
   int nLevel = nMasterLevel - 4;
   // Will not spawn henchmen higher than this level + INT_FUDGE (i.e., 14)
   if(nLevel > 11) nLevel = 11;
   // If already the highest level henchmen then do nothing.
   if(GetHitDice(oOldHenchman) >= nLevel + 3) return;
   string sLevel = IntToString(nLevel);
   // Add a 0 if necessary
   if(GetStringLength(sLevel) == 1) sLevel = "0" + sLevel;
   object oMaster = GetMaster(oOldHenchman);
   RemoveHenchman(oMaster, oOldHenchman);
   NuiDestroy(oMaster, NuiFindWindow(oMaster, GetTag(oOldHenchman) + "_widget"));
   string sNewFile = GetTag(oOldHenchman) + "_" + sLevel;
   AssignCommand(oOldHenchman, ClearAllActions());
   AssignCommand(oOldHenchman, PlayAnimation(ANIMATION_LOOPING_MEDITATE));
   object oNewHenchman = CreateObject(OBJECT_TYPE_CREATURE, sNewFile, GetLocation(oOldHenchman), FALSE);
   AddHenchman(oMaster, oNewHenchman);
   //ai_RemoveInventory(oNewHenchman);
   AssignCommand(oNewHenchman, ai_MoveInventory(oOldHenchman, oNewHenchman));
   ai_CopyObjectVariables(oOldHenchman, oNewHenchman);
   SetLocalObject(oNewHenchman,"NW_L_FORMERMASTER", oPC);
   ai_CreateWidgetNUI(oMaster, oNewHenchman);
   DestroyObject(oOldHenchman, 1.0);
   sLevel = IntToString(GetHitDice(oNewHenchman));
   DelayCommand(1.0,FloatingTextStringOnCreature(GetName(oNewHenchman) + " is now level " + sLevel + "!", oNewHenchman));
}
void main()
{
    object oPC = GetPCLevellingUp();
    if (GetIsObjectValid(oPC))
    {
        int nIndex = 1;
        object oOldHenchman = GetHenchman(oPC, nIndex);
        while(oOldHenchman != OBJECT_INVALID)
        {
            if(ai_CanLevelUp(oPC, oOldHenchman)) DelayCommand(0.5, ai_DoLevelUp(oPC, oOldHenchman));
            oOldHenchman = GetHenchman(oPC, ++nIndex);
        }
    }
}
