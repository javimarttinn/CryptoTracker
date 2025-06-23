# 📱 CryptoTracker

<div align="center">

![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)
![iOS](https://img.shields.io/badge/iOS-15.0+-blue.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-Framework-green.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

*Una aplicación iOS moderna para el seguimiento de criptomonedas en tiempo real*

[Características](#-características) • [Instalación](#-instalación) • [Uso](#-uso) • [Arquitectura](#-arquitectura) • [API](#-api)

</div>

---

## 📋 Descripción

CryptoTracker es una aplicación iOS nativa desarrollada en SwiftUI que permite a los usuarios monitorear el precio de las criptomonedas más importantes del mercado. La aplicación utiliza la API de CoinGecko para obtener datos actualizados en tiempo real y ofrece funcionalidades como favoritos, búsqueda manual y visualización de gráficos históricos.

## ✨ Características

### 🏠 Pantalla Principal
- **Top 5 Criptomonedas**: Muestra las 5 criptomonedas más importantes por capitalización de mercado
- **Monedas Personalizadas**: Visualiza las criptomonedas añadidas manualmente por el usuario
- **Soporte Multi-divisa**: Cambio entre EUR y USD en tiempo real
- **Información Detallada**: Precio actual, variación 24h, logo y símbolo

### ⭐ Sistema de Favoritos
- **Gestión de Favoritos**: Marca/desmarca criptomonedas como favoritas
- **Lista Dedicada**: Acceso rápido a tus criptomonedas favoritas
- **Persistencia**: Los favoritos se mantienen entre sesiones

### 🔍 Búsqueda Avanzada
- **Búsqueda en Tiempo Real**: Busca por nombre o símbolo de criptomoneda
- **Integración con API**: Resultados actualizados desde CoinGecko
- **Añadir a Lista**: Incorpora nuevas criptomonedas a tu lista principal

### 📊 Vista Detallada
- **Información Completa**: Precio, capitalización, volumen, máximos/mínimos
- **Gráficos Históricos**: Visualización de precios en períodos de 30, 90 y 365 días
- **Gestión de Favoritos**: Añade/elimina desde la vista detallada

### 🗑️ Gestión de Lista
- **Eliminación por Deslizamiento**: Remueve criptomonedas manualmente añadidas
- **Sin Duplicados**: Previene la duplicación de monedas en la lista

## 🚀 Instalación

### Requisitos del Sistema
- **Xcode**: 14.0 o superior
- **iOS**: 15.0 o superior
- **Swift**: 5.7 o superior

### Pasos de Instalación

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/tuusuario/CryptoTracker.git
   cd CryptoTracker
   ```

2. **Abrir en Xcode**
   ```bash
   open CryptoTracker.xcodeproj
   ```

3. **Configurar dependencias**
   - El proyecto utiliza frameworks nativos de iOS
   - No requiere dependencias externas adicionales

4. **Ejecutar la aplicación**
   - Selecciona tu dispositivo o simulador
   - Presiona `Cmd + R` para compilar y ejecutar

## 📱 Uso

### Inicio Rápido

1. **Selección de Divisa**
   - Al abrir la app, selecciona entre EUR o USD en la parte superior
   - Todos los precios se mostrarán en la divisa seleccionada

2. **Explorar Criptomonedas**
   - Navega por la lista de las top 5 criptomonedas
   - Toca cualquier moneda para ver detalles completos

3. **Añadir Favoritos**
   - En la vista detallada, toca el ícono de estrella
   - Accede a tus favoritos desde el botón "Ver Favoritos"

4. **Búsqueda Manual**
   - Toca el ícono de lupa para buscar nuevas criptomonedas
   - Añade las que te interesen a tu lista principal

### Gestos y Navegación

- **Deslizar izquierda**: Eliminar criptomoneda añadida manualmente
- **Tocar fila**: Abrir vista detallada
- **Tocar estrella**: Añadir/quitar de favoritos
- **Seleccionar período**: Cambiar rango de gráfico histórico

## 🏗️ Arquitectura

### Estructura del Proyecto

```
CryptoTracker/
├── Models/
│   ├── CryptoID.swift          # Modelo para IDs de criptomonedas manuales
│   ├── CryptoFavorite.swift    # Modelo para favoritos
│   └── CryptoData.swift        # Modelo principal de datos
├── Views/
│   ├── MainView.swift          # Vista principal
│   ├── DetailView.swift        # Vista detallada
│   ├── FavoritesView.swift     # Lista de favoritos
│   └── SearchView.swift        # Búsqueda manual
├── Services/
│   └── API.swift               # Gestión de peticiones a CoinGecko
├── Managers/
│   └── DataManager.swift       # Gestión de SwiftData
└── Resources/
    └── Assets.xcassets
```

### Tecnologías Utilizadas

- **SwiftUI**: Framework de interfaz de usuario
- **SwiftData**: Persistencia de datos local
- **Combine**: Programación reactiva
- **URLSession**: Peticiones HTTP
- **JSONDecoder**: Decodificación de respuestas JSON

### Flujo de Datos

1. **Inicialización**
   - Carga top 5 criptomonedas desde CoinGecko API
   - Sincroniza IDs guardados en SwiftData con datos actuales
   - Precarga arrays separados para EUR y USD

2. **Gestión de Estado**
   - Estados reactivos con `@State` y `@ObservedObject`
   - Actualización automática de vistas al cambiar datos

3. **Persistencia**
   - **CryptoID**: Almacena IDs de monedas añadidas manualmente
   - **CryptoFavorite**: Almacena IDs de favoritos
   - Sincronización automática entre SwiftData y API

## 🔌 API

### CoinGecko Integration

La aplicación utiliza la API gratuita de CoinGecko con las siguientes características:

#### Endpoints Utilizados

```swift
// Obtener top criptomonedas
GET /api/v3/coins/markets?vs_currency={currency}&order=market_cap_desc&per_page=5

// Búsqueda de criptomonedas
GET /api/v3/search?query={searchTerm}

// Datos históricos
GET /api/v3/coins/{id}/market_chart?vs_currency={currency}&days={days}
```

#### Limitaciones

⚠️ **Cuenta Demo**: La aplicación usa una cuenta demo con limitaciones:
- **Rate Limiting**: Límite estricto de solicitudes por minuto
- **Manejo de Errores**: Mensajes informativos cuando se alcanza el límite
- **Recomendación**: Para uso en producción, considera upgrading a una cuenta premium

#### Estructura de Respuesta

```json
{
  "id": "bitcoin",
  "symbol": "btc",
  "name": "Bitcoin",
  "current_price": 45000.32,
  "market_cap": 850000000000,
  "price_change_percentage_24h": 2.5,
  "image": "https://assets.coingecko.com/coins/images/1/large/bitcoin.png"
}
```

## 🛠️ Configuración para Desarrolladores

### Variables de Entorno

```swift
// API.swift
private let baseURL = "https://api.coingecko.com/api/v3"
private let apiKey = "tu-api-key-aqui" // Opcional para cuenta premium
```

### Manejo de Errores

```swift
enum APIError: Error {
    case rateLimitExceeded
    case networkError
    case decodingError
    case unknownError
}
```

## 📝 Roadmap

- [ ] Soporte para más divisas (GBP, JPY, etc.)
- [ ] Notificaciones push para alertas de precios
- [ ] Modo oscuro/claro
- [ ] Widget para pantalla de inicio
- [ ] Soporte para watchOS
- [ ] Análisis técnico avanzado

## 🐛 Problemas Conocidos

- **Rate Limiting**: Posibles delays debido a limitaciones de la API demo
- **Conectividad**: Requiere conexión a internet para funcionar
- **Rendimiento**: Optimizaciones pendientes para listas grandes

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

---

<div align="center">

**¿Te gusta el proyecto? ¡Dale una ⭐!**

[Reportar Bug](../../issues) • [Solicitar Feature](../../issues) • [Documentación](../../wiki)

</div>
