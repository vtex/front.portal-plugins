window.vtex = window.vtex or {}
window.vtex.i18n = window.vtex.i18n or {}

minicartLang =
  minicartPlugin:
    availableShippingOptions: "Opciones de entrega disponibles:"
    availableDays: "Días disponibles:"
    chooseDate: "Elija una fecha"
    availableHour: "Horario disponible:"
    availableHours: "Horarios disponibles:"
    from: "De"
    to: "a"
    nextAvailableWindows: "Próximas entregas disponibles:"
    loading: "Cargando..."
    of: "de"
    "Sun": "Domingo"
    "Mon": "Lunes"
    "Tue": "Martes"
    "Wed": "Miércoles"
    "Thu": "Jueves"
    "Fri": "Viernes"
    "Sat": "Sábado"
    "Jan": "Enero"
    "Feb": "Febrero"
    "Mar": "Marzo"
    "Apr": "Abril"
    "May": "Mayo"
    "Jun": "Junio"
    "Jul": "Julio"
    "Aug": "Agosto"
    "Sep": "Septiembre"
    "Oct": "Octubre"
    "Nov": "Noviembre"
    "Dec": "Diciembre"

if window.vtex.i18n["es"]
  window.vtex.i18n["es"] = $.extend({}, window.vtex.i18n["es"], minicartLang)
else
  window.vtex.i18n["es"] = minicartLang
