/*////////////////////////////////////////////////
 Script: 0s_min_creation
 Programmer: Philos
////////////////////////////////////////////////
Conjuration (Creation)
Level:  Sor/Wiz 4
Components: V, S, M
Casting Time:   1 standard action
Range:  Personal
Effect: One object.
Duration: Permanent.
Saving Throw: None
Spell Resistance: No

You create a nonmagical, nonliving, vegetable matter. The type of object created
can be selected in the players handbook under the chapter on magic.
If no object has been selected then it will make a bundle of ninty nine arrows.

Material component: A wooden plank.
/*////////////////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iSubSchool = SUBSCHOOL_CREATION;
    Spell.sArcaneComponent = "m_wood_10";
    Spell.sDivineComponent = "m_wood_10";
    Spell.iCompAmount = 1;
    Spell.iAreaShape = SHAPE_PERSONAL;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Define variables.
    int iArray, iSpellID, iStackSize = 1;
    string sCreationArray, sCreation;
    effect eVisual = EffectVisualEffect (VFX_FNF_LOS_NORMAL_10);
    // Apply the visual effect.
    DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eVisual, Spell.oCaster));
    // Create the object.
    // Get the casters summons array.
    sCreationArray = GetObjectDatabaseString (OBJECT_SELF, CHARACTER_TABLE, "summons");
    sCreation = GetStringArray (sCreationArray, 16);
    if (sCreation == "") sCreation = "arrow";
    // Check for stackable items.
    if (sCreation == "arrow" || sCreation == "bolt") iStackSize = 99;
    if (sCreation == "javelin") iStackSize == 10;
    CreateItemOnObject (sCreation, Spell.oCaster, iStackSize);
    CleanUpSpell (Spell);
}
