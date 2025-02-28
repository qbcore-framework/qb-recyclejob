local Translations = {
    success = {
        you_have_been_clocked_in = "Você foi registrado",
        sold = 'Você vendeu %{amount} %{item} por $%{price}',
    },
    text = {
        point_enter_warehouse = "[E] Entrar no armazém",
        enter_warehouse = "Entrar no armazém",
        exit_warehouse = "Sair do armazém",
        point_exit_warehouse = "[E] Sair do armazém",
        toggle_duty = "Alternar turno",
        point_toggle_duty = "[E] Alternar turno",
        hand_in_package = "Entregar pacote",
        point_hand_in_package = "[E] Entregar pacote",
        get_package = "Pegar pacote",
        point_get_package = "[E] Pegar pacote",
        picking_up_the_package = "Pegando o pacote",
        unpacking_the_package = "Desembalando o pacote",
        clock_in = "Você foi registrado",
        clock_out = "Você foi deslogado",
        sell_materials = "Vender materiais",
        point_sell_materials = "[E] Vender materiais",
        price = "Preço: $%{price}",
        amount = "Quantidade",
        sell = "Vender",
    },
    error = {
        you_have_clocked_out = "Você foi deslogado",
        nothing_to_sell = "Você não tem nada para vender",
        out_of_stock = "%{item} está fora de estoque",
        too_far_to_sell = "Você está muito longe para vender",
    },
}

if GetConvar('qb_locale', 'en') == 'pt-br' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end