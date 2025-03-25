local Translations = {
    success = {
        you_have_been_clocked_in = "Du er logget ind",
        sold = 'Du har solgt %{amount} %{item} for $%{price}',
    },
    text = {
        point_enter_warehouse = "[E] Gå ind i lageret",
        enter_warehouse = "Gå ind i lageret",
        exit_warehouse = "Gå ud af lageret",
        point_exit_warehouse = "[E] Gå ud af lageret",
        toggle_duty = "Skift vagtstatus",
        point_toggle_duty = "[E] Skift vagtstatus",
        hand_in_package = "Aflever pakke",
        point_hand_in_package = "[E] Aflever pakke",
        get_package = "Hent pakke",
        point_get_package = "[E] Hent pakke",
        picking_up_the_package = "Henter pakken",
        unpacking_the_package = "Pakker pakken ud",
        clock_in = "Du er logget ind",
        clock_out = "Du er logget ud",
        sell_materials = "Sælg materialer",
        point_sell_materials = "[E] Sælg materialer",
        price = "Pris: $%{price}",
        amount = "Mængde",
        sell = "Sælg",
    },
    error = {
        you_have_clocked_out = "Du er logget ud",
        nothing_to_sell = "Du har intet at sælge",
        out_of_stock = "%{item} er udsolgt",
        too_far_to_sell = "Du er for langt væk til at sælge",
    },
}

if GetConvar('qb_locale', 'en') == 'da' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end