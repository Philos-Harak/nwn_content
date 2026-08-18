/*//////////////////////////////////////////////////////////////////////////////
 Script: 0i_henchmen
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
    Scripts used for Henchmen.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_traps"
#include "0i_database"
#include "0i_creature"
#include "0i_quest"
// RETURNS TRUE if the player has the maximum number of henchmen.
int HasMaxNumberOfHenchman(object oPC, int bSuppressMessage = FALSE);
// Use to fire the PC's current henchman, NPC.
void FireHenchman(object oPC, object oHench=OBJECT_SELF);
void LevelUpCurrentHenchman(object oPC);
// Setup a henchman for a player.
void SetUpHenchman(object oPC, object oHenchmen, int bFirstSetup = TRUE);
// Checks to make sure a henchman can cast the spell and then casts it if possible.
// returns fDelay increased if the spell is cast otherwise it just returns what it was given.
float CheckAndCastSpell(int nSpell, int nSpellGroup, float fDelay, object oTarget, object oPC = OBJECT_INVALID);
// Clears the spell cast groups for henchmen buffing creatures.
void InitSpellsCastGroups(object oTarget = OBJECT_SELF);
// Will use the henchmans to buff up the best charcters in the party based
// on spells and creatures. Mainly used after resting.
void HenchmanBuff(object oPC);
// Will have the henchmen check to see if they need to pickup equipment on bodies
// or in placeables.
void HenchmanPickupItems();
// Loads any non-dead henchman when a player enters the game.
void CheckForHenchmanOnLoad(object oPC);
// When a player uses a Recall point, usually at a temple, to bring back dead henchmen.
// bSendMessages if TRUE it will display if there are no henchmen to recall.
void RecallHenchman(object oPC, object oPlaceable, int bSendMessages = TRUE);
// Save and remove any henchmen and/or NPC's they may have.
// bDestroyAssociate will destroy all henchmen and/or NPC's for the player. Used for OnClientLeave.
void SaveAssociatesToDatabase(object oPC, int bDestroyAssociate);

int HasMaxNumberOfHenchman(object oPC, int bSuppressMessage = FALSE)
{
    if(GetServerDatabaseString(oPC, OBJECT_TABLE, "objecttag", "henchman10") != "")
    {
        if(!bSuppressMessage)
        {
            SendMessages("You have the maximum number of saved henchman! You can only have up to 10 henchman in your database.", COLOR_RED, oPC);
        }
        return TRUE;
    }
    int nHenchmen, nIndex = 1;
    object oHenchmen = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
    while(oHenchmen != OBJECT_INVALID)
    {
        if(GetLocalInt(oHenchmen, PC_ASSOCIATE_TYPE) == ASSOCIATE_TYPE_HENCHMAN) nHenchmen++;
        oHenchmen = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, ++nIndex);
    }
    if(nHenchmen >= MAX_NUMBER_OF_HENCHMEN)
    {
        if(!bSuppressMessage)
        {
            SendMessages ("You already have maximum number of henchman! You can only have " +
                          IntToString(MAX_NUMBER_OF_HENCHMEN) + " henchman in game at one time.", COLOR_RED, oPC);
        }
        return TRUE;
    }
    return FALSE;
}
void FireHenchman(object oPC, object oHenchman = OBJECT_SELF)
{
    if(oPC == OBJECT_INVALID || oHenchman == OBJECT_INVALID) return;
    // Now double-check that this is actually our master
    if(GetMaster(oHenchman) != oPC) return;
    // Turn off stealth mode
    SetActionMode(oHenchman, ACTION_MODE_STEALTH, FALSE);
    // Remove the henchman
    RemoveHenchman(oPC, oHenchman);
    ClearAllActions(FALSE, oHenchman);
    ChangeToStandardFaction(oHenchman, STANDARD_FACTION_DEFENDER);
    RemoveHenchmanFromDatabase(oPC, oHenchman);
}
void LevelUpCurrentHenchman(object oPC)
{
    /*int nClass, nHenchmanLevel, nLevelsGained, nLeveled, nLeveling, nERL;
    int nIndex = 1;
    int nPCLevel = GetCharacterLevels(oPC, TRUE);
    string sClassName;
    object oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
    while(oAssociate != OBJECT_INVALID && nIndex < 11)
    {
        if(GetLocalInt(oAssociate, PC_ASSOCIATE_TYPE) == ASSOCIATE_TYPE_HENCHMAN)
        {
            nClass = GetClassByPosition(1, oAssociate);
            sClassName = GetStringByStrRef(StringToInt(Get2DAString("classes", "Name", nClass)));
            nHenchmanLevel = GetLevelByPosition(1, oAssociate);
            nERL = GetEffectiveRacialLevel(oAssociate);
            nLevelsGained = nPCLevel - nHenchmanLevel - nERL;
            nLeveling = nLevelsGained;
            while(nLevelsGained > 0)
            {
                NWNX_Creature_LevelUp(oAssociate, nClass, 1);
                nLevelsGained--;
            }
            if(nLeveling > 0)
            {
                SendMessages(GetName(oAssociate) + " has gained " +
                    IntToString(nLeveling) + " levels in " + sClassName + ".", COLOR_YELLOW, oPC);
                // Give class/race specific abilities.
                CheckForFeatsToAdd(oAssociate);
                CheckForClaws(oAssociate, GetHitDice (oAssociate));
                CheckForWings(oAssociate);
                SetCharacterEffectsToSkin(oAssociate);
                SetCharacterEffects(oAssociate);
                SetCreatureAuras(oAssociate);
            }
        }
        oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, ++nIndex);
    }*/
    SendMessages("Use your widget portrait to open up the Party menu. From there you can level up your henchman!", COLOR_YELLOW, oPC);
}
void SetUpHenchman(object oPC, object oHenchman, int bFirstSetup = TRUE)
{
    if(bFirstSetup)
    {
        NWNX_Object_SetDialogResref (oHenchman, "co_henchmen");
        // Set Henchmen's associates.
        int nAssociateType;
        if(GetHasFeat(FEAT_SUMMON_FAMILIAR, oHenchman))
        {
            if(GetHasFeat (1261/*Improved Animal Companion*/, OBJECT_SELF)) nAssociateType = Random (9)+ 9;
            else nAssociateType = Random(9);
            NWNX_Creature_SetFamiliarName(oHenchman, RandomName(NAME_FAMILIAR));
            NWNX_Creature_SetFamiliarCreatureType(oHenchman, nAssociateType);
        }
        if(GetHasFeat(FEAT_ANIMAL_COMPANION, oHenchman))
        {
            if(GetHasFeat(1261/*Improved Animal Companion*/, OBJECT_SELF)) nAssociateType += 9;
            else nAssociateType = Random (9);
            NWNX_Creature_SetAnimalCompanionName(oHenchman, RandomName(NAME_ANIMAL));
            NWNX_Creature_SetAnimalCompanionCreatureType(oHenchman, nAssociateType);
        }
        SaveAssociateToDatabase(oPC, oHenchman);
    }
    // Temporary fix while we are transfering from our AI to Philos PEPS AI.
    if(GetEventScript(oHenchman, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT) == "0e_hen_hrtbeat_1")
    {
        SetEventScript (oHenchman, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "nw_ch_ac1");
    }
    SetLocalObject(oHenchman, "0_Master", oPC);
    SetLocalString(oHenchman, "AI_ON_DEATH", "nw_ch_ac7");
    SetLocalInt(oHenchman, PC_ASSOCIATE_TYPE, ASSOCIATE_TYPE_HENCHMAN);
    // Set to not disappear when dead, not be resurrectable, and selectable.
    SetIsDestroyable(FALSE, FALSE, TRUE, oHenchman);
    SetCharacterEffectsToSkin(oHenchman);
    SetCreatureAuras(oHenchman);
    SetCharacterEffects(oHenchman);
    CheckForFeatsToAdd(oHenchman);
    // AI setting used to define how far away from the player they can go.
    DelayCommand(12.0, SetLocalFloat(oHenchman, "AI_ASSOC_PERCEPTION_DISTANCE", 35.0));
}
void CheckForHenchmanOnLoad(object oPC)
{
    location lLocation = GetLocation(oPC);
    // Get the NPC from the database.
    int nIndex = 1, nHenchmenLoaded;
    string sLocation, sHenchmanTag;
    object oHenchman;
    effect eEffect;
    while(nIndex <= 10 && nHenchmenLoaded < MAX_NUMBER_OF_HENCHMEN)
    {
        sHenchmanTag = "henchmen" + IntToString(nIndex++);
        sLocation = GetServerDatabaseString(oPC, OBJECT_TABLE, "location", sHenchmanTag);
        if(sLocation != "dead")
        {
            oHenchman = GetServerDatabaseObject(oPC, OBJECT_TABLE, lLocation, OBJECT_INVALID, sHenchmanTag);
            if(GetIsObjectValid(oHenchman))
            {
                if(!GetLocalInt (oPC, "0_Character_Loaded")) SetCommandable(TRUE, oHenchman);
                // Make them a henchman.
                AddHenchman(oPC, oHenchman);
                SetUpHenchman(oPC, oHenchman, FALSE);
                if(sLocation == "petrifed")
                {
                    eEffect = EffectPetrify();
                    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eEffect, oHenchman);
                    SetCommandable(FALSE, oHenchman);
                }
                nHenchmenLoaded++;
            }
        }
    }
}
void RecallHenchman(object oPC, object oPlaceable, int bSendMessages = TRUE)
{
    location lLocation = GetLocation(oPC);
    // Get the NPC from the database.
    int bEffectDone, nHenchmen, nIndex = 1;
    string sLocation, sHenchmanTag;
    effect ePower;
    // Count the number of henchman already in the players party.
    object oHenchman = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
    while(oHenchman != OBJECT_INVALID)
    {
        if(GetLocalInt(oHenchman, PC_ASSOCIATE_TYPE) == ASSOCIATE_TYPE_HENCHMAN)
        {
            SetCommandable(TRUE, oHenchman);
            if(GetIsDead(oHenchman))
            {
                RemoveCreatureEffects(oHenchman);
                effect eRaise = EffectResurrection();
                SetIsDestroyable(FALSE, TRUE, TRUE, oHenchman);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eRaise, oHenchman);
                DelayCommand(1.0, AssignCommand(oHenchman, JumpToObject(oPC)));
            }
            if(GetHasEffect(EFFECT_TYPE_PETRIFY, oHenchman))
            {
                RemoveCreatureEffects(oHenchman);
                DelayCommand(1.0, AssignCommand(oHenchman, JumpToObject(oPC)));
                if(oPlaceable != OBJECT_INVALID)
                {
                    ePower = EffectVisualEffect(189, FALSE, 1.0, [0.0,0.0,5.0], [0.0,0.0,180.0]);
                    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, ePower, GetLocation(oPlaceable));
                }
                bEffectDone = TRUE;
                if(bSendMessages) SendMessages(GetName(oHenchman) + " has been recalled!", COLOR_GREEN, oPC);
            }
            nHenchmen++;
        }
        oHenchman = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, ++nIndex);
    }
    nIndex = 1;
    while(nIndex <= 10 && nHenchmen < MAX_NUMBER_OF_HENCHMEN)
    {
        sHenchmanTag = "henchmen" + IntToString(nIndex++);
        sLocation = GetServerDatabaseString(oPC, OBJECT_TABLE, "location", sHenchmanTag);
        if(sLocation == "dead")
        {
            oHenchman = GetServerDatabaseObject(oPC, OBJECT_TABLE, lLocation, OBJECT_INVALID, sHenchmanTag);
            if(GetIsObjectValid(oHenchman))
            {
                if(!bEffectDone)
                {
                    if(oPlaceable != OBJECT_INVALID)
                    {
                        ePower = EffectVisualEffect(189, FALSE, 1.0, [0.0,0.0,5.0], [0.0,0.0,180.0]);
                        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, ePower, GetLocation(oPlaceable));
                    }
                    bEffectDone = TRUE;
                }
                SetServerDatabaseString(oPC, OBJECT_TABLE, "location", "", sHenchmanTag);
                RemoveCreatureEffects(oHenchman);
                SetCommandable(TRUE, oHenchman);
                if(GetIsDead(oHenchman))
                {
                    effect eRaise = EffectResurrection();
                    SetIsDestroyable(FALSE, TRUE, TRUE, oHenchman);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eRaise, oHenchman);
                }
                // Lets remove any other versions of this henchman from the game.
                string sTag = GetTag(oHenchman);
                object oOldHenchman = GetObjectByTag(sTag);
                if(oOldHenchman == oHenchman) oOldHenchman = GetObjectByTag(sTag, 1);
                SetIsDestroyable(TRUE, TRUE, TRUE, oOldHenchman);
                DestroyObject(oOldHenchman);
                // Make them a henchman.
                DelayCommand(0.2, AddHenchman(oPC, oHenchman));
                SetUpHenchman(oPC, oHenchman, FALSE);
                if(bSendMessages) SendMessages(GetName(oHenchman) + " has been recalled!", COLOR_GREEN, oPC);
                nHenchmen++;
            }
        }
    }
    if(!bEffectDone && bSendMessages) SendMessages("You do not have any henchman to recall!", COLOR_RED, oPC);
}
void SaveAssociatesToDatabase(object oPC, int bDestroyAssociate)
{
    int nHenchmen, nAssociateType, nHitDice, nTotalHD, nIndex = 1;
    string sAssociateTag, sDatabaseTag, sQuestID, sNPCArray, sSpellTag, sAIData, sEffect;
    // Since we remove the henchman we just get the first one until there are no more in the party.
    object oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC);
    while(oAssociate != OBJECT_INVALID)
    {
        // Make sure all NPC's are not polymorphed! They will stay that way!
        if(GetLocalInt(oAssociate, "0_NATURAL_FORM") > 0)
        {
            RemoveASpecificEffect(oAssociate, EFFECT_TYPE_POLYMORPH);
        }
        //Debug("0e_clientleave", "251", " oPC:" + GetName(oPC) + " oAssociate: " + GetName(oAssociate) +
        //      " bDestroyAssociate: " + IntToString(bDestroyAssociate) +
        //      " 0_Summon_ID: " + IntToString(GetLocalInt (oAssociate, "0_Summon_ID")) +
        //      " AIData: " + GetLocalString(oAssociate, "AI_TAG"));
        // Work around for Henchman still showing in party after leaving.
        // Remove them from the players party as there is a faction bug if
        // they are saved to the database while in the players party.
        nAssociateType = GetLocalInt(oAssociate, PC_ASSOCIATE_TYPE);
        if(nAssociateType == ASSOCIATE_TYPE_HENCHMAN)
        {
            RemoveHenchman(oPC, oAssociate);
            ChangeToStandardFaction(oAssociate, STANDARD_FACTION_DEFENDER);
            if(GetHasEffect(EFFECT_TYPE_PETRIFY, oAssociate)) sEffect = "petrifed";
            else sEffect = "";
            SaveAssociateToDatabase(oPC, oAssociate, sEffect);
            if(bDestroyAssociate)
            {
                AssignCommand(oAssociate, SetIsDestroyable(TRUE, FALSE, FALSE));
                DestroyObject(oAssociate, 2.0f);
            }
            // If we are going to put them back in the party lets wait until this script is done.
            else DelayCommand(0.0, AddHenchman(oPC, oAssociate));
            oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
        }
        else if(nAssociateType == ASSOCIATE_TYPE_NPC)
        {
            RemoveHenchman(oPC, oAssociate);
            ChangeToStandardFaction(oAssociate, STANDARD_FACTION_DEFENDER);
            sDatabaseTag = SaveAssociateToDatabase(oPC, oAssociate);
            // Save NPC to database for reloading with quests.
            sQuestID = GetQuestIDByNPC(oAssociate, oPC, "npc");
            if(sQuestID != "")
            {
                sNPCArray = GetServerDatabaseString(oPC, QUEST_TABLE, "npc", sQuestID);
                sNPCArray = SetStringArray(sNPCArray, 14, sDatabaseTag, "-");
                SetServerDatabaseString(oPC, QUEST_TABLE, "npc", sNPCArray, sQuestID);
            }
            if(bDestroyAssociate)
            {
                AssignCommand(oAssociate, SetIsDestroyable(TRUE, FALSE, FALSE));
                DestroyObject(oAssociate, 2.0f);
            }
            // If we are going to put them back in the party lets wait until this script is done.
            else DelayCommand(0.0, AddHenchman(oPC, oAssociate));
            oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
        }
        // What happens to dead summons creatures added as henchman.
        else if(GetLocalInt (oAssociate, "0_Summon_ID"))
        {
            if(bDestroyAssociate)
            {
                // Remove Controlled undead Hit Dice from caster.
                sSpellTag = GetLocalString(oAssociate, "0_SUMMON_SPELL");
                nHitDice = GetHitDice(oAssociate);
                nTotalHD = GetLocalInt(oPC, sSpellTag);
                SetLocalInt(oPC, sSpellTag, nTotalHD - nHitDice);
                // Check and remove an PEPS data from the player.
                sAIData = GetLocalString(oAssociate, "AI_TAG");
                if(sAIData != "") DelayCommand(2.0, DeleteObjectDatabaseName(oPC, "PEPS_TABLE", sAIData));
                RemoveHenchman(oPC, oAssociate);
                AssignCommand(oAssociate, SetIsDestroyable(TRUE, FALSE, FALSE));
                DestroyObject(oAssociate, 1.0f);
                oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
            }
            else oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, ++nIndex);
        }
        else oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, ++nIndex);
    }
}
