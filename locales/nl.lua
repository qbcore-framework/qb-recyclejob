local Translations = {
    success = {
        you_have_been_clocked_in = "Je bent indienst gegaan",
    },
    text = {
        point_enter_warehouse = "[E] Enter stockage",
        enter_warehouse= "Enter Stockage",
        exit_warehouse= "Verlaat Stockage",
        point_exit_warehouse = "[E] Exit Stockage",
        clock_out = "[E] Ga uitdienst",
        clock_in = "[E] Ga indienst",
        hand_in_package = "Lever pakketje in",
        point_hand_in_package = "[E] Lever pakketje in",
        get_package = "Neem pakketje",
        point_get_package = "[E] Neem pakketje",
        picking_up_the_package = "Neem het pakketje",
        unpacking_the_package = "Pakketje openen",
    },
    error = {
        you_have_clocked_out = "Je bent uitdienst gegaan"
    },
}

if GetConvar('qb_locale', 'en') == 'nl' then
    Lang = Lang or Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
