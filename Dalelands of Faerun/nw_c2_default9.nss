/*//////////////////////////////////////////////////////////////////////////////
 Script: NW_C2_DEFAULT9
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Creature OnSpawn script.
 Variables.
    0_Multiplier       - Will multiply the rolled treasure by this vaiables amount.
                         -1 will make sure the creature has no treasure.
    0_BonusGold        - Gives a bonus amount of gold equal to 0_BonusGold.
    0_BonusMagicItems  - Gives a bonus number of magic items equal to 0_BonusMagicItems.
    0_BaseItemType     - Will drop a specific base item type.
    0_Civilized        - Will act civilized with ambient animations.
    0_Size (float)     - Determines the size of the creature.
                       - 0.25f = 25%, 0.5f = 50%, 0.0f = 100%, 25.0f = 125%, 50.0f etc.
    0_No_Familiar      - A creature with a familiar will never summon their familiar.
    0_No_Companion     - A craature with a companion will never summon their companion.
    0_No_Ranged        - Will not used ranged weapons.

 Set these to 1 to allow the following behavior on the creature.
    NW_FLAG_AMBIENT_ANIMATIONS          - Does mobile ambient animations.
    NW_ANIM_FLAG_IS_MOBILE_CLOSE_RANGE  - Does mobile ambient animations in a close range.
    NW_FLAG_IMMOBILE_AMBIENT_ANIMATIONS - Does immobile ambient animations.
    X2_L_IS_INCORPOREAL                 - Makes the creature incorporeal.
*///////////////////////////////////////////////////////////////////////////////

const int NW_FLAG_DAMAGED_EVENT               = 0x00000800;
//const int NW_FLAG_SPELL_CAST_AT_EVENT         = 0x00001000;
//const int NW_FLAG_DISTURBED_EVENT             = 0x00002000;
//const int NW_FLAG_END_COMBAT_ROUND_EVENT      = 0x00004000;
//const int NW_FLAG_ON_DIALOGUE_EVENT           = 0x00008000;
//const int NW_FLAG_RESTED_EVENT                = 0x00010000;
const int NW_FLAG_HEARTBEAT_EVENT             = 0x00100000;

#include "0i_creature"
void main()
{
    object oCreature = OBJECT_SELF;
    // Adjust the size of the creature if needed.
    float fSize = GetLocalFloat(oCreature, "0_Size");
    if(fSize != 0.0f) SetObjectVisualTransform(oCreature, OBJECT_VISUAL_TRANSFORM_SCALE, fSize);
    // Set any permanent effects.
    int nEffect = GetLocalInt(oCreature, "0_Effect");
    if (nEffect > 0)
    {
        effect eVisual = EffectVisualEffect(nEffect);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eVisual, oCreature);
    }
    // Set the creatures current faction variable - used in DM menus.
    int nFaction = NWNX_Creature_GetFaction(oCreature) - 1;
    SetLocalInt(oCreature, "0_CurrentFaction", nFaction);
    // Do not set the PermanentFaction incase we copy them as a DM.
    // We want the PermanentFaction to persist.
    // If Incorporeal, apply changes.
    if(GetCreatureFlag(oCreature, CREATURE_VAR_IS_INCORPOREAL))
    {
        Debug("nw_c2_default9", "56", GetName(oCreature) + " is applying incorporeal effects!");
        effect eConceal = EffectConcealment (50, MISS_CHANCE_TYPE_NORMAL);
        eConceal = ExtraordinaryEffect(eConceal);
        effect eGhost = EffectCutsceneGhost();
        eGhost = ExtraordinaryEffect(eGhost);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eConceal, oCreature);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eGhost, oCreature);
    }
    // Make sure all creatures perception is at long.
    NWNX_Creature_SetCheckDistance(oCreature, 35.0, 20.0);
    // Summon's an NPC's Familiar.
    int nRoll, nAssociateType;
    string sAssociateType = GetLocalString(oCreature, "0_FAMILIAR");
    if (GetHasFeat(FEAT_SUMMON_FAMILIAR) && !GetLocalInt(oCreature, "0_No_Familiar"))
    {
        // If they don't have a familiar set then lets randomize one.
        if(sAssociateType == "")
        {
            if(GetHasFeat(1260/*Improved Familiar*/, oCreature)) nAssociateType = Random (10) + 10;
            else nAssociateType = Random(9);
            nRoll = d100();
        }
        else
        {
            nAssociateType = StringToInt(sAssociateType);
            if(GetHasFeat(1260/*Improved Familiar*/, oCreature)) nAssociateType += 10;
            nRoll = 100;
        }
        if (nRoll > 50)
        {
            NWNX_Creature_SetFamiliarCreatureType(oCreature, nAssociateType);
            SummonFamiliar(oCreature);
            object oFamiliar = GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oCreature);
            SetName(oFamiliar, "Summoned Familiar");
        }
    }
    // Summon's an NPC's Companions.
    if(GetHasFeat(FEAT_ANIMAL_COMPANION) && !GetLocalInt(oCreature, "0_No_Companion"))
    {
        // Check to see if they have a Companion set.
        sAssociateType = GetLocalString(oCreature, "0_COMPANION");
        if(sAssociateType == "")
        {
            if(GetHasFeat(1261/*Improved Animal Companion*/, oCreature)) nAssociateType = Random (9)+ 9;
            else nAssociateType = Random(9);
            nRoll = d100();
        }
        else
        {
            nAssociateType = StringToInt (sAssociateType);
            if(GetHasFeat(1261/*Improved Animal Companion*/, oCreature)) nAssociateType += 9;
            nRoll = 100;
        }
        if (nRoll > 75)
        {
            NWNX_Creature_SetAnimalCompanionCreatureType(oCreature, nAssociateType);
            SummonAnimalCompanion(oCreature);
            object oCompanion = GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oCreature);
            SetName(oCompanion, "Animal Companion");
        }
    }
    CheckForClaws(oCreature, GetHitDice(oCreature));
    CheckForWings(oCreature);
    SetCharacterEffectsToSkin(oCreature, TRUE);
    SetCharacterEffects(oCreature);
    CheckForFeatsToAdd(oCreature);
    SetCreatureAuras(oCreature);
    DelayCommand(1.0f, SetLootable(oCreature, TRUE));
    // We use this here to setup special scripts for our creatures.
    // These are passed through PEPS AI.
    SignalEvent(oCreature, EventUserDefined(1000));
}

