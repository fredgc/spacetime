# Política de Privacidad de Spacetime Drawing Tool

*Última actualización: 31 de octubre de 2026*

---

## Cero Datos Personales y Privacidad por Diseño

**Spacetime Drawing Tool** ("la Aplicación") es una aplicación educativa
interactiva diseñada para construir, explorar y visualizar experimentos
mentales de relatividad especial. Nos adherimos a una estricta **Privacidad
por Diseño**: no recopilamos información personal, no requerimos el registro
de cuentas para usar la herramienta, no realizamos seguimiento entre sitios
web y no vendemos ni monetizamos datos de los usuarios.

Esta aplicación estácreada para estudiantes, docentes, investigadores y
entusiastas de la relatividad de todas las edades.

---

## Información que NO recopilamos

Para mantener una arquitectura con cero datos personales:

* **Sin cuentas de usuario obligatorias:** Puede crear, editar, animar y
  descargar diagramas de espaciotiempo sin registrar una cuenta.

* **Sin sensores de dispositivo ni permisos invasivos:** La Aplicación no
  accede a la ubicación del dispositivo (GPS), cámara, micrófono, contactos ni
  sensores biométricos.

* **Sin publicidad ni seguimiento entre sitios:** La Aplicación carece de
  publicidad y no contiene redes publicitarias, rastreadores de marketing ni
  SDKs de analítica comercial.

---

## Datos gestionados por la Aplicación

### 1. Ajustes y preferencias locales

* Las preferencias como su modo de tema preferido (claro, oscuro o del
  sistema), visibilidad de la cuadrícula, velocidad de reproducción de la
  animación y opciones de vista de transformación se almacenan exclusivamente
  en su dispositivo usando `localStorage` del navegador (en la Web) o
  `SharedPreferences` (en Android y escritorio).

* En la Web, borrar los datos de navegación elimina estas preferencias. En
  Android, desinstalar la aplicación elimina todas las preferencias
  almacenadas.

### 2. Archivos de diagramas y almacenamiento

* **Almacenamiento local del dispositivo:** Los archivos de diagramas de
  espaciotiempo (`.json`) se pueden descargar y abrir directamente en su
  dispositivo local.

* **Integración opcional con Google Drive:** Si decide conectar su cuenta de
  Google Drive para guardar o abrir diagramas, la Aplicación utiliza la API
  oficial de Google Driveúnicamente para acceder a los archivos creados por o
  abiertos explícitamente con esta Aplicación. Ningún contenido de diagrama,
  credencial o metadato de archivo se transmite ni almacena en servidores de
  `gchouse.org`.

* **Enlaces compartidos:** Si comparte una URL de diagrama que contenga datos
  de escena serializados, dichos datos se codifican directamente en el
  fragmento de la URL y son procesados localmente por el navegador del
  destinatario.

---

## Infraestructura de terceros

La Aplicación se aloja estáticamente mediante **Google Firebase Hosting**
(Google LLC):

* Los metadatos de conexión técnica estándar (como direcciones IP y
  encabezados de solicitudes HTTP) son procesados temporalmente por la
  infraestructura de Google Cloud estrictamente por motivos de enrutamiento,
  seguridad y prevención de denegación de servicio.

* Para obtener más información sobre las prácticas de privacidad de Google,
  consulte la
  [Política de Privacidad de Google](https://policies.google.com/privacy) .

---

## Seguro para niños y aulas escolares (COPPA y FERPA)

La Aplicación estádiseñada para cumplir plenamente con las normativas de
privacidad educativa:

* **COPPA (Ley de Protección de la Privacidad Infantil en Internet):** La
  Aplicación no recopila información personal de niños menores de 13 años.

* **FERPA (Ley de Derechos Educativos y Privacidad de la Familia):** Debido a
  que no se recopilan, mantienen ni comparten registros educativos de
  estudiantes ni identificadores personales, la Aplicación puede usarse de
  forma segura en aulas escolares y universitarias.

---

## Preguntas y contacto

Spacetime Drawing Tool es un proyecto educativo de código abierto. Si tiene
preguntas o comentarios sobre esta Política de Privacidad:

* **Abra un issue en GitHub:**
  [https://github.com/fredgc/spacetime/issues](https://github.com/fredgc/spacetime/issues)

* **Visite GC House:** [https://www.gchouse.org](https://www.gchouse.org)
