/*////////////////////////////////////////////////
 Script Name: 0s_heroesfeast
 Programmer: Philos
////////////////////////////////////////////////
Conjuration (Creation)
Level:  Brd 6, Cleric 6
Components: V, S, DF
Casting Time: 10 minutes
Range: Close (25 ft. + 5 ft./2 levels)
Effect: One large feast
Duration: 12 hours
Saving Throw: None
Spell Resistance: No

You bring forth a great feast, including a magnificent table, chairs, and food
and drink. Every creature partaking of the feast is cured of all diseases,
sickness and becomes immune to poison for 12 hours; and gains 1d8 temporary hit
points +1 point per two caster levels (maximum +10) after imbibing the
nectar-like beverage that is part of the feast.
The ambrosial food that is consumed grants each creature that partakes a
+1 morale bonus on attack rolls and Will saves and immunity to fear effects for
12 hours. The feast itself only lasts 10 minutes before disappearing.
/*//////////////////////////////////////////////////////////////////////////////
#include "0i_spells"
#include "nwnx_effect"
#include "0i_spawn"
void DestroyHeroesFeast (object oTable)
{
    int iCounter;
    float fDelay;
    effect eCenter = EffectVisualEffect (VFX_FNF_NATURES_BALANCE);
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, GetLocation (oTable));
    object oObject = GetObjectByTag ("Heroes_Feast", iCounter);
    while (GetIsObjectValid (oObject))
    {
        if (GetDistanceBetween (oTable, oObject) < 5.0f) DestroyObject (oObject, fDelay);
        fDelay += 0.1f;
        oObject = GetObjectByTag ("Heroes_Feast", ++iCounter);
    }
    DestroyObject (oTable, 2.5f);
}

void main()
{
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iSubSchool = SUBSCHOOL_CREATION;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iDivineFocus = TRUE;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 10;
    Spell = SetSpell (Spell);
    if (Spell.iSpellID == STOP_SPELL) return;
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    int iHPBonus = Spell.iCasterLevel;
    if (iHPBonus > 10) iHPBonus = 10;
    effect eCenter = EffectVisualEffect (VFX_FNF_NATURES_BALANCE);
    // Create the feast!
    object oMug, oArea = GetAreaFromLocation (Spell.lTarget);
    //float fFacing = GetFacingFromLocation (Spell.lTarget);
    vector vPos = GetPositionFromLocation (Spell.lTarget);
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eCenter, Spell.lTarget);
    // Table
    location lNewLocation = Location (oArea, Vector (vPos.x, vPos.y, vPos.z), 0.0f);
    object oTable = CreateObject (OBJECT_TYPE_PLACEABLE, "0_hf_table", lNewLocation);
    DelayCommand (Spell.fDuration, DestroyHeroesFeast (oTable));
    // Chair1
    lNewLocation = Location (oArea, Vector (vPos.x + 2.0f, vPos.y - 1.0f, vPos.z), 0.0f);
    CreateObject (OBJECT_TYPE_PLACEABLE, "0_stone_chair", lNewLocation, FALSE, "Heroes_Feast");
    // Chair2
    lNewLocation = Location (oArea, Vector (vPos.x+ 2.0f, vPos.y  + 1.0f, vPos.z), 0.0f);
    CreateObject (OBJECT_TYPE_PLACEABLE, "0_stone_chair", lNewLocation, FALSE, "Heroes_Feast");
    // Chair3
    lNewLocation = Location (oArea, Vector (vPos.x, vPos.y  - 3.25f, vPos.z), 270.0f);
    CreateObject (OBJECT_TYPE_PLACEABLE, "0_stone_chair", lNewLocation, FALSE, "Heroes_Feast");
    // Chair4
    lNewLocation = Location (oArea, Vector (vPos.x - 2.0f, vPos.y + 1.0f, vPos.z), 180.0f);
    CreateObject (OBJECT_TYPE_PLACEABLE, "0_stone_chair", lNewLocation, FALSE, "Heroes_Feast");
    // Chair5
    lNewLocation = Location (oArea, Vector (vPos.x - 2.0f, vPos.y - 1.0f, vPos.z), 180.0f);
    CreateObject (OBJECT_TYPE_PLACEABLE, "0_stone_chair", lNewLocation, FALSE, "Heroes_Feast");
    // Chair6
    lNewLocation = Location (oArea, Vector (vPos.x, vPos.y + 3.25f, vPos.z), 90.0f);
    CreateObject (OBJECT_TYPE_PLACEABLE, "0_stone_chair", lNewLocation, FALSE, "Heroes_Feast");
    // Platter
    lNewLocation = Location (oArea, Vector (vPos.x, vPos.y, vPos.z + 0.8f), 90.0f);
    CreateObject (OBJECT_TYPE_PLACEABLE, "0_platter", lNewLocation, FALSE, "Heroes_Feast");
    // Turkey
    lNewLocation = Location (oArea, Vector (vPos.x, vPos.y, vPos.z + 0.8f), 90.0f);
    CreateObject (OBJECT_TYPE_PLACEABLE, "0_f_turkey", lNewLocation, FALSE, "Heroes_Feast");
    // Mug1
    lNewLocation = Location (oArea, Vector (vPos.x - 1.0f, vPos.y + 1.5f, vPos.z + 0.8f), 0.0f);
    oMug = CreateObject (OBJECT_TYPE_PLACEABLE, "0_hf_drink", lNewLocation, FALSE, "Heroes_Feast");
    SetLocalInt (oMug, "0_Heroes_Feast_HP", iHPBonus);
    // Mug2
    lNewLocation = Location (oArea, Vector (vPos.x - 1.0f, vPos.y - 0.5f, vPos.z + 0.8f), 0.0f);
    oMug = CreateObject (OBJECT_TYPE_PLACEABLE, "0_hf_drink", lNewLocation, FALSE, "Heroes_Feast");
    SetLocalInt (oMug, "0_Heroes_Feast_HP", iHPBonus);
    // Mug3
    lNewLocation = Location (oArea, Vector (vPos.x - 0.25f, vPos.y - 2.25f, vPos.z + 0.86f), 0.0f);
    oMug = CreateObject (OBJECT_TYPE_PLACEABLE, "0_hf_drink", lNewLocation, FALSE, "Heroes_Feast");
    SetLocalInt (oMug, "0_Heroes_Feast_HP", iHPBonus);
    // Mug4
    lNewLocation = Location (oArea, Vector (vPos.x + 1.0f, vPos.y - 1.25f, vPos.z + 0.8f), 0.0f);
    oMug = CreateObject (OBJECT_TYPE_PLACEABLE, "0_hf_drink", lNewLocation, FALSE, "Heroes_Feast");
    SetLocalInt (oMug, "0_Heroes_Feast_HP", iHPBonus);
    // Mug5
    lNewLocation = Location (oArea, Vector (vPos.x + 1.0f, vPos.y + 0.5f, vPos.z + 0.8f), 0.0f);
    oMug = CreateObject (OBJECT_TYPE_PLACEABLE, "0_hf_drink", lNewLocation, FALSE, "Heroes_Feast");
    SetLocalInt (oMug, "0_Heroes_Feast_HP", iHPBonus);
    // Mug6
    lNewLocation = Location (oArea, Vector (vPos.x + 0.25f, vPos.y + 2.0f, vPos.z + 0.86f), 0.0f);
    oMug = CreateObject (OBJECT_TYPE_PLACEABLE, "0_hf_drink", lNewLocation, FALSE, "Heroes_Feast");
    SetLocalInt (oMug, "0_Heroes_Feast_HP", iHPBonus);
    // Food1
    lNewLocation = Location (oArea, Vector (vPos.x - 1.0f, vPos.y + 1.0f, vPos.z + 0.8f), 0.0f);
    CreateObject (OBJECT_TYPE_PLACEABLE, "0_hf_food", lNewLocation, FALSE, "Heroes_Feast");
    // Food2
    lNewLocation = Location (oArea, Vector (vPos.x - 1.0f, vPos.y - 1.0f, vPos.z + 0.8f), 0.0f);
    CreateObject (OBJECT_TYPE_PLACEABLE, "0_hf_food", lNewLocation, FALSE, "Heroes_Feast");
    // Food3
    lNewLocation = Location (oArea, Vector (vPos.x, vPos.y - 2.0f, vPos.z + 0.86f), 0.0f);
    CreateObject (OBJECT_TYPE_PLACEABLE, "0_hf_food", lNewLocation, FALSE, "Heroes_Feast");
    // Food4
    lNewLocation = Location (oArea, Vector (vPos.x + 1.0f, vPos.y - 1.0f, vPos.z + 0.8f), 0.0f);
    CreateObject (OBJECT_TYPE_PLACEABLE, "0_hf_food", lNewLocation, FALSE, "Heroes_Feast");
    // Food5
    lNewLocation = Location (oArea, Vector (vPos.x + 1.0f, vPos.y + 1.0f, vPos.z + 0.8f), 0.0f);
    CreateObject (OBJECT_TYPE_PLACEABLE, "0_hf_food", lNewLocation, FALSE, "Heroes_Feast");
    // Food6
    lNewLocation = Location (oArea, Vector (vPos.x, vPos.y + 2.0f, vPos.z + 0.86f), 0.0f);
    CreateObject (OBJECT_TYPE_PLACEABLE, "0_hf_food", lNewLocation, FALSE, "Heroes_Feast");
    CleanUpSpell (Spell);
}

