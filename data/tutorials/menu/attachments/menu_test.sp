#include <sourcemod>

public void OnPluginStart()
{
    RegConsoleCmd("sm_menu", Command_Menu, "打开测试菜单");
    RegConsoleCmd("sm_shop", Command_Shop, "打开商店菜单");
}

public Action Command_Menu(int client, int args)
{
    if (client == 0)
        return Plugin_Handled;

    DrawMainMenu(client);
    return Plugin_Handled;
}

public Action Command_Shop(int client, int args)
{
    if (client == 0)
        return Plugin_Handled;

    DrawShopCategoryMenu(client);
    return Plugin_Handled;
}

void DrawMainMenu(int client)
{
    Menu menu = CreateMenu(MainMenuHandler);
    menu.SetTitle("测试菜单");

    menu.AddItem("hello", "打招呼");
    menu.AddItem("heal", "回复 50 血量");

    if (!IsPlayerAlive(client))
        menu.AddItem("info", "查看信息（需存活）", ITEMDRAW_DISABLED);
    else
        menu.AddItem("info", "查看当前血量");

    menu.Display(client, MENU_TIME_FOREVER);
}

public int MainMenuHandler(Menu menu, MenuAction action, int client, int param)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            char info[32];
            menu.GetItem(param, info, sizeof(info));

            if (StrEqual(info, "hello"))
            {
                PrintToChat(client, "[菜单] 你好，%N！", client);
            }
            else if (StrEqual(info, "heal"))
            {
                if (!IsPlayerAlive(client))
                {
                    PrintToChat(client, "[菜单] 你已死亡，无法回复血量");
                    return 0;
                }

                int health = GetClientHealth(client);
                SetEntProp(client, Prop_Send, "m_iHealth", health + 50);
                PrintToChat(client, "[菜单] 已回复 50 血量，当前 %d", GetClientHealth(client));
            }
            else if (StrEqual(info, "info"))
            {
                PrintToChat(client, "[菜单] 当前血量: %d", GetClientHealth(client));
            }
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
    return 0;
}

void DrawShopCategoryMenu(int client)
{
    Menu menu = CreateMenu(ShopCategoryHandler);
    menu.SetTitle("商店 - 选择分类");
    menu.AddItem("weapon", "武器");
    menu.AddItem("item", "道具");
    menu.AddItem("buff", "增益");
    menu.Display(client, MENU_TIME_FOREVER);
}

public int ShopCategoryHandler(Menu menu, MenuAction action, int client, int param)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            char category[32];
            menu.GetItem(param, category, sizeof(category));
            DrawShopItemMenu(client, category);
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
    return 0;
}

void DrawShopItemMenu(int client, const char[] category)
{
    Menu menu = CreateMenu(ShopItemHandler);
    menu.SetTitle("商店 - 选择商品");

    if (StrEqual(category, "weapon"))
    {
        menu.AddItem("weapon/rifle", "步枪 (100 积分)");
        menu.AddItem("weapon/shotgun", "霰弹枪 (80 积分)");
    }
    else if (StrEqual(category, "item"))
    {
        menu.AddItem("item/medkit", "医疗包 (50 积分)");
        menu.AddItem("item/pills", "止痛药 (20 积分)");
    }
    else if (StrEqual(category, "buff"))
    {
        menu.AddItem("buff/speed", "加速 30 秒 (60 积分)");
        menu.AddItem("buff/armor", "护甲 (120 积分)", ITEMDRAW_DISABLED);
    }

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int ShopItemHandler(Menu menu, MenuAction action, int client, int param)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            char info[64];
            menu.GetItem(param, info, sizeof(info));
            DrawShopConfirmMenu(client, info);
        }
        case MenuAction_Cancel:
        {
            if (param == MenuCancel_ExitBack)
                DrawShopCategoryMenu(client);
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
    return 0;
}

void DrawShopConfirmMenu(int client, const char[] info)
{
    Menu menu = CreateMenu(ShopConfirmHandler);
    menu.SetTitle("确认购买？");
    menu.AddItem(info, "是");
    menu.AddItem("cancel", "否");
    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public int ShopConfirmHandler(Menu menu, MenuAction action, int client, int param)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            char choice[64];
            menu.GetItem(param, choice, sizeof(choice));

            if (StrEqual(choice, "cancel"))
            {
                DrawShopCategoryMenu(client);
            }
            else
            {
                PrintToChat(client, "[商店] 已购买: %s", choice);
            }
        }
        case MenuAction_Cancel:
        {
            if (param == MenuCancel_ExitBack)
                DrawShopCategoryMenu(client);
        }
        case MenuAction_End:
        {
            delete menu;
        }
    }
    return 0;
}