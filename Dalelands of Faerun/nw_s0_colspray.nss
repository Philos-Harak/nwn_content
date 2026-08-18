/*////////////////////////////////////////////////
 Script: NW_S0_ColSpray.nss
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Illusion (Pattern) [Mind-Affecting]
Level:  Sor/Wiz 1
Components:     V, S, M
Casting Time:   1 standard action
Range: Close.
Area:   Cone-shaped burst
Duration:   Instantaneous; see text
Saving Throw:   Will negates
Spell Resistance:   Yes
A vivid cone of clashing colors springs forth from your hand, causing creatures
to become stunned, blinded, or possibly knocking them unconscious.
Each creature within the cone is affected according to its Hit Dice.

2 HD or less
The creature is unconscious for 3 + 1d4 rounds.(Only living creatures are knocked unconscious.)
3 or 4 HD
The creature is blinded for 2 + 1d4 rounds.
5 or more HD
The creature is stunned for 1 + 1d4 rounds.

Material Component: A pinch each of powder or sand that is colored red, yellow, and blue.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iSubSchool = SUBSCHOOL_PATTERN;
    Spell.iDescriptor = DESC_MIND;
    Spell.sArcaneComponent = "COMPONENT_POUCH";
    Spell.iAreaShape = SHAPE_SPELLCONE;
    Spell.fAreaSize = 30.0f;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDurNumOfDice = 1;
    Spell.iDurationDie = 4;
    Spell.iDuration = 3;
    Spell.iSave = SAVING_THROW_WILL;
    Spell.iSaveType = SAVING_THROW_TYPE_MIND_SPELLS;
    Spell.iSpellResistance = TRUE;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    int iHD;
    effect eSleep = EffectSleep();
    effect eStun = EffectStunned();
    effect eBlind = EffectBlindness();
    effect eMind = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_NEGATIVE);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eLSleep = EffectLinkEffects(eSleep, eMind);
    eLSleep = SetEffectCasterLevel(eLSleep, Spell.iCasterLevel);
    effect eLStun = EffectLinkEffects(eStun, eMind);
    eLStun = SetEffectCasterLevel(eLStun, Spell.iCasterLevel);
    effect eLBlind = EffectLinkEffects(eBlind, eMind);
    eLBlind = SetEffectCasterLevel(eLBlind, Spell.iCasterLevel);
    effect eImpSleep = EffectVisualEffect(VFX_IMP_SLEEP);
    effect eImpStun = EffectVisualEffect(VFX_IMP_STUN);
    effect eImpBlind = EffectVisualEffect(VFX_IMP_BLIND_DEAF_M);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // Make resistance and save check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult)
        {
            iHD = GetHitDice (Spell.oAreaTarget);
            // 1-2 HD: Sleep for 3 + 1d4 rounds
            if (iHD <= 2)
            {
                 DelayCommand(Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpSleep, Spell.oAreaTarget));
                 DelayCommand(Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLSleep, Spell.oAreaTarget, Spell.fDuration));
            }
            //3-4 HD: Blinded for 2 + 1d4 rounds
            else if (iHD < 5)
            {
                 Spell.fDuration = Spell.fDuration - 6.0f;
                 DelayCommand(Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpBlind, Spell.oAreaTarget));
                 DelayCommand(Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLBlind, Spell.oAreaTarget, Spell.fDuration));
            }
            //Over 4 HD: Stunned for 1 + 1d4 round
            else
            {
                 Spell.fDuration = Spell.fDuration - 6.0f;
                 DelayCommand(Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpStun, Spell.oAreaTarget));
                 DelayCommand(Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLStun, Spell.oAreaTarget, Spell.fDuration));
            }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

