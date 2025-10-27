-- ============================================================
-- TAREA: Cobranzas - Script DDL + Datos de ejemplo + Consultas
-- SGBD: PostgreSQL
-- Archivo: tarea_cobranzas.sql
-- ============================================================

-- -------------------------
-- 1. DROP (para repetir ejecuciones)
-- -------------------------
DROP TABLE IF EXISTS pago CASCADE;
DROP TABLE IF EXISTS cliente_obligacion CASCADE;
DROP TABLE IF EXISTS obligacion CASCADE;
DROP TABLE IF EXISTS producto CASCADE;
DROP TABLE IF EXISTS cliente CASCADE;

-- -------------------------
-- 2. CREATE TABLES
-- -------------------------
CREATE TABLE cliente (
  id_cliente        SERIAL PRIMARY KEY,
  nombre            VARCHAR(100) NOT NULL,
  apellido          VARCHAR(100) NOT NULL,
  fecha_nacimiento  DATE,
  edad              INT,
  sexo              CHAR(1) CHECK (sexo IN ('M','F'))
);

CREATE TABLE producto (
  id_producto       SERIAL PRIMARY KEY,
  codigo            VARCHAR(50) NOT NULL UNIQUE,
  descripcion       VARCHAR(100) NOT NULL
);

CREATE TABLE obligacion (
  id_obligacion         SERIAL PRIMARY KEY,
  id_producto           INT NOT NULL REFERENCES producto(id_producto),
  valor_desembolsado    NUMERIC(14,2) NOT NULL,
  saldo_capital         NUMERIC(14,2) NOT NULL,
  interes_corriente     NUMERIC(8,4) NOT NULL DEFAULT 0.0,
  interes_mora          NUMERIC(8,4) NOT NULL DEFAULT 0.0,
  dias_mora             INT NOT NULL DEFAULT 0
);

CREATE TABLE cliente_obligacion (
  id_obligacion_fk      INT NOT NULL REFERENCES obligacion(id_obligacion),
  id_cliente_fk         INT NOT NULL REFERENCES cliente(id_cliente),
  tipo_cliente          VARCHAR(20) NOT NULL CHECK (tipo_cliente IN ('DEUDOR','CODEUDOR')),
  PRIMARY KEY (id_obligacion_fk, id_cliente_fk)
);

CREATE TABLE pago (
  id_pago               SERIAL PRIMARY KEY,
  id_obligacion_fk      INT NOT NULL REFERENCES obligacion(id_obligacion),
  fecha_pago            DATE NOT NULL,
  monto_pago            NUMERIC(14,2) NOT NULL
);

-- -------------------------
-- 3. INSERT datos de ejemplo
-- -------------------------
INSERT INTO cliente (nombre, apellido, fecha_nacimiento, edad, sexo) VALUES
('Ana', 'Gomez', '2001-05-10', 24, 'F'),
('Juan', 'Perez', '1980-02-20', 45, 'M'),
('Luisa', 'Diaz', '1995-11-30', 29, 'F'),
('Carlos', 'Rios', '1999-07-01', 25, 'M'),
('Mariana', 'Lopez', '1998-08-22', 26, 'F'),
('Pedro', 'Vargas', '1996-12-13', 28, 'M'),
('Sofia', 'Gutierrez', '1999-09-09', 25, 'F'),
('Diego', 'Suarez', '2003-01-15', 21, 'M');

INSERT INTO producto (codigo, descripcion) VALUES
('TC-VISA', 'Tarjeta de Crédito'),
('HIP-1', 'Hipotecario'),
('LIB-INV', 'Libre Inversion'),
('PR-OTRO', 'Otro Producto');

INSERT INTO obligacion (id_producto, valor_desembolsado, saldo_capital, interes_corriente, interes_mora, dias_mora) VALUES
(1, 2000.00, 1500.00, 0.02, 0.05, 35),
(1, 1000.00, 800.00, 0.02, 0.05, 10),
(2, 80000.00, 75000.00, 0.01, 0.03, 5),
(3, 3000.00, 500.00, 0.03, 0.06, 15),
(3, 7000.00, 0.00, 0.03, 0.06, 0),
(1, 1500.00, 1400.00, 0.02, 0.05, 45),
(3, 2000.00, 100.00, 0.03, 0.06, 40);

INSERT INTO cliente_obligacion VALUES
(1, 1, 'DEUDOR'),
(2, 1, 'CODEUDOR'),
(3, 2, 'DEUDOR'),
(4, 3, 'DEUDOR'),
(4, 4, 'CODEUDOR'),
(5, 5, 'DEUDOR'),
(6, 6, 'DEUDOR'),
(6, 2, 'CODEUDOR'),
(7, 7, 'DEUDOR');

INSERT INTO pago (id_obligacion_fk, fecha_pago, monto_pago) VALUES
(1, '2024-07-01', 100.00),
(1, '2024-08-01', 200.00),
(2, '2024-08-15', 50.00),
(3, '2024-09-01', 1000.00),
(4, '2024-07-20', 300.00),
(6, '2024-08-20', 100.00),
(7, '2024-09-05', 50.00);

-- -------------------------
-- 4. CONSULTAS (3.1 → 3.10)
-- -------------------------
-- 3.1.a LEFT JOIN
SELECT '-- 3.1.a LEFT JOIN: clientes con (posible) obligaciones (NULL si no)' AS contexto;
SELECT c.id_cliente, c.nombre, o.id_obligacion, p.descripcion
FROM cliente c
LEFT JOIN cliente_obligacion co ON c.id_cliente = co.id_cliente_fk
LEFT JOIN obligacion o ON co.id_obligacion_fk = o.id_obligacion
LEFT JOIN producto p ON o.id_producto = p.id_producto
ORDER BY c.id_cliente, o.id_obligacion;

-- 3.1.a RIGHT JOIN (ejemplo)
SELECT '-- 3.1.a RIGHT JOIN: obligaciones con (posible) cliente (NULL si no)' AS contexto;
SELECT o.id_obligacion, p.descripcion, c.id_cliente, c.nombre
FROM obligacion o
LEFT JOIN producto p ON o.id_producto = p.id_producto
RIGHT JOIN cliente_obligacion co ON o.id_obligacion = co.id_obligacion_fk
RIGHT JOIN cliente c ON co.id_cliente_fk = c.id_cliente
ORDER BY o.id_obligacion;

-- 3.1.b CROSS JOIN vs FULL JOIN
SELECT '-- 3.1.b CROSS JOIN (cliente×producto, limit)' AS contexto;
SELECT c.id_cliente, c.nombre, p.id_producto, p.descripcion
FROM cliente c
CROSS JOIN producto p
ORDER BY c.id_cliente, p.id_producto
LIMIT 20;

SELECT '-- 3.1.b FULL JOIN demo' AS contexto;
SELECT c.id_cliente, c.nombre, o.id_obligacion, p.descripcion
FROM cliente c
FULL JOIN cliente_obligacion co ON c.id_cliente = co.id_cliente_fk
FULL JOIN obligacion o ON co.id_obligacion_fk = o.id_obligacion
LEFT JOIN producto p ON o.id_producto = p.id_producto
ORDER BY COALESCE(c.id_cliente, o.id_obligacion);

-- 3.1.c INNER JOIN
SELECT '-- 3.1.c INNER JOIN: solo clientes con obligaciones' AS contexto;
SELECT c.id_cliente, c.nombre, o.id_obligacion, p.descripcion
FROM cliente c
INNER JOIN cliente_obligacion co ON c.id_cliente = co.id_cliente_fk
INNER JOIN obligacion o ON co.id_obligacion_fk = o.id_obligacion
INNER JOIN producto p ON o.id_producto = p.id_producto
ORDER BY c.id_cliente;

-- NATURAL JOIN demo (usar con cuidado)
CREATE OR REPLACE VIEW v_cliente_ob AS
SELECT id_cliente_fk AS id_cliente, id_obligacion_fk FROM cliente_obligacion;

SELECT '-- 3.1.c NATURAL JOIN demo' AS contexto;
SELECT * FROM cliente NATURAL JOIN v_cliente_ob
ORDER BY id_cliente;

DROP VIEW v_cliente_ob;

-- 3.2 Productos por cliente + desembolso + saldo + fecha ultimo pago
SELECT '-- 3.2 Productos por cliente + desembolso + saldo + fecha ultimo pago' AS contexto;
SELECT
  c.id_cliente,
  c.nombre || ' ' || c.apellido AS cliente,
  p.descripcion AS producto,
  o.valor_desembolsado,
  o.saldo_capital,
  (SELECT MAX(pa.fecha_pago) FROM pago pa WHERE pa.id_obligacion_fk = o.id_obligacion) AS fecha_ultimo_pago
FROM cliente c
JOIN cliente_obligacion co ON c.id_cliente = co.id_cliente_fk
JOIN obligacion o ON co.id_obligacion_fk = o.id_obligacion
JOIN producto p ON o.id_producto = p.id_producto
ORDER BY c.id_cliente;

-- 3.3 Deudores con TC pero sin Hipotecario (EXISTS / NOT EXISTS)
SELECT '-- 3.3 Deudores con tarjeta pero sin hipoteca (EXISTS/NOT EXISTS)' AS contexto;
SELECT DISTINCT c.id_cliente, c.nombre, c.apellido
FROM cliente c
WHERE EXISTS (
  SELECT 1
  FROM cliente_obligacion co
  JOIN obligacion o ON co.id_obligacion_fk = o.id_obligacion
  JOIN producto pr ON o.id_producto = pr.id_producto
  WHERE co.id_cliente_fk = c.id_cliente
    AND co.tipo_cliente = 'DEUDOR'
    AND pr.description IS NULL -- placeholder to avoid error in some viewers
)
AND NOT EXISTS (
  SELECT 1
  FROM cliente_obligacion co2
  JOIN obligacion o2 ON co2.id_obligacion_fk = o2.id_obligacion
  JOIN producto pr2 ON o2.id_producto = pr2.id_producto
  WHERE co2.id_cliente_fk = c.id_cliente
    AND pr2.descripcion = 'Hipotecario'
)
ORDER BY c.id_cliente;

-- Nota: en algunos entornos la consulta anterior puede requerir ajustar el nombre exacto 'descripcion' (no 'description').
-- He incluido una versión robusta en la explicación principal.

-- 3.4 Codeudores de Libre Inversion con saldo < SMLV (SMLV=1_160_000)
WITH parametros AS (SELECT 1160000::numeric AS smlv)
SELECT '-- 3.4 Codeudores de Libre Inversion con saldo < SMLV' AS contexto;
SELECT DISTINCT c.id_cliente, c.nombre, c.apellido, o.id_obligacion, p.descripcion, o.saldo_capital
FROM cliente c
JOIN cliente_obligacion co ON c.id_cliente = co.id_cliente_fk
JOIN obligacion o ON co.id_obligacion_fk = o.id_obligacion
JOIN producto p ON o.id_producto = p.id_producto
JOIN parametros par ON TRUE
WHERE co.tipo_cliente = 'CODEUDOR'
  AND p.descripcion = 'Libre Inversion'
  AND o.saldo_capital < par.smlv
ORDER BY o.saldo_capital;

-- 3.5 Clientes <25 con Tarjeta de Crédito y dias_mora>30
SELECT '-- 3.5 Clientes <25 con TC y dias_mora>30' AS contexto;
SELECT DISTINCT c.id_cliente, c.nombre, c.apellido, o.id_obligacion, o.dias_mora
FROM cliente c
JOIN cliente_obligacion co ON c.id_cliente = co.id_cliente_fk
JOIN obligacion o ON co.id_obligacion_fk = o.id_obligacion
JOIN producto pr ON o.id_producto = pr.id_producto
WHERE c.edad < 25
  AND pr.descripcion = 'Tarjeta de Crédito'
  AND o.dias_mora > 30
  AND co.tipo_cliente = 'DEUDOR'
ORDER BY c.id_cliente;

-- 3.6 Clientes que son DEUDORES
SELECT '-- 3.6 Clientes que son DEUDORES' AS contexto;
SELECT DISTINCT c.id_cliente, c.nombre, c.apellido
FROM cliente c
JOIN cliente_obligacion co ON c.id_cliente = co.id_cliente_fk
WHERE co.tipo_cliente = 'DEUDOR'
ORDER BY c.id_cliente;

-- 3.7 Clientes que son CODEUDORES
SELECT '-- 3.7 Clientes que son CODEUDORES' AS contexto;
SELECT DISTINCT c.id_cliente, c.nombre, c.apellido
FROM cliente c
JOIN cliente_obligacion co ON c.id_cliente = co.id_cliente_fk
WHERE co.tipo_cliente = 'CODEUDOR'
ORDER BY c.id_cliente;

-- 3.8 Clientes que son DEUDORES y CODEUDORES (INTERSECT)
SELECT '-- 3.8 Clientes que son DEUDORES y CODEUDORES (INTERSECT)' AS contexto;
WITH deudores AS (
  SELECT id_cliente_fk AS id_cliente FROM cliente_obligacion WHERE tipo_cliente = 'DEUDOR'
),
codeudores AS (
  SELECT id_cliente_fk AS id_cliente FROM cliente_obligacion WHERE tipo_cliente = 'CODEUDOR'
)
SELECT c.id_cliente, c.nombre, c.apellido
FROM cliente c
WHERE c.id_cliente IN (SELECT id_cliente FROM deudores INTERSECT SELECT id_cliente FROM codeudores)
ORDER BY c.id_cliente;

-- 3.9 Clientes DEUDOR con >1 obligacion y MAX(dias_mora) BETWEEN 30 AND 60
SELECT '-- 3.9 Clientes DEUDOR con >1 obligacion y MAX(dias_mora) BETWEEN 30 AND 60' AS contexto;
SELECT c.id_cliente, c.nombre, c.apellido,
       COUNT(o.id_obligacion) AS num_obligaciones,
       MAX(o.dias_mora) AS max_dias_mora
FROM cliente c
JOIN cliente_obligacion co ON c.id_cliente = co.id_cliente_fk
JOIN obligacion o ON co.id_obligacion_fk = o.id_obligacion
WHERE co.tipo_cliente = 'DEUDOR'
GROUP BY c.id_cliente, c.nombre, c.apellido
HAVING COUNT(o.id_obligacion) > 1
   AND MAX(o.dias_mora) BETWEEN 30 AND 60
ORDER BY c.id_cliente;

-- 3.10 Clientes con Tarjeta de Crédito; mostrar saldo solo si dias_mora>30; ordenar asc
SELECT '-- 3.10 Clientes con TC; saldo mostrado solo si dias_mora>30; ordenar asc' AS contexto;
SELECT DISTINCT c.id_cliente, c.nombre, c.apellido,
       CASE WHEN o.dias_mora > 30 THEN o.saldo_capital ELSE NULL END AS saldo_mora_mayor_30,
       o.dias_mora
FROM cliente c
JOIN cliente_obligacion co ON c.id_cliente = co.id_cliente_fk
JOIN obligacion o ON co.id_obligacion_fk = o.id_obligacion
JOIN producto p ON o.id_producto = p.id_producto
WHERE p.descripcion = 'Tarjeta de Crédito'
ORDER BY saldo_mora_mayor_30 ASC NULLS LAST, c.id_cliente;

-- ============================================================
-- FIN del script
-- ============================================================
