local Translations = {
    success = {
        you_have_been_clocked_in = "Je bent ingelogd",
        sold = 'Je hebt %{amount} %{item} verkocht voor $%{price}',
    },
    text = {
        point_enter_warehouse = "[E] Betreed magazijn",
        enter_warehouse = "Betreed magazijn",
        exit_warehouse = "Verlaat magazijn",
        point_exit_warehouse = "[E] Verlaat magazijn",
        toggle_duty = "Schakel dienst in/uit",
        point_toggle_duty = "[E] Schakel dienst in/uit",
        hand_in_package = "Lever pakket in",
        point_hand_in_package = "[E] Lever pakket in",
        get_package = "Haal pakket op",
        point_get_package = "[E] Haal pakket op",
        picking_up_the_package = "Pakket ophalen",
        unpacking_the_package = "Pakket uitpakken",
        clock_in = "Je bent ingelogd",
        clock_out = "Je bent uitgelogd",
        sell_materials = "Verkoop materialen",
        point_sell_materials = "[E] Verkoop materialen",
        price = "Prijs: $%{price}",
        amount = "Hoeveelheid",
        sell = "Verkopen",
    },
    error = {
        you_have_clocked_out = "Je bent uitgelogd",
        nothing_to_sell = "Je hebt niets om te verkopen",
        out_of_stock = "%{item} is niet op voorraad",
        too_far_to_sell = "Je bent te ver weg om te verkopen",
    },
}

if GetConvar('qb_locale', 'en') == 'nl' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
