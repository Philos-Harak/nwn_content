/*////////////////////////////////////////////////
 Script Name: 0s_leosshelter
 Programmer: Philos
////////////////////////////////////////////////
Conjuration (Creation)
Level:  Brd 4, Sor/Wiz 4
Components: V, S, M, F; see text
Casting Time:   10 minutes
Range:  Close (25 ft. + 5 ft./2 levels)
Effect: 20-ft.-square structure
Duration:   2 hours/level (D)
Saving Throw:   None
Spell Resistance:   No

You conjure a sturdy cottage made of material that is common in the area.
The floor is level, clean, and dry. In all respects the lodging resembles a
normal cottage, with a sturdy door, two shuttered windows, and a small fireplace.

The dwelling provide considerable security as it is as strong as a normal stone
building, regardless of its material composition and the door and shutters are
arcane locked
The secure shelter contains rude furnishings —four bunks, a trestle table, four
stools, and a writing desk.

Material Component: A square chip of stone, crushed lime, a few grains of sand,
a sprinkling of water, and several splinters of wood.
/*//////////////////////////////////////////////////////////////////////////////
#include "0i_spells"
#include "nwnx_effect"
#include "nwnx_object"

void CreateSecureShelter (struct stSpell Spell, string sName)
{
    // Create visual effects
    effect eCenter = EffectVisualEffect (VFX_FNF_NATURES_BALANCE);
    // Create the placeable cottage.
    object oCottage = CreateObject (OBJECT_TYPE_PLACEABLE, "0_cottage", Spell.lTarget, FALSE, "Place_Shelter_" + sName);
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, GetLocation (oCottage));
    // Do magical raise from the ground.
    MoveObject (oCottage, 0.0f, 0.0f, -10.5f);
    MoveObject (oCottage, 0.0f, 0.0f, -0.5f, OBJECT_VISUAL_TRANSFORM_LERP_LINEAR, 3.5f);
    // Set the cottage placeable information.
    SetLocalString (oCottage, "0_TransitionTag", "WP_LEO_" + sName);
    NWNX_Object_SetDialogResref (oCottage, "co_magic_place");
    SetEventScript (oCottage, EVENT_SCRIPT_PLACEABLE_ON_LEFT_CLICK, "0e_transition");
    // Create the cottage area and set information.
    object oArea = CreateArea ("0_leosshelter", "Area_Shelter_" + sName, GetName (Spell.oCaster) + "'s Secure Shelter");
    object oWaypoint = GetObjectInAreaByTag (oArea, "WP_LEO_", 1, OBJECT_TYPE_WAYPOINT, TRUE);
    SetTag (oWaypoint, "WP_LEO_" + sName);
    object oWaypoint2 = CreateObject (OBJECT_TYPE_WAYPOINT, "0_wp_target", GetLocation (oCottage));
    SetTag (oWaypoint2, "WP_LEO_EXIT_" + sName);
    object oDoor = GetObjectInAreaByTag (oArea, "DOOR_LEO", 1, OBJECT_TYPE_DOOR, TRUE);
    SetTransitionTarget (oDoor, oWaypoint2);
}

void main()
{
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iSubSchool = SUBSCHOOL_CREATION;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.sDivineComponent = COMPONENT_POUCH;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 5;
    //Spell.iDurPerLvl = 1;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Check to make sure we are not inside a building, automatically fails.
    if (!GetIsAreaNatural (GetArea (Spell.oCaster)))
    {
        SendMessages ("You can only cast Leomund's Secure Shelter in a natural area!", COLOR_RED, Spell.oCaster);
        return;
    }
    // Remove any other Leomund's secure shelter.
    RemoveSpellEffects (Spell.iSpellID, Spell.oCaster, Spell.oCaster);
    string sName = RemoveIllegalCharacters (StripColorCodes (GetName (Spell.oCaster)));
    // Used to anchor the spell to the creature so we can test for it.
    effect eEffect = EffectSpellImmunity (SPELL_HORSE_MOUNT);
    eEffect = RemoveEffectIcon (eEffect);
    // Set scripts for Leomund's Secure Shelter.
    // Setup an expire script passing data in a string array.
    // Pass the name of the caster to recreate the area tag and placeable tag.
    // Setup an expire script to remove spells non-effects effects.
    effect eScript = EffectRunScript ("", "0s_leosshelter_r", "", 0.0, sName);
    eEffect = EffectLinkEffects (eEffect, eScript);
    ApplyEffectToObject (Spell.iDurationType, eEffect, Spell.oCaster, Spell.fDuration);
    DelayCommand (0.5f, CreateSecureShelter (Spell, sName));
    CleanUpSpell (Spell);
}

