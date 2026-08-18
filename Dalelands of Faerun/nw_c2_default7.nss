/*//////////////////////////////////////////////////////////////////////////////
 Script: nw_c2_default7
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Default OnDeath script for monsters and villians.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_states"
#include "0i_quest"
#include "0i_journal"
#include "0i_webhook"
void main()
{
    int bBonusXP;
    object oCreature = OBJECT_SELF;
    object oKiller = GetLastKiller();
    SetAssociateMode (MODE_DEAD);
    // Check to make sure a pc or companion made the kill.
    // Check to see if the killer had a master pc.
    oKiller = GetPlayerMaster(oKiller);
    // If a PC has killed this creature then increase that PC's kill count.
    if(GetIsCharacter(oKiller)) SetLocalInt(oKiller, "0_Kills", GetLocalInt(oKiller, "0_Kills") + 1);
    // Check for quest kill.
    string sQuestID = GetLocalString(oCreature, "0_QUEST_KILL");
    // If there is a kill ID linked with the creature then check.
    if(sQuestID != "") CheckQuestKill(oCreature, oKiller, sQuestID);
    // Check for Villain of a quest and give bonus xp.
    if(GetLocalInt(oCreature, "0_VILLAIN"))
    {
        bBonusXP = GetLocalInt(oCreature, "0_NUM_OF_POWERS") * VILLAIN_XP_MULTIPLIER;
        if(bBonusXP < VILLAIN_XP_MULTIPLIER) bBonusXP = VILLAIN_XP_MULTIPLIER;
    }
    // Give xp for kill (area effect).
    GiveXPForKill(oCreature, bBonusXP);
    // Set all inventory to unidentified.
    IdDrops(oCreature);
    // Check to see if this kill triggers a Journal Entry.
    int nJournal = GetLocalInt(oCreature, "0_Journal");
    if(nJournal > 0)
    {
        KillVillainEffect(oCreature);
        int nCR = FloatToInt(GetChallengeRating (oCreature));
        if(nCR < 1) nCR = 1;
        else if(nCR > 40) nCR = 40;
        // Epic journal entries only go from 1 - 20 thus we subract back to less than 20.
        if(nCR > 20) nCR -= 20;
        location lLocation = GetLocation(oCreature);
        float fXP = 30.0 * nCR;
        if(fXP < 100.0) fXP = 100.0;
        string sJournal = IntToString(nJournal);
        // Get players within the kill area.
        object oPC = GetFirstObjectInShape(SHAPE_SPHERE, XP_PARTY_RADIUS, lLocation, FALSE, OBJECT_TYPE_CREATURE);
        // If the object is valid then continue.
        int nJournalID;
        while(oPC != OBJECT_INVALID)
        {
            // If they are a PC then get the level and compare.
            if(GetIsCharacter(oPC))
            {
                nJournalID = GetObjectDatabaseInt(oPC, QUEST_TABLE, "journalid", "0_quest_v_" + sJournal);
                if(nJournalID < nCR)
                {
                    AdjustXPGiveToCreature(oPC, fXP);
                    AddJournalEntry("0_quest_v_" + sJournal, nCR, oPC, FALSE);
                }
            }
            // Get next object.
            oPC = GetNextObjectInShape(SHAPE_SPHERE, XP_PARTY_RADIUS, lLocation, FALSE, OBJECT_TYPE_CREATURE);
        }
    }
    // If they are a villain and the killer is a player then post the kill to discord!
    if(GetLocalInt (OBJECT_SELF, "0_VILLAIN"))
    {
        if(GetIsCharacter(oKiller)) SendPlayerVillainKilledToDiscord(oKiller, oCreature);
        else
        {
            object oMaster = GetMaster(oKiller);
            if(GetIsCharacter(oMaster)) SendPlayerVillainKilledToDiscord(oMaster, oCreature);
        }
    }
    RemoveCreatureEffects(oCreature);
}

