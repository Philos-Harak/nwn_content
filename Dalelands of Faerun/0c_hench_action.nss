/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_hench_action
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Action script used for all henchman conversations doing an action base on the
 sInput param sent.

 Param: Remove_Henchman - removes the henchman from the party.
 Param: Add_Henchman - Check if you can add and will add henchman to your party.
 Param: Track - has the henchman use the Track feat. For a henchman that can speak.
 Param: Track_Summons - has the henchman use the Track feat. For non-speakers.
 Param: Destroy_Undead - Destroyes oHenchman if they are undead.
 Param: Destroy_My_Undead - Destroys any undead that oPC has as associates.
 Param: Destroy_Your_Undead - Destroys any undead that oHenchman has as associates.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_henchmen"
#include "0i_effects"
void main()
{
    object oHenchman = OBJECT_SELF;
    string sInput = GetScriptParam("sInput");
    //Debug("0c_hench_action", "16", "sInput: " + sInput);
    object oPC = GetPCSpeaker();
    if(sInput == "Remove_Henchman")
    {
        // Turn off stealth mode
        SetActionMode(oHenchman, ACTION_MODE_STEALTH, FALSE);
        // Remove the henchman
        RemoveHenchman(oPC, oHenchman);
        ChangeToStandardFaction(oHenchman, STANDARD_FACTION_DEFENDER);
        ClearAllActions(FALSE, oHenchman);
        PlayVoiceChat(VOICE_CHAT_GOODBYE, oHenchman);
        RemoveHenchmanFromDatabase(oPC, oHenchman);
    }
    else if(sInput == "Add_Henchman")
    {
        SetUpHenchman(oPC, oHenchman);
        AddHenchman(oPC, oHenchman);
        LevelUpCurrentHenchman(oPC);
    }
    else if(sInput == "Track")
    {
        ActionPlayAnimation(ANIMATION_LOOPING_GET_LOW);
        ExecuteScript("0s_find_tracks", oHenchman);
    }
    else if(sInput == "Track_Summons")
    {
        ActionPlayAnimation (ANIMATION_LOOPING_GET_LOW);
        SendMessages ("They bend down to inspect the ground...", COLOR_GREEN, oPC);
        SetLocalObject (oPC, "0_HENCHMAN_TRACKING", OBJECT_SELF);
        ExecuteScript ("0s_find_tracks", oPC);
    }
    else if(sInput == "Destroy_Undead")
    {
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_CONJURE2));
        // Remove Controlled undead Hit Dice from caster.
        string sSpellTag = GetLocalString(oHenchman, "0_SUMMON_SPELL");
        int nCreatureHD = GetHitDice(oHenchman);
        int nTotalHD = GetLocalInt(oPC, sSpellTag);
        SetLocalInt(oPC, sSpellTag, nTotalHD - nCreatureHD);
        SendMessages("You have removed control of " + GetName(oHenchman) + " with " + IntToString(nCreatureHD) +
            " hitdice from a total of " + IntToString(nTotalHD - nCreatureHD) + " hitdice left to control.", COLOR_YELLOW, oPC);
        // Check and remove an PEPS data from the player.
        string sAIData = GetLocalString(oHenchman, "AI_TAG");
        if(sAIData != "") DelayCommand(2.0, DeleteObjectDatabaseName(oPC, "PEPS_TABLE", sAIData));
        SetIsDestroyable(TRUE, FALSE, FALSE, oHenchman);
        int nHP = GetCurrentHitPoints(oHenchman);
        effect eImpact = EffectVisualEffect(VFX_IMP_HARM);
        effect eDmg = EffectDamage(nHP + 10);
        eDmg = EffectLinkEffects(eDmg, eImpact);
        DelayCommand(1.0, RemoveCreatureEffects(oHenchman));
        DelayCommand(1.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDmg, oHenchman));
    }
    else if(sInput == "Destroy_My_Undead")
    {
        int nTotalHD, nHitDice, nHP, nIndex = 1;
        string sSpellTag, sAIData;
        object oCreature = GetHenchman(oPC, nIndex);
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_CONJURE2));
        effect eDmg, eImpact = EffectVisualEffect(VFX_IMP_HARM);
        while(oCreature != OBJECT_INVALID)
        {
            if(GetRacialType(oCreature) == RACIAL_TYPE_UNDEAD)
            {
                // Check and remove an PEPS data from the player.
                sAIData = GetLocalString(oCreature, "AI_TAG");
                if(sAIData != "") DelayCommand(2.0, DeleteObjectDatabaseName(oPC, "PEPS_TABLE", sAIData));
                SetIsDestroyable(TRUE, FALSE, FALSE, oCreature);
                nHP = GetCurrentHitPoints(oCreature);
                eDmg = EffectDamage(nHP + 10);
                eDmg = EffectLinkEffects(eDmg, eImpact);
                DelayCommand(1.0, RemoveCreatureEffects(oCreature));
                DelayCommand(1.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDmg, oCreature));
            }
            oCreature = GetHenchman(oPC, ++nIndex);
        }
        DelayCommand(3.0, DeleteLocalInt(oPC, "ANIMATE_DEAD"));
        DelayCommand(3.0, DeleteLocalInt(oPC, "TURNED_UNDEAD"));
    }
    else if(sInput == "Destroy_Your_Undead")
    {
        int nTotalHD, nHitDice, nHP, nIndex = 1;
        string sSpellTag;
        object oCreature = GetHenchman(oHenchman, nIndex);
        AssignCommand(oHenchman, ActionPlayAnimation(ANIMATION_LOOPING_CONJURE2));
        effect eDmg, eImpact = EffectVisualEffect(VFX_IMP_HARM);
        while(oCreature != OBJECT_INVALID)
        {
            if(GetRacialType(oCreature) == RACIAL_TYPE_UNDEAD)
            {
                SetIsDestroyable(TRUE, FALSE, FALSE, oCreature);
                int nHP = GetCurrentHitPoints(oCreature);
                eDmg = EffectDamage(nHP + 10);
                eDmg = EffectLinkEffects(eDmg, eImpact);
                DelayCommand(1.0, RemoveCreatureEffects(oCreature));
                DelayCommand(1.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDmg, oCreature));
            }
            oCreature = GetHenchman(oHenchman, ++nIndex);
        }
        DelayCommand(3.0, DeleteLocalInt(oPC, "ANIMATE_DEAD"));
        DelayCommand(3.0, DeleteLocalInt(oPC, "TURNED_UNDEAD"));
    }
    else if(sInput == "Remove_Animal_Companion")
    {
        object oCreature = GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oHenchman);
        if(oCreature != OBJECT_INVALID)
        {
            SetIsDestroyable(TRUE, FALSE, FALSE, oCreature);
            DestroyObject(oCreature);
            NWNX_Creature_SetFeatRemainingUses(oHenchman, FEAT_ANIMAL_COMPANION, 1);
        }
    }
    else if(sInput == "Remove_Familiar")
    {
        object oCreature = GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oHenchman);
        if(oCreature != OBJECT_INVALID)
        {
            SetIsDestroyable(TRUE, FALSE, FALSE, oCreature);
            DestroyObject(oCreature);
            NWNX_Creature_SetFeatRemainingUses(oHenchman, FEAT_SUMMON_FAMILIAR, 1);
        }
    }
    else if(sInput == "Remove_Summons")
    {
        ActionPlayAnimation(ANIMATION_LOOPING_CONJURE1);
        object oCreature = GetAssociate(ASSOCIATE_TYPE_SUMMONED, oHenchman);
        if(oCreature != OBJECT_INVALID)
        {
                SetIsDestroyable(TRUE, FALSE, FALSE, oCreature);
                effect eImpact = EffectVisualEffect(VFX_IMP_UNSUMMON);
                ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, GetLocation(oCreature));
                DestroyObject(oCreature);
        }
    }
}
