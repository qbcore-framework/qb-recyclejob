local Translations = {
    success = {
        you_have_been_clocked_in = "Você foi registrado na entrada",
    },
    text = {
        point_enter_warehouse = "[E] Entrar no Armazém",
        enter_warehouse = "Entrar no Armazém",
        exit_warehouse = "Sair do Armazém",
        point_exit_warehouse = "[E] Sair do Armazém",
        clock_out = "[E] Registrar Saída",
        clock_in = "[E] Registrar Entrada",
        hand_in_package = "Entregar Pacote",
        point_hand_in_package = "[E] Entregar Pacote",
        get_package = "Pegar Pacote",
        point_get_package = "[E] Pegar Pacote",
        picking_up_the_package = "Pegando o pacote",
        unpacking_the_package = "Desembalando o pacote",
    },
    error = {
        you_have_clocked_out = "Você registrou sua saída",
    },
}

if GetConvar('qb_locale', 'en') == 'pt-br' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end