Select   
A.CODPROD as CODPRODUTO, -- Retorna o código do produto
A.DESCRPROD as DESCRICAO, -- Retorna a descrição do produto
A.CARACTERISTICAS as OBSERVACAOPRODUTO, -- Retorna as características do produto (Observações)
'07160019000144' as CNPJEMPRESA, -- Define o CNPJ da Empresa utilizado nas cotações
A.CODGRUPOPROD as CODIGOGRUPO, -- CodgrupoProd é o código do grupo de produtos
B.DESCRGRUPOPROD AS DESCRICAOGRUPO, -- Retorna a descrição do grupo de produtos
A.MARCA AS CODIGOFABRICANTE,  -- Retorna o nome do fabricante
A.MARCA AS NOMEFABRICANTE,  -- Retorna o nome do fabricante
CODVOL AS UNIDADE,  -- Retorna o tipo de unidade padrão do produto (unidade, caixa, etc)
1 AS EMBALAGEM, -- Define 1 como embalagem para fins de integração
1 AS UNIDADEDEFAULT,  -- Define 1 como unidade padrão para fins de integração
CASE 
        WHEN A.ATIVO = 'S' THEN 1 -- Se o produto estiver ativo então retorne 1
        ELSE 0 -- Se inativo, retorne 0
    END AS ATIVO, 
SYSDATE AS DT_ATUALIZACAO 

From TGFPRO A -- Define TGFPRO como A e TGFGRU (Grupo Produto) como B
Inner 
Join
    TGFGRU B 
        ON A.CODGRUPOPROD = B.CODGRUPOPROD -- Faz o join entre as tabelas TGFPRO e TGFGRU para utilizar os dados de descrição do grupo de produtos