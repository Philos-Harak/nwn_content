/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_if_target_is
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Text appears script that checks to see if they are a specific target.
 Param:
 sTarget - type of target we are looking for.
    "PC" - player character.
    "Creature" - any creature (NPC, PC).
    "Location" - if no creature is selected then it must be the ground.
    "Placeable" - a placeable object.
    "Container" - is the object a container or door.
    "Inventory" - any object that can have inventory.
    "Item" - an Item object.
    "Potion/Wand" - Potions and wands only.
    "Quest" - Quest papers
    "Object - any object.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_character"
int StartingConditional()
{
    object oPC = GetPCSpeaker ();
    object oTarget = GetLocalObject (oPC, "0_Creature_Target");
    string sTargetType = GetScriptParam ("sTarget");
    if (sTargetType == "PC")
    {
        if (GetIsPC(oTarget)) return TRUE;
    }
    else if (sTargetType == "Creature")
    {
        if (GetObjectType (oTarget) == OBJECT_TYPE_CREATURE) return TRUE;
    }
    else if (sTargetType == "Location")
    {
        if (!GetIsObjectValid (oTarget)) return TRUE;
    }
    else if (sTargetType == "Placeable")
    {
        if (GetObjectType (oTarget) == OBJECT_TYPE_PLACEABLE || !GetIsObjectValid (oTarget)) return TRUE;
    }
    else if (sTargetType == "Container")
    {
        int nType = GetObjectType (oTarget);
        if (nType == OBJECT_TYPE_DOOR) return TRUE;
        else if (nType == OBJECT_TYPE_PLACEABLE && GetHasInventory (oTarget)) return TRUE;
    }
    else if (sTargetType == "Inventory")
    {
        if (GetHasInventory (oTarget)) return TRUE;
    }
    else if (sTargetType == "Item")
    {
        if (GetObjectType (oTarget) == OBJECT_TYPE_ITEM) return TRUE;
    }
    else if (sTargetType == "Potion/Wand")
    {
        int nItemType = GetBaseItemType (oTarget);
        if (nItemType == BASE_ITEM_POTIONS
         || nItemType == BASE_ITEM_ENCHANTED_POTION
         || nItemType == BASE_ITEM_BLANK_POTION
         || nItemType == BASE_ITEM_BLANK_WAND
         || nItemType == BASE_ITEM_ENCHANTED_WAND
         || nItemType == BASE_ITEM_MAGICWAND) return TRUE;
    }
    else if (sTargetType == "Quest")
    {
        if (GetResRef (oTarget) == "0_quest_paper") return TRUE;
    }
    else if (sTargetType == "Object")
    {
        if (GetIsObjectValid (oTarget)) return TRUE;
    }
    return FALSE;
}
