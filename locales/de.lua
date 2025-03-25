local Translations = {
    success = {
        you_have_been_clocked_in = "Du wurdest eingeloggt",
        sold = 'Du hast %{amount} %{item} für $%{price} verkauft',
    },
    text = {
        point_enter_warehouse = "[E] Lager betreten",
        enter_warehouse = "Lager betreten",
        exit_warehouse = "Lager verlassen",
        point_exit_warehouse = "[E] Lager verlassen",
        toggle_duty = "Schicht wechseln",
        point_toggle_duty = "[E] Schicht wechseln",
        hand_in_package = "Paket abgeben",
        point_hand_in_package = "[E] Paket abgeben",
        get_package = "Paket abholen",
        point_get_package = "[E] Paket abholen",
        picking_up_the_package = "Paket wird abgeholt",
        unpacking_the_package = "Paket wird ausgepackt",
        clock_in = "Du bist eingeloggt",
        clock_out = "Du bist ausgeloggt",
        sell_materials = "Materialien verkaufen",
        point_sell_materials = "[E] Materialien verkaufen",
        price = "Preis: $%{price}",
        amount = "Menge",
        sell = "Verkaufen",
    },
    error = {
        you_have_clocked_out = "Du hast dich ausgeloggt",
        nothing_to_sell = "Du hast nichts zu verkaufen",
        out_of_stock = "%{item} ist ausverkauft",
        too_far_to_sell = "Du bist zu weit entfernt, um zu verkaufen",
    },
}
if GetConvar('qb_locale', 'en') == 'de' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end