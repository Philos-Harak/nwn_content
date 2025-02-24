/*//////////////////////////////////////////////////////////////////////////////
 Script: nw_ch_ac1
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Associate(Summons, Familiar, Companion) OnHeart beat script when out of combat;
  This will usually fire every 6 seconds (1 game round).

  I am reverting the AI script back to the games default scripts for efficiency.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_module"
#include "0i_menus"
void ai_ActionFollow(object oCreature, object oTarget)
{
    if(GetLocalInt(OBJECT_SELF, AI_CURRENT_ACTION_MODE) == AI_LAST_ACTION_MOVE)
    {
        float fDistance = GetDistanceBetween(oCreature, oTarget);
        float fFollowDistance = ai_GetFollowDistance(oCreature);
        if(fDistance > fFollowDistance)
        {
            if(fDistance > fFollowDistance * 5.0) AssignCommand(oCreature, JumpToObject(oTarget));
            else
            {
                ClearAllActions();
                ActionMoveToObject(oTarget, TRUE, fFollowDistance);
            }
        }
        DelayCommand(1.0, ai_ActionFollow(oCreature, oTarget));
    }
}
void main()
{
    if (GetAILevel(OBJECT_SELF) == AI_LEVEL_VERY_LOW) return;
    object oCreature = OBJECT_SELF;
    // We run our OnSpawn in the heartbeat so the creator can use the original
    // OnSpawn for their game.
    if(!GetLocalInt(oCreature, AI_ONSPAWN_EVENT))
    {
        ai_OnAssociateSpawn(oCreature);
    }
    if(AI_DEBUG) ai_Debug("nw_ch_ac1", "12", GetName(oCreature) + " Heartbeat." +
                 " MODE_FOLLOW: " + IntToString(ai_GetAIMode(oCreature, AI_MODE_FOLLOW)) +
                 " Action: " + IntToString(GetCurrentAction(oCreature)));
    if(ai_GetIsBusy(oCreature) || ai_Disabled(oCreature)) return;
    // If we are an associate and don't have a master then exit.
    object oMaster = GetMaster(oCreature);
    if(oMaster == OBJECT_INVALID)
    {
        if(ai_GetIsInCombat(oCreature))
        {
            ai_DoAssociateCombatRound(oCreature);
            return;
        }
        ai_CheckForCombat(oCreature, FALSE);
        return;
    }
    // ***** Code for Henchman data and menus *****
    if(ai_GetIsCharacter(oMaster))
    {
        string sAssociateType = ai_GetAssociateType(oMaster, oCreature);
        ai_CheckAssociateData(oMaster, oCreature, sAssociateType);
        if(AI_HENCHMAN_WIDGET)
        {
            // This keeps widgets from disappearing and reappearing.
            int nUiToken = NuiFindWindow(oMaster, sAssociateType + AI_WIDGET_NUI);
            if(nUiToken)
            {
                json jData = NuiGetUserData(oMaster, nUiToken);
                object oAssociate = StringToObject(JsonGetString(JsonArrayGet(jData, 0)));
                if(oAssociate != oCreature) NuiDestroy(oMaster, nUiToken);
            }
            else
            {
                if(!ai_GetWidgetButton(oMaster, BTN_WIDGET_OFF, oCreature, sAssociateType))
                {
                    ai_CreateWidgetNUI(oMaster, oCreature);
                }
            }
        }
    }
    // If follow mode we do not want the NPC doing anything but follow.
    if(!ai_GetAIMode(oCreature, AI_MODE_FOLLOW))
    {
        if(ai_GetAIMode(oCreature, AI_MODE_STAND_GROUND))
        {
            if(ai_TryHealing(oCreature, oCreature)) return;
            return;
        }
        if(ai_GetIsInCombat(oCreature))
        {
            ai_DoAssociateCombatRound(oCreature);
            return;
        }
        if(ai_CheckForCombat(oCreature, FALSE)) return;
        if(IsInConversation(oCreature)) return;
        // In command mode we let the player tell us what to do.
        if(!ai_GetAIMode(oCreature, AI_MODE_COMMANDED))
        {
            if(ai_TryHealing(oCreature, oCreature)) return;
            if(ai_CheckNearbyObjects(oCreature)) return;
            if(ai_GetAIMode(oCreature, AI_MODE_SCOUT_AHEAD))
            {
                ai_ScoutAhead(oCreature);
                return;
            }
        }
    }
    // Finally we check to make sure we are following our master.
    if(GetCurrentAction(oCreature) != ACTION_FOLLOW)
    {
        //ai_Debug("0e_ch_1_hb", "66", "Follow master: " +
        //         " Stealth: " + IntToString(ai_GetAIMode(oCreature, AI_MODE_AGGRESSIVE_STEALTH)) +
        //         " Search: " + IntToString(ai_GetAIMode(oCreature, AI_MODE_AGGRESSIVE_SEARCH)));
        if(ai_GetAIMode(oCreature, AI_MODE_AGGRESSIVE_STEALTH))
        {
            if(AI_DEBUG) ai_Debug("nw_ch_ac1", "94", "Going into stealth mode!");
            int nStealth = GetSkillRank(SKILL_HIDE, oCreature);
            nStealth += GetSkillRank(SKILL_MOVE_SILENTLY, oCreature);
            if(nStealth / 2 >= ai_GetCharacterLevels(oCreature))
            {
                SetActionMode(oCreature, ACTION_MODE_STEALTH, TRUE);
                SetActionMode(oCreature, ACTION_MODE_DETECT, FALSE);
            }
        }
        else
        {
            SetActionMode(oCreature, ACTION_MODE_STEALTH, FALSE);
            if(ai_GetAIMode(oCreature, AI_MODE_AGGRESSIVE_SEARCH))
            {
                if(AI_DEBUG) ai_Debug("nw_ch_ac1", "108", "Going into search mode!");
                SetActionMode(oCreature, ACTION_MODE_DETECT, TRUE);
            }
            else SetActionMode(oCreature, ACTION_MODE_DETECT, FALSE);
        }
        // Follow master.
        if(GetDistanceBetween(oCreature, oMaster) > ai_GetFollowDistance(oCreature))
        {
            if(!ai_GetAIMode(oCreature, AI_MODE_COMMANDED))
            {
                object oTarget = GetLocalObject(oCreature, AI_FOLLOW_TARGET);
                if(oTarget == OBJECT_INVALID) oTarget = oMaster;
                //ActionForceFollowObject(oTarget, ai_GetFollowDistance(oCreature));
                //ActionMoveToObject(oTarget, TRUE, ai_GetFollowDistance(oCreature));
                SetLocalInt(oCreature, AI_CURRENT_ACTION_MODE, AI_LAST_ACTION_MOVE);
                ai_ActionFollow(oCreature, oTarget);
            }
        }
    }
}

