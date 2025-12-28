//::///////////////////////////////////////////////
//:: Glyph of Warding Heartbet
//:: x2_o0_glyphhb
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Default Glyph of warding damage script

    This spellscript is fired when someone triggers
    a player cast Glyph of Warding


    Check x2_o0_hhb.nss and the Glyph of Warding
    placeable object for details

*/
//:://////////////////////////////////////////////
//:: Created By: Georg Zoeller
//:: Created On: 2003-09-02
//:://////////////////////////////////////////////
#include "0i_spells"

void DoDamage(int iDamage, object oTarget, int iDamageType, effect eImpact)
{
    if(iDamage > 0)
    {
        //Apply VFX impact and damage effect
        ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, oTarget);
        effect eDmg = EffectDamage (iDamage, iDamageType);
        DelayCommand (0.01, ApplyEffectToObject (DURATION_TYPE_INSTANT, eDmg, oTarget));
    }
}

void main()
{
    // Reconstruct the spell variables.
    Spell.oTarget = GetLocalObject (OBJECT_SELF, "GLYPH_LAST_ENTER");
    Spell.lTarget = GetLocation (OBJECT_SELF);
    Spell.iAreaShape = SHAPE_SPHERE;
    Spell.fAreaSize = 15.0f;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_REFLEX;
    Spell.iSaveType = GetLocalInt (OBJECT_SELF, "PLC_GLYPH_SAVINGTHROWTYPE");
    Spell.iSaveHalf = TRUE;
    Spell.iCasterLevel = GetLocalInt (OBJECT_SELF, "PLC_GLYPH_CASTER_LEVEL");
    Spell.iMetaMagic = GetLocalInt (OBJECT_SELF, "PLC_GLYPH_CASTER_METAMAGIC");
    Spell.oCaster = GetLocalObject (OBJECT_SELF, "PLC_GLYPH_CASTER") ;
    Spell.iDamageType = GetLocalInt (OBJECT_SELF, "PLC_GLYPH_DAMAGE_TYPE");
    Spell.iModNumOfDice = GetLocalInt (OBJECT_SELF, "PLC_GLYPH_MODNUMOFDICE");
    Spell.iModifierDie = GetLocalInt (OBJECT_SELF, "PLC_GLYPH_MODIFIERDIE");
    Spell.iModDicePerLvl = GetLocalInt (OBJECT_SELF, "PLC_GLYPH_MODDICEPERLVL");
    Spell.iMaxModNumOfDice = GetLocalInt (OBJECT_SELF, "PLC_GLYPH_MAXMODNUMOFDICE");
    Spell.iModifier = GetLocalInt (OBJECT_SELF, "PLC_GLYPH_MODIFIER");
    Spell.iModPerLvl = GetLocalInt (OBJECT_SELF, "PLC_GLYPH_MODPERLVL");
    Spell.iMaxModifier = GetLocalInt (OBJECT_SELF, "PLC_GLYPH_MAXMODIFIER");
    Spell.iImpact = GetLocalInt (OBJECT_SELF, "PLC_GLYPH_IMPACT");
    // If created by a player then set the player as object_self.
    if (GetLocalInt (OBJECT_SELF, "PLC_GLYPH_PLAYERCREATED")) Spell.oCaster = OBJECT_SELF;
    // If not created by a player then destroy the object and exit.
    if (!GetIsObjectValid (Spell.oCaster))
    {
        DestroyObject (OBJECT_SELF);
        return;
    }
    // Create visual effects.
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eCenter = EffectVisualEffect (459);
    effect eDur = EffectVisualEffect (445);
    // Create center explosion.
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, GetSpellId()));
        // Get the result for the effect, sets Spell.iResult.
        Spell = GetModifier (Spell);
        // Make a resistance and save check.
        Spell = ResistAndSave (Spell);
        if (Spell.iResult > 0)
        {
            // Have the creator do the damage so he gets feedback strings
            if (Spell.oCaster != OBJECT_SELF) AssignCommand (Spell.oCaster, DoDamage (Spell.iResult, Spell.oAreaTarget, Spell.iDamageType, eImpact));
            // Otherwise just do the damage.
            else DoDamage (Spell.iResult, Spell.oAreaTarget, Spell.iDamageType, eImpact);
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
}
