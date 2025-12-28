/*////////////////////////////////////////////////
 Script Name:NW_S2_LayOnHand.nss
 Programmers: Preston Watamaniuk
////////////////////////////////////////////////
 A character is able to heal 1 hp per level times
 thier Charisma Bonus.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iSubSchool = SUBSCHOOL_HEALING;
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSpellResistance = TRUE;
    Spell.iImpact = VFX_IMP_HEALING_M;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Get the amount of healing.
    int iChr = GetAbilityModifier (ABILITY_CHARISMA, Spell.oCaster);
    if (iChr < 0) iChr = 0;
    int iLevel = GetLevelByClass (45 /* CLASS_TYPE_PALADIN_NEW */, Spell.oCaster);
    iLevel = iLevel + GetLevelByClass (CLASS_TYPE_DIVINECHAMPION, Spell.oCaster);
    int iHeal = iLevel * iChr;
    if(iHeal <= 0) iHeal = 1;
    // Create visual effects.
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eVisual = EffectVisualEffect (VFX_IMP_SUNSTRIKE);
    // Create effects.
    effect eDmg;
    effect eHeal = EffectHeal (iHeal);
    int iHit, iDmg;
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        // If the target is undead then do damage instead!
        if (GetRacialType (Spell.oAreaTarget) == RACIAL_TYPE_UNDEAD || GetLevelByClass (CLASS_TYPE_UNDEAD, Spell.oAreaTarget) > 0)
        {
            // Make a touch attack to hit.
            iHit = TouchAttackRanged (Spell.oAreaTarget);
            if (iHit)
            {
                // Make resistance and save check.
                Spell = ResistAndSave (Spell);
                if (!Spell.iSaveResult)
                {
                    // Check for a critical hit.
                    if (iHit == 2) iDmg = iHeal * 2;
                    else iDmg = iHeal;
                    eDmg = EffectDamage (iDmg, DAMAGE_TYPE_DIVINE);
                    //Fire cast spell at event for the specified target
                    SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
                    DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eDmg, Spell.oAreaTarget));
                    DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eVisual, Spell.oAreaTarget));
                }
            }
        }
        // Heal the target.
        else
        {

            SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eHeal, Spell.oAreaTarget));
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

