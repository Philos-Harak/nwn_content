/*//////////////////////////////////////////////////////////////////////////////
 Script: nw_ch_ac9
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Henchman/NPC/Associate OnSpawn script.
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
    // Let's make sure we are firing our OnDeath script after the AI.
    SetLocalString(oCreature, "AI_ON_DEATH", "nw_ch_ac7");
    // If Incorporeal, apply changes.
    if(GetCreatureFlag(oCreature, CREATURE_VAR_IS_INCORPOREAL))
    {
        effect eConceal = EffectConcealment (50, MISS_CHANCE_TYPE_NORMAL);
        eConceal = ExtraordinaryEffect(eConceal);
        effect eGhost = EffectCutsceneGhost();
        eGhost = ExtraordinaryEffect(eGhost);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eConceal, oCreature);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eGhost, oCreature);
    }
    CheckForClaws(oCreature, GetHitDice(oCreature));
    CheckForWings(oCreature);
    Debug("nw_ch_ac9", "56", "SetCharacterEffectsToSkin: " + GetName(oCreature));
    SetCharacterEffectsToSkin(oCreature);
    SetCharacterEffects(oCreature);
    CheckForFeatsToAdd(oCreature);
    SetCreatureAuras(oCreature);
    // Set to not disappear when dead, resurrectable, and selectable.
    int nAssociateType = GetAssociateType(oCreature);
    if(nAssociateType == ASSOCIATE_TYPE_HENCHMAN ||
       nAssociateType == ASSOCIATE_TYPE_NPC) SetIsDestroyable(FALSE, TRUE, TRUE);
    // Make sure all creatures perception is at long.
    NWNX_Creature_SetCheckDistance(oCreature, 35.0, 20.0);
    DelayCommand(1.0f, SetLootable (oCreature, TRUE));
}

