/*//////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_gui_events
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 OnPlayerGUIEvent event script
    Used to allow PEPS to gain control of specific GUI events.
/*//////////////////////////////////////////////////////////////////////////////
#include "0i_gui_events"
#include "0i_menus"
#include "0i_menus_mobile"
void main()
{
    object oPC = GetLastGuiEventPlayer();
    int nEventType = GetLastGuiEventType();
    int nEventInt = GetLastGuiEventInteger();
    //object oEventObject = GetLastGuiEventObject();
    switch(nEventType)
    {
        case GUIEVENT_EFFECTICON_CLICK:
        {
            if(ai_GetMagicMode(oPC, AI_MAGIC_EFFECT_ICON_REPORT))
            {
                ai_CreateEffectChatReport(oPC, nEventInt);
                return;
            }
            int nToken = NuiFindWindow(oPC, AI_EFFECT_ICON_NUI);
            json jData;
            if(nToken)
            {
                jData = NuiGetUserData(oPC, nToken);
                int nOldEffectIcon = JsonGetInt(JsonArrayGet(jData, 1));
                NuiDestroy(oPC, nToken);
                if(nOldEffectIcon == nEventInt) return;
            }
            ai_CreateEffectIconMenu(oPC, nEventInt);
        }
       case GUIEVENT_PARTYBAR_PORTRAIT_CLICK:
        {
            object oAssociate = GetLastGuiEventObject();
            if(GetMaster(oAssociate) == oPC)
            {
                int nPortrait = GetLocalInt(oAssociate, PORTRAIT_SETTING);
                string sAssociateType = ai_GetAssociateType(oPC, oAssociate);
                if(GetLocalInt(oAssociate, AI_LIMIT_HENCHMAN_MENUS) != TRUE)
                {
                    // If all the Command buttons are blocked then don't load the menu.
                    if(nPortrait == PORTRAIT_SETTING_COMMAND && GetLocalInt(GetModule(), sDMWidgetAccessVarname) != 7340028)
                    {
                        if(IsWindowClosed(oPC, sAssociateType + AI_COMMAND_NUI))
                        {
                            int nMobile = ai_GetWidgetButton(oPC, BTN_NUI_MOBILE, oPC, sAssociateType);
                            if(nMobile) ai_CreateAssociateCommandMobileNUI(oPC, oAssociate);
                            else ai_CreateAssociateCommandNUI(oPC, oAssociate);
                        }
                        IsWindowClosed(oPC, sAssociateType + AI_NUI);
                        IsWindowClosed(oPC, sAssociateType + AI_LOOTFILTER_NUI);
                        IsWindowClosed(oPC, sAssociateType + AI_COPY_NUI);
                        IsWindowClosed(oPC, sAssociateType + AI_QUICK_WIDGET_NUI);
                        IsWindowClosed(oPC, sAssociateType + AI_SPELL_MEMORIZE_NUI);
                        IsWindowClosed(oPC, sAssociateType + AI_SPELL_KNOWN_NUI);
                    }
                    // If all the AI buttons are blocked then don't load the menu.
                    else if(nPortrait == PORTRAIT_SETTING_AI && GetLocalInt(GetModule(), sDMAIAccessVarname) != 203423743)
                    {
                        if(IsWindowClosed(oPC, sAssociateType + AI_NUI))
                        {
                            int nMobile = ai_GetWidgetButton(oPC, BTN_NUI_MOBILE, oPC, sAssociateType);
                            if(nMobile) ai_CreateAssociateAIMobileNUI(oPC, oAssociate);
                            else ai_CreateAssociateAINUI(oPC, oAssociate);
                        }
                        IsWindowClosed(oPC, sAssociateType + AI_COMMAND_NUI);                        
                        IsWindowClosed(oPC, sAssociateType + AI_LOOTFILTER_NUI);
                        IsWindowClosed(oPC, sAssociateType + AI_COPY_NUI);
                        IsWindowClosed(oPC, sAssociateType + AI_QUICK_WIDGET_NUI);
                        IsWindowClosed(oPC, sAssociateType + AI_SPELL_MEMORIZE_NUI);
                        IsWindowClosed(oPC, sAssociateType + AI_SPELL_KNOWN_NUI);
                    }
                    else if(nPortrait == PORTRAIT_SETTING_WIDGET) 
                    {
                        int nToken = NuiFindWindow(oPC, sAssociateType + AI_COMMAND_NUI);
                        ai_ToggleAssociateWidgetOnOff(oPC, nToken, oAssociate, sAssociateType);
                    }
                    else if(nPortrait == PORTRAIT_SETTING_ACTION) ai_Action(oPC, oAssociate);
                    else if(nPortrait == PORTRAIT_SETTING_CAMERA) ai_ChangeCameraView(oPC, oAssociate);
                }
                else
                {
                    int bLocked = !ai_GetWidgetButton(oPC, BTN_WIDGET_LOCK, oAssociate, sAssociateType);
                    ai_SetWidgetButton(oPC, BTN_WIDGET_LOCK, oAssociate, sAssociateType, bLocked);
                    if(!ai_GetWidgetButton(oPC, BTN_WIDGET_OFF, oAssociate, sAssociateType) || oPC == oAssociate)
                    {
                        NuiDestroy(oPC, NuiFindWindow(oPC, sAssociateType + AI_WIDGET_NUI));
                        ai_CreateWidgetNUI(oPC, oAssociate);
                    }
                }
           }
        }
    }
}
