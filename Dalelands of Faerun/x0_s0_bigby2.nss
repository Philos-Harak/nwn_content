/*////////////////////////////////////////////////
 Script:x0_s0_bigby2
 Programmer: Brent
////////////////////////////////////////////////
Evocation [Force]
Level:  Sor/Wiz 6
Components: V, S, F
Range: Long
Area of Effect / Target: Single
Duration: 1 round / level
Additional Counter Spells:
Save: None
Spell Resistance: Yes

A giant hand appears and bull rushes with a +14 (+10 for strength and +4 for size)
bonus on the bull rush vs the targets Athletics check and size bonus.
If successful the target is knocked down and dazed for 1 round / level.

Focus: A sturdy glove made of leather or heavy cloth.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.sDivineComponent = COMPONENT_POUCH;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ENEMIES;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iSpellResistance = TRUE;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    int iCasterStr, iTargetStr;
    string sMessage;
    // Create visual effects.
    effect eAttack = EffectVisualEffect (VFX_IMP_BIGBYS_FORCEFUL_HAND);
    effect eMind = EffectVisualEffect (VFX_DUR_MIND_AFFECTING_DISABLED);
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_NEGATIVE);
    // Create effects.
    effect eDaze = EffectDazed ();
    effect eKnockdown = EffectKnockdown ();
    // Link effects.
    effect eLink = EffectLinkEffects (eDuration, eDaze);
    eLink = EffectLinkEffects (eLink, eKnockdown);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
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
            // Make bull rush check.
            iCasterStr = d20();
            iTargetStr = d20() + GetSkillRank (SKILL_ATHLETICS, Spell.oAreaTarget) + GetCreatureSizeModifier (Spell.oAreaTarget);
            if ((iCasterStr + 14) >= iTargetStr)
            {
                DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink , Spell.oAreaTarget, Spell.fDuration));
                DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eMind , Spell.oAreaTarget, Spell.fDuration));
                sMessage = AddColorToText ("Bigby's Forceful Hand", COLOR_MAGENTA) +
                           AddColorToText (" bull rushes " + GetName (Spell.oAreaTarget) + " : *hit* : (" +
                                   IntToString (iCasterStr) + " + " + IntToString (14) +
                           " = " + IntToString (iCasterStr + 14) + ")", COLOR_ORANGE);
                SendMessageToPC (Spell.oCaster, sMessage);
                SendMessageToPC (Spell.oAreaTarget, sMessage);
                // * Bull Rush succesful
                //FloatingTextStrRefOnCreature (8966, Spell.oCaster, FALSE);
            }
            else
            {
                sMessage = AddColorToText ("Bigby's Forceful Hand", COLOR_MAGENTA) +
                           AddColorToText (" bull rushes " + GetName (Spell.oAreaTarget) + " : *miss* : (" +
                                   IntToString (iCasterStr) + " + " + IntToString (14) +
                           " = " + IntToString (iCasterStr + 14) + ")", COLOR_ORANGE);
                SendMessageToPC (Spell.oCaster, sMessage);
                SendMessageToPC (Spell.oAreaTarget, sMessage);
                // * Bull Rush Failed
                //FloatingTextStrRefOnCreature(8967, Spell.oCaster, FALSE);
            }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
