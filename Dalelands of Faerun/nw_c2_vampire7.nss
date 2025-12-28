//::///////////////////////////////////////////////
//:: NW_C2_VAMPIRE7.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Vampire turns into a vampire shadow
    that looks for the nearest coffin
    with the same tag as the shadow.
*/
/*//////////////////////////////////////////////////////////////////////////////
 Script: nw_c2_vampire7
 Created By: Philos
////////////////////////////////////////////////////////////////////////////////
    OnDeath script for vampires.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_states"
#include "0i_quest"
#include "0i_journal"
void main()
{
    int bBonusXp;
    object oCreature = OBJECT_SELF;
    object oKiller = GetLastKiller();
    // If a PC has killed this creature then increase that PC's kill count.
    if(GetIsCharacter(oKiller)) SetLocalInt(oKiller, "0_Kills", GetLocalInt(oKiller, "0_Kills") + 1);
    // Check for quest kill.
    string sQuestPC = GetLocalString(oCreature, "0_QUEST_KILL");
    // If there is a PC linked with the creature then check.
    if(sQuestPC != "") CheckQuestKill(oCreature, oKiller, sQuestPC);
    // Check for Villain of a quest.
    if(GetLocalInt(oCreature, "0_VILLAIN")) bBonusXp = TRUE;
    // Give xp for kill (area effect).
    GiveXPForKill(oCreature, bBonusXp);
    // Set all inventory to unidentified.
    IdDrops(oCreature);
    // Check to see if this kill triggers a Journal Entry.
    int nJournal = GetLocalInt(oCreature, "0_Journal");
    if(nJournal > 0)
    {
         KillVillainEffect(oCreature);
         string sJournal = IntToString(nJournal);
         int nCR = FloatToInt(GetChallengeRating(oCreature));
         if(nCR < 1) nCR = 1;
         else if(nCR > 20) nCR = 20;
         location lLocation = GetLocation(oCreature);
         // Get players within the kill area.
         object oPC = GetFirstObjectInShape(SHAPE_SPHERE, XP_PARTY_RADIUS, lLocation, FALSE, OBJECT_TYPE_CREATURE);
         // If the object is valid then continue.
         while(oPC != OBJECT_INVALID)
         {
              // If they are a PC then get the level and compare.
              if(GetIsCharacter(oPC))
              {
                  AddJournalEntry("0_quest_v_" + sJournal, nCR, oPC, FALSE);
              }
              // Get next object.
              oPC = GetNextObjectInShape (SHAPE_SPHERE, XP_PARTY_RADIUS, lLocation, FALSE, OBJECT_TYPE_CREATURE);
         }
    }
    //object oGas = CreateObject(OBJECT_TYPE_CREATURE, GetTag(OBJECT_SELF) + "_SHAD", GetLocation(OBJECT_SELF));
    //SetLocalString (oGas, "NW_L_MYCREATOR", GetTag (OBJECT_SELF));
    //DestroyObject (OBJECT_SELF, 0.5);
}
