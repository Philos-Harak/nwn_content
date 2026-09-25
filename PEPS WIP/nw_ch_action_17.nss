/*//////////////////////////////////////////////////////////////////////////////
 Script: nw_ch_action_17
 Copyright (c) 2001 Bioware Corp.
////////////////////////////////////////////////////////////////////////////////
 This fires whenever a player talks to a henchman and wants to level them up.
 Philos: Fixed to allow up to maximum henchman and retention of old gear.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_menus"
// Assumes that a succesful GetCanLevelUp has already been tested.
// Will level up character to one level less than player.
void main()
{
   object oPC = GetPCSpeaker();
   object oOldHenchman = OBJECT_SELF;
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
   ChangeToStandardFaction(oOldHenchman, STANDARD_FACTION_DEFENDER);
   NuiDestroy(oMaster, NuiFindWindow(oMaster, GetTag(oOldHenchman) + AI_WIDGET_NUI));
   string sNewFile = GetTag(oOldHenchman) + "_" + sLevel;
   AssignCommand(oOldHenchman, ClearAllActions());
   AssignCommand(oOldHenchman, PlayAnimation(ANIMATION_LOOPING_MEDITATE));
   object oNewHenchman = CreateObject(OBJECT_TYPE_CREATURE, sNewFile, GetLocation(oOldHenchman), FALSE);
   AddHenchman(oMaster, oNewHenchman);
   ai_CreateWidgetNUI(oMaster, oNewHenchman);
   ai_RemoveInventory(oNewHenchman);
   AssignCommand(oNewHenchman, ai_MoveInventory(oOldHenchman, oNewHenchman));
   DelayCommand(0.4, ai_CopyObjectVariables(oOldHenchman, oNewHenchman));
   DelayCommand(0.4, SetLocalObject(oNewHenchman,"NW_L_FORMERMASTER", oPC));
   DestroyObject(oOldHenchman, 1.0);
   sLevel = IntToString(GetHitDice(oNewHenchman));
   DelayCommand(1.0,FloatingTextStringOnCreature(GetName(oNewHenchman) + " is now level " + sLevel + "!", oNewHenchman));
}
