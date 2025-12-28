/*////////////////////////////////////////////////
 Script: 0s_imspability
 Programmer: Preston Watamaniuk
//////////////////////////////////////////////////
Evocation
Level:  Clr 4
Components: V, S, DF
Casting Time: 1 standard action
Range: Touch
Target: Creature touched
Duration: Until Used
Saving Throw: Will negates (harmless)
Spell Resistance: No

You transfer some of your magical power to another creature. Only a creature
with an Intelligence score of at least 5 and a Wisdom score of at least 9 can
receive this power. The creature can now cast Bless, Cure Light wounds, and
Cure moderate wounds once. After casting each spell then it is gone.
/*////////////////////////////////////////////////
#include "0i_spells"
#include "nwnx_creature"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDivineFocus = TRUE;
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iImpact = VFX_IMP_MAGICAL_VISION;
    Spell = SetSpell (Spell);
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while (GetIsObjectValid (Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        if (GetAbilityScore (Spell.oAreaTarget, ABILITY_INTELLIGENCE) > 4 &&
            GetAbilityScore (Spell.oAreaTarget, ABILITY_WISDOM) > 8)
        {
            if (!GetHasFeat (1546/*CAST_BLESS*/, Spell.oAreaTarget) &&
                !GetHasFeat (1547/*CAST_CLW*/, Spell.oAreaTarget) && !GetHasFeat (1548/*CAST_CMW*/, Spell.oAreaTarget))
            {
                // Apply effects
                DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
                NWNX_Creature_AddFeatByLevel (Spell.oAreaTarget, 1546/*CAST_BLESS*/, GetCharacterLevels (Spell.oAreaTarget, FALSE));
                NWNX_Creature_AddFeatByLevel (Spell.oAreaTarget, 1547/*CAST_CLW*/, GetCharacterLevels (Spell.oAreaTarget, FALSE));
                NWNX_Creature_AddFeatByLevel (Spell.oAreaTarget, 1548/*CAST_CMW*/, GetCharacterLevels (Spell.oAreaTarget, FALSE));
            }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
