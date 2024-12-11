SELECT       
A.CODPROD AS CODPRODUTO,  -- Retorna o codprod a partir da TGFEXC      
B.UF AS SIGLAUF,   -- Retorna a sigla do estado a partir da TSIUFS     
1 AS EMBALAGEM,    -- Retorna 1 em todas as linhas para a coluna EMBALAGEM, muito provavelmente para indicar que lidamos com produtos unitários na integração  
C.CODVOL  AS UNIDADE,   -- Retorna a unidade padrão de venda a partir da TGFPRO
A.VLRVENDA AS VRVENDA -- Retorna o valor de venda a partir da TGFEXC
FROM TGFEXC A   -- Determina que TGFEXC (Tabela de exceção de preço que contém os produtos) é a tabela A 
INNER 
    JOIN
        (
            
        SELECT UF 
        FROM
            TSIUFS  -- Tabela de estados
        WHERE
            UF NOT IN (
                '0','PE'
            )
        ) B 
            ON 1 = 1 -- Utilizado para que todos os produtos na TGFEXC sejam replicados para todos UFs com exceção de PE
INNER 
    JOIN
        TGFPRO C 
            ON A.CODPROD = C.CODPROD
WHERE A.NUTAB = 761 -- Número da tabela de preço BR na aba histórico de atualizações 

UNION ALL -- Operador que combina os resultados da query acima com o resultado da query abaixo para unir as tabelas de preços que criamos para PE e para os clientes fora de PE

SELECT 
A.CODPROD AS CODPRODUTO,  -- Retorna o codprod a partir da TGFEXC
'PE' AS SIGLAUF, -- Retorna a sigla do estado a partir da TSIUFS
1 AS EMBALAGEM,  -- Retorna 1 em todas as linhas para a coluna EMBALAGEM, muito provavelmente para indicar que lidamos com produtos unitários na integração
C.CODVOL  AS UNIDADE,  -- Retorna a unidade padrão de venda a partir da TGFPRO
A.VLRVENDA AS VRVENDA -- Retorna o valor de venda a partir da TGFEXC
FROM TGFEXC A
INNER 
    JOIN
        TGFPRO C 
            ON A.CODPROD = C.CODPROD
WHERE A.NUTAB = 760  -- Tabela de preço PE na aba histórico de atualizações