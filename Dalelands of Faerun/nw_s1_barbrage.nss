/*////////////////////////////////////////////////
 Barbarian Rage
 Created By: Preston Watamaniuk
////////////////////////////////////////////////
 Duration of rage is 3 + new constitution modifier rounds.
 The barbarian may rage, gaining a +4 morale bonus to Strength and Constitution
 and +2 to all Will saving throws, in exchange for a -2 penalty to Armor Class.

 Greater rage feat, gives the barbarian +6 to Strength and Consitution
 and +3 to Will saves (the -2 penalty to Armor Class still applies).
 Fearless rage makes them immune to fear while in the rage.
 Deathless rage makes them immune to damage below 20 while in the rage.
/*///////////////////////////////////////////////
#include "x2_inc_itemprop"
#include "0i_spells"

// If the character has the thundering rage feat,
// their weapons are up graded to deafen and cause 2d6 points of massive criticals.
void CheckAndApplyThunderingRage (float fDuration)
{
   if (GetHasFeat(988, OBJECT_SELF))
   {
        object oWeapon =  GetItemInSlot (INVENTORY_SLOT_RIGHTHAND);
        if (GetIsObjectValid(oWeapon))
        {
           IPSafeAddItemProperty (oWeapon, ItemPropertyMassiveCritical (IP_CONST_DAMAGEBONUS_2d6), fDuration, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, TRUE, TRUE);
           IPSafeAddItemProperty (oWeapon, ItemPropertyVisualEffect (ITEM_VISUAL_SONIC), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, FALSE, TRUE);
           IPSafeAddItemProperty (oWeapon, ItemPropertyOnHitProps (IP_CONST_ONHIT_DEAFNESS,IP_CONST_ONHIT_SAVEDC_20,IP_CONST_ONHIT_DURATION_25_PERCENT_3_ROUNDS), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, FALSE, TRUE);
        }
        oWeapon =  GetItemInSlot(INVENTORY_SLOT_LEFTHAND);
        {
           IPSafeAddItemProperty (oWeapon, ItemPropertyMassiveCritical (IP_CONST_DAMAGEBONUS_2d6), fDuration, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, TRUE, TRUE);
           IPSafeAddItemProperty (oWeapon, ItemPropertyVisualEffect (ITEM_VISUAL_SONIC), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, FALSE, TRUE);
        }
     }
}

// If the character calling this function from a spellscript has the terrifying
// rage feat, he gets an aura of fear for the specified duration
// The saving throw against this fear is a check opposed to the character's
// intimidation skill
void CheckAndApplyTerrifyingRage (float fDuration)
{
    if (GetHasFeat (989, OBJECT_SELF))
    {
        effect eAOE = EffectAreaOfEffect (AOE_MOB_FEAR, "x2_s2_terrage_A", "", "");
        eAOE = ExtraordinaryEffect(eAOE);
        ApplyEffectToObject (DURATION_TYPE_TEMPORARY,eAOE, OBJECT_SELF, fDuration);
    }
}

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_EXTRAORDINARY;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 3; // Add constitution modifier in body of script.
    Spell.iImpact = VFX_IMP_IMPROVE_ABILITY_SCORE;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Party rage and barbarian rage do not stack.
    if(!GetHasFeatEffect(FEAT_BARBARIAN_RAGE) && !GetHasFeatEffect(FEAT_PARTY_RAGE))
    {
        //Declare major variables
        int iIncrease, iSave, iBattleCry;
        effect eFear;
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
        // Make them scream!
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
        PlayVoiceChat(iBattleCry);
        //Determine the duration by getting the con modifier after being modified
        Spell.iDuration = 3 + GetAbilityModifier (ABILITY_CONSTITUTION) + (iIncrease / 2);
        // Get the duration of the spell.
        Spell = GetDuration (Spell);
        effect eStr = EffectAbilityIncrease (ABILITY_CONSTITUTION, iIncrease);
        effect eCon = EffectAbilityIncrease (ABILITY_STRENGTH, iIncrease);
        effect eSave = EffectSavingThrowIncrease (SAVING_THROW_WILL, iSave);
        effect eAC = EffectACDecrease (2, AC_DODGE_BONUS);
        effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
        effect eLink = EffectLinkEffects (eCon, eStr);
        eLink = EffectLinkEffects (eLink, eSave);
        eLink = EffectLinkEffects (eLink, eAC);
        eLink = EffectLinkEffects (eLink, eDur);
        // If they have fearless rage then add fear immunity to the effects.
        if (GetHasFeat (FEAT_FEARLESS_RAGE))
        {
            eFear =  EffectImmunity (IMMUNITY_TYPE_FEAR);
            eLink = EffectLinkEffects (eLink, eFear);
        }
        SignalEvent (Spell.oCaster, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        //Make effect extraordinary
        eLink = ExtraordinaryEffect(eLink);
        effect eVis = EffectVisualEffect(Spell.iImpact);
        //Apply the VFX impact and effects
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, Spell.oCaster, Spell.fDuration);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, Spell.oCaster) ;
        // Check to see if they have Deathless rage.
        if (GetHasFeat (FEAT_DEATHLESS_RAGE))
        {
            SetImmortal (Spell.oCaster, TRUE);
            DelayCommand (Spell.fDuration, SetImmortal (Spell.oCaster, FALSE));
        }
        CheckAndApplyThunderingRage (Spell.fDuration);
        CheckAndApplyTerrifyingRage (Spell.fDuration);
    }
}
