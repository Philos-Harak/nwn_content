/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_ou_skill_b
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Event script that runs when a creature uses a skill before the skill use.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "nwnx_events"

void main()
{
    int iSkill;
    string sItem;
    object oPC, oItem;
    iSkill = StringToInt (NWNX_Events_GetEventData ("SKILL_ID"));
    oPC = OBJECT_SELF;
    if (!GetIsPC (oPC)) return;
    switch (iSkill)
    {
        case SKILL_PICK_POCKET :
            NWNX_Events_SkipEvent ();
            FloatingTextStringOnCreature ("No Pickpocket skill use allowed.", OBJECT_SELF, FALSE);
            break;
        // Requires a tool to use.
        case SKILL_DISABLE_TRAP :
        case SKILL_OPEN_LOCK :
            sItem = NWNX_Events_GetEventData ("USED_ITEM_OBJECT_ID");
            object oItem = StringToObject (sItem);
            if (!GetIsObjectValid (oItem))
            {
                FloatingTextStringOnCreature ("Must use Thieves tools to disarm traps!", oPC, FALSE);
                NWNX_Events_SkipEvent ();
            }
            break;
    }
}

