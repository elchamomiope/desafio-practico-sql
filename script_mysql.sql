
-- Tabla CLIENTES
CREATE TABLE clientes (
    id_cliente   SERIAL PRIMARY KEY,
    nombre       VARCHAR(50)  NOT NULL,
    apellido     VARCHAR(50)  NOT NULL,
    direccion    VARCHAR(150),
    correo       VARCHAR(100) UNIQUE,
    telefono     VARCHAR(20)
);

-- Tabla PRODUCTOS
CREATE TABLE productos (
    id_producto  SERIAL PRIMARY KEY,
    nombre       VARCHAR(100) NOT NULL,
    descripcion  VARCHAR(255),
    precio       DECIMAL(10,2) NOT NULL,
    categoria    VARCHAR(50),
    stock        INT DEFAULT 0
);

-- Tabla PEDIDOS
CREATE TABLE pedidos (
    id_pedido    SERIAL PRIMARY KEY,
    id_cliente   INT NOT NULL,
    fecha        DATE NOT NULL,
    estado       VARCHAR(30),
    total        DECIMAL(10,2),
    CONSTRAINT fk_pedidos_clientes
        FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

-- Tabla VENTAS 
CREATE TABLE ventas (
    id_venta      SERIAL PRIMARY KEY,
    id_pedido     INT NOT NULL,
    id_producto   INT NOT NULL,
    cantidad      INT NOT NULL,
    precio_venta  DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_ventas_pedidos
        FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido),
    CONSTRAINT fk_ventas_productos
        FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);



-- 2 INSERCION DE REGISTROS


-- CLIENTES 5
INSERT INTO clientes (nombre, apellido, direccion, correo, telefono) VALUES
('Maria',   'Perez',    'Av. Bolivar, Caracas',        'maria.perez@mail.com',   '0414-1111111'),
('Carlos',  'Gomez',    'Calle Real, Valencia',        'carlos.gomez@mail.com',  '0424-2222222'),
('Luisa',   'Fernandez','Av. Libertador, Maracay',     'luisa.fernandez@mail.com','0412-3333333'),
('Pedro',   'Ramirez',  'Calle Sucre, Barquisimeto',   'pedro.ramirez@mail.com', '0416-4444444'),
('Ana',     'Torres',   'Av. Urdaneta, Maracaibo',     'ana.torres@mail.com',    '0426-5555555');

-- PRODUCTOS 8
INSERT INTO productos (nombre, descripcion, precio, categoria, stock) VALUES
('Camiseta Basica Blanca', 'Camiseta 100% algodon',        10.00, 'Camisetas',  50),
('Camiseta Estampada',     'Camiseta con diseno grafico',  12.50, 'Camisetas',  40),
('Camiseta Deportiva',     'Camiseta dry-fit',              15.00, 'Camisetas',  30),
('Pantalon Jean',          'Jean corte recto',              25.00, 'Pantalones', 20),
('Pantalon Deportivo',     'Pantalon jogger',                20.00, 'Pantalones', 25),
('Zapatos Casuales',       'Zapatos de cuero sintetico',     35.00, 'Zapatos',    15),
('Gorra',                  'Gorra ajustable',                 8.00, 'Accesorios', 60),
('Medias',                 'Pack de 3 pares',                 5.00, 'Accesorios', 80);

-- PEDIDOS8
INSERT INTO pedidos (id_cliente, fecha, estado, total) VALUES
(1, CURRENT_DATE - INTERVAL '5 days',   'Completado', 32.50),
(2, CURRENT_DATE - INTERVAL '10 days',  'Completado', 45.00),
(3, CURRENT_DATE - INTERVAL '20 days',  'Completado', 20.00),
(1, CURRENT_DATE - INTERVAL '40 days',  'Completado', 15.00),
(4, CURRENT_DATE - INTERVAL '90 days',  'Completado', 35.00),
(5, CURRENT_DATE - INTERVAL '200 days', 'Completado', 10.00),
(2, CURRENT_DATE - INTERVAL '3 days',   'Pendiente',  0.00),
(3, CURRENT_DATE - INTERVAL '7 days',   'Cancelado',  0.00);

-- VENTAS solo para los pedidos 1 al 6; 7 y 8 quedan sin ventas
INSERT INTO ventas (id_pedido, id_producto, cantidad, precio_venta) VALUES
(1, 1, 2, 10.00),
(1, 7, 1, 8.00),
(2, 4, 1, 25.00),
(2, 2, 1, 12.50),
(3, 2, 1, 12.50),
(3, 8, 1, 5.00),
(4, 1, 1, 10.00),
(5, 6, 1, 35.00),
(6, 7, 1, 10.00);



-- 3 CONSULTAS AVANZADAS CON SELECT


-- Consulta 1: nombre completo, direccion y correo de clientes que
-- hicieron pedidos en los ultimos 30 dias.
SELECT DISTINCT
    c.nombre || ' ' || c.apellido AS nombre_completo,
    c.direccion,
    c.correo
FROM clientes c
JOIN pedidos p ON p.id_cliente = c.id_cliente
WHERE p.fecha >= CURRENT_DATE - INTERVAL '30 days';

-- Consulta 2: productos con mayor cantidad de ventas en el ultimo mes,
-- junto con el total vendido de cada uno.
SELECT
    pr.nombre,
    SUM(v.cantidad)                 AS unidades_vendidas,
    SUM(v.cantidad * v.precio_venta) AS total_vendido
FROM ventas v
JOIN productos pr ON pr.id_producto = v.id_producto
JOIN pedidos pe    ON pe.id_pedido  = v.id_pedido
WHERE pe.fecha >= CURRENT_DATE - INTERVAL '1 month'
GROUP BY pr.nombre
ORDER BY unidades_vendidas DESC;

-- Consulta 3: clientes que mas pedidos han hecho en el ultimo ano,
-- ordenados de mayor a menor cantidad de pedidos.
SELECT
    c.nombre || ' ' || c.apellido AS nombre_completo,
    COUNT(p.id_pedido) AS cantidad_pedidos
FROM clientes c
JOIN pedidos p ON p.id_cliente = c.id_cliente
WHERE p.fecha >= CURRENT_DATE - INTERVAL '1 year'
GROUP BY c.nombre, c.apellido
ORDER BY cantidad_pedidos DESC;



-- 4. ACTUALIZACIONES CON UPDATE


-- Actualizacion 1: aumentar 10% el precio de todos los productos
-- de la categoria "Camisetas".
UPDATE productos
SET precio = ROUND(precio * 1.10, 2)
WHERE categoria = 'Camisetas';

-- Verificacion del cambio
SELECT nombre, categoria, precio FROM productos WHERE categoria = 'Camisetas';



-- 5. ELIMINACIONES CON DELETE


-- Eliminacion 2: eliminar los pedidos que NO tengan ventas asociadas
-- (en los datos de prueba son los pedidos 7 y 8).
DELETE FROM pedidos
WHERE id_pedido NOT IN (
    SELECT DISTINCT id_pedido FROM ventas
);

-- Verificacion: deberian quedar solo los pedidos 1 al 6
SELECT * FROM pedidos ORDER BY id_pedido;



-- 6. CREACION DE VISTAS


-- Vista 1: nombre completo del cliente, fecha del pedido y total del pedido.
CREATE VIEW vista_clientes_pedidos AS
SELECT
    c.nombre || ' ' || c.apellido AS nombre_completo,
    p.fecha AS fecha_pedido,
    p.total AS total_pedido
FROM clientes c
JOIN pedidos p ON p.id_cliente = c.id_cliente;

-- Consultar la vista
SELECT * FROM vista_clientes_pedidos ORDER BY fecha_pedido DESC;
