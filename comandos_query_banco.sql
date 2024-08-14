
-- 1. Calcule a m�dia de quantidade de estoque dos produtos.

SELECT AVG(quantidade_estoque) AS media_estoque
FROM Produtos;



-- 2. Liste as 3 datas em que mais vendas foram feitas.

SELECT TOP 3 data_venda, COUNT(*) AS total_vendas
FROM Vendas
GROUP BY data_venda
ORDER BY total_vendas DESC;

-- 3.  Calcule o total de vendas e a m�dia de vendas por cliente.

WITH VendaProdutoCount AS (
    SELECT 
        v.cod_cliente_fk,
        COUNT(pv.codProdVenda) AS total_produtos_vendidos
    FROM 
        Vendas v
    JOIN 
        Produtos_Vendas pv ON v.codVenda = pv.cod_venda_fk
    GROUP BY 
        v.cod_cliente_fk
)

SELECT 
    c.cod_cliente,
    c.nome_cliente,
    ISNULL(vp.total_produtos_vendidos, 0) AS total_produtos_vendidos,
    AVG(vp.total_produtos_vendidos) OVER() AS media_produtos_vendidos
FROM 
    Clientes c
LEFT JOIN 
    VendaProdutoCount vp ON c.cod_cliente = vp.cod_cliente_fk;

-- 4. Calcule a m�dia de vendas por cliente e ordene pelo c�digo do cliente.

WITH VendaProdutoCount AS (
    SELECT 
        v.cod_cliente_fk,
        COUNT(pv.codProdVenda) AS total_produtos_vendidos
    FROM 
        Vendas v
    JOIN 
        Produtos_Vendas pv ON v.codVenda = pv.cod_venda_fk
    GROUP BY 
        v.cod_cliente_fk
)

SELECT 
    c.cod_cliente,
    c.nome_cliente,
    ISNULL(vp.total_produtos_vendidos, 0) AS total_produtos_vendidos,
    AVG(vp.total_produtos_vendidos) OVER() AS media_produtos_vendidos
FROM 
    Clientes c
LEFT JOIN 
    VendaProdutoCount vp ON c.cod_cliente = vp.cod_cliente_fk
ORDER BY 
    c.cod_cliente;


-- 5. Liste os clientes que fizeram vendas em uma data espec�fica, por exemplo, '2023-06-15', utilizando uma subconsulta para filtrar as vendas por data.

SELECT 
    c.cod_cliente,
    c.nome_cliente
FROM 
    Clientes c
WHERE 
    c.cod_cliente IN (
        SELECT 
            v.cod_cliente_fk
        FROM 
            Vendas v
        WHERE 
            v.dt_venda = '2023-06-15'
    );

-- 6. Liste os produtos que t�m uma quantidade de estoque abaixo da m�dia, utilizando uma subconsulta para calcular a m�dia de estoque.

SELECT 
    p.cod_produto,
    p.nome_produto,
    p.qtd_estoque
FROM 
    Produtos p
WHERE 
    p.qtd_estoque < (
        SELECT 
            AVG(qtd_estoque)
        FROM 
            Produtos
    );


-- 07. Liste as datas em que o n�mero de vendas foi acima da m�dia, utilizando uma subconsulta para calcular a m�dia de vendas por data. 

WITH VendasPorData AS (
    SELECT 
        dt_venda,
        COUNT(codVenda) AS total_vendas
    FROM 
        Vendas
    GROUP BY 
        dt_venda
)

SELECT 
    v.dt_venda,
    v.total_vendas
FROM 
    VendasPorData v
WHERE 
    v.total_vendas > (
        SELECT 
            AVG(total_vendas)
        FROM 
            VendasPorData
    );

-- 8. Calcular a soma total das quantidades de estoque dos produtos vendidos e comparar com a m�dia geral de estoque.

WITH EstoqueVendido AS (
    SELECT 
        p.cod_produto,
        p.qtd_estoque AS estoque_vendido
    FROM 
        Produtos p
    JOIN 
        Produtos_Vendas pv ON p.cod_produto = pv.cod_produto_fk
    GROUP BY 
        p.cod_produto, p.qtd_estoque
),

SomaEstoqueVendido AS (
    SELECT 
        SUM(estoque_vendido) AS total_estoque_vendido
    FROM 
        EstoqueVendido
),

MediaEstoque AS (
    SELECT 
        AVG(qtd_estoque) AS media_estoque
    FROM 
        Produtos
)

SELECT 
    s.total_estoque_vendido,
    m.media_estoque
FROM 
    SomaEstoqueVendido s, MediaEstoque m;

