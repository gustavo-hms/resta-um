module Tests exposing (..)

import Test exposing (..)
import Expect
import Fuzz exposing (list, int, intRange, tuple, string)
import RestaUm exposing (..)


posição : Fuzz.Fuzzer Posição
posição =
    tuple ( intRange 0 14, intRange 0 14 )


escolherPedra : Test
escolherPedra =
    describe "Escolher uma casa"
        [ test "Casa com pedra altera a seleção" <|
            \() ->
                let
                    esperado =
                        { tabuleiro = tabuleiroNovo
                        , escolhida = Just ( 7, 1 )
                        }
                in
                    modelo
                        |> escolher ( 7, 1 )
                        |> Expect.equal esperado
        , test "Casa sem pedra não altera o modelo" <|
            \() ->
                modelo
                    |> escolher ( 7, 7 )
                    |> Expect.equal modelo
        , fuzz posição "Tenta selecionar uma casa aleatória" <|
            \posição ->
                let
                    esperado =
                        if ocupada posição modelo.tabuleiro then
                            { modelo | escolhida = Just posição }
                        else
                            modelo
                in
                    modelo
                        |> escolher posição
                        |> Expect.equal esperado
        ]


validarJogada : Test
validarJogada =
    describe "Validação de uma jogada"
        [ test "Jogada válida" <|
            \() ->
                let
                    jogada =
                        Jogada ( 5, 7 ) ( 7, 7 )
                in
                    jogadaVálida jogada modelo.tabuleiro
                        |> Expect.true "Espera-se que a jogada seja válida"
        , test "Casa fora do tabuleiro gera jogada inválida" <|
            \() ->
                let
                    tabuleiro =
                        remover ( 6, 1 ) modelo.tabuleiro

                    jogada =
                        Jogada ( 4, 1 ) ( 6, 1 )
                in
                    jogadaVálida jogada tabuleiro
                        |> Expect.false "Espera-se que a jogada seja inválida"
        , test "Casa de origem vazia gera jogada inválida" <|
            \() ->
                let
                    tabuleiro =
                        remover ( 7, 5 ) modelo.tabuleiro

                    jogada =
                        Jogada ( 7, 5 ) ( 7, 7 )
                in
                    jogadaVálida jogada tabuleiro
                        |> Expect.false "Espera-se que a jogada seja inválida"
        , test "Casa de destino ocupada gera jogada inválida" <|
            \() ->
                let
                    jogada =
                        Jogada ( 7, 8 ) ( 7, 10 )
                in
                    jogadaVálida jogada modelo.tabuleiro
                        |> Expect.false "Espera-se que a jogada seja inválida"
        , test "Distância menor que 2 gera jogada inválida" <|
            \() ->
                let
                    jogada =
                        Jogada ( 7, 6 ) ( 7, 7 )
                in
                    jogadaVálida jogada modelo.tabuleiro
                        |> Expect.false "Espera-se que a jogada seja inválida"
        , test "Distância maior que 2 gera jogada inválida" <|
            \() ->
                let
                    jogada =
                        Jogada ( 7, 4 ) ( 7, 7 )
                in
                    jogadaVálida jogada modelo.tabuleiro
                        |> Expect.false "Espera-se que a jogada seja inválida"
        , test "Jogada não-linear é inválida" <|
            \() ->
                let
                    jogada =
                        Jogada ( 5, 6 ) ( 7, 7 )
                in
                    jogadaVálida jogada modelo.tabuleiro
                        |> Expect.false "Espera-se que a jogada seja inválida"
        ]


efetuarJogada : Test
efetuarJogada =
    describe "Verificar se uma jogada é feita corretamente"
        [ test "Jogada válida" <|
            \() ->
                let
                    jogada =
                        Jogada ( 7, 5 ) ( 7, 7 )

                    resultado =
                        modelo.tabuleiro
                            |> remover ( 7, 5 )
                            |> remover ( 7, 6 )
                            |> inserir ( 7, 7 )
                in
                    modelo.tabuleiro
                        |> jogar jogada
                        |> Expect.equal resultado
        , test "Jogada inválida" <|
            \() ->
                let
                    jogada =
                        Jogada ( 7, 6 ) ( 7, 8 )
                in
                    modelo.tabuleiro
                        |> jogar jogada
                        |> Expect.equal modelo.tabuleiro
        , fuzz2 posição posição "Executa uma jogada aleatória" <|
            \a b ->
                let
                    jogada =
                        Jogada a b

                    esperado =
                        if jogadaVálida jogada modelo.tabuleiro then
                            modelo.tabuleiro
                                |> remover a
                                |> remover (entre a b)
                                |> inserir b
                        else
                            modelo.tabuleiro
                in
                    modelo.tabuleiro
                        |> jogar jogada
                        |> Expect.equal esperado
        ]


all : Test
all =
    describe "Testes"
        [ escolherPedra
        , validarJogada
        , efetuarJogada
        ]
