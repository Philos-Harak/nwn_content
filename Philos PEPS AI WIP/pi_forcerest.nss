#include "0i_menus"
// Does startup check if the game has just been loaded.
int StartingUp(object oPC);
void ai_UpdateAssociateWidget(object oMaster, object oAssociate, int nUIToken)
{
    if(nUIToken) NuiDestroy(oMaster, nUIToken);
    ai_CreateWidgetNUI(oMaster, oAssociate);
}
void main()
{
    object oPC = OBJECT_SELF;
    if(StartingUp(oPC)) return;
    ForceRest(oPC);
    int nIndex;
    int nMaxHenchman = GetMaxHenchmen();
    object oAssociate;
    for(nIndex = 1;nIndex <= nMaxHenchman; nIndex++)
    {
        oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
        ForceRest(oAssociate);
        if(ai_GetMagicMode(oAssociate, AI_MAGIC_BUFF_AFTER_REST))
        {
            DelayCommand(1.0, ai_HenchmanCastDefensiveSpells(oAssociate, oPC));
        }
        if(AI_HENCHMAN_WIDGET)
        {
            // Update widget for spell widget.
            string sAssociateType = ai_GetAssociateType(oPC, oAssociate);
            int nUIToken = NuiFindWindow(oPC, sAssociateType + AI_WIDGET_NUI);
            if(nUIToken) DelayCommand(6.0, ai_UpdateAssociateWidget(oPC, oAssociate, nUIToken));
            else
            {
                if(!ai_GetWidgetButton(oPC, BTN_WIDGET_OFF, oAssociate, sAssociateType))
                {
                    DelayCommand(6.0, ai_UpdateAssociateWidget(oPC, oAssociate, 0));
                }
            }
        }
    }
}
int StartingUp(object oPC)
{
    if(GetLocalInt(oPC, AI_ADD_PLUGIN))
    {
        json jPlugin = JsonArray();
        jPlugin = JsonArrayInsert(jPlugin, JsonString("pi_forcerest"));
        jPlugin = JsonArrayInsert(jPlugin, JsonBool(FALSE));
        jPlugin = JsonArrayInsert(jPlugin, JsonString("Force Rest"));
        jPlugin = JsonArrayInsert(jPlugin, JsonString("ir_rest"));
        json jPlugins = GetLocalJson(oPC, AI_JSON_PLUGINS);
        jPlugins = JsonArrayInsert(jPlugins, jPlugin);
        SetLocalJson(oPC, AI_JSON_PLUGINS, jPlugin);
        SetLocalInt(oPC, AI_PLUGIN_SET, TRUE);
        return TRUE;
    }
    if(!GetLocalInt(oPC, AI_STARTING_UP)) return FALSE;
    return TRUE;
}

