local Translations = {
    success = {
        you_have_been_clocked_in = "Vous avez pris votre service",
    },
    text = {
        point_enter_warehouse = "[E] Entrer dans l'entrepôt",
        enter_warehouse= "Entrer dans l'entrepôt",
        exit_warehouse= "Sortir de l'entrepôt",
        point_exit_warehouse = "[E] Sortir de l'entrepôt",
        clock_out = "[E] Quitter son service",
        clock_in = "[E] Prendre son service",
        hand_in_package = "Donner la boite",
        point_hand_in_package = "[E] Donner la boite",
        get_package = "Prendre une boite",
        point_get_package = "[E] Prendre une boite",
        picking_up_the_package = "Prend une boite..",
        unpacking_the_package = "Déballe la boite..",
    },
    error = {
        you_have_clocked_out = "Vous avez quitté votre service!"
    },
}

if GetConvar('qb_locale', 'en') == 'fr' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
