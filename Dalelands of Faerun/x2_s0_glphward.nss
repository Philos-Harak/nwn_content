/*////////////////////////////////////////////////
 Script Name:X2_S0_GlphWard
 Programmer: Andrew Nobbs
//////////////////////////////////////////////////
Caster Level(s): Cleric 3
Innate Level: 3
School: Abjuration
Descriptor(s): Sonic
Component(s): Verbal, Somatic, Material
Range: Short
Area of Effect / Target: Large
Duration: 1 Hour / Level
Save: Reflex 1/2
Spell Resistance: Yes

The caster creates a small, magical zone that can detect the passage of enemy
creatures. When the field is activated, it explodes, doing 1d8 points of sonic
damage per two caster levels to all creatures within the area of effect (to a
maximum of 5d8).
After being triggered, the glyph dissipates. No two glyphs can be within 15 feet
of each other.
Enhanced: When exploding it will do 1d8 points of sonic damage per caster level
to all creatures within the area of effect (to a maximum of 10d8).

Material Component: You trace the glyph with incense.
Enhancing Component: Add 200gp worth of diamond dust to the incense.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_SONIC;
    Spell.sDivineComponent = COMPONENT_POUCH;
    Spell.sEnhancingComp = "diamond_dust";
    Spell.iCompAmount = 8; // 200gp worth of diamond dust.
    Spell.iDurationType = DURATION_TYPE_HOURS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iSaveType = SAVING_THROW_TYPE_SONIC;
    Spell.iDamageType = DAMAGE_TYPE_SONIC;
    Spell.iModNumOfDice = 1;
    Spell.iModifierDie = 8;
    Spell.iModDicePerLvl = 2;
    Spell.iMaxModNumOfDice = 5;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Do they have the Enhancing component?
    if (Spell.sEnhancingComp == "TRUE")
    {
        Spell.iModDicePerLvl = 1;
        Spell.iMaxModNumOfDice = 10;
    }
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Create an object in target location.
    object oGlyph = CreateObject (OBJECT_TYPE_PLACEABLE, "x2_plc_glyph", Spell.lTarget);
    // Check for other glyphs in the area if so then destroy the cast glyph.
    // This is a protection from multiple glyphs in one area.
    object oTest = GetNearestObjectByTag ("X2_PLC_GLYPH",oGlyph);
    if (GetIsObjectValid(oTest) && GetDistanceBetween(oGlyph, oTest) < 5.0f)
    {
        FloatingTextStrRefOnCreature(84612,OBJECT_SELF);
        DestroyObject(oGlyph);
        return;
    }
   // Store the caster
   SetLocalObject (oGlyph, "PLC_GLYPH_CASTER", Spell.oCaster);
   // Store the caster level
   SetLocalInt (oGlyph, "PLC_GLYPH_CASTER_LEVEL", Spell.iCasterLevel);
   // Store Meta Magic
   SetLocalInt (oGlyph, "PLC_GLYPH_CASTER_METAMAGIC", Spell.iMetaMagic);
   // Store Duration.
   SetLocalFloat (oGlyph, "PLC_GLYPH_DURATION", Spell.fDuration);
   // Store saving throw type.
   SetLocalInt (oGlyph, "PLC_GLYPH_SAVINGTHROWTYPE", Spell.iSaveType);
   // Store Damage variables.
   SetLocalInt (oGlyph, "PLC_GLYPH_DAMAGE_TYPE", Spell.iDamageType);
   // Store Damage variables.
   SetLocalInt (oGlyph, "PLC_GLYPH_MODNUMOFDICE", Spell.iModNumOfDice);
   // Store Damage variables.
   SetLocalInt (oGlyph, "PLC_GLYPH_MODIFIERDIE", Spell.iModifierDie);
   // Store Damage variables.
   SetLocalInt (oGlyph, "PLC_GLYPH_MODDICEPERLVL", Spell.iModDicePerLvl);
   // Store Damage variables.
   SetLocalInt (oGlyph, "PLC_GLYPH_MAXMODNUMOFDICE", Spell.iMaxModNumOfDice);
   // Store Damage variables.
   SetLocalInt (oGlyph, "PLC_GLYPH_MODIFIER", Spell.iModifier);
   // Store Damage variables.
   SetLocalInt (oGlyph, "PLC_GLYPH_MODPERLVL", Spell.iModPerLvl);
   // Store Damage variables.
   SetLocalInt (oGlyph, "PLC_GLYPH_MAXMODIFIER", Spell.iMaxModifier);
   // Store Damage variables.
   SetLocalInt (oGlyph, "PLC_GLYPH_IMPACT", Spell.iImpact);
   // This spell (default = line 764 in spells.2da) will run when someone enters the glyph
   SetLocalInt (oGlyph, "PLC_GLYPH_SPELL", 764);
   // Tell the system that this glyph was player and not toolset created
   SetLocalInt (oGlyph, "PLC_GLYPH_PLAYERCREATED", TRUE);
   // Tell the game the glyph is not a permanent one
   DeleteLocalInt(oGlyph, "PLC_GLYPH_PERMANENT");
   // Force first hb
   ExecuteScript ("x2_o0_glyphhb", oGlyph);
    CleanUpSpell (Spell);
}


