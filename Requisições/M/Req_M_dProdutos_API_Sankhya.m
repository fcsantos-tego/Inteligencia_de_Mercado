let
    // Função para autenticar e obter o BearerToken
    AutenticarAPI = () => 
        let
            url = "https://api.sankhya.com.br/login",
            payload = "{}",
            headers = [
                #"Appkey" = "",
                #"Token" = "",
                #"Username" = "",
                #"Password" = ""
            ],
            options = [
                Headers = headers,
                Content = Text.ToBinary(payload),
                IsRetry = false
            ],
            response = Web.Contents(url, options),
            jsonResponse = Json.Document(response),
            BearerToken = if Record.HasFields(jsonResponse, "bearerToken") then jsonResponse[bearerToken] else null
        in
            BearerToken,

    // Função para obter os dados com paginação
          
          ObterDadosAPI = (BearerToken as text, offsetPage as number) =>
        let
            url = "https://api.sankhya.com.br/gateway/v1/mge/service.sbr?serviceName=CRUDServiceProvider.loadRecords&outputType=json",
            payload = Text.ToBinary(
                "{
                    ""requestBody"": {
                        ""dataSet"": {
                            ""rootEntity"": ""Produto"",
                            ""includePresentationFields"": ""N"",
                            ""tryJoinedFields"": ""true"",
                            ""offsetPage"": """ & Number.ToText(offsetPage) & """,
                            ""entity"": [
                                {
                                  ""path"": """",
                                  ""fieldset"": {
                                      ""list"": ""DESCRPROD, CODPROD, MARCA, NCM, COMPLDESC, AD_REGISTRO_MS, ATIVO, REFFORN, AD_CATEGORIA, AD_SUBCATEGORIA, AD_LINHA, USOPROD""
                                  }
                              },
                              {
                                  ""path"": ""GrupoProduto"",
                                  ""fieldset"": {
                                      ""list"": ""DESCRGRUPOPROD""
                                  }
                              }
                          ]
                      }
                  }
              }"
            ),
            headers = [
                #"Authorization" = "Bearer " & BearerToken,
                #"Appkey" = "",
                #"Token" = "",
                #"Username" = "",
                #"Password" = "",
                #"Content-Type" = "application/json"
            ],
            options = [
                Headers = headers,
                Content = payload
            ],
            response = Web.Contents(url, options),
            jsonResponse = Json.Document(response)
        in
            jsonResponse,

    // Função para coletar todas as páginas
    ColetarTodosOsDados = (BearerToken as text) =>
        let
            ColetarPaginas = List.Generate(
                ()=> [Page = 0, TotalEntidades = 1, Resultados = {}],
                each [TotalEntidades] > 0,
                each 
                    let
                        responseData = ObterDadosAPI(BearerToken, [Page]),
                        entidades = responseData[responseBody][entities][entity],  // Acessando a lista correta
                        totalEntidades = Number.FromText(Record.FieldOrDefault(responseData[responseBody][entities], "total", "0")),
                        newPage = [Page] + 1
                    in
                        [Page = newPage, TotalEntidades = totalEntidades, Resultados = entidades]
            ),
            ResultadosCompletos = List.Combine(List.Transform(ColetarPaginas, each _[Resultados]))
        in
            ResultadosCompletos,
    // Autentica e coleta todos os dados
    BearerToken = AutenticarAPI(),
    Dados = ColetarTodosOsDados(BearerToken),
// Transformando a lista de registros em uma tabela
    TabelaDados = Table.FromList(Dados, Splitter.SplitByNothing(), null, null, ExtraValues.Error),

    // Expandindo os registros
    TabelaExpandida = Table.ExpandRecordColumn(TabelaDados, "Column1", {"f0", "f1", "f2", "f3", "f4", "f5", "f6", "f7", "f8", "f9", "f10", "f11", "f12"}, {"DESCRPROD", "CODPROD", "MARCA", "NCM", "COMPLDESC", "AD_REGISTRO_MS", "ATIVO", "REFFORN", "AD_CATEGORIA", "AD_SUBCATEGORIA", "AD_LINHA", "USOPROD", "GrupoProduto_DESCRGRUPOPROD"}),

    TabelaExpandida1 = Table.ExpandRecordColumn(TabelaExpandida, "CODPROD", {"$"}, {"Código"}),
    TabelaExpandida2 = Table.ExpandRecordColumn(TabelaExpandida1, "DESCRPROD", {"$"}, {"Descrição"}),
    TabelaExpandida3 = Table.ExpandRecordColumn(TabelaExpandida2, "MARCA", {"$"}, {"Marca"}),
    TabelaExpandida4 = Table.ExpandRecordColumn(TabelaExpandida3, "NCM", {"$"}, {"NCM"}),
    TabelaExpandida5 = Table.ExpandRecordColumn(TabelaExpandida4, "COMPLDESC", {"$"}, {"Descrição Generica"}),
    TabelaExpandida6 = Table.ExpandRecordColumn(TabelaExpandida5, "AD_REGISTRO_MS", {"$"}, {"Registro M.S."}),
    TabelaExpandida7 = Table.ExpandRecordColumn(TabelaExpandida6, "ATIVO", {"$"}, {"Ativo"}),
    TabelaExpandida8 = Table.ExpandRecordColumn(TabelaExpandida7, "REFFORN", {"$"}, {"Referência do Fornecedor"}),
    TabelaExpandida9 = Table.ExpandRecordColumn(TabelaExpandida8, "AD_CATEGORIA", {"$"}, {"Categoria"}),
    TabelaExpandida10 = Table.ExpandRecordColumn(TabelaExpandida9, "AD_SUBCATEGORIA", {"$"}, {"Sub categoria"}),
    TabelaExpandida11 = Table.ExpandRecordColumn(TabelaExpandida10, "AD_LINHA", {"$"}, {"Linha"}),
    TabelaExpandida12 = Table.ExpandRecordColumn(TabelaExpandida11, "USOPROD", {"$"}, {"USOPROD_Value"}),
    TabelaExpandida13 = Table.ExpandRecordColumn(TabelaExpandida12, "GrupoProduto_DESCRGRUPOPROD", {"$"}, {"Descrição (Grupo Produto)"}),
    
    TabelaExpandidaFinal = TabelaExpandida13,
    #"Linhas Filtradas" = Table.SelectRows(TabelaExpandidaFinal, each [USOPROD_Value] <> "S"),
    #"Valor Substituído" = Table.ReplaceValue(#"Linhas Filtradas","S","Sim",Replacer.ReplaceText,{"Ativo"}),
    #"Valor Substituído1" = Table.ReplaceValue(#"Valor Substituído","N","Não",Replacer.ReplaceText,{"Ativo"}),
    #"Valor Substituído2" = Table.ReplaceValue(#"Valor Substituído1","EP","ELETROFISIOLOGIA",Replacer.ReplaceText,{"Linha"}),
    #"Valor Substituído3" = Table.ReplaceValue(#"Valor Substituído2","TER. ABLATIVAS","TERAPIAS ABLATIVAS",Replacer.ReplaceText,{"Linha"}),
    #"Texto Aparado" = Table.TransformColumns(#"Valor Substituído3",{{"Descrição", Text.Trim, type text}, {"Código", Text.Trim, type text}, {"Marca", Text.Trim, type text}, {"NCM", Text.Trim, type text}, {"Descrição Generica", Text.Trim, type text}, {"Registro M.S.", Text.Trim, type text}, {"Ativo", Text.Trim, type text}, {"Referência do Fornecedor", Text.Trim, type text}, {"Categoria", Text.Trim, type text}, {"Sub categoria", Text.Trim, type text}, {"Linha", Text.Trim, type text}, {"USOPROD_Value", Text.Trim, type text}, {"Descrição (Grupo Produto)", Text.Trim, type text}}),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Texto Aparado",{{"Código", Int64.Type}, {"NCM", Int64.Type}}),
    #"Colunas Reordenadas" = Table.ReorderColumns(#"Tipo Alterado",{"Descrição", "Código", "Marca", "NCM", "Descrição Generica", "Registro M.S.", "Ativo", "Referência do Fornecedor", "Categoria", "Sub categoria", "Descrição (Grupo Produto)", "Linha", "USOPROD_Value"}),
    #"Colunas Removidas" = Table.RemoveColumns(#"Colunas Reordenadas",{"USOPROD_Value"})
in
    #"Colunas Removidas"