/*////////////////////////////////////////////////
 Script: x0_s0_bigby5
 Programmer: Brent
////////////////////////////////////////////////
Evocation [Force]
Level:  Sor/Wiz 9
Components: V, S, Material
Range: Long
Area of Effect / Target: Single
Duration: 1 round / level
Additional Counter Spells:
Save: None
Spell Resistance: Yes

The crushing hand gets one grapple attack per round.
Its attack bonus to make contact equals your caster level + your Intelligence,
Wisdom, or Charisma modifier (for wizards, clerics, and sorcerers, respectively),
+12 for the hand's Strength score (35), -1 for being Large. Its grapple bonus is
this same figure, except with a +4 modifier for being Large instead of -1. The
hand crushes the creature it has grappled for 2d6+12 damage.If the creature dies
it will move to the nearest enemy.

Arcane Focus: The shell of an egg.

   // Mark B's famous advice:
   // Note:  if the target is dead during one of these second-long heartbeats,
   // the DelayCommand doesn't get run again, and the whole package goes away.
   // Do NOT attempt to put more than two parameters on the delay command.  They
   // may all end up on the stack, and that's all bad.  60 x 2 = 120.
/*///////////////////////////////////////////////
#include "0i_spells"
void CrushingHandAttack (struct stSpell Spell, object oTarget);
void CrushingHandDamage (struct stSpell Spell, object oTarget);

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
    Spell.iModNumOfDice = 2;
    Spell.iModifierDie = 6;
    Spell.iModifier = 12;
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
            //Add one round since the CrushingHandAttack function removes 1 round each pass.
            Spell.fDuration = Spell.fDuration - 6.0f;
            CrushingHandAttack (Spell, Spell.oAreaTarget);
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

// If the hand fails on an attack we attempt another attack the next round
// until the spells duration ends.
void CrushingHandAttack (struct stSpell Spell, object oTarget)
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
                DelayCommand (6.0f, CrushingHandAttack (Spell, oNewTarget));
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
    int iCasterAtkRoll, iCasterAtkMod, iTargetAC, iTargetGrapple;
    effect eLinkLoop;
    // Create visual effects.
    effect eBreakfree = EffectVisualEffect (VFX_IMP_BREACH);
    effect eMind = EffectVisualEffect (VFX_DUR_MIND_AFFECTING_DISABLED);
    effect eVisual = EffectVisualEffect (VFX_DUR_BIGBYS_CRUSHING_HAND);
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_NEGATIVE);
    // Create effects.
    effect eHeldImmune = EffectCutsceneImmobilize ();
    effect eHeld = EffectParalyze ();
    // Link effects.
    effect eLink = EffectLinkEffects (eDuration, eVisual);
    // Make attack.
    iCasterAtkMod = GetCasterAbilityModifier (Spell.oCaster) + Spell.iCasterLevel + 12 - 1;
    iCasterAtkRoll = d20();
    iTargetAC = GetAC (oTarget);
    if ((iCasterAtkRoll + iCasterAtkMod) >= iTargetAC)
    {
        // Send attack message *hit*.
        sMessage = AddColorToText ("Bigby's Crushing Hand", COLOR_MAGENTA) +
                   AddColorToText (" attacks " + GetName (oTarget) + " : *hit* : (" +
                           IntToString (iCasterAtkRoll) + " + " + IntToString (iCasterAtkMod) +
                     " = " + IntToString (iCasterAtkRoll + iCasterAtkMod) + ")", COLOR_ORANGE);
        SendMessageToPC (Spell.oCaster, sMessage);
        SendMessageToPC (oTarget, sMessage);
        // Make Grapple (Size -1 for atk is adjusted to Size +4 for grapple = +5).
        iCasterAtkRoll = d20 ();
        iCasterAtkMod = iCasterAtkMod + 5;
        iTargetGrapple = d20 () + GetBaseAttackBonus (oTarget)
                                + GetCreatureSizeModifier (oTarget)
                                + GetAbilityModifier (ABILITY_STRENGTH, oTarget);
        if ((iCasterAtkRoll + iCasterAtkMod) >= iTargetGrapple)
        {
           // Send grapple message *grappled*.
           sMessage = AddColorToText ("Bigby's Crushing Hand", COLOR_MAGENTA) +
                      AddColorToText (" grapples " + GetName (oTarget) + " : *grappled* : (" +
                               IntToString (iCasterAtkRoll) + " + " + IntToString (iCasterAtkMod) +
                         " = " + IntToString (iCasterAtkRoll + iCasterAtkMod) + ")", COLOR_ORANGE);
                    SendMessageToPC (Spell.oCaster, sMessage);
                    SendMessageToPC (oTarget, sMessage);
           if (GetIsImmune (Spell.oAreaTarget, IMMUNITY_TYPE_PARALYSIS) ||
               GetIsImmune(Spell.oAreaTarget, IMMUNITY_TYPE_MIND_SPELLS))
           {
               eLinkLoop = EffectLinkEffects (eLink, eHeldImmune);
           }
           else eLinkLoop = EffectLinkEffects (eLink, eHeld);
           DelayCommand (0.5f, ApplyEffectToObject (Spell.iDurationType, eLinkLoop , oTarget, Spell.fDuration));
           DelayCommand (0.5f, ApplyEffectToObject (Spell.iDurationType, eMind , oTarget, Spell.fDuration));
           // Now lets do damage!
           CrushingHandDamage (Spell, oTarget);
           // *Target grappled!*
           //FloatingTextStrRefOnCreature (2478, Spell.oCaster, FALSE);
        }
        else
        {
            // Send grapple message *evades grapple*.
            sMessage = AddColorToText ("Bigby's Crushing Hand", COLOR_MAGENTA) +
                       AddColorToText (" grapples " + GetName (oTarget) + " : *grappled* : (" +
                              IntToString (iCasterAtkRoll) + " + " + IntToString (iCasterAtkMod) +
                        " = " + IntToString (iCasterAtkRoll + iCasterAtkMod) + ")", COLOR_ORANGE);
            SendMessageToPC (Spell.oCaster, sMessage);
            SendMessageToPC (oTarget, sMessage);
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eVisual, oTarget, 1.0f));
            DelayCommand (Spell.fDelay + 0.5f, ApplyEffectToObject (DURATION_TYPE_INSTANT, eBreakfree, oTarget));
            //Add one round since the CrushingHandDamage function removes 1 round each pass.
            Spell.fDuration = Spell.fDuration - 6.0f;
            CrushingHandDamage (Spell, oTarget);
            // *Target evades grapple attempt*
            //FloatingTextStrRefOnCreature(83309, Spell.oCaster, FALSE);
        }
    }
    // Setup next rounds attack!
    else
    {
       // Send attack message *miss*.
       sMessage = AddColorToText ("Bigby's Crushing Hand", COLOR_MAGENTA) +
                  AddColorToText (" attacks " + GetName (oTarget) + " : *miss* : (" +
                           IntToString (iCasterAtkRoll) + " + " + IntToString (iCasterAtkMod) +
                     " = " + IntToString (iCasterAtkRoll + iCasterAtkMod) + ")", COLOR_ORANGE);
       SendMessageToPC (Spell.oCaster, sMessage);
       SendMessageToPC (oTarget, sMessage);
       DelayCommand (6.0f, CrushingHandAttack (Spell, oTarget));
       DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eVisual, oTarget, 1.0f));
       DelayCommand (Spell.fDelay + 0.5f, ApplyEffectToObject (DURATION_TYPE_INSTANT, eBreakfree, oTarget));
       //FloatingTextStrRefOnCreature(83309, Spell.oCaster, FALSE);
    }
}

void CrushingHandDamage(struct stSpell Spell, object oTarget)
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
                DelayCommand (6.0f, CrushingHandAttack (Spell, oNewTarget));
                return;
            }
            iCounter ++;
            oNewTarget = GetNearestObject (OBJECT_TYPE_CREATURE, oTarget, iCounter);
        }
        // We didn't find a new target so lets end the spell.
        return;
    }
    // Get the result for the effect, sets Spell.iResult.
    Spell = GetModifier (Spell);
    effect eDmg = EffectDamage(Spell.iResult, Spell.iDamageType);
    eDmg = SetEffectCasterLevel(eDmg, Spell.iCasterLevel);
    effect eVisual = EffectVisualEffect (VFX_IMP_ACID_L);
    effect eVisual2 = EffectVisualEffect (VFX_IMP_BIGBYS_FORCEFUL_HAND);
    ApplyEffectToObject (DURATION_TYPE_INSTANT, eDmg, oTarget);
    ApplyEffectToObject (DURATION_TYPE_INSTANT, eVisual, oTarget);
    ApplyEffectToObject (DURATION_TYPE_INSTANT, eVisual2, oTarget);
    DelayCommand (6.0f, CrushingHandDamage (Spell, oTarget));
}
