SELECT
CODPROD AS CODPRODUTO,    
CASE  -- Verifica se o estoque - estoque reservado é menor que 0, se sim, retorna 0, senão, retorna a diferença
        WHEN SUM(ESTOQUE) - SUM(RESERVADO) < 0 THEN 0 
        ELSE SUM(ESTOQUE) - SUM(RESERVADO) 
    END AS ESTOQUE, 
'07160019000144' as CNPJEMPRESA,   
SYSDATE AS DT_ATUALIZACAO

FROM TGFEST -- Tabela de estoque

WHERE  -- Determina que queremos os dados apenas das empresas 1 e 3 (VITALE MATRIZ e VITALE FILIAL, respectivamente)
    CODEMP IN (
        1,3
    )

GROUP 
BY
    CODPROD