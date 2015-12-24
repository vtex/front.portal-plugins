window.vtex = window.vtex or {}
window.vtex.i18n = window.vtex.i18n or {}

minicartLang =
  minicartPlugin:
    availableShippingOptions: "Opções de entrega disponíveis:"
    availableDays: "Dias disponíveis:"
    chooseDate: "Escolha uma data"
    availableHour: "Horário disponível:"
    availableHours: "Horários disponíveis:"
    from: "Das"
    to: "às"
    nextAvailableWindows: "Próximas entregas disponíveis:"
    loading: "Carregando..."
    of: "de"
    "Sun": "Domingo"
    "Mon": "Segunda-feira"
    "Tue": "Terça-feira"
    "Wed": "Quarta-feira"
    "Thu": "Quinta-feira"
    "Fri": "Sexta-feira"
    "Sat": "Sábado"
    "Jan": "Janeiro"
    "Feb": "Fevereiro"
    "Mar": "Março"
    "Apr": "Abril"
    "May": "Maio"
    "Jun": "Junho"
    "Jul": "Julho"
    "Aug": "Agosto"
    "Sep": "Setembro"
    "Oct": "Outubro"
    "Nov": "Novembro"
    "Dec": "Dezembro"

if window.vtex.i18n["pt-BR"]
  window.vtex.i18n["pt-BR"] = $.extend(window.vtex.i18n["pt-BR"], minicartLang)
else
  window.vtex.i18n["pt-BR"] = minicartLang
