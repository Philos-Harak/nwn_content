/*////////////////////////////////////////////////
 Script: x0_s0_bigby4
 Programmer: Brent
////////////////////////////////////////////////
Evocation [Force]
Level:  Sor/Wiz 7
Components: V, S, AF/DF
Range: Long
Area of Effect / Target: Single
Duration: 1 round / level
Additional Counter Spells:
Save: None
Spell Resistance: Yes

The Clenched fist gets one attack per round.
Its attack bonus to make contact equals your caster level + your Intelligence,
Wisdom, or Charisma modifier (for wizards, clerics, and sorcerers, respectively),
+11 for the fist's Strength score (33), -1 for being Large.
The fist deals 1d8 + 11 points of damage each attack and any creature struck
make a Fortitude save (against this spell�s save DC) or be stunned for 1 round.

Arcane Focus: A leather glove.
/*///////////////////////////////////////////////
#include "0i_spells"

void ClenchedFist (struct stSpell Spell, object oTarget);

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_FORCE;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iDivineFocus = TRUE;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ENEMIES;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iSpellResistance = TRUE;
    Spell.iDamageType = DAMAGE_TYPE_BLUDGEONING;
    Spell.iModNumOfDice = 1;
    Spell.iModifierDie = 8;
    Spell.iModifier = 11;
    Spell.iImpact = VFX_IMP_ACID_L;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Create visual effects.
    effect eAttack = EffectVisualEffect (VFX_IMP_BIGBYS_FORCEFUL_HAND);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        SignalEvent(Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eAttack , Spell.oAreaTarget));
        // Make resistance and save check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult)
        {
            //Add one round since the ClenchFist function removes 1 round each pass.
            Spell.fDuration = Spell.fDuration + 6.0f;
            ClenchedFist (Spell, Spell.oAreaTarget);
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}


// We make attacks against the target until the spell ends.
void ClenchedFist (struct stSpell Spell, object oTarget)
{
    // Check to see if the spell has ended.
    if (Spell.fDuration <= 0.0f) return;
    else Spell.fDuration = Spell.fDuration - 6.0f;
    // If the target is dead then move to the nearest enemy.
    if (GetIsDead (oTarget))
    {
        int iCounter = 1;
        object oNewTarget = GetNearestObject (OBJECT_TYPE_CREATURE, oTarget, iCounter);
        while (GetIsObjectValid (oNewTarget))
        {
            if (GetIsSpellTargetValid (oNewTarget, Spell.iTargetType, Spell.oCaster) &&
                GetDistanceBetween (oTarget, oNewTarget) <= 30.0f)
            {
                // We found a new enemy so attack next round and exit this.
                DelayCommand (6.0f, ClenchedFist (Spell, oNewTarget));
                return;
            }
            iCounter ++;
            oNewTarget = GetNearestObject (OBJECT_TYPE_CREATURE, oTarget, iCounter);
        }
        // We didn't find a new target so lets end the spell.
        return;
    }
    // Declare variables.
    string sMessage;
    int iCasterAtkRoll, iCasterAtkMod, iTargetAC;
    effect eDmg;
    // Create visual effects.
    effect eMind = EffectVisualEffect (VFX_DUR_MIND_AFFECTING_DISABLED);
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_NEGATIVE);
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eImpact2 = EffectVisualEffect (VFX_IMP_BIGBYS_FORCEFUL_HAND);
    // Create effects.
    effect eStun = EffectStunned ();
    // Link effects.
    effect eLink = EffectLinkEffects (eDuration, eMind);
    eLink = EffectLinkEffects (eLink, eStun);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
    // Make attack.
    iCasterAtkMod = GetCasterAbilityModifier (Spell.oCaster) + Spell.iCasterLevel + 11 - 1;
    iCasterAtkRoll = d20();
    iTargetAC = GetAC (oTarget);
    if ((iCasterAtkRoll + iCasterAtkMod) >= iTargetAC)
    {
        // Send attack message *hit*.
        sMessage = AddColorToText ("Bigby's Clenched Fist", COLOR_MAGENTA) +
                   AddColorToText (" attacks " + GetName (oTarget) + " : *hit* : (" +
                           IntToString (iCasterAtkRoll) + " + " + IntToString (iCasterAtkMod) +
                     " = " + IntToString (iCasterAtkRoll + iCasterAtkMod) + ")", COLOR_ORANGE);
        SendMessageToPC (Spell.oCaster, sMessage);
        SendMessageToPC (oTarget, sMessage);
        // Get the result for the effect, sets Spell.iResult.
        Spell = GetModifier (Spell);
        eDmg = EffectDamage (Spell.iResult, Spell.iDamageType);
        eDmg = SetEffectCasterLevel(eDmg, Spell.iCasterLevel);
        ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, oTarget);
        ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact2, oTarget);
        ApplyEffectToObject (DURATION_TYPE_INSTANT, eDmg, oTarget);
        // Make Fortitude save or be stunned.
        if (!SavingThrowWithEffects (SAVING_THROW_FORT, oTarget, Spell.iSaveDC) &&
            !GetIsImmune (oTarget, IMMUNITY_TYPE_STUN))
        {
            ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eLink, oTarget, 6.0f);
        }
    }
    // Show that the spell missed!
    else
    {
       // Send attack message *miss*.
       sMessage = AddColorToText ("Bigby's Clenched Fist", COLOR_MAGENTA) +
                  AddColorToText (" attacks " + GetName (oTarget) + " : *miss* : (" +
                           IntToString (iCasterAtkRoll) + " + " + IntToString (iCasterAtkMod) +
                     " = " + IntToString (iCasterAtkRoll + iCasterAtkMod) + ")", COLOR_ORANGE);
       SendMessageToPC (Spell.oCaster, sMessage);
       SendMessageToPC (oTarget, sMessage);
    }
    DelayCommand (6.0f, ClenchedFist (Spell, oTarget));
}
