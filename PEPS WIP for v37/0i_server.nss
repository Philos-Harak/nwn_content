/*//////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_server
////////////////////////////////////////////////////////////////////////////////
 Include script for handling event scripts for online servers.
*///////////////////////////////////////////////////////////////////////////////
void ai_SetModuleValues()
{
    object oModule = GetModule();
    if(GetLocalInt(oModule, "AI_RULES_SET")) return;
    SetLocalInt(oModule, "AI_RULES_SET", TRUE);
    // Allow the AI move during combat base on the situation and action taking.
    SetLocalInt(oModule, AI_RULE_ADVANCED_MOVEMENT, TRUE);
    // Monster AI's chance to attack the weakest target instead of the nearest.
    SetLocalInt(oModule, AI_RULE_AI_DIFFICULTY, 0);
    // Allow the AI to use Use Magic Device.
    SetLocalInt(oModule, AI_RULE_ALLOW_UMD, TRUE);
    // Allows monsters to use the ambush AI scripts.
    SetLocalInt(oModule, AI_RULE_AMBUSH, TRUE);
    // Allows monsters to prebuff before combat starts.
    SetLocalInt(oModule, AI_RULE_BUFF_MONSTERS, FALSE);
    // Allow the AI to use healing kits.
    SetLocalInt(oModule, AI_RULE_HEALERSKITS, TRUE);
    // Follow Item Level Restrictions for monsters/associates.
    // Usually off in Single player and on in Multi player.
    SetLocalInt(oModule, AI_RULE_ILR, FALSE);
    // Moral checks on or off.
    SetLocalInt(oModule, AI_RULE_MORAL_CHECKS, FALSE);
    // Variable that can change the distance creatures will come and attack after
    // hearing a shout from an ally that sees or hears an enemy.
    // Or when searching for an invisible, heard enemy.
    // 10.0 short, 20.0 Medium, 35.0 long, 35.0 player.
    SetLocalFloat(oModule, AI_RULE_PERCEPTION_DISTANCE, 30.0);
    // Summoned associates are permanent and don't disappear when the caster dies.
    SetLocalInt(oModule, AI_RULE_PERM_ASSOC, FALSE);
    // Allows monsters cast summons spells when prebuffing.
    SetLocalInt(oModule, AI_RULE_PRESUMMON, FALSE);
    // Makes all monsters wander around.
    SetLocalInt(GetModule(), AI_RULE_WANDER, FALSE);
}
