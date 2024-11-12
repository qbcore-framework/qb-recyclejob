local Translations = {
    success = {
        you_have_been_clocked_in = "Sie haben sich angemeldet",
    },
    text = {
        point_enter_warehouse = "[E] Lager betreten",
        enter_warehouse= "Lager betreten",
        exit_warehouse= "Lager verlassen",
        point_exit_warehouse = "[E] Lager verlassen",
        clock_out = "[E] Abmelden",
        clock_in = "[E] Anmelden",
        hand_in_package = "Paket abgeben",
        point_hand_in_package = "[E] Paket abgeben",
        get_package = "Paket holen",
        point_get_package = "[E] Paket holen",
        picking_up_the_package = "Paket wird aufgehoben",
        unpacking_the_package = "Paket wird ausgepackt",
    },
    error = {
        you_have_clocked_out = "Sie haben sich abgemeldet"
    },
}

if GetConvar('qb_locale', 'en') == 'de' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
