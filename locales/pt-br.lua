local Translations = {
    success = {
        you_have_been_clocked_in = "Você foi registrado no trabalho",
    },
    text = {
        point_enter_warehouse = "[E] Entrar no Depósito",
        enter_warehouse = "Entrar no Depósito",
        exit_warehouse = "Sair do Depósito",
        point_exit_warehouse = "[E] Sair do Depósito",
        clock_out = "[E] Sair do Trabalho",
        clock_in = "[E] Registrar no Trabalho",
        hand_in_package = "Entregar Pacote",
        point_hand_in_package = "[E] Entregar Pacote",
        get_package = "Pegar Pacote",
        point_get_package = "[E] Pegar Pacote",
        picking_up_the_package = "Pegando o pacote",
        unpacking_the_package = "Desembalando o pacote",
    },
    error = {
        you_have_clocked_out = "Você saiu do trabalho",
    },
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
