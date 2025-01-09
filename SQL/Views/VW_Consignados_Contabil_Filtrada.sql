SELECT
SNK_GET_CUSTO('MEDIOSEMICMS',ITE.CODEMP,ITE.CODPROD,ITE.CODLOCALORIG,ITE.CONTROLE,SYSDATE) * (ITE.QTDNEG-ITE.QTDENTREGUE) AS CUSTO_TOTAL_REAL,
CASE WHEN CAB.CODTIPOPER = 1410
AND NVL((   SELECT
                MAX(I.NUNOTARET)        
                FROM AD_PENDFAT P 
                INNER JOIN AD_ITENSPED I ON P.CODPEND = I.CODPEND 
                WHERE P.NUNOTAEST = ITE.NUNOTA
                AND I.SEQUENCIA = ITE.AD_SEQUENCIAPEND AND EXISTS(SELECT * FROM TGFITE WHERE NUNOTA = I.NUNOTARET)
            ),0) = 0 
            THEN 
            'S' 
            WHEN CAB.CODTIPOPER <> 1410 THEN
            ITE.PENDENTE
            ELSE 'N'
            END 
             AS "Pendente", -- "Pendente"

CUS.CODCENCUS,
CUS.DESCRCENCUS AS "Centro_Resultado", -- "Centro_Resultado"
CAB.CODTIPOPER AS "Codigo_da_TOP", -- "Codigo_da_TOP" -- Validar se é a mesma coluna utilizada na tela "Controle de Consignados"
TPO.DESCROPER AS "Descricao_da_TOP", -- "Descricao_da_TOP"
CAB.NUMNOTA AS "Nro_Nota", -- "Nro_Nota"
CAB.NUNOTA AS "Nro_Unico", --"Nro_Unico"
TO_CHAR(CAB.DTNEG, 'DD/MM/YYYY') AS "DtNegoc",
CAB.CODPARC AS "CodParceiro", --"CODPARCEIRO"
DEST.CODPARC AS "CodParceiro_Fat", -- "CODPARCEIRO_FAT"
DEST.NOMEPARC AS "Nome_do_Parceiro_Fat", -- "NOME_DO_PARCEIRO_FAT"
PAR.NOMEPARC AS "Nome_do_Parceiro", -- "NOME_DO_PARCEIRO"
LOC.DESCRLOCAL AS "Descricao_do_Local", -- "DESCRICAO_DO_LOCAL"
ITE.CODPROD AS "CodProduto", -- "CODPRODUTO"
PRO.DESCRPROD AS "DescProdutos", -- "DESCPRODUTOS"
ITE.CONTROLE AS "Controle", -- "CONTROLE"
ITE.QTDNEG AS "Qtd_Itens", -- "QTD_ITENS"
CASE WHEN  CAB.PENDENTE = 'N' THEN (SELECT NOMEUSU FROM TSIUSU WHERE CODUSU = CAB.CODUSU) END AS "Usuario de Alteração",
(ITE.QTDNEG-ITE.QTDENTREGUE)*ITE.VLRUNIT AS "Vlr. Total Pendente",
CAB.OBSERVACAO As "Observacao_da_Nota" ,
CAB.AD_MEDICO_TEX  || ' '||MED.NOMEMEDICO  AS "Medico",
CAB.AD_PACIENTE as "Paciente",
CAB.AD_CONVENIO_TEX || ' '|| CON.NOME as "Convenio",
TO_CHAR(CAB.AD_DTUTILIZACAO, 'DD/MM/YYYY') AS "DT_Utilizacao",
VEN.APELIDO,
PRO.MARCA as MARCA,
PRO.AD_LINHA as LINHA,
PROCED.CODPROCED as "CodProcedimento",
PROCED.DESCRPROCED as "Procedimento"



FROM TGFCAB CAB  -- Cabeçalho da Nota (possui os campos do cabelho da nota)
    
INNER JOIN TGFITE ITE ON (CAB.NUNOTA = ITE.NUNOTA)  -- Item nota (possui os campos do corpo da nota)
INNER JOIN TGFPAR PAR ON (CAB.CODPARC = PAR.CODPARC) -- Parceiros (contém os parceiros cadastrados no sistema)
INNER JOIN TGFPRO PRO ON (ITE.CODPROD = PRO.CODPROD) -- Produtos (contém os produtos cadastrados no sistema)
INNER JOIN TGFTOP TPO ON (CAB.CODTIPOPER = TPO.CODTIPOPER AND CAB.DHTIPOPER = TPO.DHALTER) -- Tipo de Operação (contém os tipos de operações cadastrados no sistema)
INNER JOIN TSIEMP EMP ON (ITE.CODEMP = EMP.CODEMP) -- Empresa (contém as empresas da vitale que foram cadastradas no sistema)
INNER JOIN TGFLOC LOC ON (ITE.CODLOCALORIG = LOC.CODLOCAL) -- Locais de estoque

LEFT JOIN AD_PENDFAT FAT ON CAB.AD_CODPEND = FAT.CODPEND  -- Pendência de faturamento
LEFT JOIN TGFPAR DEST ON CAB.CODPARCDEST = DEST.CODPARC -- 
LEFT JOIN TSICID CID ON PAR.CODCID = CID.CODCID -- Cidades
LEFT JOIN TSIUFS UFS ON CID.UF = UFS.CODUF -- Estados
LEFT JOIN TSICID CIDD ON DEST.CODCID = CIDD.CODCID -- 
LEFT JOIN TSIUFS UF ON CIDD.UF = UF.CODUF -- 
LEFT JOIN TSICUS CUS ON CAB.CODCENCUS = CUS.CODCENCUS -- Centros de Resultado
LEFT JOIN AD_TIPOPROCED PROCED ON FAT.CODPROCED = PROCED.CODPROCED -- Procedimentos médicos
LEFT JOIN AD_CONVENIO CON ON CAB.AD_CODCONVENIO = CON.CODCONVENIO -- Convenios cadastrados
LEFT JOIN AD_MEDICO MED ON CAB.AD_CODMEDICO = MED.CODMEDICO -- Medicos cadastrados
LEFT JOIN TGFVEN VEN ON CAB.CODVEND = VEN.CODVEND -- Vendedores cadastrados

LEFT JOIN TGFEST EST ON (CAB.CODEMP = EST.CODEMP   -- Estoque
            AND ITE.CODPROD = EST.CODPROD             
            AND ITE.CONTROLE = EST.CONTROLE 
            AND ITE.CODLOCALORIG = EST.CODLOCAL 
            AND EST.TIPO = 'P' 
            AND EST.CODPARC = 0)

WHERE
CAB.DTNEG >= TO_DATE('01/01/2018','DD/MM/YYYY') -- Data inicial da consulta com base na data de negociação
AND PRO.AD_LINHA IN ('CORONÁRIA','VASCULAR','CRM','EP','TER. ABLATIVAS','ESTRUTURAL','ENDOSCOPIA','OPME ACESSÓRIOS', 'IMOBILIZADOS', 'NUTRIÇÃO', 'RADIOLOGIA') -- Linhas consideradas (Incluídas as linhas "IMOBILIZADOS", "NUTRIÇÃO" e "RADIOLOGIA")  -- Centros de Resultado considerados
AND CAB.CODTIPOPER IN (682,1410) -- Tops que estão sendo consideradas
AND CASE WHEN CAB.CODTIPOPER = 1410
        AND NVL((   SELECT
                MAX(I.NUNOTARET)        
                FROM AD_PENDFAT P 
                INNER JOIN AD_ITENSPED I ON P.CODPEND = I.CODPEND 
                WHERE P.NUNOTAEST = ITE.NUNOTA
                AND I.SEQUENCIA = ITE.AD_SEQUENCIAPEND AND EXISTS(SELECT * FROM TGFITE WHERE NUNOTA = I.NUNOTARET)
                ),0) = 0 
                THEN 
                'S' 
                WHEN CAB.CODTIPOPER <> 1410 THEN
                ITE.PENDENTE
                ELSE 'N'
                END = 'S'
AND (CAB.CODTIPOPER = 1410 OR CAB.STATUSNOTA = 'L')
AND ITE.SEQUENCIA > 0