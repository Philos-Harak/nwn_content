/*//////////////////////////////////////////////////////////////////////////////
 Script: nw_ch_ac7
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Henchmen on death script.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_effects"
#include "0i_henchmen"
#include "0i_creature"
// Will resurrect an associate and put them back in the party.
void ResurrectAssociate(object oAssociate, int nAssociateType, int nSpell = 0)
{
    // Remove the droppable flag on an associates items.
    SetDroppableFlagAllInventory(oAssociate, TRUE, TRUE);
    // Give them back any gold they had.
    int nGold = GetLocalInt(oAssociate, "0_Gold");
    GiveGoldToCreature(oAssociate, nGold);
    // Reset dying to normal status.
    NWNX_Creature_OverrideDamageLevel(oAssociate, -1);
    SetAssociateMode(MODE_DYING, FALSE);
    // Resurrect associate.
    SetIsDestroyable(FALSE, TRUE, TRUE, oAssociate);
    effect eResurrect = EffectResurrection();
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eResurrect, oAssociate);
    // Check for spell resurrection and give hitpoints accordingly.
    if(nSpell == SPELL_RESURRECTION || nSpell == 970/*SPELL_TRUE_RESURRECTION*/)
    {
        NWNX_Object_SetCurrentHitPoints(oAssociate, GetMaxHitPoints(oAssociate));
    }
    object oMaster = GetLocalObject(oAssociate, "0_Master");
    AddHenchman(oMaster, oAssociate);
    SetCommandable(TRUE, oAssociate);
    if(nAssociateType == ASSOCIATE_TYPE_NPC)
    {
        string sQuestID = GetQuestIDByNPC(oAssociate, oMaster, "npc");
        SetQuestState(oMaster, sQuestID, 9, 0);
    }
    if(nSpell == 0) SpeakString(GetName(oAssociate) + " has recovered!!");
    if(GetArea(oMaster) != GetArea(oAssociate)) AssignCommand(oAssociate, JumpToObject(oMaster));
}
void AssociateDied(object oAssociate, int nAssociateType)
{
    // Set them as dead.
    object oPC = GetLocalObject(oAssociate, "0_Master");
    if(nAssociateType == ASSOCIATE_TYPE_NPC)
    {
        // Set the quest NPC as dead.
        string sQuestID = GetQuestIDByNPC(oAssociate, oPC, "npc");
        SetQuestState(oPC, sQuestID, 9, 1);
        RemoveHenchmanFromDatabase(oPC, oAssociate);
        // Create the remains for our PC's to loot.
        CreateRemains(oAssociate);
    }
    if(nAssociateType == ASSOCIATE_TYPE_HENCHMAN)
    {
        // Get location to safely copy oAssociate so we can resurrect and save.
        location lLocation = GetLocation(GetWaypointByTag(WP_CREATURE_SPAWN));
        object oHenchman = CopyObject(oAssociate, lLocation, OBJECT_INVALID, "", TRUE);
        SetIsDestroyable(TRUE, TRUE, TRUE, oHenchman);
        effect eResurrect = EffectResurrection();
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eResurrect, oHenchman);
        ActionSaveAssociateToDatabase(oPC, oHenchman, "dead");
        DestroyObject(oHenchman);
    }
    SetIsDestroyable(FALSE, TRUE, TRUE, oAssociate);
    NWNX_Creature_OverrideDamageLevel(oAssociate, 5);
    SetAssociateMode(MODE_DEAD, TRUE, oAssociate);
    DeathEffect(oAssociate);
}
void AssociateBleeding(object oAssociate, int nAssociateType)
{
    int nHp = GetCurrentHitPoints(oAssociate);
    if(nHp < -10) nHp = GetLocalInt(oAssociate, "0_Hitpoints");
    else
    {
        nHp = nHp + 11 + GetLocalInt(oAssociate, "0_Hitpoints");
    }
    // If below 1 then lets check for what happens next.
    // Check to see if we are dead!
    if(nHp < -9)
    {
        AssociateDied(oAssociate, nAssociateType);
        return;
    }
    else if(nHp < 1)
    {
         // Make the Fortitude Save to see if we are stable for this round.
         // Set the DC to BLEED_DC + Current Hitpoints below Zero.
         if(FortitudeSave(oAssociate, BLEED_DC - nHp, SAVING_THROW_TYPE_DEATH))
         {
            ResurrectAssociate (oAssociate, nAssociateType);
            return;
         }
         else
         {
             // We have failed so lets bleed the character for this round.
             SetLocalInt(oAssociate, "0_Hitpoints", --nHp);
             // Sometimes play voice pain.
             if(d100() < 25)
             {
                 int iPain = d4();
                 if(iPain == 1) PlayVoiceChat(VOICE_CHAT_PAIN1);
                 else if(iPain == 2) PlayVoiceChat(VOICE_CHAT_PAIN2);
                 else if(iPain == 3) PlayVoiceChat(VOICE_CHAT_PAIN3);
                 else PlayVoiceChat(VOICE_CHAT_NEARDEATH);
             }
             SpeakString(GetName(oAssociate) + " is bleeding! (" + IntToString(nHp) + ")");
             NWNX_Creature_OverrideDamageLevel(oAssociate, 6);
             // Check for bleeding the next round.
             DelayCommand(6.0, AssociateBleeding (oAssociate, nAssociateType));
         }
     }
     if(nHp > 0)
     {
        ResurrectAssociate(oAssociate, nAssociateType);
        if(nHp > 1)
        {
            effect eHeal = EffectHeal(nHp - 1);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, oAssociate);
        }
     }
}
void main()
{
    object oCreature = OBJECT_SELF;
    int nAssociateType = GetLocalInt(oCreature, PC_ASSOCIATE_TYPE);
    if(nAssociateType == ASSOCIATE_TYPE_FAMILIAR)
    {
        // Familiars do d6 damage to their masters when they die.
        int nDmg = d6();
        object oMaster = GetMaster();
        effect eDmg = EffectDamage (nDmg);
        FloatingTextStrRefOnCreature (63489, oMaster, FALSE);
        ApplyEffectToObject (DURATION_TYPE_PERMANENT, eDmg, oMaster);
    }
    object oKiller = GetLastKiller();
    if(GetIsCharacter(oKiller))
    {
        int iKills = GetLocalInt(oKiller, "0_Kills") + 1;
        SetLocalInt(oKiller, "0_Kills", iKills);
    }
    //GiveXPForKill(oCreature);
    if(nAssociateType == ASSOCIATE_TYPE_HENCHMAN ||
       nAssociateType == ASSOCIATE_TYPE_NPC)
    {
        // Remove all gold and store as a variable.
        int nGold = GetGold();
        SetLocalInt(oCreature, "0_Gold", nGold);
        TakeGoldFromCreature(nGold, oCreature, TRUE);
        // Make all henchmen items not droppable or they maybe picked up by an another associate.
        SetDroppableFlagAllInventory(oCreature, FALSE, TRUE);
        // Get henchmens hitpoints from variable since when a henchmen dies they
        // automatically go to -10 hitpoints.
        // Check to see if they just died! Took more than -9 damage.
        if(GetLocalInt(oCreature, "0_Hitpoints") < -9) AssociateDied(oCreature, nAssociateType);
        else
        {
            // Set them as bleeding.
            NWNX_Creature_OverrideDamageLevel(oCreature, 6);
            SetAssociateMode(MODE_DYING);
            // Check for the Sorcerer's Undeath blood line II feat, periapt of wound closure,
            // or they are under the influence of the magical divine bard song.
            // These automatically stop bleeding.
            if(GetHasFeat(1351/*Undeath blood line II*/) ||
               GetTag (GetItemInSlot(INVENTORY_SLOT_NECK, oCreature)) == "0_periapt_woundc" ||
               GetHasSpellEffect(930/*SPELL_BARD_SONG_DIVINE*/, oCreature))
            {
                DelayCommand(6.0, ResurrectAssociate (oCreature, nAssociateType));
            }
            else DelayCommand(6.0, AssociateBleeding (oCreature, nAssociateType));
        }
    }
    // What happens to dead summons creatures added as henchman.
    else if(GetLocalInt (oCreature, "0_Summon_ID"))
    {
        // Used to remove Turned Undead and Animate Dead controlling Hit Dice.
        string sSpellTag = GetLocalString(oCreature, "0_SUMMON_SPELL");
        if(sSpellTag == "ANIMATE_DEAD" || sSpellTag == "TURNED_UNDEAD")
        {
            // Removes Hit Dice from casters controlled undead stats.
            int nCreatureHD = GetHitDice(oCreature);
            object oMaster = GetMaster(oCreature);
            if(GetIsCharacter(oMaster))
            {
                DecreaseUndeadControlledHitDice(oMaster, oCreature, sSpellTag);
                // Check and remove an PEPS data from the player.
                string sAIData = GetLocalString(oCreature, "AI_TAG");
                if(sAIData != "") DelayCommand(2.0, DeleteObjectDatabaseName(oMaster, "PEPS_TABLE", sAIData));
                RemoveCreatureEffects(oCreature);
            }
        }

    }
}
