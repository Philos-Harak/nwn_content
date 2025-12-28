/*////////////////////////////////////////////////
 Party Rage
 Created By: Philos
////////////////////////////////////////////////
 The barbarian may make all party members within 30' rage,
 gaining a +4 morale bonus to Strength and Constitution
 and +2 to all Will saving throws, in exchange for a -2 penalty to Armor Class.

 Greater rage feat, gives the barbarian +6 to Strength and Consitution
 and +3 to Will saves (the -2 penalty to Armor Class still applies).
 Fearless rage makes them immune to fear while in the rage.
 Deathless rage makes them immune to damage below 20 while in the rage.
/*///////////////////////////////////////////////
#include "x2_i0_spells"
#include "0i_server_const"
void main()
{
    // Party rage and barbarian rage do not stack.
    if(!GetHasFeatEffect(FEAT_BARBARIAN_RAGE) && !GetHasFeatEffect(FEAT_PARTY_RAGE))
    {
        //Declare major variables
        int iIncrease, iSave, iBattleCry;
        effect eFear;
        location lLocation;
        object oCreature;
        // Has Greater rage.
        if (GetHasFeat (FEAT_GREATER_RAGE))
        {
            iIncrease = 6;
            iSave = 3;
        }
        // Else do normal rage.
        else
        {
            iIncrease = 4;
            iSave = 2;
        }
        //Determine the duration by getting the con modifier after being modified
        effect eStr = EffectAbilityIncrease (ABILITY_CONSTITUTION, iIncrease);
        effect eCon = EffectAbilityIncrease (ABILITY_STRENGTH, iIncrease);
        effect eSave = EffectSavingThrowIncrease (SAVING_THROW_WILL, iSave);
        effect eAC = EffectACDecrease (2, AC_DODGE_BONUS);
        effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
        effect eLink = EffectLinkEffects (eCon, eStr);
        eLink = EffectLinkEffects (eLink, eSave);
        eLink = EffectLinkEffects (eLink, eAC);
        eLink = EffectLinkEffects (eLink, eDur);
        //Make effect extraordinary
        eLink = ExtraordinaryEffect(eLink);
        effect eVis = EffectVisualEffect(VFX_IMP_IMPROVE_ABILITY_SCORE);
        // If they have fearless rage then add fear immunity to the effects.
        if (GetHasFeat (FEAT_FEARLESS_RAGE))
        {
            eFear =  EffectImmunity (IMMUNITY_TYPE_FEAR);
            eLink = EffectLinkEffects (eLink, eFear);
        }
        lLocation = GetLocation (OBJECT_SELF);
        // Cycle through all creatures within a 10' radius.
        oCreature = GetFirstObjectInShape (SHAPE_SPHERE, 30.0f, lLocation, TRUE);
        while (GetIsObjectValid (oCreature))
        {
            // We can't enrage dead creatures!
            if (!GetIsDead (oCreature))
            {
                // Check to see if the creature is in the Orc Warlords party or is the Orc Warlord.
                if (GetFactionEqual (oCreature, OBJECT_SELF) || OBJECT_SELF == GetMaster (oCreature) || oCreature == OBJECT_SELF)
                {
                    SignalEvent (oCreature, EventSpellCastAt (oCreature, SPELLABILITY_BARBARIAN_RAGE, FALSE));
                    // Get duration.
                    int iDuration = 3 + GetAbilityModifier (ABILITY_CONSTITUTION, oCreature) + (iIncrease / 2);
                    //Apply the VFX impact and effects
                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oCreature, RoundsToSeconds (iDuration));
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oCreature) ;
                    // 2003-07-08, Georg: Rage Epic Feat Handling
                    AssignCommand (oCreature, CheckAndApplyEpicRageFeats (iDuration));
                    // Make the scream!
                    int iRoll = d6();
                    switch (iRoll)
                    {
                        case 1: iBattleCry = VOICE_CHAT_BATTLECRY1; break;
                        case 2: iBattleCry = VOICE_CHAT_BATTLECRY2; break;
                        case 3: iBattleCry = VOICE_CHAT_BATTLECRY3; break;
                        case 4: iBattleCry = VOICE_CHAT_CUSS; break;
                        case 5: iBattleCry = VOICE_CHAT_TAUNT; break;
                        case 6: iBattleCry = VOICE_CHAT_THREATEN; break;
                    }
                    PlayVoiceChat (iBattleCry, oCreature);
                    // Check to see if the barbarian has Deathless rage.
                    if (GetHasFeat (FEAT_DEATHLESS_RAGE))
                    {
                        SetImmortal (oCreature, TRUE);
                        DelayCommand (RoundsToSeconds (iDuration), SetImmortal (oCreature, FALSE));
                    }
                }
            }
            oCreature = GetNextObjectInShape (SHAPE_SPHERE, 30.0f, lLocation, TRUE);
        }
    }
}
