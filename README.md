# Tarea Cobranzas - Sistema de Gestión de Obligaciones 💳

**Base de Datos: PostgreSQL** | **Script DDL + Consultas de Análisis**

## 📋 Descripción

Sistema completo de gestión de cobranzas que incluye clientes, productos financieros, obligaciones y pagos. Implementa un modelo relacional robusto para análisis de cartera y seguimiento de mora.

## 🗄️ Estructura de Base de Datos

### Tablas Principales

- **`cliente`** - Información personal de clientes
- **`producto`** - Catálogo de productos financieros  
- **`obligacion`** - Detalles de préstamos y créditos
- **`cliente_obligacion`** - Relación cliente-obligación (DEUDOR/CODEUDOR)
- **`pago`** - Registro histórico de pagos

### Modelo de Datos
```
cliente (1:N) cliente_obligacion (N:1) obligacion (N:1) producto
                                           ↓ (1:N)
                                         pago
```

## 🚀 Ejecución

```bash
psql -d tu_base_datos -f tarea_cobranzas.sql
```

## 📊 Productos Incluidos

- **TC-VISA**: Tarjeta de Crédito
- **HIP-1**: Hipotecario  
- **LIB-INV**: Libre Inversión
- **PR-OTRO**: Otro Producto

## 🔍 Consultas Implementadas

### 3.1 Tipos de JOIN
- **LEFT JOIN**: Clientes con posibles obligaciones
- **RIGHT JOIN**: Obligaciones con posibles clientes
- **CROSS JOIN**: Producto cartesiano (limitado)
- **FULL JOIN**: Unión completa
- **INNER JOIN**: Solo registros coincidentes
- **NATURAL JOIN**: Unión por columnas comunes

### 3.2 Análisis por Cliente
- Productos por cliente
- Valor desembolsado y saldo actual
- Fecha último pago

### 3.3 Filtros con EXISTS/NOT EXISTS
- Deudores con TC pero sin Hipotecario

### 3.4 Análisis de Codeudores
- Codeudores de Libre Inversión con saldo < SMLV

### 3.5 Análisis de Mora
- Clientes <25 años con TC y mora >30 días

### 3.6 Clasificación de Clientes
- Identificación de DEUDORES vs CODEUDORES

## 💰 Métricas Clave

- **Saldo Capital**: Monto pendiente por pagar
- **Días Mora**: Indicador de riesgo crediticio
- **Interés Corriente**: Tasa normal aplicada
- **Interés Mora**: Tasa por atraso en pagos

## 📈 Casos de Uso

1. **Gestión de Cartera**: Seguimiento de obligaciones activas
2. **Análisis de Riesgo**: Identificación de clientes en mora
3. **Reportes Regulatorios**: Clasificación por tipo de cliente
4. **Cobranza**: Priorización por días de mora y saldo

## 🔧 Características Técnicas

- **SGBD**: PostgreSQL
- **Integridad Referencial**: Claves foráneas y restricciones
- **Validaciones**: CHECK constraints para datos críticos
- **Índices**: Claves primarias automáticas (SERIAL)
- **Datos de Prueba**: 8 clientes, 4 productos, 7 obligaciones

## 📋 Requisitos

- PostgreSQL 12+
- Permisos de creación de tablas
- Aproximadamente 2MB de espacio

---

**© 2024 Sistema de Cobranzas - Análisis de Cartera Financiera**