# buZfinance 💰📈

> **Aplicación de Finanzas Personales, Planificación Patrimonial Plurianual y Simulador de Interés Compuesto.**  
> *100% Offline-First, Privacidad Absoluta con Cifrado Militar AES-256-GCM y Cero Dependencias Externas.*

---

## 🌟 Descripción General

**buZfinance** es una solución fintech moderna diseñada para el control exhaustivo de finanzas personales, ahorro sistemático e inversión a medio y largo plazo. 

A diferencia de las aplicaciones bancarias tradicionales, **buZfinance no se conecta a ningún servidor externo ni recopila telemetría**: funciona íntegramente en el navegador de tu dispositivo (PC, tablet o móvil Android) mediante tecnología PWA (*Progressive Web App*) y está completamente optimizada para instalarse como aplicación nativa en formato APK.

---

## ✨ Características Principales

### 1. 📊 Panel de Control Patrimonial (Inicio)
* **Patrimonio Neto Global en tiempo real**: Suma consolidada de efectivo en cuenta corriente, saldo acumulado en cuenta de ahorro remunerada y valor de mercado de tu cartera de inversiones.
* **Métrica Delta ($\Delta$)**: Comparativa patrimonial automática respecto al mes anterior con indicador visual de crecimiento o contracción.
* **Métricas Clave de Liquidez**: Ratio de colchón de seguridad, capacidad de ahorro estimada y rentabilidad media anual ponderada.

### 2. 🗓️ Planificación Patrimonial y Seguimiento Plurianual
* **Horizonte Flexible (36 a 60+ meses)**: Proyección cronológica mes a mes que calcula con rigor matemático:
  * Ingreso por nómina y complementos.
  * Gastos categorizados y cuota hipotecaria.
  * Capacidad de ahorro bruta y ahorro líquido remanente.
  * Traspasos periódicos a cuenta remunerada.
  * Rendimientos brutos y netos con retención fiscal del 19%.
  * Saldo final de tesorería y colchón remunerado.
* **Evolución Salarial Año por Año**:
  * Configuración directa en **euros netos** para cada año de tu plan (ej. 2026, 2027, 2028...).
  * **Herencia en cascada**: si dejas un año futuro en blanco, mantiene automáticamente el sueldo del año anterior sin forzarte a adivinar porcentajes.
  * Cálculo y visualización informativa de la variación interanual ($\Delta\%$) en tiempo real.
* **Gestor de Pagas Extras y Bonus**:
  * Configura importes exactos en euros para los meses que correspondan (ej. $+1.200\text{ €}$ en junio, $+1.200\text{ €}$ en diciembre, $+1.200\text{ €}$ de beneficios en marzo).
  * El motor inyecta automáticamente los ingresos extraordinarios en sus meses a lo largo de toda la simulación.
* **Hipoteca Fija y Variable**:
  * Selección de tipo de préstamo (*Fija* o *Variable*).
  * Para hipotecas variables: mes de revisión anual (1 a 12) y nueva cuota estimada post-revisión.
* **Edición Puntual por Mes (*Overrides*)**:
  * Libertad absoluta: haz clic en cualquier celda de la tabla de seguimiento para fijar un importe específico en un mes puntual.

### 3. 🏷️ Control y Análisis Inteligente de Gastos
* Registro rápido de transacciones con categoría, fecha, descripción e importe.
* **Filtros Temporales**: Conmutador dinámico para consultar gastos por **Mes** o por **Año completo**.
* **Tarjeta Top Gastos con Podio**: Deducción automática de los gastos más representativos del periodo (#1 Oro, #2 Plata, #3 Bronce) con cálculo del porcentaje que suponen sobre el total.
* **Buscador en Tiempo Real** y filtros reactivos por categorías personalizables.
* **Ordenación Bidireccional**: Por mayor importe o por fecha más reciente.

### 4. 🚀 Inversiones e Interés Compuesto
* **Cartera de Activos Múltiples**: Gestión de fondos indexados, acciones, planes de pensiones, depósitos, criptomonedas o inmobiliario.
* **Simulador Compuesto a 1–20 Años**: Gráfico dual interactivo trazado mediante Canvas nativo que compara el **Capital aportado** frente al **Crecimiento compuesto con rentabilidad acumulada**.
* **Distribución de Cartera (*Asset Allocation*)**: Gráfico doughnut con el peso porcentual de cada producto sobre el total invertido.
* **Cotizaciones en Tiempo Real**: Consulta de precios con sistema de fallback resiliente.

### 5. 🔐 Seguridad y Privacidad Absoluta
* **Datos por defecto a 0**: Inicialización limpia sin datos personales ni registros previos preconfigurados.
* **Cifrado Militar AES-256-GCM**: Cifrado opcional con PIN de 4 dígitos ejecutado de forma nativa en tu procesador con Web Crypto API y derivación de claves PBKDF2 (100.000 iteraciones con sal criptográfica).
* **Pantalla de Bloqueo PIN**: Teclado numérico táctil interactivo con soporte para teclado físico de escritorio.
* **Copias de Seguridad Portables**: Exportación e importación local en formato `.json` cifrado o en texto plano según el modo elegido.

---

## 🛠️ Arquitectura y Tecnologías

La aplicación está construida bajo los principios de máxima ligereza, cero dependencias y autonomía absoluta:

* **Frontend**: HTML5 semántico, CSS3 moderno (Variables CSS, Flexbox, Grid, diseño oscuro *luxury obsidian/emerald*) y Vanilla JavaScript (ES6+).
* **Gráficos**: Canvas API 2D nativo sin librerías externas pesadas.
* **Criptografía**: Web Crypto API nativa del estándar W3C (`window.crypto.subtle`).
* **Offline / PWA**: Service Worker (`service-worker.js`) con estrategia *Network First con fallback a Caché offline* y Web App Manifest (`manifest.json`).
* **Iconografía Fintech**: Iconos vectoriales 3D en oro cepillado sobre esmeralda obsidiana (192px, 512px y 512px maskable).

---

## 🧪 Batería de Pruebas Unitarias

El proyecto incluye dos suites de pruebas automatizadas para garantizar la precisión matemática del motor financiero:

1. **Suite Automatizada de Terminal (`test_engine.ps1`)**:
   * **46 comprobaciones matemáticas y de regresión** ejecutables en PowerShell.
   * Valida: valores iniciales en cero, fórmulas de interés compuesto, cálculo de retenciones del 19%, capacidad de ahorro, cascada de nóminas por año, suma de pagas extras, revisiones hipotecarias y codificación estricta de caracteres UTF-8.
   * Ejecución:
     ```powershell
     powershell -ExecutionPolicy Bypass -File .\test_engine.ps1
     ```

2. **Suite Visual en Navegador (`tests.html`)**:
   * Permite ejecutar todas las pruebas unitarias y de cifrado directamente en la pantalla de cualquier navegador móvil o de escritorio con interfaz gráfica.

---

## 📱 Instalación y Uso

### Como Web App (PWA)
1. Abre el archivo `index.html` en tu navegador favorito (Chrome, Edge, Brave, Safari, Firefox).
2. O súbelo a cualquier alojamiento estático (GitHub Pages, Vercel, Netlify o tu propio servidor).
3. Pulsa sobre el botón del navegador **«Instalar aplicación»** o **«Añadir a la pantalla de inicio»** en tu móvil.

### Como Aplicación Android (.APK)
La PWA cumple al 100% con los estándares de Google para Progressive Web Apps y está preparada para empaquetarse en un archivo `.apk` mediante herramientas oficiales:
* **Bubblewrap CLI (Recomendado por Google)**:
  ```bash
  npm i -g @bubblewrap/cli
  bubblewrap init --manifest=manifest.json
  bubblewrap build
  ```
* **PWABuilder**: Subiendo el manifiesto a [pwabuilder.com](https://www.pwabuilder.com/) para generar el paquete de Android directamente.

---

## 📂 Estructura del Repositorio

```text
├── index.html                 # Aplicación completa (SPA modular offline-first)
├── manifest.json              # Configuración de instalación PWA / Android
├── service-worker.js          # Control de caché offline y sincronización
├── tests.html                 # Suite interactiva de pruebas unitarias en navegador
├── test_engine.ps1            # Suite de 46 pruebas automatizadas en PowerShell
├── icon-192.png               # Icono de la app (192x192)
├── icon-512.png               # Icono de alta resolución (512x512)
├── icon-512-maskable.png      # Icono adaptable para Android (512x512 maskable)
└── README.md                  # Documentación del proyecto
```

---

## 📄 Licencia y Privacidad

* **Privacidad**: Todos tus datos se almacenan exclusivamente en el `localStorage` de tu navegador de forma local o cifrados con tu PIN. Ningún dato viaja por Internet.
* **Licencia**: Proyecto desarrollado para uso personal y gestión financiera privada. Libre de modificar y adaptar según tus necesidades.
