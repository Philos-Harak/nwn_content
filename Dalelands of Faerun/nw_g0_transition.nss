/*///////////////////////////////////////////////////////////
 Script Name: nw_g0_transition
 Programmer: Philos
////////////////////////////////////////////////////////////
 * OnClick/OnAreaTransitionClick script that is called if no OnClick script is
   specified for an Area Transition Trigger or if no OnAreaTransitionClick
   script is specified for a Door that has a LinkedTo Destination Type other than None.
 * Removed mounts code.
 * Added area xxx/yyy/zz coordinate support. New transitioning system.
   Simpler for over land travel and area building.
   Automatically transitions any player that clicks on the edge of the map.
 * Variable: 0_TransitionTag will transition to the placeable/waypoint with this tag.
 * Using overland.2da to generate areas that are not unique.
       Array used in 2da :Name:MinLevel:MaxLevel:Encounter:TileType:
       Z coordinates defines what level the area is below the overland map.
       01 - 05 is caverns.
       06 - 10 is upperdark.
       11 - 15 is middledark.
       16 - 20 is lowerdark.
 * Remarked out at the moment: Add support for monsters chasing PC's across areas.
/*/////////////////////////////////////////////////////////////
#include "0i_master"
#include "0i_area"
void main()
{
    object oTransition = OBJECT_SELF;
    int nObjectType = GetObjectType(oTransition);
    object oClicker;
    if(nObjectType == OBJECT_TYPE_DOOR) oClicker = GetClickingObject();
    else if(nObjectType == OBJECT_TYPE_TRIGGER) oClicker = GetClickingObject();
    else if(nObjectType == OBJECT_TYPE_PLACEABLE) oClicker = GetPlaceableLastClickedBy();
    //else Debug ("nw_g0_transition", "32", "Cannot get oClicker from transition object: " + GetName (OBJECT_SELF));
    // Since we have clicked on a transition lets remove edge map transition data.
    DeleteMoveVariables(oClicker);
    SetLocalObject(oClicker, "Move_Tran", oTransition);
    // Check distance as we don't want to transition until they are close to the placeable.
    float fDistance = GetDistanceBetween (oClicker, oTransition);
    //Debug("nw_g0_transition", "36", "oClicker: " + GetName (oClicker) + " oTransition: " + GetName (oTransition) +
    //      " fDistance: " + FloatToString(fDistance, 0, 2));
    if(fDistance > 3.0f && fDistance != 0.0f)
    {
        // Only move them closer on the first script run.
        ActionMoveToObject(OBJECT_SELF, TRUE, 1.0f);
        // Set Move location to where we are going so we know when we are there!
        SetLocalLocation(oClicker, "Move_Loc", GetLocation(oTransition));
        // Check to see if we are already looking to move.
        int nCount = GetLocalInt(oClicker, "Move_Count");
        // If the original count was 0 then we need to start a
        // wait for transition function for this PC.
        //Debug("nw_g0_transition", "50", "Counter: " + IntToString(nCount));
        if(nCount == 0)
        {
            //Debug("nw_g0_transition", "52", "Running WaitToTransition (oClicker)!");
            SetLocalInt(oClicker, "Move_Count", 1);
            WaitToTransition(oClicker);
        }
        // If it is counting then we need to clear the count since we have
        // clicked a new location. The old wait for transition will still run.
        else SetLocalInt(oClicker, "Move_Count", 1);
    }
    else
    {
        //Debug ("nw_g0_transition", "61", "Running Transition (oClicker)!");
        Transition(oClicker);
    }
}
    /***************** Monster chasing code ***************
    /***************** Removed for now ********************
    // Check to see if they are being chased.
    // First see if it is a civilized area, monsters will not enter them.
    if (!GetLocalInt (GetArea (oTarget), "0_No_Difficulty"))
    {
        int iEnemyCount = 1, iPCConCheck, iMonsterConCheck;
        float fSpawnDelay;
        // Have the PC make a constitution check to flee.
        // Check to see if PC has trackless step.
        // This will make it harder for monsters to follow them.
        if (GetHasFeat (FEAT_TRACKLESS_STEP, oClicker)) iBonus = 4;
        iPCConCheck = d20() + GetAbilityModifier (ABILITY_CONSTITUTION, oClicker) + iBonus;
        object oEnemy = GetNearestEnemy (oClicker, iEnemyCount);
        while (GetIsObjectValid (oEnemy))
        {
            //Debug ("nw_g0_transition", "151", "Enemy: " + GetName (oEnemy));
            // Check to see if they are targeting the transitioning character.
            if (GetLocalObject(oEnemy, HENCH_AI_SCRIPT_INTRUDER_OBJ) == oClicker)
            {
                // Make sure they are in line of sight.
                if (LineOfSightObject (oClicker, oEnemy))
                {
                    // Creature needs to make a constitution check.
                    iMonsterConCheck = d20() + GetAbilityModifier (ABILITY_CONSTITUTION, oEnemy);
                    // Check to see if the PC has out ran the Monster.
                    if (iPCConCheck < iMonsterConCheck)
                    {
                        // Creature caught the pc so jump them to the new area.
                        SendMessages (GetName (oEnemy) + " is giving chase!", COLOR_RED, oClicker, FALSE, FALSE);
                        // Get distance from each other will define spawn delay.
                        fSpawnDelay = GetDistanceBetween (oClicker, oEnemy);
                        DelayCommand (fSpawnDelay, AssignCommand(oEnemy,JumpToObject(oTarget)));
                    }
                    // PC is out of sight and creatures will not follow.
                    else SendMessages ("You have lost " + GetName (oEnemy), COLOR_GREEN, oClicker, FALSE, FALSE);
                }
                // PC out ran the creature so let them know.
                else SendMessages ("You have lost " + GetName (oEnemy), COLOR_GREEN, oClicker, FALSE, FALSE);
            }
            iEnemyCount ++;
            oEnemy = GetNearestEnemy (oClicker, iEnemyCount);
        }
    } */

