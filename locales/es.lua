local Translations = {
    success = {
        you_have_been_clocked_in = "Has iniciado sesión",
        sold = 'Has vendido %{amount} %{item} por $%{price}',
    },
    text = {
        point_enter_warehouse = "[E] Entrar al almacén",
        enter_warehouse = "Entrar al almacén",
        exit_warehouse = "Salir del almacén",
        point_exit_warehouse = "[E] Salir del almacén",
        toggle_duty = "Cambiar turno",
        point_toggle_duty = "[E] Cambiar turno",
        hand_in_package = "Entregar paquete",
        point_hand_in_package = "[E] Entregar paquete",
        get_package = "Obtener paquete",
        point_get_package = "[E] Obtener paquete",
        picking_up_the_package = "Recogiendo el paquete",
        unpacking_the_package = "Desempaquetando el paquete",
        clock_in = "Has iniciado sesión",
        clock_out = "Has cerrado sesión",
        sell_materials = "Vender materiales",
        point_sell_materials = "[E] Vender materiales",
        price = "Precio: $%{price}",
        amount = "Cantidad",
        sell = "Vender",
    },
    error = {
        you_have_clocked_out = "Has cerrado sesión",
        nothing_to_sell = "No tienes nada para vender",
        out_of_stock = "%{item} está agotado",
        too_far_to_sell = "Estás demasiado lejos para vender",
    },
}

if GetConvar('qb_locale', 'en') == 'es' then
    Lang = Lang or Locale:new({
        phrases = Translations,
        warnOnMissing = true
    })
end