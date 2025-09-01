/*//////////////////////////////////////////////////////////////////////////////
 Script: nw_ch_aca
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Associate OnRested event script;
  Fires when the creature attempts to rest via ActionRest or a PC rests.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_menus"
void ai_UpdateAssociateWidget(object oMaster, object oAssociate, int nUIToken)
{
    if(nUIToken) NuiDestroy(oMaster, nUIToken);
    ai_CreateWidgetNUI(oMaster, oAssociate);
    if(oMaster != oAssociate)
    {
        nUIToken = NuiFindWindow(oMaster, "pc" + AI_WIDGET_NUI);
        if(nUIToken)
        {
            NuiDestroy(oMaster, nUIToken);
            ai_CreateWidgetNUI(oMaster, oMaster);
        }
    }
}
void main()
{
    object oAssociate = OBJECT_SELF;
    ai_ClearCreatureActions();
    ai_OnRested(oAssociate);
    object oMaster = GetMaster(oAssociate);
    if(ai_GetIsCharacter(oMaster) && AI_HENCHMAN_WIDGET)
    {
        int nLevel = ai_GetCharacterLevels(oAssociate);
        float fDelay = StringToFloat(Get2DAString("restduration", "DURATION", nLevel));
        fDelay = (fDelay / 1000.0f) + 6.0f;
        // Update widget for spell widget.
        string sAssociateType = ai_GetAssociateType(oMaster, oAssociate);
        int nUIToken = NuiFindWindow(oMaster, sAssociateType + AI_WIDGET_NUI);
        if(nUIToken) DelayCommand(fDelay, ai_UpdateAssociateWidget(oMaster, oAssociate, nUIToken));
        else
        {
            if(!ai_GetWidgetButton(oMaster, BTN_WIDGET_OFF, oAssociate, sAssociateType))
            {
                DelayCommand(fDelay, ai_UpdateAssociateWidget(oMaster, oAssociate, 0));
            }
        }
    }
}
